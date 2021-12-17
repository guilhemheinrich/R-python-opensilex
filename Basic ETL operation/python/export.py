import csv
import json
from pprint import pprint
import opensilexClientToolsPython
import atexit
import re
from datetime import datetime
import logging
from pathlib import Path

from tool_function.clientHelper import clientHelper
#     _____ ______ _______ _______ _____ _   _  _____  _____ 
#    / ____|  ____|__   __|__   __|_   _| \ | |/ ____|/ ____|
#   | (___ | |__     | |     | |    | | |  \| | |  __| (___  
#    \___ \|  __|    | |     | |    | | | . ` | | |_ |\___ \ 
#    ____) | |____   | |     | |   _| |_| |\  | |__| |____) |
#   |_____/|______|  |_|     |_|  |_____|_| \_|\_____|_____/ 
#   

                                                        
pythonClient_host = "http://138.102.159.36:8081/rest"
pythonClient_pwd = "admin"                   
pythonClient = opensilexClientToolsPython.ApiClient()

helper = clientHelper(
    host = "http://138.102.159.36:8081/rest",
    client = pythonClient,
    )

    
pythonClient.connect_to_opensilex_ws(
    identifier="admin@opensilex.org", password=pythonClient_pwd, host=pythonClient_host)
print("V3.4" + str(pythonClient.default_headers) + '\n')

page_size = 1000000
log_file = f'{Path(__file__).stem}_debug.txt'
logging.basicConfig(level=logging.INFO,    handlers=[
    logging.FileHandler(log_file),
    logging.StreamHandler()
], format='%(asctime)s,%(msecs)d %(levelname)-8s [%(filename)s:%(lineno)d] %(message)s')


def reconnect():
    pythonClient.connect_to_opensilex_ws(
        identifier="admin@opensilex.org", password=pythonClient_pwd, host=pythonClient_host)

def retry_with_reconnect(function, argumentsDict = {}, positionalArguments = [], default_return = None):
    result = default_return
    failed_loop = False
    try:
        result = function(*positionalArguments, **argumentsDict)
    except Exception as e:
        reconnect()
        try:
            result = function(*positionalArguments, **argumentsDict)
        except Exception as e:
             logging.error(f'Getting error while executing {function.__name__} with exeception {e}')
             failed_loop = True
    return {
        'result': result,
        'failed_loop': failed_loop
        }

def compile_mappings_targetXexperiments(mappings_targetXexperiments_path):
    mappings_targetXexperiments = dict()    
    with open(mappings_targetXexperiments_path) as csvFile:
        reader = csv.DictReader(csvFile)
        for row in reader:
            mappings_targetXexperiments[row['scientific_object']] = str(row['experiment'])
    return mappings_targetXexperiments
#   __      __        _       _     _           
#   \ \    / /       (_)     | |   | |          
#    \ \  / /_ _ _ __ _  __ _| |__ | | ___  ___ 
#     \ \/ / _` | '__| |/ _` | '_ \| |/ _ \/ __|
#      \  / (_| | |  | | (_| | |_) | |  __/\__ \
#       \/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
#                                               

def variables_delete():
    input_path = "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_variable_detail_update.csv"
    variable_api = opensilexClientToolsPython.VariablesApi(pythonClient)
    with open(input_path) as csvFile:
        reader = csv.DictReader(csvFile)
        for row in reader:
            # update = row.copy()
            # update.pop('uri')

            # updated_variable = opensilexClientToolsPython.VariableUpdateDTO(row['uri'], **update)
            try:
                # variable_api.update_variable(body = updated_variable)
                variable_api.delete_variable(row['uri'])
            except Exception as e:
                print(f'Exception found in {row["uri"]}')
                print(f'With exception: {e}')
    

#     _____      _            _   _  __ _         ____  _     _           _       
#    / ____|    (_)          | | (_)/ _(_)       / __ \| |   (_)         | |      
#   | (___   ___ _  ___ _ __ | |_ _| |_ _  ___  | |  | | |__  _  ___  ___| |_ ___ 
#    \___ \ / __| |/ _ \ '_ \| __| |  _| |/ __| | |  | | '_ \| |/ _ \/ __| __/ __|
#    ____) | (__| |  __/ | | | |_| | | | | (__  | |__| | |_) | |  __/ (__| |_\__ \
#   |_____/ \___|_|\___|_| |_|\__|_|_| |_|\___|  \____/|_.__/| |\___|\___|\__|___/
#                                                           _/ |                  
#    

