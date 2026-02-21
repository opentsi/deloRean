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
                            validate = TRUE) {

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
  message("Use opentimeseries::resolve_meta() to view key mappings.")

  invisible(meta)
}
