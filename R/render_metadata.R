#' Render Metadata YAML to JSON
#'
#' Reads a YAML metadata file, validates it, and writes a JSON version
#' for programmatic consumption. The YAML remains the source of truth
#' (human-readable, browsable on GitHub), while JSON is the artifact
#' consumed by opentimeseries.
#'
#' @param archive_path Path to the data archive/package directory.
#'   If NULL (default), uses current working directory.
#' @param validate Logical. If TRUE (default), validates metadata before rendering.
#' @param verbose Logical. If TRUE, prints resolved key mappings after rendering.
#' @return Invisibly returns the metadata as a list.
#' @importFrom yaml read_yaml
#' @importFrom jsonlite toJSON
#' @export
#' @examples
#' \dontrun{
#' # Render for a specific archive
#' render_metadata("path/to/my.dataset")
#'
#' # From within a data package directory
#' render_metadata()
#'
#' # Skip validation (not recommended)
#' render_metadata("path/to/my.dataset", validate = FALSE)
#' }
render_metadata <- function(archive_path = NULL,
                            validate = TRUE,
                            verbose = TRUE) {

  if (is.null(archive_path)) {
    archive_path <- getwd()
  }

  # Handle case where user passes yaml file path instead of archive root
  if (grepl("metadata\\.yaml$", archive_path)) {
    yaml_path <- archive_path
    # Go up from data-raw/metadata.yaml to archive root
    archive_path <- dirname(dirname(archive_path))
  } else {
    yaml_path <- file.path(archive_path, "data-raw", "metadata.yaml")
  }

  json_path <- file.path(archive_path, "inst", "metadata.json")

  if (!file.exists(yaml_path)) {
    stop(sprintf("Metadata file not found: %s", yaml_path))
  }

  # Read YAML
  meta <- read_yaml(yaml_path)

  # Validate
  if (validate) {
    validate_metadata(meta, strict = TRUE)
    message("Metadata validation passed.")
  }

  # Ensure output directory exists
  json_dir <- dirname(json_path)
  if (!dir.exists(json_dir)) {
    dir.create(json_dir, recursive = TRUE)
  }

  # Write JSON
  json_content <- toJSON(meta, pretty = TRUE, auto_unbox = TRUE)
  writeLines(json_content, json_path)

  message(sprintf("Rendered: %s -> %s", yaml_path, json_path))

  # Show resolved keys if verbose
  if (verbose) {
    resolved <- resolve_meta(meta)
    if (nrow(resolved) > 0) {
      cat("\nResolved keys:\n")
      for (i in seq_len(nrow(resolved))) {
        cat(sprintf("  %s\n", resolved$key[i]))
      }
      cat("\n")
    }
  }

  invisible(meta)
}
