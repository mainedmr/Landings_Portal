library(shiny)
library(glue)

shinyServer(function(input, output, session) {
  ## This bit reacts when a tab is clicked and hides/shows the sidebar depending
  ## on the tab; ie, for the About and Data tab the sidebar is hidden
  # Session-wide boolean for side panel state
  sidebar_state <- F
  # Session-wide boolean for map bumped
  map_bumped <- F
  observe({
    req(input$tab_panel)
    # Hide the sidebar panel when About or View Download is chosen
    if (input$tab_panel == "about" | 
        input$tab_panel == "tbls") {
      shinyjs::hide(id = "div_sidebar")
      sidebar_state <<- F
    } else {
      shinyjs::show(id = "div_sidebar")
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
      if (input$tab_panel == "about" | 
          input$tab_panel == "tbls") {
        shinyjs::hide(id = "div_sidebar")
        sidebar_state <<- F
      } else {
        shinyjs::show(id = "div_sidebar")
        sidebar_state <<- T
      }
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
    title <- glue("{lab_series()}")
    if (input$gbl_group_plots != 'none') {
      title <- glue("{title} per {lab_group()}")
    }
    title <- glue("{title} {input$gbl_year_range[1]} to \\
              {input$gbl_year_range[2]}")
    tagList(
      h4(title, align = "center"),
      h5(lab_ports(), align = "center"),
      h5(lab_species(), align = "center")
    )
  })
  
  # Create time series plot
  reactive({
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
  # Generate lollipop chart
  output$plot_group <- renderPlot({
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
    # Build plot title
    ggtitle(label = glue("{lab_series()} per {lab_group()}, \\
                         {input$gbl_year_range[1]} to {input$gbl_year_range[2]}"),
            subtitle = glue("{lab_ports()} \n {lab_species()}")
            ) +
    # Set theme options
    gbl_theme
  })
  ## -------------------------------------------------------------------------
  ## Table View Panel
  ## -------------------------------------------------------------------------  
}) # End shinyServer