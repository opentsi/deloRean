
#' This function returns a Long Format CSV of all series in the package
#' you need to declare all imports needed
#' Dont' forget to add imports to this function!
handle_update <- function(){

  update_bool <- is_update_needed()

  if(update_bool){
    dta <- handle_download()

    opentimeseries:::ke

  } else {
    message("No update needed, series up-to-date.")
    return(NULL)
  }

}
