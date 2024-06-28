#' Add One or More Time Series to a Version
#'
#' @param x a single R time series object. Multiple time series objects can be represented as long format data.table or tslist.
#' @param version Date
#' @param root_folder character path to the time series archive. If the archive folder repository does not exist, it will be created.
#' @importFrom gert git_add git_init git_status
#' @importFrom data.table fwrite
#' @importFrom fs file_exists dir_create
#' @export
version_add_ts <- function(x,
                           existing_version = NULL,
                           version = Sys.Date(),
                           root_folder = "../ts_archive",
                           seal = FALSE) {
    UseMethod("version_add_ts")
}


# Don't forget to load the package before running document(), 
# i.e., run document twice.
# https://stackoverflow.com/questions/61482561/whats-the-preferred-means-for-defining-an-s3-method-in-an-r-package-without-int
#' @exportS3Method opentsi::version_add_ts
version_add_ts.data.table <- function(x,
                                      existing_version = NULL,
                                      version = Sys.Date(),
                                      root_folder = "../ts_archive",
                                      seal = FALSE) {
    # init git repo if there is no git repo ####
    if (!file_exists(file.path(root_folder, ".git"))) {
        repo <- git_init(root_folder)
    } else {
        repo <- root_folder
    }

    v <- sprintf("v%s", version)
    if (version_exists(date = version, repo = repo)) {
        stop("There is already a version for this date. Please choose another
         date or remove the existing version before.")
    }

    keys <- unique(x$id)
    p <- key_to_path(keys, root_folder = root_folder)
    p_w_root <- file.path(root_folder, p)
    sapply(p_w_root, dir_create)

    by_id <- split(x, f = x$id)
    names(by_id) <- p
    lapply(names(by_id), function(x) {
        fn <- file.path(x, "series.csv")
        fwrite(by_id[[x]], file = file.path(root_folder, fn))
        git_add(files = fn, repo = repo)
    })

    state <- git_status(repo = repo)
    if (!any(state$staged)) {
        stop("Aborting because no changes were made compared to the previous version. Not creating a new version")
    }

    if (is.null(existing_version)) {
        out <- list()
        out$version <- sprintf("v%s", version)
        out$number_of_series <- length(by_id)
        out$repo <- repo
        out
    } else {
        out <- existing_version
        out$number_of_series <- out$number_of_series + length(by_id)
        out$repo <- repo
        out
    }

    if (seal) {
        version_seal(out)
    }
}


version_add_ts.tslist <- function() {

}



#' @exportS3Method opentimeseries::version_add_ts
version_add_ts.ts <- function() {

}
