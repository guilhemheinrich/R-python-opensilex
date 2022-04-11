library(logging)
library(opensilexClientToolsR)



#    _                       _
#   | |                     (_)
#   | |     ___   __ _  __ _ _ _ __   __ _
#   | |    / _ \ / _` |/ _` | | '_ \ / _` |
#   | |___| (_) | (_| | (_| | | | | | (_| |
#   |______\___/ \__, |\__, |_|_| |_|\__, |
#                 __/ | __/ |         __/ |
#                |___/ |___/         |___/


#                  _   _                _   _           _   _
#       /\        | | | |              | | (_)         | | (_)
#      /  \  _   _| |_| |__   ___ _ __ | |_ _  ___ __ _| |_ _  ___  _ __
#     / /\ \| | | | __| '_ \ / _ \ '_ \| __| |/ __/ _` | __| |/ _ \| '_ \
#    / ____ \ |_| | |_| | | |  __/ | | | |_| | (_| (_| | |_| | (_) | | | |
#   /_/    \_\__,_|\__|_| |_|\___|_| |_|\__|_|\___\__,_|\__|_|\___/|_| |_|
#
#
USER <- "admin@opensilex.org"
PASSWORD <- "admin"
HOST <- "http://138.102.159.36:8081/rest"

#    _______          _       __                  _   _
#   |__   __|        | |     / _|                | | (_)
#      | | ___   ___ | |    | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
#      | |/ _ \ / _ \| |    |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
#      | | (_) | (_) | |    | | | |_| | | | | (__| |_| | (_) | | | \__ \
#      |_|\___/ \___/|_|    |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#
#

opensilexClientToolsR::connectToOpenSILEX(identifier = USER,
                                          password = PASSWORD,
                                          url = HOST)

retry_once <- function(func, ...) {
  args = list(...)
  final_call <- NULL
  # From <https://stackoverflow.com/a/12195574>
  out <- tryCatch({
    opensilexClientToolsR::connectToOpenSILEX(identifier = USER,
                                              url = HOST,
                                              password = PASSWORD)
    
    final_call <- do.call(func, args)
    return(final_call)
  },
  error = function(cond) {
    # Try once more
    tryCatch({
      opensilexClientToolsR::connectToOpenSILEX(identifier = USER,
                                                url = HOST,
                                                password = PASSWORD)

      final_call <- do.call(func, args)
      message("there")
      return(final_call)
    },
    error = function(cond) {
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning = function(cond) {
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    })
  },
  finally = {
    # NOTE:
    # Here goes everything that should be executed at the end,
    # regardless of success or error.
    # If you want more than one expression to be executed, then you
    # need to wrap them in curly brackets ({...}); otherwise you could
    # just have written 'finally=<expression>'
    message("\nSome other message at the end")
  })
  
  if (!is.null(final_call)) {
    return(final_call)
  }
  return(out)
}

# experiments

experimentsApi <- opensilexClientToolsR::ExperimentsApi$new()
result <- retry_once(experimentsApi$search_experiments)$data
result_df <- clay::EnvironmentList_to_dataframe(result)
experiment_dt <- data.table::data.table(result_df)

experiments_uri <- experiment_dt$uri
result_list <- list()
type_uri_per_experiment <-list()

scientificObjectsApi <- opensilexClientToolsR::ScientificObjectsApi$new()
for (uri in experiments_uri) {
  so_types <- tryCatch(
    {
      retry_once(scientificObjectsApi$get_used_types,experiment = uri)$data
    },
    error=function(cond) {
      # Choose a return value in case of error
      return(NULL)
    },
    warning=function(cond) {
      message(paste("URL caused a warning:", url))
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    })
  if (!is.null(so_types)) {
    
    so_types_df <- clay::EnvironmentList_to_dataframe(so_types)$name
    result_list[[uri]] <- paste(so_types_df, collapse = ", ")
    so_uri_types_df <- clay::EnvironmentList_to_dataframe(so_types)$uri
    print(as.character(so_uri_types_df))
    type_uri_per_experiment[[uri]] <- as.character(so_uri_types_df)
  }
}
mat <- cbind(names(result_list), unlist(unname(result_list)))
colnames(mat) <- c('uri', 'so_type')
so_types_DT <- data.table::data.table(mat)
list(so_types_DT = so_types_DT, type_uri_per_experiment = type_uri_per_experiment)


experiments_uri <- experiment_dt$uri
result_list <- list()
scientificObjectsApi <- opensilexClientToolsR::ScientificObjectsApi$new()
for (uri in experiments_uri) {
  so_count <- tryCatch(
    {
      data <- retry_once(scientificObjectsApi$search_scientific_objects, experiment = uri, page_size = 1)
      data$metadata$pagination$totalCount
    },
    error=function(cond) {
      # Choose a return value in case of error
      return(NULL)
    },
    warning=function(cond) {
      message(paste("URL caused a warning:", url))
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    }
  )    
  # so_types <- scientificObjectsApi$get_used_types(experiment = uri)$data
  if (!is.null(so_count)) {
    # so_types_df <- clay::EnvironmentList_to_dataframe(so_types)$name
    result_list[[uri]] <- so_count
  }
}
mat <- cbind(names(result_list), unlist(unname(result_list)))
colnames(mat) <- c('uri', 'so_count')
so_card_DT <- data.table::data.table(mat)
so_card_DT$so_count <- as.numeric(so_card_DT$so_count)
so_card_DT
