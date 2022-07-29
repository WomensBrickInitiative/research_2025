library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R"))

town_minifigs <- read_csv(here::here("data", "town", "town_minifig.csv"))

town_price <- town_minifigs |>
  mutate(price_link=paste0(item_link, "#T=P"))

get_price <- function(url){
  item_page <- rvest::read_html(url)
  past_used_avg <- item_page |>
    html_elements("td:nth-child(2) tr:nth-child(4) b") |>
    html_text()
  past_used_min <- item_page |>
    html_elements("#_idPGContents td:nth-child(2) tr:nth-child(3) b") |>
    html_text()
  past_used_max <- item_page |>
    html_elements("td:nth-child(2) .pcipgSummaryTable tr:nth-child(6) b") |>
    html_text()
  current_used_avg <- item_page |>
    html_elements("td:nth-child(4) tr:nth-child(4) b") |>
    html_text()
  current_used_min <- item_page |>
    html_elements("td:nth-child(4) tr:nth-child(3) b") |>
    html_text()
  current_used_max <- item_page |>
    html_elements("td:nth-child(4) tr:nth-child(6) b") |>
    html_text()
  past_new_avg <- item_page |>
    html_elements("#_idPGContents td:nth-child(1) tr:nth-child(4) b") |>
    html_text()
  past_new_min <- item_page |>
    html_elements("#_idPGContents td:nth-child(1) tr:nth-child(3) b") |>
    html_text()
  past_new_max <- item_page |>
    html_elements("#_idPGContents td:nth-child(1) tr:nth-child(6) b") |>
    html_text()
  current_new_avg <- item_page |>
    html_elements("td:nth-child(3) tr:nth-child(4) b") |>
    html_text()
  current_new_min <- item_page |>
    html_elements("td:nth-child(3) tr:nth-child(3) b") |>
    html_text()
  current_new_max <- item_page |>
    html_elements("td:nth-child(3) .pcipgSummaryTable tr:nth-child(6) b") |>
    html_text()
  tibble(past_used_avg, past_used_min, past_used_max,
         current_used_avg, current_used_min, current_used_max,
         past_new_avg, past_new_min, past_new_max,
         current_new_avg, current_new_min, current_new_max)
}

test <- get_price("https://www.bricklink.com/v2/catalog/catalogitem.page?M=cty0841#T=P")
test2 <- get_price(town_price$price_link[[1]])
