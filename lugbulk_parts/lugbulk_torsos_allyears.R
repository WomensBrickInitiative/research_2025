library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R")) # file containing functions to customize colors

# read in parts data for each year
data_2022 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2022.csv"))
data_2021 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2021.csv"))
data_2020 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2020.csv"))
data_2019 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2019.csv"))
data_2018 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2018.csv"))
data_2017 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2017.csv"))
data_2016 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2016.csv"))
data_2015 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2015.csv"))

# function to scrape descriptions
get_description <- function(url) {
  page <- read_html(url)
  description <- page |>
    html_elements("#item-name-title") |>
    html_text()
  description
}

# vectorized function to scrape descriptions
get_descriptions <- function(urls) {
  descriptions <- map(urls, get_description)
  descriptions <- descriptions |>
    as.character() %>%
    ifelse(. == "character(0)", "NA", .)
  descriptions
}

# clean up each year so they all have consistent formatting
all_2022 <- data_2022 |>
  janitor::clean_names() |>
  mutate(year = 2022) |>
  select(item_id, item_description, bl_part_id, usd, year)

all_2021 <- data_2021 |>
  janitor::clean_names() |>
  mutate(year = 2021) |>
  select(item_id, item_description, bl_part_id, usd, year)

all_2020 <- data_2020 |>
  janitor::clean_names() |>
  mutate(year = 2020) |>
  rename(item_description = description, bl_part_id = bl_part) |>
  select(item_id, item_description, bl_part_id, usd, year)

all_2019 <- data_2019 |>
  janitor::clean_names() |>
  mutate(year = 2019) |>
  rename(item_id = element_id, item_description = element_name) |>
  mutate(bl_part_id = NA, usd = NA) |>
  select(item_id, item_description, bl_part_id, usd, year)

all_2018 <- data_2018 |>
  janitor::clean_names() |>
  mutate(year = 2018) |>
  rename(brick_link_color = color_name_1, bl_part_id = design_id) |>
  select(item_id, item_description, bl_part_id, usd, year)

all_2017 <- data_2017 |>
  janitor::clean_names() |>
  rename(item_id = element_id, bl_part_id = bl_id, brick_link_color = bl_color) |>
  mutate(year = 2017) |>
  select(item_id, item_description, bl_part_id, usd, year)

all_2016 <- data_2016 |>
  janitor::clean_names() |>
  mutate(year = 2016, usd = NA) |>
  rename(bl_part_id = design_id) |>
  select(item_id, item_description, bl_part_id, usd, year)

all_2015 <- data_2015 |>
  janitor::clean_names() |>
  mutate(year = 2015, usd = NA) |>
  rename(bl_part_id = design_id) |>
  select(item_id, item_description, bl_part_id, usd, year)

# combine all years into one dataframe
data_all <- list(all_2015, all_2016, all_2017, all_2018, all_2019, all_2020, all_2021, all_2022) |>
  plyr::ldply(rbind)

# filter to just minifig parts, classify different parts of body
data_minifig_parts <- data_all |>
  filter(str_detect(item_description, "MINI")) |>
  mutate(type = case_when(
    str_detect(tolower(item_description), "mini wig") ~ "wig",
    str_detect(tolower(item_description), "mini head") ~ "head",
    str_detect(tolower(item_description), "mini upper part") ~ "torso",
    str_detect(tolower(item_description), "mini lower part") |
      str_detect(tolower(item_description), "mini leg") ~ "legs"
  ))

torsos <- data_minifig_parts |>
  filter(type == "torso") |>
  mutate(price_usd = as.numeric(substr(usd, 2, 5))) |>
  mutate(brick_link_url = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", bl_part_id)) |>
  mutate(description = map_chr(brick_link_url, get_descriptions))

torsos2 <- torsos |>
  group_by(item_id) |>
  mutate(description2 = max(description)) |>
  mutate(search_link = paste0("https://www.bricklink.com/v2/search.page?q=", item_id, "#T=A"))


torsos_not_complete <- torsos2 |>
  mutate(description = description2) |>
  select(-description2)

torsos_na <- torsos_not_complete |>
  filter(description == "NA") |>
  select(item_id, search_link, description, year)


write_csv(torsos_not_complete, "torsos_not_complete.csv")

write_csv(torsos_na, "torsos_na.csv")

## After manual filling in of genders by Alice

# genders filled in
na_complete <- read_csv(here::here("torsos_na_completed.csv")) |>
  select(item_id, gender, year, search_link)

# torsos where we had descriptions from before
part1 <- read_csv(here::here("torsos_not_complete.csv")) |>
  filter(!is.na(description)) |>
  select(item_id, description, year, search_link) |>
  mutate(
    gender = case_when( # gender classification based on keywords
      str_detect(description, "Female|Necklace|Halter") ~ "f",
      str_detect(description, "Male|King|SW|Santa|Tie|Tunic|No Shirt") ~ "m",
      TRUE ~ "n"
    )
  ) |>
  select(item_id, gender, year, search_link)

# combine torsos classified by Alice with torsos classified by string detect
torsos_all <- part1 |>
  bind_rows(na_complete) |>
  mutate(gender = case_when(
    tolower(gender) == "f" | item_id == "6116697" ~ "female",
    tolower(gender) == "m" | item_id == "6022406" ~ "male",
    tolower(gender) == "n" ~ "neutral"
    )
  ) |>
  filter(item_id != "6218204")

# summarize gender counts by year
torsos_summarized <- torsos_all |>
  group_by(gender, year) |>
  summarise(count = n())

# line graph of counts over time by gender
g1 <- ggplot(torsos_summarized, aes(x = year, y = count, color = gender)) +
  geom_line() +
  geom_point() +
  scale_color_wbi() +
  labs(title = "LUGBULK Torso Counts By Gender Over Time (2015-2022)",
         x = "Year",
         y = "Count",
         color = "Gender"
         )

add_logo(g1)
