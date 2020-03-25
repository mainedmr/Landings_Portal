### UI code for the map tab
tab_map_ui <- tags$div(
  div(id = "div_map",
      # Title is generated dynamically
      fluidRow(uiOutput("map_title")),
      # The leaflet map
      leafletOutput(
        "map", width = "100%", height = "800px"
      )
  )
)