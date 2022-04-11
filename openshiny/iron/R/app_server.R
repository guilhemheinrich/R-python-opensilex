#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  authentification_module <- clay::mod_authentification_server("auth")
  overview <- mod_overview_server("quick", authentification_module)
}
