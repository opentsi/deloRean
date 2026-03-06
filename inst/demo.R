library(deloRean)

# Create a new archive
archive_init(
  archive_name = "ch.kof.globalbaro",
  parent_dir = "~/repositories/opentsi/"
)


global <- kofdata::get_collection("globalbaro_vintages")
names(global) <- gsub("globalbaro_","",names(global))
names(global) <- sub("_", "\\.", names(global))
class(global) <- c(class(global), "tslist")

release_dates <- rep(seq(as.Date("2020-01-10"),
                         by = "1 month",
                         length.out = length(global)/2),2)


vintages_dt <- create_vintage_dt(release_dates, global)

# Import with historical commit dates
archive_import_history(
  vintages_dt,
  repository_path = "~/repositories/opentsi/ch.kof.globalbaro/"
)


validate_metadata("~/repositories/opentsi/ch.kof.globalbaro/data-raw/metadata.yaml")
render_metadata(archive_path = "~/repositories/opentsi/ch.kof.globalbaro")
