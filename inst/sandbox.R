library(kofdata)
library(data.table)
library(tsbox)
library(devtools)
load_all()

global <- kofdata::get_collection("globalbaro_vintages")
class(global) <- c(class(global), "tslist")

ldt <- list()
for (i in 1:54) {
    l <- c(global[i], global[i + 54])
    class(l) <- c(class(l), "tslist")
    dt <- ts_dt(l)
    dt$id <- gsub("_[0-9]{4}-[0-9]{2}$", "", dt$id)
    dt$id <- sprintf("ch.kof.%s", gsub("_", ".", dt$id))
    setnames(dt, "time", "date")
    ldt[[i]] <- dt
}

# put ldt into folder
fs::dir_create("../kofethz")
git_init("../kofethz")

d <- seq(as.Date("2021-01-01"), by = "1 months", length = length(ldt))
d
i=1

for (i in seq(ldt)) {
    version_add_ts(ldt[[i]], root_folder = "../kofethz", seal = TRUE, version = d[i])
}
