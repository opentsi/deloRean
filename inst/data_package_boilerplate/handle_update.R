
#' Handle Data Update
#'
#' Orchestrates the update process: checks if update is needed,
#' processes data, writes output, and stores the new checksum.
#'
#' @importFrom opentimeseries write_open_ts
#' @export
handle_update <- function() {
  if (!is_update_needed()) {
    message("No update needed, series up-to-date.")
    return(invisible(NULL))
  }

  # Compute checksum before processing (same value is_update_needed used)
  new_checksum <- compute_source_checksum()

  tsx <- process_data()
  write_open_ts(tsx)

  # Store checksum after successful update
  write_checksum(new_checksum)
  message("Update complete, checksum stored.")

  invisible(tsx)
}
