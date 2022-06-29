library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)
library(scales)

# read in minifigs data
minifigs_data <- read_csv(here::here("data", "minifigs_data.csv"))

# function to scrape release year given item link
scrape_year <- function(url) {
  if (!robotstxt::paths_allowed(paths = c(url))) stop("scraping not allowed, cannot proceed")
  item_page <- rvest::read_html(url)
  release_year <- item_page |>
    html_elements("#yearReleasedSec") |>
    html_text()
  release_year
}

# function to scrape parts ids and description given item link, returns a dataframe
scrape_parts_description <- function(url) {
  item_page <- rvest::read_html(url)
  parts_id <- item_page |>
    html_elements("td:nth-child(3) a:nth-child(1)") |>
    html_text()
  parts_description <- item_page |>
    html_elements(".IV_ITEM td:nth-child(4) b") |>
    html_text()
  tibble(parts_id, parts_description)
}

# filter to just starwars
minifigs_starwars <- minifigs_data |>
  filter(category == "Star Wars")

# compute number of minifigs for each character
minifig_characters <- tolower(minifigs_starwars$description)
movie_characters <- tolower(starwars$name)

num_minifigs <- map_int(movie_characters, ~sum(str_detect(minifig_characters, .x)))

# add column to starwars data with number of minifigs for each character, calculate number of films and number of
# ratio of minifigs to films
starwars_minifigs_compare <- starwars |>
  select(name, sex, species, films) |>
  mutate(num_minifigs = num_minifigs,
         num_films = map_int(films, length),
         ratio = num_minifigs/num_films
  ) |>
  filter(species == "Human")

## Analysis of repetition of Leia heads

# filter to only Princess Leia minifigs
leia <- minifigs_starwars |>
  filter(str_detect(description, "Leia")) |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(leia$parts_link, scrape_parts_description)

# data for heads of Leia minifigs
leia_heads <- leia |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info) |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate(head_link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", parts_id))

# Scrape release_year
minifig_year <- map(leia_heads$item_link, scrape_year)
minifig_year <- minifig_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# Scrape release_year head
head_year <- map(leia_heads$head_link, scrape_year)
head_year <- head_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# add release year for head and minifig
leia_heads2 <- leia_heads |>
  mutate(minifig_year = as.numeric(minifig_year), head_year = as.numeric(head_year))

# summarise count of minifigs per unique head
leia_heads_summarized <- leia_heads2 |>
  group_by(parts_id, head_year) |>
  summarise(count = n())

# barchart of number of minifigs per unique head
g1 <- ggplot(leia_heads_summarized, aes(x = reorder(parts_id, count), y = as.integer(count))) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(breaks = 1:10, labels = as.character(1:10)) +
  geom_text(aes(label = count), hjust = -0.2) +
  labs(title = "Number of Minifigs Per Unique Princess Leia Head",
       x = "Part ID",
       y = "Count")
g1 <- add_logo(g1)
g1

# Analysis of Repetition of Luke Heads
# filter to only luke Skywalker minifigs
luke <- minifigs_starwars |>
  filter(str_detect(description, "Luke Skywalker")) |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(luke$parts_link, scrape_parts_description)

# data for heads of Leia minifigs
luke_heads <- luke |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info) |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate(head_link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", parts_id))

# Scrape release_year
minifig_year_luke <- map(luke_heads$item_link, scrape_year)
minifig_year_luke <- minifig_year_luke |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# Scrape release_year head
head_year_luke <- map(luke_heads$head_link, scrape_year)
head_year_luke <- head_year_luke |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# add release year for head and minifig
luke_heads2 <- luke_heads |>
  mutate(minifig_year = as.numeric(minifig_year_luke), head_year = as.numeric(head_year_luke))

# summarise count of minifigs per unique head
luke_heads_summarized <- luke_heads2 |>
  group_by(parts_id, head_year) |>
  summarise(count = n())

# top luke heads
luke_heads_top <- luke_heads_summarized |>
  filter(count > 1)

# barchart of number of minifigs per unique head
g1b <- ggplot(luke_heads_summarized, aes(x = reorder(parts_id, count), y = as.integer(count))) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(breaks = 1:10, labels = as.character(1:10)) +
  geom_text(aes(label = paste0(count, "|", head_year)), hjust = 0) +
  labs(title = "Number of Minifigs Per Unique Luke Skywalker Head",
       x = "Part ID",
       y = "Count")
g1b <- add_logo(g1b)
g1b

# Analysis of Female Representation
# filter to only female
starwars_female <- starwars_minifigs_compare |>
  filter(sex == "female")

num_minifigs_female <- c(26, 1, 1, 0, 0, 0, 0, 4, 5)
num_films_corrected <- c(7, 3, 2, 2, 1, 1, 1, 3, 3)

starwars_female <- starwars_female |>
  mutate(num_minifigs = num_minifigs_female, num_films = num_films_corrected)

starwars_female_long <- starwars_female |>
  mutate(num_minifigs = num_minifigs_female) |>
  pivot_longer(names_to = "minifigs_or_films", values_to = "value", cols = c(num_minifigs, num_films))

g2 <- ggplot(starwars_female_long, aes(x = reorder(name, value), y = value, fill = minifigs_or_films)) +
  geom_col(position = "dodge") +
  coord_flip() +
  geom_text(aes(label = value), position = position_dodge(width = 1), inherit.aes = TRUE, hjust = -0.2) +
  scale_fill_wbi() +
  labs(title = "Number of Minifigs Versus Number of Films: Female Characters",
       x = "Character Name",
       y = "Count",
       fill = "Count")
add_logo(g2)

### other random graphs

ggplot(starwars_minifigs_compare,
       aes(x = num_films, y = num_minifigs, color = sex)) +
  geom_point() +
  geom_jitter() +
  scale_color_wbi() +
  labs(title = "Relationship between Number of Films and Number of Minifigs by Sex")


sw_mf2 <- starwars_minifigs_compare |>
  group_by(sex) |>
  summarize(mean_films = mean(num_films), mean_minifigs = mean(num_minifigs)) |>
  filter(!is.na(sex)) |>
  pivot_longer(
    cols = c(mean_films, mean_minifigs), names_to = "comp", values_to = "average_num")

ggplot(sw_mf2, aes(x = reorder(sex, desc(average_num)), y = average_num, fill = comp)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_wbi() +
  labs(title = "Comparison of Films and Minifigs by Sex",
       x = "sex")

sw_mf_ratio <- starwars_minifigs_compare |>
  group_by(sex) |>
  summarize(mean_ratio = mean(ratio)) |>
  filter(!is.na(sex)) |>
  filter(mean_ratio > 0)

ggplot(sw_mf_ratio, aes(x = reorder(sex, desc(mean_ratio)), y = mean_ratio, fill = sex)) +
  geom_col() +
  scale_fill_wbi() +
  labs(title = "Ratio of Number of Minifigs to Number of Films by Sex",
       x = "sex")
