#' Initialize a New Time Series Dataset Archive
#'
#'
#' @importFrom fs dir_create file_touch
#' @importFrom usethis use_data_raw
#' @export
archive_init <- function(archive_name,
                         parent_dir = NULL,
                         remote_owner = "opentsi",
                         rproj = TRUE) {
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

## Basic Usage Via opentimeseries


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

  use_data_raw(name = gsub("\\.", "", archive_name))
  fs::file_move(path = "data-raw", file.path(archive_path, "data-raw"))


  repo <- git_init(archive_path)
  git_add(files = ".", repo = repo)
  git_commit("archive init commit", repo = repo)

  git_init(archive_path)
  repo

  if (!is.null(remote_owner)) {
    # push to Remote
    # see Colin's slides.
  }
}
