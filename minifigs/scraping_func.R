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
get_pages_year <- function(url){
  webpage <- read_html(url)
  num_pages <- webpage |>
    html_elements(".l-clear-left b:nth-child(3)") |>
    html_text()
  num_pages
}

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

scrape_appearance <- function(url) {
  if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  item_page <- rvest::read_html(url)
  number_app <- item_page |>
    html_elements("br+ .links") |>
    html_text()
  number_app

  tibble(number_app)
}

avoid_empty <- function(missing) {
  if (length(missing) == 0) {
    missing <- NA
  } else{
    missing <- missing[1]
  }

  missing
}

get_price <- function(url) {
  # Read the page
  item_page <- rvest::read_html(url)

  # Safe element extractor
  safe_extract <- function(selector) {
    result <- html_elements(item_page, selector) |> html_text()
    if (length(result) == 0) {
      return(NA_character_)
    } else {
      return(result[1])
    }
  }

  # Extract values
  current_new_avg <- safe_extract("td:nth-child(3) tr:nth-child(4) b")
  current_new_min <- safe_extract("td:nth-child(3) tr:nth-child(3) b")
  current_new_max <- safe_extract("td:nth-child(3) tr:nth-child(6) b")

  # Close and pause
  closeAllConnections()
  Sys.sleep(0.5)

  # Return tibble
  tibble(
    current_new_avg = current_new_avg,
    current_new_min = current_new_min,
    current_new_max = current_new_max
  )
}

get_price_one <- function(url){
  #f (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  item_page <- rvest::read_html(url)
  current_new_avg <- item_page |>
    html_elements("td:nth-child(3) tr:nth-child(4) b") |>
    html_text()
  current_new_avg <- current_new_avg[1]
  current_new_min <- item_page |>
    html_elements("td:nth-child(3) tr:nth-child(3) b") |>
    html_text()
  current_new_min <- current_new_min[1]
  current_new_max <- item_page |>
    html_elements("td:nth-child(3) tr:nth-child(6) b") |>
    html_text()
  current_new_max <- current_new_max[1]
  closeAllConnections()
  Sys.sleep(0.5)
  # Error: Tibble columns must have compatible sizes
  tibble(current_new_avg, current_new_min, current_new_max)
  # list(past_used_avg, past_used_min, past_used_max,
  #      current_used_avg, current_used_min, current_used_max,
  #      past_new_avg, past_new_min, past_new_max,
  #      current_new_avg, current_new_min, current_new_max)
}

# function to scrape minifigure ids for minifigs in each set
scrape_mini_id <- function(url) {
  item_page <- rvest::read_html(url)
  mini_id <- item_page |>
    html_elements("td:nth-child(3) a:nth-child(1)") |>
    html_text()
  mini_id
}

# Scrape Minifigure Description (from the minifigure's page)
scrape_mini_description <- function(url) {
  item_page <- rvest::read_html(url)
  description <- item_page |>
    rvest::html_elements("#item-name-title") |>
    rvest::html_text()
  description
}


scrape_color <- function(url){
  item_page <- rvest::read_html(url)
  color <- item_page |>
    rvest::html_elements("#_idTabContentsC td:nth-child(1) a") |>
    rvest::html_text()
  color
}
