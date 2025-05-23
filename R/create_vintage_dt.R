#' Create Time Series Versions Data Tables (Vintages)
#'
#' This functions uses a vector of release dates and a list of time series to
#'create a nested data tables that contains all time series and their release dates.
#'
#' @param release_date character date vector of release dates, will be
#' converted to POSIXct.
#' @param tsl list named list of time series.
#' @param time_chunk character time formatted as HH:MM:SS.
#' @importFrom tsbox ts_dt
#' @importFrom data.table data.table
#' @export
create_vintage_dt <- function(release_date,
                              tsl,
                              time_chunk = "23:59:59",
                              tz = Sys.getenv("DELOREAN_TZ")){
  out <- list()
  keys <- gsub("(.+)(\\.\\d{4}-\\d{2})","\\1",names(tsl))
  dt_list <- data.table(
    id = keys,
    release_date = as.POSIXct(sprintf("%s %s",release_date, time_chunk),
                              tz = tz),
    data = lapply(tsl, ts_dt)
  )
  dt_list
}
