### UI code for the time series tab
tab_ts_ui <- tags$div(
  div(id = "div_ts",
      fluidRow(
        # Title is generated dynamically
        uiOutput("plot_time_series_title"),
        column(6, align = "center", offset = 3,
               # Button to download the data
               downloadButton("dl_ts", "Download selected data (CSV)")
        )
      ),
      uiOutput("ts_page")
  )
)