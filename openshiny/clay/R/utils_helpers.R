#' Compute reactive value in list 
#'
#' @description Given a list of items, calculate the actual value of the item in the list. It is a helper function to get the value of shiny::reactive value, and then need to be use in a reactive function. If the item is an R litteral, then this function returns it as it is. 
#' @param options The list to calculate values over
#' @return The list of the calculated values
#'
#' @export
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
