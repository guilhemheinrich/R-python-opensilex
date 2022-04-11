#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  authentification <- mod_authentification_server("auth")
  experiment <- mod_experiment_explorer_server("experiment", authentification, widget_options = list(multiple = FALSE))
  so <- mod_scientific_object_explorer_server("so", authentification,  widget_options = list(multiple = FALSE), api_function_options = list(experiment = experiment$selected))
  event <- mod_event_explorer_server("event", authentification)
  experiments_data <- mod_experiment_explorer_server("experiments_data", authentification, widget_options = list(multiple = TRUE))
  data <- mod_data_explorer_server("data", authentification, api_function_options = list(experiment = experiments_data$selected, page = 1))
  so_type <- mod_scientific_object_type_explorer_server("so_type", authentification,  widget_options = list(multiple = FALSE), api_function_options = list(experiment = experiment$selected))
  test <- mod_TEST_server("TEST_ui_1", so_type)
  
  # 
  # observe({
  #   selection <- experiment$selected()
  #   print(selection)
  #   # scientific_objects <-
  #   #   mod_scientific_object_explorer_server("so", authentification,  multiple = TRUE, option_search = list(experiment = selection()$value))
  # })
  # scientific_objects <- 
  #   mod_scientific_object_explorer_server("so", authentification,  multiple = TRUE, option_search = list(experiment = selection()$value))

  
  
  # observeEvent(input$reset, {
  #   print(environment())
  #   print(ls())
  #   print(experiment$selected())
  #   scientific_objects <-
  #     mod_scientific_object_explorer_server("so", authentification,  multiple = TRUE, option_search = list(experiment = experiment$selected()$value))
  #   test <- mod_TEST_server("test", experiment, option = list(scientific_objects))
  # })
  

 
  
  # observeEvent(experiment$selected, {
  #   experiment$selected
  #   print("experiment$options")
  #   print(experiment$options())
  #   print("experiment$choices")
  #   print(experiment$choices())
  #   print("experiment$selected")
  #   print(experiment$selected())
  # })
  

}
