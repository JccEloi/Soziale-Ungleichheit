### cc_trend_facet_time.R ###
### Country Gini Facet Plot ###

## Selected countries by continent for legend
continent_map_selected <- list(
  "Europe (WID)" = c("Denmark", "Germany", "Poland"),
  "Asia (WID)" = c("Singapore", "South Korea", "Indonesia", "China"),
  "Africa (WID)" = c("Algeria", "Egypt", "South Africa"),
  "North America (WID)" = c("United States", "Canada"),
  "Latin America (WID)" = c("Argentina", "Colombia", "Peru"),
  "Oceania (WID)" = c("New Zealand", "Australia")
)

## Add linetype info
gini_before_selected <- gini_before_selected %>%
  mutate(linetype = case_when(
    Country == "Germany" ~ "dashed",
    Country == "South Korea" ~ "dashed",
    Country == "Indonesia" ~ "dashed",
    Country == "Egypt" ~ "dashed",
    Country == "United States" ~ "dashed",
    Country == "Colombia" ~ "dashed",
    Country == "New Zealand" ~ "dashed",
    TRUE ~ "solid"
  ))

## Main plot
p_main <- ggplot(gini_before_selected, aes(x = Year, y = Gini_beforetax, color = Country, linetype = linetype)) +
  geom_line(linewidth = 0.9, alpha = 0.9) +
  scale_color_manual(values = country_colors) +
  scale_linetype_manual(values = c("solid" = "solid", "dashed" = "dashed")) +
  facet_wrap(~ Region, ncol = 3, scales = "fixed") +
  labs(title = "Before-tax Gini coefficients by country and region (2000-2023)",
       x = "Year",
       y = "Gini Coefficient (Before Tax)",
       color = "Country",
       linetype = "Country") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5, face = "plain"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12),
        strip.text = element_text(hjust = 0.5),
        legend.position = "none")

## Function to create legend for each continent
make_legend <- function(countries, data = gini_before_selected) {
  df_leg <- data %>%
    filter(Country %in% countries) %>%
    distinct(Country, linetype)
  
  color_values <- country_colors[df_leg$Country]
  names(color_values) <- df_leg$Country
  
  linetype_values <- df_leg$linetype
  linetype_values <- ifelse(linetype_values == "dashed", "12", "solid")
  names(linetype_values) <- df_leg$Country
  
  df_plot <- data.frame(
    x = rep(c(1, 2), nrow(df_leg)),
    y = rep(1, 2 * nrow(df_leg)),
    Country = rep(df_leg$Country, each = 2)
  )
  
  p_legend <- ggplot(df_plot, aes(x, y, colour = Country, linetype = Country)) +
    geom_line(linewidth = 1.2) +
    scale_color_manual(values = color_values) +
    scale_linetype_manual(values = linetype_values) +
    guides(
      colour = guide_legend(nrow = 1, byrow = TRUE),
      linetype = guide_legend(nrow = 1, byrow = TRUE)
    ) +
    theme_void() +
    theme(
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(size = 10),
      legend.key.size = unit(1, "lines"),
      legend.spacing.y = unit(0.1, "lines")
    )
  
  cowplot::get_legend(p_legend)
}

## Create legends for each continent
leg_europe <- make_legend(continent_map_selected[["Europe (WID)"]])
leg_asia <- make_legend(continent_map_selected[["Asia (WID)"]])
leg_africa <- make_legend(continent_map_selected[["Africa (WID)"]])
leg_na <- make_legend(continent_map_selected[["North America (WID)"]])
leg_latam <- make_legend(continent_map_selected[["Latin America (WID)"]])
leg_oceania <- make_legend(continent_map_selected[["Oceania (WID)"]])

## Combine legends
legends_grid <- cowplot::plot_grid(
  leg_europe, leg_asia, leg_africa,
  leg_na, leg_latam, leg_oceania,
  ncol = 3,
  align = "hv"
)

## Final plot
p1.2 <- cowplot::plot_grid(
  p_main,
  legends_grid,
  ncol = 1,
  rel_heights = c(7.5, 2)
)

p1.2
