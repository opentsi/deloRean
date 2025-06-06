library(deloRean)

#' @importFrom deloRean is_update_needed write_current_dt
#' @importFrom desc desc_get
#' @export
run_update <- function(){

  # get a boolean to check whether update run is needed.
  update_needed <- is_update_needed(
    get_publisher_last_update(),
    data_dir = ".")

  if(!update_needed){
    return(NULL)
  }

  pkg_name <- desc_get("Package")

  # part of the data package,
  # data repo specific function either
  # tmp download and read
  # or API
  # but result is always an in memory long format representation
  current_version <- handle_data()

  # skip for now.
  handle_meta_data()

  write_current_dt(current_version_dt = current_version,
                   repo_name = pkg_name)

  write_meta_data()

  archive_update()
}







