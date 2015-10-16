bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%; height:100%; background-color:#F1F1F1;}"),
  leafletOutput("map", width = "80%", height = "100%"),
  absolutePanel(top = "1%", right = "1%", width = "18%", draggable = TRUE,

                fileInput("gpsData", "Add tracks", multiple = TRUE, accept = c("text/csv")),

                uiOutput("loadedFiles")
  )
)
