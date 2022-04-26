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
source("./retry_once.R")


# experiments

experimentsApi <- opensilexClientToolsR::ExperimentsApi$new()
result <- retry_once(experimentsApi$search_experiments)$data
result_df <- clay::EnvironmentList_to_dataframe(result)
experiment_dt <- data.table::data.table(result_df)

experiments_uri <- experiment_dt$uri
result_list <- list()
type_uri_per_experiment <- list()


# Scientific object types per experiments
scientificObjectsApi <-
  opensilexClientToolsR::ScientificObjectsApi$new()
for (uri in experiments_uri) {
  so_types <- tryCatch({
    retry_once(scientificObjectsApi$get_used_types, experiment = uri)$data
  },
  error = function(cond) {
    # Choose a return value in case of error
    return(NULL)
  },
  warning = function(cond) {
    message(paste("URL caused a warning:", url))
    message("Here's the original warning message:")
    message(cond)
    # Choose a return value in case of warning
    return(NULL)
  })
  if (!is.null(so_types)) {
    so_types_df <- clay::EnvironmentList_to_dataframe(so_types)$name
    result_list[[uri]] <- paste(so_types_df, collapse = ", ")
    so_uri_types_df <-
      clay::EnvironmentList_to_dataframe(so_types)$uri
    print(as.character(so_uri_types_df))
    type_uri_per_experiment[[uri]] <- as.character(so_uri_types_df)
  }
}
mat <- cbind(names(result_list), unlist(unname(result_list)))
colnames(mat) <- c('uri', 'so_type')
so_types_DT <- data.table::data.table(mat)
so_types_per_experiment <-
  list(so_types_DT = so_types_DT, type_uri_per_experiment = type_uri_per_experiment)


# Scientific object count per experiment
experiments_uri <- experiment_dt$uri
result_list <- list()
scientificObjectsApi <-
  opensilexClientToolsR::ScientificObjectsApi$new()
for (uri in experiments_uri) {
  so_count <- tryCatch({
    data <-
      retry_once(
        scientificObjectsApi$search_scientific_objects,
        experiment = uri,
        page_size = 1
      )
    data$metadata$pagination$totalCount
  },
  error = function(cond) {
    # Choose a return value in case of error
    return(NULL)
  },
  warning = function(cond) {
    message(paste("URL caused a warning:", url))
    message("Here's the original warning message:")
    message(cond)
    # Choose a return value in case of warning
    return(NULL)
  })
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


# Scientific object count per type per experiment

print(type_uri_per_experiment)
final_df <- data.frame()
scientificObjectsApi <-
  opensilexClientToolsR::ScientificObjectsApi$new()
for (uri in names(type_uri_per_experiment)) {
  types_uri <- type_uri_per_experiment[[uri]]
  for (type_uri in types_uri) {
    so_count <- tryCatch({
      data <-
        retry_once(
          scientificObjectsApi$search_scientific_objects,
          experiment = uri,
          rdf_types = type_uri,
          page_size = 1
        )
      print(data)
      data$metadata$pagination$totalCount
    },
    error = function(cond) {
      message("error")
      # Choose a return value in case of error
      return(NULL)
    },
    warning = function(cond) {
      # Choose a return value in case of warning
      return(NULL)
    })
    
    if (!is.null(so_count)) {
      tmp <- uri
      sub_exp <- subset(experiment_dt, uri == tmp)
      ## Should better use an apiCall result, but ...
      inferred_so_type_name <- strsplit(type_uri, "#")[[1]][2]
      to_insert <-
        list(
          experiment_uri = uri,
          experiment_name = sub_exp$name[1],
          so_type = type_uri,
          so_type_name = inferred_so_type_name,
          number = so_count
        )
      final_df <- rbind(final_df, data.frame(to_insert))
    }
  }
}

final_dt <- data.table::data.table(final_df)
final_dt

# Data count per experiment, per so_types
# Issue spotted
# Using low level api call

call0 <- paste(HOST, "/security/authenticate", sep = "")
post_authenticate <- httr::POST(
  call0,
  body = paste('{
  "identifier": "', USER, '",
  "password": "', PASSWORD, '"
}', sep = ""),
  httr::add_headers(`Content-Type` = "application/json", Accept = "application/json")
)


post_authenticate_text <- httr::content(post_authenticate, "text")
post_authenticate_json <-
  jsonlite::fromJSON(post_authenticate_text, flatten = TRUE)
token <- post_authenticate_json$result$token

# Data count per experiments
result_list <- list()
for (experiment_uri in names(type_uri_per_experiment)) {
  print(experiment_uri)
  data_count <- tryCatch({
    call1 <-
      paste(
        HOST,
        "/core/data/count",
        "?",
        "experiments=",
        URLencode(experiment_uri, reserved = TRUE),
        "&page_size=10000",
        sep = ""
      )
    
    get_count <-
      httr::GET(call1, httr::add_headers(Authorization = token))
    get_count_text <- httr::content(get_count, "text")
    get_count_json <-
      jsonlite::fromJSON(get_count_text, flatten = TRUE)
    get_count_json$result
  },
  error = function(cond) {
    # message(paste("URL caused a error:", url))
    message("Here's the original error message:")
    message(cond)
    # Choose a return value in case of error
    return(NULL)
  },
  warning = function(cond) {
    # message(paste("URL caused a warning:", url))
    message("Here's the original warning message:")
    message(cond)
    # Choose a return value in case of warning
    return(NULL)
  })
  print(data_count)
  if (!is.null(data_count)) {
    result_list[[experiment_uri]] <- data_count
  }
}

print("End of data count")
print(result_list)
mat <- cbind(names(result_list), unlist(unname(result_list)))
print(mat)
colnames(mat) <- c('experiment_uri', 'data_count')
data_card_DT <- data.table::data.table(mat)
# Data count per experiments per os type/variable
# Issue: Lack of variable functions


# result_list <- list()
# for (experiment_uri in names(type_uri_per_experiment)) {
#   types_uri <- type_uri_per_experiment[[experiment_uri]]
#   for (type_uri in types_uri) {
#     print(experiment_uri)
#     data_count <- tryCatch({
#       call1 <-
#         paste(
#           HOST,
#           "/core/data/count",
#           "?",
#           "experiments=",
#           URLencode(experiment_uri, reserved = TRUE),
#           sep = ""
#         )
#       
#       get_count <-
#         httr::GET(call1, httr::add_headers(Authorization = token))
#       get_count_text <- httr::content(get_count, "text")
#       get_count_json <-
#         jsonlite::fromJSON(get_count_text, flatten = TRUE)
#       data$result
#     },
#     error = function(cond) {
#       # message(paste("URL caused a error:", url))
#       message("Here's the original error message:")
#       message(cond)
#       # Choose a return value in case of error
#       return(NULL)
#     },
#     warning = function(cond) {
#       # message(paste("URL caused a warning:", url))
#       message("Here's the original warning message:")
#       message(cond)
#       # Choose a return value in case of warning
#       return(NULL)
#     })
#     print(data_count)
#     if (!is.null(data_count)) {
#       result_list[[uri]] <- data_count
#     }
#   }
# }
# print("End of data count")
# print(result_list)
# mat <- cbind(names(result_list), unlist(unname(result_list)))
# print(mat)
# colnames(mat) <- c('uri', 'data_count')
# data_card_DT <- data.table::data.table(mat)

write.csv(data_card_DT ,"data\\data_count_per_experiment.csv", row.names = TRUE)
write.csv(final_dt ,"data\\overview.csv", row.names = TRUE)
