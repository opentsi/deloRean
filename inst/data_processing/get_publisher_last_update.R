
get_publisher_last_update <- function(){
  # insert a function that gets the UTC publication of the
  # last available publication from your specific data provider
  # this will update always, replace this with reasonable algo
  # to determine when the provider last updated the data
  as.POSIXct(Sys.time() - 1,tz = "UTC")
}
