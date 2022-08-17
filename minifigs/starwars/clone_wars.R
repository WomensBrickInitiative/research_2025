library(tidyverse)
source(here::here("wbi_colors.R"))
library(rvest)

# data with links to screentime info for each season 1-7
clone_wars_links <- read_csv(here::here("data", "starwars", "clone_wars.csv"))

# function to pull clone wars screen time
get_screentime_data <- function(url, season) {
  page <- read_html(url)
  screentime <- page |>
    html_elements(".list-description p") |>
    html_text() |>
    str_split("\n")
  screentime_data <- tibble(screentime) |>
    unnest(cols = c(screentime)) |>
    separate(col = screentime, into = c("character", "screentime"), sep = "<") |>
    mutate(character = str_replace_all(character, "\"", ""),
           character = trimws(character)) |>
    mutate(screentime = str_sub(screentime, 1, -2)) |>
    separate(col = screentime, into = c("minutes", "seconds"), sep = ":") |>
    mutate(minutes = as.numeric(minutes), seconds = as.numeric(seconds)) |>
    mutate(total_seconds = seconds + 60 * minutes) |>
    mutate(season = season)
  screentime_data
}

# scrape screentime info
clone_wars_screentime <- map2(clone_wars_links$link, clone_wars_links$Season, get_screentime_data) |>
  plyr::ldply(bind_rows)

# summarize screentime by character
clone_wars_summarized <- clone_wars_screentime |>
  mutate(character = case_when(
    character == "Willhuff Tarkin" ~ "Wilhuff Tarkin",
    character == "Luminar Unduli" ~ "Luminara Unduli",
    character == "Jabba Desilijic Tiure" ~ "Jabba",
    character == "Eeth Koth 0:09>" ~ "Eeth Koth",
    character == "Orn Free Taaa" ~ "Orn Free Taa",
    character == "Padmé Amidala" ~ "Padme",
    TRUE ~ character
    )
  ) |>
  mutate(total_seconds = ifelse(is.na(total_seconds), 0, total_seconds)) |>
  group_by(character) |>
  summarize(seconds = sum(total_seconds), minutes = round(seconds/60, 2))

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

# scrape minifig data from clone wars bricklink category
minifigs_links <- c("https://www.bricklink.com/catalogList.asp?catType=M&catString=65.635",
                    "https://www.bricklink.com/catalogList.asp?pg=2&catType=M&catString=65.635",
                    "https://www.bricklink.com/catalogList.asp?pg=3&catType=M&catString=65.635")

clone_wars_minifigs <- map(minifigs_links, scrape_minifigs_data) |>
  plyr::ldply(bind_rows)

# compute total number of minifigs per character

# compute number of minifigs for each character
# function to compute number of minifigs for each character
get_num_minifigs <- function(screentime_data, minifig_data) {
  minifig_characters <- tolower(minifig_data$description)
  movie_characters <- tolower(screentime_data$character)

  num_minifigs <- map_int(movie_characters, ~ sum(str_detect(minifig_characters, .x)))
  num_minifigs
}

num_minifigs <- get_num_minifigs(clone_wars_summarized, clone_wars_minifigs)

clone_wars <- clone_wars_summarized |>
  mutate(num_minifigs = num_minifigs)

write_csv(clone_wars, "clone_wars.csv")

### Analysis

clone_wars <- read_csv(here::here("data", "starwars", "clone_wars.csv")) |>
  filter(gender != "No idea who this is")


# dataset for making bar chart comparing screentime by gender
screentime_summarized <- clone_wars |>
  select(gender, num_minifigs, minutes) |>
  group_by(gender) |>
  summarize(count_gender = n(), time_gender = sum(minutes), count_minifigs = sum(num_minifigs)) |>
  mutate(screentime_hours = round(time_gender / 60, 2)) |>
  pivot_longer(cols = c(count_gender, count_minifigs, screentime_hours), names_to = "type", values_to = "value")

# dataset for making bar chart comparing minifig&character count by gender
count_summarized <- screentime_summarized |>
  filter(type != "screentime_hours") |>
  mutate(type = ifelse(type == "count_gender", "characters", "minifigs"))

# Bar chart to compare minifig count & character count by gender
g1 <- ggplot(count_summarized, aes(x = type, y = value, fill = gender)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = value), position = position_dodge(width = 1), vjust = -0.2) +
  scale_fill_wbi() +
  labs(
    title = "Minifigs Count versus Character Count by Gender",
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
    title = "Screentime Distribution by Gender",
    x = "Screen Time",
    y = "Hours"
  ) +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank())
g2

# compute gender percentages for screentime, characters, and minifigs--main films
percentages_summarized <- clone_wars |>
  mutate(
    total_screentime = sum(minutes),
    total_minifigs = sum(num_minifigs),
    total_characters = n()
  ) |>
  group_by(gender) |>
  summarise(
    screentime_sum = sum(minutes),
    minifigs_sum = sum(num_minifigs),
    characters_sum = n(),
    perc_screentime = round(100 * screentime_sum / total_screentime),
    perc_minifigs = round(100 * minifigs_sum / total_minifigs),
    perc_characters = round(100 * characters_sum / total_characters),
  ) |>
  distinct() |>
  select(-c(screentime_sum, characters_sum, minifigs_sum)) |>
  pivot_longer(cols = -gender, names_to = "type", values_to = "value") |>
  separate(type, into = c("discard", "type"), sep = "_") |>
  select(-discard)

# barchart comparing gender percentages for screentime, characters, and minifigs
b3 <- ggplot(
  percentages_summarized,
  aes(x = type, y = value, fill = gender)
) +
  geom_col() +
  scale_fill_wbi() +
  labs(
    title = "Percentage Breakdown by Gender for Characters, Minifigs, and Screentime",
    x = "",
    y = "Percentage",
    fill = "Gender"
  )
add_logo(b3)

library(plotly)
# screen tiem vs number of minifigs scatterplot
p <- ggplotly(
  ggplot(clone_wars, aes(x = minutes, y = num_minifigs, color = gender, text = paste("Name:", character, "\n#Minifigs:", num_minifigs, "\nScreentime:", minutes, "\nSpecies:", species))) +
    geom_jitter(alpha = 0.5) +
    # geom_smooth() + not working
    scale_color_wbi() +
    labs(
      title = "Relationship between Screentime and Number of Minifigs (Clone Wars)",
      x = "Screentime (minutes)",
      y = "Number of Minifigs",
      color = "Gender"
    ),
  tooltip = "text"
)
p

htmlwidgets::saveWidget(as_widget(p), "scatterplot_clone_wars.html")
