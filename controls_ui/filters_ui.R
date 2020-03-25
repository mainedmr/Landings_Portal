### Control panel for filters
filters_ui <- tags$div(
  # Title for selector box
  selectors_title,
  ## Port
  div(id = "div_port",
      selectizeInput(
        "gbl_ports", 
        label = ports_label, 
        choices = vars_ports,
        #selected = vars_ports[1],
        multiple = T,
        options = list(maxOptions = ports_max_options,
                       maxItems = ports_max_items,
                       placeholder = ports_placeholder,
                       'plugins' = list('remove_button'),
                       onInitialize = I('function() { this.setValue(""); }')
        )
      ),
      actionButton(
        "rst_port",
        label = "Clear Port Selection"
      )
  ),
  ## Species
  div(id = "div_species",
      selectizeInput(
        "gbl_species",
        label = species_label,
        choices = vars_species,
        #selected = vars_species[1],
        multiple = T,
        options = list(maxOptions = species_max_options,
                       maxItems = species_max_items,
                       placeholder = species_placeholder,
                       'plugins' = list('remove_button'),
                       onInitialize = I('function() { this.setValue(""); }')
        )
      ),
      actionButton(
        "rst_species",
        label = "Clear Species Selection"
      )
  ),
  ## Year range
  div(id = "div_year",
      sliderInput(
        "gbl_year_range", 
        label = years_label, 
        min = min(as.numeric(vars_years)), 
        max = max(as.numeric(vars_years)), 
        value = c(years_min_year, years_max_year),
        sep = ""
      )
  ) # End div_year
)