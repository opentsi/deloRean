#' Initialize a New Time Series Dataset Archive
#'
#'
#' @importFrom fs dir_create file_touch file_copy file_move
#' @importFrom usethis use_data_raw use_directory create_package
#' @importFrom gert git_init git_add git_commit
#' @export
archive_init <- function(archive_name,
                         parent_dir = NULL,
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

create_package(
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
    Description = generic_desc,
    Imports = "desc, opentimeseries"
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

# Create inst directory for rendered metadata
fs::dir_create(
  file.path(archive_path, "inst")
)


# create a boilerplated R folder in the newly created package
file_copy(system.file("data_package_boilerplate/handle_update.R",
                      package = "deloRean"),
          file.path(archive_path,"R"))

file_copy(system.file("data_package_boilerplate/boilerplate.R",
                      package = "deloRean"),
          file.path(archive_path,"inst"))


file_copy(system.file("data_package_boilerplate/process_data.R",
                      package = "deloRean"),
          file.path(archive_path,"R"))

# adding claude.md as boilerplate
file_copy(system.file("data_package_boilerplate/CLAUDE.md",
                      package = "deloRean"),
          file.path(archive_path))

  

fs::dir_create(
  file.path(
    archive_path,"data-raw"
  )
)

# Copy metadata template
file_copy(
  system.file("templates/metadata_template.yaml", package = "deloRean"),
  file.path(archive_path, "data-raw", "metadata.yaml")
)
message("Metadata template created at data-raw/metadata.yaml")


repo <- git_init(archive_path)
git_add(files = ".", repo = repo)
git_commit("archive init commit", repo = repo)

msg <- sprintf("New opentimeseries archive '%s' created. Happy editing!",
        archive_name)
message(msg)

}