def scientific_objects():

    input_path = "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_scientific_objects.csv"
    scientific_object_api = opensilexClientToolsPython.ScientificObjectsApi(pythonClient)

    ## Fetch previous SO's uri
    expe_uris =[
        'http://www.opensilex.org/weis/WS1996-1',
        'http://www.opensilex.org/weis/WS2019-1',
        'http://www.opensilex.org/weis/WS2019-2',
        'http://www.opensilex.org/weis/WS2017-1',
        'http://www.opensilex.org/weis/WS2016-1',
        'http://www.opensilex.org/weis/WS2018-1',
        'http://www.opensilex.org/weis/WS2018-2',
        'http://www.opensilex.org/weis/WS2020-1'
    ]

    def exit_handler():
        print(f'I exit at index: {index}')
    atexit.register(exit_handler)

    experiment_api = opensilexClientToolsPython.ExperimentsApi(pythonClient)
    all_experiments = experiment_api.get_experiments_by_ur_is(expe_uris)
    all_SO_nameXexperiment = set()
    for experiment in all_experiments['result']: 
        all_so = scientific_object_api.search_scientific_objects(experiment = experiment.uri, page_size = page_size)
        for SO in all_so['result']:
            all_SO_nameXexperiment.add(experiment.uri + SO.name)
        # all_SO_uris
        # all_SO_uris.extend(SO.uri for SO in all_so['result'])
    pprint(len(all_SO_nameXexperiment) )
    # pprint()
    start_over = -1
    index = 0
    with open(input_path) as csvFile:
        reader = csv.DictReader(csvFile)
        for row in reader:
            if index < start_over:
                index = index + 1
                continue
            if row['experiment'] + row['name'] in all_SO_nameXexperiment:
                index = index + 1
                print(f'{row["name"]} already referenced in the same experiment ({row["experiment"]})')
                continue
            # evaluate to truthy
            if row['geometry']:
                geo = json.loads(row['geometry'])
                geometry = opensilexClientToolsPython.GeoJsonObject(type=geo["type"], coordinates=geo["coordinates"])
                new_SO = opensilexClientToolsPython.ScientificObjectCreationDTO(**{
                    "uri": row['uri'],
                    "name": row['name'],
                    "rdf_type":row["rdf_type"],
                    "experiment": row['experiment'],
                    "geometry": geometry          
                })
            else: 
                new_SO = opensilexClientToolsPython.ScientificObjectCreationDTO(**{
                    "uri": row['uri'],
                    "name": row['name'],
                    "rdf_type":row["rdf_type"],
                    "experiment": row['experiment']
                })
            # pprint(new_SO)
            try:
                scientific_object_api.create_scientific_object(body=new_SO)
                all_SO_nameXexperiment.add(row['experiment'] + row['name'])
            except Exception as e:
                print(f'Exception found in {row["uri"]} at index {index}')
                print(f'With exception: {e}')
            index = index + 1
            if index % 200 == 0:
                reconnect()
                print(f"Proceeded {index + 1} scientific_object")


#    _____                                                    
#   |  __ \                                                   
#   | |__) | __ _____   _____ _ __   __ _ _ __   ___ ___  ___ 
#   |  ___/ '__/ _ \ \ / / _ \ '_ \ / _` | '_ \ / __/ _ \/ __|
#   | |   | | | (_) \ V /  __/ | | | (_| | | | | (_|  __/\__ \
#   |_|   |_|  \___/ \_/ \___|_| |_|\__,_|_| |_|\___\___||___/
#                                                             
#      


def provenances():
    input_path = "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_provenances.csv"
    data_api = opensilexClientToolsPython.DataApi(pythonClient)

    index = 0
    def exit_handler():
        print(f'I exit at index: {index}')
    atexit.register(exit_handler)
    with open(input_path) as csvFile:
        reader = csv.DictReader(csvFile)
        for row in reader:
            new_prov = opensilexClientToolsPython.ProvenanceCreationDTO(**row)
            try:
                data_api.update_provenance(body=new_prov)
            except Exception as e:
                print(f'Exception found in {row["uri"]} at index {index}')
                print(f'With exception: {e}')
            index = index + 1
            
#    _____        _        
#   |  __ \      | |       
#   | |  | | __ _| |_ __ _ 
#   | |  | |/ _` | __/ _` |
#   | |__| | (_| | || (_| |
#   |_____/ \__,_|\__\__,_|
#    

valid_provenances = [
    'http://www.opensilex.org/weis/id/provenance/1569414107960',
    'http://www.opensilex.org/weis/id/provenance/1569421205203',
    'http://www.opensilex.org/weis/id/provenance/1588007306736',
    'http://www.opensilex.org/weis/id/provenance/1588062970037',
    'http://www.opensilex.org/weis/id/provenance/1590582007111',
    'http://www.opensilex.org/weis/id/provenance/1590588906821',
    'http://www.opensilex.org/weis/id/provenance/1590761313079',
    'http://www.opensilex.org/weis/id/provenance/1592550291643',
    'http://www.opensilex.org/weis/id/provenance/1596099509770',
    'http://www.opensilex.org/weis/id/provenance/1596100139730',
    'http://www.opensilex.org/weis/id/provenance/1604481403880',
    'http://www.opensilex.org/weis/id/provenance/1604482504917'
]   
        
