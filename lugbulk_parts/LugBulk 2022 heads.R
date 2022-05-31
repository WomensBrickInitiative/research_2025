---
  title: "lugbulk parts"
author: "Rose Porta, Yutong Zhang"
date: '2022-05-27'
output: html_document
---

  ```{r setup, include=FALSE}
library(tidyverse)
#source(here::here("wbi_colors.R")) # file containing functions to customize colors
```

```{r}
# read in parts data
data <- read.csv(here::here("data", "lugbulk_parts.csv"))
# filter to just heads
data_heads <- data |>
  janitor::clean_names() |>
  mutate(price_usd = as.numeric(substr(usd, 2, 5))) |>
  filter(category == "FIGURE, HEADS AND MA") |>
  select(item_id, item_description, brick_link_color, category, subcategory, price_usd, brick_set)

# subcategories (mini figs, various)
data_subcategories <- data_heads |>
  group_by(subcategory) |>
  summarize(count = n(), avg_price = round(mean(price_usd),2),
            median_price = median(price_usd))

# only mini fig data
data_mini_fig <-  data_heads %>% filter(subcategory == "MINI FIGURE HEADS")
  summarize(count = n(), avg_price = round(mean(price_usd),2),
            median_price = median(price_usd))

# minifigs by color only
data_mini_fig_color <- data_mini_fig |>
  group_by(brick_link_color) |>
  summarize(count = n(), avg_price = round(mean(price_usd),2),
            median_price = median(price_usd))

#minifig count
data_mini_fig_count <- data_mini_fig_color |>
  filter(count > 1)

#barchart median price by color
p1 <- ggplot(data_mini_fig_color, aes(x = reorder(brick_link_color, median_price), y = median_price)) +
               geom_col() + coord_flip() +
               labs(title = "Median Price of Heads by Color",
                    x = "Color", y = "Median Price (usd)",
                    fill = "Color")
  #scale_fill_wbi()
#add_logo(p1)

# scatter plot count vs. average cost by color
p2 <- ggplot(data_wigs_color, aes(x = count, y = average_cost)) +
  geom_point() +
  labs(title = "Relationship between Count and Average Cost of Wigs by Color")
add_logo(p2)

# barchart count female vs male
p3 <- ggplot(data_wigs_gender, aes(x = subcategory, y = count, fill = subcategory)) + geom_col() +
  labs(title = "Total Number of Female Versus Male Wigs", x = "Gender" , fill = "Gender")
 # scale_fill_wbi()
#add_logo(p3)

# pivot to long format to make side by side barchart median vs. mean
data_gender_long <- data_wigs_gender |>
  pivot_longer(cols = c(avg_price, median_price), names_to = "type", values_to = "value")
# barchart mean and median price female vs. male
p4 <- ggplot(data_gender_long, aes(x = subcategory, y = value, fill = type)) + geom_col(position = "dodge") +
  labs(title = "Mean and Median Price of Female Versus Male Wigs", x = "Gender", fill = "Mean/Median", y = "Value (usd)")
  #scale_fill_wbi()
#add_logo(p4)

# barchart median price by color
p5 <- ggplot(data_wigs_color, aes(x = reorder(brick_link_color, median_price), y = median_price)) + geom_col() + coord_flip() +
  labs(title = "Median Price by Color", x = "Color", y = "Median Price (usd)")
#add_logo(p5)




```

