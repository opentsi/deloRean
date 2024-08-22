# Initialize a New Time Series Archive
#' @importFrom fs dir_create file_touch
#' @export
archive_init <- function(archive_name,
                         parent_dir = NULL,
                         remote_owner = "opentsi",
                         basic_readme = TRUE,
                         rproj = TRUE) {
  if (is.null(parent_dir)) {
    archive_path <- file.path(getwd(), archive_name)
  } else {
    archive_path <- file.path(parent_dir, archive_name)
  }
  dir_create(archive_path)

  repo <- git_init(archive_path)

  # correctly adds readme for the first but then prints error
  if (basic_readme) {
    if (file.exists(file.path(repo, "README.md"))) {
      print("README.md already exists in the archive directory, and won't be overwritten.")
    } else {
      # could also use: use_this::use_readme_md()
      readme_loc <- file.path(repo, "README.md")
      file_touch(readme_loc)
      writeLines(c(
        sprintf("# Open Time Series Archive for %s.\n\n", archive_name),
        "## Data Source: \n\n",
        "## Data Description: \n\n",
        "## Maintainer & Contact\n\n"
      ), readme_loc)
      git_add(files = "README.md", repo = repo)
      git_commit("initial commit", repo = repo)
      print("Automatic README generated, please add relevant information about the archive")
    }
  }

  if (rproj) {
    # add an Rproj Rstudio project file
  }

  # TODO add a description file
  # Although mostly associated with R packages, a DESCRIPTION
  # file can also  be used to declare dependencies
  # for a non-package project.
  # possible use the usethis package
  # add maintainer
  # add imports
  # set version to 0.1
  # suggest opentimeseries R package
  # repo



  if (!is.null(remote_owner)) {
    # push to Remote
    # see Colin's slides.
  }
}
