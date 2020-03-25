### UI for map controls
map_controls_ui <- tags$div(
  div(id = "div_map_controls",
      wellPanel(
        h4("Map Controls"),
        selectizeInput(
          "map_lyr",
          label = "Map by:",
          choices = vars_map_lyrs,
          selected = vars_map_lyrs[1]
        ),
        selectizeInput(
          "map_color_by",
          label = "Color by:",
          choices = vars_series,
          selected = vars_series[1]
        ),
        selectInput("map_color_scheme", 
                    label = "Color Scheme:",
                    choices = rownames(subset(brewer.pal.info, category %in% c("seq", "div"))),
                    selected = "YlOrBr"),
        div(id = "div_size_by",
            selectizeInput(
              "map_size_by",
              label = "Size Points by:",
              choices = vars_series,
              selected = vars_series[2]
            )
        )
      ) # End well panel
  ) # End map control div
)