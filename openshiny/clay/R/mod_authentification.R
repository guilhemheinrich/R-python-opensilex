library(opensilexClientToolsR)

#' authentification UI Function
#'
#' @description The UI part of the module handling the connection to an opensilex instance. Required for all other module of this package.
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @export
#' @importFrom shiny NS tagList textInput passwordInput actionButton verbatimTextOutput
mod_authentification_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::textInput(NS(id, "host"), "Host", value = "http://138.102.159.36:8081/rest"),
    shiny::textInput(NS(id, "user"), "Username", value = "admin@opensilex.org"),
    shiny::passwordInput(NS(id, "password"), "Password",  value = "admin"),
    shiny::actionButton(NS(id, "test"), "Test connection"),
    shiny::verbatimTextOutput(NS(id, "terminal"))
  )
}

#' authentification Server Functions
#' 
#' @description The server part of the module handling the connection to an opensilex instance. Required for all other module of this package.
#' @param id Internal parameter for {shiny}.
#' @return A named list with various reactive values
#' \describe{
#'  \item{connect}{A function handling the connection to an Opensilex WebAPI}
#'  \item{user}{The currently connected user}
#'  \item{password}{The current password}
#'  \item{host}{The current opensilex WebAPI host address}
#' }
#' @export
#' @importFrom shiny renderPrint reactive observeEvent
#' @importFrom evaluate try_capture_stack evaluate
#' @importFrom utils capture.output
mod_authentification_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    attempt_connect <- function() {
      print('Connecting...')
      print(paste0('User: ', input$user))
      print(paste0('url: ', input$host))
      result <- evaluate::try_capture_stack(utils::capture.output(opensilexClientToolsR::connectToOpenSILEX(
        identifier = input$user,
        password = input$password,
        url = input$host
      )), environment())
      if (!is.null(result) && 'message' %in% names(result)) {
        print('error')
        output$terminal <- shiny::renderPrint({
          print(result$message)
        })
      } else {
        print('all ok')
        output$terminal <- shiny::renderPrint({
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
    connect <- shiny::reactive({
      attempt_connect()
    })
    shiny::observeEvent(input$test, {
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
        output$terminal <- shiny::renderPrint({
          print(result$message)
        })
      } else {
        print('all ok')
        output$terminal <- shiny::renderPrint({
          print(result)
        })
      }
      print('All done')
    })

    return(list(
      connect = connect,
      user = shiny::reactive(input$user),
      password = shiny::reactive(input$password),
      host = shiny::reactive(input$host)
      ))
  })
}

