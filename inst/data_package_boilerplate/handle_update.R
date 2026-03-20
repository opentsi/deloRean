#' Handle Data Update
#'
#' Orchestrates the update process: checks if update is needed,
#' processes data, writes output, and stores the new checksum.
#'
#' @importFrom opentimeseries write_open_ts is_update_needed update_checksum
#' @export
handle_update <- function() {

  checksum_input <- generate_checksum_input()

  if (!is_update_needed(checksum_input)) {
    message("No update needed, series up-to-date.")
    return(invisible(NULL))
  }

  # Edit R/process_data.R and enter a function
  # that returns the most recent version of a time series
  # from its original provider
  # Store checksum after successful update
  upd <- update_checksum(checksum)
  if(upd){
    process_data("kofbarometer", ids = c("barometer"))
  } else {
    message("Checksum initialized. Data untouched.")
  }
  message("Update complete, checksum stored.")
}


#' User Written Function to Create Input for Checksum Comparison
#'
#' This function generates input for computation of checksums to identify
#' outdated content. Good inputs are either publication dates extracted from
#' official publisher sites or APIs or any single time series from a database,
#' because opentsi definition all time series of the same dataset must
#' have the same publication date.
generate_checksum_input <- function(){

}
