library(opensilexClientToolsR)

#' authentification UI Function
#'
#' @description A shiny Module.
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @export
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
#' @export
#' @noRd
mod_authentification_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    attempt_connect <- function() {
      print('Connecting...')
      print(paste0('User: ', input$user))
      print(paste0('url: ', input$host))
      result <- evaluate::try_capture_stack(capture.output(opensilexClientToolsR::connectToOpenSILEX(
        identifier = input$user,
        password = input$password,
        url = input$host
      )), environment())
      if (!is.null(result) && 'message' %in% names(result)) {
        print('error')
        output$terminal <- renderPrint({
          print(result$message)
        })
      } else {
        print('all ok')
        output$terminal <- renderPrint({
          print(result)
        })
      }
      evaluate::evaluate(opensilexClientToolsR::connectToOpenSILEX(
                identifier = input$user,
                password = input$password,
                url = input$host
              ), environment())
      print('All done')
    }
    connect <- reactive({
      attempt_connect()
    })
    observeEvent(input$test, {
      print('Connecting...')
      print(paste0('User: ', input$user))
      print(paste0('url: ', input$host))
      result <- evaluate::try_capture_stack(capture.output(opensilexClientToolsR::connectToOpenSILEX(
        identifier = input$user,
        password = input$password,
        url = input$host
      )), environment())
      if (!is.null(result) && 'message' %in% names(result)) {
        print('error')
        output$terminal <- renderPrint({
          print(result$message)
        })
      } else {
        print('all ok')
        output$terminal <- renderPrint({
          print(result)
        })
      }
      print('All done')
    })

    return(list(
      connect = connect,
      user = reactive(input$user),
      host = reactive(input$host)
      ))
  })
}

