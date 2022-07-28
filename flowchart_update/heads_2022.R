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
get_colors <- function(item_no) {
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

# function to scrape release year given item link
scrape_year <- function(url) {
  if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  item_page <- rvest::read_html(url)
  release_year <- item_page |>
    html_elements("#yearReleasedSec") |>
    html_text()
  release_year
}

# page links for all 2022 heads (3 pages in total)
page_link <- generate_page_links(3, 2022)

# scrape heads data for each page and combine into one
data_all <- purrr::map(page_link, scrape_heads_data, year = 2022)
data_bind <- plyr::ldply(data_all, rbind)

# scrape color data for 2022
colors <- map(data_bind$item_number, get_colors)

# correct colors that are wrong, filter to only flesh tone colors
data_bind2 <- data_bind |>
  mutate(color = colors, color = case_when(
    str_detect(description, "Light Nougat Face") ~ list("Light Nougat"),
    str_detect(description, "Reddish Brown Face") ~ list("Reddish Brown"),
    str_detect(description, "Yellow Face") ~ list("Yellow"),
    TRUE ~ color
  )) |>
  unnest(cols = color) |>
  filter(color %in% skin_colors)

# age keywords
older_keywords <- c(
  "age lines", "crow's feet", "wrinkles", "laugh lines", "eye bags", "gray eyebrows", "facial lines",
  "cheek lines", "forehead lines"
)
child_keywords <- c("child", "baby", "toddler")

# gender keywords
male_keywords <- c(
  "beard", "goatee", "sideburns", "moustache", "stubble", " male", "mutton chops",
  "whiskers", "muttonchops", "soul patch", "bushy"
)

# filter out non-human, classify gender and age based on keywords above
data_bind2 <- data_bind2 |>
  filter(!str_detect(tolower(description), "alien")) |>
  mutate(
    gender = case_when(
      str_detect(tolower(description), "female") ~ "female",
      str_detect(tolower(description), paste(male_keywords, collapse = "|")) ~ "male",
      TRUE ~ "neutral"
    ),
    age = case_when(
      str_detect(tolower(description), paste(older_keywords, collapse = "|")) ~ "older adult",
      str_detect(tolower(description), paste(child_keywords, collapse = "|")) ~ "child",
      TRUE ~ "young adult"
    )
  )

# pivot so that each row is 1 expression (instead of 1 head, since some are dual-sided)
dual_sided <- data_bind2 |>
  mutate(expression = str_replace(description, "Baby / Toddler", "Baby")) |>
  separate(col = expression, into = c("expression1", "expression2"), sep = "/") |>
  pivot_longer(cols = c("expression1", "expression2"), names_to = "Side", values_to = "expression") |>
  filter(!is.na(expression)) |>
  mutate(emotion = case_when(
    str_detect(tolower(expression), "happy") ~ "happy",
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
    TRUE ~ "neutral"
  )) |>
  select(-year, -Side, -expression)

# read in data from past years
past_male <- read_csv(here::here("data", "flowchart", "dori_male.csv"))[1:11] |>
  janitor::clean_names() |>
  select(item_number = item_no, description, color, expression_1, expression_2)

past_female <- read_csv(here::here("data", "flowchart", "dori_female.csv")) |>
  janitor::clean_names() |>
  select(item_number, description, color, expression_1, expression_2)

# combine male and female data from past years, reclassify gender and age
past <- past_male |>
  bind_rows(past_female) |>
  mutate(
    gender = case_when(
      str_detect(tolower(description), "female") ~ "female",
      str_detect(tolower(description), paste(male_keywords, collapse = "|")) ~ "male",
      TRUE ~ "neutral"
    ),
    age = case_when(
      str_detect(tolower(description), paste(older_keywords, collapse = "|")) ~ "older adult",
      str_detect(tolower(description), paste(child_keywords, collapse = "|")) ~ "child",
      TRUE ~ "young adult"
    )
  )

# pivot so that each row is 1 expression
past2 <- past |>
  pivot_longer(cols = c(expression_1, expression_2), names_to = "side", values_to = "emotion") |>
  filter(!is.na(emotion)) |>
  mutate(emotion = tolower(emotion)) |>
  select(-side)

# combine 2022 and past years' dataframe
# dataframe with 1 row / expression
all <- past2 |>
  bind_rows(dual_sided) |>
  mutate(color = case_when(
    color == "Med. Nougat" ~ "Medium Nougat",
    color == "Med. Brown" | color == "Dark Orange" ~ "Reddish Brown",
    TRUE ~ color
  ))

# dataframe with 1 row / unique head
all_unique <- data_bind2 |>
  bind_rows(past) |>
  mutate(color = case_when(
    color == "Med. Nougat" ~ "Medium Nougat",
    color == "Med. Brown" | color == "Dark Orange" ~ "Reddish Brown",
    TRUE ~ color
  ))

# summarize by color, gender, age, and emotion separately
color_summarized <- all_unique |>
  group_by(color) |>
  summarize(count = n())

gender_summarized <- all_unique |>
  group_by(gender) |>
  summarize(count = n())

age_summarized <- all_unique |>
  group_by(age) |>
  summarize(count = n())

emotion_summarized <- all |>
  group_by(emotion) |>
  summarize(count = n())

# summarize everything for making the flowchart
flowchart_summarized <- all |>
  group_by(gender, age, color, emotion) |>
  summarize(count = n()) |>
  ungroup() |>
  complete(gender, age, color, emotion, fill = list(count = 0)) |>
  mutate(has_head = ifelse(count > 0, TRUE, FALSE))

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
  mutate(color = colors, color = case_when(
    str_detect(description, "Light Nougat Face") ~ list("Light Nougat"),
    str_detect(description, "Reddish Brown Face") ~ list("Reddish Brown"),
    str_detect(description, "Yellow Face") ~ list("Yellow"),
    TRUE ~ color
  )) |>
  unnest(cols = color) |>
  filter(color %in% skin_colors) |>
  filter(!str_detect(tolower(description), "alien")) |>
  mutate(
    gender = case_when(
      str_detect(tolower(description), "female") ~ "female",
      str_detect(tolower(description), paste(male_keywords, collapse = "|")) ~ "male",
      TRUE ~ "neutral"
    ),
    age = case_when(
      str_detect(tolower(description), paste(older_keywords, collapse = "|")) ~ "older adult",
      str_detect(tolower(description), paste(child_keywords, collapse = "|")) ~ "child",
      TRUE ~ "young adult"
    )
  )

# pivot so that each row is 1 expression (instead of 1 head, since some are dual-sided)
dual_sided <- data_bind2 |>
  mutate(expression = str_replace(description, "Baby / Toddler", "Baby")) |>
  separate(col = expression, into = c("expression1", "expression2"), sep = "/") |>
  pivot_longer(cols = c("expression1", "expression2"), names_to = "side", values_to = "expression") |>
  filter(!is.na(expression)) |>
  mutate(emotion = case_when(
    str_detect(tolower(expression), "happy|laughing") ~ "happy",
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
    TRUE ~ "neutral"
  )) |>
  select(-year, -side, -expression)

data <- read_csv(here::here("flowchart_heads.csv"))

heads_2021 <- dual_sided |>
  filter(!(map_lgl(item_number, `%in%`, data$item_number))) |>
  mutate(color = case_when(
    color == "Med. Nougat" ~ "Medium Nougat",
    color == "Med. Brown" | color == "Dark Orange" ~ "Reddish Brown",
    color == "Tan" ~ "Light Nougat",
    TRUE ~ color
  )) |>
  mutate(color_code = case_when(
    color == "Yellow" ~ 3,
    color == "Light Nougat" ~ 90,
    color == "Nougat" ~ 28,
    color == "Medium Nougat" ~ 150,
    color == "Reddish Brown" ~ 88,
  ))

# write_csv(heads_2021, "flowchart_heads_2021.csv")

# Read in new data after manual corrections
data_all <- read_csv(here::here("data", "flowchart_data_2022_corrected.csv")) |>
  mutate(emotion = case_when(
    emotion == "smile" ~ "happy",
    emotion == "frown" ~ "sad",
    TRUE ~ emotion
  ))

# summarize aggregate counts by gender, age, color, emotion
flowchart_summary <- data_all |>
  group_by(gender, age, color, emotion) |>
  summarize(count = n()) |>
  ungroup() |>
  complete(gender, age, color, emotion, fill = list(count = 0)) |>
  mutate(has_head = ifelse(count > 0, TRUE, FALSE))

# summarize aggregate proportions by age, gender, color
flowchart_props <- data_all |>
  group_by(gender, age) |>
  mutate(total = n()) |>
  group_by(gender, age, color) |>
  summarize(count = n(), perc = round(100 * count / total)) |>
  distinct()

# write_csv(flowchart_summary, "flowchart_aggregate.csv")

# split aggregate data and make a separate data frame for each gender-age category, pivot to wide format
data_split <- flowchart_summary |>
  select(-has_head) |>
  split(f = list(as.factor(flowchart_summary$gender), as.factor(flowchart_summary$age))) |>
  map(~ select(.x, -c(gender, age))) |>
  map(~ pivot_wider(.x, names_from = color, values_from = count))

# write individual csv files to format into flowchart
map2(data_split, paste0(names(data_split), ".csv"), write_csv)

##  summary graphs

# combine emotion categories
data_all2 <- data_all |>
  mutate(emotion = case_when(
    emotion == "smile" ~ "happy",
    emotion == "frown" ~ "sad",
    TRUE ~ emotion
  ))

# barchart of count of each color by gender and age

gender_color_age <- data_all2 |>
  select(-emotion) |>
  distinct() |>
  group_by(gender, age) |>
  mutate(total = n()) |>
  group_by(gender, color, age) |>
  summarize(count = n(), perc = round(100 * count / total)) |>
  distinct()

g1 <- ggplot(
  gender_color_age,
  aes(
    x = gender,
    y = count,
    fill = factor(color, levels = c("Reddish Brown", "Medium Nougat", "Nougat", "Light Nougat", "Yellow")) # re-order colors
  )
) +
  geom_col(show.legend = FALSE) +
  scale_fill_manual(values = c(
    "Yellow" = "#f3d000",
    "Light Nougat" = "#faccae",
    "Nougat" = "#f8ae79",
    "Medium Nougat" = "#dd9f55",
    "Reddish Brown" = "#843419"
  )) +
  facet_wrap(~ factor(gender_color_age$age, levels = c("child", "young adult", "older adult"))) +
  labs(
    title = "Minifig Head Color Counts by Gender and Age",
    x = "Gender",
    y = "Count",
    fill = "Color"
  )

g1

# barchart of percentage of each color by gender and age
g2 <- ggplot(
  gender_color_age,
  aes(
    x = gender,
    y = perc,
    fill = factor(color, levels = c("Reddish Brown", "Medium Nougat", "Nougat", "Light Nougat", "Yellow")) # re-order colors
  )
) +
  geom_col() +
  facet_wrap(~ factor(gender_color_age$age, levels = c("child", "young adult", "older adult"))) +
  scale_fill_manual(values = c(
    "Yellow" = "#f3d000",
    "Light Nougat" = "#faccae",
    "Nougat" = "#f8ae79",
    "Medium Nougat" = "#dd9f55",
    "Reddish Brown" = "#843419"
  )) +
  labs(
    title = "Minifig Head Color Percentages by Gender and Age (Human Heads Only)",
    x = "Gender",
    y = "Percentage",
    fill = "Color"
  )

g2

# version 2 with combined expressions

flowchart_summary2 <- data_all |>
  mutate(emotion = case_when(
    emotion == "smile" ~ "happy",
    emotion == "frown" ~ "sad",
    TRUE ~ emotion
  )) |>
  group_by(gender, age, color, emotion) |>
  summarize(count = n()) |>
  ungroup() |>
  complete(gender, age, color, emotion, fill = list(count = 0)) |>
  mutate(has_head = ifelse(count > 0, TRUE, FALSE))


# barcharts of emotion by gender
emotions <- data_all2 |>
  group_by(emotion) |>
  mutate(total = n()) |>
  group_by(emotion, gender) |>
  summarize(count = n(), perc = round(100 * count / total)) |>
  distinct()

# emotion counts by gender
p1 <- ggplot(emotions, aes(
  x = reorder(emotion, desc(count)),
  y = count,
  fill = gender
)) +
  geom_col() +
  scale_fill_wbi() +
  labs(
    title = "Emotion Counts by Gender for Minifig Heads",
    x = "Emotion",
    y = "Count",
    fill = "Gender"
  )
p1

# gender percentages by emotions
p2 <- ggplot(emotions, aes(x = reorder(emotion, desc(count)), y = perc, fill = gender)) +
  geom_col() +
  scale_fill_wbi() +
  labs(
    title = "Gender Percentages by Emotion for Minifig Heads",
    x = "Emotion",
    y = "Percentage",
    fill = "Gender"
  )
p2

# barcharts emotion by color
emotion_color <- data_all2 |>
  group_by(emotion) |>
  mutate(total = n()) |>
  group_by(emotion, color) |>
  summarize(count = n(), perc = round(100 * count / total)) |>
  distinct()

# emotion counts by color
p3 <- ggplot(emotion_color, aes(
  x = reorder(emotion, desc(count)),
  y = count,
  fill = factor(color, levels = c("Reddish Brown", "Medium Nougat", "Nougat", "Light Nougat", "Yellow"))
)) +
  geom_col() +
  scale_fill_manual(values = c(
    "Yellow" = "#f3d000",
    "Light Nougat" = "#faccae",
    "Nougat" = "#f8ae79",
    "Medium Nougat" = "#dd9f55",
    "Reddish Brown" = "#843419"
  )) +
  labs(
    title = "Emotion Counts by Color for Minifig Heads",
    x = "Emotion",
    y = "Count",
    fill = "Color"
  )
p3

# color percentages by emotion
p4 <- ggplot(emotion_color, aes(
  x = reorder(emotion, desc(count)),
  y = perc,
  fill = factor(color, levels = c("Reddish Brown", "Medium Nougat", "Nougat", "Light Nougat", "Yellow"))
)) +
  geom_col() +
  scale_fill_manual(values = c(
    "Yellow" = "#f3d000",
    "Light Nougat" = "#faccae",
    "Nougat" = "#f8ae79",
    "Medium Nougat" = "#dd9f55",
    "Reddish Brown" = "#843419"
  )) +
  labs(
    title = "Color Percentages by Emotion for Minifig Heads",
    x = "Emotion",
    y = "Percentage",
    fill = "Color"
  )
p4

# barcharts emotion by age
emotion_age <- data_all2 |>
  group_by(emotion) |>
  mutate(total = n()) |>
  group_by(emotion, age) |>
  summarize(count = n(), perc = round(100 * count / total)) |>
  distinct()

# emotion counts by age
p5 <- ggplot(emotion_age, aes(
  x = reorder(emotion, desc(count)),
  y = count,
  fill = age
)) +
  geom_col() +
  scale_fill_wbi() +
  labs(
    title = "Emotion Counts by Age for Minifig Heads",
    x = "Emotion",
    y = "Count",
    fill = "Age"
  )
p5

# age percentages by emotion
p6 <- ggplot(emotion_age, aes(
  x = reorder(emotion, desc(count)),
  y = perc,
  fill = age
)) +
  geom_col() +
  scale_fill_wbi() +
  labs(
    title = "Age Percentages by Emotion for Minifig Heads",
    x = "Emotion",
    y = "Percentage",
    fill = "Age"
  )
p6

# gender by color
gender_color <- data_all2 |>
  select(-emotion) |>
  distinct() |>
  group_by(gender) |>
  mutate(total = n()) |>
  group_by(gender, color) |>
  summarize(count = n(), perc = round(100 * count / total)) |>
  distinct()

# gender counts by color
p7 <- ggplot(gender_color, aes(
  x = reorder(gender, desc(count)),
  y = count,
  fill = factor(color, levels = c("Reddish Brown", "Medium Nougat", "Nougat", "Light Nougat", "Yellow"))
)) +
  geom_col() +
  scale_fill_manual(values = c(
    "Yellow" = "#f3d000",
    "Light Nougat" = "#faccae",
    "Nougat" = "#f8ae79",
    "Medium Nougat" = "#dd9f55",
    "Reddish Brown" = "#843419"
  )) +
  labs(
    title = "Gender Counts by Color",
    x = "Gender",
    y = "Count",
    fill = "Color"
  )
p7

# color percentages by gender
p8 <- ggplot(gender_color, aes(
  x = reorder(gender, desc(count)),
  y = perc,
  fill = factor(color, levels = c("Reddish Brown", "Medium Nougat", "Nougat", "Light Nougat", "Yellow"))
)) +
  geom_col() +
  scale_fill_manual(values = c(
    "Yellow" = "#f3d000",
    "Light Nougat" = "#faccae",
    "Nougat" = "#f8ae79",
    "Medium Nougat" = "#dd9f55",
    "Reddish Brown" = "#843419"
  )) +
  labs(
    title = "Color Percentages by Gender",
    x = "Gender",
    y = "Percentage",
    fill = "Color"
  )
p8

# get year info
data_all2 <- data_all

data_all2 <- data_all2 |>
  mutate(link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", item_number))

# scrape release years
release_year <- map(data_all2$link, scrape_year)
release_year <- release_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# add release years to data, filter out NAs (109)
data_all3 <- data_all2 |>
  mutate(release_year = release_year) #|>
  # filter(release_year != "NA") |>
  # mutate(release_year = as.numeric(release_year))

data_all3 <- data_all3 |>
  select(-emotion) |>
  distinct()

# Color change over time
color_summarized <- data_all3 |>
  group_by(release_year) |>
  mutate(total = n()) |>
  group_by(release_year, color) |>
  summarize(count = n(), perc = round(100 * count / total)) |>
  ungroup() |>
  complete(release_year, color, fill = list(count = 0)) |>
  distinct() |>
  mutate(perc = ifelse(is.na(perc), 0, perc)) |>
  filter(release_year > 1991)

# line graph color counts over time
l1 <- ggplot(color_summarized, aes(
  x = release_year,
  y = count,
  color = factor(color, levels = c("Reddish Brown", "Medium Nougat", "Nougat", "Light Nougat", "Yellow"))
)) +
  geom_line() +
  scale_color_manual(values = c(
    "Yellow" = "#f3d000",
    "Light Nougat" = "#faccae",
    "Nougat" = "#f8ae79",
    "Medium Nougat" = "#dd9f55",
    "Reddish Brown" = "#843419"
  )) +
  scale_x_continuous(
    breaks = c(1992, 1997, 2002, 2007, 2012, 2017, 2022),
    labels = c(1992, 1997, 2002, 2007, 2012, 2017, 2022)
  ) +
  labs(
    title = "Color Counts Over Time for Minifig Heads",
    x = "Year",
    y = "Count",
    color = "Color"
  )
add_logo(l1)

# line graph color percentages over time
l2 <- ggplot(color_summarized, aes(
  x = release_year,
  y = perc,
  color = factor(color, levels = c("Reddish Brown", "Medium Nougat", "Nougat", "Light Nougat", "Yellow"))
)) +
  geom_line() +
  scale_color_manual(values = c(
    "Yellow" = "#f3d000",
    "Light Nougat" = "#faccae",
    "Nougat" = "#f8ae79",
    "Medium Nougat" = "#dd9f55",
    "Reddish Brown" = "#843419"
  )) +
  scale_x_continuous(
    breaks = c(1992, 1997, 2002, 2007, 2012, 2017, 2022),
    labels = c(1992, 1997, 2002, 2007, 2012, 2017, 2022)
  ) +
  labs(
    title = "Color Percentages Over Time for Minifig Heads",
    x = "Year",
    y = "Percentage",
    color = "Color"
  )
add_logo(l2)

# Gender over time
gender_summarized <- data_all3 |>
  group_by(release_year) |>
  mutate(total = n()) |>
  group_by(release_year, gender) |>
  summarize(count = n(), perc = round(100 * count / total)) |>
  ungroup() |>
  complete(release_year, gender, fill = list(count = 0)) |>
  distinct() |>
  mutate(perc = ifelse(is.na(perc), 0, perc)) |>
  filter(release_year > 1991)

# line graph gender counts over time
l3 <- ggplot(gender_summarized, aes(
  x = release_year,
  y = count,
  color = gender
)) +
  geom_line() +
  scale_color_wbi() +
  scale_x_continuous(
    breaks = c(1992, 1997, 2002, 2007, 2012, 2017, 2022),
    labels = c(1992, 1997, 2002, 2007, 2012, 2017, 2022)
  ) +
  labs(
    title = "Gender Counts Over Time for Minifig Heads",
    x = "Year",
    y = "Count",
    color = "Gender"
  )
add_logo(l3)

# line graph gender percentages over time
l4 <- ggplot(gender_summarized, aes(
  x = release_year,
  y = perc,
  color = gender
)) +
  geom_line() +
  scale_color_wbi() +
  scale_x_continuous(
    breaks = c(1992, 1997, 2002, 2007, 2012, 2017, 2022),
    labels = c(1992, 1997, 2002, 2007, 2012, 2017, 2022)
  ) +
  labs(
    title = "Gender Percentages Over Time for Minifig Heads",
    x = "Year",
    y = "Percentage",
    color = "Gender"
  )
add_logo(l4)


## create individual sheets for options for each category
# split data and make a separate data frame for each gender-age category, pivot to wide format
data_split <- data_all3 |>
  split(f = list(as.factor(data_all3$gender), as.factor(data_all3$age))) |>
  map(~ select(.x, -c(gender, age)))

# write individual csv files to format into flowchart
map2(data_split, paste0(names(data_split), ".csv"), write_csv)


write_csv(data_all3, "flowchart_2022_all")

