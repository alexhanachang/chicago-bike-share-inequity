## SHINY APP THEME
library(bslib)
library(extrafont)
library(janitor)
library(RColorBrewer)
library(shiny)
library(showtext)
library(thematic)
library(tidyverse)

#### DIVVY THEME ####
divvytheme <- bslib::bs_theme(
  bg = "#FFFFFF", 
  fg = "#000000", 
  primary = "#5FB3E0", 
  secondary = "#A2A6F2", 
  base_font = font_google("Maven Pro"),
  heading_font = font_google("Maven Pro")
)

bs_theme_preview(divvytheme)

## colors for divvy theme:
# "#5FB3E0"
# "#C5D0D9"
# "#A2A6F2"

# divvy theme fonts
# family = "Maven Pro", face = "bold"


#### EQUITICITY THEME ####
equiticitytheme <- bslib::bs_theme(
  bg = "#FFFFFF", 
  fg = "#000000", 
  primary = "#7F998C", 
  secondary = "#58866F", 
  success = "#3F7B5D", 
  info = "#325B47", 
  warning = "#234938",
  danger = "#122F22"
)
bs_theme_preview(equiticitytheme)

write_rds(equiticitytheme, "app/data/equiticitytheme.RDS")

equiticitytheme_colorbrewer <- palette(c("#7F998C", "#58866F", "#3F7B5D", "#325B47", "#234938", "#122F22"))

## colors used for equiticity theme:
# "#668C7A" (sage)
# "#8C5F58" (brown)
# "#6BA033" (grass green)
# "#EDFFF6" (pale green)
# "#B4D9C7" (darker mint)
# "#7F998C" (olive)

## colors NOT used for equiticity theme: 
# "#BEE6D3" (mint)
# "#9FBFB0" (sage)
# "#4A5952" (dark olive)

## equiticity theme fonts
# family = "Arial", face = "bold"

