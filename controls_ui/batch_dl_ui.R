### UI for batch download buttons
batch_dl_ui <- tags$div(
  # Download buttons
  downloadButton(outputId = "dl_all_mod", 
                 label = "Modern Landings"),
  downloadButton(outputId = "dl_all_hist", 
                 label = "Historic Landings")
)