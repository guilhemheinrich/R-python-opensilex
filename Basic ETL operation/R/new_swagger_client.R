library(swagger)


USER <- "admin@opensilex.org"
PASSWORD <- "admin"
HOST <- "http://138.102.159.36:8081/rest"

apiClient <- ApiClient$new(basePath = HOST)

authenticationApi <- swagger::AuthenticationApi$new(apiClient)
authenticationDTO <- swagger::AuthenticationDTO$new(identifier = USER, password = PASSWORD)
result <- authenticationApi$authenticate(authenticationDTO)$response # !! Doesn't work
content_text <- httr::content(result$content, "text")
content_json <- jsonlite::fromJSON(content_text, flatten = TRUE)