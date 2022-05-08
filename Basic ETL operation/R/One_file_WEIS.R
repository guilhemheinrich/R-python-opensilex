if (!"dplyr" %in% rownames(installed.packages())) install.packages("dplyr")
if (!"httr" %in% rownames(installed.packages())) install.packages("httr")
if (!"jsonlite" %in% rownames(installed.packages())) install.packages("jsonlite")

# More elegant but more time consuming... for what it matters
# required_packages <- c("dplyr", "httr", "jsonlite")
# install.packages(setdiff(required_packages, rownames(installed.packages())))  

library(dplyr)


#     _____             __ _                       _   _             
#    / ____|           / _(_)                     | | (_)            
#   | |     ___  _ __ | |_ _  __ _ _   _ _ __ __ _| |_ _  ___  _ __  
#   | |    / _ \| '_ \|  _| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \ 
#   | |___| (_) | | | | | | | (_| | |_| | | | (_| | |_| | (_) | | | |
#    \_____\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|
#                             __/ |                                  
#                            |___/                                               


config <- list(
  # Instance configuration
  user = "admin@opensilex.org",
  password = "admin",
  host = "http://138.102.159.36:8081/rest",
  # Output configuration
  write = TRUE,
  prefix = "WEIS",
  folder_basepath_to_write = "./WEIS_extract"
)

if (config$write) {
  if (!file.exists(config$folder_basepath_to_write)) {
    dir.create(config$folder_basepath_to_write)
  }
}

#    _    _      _                     ______                _   _                 
#   | |  | |    | |                   |  ____|              | | (_)                
#   | |__| | ___| |_ __   ___ _ __    | |__ _   _ _ __   ___| |_ _  ___  _ __  ___ 
#   |  __  |/ _ \ | '_ \ / _ \ '__|   |  __| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
#   | |  | |  __/ | |_) |  __/ |      | |  | |_| | | | | (__| |_| | (_) | | | \__ \
#   |_|  |_|\___|_| .__/ \___|_|      |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#                 | |                                                              
#                 |_|                                                                     
getToken <-
  function(host,
           user = "admin@opensilex.org",
           password = "admin") {
    call0 <- paste(host, "/security/authenticate", sep = "")
    post_authenticate <- httr::POST(
      call0,
      body = paste(
        '{
  "identifier": "',
        user,
        '",
  "password": "',
        password,
        '"
}',
        sep = ""
      ),
      httr::add_headers(`Content-Type` = "application/json", Accept = "application/json")
    )
    post_authenticate_text <-
      httr::content(post_authenticate, "text")
    post_authenticate_json <-
      jsonlite::fromJSON(post_authenticate_text, flatten = TRUE)
    token <- post_authenticate_json$result$token
    return(token)
  }
#    _____       _ _   _       _ _           _   _             
#   |_   _|     (_) | (_)     | (_)         | | (_)            
#     | |  _ __  _| |_ _  __ _| |_ ___  __ _| |_ _  ___  _ __  
#     | | | '_ \| | __| |/ _` | | / __|/ _` | __| |/ _ \| '_ \ 
#    _| |_| | | | | |_| | (_| | | \__ \ (_| | |_| | (_) | | | |
#   |_____|_| |_|_|\__|_|\__,_|_|_|___/\__,_|\__|_|\___/|_| |_|
#                                                              
#                                                              

if (config$write) {
  if (!file.exists(config$folder_basepath_to_write)) {
    dir.create(config$folder_basepath_to_write)
  }
}

#    ______                      _                      _       
#   |  ____|                    (_)                    | |      
#   | |__  __  ___ __   ___ _ __ _ _ __ ___   ___ _ __ | |_ ___ 
#   |  __| \ \/ / '_ \ / _ \ '__| | '_ ` _ \ / _ \ '_ \| __/ __|
#   | |____ >  <| |_) |  __/ |  | | | | | | |  __/ | | | |_\__ \
#   |______/_/\_\ .__/ \___|_|  |_|_| |_| |_|\___|_| |_|\__|___/
#               | |                                             
#               |_|                                             

token <-
  getToken(
    host = config$host,
    user = config$user,
    password = config$password
  )

url <-
  paste0(config$host,
         "/core/experiments",
         "?page_size=10000")
get_result <-
  httr::GET(url, httr::add_headers(Authorization = token))
get_result_text <- httr::content(get_result, "text")
get_result_json <-
  jsonlite::fromJSON(get_result_text, flatten = TRUE)
experiments_df <- get_result_json$result
colnames(experiments_df)[which(names(experiments_df) == "uri")] <-
  "experiment_uri"
colnames(experiments_df)[which(names(experiments_df) == "name")] <-
  "experiment_label"


#     _____      _            _   _  __ _            ____  _     _           _       _______                    
#    / ____|    (_)          | | (_)/ _(_)          / __ \| |   (_)         | |     |__   __|                   
#   | (___   ___ _  ___ _ __ | |_ _| |_ _  ___     | |  | | |__  _  ___  ___| |_       | |_   _ _ __   ___  ___ 
#    \___ \ / __| |/ _ \ '_ \| __| |  _| |/ __|    | |  | | '_ \| |/ _ \/ __| __|      | | | | | '_ \ / _ \/ __|
#    ____) | (__| |  __/ | | | |_| | | | | (__     | |__| | |_) | |  __/ (__| |_       | | |_| | |_) |  __/\__ \
#   |_____/ \___|_|\___|_| |_|\__|_|_| |_|\___|     \____/|_.__/| |\___|\___|\__|      |_|\__, | .__/ \___||___/
#                                                              _/ |                        __/ | |              
#                                                             |__/                        |___/|_|              

