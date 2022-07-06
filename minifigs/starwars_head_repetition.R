library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)

# read in minifigs data
minifigs_starwars <- read_csv(here::here("data", "minifigs_data.csv")) |>
  filter(category == "Star Wars")

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
  summarise(count = n()) |>
  mutate(is_repeated = ifelse(parts_id %in% c("3626cpb0416", "3626cpb2357", "3626cpb1920", "3626cpb1489"), FALSE, TRUE))

# barchart of number of minifigs per unique head
g1 <- ggplot(leia_heads_summarized, aes(x = reorder(parts_id, count), y = as.integer(count), fill = is_repeated)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(breaks = 1:15, labels = as.character(1:15), limits = c(0,12)) +
  geom_text(aes(label = paste0(count, " | ", head_year)), hjust = 0) +
  scale_fill_wbi() +
  labs(title = "Number of Minifigs Per Unique Princess Leia Head",
       x = "Part ID",
       y = "Count",
       fill = "Head used in a character other than Leia?")
g1 <- add_logo(g1)
g1

# Analysis of Repetition of Luke Heads
# filter to only luke Skywalker minifigs
luke <- minifigs_starwars |>
  filter(str_detect(description, "Luke Skywalker")) |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(luke$parts_link, scrape_parts_description)

# data for heads of Luke minifigs
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
  summarise(count = n()) |>
  mutate(is_repeated = ifelse(parts_id %in% c("3626bps2", "3626cpb1414"), TRUE, FALSE))

# top luke heads
luke_heads_top <- luke_heads_summarized |>
  filter(count > 1)

# barchart of number of minifigs per unique head
g2 <- ggplot(luke_heads_summarized, aes(x = reorder(parts_id, count), y = as.integer(count), fill = is_repeated)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(breaks = 1:12, labels = as.character(1:12), limits = c(0, 12)) +
  geom_text(aes(label = paste0(count, " | ", head_year)), hjust = 0) +
  scale_fill_wbi() +
  labs(title = "Number of Minifigs Per Unique Luke Skywalker Head",
       x = "Part ID",
       y = "Count",
       fill = "Head used in a character other than Luke?")
g2 <- add_logo(g2)
g2

## Analysis of repetition of Han Solo heads

# filter to only Princess Leia minifigs
solo <- minifigs_starwars |>
  filter(str_detect(description, "Han Solo")) |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(solo$parts_link, scrape_parts_description)

# data for heads of Leia minifigs
solo_heads <- solo |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info) |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate(head_link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", parts_id))

# Scrape release_year
minifig_year <- map(solo_heads$item_link, scrape_year)
minifig_year <- minifig_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# Scrape release_year head
head_year <- map(solo_heads$head_link, scrape_year)
head_year <- head_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# add release year for head and minifig
solo_heads2 <- solo_heads |>
  mutate(minifig_year = as.numeric(minifig_year), head_year = as.numeric(head_year))

# summarise count of minifigs per unique head
solo_heads_summarized <- solo_heads2 |>
  group_by(parts_id, head_year) |>
  summarise(count = n()) |>
  mutate(is_repeated = ifelse(parts_id == "3626cpb2108", TRUE, FALSE)) # add variable indicating whether or not head used for another character

# barchart of number of minifigs per unique head
g3 <- ggplot(solo_heads_summarized, aes(x = reorder(parts_id, count), y = as.integer(count), fill = is_repeated)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(breaks = 1:12, labels = as.character(1:12), limits = c(0,12)) +
  geom_text(aes(label = paste0(count, " | ", head_year)), hjust = 0) +
  scale_fill_wbi() +
  labs(title = "Number of Minifigs Per Unique Han Solo Head",
       x = "Part ID",
       y = "Count",
       fill = "Head used in a character other than Han Solo?")
g3 <- add_logo(g3)
g3

## Analysis of repetition of Rey heads

# filter to only Rey minifigs
rey <- minifigs_starwars |>
  filter(str_detect(description, "Rey")) |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(rey$parts_link, scrape_parts_description)

# data for heads of Rey minifigs
rey_heads <- rey |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info) |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate(head_link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", parts_id))

# Scrape release_year
minifig_year <- map(rey_heads$item_link, scrape_year)
minifig_year <- minifig_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# Scrape release_year head
head_year <- map(rey_heads$head_link, scrape_year)
head_year <- head_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# add release year for head and minifig
rey_heads2 <- rey_heads |>
  mutate(minifig_year = as.numeric(minifig_year), head_year = as.numeric(head_year))

# summarise count of minifigs per unique head
rey_heads_summarized <- rey_heads2 |>
  group_by(parts_id, head_year) |>
  summarise(count = n())

## Analysis of repetition of Poe Dameron heads

# filter to only Poe minifigs
poe <- minifigs_starwars |>
  filter(str_detect(description, "Poe Dameron")) |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(poe$parts_link, scrape_parts_description)

# data for heads of Poe minifigs
poe_heads <- poe |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info) |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate(head_link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", parts_id))

# Scrape release_year
minifig_year <- map(poe_heads$item_link, scrape_year)
minifig_year <- minifig_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# Scrape release_year head
head_year <- map(poe_heads$head_link, scrape_year)
head_year <- head_year |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# add release year for head and minifig
poe_heads2 <- poe_heads |>
  mutate(minifig_year = as.numeric(minifig_year), head_year = as.numeric(head_year))

# summarise count of minifigs per unique head
poe_heads_summarized <- poe_heads2 |>
  group_by(parts_id, head_year) |>
  summarise(count = n())




