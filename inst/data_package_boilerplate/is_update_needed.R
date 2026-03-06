#' Check if Data Update is Needed
#'
#' Compares the current source checksum with the stored checksum to determine
#' if the data has changed. This function should not be exported to avoid
#' name collisions across opentsi data packages.
#'
#' @return Logical. TRUE if update is needed, FALSE otherwise.
is_update_needed <- function() {
  current <- compute_source_checksum()
  stored <- read_checksum()

  if (is.null(stored)) {
    return(TRUE)
  }

  !identical(current, stored)
}


#' Compute Checksum of Source Data
#'
#' USER: Customize this function to return content that represents the current
#' state of your data source. This could be:
#' \itemize{
#'   \item A scraped webpage or section thereof
#'   \item An API response or headers (e.g., ETag, Last-Modified)
#'   \item A minimal data pull (first N rows, summary stats)
#'   \item Any string that changes when the source data changes
#' }
#'
#' @return Character. MD5 checksum of the source content.
compute_source_checksum <- function() {

  # ---------------------------------------------------------------------
  # TODO: Replace the example below with your data source check

  # Example 1: Check a webpage
  # content <- readLines("https://provider.example.com/data-page")
  #
  # Example 2: Check API headers
  # response <- httr::HEAD("https://api.example.com/data")
  # content <- httr::headers(response)$`last-modified`
  #
  # Example 3: Check a data summary
  # data <- fetch_minimal_data()
  # content <- paste(nrow(data), max(data$date), collapse = "|")
  # ---------------------------------------------------------------------

  content <- as.character(Sys.time())
  # Placeholder: always triggers update. Replace with real check.

  md5_hash(content)
}


#' Compute MD5 Hash of Content
#'
#' Uses base R tools::md5sum via a tempfile.
#'
#' @param content Character vector to hash.
#' @return Character. 32-character lowercase MD5 hash.
md5_hash <- function(content) {
  tmp <- tempfile()
  on.exit(unlink(tmp), add = TRUE)
  writeLines(as.character(content), tmp)
  unname(tools::md5sum(tmp))
}


#' Read Stored Checksum from Metadata JSON
#'
#' @param path Path to metadata JSON. Defaults to inst/metadata.json
#' @return Character checksum or NULL if not present.
read_checksum <- function(path = "inst/metadata.json") {
  if (!file.exists(path)) {
    return(NULL)
  }
  meta <- jsonlite::fromJSON(path)
  meta$update_checksum
}


#' Write Checksum to Metadata JSON
#'
#' Updates the update_checksum field in the rendered metadata JSON.
#'
#' @param checksum Character. The checksum to store.
#' @param path Path to metadata JSON. Defaults to inst/metadata.json
write_checksum <- function(checksum, path = "inst/metadata.json") {
  if (!file.exists(path)) {
    stop("Metadata JSON not found. Run deloRean::render_metadata() first.")
  }
  meta <- jsonlite::fromJSON(path)
  meta$update_checksum <- checksum
  jsonlite::write_json(meta, path, pretty = TRUE, auto_unbox = TRUE)
}


#' Initialize Checksum After History Import
#'
#' Call this after archive_import_history() and render_metadata() to establish
#' the baseline checksum without triggering a data re-fetch. This prevents
#' the first handle_update() run from duplicating data already in history.
#'
#' @param path Path to metadata JSON. Defaults to inst/metadata.json
#' @return Invisibly returns the checksum.
init_checksum <- function(path = "inst/metadata.json") {
  checksum <- compute_source_checksum()
  write_checksum(checksum, path)
  message("Initial checksum stored: ", checksum)
  invisible(checksum)
}
