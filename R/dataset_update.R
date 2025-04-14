#' Handle Regular Updates of Dataset
#'
#' opentsi archives use git to manage versioned time series. Once
#' a dataset archive is initialized and the full history of dataset is imported,
#' datasets need to be updated on a regular basis. This dataset_update function
#' is designed to do just that. It is meant to run in a batch process and
#' append to the next iteration of the time series in a dataset to the history.
#'
#' @param tsx object containing time series represented in either ts, tslist,
#' list of time series.
#' @export
dataset_update <- function(tsx,
                           repo,
                           repo_parent_dir = ".",
                           owner = "opentsi",
                           release_date_time = NULL,
                           remote_provider = "https://github.com",
                           clean_up_local = TRUE,
                           local_only = FALSE){
  UseMethod("dataset_update")
}



dataset_update.tslist <- function(tsx,
                                  repo,
                                  repo_parent_dir = ".",
                                  owner = "opentsi",
                                  release_date_time = NULL,
                                  remote_provider = "https://github.com",
                                  clean_up_local = TRUE,
                                  local_only = FALSE){
  class(tsx) <- "list"
  dataset_update(tsx,
                 repo = repo,
                 remote_provider = remote_provider,
                 local_only = local_only)
}

dataset_update.data.table <- function(tsx,
                                      repo,
                                      repo_parent_dir = ".",
                                      owner = "opentsi",
                                      release_date_time = NULL,
                                      remote_provider = "https://github.com",
                                      clean_up_local = TRUE,
                                      local_only = FALSE){
  ll <- split(tsx, f = tsx$id)
  dataset_update(tsx = ll,
                 repo = repo,
                 owner = "opentsi",
                 remote_provider = remote_provider,
                 local_only = local_only)

}


dataset_update.list <- function(tsx,
                                repo,
                                repo_parent_dir = ".",
                                owner = "opentsi",
                                release_date_time = NULL,
                                remote_provider = "https://github.com",
                                clean_up_local = TRUE,
                                local_only = FALSE){
  prev_wd <- getwd()
  repo_path <- file.path(repo_parent_dir, repo)

  if(!local_only){
    if(grepl("git@", remote_provider)){
      remote_path <- sprintf("%s%s/%s.git",remote_provider, owner, repo)
    } else {
      remote_path <- file.path(remote_provider, owner, repo)
    }

    gert::git_clone(remote_path,
                    repo_path,
                    ssh_key = Sys.getenv("DELOREAN_SSH_KEY"))
  }

  setwd(repo_path)
  input_keys <- sort(names(tsx))

  # extract repo name from DESCRIPTIONs
  # to find correct path
  desc_file <- desc::desc(file.path(repo_path,"DESCRIPTION"))
  repo_name <- desc_file$get("Package")
  f_ik <- sprintf("%s.%s",repo_name, input_keys)
  idx <- fread(file.path(repo_path,"data-raw", "index.csv"))$ts_key

  # if keys not in official index of the dataset,
  # stop and ask whether you want to add a news series...
  # because this leads to an history altering
  # scenario which should not be handled by a standard update.
  # (all commits need to include the new series in such a case not
  # just the commit that brings in the new series first.)
  if(!all.equal(sort(f_ik), sort(idx))){
    # TODO: echo time series that are new.
    stop("Input time series do not match registered time series for this dataset. Would you like to register a new time series to be tracked in this dataset repo?")
  }


  out <- sapply(names(tsx), function(x){
    data_path <- file.path(repo_path,"data-raw",x,"series.csv")
    fwrite(tsx[[x]], file = data_path)
  })

  if(!all(sapply(out, is.null))){
    message("One or more time series could not be written properly.")
  }

  commit_by_date(repo = NULL,
                 date_time = release_date_time,
                 tz = NULL,
                 author = NULL,
                 email = NULL)

  if(!local_only){
    gert::git_push()
  }

  if(clean_up_local){
    fs::dir_delete(repo_path)
  }

}
