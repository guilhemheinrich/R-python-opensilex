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

  tagList(
    uiOutput(NS(id, "choix_experiment"))
  )
}

#' experiment_explorer Server Functions
#'
#' @noRd
mod_experiment_explorer_server <-
  function(id, authentification_module, ...) {
    moduleServer(id, function(input, output, session) {
      ns <- session$ns
      reactive({
        authentification_module$connect()
      })
      output$choix_experiment <- renderUI({
        authentification_module$connect()
        experiments_api <- ExperimentsApi$new()
        experiments <- experiments_api$search_experiments()$data
        experiments_df <- EnvironmentList_to_dataframe(experiments)
        experimentList <- setNames(experiments_df$uri, experiments_df$name)
        
        input_parameters <- list(...)
        label <- 'Choose an experiment:'
        if (isTruthy(input_parameters$multiple)) {
          label <- 'Choose one or more experiments:'
        }
        
        selectInput(inputId = "choix_experiment",
                    label = "Choose an experiment:",
                    choices = experimentList,
                    ...)
      })
      return(list(
        selected = reactive(input$choix_experiment),
        choices = reactive(experimentList)
        ))
    })
  }

## To be copied in the UI
# mod_experiment_explorer_ui("experiment_explorer_ui_1")

## To be copied in the server
# mod_experiment_explorer_server("experiment_explorer_ui_1")
