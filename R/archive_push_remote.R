#' Push Archive to GitHub Remote
#'
#' Adds a GitHub remote to a local archive repository and pushes all commits.
#' The GitHub repository must already exist (create it via GitHub web UI first).
#'
#' @param repo_path Character. Path to the local git repository.
#' @param remote_owner Character. GitHub username or organization name
#'   that owns the remote repository.
#' @param repo_name Character. Name of the GitHub repository.
#'   Defaults to the basename of the repo_path.
#' @param remote_name Character. Name for the git remote.
#'   Defaults to "origin".
#' @param protocol Character. Protocol for the remote URL.
#'   Either "ssh" (default) or "https".
#'
#' @details
#' Before calling this function, create the repository on GitHub:
#' \enumerate{
#'   \item Go to \url{https://github.com/new}
#'   \item Enter repository name (should match your archive name)
#'   \item Choose public or private
#'   \item Do NOT initialize with README, .gitignore, or license
#'   \item Click "Create repository"
#' }
#'
#' For SSH protocol, ensure your SSH keys are configured with GitHub.
#' For HTTPS, git will prompt for credentials or use stored credentials.
#'
#' @return Invisibly returns the remote URL.
#'
#' @examples
#' \dontrun{
#' # Typical workflow: first init, then push
#' archive_init("ch.seco.bfs", parent_dir = "~/opentsi")
#'
#' # Push to personal account (community contributor workflow)
#' archive_push_remote(
#'   repo_path = "~/opentsi/ch.seco.bfs",
#'   remote_owner = "my_username"
#' )
#'
#' # Push directly to opentsi (admin workflow)
#' archive_push_remote(
#'   repo_path = "~/opentsi/ch.seco.bfs",
#'   remote_owner = "opentsi"
#' )
#'
#' # Use HTTPS instead of SSH
#' archive_push_remote(
#'   repo_path = "~/opentsi/ch.seco.bfs",
#'   remote_owner = "opentsi",
#'   protocol = "https"
#' )
#' }
#'
#' @importFrom gert git_remote_add git_remote_list git_push
#' @export
archive_push_remote <- function(repo_path,
                                remote_owner,
                                repo_name = NULL,
                                remote_name = "origin",
                                protocol = c("ssh", "https")) {
  protocol <- match.arg(protocol)


  if (!dir.exists(repo_path)) {
    stop(sprintf("Directory does not exist: %s", repo_path))
  }

  if (!dir.exists(file.path(repo_path, ".git"))) {
    stop(sprintf("Not a git repository: %s", repo_path))
  }

  if (is.null(repo_name)) {
    repo_name <- basename(normalizePath(repo_path))
  }

  existing_remotes <- git_remote_list(repo = repo_path)
  if (remote_name %in% existing_remotes$name) {
    stop(sprintf(
      "Remote '%s' already exists. Remove it first with git_remote_remove() or use a different remote_name.",
      remote_name
    ))
  }

  if (protocol == "ssh") {
    remote_url <- sprintf("git@github.com:%s/%s.git", remote_owner, repo_name)
  } else {
    remote_url <- sprintf("https://github.com/%s/%s.git", remote_owner, repo_name)
  }

  message(sprintf("Adding remote '%s' -> %s", remote_name, remote_url))
  git_remote_add(
    name = remote_name,
    url = remote_url,
    repo = repo_path
  )

  message("Pushing to remote...")
  git_push(
    remote = remote_name,
    set_upstream = TRUE,
    repo = repo_path
  )

  message(sprintf("Successfully pushed to https://github.com/%s/%s", remote_owner, repo_name))

  invisible(remote_url)
}
