#' Initialize a New Time Series Dataset Archive
#'
#'
#' @importFrom fs dir_create file_touch file_copy file_move
#' @importFrom usethis use_data_raw use_directory
#' @importFrom gert git_init
#' @export
archive_init <- function(archive_name,
                         parent_dir = NULL,
                         remote_owner = "opentsi",
                         rproj = TRUE,
                         use_gha = TRUE) {
  if (is.null(parent_dir)) {
    archive_path <- file.path(getwd(), archive_name)
  } else {
    archive_path <- file.path(parent_dir, archive_name)
  }

  generic_desc <- sprintf(
    "The %s package provides versioned time series data
                            and their meta information for scientific research.
                            In addition, the package contains the
                            extract-transform-load (ETL) functionality that
                            sources the data from its original provider.",
    archive_name
  )
  generic_desc_sw <- gsub(" +", " ", generic_desc)
  generic_desc_no_ls <- gsub("\n\\s+", "\n", generic_desc_sw)

  readme_md_content <- sprintf(
    "
# %s

%s

## Browse Time Series Data

## Basic Data Consumption via opentimeseries


```r
ts <- read_open_ts(
  \"%s\",
  archive= \"opentsi\" # or your organisation
)

ts
```

## The %s Data R Package

",
  archive_name,
  generic_desc_no_ls,
  archive_name,
  archive_name
  )

usethis::create_package(
  path = archive_path,
  rstudio = rproj,
  roxygen = TRUE,
  open = FALSE,
  fields = list(
    Title = sprintf(
      "Versioned Long Format Time Series from %s",
      toupper(archive_name)
    ),
    Version = "0.1",
    Description = generic_desc
  )
)

readme_loc <- file.path(archive_path, "README.md")
file_touch(readme_loc)
file_con <- file(readme_loc, "w")
writeLines(readme_md_content, file_con)
close(file_con)

if(use_gha){
  gha_loc <- file.path(archive_path, ".github","workflows","update_data.yaml")
  fs::dir_create(
    file.path(
      archive_path,".github/workflows"
    )
  )
  file_copy(
    system.file("github_actions/update_data.yaml", package = "deloRean"),
    file.path(archive_path, ".github/workflows/update_data.yaml")
  )
  message("Basic GitHub Action for Updating data created.")
}

# create a boilerplated R folder in the newly created package
file_copy(system.file("data_processing/handle_data.R",
                      package = "deloRean"),
          file.path(archive_path,"R"))
file_copy(system.file("data_processing/run_update.R",
                      package = "deloRean"),
          file.path(archive_path,"R"))

file_copy(system.file("data_processing/get_publisher_last_update.R",
                      package = "deloRean"),
          file.path(archive_path,"R"))

use_data_raw(name = gsub("\\.", "", archive_name),
             open = FALSE)
file_move(path = "data-raw", file.path(archive_path, "data-raw"))


repo <- git_init(archive_path)
git_add(files = ".", repo = repo)
git_commit("archive init commit", repo = repo)

msg <- sprintf("New opentimeseries archive '%s' created. Happy editing!",
        archive_name)
message(msg)
message("Please add your dataset specific update functions to the R folder of your new bootstrapped data package.")
message("handle_data.R")
message("get_publisher_last_update.R")

if (!is.null(remote_owner)) {
  # push to Remote
  # see Colin's slides.
}
}
