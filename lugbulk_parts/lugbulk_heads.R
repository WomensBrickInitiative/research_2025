
library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R")) # file containing functions to customize colors


# read in parts data
data <- read.csv(here::here("data", "lugbulk_parts.csv"))
# filter to just heads
data_heads <- data |>
  janitor::clean_names() |>
  mutate(price_usd = as.numeric(substr(usd, 2, 5))) |>
  filter(category == "FIGURE, HEADS AND MA" & subcategory == "MINI FIGURE HEADS") |>
  select(item_id, item_description, bl_part_id, brick_link_color, category, subcategory, price_usd, brick_set) |>
  mutate(brick_link_url = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", bl_part_id))

get_description <- function(url) {
  page <- read_html(url)
  description <- page |>
    html_elements("#item-name-title") |>
    html_text()
  description
}

descriptions <- map(data_heads$brick_link_url, get_description)
descriptions <- descriptions |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

data_heads <- data_heads |>
  mutate(description = descriptions) |>
  mutate(is_female = str_detect(tolower(description), "female"),
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



data_heads2 <- data_heads |>
  filter(description != "NA")

data_type <- data_heads2 |>
  group_by(type) |>
  summarize(count = n())

data_type_human <- data_heads2 |>
  group_by(type) |>
  summarize(count = n()) |>
  filter(type != "non human") |>
  filter(type != "no face")

p_type <- ggplot(data_type, aes(x = reorder(type, count), y = count)) +
  geom_col() +
  coord_flip()
p_type

p_type_human <- ggplot(data_type_human, aes(x = reorder(type, count), y = count, fill = type)) +
  geom_col() +
  coord_flip() +
  scale_fill_wbi() +
  labs(title = "Head Count by Category (Humans with Faces Only)",
       x = "Category",
       y = "Count",
       fill = "Category") +
  geom_text(aes(label = count), hjust = 1)
add_logo(p_type_human)
# subcategories (mini figs, various)
data_subcategories <- data_heads |>
  group_by(subcategory) |>
  summarize(
    count = n(), avg_price = round(mean(price_usd), 2),
    median_price = median(price_usd)
  )

# only mini fig data
data_mini_fig <- data_heads %>% filter(subcategory == "MINI FIGURE HEADS")
summarize(
  count = n(), avg_price = round(mean(price_usd), 2),
  median_price = median(price_usd)
)

# minifigs by color only
data_mini_fig_color <- data_mini_fig |>
  group_by(brick_link_color) |>
  summarize(
    count = n(), avg_price = round(mean(price_usd), 2),
    median_price = median(price_usd)
  )

# minifig count
data_mini_fig_count <- data_mini_fig_color |>
  filter(count > 1)

# barchart median price by color
p1 <- ggplot(data_mini_fig_color, aes(x = reorder(brick_link_color, median_price), y = median_price)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Median Price of Heads by Color",
    x = "Color", y = "Median Price (usd)",
    fill = "Color"
  )
# scale_fill_wbi()
# add_logo(p1)

p2 <- ggplot(data_mini_fig_count,
             aes(reorder(brick_link_color, count), y = count)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Head Counts by Color 2022",
    x = "Color",
    y = "Count"
  )

p2
