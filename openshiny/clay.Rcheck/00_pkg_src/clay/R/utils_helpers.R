#' helpers 
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
compute_reactive_in_list <- function(options) {
  return(reactive({
    print('computing reactive')
    out <- list()
    if (is.list(options) && length(options) > 0) {
      for (index in 1:length(options)) {
        # In case of reactive value
        name <- names(options)[[index]]
        print(name)
        if ('reactive' %in% class(options[[index]])) {
          calc_value <- options[[index]]()
          print("reactive calculated value")
          print(calc_value)
          out[[name]] <- calc_value
        } else {
          print("static value")
          print(options[[index]])
          out[[name]] <- options[[index]]
        }
      }
    }
    print('computation over')
    return(out)
  }))
}
