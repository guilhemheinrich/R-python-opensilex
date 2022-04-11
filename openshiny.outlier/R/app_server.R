library(clay)
library(opensilexClientToolsR)
#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  authentification <- mod_authentification_server("auth")
  experiment <- mod_experiment_explorer_server("experiment", authentification, widget_options = list(multiple = FALSE))
  so <- clay::mod_scientific_object_type_explorer_server('so_type', authentification, api_function_options = list(experiment = experiment$selected))
  
  # data_df <- reactive({
  #   experiment <- experiment$selected()
  #   so_type <- so$selected()
  #   authentication_params = list(
  #     user = authentification$user(),
  #     password = authentification$password(),
  #     host = authentification$host()
  #   )
  #   print(experiment)
  #   print(so_type)
  #   get_data_by_experiment_and_sotype(experiment, so_type, authentication_params)
  # })
  
  
  shiny::observeEvent(input$test, {
      experiment <- experiment$selected()
      so_type <- so$selected()
      authentication_params = list(
        user = authentification$user(),
        password = authentification$password(),
        host = authentification$host()
      )
      print(experiment)
      print(so_type)
      data_df <- get_data_by_experiment_and_sotype(experiment, so_type, authentication_params)

      output$plot<-renderPlot({
        ggplot2::ggplot(data_df,
                        ggplot2::aes(x=date,y=value)) + ggplot2::geom_point(colour='red')
      },height = 400,width = 600)
    print('All done')
  })


  # shiny::observe({
  #   experiment <- experiment$selected()
  #   so_type <- so$selected()
  #   authentication_params = list(
  #     user = authentification$user(),
  #     password = authentification$password(),
  #     host = authentification$host()
  #   )
  #   
  #   # get_data_by_experiment_and_sotype(experiment, experiment, authentication_params)
  # })
  # so <- mod_scientific_object_explorer_server("so", authentification,  multiple = FALSE, options = list(experiment = experiment$selected))
  # event <- mod_event_explorer_server("event", authentification)
  # experiments_data <- mod_experiment_explorer_server("experiments_data", authentification, multiple = TRUE)
  # data <- mod_data_explorer_server("data", authentification, options = list(experiment = experiments_data$selected, page = 1))
  
}
