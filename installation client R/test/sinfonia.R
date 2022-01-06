library(opensilexClientToolsR)
source(file = "./r6_to_dataframe.R")

connectToOpenSILEX(identifier = "admin@opensilex.org", password = "admin", 
                     url = "http://192.168.0.24:8666/rest")

experiments_api <- ExperimentsApi$new()
experiments <- experiments_api$search_experiments()$data
experiments_df <- EnvironmentList_to_dataframe(experiments)
print(experiments_df)

