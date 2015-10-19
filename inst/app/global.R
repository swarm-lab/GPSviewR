library(shiny)
library(leaflet)
library(dplyr)
library(lubridate)
library(RColorBrewer)

dat <- NULL
cbf <- RColorBrewer::brewer.pal(8, "Accent")
currentTime <- NULL
proxy <- NULL
