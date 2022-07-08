library(tidyverse)
cultural_data <- read_csv(here::here("data", "cultural_minifigs.csv"))
source(here::here("wbi_colors.R"))

ninjago <- cultural_data |>
  filter(inspiration=="Ninjago"|inspiration=="The LEGO Ninjago Movie")
