knitr::opts_chunk$set(echo = TRUE)
library(rvest)
library(tidyverse)

scrape_minifigs_data <- function(url, category) {
  if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")

  webpage <- rvest::read_html(url)

  if (category %in% c("Discovery", "Quatro", "Universe", "Fusion")) {
    item_number <- webpage |>
      rvest::html_elements("#id_divBlock_Main td span span") |>
      rvest::html_text()
    description <- webpage |>
      rvest::html_elements("#item-name-title") |>
      rvest::html_text()
  } else {
    item_number <- webpage |>
      rvest::html_elements("font:nth-child(1) a:nth-child(2)") |>
      rvest::html_text()
    description <- webpage |>
      rvest::html_elements("#ItemEditForm strong") |>
      rvest::html_text()
  }
  tibble(item_number, description, category = category)
}

# function to get number of pages in a category
get_pages <- function(url){
  webpage <- read_html(url)
  num_pages <- webpage |>
    html_elements("b:nth-child(3)") |>
    html_text()
  num_pages
}


# function to create a new url for each additional page beyond the first page
replace_page <- function(pg, url) {
  pg_char <- as.character(pg)
  url_split <- str_split(url, "catType")
  new_url <- paste0(url_split[[1]][[1]], "pg=", pg_char, "&catType", url_split[[1]][[2]])
}

# function to create all urls for each category
generate_page_links <- function(num_pg, url) {
  if (num_pg == 1L) {
    url_list <- as.list(url)
  } else {
    pages <- 2L:num_pg
    url_list <- map(pages, replace_page, url = url)
    url_list <- c(url, url_list)
  }
  url_list
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

# function to scrape set ids given sets url
scrape_sets_id <- function(url) {
  item_page <- rvest::read_html(url)
  sets_id <- item_page |>
    html_elements("td:nth-child(3) a:nth-child(1)") |>
    html_text()
  sets_id
}

# function to scrape set description given sets url
scrape_sets_description <- function(url){
  item_page <- rvest::read_html(url)
  sets_description <- item_page |>
    html_elements("td:nth-child(4) font b") |>
    html_text()
  sets_description
}
