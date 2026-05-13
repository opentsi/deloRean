#' Process FSO INDPAU Data
#'
#' Fetches all time series in the ch.fso.indpau collection from the KOF
#' Time Series Database and writes each to its key.csv
#'
#' @importFrom tsdbapi read_dataset_keys set_config read_ts
#' @param key API key for the KOF Time Series Database.
#' @return Invisibly returns a character vector of output file paths.
#' @export
process_data <- function(key = key) {
  set_config(api_key = key)

  keys <- read_dataset_keys("ch.fso.indpau")
  tsl <- read_ts(keys)

  out_paths <- lapply(names(tsl), function(k) {
    ts_obj <- tsl[[k]]
    # remove prefix so it matches with current data
    k <- sub("^ch\\.fso\\.indpau\\.", "", k)
    print(k)

    output_path <- file.path("data-raw", "csv", paste0(k, ".csv"))

    ts_time <- time(ts_obj)
    freq <- frequency(ts_obj)
    values <- as.numeric(ts_obj)

    if (freq == 12) {
      years <- floor(ts_time)
      months <- round((ts_time - years) * 12) + 1
      ts_dates <- as.Date(sprintf("%d-%02d-01", years, months))
    } else {
      stop(sprintf("Unsupported frequency: %d", freq))
    }

    ts_df <- data.frame(time = ts_dates, value = values)
    write.csv(ts_df, file = output_path, row.names = FALSE, quote = FALSE)
    message(sprintf("Written: %s", output_path))
    output_path
  })

  invisible(unlist(out_paths))
}

# try it out here