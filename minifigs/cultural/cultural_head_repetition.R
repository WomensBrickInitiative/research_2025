library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R"))
cultural_data <- read_csv(here::here("data", "cultural_minifigs.csv"))

# function to scrape parts ids and description given item link, returns a dataframe
scrape_parts_description <- function(url) {
  item_page <- rvest::read_html(url)
  parts_id <- item_page |>
    html_elements("td:nth-child(3) a:nth-child(1)") |>
    html_text()
  parts_description <- item_page |>
    html_elements(".IV_ITEM td:nth-child(4) b") |>
    html_text()
  tibble(parts_id, parts_description)
}

# scrape number of minifigs a part is used in
scrape_num_minifigs <- function(url) {
  page <- read_html(url)
  num_minifigs <- page |>
    html_elements(".links:nth-child(5)") |>
    html_text()
  num_minifigs
}

scrape_minifigs_info <- function(url) {
  page <- read_html(url)
  item_number <- page |>
    html_elements("#id-main-legacy-table center td a:nth-child(1)") |>
    html_text()
  item_number <- item_number[item_number != ""]
  description <- page |>
    html_elements("td:nth-child(4) font b") |>
    html_text()
  description <- description[1:144]
  category <- page |>
    html_elements(".fv a:nth-child(4)") |>
    html_text()
  tibble(item_number, description, category)
}

# filter to ninjago
ninjago <- cultural_data |>
  filter(inspiration=="Ninjago"|inspiration=="The LEGO Ninjago Movie") |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(ninjago$parts_link, scrape_parts_description)

# Add parts_info to sets_data and unnest so that each row is a part of the minifig
ninjago_parts <- ninjago |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info)

# filter to only heads, classify heads by gender
heads <- ninjago_parts |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate( # categorize heads to female, male, neutral
    is_female = str_detect(tolower(parts_description), "female"),
    is_male = str_detect(tolower(parts_description), " male") |
      str_detect(tolower(parts_description), "beard") |
      str_detect(tolower(parts_description), "goatee") |
      str_detect(tolower(parts_description), "sideburns") |
      str_detect(tolower(parts_description), "moustache") |
      str_detect(tolower(parts_description), "stubble"),
    type = case_when(
      is_female ~ "female",
      is_male ~ "male",
      TRUE ~ "neutral"
    )
  )

# save one baby head used in 2 ninjago minifigs
baby_head <- ninjago_parts |>
  filter(parts_id == "33464pb01")

# summarize to unique heads, pull number of minifigs used for each head
heads_summarized <- heads |>
  group_by(parts_id) |>
  summarize(count = n()) |>
  # filter(count < 9) |>  # filter out main characters
  mutate(head_link = paste0("https://bricklink.com/v2/catalog/catalogitem.page?P=", parts_id),
         num_minifigs = map_chr(head_link, scrape_num_minifigs)
         )

# add gender info
heads_gender <- heads |>
  filter(parts_id %in% heads_summarized$parts_id) |>
  select(parts_id, type) |>
  distinct()

# calcuate percent of minifigs that are outside of ninjago for each head
heads_summarized2 <- heads_summarized |>
  separate(col = num_minifigs, into = c("num_minifigs", "discard"), sep = " ") |>
  select(-discard) |>
  left_join(heads_gender, by = "parts_id") |>
  mutate(num_minifigs = as.numeric(num_minifigs)) |>
  mutate(num_outside = num_minifigs - count,
         perc_not = 100*round(num_outside/num_minifigs, 2),
         perc_not = ifelse(perc_not < 0, 0, perc_not),
         has_outside = ifelse(perc_not > 0, TRUE, FALSE),
         minifigs_link = paste0("https://www.bricklink.com/catalogItemIn.asp?P=", parts_id ,"&in=M")
         )

# initial summary of counts by gender for heads for comparison
gender <- heads_summarized2 |>
  group_by(type, has_outside) |>
  summarise(count = n())


# filter to only heads used outside of ninjago
heads_filtered <- heads_summarized2 |>
  filter(perc_not > 0)

minifigs_3626cpb0633 <- scrape_minifigs_info("https://www.bricklink.com/catalogItemIn.asp?P=3626cpb0633&in=M")

# count by category
category_summary <- minifigs_3626cpb0633 |>
  group_by(category) |>
  summarize(count = n())

g1 <- ggplot(heads_summarized2, aes(x = perc_not)) +
  geom_histogram(binwidth = 10)
