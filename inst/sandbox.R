# TODO:
# sandbox to R functions.


library(kofdata)
library(data.table)
library(tsbox)
library(devtools)
load_all()

archive_init("ch.kof.globalbaro", "~/repositories/opentsi/")

Sys.setenv("DELOREAN_TZ" = "UTC")
Sys.setenv("DELOREAN_EMAIL" = "bannert@kof.ethz.ch")
Sys.setenv("DELOREAN_AUTHOR" = "Open Time Series Initiative")
Sys.setenv("DELOREAN_SSH_KEY" = "~/.ssh/id_rsa")



global <- kofdata::get_collection("globalbaro_vintages")
names(global) <- gsub("globalbaro_","",names(global))
names(global) <- sub("_", "\\.", names(global))
class(global) <- c(class(global), "tslist")

release_dates <- rep(seq(as.Date("2020-01-10"),
                     by = "1 month",
                     length.out = length(global)/2),2)


create_vintages <- function(release_date, tsl){
  out <- list()
  keys <- gsub("(.+)(\\.\\d{4}-\\d{2})","\\1",names(tsl))
  dt_list <- data.table(
    id = keys,
    release_date = as.POSIXct(sprintf("%s 23:59:59",release_date),
                              tz = "UTC"),
    data = lapply(tsl, tsbox::ts_dt)
  )
  dt_list
}

dv <- create_vintages(release_dates, global)


# commit full history

commit_full_history <- function(history_dt,
                                repository_path){
  path_chunk <- file.path(repository_path, "data-raw")
  uk <- unique(history_dt$id)
  keys <- sprintf("%s.%s",
          sub(".*[\\\\/]", "", repository_path),
          uk)
  ukp <- key_to_path(uk)
  paths <- file.path(path_chunk, ukp)
  lapply(paths, dir.create, recursive = TRUE, showWarnings = FALSE)

  # write key index before the actually data, so it gets committed with
  # the below commit statement.
  fwrite(list(ts_key = keys),
         file = file.path(repository_path, "data-raw", "index.csv"),
         append = TRUE)

  u <- unique(history_dt$release_date)
  for(rd in u){
    sig <- gert::git_signature("Open Time Series Initiative",
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
    gert::git_add(files = "data-raw",
                  repo = repository_path)
    gert::git_commit(message = "opentsi full history init",
                     author = sig,
                     committer = sig,
                     repo = repository_path)
  }
}



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


# Ah wait before we can do step IV we need to 3, i.e., create a remote repo.
# possible can do that manually for now...

# git remote add origin git@github.com:opentsi/ch.kof.globalbaro.git
# git branch -M main
# git push -u origin main



# let's create dummy update release.
toy <- list()
toy$leading <- global$`leading.2025-03` * 3
toy$coincident <- global$`leading.2025-03` * 5

toy_dt <- lapply(toy, tsbox::ts_dt)


# this function is always local thinking
# either on your computer or in a docker container inside a GHA
#' @param tsx object containing time series
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
  dataset_update(tsx, repo = repo,
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


dv1 <- dv[1:3,]
dv2 <- dv[66,]

dv3 <- dv[67,]

commit_full_history(dv1,
                    repository_path = "~/repositories/opentsi/ch.kof.globalbaro")

commit_full_history(dv2,
                    repository_path = "~/repositories/opentsi/ch.kof.globalbaro")

commit_full_history(dv3,
                    repository_path = "~/repositories/opentsi/ch.kof.globalbaro")




## !! append = TRUE for index.csv, may not be right.
## gotta figure out not to get dupes


# squashing older commits:
# git checkout -b temp <OLDER COMMIT>
# git cherry-pick <NEXT COMMIT>





# git checkout -b temp
# then add stuff like run dv2 full hist + commit
# then rebase
# git rebase --onto temp 0175301f999d7ef2f9c9f1f7d39b404a167068e9 main
# ends up on main, delete temp afterwards.

# next step: figure out additional vintages
# after the first registration of the series



dataset_update(tsx = toy_dt,
               repo = "ch.kof.globalbaro",
               repo_parent_dir = "~/repositories/opentsi",
               owner = "opentsi",
               remote_provider = "git@github.com:")




# Yay updates work now !!
# next step
# move functions from sandbox to R folder
#
# (check clone options to get smaller local repo
# could also postpone this, since GHA does a depth=1 by default)
# how to add time series alter history -> see good discussion with deep Seek R1




dv <- create_vintages(release_dates, global)

debug(commit_full_history)


xx <- fread("~/repositories/opentsi/ch.kof.globalbaro/data-raw/coincident/series.csv")
yy <- fread("~/repositories/opentsi/ch.kof.globalbaro/data-raw/coincident/series.csv")


tsbox::ts_plot(xx)
tsbox::ts_plot(yy)


# TODO understand commiting a single commit first and then rebasing it so some
# other place in history... also: there merge conflicts with existing series..



#' Add New Time Series to an Existing Dataset (History Altering)
#'
#' You can add new time series and all their versions (vintages) to an already
#' existing dataset, but you need to be aware of a few things:
#'
#' Adding a version of a time series which was created before the
#' current version is not as innocent as it looks. You are altering the
#' history of your dataset by pretending this early version and all later
#' versions of said time series always existed.
#' Hence this functions adds the new series to from its first appearance on
#' to every commit (dataset version) that follows.
#'
#' Second, keep in my mind that within a dataset all time series need to have
#' the same release date. If the release differs from the rest of the dataset
#' rather start a new dataset using archive_init().
#'
#'
#'
#'
archive_register_ts <- function(tsx,
                                repo,
                                repo_parent_dir = ".",
                                owner = "opentsi",
                                release_date_time = NULL,
                                remote_provider = "https://github.com",
                                clean_up_local = TRUE,
                                local_only = FALSE){
  repo_path <- file.path(repo_parent_dir, repo)

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

  desc_file <- desc::desc(file.path(repo_path,"DESCRIPTION"))
  repo_name <- desc_file$get("Package")
  f_ik <- sprintf("%s.%s",repo_name, input_keys)
  idx <- fread(file.path(repo_path,"data-raw", "index.csv"))$ts_key

  # this is the exact opposite of the update check.
  # stop when the key already exists.
  if(any(duplicated(c(f_ik,idx)))){
    # TODO: echo time series that are new.
    stop("One or more time series you're trying to register already exist.")
  }


  # do date based commit and then rebase

}




# This might be the next step:

# library(gert)
#
# # File changes (e.g., staging all modified files)
# git_add(".")
#
# # Commit with a retroactive date
# git_commit(
#   message = "Your commit message",
#   author = git_signature(name = "Your Name", email = "you@example.com", time = as.POSIXct("2023-03-15 12:00:00", tz = "UTC")),
#   committer = git_signature(name = "Your Name", email = "you@example.com", time = as.POSIXct("2023-03-15 12:00:00", tz = "UTC"))
# )



