source("./routine.R")

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

routine(
  WEIS,
  routine_configuration = list(
    agglo_experiment = FALSE,
    agglo_mod_os = FALSE,
    agglo_direct_data = TRUE,
    agglo_mod_os_packageless = FALSE,
    agglo_mod_os_CSV = FALSE
  )
)
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

routine(
  SIXTINE,
  routine_configuration = list(
    agglo_experiment = FALSE,
    agglo_mod_os = FALSE,
    agglo_direct_data = TRUE,
    agglo_mod_os_packageless = FALSE,
    agglo_mod_os_CSV = FALSE
  ),
  profiling = TRUE
)


SIXTINE_BIS <- list(
  prefix = "SIXTINE_BIS",
  user = "admin@opensilex.org",
  password = "admin",
  host = "https://sixtine.mistea.inrae.fr/rest",
  experiments_uri = "sixtine:set/experiments#resintbio",
  scientific_object_type = "http://www.opensilex.org/vocabulary/oeso#SubPlot"
)

routine(
  SIXTINE_BIS,
  routine_configuration = list(
    agglo_experiment = FALSE,
    agglo_mod_os = FALSE,
    agglo_direct_data = TRUE,
    agglo_mod_os_packageless = FALSE,
    agglo_mod_os_CSV = FALSE,
    agglo_direct_data_CSV = TRUE,
    agglo_direct_data_CSV_parameterless = TRUE
  ),
  profiling = TRUE
)
