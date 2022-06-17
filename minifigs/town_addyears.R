library(tidyverse)
library(rvest)

town_data <- read_csv(here::here("data", "town_minifig.csv"))

# function to scrape release year given item link
scrape_year <- function(url) {
  if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  item_page <- rvest::read_html(url)
  release_year <- item_page |>
    html_elements("#yearReleasedSec") |>
    html_text()
  release_year
}

# function to scrape parts description given item link
scrape_parts_description <- function(url){
  item_page <- rvest::read_html(url)
  parts_description <- item_page |>
    html_elements(".IV_ITEM td:nth-child(4) b") |>
    html_text()
  parts_description
}

town <- town_data |>
  mutate(item_link = paste0("https://bricklink.com/v2/catalog/catalogitem.page?M=", item_number)) |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

release_year <- map(town$item_link, scrape_year)
release_year <- release_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

town <- town |>
  mutate(release_year = release_year) |>
  filter(release_year != "NA") |>
  mutate(release_year = as.numeric(release_year)) |>
  filter(release_year > 1997, release_year < 2001)

write_csv(town, "town_minifig.csv")
