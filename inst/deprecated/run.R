#' Run Data Update Inside a Data Package Structure
#'
#' This wrapper runs all templated functions of a data package in standardized
#' fashion. This way bootstrapped data packages return standard output which is
#' compliant with opentimeseries. In order for this function to work properly
#' dataset specific functions need to be written by the enduser.
#'
#'
#' @param update_processor function that returns a POSIXct date
#' with timezone UTC to represent the date of the last time the publisher
#' updated the data.
#' @param download_processor function to obtain data from a file download,
#' database or API.
#' @param data_processor function to turn downloaded artefact into long format
#' csv
#' @param meta_data_processor function to turn downloaded artefact meta data.
#' csv
#' @param data_dir character relative data path reference.
#' @export
run <- function(update_processor,
                download_processor,
                data_processor,
                metadata_processor,
                data_dir = "data-raw"){

  update_needed <- is_update_needed(
    update_processor(data_dir),
    data_dir = data_dir
  )

  if(!update_needed){
    return(NULL)
  } else {

    # output object is a list
    out <- list()
    out#status
    out$lfd <- data_processor()
    out$meta





    write_meta_data(out)

    write_data(out)



  }


}
