#' Checks Whether a Time Series Archive Is Up to Date
#'
#' This functions returns TRUE when a more recent version is available.
#'
#' @param publisher_last_update POSIXct formatted UTC time of publisher's last
#' available publication
is_update_needed <- function(publisher_last_update, data_dir = "data-raw"){
  update_file_loc <- file.path(data_dir, "LAST_UPDATE")
  fcon <- file(update_file_loc)
  as.POSIXct(readLines(con = fcon)) < publisher_last_update
}
