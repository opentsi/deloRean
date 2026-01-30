
#' This function returns a Long Format CSV of all series in the package
#' you need to declare all imports needed
#' Dont' forget to add imports to this function!
#' @importFrom opentimeseries write_open_ts
#' @export
handle_update <- function(){

  update_bool <- is_update_needed()

  if(!update_bool){
    message("No update needed, series up-to-date.")
    return(NULL)
  }

  tsx <- process_data()

  write_open_ts(tsx)


}
