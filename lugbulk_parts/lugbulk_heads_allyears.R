library(tidyverse)
library(rvest)
source(here::here("wbi_colors.R")) # file containing functions to customize colors

# read in parts data all years
data_2022 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2022.csv"))
data_2021 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2021.csv"))
data_2020 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2020.csv"))
data_2019 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2019.csv"))
data_2018 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2018.csv"))
data_2017 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2017.csv"))
data_2016 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2016.csv"))
data_2015 <- read.csv(here::here("data", "lugbulk_data", "lugbulk_2015.csv"))

# function to scrape descriptions
get_description <- function(url) {
  page <- read_html(url)
  description <- page |>
    html_elements("#item-name-title") |>
    html_text()
  description
}

# vectorized function to scrape descriptions
get_descriptions <- function(urls) {
  descriptions <- map(urls, get_description)
  descriptions <- descriptions |>
    as.character() %>%
    ifelse(. == "character(0)", "NA", .)
  descriptions
}

# filter data for each year to only heads within skintone colors, standardize formatting
heads_2022 <- data_2022 |>
  janitor::clean_names() |>
  filter(category == "FIGURE, HEADS AND MA" & subcategory == "MINI FIGURE HEADS") |>
  mutate(year = 2022) |>
  filter(brick_link_color %in% skin_colors) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2021 <- data_2021 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(year = 2021) |>
  mutate(brick_link_color = case_when(
    lego_color == "BR.YEL" ~ "Yellow",
    lego_color == "WHITE" ~ "White",
    lego_color == "M. NOUGAT" ~ "Medium Nougat",
    lego_color == "RED. BROWN" ~ "Reddish Brown"
  )) |>
  filter(!is.na(brick_link_color)) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2020 <- data_2020 |>
  janitor::clean_names() |>
  filter(str_detect(description, "MINI HEAD")) |>
  mutate(year = 2020) |>
  mutate(brick_link_color = case_when(
    colour_id == "BR.YEL" ~ "Yellow",
    colour_id == "WHITE" ~ "White",
    colour_id == "M. NOUGAT" ~ "Medium Nougat",
    colour_id == "RED. BROWN" ~ "Reddish Brown"
  )) |>
  rename(item_description = description, bl_part_id = bl_part) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2019 <- data_2019 |>
  janitor::clean_names() |>
  filter(str_detect(element_name, "MINI HEAD")) |>
  mutate(year = 2019) |>
  rename(item_id = element_id, item_description = element_name) |>
  mutate(bl_part_id = NA, usd = NA, brick_link_color = str_to_title(color_tlg)) |>
  mutate(brick_link_color = ifelse(brick_link_color == "Bright Yellow", "Yellow", brick_link_color)) |>
  filter(brick_link_color %in% skin_colors) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2018 <- data_2018 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(year = 2018) |>
  rename(brick_link_color = color_name_1, bl_part_id = design_id) |>
  mutate(brick_link_color = ifelse(brick_link_color == "Light Flesh", "Light Nougat", brick_link_color)) |>
  filter(brick_link_color %in% skin_colors) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2017 <- data_2017 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(bl_color = ifelse(bl_color == "Light Flesh", "Light Nougat", bl_color)) |>
  rename(item_id = element_id, bl_part_id = bl_id, brick_link_color = bl_color) |>
  mutate(year = 2017) |>
  filter(brick_link_color %in% skin_colors) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2016 <- data_2016 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(brick_link_color = case_when(
    color == 1L ~ "White",
    color == 24L ~ "Yellow",
    color == 192L ~ "Reddish Brown",
    color == 312L ~ "Medium Nougat",
    color == 18L ~ "Nougat",
    color == 283L ~ "Light Nougat",
    color == 138L ~ "Dark Tan",
    color == 38L ~ "Dark Orange",
    color == 308L ~ "Dark Brown",
    color == 5L ~ "Tan"
  )) |>
  filter(!is.na(brick_link_color)) |>
  mutate(year = 2016, usd = NA) |>
  rename(bl_part_id = design_id) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

heads_2015 <- data_2015 |>
  janitor::clean_names() |>
  filter(str_detect(item_description, "MINI HEAD")) |>
  mutate(brick_link_color = case_when(
    color == 1L ~ "White",
    color == 24L ~ "Yellow",
    color == 192L ~ "Reddish Brown",
    color == 312L ~ "Medium Nougat",
    color == 18L ~ "Nougat",
    color == 283L ~ "Light Nougat",
    color == 138L ~ "Dark Tan",
    color == 38L ~ "Dark Orange",
    color == 308L ~ "Dark Brown",
    color == 5L ~ "Tan"
  )) |>
  filter(!is.na(brick_link_color)) |>
  mutate(year = 2015, usd = NA) |>
  rename(bl_part_id = design_id) |>
  select(item_id, item_description, bl_part_id, brick_link_color, usd, year)

