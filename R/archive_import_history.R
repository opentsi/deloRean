#' Import Full History of a Dataset from History Data.Table
#'
#' @param history_dt data.table with nested cells, contains key, release_date
#' and data in long format.
#' @param repository_path character path to local repository
#' @importFrom data.table fwrite
#' @importFrom gert git_signature git_add git_commit
#' @export
# TODO catalog function, metadata
archive_import_history <- function(history_dt,
                                repository_path){
  path_chunk <- file.path(repository_path, "data-raw/csv")
  dataset_name <- sub(".*[\\\\/]", "", repository_path)
  uk <- unique(history_dt$id)
  keys <- sprintf("%s.%s", dataset_name, uk)

  # write key index before the actual data, so it gets committed with
  # the below commit statement.
  if(file.exists(
    file.path(repository_path, "data-raw/csv", "index.csv")
  )) {
    stop("Index already exists. Cannot import full history. Consider initiating a new dataset or use archive_register_ts to add new time series to an existing dataset.")
  } else {
    fwrite(list(ts_key = keys),
           file = file.path(repository_path, "data-raw", "index.csv"))
  }

  u <- unique(history_dt$release_date)

  # fill index.md sections: hierarchy + series table + vintage dates
  index_md_path <- file.path(repository_path, "data-raw", "index.md")

  series_info <- lapply(uk, function(id_val) {
    rows <- history_dt[id == id_val]
    latest_data <- rows[which.max(release_date)]$data[[1]]
    list(
      id         = id_val,
      n_vintages = nrow(rows),
      date_min   = format(min(latest_data$time), "%Y-%m-%d"),
      date_max   = format(max(latest_data$time), "%Y-%m-%d")
    )
  })

  table_rows <- vapply(series_info, function(s) {
    sprintf("| `%s` | %d | %s \u2013 %s | [CSV](csv/%s.csv) |",
            s$id, s$n_vintages, s$date_min, s$date_max, s$id)
  }, "")

  update_index_section(index_md_path, "Hierarchy", build_hierarchy(uk))
  update_index_section(index_md_path, "Series",
    c("| Key | Vintages | Date Range | Link |",
      "|-----|----------|------------|------|",
      table_rows))
  update_index_section(index_md_path, "Vintage Dates",
    sprintf("- %s", format(sort(u), "%Y-%m-%d")))

  for(rd in u){
    sig <- git_signature("Open Time Series Initiative",
                               "bannert@kof.ethz.ch",
                               rd)
    rd_subset <- history_dt[release_date == rd]

    for(i in 1:nrow(rd_subset)){
      d <- rd_subset[i,]
      fwrite(d$data[[1]],
             file = file.path(path_chunk, paste0(d$id, ".csv"))
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

# before
# setwd("/Users/minna/KOF_Lab/opentsi/deloRean")
# devtools::load_all()

# # testing 
# debugonce(archive_import_history)
# setwd("/Users/minna/KOF_Lab/opentsi/ch.kof.globalbaro")

# archive_init("ch.kof.globalbaro", "~/KOF_Lab/opentsi")
# library(kofdata)
# library(data.table)
# library(tsbox)

# global <- get_collection("globalbaro_vintages")
# names(global) <- gsub("globalbaro_","",names(global))
# names(global) <- sub("_", "\\.", names(global))
# class(global) <- c(class(global), "tslist")
# release_dates <- rep(seq(as.Date("2020-01-10"),
#                          by = "1 month",
#                          length.out = length(global)/2),2)
# vintages_dt <- create_vintage_dt(release_dates, global)
# head(vintages_dt)

# ## Example Step 3, Import History to Archive
# # debugonce(archive_import_history)
# archive_import_history(vintages_dt, repository_path = "~/KOF_Lab/opentsi/ch.kof.globalbaro")

# # source("/Users/minna/KOF_Lab/opentsi/deloRean/R/archive_import_history.R")