g1

# barchart of counts by gender and whether or not used outside
g2 <- ggplot(gender, aes(x = type, y = count, fill = has_outside)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = count), position = position_dodge(width = 0.8), vjust = -0.2) +
  scale_fill_wbi() +
  labs(title = "Counts for Ninjago Heads by Gender and If Used Outside of Ninjago",
       x = "Gender",
       y = "Number of Heads",
       fill = "Used Outside Ninjago?"
       )
add_logo(g2)

g3 <- ggplot(category_summary, aes(x = reorder(category, count), y = count)) +
  geom_col() +
  coord_flip() +
  labs(title = "Category Distribution for Head 3626cpb0633",
       subtitle = "Out of 144 Total",
       x = "Category",
       y = "Number of Minifigs"
       ) +
  geom_text(aes(label=count), hjust=-0.2)
add_logo(g3)
g3

write_csv(heads_summarized2, "ninjago_repetition.csv")

ninjago_heads <- read_csv(here::here("data", "ninjago_repetition.csv"))
has_outside <- ninjago_heads |>
  filter(num_outside>2) |>
  select(parts_id, num_inside = count, num_outside, type) |>
  pivot_longer(cols = c(num_inside, num_outside), names_to = "in_or_out", values_to = "count")

g4 <- ggplot(has_outside, aes(x=reorder(parts_id, count), y=count, fill=in_or_out)) +
  geom_col() +
  coord_flip() +
  labs(title = "Number of Minifigs in/outside Ninjago per reused head",
       subtitle = "Out of 33 total heads that have been reused more than twice",
       x = "Unique Head",
       y = "Count",
       fill = "Inside Ninjago?") +
  scale_fill_wbi()
g4

# by gender
g5 <- ggplot(has_outside, aes(x=reorder(parts_id, count), y=count, fill=type)) +
  geom_col() +
  coord_flip() +
  labs(title = "Number of Minifigs per reused head",
       subtitle = "Out of 33 total heads that have been reused more than twice",
       x = "Unique Head",
       y = "Count",
       fill = "Gender") +
  scale_fill_wbi()
g5



#### Monkie Kid

# filter to Monkie Kid
mk <- cultural_data |>
  filter(inspiration=="Monkie Kid") |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(mk$parts_link, scrape_parts_description)

# Add parts_info to sets_data and unnest so that each row is a part of the minifig
mk_parts <- mk |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info)

# filter to only heads, classify heads by gender
heads <- mk_parts |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate( # categorize heads to female, male, neutral
    is_female = str_detect(tolower(parts_description), "female"),
    is_male = str_detect(tolower(parts_description), " male") |
      str_detect(tolower(parts_description), "beard") |
      str_detect(tolower(parts_description), "goatee") |
      str_detect(tolower(parts_description), "sideburns") |
      str_detect(tolower(parts_description), "moustache") |
      str_detect(tolower(parts_description), "stubble"),
    type = case_when(
      is_female ~ "female",
      is_male ~ "male",
      TRUE ~ "neutral"
    )
  )

# summarize to unique heads, pull number of minifigs used for each head
heads_summarized <- heads |>
  group_by(parts_id) |>
  summarize(count = n()) |>
  mutate(head_link = paste0("https://bricklink.com/v2/catalog/catalogitem.page?P=", parts_id),
         num_minifigs = map_chr(head_link, scrape_num_minifigs)
  )

# add gender info
heads_gender <- heads |>
  filter(parts_id %in% heads_summarized$parts_id) |>
  select(parts_id, type) |>
  distinct()

# calcuate percent of minifigs that are outside of ninjago for each head
heads_summarized2 <- heads_summarized |>
  separate(col = num_minifigs, into = c("num_minifigs", "discard"), sep = " ") |>
  select(-discard) |>
  left_join(heads_gender, by = "parts_id") |>
  mutate(num_minifigs = as.numeric(num_minifigs)) |>
  mutate(num_outside = num_minifigs - count,
         perc_not = 100*round(num_outside/num_minifigs, 2),
         perc_not = ifelse(perc_not < 0, 0, perc_not),
         has_outside = ifelse(perc_not > 0, TRUE, FALSE),
         minifigs_link = paste0("https://www.bricklink.com/catalogItemIn.asp?P=", parts_id ,"&in=M")
  )

# initial summary of counts by gender for heads for comparison
gender <- heads_summarized2 |>
  group_by(type, has_outside) |>
  summarise(count = n())

