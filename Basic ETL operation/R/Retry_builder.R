library(opensilexClientToolsR)

# On pourrait créer un environment spéciqfique à cette fonction

build_retryer <-  function(url, user, password) {
  retry_once <- function(func, ...) {
    args = list(...)
    message("user", user)
    # From <https://stackoverflow.com/a/12195574>
    out <- tryCatch({
      message("right here")
      opensilexClientToolsR::connectToOpenSILEX(identifier = user,
                                     url = url,
                                     password = password)
      
      return(do.call(func, args))
    },
    error = function(cond) {
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning = function(cond) {
      message("Here's the original warning message:")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally = {
      # NOTE:
      # Here goes everything that should be executed at the end,
      # regardless of success or error.
      # If you want more than one expression to be executed, then you
      # need to wrap them in curly brackets ({...}); otherwise you could
      # just have written 'finally=<expression>'
      message("Some other message at the end")
    })
    return(out)
  }
  return(retry_once)
}


testFunc <- function(a, b, c = "toto") {
  return(paste(c, "said that ", a, "+", b, "=", a + b))
}

retryer <-
  build_retryer(user = "admin",
                password = "admin",
                url = "http://138.102.159.36:8081/app/")

retryer
retryer(testFunc, a = 2, b = 3)
