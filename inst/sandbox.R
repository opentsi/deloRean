# TODO:
# sandbox to R functions.


library(kofdata)
library(data.table)
library(tsbox)
library(devtools)
load_all()

archive_init("ch.kof.globalbaro", "~/repositories/opentsi/")

Sys.setenv("DELOREAN_TZ" = "UTC")
Sys.setenv("DELOREAN_EMAIL" = "bannert@kof.ethz.ch")
Sys.setenv("DELOREAN_AUTHOR" = "Open Time Series Initiative")
Sys.setenv("DELOREAN_SSH_KEY" = "~/.ssh/id_rsa")



global <- kofdata::get_collection("globalbaro_vintages")
names(global) <- gsub("globalbaro_","",names(global))
names(global) <- sub("_", "\\.", names(global))
class(global) <- c(class(global), "tslist")

release_dates <- rep(seq(as.Date("2020-01-10"),
                     by = "1 month",
                     length.out = length(global)/2),2)


vintages_dt <- create_vintage_dt(release_dates, global)


# commit full history
# git remote add origin git@github.com:opentsi/ch.kof.globalbaro.git
# git branch -M main
# git push -u origin main

# let's create dummy update release.
toy <- list()
toy$leading <- global$`leading.2025-03` * 3
toy$coincident <- global$`leading.2025-03` * 5

toy_dt <- lapply(toy, tsbox::ts_dt)




dv1 <- dv[1:3,]
dv2 <- dv[66,]

dv3 <- dv[67,]

commit_full_history(dv1,
                    repository_path = "~/repositories/opentsi/ch.kof.globalbaro")

commit_full_history(dv2,
                    repository_path = "~/repositories/opentsi/ch.kof.globalbaro")

commit_full_history(dv3,
                    repository_path = "~/repositories/opentsi/ch.kof.globalbaro")




## !! append = TRUE for index.csv, may not be right.
## gotta figure out not to get dupes




dataset_update(tsx = toy_dt,
               repo = "ch.kof.globalbaro",
               repo_parent_dir = "~/repositories/opentsi",
               owner = "opentsi",
               remote_provider = "git@github.com:")




# Yay updates work now !!
# next step
# move functions from sandbox to R folder
#
# (check clone options to get smaller local repo
# could also postpone this, since GHA does a depth=1 by default)
# how to add time series alter history -> see good discussion with deep Seek R1




dv <- create_vintages(release_dates, global)

debug(commit_full_history)


xx <- fread("~/repositories/opentsi/ch.kof.globalbaro/data-raw/coincident/series.csv")
yy <- fread("~/repositories/opentsi/ch.kof.globalbaro/data-raw/coincident/series.csv")


tsbox::ts_plot(xx)
tsbox::ts_plot(yy)


