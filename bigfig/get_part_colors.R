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

# example with just the first 4 item numbers
item_numbers <- c(2780, 6541, 92946, 2430)

# list of character vectors containing possible colors for each item number
colors <- purrr::map(item_numbers, get_colors)

# check to see if each part exists in dark pink-- none of these first 4 do
darkpink_check <- purrr::map_lgl(colors, ~`%in%`("Dark Pink", .x))

# bind data into a dataframe so it is easier to look at
colors_data <- tibble::tibble(item_no = item_numbers, colors, darkpink_check)
