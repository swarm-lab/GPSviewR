shinyUI(
  bootstrapPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),

    leaflet::leafletOutput("map", width = "80%", height = "100%"),

    absolutePanel(top = "1%", right = "1%", width = "18%",
                  fileInput("gpsData", "Add tracks", multiple = TRUE, accept = c("text/csv")),
                  tags$hr(),
                  checkboxGroupInput("tracks", "Display tracks", choices = NULL),
                  actionLink("checkAll", "Show all"),
                  HTML("&bull;"),
                  actionLink("checkNone", "Show none"),
                  tags$hr(),
                  sliderInput("tailLength", "Tail length", min = 1, max = 120,
                              value = 60, step = 1, ticks = FALSE, width = "100%")),

    absolutePanel(bottom = "5%", left = "5%", width = "70%",
                  sliderInput("timeSlider", "",
                              min = lubridate::now("UTC"),
                              max = lubridate::now("UTC"),
                              value = lubridate::now("UTC"),
                              step = 1, ticks = FALSE,
                              width = "100%",
                              animate = animationOptions(interval = 50)))
  )
)
