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
    values = c("#f43b93", "#8cc63f", "#f77f08", "#46bdc6", "#34a853", "#b77e22", "#b97295", "#9966fc")
  )
}

scale_y_continuous_wbi <- function(...){
  scale_colour_gradient(
    ...,
    low = "#f43b93",
    high = "#8cc63f",
  )
}

# function to add logo and socials to plot
add_logo <- function(plot) {
  logo <- magick::image_read("../wbi_pics/logo.png")
  socials <- magick::image_read("../wbi_pics/socials.png")
  cowplot::ggdraw() +
    cowplot::draw_plot(plot, x = 0, y = 0.15, width = 1, height = 0.85) +
    cowplot::draw_image(logo, x = 0.85, y = 0, width = 0.15, height = 0.15) +
    cowplot::draw_image(socials, x = 0, y = 0, width = 0.15, height = 0.15)
}

# create named vector assigning skin tone colors to hex code colors
skin_colors <- c("Dark Brown", "Dark Orange", "Dark Tan", "Light Nougat", "Medium Nougat", "Nougat",
            "Reddish Brown", "Tan", "Yellow", "Medium Brown", "Medium Tan", "Sienna")
hexcodes <- c("#300000", "#ad5300", "#8d744e", "#faccae", "#dd9f55", "#f8ae79", "#843419", "#dbc69a", "#f3d000", "#a16c42", "#d9c594",  "#915C3C" )

skin_tones <- setNames(hexcodes, skin_colors)

# function to create custom color/fill palette for skin tones
scale_fill_skintones <- function(...) {
  ggplot2::scale_fill_manual(
    ...,
    values = skin_tones
  )
}

# function to create custom color palette for skin tones
scale_color_skintones <- function(...) {
  ggplot2::scale_color_manual(
    ...,
    values = skin_tones
  )
}
