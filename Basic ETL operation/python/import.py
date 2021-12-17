import WeisWSClient
## Installer en suivant <https://forgemia.inra.fr/OpenSILEX/opensilex-ws-clients#python>
from WeisWSClient.rest import ApiException
from pprint import pprint
import json
import csv
from enum import Enum
from pathlib import Path
import logging


#     _____ ______ _______ _______ _____ _   _  _____  _____ 
#    / ____|  ____|__   __|__   __|_   _| \ | |/ ____|/ ____|
#   | (___ | |__     | |     | |    | | |  \| | |  __| (___  
#    \___ \|  __|    | |     | |    | | | . ` | | |_ |\___ \ 
#    ____) | |____   | |     | |   _| |_| |\  | |__| |____) |
#   |_____/|______|  |_|     |_|  |_____|_| \_|\_____|_____/ 
#                                                            
#                                                           
class OutputFormat(Enum):
    CSV = '.csv'
    JSON = '.json'

pythonClient_host = "http://138.102.159.36:8080/weisAPI/rest"
pythonClient_pwd = "admin"

output_format_file = OutputFormat.CSV
output_dir_path = './API_import_' + output_format_file.name
pythonClient = WeisWSClient.ApiClient()
pythonClient.connect_to_opensilex_ws(
    username="admin@opensilex.org", password=pythonClient_pwd, host=pythonClient_host)

pageSize = 100000

log_file = f'{Path(__file__).stem}_debug.txt'
logging.basicConfig(level=logging.INFO,    handlers=[
    logging.FileHandler(log_file),
    logging.StreamHandler()
], format='%(asctime)s,%(msecs)d %(levelname)-8s [%(filename)s:%(lineno)d] %(message)s')

#    ________   _________ _____            _____ _______ 
#   |  ____\ \ / /__   __|  __ \     /\   / ____|__   __|
#   | |__   \ V /   | |  | |__) |   /  \ | |       | |   
#   |  __|   > <    | |  |  _  /   / /\ \| |       | |   
#   | |____ / . \   | |  | | \ \  / ____ \ |____   | |   
#   |______/_/ \_\  |_|  |_|  \_\/_/    \_\_____|  |_|   
#                                                        
#                                                        


def extractor(function, paramsDict, list, positionalArguments = []):
    try:
        api_response = function(*positionalArguments, **paramsDict)
        for item in api_response['result']:
            list.append(item.to_dict())
        logging.info("Successfully called %s(**%s)" % (function.__name__, paramsDict))
        logging.info("with %i elements counted" % len(list))
    except ApiException as e:
        logging.exception("Exception when calling %s" % function.__name__)

# Variables
weis_variables = []
weis_variable_detail = []
api_instance = WeisWSClient.VariablesApi(pythonClient)

# extractor(api_instance.get_variables_by_search, {"page_size": pageSize}, weis_variables)
# # Get variables details
# for variable in weis_variables:
#     extractor(api_instance.get_variable_detail, {"page_size": pageSize, "variable": variable['uri']}, weis_variable_detail)

# Experiments

weis_experiments =[]
# api_instance = WeisWSClient.ExperimentsApi(pythonClient)
# extractor(api_instance.get_experiments_by_search, {"page_size": pageSize}, weis_experiments)




# Events & Annotations

weis_events=[]
# api_instance = WeisWSClient.EventsApi(pythonClient)
# extractor(api_instance.get_events, {"page_size": pageSize}, weis_events)


weis_annotations = []
# api_instance = WeisWSClient.AnnotationsApi(pythonClient)
# extractor(api_instance.get_annotations_by_search, {"page_size": pageSize}, weis_annotations)


# Device (sensors)

weis_sensors = []
# api_instance = WeisWSClient.SensorsApi(pythonClient)
# extractor(api_instance.get_sensors_by_search, {"page_size": pageSize}, weis_sensors)


# ScientificObject
weis_scientific_objects = []
api_instance = WeisWSClient.ScientificObjectsApi(pythonClient)
extractor(api_instance.get_scientific_objects_by_search, {"page_size": 10}, weis_scientific_objects)


# Provenance
weis_provenances = []
api_instance = WeisWSClient.ProvenancesApi(pythonClient)
extractor(api_instance.get_provenances, {"page_size": pageSize}, weis_provenances)

# Data

weis_data = []
api_instance = WeisWSClient.DataApi(pythonClient)

# Data need iteration over all variables
# for variable in weis_variables:
#     extractor(api_instance.get_data, {"page_size": pageSize}, weis_data, positionalArguments = [variable['uri']])


#   __          _______  _____ _______ ______ 
#   \ \        / /  __ \|_   _|__   __|  ____|
#    \ \  /\  / /| |__) | | |    | |  | |__   
#     \ \/  \/ / |  _  /  | |    | |  |  __|  
#      \  /\  /  | | \ \ _| |_   | |  | |____ 
#       \/  \/   |_|  \_\_____|  |_|  |______|
#                                             
#      

# Ensure folder path exit
Path(output_dir_path).mkdir(parents=True, exist_ok=True)

def write(weis_content_string):
    with open(output_dir_path + "/" + weis_content_string + output_format_file.value, "w") as file:
        content = eval(weis_content_string)
        # Avoid misstyped/empty mess
        if content is None or len(content) == 0:
            logging.warning('No files has been printed')
            return
        if (output_format_file == OutputFormat.JSON):
            file.write(json.dumps(eval(weis_content_string), indent = 2, sort_keys=True, default=str))
        if (output_format_file == OutputFormat.CSV):
            dict_writer = csv.DictWriter(file, fieldnames=content[0].keys())
            dict_writer.writeheader()
            dict_writer.writerows(content)


# write("weis_variables")
# write("weis_variable_detail")
# write("weis_experiments")
# write("weis_events")
# write("weis_annotations")
# write("weis_sensors")
write("weis_scientific_objects")
# write("weis_provenances")
# write("weis_data")
