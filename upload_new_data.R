# Load/install packages
if (!require("pacman")) install.packages("pacman")
library(pacman)
p_load(tidyverse)

# Set wd as location of script if user is using RStudio, else set it to a temp dir
if (rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
} else setwd(tempdir())


# Input CSV file
input_csv <- "LandingsDataByPort_8-12-2024.csv"

# Check that all columns for portal are included
req_cols <- c("year", "species", "port", "county", "lob_zone", 
              "weight", "weight_type", "value", "trip_n", "harv_n")

# Load in last update for comparison
load('landings.Rda')
last_landings <- landings %>%
  rename(lst_weight = weight, lst_value = value, lst_trip_n = trip_n,
         lst_harv_n = harv_n)
last_hist_landings <- hist_landings

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

# Check for duplicate values
landings %>%
  group_by(year, species, port, lob_zone) %>%
  summarize(n = n()) %>%
  ungroup() %>%
  dplyr::filter(n > 1) %>%
  arrange(desc(year))

# Bin landings by grouping unit
landings_no_dups <- landings %>%
  group_by(year, species, port, county, lob_zone, weight_type) %>%
  summarize(weight = sum(weight, na.rm = T),
            value = sum(value, na.rm = T),
            trip_n = sum(trip_n, na.rm = T),
            harv_n = sum(harv_n, na.rm = T)) %>%
  ungroup()

last_landings_no_dups <- last_landings %>%
  group_by(year, species, port, county, lob_zone, weight_type) %>%
  summarize(lst_weight = sum(lst_weight, na.rm = T),
            lst_value = sum(lst_value, na.rm = T),
            lst_trip_n = sum(lst_trip_n, na.rm = T),
            lst_harv_n = sum(lst_harv_n, na.rm = T)) %>%
  ungroup()


# Compare to last update
last_rows <- nrow(last_landings_no_dups)
compare <- landings_no_dups %>%
  inner_join(last_landings_no_dups, by = c('year', 'species', 'port', 'county',
                                   'lob_zone', 'weight_type'))

compare_no_match <- compare %>% 
  dplyr::filter(weight != lst_weight | value != lst_value | trip_n != lst_trip_n
         | harv_n != lst_harv_n)



# Save file
landings <- landings_no_dups
save(landings, hist_landings, file = "landings.Rda")

# Then upload the output landings.Rda file to the GitHub repo; for convenience,
# the output folder is opened
shell(paste0("explorer ", normalizePath(getwd())), intern = T) 
