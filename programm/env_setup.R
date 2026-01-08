### env_setup.R ###
### Load packages and read data ###

##
options(repos = c(CRAN = "https://cloud.r-project.org"))

## Required packages
packages <- c(
  "tidyverse",
  "tidyr",
  "dplyr",
  "colorspace",
  "stringr",
  "ggrepel",
  "lubridate",
  "ggplot2",
  "plotly",
  "purrr",
  "knitr",
  "magrittr",
  "readr",
  "patchwork",
  "RColorBrewer",
  "cowplot"
)

## Load packages (auto install if missing)
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

## Read all CSV files from Data folder
folder_path <- "Data/"
csv_files <- list.files(
  path = folder_path,
  pattern = "\\.csv$",
  full.names = TRUE,
  ignore.case = TRUE
)
for (file in csv_files) {
  var_name <- basename(file)
  var_name <- gsub("\\.csv$", "", var_name)
  var_name <- gsub("-", "_", var_name)
  data <- read.csv(file)
  assign(var_name, data)
}
