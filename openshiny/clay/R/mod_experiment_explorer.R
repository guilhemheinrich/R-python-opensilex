library(opensilexClientToolsR)
#' experiment_explorer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_experiment_explorer_ui <- function(id) {
  ns <- NS(id)
  tagList(uiOutput(NS(id, "choix_so")))
}

#' experiment_explorer Server Functions
#'
#' @noRd
mod_experiment_explorer_server <-
  function(id, authentification_module) {
    moduleServer(id, function(input, output, session) {
      ns <- session$ns
      authentification_module()
      output$choix_so <- renderUI({
        experiments_api <- ExperimentsApi$new()
        experiments <- experiments_api$search_experiments()$data
        experiments_df <- EnvironmentList_to_dataframe(experiments)
        experimentList <- setNames(experiments_df$uri, experiments_df$name)
        
        selectInput(inputId = "choix_so",
                    label = "Choose an experiment:",
                    choices = experimentList)
      })
    })
  }

## To be copied in the UI
# mod_experiment_explorer_ui("experiment_explorer_ui_1")

## To be copied in the server
# mod_experiment_explorer_server("experiment_explorer_ui_1")
