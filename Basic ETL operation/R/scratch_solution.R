
USER <- "admin@opensilex.org"
PASSWORD <- "admin"
HOST <- "http://138.102.159.36:8081/rest"

call0 <- paste(HOST, "/security/authenticate", sep="")
post_authenticate <- httr::POST(call0, body = '{
  "identifier": "admin@opensilex.org",
  "password": "admin"
}', httr::add_headers(`Content-Type` = "application/json", Accept = "application/json"))


post_authenticate_text <- httr::content(post_authenticate, "text")
post_authenticate_json <- jsonlite::fromJSON(post_authenticate_text, flatten = TRUE)
token <- post_authenticate_json$result$token

call1 <- paste(HOST, "/core/data/count", "?", "experiments=", URLencode("http://www.opensilex.org/weis/WS2017-1", reserved=TRUE), sep="")

get_count <- httr::GET(call1, httr::add_headers(Authorization = post_authenticate_json$result$token))
get_count_text <- httr::content(get_count, "text")
get_count_json <- jsonlite::fromJSON(get_count_text, flatten = TRUE)