# Initialize data.frame, so we can rbind() recursively on it
so_df <- data.frame()
token <-
  getToken(
    host = config$host,
    user = config$user,
    password = config$password
  )

for (experiment_uri in experiments_df$experiment_uri) {
  # Try/catch structure is required to handle "gracefully" all the case where it goes wrong
  # It can be a service failure, a list of size 0 (in that case) etc...
  so_type <- tryCatch({
    url <-
      paste0(
        config$host,
        "/core/scientific_objects/used_types",
        "?page_size=10000",
        "&experiment=",
        URLencode(experiment_uri, reserved = TRUE)
      )
    get_result <-
      httr::GET(url, httr::add_headers(Authorization = token))
    get_result_text <- httr::content(get_result, "text")
    get_result_json <-
      jsonlite::fromJSON(get_result_text, flatten = TRUE)
    result_df <- get_result_json$result
    data.frame(
      scientific_object_type_uri = result_df$uri,
      scientific_object_type_label = result_df$name,
      experiment_uri = rep(experiment_uri, length(result_df$uri))
    )
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
  
  if (!is.null(so_type)) {
    so_df <- rbind(so_df, so_type)
  }
}

#     ____                       _               
#    / __ \                     (_)              
#   | |  | |_   _____ _ ____   ___  _____      __
#   | |  | \ \ / / _ \ '__\ \ / / |/ _ \ \ /\ / /
#   | |__| |\ V /  __/ |   \ V /| |  __/\ V  V / 
#    \____/  \_/ \___|_|    \_/ |_|\___| \_/\_/  
#                                                

# Overview is just the merge of the two previous data.frame    


overview_df <- merge(experiments_df, so_df)
# Remove species as it is not usefull, and cause some bug (vector of list ?)
overview_df$species <- NULL
if (config$write) {
  write.csv(overview_df,
            paste0(config$folder_basepath_to_write, "/overview.csv"),
            row.names = FALSE)
}

#    _____        _        
#   |  __ \      | |       
#   | |  | | __ _| |_ __ _ 
#   | |  | |/ _` | __/ _` |
#   | |__| | (_| | || (_| |
#   |_____/ \__,_|\__\__,_|
#                          
#

# Data are aggregated experiments X scientific object type

data_per_so_X_experiment <- list()
agglo_data_import <- function(host,
                              user,
                              password,
                              experiment_uri,
                              scientific_object_type) {
  token <- getToken(host, user, password)
  
  # Retrieve SO per type
  call1 <-
    paste0(
      host,
      "/core/scientific_objects",
      "?",
      "experiment=",
      URLencode(experiment_uri, reserved = TRUE),
      # Only one
      "&",
      paste0(
        "rdf_types=",
        URLencode(scientific_object_type, reserved = TRUE),
        collapse = "&"
      ),
      "&page_size=10000"
    )
  get_result <-
    httr::GET(call1, httr::add_headers(Authorization = token))
  get_result_text <- httr::content(get_result, "text")
  get_result_json <-
    jsonlite::fromJSON(get_result_text, flatten = TRUE)
  so_list <- get_result_json$result
  
  token <- getToken(host = host,
                    user = user,
                    password = password)
  call1 <- paste0(
    host,
    "/core/data/export",
    "?experiments=",
    URLencode(experiment_uri, reserved = TRUE),
    # What we "should" call
    # scientific_objects uri as url parmaeters => not scalable
    # "&scientific_objects=",
    # paste0(URLencode(so_list$uri, reserved= TRUE), collapse="&scientific_objects="),
    "&mode=long"
  )
  get_result <-
    httr::GET(
      call1,
      httr::add_headers(Authorization = token, `Content-Type` = "application/json")
    )
  get_result_text <- httr::content(get_result, "text")
  result_df <-
    read.csv(text = get_result_text,
             sep = ",",
             header = TRUE)
  final_df <- result_df %>% filter(Target.URI %in% so_list$uri)
  return(final_df)
}


for (row_index in 1:nrow(overview_df)) {
  row <- overview_df[row_index, ]
  data <- tryCatch({
    agglo_data_import(
      config$host,
      config$user,
      config$password,
      row$experiment_uri,
      scientific_object_type = row$scientific_object_type_uri
    )
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
  if (!is.null(data)) {
    if (is.null(data_per_so_X_experiment[[row$scientific_object_type_uri]])) {
      data_per_so_X_experiment[[row$scientific_object_type_uri]] <- list()
    }
    data_per_so_X_experiment[[row$scientific_object_type_uri]][[row$experiment_uri]] <-
      data
    if (config$write) {
      filename_RAW <-
        paste0(
          c(
            config$prefix,
            row$scientific_object_type_label,
            row$experiment_label,
            "data.csv"
          ),
          collapse = "_"
        )
      filename_ESCAPED <-
        gsub('\\s|/', "_", filename_RAW) # Add more pattern if required
      write.csv(data,
                paste0(config$folder_basepath_to_write, "/", filename_ESCAPED),
                row.names = FALSE)
    }
  }
} 