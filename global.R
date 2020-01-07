library(shiny)
library(shinyjs)
library(tidyverse)
library(ggplot2)
library(scales)
library(ggvis)
library(glue)

# Base url to the GitHub repo with data and settings
base_url <- "https://github.com/mainedmr/Landings_Portal/raw/master/"

# Input data
data_url <- paste0(base_url, "landings.Rda")
load(url(data_url))

# Source settings
devtools::source_url(paste0(base_url, "settings.R"))


# List of variables for selectors
vars_species <- sort(unique(landings$species))
vars_years <- sort(unique(landings$year))
vars_ports <- sort(unique(landings$port))
vars_lob_zones <- sort(unique(landings$lob_zone))
vars_groups <- c("None" = "none", 
                 "Species" = "species", 
                 "Port" = "port",
                 "County" = "county",
                 "Lobster Zone" = "lob_zone")
lab_wt <- glue("Total Weight ({unit_wt})")
lab_val <- glue("Total Value ({unit_val})")
vars_series <- c("total_weight", 
                 "total_value",
                 "total_trips",
                 "total_harvs")
# Assign names to vars_series with dynamic labels
names(vars_series) <- c(glue("Total Weight ({unit_wt})"), 
                        glue("Total Value ({unit_val})"),
                        "Total Trips",
                        "Total Harvesters")

### Functions

# Returns name of a named vector item vs its value
get_var_name <- function(vector, value) {
  names(vector)[match(value, vector)]
}




