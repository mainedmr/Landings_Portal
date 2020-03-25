### Server code for the map tab
# Render plot title reactively
output$map_title <- renderUI({
  title <- glue("{lab_map_series()} per {lab_map_lyr()}, \\
                  {input$gbl_year_range[1]} to {input$gbl_year_range[2]}")
  tagList(
    h4(title, align = "center"),
    h5(lab_species(), align = "center")
    #column(6, align = "center", offset = 3,
    #       # Button to download the data
    #       downloadButton("dl_gr", "Download selected data (CSV)")
    #)
  )
})
# Render basemap
output$map <- get_leaflet_base()
# Get data for map
# Filter data reactively and join to spatial layer for map
map_data <- reactive({
  validate(
    # Require that the selected map layer exist
    need(exists(paste0("lyr_", input$map_lyr)), "Map layer selected does not exist!.")
  )
  d <- landings %>%
    # Filter by selected species if filter species is checked
    {if (fil_species()) {
      dplyr::filter(., species %in% input$gbl_species)
    } else {.}} %>%
    # Filter by selected year range
    dplyr::filter(between(year, input$gbl_year_range[1], 
                          input$gbl_year_range[2])) %>%
    # Group based on selected group variable
    #dplyr::group_by(!!sym(input$map_lyr)) %>%
    dplyr::group_by(!!sym(input$map_lyr)) %>%
    # Sum weight, value, trips, harvesters
    dplyr::summarise(total_weight = sum(weight, na.rm = T),
                     total_value = sum(value, na.rm = T),
                     total_trips = sum(trip_n, na.rm = T),
                     total_harvs = sum(harv_n, na.rm = T))
  
  # Join spatial data to landings
  f <- get(paste0("lyr_", input$map_lyr)) %>%
    # Join
    dplyr::left_join(d, by = input$map_lyr) %>%
    # Replace NAs in numeric cols with 0s
    dplyr::mutate_if(is.numeric, replace_na, replace = 0)
  rm(d)
  return(f)
})
# Reactive to detect if selected layer is point or polygon; also toggles
# selector for point size variable if point layer selected
pnt_or_poly <- reactive({
  # If point geometry
  if ("sfc_POINT" %in% class(map_data()$geometry)) {
    p <- "point"
    # Show size by div
    shinyjs::show("div_size_by")
  } else if ("sfc_POLYGON" %in% class(map_data()$geometry) |
             "sfc_MULTIPOLYGON" %in% class(map_data()$geometry)) {
    # Polygon geometry
    p <- "polygon"
    # Hide size by div
    shinyjs::hide("div_size_by")
  } else {p <- "unknown"}
  return(p)
})

# Modify map when selectors change
observe({
  validate(
    need(nrow(map_data()) >= 1, "No data in selection.")
  )
  # Get color palette for map layer
  color_data <- as.numeric(map_data()[[input$map_color_by]])
  map_pal <- get_palette(color_data = color_data, 
                         bins = 10, palette = input$map_color_scheme)
  # If sizing by point, get point radii
  if (pnt_or_poly() == "point") {
    size_data <- map_data()[[input$map_size_by]]
    radii <- get_pnt_radii(size_data = size_data,
                           min_radius = point_size[1], 
                           max_radius = point_size[2])
  }
  # Build popups for map layer
  popups <- paste0(
    "<strong>", lab_map_lyr(), ": </strong>",
    map_data()[[input$map_lyr]],
    "<br/><strong>Pounds: </strong>", prettyNum(round(map_data()$total_weight, 0), big.mark = ",", scientific = F),
    "<br/><strong>Value ($): </strong>", prettyNum(round(map_data()$total_value, 0), big.mark = ",", scientific = F),
    "<br/><strong>Trips: </strong>", prettyNum(round(map_data()$total_trips, 0), big.mark = ",", scientific = F),
    "<br/><strong>Harvesters: </strong>", prettyNum(round(map_data()$total_harvs, 0), big.mark = ",", scientific = F)
  ) %>%
    lapply(htmltools::HTML)
  # Build legend titles
  legend_title <- paste0(lab_map_series(), " per ", lab_map_lyr())
  legend_title2 <- paste0(lab_map_pnt_size(), " per ", lab_map_lyr())
  # Proxy leaflet map with generated map data
  leafletProxy("map") %>%
    # Clear markers
    clearMarkers() %>%
    # Clear poly group
    clearGroup("poly") %>%
    # Clear controls
    clearControls() %>%
    # Add circle markers if mapping points
    {if (pnt_or_poly() == "point") {
      addCircleMarkers(., data = map_data(),
                       # Assign tow number as layer ID for use in histogram popup
                       #layerId = ~tow_num,
                       fillColor = map_pal(color_data), 
                       fillOpacity = 0.7, color = "white", 
                       radius = radii, stroke = F,
                       label = popups,
                       labelOptions = labelOptions(style = list("font-weight" = "normal", 
                                                                padding = "3px 8px"), 
                                                   textsize = "13px", 
                                                   direction = "auto")
      )
    } else {.}} %>%
    # Add polygons if mapping counties, zones, etc
    {if (pnt_or_poly() == "polygon") {
      addPolygons(., data = map_data(),
                  group = "poly", fillColor = map_pal(color_data),
                  fillOpacity = 0.7, color = "white",
                  stroke = F, label = popups,
                  labelOptions = labelOptions(style = list("font-weight" = "normal", 
                                                           padding = "3px 8px"), 
                                              textsize = "13px", 
                                              direction = "auto")
      )
    } else {.}} %>%
    # Add legend
    addLegend(pal = map_pal, values = color_data, opacity = 0.9, 
              title = legend_title, 
              position = "bottomright") %>%
    {if (pnt_or_poly() == "point" & F) { # Disabled for now due to rendering issues
      pnt_labs <- pretty(size_data, n = 10)
      sizes <- get_pnt_radii(size_data = pnt_labs,
                             min_size = min(size_data),
                             max_size = max(size_data),
                             min_radius = point_size[1],
                             max_radius = point_size[2])
      addLegendCustom(map = ., title = legend_title2, 
                      colors = rep("black", length(sizes)), 
                      labels = pnt_labs,
                      sizes = sizes,
                      opacity = 0.9)
    } else {.}}
})