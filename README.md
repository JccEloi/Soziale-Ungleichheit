# Soziale-Ungleichheit
**Author: ** Chengyu Wu, Tian Xu, Xinhui Liu, Yunzhen Jin

## General Instruction

This is the repository for Soziale-Ungleichheit Project.
To ensure the performance of our programs, please read this instruction before running the codes.

We use R Version 4.5.2. Some of our packages are dependent on the latest version of R.
If you are using other versions, you may encounter errors while installing them.

## Usage

The project environment is initialized automatically when rendering Pre.qmd, 
and no manual setup is required to generate the final presentation.

For running individual analysis scripts separately, please source env_setup.R beforehand.

## Directory Structure

### Root Directory

Executive Summary — Social Inequality.pdf

presentation_files/

programm/

Results/

README.md


### Programm (Working Directory)

The programm directory contains all R scripts used for data preparation, analysis,visualization, 
and presentation in the Social Inequality Project. The project environment is initialized via env_setup.R, 
which loads all required R packages and sets up shared resources.

Data cleaning and preprocessing are performed in cleandata.R, while analytical scripts such as Happiness.R, 
homi.R, and life_ex.R focus on the analysis of happiness indicators, homicide rates, and life expectancy, respectively.

Trend-based visualizations are generated using cc_trend_facet_time.R for faceted time-series plots and cw_trend.R for time-trend visualizations.

The visual appearance of the presentation is defined in customstyle.scss. 

The Quarto source file Pre.qmd integrates all analyses and generates the final presentation, which is rendered as Pre.html. 

When rendering Pre.qmd, the project environment is initialized automatically; 
however, for running individual analysis scripts separately, env_setup.R should be sourced beforehand.

#### Data

This directory contains the original data sets from the Soziale-Ungleichheit project.

The project combines publicly available macro-level datasets with data processing, 
statistical analysis, and visualization in R.

### Results

This directory contains the results (figures) of our analysis. They are all saved in svg format.
