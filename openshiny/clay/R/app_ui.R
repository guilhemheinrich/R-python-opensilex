#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    # fluidPage(
    #   h1("clay"),
    #   h2("tst"),
    #   tabPanel("authentification", mod_authentification_ui("auth")),
    # )
    navbarPage("Clay golem",
               tabPanel("Authentification", mod_authentification_ui("auth")),
               tabPanel("Experiment", mod_experiment_explorer_ui("experiment")),
               tabPanel("Scientific Objects", mod_scientific_object_explorer_ui("so")),
               tabPanel("Scientific Objects Types", mod_scientific_object_type_explorer_ui("so_type")),
               tabPanel("Experiments Data", mod_experiment_explorer_ui("experiments_data")),
               tabPanel("Data", mod_data_explorer_ui("data")),
               tabPanel("Events", mod_scientific_object_explorer_ui("event")),
               tabPanel("TEST",mod_TEST_ui("TEST_ui_1"))
    )
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(ext='png'),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'clay'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