float_int = re.compile(r"^-?[\d\.]+$", re.MULTILINE | re.DOTALL)
def data(input_path, mappings_targetXexperiments_path, maxData = 8000):
    mappings_targetXexperiments = compile_mappings_targetXexperiments(mappings_targetXexperiments_path)
    new_data = []
    with open(input_path) as csvFile:
        reader = csv.DictReader(csvFile)
        index = 0
        dumped_values = 0
        for row in reader:
            # Dump empty value ... Not any sense for data (?)
            if not row['value']:
                dumped_values += 1
                index = index + 1
                continue
            formatted_row = row.copy()
            experiments = mappings_targetXexperiments[row['target']]
            if row['provenance'] not in valid_provenances:
                unidentified_provenance = row['provenance']
                uri = row['uri']
                logging.info(f'unidentified provenance {unidentified_provenance} for {uri}')
                formatted_row['provenance'] = opensilexClientToolsPython.DataProvenanceModel(uri = 'weis:id/provenance/standard-provenance', experiments = [experiments])
            else:
                formatted_row['provenance'] = opensilexClientToolsPython.DataProvenanceModel(uri = row['provenance'], experiments = [experiments])
            try:
                if float_int.match(row['value']):
                    formatted_row['value'] = float(row['value'])
                else:
                    formatted_row['value'] = row['value']
            except Exception as e:
                wrong_value = row['value']
                print(f'Value cannot be cast: {wrong_value} at position {index + 2}')
                logging.info(f'Value cannot be cast: {wrong_value} at position {index + 2}')
                index = index + 1
                continue
            formatted_row['confidence'] = float(row['confidence'])
            _datetime = datetime.strptime(row['_date'], '%Y-%m-%d %H:%M:%S%z')
            # See https://stackoverflow.com/questions/13182075/how-to-convert-a-timezone-aware-string-to-datetime-in-python-without-dateutil
            _date = _datetime.astimezone().isoformat()
            ## No timezone
            formatted_row['timezone'] = None
            formatted_row['_date'] = _date
            new_datum = opensilexClientToolsPython.DataCreationDTO(**formatted_row)
            new_data.append(new_datum)
            index = index + 1
        logging.warning(f'Dumped {dumped_values} data over {index + 1}')
        data_api = opensilexClientToolsPython.DataApi(pythonClient)
        # Load by smaller chunk...
        loop = 0
        failed_loop = False
        def _filterer(datum):
            if datum.variable is not None and len(datum.variable) > 0 :
                pass
            else:
                logging.info(f'')
                return False
            return True
        filtered_new_data = list(filter(_filterer , new_data))
        for packet in [filtered_new_data[i:i+maxData] for i in range(0,len(new_data),maxData)]:
            try:
                data_api.add_list_data(body = packet)
            except Exception as e:
                failed_loop = True
            if failed_loop:
                try:
                    reconnect()
                    data_api.add_list_data(body = packet)
                except Exception as e:
                    # pprint(packet)
                    print(f'Loop {loop} failed')
                    print(f'With exception: {e}')
                    logging.error(f'Loop {loop} failed with exeception {e}')
                    return
            failed_loop = False
            loop = loop + 1
            print(f'Done loop {loop}')

# !! Not reliable !!
# Best is to directly delete data in the mongo instance...          
def data_delete():
    input_path = "/home/heinrich/code/ANSWER-data/data/transform_CSV/new_data.csv"
    with open(input_path) as csvFile:
        reader = csv.DictReader(csvFile)
        data_api = opensilexClientToolsPython.DataApi(pythonClient)
        index = 0
        deleted = 0
        for row in reader:
            try:
                data_api.delete_data(row['uri'])
                deleted += 1
            except Exception as e:
                if "URI not found" in str(e):
                    pass
                else:
                    reconnect()
                    data_api = opensilexClientToolsPython.DataApi(pythonClient)
                    try:
                        data_api.delete_data(row['uri'])
                        deleted += 1
                    except Exception as e:
                        if "URI not found" in str(e):
                            pass
                        else:
                            print(f'Failed at index {index}')
                            print(e)
                            quit()
                        pass
            if index % 100 == 0:
                print(f'Currently deleted {deleted} data on {index}')
            index += 1
        print(f'{deleted} data deleted on {index}')


            
#    _      ____          _____  
#   | |    / __ \   /\   |  __ \ 
#   | |   | |  | | /  \  | |  | |
#   | |   | |  | |/ /\ \ | |  | |
#   | |___| |__| / ____ \| |__| |
#   |______\____/_/    \_\_____/ 
#                                

# def variables_delete():

# scientific_objects()
# provenances()
# data_delete()
## opensilex data
# data('/home/heinrich/code/ANSWER-data/data/transform_CSV/new_data.csv', '/home/heinrich/code/ANSWER-data/answer-data/src/dataTarget_experiments_mappings.csv')

## Taihu data
data('/home/heinrich/code/ANSWER-data/data/transform_CSV/obs_taihu.csv', '/home/heinrich/code/ANSWER-data/answer-data/src/dataTarget_experiments_mappings_taihu.csv')