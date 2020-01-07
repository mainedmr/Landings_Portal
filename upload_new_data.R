# Load/install packages
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse)

# Set wd as location of script if user is using RStudio, else set it to a temp dir
if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
} else setwd(tempdir())


# Input CSV file
input_csv <- "landings_new.csv"

# Check that all columns for portal are included
req_cols <- c("year", "species", "port", "county", "lob_zone", 
              "weight", "weight_type", "value", "trip_n", "harv_n")

# Load data
landings <- readr::read_csv(input_csv) %>%
  dplyr::rename_all(tolower) %>%
  # Rename fields here if necessary
  dplyr::rename(species = common_name,
                port = port_name,
                weight = total_pounds,
                value = total_value,
                trip_n = `#_trips`,
                harv_n = `#_active_harvesters`) %>%
  mutate(species = stringr::str_to_title(species)) %>%
  # Select just columns needed
  dplyr::select(!!req_cols) %>%
  # Replace NAs
  tidyr::replace_na(list(
    port = "UK",
    county = "UK",
    lob_zone = "UK"
  ))

# Save file
save(landings, file = "landings.Rda")

# Then upload the output landings.Rda file to the GitHub repo; for convenience,
# the output folder is opened
shell(paste0("explorer ", normalizePath(getwd())), intern = T) 
