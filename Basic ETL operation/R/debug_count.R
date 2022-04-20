data_count_debug <- function(start_date,end_date,timezone,experiments,targets,variables,devices,min_confidence,max_confidence,provenances,metadata,...){
  args <- list(...)
  queryParams <- list()
  headerParams <- character()
  self$apiClient$basePath =  sub("/$", "",get("BASE_PATH",opensilexWSClientR:::configWS))
  if(self$apiClient$basePath == ""){
    stop("Wrong you must first connect with connectToOpenSILEX")
  }
  
  #if (!missing(`authorization`)) {
  #  headerParams[['Authorization']] <- authorization
  #}
  #if (!missing(`accept_language`)) {
  #  headerParams[['Accept-Language']] <- accept_language
  #}
  
  if (!missing(`start_date`)) {
    for (item in start_date) {
      to_add <- list(item)
      names(to_add) <- "start_date"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['start_date']] <- start_date
  }
  
  if (!missing(`end_date`)) {
    for (item in end_date) {
      to_add <- list(item)
      names(to_add) <- "end_date"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['end_date']] <- end_date
  }
  
  if (!missing(`timezone`)) {
    for (item in timezone) {
      to_add <- list(item)
      names(to_add) <- "timezone"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['timezone']] <- timezone
  }
  print("Before adding experiments")
  if (!missing(`experiments`)) {
    for (item in experiments) {
      to_add <- list(item)
      names(to_add) <- "experiments"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['experiments']] <- experiments
  }
  print("After adding experiments")
  if (!missing(`targets`)) {
    for (item in targets) {
      to_add <- list(item)
      names(to_add) <- "targets"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['targets']] <- targets
  }
  
  if (!missing(`variables`)) {
    for (item in variables) {
      to_add <- list(item)
      names(to_add) <- "variables"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['variables']] <- variables
  }
  
  if (!missing(`devices`)) {
    for (item in devices) {
      to_add <- list(item)
      names(to_add) <- "devices"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['devices']] <- devices
  }
  
  if (!missing(`min_confidence`)) {
    for (item in min_confidence) {
      to_add <- list(item)
      names(to_add) <- "min_confidence"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['min_confidence']] <- min_confidence
  }
  
  if (!missing(`max_confidence`)) {
    for (item in max_confidence) {
      to_add <- list(item)
      names(to_add) <- "max_confidence"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['max_confidence']] <- max_confidence
  }
  
  if (!missing(`provenances`)) {
    for (item in provenances) {
      to_add <- list(item)
      names(to_add) <- "provenances"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['provenances']] <- provenances
  }
  
  if (!missing(`metadata`)) {
    for (item in metadata) {
      to_add <- list(item)
      names(to_add) <- "metadata"
      queryParams <- append(queryParams, to_add)
    }
    
    # queryParams[['metadata']] <- metadata
  }
  
  
  
  urlPath <- "/core/data/count"
  resp <- self$apiClient$callApi(url = paste0(self$apiClient$basePath, urlPath),
                                 method = "GET",
                                 queryParams = queryParams,
                                 headerParams = headerParams,
                                 body = body,
                                 ...)
  method = "GET"
  if (httr::status_code(resp) >= 200 && httr::status_code(resp) <= 299) {
    
    if(method == "GET"){
      json <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
      data <- json$result
      returnedOjects = list()
      for(i in 1:nrow(data)){
        row <- data[i,]
        returnObject <- Integer$new()
        returnObject$fromJSONObject(row)
        returnedOjects = c(returnedOjects,returnObject)
      }
      return(Response$new(json$metadata,returnedOjects, resp, TRUE))
    }
    if(method == "POST" || method == "PUT"){
      json <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
      return(Response$new(json$metadata, json$metadata$datafiles, resp, TRUE))
    }
  } else if (httr::status_code(resp) >= 400 && httr::status_code(resp) <= 499) {
    json <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
    return(Response$new(json$metadata, json, resp, FALSE))
  } else if (httr::status_code(resp) >= 500 && httr::status_code(resp) <= 599) {
    json <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
    return(Response$new(json$metadata, json, resp, FALSE))
  }
  
}