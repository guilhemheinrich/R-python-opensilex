#' scientific_object_explorer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_scientific_object_explorer_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(NS(id, "choix_so"))
  )
}
    
#' scientific_object_explorer Server Functions
#'
#' @noRd 
mod_scientific_object_explorer_server <- function(id, authentification_module, experiment_module){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    authentification_module()
    output$choix_so <- renderUI({
      experiments_api <- ExperimentsApi$new()
      experiments <- experiments_api$search_experiments()$data
      experiments_df <- EnvironmentList_to_dataframe(experiments)
      experimentList <- setNames(experiments_df$uri, experiments_df$name)
      
      selectInput(inputId = "choix_so",
                  label = "Choose a scientific object:",
                  choices = experimentList)
    })
    return(reactive(input$choix_so))
  })
}
    
## To be copied in the UI
# mod_scientific_object_explorer_ui("scientific_object_explorer_ui_1")
    
## To be copied in the server
# mod_scientific_object_explorer_server("scientific_object_explorer_ui_1")
