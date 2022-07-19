library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)

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

# season 1 and 2 data only
rebels_links <- c("https://www.imdb.com/list/ls536871832/", "https://www.imdb.com/list/ls560048877/")

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
rebels_screentime <- map2(rebels_links, c(1,2), get_screentime_data) |>
  plyr::ldply(bind_rows)


# summarize screentime by character
rebels_summarized <- rebels_screentime |>
  mutate(character = case_when(
    character == "The Seventh Sister" ~ "Seventh Sister",
    character == "The Fifth Brother" ~ "Fifth Brother",
    character == "Leia Organa" ~ "Leia",
    TRUE ~ character
  )
  ) |>
  mutate(total_seconds = ifelse(is.na(total_seconds), 0, total_seconds)) |>
  group_by(character) |>
  summarize(seconds = sum(total_seconds), minutes = round(seconds/60, 2))

# scrape minifigs data
rebels_minifigs <- scrape_minifigs_data("https://www.bricklink.com/catalogList.asp?catType=M&catString=65.818")

# function to compute number of minifigs for each character
get_num_minifigs <- function(screentime_data, minifig_data) {
  minifig_characters <- tolower(minifig_data$description)
  movie_characters <- tolower(screentime_data$character)

  num_minifigs <- map_int(movie_characters, ~ sum(str_detect(minifig_characters, .x)))
  num_minifigs
}

num_minifigs <- get_num_minifigs(rebels_summarized, rebels_minifigs)

rebels <- rebels_summarized |>
  mutate(num_minifigs = num_minifigs,
         has_minifig = ifelse(num_minifigs > 0, TRUE, FALSE)
         )

write_csv(rebels, "rebels.csv")
