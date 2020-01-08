library(shiny)
library(shinyjs)
library(shinyalert)

shinyUI(
  fluidPage(
    #theme = "bootstrap.css",
    # Turn on shinyjs for user authentication
    shinyjs::useShinyjs(),
    # Turn on shiny alert
    useShinyalert(),
    # If using Google Analytics
    #tags$head(includeScript("www/google-analytics.js")),
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
                               onInitialize = I('function() { this.setValue(""); }')
                          )
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
                               onInitialize = I('function() { this.setValue(""); }')
                               )
              )
            ),
           ## Year range
            div(id = "div_year",
              sliderInput(
                "gbl_year_range", 
                label = h5("Year Range"), 
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
                  h4("Plot Controls"),
                  selectizeInput(
                    "gbl_group_plots",
                    label = "Break plots by:",
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
            ) # End plot control div
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
              uiOutput("plot_time_series_title")
            ),
            fluidRow(
              # Time series plot of landings per year
              ggvisOutput("plot_time_series"),
              uiOutput("plot_time_series_ui"),
              # Button to download the data from this plot
              downloadButton("dl_ts", "Download plot data (CSV)")
            )
          )
        ),
        ## -------------------------------------------------------------------------
        ## Grouped variable panel
        ## -------------------------------------------------------------------------
        tabPanel(h4("Grouped Variable"), value = "group",
           fluidRow(
             # Lollipop chart of landings
             plotOutput("plot_group", width = "auto", height = "600")
           )
        ),
        ## -------------------------------------------------------------------------
        ## Table panel - view various landings tables
        ## -------------------------------------------------------------------------
        tabPanel(h4("View Tables"), value = "tbls"
          # Placeholder
        )
      ) # End tabset panel
    ) # End main panel
  ) # End sidebar layout
  ) # End fluidPage
) # End Shiny UI