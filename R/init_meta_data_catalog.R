#' Initialize a Metadata Catalog
#'
#'
#' @param variables character vector of variable names. Variable names have to be unique
#' within the same dataset.
init_meta_data_catalog <- function(variables,
                                   country,
                                   provider,
                                   dataset,
                                   frequency,
                                   url = NULL,
                                   mi_languages = c("en","de", "fr", "it")){
  stopifnot(length(variables) == length(unique(variables)))
    dataset_specifics <- list(
      "title" = dataset,
      "source_name" = paste(country, provider, sep = ","),
      "source_url" = url,
      "dataset_frequency" = frequency,
      "dim_order" = list(),
      "hierarchy" = list(
        aggregation_strategy = ""
      ),
      "labels" = list(
        dimnames = list()
      )
    )




# ch.adecco.sjmi.f4.idx_type.ins.idx

}

# 1.2.3.4.5.6.7
# country.provider.dataset.frequency.group_by.variable.unit