# barchart of counts by gender and whether or not used outside
m1 <- ggplot(gender, aes(x = type, y = count, fill = has_outside)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = count), position = position_dodge(width = 0.8), vjust = -0.2) +
  scale_fill_wbi() +
  labs(title = "Counts for Ninjago Heads by Gender and If Used Outside of Monkie Kid",
       x = "Gender",
       y = "Number of Heads",
       fill = "Used Outside Monkie Kid?"
  )
add_logo(m1)

# pivot to long format for barchart of how many minifigs per head are in Monkie Kid
has_outside <- heads_summarized2 |>
  select(parts_id, num_inside = count, num_outside, type) |>
  pivot_longer(cols = c(num_inside, num_outside), names_to = "in_or_out", values_to = "count")

m2 <- ggplot(has_outside, aes(x=reorder(parts_id, count), y=count, fill=in_or_out)) +
  geom_col() +
  coord_flip() +
  labs(title = "Number of Minifigs in/outside Monkie Kid per reused head",
       subtitle = "Out of 30 total heads",
       x = "Unique Head",
       y = "Count",
       fill = "Inside Monkie Kid?") +
  scale_fill_wbi()
add_logo(m2)

# by gender
m3 <- ggplot(has_outside, aes(x=reorder(parts_id, count), y=count, fill=type)) +
  geom_col() +
  coord_flip() +
  labs(title = "Number of Minifigs per head",
       subtitle = "Out of 30 total heads",
       x = "Unique Head",
       y = "Count",
       fill = "Gender") +
  scale_fill_wbi()
add_logo(m3)

# calculate overlap between Monkie Kid and Ninjago
map_lgl(ninjago_heads$parts_id, `%in%`, heads_summarized2$parts_id) |> sum()

## All other Cultural Minifigs

other <- cultural_data |>
  filter(!(inspiration %in% c("Monkie Kid", "Ninjago", "The LEGO Ninjago Movie")))|>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(other$parts_link, scrape_parts_description)

# Add parts_info to sets_data and unnest so that each row is a part of the minifig
other_parts <- other |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info)

# filter to only heads, classify heads by gender
heads <- other_parts |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate( # categorize heads to female, male, neutral
    is_female = str_detect(tolower(parts_description), "female"),
    is_male = str_detect(tolower(parts_description), " male") |
      str_detect(tolower(parts_description), "beard") |
      str_detect(tolower(parts_description), "goatee") |
      str_detect(tolower(parts_description), "sideburns") |
      str_detect(tolower(parts_description), "moustache") |
      str_detect(tolower(parts_description), "stubble"),
    type = case_when(
      is_female ~ "female",
      is_male ~ "male",
      TRUE ~ "neutral"
    )
  )

# summarize to unique heads, pull number of minifigs used for each head
heads_summarized <- heads |>
  group_by(parts_id, region) |>
  summarize(count = n()) |>
  mutate(head_link = paste0("https://bricklink.com/v2/catalog/catalogitem.page?P=", parts_id),
         num_minifigs = map_chr(head_link, scrape_num_minifigs)
  )

# add gender info
heads_gender <- heads |>
  filter(parts_id %in% heads_summarized$parts_id) |>
  select(parts_id, type) |>
  distinct()

# calcuate percent of minifigs that are outside of ninjago for each head
heads_summarized2 <- heads_summarized |>
  separate(col = num_minifigs, into = c("num_minifigs", "discard"), sep = " ") |>
  select(-discard) |>
  left_join(heads_gender, by = "parts_id") |>
  mutate(num_minifigs = as.numeric(num_minifigs)) |>
  mutate(num_outside = num_minifigs - count,
         perc_not = 100*round(num_outside/num_minifigs, 2),
         perc_not = ifelse(perc_not < 0, 0, perc_not),
         has_outside = ifelse(perc_not > 0, TRUE, FALSE),
         minifigs_link = paste0("https://www.bricklink.com/catalogItemIn.asp?P=", parts_id ,"&in=M")
  )


# look at heads that overlap across regions
overlap <- heads_summarized |>
  group_by(parts_id) |>
  summarize(count = n()) |>
  filter(count > 1)

# overlap between Ninjago and other
other_ninjago <- heads_summarized2 |>
  filter(map_lgl(heads_summarized2$parts_id, `%in%`, ninjago_heads$parts_id))

