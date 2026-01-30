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



