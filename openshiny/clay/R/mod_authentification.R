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
    attempt_connect <- function() {
      tryCatch({
        # Just to highlight: if you want to use more than one
        # R expression in the "try" part then you'll have to
        # use curly brackets.
        # 'tryCatch()' will return the last evaluated expression
        # in case the "try" part was completed successfully
        
        
        # The return value of `readLines()` is the actual value
        # that will be returned in case there is no condition
        # (e.g. warning or error).
        # You don't need to state the return value via `return()` as code
        # in the "try" part is not wrapped inside a function (unlike that
        # for the condition handlers for warnings and error below)
        connection_result <-
          capture.output(
            connectToOpenSILEX(
              identifier = input$user,
              password = input$password,
              url = input$host
            )
          )
        output$terminal <- renderPrint({
          # print(connection_result)
          print(connection_result[1])
        })
        return(connection_result[2])
        
      },
      error = function(cond) {
        output$terminal <- renderPrint({
          print(cond)
        })
      },
      warning = function(cond) {
        output$terminal <- renderPrint({
          print(cond)
        })
      },
      finally = {
        # NOTE:
        # Here goes everything that should be executed at the end,
        # regardless of success or error.
        # If you want more than one expression to be executed, then you
        # need to wrap them in curly brackets ({...}); otherwise you could
        # just have written 'finally=<expression>'
      })
    }
    observeEvent(input$test, {
      attempt_connect()
    })
    return(attempt_connect)
  })
}

## To be copied in the UI
# mod_authentification_ui("authentification_ui_1")

## To be copied in the server
# mod_authentification_server("authentification_ui_1")
