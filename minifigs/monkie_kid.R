library(tidyverse)
cultural_data <- read_csv(here::here("data", "cultural_minifigs.csv"))
source(here::here("wbi_colors.R"))

# Filter to just the Monkie Kid minifigs
monkie <- cultural_data |>
  filter(inspiration=="Monkie Kid") |>
  # convert release_year from numeric to date; ignore month and day in the date format
  mutate(release_date=as.Date(as.character(release_year), format="%Y"))
#release_year=lubridate::year(release_year))

# Overall gender representation in Monkie Kid
gender <- monkie |>
  group_by(gender) |>
  summarise(count=n())

# Number of Monkie Kid minifigs created over years
year <- monkie |>
  filter(!is.na(release_year)) |>
  group_by(release_date) |>
  summarise(count=n())

# Gender representation in Monkie Kid minifigs over years
gender_year <- monkie |>
  filter(!is.na(release_year), gender != "neutral") |>
  group_by(release_year) |>
  mutate(total=n()) |>
  group_by(gender, release_year) |>
  summarize(count=n(),prop=round(count/total,2)) |>
  distinct()

# Bar chart of overall gender representation
g0 <- ggplot(gender, aes(x = gender, y = count, fill = gender)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Gender Representation in Monkie Kid Minifigs",
    subtitle = paste0("Out of ", sum(gender$count), " total"),
    x = "Gender",
    y = "Count",
    fill = "Gender"
  ) +
  ylim(c(0,35))+
  geom_text(aes(label = count), vjust = -0.2) +
  scale_fill_wbi()
add_logo(g0)
g0

# bar chart for gender counts by year
g1 <- ggplot(gender_year, aes(x = release_year, y = count, fill = gender)) +
  geom_col(position = "dodge") +
  scale_fill_wbi() +
  # https://statisticsglobe.com/r-position-geom_text-labels-in-grouped-ggplot2-barplot
  geom_text(aes(label = count), position = position_dodge(width = 1), vjust = -0.2) +
  ylim(c(0,12)) +
  labs(title = "Counts by Gender Over Time for Monkie Kid Minifigs",
       x = "Year",
       y = "Count",
       color = "Gender")
g1
add_logo(g1)
