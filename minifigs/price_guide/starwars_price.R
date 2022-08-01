library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R"))

starwars_minifigs <- read_csv(here::here("data", "starwars", "starwars_mainfilms_minifigs.csv"))

starwars_price <- starwars_minifigs |>
  mutate(price_guide_link=paste0("https://www.bricklink.com/catalogPG.asp?M=",item_number))

get_price <- function(url){
  item_page <- rvest::read_html(url)
  past_used_avg <- item_page |>
    html_elements("td:nth-child(2) tr:nth-child(4) b") |>
    html_text()
  past_used_min <- item_page |>
    html_elements("td:nth-child(2) tr:nth-child(3) b") |>
    html_text()
  past_used_max <- item_page |>
    html_elements("td:nth-child(2) tr:nth-child(6) b") |>
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
    html_elements(".fv td:nth-child(1) table:nth-child(1) .fv tr:nth-child(4) b") |>
    html_text()
  past_new_min <- item_page |>
    html_elements(".fv td:nth-child(1) td tr:nth-child(3) b") |>
    html_text()
  past_new_max <- item_page |>
    html_elements(".fv td:nth-child(1) table:nth-child(1) .fv tr:nth-child(6) b") |>
    html_text()
  current_new_avg <- item_page |>
    html_elements("td:nth-child(3) tr:nth-child(4) b") |>
    html_text()
  current_new_min <- item_page |>
    html_elements("td:nth-child(3) tr:nth-child(3) b") |>
    html_text()
  current_new_max <- item_page |>
    html_elements("td:nth-child(3) tr:nth-child(6) b") |>
    html_text()
  # Error: Tibble columns must have compatible sizes
  # tibble(past_used_avg, past_used_min, past_used_max,
  #        current_used_avg, current_used_min, current_used_max,
  #        past_new_avg, past_new_min, past_new_max,
  #        current_new_avg, current_new_min, current_new_max)
  list(past_used_avg, past_used_min, past_used_max,
       current_used_avg, current_used_min, current_used_max,
       past_new_avg, past_new_min, past_new_max,
       current_new_avg, current_new_min, current_new_max)
}

test <- get_price("https://www.bricklink.com/catalogPG.asp?M=sw0594")
test2 <- get_price(starwars_price$price_guide_link[[1]])
test3 <- get_price("https://www.bricklink.com/catalogPG.asp?M=sw0473")

# Vector to store 12 prices scraped in a list of dataframe
prices <- map(starwars_price$price_guide_link, get_price)

# Add parts_info to sets_data and unnest so that each row is a part of the minifig
starwars_price <- starwars_price |>
  mutate(price_info = prices) |>
  unnest_wider(col = price_info)
