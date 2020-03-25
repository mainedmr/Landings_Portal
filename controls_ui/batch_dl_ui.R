### UI for batch download buttons
batch_dl_ui <- tags$div(
  tags$h3("Batch Download"),
  # Download buttons
  downloadButton(outputId = "dl_all_mod", 
                 label = "Modern Landings"),
  downloadButton(outputId = "dl_all_hist", 
                 label = "Historic Landings")
)