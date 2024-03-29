source('getToken.R')

agglo_mod_os_import <- function(host,
                                user,
                                password,
                                experiment_uri,
                                scientific_object_type) {
  token <- getToken(host = host,
                    user = user,
                    password = password)
  call1 <- paste0(host, "/core/scientific_objects/export")
  post_result <-
    httr::POST(
      call1,
      body = paste0(
        '{
          "experiment": "', experiment_uri, '",
          "factor_levels": [],
          "name": "",
          "order_by": ["name=asc"],
          "rdf_types": ["', scientific_object_type, '"]
         }'
      ),
      httr::add_headers(Authorization = token, `Content-Type` = "application/json" )
    )
  # Can't read 'httr::content:as' a csv, need to do it manually
  # also safer
  # see https://httr.r-lib.org/reference/content.html
  post_result_text <- httr::content(post_result, "text")
  # The two header lines doesn't render well -> need to choose one
  header_lines <- read.csv(text=post_result_text, sep = ";", nrows=2, header = FALSE)
  header <- paste(header_lines[1,], header_lines[2,], sep = "/")
  result_df <- read.csv(text=post_result_text, sep = ";", skip=2, col.names=header)
  return(result_df)
}