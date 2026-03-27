#' Validate OpenTSI Metadata
#'
#' Validates a metadata list or YAML file against the OpenTSI schema.
#' Checks required fields, frequency values, language codes (ISO 639-1),
#' and multilingual text structure.
#'
#' @param meta Either a list (parsed metadata) or a path to a YAML file.
#' @param strict Logical. If TRUE (default), stops on first error.
#'   If FALSE, collects all errors and returns them.
#' @return TRUE if valid. If strict=FALSE and invalid, returns character
#'   vector of error messages.
#' @importFrom yaml read_yaml
#' @export
#' @examples
#' \dontrun{
#' validate_metadata("path/to/metadata.yaml")
#' validate_metadata(list(title = list(en = "My Dataset"), ...))
#' }
validate_metadata <- function(meta, strict = TRUE) {
  if (is.character(meta) && length(meta) == 1 && file.exists(meta)) {
    meta <- read_yaml(meta)
  }

  if (!is.list(meta)) {
    stop("meta must be a list or path to a YAML file")
  }

  errors <- character()


  # --- Required fields ---
  required_fields <- c("country", "provider", "dataset", "title", "source_name", "source_url", "dataset_frequency")
  missing <- setdiff(required_fields, names(meta))
  if (length(missing)) {
    errors <- c(errors, paste0("Missing required field(s): ", paste(missing, collapse = ", ")))
  }


  # --- Country code validation ---
  if ("country" %in% names(meta)) {
    if (!grepl("^[a-z]{2}$", meta$country)) {
      errors <- c(errors, "country must be a 2-letter lowercase code (ISO 3166-1 alpha-2)")
    }
  }


  # --- Provider/dataset identifier validation ---
  for (field in c("provider", "dataset")) {
    if (field %in% names(meta)) {
      if (!grepl("^[a-z0-9_]+$", meta[[field]])) {
        errors <- c(errors, paste0(field, " must contain only lowercase letters, numbers, and underscores"))
      }
    }
  }


  # --- Frequency validation ---
  valid_frequencies <- c("D", "W", "M", "Q", "Y", "I")
  if ("dataset_frequency" %in% names(meta)) {
    if (!meta$dataset_frequency %in% valid_frequencies) {
      errors <- c(errors, paste0(
        "Invalid dataset_frequency '", meta$dataset_frequency, "'. ",
        "Must be one of: ", paste(valid_frequencies, collapse = ", ")
      ))
    }
  }


  # --- Multilingual text fields ---
  multilingual_fields <- c("title", "source_name")
  for (field in multilingual_fields) {
    if (field %in% names(meta)) {
      field_errors <- validate_multilingual_text(meta[[field]], field)
      errors <- c(errors, field_errors)
    }
  }


  # --- Units validation (if present) ---
  if ("units" %in% names(meta) && is.list(meta$units)) {
    for (key in names(meta$units)) {
      if (is.list(meta$units[[key]])) {
        field_errors <- validate_multilingual_text(
          meta$units[[key]],
          paste0("units$", key)
        )
        errors <- c(errors, field_errors)
      }
    }
  }


  # --- Aggregate validation (if present) ---
  valid_aggregates <- c("mean", "sum", "last", "first")
  if ("aggregate" %in% names(meta) && is.list(meta$aggregate)) {
    for (key in names(meta$aggregate)) {
      if (!meta$aggregate[[key]] %in% valid_aggregates) {
        errors <- c(errors, paste0(
          "Invalid aggregate method '", meta$aggregate[[key]], "' for '", key, "'. ",
          "Must be one of: ", paste(valid_aggregates, collapse = ", ")
        ))
      }
    }
  }


  # --- Labels validation (if present) ---
  if ("labels" %in% names(meta) && is.list(meta$labels)) {
    label_errors <- validate_labels(meta$labels)
    errors <- c(errors, label_errors)
  }


  # --- Return or stop ---
  if (length(errors) > 0) {
    if (strict) {
      stop(paste(c("Metadata validation failed:", errors), collapse = "\n  - "))
    } else {
      return(errors)
    }
  }

  TRUE
}


#' Validate Multilingual Text Object
#'
#' Checks that a multilingual text object has valid ISO 639-1 language codes
#' and contains at least English ('en').
#'
#' @param obj The multilingual text object (named list).
#' @param field_name Name of the field (for error messages).
#' @return Character vector of errors (empty if valid).
#' @keywords internal
validate_multilingual_text <- function(obj, field_name) {
  errors <- character()

  if (!is.list(obj)) {
    return(paste0(field_name, " must be a named list of language codes"))
  }

  lang_codes <- names(obj)

  if (length(lang_codes) == 0) {
    return(paste0(field_name, " must have at least one language"))
  }

  # Check for required English
  if (!"en" %in% lang_codes) {
    errors <- c(errors, paste0(field_name, " must include 'en' (English) as baseline"))
  }

  # Validate all language codes against ISO 639-1
  valid_codes <- get_iso_639_1_codes()
  invalid_codes <- setdiff(lang_codes, valid_codes)

  if (length(invalid_codes) > 0) {
    errors <- c(errors, paste0(
      field_name, " contains invalid language code(s): ",
      paste(invalid_codes, collapse = ", "),
      ". Must be valid ISO 639-1 codes."
    ))
  }

  errors
}


