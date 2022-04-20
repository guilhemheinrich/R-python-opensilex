retry_once <- function(func, ...) {
  args = list(...)
  final_call <- NULL
  # From <https://stackoverflow.com/a/12195574>
  out <- tryCatch({
    opensilexClientToolsR::connectToOpenSILEX(identifier = USER,
                                              url = HOST,
                                              password = PASSWORD)
    
    final_call <- do.call(func, args)
    return(final_call)
  },
  error = function(cond) {
    # Try once more
    tryCatch({
      opensilexClientToolsR::connectToOpenSILEX(identifier = USER,
                                                url = HOST,
                                                password = PASSWORD)
      
      final_call <- do.call(func, args)
      message("there")
      return(final_call)
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
    })
  },
  finally = {
    # NOTE:
    # Here goes everything that should be executed at the end,
    # regardless of success or error.
    # If you want more than one expression to be executed, then you
    # need to wrap them in curly brackets ({...}); otherwise you could
    # just have written 'finally=<expression>'
    message("\nSome other message at the end")
  })
  
  if (!is.null(final_call)) {
    return(final_call)
  }
  return(out)
}