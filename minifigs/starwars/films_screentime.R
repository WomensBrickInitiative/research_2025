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
  mutate(seconds = ifelse(is.na(seconds), 0, seconds),
         minutes = ifelse(minutes == "" | minutes == "x", 0, minutes)) |>
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
  mutate(species=tolower(species),is_human=ifelse(species=="human","human","non human")) |>
  mutate(name_detect = case_when(name_detect=="BB-8"~"BB-8 ",
                   name_detect=="Sabe"~"Sabe ",
                   name_detect=="Sebulba"~"Sebulba ",
                   name_detect=="Val"~"Val ",
                   TRUE ~ name_detect))

minifigs <- read_csv(here::here("data", "minifigs_data.csv"))
starwars <- minifigs |>
  filter(category=="Star Wars")

# compute number of minifigs for each character
minifig_characters <- tolower(starwars$description)
movie_characters <- tolower(screentime$name_detect)

num_minifigs <- map_int(movie_characters, ~sum(str_detect(minifig_characters, .x)))

screentime <- screentime |>
  mutate(num_minifigs=num_minifigs) |>
  # combine anakin skywalker and darth vader
  mutate(num_minifigs=ifelse(name=="Anakin Skywalker / Darth Vader",53,num_minifigs)) |>
  select(-name_detect) |>
  distinct() |>
  mutate(has_minifigs=ifelse(num_minifigs>0,TRUE,FALSE))

# Interactive scatter plot of #minifigs over screentime (min)
p <- ggplotly(
  ggplot(screentime, aes(x=minutes, y=num_minifigs, color=gender,text = paste("Name:", name, "\n#Minifigs:", num_minifigs,"\nScreentime:", minutes, "\nSpecies:", species))) +
  geom_point() +
  scale_color_wbi() +
  labs(title = "Relationship between Screentime and Number of Star Wars Minifigs",
       x = "Screentime (minutes)",
       y = "Number of Minifigs",
       color = "Gender"),
  tooltip = "text"
)
p

# dataset for making bar chart comparing screentime by gender
screentime_summarized <- screentime |>
  select(gender, num_minifigs, minutes) |>
  group_by(gender) |>
  summarize(count_gender=n(), time_gender=sum(minutes), count_minifigs=sum(num_minifigs)) |>
  filter(gender!="neutral") |>
  mutate(screentime_hours=round(time_gender/60,2)) |>
  pivot_longer(cols = c(count_gender, count_minifigs, screentime_hours), names_to = "type", values_to = "value")

# dataset for making bar chart comparing minifig&character count by gender
count_summarized <- screentime_summarized |>
  filter(type!="screentime_hours")

# Bar chart to compare minifig count & character count by gender
g1 <- ggplot(count_summarized, aes(x=type, y=value, fill=gender)) +
  geom_col(position = "dodge") +
  geom_text(aes(label=value),position = position_dodge(width = 1),vjust=-0.2) +
  scale_fill_wbi() +
  labs(title = "Star Wars Minifigs Count versus Character Count by Gender",
       x="",
       y="Count",
       fill="Gender")
g1

# Bar chart to compare screentime by gender
g2 <- ggplot(filter(screentime_summarized,type=="screentime_hours"), aes(x=gender, y=value, fill=gender)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label=value), vjust=0) +
  scale_fill_wbi() +
  labs(title = "Star Wars Screentime Distribution by Gender",
       x="Gender",
       y="Screentime (hours)")
g2
