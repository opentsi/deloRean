# Initialize a New Time Series Archive
#' @importFrom fs dir_create file_touch
#' @export
archive_init <- function(archive_name,
                         parent_dir = NULL,
                         remote_owner = "opentsi",
                         basic_readme = TRUE,
                         rproj = TRUE

){
  if(is.null(parent_dir)){
    archive_path = file.path(getwd(), archive_name)
  } else {
    archive_path = file.path(parent_dir, archive_name)
  }

  dir_create(archive_path)

  if(basic_readme){
    readme_loc <- file.path(archive_path, "README.md")
    file_touch(readme_loc)
    repo <- git_init(archive_path)
    git_add(files = "README.md", repo = repo)
    git_commit("initial commit", repo = repo)
    # add archive name to h1
    # description 
  }

  if(rproj){
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
  git_init(archive_path)
  repo




   if(!is.null(remote_owner)){
     # push to Remote
     # see Colin's slides. 
   }
}
