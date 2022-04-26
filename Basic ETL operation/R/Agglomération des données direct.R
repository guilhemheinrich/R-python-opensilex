#                  _   _                _   _           _   _
#       /\        | | | |              | | (_)         | | (_)
#      /  \  _   _| |_| |__   ___ _ __ | |_ _  ___ __ _| |_ _  ___  _ __
#     / /\ \| | | | __| '_ \ / _ \ '_ \| __| |/ __/ _` | __| |/ _ \| '_ \
#    / ____ \ |_| | |_| | | |  __/ | | | |_| | (_| (_| | |_| | (_) | | | |
#   /_/    \_\__,_|\__|_| |_|\___|_| |_|\__|_|\___\__,_|\__|_|\___/|_| |_|
#
#

USER <- "admin@opensilex.org"
PASSWORD <- "admin"
HOST <- "https://sixtine.mistea.inrae.fr/rest"



#    _____                               _
#   |  __ \                             | |
#   | |__) |_ _ _ __ __ _ _ __ ___   ___| |_ ___ _ __ ___
#   |  ___/ _` | '__/ _` | '_ ` _ \ / _ \ __/ _ \ '__/ __|
#   | |  | (_| | | | (_| | | | | | |  __/ ||  __/ |  \__ \
#   |_|   \__,_|_|  \__,_|_| |_| |_|\___|\__\___|_|  |___/
#
#

# One, or many experiments uri
experiments_uri <-
  c(
    # "sixtine:set/experiments#qualite-du-fruit-2017",
    "sixtine:set/experiments#resintbio"
  )
# Only one so type
scientific_object_type <-
  "http://www.opensilex.org/vocabulary/oeso#SubPlot"
# zero or more variables
variables <- c()


# Get all variables in experiment, if none provided
source('getToken.R')

token <- getToken(HOST, USER, PASSWORD)


call1 <-
  paste(
    HOST,
    "/core/data/variables",
    "?",
    paste0(
      "experiments=",
      URLencode(experiments_uri, reserved = TRUE),
      collapse = "&"
    ),
    "&page_size=10000",
    sep = ""
  )

get_result <-
  httr::GET(call1, httr::add_headers(Authorization = token))
get_result_text <- httr::content(get_result, "text")
get_result_json <-
  jsonlite::fromJSON(get_result_text, flatten = TRUE)
variables_list <- get_result_json$result$uri

# Get all SO corresponding to SO type
token <- getToken(HOST, USER, PASSWORD)
so_per_experiment <- data.frame(
  so_uri = character(),
  so_name = character(),
  rdf_type = character(),
  experiment_uri = character()
)

for (experiment_uri in experiments_uri) {
  call1 <-
    paste(
      HOST,
      "/core/scientific_objects",
      "?",
      "experiment=",
      URLencode(experiment_uri, reserved = TRUE),
      # Only one
      "&",
      paste0(
        "rdf_types=",
        URLencode(scientific_object_type, reserved = TRUE),
        collapse = "&"
      ),
      "&page_size=10000",
      sep = ""
    )
  get_result <-
    httr::GET(call1, httr::add_headers(Authorization = token))
  get_result_text <- httr::content(get_result, "text")
  get_result_json <-
    jsonlite::fromJSON(get_result_text, flatten = TRUE)
  so_list <- get_result_json$result
  so_per_experiment <-
    rbind(
      so_per_experiment,
      data.frame(
        so_uri = so_list$uri,
        so_name = so_list$name,
        rdf_type = so_list$rdf_type,
        experiment_uri = experiment_uri
      )
    )
}
so_list <- so_per_experiment$so_uri
# Get data related to corresponding SO, variables, experiments
token <- getToken(HOST, USER, PASSWORD)



call1 <-
  paste(
    HOST,
    "/core/data",
    "?",
    paste0(
      "experiments=",
      URLencode(experiments_uri, reserved = TRUE),
      collapse = "&"
    ),
    "&",
    paste0("targets=", URLencode(so_list, reserved = TRUE), collapse = "&"),
    "&",
    paste0(
      "variables=",
      URLencode(variables_list, reserved = TRUE),
      collapse = "&"
    ),
    "&page_size=10000",
    sep = ""
  )

get_result <-
  httr::GET(call1, httr::add_headers(Authorization = token))
get_result_text <- httr::content(get_result, "text")
get_result_json <- jsonlite::fromJSON(get_result_text, flatten = TRUE)
content_df <- data.frame(
  so_uri = get_result_json$result$target,
  date = get_result_json$result$date,
  variable_uri = get_result_json$result$variable,
  value = get_result_json$result$value
)

final_dt <-merge(content_df, so_per_experiment)
write.csv(final_dt,"data\\direct_data.csv", row.names = TRUE)
  