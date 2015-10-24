options(shiny.maxRequestSize = 10 * 1024 ^ 2)

shinyServer(function(input, output, session) {

  ### Reactive values ###
  react <- reactiveValues(newTrack = 0)
  ### ###

  ### Map logic ###
  output$map <- leaflet::renderLeaflet({
    leaflet() %>%
      addProviderTiles("Esri.WorldImagery",
                       options = providerTileOptions(maxNativeZoom = 17,
                                                     maxZoom = 19)) %>%
      setView(lng = 15.76418, lat = -22.40372, zoom = 12)
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
          # tmp <- read.csv(files[i, ]$datapath, stringsAsFactors = FALSE) %>%
          tmp <- fread(files[i, ]$datapath) %>%
            dplyr::select(1:4) %>%
            dplyr::rename("Date" = V1,
                          "Time" = V2,
                          "Longitude" = V3,
                          "Latitude" = V4)
          if (all(c("Date", "Time", "Longitude", "Latitude") %in% names(tmp))) {
            tmp$Time[tmp$Time == "0:00:00"] <- "0:00:01"
            tmp <- dplyr::mutate(tmp, name = files[i, ]$name) %>%
              dplyr::mutate(DateTime = lubridate::ymd_hms(paste(Date, Time)))
            dat <<- rbind(dat, tmp)
            col <- 18 - length(unique(dat$name)) %% 18
            proxy %>% leaflet::addPolylines(lng = tmp$Longitude, lat = tmp$Latitude,
                                            weight = 2, group = tmp$name[1],
                                            color = cbf[col], opacity = 1,
                                            popup = tmp$name[1]) %>%
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
      tmp <- dat[DateTime <= input$timeSlider &
                   DateTime > input$timeSlider - (input$tailLength + 1)]

      tracks <- unique(tmp$name)
      idx <- paste0("id", 1:length(tracks))
      for (i in 1:length(tracks)) {
        proxy %>% leaflet::addPolylines(lng = tmp[name == tracks[i]]$Longitude,
                                        lat = tmp[name == tracks[i]]$Latitude,
                                        layerId = idx[i], popup = tracks[i],
                                        color = cbf[18 - i %% 18], opacity = 1,
                                        smoothFactor = 0)
      }
    }
  })
  ### ###
})
