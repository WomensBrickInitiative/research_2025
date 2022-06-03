library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R")) # file containing functions to customize colors

# read in parts data 2022
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

get_descriptions <- function(urls){
  descriptions <- map(urls, get_description)
  descriptions <- descriptions |>
    as.character() %>%
    ifelse(. == "character(0)", "NA", .)
  descriptions
}

heads_2022 <- data_2022 |>
  janitor::clean_names() |>
  filter(category == "FIGURE, HEADS AND MA" & subcategory == "MINI FIGURE HEADS") |>
  mutate(year = 2022) |>
  filter(brick_link_color %in% skin_colors) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)


heads_2021 <- data_2021 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(year = 2021) |>
  mutate(brick_link_color = case_when(
    lego_color=="BR.YEL" ~ "Yellow",
    lego_color=="WHITE" ~ "White",
    lego_color=="M. NOUGAT" ~ "Medium Nougat",
    lego_color=="RED. BROWN" ~ "Reddish Brown"
  )) |>
  filter(!is.na(brick_link_color)) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2020 <- data_2020 |>
  janitor::clean_names() |>
  filter(str_detect(description, "MINI HEAD")) |>
  mutate(year = 2020) |>
  mutate(brick_link_color = case_when(
    colour_id =="BR.YEL" ~ "Yellow",
    colour_id =="WHITE" ~ "White",
    colour_id =="M. NOUGAT" ~ "Medium Nougat",
    colour_id =="RED. BROWN" ~ "Reddish Brown"
  )) |>
  rename(item_description = description, bl_part_id = bl_part) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2019 <- data_2019 |>
  janitor::clean_names() |>
  filter(str_detect(element_name, "MINI HEAD")) |>
  mutate(year = 2019) |>
  rename(item_id = element_id, item_description = element_name) |>
  mutate(bl_part_id = NA, usd = NA, brick_link_color = str_to_title(color_tlg)) |>
  mutate(brick_link_color = ifelse(brick_link_color == "Bright Yellow", "Yellow", brick_link_color)) |>
  filter(brick_link_color %in% skin_colors) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2018 <- data_2018 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(year = 2018) |>
  rename(brick_link_color = color_name_1, bl_part_id = design_id) |>
  mutate(brick_link_color=ifelse(brick_link_color=="Light Flesh", "Light Nougat", brick_link_color)) |>
  filter(brick_link_color %in% skin_colors) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2017 <- data_2017 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(bl_color=ifelse(bl_color=="Light Flesh", "Light Nougat", bl_color)) |>
  rename(item_id = element_id, bl_part_id = bl_id, brick_link_color = bl_color) |>
  mutate(year = 2017) |>
  filter(brick_link_color %in% skin_colors) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2016 <- data_2016 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(brick_link_color = case_when(
    color == 1L ~ "White",
    color == 24L ~ "Yellow",
    color == 192L ~ "Reddish Brown",
    color == 312L ~ "Medium Nougat",
    color == 18L ~ "Nougat",
    color == 283L ~ "Light Nougat",
    color == 138L ~ "Dark Tan",
    color == 38L ~ "Dark Orange",
    color == 308L ~ "Dark Brown",
    color == 5L ~ "Tan"
  )) |>
  filter(!is.na(brick_link_color)) |>
  mutate(year = 2016, usd = NA) |>
  rename(bl_part_id = design_id) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2015 <- data_2015 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(brick_link_color = case_when(
    color == 1L ~ "White",
    color == 24L ~ "Yellow",
    color == 192L ~ "Reddish Brown",
    color == 312L ~ "Medium Nougat",
    color == 18L ~ "Nougat",
    color == 283L ~ "Light Nougat",
    color == 138L ~ "Dark Tan",
    color == 38L ~ "Dark Orange",
    color == 308L ~ "Dark Brown",
    color == 5L ~ "Tan"
  )) |>
  filter(!is.na(brick_link_color)) |>
  mutate(year = 2015, usd = NA) |>
  rename(bl_part_id = design_id) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

data_all <- list(heads_2015, heads_2016, heads_2017, heads_2018, heads_2019, heads_2020, heads_2021, heads_2022) |>
  plyr::ldply(rbind)


heads_all <- data_all |>
  mutate(price_usd = as.numeric(substr(usd, 2, 5))) |>
  mutate(brick_link_url = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", bl_part_id)) |>
  mutate(description = map_chr(brick_link_url, get_descriptions)) |>
  mutate(is_female = str_detect(tolower(description), "female"),
         is_male = str_detect(tolower(description), " male") |
           str_detect(tolower(description), "beard") |
           str_detect(tolower(description), "goatee") |
           str_detect(tolower(description), "sideburns") |
           str_detect(tolower(description), "moustache") |
           str_detect(tolower(description), "stubble"),
         is_child = str_detect(tolower(description), "child"),
         is_dual_sided = str_detect(tolower(description), "dual sided"),
         is_plain = str_detect(tolower(description), "plain"),
         is_nonhuman = str_detect(tolower(description), "pineapple") |
           str_detect(tolower(description), "cobra") |
           str_detect(tolower(description), "skull") |
           str_detect(tolower(description), "ghost") |
           str_detect(tolower(description), "alien") |
           str_detect(tolower(description), "clock") |
           str_detect(tolower(description), "headphones"),
         type = case_when(
           is_female ~ "female",
           is_male ~ "male",
           is_child ~ "child",
           is_plain ~ "no face",
           is_nonhuman ~ "non human",
           !(is_female | is_male | is_child | is_plain | is_nonhuman) ~ "neutral"
         )
  )

write_csv(heads_all, "heads_all.csv")

na <- heads_all |>
  group_by(year) |>
  mutate(is_na = description != "NA") |>
  summarise(count = sum(is_na))

