library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R"))

town_parts <- read_csv(here::here("data", "town", "town_parts_2017-2022.csv"))

neutral_heads <- town_parts |>
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
  ) |>
  filter(type == "neutral") |>
  select(-category, -item_number, -description, -parts_link, -item_link, -release_year, -is_female, -is_male, -type) |>
  distinct() |>
  filter(!str_detect(parts_description, "(Plain)")) |>
  mutate(
    head_link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", parts_id),
    minifigs_link = paste0("https://www.bricklink.com/catalogItemIn.asp?P=", parts_id, "&in=M")
  )

# function to scrape minifigure ids for minifigs in each set
scrape_mini_id <- function(url) {
  item_page <- rvest::read_html(url)
  mini_id <- item_page |>
    html_elements("td:nth-child(3) a:nth-child(1)") |>
    html_text()
  mini_id
}

# Vector to store scraped minifigure ids (no description for the whole minifig)
mini_info <- map(neutral_heads$minifigs_link, scrape_mini_id)

# Add minifig ids to sets_data and unnest so that each row is a minifig
neutral_heads <- neutral_heads |>
  mutate(mini_id = mini_info) |>
  unnest(cols = mini_id)

# Add parts_link for each minifig
neutral_heads <- neutral_heads |>
  select(-minifigs_link) |>
  mutate(
    parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", mini_id),
    minifig_link = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?M=", mini_id)
  )

# Scrape Minifigure Description (from the minifigure's page)
scrape_mini_description <- function(url) {
  item_page <- rvest::read_html(url)
  description <- item_page |>
    rvest::html_elements("#item-name-title") |>
    rvest::html_text()
  description
}

# Vector to store scraped minifigures' description
mini_description <- map(neutral_heads$minifig_link, scrape_mini_description)

neutral_heads <- neutral_heads |>
  mutate(mini_description = mini_description) |>
  filter(
    !str_detect(mini_description, "Ghost"),
    !str_detect(mini_description, "Skeleton"),
    !str_detect(mini_description, "Clown")
  ) |>
  mutate( # categorize heads to female, male, neutral
    gender = case_when(
      str_detect(mini_description, "Mom") |
        str_detect(mini_description, "Ballerina") |
        str_detect(mini_description, "Barista") |
        str_detect(mini_description, "Ballerina") |
        str_detect(mini_description, "Ballerina") |
        str_detect(mini_description, "Ballerina") |
        str_detect(tolower(mini_description), "female") |
        str_detect(tolower(mini_description), "woman") |
        str_detect(tolower(mini_description), "girl") |
        str_detect(tolower(mini_description), "lady") |
        str_detect(tolower(mini_description), "ponytail") |
        str_detect(mini_description, "Little Red") |
        str_detect(mini_description, "Sally") |
        str_detect(mini_description, "Madison") |
        str_detect(tolower(mini_description), "necklace") ~ "female",
      str_detect(mini_description, "Male") |
        str_detect(tolower(mini_description), "beard") |
        str_detect(tolower(mini_description), "goatee") |
        str_detect(tolower(mini_description), "sideburns") |
        str_detect(tolower(mini_description), "moustache") |
        str_detect(tolower(mini_description), "stubble") |
        str_detect(mini_description, "Man") |
        str_detect(mini_description, "Son") |
        str_detect(mini_description, "Dad") |
        str_detect(mini_description, "Guy") |
        str_detect(tolower(mini_description), "father") |
        str_detect(tolower(mini_description), "uncle") |
        str_detect(tolower(mini_description), "salesman") |
        str_detect(tolower(mini_description), "businessman") |
        str_detect(mini_description, "Dareth") |
        str_detect(mini_description, "Chad") |
        str_detect(mini_description, "Rocky") |
        str_detect(mini_description, "Si") |
        str_detect(mini_description, "Ronny") |
        str_detect(mini_description, "Chan Kong-Sang") |
        str_detect(mini_description, "Jia") |
        str_detect(mini_description, "Groom") |
        str_detect(mini_description, "Chase McCain") |
        str_detect(mini_description, "Hans Christian Andersen") |
        str_detect(mini_description, "Merman") |
        str_detect(mini_description, "Santa") |
        str_detect(mini_description, "Billy") |
        str_detect(mini_description, "Lil' Nelson") |
        str_detect(mini_description, "Tito") |
        str_detect(mini_description, "Jack") |
        str_detect(mini_description, "Robin") |
        str_detect(mini_description, "Tommy") |
        str_detect(mini_description, "Wade") |
        str_detect(mini_description, "Lee") |
        str_detect(mini_description, "Paul") |
        str_detect(mini_description, "Duke") |
        str_detect(mini_description, "Wizard") |
        str_detect(tolower(mini_description), "boy") ~ "male",
      TRUE ~ "neutral"
    )
  )

temp_neutral <- neutral_heads |>
  filter(gender == "neutral")

gender_summarized <- neutral_heads |>
  group_by(gender) |>
  summarise(count = n())

unique_heads_summarized <- neutral_heads |>
  group_by(parts_id) |>
  mutate(total=n()) |>
  filter(total>1) |>
  group_by(parts_id, gender) |>
  summarize(count=n(),perc=round(count/total*100)) |>
  distinct()

# boxplot
b1 <- ggplot(unique_heads_summarized, aes(x=gender, y=perc, fill=gender)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_wbi() +
  labs(title = "Distribution of Minifigs' Gender Percentages for Neutral Heads",
       x = "Gender",
       y = "Percentage")
b1

# histogram
h1 <- ggplot(unique_heads_summarized, aes(x=perc, fill=gender)) +
  geom_histogram(binwidth = 10) +
  facet_wrap(~gender) +
  scale_fill_wbi() +
  labs(title = "Distribution of Minifigs' Gender Percentages for Neutral Heads",
       x = "Percentage",
       y = "Frequency")
h1

# stacked bar chart showing gender dist. of unique neutral heads
g1 <- ggplot(unique_heads_summarized, aes(x=reorder(parts_id, perc), y=perc, fill=gender)) +
  geom_col() +
  scale_fill_wbi() +
  labs(title = "Minifigs' Gender Distribution by Unique Neutral Heads",
       x="Unique Neutral Heads",
       y="Percentage") +
  theme(axis.text.x = element_blank(), axis.ticks.x=element_blank())

g1
