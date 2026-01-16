# TODO understand committing a single commit first and then rebasing it so some
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

