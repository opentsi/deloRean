library(kofdata)
library(data.table)
library(tsbox)
library(devtools)
load_all()

archive_init("ch.kof.globalbaro", "~/repositories/opentsi/")


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
  uk <- key_to_path(unique(history_dt$id))
  paths <- file.path(path_chunk, uk)
  lapply(paths, dir.create, recursive = TRUE, showWarnings = FALSE)

  u <- unique(history_dt$release_date)
  for(rd in u){
    sig <- gert::git_signature("Open Time Series Iniative",
                               "bannert@kof.ethz.ch",
                               rd)
    rd_subset <- history_dt[release_date == rd]

    for(i in 1:nrow(rd_subset)){
      d <- rd_subset[i,]
      write.csv(d$data[[1]], file = file.path(path_chunk,
                                            key_to_path(d$id),
                                            "series.csv"),
                row.names = FALSE)
    }
    # Putting the git commit outside the of the inner loop
    # saves a commit and commits all files that belong
    # to the same data release at the same time.
    # otherwise we get a commit for each file..
    gert::git_add(files = "data-raw",
                  repo = repository_path)
    gert::git_commit(message = "opentsi release",
                     author = sig,
                     committer = sig,
                     repo = repository_path)
  }
}


dv <- create_vintages(release_dates, global)

debug(commit_full_history)
commit_full_history(dv,
                    repository_path = "~/repositories/opentsi/ch.kof.globalbaro")


xx <- fread("~/repositories/opentsi/ch.kof.globalbaro/data-raw/coincident/series.csv")
yy <- fread("~/repositories/opentsi/ch.kof.globalbaro/data-raw/coincident/series.csv")


tsbox::ts_plot(xx)
tsbox::ts_plot(yy)








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



