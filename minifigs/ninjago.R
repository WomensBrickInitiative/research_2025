library(tidyverse)
cultural_data <- read_csv(here::here("data", "cultural_minifigs.csv"))
source(here::here("wbi_colors.R"))

# Filter to just the Ninjago minifigs
ninjago <- cultural_data |>
  filter(inspiration=="Ninjago"|inspiration=="The LEGO Ninjago Movie") |>
  # convert release_year from numeric to date; ignore month and day in the date format
  mutate(release_date=as.Date(as.character(release_year), format="%Y"))
         #release_year=lubridate::year(release_year))

# Overall gender representation in Ninjago
gender <- ninjago |>
  group_by(gender) |>
  summarise(count=n())

# Number of Ninjago minifigs created over years
year <- ninjago |>
  filter(!is.na(release_date)) |>
  group_by(release_date) |>
  summarise(count=n())

# Gender representation in Ninjago minifigs over years
gender_year <- ninjago |>
  filter(!is.na(release_date), gender != "neutral") |>
  group_by(release_date) |>
  mutate(total=n()) |>
  group_by(gender, release_date) |>
  summarize(count=n(),prop=round(count/total,2)) |>
  distinct()

# Bar chart of overall gender representation
g0 <- ggplot(gender, aes(x = gender, y = count, fill = gender)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Gender Representation in Ninjago Minifigs",
    subtitle = paste0("Out of ", sum(gender$count), " total"),
    x = "Gender",
    y = "Count",
    fill = "Gender"
  ) +
  geom_text(aes(label = count), vjust = -0.2) +
  ylim(c(0,400)) +
  scale_fill_wbi()
add_logo(g0)
g0

# linegraph for gender counts by year
g1 <- ggplot(gender_year, aes(x = release_date, y = count, color = gender)) +
  geom_line() +
  geom_point() +
  scale_color_wbi() +
  labs(title = "Counts by Gender Over Time for Ninjago Minifigs",
       x = "Year",
       y = "Count",
       color = "Gender")
g1
add_logo(g1)

# linegraph for gender proportions by year
g1a <- ggplot(gender_year, aes(x = release_date, y = prop, color = gender)) +
  geom_line() +
  geom_point() +
  scale_color_wbi() +
  labs(title = "Gender Proportions Over Time for Ninjago Minifigs",
       x = "Year",
       y = "Proportion",
       color = "Gender"
  )
g1a
add_logo(g1a)

# linegraph for counts by year
g2 <- ggplot(year, aes(x = release_date, y = count)) +
  geom_line() +
  geom_point() +
  labs(title = "Counts Over Time for Ninjago Minifigs",
       x = "Year",
       y = "Count")
g2
add_logo(g2)
