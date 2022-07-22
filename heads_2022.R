library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R"))

# function to scrape data from one year summary webpage
scrape_heads_data <- function(url, year) {
  if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")

  webpage <- rvest::read_html(url)

  item_number <- webpage |>
    rvest::html_elements("font:nth-child(1) a:nth-child(2)") |>
    rvest::html_text()
  description <- webpage |>
    rvest::html_elements("#ItemEditForm strong") |>
    rvest::html_text()
  tibble(item_number, description, year = year)
}

# function to create a new url for each additional page beyond the first page
replace_page <- function(pg, url) {
  pg_char <- as.character(pg)
  url_split <- str_split(url, "catType")
  new_url <- paste0(url_split[[1]][[1]], "pg=", pg_char, "&catType", url_split[[1]][[2]])
}

# function to create all urls for each year
generate_page_links <- function(num_pg, year) {
  url <- paste0("https://www.bricklink.com/catalogList.asp?itemYear=", as.character(year), "&catString=238&catType=P")
  if (num_pg == 1L) {
    url_list <- as.list(url)
  } else {
    pages <- 2L:num_pg
    url_list <- map(pages, replace_page, url = url)
    url_list <- c(url, url_list)
  }
  url_list
}

# function to get colors for each head
get_colors <- function(item_no){
  url <- paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", as.character(item_no))
  suppressMessages(
    if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  )
  page <- read_html(url)
  colors <- page |>
    html_elements("#_idColorListAll .pciSelectColorColorItem") |>
    html_attr("data-name")
  colors[-1]
}

# page links for all 2022 heads (3 pages in total)
page_link <- generate_page_links(3, "https://www.bricklink.com/catalogList.asp?itemYear=2022&catString=238&catType=P")

# scrape heads data for each page and combine into one
data_all <- purrr::map(page_link, scrape_heads_data, year = 2022)
data_bind <- plyr::ldply(data_all, rbind)

# scrape color data for 2022
colors <- map(data_bind$item_number, get_colors)

# correct colors that are wrong, filter to only flesh tone colors
data_bind2 <- data_bind |>
  mutate(color = colors,color = case_when(str_detect(description, "Light Nougat Face") ~ list("Light Nougat"),
                                          str_detect(description, "Reddish Brown Face") ~ list("Reddish Brown"),
                                          str_detect(description, "Yellow Face") ~ list("Yellow"),
                                          TRUE ~ color)) |>
  unnest(cols = color) |>
  filter(color %in% skin_colors)

# age keywords
older_keywords <- c("age lines","crow's feet", "wrinkles", "laugh lines", "eye bags", "gray eyebrows", "facial lines",
                    "cheek lines", "forehead lines")
child_keywords <- c("child", "baby", "toddler")

# gender keywords
male_keywords <- c("beard", "goatee", "sideburns", "moustache", "stubble", " male", "mutton chops",
                   "whiskers", "muttonchops", "soul patch", "bushy")

# filter out non-human, classify gender and age based on keywords above
data_bind2 <- data_bind2 |>
  filter(!str_detect(tolower(description), "alien")) |>
  mutate(gender=case_when(
    str_detect(tolower(description), "female") ~ "female",
    str_detect(tolower(description), paste(male_keywords, collapse = "|")) ~ "male",
    TRUE ~ "neutral"),
    age=case_when(
      str_detect(tolower(description), paste(older_keywords, collapse = "|")) ~ "older adult",
      str_detect(tolower(description), paste(child_keywords, collapse = "|")) ~ "child",
      TRUE ~ "young adult")
    )

# pivot so that each row is 1 expression (instead of 1 head, since some are dual-sided)
dual_sided <- data_bind2 |>
  mutate(expression=str_replace(description, "Baby / Toddler", "Baby")) |>
  separate(col = expression, into = c("expression1", "expression2"), sep = "/") |>
  pivot_longer(cols = c("expression1", "expression2"), names_to = "Side", values_to = "expression") |>
  filter(!is.na(expression)) |>
  mutate(emotion=case_when(str_detect(tolower(expression), "happy") ~ "happy",
                           str_detect(tolower(expression), "angry|grimace") ~ "angry",
                           str_detect(tolower(expression), "sad|worried|concerned|confused") ~ "sad",
                           str_detect(tolower(expression), "annoyed|scowl|sneer") ~ "annoyed",
                           str_detect(tolower(expression), "evil|vicious") ~ "evil",
                           str_detect(tolower(expression), "frown") ~ "frown",
                           str_detect(tolower(expression), "scared|terrified") ~ "scared",
                           str_detect(tolower(expression), "sleepy|asleep") ~ "sleepy",
                           str_detect(tolower(expression), "smirk|lopsided grin|raised eyebrow") ~ "smirk",
                           str_detect(tolower(expression), "surprised") ~ "surprised",
                           str_detect(tolower(expression), "smile|grin") ~ "smile",
                           TRUE ~ "neutral")) |>
  select(-year, -Side, -expression)

