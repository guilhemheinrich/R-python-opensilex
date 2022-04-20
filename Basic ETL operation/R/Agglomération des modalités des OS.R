

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
HOST <- "https://sixtine.mistea.inrae.fr/rest"
#    _____                               _
#   |  __ \                             | |
#   | |__) |_ _ _ __ __ _ _ __ ___   ___| |_ ___ _ __ ___
#   |  ___/ _` | '__/ _` | '_ ` _ \ / _ \ __/ _ \ '__/ __|
#   | |  | (_| | | | (_| | | | | | |  __/ ||  __/ |  \__ \
#   |_|   \__,_|_|  \__,_|_| |_| |_|\___|\__\___|_|  |___/
#
#

# One, or many experiments uri
experiments_uri <-
  c(
    "sixtine:set/experiments#qualite-du-fruit-2017",
    "sixtine:set/experiments#resintbio"
  )
# Only one so type
scientific_object_type <-
  "http://www.opensilex.org/vocabulary/oeso#SubPlot"

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

#    ______         _             
#   |  ____|       | |            
#   | |__ __ _  ___| |_ ___  _ __ 
#   |  __/ _` |/ __| __/ _ \| '__|
#   | | | (_| | (__| || (_) | |   
#   |_|  \__,_|\___|\__\___/|_|   
#                                 
#            

# Factors level, bounded to experiment
# Package try, FAIL (To much mess)

experimentsApi <-
  opensilexClientToolsR::ExperimentsApi$new()
result <-
  retry_once(
    experimentsApi$get_available_factors,
    "sixtine:set/experiments#qualite-du-fruit-2017"
  )$data
result_df <-
  rbind(
    clay::EnvironmentList_to_dataframe(result),
    clay::EnvironmentList_to_dataframe(result, "levels")
  )
for (experiment_uri in experiments_uri) {
  factors <- tryCatch({
    result <-
      retry_once(experimentsApi$get_available_factors, experiment_uri)$data
    clay::EnvironmentList_to_dataframe(result)
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
  print(factors)
}

# Raw try
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


factors_per_experiments <- list()
for (experiment_uri in experiments_uri) {
  factor_info <- tryCatch({
    call1 <-
      paste(
        HOST,
        "core/experiments",
        URLencode(experiment_uri, reserved = TRUE),
        "factors",
        sep = "/"
      )
    get_result <-
      httr::GET(call1, httr::add_headers(Authorization = token))
    get_result_text <- httr::content(get_result, "text")
    get_result_json <-
      jsonlite::fromJSON(get_result_text, flatten = TRUE)
    factors <- get_result_json$result$uri
    names(factors) <- get_result_json$result$name
    factors_level <- get_result_json$result$levels
    names(factors_level) <- factors
    list(factors_level = factors_level, factors_name = factors)
  },
  error = function(cond) {
    message("Here's the original error message:")
    message(cond)
    # Choose a return value in case of error
    return(NULL)
  },
  warning = function(cond) {
    message("Here's the original warning message:")
    message(cond)
    # Choose a return value in case of warning
    return(NULL)
  })
  
  if (!is.null(factor_info)) {
    factors_per_experiments[[experiment_uri]] <- factor_info
  }
}


#     _____      _            _   _  __ _          ____  _     _           _   
#    / ____|    (_)          | | (_)/ _(_)        / __ \| |   (_)         | |  
#   | (___   ___ _  ___ _ __ | |_ _| |_ _  ___   | |  | | |__  _  ___  ___| |_ 
#    \___ \ / __| |/ _ \ '_ \| __| |  _| |/ __|  | |  | | '_ \| |/ _ \/ __| __|
#    ____) | (__| |  __/ | | | |_| | | | | (__   | |__| | |_) | |  __/ (__| |_ 
#   |_____/ \___|_|\___|_| |_|\__|_|_| |_|\___|   \____/|_.__/| |\___|\___|\__|
#                                                            _/ |              
#                                                           |__/               
so_per_experiments <- list()
scientificObjectsApi <-
  opensilexClientToolsR::ScientificObjectsApi$new()
result <- scientificObjectsApi$search_scientific_objects(experiment = experiments_uri[1], rdf_types = scientific_object_type)$data
so_uri <- clay::EnvironmentList_to_dataframe(result, "name", "uri")
for (experiment_uri in experiments_uri) {
  scientific_objects <- tryCatch({
    result <- retry_once(scientificObjectsApi$search_scientific_objects, experiment = experiment_uri, rdf_types = scientific_object_type)$data
    so_uri <- clay::EnvironmentList_to_dataframe(result, "name", "uri")
    so_uri
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
  print(scientific_objects)
  if (!is.null(scientific_objects)) {
    so_per_experiments[[experiment_uri]] <- scientific_objects
  }
}

# SO detail
for (experiment_uri in experiments_uri) {
  SOs_uri <- so_per_experiments[[experiment_uri]]$uri
  for (so_uri in SOs_uri) {
    so_detail <- tryCatch({
      result <-
        retry_once(
          scientificObjectsApi$get_scientific_object_detail,
          uri = so_uri,
          experiment = experiment_uri
        )$data
      result
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
  }
  if (!is.null(so_detail)) {
    print(so_detail)
  }
}