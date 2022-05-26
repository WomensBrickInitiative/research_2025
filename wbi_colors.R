# functions to create custom color palettes with WBI colors
scale_color_wbi <- function(...) {
  ggplot2::scale_color_manual(
    ...,
    values = c("#f43b93", "#8cc63f", "#f77f08", "#999999")
  )
}

scale_fill_wbi <- function(...) {
  ggplot2::scale_fill_manual(
    ...,
    values = c("#f43b93", "#8cc63f", "#f77f08", "#999999")
  )
}

scale_y_continuous_wbi <- function(...){
  scale_colour_gradient(
    ...,
    low = "#f43b93",
    high = "#8cc63f",
  )
}

## test examples
ggplot(
  starwars,
  aes(x = height, y = mass, color = sex)) +
  geom_point() +
  scale_color_wbi()

starwars2 <- starwars %>%
  filter(species %in% c("Human", "Droid", "Gungan", "Kaminoan")) %>%
  group_by(species) %>%
  summarise(count = n())
ggplot(
  starwars2,
  aes(x = reorder(species, desc(count)), y = count, fill = species)) +
  geom_col() +
  scale_fill_wbi()

ggplot(starwars, aes(x = mass, y = height, color = birth_year )) +
  geom_point() +
  scale_y_continuous_wbi()
