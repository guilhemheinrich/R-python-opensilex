source(file = "Agglomération des modalités des OS.R")
source(file = "Agglomération des données direct.R")
source('getToken.R')
routine <- function(experiments_uri, scientific_object_type, prefix) {
    
    result <- agglo_mod_os(
      host = configuration$host,
      user = configuration$user,
      password = configuration$password,
      experiments_uri = configuration$experiments_uri,
      scientific_object_type = configuration$scientific_object_type
    )
    write.csv(result,
              paste0("data\\", prefix, "__", scientific_object_type, "_os_modality.csv"),
              row.names = FALSE)
    
    
    result <- agglo_direct_data(
      host = configuration$host,
      user = configuration$user,
      password = configuration$password,
      experiments_uri = configuration$experiments_uri,
      scientific_object_type = configuration$scientific_object_type
    )
    write.csv(result,
              paste0("data\\", prefix, "__", scientific_object_type, "_direct_data.csv"),
              row.names = FALSE)
}




#   __          ________ _____  _____
#   \ \        / /  ____|_   _|/ ____|
#    \ \  /\  / /| |__    | | | (___
#     \ \/  \/ / |  __|   | |  \___ \
#      \  /\  /  | |____ _| |_ ____) |
#       \/  \/   |______|_____|_____/
#
#

#    _____                               _
#   |  __ \                             | |
#   | |__) |_ _ _ __ __ _ _ __ ___   ___| |_ ___ _ __ ___
#   |  ___/ _` | '__/ _` | '_ ` _ \ / _ \ __/ _ \ '__/ __|
#   | |  | (_| | | | (_| | | | | | |  __/ ||  __/ |  \__ \
#   |_|   \__,_|_|  \__,_|_| |_| |_|\___|\__\___|_|  |___/
#
#

WEIS <- list(
  prefix = "WEIS",
  user = "admin@opensilex.org",
  password = "admin",
  host = "http://138.102.159.36:8081/rest",
)


token <- getToken(user = WEIS$user, password = WEIS$password, host = WEIS$host)