# read in data from past years
past_male <- read_csv(here::here("data", "flowchart", "dori_male.csv"))[1:11] |>
  janitor::clean_names() |>
  select(item_number=item_no, description, color, expression_1, expression_2)

past_female <- read_csv(here::here("data", "flowchart", "dori_female.csv")) |>
  janitor::clean_names() |>
  select(item_number, description, color, expression_1, expression_2)

# combine male and female data from past years, reclassify gender and age
past <- past_male |>
  bind_rows(past_female) |>
  mutate(gender=case_when(
    str_detect(tolower(description), "female") ~ "female",
    str_detect(tolower(description), paste(male_keywords, collapse = "|")) ~ "male",
    TRUE ~ "neutral"),
    age=case_when(
      str_detect(tolower(description), paste(older_keywords, collapse = "|")) ~ "older adult",
      str_detect(tolower(description), paste(child_keywords, collapse = "|")) ~ "child",
      TRUE ~ "young adult")
  )

# pivot so that each row is 1 expression
past2 <- past |>
  pivot_longer(cols = c(expression_1, expression_2), names_to = "side", values_to = "emotion") |>
  filter(!is.na(emotion)) |>
  mutate(emotion=tolower(emotion)) |>
  select(-side)

# combine 2022 and past years' dataframe
# dataframe with 1 row / expression
all <- past2 |>
  bind_rows(dual_sided) |>
  mutate(color=case_when(color=="Med. Nougat" ~ "Medium Nougat",
                         color=="Med. Brown"|color=="Dark Orange" ~ "Reddish Brown",
                         TRUE ~ color))

# dataframe with 1 row / unique head
all_unique <- data_bind2 |>
  bind_rows(past) |>
  mutate(color=case_when(color=="Med. Nougat" ~ "Medium Nougat",
                         color=="Med. Brown"|color=="Dark Orange" ~ "Reddish Brown",
                         TRUE ~ color))

# summarize by color, gender, age, and emotion separately
color_summarized <- all_unique |>
  group_by(color) |>
  summarize(count=n())

gender_summarized <- all_unique |>
  group_by(gender) |>
  summarize(count=n())

age_summarized <- all_unique |>
  group_by(age) |>
  summarize(count=n())

emotion_summarized <- all |>
  group_by(emotion) |>
  summarize(count=n())

# summarize everything for making the flowchart
flowchart_summarized <- all |>
  group_by(gender, age, color, emotion) |>
  summarize(count=n()) |>
  ungroup() |>
  complete(gender, age, color, emotion, fill = list(count = 0)) |>
  mutate(has_head = ifelse(count>0, TRUE, FALSE))

write_csv(all, "flowchart_heads.csv")



## 2021
# page links for all 2021 heads (5 pages in total)
page_links <- generate_page_links(5, 2021)

# scrape heads data for each page and combine into one
data_2021 <- purrr::map(page_links, scrape_heads_data, year = 2021)
bind_2021 <- plyr::ldply(data_2021, bind_rows)

# scrape color data for 2022
colors <- map(bind_2021$item_number, get_colors)

# correct colors that are wrong, filter to only flesh tone colors
data_bind2 <- bind_2021 |>
  mutate(color = colors,color = case_when(str_detect(description, "Light Nougat Face") ~ list("Light Nougat"),
                                          str_detect(description, "Reddish Brown Face") ~ list("Reddish Brown"),
                                          str_detect(description, "Yellow Face") ~ list("Yellow"),
                                          TRUE ~ color)) |>
  unnest(cols = color) |>
  filter(color %in% skin_colors) |>
  filter(!str_detect(tolower(description), "alien")) |>
  mutate(gender=case_when(
    str_detect(tolower(description), "female") ~ "female",
    str_detect(tolower(description), paste(male_keywords, collapse = "|")) ~ "male",
    TRUE ~ "neutral"),
    age=case_when(
      str_detect(tolower(description), paste(older_keywords, collapse = "|")) ~ "older adult",
      str_detect(tolower(description), paste(child_keywords, collapse = "|")) ~ "child",
      TRUE ~ "young adult")
  )

