#' Register a Time Series Dataset to an Archive
#'
#' Add a new dataset, potentially containing many time series and their versions
#' to an existing provider archive. Within a dataset all time series need to
#' have the same release date. If release dates diverge across time series,
#' this is an indictor that these series should be stored in a separate
#' dataset which may very well be registered at the same data provider archive.
#'
archive_register_dataset <- function(dataset_key,
                                     archive_root = "ch.kof",
                                     tsl,
                                     organization = "opentsi",
                                     origin = "github"){
  if(origin == "local"){
    fs::dir_create(file.path(archive_root, dataset_key))
  }





}








#'
#' #' @param org character name of the GitHub Org to host the remote repositories
#' #' @param provider_archive character provider specific archive repository name.
#' #' @param releases list nested object that contains a release POSIXct datetime
#' #' and list of time series.
#' #' @export
#' archive_register_dataset <- function(org = "opentsi",
#'                                 provider_archive = "ch.kof",
#'                                 releases){
#'
#' }
#'
#'
#' #' @param ... list of time series
#' #' @param release_datetime POSIXct vector of points in time for which we
#' #' would like to release time series.
#' #' @export
#' create_history <- function(...,
#'                            release_datetime){
#'   list_of_tsl <- list(...)
#'   stopifnot(length(list_of_tsl) == length(release_datetime))
#'   list(
#'     release = release_datetime,
#'     tsl = list_of_tsl
#'   )
#' }
#'
#'
#' create_history(tsl, tsl, release_datetime = c(
#'   as.POSIXct(Sys.time()),
#'   as.POSIXct(Sys.time() - 1000000)
#' ))
#'
#'
#'
#' # tsl <- kofdata::get_time_series("ch.kof.barometer")
#'
#'
#' rel <- list(
#'   list(
#'     release = as.POSIXct(Sys.time()),
#'     tsl = tsl
#'   ),
#'   list(
#'     release = as.POSIXct(Sys.time() - 1000000),
#'     tsl = tsl
#'   )
#' )
#'
#'
#' #
#' # lapply(rel, "[[", "release")
#' # lapply(rel, "[[", "tsl")
