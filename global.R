library(shiny)
library(shinyjs)
library(shinyWidgets)
library(tidyverse)
library(ggplot2)
library(scales)
library(ggvis)
library(glue)
library(DT)
library(uuid)
library(RColorBrewer)
library(leaflet)
library(leaflet.esri)
library(leaflet.extras)
library(sf)
library(scales)

# Base url to the GitHub repo with data and settings
base_url <- "https://github.com/mainedmr/Landings_Portal/raw/master/"

# Input data
data_url <- paste0(base_url, "landings.Rda")
load(url(data_url))

## Stick dummy values into historic landings (so they can be fed through the same
## pipes as regular landings)
hist_landings$trip_n <- NA
hist_landings$harv_n <- NA

# Source settings
devtools::source_url(paste0(base_url, "settings.R"))

# Source tracking settings file
if (file.exists("tracking_settings.R")) {
  source("tracking_settings.R")
}

# Source functions file
source("functions.R")

# Source queries
devtools::source_url(paste0(base_url, "queries.R"))

# Set global table options
options(DT.options = gbl_dt_options)

# Load map layers (SF objects in Rda)
load("map_layers.Rda")

# Load map helper functions
source("map_functions.R")

vars_map_lyrs <- c("Port" = "port",
                   "County" = "county",
                   "Lobster Zone" = "lob_zone")

### List of variables for selectors
vars_species <- sort(c(unique(landings$species), "Coconut Crab"))
vars_hist_species <- sort(c(unique(hist_landings$species)))
vars_years <- sort(unique(landings$year))
vars_hist_years <- sort(unique(hist_landings$year))
vars_ports <- sort(unique(landings$port))
vars_lob_zones <- sort(unique(landings$lob_zone))

# Build column selectors dynamically from dt_cols in settings.R
vars_groups = c("None" = "none") %>%
              c(., dt_cols_to_vec("group"))

# Groups to show when historic landings are selected
vars_hist_groups = c('None' = 'none',
                     'Species' = 'species')

vars_series <- dt_cols_to_vec("var")
vars_hist_series <- vars_series[1:2]

lab_wt <- glue("Total Weight ({unit_wt})")
lab_val <- glue("Total Value ({unit_val})")



