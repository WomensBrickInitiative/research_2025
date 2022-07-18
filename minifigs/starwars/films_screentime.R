library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)
library(plotly)
# pull screentime data for films
url <- "https://www.imdb.com/list/ls027631145/"
robotstxt::paths_allowed(paths = c(url))
page <- read_html(url)
screentime <- page |>
  html_elements(".mode-detail .list-description p") |>
  html_text() |>
  str_split("\n")
titles <- page |>
  html_elements(".lister-item-header a") |>
  html_text()

# clean up data
screentime_data <- tibble(titles, screentime) |>
  unnest(cols = c(screentime)) |>
  separate(col = screentime, into = c("character", "screentime"), sep = "<") |>
  mutate(screentime = str_sub(screentime, 1, -2)) |>
  separate(col = screentime, into = c("minutes", "seconds"), sep = ":") |>
  mutate(
    seconds = ifelse(is.na(seconds), 0, seconds),
    minutes = ifelse(minutes == "" | minutes == "x", 0, minutes)
  ) |>
  mutate(minutes = as.numeric(minutes), seconds = as.numeric(seconds)) |>
  mutate(total_seconds = seconds + 60 * minutes) |>
  mutate(character = trimws(character))

time_summarized <- screentime_data |>
  group_by(character) |>
  summarize(seconds = sum(total_seconds), minutes = round(seconds / 60, 2))

dummy <- time_summarized |>
  rename(name = character) |>
  left_join(starwars, by = "name") |>
  select(name, seconds, minutes, gender, species)

write_csv(dummy, "starwars_screentime.csv")

## Data filled in from Thorin and Alexander
screentime <- read_csv(here::here("data", "starwars_screentime.csv"))
screentime <- screentime |>
  select(-notes) |>
  mutate(species = tolower(species), is_human = ifelse(species == "human", "human", "non human")) |>
  mutate(name_detect = case_when(
    name_detect == "BB-8" ~ "BB-8 ",
    name_detect == "Sabe" ~ "Sabe ",
    name_detect == "Sebulba" ~ "Sebulba ",
    name_detect == "Val" ~ "Val ",
    TRUE ~ name_detect
  ))

minifigs <- read_csv(here::here("data", "minifigs_data.csv"))
starwars <- minifigs |>
  filter(category == "Star Wars")

# compute number of minifigs for each character
minifig_characters <- tolower(starwars$description)
movie_characters <- tolower(screentime$name_detect)

num_minifigs <- map_int(movie_characters, ~ sum(str_detect(minifig_characters, .x)))

screentime <- screentime |>
  mutate(num_minifigs = num_minifigs) |>
  # combine anakin skywalker and darth vader
  mutate(num_minifigs = ifelse(name == "Anakin Skywalker / Darth Vader", 53, num_minifigs)) |>
  select(-name_detect) |>
  distinct() |>
  mutate(has_minifigs = ifelse(num_minifigs > 0, TRUE, FALSE))

# Interactive scatter plot of #minifigs over screentime (min)
p <- ggplotly(
  ggplot(screentime, aes(x = minutes, y = num_minifigs, color = gender, text = paste("Name:", name, "\n#Minifigs:", num_minifigs, "\nScreentime:", minutes, "\nSpecies:", species))) +
    geom_point() +
    # geom_smooth() + not working
    scale_color_wbi() +
    labs(
      title = "Relationship between Screentime and Number of Star Wars Minifigs",
      x = "Screentime (minutes)",
      y = "Number of Minifigs",
      color = "Gender"
    ),
  tooltip = "text"
)
p

# dataset for making bar chart comparing screentime by gender
screentime_summarized <- screentime |>
  select(gender, num_minifigs, minutes) |>
  group_by(gender) |>
  summarize(count_gender = n(), time_gender = sum(minutes), count_minifigs = sum(num_minifigs)) |>
  filter(gender != "neutral") |>
  mutate(screentime_hours = round(time_gender / 60, 2)) |>
  pivot_longer(cols = c(count_gender, count_minifigs, screentime_hours), names_to = "type", values_to = "value")

# dataset for making bar chart comparing minifig&character count by gender
count_summarized <- screentime_summarized |>
  filter(type != "screentime_hours")

# Bar chart to compare minifig count & character count by gender
g1 <- ggplot(count_summarized, aes(x = type, y = value, fill = gender)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = value), position = position_dodge(width = 1), vjust = -0.2) +
  scale_fill_wbi() +
  labs(
    title = "Star Wars Minifigs Count versus Character Count by Gender",
    x = "",
    y = "Count",
    fill = "Gender"
  )
g1

# Bar chart to compare screentime by gender
g2 <- ggplot(filter(screentime_summarized, type == "screentime_hours"), aes(x = gender, y = value, fill = gender)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = value), vjust = 0) +
  scale_fill_wbi() +
  labs(
    title = "Star Wars Screentime Distribution by Gender",
    x = "Gender",
    y = "Screentime (hours)"
  )
g2

