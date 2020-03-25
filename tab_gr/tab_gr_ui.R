### UI for grouped data page
tab_gr_ui <- tags$div(
  div(id = "div_gr",
    fluidRow(
      # Title is generated dynamically
      uiOutput("plot_gr_title")
    ),
    uiOutput("grouped_page")
  )
)