library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R")) # file containing functions to customize colors

data_2017 <- read_csv(here::here("data", "lugbulk_parts2017.csv")) |>
  janitor::clean_names() |>
  mutate(price_usd = as.numeric(substr(bl_price, 2, 5))) |>
  select(element_id, bl_id, bl_color, item_description, group, price_usd, number_of_people_ordering, total_ordered_qt_of_50_25, bl_url)
#mutate(brick_link_url = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", bl_id))

data_2017_head <- data_2017 |>
  filter(str_detect(item_description, "MINI HEAD"))

# minifigs by color only
data_mini_fig_color <- data_2017_head |>
  group_by(bl_color) |>
  summarize(
    count = n(), avg_price = round(mean(price_usd), 2),
    median_price = median(price_usd)
  )

# minifig count
data_mini_fig_count <- data_mini_fig_color |>
  # filter(count > 1) |>
  mutate(bl_color=ifelse(bl_color=="Light Flesh", "Light Nougat", bl_color)) |>
  filter(bl_color %in% skin_colors)

p2 <- ggplot(data_mini_fig_count,
             aes(reorder(bl_color, count), y = count, fill = bl_color)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_skintones() +
  geom_text(aes(label = count), hjust = -0.3) +
  labs(
    title = "Head Counts by Color 2017",
    x = "Color",
    y = "Count"
  )

add_logo(p2)
p2

