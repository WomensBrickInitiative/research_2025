library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)

# pull screentime data for films
url <- "https://www.imdb.com/list/ls027631145/"
robotstxt::paths_allowed(paths = c(url))
page <- read_html(url)
screentime <- page |>
  html_elements(".mode-detail .list-description p") |>
  html_text() |>
  str_split("\n")
titles <- page |>
  html_elements(".lister-item-header a") |>
  html_text()

# clean up data
screentime_data <- tibble(titles, screentime) |>
  unnest(cols = c(screentime)) |>
  separate(col = screentime, into = c("character", "screentime"), sep = "<") |>
  mutate(screentime = str_sub(screentime, 1, -2)) |>
  separate(col = screentime, into = c("minutes", "seconds"), sep = ":") |>
  mutate(seconds = ifelse(is.na(seconds), 0, seconds),
         minutes = ifelse(minutes == "" | minutes == "x", 0, minutes)) |>
  mutate(minutes = as.numeric(minutes), seconds = as.numeric(seconds)) |>
  mutate(total_seconds = seconds + 60 * minutes) |>
  mutate(character = trimws(character))

time_summarized <- screentime_data |>
  group_by(character) |>
  summarize(seconds = sum(total_seconds), minutes = round(seconds / 60, 2))

dummy <- time_summarized |>
  rename(name = character) |>
  left_join(starwars, by = "name") |>
  select(name, seconds, minutes, gender, species)

write_csv(dummy, "starwars_screentime.csv")
