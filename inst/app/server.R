function(input, output, session) {

  ### Data logic ###
  dataReact <- reactiveValues(files = 0)

  observe({
    if (!is.null(input$gpsData)) {
      proxy <- leafletProxy("map")

      loadedFiles <- unique(dat$name)
      files <- input$gpsData %>%
        dplyr::filter(!(name %in% loadedFiles)) %>%
        dplyr::filter(type == "text/csv")

      if (nrow(files) > 0) {
        for (i in 1:nrow(files)) {
          tmp <- read.csv(files[i, ]$datapath, stringsAsFactors = FALSE)
          if (all.equal(names(tmp), c("Date", "Time", "Longitude", "Latitude"))) {
            tmp <- dplyr::mutate(tmp, name = files[i, ]$name) %>%
              mutate(DateTime = lubridate::dmy_hms(paste(Date, Time)))
            dat <<- rbind(dat, tmp)
            col <- 8 - length(unique(dat$name)) %% 8
            proxy %>% addPolylines(lng = tmp$Longitude, lat = tmp$Latitude,
                                   weight = 2, group = tmp$name[1],
                                   color = cbf[col], opacity = 1)
          }
        }
        isolate({dataReact$files <- dataReact$files + 1})
      }
    }
  })

  output$loadedFiles <- renderUI({
    if (dataReact$files == 0)
      return()

    boxes <- unique(dat$name)
    checkboxGroupInput("tracks", "Choose tracks",
                       choices = boxes, selected = boxes)
  })
  ### ###

  ### Map logic ###
  # Base map centered on Namibia
  output$map <- renderLeaflet({
    leaflet() %>% addProviderTiles("Esri.WorldImagery") %>%
      fitBounds(15.707703, -22.454663, 15.820656, -22.352775)
  })

  # Show loaded GPS tracks
  observe({
    proxy <- leafletProxy("map")
    tracks <- unique(dat$name)
    show <- tracks[tracks %in% input$tracks]
    hide <- tracks[!(tracks %in% input$tracks)]

    if (length(hide) > 0) {
      for (i in 1:length(hide)) {
        proxy %>% hideGroup(hide[i])
      }
    }

    if (length(show) > 0) {
      for (i in 1:length(show)) {
        proxy %>% showGroup(show[i])
      }
    }
  })

  ### ###

}