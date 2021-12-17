import csv
import json
from pprint import pprint
from collections import OrderedDict
from pathlib import Path
from types import SimpleNamespace
import re
#     _____ ______ _______ _______ _____ _   _  _____  _____ 
#    / ____|  ____|__   __|__   __|_   _| \ | |/ ____|/ ____|
#   | (___ | |__     | |     | |    | | |  \| | |  __| (___  
#    \___ \|  __|    | |     | |    | | | . ` | | |_ |\___ \ 
#    ____) | |____   | |     | |   _| |_| |\  | |__| |____) |
#   |_____/|______|  |_|     |_|  |_____|_| \_|\_____|_____/ 
#                                                            
#                        



''' From <https://dzone.com/articles/simple-csv-transformations>'''
def etl(sourcePath, transformation, destinationPath, unroller = None):
    with open(sourcePath, "r", newline='') as csvInput:      
        reader = csv.DictReader(csvInput)
        Path(destinationPath).parent.mkdir(parents=True, exist_ok=True)
        with open(destinationPath, "w") as csvOutput:
            new_header = transformation(dict()).keys()
            writer = csv.DictWriter(csvOutput, fieldnames=new_header)
            writer.writeheader()
            if unroller is not None:
                for row in reader:
                    writer.writerows(transformation(unrolled_row) for unrolled_row in unroller(row))
            else:
                writer.writerows(transformation(row) for row in reader)


between_letters = re.compile(r"(\w[\s\w\^\d]+)\"([\w\^][\s\w\^\d]+)", re.MULTILINE | re.DOTALL)

# All ' are invalid json => transform all but the one you shouldn't ...
def correct_json(json_as_string):
    correct_json_string = json_as_string
    correct_json_string = str(correct_json_string).replace("None", "null")
    correct_json_string = str(correct_json_string).replace("\"\"", "\'")
    correct_json_string = str(correct_json_string).replace("\"", "\'")
    correct_json_string = str(correct_json_string).replace("'", "\"")
    correct_json_string = str(correct_json_string).replace("\"\"", "\"'")
    correct_json_string = between_letters.sub(r"\1'\2", correct_json_string)
    return correct_json_string

#   __      __        _       _     _           
#   \ \    / /       (_)     | |   | |          
#    \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___ 
#     \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#      \  / (_| | |  | | (_| | |_) | |  __/\__ \
#       \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#                                               
#                                                                                  

def transform_variables_migration_script(row):
    default_row = {
        "Entity": "Unknown", # Unknown, like Water
        "Characteristic": 'Unknown', # Unknown
        "method.uri": '',
        "method.label": '',
        "method.comment": '',
        "unit.uri": '',
        "unit.label": '',
        "unit.comment": '',
        "label": '',
        "trait_name": '',
        "trait": '',
        "uri": '',
        "datatype": '',
        "description": 'None'
    }
    new_row = default_row
    if row:
        method_object = json.loads(correct_json(row['method']), object_hook=lambda d: SimpleNamespace(**d))
        new_row["method.uri"] = method_object.uri
        new_row["method.label"] = method_object.label
        new_row["method.comment"] = method_object.comment

        unit_object = json.loads(correct_json(row['unit']), object_hook=lambda d: SimpleNamespace(**d))
        new_row["unit.uri"]     = unit_object.uri
        new_row["unit.label"]   = unit_object.label
        new_row["unit.comment"] = unit_object.comment

        trait_object = json.loads(correct_json(row['trait']), object_hook=lambda d: SimpleNamespace(**d))
        new_row["trait_name"] = trait_object.label
        new_row["trait"] = trait_object.uri
        if trait_object.comment is not None:      
            new_row["description"] = trait_object.comment


        new_row["label"] = row['label']
        new_row["uri"] = row['uri']


        # pprint(method_object)
    return new_row

