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
vars_years <- sort(unique(landings$year))
vars_ports <- sort(unique(landings$port))
vars_lob_zones <- sort(unique(landings$lob_zone))

# Build column selectors dynamically from dt_cols in settings.R
vars_groups = c("None" = "none") %>%
              c(., dt_cols_to_vec("group"))

vars_series <- dt_cols_to_vec("var")

lab_wt <- glue("Total Weight ({unit_wt})")
lab_val <- glue("Total Value ({unit_val})")



