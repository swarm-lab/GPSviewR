function(input, output, session) {

  ### Reactive values ###
  react <- reactiveValues(newTrack = 0)
  ### ###

  ### Map logic ###
  output$map <- leaflet::renderLeaflet({
    leaflet() %>% addProviderTiles("Esri.WorldImagery") %>%
      fitBounds(15.707703, -22.454663, 15.820656, -22.352775)
  })
  ### ###

  ### Files logic ###
  observe({
    if (!is.null(input$gpsData)) {
      proxy <<- leaflet::leafletProxy("map")
      loadedFiles <- unique(dat$name)
      files <- input$gpsData %>%
        dplyr::filter(!(name %in% loadedFiles)) %>%
        dplyr::filter(type == "text/csv")

      if (nrow(files) > 0) {
        for (i in 1:nrow(files)) {
          tmp <- read.csv(files[i, ]$datapath, stringsAsFactors = FALSE)
          if (all(c("Date", "Time", "Longitude", "Latitude") %in% names(tmp))) {
            tmp$Time[tmp$Time == "0:00:00"] <- "0:00:01"
            tmp <- dplyr::mutate(tmp, name = files[i, ]$name) %>%
              dplyr::mutate(DateTime = lubridate::dmy_hms(paste(Date, Time)))
            dat <<- rbind(dat, tmp)
            col <- 8 - length(unique(dat$name)) %% 8
            proxy %>% leaflet::addPolylines(lng = tmp$Longitude, lat = tmp$Latitude,
                                            weight = 2, group = tmp$name[1],
                                            color = cbf[col], opacity = 0.5) %>%
              leaflet::hideGroup(tmp$name[1])
          }
        }
        isolate({react$newTrack <- react$newTrack + 1})
      }
    }
  })
  ### ###

  ### Tracks logic ###
  observe({
    switch(as.character(react$newTrack),
           "0" = return(),
           {
             choices <- c(unique(dat$name))
             isolate({selected <- input$tracks})
             updateCheckboxGroupInput(session, "tracks",
                                      choices = choices,
                                      selected = selected)
           }
    )
  })

  observe({
    if (!is.null(input$checkAll)) {
      updateCheckboxGroupInput(session, "tracks", selected = unique(dat$name))
    }
  })

  observe({
    if (!is.null(input$checkNone)) {
      updateCheckboxGroupInput(session, "tracks", selected = "")
    }
  })

  observe({
    tracks <- unique(dat$name)
    show <- tracks[tracks %in% input$tracks]
    hide <- tracks[!(tracks %in% input$tracks)]

    if (length(hide) > 0) {
      for (i in 1:length(hide)) {
        proxy %>% leaflet::hideGroup(hide[i])
      }
    }

    if (length(show) > 0) {
      for (i in 1:length(show)) {
        proxy %>% leaflet::showGroup(show[i])
      }
    }
  })
  ### ###

  ### Dots logic ###
  observe({
    switch(as.character(react$newTrack),
           "0" = return(),
           "1" = {
             minTime <- min(dat$DateTime)
             maxTime <- max(dat$DateTime)
             updateSliderInput(session, "timeSlider", value = minTime,
                               min = minTime, max = maxTime)
           },
           {
             minTime <- min(dat$DateTime)
             maxTime <- max(dat$DateTime)
             updateSliderInput(session, "timeSlider",
                               min = minTime, max = maxTime)
           }
    )
  })

  observe({
    react$newTrack
    if (!is.null(dat)) {
      tmp <- dplyr::filter(dat, DateTime <= input$timeSlider &
                             DateTime > input$timeSlider - 60)
      tracks <- unique(tmp$name)
      for (i in 1:length(tracks)) {
        idx <- tmp$name == tracks[i]
        col <- 8 - i %% 8
        proxy %>% leaflet::addPolylines(lng = tmp$Longitude[idx],
                                        lat = tmp$Latitude[idx],
                                        layerId = paste0("id", i),
                                        color = cbf[col], opacity = 1)
      }
    }
  })
  ### ###
}


