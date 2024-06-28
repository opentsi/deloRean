key_to_path <- function(key, root_folder = "../ts_archive", remote = FALSE) {
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
