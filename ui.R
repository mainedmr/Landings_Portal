library(shiny)
library(shinyjs)
library(shinyalert)
library(shinydashboard)
library(shinydashboardPlus)

shinyUI(function(req) {
  tagList(
    # Turn on shinyjs
    shinyjs::useShinyjs(),
    # If using Google Analytics
    #tags$head(includeScript('www/google-analytics.js')),
    ## Geolocation
    tags$head(
      # Load geolocation JS
      tags$script(src = 'geolocation.js')
    ),
    # https://github.com/rstudio/shiny/issues/141
    
  )
 dashboardPage(
   
    header = dashboardHeader(
      title = app_title,
      fixed = T,
      leftUi = tagList(
        dropdownBlock(
          id = 'dd_filters',
          title = 'Filters',
          icon = icon('filter'),
          badgeStatus = NULL,
          filters_ui
        ),
        dropdownBlock(
          id = 'dd_plot',
          title = 'Plot Controls',
          icon = icon('chart-bar'),
          badgeStatus = NULL,
          plot_controls_ui
        ),
        dropdownBlock(
          id = 'dd_map',
          title = 'Map Controls',
          icon = icon('map'),
          badgeStatus = NULL,
          map_controls_ui
        ),
        dropdownBlock(
          id = 'dd_queries',
          title = 'Preset Queries',
          icon = icon('search'),
          badgeStatus = NULL,
          queries_ui
        ),
        dropdownBlock(
          id = 'dd_dl',
          title = 'Batch Download',
          icon = icon('download'),
          badgeStatus = NULL,
          batch_dl_ui
        )
      )
    ),
    sidebar = dashboardSidebar(
      sidebarMenu(
        # Prevent sidebar from dissappearing when scrolling
        style = 'position: fixed; overflow: visible;',
        # Id used to get selected tab
        id = 'tab_panel',
        # About section
        menuItem('About', tabName = 'about', icon = icon('info')),
        # Time Series
        menuItem('Time Series', tabName = 'ts', icon = icon('chart-line')),
        # Grouped variable
        menuItem('Grouped Variable', tabName = 'group', icon = icon('chart-bar')),
        # Map
        menuItem('Map', tabName = 'map', icon = icon('map'))
      )
    ),
    body = dashboardBody(
      tabItems(
        # About tab content
        tabItem(tabName = 'about',
          # The content of this tab will be rendered from a separate file as 
          # specified in server.ui
          br(), br(),
          uiOutput('about_page')
        ),
        # Time series tab content
        tabItem(tabName = 'ts',
          br(), br(),
          tab_ts_ui
        ),
        # Grouped variable tab content
        tabItem(tabName = 'group',
          br(), br(),
          tab_gr_ui
        ),
        # Map tab content
        tabItem(tabName = 'map',
          br(), br(),
          tab_map_ui
        )
      )
      
    ) # End dashboard body
  ) # End dashboardpagePlus
}) # End ShinyUI