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



#' Create Time Series Versions Data Tables (Vintages)
#'
#' This functions uses a vector of release dates and a list of time series to
#'create a nested data tables that contains all time series and their release dates.
#'
#' @param release_date character date vector of release dates, will be
#' converted to POSIXct.
#' @param tsl list named list of time series.
#' @param time_chunk character time formatted as HH:MM:SS.
#' @importFrom tsbox ts_dt
#' @export
create_vintage_dt <- function(release_date,
                            tsl,
                            time_chunk = "23:59:59",
                            tz = Sys.getenv("DELOREAN_TZ")){
  out <- list()
  keys <- gsub("(.+)(\\.\\d{4}-\\d{2})","\\1",names(tsl))
  dt_list <- data.table(
    id = keys,
    release_date = as.POSIXct(sprintf("%s %s",release_date, time_chunk),
                              tz = tz),
    data = lapply(tsl, ts_dt)
  )
  dt_list
}

#' Register Commit with Specified Date in the Commit Signature
#'
#' This helper functions is typically not called directly. It helps
#' to organize versions of entire datasets by date.
#'
#' @param repo character repository
#' @param date_time POSIXct of the time
#' @param tz character timezone. Defaults to UTC.
#' @param author character commit author, will appear in the commit signature.
#' Will use env vars when set to NULL.
#' @param email character commit author email, will appear in the commit signature
#' Will use env vars when set to NULL.
#' @importFrom gert git_signature git_commit git_add
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

  sig <- git_signature(name = author,
                             email = email,
                             time = sig_time)

  # use working directory if there is no
  # explicit path spec
  if(is.null(repo)){
    git_add(files = "data-raw")
    git_commit(message = "opentsi release",
                     author = sig,
                     committer = sig,
                     repo = ".")
  } else {
    git_add(files = "data-raw",
                  repo = repo)
    git_commit(message = "opentsi release",
                     author = sig,
                     committer = sig,
                     repo = repo)
  }


}

#' Set Default deloRean Environment Variables
#'
#' Set environment variables for timezone, author, author email and SSH
#' key location
#'
#' @export
set_delorean_env_vars <- function(){
  Sys.setenv("DELOREAN_TZ" = "UTC")
  Sys.setenv("DELOREAN_EMAIL" = "bannert@kof.ethz.ch")
  Sys.setenv("DELOREAN_AUTHOR" = "Open Time Series Initiative")
  Sys.setenv("DELOREAN_SSH_KEY" = "~/.ssh/id_rsa")
}


write_update_date_to_file <- function(dt, tz = "UTC",
                                      data_dir = "data-raw"){
  fn <- "LAST_UPDATE"
  pdt <- as.POSIXct(dt, tz = tz)
  fcon <- file(file.path(data_dir, fn))
  writeLines(as.character(pdt), con = fcon)
}