def transform_variables(row):
    default_row = {
        'uri'               : '',                                           #'str',
        'name'              : '',                                           #'str',
        'alternative_name'  : '',                                           #'str',
        'description'       : '',                                           #'str',
        'entity'            : '',                                           #'str',
        'characteristic'    : '',                                           #'str',
        'trait'             : '',                                           #'str',
        'trait_name'        : '',                                           #'str',
        'method'            : '',                                           #'str',
        'unit'              : '',                                           #'str',
        'species'           : '',                                           #'str',
        'datatype'          : 'http://www.w3.org/2001/XMLSchema#decimal',   #'str',
        'time_interval'     : '',                                           #'str',
        'sampling_interval' : '',                                           #'str',
        'exact_match'       : None,                                           #'list[str]',
        'close_match'       : None,                                           #'list[str]',
        'broad_match'       : None,                                           #'list[str]',
        'narrow_match'      : None                                            #'list[str]'
    }
    # uri,label,comment,ontologies_references,properties,trait,method,unit
    new_row = default_row
    if row:
        new_row["name"] = row['label']
        new_row["uri"] = row['uri']

        method_object = json.loads(correct_json(row['method']), object_hook=lambda d: SimpleNamespace(**d))
        new_row["method"] = method_object.uri

        unit_object = json.loads(correct_json(row['unit']), object_hook=lambda d: SimpleNamespace(**d))
        new_row["unit"]     = unit_object.uri


        trait_object = json.loads(correct_json(row['trait']), object_hook=lambda d: SimpleNamespace(**d))
        new_row["trait_name"] = trait_object.label
        new_row["trait"] = trait_object.uri
        if trait_object.comment is not None:      
            new_row["description"] = trait_object.comment
        
        if row['uri'] in [
            'http://www.opensilex.org/weis/id/variables/v052',
            'http://www.opensilex.org/weis/id/variables/v063',
            'http://www.opensilex.org/weis/id/variables/v065',
            'http://www.opensilex.org/weis/id/variables/v066'
        ]:
            new_row["datatype"] = 'http://www.w3.org/2001/XMLSchema#string'
    return new_row



#     _____      _            _   _  __ _         ____  _     _           _       
#    / ____|    (_)          | | (_)/ _(_)       / __ \| |   (_)         | |      
#   | (___   ___ _  ___ _ __ | |_ _| |_ _  ___  | |  | | |__  _  ___  ___| |_ ___ 
#    \___ \ / __| |/ _ \ '_ \| __| |  _| |/ __| | |  | | '_ \| |/ _ \/ __| __/ __|
#    ____) | (__| |  __/ | | | |_| | | | | (__  | |__| | |_) | |  __/ (__| |_\__ \
#   |_____/ \___|_|\___|_| |_|\__|_|_| |_|\___|  \____/|_.__/| |\___|\___|\__|___/
#                                                           _/ |                  
#                                                          |__/                   


def transform_so(row):
    default_row = {
        "uri": "", # Required
        "rdf_type": 'Unknown', # Required
        "name": '', # Required
        "experiment": '',
        "vocabulary:hasCreationDate": '',
        "vocabulary:hasDestructionDate": '',
        "vocabulary:hasFacility": '',
        "vocabulary:isPartOf": '',
        "rdfs:comment": '',
        "geometry": '',
        "vocabulary:hasFactorLevel": '',
        "vocabulary:hasGermplasm": ''
    }
    new_row = default_row
    if row:
        new_row["name"] = row['label']
        new_row["uri"] = row['uri']
        new_row["rdf_type"] = row['rdf_type']
        new_row["experiment"] = row['experiment']
        ## evaluate to truthy
        if row['geometry']:
            geometry_object = json.loads(correct_json(row['geometry']), object_hook=lambda d: SimpleNamespace(**d))
            ## Using the default lambda to 'revert cast' the namespace to a dict
            json_string = json.dumps(geometry_object, default=lambda o: o.__dict__)
            new_row["geometry"] = json_string
    return new_row

#    _____                                                    
#   |  __ \                                                   
#   | |__) | __ _____   _____ _ __   __ _ _ __   ___ ___  ___ 
#   |  ___/ '__/ _ \ \ / / _ \ '_ \ / _` | '_ \ / __/ _ \/ __|
#   | |   | | | (_) \ V /  __/ | | | (_| | | | | (_|  __/\__ \
#   |_|   |_|  \___/ \_/ \___|_| |_|\__,_|_| |_|\___\___||___/
#                                                             
#                             

def transform_provenances(row):
    default_row = {
        'uri'           : '',   #'str'
        'name'          : '',   #'str'
        'description'   : '',   #'str'
        'prov_activity' : None, #'list[ActivityCreationDTO]'
        'prov_agent'    : None  #'list[AgentModel]'
    }
    new_row = default_row
    if row:
        new_row["uri"] = row['uri']
        new_row["name"] = row['label']
        new_row["description"] = row['comment']
    return new_row

#    _____        _        
#   |  __ \      | |       
#   | |  | | __ _| |_ __ _ 
#   | |  | |/ _` | __/ _` |
#   | |__| | (_| | || (_| |
#   |_____/ \__,_|\__\__,_|
#                          
#                     

def transform_data(row):

    default_row = {
        'uri'       : '',           #'str'
        '_date'     : '',           #'str'
        'timezone'  : '',           #'str'
        'target'    : '',           #'str'
        'variable'  : '',           #'str'
        'value'     : 0,            #'object'
        'confidence': 0.5,          #'float
        'provenance': '',           #'DataProvenanceModel'
        # 'metadata'  : None,       #'dict(str, object)'
        # 'raw_data'  : None,       #'list[object]'
    }
