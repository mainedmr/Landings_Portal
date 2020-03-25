submit_event <- function(event_type, event_value, guid, ip, lat = 0, lon = 0) {
  if (!(exists("tracking_url")) | !exists("access_code")) {
    return(F)
  }
   r <- httr::POST(url = tracking_url,
                   body = list(access_code = access_code,
                               event_type = event_type,
                               event_value = event_value,
                               datetime = as.integer(Sys.time()),
                               session_guid = guid,
                               lat = lat,
                               lon = lon,
                               ip_address = ip),
                   encode = "json")
   # Stop for status
   #httr::stop_for_status()
}

# Returns name of a named vector item vs its value
get_var_name <- function(vector, value) {
  names(vector)[match(value, vector)]
}

# For a vector of a dataframes colnames, finds the labels from dt_cols, returning
# a named vector to pass to datatable()
dt_col_labels <- function(columns) {
  # Blank vectors
  col_names <- c()
  col_labels <- c()
  # Incrementer
  i <- 1
  # For each input column name
  for (cname in columns) {
    # Check if it is in vars_groups
    if (cname %in% vars_groups) {
      # If so append name and label to vectors and increment i
      col_names[i] <- cname
      col_labels[i] <- get_var_name(vars_groups, cname)
      i <- i + 1
      next
    }
    # Check if it is in vars_series
    if (cname %in% vars_series) {
      # If so append name and label to vectors and increment i
      col_names[i] <- cname
      col_labels[i] <- get_var_name(vars_series, cname)
      i <- i + 1
      next
    }
    # Check if it is in the dt_cols list
    if (!is.null(dt_cols[[cname]]$name)) {
      # If so append name and label to vectors and increment i
      col_names[i] <- dt_cols[[cname]]$name
      col_labels[i] <- dt_cols[[cname]]$label
      i <- i + 1
    }
  }
  # Assign labels as names and return
  names(col_names) <- col_labels
  return(col_names)
}

# Get a named vector of field names from dt_cols to provide to a selector for
# a given field type
dt_cols_to_vec <- function(col_type) {
  # Blank vectors
  vec_names <- c()
  vec_labels <- c()
  # For each field if the type matches append to the vector
  for (field in names(dt_cols)) {
    if (dt_cols[[field]]$type == col_type) {
      vec_names <- c(vec_names, dt_cols[[field]]$name)
      vec_labels <- c(vec_labels, dt_cols[[field]]$label)
    }
  }
  # Assign labels as names for vector
  names(vec_names) <- vec_labels
  return(vec_names)
}
