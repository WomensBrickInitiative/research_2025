library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)

# data with links to screentime info for each season 1-7
clone_wars_links <- read_csv(here::here("data", "starwars", "clone_wars.csv"))

# function to pull clone wars screen time
get_screentime_data <- function(url, season) {
  page <- read_html(url)
  screentime <- page |>
    html_elements(".list-description p") |>
    html_text() |>
    str_split("\n")
  screentime_data <- tibble(screentime) |>
    unnest(cols = c(screentime)) |>
    separate(col = screentime, into = c("character", "screentime"), sep = "<") |>
    mutate(character = str_replace_all(character, "\"", ""),
           character = trimws(character)) |>
    mutate(screentime = str_sub(screentime, 1, -2)) |>
    separate(col = screentime, into = c("minutes", "seconds"), sep = ":") |>
    mutate(minutes = as.numeric(minutes), seconds = as.numeric(seconds)) |>
    mutate(total_seconds = seconds + 60 * minutes) |>
    mutate(season = season)
  screentime_data
}

# scrape screentime info
clone_wars_screentime <- map2(clone_wars_links$link, clone_wars_links$Season, get_screentime_data) |>
  plyr::ldply(bind_rows)

# summarize screentime by character
clone_wars_summarized <- clone_wars_screentime |>
  mutate(character = case_when(
    character == "Willhuff Tarkin" ~ "Wilhuff Tarkin",
    character == "Luminar Unduli" ~ "Luminara Unduli",
    character == "Jabba Desilijic Tiure" ~ "Jabba",
    character == "Eeth Koth 0:09>" ~ "Eeth Koth",
    character == "Orn Free Taaa" ~ "Orn Free Taa",
    character == "Padmé Amidala" ~ "Padme",
    TRUE ~ character
    )
  ) |>
  mutate(total_seconds = ifelse(is.na(total_seconds), 0, total_seconds)) |>
  group_by(character) |>
  summarize(seconds = sum(total_seconds), minutes = round(seconds/60, 2))

# function to scrape data from one category webpage
scrape_minifigs_data <- function(url, category) {
  if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")

  webpage <- rvest::read_html(url)

  item_number <- webpage |>
    rvest::html_elements("font:nth-child(1) a:nth-child(2)") |>
    rvest::html_text()
  description <- webpage |>
    rvest::html_elements("#ItemEditForm strong") |>
    rvest::html_text()

  tibble(item_number, description)
}

# scrape minifig data from clone wars bricklink category
minifigs_links <- c("https://www.bricklink.com/catalogList.asp?catType=M&catString=65.635",
                    "https://www.bricklink.com/catalogList.asp?pg=2&catType=M&catString=65.635",
                    "https://www.bricklink.com/catalogList.asp?pg=3&catType=M&catString=65.635")

clone_wars_minifigs <- map(minifigs_links, scrape_minifigs_data) |>
  plyr::ldply(bind_rows)

# compute total number of minifigs per character

# compute number of minifigs for each character
# function to compute number of minifigs for each character
get_num_minifigs <- function(screentime_data, minifig_data) {
  minifig_characters <- tolower(minifig_data$description)
  movie_characters <- tolower(screentime_data$character)

  num_minifigs <- map_int(movie_characters, ~ sum(str_detect(minifig_characters, .x)))
  num_minifigs
}

num_minifigs <- get_num_minifigs(clone_wars_summarized, clone_wars_minifigs)

clone_wars <- clone_wars_summarized |>
  mutate(num_minifigs = num_minifigs)

write_csv(clone_wars, "clone_wars.csv")
