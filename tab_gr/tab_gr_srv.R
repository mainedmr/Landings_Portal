### Server code for grouped variable tab
# Filter data reactively
gr_data <- reactive({
  req(!hist_toggle)
  # Require the user to choose a grouping variable
  validate(
    need(input$gbl_group_plots != "none", "Please select a grouping variable.")
  )
  d <- {if (input$gbl_landings_type == 'mod') landings else hist_landings} %>%
    # Require that column is in data (handles reactivity errors)
    {req(input$gbl_group_plots %in% colnames(.))
      .} %>%
    # Filter by selected species if filtering species
    {if (fil_species()) {
      dplyr::filter(., species %in% input$gbl_species)
    } else {.}} %>%
    # Filter by selected ports if filtering ports and viewing modern
    {if (fil_ports() & input$gbl_landings_type == 'mod') {
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
    submit_event("download", "grouped", guid, ip = "ip()")
    readr::write_csv(gr_data(), con, na = "")
  }
)