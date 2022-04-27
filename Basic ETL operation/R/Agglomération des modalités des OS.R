source("./retry_once.R")
source('getToken.R')
agglo_mod_os <-
  function(host,
           user,
           password,
           experiments_uri,
           scientific_object_type) {
    
    opensilexClientToolsR::connectToOpenSILEX(identifier = user,
                                              password = password,
                                              url = host)
    #    ______         _
    #   |  ____|       | |
    #   | |__ __ _  ___| |_ ___  _ __
    #   |  __/ _` |/ __| __/ _ \| '__|
    #   | | | (_| | (__| || (_) | |
    #   |_|  \__,_|\___|\__\___/|_|
    #
    #
    
    # Factors level, bounded to experiment
    # Not directly needed
    # Package try, FAIL (To much mess)
    
    # experimentsApi <-
    #   opensilexClientToolsR::ExperimentsApi$new()
    # result <-
    #   retry_once(
    #     experimentsApi$get_available_factors,
    #     "sixtine:set/experiments#qualite-du-fruit-2017"
    #   )$data
    # result_df <-
    #   rbind(
    #     clay::EnvironmentList_to_dataframe(result),
    #     clay::EnvironmentList_to_dataframe(result, "levels")
    #   )
    # for (experiment_uri in experiments_uri) {
    #   factors <- tryCatch({
    #     result <-
    #       retry_once(experimentsApi$get_available_factors, experiment_uri)$data
    #     clay::EnvironmentList_to_dataframe(result)
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
    # }
    
    # Raw try
    token <- getToken(host = host, user = user, password = password)
    
    
    factors_per_experiments <- list()
    for (experiment_uri in experiments_uri) {
      factor_info <- tryCatch({
        call1 <-
          paste(
            host,
            "core/experiments",
            URLencode(experiment_uri, reserved = TRUE),
            "factors",
            sep = "/"
          )
        get_result <-
          httr::GET(call1, httr::add_headers(Authorization = token))
        get_result_text <- httr::content(get_result, "text")
        get_result_json <-
          jsonlite::fromJSON(get_result_text, flatten = TRUE)
        factors <- get_result_json$result$uri
        names(factors) <- get_result_json$result$name
        factors_level <- get_result_json$result$levels
        names(factors_level) <- factors
        list(factors_level = factors_level, factors_name = factors)
      },
      error = function(cond) {
        message("Here's the original error message:")
        message(cond)
        # Choose a return value in case of error
        return(NULL)
      },
      warning = function(cond) {
        message("Here's the original warning message:")
        message(cond)
        # Choose a return value in case of warning
        return(NULL)
      })
      
      if (!is.null(factor_info)) {
        factors_per_experiments[[experiment_uri]] <- factor_info
      }
    }
    
    
    #     _____      _            _   _  __ _          ____  _     _           _
    #    / ____|    (_)          | | (_)/ _(_)        / __ \| |   (_)         | |
    #   | (___   ___ _  ___ _ __ | |_ _| |_ _  ___   | |  | | |__  _  ___  ___| |_
    #    \___ \ / __| |/ _ \ '_ \| __| |  _| |/ __|  | |  | | '_ \| |/ _ \/ __| __|
    #    ____) | (__| |  __/ | | | |_| | | | | (__   | |__| | |_) | |  __/ (__| |_
    #   |_____/ \___|_|\___|_| |_|\__|_|_| |_|\___|   \____/|_.__/| |\___|\___|\__|
    #                                                            _/ |
    #                                                           |__/
    so_per_experiments <- list()
    scientificObjectsApi <-
      opensilexClientToolsR::ScientificObjectsApi$new()
    result <-
      scientificObjectsApi$search_scientific_objects(experiment = experiments_uri[1], rdf_types = scientific_object_type)$data
    so_uri <-
      clay::EnvironmentList_to_dataframe(result, "name", "uri")
    for (experiment_uri in experiments_uri) {
      scientific_objects <- tryCatch({
        result <-
          retry_once(
            scientificObjectsApi$search_scientific_objects,
            experiment = experiment_uri,
            rdf_types = scientific_object_type
          )$data
        so_uri <-
          clay::EnvironmentList_to_dataframe(result, "name", "uri")
        so_uri
      },
      error = function(cond) {
        # Choose a return value in case of error
        return(NULL)
      },
      warning = function(cond) {
        message(paste("URL caused a warning:", url))
        message("Here's the original warning message:")
        message(cond)
        # Choose a return value in case of warning
        return(NULL)
      })
      if (!is.null(scientific_objects)) {
        so_per_experiments[[experiment_uri]] <- scientific_objects
      }
    }
    
    # SO detail
    # Package not working
    
    # experiment_uri <- experiments_uri[1]
    # SOs_uri <- so_per_experiments[[experiment_uri]]$uri
    # so_uri <- SOs_uri[1]
    # scientificObjectsApi$get_scientific_object_detail(    uri = so_uri,
    #                                                       experiment = experiment_uri)
    # result <-
    #   retry_once(
    #     scientificObjectsApi$get_scientific_object_detail,
    #     uri = so_uri,
    #     experiment = experiment_uri
    #   )$data
    # for (experiment_uri in experiments_uri) {
    #   SOs_uri <- so_per_experiments[[experiment_uri]]$uri
    #   for (so_uri in SOs_uri) {
    #     so_detail <- tryCatch({
    #       result <-
    #         retry_once(
    #           scientificObjectsApi$get_scientific_object_detail,
    #           uri = so_uri,
    #           experiment = experiment_uri
    #         )$data
    #       result
    #     },
    #     error = function(cond) {
    #       # Choose a return value in case of error
    #       return(NULL)
    #     },
    #     warning = function(cond) {
    #       message(paste("URL caused a warning:", url))
    #       message("Here's the original warning message:")
    #       message(cond)
    #       # Choose a return value in case of warning
    #       return(NULL)
    #     })
    #   }
    #   if (!is.null(so_detail)) {
    #   }
    # }
    
    # Raw method
    detail_per_so <-
      data.frame(
        SO_uri = character(),
        name = character(),
        property_type = character(),
        property_value = character(),
        experiment_uri = character()
      )
    
    token <- getToken(host = host, user = user, password = password)
    
    for (experiment_uri in experiments_uri) {
      SOs_uri <- so_per_experiments[[experiment_uri]]$uri
      for (so_uri in SOs_uri) {
        so_detail <- tryCatch({
          call1 <-
            paste(
              host,
              "/core/scientific_objects/",
              URLencode(so_uri, reserved = TRUE),
              "?",
              "experiment=",
              URLencode(experiment_uri, reserved = TRUE),
              "&page_size=10000",
              sep = ""
            )
          get_result <-
            httr::GET(call1, httr::add_headers(Authorization = token))
          get_result_text <- httr::content(get_result, "text")
          get_result_json <-
            jsonlite::fromJSON(get_result_text, flatten = TRUE)
          get_result_json$result
        },
        error = function(cond) {
          # Choose a return value in case of error
          return(NULL)
        },
        warning = function(cond) {
          message(paste("URL caused a warning:", url))
          message("Here's the original warning message:")
          message(cond)
          # Choose a return value in case of warning
          return(NULL)
        })
        if (!is.null(so_detail)) {
          # Lazyly select vocabulary:hasGermplasm and vocabulary:hasFactorLevel property
          # ! WARNING ! : any specialisation of vocabulary:hasGermplasm will not be recovered without a preceding ontology subclass check
          # Also consider we are checking the prefixed name of the property, which may lead to missing results...
          germplasm_properties <- c("vocabulary:hasGermplasm")
          factor_properties <- c("vocabulary:hasFactorLevel")
          # germplasm_index <- which(so_detail$relations$property == "vocabulary:hasGermplasm")
          # factor_index <- which(so_detail$relations$property == "vocabulary:hasFactorLevel")
          germplasm_index <-
            which(so_detail$relations$property %in% germplasm_properties)
          factor_index <-
            which(so_detail$relations$property %in% factor_properties)
          germplasm_values <-
            so_detail$relations$value[germplasm_index]
          factor_values <- so_detail$relations$value[factor_index]
          for (element in germplasm_values) {
            new_row <-
              c(
                SO_uri = so_uri,
                name = so_detail$name,
                property_type = "germplasm",
                property_value = element,
                experiment_uri = experiment_uri
              )
            detail_per_so[nrow(detail_per_so) + 1, ] <- new_row
            # detail_per_so <- rbind(detail_per_so, new_row)
          }
          for (element in factor_values) {
            new_row <-
              c(
                SO_uri = so_uri,
                name = so_detail$name,
                property_type = "factor level",
                property_value = element,
                experiment_uri = experiment_uri
              )
            detail_per_so[nrow(detail_per_so) + 1, ] <- new_row
            # detail_per_so <- rbind(detail_per_so, new_row)
          }
        } else {
          print(paste(
            "No info on SO ",
            so_uri,
            "within experiment ",
            experiment_uri
          ))
        }
      }
    }
    return(detail_per_so)
  }


