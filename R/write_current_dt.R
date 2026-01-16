#' @importFrom fs dir_create
#' @importFrom data.table fwrite
#' @export
write_current_dt <- function(current_version_dt,
                             repo_name){
  repo_name <- paste0(repo_name, ".")
  current_version_dt$id <- gsub(repo_name, "", current_version_dt$id)
  split_list <- split(current_version_dt, f = current_version_dt$id)
  for(i in names(split_list)){
    dir_create(
      file.path("data-raw",i)
    )
    fwrite(split_list[[i]],
           file = file.path("data-raw",
                            key_to_path(i),
                            "series.csv")
    )
  }
}
