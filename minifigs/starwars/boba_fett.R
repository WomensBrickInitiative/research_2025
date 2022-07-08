library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)

# pull boba fett screentime data
url <- "https://m.imdb.com/list/ls537797499"
robotstxt::paths_allowed(paths = c(url))
page <- read_html(url)
screentime <- page |>
  html_elements(".underlined-links p") |>
  html_text() |>
  str_split("\n")

screentime_data <- tibble(screentime) |>
  unnest(cols = c(screentime)) |>
  separate(col = screentime, into = c("character", "screentime"), sep = "<") |>
  mutate(screentime = str_sub(screentime, 1, -2)) |>
  separate(col = screentime, into = c("minutes", "seconds"), sep = ":") |>
  mutate(minutes = as.numeric(minutes), seconds = as.numeric(seconds)) |>
  mutate(total_seconds = seconds + 60 * minutes)

bobafett_time_summarized <- screentime_data |>
  group_by(character) |>
  summarize(seconds = sum(total_seconds), minutes = round(seconds / 60, 2))

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

# scrape boba fett minifigs part id and description
bobafett_minifigs <- scrape_minifigs_data("https://www.bricklink.com/catalogList.asp?catType=M&catString=65.1217")

# all star wars minifigs
minifigs_starwars <- read_csv(here::here("data", "minifigs_data.csv")) |>
  filter(category == "Star Wars")

# compute number of minifigs for each character
bobafett_minifig_characters <- tolower(bobafett_minifigs$description)
minifig_characters <- tolower(minifigs_starwars$description)
movie_characters <- trimws(tolower(bobafett_time_summarized$character))

num_minifigs_all1 <- map_int(movie_characters, ~sum(str_detect(minifig_characters, .x)))
num_minifigs_all1[[12]] <- 1 # add 1 minifig added just recently that was not in the original data
num_minifigs_all1[[8]] <- 1 # guard w/ helmet not detected

num_minifigs_bobafett1 <- map_int(movie_characters, ~sum(str_detect(bobafett_minifig_characters, .x)))
num_minifigs_bobafett1[[8]] <- 1 # guard w/ helmet not detected


bobafett_time_summarized <- bobafett_time_summarized |>
  mutate(num_minifigs_all = num_minifigs_all1,
         num_minifigs_bobafett = num_minifigs_bobafett1,
         has_minifig_all = ifelse(num_minifigs_all > 0, TRUE, FALSE),
         has_minifig_bobafett = ifelse(num_minifigs_bobafett > 0, TRUE, FALSE)
         )

# barchart of screentime by character
g1 <- ggplot(bobafett_time_summarized, aes(x = reorder(character, minutes), y = minutes, fill = has_minifig_bobafett)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_manual(values = c("#999999", "#f77f08")) +
  labs(title = "Distribution of Screentime: The Book of Boba Fett",
       x = "Character",
       y = "Screen Time (minutes)",
       fill = "Has a minifig in the Boba Fett Category?")
g1

# barchart of number of minifigs by character
g2 <- ggplot(bobafett_time_summarized, aes(x = reorder(character, minutes), y = num_minifigs_all, fill = has_minifig_bobafett)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("#999999", "#f77f08")) +
  labs(title = "Distribution of Total Minifigs: The Book of Boba Fett",
       x = "",
       y = "Number of Minifigs",
       fill = "Has a minifig in the Boba Fett Category?") +
  theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
g2