# uri,provenance_uri,object_uri,variable_uri,_date,value
    new_row = default_row
    if row:
        new_row['uri'       ] = row['uri'           ]
        new_row['_date'     ] = row['_date'         ]
        new_row['target'    ] = row['object_uri'    ]
        new_row['variable'  ] = row['variable_uri'  ]
        new_row['value'     ] = row['value'         ]
        new_row['provenance'] = row['provenance_uri']
    return new_row

def default_transformation(row):
    default_row = {
        'uri'       : '',           #'str'
        '_date'     : '',           #'str'
        'timezone'  : '',           #'str'
        'target'    : '',           #'str'
        'variable'  : '',           #'str'
        'value'     : 0,            #'object'
        'confidence': 0.5,          #'float
        'provenance': '',           #'DataProvenanceModel'
        # 'metadata'  : None,       #'dict(str, object)'
        # 'raw_data'  : None,       #'list[object]'
    }
    new_row = default_row
    if row:
        new_row['uri'       ] = row['uri'       ]
        new_row['_date'     ] = row['_date'     ]
        new_row['target'    ] = row['target'    ]
        new_row['variable'  ] = row['variable'  ]
        new_row['value'     ] = row['value'     ]
        new_row['provenance'] = row['provenance']
    return new_row

import opensilexClientToolsPython
variable_mappings = dict()
with open('/home/heinrich/code/ANSWER-data/answer-data/src/variable_mappings.csv', "r", newline='') as mappings_file:
    reader = csv.DictReader(mappings_file)
    for mapping in reader:
        variable_mappings[mapping['obs_var_name']] = mapping['uri']
pythonClient_host = "http://138.102.159.36:8081/rest"
pythonClient_pwd = "admin"                   
pythonClient = opensilexClientToolsPython.ApiClient()
pythonClient.connect_to_opensilex_ws(
identifier="admin@opensilex.org", password=pythonClient_pwd, host=pythonClient_host)
scientific_object_api = opensilexClientToolsPython.ScientificObjectsApi(pythonClient)
SO_mapping = dict()
def target_mapping(station_id):
    # https://blog.finxter.com/python-int-to-string-with-leading-zeros/
    name = 'TH' + station_id.zfill(2)
    if not name in SO_mapping:
        print(f'Calling API for {name}')
        api_call_result = scientific_object_api.search_scientific_objects(name = name)
        # Assume that the name is enough to uniquely identify the SO
        SO_mapping[name] = api_call_result['result'][0].uri
    return SO_mapping[name]

def observation_taihu(row):
    new_row = dict()
    for variable_name in variable_mappings:
        print(variable_name)
        new_row['uri'] = None
        new_row['_date'] = f"{row['Year']}-{row['Month']}-{row['Day']} 12:00:00+0100"
        new_row['timezone'] = None
        new_row['target'] = target_mapping(row['Stations_id'])
        new_row['variable'] = variable_mappings[variable_name]
        new_row['value'] = row[variable_name]
        new_row['confidence'] = 1
        new_row['provenance'] = None
        yield new_row
    


#    _______ _____            _   _  _____ ______ ____  _____  __  __ 
#   |__   __|  __ \     /\   | \ | |/ ____|  ____/ __ \|  __ \|  \/  |
#      | |  | |__) |   /  \  |  \| | (___ | |__ | |  | | |__) | \  / |
#      | |  |  _  /   / /\ \ | . ` |\___ \|  __|| |  | |  _  /| |\/| |
#      | |  | | \ \  / ____ \| |\  |____) | |   | |__| | | \ \| |  | |
#      |_|  |_|  \_\/_/    \_\_| \_|_____/|_|    \____/|_|  \_\_|  |_|
#                                                                     
#                                                                     

# etl("/home/heinrich/code/ANSWER-data/data/API_import_CSV/weis_variable_detail.csv", transform_variables_migration_script, "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_variable_detail.csv")
# etl("/home/heinrich/code/ANSWER-data/data/API_import_CSV/weis_variable_detail.csv", transform_variables, "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_variable_detail_update.csv")

# etl("/home/heinrich/code/ANSWER-data/data/API_import_CSV/weis_scientific_objects.csv", transform_so, "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_scientific_objects.csv")

# etl("/home/heinrich/code/ANSWER-data/data/API_import_CSV/weis_provenances.csv", transform_provenances, "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_provenances.csv")

# etl("/home/heinrich/code/ANSWER-data/data/API_import_CSV/weis_data.csv", transform_data, "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_data.csv")
etl("/home/heinrich/code/ANSWER-data/data/obs_data_LakeTaihu_dat1.csv", default_transformation, "/home/heinrich/code/ANSWER-data/data/transform_CSV/obs_taihu.csv", unroller = observation_taihu)