#' Validate Labels Structure
#'
#' Recursively validates the labels object, checking that all
#' leaf nodes with language codes are valid.
#'
#' @param labels The labels object.
#' @param path Current path (for error messages).
#' @return Character vector of errors (empty if valid).
#' @keywords internal
validate_labels <- function(labels, path = "labels") {
  errors <- character()
  valid_codes <- get_iso_639_1_codes()

  for (key in names(labels)) {
    current_path <- paste0(path, "$", key)
    value <- labels[[key]]

    if (is.list(value)) {
      # Check if this looks like a multilingual text object
      # (has language code keys)
      keys <- names(value)
      if (length(keys) > 0 && all(nchar(keys) == 2)) {
        # Likely a multilingual text object
        invalid_codes <- setdiff(keys, valid_codes)
        if (length(invalid_codes) > 0) {
          errors <- c(errors, paste0(
            current_path, " contains invalid language code(s): ",
            paste(invalid_codes, collapse = ", ")
          ))
        }
      } else {
        # Recurse into nested structure
        nested_errors <- validate_labels(value, current_path)
        errors <- c(errors, nested_errors)
      }
    }
  }

  errors
}


#' Get ISO 639-1 Language Codes
#'
#' Returns a character vector of valid ISO 639-1 two-letter language codes.
#' Requires the ISOcodes package.
#'
#' @return Character vector of valid two-letter language codes.
#' @keywords internal
get_iso_639_1_codes <- function() {
  if (!requireNamespace("ISOcodes", quietly = TRUE)) {
    stop(
      "Package 'ISOcodes' is required for language code validation.\n",
      "Install it with: install.packages('ISOcodes')"
    )
  }

  codes <- ISOcodes::ISO_639_2$Alpha_2
  codes[!is.na(codes)]
}


#' List Available Language Codes
#'
#' Returns a data frame of valid ISO 639-1 language codes with their names.
#' Useful for documentation and autocomplete.
#'
#' @return Data frame with columns 'code' and 'name'.
#' @export
#' @examples
#' \dontrun{
#' list_language_codes()
#' }
list_language_codes <- function() {
  if (!requireNamespace("ISOcodes", quietly = TRUE)) {
    stop(
      "Package 'ISOcodes' is required.\n",
      "Install it with: install.packages('ISOcodes')"
    )
  }

  iso <- ISOcodes::ISO_639_2
  iso <- iso[!is.na(iso$Alpha_2), c("Alpha_2", "Name")]
  names(iso) <- c("code", "name")
  iso[order(iso$code), ]
}


#' View OpenTSI Metadata Schema
#'
#' Prints the OpenTSI metadata JSON schema to the console in a readable format.
#' The schema defines the structure for dataset metadata files.
#'
#' @param raw Logical. If TRUE, returns the schema as a list instead of printing.
#' @return Invisibly returns the schema as a list. Prints formatted output if raw=FALSE.
#' @importFrom jsonlite fromJSON toJSON
#' @export
#' @examples
#'
#' view_schema()
#' schema <- view_schema(raw = TRUE)
#'
view_schema <- function(raw = FALSE) {
  schema_path <- system.file(
    "schema/opentsi_metadata.schema.json",
    package = "deloRean"
  )

  if (schema_path == "") {
    stop("Schema file not found. Is deloRean installed correctly?")
  }

  schema <- fromJSON(schema_path, simplifyVector = FALSE)

  if (raw) {
    return(schema)
  }

  # Pretty print header
  cat("\n")
  cat("OpenTSI Metadata Schema (v1)\n")
  cat("============================\n")
  cat("Published: https://opentsi.github.io/schema/v1/metadata.json\n\n")

  # Required fields
  cat("REQUIRED FIELDS:\n")
  for (field in schema$required) {
    prop <- schema$properties[[field]]
    desc <- if (!is.null(prop$description)) prop$description else ""
    cat(sprintf("  - %s: %s\n", field, desc))
  }
  cat("\n")

  # Optional fields
  cat("OPTIONAL FIELDS:\n")
  optional <- setdiff(names(schema$properties), schema$required)
  for (field in optional) {
    prop <- schema$properties[[field]]
    desc <- if (!is.null(prop$description)) prop$description else ""
    cat(sprintf("  - %s: %s\n", field, desc))
  }
  cat("\n")

  # Frequency enum
  cat("FREQUENCY VALUES:\n")
  freq <- schema$properties$dataset_frequency
  cat(sprintf("  %s\n", freq$description))
  cat(sprintf("  Valid: %s\n", paste(freq$enum, collapse = ", ")))
  cat("\n")

  # Multilingual text
  cat("MULTILINGUAL TEXT:\n")
  ml <- schema$definitions$multilingualText
  cat(sprintf("  %s\n", ml$description))
  cat("  Example: { \"en\": \"Title\", \"de\": \"Titel\" }\n")
  cat("\n")

  # Full JSON
  cat("FULL SCHEMA (JSON):\n")
  cat(toJSON(schema, pretty = TRUE, auto_unbox = TRUE))
  cat("\n")

  invisible(schema)
}
