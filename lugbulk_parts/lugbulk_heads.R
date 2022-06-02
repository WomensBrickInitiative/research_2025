library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R")) # file containing functions to customize colors


# read in parts data 2022
data <- read.csv(here::here("data", "lugbulk_parts.csv"))

# filter to just heads
data_heads <- data |>
  janitor::clean_names() |>
  mutate(price_usd = as.numeric(substr(usd, 2, 5))) |>
  filter(category == "FIGURE, HEADS AND MA" & subcategory == "MINI FIGURE HEADS") |>
  select(item_id, item_description, bl_part_id, brick_link_color, category, subcategory, price_usd, brick_set) |>
  mutate(brick_link_url = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", bl_part_id))

# function to scrape descriptions
get_description <- function(url) {
  page <- read_html(url)
  description <- page |>
    html_elements("#item-name-title") |>
    html_text()
  description
}

# scrape descriptions
descriptions <- map(data_heads$brick_link_url, get_description)
descriptions <- descriptions |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

# classify gender categories based on specific indicating strings
data_heads <- data_heads |>
  mutate(description = descriptions) |>
  filter(description != "NA") |> # filter out missing descriptions
  mutate(
    is_female = str_detect(tolower(description), "female"),
    is_male = str_detect(tolower(description), " male") |
      str_detect(tolower(description), "beard") |
      str_detect(tolower(description), "goatee") |
      str_detect(tolower(description), "sideburns") |
      str_detect(tolower(description), "moustache") |
      str_detect(tolower(description), "stubble"),
    is_child = str_detect(tolower(description), "child"),
    is_dual_sided = str_detect(tolower(description), "dual sided"),
    is_plain = str_detect(tolower(description), "plain"),
    is_nonhuman = str_detect(tolower(description), "pineapple") |
      str_detect(tolower(description), "cobra") |
      str_detect(tolower(description), "skull") |
      str_detect(tolower(description), "ghost") |
      str_detect(tolower(description), "alien"),
    type = case_when(
      is_female ~ "female",
      is_male ~ "male",
      is_child ~ "child",
      is_plain ~ "no face",
      is_nonhuman ~ "non human",
      !(is_female | is_male | is_child | is_plain | is_nonhuman) ~ "neutral"
    )
  )


# summarize by gender
data_type <- data_heads |>
  group_by(type) |>
  summarize(count = n())

# eliminate non-humans and no faces, calculate proportions
data_type_human <- data_heads |>
  group_by(type) |>
  summarize(count = n()) |>
  filter(type != "non human") |>
  filter(type != "no face") |>
  mutate(total_count = sum(count), prop = round(count / total_count, 2))

# plot count by type w/ all types, not currently used
p_type <- ggplot(data_type, aes(x = reorder(type, count), y = count)) +
  geom_col() +
  coord_flip()
p_type

# plot counts by type humans w/ faces only
p_type_human <- ggplot(data_type_human, aes(x = reorder(type, count), y = count, fill = type)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_wbi() +
  labs(
    title = "Head Count by Category 2022 (Humans with Faces Only)",
    x = "Category",
    y = "Count",
    fill = "Category"
  ) +
  geom_text(aes(label = count), hjust = -0.4)
add_logo(p_type_human)

# plot proportions by type humans w/ faces only
p_type_human_prop <- ggplot(data_type_human, aes(x = reorder(type, prop), y = prop, fill = type)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_wbi() +
  labs(
    title = "Head Proportions by Category 2022 (Humans with Faces Only)",
    x = "Category",
    y = "Proportion",
    fill = "Category"
  ) +
  geom_text(aes(label = prop), hjust = 1)
add_logo(p_type_human_prop)
p_type_human_prop


# summarize by brick link color
data_color <- data_heads |>
  group_by(brick_link_color) |>
  summarize(
    count = n(), avg_price = round(mean(price_usd), 2),
    median_price = median(price_usd)
  ) |>
  filter(brick_link_color %in% skin_colors) # filter to only yellow or flesh colors

# barchart median price by color-- not currently used
p1 <- ggplot(data_color, aes(x = reorder(brick_link_color, median_price), y = median_price)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Median Price of Heads by Color",
    x = "Color", y = "Median Price (usd)",
    fill = "Color"
  )
add_logo(p1)

# barchart counts by color
p2 <- ggplot(
  data_color,
  aes(reorder(brick_link_color, count), y = count, fill = brick_link_color)
) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_skintones() +
  geom_text(aes(label = count), hjust = -0.4) +
  labs(
    x = "Color",
    y = "Count"
  ) +
  ggtitle("Head Counts by Color 2022")

add_logo(p2)
