library(shiny)
library(leaflet)
library(data.table)
library(dplyr)
library(lubridate)
library(RColorBrewer)

dat <- NULL
# cbf <- RColorBrewer::brewer.pal(8, "Accent")
cbf <- c("#A08327", "#B865E9", "#4688A6", "#D43B6B", "#3B9465", "#83547F",
  "#DD4031", "#58A735", "#607BC2", "#C3692C", "#CB3B95", "#B77FCC", "#5C7A2A",
  "#B6514E", "#6B6CDC", "#CF6C99", "#8F47A4", "#DC49D5")
currentTime <- NULL
proxy <- NULL
