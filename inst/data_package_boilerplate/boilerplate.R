library(deloRean)
library(opentimeseries)


## Example Step 1, Init Archive, once generated make sure
# the newly created archive is your working dir
# outcommented because by the time you read this in boilerplate.R
# you've already created the archive.
# archive_init("ch.kof.globalbaro", parent_dir = )



## Example Step 2, Generate History

library(kofdata)
library(data.table)
library(tsbox)

global <- get_collection("globalbaro_vintages")
names(global) <- gsub("globalbaro_","",names(global))
names(global) <- sub("_", "\\.", names(global))
class(global) <- c(class(global), "tslist")
release_dates <- rep(seq(as.Date("2020-01-10"),
                         by = "1 month",
                         length.out = length(global)/2),2)
vintages_dt <- create_vintage_dt(release_dates, global)
head(vintages_dt)

## Example Step 3, Import History to Archive
archive_import_history(vintages_dt, repository_path = ".")






