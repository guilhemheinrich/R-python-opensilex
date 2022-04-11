# opensilexClientToolsR::connectToOpenSILEX(identifier = "admin@opensilex.org",
#                                           password = "admin",
#                                           url = "http://138.102.159.36:8081/rest")
# 
# dataApi <- opensilexClientToolsR::DataApi$new()
# data <- dataApi$search_data_list(experiments = "http://www.opensilex.org/weis/WS2018-1", page_size = 1)
# print(data$metadata$pagination$totalCount)
# # 
# experimentsApi <- opensilexClientToolsR::ExperimentsApi$new()
# result <- experimentsApi$search_experiments()$data
# result_df <- clay::EnvironmentList_to_dataframe(result)
# experiment_dt <- data.table::data.table(result_df)
# 
# type_uri_per_experiment <- list()
# result_list <- list()
# scientificObjectsApi <-
#   opensilexClientToolsR::ScientificObjectsApi$new()
# for (uri in experiment_dt$uri) {
#   so_types <- tryCatch({
#     scientificObjectsApi$get_used_types(experiment = uri)$data
#   },
#   error = function(cond) {
#     # Choose a return value in case of error
#     return(NULL)
#   },
#   warning = function(cond) {
#     message(paste("URL caused a warning:", url))
#     message("Here's the original warning message:")
#     message(cond)
#     # Choose a return value in case of warning
#     return(NULL)
#   })
#   # so_types <- scientificObjectsApi$get_used_types(experiment = uri)$data
#   if (!is.null(so_types)) {
#     so_types_df <- clay::EnvironmentList_to_dataframe(so_types)$name
#     result_list[[uri]] <- paste(so_types_df, collapse = ", ")
#     so_uri_types_df <-
#       clay::EnvironmentList_to_dataframe(so_types)$uri
#     print(as.character(so_uri_types_df))
#     type_uri_per_experiment[[uri]] <- as.character(so_uri_types_df)
#   }
# }
# print(type_uri_per_experiment)
# mat <- cbind(names(result_list), unlist(unname(result_list)))
# colnames(mat) <- c('uri', 'so_type')
# so_types_DT <- data.table::data.table(mat)
# so_types_per_experiment <-
#   list(so_types_DT = so_types_DT, type_uri_per_experiment = type_uri_per_experiment)
# 
# type_uri_per_experiment <-
#   so_types_per_experiment$type_uri_per_experiment
# scientificObjectsApi <-
#   opensilexClientToolsR::ScientificObjectsApi$new()
# 
# final_df <- data.frame()
# for (uri in names(type_uri_per_experiment)) {
#   types_uri <- type_uri_per_experiment[[uri]]
#   for (type_uri in types_uri) {
#     so_count <- tryCatch({
#       scientificObjectsApi$search_scientific_objects(experiment = uri, rdf_types = type_uri, page_size = 1)$metadata$pagination$totalCount
#     },
#     error = function(cond) {
#       message("error")
#       # Choose a return value in case of error
#       return(NULL)
#     },
#     warning = function(cond) {
#       # Choose a return value in case of warning
#       return(NULL)
#     })
# 
#     if (!is.null(so_count)) {
#       tmp <- uri
#       sub_exp <- subset(experiment_dt, uri == tmp)
#       inferred_so_type_name <- strsplit(type_uri, "#")[[1]][2]
#       to_insert <-
#         list(
#           experiment_uri = uri,
#           experiment_name = sub_exp$name[1],
#           so_type = type_uri,
#           so_type_name = inferred_so_type_name,
#           number = so_count
#         )
#       final_df <- rbind(final_df, data.frame(to_insert))
#     }
#   }
# }
# 
# final_dt <- data.table::data.table(final_df)
# 
# so_card_per_experiment <- final_dt[, ..c("experiment_uri", "number")]
# 
# scientificObjectsApi$search_scientific_objects(experiment = "http://www.opensilex.org/weis/WS2017-1",
#                                                rdf_types = "http://www.opensilex.org/vocabulary/oeso-weis#Area",
#                                                page_size = 1)$metadata$pagination$totalCount




# authentication_params = list(user = "charlotte.brault@vignevin.com",
#                              password = "L9Jr75rpGgEEYSC",
#                              host = "http://192.168.0.24:8669/rest")
# opensilexClientToolsR::connectToOpenSILEX(identifier = authentication_params[['user']],
#                                           password = authentication_params[['password']],
#                                           url = authentication_params[['host']])
# 
# # Liste des SO correspondant au type dans l'expérience
# scientificObjectApi <- opensilexClientToolsR::ScientificObjectsApi$new()
# experiment_uri <- "http://sinfonia.vignevin.com/set/experiments#varietes-resistantes---pouilly-beaujolais"
# so_type_uri <- "http://sinfonia.vignevin.com/oeso#Sub-plot"
# so_list <- scientificObjectApi$search_scientific_objects(experiment = experiment_uri,
#                                                          rdf_types = so_type_uri,
#                                                          page_size=4000)$data
# experimentsApi <- opensilexClientToolsR::ExperimentsApi$new()
# #result <- experimentsApi$search_experiments(page_size = 6)$data
# length(so_list)
# so_list_df <- clay::EnvironmentList_to_dataframe(so_list)
# dim(so_list_df)
# (targets_uri <- as.vector(so_list_df$uri))
# dataApi <- opensilexClientToolsR::DataApi$new()
# dataResult <- dataApi$search_data_list(experiments = experiment_uri,
#                                        page_size = 40,)$data
# 
# data_df <- clay::EnvironmentList_to_dataframe(dataResult)
# data_df


# Lorenc 
# 
# library(opensilexClientToolsR)
# 
# opensilexClientToolsR::connectToOpenSILEX(identifier="llorenc.cabrera-bosquet@inrae.fr",
#                                           password="llorenc", url = "http://phenome.inrae.fr/m3p/rest")
# 
# deviceApi <- DevicesApi$new()
# 
# 
# 
# 
# kk<- deviceApi$get_device(uri="http://phenome.inrae.fr/m3p/id/deviceAttribut/eo/2017/sa1700003")
# 
# don <- get_attributes(kk$data$result)



