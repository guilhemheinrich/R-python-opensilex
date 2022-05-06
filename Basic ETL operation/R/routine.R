source(file = "Agglomération expérimentations.R")
source(file = "Agglomération des modalités des OS.R")
source(file = "Agglomération des modalités des OS packageless.R")
source(file = "Agglomération des modalités des OS CSV import.R")
source(file = "Agglomération des données direct.R")
source(file = "Agglomération des données direct CSV import.R")
source(file = "Agglomération des données direct CSV import parameterless.R")

routine <- function(configuration,
                    routine_configuration = list(
                      agglo_experiment = TRUE,
                      agglo_mod_os = TRUE,
                      agglo_direct_data = TRUE,
                      agglo_mod_os_packageless = TRUE,
                      agglo_mod_os_CSV = TRUE,
                      agglo_direct_data_CSV = TRUE,
                      agglo_direct_data_CSV_parameterless = TRUE
                    ),
                    profiling = FALSE) {
  print(routine_configuration)
  internal_routine <- function() {
    if (routine_configuration$agglo_experiment) {
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
    }
    
    if (routine_configuration$agglo_mod_os) {
      result <- agglo_mod_os(
        host = configuration$host,
        user = configuration$user,
        password = configuration$password,
        experiments_uri = configuration$experiments_uri,
        scientific_object_type = configuration$scientific_object_type
      )
      write.csv(
        result,
        paste0("data\\", configuration$prefix, "_os_modality.csv"),
        row.names = FALSE
      )
    }
    
    if (routine_configuration$agglo_direct_data) {
      print('start agglo direct data start')
      result <- agglo_direct_data(
        host = configuration$host,
        user = configuration$user,
        password = configuration$password,
        experiments_uri = configuration$experiments_uri,
        scientific_object_type = configuration$scientific_object_type
      )
      write.csv(
        result,
        paste0("data\\", configuration$prefix, "_direct_data.csv"),
        row.names = FALSE
      )
      print('finished agglo direct data start')
    }
    
    if (routine_configuration$agglo_direct_data_CSV) {
      print('start agglo direct data start CSV')
      result <- agglo_data_import(
        host = configuration$host,
        user = configuration$user,
        password = configuration$password,
        experiment_uri = configuration$experiments_uri[1],
        scientific_object_type = configuration$scientific_object_type
      )
      write.csv(
        result,
        paste0("data\\", configuration$prefix, "_direct_data_csv.csv"),
        row.names = FALSE
      )
      print('finished agglo direct data start CSV')
    }
    
    if (routine_configuration$agglo_direct_data_CSV_parameterless) {
      print('start agglo direct data start CSV without SO uris (url parameter)')
      result <- agglo_data_import_parameterless(
        host = configuration$host,
        user = configuration$user,
        password = configuration$password,
        experiment_uri = configuration$experiments_uri[1],
        scientific_object_type = configuration$scientific_object_type
      )
      write.csv(
        result,
        paste0("data\\", configuration$prefix, "_direct_data_csv_parameterless.csv"),
        row.names = FALSE
      )
      print('finished agglo direct data start CSV without SO uris (url parameter)')
    }
    
    if (routine_configuration$agglo_mod_os_packageless) {
      result <- agglo_mod_os_packageless(
        host = configuration$host,
        user = configuration$user,
        password = configuration$password,
        experiments_uri = configuration$experiments_uri,
        scientific_object_type = configuration$scientific_object_type
      )
      write.csv(
        result,
        paste0(
          "data\\",
          configuration$prefix,
          "_os_modality_packageless.csv"
        ),
        row.names = FALSE
      )
    }
    
    if (routine_configuration$agglo_mod_os_CSV) {
      result <- agglo_mod_os_import(
        host = configuration$host,
        user = configuration$user,
        password = configuration$password,
        experiment_uri = configuration$experiments_uri[1],
        scientific_object_type = configuration$scientific_object_type
      )
      write.csv(
        result,
        paste0("data\\", configuration$prefix, "_os_modality_csv.csv"),
        row.names = FALSE
      )
    }
  }
  
  if (profiling) {
    profvis::profvis({
      internal_routine()
    })
  } else {
    internal_routine()
  }
}