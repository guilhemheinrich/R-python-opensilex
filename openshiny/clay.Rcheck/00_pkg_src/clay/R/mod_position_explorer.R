#' position_explorer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @export
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_position_explorer_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(NS(id, "choix"))
  )
}
    
#' position_explorer Server Functions
#'
#' @export
#' @noRd 
mod_position_explorer_server <-   function(id,
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
      positionsApi <- PositionsApi$new()
      result <-
        do.call(positionsApi$search_position_history, final_options)$data
      result_df <-
        EnvironmentList_to_dataframe(result)
      itemList <<-
        setNames(result_df$uri, result_df$name)
      
      label <- 'Choose a position:'
      if (isTruthy(input_parameters$multiple)) {
        label <- 'Choose one or more positions:'
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