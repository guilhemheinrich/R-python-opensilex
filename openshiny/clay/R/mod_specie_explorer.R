#' specie_explorer UI Function
#'
#' @description A shiny::selectInput wrapper around SpeciesApi.get_all_species (\code{\link[opensilexClientToolsR:SpeciesApi]{ get_all_species }})
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @export
#' @param id Environment id of the module
#' @importFrom shiny NS tagList uiOutput
mod_specie_explorer_ui <- function(id){
  ns <- NS(id)
  tagList(
    shiny::uiOutput(NS(id, "choix"))
  )
}
    
#' specie_explorer Server Functions
#'
#' @export
#' @param id Internal parameter for {shiny}.
#' @param authentification_module Authentification module from this package (\code{\link{mod_authentification_server}})
#' @param api_function_options List of options to pass to SpeciesApi.get_all_species from opensilexClientToolsR package (\code{\link[opensilexClientToolsR:SpeciesApi]{ get_all_species }})
#' @param widget_options List of options to pass to \code{\link[shiny]{selectInput}}
#' @return A named list with various reactive values
#' \describe{
#'  \item{input}{The module input, to be used for binding events}
#'  \item{options}{The options used to call SpeciesApi.get_all_species }
#'  \item{selected}{The selection of the shiny::selectInput widget }
#'  \item{choices}{A named list containing the selection choices} 
#'  \item{result_df}{A dataframe containing the results of SpeciesApi.get_all_species call}
#' }
#' @importFrom shiny reactive renderUI
#' @importFrom stats setNames
mod_specie_explorer_server <-   function(id,
                                           authentification_module,
                                           api_function_options = list(),
                                           widget_options = list()) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    shiny::reactive({
      authentification_module$connect()
    })
    
    # Function to call when wanted actual values, in a reactive context
    function_options_reactive <- compute_reactive_in_list(api_function_options)
    widget_options_reactive <- compute_reactive_in_list(widget_options)

    itemList <- list()

    output$choix <- shiny::renderUI({
      # Compute reactive
      authentification_module$connect()
      final_options <<- function_options_reactive()
      # Custom code
      speciesApi <- SpeciesApi$new()
      result <-
        do.call(speciesApi$get_all_species, final_options)$data
      result_df <<-
        EnvironmentList_to_dataframe(result)
      itemList <<-
        stats::setNames(result_df$uri, result_df$name)
      
      label <- 'Choose a specie:'
      final_widget_options <- widget_options_reactive()
      final_widget_options[['inputId']] = ns("choix")

      # If the user specifies thoses values, we keep item
      # This allow easy use of the module by hiding its UI
      if (!('label' %in% names(final_widget_options))) {
        final_widget_options[['label']] = label
      }
      if (!('choices' %in% names(final_widget_options))) {
        final_widget_options[['choices']] = itemList
      }
      if (isTruthy(final_widget_options$multiple)) {
        label <- 'Choose one or more species:'
      }
      do.call(shiny::selectInput, final_widget_options)
    })
    
    reactiveitemList <- shiny::reactive({
      itemList
    })
    
    selected <- shiny::reactive({
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
        options = shiny::reactive({
          final_options
        }),
        selected = selected,
        choices = reactiveitemList,
        result_df = shiny::reactive({
          result_df
        })
      )
    )
  })
}