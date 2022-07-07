library(tidyverse)
cultural_data <- read_csv(here::here("data", "cultural_minifigs.csv"))
source(here::here("wbi_colors.R"))

# cleaning and grouping by broader geographic region
cultural <- cultural_data |>
  mutate(culture_represented = ifelse(culture_represented == "Mohawk" |
    culture_represented == "American Indian", "Native American", culture_represented)) |>
  mutate(inspiration = ifelse(inspiration == "N/A" |
    inspiration == "90307pb02: Red Minifigure, Headgear Hat, Mexican Sombrero with Bright Green Trim Pattern. 90542pb02: Yellow Minifigure Poncho Half Cloth with Green and Red Mexican Print Pattern",
  NA, inspiration
  )) |>
  mutate(gender = tolower(gender)) |>
  mutate(
    gender = ifelse(is.na(gender), "neutral", gender),
    gender = ifelse(gender == "n/a", "neutral", gender),
    gender = ifelse(gender == "femlae", "female", gender)
  ) |>
  mutate(release_year = as.numeric(substr(year, 1, 4))) |>
  mutate(region = case_when(
    culture_represented == "Egyptian" |
      culture_represented == "Muslim/islamic" |
      culture_represented == "Middle Eastern and Asian" ~ "Middle Eastern",
    culture_represented == "German" |
      culture_represented == "British" |
      culture_represented == "Spanish" |
      culture_represented == "Greek" |
      culture_represented == "Roman" |
      culture_represented == "European" |
      culture_represented == "Irish" |
      culture_represented == "Swedish" |
      culture_represented == "Scandinavian" |
      culture_represented == "Viking" ~ "Western European",
    culture_represented == "Ukranian" |
      culture_represented == "Armenian" |
      culture_represented == "Russian" ~ "Eastern European",
    culture_represented == "Chinese" |
      culture_represented == "Japanese" |
      culture_represented == "East Asian" |
      culture_represented == "Mongolian" ~ "East Asian",
    culture_represented == "Indian" |
      culture_represented == "South Asian" ~ "South Asian",
    culture_represented == "Pacific Islander (loosely)" |
      culture_represented == "Polynesian" ~ "Pacific Islander",
    culture_represented == "Aztec" |
      culture_represented == "Mexican" ~ "Mesoamerican",
    culture_represented == "South American" ~ "South American",
    culture_represented == "Native American" ~ "Native North American"
  ))

# summarize counts by culture
culture_summarized <- cultural |>
  group_by(culture_represented) |>
  summarise(count = n())

# summarize counts by broader region
region_summarized <- cultural |>
  group_by(region) |>
  summarise(count = n())

# summarize counts by gender
gender_summarized <- cultural |>
  group_by(gender) |>
  summarise(count = n())

# summarize counts by region and gender
region_gender_summarized <- cultural |>
  group_by(region, gender) |>
  summarise(count = n())

# summarize by inspiration
inspiration_summarized <- cultural |>
  group_by(inspiration) |>
  summarise(count = n())

# summarize by year
year_summarized <- cultural |>
  filter(!is.na(release_year)) |>
  group_by(release_year) |>
  summarise(count = n())

# summarize by gender and year
year_gender_summarized <- cultural |>
  filter(!is.na(release_year), gender != "neutral") |>
  group_by(release_year) |>
  mutate(total = n()) |>
  group_by(release_year, gender) |>
  summarise(count = n(), prop = count/total) |>
  distinct()

# linegraph for gender counts by year
g5 <- ggplot(year_gender_summarized, aes(x = release_year, y = count, color = gender)) +
  geom_line() +
  geom_point() +
  scale_color_wbi() +
  labs(title = "Counts by Gender Over Time for Cultural Minifigs",
       x = "Year",
       y = "Count",
       color = "Gender")
add_logo(g5)

# linegraph for gender proportions by year
g5a <- ggplot(year_gender_summarized, aes(x = release_year, y = prop, color = gender)) +
  geom_line() +
  geom_point() +
  scale_color_wbi() +
  labs(title = "Gender Proportions Over Time for Cultural Minifigs",
       x = "Year",
       y = "Proportion",
       color = "Gender"
       )
add_logo(g5a)

# linegraph for counts by year
g6 <- ggplot(year_summarized, aes(x = release_year, y = count)) +
  geom_line() +
  geom_point() +
  labs(title = "Counts Over Time for Cultural Minifigs",
       x = "Year",
       y = "Count")
add_logo(g6)

# Bar chart of gender representation
g1 <- ggplot(gender_summarized, aes(x = gender, y = count, fill = gender)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Gender Representation in Cultural Minifigs",
    subtitle = paste0("Out of ", sum(gender_summarized$count), " total"),
    x = "Gender",
    y = "Count",
    fill = "Gender"
  ) +
  geom_text(aes(label = count), vjust = -0.2) +
  scale_fill_wbi()
add_logo(g1)

# Bar chart of region representation
g2 <- ggplot(region_summarized, aes(x = reorder(region, count), y = count)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Region Representation in Cultural Minifigs",
    subtitle = paste0("Out of ", sum(region_summarized$count), " total"),
    x = "Region",
    y = "Count"
  ) +
  coord_flip() +
  geom_text(aes(label = count), hjust = -0.2)
add_logo(g2)


# Bar chart of region and gender representation
g4 <- ggplot(region_gender_summarized, aes(x = reorder(gender, count), y = count, fill = gender)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Gender Representation by Region in Cultural Minifigs",
    subtitle = paste0("Out of ", sum(region_gender_summarized$count), " total"),
    x = "Region",
    y = "Count"
  ) +
  facet_wrap(~region) +
  geom_text(aes(label = count), vjust = 0) +
  scale_fill_wbi() +
  ylim(c(0, 460))

add_logo(g4)

# Bar chart of region and gender representation (without East Asian)
g4a <- ggplot(filter(region_gender_summarized, region != "East Asian"), aes(x = reorder(gender, count), y = count, fill = gender)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Gender Representation by Region in Cultural Minifigs (Without East Asian)",
    x = "Region",
    y = "Count"
  ) +
  facet_wrap(~region) +
  geom_text(aes(label = count), vjust = 0) +
  scale_fill_wbi() +
  ylim(c(0, 60))
add_logo(g4a)

chinese <- cultural |>
  filter(culture_represented == "Chinese")

g3 <- ggplot(chinese, aes(x = release_year)) +
  geom_histogram(binwidth = 3) +
  labs(
    title = "Chinese Minifigs Released Over Time",
    subtitle = paste0("Out of ", nrow(chinese), " total"),
    x = "Year",
    y = "Count"
  )
g3

## cmfs

cmfs <- cultural |>
  filter(str_detect(category, "Collectible Minifigures: Series"))
