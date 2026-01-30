
library(httr2)


url <- paste0("https://api.github.com/repos/", "opentsi/deloRean", "/commits?sha=", "main","&per_page=3")


res <- httr2::request(url) |>
  req_headers(Accept = "application/vnd.github.v3+json") |>
  req_perform()

gh_json <- res |>
  resp_body_json()

gh_json[[1]]$commit$author$date

response <- GET(url, add_headers(Accept = "application/vnd.github.v3+json"))
commits <- content(response)

commit_info <- lapply(commits, function(commit) list(hash = commit$sha, date = commit$commit$author$date))


commit_df <- do.call(rbind.data.frame, lapply(commit_info, function(x) data.frame(hash = x$hash, date = x$date)))



desired_date <- as.POSIXct("2025-03-01T00:00:00Z", format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
closest_commit <- NULL
closest_diff <- Inf

for (commit in commits) {
  commit_date <- as.POSIXct(commit$commit$author$date, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  diff <- abs(difftime(commit_date, desired_date, units = "secs"))

  if (diff < closest_diff) {
    closest_commit <- commit
    closest_diff <- diff
  }
}

if (!is.null(closest_commit)) {
  commit_hash <- closest_commit$sha
  commit_date <- closest_commit$commit$author$date
  cat("Closest Commit:", commit_hash, "Date:", commit_date, "\n")
} else {
  cat("No commits found.\n")
}


str(commits)


lapply(commits, "[[", "author")

commits[[1]]
names(commits)
