### Happiness.R ###
### Gini vs Happiness Analysis ###

## Year to use
year_use <- 2021

## Gini data
gini_sub <- gini_coefficient_aftertax %>%
  filter(Year == year_use) %>%
  select(Country, Year, Gini = Gini.coefficient..World.Bank.PIP.)

## Happiness data
happy_sub <- happy_raw %>%
  filter(Year == year_use) %>%
  select(Country = Entity, Year, Happiness = Cantril.ladder.score)

## Merge data
df <- inner_join(gini_sub, happy_sub, by = c("Country", "Year")) %>%
  filter(Country != "World")

## Add Region
continent_df <- stack(continent_map)
colnames(continent_df) <- c("Country", "Region")

df <- df %>%
  left_join(continent_df, by = "Country") %>%
  filter(!is.na(Region))

df$Region <- factor(
  df$Region,
  levels = c("Europe (WID)", "Asia (WID)", "Africa (WID)",
             "North America (WID)", "Latin America (WID)", "Oceania (WID)")
)

## Calculate Pearson r
r_val <- cor(df$Gini, df$Happiness, use = "complete.obs", method = "pearson")
label_txt <- paste0("Pearson r = ", round(r_val, 3))

x_pos <- max(df$Gini, na.rm = TRUE)
y_pos <- max(df$Happiness, na.rm = TRUE)

## Plot
p_happiness <- ggplot(df, aes(x = Gini, y = Happiness)) +
  geom_point(aes(color = Region), size = 2.8, shape = 16, alpha = 1) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 0.7) +
  annotate("text", x = x_pos, y = y_pos, label = label_txt,
           hjust = 1.05, vjust = 1.2, size = 4.5, fontface = "bold") +
  scale_color_manual(
    values = region_colors,
    breaks = c("Europe (WID)", "Asia (WID)", "Africa (WID)",
               "North America (WID)", "Latin America (WID)", "Oceania (WID)"),
    labels = c("Europe", "Asia", "Africa", "North America", "Latin America", "Oceania"),
    name = "Region"
  ) +
  labs(
    title = paste0("After-tax Gini vs Happiness (", year_use, ")"),
    x = "Gini Coefficient (After-tax)",
    y = "Happiness (0-10 score)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5), aspect.ratio = 0.5)

p_happiness
