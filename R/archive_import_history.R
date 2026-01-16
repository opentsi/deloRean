#' Import Full History of a Dataset from History Data.Table
#'
#' @param history_dt data.table with nested cells, contains key, release_date
#' and data in long format.
#' @param repository_path character path to local repository
#' @importFrom data.table fwrite
#' @importFrom gert git_signature git_add git_commit
#' @export
archive_import_history <- function(history_dt,
                                repository_path){
  path_chunk <- file.path(repository_path, "data-raw")
  uk <- unique(history_dt$id)
  keys <- sprintf("%s.%s",
                  sub(".*[\\\\/]", "", repository_path),
                  uk)
  ukp <- key_to_path(uk)
  paths <- file.path(path_chunk, ukp)
  lapply(paths, dir.create, recursive = TRUE, showWarnings = FALSE)

  # write key index before the actual data, so it gets committed with
  # the below commit statement.
  if(file.exists(
    file.path(repository_path, "data-raw", "index.csv")
  )) {
    stop("Index already exists. Cannot import full history. Consider initiating a new dataset or use archive_register_ts to add new time series to an existing dataset.")
  } else {
    fwrite(list(ts_key = keys),
           file = file.path(repository_path, "data-raw", "index.csv"))
  }

  u <- unique(history_dt$release_date)
  for(rd in u){
    sig <- git_signature("Open Time Series Initiative",
                               "bannert@kof.ethz.ch",
                               rd)
    rd_subset <- history_dt[release_date == rd]

    for(i in 1:nrow(rd_subset)){
      d <- rd_subset[i,]
      fwrite(d$data[[1]],
             file = file.path(path_chunk,
                              key_to_path(d$id),
                              "series.csv")
      )
    }
    # Putting the git commit outside the of the inner loop
    # saves a commit and commits all files that belong
    # to the same data release at the same time.
    # otherwise we get a commit for each file..
    git_add(files = "data-raw",
                  repo = repository_path)
    git_commit(message = "opentsi full history init",
                     author = sig,
                     committer = sig,
                     repo = repository_path)
  }
}

