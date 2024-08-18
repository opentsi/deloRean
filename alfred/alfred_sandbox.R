library(zoo)
library(alfred)
library(tidyverse)
library(forecast)
library(ggplot2)
library(fpp3)

# the purpose of this document is to play around with different alfred time series and determine when their vintages start and how these revisions are being shown in the function.
# Fazit: Documentation for the differences in vintages is non-existent on the [aflred website](https://alfred.stlouisfed.org)...

cpi <- get_alfred_series(
    series_id = "CPIAUCSL",
    series_name = "cpi",
    observation_start = "2012-01-01",
    observation_end = "2017-01-01",
    realtime_start = "2017-01-01",
    realtime_end = "2024-08-16"
)
view(cpi)
cpi_2 <- cpi |> filter(realtime_period %in% c("2017-01-01", "2024-08-16"))
view(cpi_2)
# try with indpro... is this the same?
indpro <- get_alfred_series("INDPRO", "indpro",
    observation_start = "2000-01-01",
    observation_end = "2017-01-01",
    realtime_start = "2017-01-01",
    realtime_end = "2024-08-16"
)
view(indpro) # indpro has been revised since before 2000, cpi only from 2012 onwards


check_revisions <- function(ts, dates) {
    ts <- ts |> filter(realtime_period %in% dates)

    filtered_ts <- ts |> filter(ts$realtime_period == dates[1])
    df <- setNames(
        data.frame(matrix(ncol = 2, nrow = nrow(filtered_ts))),
        c("date", "difference")
    )

    for (i in seq_len(nrow(filtered_ts))) {
        d <- filtered_ts$date[i]
        difference_df <- ts |> filter(date == d) # compares each date in the two versions
        val_col <- names(difference_df)[sapply(difference_df, is.numeric)]
        dist <- difference_df[[val_col]][1] - difference_df[[val_col]][2]
        df$date[i] <- strftime(d)
        df$difference[i] <- dist
    }
    return(df)
}

rev_cpi <- check_revisions(cpi, dates = c("2017-01-01", "2024-08-16"))
view(rev_cpi)
rev_ind <- check_revisions(indpro, dates = c("2017-01-01", "2024-08-16"))
view(rev_ind) # here too, difference within 5 years is given...