# Group by Eras

by_era <- screentime_data |>
  mutate(era = case_when(
    titles %in% c("Star Wars: Episode I - The Phantom Menace", "Star Wars: Episode II - Attack of the Clones", "Star Wars: Episode III - Revenge of the Sith") ~ "1",
    titles %in% c("Star Wars", "Star Wars: Episode V - The Empire Strikes Back", "Star Wars: Episode VI - Return of the Jedi") ~ "2",
    titles %in% c("Star Wars: Episode VII - The Force Awakens", "Star Wars: Episode VIII - The Last Jedi", "Star Wars: The Rise Of Skywalker") ~ "3"
  )) |>
  filter(!is.na(era)) |>
  group_by(era, character) |>
  summarize(seconds = sum(total_seconds), minutes = round(seconds / 60, 2))

write_csv(by_era, "screentime_by_era.csv") # fill in names to match original grouped screentime data

screentime_join <- screentime |>
  select(-c(seconds, minutes))
# screentime data by era
by_era2 <- read_csv(here::here("data", "screentime_by_era2.csv")) |>
  group_by(era, character) |>
  summarize(seconds = sum(seconds), minutes = round(seconds / 60, 2)) |>
  rename(name = character) |>
  left_join(screentime_join, by = "name")

# minifig data by era
minifigs_by_era <- read_csv(here::here("data", "starwars_mainfilms_minifigs.csv")) |>
  mutate(era = case_when(
    category %in% c("Star Wars Episode 1", "Star Wars Episode 2", "Star Wars Episode 3") ~ "1",
    category %in% c("Star Wars Episode 4/5/6") ~ "2",
    category %in% c("Star Wars Episode 7", "Star Wars Episode 8", "Star Wars Episode 9") ~ "3",
  ))

# function to compute number of minifigs for each character
get_num_minifigs <- function(screentime_data, minifig_data) {
  minifig_characters <- tolower(minifig_data$description)
  movie_characters <- tolower(screentime_data$name_detect)

  num_minifigs <- map_int(movie_characters, ~ sum(str_detect(minifig_characters, .x)))
  num_minifigs
}

# split by era
by_era_split <- by_era2 |>
  split(f = by_era2$era)

minifigs_split <- minifigs_by_era |>
  split(f = minifigs_by_era$era)

# compute number of minifigs for each character only within categories corresponding to the era
num_minifigs <- map2(by_era_split, minifigs_split, get_num_minifigs)

by_era_split2 <- map2(by_era_split, num_minifigs, ~ mutate(.x, num_minifigs = .y))

era_bind <- plyr::ldply(by_era_split2, bind_rows) |>
  group_by(era, name) |>
  mutate(num_minifigs = sum(num_minifigs)) |>
  select(-c(name_detect, `.id`)) |>
  distinct()

gender_summarized <- era_bind |>
  group_by(era, gender) |>
  summarize(count_character = n(), count_minifigs = sum(num_minifigs)) |>
  filter(gender != "neutral") |>
  pivot_longer(cols = c(count_character, count_minifigs), names_to = "type", values_to = "count")

screentime_summarized <- era_bind |>
  filter(gender != "neutral") |>
  group_by(era, gender) |>
  summarize(screentime = sum(minutes), hours = round(screentime / 60, 2))


## graphs by era
# Bar chart to compare minifig count & character count by gender
g1 <- ggplot(gender_summarized, aes(x = type, y = count, fill = gender)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = count), position = position_dodge(width = 1), hjust = -0) +
  scale_fill_wbi() +
  facet_wrap(~era) +
  coord_flip() +
  ylim(c(0, 220)) +
  labs(
    title = "Star Wars Minifigs Count versus Character Count by Gender and Era",
    x = "",
    y = "Count",
    fill = "Gender"
  )
add_logo(g1)

# Bar chart to compare screentime by gender
g2 <- ggplot(screentime_summarized, aes(x = gender, y = hours, fill = gender)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = hours), hjust = 0) +
  scale_fill_wbi() +
  labs(
    title = "Star Wars Screentime Distribution by Gender and Era",
    x = "Gender",
    y = "Screentime (hours)"
  ) +
  facet_wrap(~era) +
  coord_flip() +
  ylim(c(0, 10))
add_logo(g2)

# Interactive scatter plot of #minifigs over screentime (min)
p <- ggplotly(
  ggplot(era_bind, aes(x = minutes, y = num_minifigs, color = gender, text = paste("Name:", name, "\n#Minifigs:", num_minifigs, "\nScreentime:", minutes, "\nSpecies:", species))) +
    geom_point() +
    scale_color_wbi() +
    facet_grid(~era) +
    geom_jitter() +
    labs(
      title = "Relationship between Screentime and Number of Star Wars Minifigs",
      x = "Screentime (minutes)",
      y = "Number of Minifigs",
      color = "Gender"
    ),
  tooltip = "text"
)
p

htmlwidgets::saveWidget(as_widget(p), "scatterplot_by_era.html")
