library(tidyverse)
cultural_data <- read_csv(here::here("data", "cultural_minifigs.csv"))
source(here::here("wbi_colors.R"))

## Exclude Ninjago and Monkie Kid
other <- cultural_data |>
  filter(!inspiration %in% c("Monkie Kid","Ninjago","The LEGO Ninjago Movie")) |>
  mutate(parts_link = paste0("https://www.bricklink.com/catalogItemInv.asp?M=", item_number))

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
parts_data <- map(other$parts_link, scrape_parts_description)

# Add parts_info to sets_data and unnest so that each row is a part of the minifig
other_heads <- other |>
  mutate(parts_info = parts_data) |>
  unnest(cols = parts_info) |>
  filter(str_detect(parts_description, "Minifigure, Head ")) |>
  separate(col = parts_description, into = c("flesh_tone","discarded"), sep = " Minifigure, Head ") |>
  select(-parts_id, -discarded)

missing_heads <- map_lgl(other$item_number, `%in%`, other_heads$item_number)

heads <- other |>
  filter(!missing_heads) |>
  mutate(flesh_tone=c("Yellow","Light Nougat","Reddish Brown","Yellow","Yellow")) |>
  bind_rows(other_heads) |>
  filter(flesh_tone %in% skin_colors)

heads_summarized <- heads |>
  group_by(region) |>
  mutate(total=n()) |>
  group_by(region, flesh_tone) |>
  summarize(count=n(),prop=round(count/total, 2)) |>
  distinct() |>
  mutate(prop=prop*100)

g1 <- ggplot(heads_summarized, aes(x=flesh_tone, y=count, fill=flesh_tone)) +
  geom_col(show.legend = FALSE) +
  labs(title = "Distribution of flesh tones by region (count)",
       x = "Flesh Tones",
       y = "Count") +
  coord_flip() +
  scale_fill_skintones() +
  facet_wrap(~region)
g1

g2 <- ggplot(heads_summarized, aes(x=flesh_tone, y=prop, fill=flesh_tone)) +
  geom_col(show.legend = FALSE) +
  labs(title = "Distribution of flesh tones by region (percentage)",
       x = "Flesh Tones",
       y = "Percent") +
  coord_flip() +
  scale_fill_skintones() +
  facet_wrap(~region)
g2
