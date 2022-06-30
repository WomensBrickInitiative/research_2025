library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)

# data source: https://www.youtube.com/watch?v=2gujQ2Ez9RI
mandalorian <- tibble(
  character = c(
    "The Mandalorian", "Grogu", "Cara Dune", "Fennec Shand", "Kuiil", "Mayfeld",
    "Greef Karga", "Bo-Katan", "Koska Reeves", "Moff Gideon"
  ),
  is_human = c(TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE),
  gender = c("male", "male", "female", "female", "male", "male", "male", "female", "female", "male"),
  minutes = c(393, 272, 107, 48, 47, 42, 39, 34, 32, 28)
)

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
mandalorian_minifigs <- scrape_minifigs_data("https://www.bricklink.com/catalogList.asp?catType=M&catString=65.1061")

minifigs_starwars <- read_csv(here::here("data", "minifigs_data.csv")) |>
  filter(category == "Star Wars")

# compute number of minifigs for each character
mandalorian_minifig_characters <- tolower(mandalorian_minifigs$description)
minifig_characters <- tolower(minifigs_starwars$description)
movie_characters <- trimws(tolower(mandalorian$character))

num_minifigs_all1 <- map_int(movie_characters, ~sum(str_detect(minifig_characters, .x)))
num_minifigs_all1[[3]] <- 1

num_minifigs_mandalorian1 <- map_int(movie_characters, ~sum(str_detect(mandalorian_minifig_characters, .x)))
num_minifigs_mandalorian1[[3]] <- 1

mandalorian <- mandalorian |>
  mutate(num_minifigs_all = num_minifigs_all1,
         num_minifigs_mandalorian = num_minifigs_mandalorian1,
         has_minifig_all = ifelse(num_minifigs_all > 0, TRUE, FALSE),
         has_minifig_mandalorian = ifelse(num_minifigs_mandalorian > 0, TRUE, FALSE)
  )

# barchart of screentime by character and gender
g1 <- ggplot(mandalorian, aes(x = reorder(character, minutes), y = minutes, fill = gender)) +
  geom_col() +
  coord_flip() +
  scale_fill_wbi() +
  labs(title = "Distribution of Screentime: The Mandalorian (Top 10)",
       x = "Character",
       y = "Screen Time (minutes)",
       fill = "Gender")
g1

# barchart of number of minifigs by character
g2 <- ggplot(mandalorian, aes(x = reorder(character, minutes), y = num_minifigs_all, fill = has_minifig_mandalorian)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("#999999", "#f77f08")) +
  labs(title = "Distribution of Total Minifigs: The Mandalorian",
       x = "",
       y = "Number of Minifigs",
       fill = "Has a minifig in the Mandalorian Category?") +
  theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) +
  geom_text(aes(label = num_minifigs_all), hjust = 0)
g2