# combine heads data from all years into one dataframe
data_all <- list(heads_2015, heads_2016, heads_2017, heads_2018, heads_2019, heads_2020, heads_2021, heads_2022) |>
  plyr::ldply(rbind)

# scrape descriptions for all heads
heads_all <- data_all |>
  mutate(price_usd = as.numeric(substr(usd, 2, 5))) |>
  mutate(brick_link_url = paste0("https://www.bricklink.com/v2/catalog/catalogitem.page?P=", bl_part_id)) |>
  mutate(description = map_chr(brick_link_url, get_descriptions))


write_csv(heads_all, "heads_all.csv")

heads_all <- read_csv(here::here("data", "lugbulk_data", "heads_all.csv"))

### Color Analysis

# create column indicating yellow vs flesh tone
heads_color <- heads_all |>
  filter(brick_link_color != "White") |>
  mutate(yellow_vs_flesh = ifelse(brick_link_color == "Yellow", "Yellow", "Flesh"))

# calculate counts and proportions for each color by year
color_counts <- heads_color |>
  group_by(year, brick_link_color) |>
  summarize(count = n()) |>
  group_by(year) |>
  mutate(total = sum(count), prop = round(count / total, 2))

#### plots
# faceted barchart-- color props by year
p1 <- ggplot(color_counts, aes(x = reorder(brick_link_color, prop), y = prop, fill = brick_link_color)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~year) +
  coord_flip() +
  scale_fill_skintones() +
  labs(
    title = "Head Color Proportions by Year",
    x = "Color",
    y = "Proportion"
  )
# add_logo(p1)
p1
# filter out yellow heads
color_counts_flesh <- color_counts |>
  filter(brick_link_color != "Yellow")

# faceted barchart-- color props by year for only flesh tones
p2 <- ggplot(color_counts_flesh, aes(x = reorder(brick_link_color, prop), y = prop, fill = brick_link_color)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~year) +
  coord_flip() +
  scale_fill_skintones() +
  labs(
    title = "Head Color Proportions by Year (flesh tones only)",
    x = "Color",
    y = "Proportion"
  )
add_logo(p2)

# faceted barchart-- color counts by year for only flesh tones
p3 <- ggplot(color_counts_flesh, aes(x = reorder(brick_link_color, count), y = count, fill = brick_link_color)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~year) +
  coord_flip() +
  scale_fill_skintones() +
  labs(
    title = "Head Color Counts by Year (flesh tones only)",
    x = "Color",
    y = "Count"
  )
add_logo(p3)

# caculate counts and props for yellow vs flesh tones by year
color_counts_yvf <- heads_color |>
  group_by(year, yellow_vs_flesh) |>
  summarize(count = n()) |>
  group_by(year) |>
  mutate(total = sum(count), prop = round(count / total, 2))

# line plot yellow vs flesh tone head props over time
p4 <- ggplot(color_counts_yvf, aes(x = year, y = prop)) +
  geom_line(aes(color = yellow_vs_flesh)) +
  geom_point(aes(color = yellow_vs_flesh)) +
  scale_color_manual(values = c("#f8ae79", "#f3d000")) +
  labs(
    title = "Proportion of Yellow Vs. Flesh Heads Over Time",
    x = "Year",
    y = "Proportion",
    color = ""
  )
add_logo(p4)
plotly::ggplotly(p4)

# line plot yellow vs flesh tone head counts over time
p5 <- ggplot(color_counts_yvf, aes(x = year, y = count)) +
  geom_line(aes(color = yellow_vs_flesh)) +
  geom_point(aes(color = yellow_vs_flesh)) +
  scale_color_manual(values = c("#f8ae79", "#f3d000")) +
  labs(
    title = "Counts of Yellow Vs. Flesh Heads Over Time",
    x = "Year",
    y = "Count",
    color = ""
  )
add_logo(p5)
plotly::ggplotly(p5)

## Reformat to facet by color instead of year
# proportions
p1a <- ggplot(color_counts, aes(x = year, y = prop, fill = brick_link_color)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~brick_link_color) +
  scale_fill_skintones() +
  labs(
    title = "Head Color Proportions Over Time",
    x = "Year",
    y = "Proportion"
  )
p1a <- add_logo(p1a)


# proportions without yellow
p2a <- ggplot(color_counts_flesh, aes(x = year, y = prop, fill = brick_link_color)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~brick_link_color) +
  # coord_flip() +
  scale_fill_skintones() +
  labs(
    title = "Head Color Proportions Over Time (flesh tones only)",
    x = "Year",
    y = "Proportion"
  )
