library(tidyverse)

data_2022_item <- read_csv(here::here("data", "lugbulk_parts.csv")) |>
  janitor::clean_names() |>
  select(item_id) |>
  mutate(year="2022")
data_2021_item <- read_csv(here::here("data", "lugbulk_parts2021.csv")) |>
  janitor::clean_names() |>
  select(item_id) |>
  mutate(year="2021")

combined <- rbind(data_2022_item, data_2021_item) |>
  group_by(item_id) |>
  mutate(count=n()) |>
  pivot_wider(names_from = year, values_from = count) |>
  group_by(`2021`) |>
  summarise(count=n())

year_comparison <- c("2022 only","both","2021 only")
item_comparison <- tibble(year_comparison,count=combined$count)
