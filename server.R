library(shiny)
library(shinyjs)
library(glue)

shinyServer(function(input, output, session) {
  # When session first starts generate a guid
  guid <- uuid::UUIDgenerate()
  # Get IP info
  ip <- reactive({
    isolate(input$remote_addr)
  })
  # Then submit new session
  submit_event("new_session", "new_session", guid, ip = "ip()")
  # This code will be run after the client has disconnected
  session$onSessionEnded(function() {
    submit_event("end_session", "end_session", guid, ip = "ip()")
  })
  # React when a user agrees to geolocation and submit
  observeEvent(input$geolocation, {
    event_value <- ifelse(input$geolocation, "agreed", "denied")
    submit_event("geolocation", event_value, guid, 
                ip = "ip()", lat = input$lat, lon = input$long)
  })
  ## This bit reacts when a tab is clicked and hides/shows the sidebar depending
  ## on the tab; ie, for the About and Data tab the sidebar is hidden
  # Session-wide boolean for side panel state
  sidebar_state <- F
  # Session-wide boolean for map bumped
  map_bumped <- F
  # React when tab is changed
  observeEvent(input$tab_panel, {
    submit_event("tab_change", input$tab_panel, guid, ip = "ip()")
    # Disable/enable plot and map control panels depending on tab clicked
    if (input$tab_panel == "map") {
      shinyjs::show("div_map_controls")
      shinyjs::hide("div_plot_controls")
      shinyjs::hide("div_port")
      # Force the map to draw by toggling a selector- this makes sure the map draws
      # when the session is started - only due this once per session, as 
      # per map_bumped boolean
      if (!(map_bumped)) {
        current <- input$map_color_by
        updateSelectInput(session, "map_color_by", selected = vars_series[2])
        updateSelectInput(session, "map_color_by", selected = current)
        map_bumped <<- T
      }
    } else {
      shinyjs::hide("div_map_controls")
      shinyjs::show("div_plot_controls")
      if (input$gbl_landings_type == 'mod') {
        shinyjs::show("div_port")
      } else {
        shinyjs::hide("div_port")
      }
    }
    # Hide the sidebar panel when About or View Download is chosen
    if (input$tab_panel == "about") {
      shinyjs::hide("div_sidebar")
      sidebar_state <<- F
    } else {
      shinyjs::show("div_sidebar")
      sidebar_state <<- T
    }
  })
  
  ## Toggle sidebar on/off with button clicks
  observeEvent(input$sidebar_toggle, {
    req(input$sidebar_toggle)
    if (sidebar_state) {
      shinyjs::hide(id = "div_sidebar")
      sidebar_state <<- F
    } else {
      if (input$tab_panel == "about") {
        shinyjs::hide(id = "div_sidebar")
        sidebar_state <<- F
      } else {
        shinyjs::show(id = "div_sidebar")
        sidebar_state <<- T
      }
    }
    # Submit event
    submit_event("sidebar_state", ifelse(sidebar_state, "on", "off"), guid, ip = "ip()")
  })
  
  ## Clear port and species selectors when buttons hit
  observeEvent(input$rst_port, {
    updateSelectizeInput(session, "gbl_ports", selected = character(0))
  })
  observeEvent(input$rst_species, {
    updateSelectizeInput(session, "gbl_species", selected = character(0))
  })


  # Tamatoa lies in wait....
  tamatoa <- F
  observeEvent({input$gbl_ports 
                input$gbl_species}, {
    if (
      "Southport" %in% input$gbl_ports & "Coconut Crab" %in% input$gbl_species &
      !tamatoa
    ) 
    {
      shinyalert(title = "Shiiiiinnny!!!", 
                text = "Well, Tamatoa hasn't always been this glam\n
                I was a drab little crab once\n
                Now I know I can be happy as a clam\n
                Because I'm beautiful, baby.", 
                 type = "info",
                closeOnClickOutside = T,
                 imageHeight = 100,
                 imageUrl = "https://vignette.wikia.nocookie.net/disney/images/c/c5/Profile_-_Tamatoa.jpeg/revision/latest?cb=20190627030539"
                 )
      tamatoa <<- T
      # Submit event
      submit_event("tamatoa", "shiiiiny", guid, ip = "ip()")
    }
  })
  
  
  ## Observe selectors
  fil_ports <- reactive({
    if (length(input$gbl_ports) > 0) {
      return(T)
    } else {
      return(F)
    }
  })
  fil_species <- reactive({
    if (length(input$gbl_species) > 0) {
      return(T)
    } else {
      return(F)
    }
  })
  
  # React to series selected for ggvis plots
  series_name <- reactive({
    as.name(input$gbl_plot_series)
  })
  # Series label
  lab_series <- reactive({
    get_var_name(vars_series, input$gbl_plot_series)
  })
  # Map variable label
  lab_map_series <- reactive({
    get_var_name(vars_series, input$map_color_by)
  })
  # Group label
  lab_group <- reactive({
    get_var_name(vars_groups, input$gbl_group_plots)
  })
  # Map layer label
  lab_map_lyr <- reactive({
    get_var_name(vars_map_lyrs, input$map_lyr)
  })
  # Map point size label
  lab_map_pnt_size <- reactive({
    get_var_name(vars_series, input$map_size_by)
  })
  # Ports selected label
  lab_ports <- reactive({
    if (fil_ports() & input$gbl_landings_type == 'mod') {
      paste0("Ports: ", paste(sort(input$gbl_ports), collapse = ", "))
    } else {"All Ports"}
  })
  # Species selected label
  lab_species <- reactive({
    if (fil_species()) {
      paste0("Species: ", paste(sort(input$gbl_species), collapse = ", "))
    } else {"All Species"}
  })

  ## React to preset query being selected
  observeEvent(input$gbl_query, {
    set_query(query_name = input$gbl_query, session)
  })
  
  ## React to batch download button presses
  # Modern landings
  output$dl_all_mod <- downloadHandler(
    filename = function() {
      paste0('MaineDMR_Modern_Landings_Data_', Sys.Date(), '.csv')
    },
    content = function(con) {
      submit_event("download", "all_modern", guid, ip = "ip()")
      readr::write_csv(landings, con, na = "")
    }
  )
  # Historic landings
  output$dl_all_hist <- downloadHandler(
    filename = function() {
      paste0('MaineDMR_Historic_Landings_Data_', Sys.Date(), '.csv')
    },
    content = function(con) {
      submit_event("download", "all_historic", guid, ip = "ip()")
      readr::write_csv(hist_landings, con, na = "")
    }
  )
  
  ## React to selector for modern/historic landings
  hist_toggle <- F
  observeEvent(input$gbl_landings_type, {
    hist_toggle <<- T
    # Modern landings
    if (input$gbl_landings_type == 'mod') {
      # Update group by selector
      updateSelectizeInput(session, inputId = 'gbl_group_plots',
                           choices = vars_groups,
                           selected = "none")
      # Update series selector
      updateSelectizeInput(session, inputId = 'gbl_plot_series',
                           choices = vars_series)
      # Show port selector
      shinyjs::show('div_port')
      # Show map tab
      showTab(inputId = 'tab_panel', target = 'map')
      # Update species selector
      updateSelectizeInput(session, inputId = 'gbl_species', 
                           choices = vars_species,
                           selected = character(0))
      # Update years selector
      updateSliderInput(session, inputId = 'gbl_year_range', 
                        min = min(as.numeric(vars_years)), 
                        max = max(as.numeric(vars_years)), 
                        value = c(years_min_year, years_max_year))
      
    } else {
      # Update group by selector
      updateSelectizeInput(session, inputId = 'gbl_group_plots',
                           choices = vars_hist_groups,
                           selected = "none")
      # Update series selector
      updateSelectizeInput(session, inputId = 'gbl_plot_series',
                           choices = vars_hist_series,
                           selected = vars_hist_series[1])
      # Hide port selector
      shinyjs::hide('div_port')
      # Hide map tab
      hideTab(inputId = 'tab_panel', target = 'map')
      # Update species selector
      updateSelectizeInput(session, inputId = 'gbl_species', 
                           label = NULL, 
                           choices = vars_hist_species,
                           selected = character(0))
      # Update years selector
      updateSliderInput(session, inputId = 'gbl_year_range', 
                        min = min(as.numeric(vars_hist_years)), 
                        max = max(as.numeric(vars_hist_years)), 
                        value = c(years_hist_min_year, 
                                  max(as.numeric(vars_hist_years))))
    }
    hist_toggle <<- F
  }, priority = 500)
  
  ## -------------------------------------------------------------------------
  ## About panel
  ## -------------------------------------------------------------------------
  # Render about panel from file
  output$about_page <- renderUI({
    # For Markdown files
    if (endsWith(about_file_path, ".md")) {
      return(includeMarkdown(about_file_path))
    }
    # For HTML files
    if (endsWith(about_file_path, ".html")) {
      return(includeHTML(about_file_path))
    }
    else {
      h5("Could not load about file...")
    }
  })
  ## -------------------------------------------------------------------------
  ## Time Series panel
  ## -------------------------------------------------------------------------
  source('tab_ts/tab_ts_srv.R', local = T)
  ## -------------------------------------------------------------------------
  ## Grouped variable panel
  ## -------------------------------------------------------------------------
  source('tab_gr/tab_gr_srv.R', local = T)
  ## -------------------------------------------------------------------------
  ## Map panel
  ## -------------------------------------------------------------------------
  source('tab_map/tab_map_srv.R', local = T)
}) # End shinyServer