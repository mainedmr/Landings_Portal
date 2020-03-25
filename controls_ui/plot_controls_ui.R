### UI for plot controls
plot_controls_ui <- tags$div(
  div(id = "div_plot_controls",
        h4("Plot/Table Controls"),
        selectizeInput(
          "gbl_landings_type", 
          label = "Landings Type:", 
          choices = c("Modern" = "mod", "Historic" = "hist")
        ),
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
  ) # End div
)