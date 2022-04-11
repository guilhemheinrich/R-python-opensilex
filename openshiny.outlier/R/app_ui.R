library(shinydashboard)
library(clay)
library(opensilexClientToolsR)
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
    
    # dashboardPage(
    #   dashboardHeader(title = "Outlier detection"),
    #
    #   dashboardSidebar(sidebarUserPanel(
    #     "User Name",
    #     subtitle = a(href = "#", icon("circle", class = "text-success"), "Online"),
    #   )),
    #
    #   dashboardBody()
    # )
    
    
    # dashboardPage(
    #   dashboardHeader(title = "Outlier detection"),
    #
    #   dashboardSidebar(clay::mod_authentification_server("auth")),
    #
    #   dashboardBody()
    # )
    
    
    shinydashboard::dashboardPage(
      shinydashboard::dashboardHeader(title = "Outlier detection"),
      shinydashboard::dashboardSidebar(
        shinydashboard::sidebarMenu(
          id = "tabs",
          menuItem("Authentification", tabName = "authentification", clay::mod_authentification_ui("auth")),
          
          # clay::mod_authentification_ui("auth"),
          clay::mod_experiment_explorer_ui('experiment'),
          clay::mod_scientific_object_type_explorer_ui('so_type'),
          shiny::actionButton("test", "Test data")
          
          # sidebarUserPanel(
          #       "User Name",
          #       subtitle = a(href = "#", icon("circle", class = "text-success"), "Online"),
          #     )
          # clay::mod_authentification_ui("auth"),
          # clay::mod_experiment_explorer_ui('experiment')  ),
          
        )
      ),
      shinydashboard::dashboardBody(h1("lol"),
                                    shiny::plotOutput("plot"))
    )
    # navbarPage(
    #   "Clay golem MOCK",
    #   tabPanel("Authentification", mod_authentification_ui("auth")),
    #   tabPanel("Experiment", mod_experiment_explorer_ui("experiment")),
    #   tabPanel(
    #     "Scientific Objects",
    #     mod_scientific_object_explorer_ui("so")
    #   ),
    #   tabPanel(
    #     "Experiments Data",
    #     mod_experiment_explorer_ui("experiments_data")
    #   ),
    #   tabPanel("Data", mod_data_explorer_ui("data")),
    #   tabPanel("Events", mod_scientific_object_explorer_ui("event"))
    # )
    
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
golem_add_external_resources <- function() {
  add_resource_path('www', app_sys('app/www'))
  
  tags$head(favicon(),
            bundle_resources(path = app_sys('app/www'),
                             app_title = 'openshiny.outlier')
            # Add here other external resources
            # for example, you can add shinyalert::useShinyalert() ))
            )
}
