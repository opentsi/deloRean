key_to_path <- function(key,
                        root_folder = "../ts_archive",
                        remote = FALSE) {
    l <- strsplit(key, "\\.")
    sapply(l, function(x) {
        if (remote) {
            o <- do.call(file.path, as.list(x))
            file.path(o, "series.csv")
        } else {
            do.call(file.path, as.list(x))
        }
    })
}

# replace with git_tag_list(,repo)
#' @importFrom gert git_tag_list
version_exists <- function(date = Sys.Date(), repo) {
    current_version <- sprintf("v%s", date)
    vs <- names(git_tag_list(repo))
    any(current_version %in% vs)
}



#' Create Vintages From a Named List of Time Series
#' @importFrom tsbox ts_dt
#' @export
create_vintages <- function(release_date,
                            tsl,
                            time_chunk = "23:59:59",
                            tz = "UTC"){
  out <- list()
  keys <- gsub("(.+)(\\.\\d{4}-\\d{2})","\\1",names(tsl))
  dt_list <- data.table(
    id = keys,
    release_date = as.POSIXct(sprintf("%s %s",release_date, time_chunk),
                              tz = tz),
    data = lapply(tsl, tsbox::ts_dt)
  )
  dt_list
}

#' Commit a Contribution
commit_by_date <- function(repo = NULL,
                           date_time = Sys.time(),
                           tz = "UTC",
                           author = "Open Time Series Initiative",
                           email = "bannert@kof.ethz.ch"){
  # if you want to use ENV VARS, simply set params to NULL.
  if(is.null(tz)) tz <- Sys.getenv("DELOREAN_TZ")
  if(is.null(author)) author <- Sys.getenv("DELOREAN_AUTHOR")
  if(is.null(email)) email <- Sys.getenv("DELOREAN_EMAIL")

  if(!inherits(x = date_time, "POSIXct")){
    sig_time <- as.POSIXct(date_time, tz = tz)
  } else {
    sig_time <- date_time
  }

  sig <- gert::git_signature(name = author,
                             email = email,
                             time = sig_time)

  # use working directory if there is no
  # explicit path spec
  if(is.null(repo)){
    gert::git_add(files = "data-raw")
    gert::git_commit(message = "opentsi release",
                     author = sig,
                     committer = sig,
                     repo = ".")
  } else {
    gert::git_add(files = "data-raw",
                  repo = repo)
    gert::git_commit(message = "opentsi release",
                     author = sig,
                     committer = sig,
                     repo = repo)
  }


}

#' Set Environment Variables as Suggested by de
set_env_vars <- function(){
  Sys.setenv("DELOREAN_TZ" = "UTC")
  Sys.setenv("DELOREAN_EMAIL" = "bannert@kof.ethz.ch")
  Sys.setenv("DELOREAN_AUTHOR" = "Open Time Series Initiative")
  Sys.setenv("DELOREAN_SSH_KEY" = "~/.ssh/id_rsa")

}





