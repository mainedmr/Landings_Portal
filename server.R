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
      shinyjs::show("div_port")
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
  # Group label
  lab_group <- reactive({
    get_var_name(vars_groups, input$gbl_group_plots)
  })
  # Ports selected label
  lab_ports <- reactive({
    if (fil_ports()) {
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
  # Filter data reactively
  ts_data <- reactive({
    d <- landings %>%  
    # Filter by selected species if species are selected
    {if (fil_species()) {
      dplyr::filter(., species %in% input$gbl_species)
    } else {.}} %>%
    # Filter by selected ports if ports are selected
    {if (fil_ports()) {
      dplyr::filter(., port %in% input$gbl_ports)
    } else {.}} %>%
    # Filter by selected year range
    dplyr::filter(between(year, input$gbl_year_range[1], 
                          input$gbl_year_range[2])) %>%
    # First group by year
    dplyr::group_by(year) %>%
    # Then conditionally group based on selected group variable
    {if (input$gbl_group_plots != 'none') {
      dplyr::group_by(., !!sym(input$gbl_group_plots), add = T)
    } else {.}} %>%
    # Sum weight, value, trips, harvesters
    dplyr::summarise(total_weight = sum(weight, na.rm = T),
                     total_value = sum(value, na.rm = T),
                     total_trips = sum(trip_n, na.rm = T),
                     total_harvs = sum(harv_n, na.rm = T)
                     )
    # If grouping, apply factor to group by column
    if (input$gbl_group_plots != 'none') {
      d[[input$gbl_group_plots]] <- factor(d[[input$gbl_group_plots]])
    }
    return(d)
  })
  # Render plot title reactively
  output$plot_time_series_title <- renderUI({
    if (input$gbl_plot_tbl == "plot") {
      title <- glue("{lab_series()}")
    } else {
      title <- "Tabular Data"
    }
    if (input$gbl_group_plots != 'none') {
      title <- glue("{title} per {lab_group()}")
    }
    title <- glue("{title} per Year {input$gbl_year_range[1]} to \\
              {input$gbl_year_range[2]}")
    tagList(
      h4(title, align = "center"),
      h5(lab_ports(), align = "center"),
      h5(lab_species(), align = "center")
    )
  })
  
  # Create time series plot
  reactive({
    req(input$gbl_plot_tbl == "plot")
    # Make plot
    ts_data() %>%
      {
        if (input$gbl_group_plots != 'none') {
          dplyr::ungroup(.) %>%
          ggvis(x = ~year, y = series_name) %>%
          group_by(!!sym(input$gbl_group_plots)) %>%
          layer_lines() %>%
          layer_points(fill = as.name(input$gbl_group_plots)) %>%
          #layer_lines(y = ~total_value, strokeDash := 6) %>%
          #layer_points(y = ~total_value,
          #             fill = as.name(input$gbl_group_plots)) %>%
          # Legend
          add_legend("fill",
                     title = lab_group())
        } else {
          ggvis(., x = ~year, y = series_name) %>%
                layer_lines() %>%
                layer_points()
        }
      } %>%
      add_axis("x", title = "Year", subdivide = 0, format = '####') %>%
      scale_numeric("x", domain = c(input$gbl_year_range[1], 
                                    input$gbl_year_range[2]),
                    nice = T) %>%
      add_axis("y", orient = "left", 
               title = lab_series(), 
               title_offset = 75) %>%
      # Set ggvis options
      set_options(width = "auto", height = "600", resizable = F)
  }) %>%
  ## Bind reactive plot to a shiny output
  bind_shiny(plot_id = "plot_time_series", controls_id = "plot_time_series_ui")
  # React to plot download clicks
  output$dl_ts <- downloadHandler(
    filename = function() {
      paste0('MaineDMR_Landings_Time_Series_Data_', Sys.Date(), '.csv')
    },
    content = function(con) {
      readr::write_csv(ts_data(), con, na = "")
    }
  )
  ## Render UI for table or plot
  output$ts_page <- renderUI({
    if (input$gbl_plot_tbl == "plot") {
      tagList(
        fluidRow(
          # Time series plot of landings per year
          ggvisOutput("plot_time_series"),
          uiOutput("plot_time_series_ui")
        )
      )
    } else {
      tagList(
        dataTableOutput("tbl_ts")
      )
    }
  })
  # Render table
  output$tbl_ts <- renderDT(
        datatable(ts_data(), rownames = F, 
                  colnames = dt_col_labels(colnames(ts_data())),
                    options = list(
                      # Get the index of the column being plotted,
                      # and order by year asc and order desc
                      order = list(
                        list(grep("year", colnames(ts_data())), "asc"),
                        list(grep(input$gbl_plot_series, colnames(ts_data())), "desc")
                      )
                    )
                    ) %>%
          # Format currency column
          formatCurrency(columns = grep(dt_cols$total_value$name, colnames(ts_data())),
                         currency = unit_val,
                         digits = digits_value) %>%
          # Format weight column
          formatRound(columns = grep(dt_cols$total_weight$name, colnames(ts_data())),
                      digits = digits_weight) %>%
          # Format trips/harvesters with comma
          formatRound(columns = c(grep(dt_cols$total_trips$name, colnames(ts_data())),
                                  grep(dt_cols$total_harvs$name, colnames(ts_data()))),
                      digits = 0)
                    )
  ## -------------------------------------------------------------------------
  ## Grouped variable panel
  ## -------------------------------------------------------------------------
  # Filter data reactively
  gr_data <- reactive({
    # Require the user to choose a grouping variable
    validate(
      need(input$gbl_group_plots != "none", "Please select a grouping variable.")
    )
    d <- landings %>%
      # Filter by selected species if filter species is checked
      {if (fil_species()) {
        dplyr::filter(., species %in% input$gbl_species)
      } else {.}} %>%
      # Filter by selected ports if filter ports is checked
      {if (fil_ports()) {
        dplyr::filter(., port %in% input$gbl_ports)
      } else {.}} %>%
      # Filter by selected year range
      dplyr::filter(between(year, input$gbl_year_range[1], 
                            input$gbl_year_range[2])) %>%
      # Group based on selected group variable
      dplyr::group_by(!!sym(input$gbl_group_plots)) %>%
      # Sum weight, value, trips, harvesters
      dplyr::summarise(total_weight = sum(weight, na.rm = T),
                       total_value = sum(value, na.rm = T),
                       total_trips = sum(trip_n, na.rm = T),
                       total_harvs = sum(harv_n, na.rm = T)) %>%
      # Sort by variable being viewed
      arrange(!!sym(input$gbl_plot_series))
    # Apply factor to group by column, ordering factor by sorted data
    d <- d[!is.na(d[[input$gbl_group_plots]]), ]
    d[[input$gbl_group_plots]] <- factor(d[[input$gbl_group_plots]],
                                         levels = d[[input$gbl_group_plots]])
    return(d)
  })
  # Render plot title reactively
  output$plot_gr_title <- renderUI({
    req(input$gbl_group_plots != 'none')
    if (input$gbl_plot_tbl == "plot") {
      title <- glue("{lab_series()}")
    } else {
      title <- "Tabular Data"
    }
    title <- glue("{title} per {lab_group()}, \\
                  {input$gbl_year_range[1]} to {input$gbl_year_range[2]}")
    tagList(
      h4(title, align = "center"),
      h5(lab_ports(), align = "center"),
      h5(lab_species(), align = "center"),
      column(6, align = "center", offset = 3,
         # Button to download the data
         downloadButton("dl_gr", "Download selected data (CSV)")
      )
    )
  })
  # Generate lollipop chart
  output$plot_group <- renderPlot({
    req(input$gbl_plot_tbl == "plot")
    ggplot(gr_data(), aes(y = !!sym(input$gbl_group_plots), 
                          x = !!sym(input$gbl_plot_series))) +
    geom_point(size = 4, color = "orange") +
    geom_segment(aes(y = !!sym(input$gbl_group_plots), 
                     yend = !!sym(input$gbl_group_plots),
                     x = 0, 
                     xend = !!sym(input$gbl_plot_series))) +
    # Add x and y labels
    xlab(lab_series()) +
    ylab(lab_group()) +
    # Set x labels to comma separated
    scale_x_continuous(labels = scales::comma) +
    # Set theme options
    gbl_theme
  })
  ## Render UI for table or plot
  output$grouped_page <- renderUI({
    if (input$gbl_plot_tbl == "plot") {
      tagList(
        fluidRow(
          # Lollipop chart of landings
          plotOutput("plot_group", width = "auto", height = "600")
        )
      )
    } else {
      tagList(
        dataTableOutput("tbl_gr")
      )
    }
  })
  # Render table
  output$tbl_gr <- renderDT(
                    datatable(gr_data(), rownames = F,
                    colnames = dt_col_labels(colnames(gr_data())),
                      options = list(
                        order = list(
                          # Get the index of the column being plotted and order desc
                          list(grep(input$gbl_plot_series, colnames(gr_data())), "desc")
                        )
                      )
                    ) %>%
                    # Format currency column
                    formatCurrency(columns = grep(dt_cols$total_value$name, colnames(gr_data())),
                                   currency = unit_val,
                                   digits = digits_value) %>%
                    # Format weight column
                    formatRound(columns = grep(dt_cols$total_weight$name, colnames(gr_data())),
                                digits = digits_weight) %>%
                    # Format trips/harvesters with comma
                    formatRound(columns = c(grep(dt_cols$total_trips$name, colnames(gr_data())),
                                            grep(dt_cols$total_harvs$name, colnames(gr_data()))),
                                digits = 0)
                  )
  
  # React to plot download clicks
  output$dl_gr <- downloadHandler(
    filename = function() {
      paste0('MaineDMR_Landings_Grouped_Data_', Sys.Date(), '.csv')
    },
    content = function(con) {
      readr::write_csv(gr_data(), con, na = "")
    }
  )
  ## -------------------------------------------------------------------------
  ## Map panel
  ## -------------------------------------------------------------------------
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
  # Modify map when selectors change
  observe({
    validate(
      need(nrow(map_data()) >= 1, "No data in selection.")
    )
    # Get color palette for map layer
    color_data <- as.numeric(map_data()[[input$map_color_by]])
    map_pal <- get_palette(color_data = color_data, 
                           bins = 10, palette = input$map_color_scheme)
    # Build popups for map layer
    popups <- paste0(
      "<strong>", get_var_name(vars_map_lyrs, input$map_lyr), ": </strong>",
      map_data()[[input$map_lyr]],
      "<br/><strong>Pounds: </strong>", prettyNum(round(map_data()$total_weight, 0), big.mark = ",", scientific = F),
      "<br/><strong>Value ($): </strong>", prettyNum(round(map_data()$total_value, 0), big.mark = ",", scientific = F),
      "<br/><strong>Trips: </strong>", prettyNum(round(map_data()$total_trips, 0), big.mark = ",", scientific = F),
      "<br/><strong>Harvesters: </strong>", prettyNum(round(map_data()$total_harvs, 0), big.mark = ",", scientific = F)
    ) %>%
      lapply(htmltools::HTML)
    # Build legend title
    legend_title <- paste0(get_var_name(vars_series, input$map_color_by), 
                           " per ", get_var_name(vars_map_lyrs, input$map_lyr))
    # Proxy leaflet map with generated map data
    leafletProxy("map") %>%
      # Clear markers
      clearMarkers() %>%
      # Clear poly group
      clearGroup("poly") %>%
      # Clear controls
      clearControls() %>%
      # Add circle markers if mapping points
      {if ("sfc_POINT" %in% class(map_data()$geometry)) {
        addCircleMarkers(., data = map_data(),
           # Assign tow number as layer ID for use in histogram popup
           #layerId = ~tow_num,
           fillColor = map_pal(color_data), 
           fillOpacity = 0.7, color = "white", 
           radius = 8, stroke = F,
           label = popups,
           labelOptions = labelOptions(style = list("font-weight" = "normal", 
                                                    padding = "3px 8px"), 
                                       textsize = "13px", 
                                       direction = "auto")
        )
      } else {.}} %>%
      # Add polygons if mapping counties, zones, etc
      {if ("sfc_POLYGON" %in% class(map_data()$geometry) |
           "sfc_MULTIPOLYGON" %in% class(map_data()$geometry)) {
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
                position = "bottomright")
  })
  
}) # End shinyServer