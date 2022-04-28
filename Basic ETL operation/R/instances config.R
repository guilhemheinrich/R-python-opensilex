source(file = "Agglomération expérimentations.R")
source(file = "Agglomération des modalités des OS.R")
source(file = "Agglomération des données direct.R")

routine <- function(configuration) {
  profvis::profvis({
    result <- agglo_experiment(
      host = configuration$host,
      user = configuration$user,
      password = configuration$password
    )
    write.csv(
      result$data_card_DT ,
      paste0(
        "data\\",
        configuration$prefix,
        "_overview_data_count_per_experiment.csv"
      ),
      row.names = FALSE
    )
    write.csv(
      result$final_dt ,
      paste0("data\\", configuration$prefix, "_overview.csv"),
      row.names = FALSE
    )
    
    result <- agglo_mod_os(
      host = configuration$host,
      user = configuration$user,
      password = configuration$password,
      experiments_uri = configuration$experiments_uri,
      scientific_object_type = configuration$scientific_object_type
    )
    write.csv(result,
              paste0("data\\", configuration$prefix, "_os_modality.csv"),
              row.names = FALSE)
    
    
    result <- agglo_direct_data(
      host = configuration$host,
      user = configuration$user,
      password = configuration$password,
      experiments_uri = configuration$experiments_uri,
      scientific_object_type = configuration$scientific_object_type
    )
    write.csv(result,
              paste0("data\\", configuration$prefix, "_direct_data.csv"),
              row.names = FALSE)
  })
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
  experiments_uri =   c(
    "http://www.opensilex.org/weis/WS2019-2",
    "http://www.opensilex.org/weis/WS2017-1"
  ),
  scientific_object_type = "http://www.opensilex.org/vocabulary/oeso-weis#Process"
)

routine(WEIS)
#     _____ _      _   _
#    / ____(_)    | | (_)
#   | (___  ___  _| |_ _ _ __   ___
#    \___ \| \ \/ / __| | '_ \ / _ \
#    ____) | |>  <| |_| | | | |  __/
#   |_____/|_/_/\_\\__|_|_| |_|\___|
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
SIXTINE <- list(
  prefix = "SIXTINE",
  user = "admin@opensilex.org",
  password = "admin",
  host = "https://sixtine.mistea.inrae.fr/rest",
  experiments_uri =   c(
    "sixtine:set/experiments#qualite-du-fruit-2017",
    "sixtine:set/experiments#resintbio"
  ),
  scientific_object_type = "http://www.opensilex.org/vocabulary/oeso#SubPlot"
)

routine(SIXTINE)