p2a <- add_logo(p2a)


# faceted barchart-- color counts by year for only flesh tones
p3a <- ggplot(color_counts_flesh, aes(x = year, y = count, fill = brick_link_color)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~brick_link_color) +
  # coord_flip() +
  scale_fill_skintones() +
  labs(
    title = "Head Color Counts Over Time (flesh tones only)",
    x = "Color",
    y = "Count"
  )
p3a <- add_logo(p3a)

###### Gender Analysis

male_keywords <- c("beard", "goatee", "sideburns", "moustache", "stubble", " male")
nonhuman_keywords <- c("pineapple", "cobra", "skull", "ghost", "alien", "clock", "headphones", "globe")

### Fill in missing values for descriptions
## for all item_ids, make sure same description filled in for all years
heads_all <- heads_all |>
  mutate(na_description = ifelse(is.na(description), TRUE, FALSE)) |>
  mutate(description2 = ifelse(na_description, "NA", description)) |>
  group_by(item_id) |>
  mutate(description = min(description2)) |>
  filter(brick_link_color != "White") |>
  mutate(
    is_female = str_detect(tolower(description), "female"),
    is_male = str_detect(tolower(description), paste(male_keywords, collapse = "|")),
    is_child = str_detect(tolower(description), "child"),
    is_dual_sided = str_detect(tolower(description), "dual sided"),
    is_plain = str_detect(tolower(description), "plain"),
    is_nonhuman = str_detect(tolower(description), paste(nonhuman_keywords, collapse = "|")),
    type = case_when(
      is_female ~ "female",
      is_male ~ "male",
      is_child ~ "child",
      is_plain ~ "no face",
      is_nonhuman ~ "non human",
      TRUE ~ "neutral"
    )
  )

# filter to only humans, generate bricklink search links
heads_human <- heads_all |>
  filter(type != "non human", type != "no face") |>
  mutate(search_link = paste0("https://www.bricklink.com/v2/search.page?q=", item_id, "#T=A"))

# separate data into missing descriptions and non-missing descriptions
na_d <- heads_human |>
  filter(description == "NA")
d <- heads_human |>
  filter(description != "NA")

# save subset of data with missing descriptions-- imported this into google sheets to manually fill in
# write_csv(na_d, file = "na_heads.csv")

# read in subset of data previously missing descriptions with manually filled in descriptions
na_completed <- read_csv(here::here("data", "lugbulk_data", "na_heads_completed.csv")) |>
  rename(description = `...9`) |>
  mutate(bl_part_id = as.character(bl_part_id)) |>
  select(-description3)

# combine subset of data with descriptions with subset with newly filled in descriptions
# recompute type categories and filter to only human with all descriptions present
heads_completed <- bind_rows(d, na_completed) |>
  filter(!is.na(description)) |>
  mutate(
    is_female = str_detect(tolower(description), "female"),
    is_male = str_detect(tolower(description), paste(male_keywords, collapse = "|")),
    is_child = str_detect(tolower(description), "child"),
    is_dual_sided = str_detect(tolower(description), "dual sided"),
    is_plain = str_detect(tolower(description), "plain"),
    is_nonhuman = str_detect(tolower(description), paste(nonhuman_keywords, collapse = "|")),
    type = case_when(
      is_female ~ "female",
      is_male ~ "male",
      is_child ~ "child",
      is_plain ~ "no face",
      is_nonhuman ~ "non human",
      TRUE ~ "neutral"
    )
  ) |>
  filter(type != "non human", type != "no face") |>
  select(-description2)

# save new completed heads data
write_csv(heads_completed, "heads_completed.csv")

# compute counts and props for each type category by year
gender_counts <- heads_completed |>
  group_by(year, type) |>
  summarize(count = n()) |>
  group_by(year) |>
  mutate(total = sum(count), prop = round(count / total, 2))

# line graph proportions of each category over time
p6 <- ggplot(gender_counts, aes(x = year, y = prop)) +
  geom_line(aes(color = type)) +
  geom_point(aes(color = type)) +
  labs(
    title = "Proportion of Category of Heads Over Time",
    x = "Year",
    y = "Proportion",
    color = ""
  ) +
  scale_color_wbi()
add_logo(p6)
plotly::ggplotly(p6)

heads <- read_csv(here::here("data", "lugbulk_data", "heads_completed.csv"))

# look at overlap from year to year
heads_summarized <- heads |>
  group_by(item_id) |>
  summarize(count = n()) |>
  group_by(count) |>
  summarize(count = n())
