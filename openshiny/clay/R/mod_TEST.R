#' TEST UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList verbatimTextOutput
mod_TEST_ui <- function(id){
  ns <- NS(id)
  tagList(
    verbatimTextOutput(NS(id, "terminal"))
  )
}
    
#' TEST Server Functions
#'
#' @noRd 
mod_TEST_server <- function(id, object){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    output$terminal <- renderPrint({
      compute_reactive_in_list(object)()
    })
  })
}
    
## To be copied in the UI
# mod_TEST_ui("TEST_ui_1")
    
## To be copied in the server
# mod_TEST_server("TEST_ui_1")
