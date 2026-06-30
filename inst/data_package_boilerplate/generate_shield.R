# Determines whether a dataset is active or inactive, based on the dataset
# frequency and whether the last commit is within the expected grace period.
last_commit_date <- tryCatch(
  as.Date(trimws(system(
    "git log -1 --format='%ci' -- data-raw/csv/",
    intern = TRUE
  ))),
  error = function(e) NULL
)

if (is.null(last_commit_date) || length(last_commit_date) == 0) {
  message <- "unknown"
  color   <- "lightgrey"
} else {
  meta_lines <- readLines("inst/metadata.json")
  freq_line  <- grep('"dataset_frequency"', meta_lines, value = TRUE)[1]
  freq       <- gsub('.*"dataset_frequency":\\s*"([^"]+)".*', "\\1", freq_line)

  grace_days <- switch(freq,
    "D" = 5,
    "W" = 21,
    "M" = 60,
    "Q" = 135,
    "Y" = 400,
    90
  )

  days_since <- as.numeric(Sys.Date() - last_commit_date)
  is_active  <- days_since <= grace_days
  message    <- if (is_active) "active" else "inactive"
  color      <- if (is_active) "brightgreen" else "red"
}

cat(
  sprintf(
    '{"schemaVersion":1,"label":"dataset","message":"%s","color":"%s"}\n',
    message, color
  ),
  file = "data-raw/shield.json"
)
