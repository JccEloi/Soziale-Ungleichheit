### cleandata.R ###
### Data cleaning and common variables ###

## Filter before-tax Gini 2000-2023
gini_before_2000_2023 <- gini_coefficient_beforetax %>%
  filter(!is.na(Gini.coefficient..before.tax...World.Inequality.Database.)) %>%
  filter(Year >= 2000 & Year <= 2023) %>%
  rename(Gini_beforetax = Gini.coefficient..before.tax...World.Inequality.Database.)

## Filter after-tax Gini 2000-2023
gini_after_2000_2023 <- gini_coefficient_aftertax %>%
  filter(!is.na(Gini.coefficient..World.Bank.PIP.)) %>%
  filter(Year >= 2000 & Year <= 2023) %>%
  rename(Gini_aftertax = Gini.coefficient..World.Bank.PIP.)

## Target countries
target_countries <- c(
  "Denmark", "Germany", "Poland",
  "Singapore", "South Korea", "Indonesia",
  "Algeria", "Egypt", "South Africa",
  "United States", "Canada",
  "Argentina", "Colombia", "Peru",
  "New Zealand", "Australia"
)

## Countries grouped by continent
continent_map <- list(
  "Europe (WID)" = c(
    "Albania","Andorra","Austria","Belarus","Belgium",
    "Bosnia and Herzegovina","Bulgaria","Croatia","Cyprus","Czechia",
    "Denmark","Estonia","Finland","France","Georgia","Germany","Greece",
    "Hungary","Iceland","Ireland","Italy","Kosovo","Latvia",
    "Liechtenstein","Lithuania","Luxembourg","Malta","Moldova","Monaco",
    "Montenegro","Netherlands","North Macedonia","Norway","Poland",
    "Portugal","Romania","Russia","San Marino","Serbia","Slovakia",
    "Slovenia","Spain","Sweden","Switzerland","Turkey","Ukraine",
    "United Kingdom","Vatican City"
  ),
  "Asia (WID)" = c(
    "Afghanistan","Armenia","Azerbaijan","Bahrain","Bangladesh","Bhutan",
    "Brunei","Cambodia","China","Hong Kong","Macau","Taiwan","India",
    "Indonesia","Iran","Iraq","Israel","Japan","Jordan","Kazakhstan",
    "Kuwait","Kyrgyzstan","Laos","Lebanon","Malaysia","Maldives","Mongolia",
    "Myanmar","Nepal","North Korea","Oman","Pakistan","Palestine",
    "Philippines","Qatar","Saudi Arabia","Singapore","South Korea",
    "Sri Lanka","Syria","Tajikistan","Thailand","Timor-Leste","Turkmenistan",
    "United Arab Emirates","Uzbekistan","Vietnam","Yemen"
  ),
  "Africa (WID)" = c(
    "Algeria","Angola","Benin","Botswana","Burkina Faso","Burundi",
    "Cabo Verde","Cameroon","Central African Republic","Chad","Comoros",
    "Congo","Democratic Republic of the Congo","Djibouti","Egypt",
    "Equatorial Guinea","Eritrea","Eswatini","Ethiopia","Gabon","Gambia",
    "Ghana","Guinea","Guinea-Bissau","Ivory Coast","Kenya","Lesotho",
    "Liberia","Libya","Madagascar","Malawi","Mali","Mauritania","Mauritius",
    "Morocco","Mozambique","Namibia","Niger","Nigeria","Rwanda",
    "Sao Tome and Principe","Senegal","Seychelles","Sierra Leone",
    "Somalia","South Africa","South Sudan","Sudan","Tanzania","Togo",
    "Tunisia","Uganda","Zambia","Zimbabwe"
  ),
  "North America (WID)" = c(
    "United States","Canada","Mexico","Greenland","Bermuda"
  ),
  "Latin America (WID)" = c(
    "Argentina","Belize","Bolivia","Brazil","Chile","Colombia","Costa Rica",
    "Cuba","Dominican Republic","Ecuador","El Salvador","Guatemala","Guyana",
    "Haiti","Honduras","Jamaica","Nicaragua","Panama","Paraguay","Peru",
    "Suriname","Trinidad and Tobago","Uruguay","Venezuela"
  ),
  "Oceania (WID)" = c(
    "Australia","New Zealand","Fiji","Kiribati","Marshall Islands",
    "Micronesia","Nauru","Palau","Papua New Guinea","Samoa",
    "Solomon Islands","Tonga","Tuvalu","Vanuatu"
  )
)

## Convert list to data frame
country_region_df <- stack(continent_map) %>%
  rename(Country = values, Region = ind)

## Target countries before-tax Gini with Region
gini_before_selected <- gini_before_2000_2023 %>%
  mutate(Year = as.integer(Year)) %>%
  filter(Country %in% target_countries) %>%
  left_join(country_region_df, by = "Country")

## Region colors
region_colors <- c(
  "World" = "#000000",
  "Europe (WID)" = "#BB5500",
  "Asia (WID)" = "#74ADD1",
  "Africa (WID)" = "#66A61E",
  "North America (WID)" = "#7570B3",
  "Latin America (WID)" = "#E7298A",
  "Oceania (WID)" = "#35978F"
)

## Function to generate country colors
generate_country_colors <- function(region, countries,
                                    l_range = c(40, 85),
                                    c_range = c(80, 30),
                                    power = 1.2,
                                    reverse = FALSE) {
  base_color <- region_colors[region]
  n <- length(countries)
  if (n == 0) return(character(0))
  if (n == 1) { names(base_color) <- countries; return(base_color) }
  rgb_vals <- col2rgb(base_color) / 255
  hsv_vals <- rgb2hsv(rgb_vals[1], rgb_vals[2], rgb_vals[3])
  h <- hsv_vals["h", ] * 360
  cols <- colorspace::sequential_hcl(
    n, h = h,
    c = c(c_range[1], c_range[2]),
    l = c(l_range[1], l_range[2]),
    power = power
  )
  if (reverse) cols <- rev(cols)
  names(cols) <- countries
  cols
}

## Generate country colors
country_colors <- unlist(lapply(names(continent_map), function(region) {
  generate_country_colors(region, continent_map[[region]])
}))

## Continent names
continents <- names(continent_map)

## Country-level Gini data
gini_country_before <- gini_before_2000_2023 %>%
  filter(!Country %in% c("World", continents)) %>%
  inner_join(country_region_df, by = "Country") %>%
  filter(!is.na(Gini_beforetax))

## Simple average by continent
region_before_weighted <- gini_country_before %>%
  group_by(Year, Country = Region) %>%
  summarise(Gini_beforetax = mean(Gini_beforetax, na.rm = TRUE), .groups = "drop")

## World simple average
world_before_weighted <- gini_country_before %>%
  group_by(Year) %>%
  summarise(Country = "World", Gini_beforetax = mean(Gini_beforetax, na.rm = TRUE), .groups = "drop")

## Combine for plotting
region_before_2000_2023_w <- bind_rows(region_before_weighted, world_before_weighted) %>%
  mutate(Country = factor(Country, levels = c(continents, "World")))
