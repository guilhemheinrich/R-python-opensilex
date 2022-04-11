source("generate_explorer.R")

host <- "http://138.102.159.36:8081/rest"
user <- "admin@opensilex.org"
password <- "admin"

connection <- opensilexClientToolsR::connectToOpenSILEX(
    identifier = user,
    password = password,
    url = host)
# Find all api call containing "get" or "search" in their name (can't find anything structure related)

# Pas possible (?) de retrouver l'information à partir d'une connection
# Incohérence de nommage dans le swagger pour connaitre l'object retrourné (partie response 200)
# Par exemple:
#     - Return position list
#     - Position retrieved


generate_explorer(entity = "annotation", api_call = "AnnotationsApi", function_call = "search_annotations")
generate_explorer(entity = "data", api_call = "DataApi", function_call = "search_data_list")
generate_explorer(entity = "device", api_call = "DevicesApi", function_call = "search_devices")
generate_explorer(entity = "document", api_call = "DocumentsApi", function_call = "search_documents")
generate_explorer(entity = "event", api_call = "EventsApi", function_call = "search_events")
generate_explorer(entity = "experiment", api_call = "ExperimentsApi", function_call = "search_experiments")
generate_explorer(entity = "categorie", api_call = "FactorsApi", function_call = "search_categories")
generate_explorer(entity = "factor level", api_call = "FactorsApi", function_call = "search_factor_levels")
generate_explorer(entity = "factor", api_call = "FactorsApi", function_call = "search_factors")
generate_explorer(entity = "germplasm", api_call = "GermplasmApi", function_call = "search_germplasm")
generate_explorer(entity = "subclasse", api_call = "OntologyApi", function_call = "search_sub_classes_of")
generate_explorer(entity = "facilitie", api_call = "OrganisationsApi", function_call = "search_infrastructure_facilities")
generate_explorer(entity = "tree", api_call = "OrganisationsApi", function_call = "search_infrastructures_tree")
generate_explorer(entity = "position", api_call = "PositionsApi", function_call = "search_position_history")
generate_explorer(entity = "project", api_call = "ProjectsApi", function_call = "search_projects")
generate_explorer(entity = "scientific object", api_call = "ScientificObjectsApi", function_call = "search_scientific_objects")
generate_explorer(entity = "scientific object type", api_call = "ScientificObjectsApi", function_call = "get_used_types")
generate_explorer(entity = "group", api_call = "SecurityApi", function_call = "search_groups")
generate_explorer(entity = "profile", api_call = "SecurityApi", function_call = "search_profiles")
generate_explorer(entity = "user", api_call = "SecurityApi", function_call = "search_users")
generate_explorer(entity = "variable", api_call = "VariablesApi", function_call = "search_variables")
generate_explorer(entity = "variable detail", api_call = "VariablesApi", function_call = "search_variables_details")
generate_explorer(entity = "variable group", api_call = "VariablesApi", function_call = "search_variables_groups")
generate_explorer(entity = "specie", api_call = "SpeciesApi", function_call = "get_all_species")