# pivot so that each row is 1 expression (instead of 1 head, since some are dual-sided)
dual_sided <- data_bind2 |>
  mutate(expression=str_replace(description, "Baby / Toddler", "Baby")) |>
  separate(col = expression, into = c("expression1", "expression2"), sep = "/") |>
  pivot_longer(cols = c("expression1", "expression2"), names_to = "side", values_to = "expression") |>
  filter(!is.na(expression)) |>
  mutate(emotion=case_when(str_detect(tolower(expression), "happy|laughing") ~ "happy",
                           str_detect(tolower(expression), "angry|grimace|clenched teeth") ~ "angry",
                           str_detect(tolower(expression), "sad|worried|concerned|confused") ~ "sad",
                           str_detect(tolower(expression), "annoyed|scowl|sneer") ~ "annoyed",
                           str_detect(tolower(expression), "evil|vicious") ~ "evil",
                           str_detect(tolower(expression), "frown") ~ "frown",
                           str_detect(tolower(expression), "scared|terrified") ~ "scared",
                           str_detect(tolower(expression), "sleepy|asleep|sleeping") ~ "sleepy",
                           str_detect(tolower(expression), "smirk|lopsided grin|raised eyebrow") ~ "smirk",
                           str_detect(tolower(expression), "surprised") ~ "surprised",
                           str_detect(tolower(expression), "smile|grin") ~ "smile",
                           TRUE ~ "neutral")) |>
  select(-year, -side, -expression)

data <- read_csv(here::here("flowchart_heads.csv"))

heads_2021 <- dual_sided |>
  filter(!(map_lgl(item_number, `%in%`, data$item_number))) |>
  mutate(color=case_when(color=="Med. Nougat" ~ "Medium Nougat",
                         color=="Med. Brown"|color=="Dark Orange" ~ "Reddish Brown",
                         color == "Tan" ~ "Light Nougat",
                         TRUE ~ color)) |>
  mutate(color_code = case_when(
    color == "Yellow" ~ 3,
    color == "Light Nougat" ~ 90,
    color == "Nougat" ~ 28,
    color == "Medium Nougat" ~ 150,
    color == "Reddish Brown" ~ 88,
  ))

# write_csv(heads_2021, "flowchart_heads_2021.csv")

# Read in new data after manual corrections

data_all <- read_csv(here::here("data", "flowchart_data_2022_corrected.csv"))

flowchart_summary <- data_all |>
  group_by(gender, age, color, emotion) |>
  summarize(count=n()) |>
  ungroup() |>
  complete(gender, age, color, emotion, fill = list(count = 0)) |>
  mutate(has_head = ifelse(count>0, TRUE, FALSE))

flowchart_props <- data_all |>
  group_by(gender, age) |>
  mutate(total=n()) |>
  group_by(gender, age, color) |>
  summarize(count = n(), perc = round(100*count/total)) |>
  distinct()

# write_csv(flowchart_summary, "flowchart_aggregate.csv")

data_split <- flowchart_summary |>
  select(-has_head) |>
  split(f = list(as.factor(flowchart_summary$gender), as.factor(flowchart_summary$age))) |>
  map(~select(.x, -c(gender, age))) |>
  map(~pivot_wider(.x, names_from = color, values_from = count))

map2(data_split, paste0(names(data_split), ".csv"), write_csv)

# graphs

g1 <- ggplot(flowchart_summary, aes(x = gender, y = count, fill = color)) +
  geom_col() +
  facet_wrap(~factor(flowchart_summary$age, levels = c("child", "young adult", "older adult"))) +
  scale_fill_skintones() +
  labs(title = "Minifig Head Counts by Gender, Age, and Color",
       x = "Gender",
       y = "Count")

add_logo(g1)

g2 <- ggplot(flowchart_props, aes(x = gender, y = perc, fill = color)) +
  geom_col() +
  facet_wrap(~factor(flowchart_props$age, levels = c("child", "young adult", "older adult"))) +
  scale_fill_skintones() +
  # scale_fill_manual(values = c("#f3d000", "#faccae", "#f8ae79", "#dd9f55", "#843419")) +
  labs(title = "Minifig Head Counts by Gender, Age, and Color",
       x = "Gender",
       y = "Percentage")

add_logo(g2)

# version 2 with combined expressions

flowchart_summary2 <- data_all |>
  mutate(emotion = case_when(
    emotion == "smile" ~ "happy",
    emotion == "frown" ~ "sad",
    TRUE ~ emotion
  )) |>
  group_by(gender, age, color, emotion) |>
  summarize(count=n()) |>
  ungroup() |>
  complete(gender, age, color, emotion, fill = list(count = 0)) |>
  mutate(has_head = ifelse(count>0, TRUE, FALSE))

