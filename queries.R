### Pre-defined queries to help users understand the portal

queries <- list(
  # Plot yearly lobster landings per zone
  lob_per_zone = list(
    description = "Plot Yearly Lobster Landings Per Zone",
    tab = "ts",
    selections = list(
      gbl_port = list(
        type = "selectize",
        selected = character(0)
      ),
      gbl_species = list(
        type = "selectize",
        selected = c("Lobster American")
      ),
      gbl_year_range = list(
        type = "slider",
        value = c(2010, 2018)
      ),
      gbl_plot_tbl = list(
        type = "selectize",
        selected = "plot"
      ),
      gbl_group_plots = list(
        type = "selectize",
        selected = "lob_zone"
      ),
      gbl_plot_series = list(
        type = "selectize",
        selected = "total_weight"
      )
    )
  ),
  # Plot yearly lobster landings per zone
  clam_towns_2018 = list(
    description = "Plot Softshell Clam Weight Per Town for 2018",
    tab = "group",
    selections = list(
      gbl_port = list(
        type = "selectize",
        selected = character(0)
      ),
      gbl_species = list(
        type = "selectize",
        selected = c("Clam Soft")
      ),
      gbl_year_range = list(
        type = "slider",
        value = c(2018, 2018)
      ),
      gbl_plot_tbl = list(
        type = "selectize",
        selected = "plot"
      ),
      gbl_group_plots = list(
        type = "selectize",
        selected = "port"
      ),
      gbl_plot_series = list(
        type = "selectize",
        selected = "total_weight"
      )
    )
  )
)


## Unpack the name and description of each query to a named vector for the selector
desc_queries <- c()
for (name in names(queries)) {
  desc <- queries[[name]]$description
  desc_queries <- c(desc_queries, desc)
}
vars_queries <- names(queries)
names(vars_queries) <- desc_queries
rm(desc_queries, desc, name)

## Function to update the portal for a given query
set_query <- function(session, query_name) {
  # Get query parameters
  p <- queries[[query_name]]
  # Check that it is a valid query name
  if (is.null(p)) {return(F)}
  # Set the active tab
  updateTabsetPanel(session, "tab_panel", selected = p$tab)
  # For each selections id
  for (id in names(p$selections)) {
    # Get the type of the selector
    type <- p$selections[[id]]$type
    # Selective input
    if (type == "selectize") {
      updateSelectizeInput(session, id, selected = p$selections[[id]]$selected)
      next()
    }
    # Select inputs
    if (type == "select") {
      updateSelectInput(session, id, selected = p$selections[[id]]$selected)
      next()
    }
    # Slider inputs
    if (type == "slider") {
      updateSliderInput(session, id, value = p$selections[[id]]$value)
    }
  }
  return(T)
}
