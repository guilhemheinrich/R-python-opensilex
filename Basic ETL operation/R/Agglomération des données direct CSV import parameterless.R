source('getToken.R')

agglo_data_import_parameterless <- function(host,
                              user,
                              password,
                              experiment_uri,
                              scientific_object_type, 
                              variables = c()) {
  
  # Get all variables if none provided
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
  
  # Retrieve SO pet type
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
  
  
  
  
  token <- getToken(host = host,
                    user = user,
                    password = password)
  call1 <- paste0("https://sixtine.mistea.inrae.fr/rest/core/data/export",
                  "?experiments=",
                  URLencode(experiment_uri, reserved= TRUE),
                  # What we "should" call
                  # scientific_objects uri as url parmaeters => not scalable
                  # "&scientific_objects=",
                  # paste0(URLencode(so_list$uri, reserved= TRUE), collapse="&scientific_objects="),
                  "&mode=long")
  get_result <-
    httr::GET(
      call1,
      httr::add_headers(Authorization = token, `Content-Type` = "application/json" )
    )
  get_result_text <- httr::content(get_result, "text")
  result_df <- read.csv(text=get_result_text, sep = ",", header = TRUE)
  final_df <- result_df %>% filter(Target.URI %in% so_list$uri)
  return(final_df)
}