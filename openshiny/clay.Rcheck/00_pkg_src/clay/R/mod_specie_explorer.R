#' specie_explorer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @export
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_specie_explorer_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(NS(id, "choix"))
  )
}
    
#' specie_explorer Server Functions
#'
#' @export
#' @noRd 
mod_specie_explorer_server <-   function(id,
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
      speciesApi <- SpeciesApi$new()
      result <-
        do.call(speciesApi$get_all_species, final_options)$data
      result_df <-
        EnvironmentList_to_dataframe(result)
      itemList <<-
        setNames(result_df$uri, result_df$name)
      
      label <- 'Choose a specie:'
      if (isTruthy(input_parameters$multiple)) {
        label <- 'Choose one or more species:'
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