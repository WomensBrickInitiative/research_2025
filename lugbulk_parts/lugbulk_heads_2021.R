library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R")) # file containing functions to customize colors

data_2021 <- read_csv(here::here("data", "lugbulk_parts2021.csv")) |>
  janitor::clean_names() |>
  mutate(price_usd = as.numeric(substr(usd, 2, 5))) |>
  select(item_id, bl_part_id, lego_color, item_description, price_usd) |>
  mutate(brick_link_url = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", bl_part_id))

data_2021_head <- data_2021 |>
  filter(str_detect(item_description, "MINI HEAD"))

get_description <- function(url) {
  page <- read_html(url)
  description <- page |>
    html_elements("#item-name-title") |>
    html_text()
  description
}

descriptions <- map(data_2021_head$brick_link_url, get_description)
descriptions <- descriptions |>
  as.character() %>%
  ifelse(. == "character(0)", "NA", .)

data_2021_head <- data_2021_head |>
  mutate(description = descriptions) |>
  filter(description != "NA")

data_2021_head <- data_2021_head |>
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
           str_detect(tolower(description), "alien") |
           str_detect(tolower(description), "clock") |
           str_detect(tolower(description), "headphones"),
         type = case_when(
           is_female ~ "female",
           is_male ~ "male",
           is_child ~ "child",
           is_plain ~ "no face",
           is_nonhuman ~ "non human",
           !(is_female | is_male | is_child | is_plain | is_nonhuman) ~ "neutral"
         )
  )

data_type <- data_2021_head |>
  group_by(type) |>
  summarize(count = n())

data_type_human <- data_2021_head |>
  group_by(type) |>
  summarize(count = n()) |>
  filter(type != "non human") |>
  filter(type != "no face") |>
  mutate(total_count=sum(count),prop=round(count/total_count,2))

data_neutral <- data_2021_head |>
  filter(type == "neutral")


p_type <- ggplot(data_type, aes(x = reorder(type, count), y = count)) +
  geom_col() +
  coord_flip()
p_type

p_type_human <- ggplot(data_type_human, aes(x = reorder(type, count), y = count, fill = type)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_wbi() +
  labs(title = "Head Count by Category 2021 (Humans with Faces Only)",
       x = "Category",
       y = "Count",
       fill = "Category") +
  geom_text(aes(label = count), hjust = -0.4)
#add_logo(p_type_human)
p_type_human

p_type_human_prop <- ggplot(data_type_human, aes(x = reorder(type, prop), y = prop, fill = type)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_wbi() +
  labs(title = "Head props by Category 2021 (Humans with Faces Only)",
       x = "Category",
       y = "Proportion",
       fill = "Category") +
  geom_text(aes(label = prop), hjust = 1)
#add_logo(p_type_human)
p_type_human_prop


# minifigs by color only
data_mini_fig_color <- data_2021_head |>
  group_by(lego_color) |>
  summarize(
    count = n(), avg_price = round(mean(price_usd), 2),
    median_price = median(price_usd)
  )

# minifig count
data_mini_fig_count <- data_mini_fig_color |>
  mutate(bl_color = case_when(
    lego_color=="BR.YEL" ~ "Yellow",
    lego_color=="WHITE" ~ "White",
    lego_color=="M. NOUGAT" ~ "Medium Nougat",
    lego_color=="BR.YEL" ~ "Yellow",
    lego_color=="RED. BROWN" ~ "Reddish Brown"
  )) |>
  filter(!is.na(bl_color))

p2 <- ggplot(data_mini_fig_count,
             aes(reorder(bl_color, count), y = count, fill = bl_color)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  scale_fill_skintones() +
  geom_text(aes(label = count), hjust = -0.3) +
  labs(
    title = "Head Counts by Color 2021",
    x = "Color",
    y = "Count"
  )

# add_logo(p2)
p2

