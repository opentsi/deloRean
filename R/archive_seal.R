#' Seal an Archive by Storing the Current Update Checksum
#'
#' Stamps the archive with a checksum derived from `checksum_input` and writes
#' it to `inst/metadata.json`. The JSON is assumed to have already been rendered
#' from `data-raw/metadata.yaml` via [render_metadata()] before calling this
#' function.
#'
#' If `checksum_input` is already a valid 64-character lowercase hex SHA-256
#' string it is used directly; otherwise the object is hashed with SHA-256 via
#' [digest::digest()].
#'
#' After sealing, a status summary is printed confirming which workflow stages
#' are in place.
#'
#' @param checksum_input An R object to hash, or a 64-character lowercase hex
#'   SHA-256 string.
#' @param archive_path Path to the archive/package root directory.
#'   Defaults to the current working directory.
#' @return Invisibly returns the checksum string.
#' @importFrom digest digest
#' @importFrom jsonlite fromJSON toJSON
#' @export
#' @examples
#' \dontrun{
#' # Hash an R object (e.g. a data frame or publication date)
#' archive_seal(my_data_frame)
#'
#' # Pass a pre-computed SHA-256 string
#' archive_seal("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
#'
#' # Seal a specific archive
#' archive_seal(my_data_frame, archive_path = "~/opentsi/ch.kof.barometer")
#' }
archive_seal <- function(checksum_input, archive_path = NULL) {
  if (is.null(archive_path)) {
    archive_path <- getwd()
  }

  is_sha256 <- is.character(checksum_input) &&
    length(checksum_input) == 1 &&
    grepl("^[0-9a-f]{64}$", checksum_input)

  hash <- if (is_sha256) checksum_input else digest(checksum_input, algo = "sha256")

  json_path <- file.path(archive_path, "inst", "metadata.json")
  if (!file.exists(json_path)) {
    stop(sprintf(
      "Metadata JSON not found: %s\nRun render_metadata() before archive_seal().",
      json_path
    ))
  }

  meta <- fromJSON(json_path, simplifyVector = FALSE)
  meta$update_checksum <- hash
  writeLines(toJSON(meta, pretty = TRUE, auto_unbox = TRUE), json_path)

  .seal_report(archive_path, hash)

  invisible(hash)
}


.seal_report <- function(archive_path, hash) {
  chk <- function(ok) if (ok) "[x]" else "[ ]"

  init_ok    <- dir.exists(file.path(archive_path, ".git")) &&
                  file.exists(file.path(archive_path, "DESCRIPTION"))
  # history ok is a bit more complex,cant just check that index.md exists. 
  history_ok <- local({
    idx_path <- file.path(archive_path, "data-raw", "index.md")
    if (!file.exists(idx_path)) return(FALSE)
    txt <- readLines(idx_path, warn = FALSE)
    h_idx <- grep("^## ", txt)
    # need to check that keys andpaths are written below header
    if (length(h_idx) == 0L) return(FALSE)
    any(nzchar(trimws(txt[(h_idx[[1L]] + 1L):length(txt)])))
  })
  meta_ok    <- file.exists(file.path(archive_path, "inst", "metadata.json"))
  process_ok <- file.exists(file.path(archive_path, "R", "process_data.R"))
  auto_ok    <- file.exists(file.path(archive_path, "R", "handle_update.R"))

  cat("\n-- archive seal --\n\n")
  cat(chk(init_ok),    "archive init\n")
  cat(chk(history_ok), "history imported\n")
  cat(chk(meta_ok),    "meta information rendered\n")
  cat(chk(process_ok), "data processing in place\n")
  cat(chk(auto_ok),    "update automation in place\n")
  cat("\nchecksum:", hash, "\n\n")
}
