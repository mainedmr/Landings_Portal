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
            # Button row
            fluidRow(
              column(2,
                # Pre-defined queries button
                dropdownButton(
                  queries_ui,
                  circle = T,
                  icon = icon("info-circle"),
                  status = "info",
                  size = "sm",
                  label = "Preset Queries",
                  tooltip = T
                )
              ),
              column(2,
                dropdownButton(
                  batch_dl_ui,
                  circle = T,
                  icon = icon("file-download"),
                  status = "success",
                  size = "sm",
                  label = "Batch Download",
                  tooltip = T
                )
              )
            ),
            filters_ui
          ), # End well panel 
        # The control panel for the plots
        plot_controls_ui,
        # The control panel for the map
        map_controls_ui
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
          tab_ts_ui
        ),
        ## -------------------------------------------------------------------------
        ## Grouped variable panel
        ## -------------------------------------------------------------------------
        tabPanel(h4("Grouped Variable"), value = "group",
          tab_gr_ui
        ),
        ## -------------------------------------------------------------------------
        ## Map panel
        ## -------------------------------------------------------------------------
        tabPanel(h4("Map"), value = "map",
           tab_map_ui
        )
      ) # End tabset panel
    ) # End main panel
  ) # End sidebar layout
  ) # End fluidPage
}) # End Shiny UI