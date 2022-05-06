source(file = "Agglomération des modalités des OS.R")
source(file = "Agglomération des modalités des OS packageless.R")

PREFIX = "TEST2_AGGLO_OS_SIXTINE"

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

profvis::profvis({
packageless_result <- agglo_mod_os_packageless(SIXTINE$host, SIXTINE$user, SIXTINE$password, SIXTINE$experiments_uri, SIXTINE$scientific_object_type)

write.csv(
  packageless_result ,
  paste0(
    "data\\", PREFIX, "_packageless.csv"
  ),
  row.names = FALSE
)


  result <- agglo_mod_os(SIXTINE$host, SIXTINE$user, SIXTINE$password, SIXTINE$experiments_uri, SIXTINE$scientific_object_type)


  write.csv(
    result ,
    paste0(
      "data\\TEST_AGGLO_OS_SIXTINE.csv"
    ),
    row.names = FALSE
  )
})

