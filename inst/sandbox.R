library(kofdata)
library(data.table)
library(tsbox)
library(devtools)
load_all()

global <- kofdata::get_collection("globalbaro_vintages")
names(global) <- sub("_", "\\.", names(global))
class(global) <- c(class(global), "tslist")

release_dates <- rep(seq(as.Date("2020-01-10"),
                     by = "1 month",
                     length.out = length(global)/2),2)


create_vintages <- function(release_date, tsl){
  out <- list()
  keys <- gsub("(.+)(_\\d{4}-\\d{2})","\\1",names(tsl))
  dt_list <- data.table(
    id = keys,
    release_date = as.POSIXct(sprintf("%s 23:59:59",release_date),
                              tz = "UTC"),
    data = lapply(tsl, tsbox::ts_dt)
  )
  dt_list
}


dv <- create_vintages(release_dates, global)

unique_dates <- unique(dv$release_date)


for (rd in unique_dates) {
  dv_subset <- dv[release_date == rd]

  dv_subset[, {
    dir.create(id, showWarnings = FALSE)
    write.csv(data[[1]], file = file.path(id, "data.csv"), row.names = FALSE)
  }, by = id]

  message(sprintf("%s written", rd))

}
