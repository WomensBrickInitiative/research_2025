library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R"))

town <- read_csv(here::here("data", "town","town_minifig.csv"))
town_recent <- town |>
  filter(release_year > 2016)

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
parts_data <- map(town_recent$parts_link, scrape_parts_description)

# Add parts_info to sets_data and unnest so that each row is a part of the minifig
town_recent_parts <- town_recent |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info)

# Filter to just heads, classify gender
# excludes babies and robots
heads_data_recent <- town_recent_parts |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  mutate( # categorize heads to female, male, neutral
    is_female = str_detect(tolower(parts_description), "female"),
    is_male = str_detect(tolower(parts_description), " male") |
      str_detect(tolower(parts_description), "beard") |
      str_detect(tolower(parts_description), "goatee") |
      str_detect(tolower(parts_description), "sideburns") |
      str_detect(tolower(parts_description), "moustache") |
      str_detect(tolower(parts_description), "stubble"),
    type = case_when(
      is_female ~ "female",
      is_male ~ "male",
      TRUE ~ "neutral"
    )
  )

# Summarize to see range and repetition of heads for each gender
heads_data_summarized <- heads_data_recent |>
  group_by(type, parts_id) |>
  summarize(count = n()) |>
  group_by(type) |>
  mutate(unique_ids = n())

# Separate into female, male, and neutral for graphing
heads_female <- heads_data_summarized |>
  filter(type == "female")
female_top <- heads_female |>
  top_n(n = 10, wt = count)
heads_male <- heads_data_summarized |>
  filter(type == "male")
male_top <- heads_male |>
  top_n(n = 10, wt = count)
heads_neutral <- heads_data_summarized |>
  filter(type == "neutral")
neutral_top <- heads_neutral |>
  top_n(n = 10, wt = count)

# Barcharts of repetition of heads by gender
# top ten for each gender only
g1 <- ggplot(female_top, aes(x = reorder(parts_id, count), y = count)) +
  geom_col(fill = "#f43b93") +
  coord_flip() +
  labs(
    title = "Repetition of Female Heads",
    subtitle = paste("Out of", as.character(sum(heads_female$count)), "total"),
    x = "Parts ID",
    y = "Count"
  ) +
  geom_text(aes(label = count), hjust = -0.2) +
  ylim(0, 40)
g1

g2 <- ggplot(male_top, aes(x = reorder(parts_id, count), y = count)) +
  geom_col(fill = "#8cc63f") +
  coord_flip() +
  labs(
    title = "Repetition of Male Heads",
    subtitle = paste("Out of", as.character(sum(heads_male$count)), "total"),
    x = "Parts ID",
    y = "Count"
  ) +
  geom_text(aes(label = count), hjust = -0.2) +
  ylim(0, 40)
g2

g3 <- ggplot(neutral_top, aes(x = reorder(parts_id, count), y = count)) +
  geom_col(fill = "#f77f08") +
  coord_flip() +
  labs(
    title = "Repetition of Neutral Heads",
    subtitle = paste("Out of", as.character(sum(heads_neutral$count)), "total"),
    x = "Parts ID",
    y = "Count"
  ) +
  geom_text(aes(label = count), hjust = -0.2) +
  ylim(0, 40)
g3

# all for each gender
g1b <- ggplot(heads_female, aes(x = reorder(parts_id, desc(count)), y = count)) +
  geom_col(fill = "#f43b93") +
  labs(
    title = "Repetition of Female Heads",
    subtitle = paste("Out of", as.character(sum(heads_female$count)), "total"),
    x = "Unique Head",
    y = "Count"
  ) +
  ylim(0, 40) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
g1b

g2b <- ggplot(heads_male, aes(x = reorder(parts_id, desc(count)), y = count)) +
  geom_col(fill = "#8cc63f") +
  labs(
    title = "Repetition of Male Heads",
    subtitle = paste("Out of", as.character(sum(heads_male$count)), "total"),
    x = "Unique Head",
    y = "Count"
  ) +
  ylim(0, 40) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
g2b

g3b <- ggplot(heads_neutral, aes(x = reorder(parts_id, desc(count)), y = count)) +
  geom_col(fill = "#f77f08") +
  labs(
    title = "Repetition of Neutral Heads",
    subtitle = paste("Out of", as.character(sum(heads_neutral$count)), "total"),
    x = "Unique Head",
    y = "Count"
  ) +
  ylim(0, 40) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
g3b

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

heads_data_summarized0 <- heads_data_recent |>
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

# boxplots showing distribution of count by gender

g6 <- ggplot(heads_female, aes(x = count)) +
  geom_boxplot(fill = "#f43b93") +
  labs(
    title = "Distribution of Number of Times Each Female Head Used",
    subtitle = paste("Out of", as.character(sum(heads_female$count)), "total"),
    x = "Unique Head",
    y = "Count"
  )
g6

g7 <- ggplot(heads_male, aes(x = count)) +
  geom_boxplot(fill = "#8cc63f") +
  labs(
    title = "Distribution of Number of Times Each Male Head Used",
    subtitle = paste("Out of", as.character(sum(heads_male$count)), "total"),
    x = "Unique Head",
    y = "Count"
  )
g7

g8 <- ggplot(heads_neutral, aes(x = count)) +
  geom_boxplot(fill = "#f77f08") +
  labs(
    title = "Distribution of Number of Times Each Neutral Head Used",
    subtitle = paste("Out of", as.character(sum(heads_neutral$count)), "total"),
    x = "Unique Head",
    y = "Count"
  )
g8

# save parts data
write_csv(town_recent_parts, "town_parts_2017-2022.csv")

# save plots
names <- c(
  "g1.png", "g2.png", "g3.png", "g1b.png", "g2b.png", "g3b.png", "g4.png", "g5.png", "g6.png",
  "g7.png", "g8.png"
)
plots <- list(g1, g2, g3, g1b, g2b, g3b, g4, g5, g6, g7, g8)

map2(names, plots, ggsave)
