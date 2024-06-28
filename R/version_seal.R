#' Finalize Version of a Set of Time Series
#'
#' This function commits a version to an archive and tags it accordingly with a
#' date. The opentimeseries package is designed to store versions as high as daily frequency.
#' higher frequency require workarounds
#'
#' @importFrom gert git_commit git_tag_create
#' @export
version_seal <- function(v_obj) {
    msg <- "version %s containing %d time series stored"
    git_commit(repo = v_obj$repo,
        message = sprintf(
            msg,
            v_obj$version,
            v_obj$number_of_series
        )
    )
    git_tag_create(name = v_obj$version, repo = v_obj$repo,
        message = v_obj$version)
}
