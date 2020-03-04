# Load/install packages
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse)

# Set wd as location of script if user is using RStudio, else set it to a temp dir
if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
} else setwd(tempdir())


# Input CSV file
input_csv <- "landings_update_03_04_2020.csv"

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
  mutate(species = stringr::str_to_title(species),
         year = as.numeric(year)) %>%
  # Select just columns needed
  dplyr::select(!!req_cols) %>%
  # Replace NAs
  tidyr::replace_na(list(
    port = "UK",
    county = "UK",
    lob_zone = "UK"
  ))

# If landings value is character, convert to numeric
if (class(landings$value) == 'character') {
  # Replace $ , then convert to numeric
  landings$value <- as.numeric(gsub("[\\$,]", "", landings$value))
}


##### Historic landings

# Input CSV file
input_csv <- "hist_landings.csv"

# Check that all columns for portal are included
req_cols <- c("year", "species", "weight", "value")

# Load data
hist_landings <- readr::read_csv(input_csv) %>%
  dplyr::rename_all(tolower) %>%
  # Rename fields here if necessary
  dplyr::rename(year = year,
                species = species,
                weight = pounds,
                value = value) %>%
  mutate(species = stringr::str_to_title(species),
         year = as.numeric(year)) %>%
  # Select just columns needed
  dplyr::select(!!req_cols)

# If landings value is character, convert to numeric
if (class(hist_landings$value) == 'character') {
  # Replace $ , then convert to numeric
  hist_landings$value <- as.numeric(gsub("[\\$,]", "", hist_landings$value))
}

# Save file
save(landings, hist_landings, file = "landings.Rda")

# Then upload the output landings.Rda file to the GitHub repo; for convenience,
# the output folder is opened
shell(paste0("explorer ", normalizePath(getwd())), intern = T) 
