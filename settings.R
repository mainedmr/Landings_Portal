### Maine Landings Portal Settings

# Title to display at top of app
app_title <- "MaineDMR Landings Portal"

# local path/URL to a Markdown or HTML file to render on the about page
about_file_path <- "https://raw.githubusercontent.com/mainedmr/Landings_Portal/master/about.md"

# Units to display in plots
unit_wt <- "lbs"
unit_val <- "$"

## Selectors
# Title for selectors panel
selectors_title = h4("Filter data with the following selectors:")
# Label for the port selector
ports_label = h4("Ports:")
# Max number of ports to show in ports drop down
ports_max_options = Inf
# Max number of ports that can be selected by a user
ports_max_items = 5
# Placeholder text when no port is selected
ports_placeholder = "All Ports"
# Label for the species selector
species_label = h4("Species:")
# Max number of species to show in ports drop down
species_max_options = Inf
# Max number of species that can be selected by a user
species_max_items = 5
# Placeholder text when no species is selected
species_placeholder = "All Species"
# Label for years selector
years_label = h4("Years:")
# The default selected min and max for the years selector. The range of the
# selector will automatically be set to the min/max years present in the data
years_min_year = 2000
years_max_year = 2021

years_hist_min_year = 1950

# Set global ggplot theme options - these styles are applied across all
# ggplot produced plots in the portal
gbl_theme <- theme(
  plot.title = element_text(
    face = "bold", 
    size = 20, 
    hjust = 0.5
  ),
  plot.subtitle = element_text(
    size = 16,
    hjust = 0.5
  ),
  axis.title = element_text(
    face = "bold", 
    size = 14
  ),
  axis.text = element_text(
    size = 12
  )
)

## Global options to apply to all datatables in the portal
gbl_dt_options <- list(
  filter = "top",
  #columnDefs = list(list(targets = 'all', searchable = T)),
  pageLength = 20,
  searching = T,
  scrollX = T,
  scrollY = T,
  orderCellsTop = T,
  fixedHeader = T,
  orderClasses = T
)

# Names and labels of output numeric columns in datatables (used for formatting)
# Move to settings.R sometime
dt_cols <- list(
  total_weight = list(
    name = "total_weight",
    label = glue("Total Weight ({unit_wt})"),
    type = "var"
  ),
  total_value = list(
    name = "total_value",
    label = glue("Total Value ({unit_val})"),
    type = "var"
  ),
  total_trips = list(
    name = "total_trips",
    label = "Total Trips",
    type = "var"
  ),
  total_harvs = list(
    name = "total_harvs",
    label = "Total Harvesters",
    type = "var"
  ),
  year = list(
    name = "year",
    label = "Year",
    type = "ts"
  ),
  species = list(
    name = "species",
    label = "Species",
    type = "group"
  ),
  port = list(
    name = "port",
    label = "Port",
    type = "group"
  ),
  county = list(
    name = "county",
    label = "County",
    type = "group"
  ),
  zone = list(
    name = "lob_zone",
    label = "Lobster Zone",
    type = "group"
  )
)

## Digits to round weight and value to
digits_weight <- 0
digits_value <- 0


## Map settings
# Min max radii for points in Leaflet
point_size <- c(2, 15)

