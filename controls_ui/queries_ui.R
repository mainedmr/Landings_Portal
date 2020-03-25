### UI for preset queries selector
queries_ui <- tags$div(
  selectizeInput("gbl_query", label = "", 
    choices = vars_queries,
    options = list(placeholder = "Choose query", 
      'plugins' = list('remove_button'),
      onInitialize = I('function() { this.setValue(""); }')
    )
  )
)