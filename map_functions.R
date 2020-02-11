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
        baseGroups = c("ESRI World Oceans", "ESRI World Imagery", "NOAA Chart Service"),
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
#' @param ceil If true, the highest value in the color scale will be greater
#' than or equal to the number of bins; if false, the top of the scale will be
#' the max of the color data; false should be passed when applying log adjust.
get_palette <- function(color_data, bins, palette, ceil = T) {
  # Maximum value from the color by data
  max_number <- max(color_data)
  # Handle max errors
  if (max_number == Inf | max_number == -Inf) {
    max_number <- bins
  }
  # If the max number is less than the number of bins AND not ceil (ie log adj),
  # just set both maxes to the number of bins; else set max scale to 
  # next bin up from max_number
  if (max_number < bins & ceil) {
    max_number <- bins
    max_scale <- bins
  } else if (!ceil) {
    # Max scale is max number
    max_scale <- max_number
  } else {
    # Intialize max scale as nearest integer up from max number
    max_scale <- ceiling(max_number)
    # Increase max scale to be evenly divisible by number of bins
    while (max_scale %% bins != 0) {
      max_scale <- max_scale + 1
    }
  }
  # Create bins
  my_bins = seq(0, max_scale, by = max_scale / bins)
  my_palette = leaflet::colorBin(palette = palette, domain = max_number,
                                 na.color = "transparent", bins = my_bins)
  return(my_palette)
}
