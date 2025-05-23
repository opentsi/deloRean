library(deloRean)

#' @importFrom deloRean is_update_needed write_data
#' @export
run_update <- function(){

  # get a boolean to check whether update run is needed.
  update_needed <- is_update_needed(
    get_publisher_last_update(),
    data_dir = ".")

  if(!update_needed){
    return(NULL)
  }

  # part of the data package,
  # data repo specific function either
  # tmp download and read
  # or API
  # but result is always an in memory long format representation
  handle_data()

  # skip for now.
  handle_meta_data()

  write_data()

  write_meta_data()

  commit_data()


}







