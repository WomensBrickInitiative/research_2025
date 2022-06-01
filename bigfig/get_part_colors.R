library(rvest)

# function returns list of all available colors given a bricklink part number
get_colors <- function(item_no){
  url <- paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", as.character(item_no))
  suppressMessages(
    if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  )
  page <- read_html(url)
  colors <- page |>
    html_elements("#_idColorListAll .pciSelectColorColorItem") |>
    html_attr("data-name")
  colors[-c(1,2)]
}

# function returns list of all available color ids given a bricklink part number
get_color_ids <- function(item_no){
  url <- paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", as.character(item_no))
  suppressMessages(
    if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  )
  page <- read_html(url)
  colors <- page |>
    html_elements("#_idColorListAll .pciSelectColorColorItem") |>
    html_attr("data-color")
  colors[-c(1,2)]
}

# example with just the first 4 item numbers
item_numbers <- c(2780, 6541, 92946, 2430)

# list of character vectors containing possible colors for each item number
colors <- purrr::map(item_numbers, get_colors)

# list of character vectors containing color ids for each possible color
color_ids <- purrr::map(item_numbers, get_color_ids)

# construct link to go to specific color price guide page
construct_link <- function(item_number, color_id){
  paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", item_number, "#T=P&C=", color_id)
}

construct_links <- function(item_number, color_ids){
  purrr::map(color_ids, ~construct_link(item_number, .x))
}

links <- purrr::map(item_numbers, ~construct_links(.x, color_ids))

# not working-- I think the code is hidden again :((
get_avg_price <- function(url) {
  suppressMessages(
    if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  )
  page <- read_html(url)
  price <- page |>
    html_elements("d:nth-child(4) tr:nth-child(4) b") |>
    html_text()
  price
}

get_avg_price("https://www.bricklink.com/v2/catalog/catalogitem.page?P=2430#T=P&C=11")


# check to see if each part exists in dark pink-- none of these first 4 do
darkpink_check <- purrr::map_lgl(colors, ~`%in%`("Dark Pink", .x))

# bind data into a dataframe so it is easier to look at
colors_data <- tibble::tibble(item_no = item_numbers, colors, color_ids, links, darkpink_check)
