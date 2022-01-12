user <- 'admin@opensilex.orga'
password <- 'admin'
host <- 'http://138.102.159.36:8081/rest'

evaluated <- evaluate::evaluate(connectToOpenSILEX(
  identifier = user,
  password = password,
  url = host
))
evaluated <- evaluate::try_capture_stack(capture.output(connectToOpenSILEX(
  identifier = user,
  password = password,
  url = host
)), environment())



test_list <- list(a = TRUE)
test_list <- list(a = FALSE)
test_list <- NULL
!is.null(test_list) && 'a' %in% names(test_list) && test_list$a
isTruthy(test_list$a)


