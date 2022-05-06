source('getToken.R')

agglo_direct_data <- function(host,
                              user,
                              password,
                              experiments_uri,
                              scientific_object_type, 
                              variables = c()) {
  
  
  # Get all variables in experiment, if none provided
  
  if (is.null(variables)) {
  token <- getToken(host, user, password)
    
    call1 <-
      paste(
        host,
        "/core/data/variables",
        "?",
        paste0(
          "experiments=",
          URLencode(experiments_uri, reserved = TRUE),
          collapse = "&"
        ),
        "&page_size=10000",
        sep = ""
      )
    
    get_result <-
      httr::GET(call1, httr::add_headers(Authorization = token))
    get_result_text <- httr::content(get_result, "text")
    get_result_json <-
      jsonlite::fromJSON(get_result_text, flatten = TRUE)
    variables_list <- list(uri = get_result_json$result$uri, name = get_result_json$result$name) 
  } else {
    variables_list <- variables
  }
  
  # Get all SO corresponding to SO type
  token <- getToken(host, user, password)
  so_per_experiment <- data.frame(
    so_uri = character(),
    so_name = character(),
    rdf_type = character(),
    experiment_uri = character()
  )
  
  for (experiment_uri in experiments_uri) {
    call1 <-
      paste(
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
        "&page_size=10000",
        sep = ""
      )
    get_result <-
      httr::GET(call1, httr::add_headers(Authorization = token))
    get_result_text <- httr::content(get_result, "text")
    get_result_json <-
      jsonlite::fromJSON(get_result_text, flatten = TRUE)
    so_list <- get_result_json$result
    so_per_experiment <-
      rbind(
        so_per_experiment,
        data.frame(
          so_uri = so_list$uri,
          so_name = so_list$name,
          rdf_type = so_list$rdf_type,
          experiment_uri = experiment_uri
        )
      )
  }
  so_list <- so_per_experiment$so_uri
  # Get data related to corresponding SO, variables, experiments
  token <- getToken(host, user, password)
  
  
  
  call1 <-
    paste(
      host,
      "/core/data",
      "?",
      paste0(
        "experiments=",
        URLencode(experiments_uri, reserved = TRUE),
        collapse = "&"
      ),
      # C'est mieux de ne PAS mettre de target, car les paramètre d'une requête GET ont une taille trop limité
      # "&",
      # paste0("targets=", URLencode(so_list, reserved = TRUE), collapse = "&"),
      "&",
      paste0(
        "variables=",
        URLencode(variables_list$uri, reserved = TRUE),
        collapse = "&"
      ),
      "&page_size=10000",
      sep = ""
    )
  
  get_result <-
    httr::GET(call1, httr::add_headers(Authorization = token))
  get_result_text <- httr::content(get_result, "text")
  get_result_json <-
    jsonlite::fromJSON(get_result_text, flatten = TRUE)
  content_df <- data.frame(
    so_uri = get_result_json$result$target,
    date = get_result_json$result$date,
    variable_uri = get_result_json$result$variable,
    value = get_result_json$result$value
  )
    # variable_name = variables_list$name[which(variables_list$uri == get_result_json$result$variable)],
  final_dt <- merge(content_df, so_per_experiment)
  final_dt <- merge(final_dt, data.frame(variable_uri = variables_list$uri, variable_name = variables_list$name))
  return(final_dt)
}


