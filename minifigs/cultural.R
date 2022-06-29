library(tidyverse)
cultural_data <- read_csv(here::here("data", "cultural_minifigs.csv"))
source(here::here("wbi_colors.R"))

cultural <- cultural_data |>
  mutate(culture_represented=ifelse(culture_represented=="Mohawk" |
                  culture_represented=="American Indian", "Native American", culture_represented)) |>
  mutate(inspiration=ifelse(inspiration=="N/A" |
                              inspiration=="90307pb02: Red Minifigure, Headgear Hat, Mexican Sombrero with Bright Green Trim Pattern. 90542pb02: Yellow Minifigure Poncho Half Cloth with Green and Red Mexican Print Pattern",
                            NA, inspiration)) |>
  mutate(gender=tolower(gender)) |>
  mutate(gender=ifelse(gender=="n/a",NA,gender)) |>
  mutate(release_year=as.numeric(substr(year,1,4))) |>
  mutate(region=case_when(
    culture_represented=="Egyptian"|
      culture_represented=="Muslim/islamic"|
      culture_represented=="Middle Eastern and Asian" ~"Middle Eastern",
    culture_represented=="German"|
      culture_represented=="British"|
      culture_represented=="Spanish"|
      culture_represented=="Greek"|
      culture_represented=="Roman"|
      culture_represented=="European"|
      culture_represented=="Irish"|
      culture_represented=="Swedish"|
      culture_represented=="Viking" ~ "Western European",
    culture_represented=="Ukranian"|
      culture_represented=="Armenian"|
      culture_represented=="Russian" ~ "Eastern European",
    culture_represented=="Chinese"|
      culture_represented=="Japanese"|
      culture_represented=="East Asian"|
      culture_represented== "Mongolian" ~ "East Asian",
    culture_represented=="Indian"|
      culture_represented=="South Asian" ~ "South Asian",
    culture_represented=="Pacific Islander (loosely)"|
      culture_represented=="Polynesian" ~ "Pacific Islander",
    culture_represented=="Aztec"|
      culture_represented=="Mexican" ~ "Mesoamerican",
    culture_represented=="South American" ~ "South American",
    culture_represented=="Native American" ~ "Native North American"
  ))

culture_summarized <- cultural |>
  group_by(culture_represented) |>
  summarise(count=n())

region_summarized <- cultural |>
  group_by(region) |>
  summarise(count=n())

gender_summarized <- cultural |>
  group_by(gender) |>
  summarise(count=n())

# Bar chart of gender representation
g1 <- ggplot(gender_summarized, aes(x = gender, y = count, fill = gender)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Gender Representation in Cultural Minifigs",
    subtitle = paste0("Out of ",sum(gender_summarized$count)," total"),
    x = "Gender",
    y = "Count",
    fill = "Gender"
  ) +
  geom_text(aes(label = count),vjust=-0.2) +
  scale_fill_wbi()
g1
g1 <- add_logo(g1)

# Bar chart of region representation
g2 <- ggplot(region_summarized, aes(x = reorder(region, count), y = count)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "Region Representation in Cultural Minifigs",
    subtitle = paste0("Out of ",sum(region_summarized$count)," total"),
    x = "Region",
    y = "Count"
  ) +
  coord_flip() +
  geom_text(aes(label = count),hjust=-0.2)
g2
g2 <- add_logo(g2)

chinese <- cultural |>
  filter(culture_represented=="Chinese") |>
  group_by(release_year) |>
  summarise(count=n())

g3 <- ggplot(chinese, aes(x=release_year)) +
  geom_histogram(binwidth = 3) +
  labs(
    title = "Chinese Minifigs Released Over Time",
    subtitle = paste0("Out of ",nrow(chinese)," total"),
    x = "Year",
    y = "Count"
  )
g3
g3 <- add_logo(g3)
