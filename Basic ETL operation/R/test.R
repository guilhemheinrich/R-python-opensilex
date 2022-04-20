USER <- "admin@opensilex.org"
PASSWORD <- "admin"
HOST <- "http://138.102.159.36:8081/rest"

opensilexClientToolsR::connectToOpenSILEX(identifier = USER,
                                          password = PASSWORD,
                                          url = HOST)

dataApi <- opensilexClientToolsR::DataApi$new()
data <- dataApi$count_data(experiments = uri, page_size = 1)