group_species = T
group_ports = T
gbl_species = c("American Lobster")
gbl_ports = c("Boothbay", "Stonington")
gbl_year_range = c(2000, 2017)
group_var = "species"

landings <- readr::read_csv("lobster_landings.csv")

test <- landings %>%  
  # Filter by selected species if group species is checked
  {if (group_species) {
    dplyr::filter(., species %in% gbl_species)
  } else {.}} %>%
  # Filter by selected ports if group ports is checked
  {if (group_ports) {
    dplyr::filter(., port %in% gbl_ports)
  } else {.}} %>%
  # Filter by selected year range
  dplyr::filter(between(year, gbl_year_range[1], 
                        gbl_year_range[2])) %>%
  # First group by year
  dplyr::group_by(year) %>%
  # Then Conditionally group based on checked boxes
  {if (group_species) {
    dplyr::group_by(., species, add = T)
  } else {.}} %>%
  {if (group_ports) {
    dplyr::group_by(., port, add = T) 
  } else {.}} %>%
  # Sum weight and value
  dplyr::summarise(total_weight = sum(weight, na.rm = T),
                   total_value = sum(value, na.rm = T))

group_var = "port"
# Plot
test %>%
  ggvis(~year, ~total_weight) %>%
  group_by(!!group_var) %>%
  layer_paths()



test <- landings %>%  
  # Filter by selected species if group species is checked
  {if (group_species) {
    dplyr::filter(., species %in% gbl_species)
  } else {.}} %>%
  # Filter by selected ports if group ports is checked
  {if (group_ports) {
    dplyr::filter(., port %in% gbl_ports)
  } else {.}} %>%
  # Filter by selected year range
  dplyr::filter(between(year, gbl_year_range[1], 
                        gbl_year_range[2])) %>%
  # First group by year
  dplyr::group_by(year) %>%
  # Then conditionally group based on selected group variable
  {if (group_var != 'none') {
    dplyr::group_by(., !!sym(group_var), add = T)
  } else {.}} %>%
  # Sum weight and value
  dplyr::summarise(total_weight = sum(weight, na.rm = T),
                   total_value = sum(value, na.rm = T))




vars_groups <- c("None" = "none", 
                 "Species" = "species", 
                 "Port" = "port")

# Returns name of a named vector item vs its value
get_var_name <- function(vector, value) {
  names(vector)[match(value, vector)]
}



landings <- readr::read_csv("landings2.csv") %>%
  dplyr::rename_all(tolower)




