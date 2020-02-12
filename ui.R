library(shiny)
library(shinyjs)
library(shinyalert)

shinyUI(function(req) {
  fluidPage(
    #theme = "bootstrap.css",
    # Turn on shinyjs for user authentication
    shinyjs::useShinyjs(),
    # Turn on shiny alert
    useShinyalert(),
    # If using Google Analytics
    #tags$head(includeScript("www/google-analytics.js")),
    ## Geolocation
    tags$head(
      # Load geolocation JS
      tags$script(src = "geolocation.js")
    ),
    # https://github.com/rstudio/shiny/issues/141
    div(style = "display: none;",
        textInput("remote_addr", "remote_addr",
                  if (!is.null(req[["HTTP_X_FORWARDED_FOR"]]))
                    req[["HTTP_X_FORWARDED_FOR"]]
                  else
                    req[["REMOTE_ADDR"]]
        )
    ),
    # Data portal title
    fluidRow(h2(app_title, align = "center")),
    # Buttons to toggle on/off sidebar
    actionButton(inputId = "sidebar_toggle",
                 label = "Sidebar On/Off"),
    ### Create sidebar/main panel - sidebar has selectors, main panel has tabs
    sidebarLayout(
      fluid = T,
      # Sidebar panel with global selectors
      div(id = "div_sidebar",
        sidebarPanel(
          width = 2,
          ## Selectors
          fluidRow(wellPanel(
            # Pre-defined queries button
            dropdownButton(
              tags$h3("Preset Queries"),
              selectizeInput("gbl_query", label = "", 
                 choices = vars_queries,
                 options = list(placeholder = "Choose query",
                                'plugins' = list('remove_button'),
                                onInitialize = I('function() { this.setValue(""); }')
                 )),
              circle = T,
              icon = icon("info-circle"),
              status = "info",
              size = "sm",
              label = "Preset Queries",
              tooltip = T
            ),
            # Title for selector box
            selectors_title,
            ## Port
            div(id = "div_port",
              selectizeInput(
                "gbl_ports", 
                label = ports_label, 
                choices = vars_ports,
                #selected = vars_ports[1],
                multiple = T,
                options = list(maxOptions = ports_max_options,
                               maxItems = ports_max_items,
                               placeholder = ports_placeholder,
                               'plugins' = list('remove_button'),
                               onInitialize = I('function() { this.setValue(""); }')
                          )
              ),
              actionButton(
                "rst_port",
                label = "Clear Port Selection"
              )
            ),
            ## Species
            div(id = "div_species",
              selectizeInput(
                "gbl_species",
                label = species_label,
                choices = vars_species,
                #selected = vars_species[1],
                multiple = T,
                options = list(maxOptions = species_max_options,
                               maxItems = species_max_items,
                               placeholder = species_placeholder,
                               'plugins' = list('remove_button'),
                               onInitialize = I('function() { this.setValue(""); }')
                               )
              ),
              actionButton(
                "rst_species",
                label = "Clear Species Selection"
              )
            ),
           ## Year range
            div(id = "div_year",
              sliderInput(
                "gbl_year_range", 
                label = years_label, 
                min = min(as.numeric(vars_years)), 
                max = max(as.numeric(vars_years)), 
                value = c(years_min_year, years_max_year),
                sep = ""
              )
            ) # End div_year
          ), # End well panel 
          # The control panel for the plots
          div(id = "div_plot_controls",
              wellPanel(
                h4("Plot/Table Controls"),
                selectizeInput(
                  "gbl_plot_tbl", 
                  label = "Display Type:", 
                  choices = c("Plot" = "plot", "Table" = "table")
                ),
                selectizeInput(
                  "gbl_group_plots",
                  label = "Group by:",
                  choices = vars_groups,
                  selected = "none"
                ),
                selectizeInput(
                  "gbl_plot_series",
                  label = "Plot Series:",
                  choices = vars_series,
                  selected = vars_series[1]
                )
              ) # End well panel
            ), # End plot control div
        # The control panel for the map
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
        ) # End fluid row
      ) # End sidebar panel
    ), # End sidebar div
    # Main panel separated into tabs
    mainPanel(
      width = 10,
      tabsetPanel(
        id = "tab_panel",
        ## -------------------------------------------------------------------------
        ## About panel
        ## -------------------------------------------------------------------------
        tabPanel(h4("About"), value = "about",
          # The content of this tab will be rendered from a separate file as 
          # specified in server.ui
          uiOutput("about_page")
        ),
        ## -------------------------------------------------------------------------
        ## Time Series panel
        ## -------------------------------------------------------------------------
        tabPanel(h4("Time Series"), value = "ts",
          div(id = "div_ts",
            fluidRow(
              # Title is generated dynamically
              uiOutput("plot_time_series_title"),
              column(6, align = "center", offset = 3,
                # Button to download the data
                downloadButton("dl_ts", "Download selected data (CSV)")
              )
            ),
            uiOutput("ts_page")
          )
        ),
        ## -------------------------------------------------------------------------
        ## Grouped variable panel
        ## -------------------------------------------------------------------------
        tabPanel(h4("Grouped Variable"), value = "group",
          div(id = "div_gr",
            fluidRow(
              # Title is generated dynamically
              uiOutput("plot_gr_title")
            ),
            uiOutput("grouped_page")
          )
        ),
        ## -------------------------------------------------------------------------
        ## Map panel
        ## -------------------------------------------------------------------------
        tabPanel(h4("Map"), value = "map",
           div(id = "div_map",
               # Title is generated dynamically
               fluidRow(uiOutput("map_title")),
               # The leaflet map
               leafletOutput(
                 "map", width = "100%", height = "800px"
               )
           )
        )
      ) # End tabset panel
    ) # End main panel
  ) # End sidebar layout
  ) # End fluidPage
}) # End Shiny UI