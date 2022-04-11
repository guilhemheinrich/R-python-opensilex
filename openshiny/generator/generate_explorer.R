library(whisker)
library(snakecase)


templateFile <- 'template.mustache'
template <- readChar(templateFile, file.info(templateFile)$size)
generate_explorer <- function(entity, api_call, function_call) {
  config <- list(entity = to_snake_case(entity),
                 api_call = api_call,
                 function_call = function_call)
  final_config <- c(
    config,
    api_instance = to_lower_camel_case(config$api_call),
    module_name = paste0(config$entity, "_explorer")
  )
  codegen <- whisker.render(template, final_config)
  output_file_name <- paste0("mod_", final_config$module_name, ".R")
  
  dir.create("generated", showWarnings = FALSE)
  sink(paste0("generated/",output_file_name))
  cat(codegen)
  sink()
}

