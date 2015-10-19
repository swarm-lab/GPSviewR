bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%; height:100%; background-color:#F1F1F1;}"),

  leaflet::leafletOutput("map", width = "80%", height = "100%"),

  absolutePanel(top = "1%", right = "1%", width = "18%",
                fileInput("gpsData", "Add tracks", multiple = TRUE, accept = c("text/csv")),
                checkboxGroupInput("tracks", "Display tracks", choices = NULL),
                actionLink("checkAll", "Check all"),
                HTML("&bull;"),
                actionLink("checkNone", "Check none")),

  absolutePanel(bottom = "5%", left = "5%", width = "70%",
                sliderInput("timeSlider", "",
                            min = lubridate::now("UTC"),
                            max = lubridate::now("UTC"),
                            value = lubridate::now("UTC"),
                            step = 1, ticks = FALSE,
                            width = "100%", animate = animationOptions(interval = 25)))
)
