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

# clean up each year so they all have consistent formatting
all_2022 <- data_2022 |>
  janitor::clean_names() |>
  mutate(year = 2022) |>
  select(item_id, item_description, year)

all_2021 <- data_2021 |>
  janitor::clean_names() |>
  mutate(year = 2021) |>
  select(item_id, item_description, year)

all_2020 <- data_2020 |>
  janitor::clean_names() |>
  mutate(year = 2020) |>
  rename(item_description = description, bl_part_id = bl_part) |>
  select(item_id, item_description, year)

all_2019 <- data_2019 |>
  janitor::clean_names() |>
  mutate(year = 2019) |>
  rename(item_id = element_id, item_description = element_name) |>
  select(item_id, item_description, year)

all_2018 <- data_2018 |>
  janitor::clean_names() |>
  mutate(year = 2018) |>
  rename(brick_link_color = color_name_1, bl_part_id = design_id) |>
  select(item_id, item_description, year)

all_2017 <- data_2017 |>
  janitor::clean_names() |>
  rename(item_id = element_id, bl_part_id = bl_id, brick_link_color = bl_color) |>
  mutate(year = 2017) |>
  select(item_id, item_description, year)

all_2016 <- data_2016 |>
  janitor::clean_names() |>
  mutate(year = 2016, usd = NA) |>
  rename(bl_part_id = design_id) |>
  select(item_id, item_description, year)

all_2015 <- data_2015 |>
  janitor::clean_names() |>
  mutate(year = 2015) |>
  select(item_id, item_description, year)

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

# count by year and body part type
parts_summarized <- data_minifig_parts |>
  group_by(year, type) |>
  summarize(count = n())

# pivot to wide format to increase readability
parts_wide <- parts_summarized |>
  pivot_wider(names_from = year, values_from = count)

# calculate totals for each year
parts_summarized2 <- data_minifig_parts |>
  group_by(year, type) |>
  summarize(count = n()) |>
  group_by(year) |>
  summarize(total = sum(count)) |>
  pivot_wider(names_from = year, values_from = total)

totals <- tibble(type = "total", parts_summarized2)

# combine types by count and totals into one table
parts_wide2 <- bind_rows(parts_wide, totals)

# line graph of counts by part over time
p1 <- ggplot(parts_summarized, aes(x = year, y = count)) +
  geom_line(aes(color = type)) +
  geom_point(aes(color = type)) +
  labs(
    title = "Counts by Part Over Time",
    x = "Year",
    y = "Count",
    color = ""
  ) +
  scale_color_wbi()
add_logo(p1)
plotly::ggplotly(p1)
