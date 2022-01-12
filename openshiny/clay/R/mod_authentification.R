
library(opensilexClientToolsR)

#' authentification UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_authentification_ui <- function(id) {
  ns <- NS(id)
  tagList(
    textInput(NS(id, "host"), "Host", value = "http://138.102.159.36:8081/rest"),
    textInput(NS(id, "user"), "Username", value = "admin@opensilex.org"),
    passwordInput(NS(id, "password"), "Password",  value = "admin"),
    actionButton(NS(id, "test"), "Test connection"),
    verbatimTextOutput(NS(id, "terminal"))
  )
}

#' authentification Server Functions
#'
#' @noRd
mod_authentification_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    reactive({ input$user })
    reactive({ input$password })
    reactive({ input$host })
    attempt_connect <- function() {
      print('Connecting...')
      print(paste0('User: ', input$user))
      print(paste0('url: ', input$host))
      result <- evaluate::try_capture_stack(capture.output(connectToOpenSILEX(
        identifier = input$user,
        password = input$password,
        url = input$host
      )), environment())
      if (!is.null(result) && 'message' %in% names(result)) {
        output$terminal <- renderPrint({
          print(result$message)
        })
      } else {
        output$terminal <- renderPrint({
          print(result)
        })
      }

    }
    connect <- reactive({
      attempt_connect()
    })
    
    # out <- reactiveValues(connection_result = NULL, connect_function = attempt_connect)
    observeEvent(input$test, {
      attempt_connect()
    })
    
    return(list(
      connect = connect,
      user = reactive(input$user),
      host = reactive(input$host)
      ))
  })
}

## To be copied in the UI
# mod_authentification_ui("authentification_ui_1")

## To be copied in the server
# mod_authentification_server("authentification_ui_1")
