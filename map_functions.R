## Function to make a DMR Leaflet basemap - world imagery, world oceans, nautical
## charts
get_leaflet_base <- function(view = c(44, -69, 8)) {
  m <- renderLeaflet({
    # Make the map
    leaflet() %>%
      setView(lat = view[1], lng = view[2] , zoom = view[3]) %>%
      # ESRI baselayers
      addProviderTiles(providers$Esri.WorldImagery,
                       options = providerTileOptions(noWrap = T),
                       group = "ESRI World Imagery") %>%
      addProviderTiles(providers$Esri.OceanBasemap,
                       options = providerTileOptions(noWrap = T),
                       group = "ESRI World Oceans") %>%
      # NOAA RNC
      addEsriImageMapLayer(url = "https://seamlessrnc.nauticalcharts.noaa.gov/arcgis/rest/services/RNC/NOAA_RNC/ImageServer",
                           layerId = "chart",
                           group = "NOAA Chart Service") %>%
      # Baselayer control
      addLayersControl(
        position = "topleft",
        baseGroups = c("ESRI World Imagery", "ESRI World Oceans", "NOAA Chart Service"),
        options = layersControlOptions(collapsed = F)
      ) #%>%
      # # Drawing tool bar for multi-selections
      # addDrawToolbar(
      #   targetGroup = 'Selected',
      #   polylineOptions = F,
      #   markerOptions = F,
      #   circleMarkerOptions = F,
      #   polygonOptions = drawPolygonOptions(
      #     shapeOptions = drawShapeOptions(
      #       fillOpacity = 0,
      #       color = 'red',
      #       weight = 3
      #     )
      #   ),
      #   rectangleOptions = drawRectangleOptions(
      #     shapeOptions = drawShapeOptions(
      #       fillOpacity = 0,
      #       color = 'red',
      #       weight = 3
      #     )
      #   ),
      #   circleOptions = drawCircleOptions(
      #     shapeOptions = drawShapeOptions(
      #       fillOpacity = 0,
      #       color = 'red',
      #       weight = 3
      #     )
      #   ),
      #   editOptions = editToolbarOptions(
      #     edit = F, 
      #     selectedPathOptions = selectedPathOptions()
      #   )
      # ) # End add draw toolbar
  })
}


# Generate a color palette for input numeric data for the number of bins and a
# given color palette
#' @param color_data Numeric vector of input data for color scale
#' @param bins Integer number of bins to use when creating the palette
#' @param palette Character, RColorBrewer palette name to use
#' than or equal to the number of bins; if false, the top of the scale will be
#' the max of the color data; false should be passed when applying log adjust.
get_palette <- function(color_data, bins, palette) {
  # Create bins
  bins <- pretty(color_data, n = bins)
  palette = leaflet::colorBin(palette = palette, domain = max(bins),
                                 na.color = "transparent", bins = bins)
  return(palette)
}


#' Generate a numeric vector of radii for leaflet
#' 
#' @rdname get_pnt_radii
#' @param size_data Numeric vector of input data for point size scale
#' @param min_radius Integer number max radius size for Leaflet points
#' @param max_radius Integer number max radius size for Leaflet points
#' @param min_size Defauls to min of size data, can be specified as well.
#' @param max_size
#' @return A numeric vector of the radius for each input point value, sizing
#' point area NOT point radius based on the relative magnitude of the input.
get_pnt_radii <- function(size_data, min_radius, max_radius, min_size, max_size) {
  if (missing(min_size)) {min_size <- min(size_data)}
  if (missing(max_size)) {max_size <- max(size_data)}
  # Size data represents area of point - convert to radius for each point. Make
  # sure there's no negatives in size data
  min_size <- sqrt(abs(min_size) / pi)
  max_size <- sqrt(abs(max_size) / pi)
  radii <- sqrt(abs(size_data) / pi)
  # Rescale to min/max radius
  radii <- scales::rescale(radii, from = c(min_size, max_size),
                                  to = c(min_radius, max_radius))
}

# Given a vector of radii in pixels, backsolve to get the amount represented by 
# each radius in the given size data vector
backsolve_radii <- function(known_radii, size_data, min_radius, max_radius) {
  # First calculate all radii for size data
  radii <- sqrt(abs(size_data) / pi)
  # Rescale given radius from min/max radius scale to unscaled radii scale
  known_radii <- scales::rescale(known_radii, from = c(min_radius, max_radius),
                            to = c(min(size_data), max(size_data)))
  # Then convert radius to actual size_data units
  sizes <- pi * known_radii^2
}


## Add a custom Leaflet legend - props to:
## https://stackoverflow.com/questions/37446283/creating-legend-with-circles-leaflet-r
addLegendCustom <- function(map, title, colors, labels, sizes, opacity = 0.5,
                            position = "bottomright") {
  colorAdditions <- paste0(colors, "; border-radius: 50%; width:", sizes, 
                           "px; height:", sizes, "px")
  labelAdditions <- paste0("<div style='display: inline-block;height: ", sizes, 
                           "px;margin-top: 4px;line-height: ", sizes, "px;'>", 
                           labels, "</div>")
  return(leaflet::addLegend(map, title = title, colors = colorAdditions, 
                   labels = labelAdditions, opacity = opacity, position = position))
}

