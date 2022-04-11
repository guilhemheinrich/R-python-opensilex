library(opensilexClientToolsR)
#' data_by_experiment_and_so_type 
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
#' 
# experiment_uri <- "http://www.opensilex.org/weis/WS1996-1"
# so_type_uri <- "http://www.opensilex.org/vocabulary/oeso-weis#Observation_point"
# authentication_params = list(user = "admin@opensilex.org", password = "admin", host = "http://138.102.159.36:8081/rest")

get_data_by_experiment_and_sotype <- function(experiment_uri, so_type_uri, authentication_params = list(user = "admin@opensilex.org", password = "admin", host = "http://138.102.159.36:8081/rest")) {
  opensilexClientToolsR::connectToOpenSILEX(identifier = authentication_params[['user']], password = authentication_params[['password']], url = authentication_params[['host']])
  
  # Liste des SO correspondant au type dans l'expérience
  scientificObjectApi <- opensilexClientToolsR::ScientificObjectsApi$new()
  so_list <- scientificObjectApi$search_scientific_objects(experiment = experiment_uri, rdf_types = so_type_uri)$data
  so_list_df <- clay::EnvironmentList_to_dataframe(so_list)
  
  targets_uri <- as.vector(so_list_df$uri)
  dataApi <- opensilexClientToolsR::DataApi$new()
  dataResult <- dataApi$search_data_list(experiments = experiment_uri, targets = targets_uri, page_size = 40000)$data

  data_df <- clay::EnvironmentList_to_dataframe(dataResult)

  
  return(data_df)
}


