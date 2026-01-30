#' Add a New Time Series Version
#'
#'
#' @param sig git signature author and timesetamp for this particlar version
#' @importFrom gert git_push git_add git_commit
#' @export
archive_update <- function(sig = git_signature("Open Time Series Initiative",
                                               "bannert@kof.ethz.ch",
                                               Sys.Date()),
                           push = FALSE){
  git_add(files = "data-raw")
  git_commit(message = "opentsi dataset version updated",
             author = sig,
             committer = sig)
  if(push){
    git_push()
  } else {
    message("committed updates but not pushed to remote")
  }
}

