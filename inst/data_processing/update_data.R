library(deloRean)


get_publisher_last_update <- function(){
  # insert a function that gets the UTC publication of the
  # last available publication from your specific data provider
  # this will update always, replace this with reasonable algo
  # to determine when the provider last updated the data
  as.POSIXct(Sys.time() - 1,tz = "UTC")
}


update_needed <- is_update_needed(
  get_publisher_last_update(),
  data_dir = ".")

process_data <- function(do_update = update_needed){
  if(do_update){

    download_data

    write_update_date_to_file()
  } else {
    stop("Already up to date.")
  }
}


process_data(do_update,
             downloader = "somefunction" ,
             data_processor = "")





