#' Get Last Update From a Particular Publisher
#'
#' It's recommended to not export this function, because every opentsi data package
#' should have such a function. Not exporting avoids name collisions across packages.
#'
#' @param tz character time zone, defaults to UTC.
get_publisher_last_update <- function(tz = "UTC"){
  # insert a function that gets the UTC publication of the
  # last available publication from your specific data provider
  # this will update always, replace this with reasonable algo
  # to determine when the provider last updated the data
  as.POSIXct(Sys.time() - 1, tz = tz)
}
