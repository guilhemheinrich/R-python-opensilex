library(opensilexClientToolsR)

#' variable_explorer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_variable_explorer_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(NS(id, "choix_variable"))
  )
}
    
#' variable_explorer Server Functions
#'
#' @noRd 
mod_variable_explorer_server <- function(id, authentification_module, experiment_module){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    authentification_module()
  })
}
    
## To be copied in the UI
# mod_variable_explorer_ui("variable_explorer_ui_1")
    
## To be copied in the server
# mod_variable_explorer_server("variable_explorer_ui_1")
