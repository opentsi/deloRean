#' Resolve Metadata to Key-Label Mappings
#'
#' Takes dataset metadata and generates all available time series keys
#' with their human-readable labels by traversing the hierarchy.
#'
#' @param meta Either a list (parsed metadata) or a path to a YAML file.
#' @param lang Language code for labels (default "en").
#' @return A data.frame with columns: key, label_full, label_short.
#' @importFrom yaml read_yaml
#' @export
#' @examples
#' \dontrun{
#' resolve_meta("metadata.yaml")
#' resolve_meta("metadata.yaml", lang = "de")
#' }
resolve_meta <- function(meta, lang = "en") {

  if (is.character(meta) && length(meta) == 1 && file.exists(meta)) {
    meta <- read_yaml(meta)
  }

  if (!is.list(meta)) {
    stop("meta must be a list or path to a YAML file")
  }

  # Check required identity fields
  for (field in c("country", "provider", "dataset")) {
    if (is.null(meta[[field]]) || meta[[field]] == "") {
      stop(sprintf("Missing required field '%s' in metadata", field))
    }
  }

  # Get all paths through the hierarchy
  paths <- traverse_hierarchy(meta$hierarchy)

  if (length(paths) == 0) {
    message("No hierarchy defined in metadata")
    return(data.frame(
      key = character(),
      label_full = character(),
      label_short = character(),
      stringsAsFactors = FALSE
    ))
  }

  # Build keys and labels for each path
  results <- lapply(paths, function(path) {
    build_key_labels(
      path = path,
      meta = meta,
      lang = lang
    )
  })

  do.call(rbind, results)
}


#' Traverse Hierarchy to Get All Paths
#'
#' Recursively traverses the hierarchy object and returns all
#' leaf paths as character vectors.
#'
#' @param hierarchy The hierarchy object (nested list).
#' @param current_path Current path being built (used in recursion).
#' @return List of character vectors, each representing a path to a leaf.
#' @keywords internal
traverse_hierarchy <- function(hierarchy, current_path = character()) {

  if (!is.list(hierarchy) || length(hierarchy) == 0) {
    # Leaf node - return the current path
    if (length(current_path) > 0) {
      return(list(current_path))
    }
    return(list())
  }

  paths <- list()

  for (key in names(hierarchy)) {
    new_path <- c(current_path, key)
    child <- hierarchy[[key]]

    if (is.list(child) && length(child) > 0) {
      # Has children - recurse
      child_paths <- traverse_hierarchy(child, new_path)
      paths <- c(paths, child_paths)
    } else {
      # Leaf node
      paths <- c(paths, list(new_path))
    }
  }

  paths
}


#' Build Key and Labels for a Path
#'
#' Constructs the full key and human-readable labels for a hierarchy path.
#'
#' @param path Character vector of hierarchy segments.
#' @param meta Full metadata list (must contain country, provider, dataset).
#' @param lang Language code.
#' @return Single-row data.frame with key, label_full, label_short.
#' @keywords internal
build_key_labels <- function(path, meta, lang) {

  # Build the full key
  key <- paste(c(meta$country, meta$provider, meta$dataset, path), collapse = ".")

  # Get dataset title
  dataset_title <- get_label(meta$title, lang)

  # Get source name

  source_name <- get_label(meta$source_name, lang)

  # Get labels for each path segment
  path_labels <- vapply(seq_along(path), function(i) {
    segment <- path[i]

    # Try to find label in meta$labels
    # First check if this segment is a dimension name
    if (i == 1 && !is.null(meta$labels$dimnames[[segment]])) {
      # This is a dimension, look for value labels
      dim_name <- segment
      if (length(path) > i) {
        # Get label for the value
        value <- path[i + 1]
        # Skip dimension name, we want value labels
      }
    }

    # Look up the segment in labels
    label <- lookup_segment_label(segment, meta$labels, lang)
    if (is.null(label) || label == "") {
      label <- segment
    }
    label
  }, character(1))

  # Get units if available
  unit_label <- ""
  if (!is.null(meta$units)) {
    if (!is.null(meta$units$all)) {
      unit_label <- get_label(meta$units$all, lang)
    } else {
      # Try to find unit matching last path segment
      last_seg <- path[length(path)]
      if (!is.null(meta$units[[last_seg]])) {
        unit_label <- get_label(meta$units[[last_seg]], lang)
      }
    }
  }

  # Build full label
  label_parts <- c(source_name, dataset_title, path_labels)
  if (unit_label != "") {
    label_parts <- c(label_parts, unit_label)
  }
  label_full <- paste(label_parts, collapse = ", ")

  # Build short label (dataset + last path segment)
  label_short <- paste(dataset_title, path_labels[length(path_labels)], sep = ", ")

  data.frame(
    key = key,
    label_full = label_full,
    label_short = label_short,
    stringsAsFactors = FALSE
  )
}


#' Get Label from Multilingual Object
#'
#' Extracts label for specified language, falls back to English.
#'
#' @param obj Multilingual text object.
#' @param lang Language code.
#' @return Character string.
#' @keywords internal
get_label <- function(obj, lang = "en") {

  if (is.null(obj)) return("")
  if (!is.list(obj)) return(as.character(obj))

  if (!is.null(obj[[lang]]) && obj[[lang]] != "") {
    return(obj[[lang]])
  }
  if (!is.null(obj[["en"]]) && obj[["en"]] != "") {
    return(obj[["en"]])
  }
  # Return first available
  vals <- unlist(obj)
  if (length(vals) > 0) return(vals[1])
  ""
}


#' Lookup Segment Label in Labels Object
#'
#' Searches the labels object for a matching segment label.
#'
#' @param segment The segment to look up.
#' @param labels The labels object from metadata.
#' @param lang Language code.
#' @return Character string or NULL.
#' @keywords internal
lookup_segment_label <- function(segment, labels, lang) {

  if (is.null(labels)) return(NULL)

  # Search through all label groups

  for (group_name in names(labels)) {
    group <- labels[[group_name]]
    if (is.list(group) && segment %in% names(group)) {
      return(get_label(group[[segment]], lang))
    }
  }

  NULL
}


#' Print Resolved Metadata
#'
#' Prints resolved key-label mappings in a readable format.
#'
#' @param resolved Output from resolve_meta().
#' @param format Either "full" or "short" labels.
#' @return Invisibly returns the input.
#' @export
#' @examples
#' \dontrun{
#' meta <- yaml::read_yaml("metadata.yaml")
#' resolved <- resolve_meta(meta, "ch", "adecco", "sjmi")
#' print_resolved(resolved)
#' print_resolved(resolved, format = "short")
#' }
print_resolved <- function(resolved, format = c("full", "short")) {

  format <- match.arg(format)

  cat("\n")
  cat("OpenTSI Key Mappings\n")
  cat("====================\n\n")

  for (i in seq_len(nrow(resolved))) {
    row <- resolved[i, ]
    label <- if (format == "full") row$label_full else row$label_short
    cat(sprintf("%s\n  -> %s\n\n", row$key, label))
  }

  invisible(resolved)
}
