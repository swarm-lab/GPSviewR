GPSviewR <- function() {
  app_path <- paste0(find.package("GPSviewR"), "/app")
  shiny::runApp(app_path, launch.browser = TRUE)
}