### Server code for the time series tab
# Filter data reactively
ts_data <- reactive({
  req(!hist_toggle)
  d <- {if (input$gbl_landings_type == 'mod') landings else hist_landings} %>%  
    # Filter by selected species if species are selected
    {if (fil_species()) {
      dplyr::filter(., species %in% input$gbl_species)
    } else {.}} %>%
    # Filter by selected ports if ports are selected
    {if (fil_ports() & input$gbl_landings_type == 'mod') {
      dplyr::filter(., port %in% input$gbl_ports)
    } else {.}} %>%
    # Filter by selected year range
    dplyr::filter(between(year, input$gbl_year_range[1], 
                          input$gbl_year_range[2])) %>%
    # First group by year
    dplyr::group_by(year) %>%
    # Then conditionally group based on selected group variable
    {if (input$gbl_group_plots != 'none') {
      # Require that column is in data (handles reactivity errors)
      req(input$gbl_group_plots %in% colnames(.))
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
    set_options(width = "auto", height = "600", resizable = F) %>%
    # Popup on hover
    add_tooltip(function(data) {
      # Blank HTML
      html <- ""
      # For each column in the hovered point
      for (col in names(data)) {
        # If it is the reactive col, give it the series name
        if (grepl('reactive', col)) {
          colname <-  lab_series()
        } else { # Column name to title case
          colname <- stringr::str_to_title(col)
        }
        # Get value of hovered point, format it as number if numeric and not
        val <- unlist(data[col])
        if (is.numeric(val) & tolower(col) != 'year') {
          val <- prettyNum(round(val, 0), big.mark = ",", scientific = F)
        }
        html <- paste0(html, "<strong>", colname, ": </strong>", val, "</br>")
      }
      return(html)
    }, on = "hover")
}) %>%
  ## Bind reactive plot to a shiny output
  bind_shiny(plot_id = "plot_time_series", controls_id = "plot_time_series_ui")
# React to plot download clicks
output$dl_ts <- downloadHandler(
  filename = function() {
    paste0('MaineDMR_Landings_Time_Series_Data_', Sys.Date(), '.csv')
  },
  content = function(con) {
    submit_event("download", "time_series", guid, ip = "ip()")
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
        uiOutput("plot_time_series_ui"),
        # Plot caption
        h4("Hover mouse over plot points to see data detail.")
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