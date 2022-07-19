library(tidyverse)
source(here::here("wbi_colors.R"))
# function to scrape set ids and category given url
scrape_sets_info <- function(url) {
  item_page <- rvest::read_html(url)
  sets_id <- item_page |>
    html_elements("td:nth-child(3) a:nth-child(1)") |>
    html_text()
  sets_cat <- item_page |>
    html_elements("a:nth-child(5)") |>
    html_text()
  tibble(sets_id, sets_cat)
}

# function to scrape minifigure ids for minifigs in each set
scrape_mini_id <- function(url) {
  item_page <- rvest::read_html(url)
  mini_id <- item_page |>
    html_elements("td:nth-child(3) a:nth-child(1)") |>
    html_text()
  mini_id
}

# Get sets ids and categories for all sets where the female head 3626bp02 is present
sets_data <- scrape_sets_info("https://www.bricklink.com/catalogItemIn.asp?P=3626bp02&in=S")

# Filter to only Town category and add links to sets and pages with minifigs in sets
sets_data <- sets_data |>
  filter(sets_cat == "Town") |>
  mutate(set_link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?S=", sets_id, "#T=S&O={%22iconly%22:0}")) |>
  mutate(mini_link = paste0("https://www.bricklink.com/catalogItemInv.asp?S=", sets_id, "&viewItemType=M"))

# Vector to store scraped minifigure ids (no description for the whole minifig)
mini_info <- map(sets_data$mini_link, scrape_mini_id)

# Add minifig ids to sets_data and unnest so that each row is a minifig
sets_data <- sets_data |>
  mutate(mini_id = mini_info) |>
  unnest(cols = mini_id)

# Add parts_link for each minifig
sets_data <- sets_data |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", mini_id))

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

# Vector to store scraped parts ids and descriptions in a list of dataframe
parts_data <- map(sets_data$parts_link, scrape_parts_description)

# Add parts_info to sets_data and unnest so that each row is a part of the minifig
sets_data <- sets_data |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info)

male_keywords <- c("beard", "goatee", "sideburns", "moustache", "stubble", " male")

# Filter to just heads
heads_data <- sets_data |>
  filter(str_detect(parts_id, "bp")) |>
  select(-sets_id, -set_link, -sets_cat, -mini_link) |>
  distinct() |> # filter to only distinct minifigs
  rename(description = parts_description) |>
  mutate( # categorize heads to female, male, neutral
    type = case_when(
      str_detect(tolower(temp), "female") ~ "female",
      str_detect(tolower(temp), paste(male_keywords, collapse = "|")) ~ "male",
      TRUE ~ "no tag"
    )
  )

# Summarize to see range and repetition of heads for each gender
heads_data_summarized <- heads_data |>
  # group_by(type) |>
  group_by(type, parts_id) |>
  summarize(count = n()) |>
  group_by(type) |>
  mutate(unique_ids = n())

# Separate into female, male, and neutral for graphing
heads_female <- heads_data_summarized |>
  filter(type == "female")
heads_male <- heads_data_summarized |>
  filter(type == "male")
heads_neutral <- heads_data_summarized |>
  filter(type == "neutral")

# Barcharts of repetition of heads by gender
g1 <- ggplot(heads_female, aes(x = reorder(parts_id, count), y = count)) +
  geom_col(fill = "#f43b93") +
  coord_flip() +
  labs(
    title = "Repetition of Female Heads",
    subtitle = paste("Out of", as.character(sum(heads_female$count)), "total"),
    x = "Parts ID",
    y = "Count"
  ) +
  geom_text(aes(label = count), hjust = -0.2) +
  ylim(0, 50)
g1

g2 <- ggplot(heads_male, aes(x = reorder(parts_id, count), y = count)) +
  geom_col(fill = "#8cc63f") +
  coord_flip() +
  labs(
    title = "Repetition of Male Heads",
    subtitle = paste("Out of", as.character(sum(heads_male$count)), "total"),
    x = "Parts ID",
    y = "Count"
  ) +
  geom_text(aes(label = count), hjust = -0.2) +
  ylim(0, 50)
g2

g3 <- ggplot(heads_neutral, aes(x = reorder(parts_id, count), y = count)) +
  geom_col(fill = "#f77f08") +
  coord_flip() +
  labs(
    title = "Repetition of Neutral Heads",
    subtitle = paste("Out of", as.character(sum(heads_neutral$count)), "total"),
    x = "Parts ID",
    y = "Count"
  ) +
  geom_text(aes(label = count), hjust = -0.2) +
  ylim(0, 50)
g3

# Summarize to unique ids by type
heads_data_summarized2 <- heads_data_summarized |>
  select(type, unique_ids) |>
  distinct()

g4 <- ggplot(heads_data_summarized2, aes(x = type, y = unique_ids, fill = type)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Number of Unique Heads by Gender",
    subtitle = paste("Out of", as.character(sum(heads_data_summarized2$unique_ids)), "total"),
    x = "Type",
    y = "Number of Unique Heads"
  ) +
  geom_text(aes(label = unique_ids), vjust = -0.1) +
  scale_fill_wbi()
g4

heads_data_summarized0 <- heads_data |>
  group_by(type) |>
  summarize(count = n())

g5 <- ggplot(heads_data_summarized0, aes(x = type, y = count, fill = type)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Total Number of Heads by Gender",
    subtitle = paste("Out of", as.character(sum(heads_data_summarized0$count)), "total"),
    x = "Type",
    y = "Count"
  ) +
  geom_text(aes(label = count), vjust = -0.1) +
  scale_fill_wbi()
g5

write_csv(sets_data, "sets_data_3626bp02.csv")
