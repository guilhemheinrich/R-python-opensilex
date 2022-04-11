#' experiment_explorer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @export
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_experiment_explorer_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(NS(id, "choix"))
  )
}
    
#' experiment_explorer Server Functions
#'
#' @export
#' @noRd 
mod_experiment_explorer_server <-   function(id,
                                           authentification_module,
                                           options = list(),
                                           ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    reactive({
      authentification_module$connect()
    })
    
    options_reactive <- compute_reactive_in_list(options)
    input_parameters <- list(...)
    itemList <- list()
    output$choix <- renderUI({
      # Compute reactive
      authentification_module$connect()
      final_options <- options_reactive()
      # Custom code
      experimentsApi <- ExperimentsApi$new()
      result <-
        do.call(experimentsApi$search_experiments, final_options)$data
      result_df <-
        EnvironmentList_to_dataframe(result)
      itemList <<-
        setNames(result_df$uri, result_df$name)
      
      label <- 'Choose a experiment:'
      if (isTruthy(input_parameters$multiple)) {
        label <- 'Choose one or more experiments:'
      }
      
      selectInput(
        inputId = ns("choix"),
        label = label,
        choices = itemList,
        ...
      )
    })
    
    reactiveitemList <- reactive({
      itemList
    })
    
    selected <- reactive({
      if (length(itemList) > 0 &&
          match(input$choix, itemList) != 0) {
          out <- input$choix
        } else {
          out <- NA
        }
        return(out)
    })

    return(
      list(
        input = input,
        options = reactive({
          options
        }),
        selected = selected,
        choices = reactiveitemList
      )
    )
  })
}