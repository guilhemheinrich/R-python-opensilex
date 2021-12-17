import opensilexClientToolsPython
import logging
from pprint import pprint
from pathlib import Path

from opensilexClientToolsPython.models.data_update_dto import DataUpdateDTO

#     _____ ______ _______ _______ _____ _   _  _____  _____ 
#    / ____|  ____|__   __|__   __|_   _| \ | |/ ____|/ ____|
#   | (___ | |__     | |     | |    | | |  \| | |  __| (___  
#    \___ \|  __|    | |     | |    | | | . ` | | |_ |\___ \ 
#    ____) | |____   | |     | |   _| |_| |\  | |__| |____) |
#   |_____/|______|  |_|     |_|  |_____|_| \_|\_____|_____/ 
#                                                            

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

log_file = f'{Path(__file__).stem}_debug.txt'
logging.basicConfig(level=logging.INFO,    
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler()
    ], 
    format='%(asctime)s,%(msecs)d %(levelname)-8s [%(filename)s:%(lineno)d] %(message)s')

pythonClient_host = "http://138.102.159.36:8081/rest"
pythonClient_pwd = "admin"                   
pythonClient = opensilexClientToolsPython.ApiClient()

page_size = batch_size = 8000


def reconnect():
    pythonClient.connect_to_opensilex_ws(
        identifier="admin@opensilex.org", password=pythonClient_pwd, host=pythonClient_host)

# def retry_with_reconnect(function, positionalArguments = [], default_return = None, argumentsDict = {}:
def retry_with_reconnect(function, *positionalArguments, default_return = None, **argumentsDict):
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


#    _____       _ _   _       _ _          
#   |_   _|     (_) | (_)     | (_)         
#     | |  _ __  _| |_ _  __ _| |_ ___  ___ 
#     | | | '_ \| | __| |/ _` | | / __|/ _ \
#    _| |_| | | | | |_| | (_| | | \__ \  __/
#   |_____|_| |_|_|\__|_|\__,_|_|_|___/\___|
#                                           
#      

reconnect()
scientific_object_api = opensilexClientToolsPython.ScientificObjectsApi(pythonClient)
scientifi_object_X_experiments = dict()

def get_experiments(target_uri):
    if target_uri not in scientifi_object_X_experiments:
        scientifi_object_X_experiments[target_uri] = scientific_object_api.get_scientific_object_detail_by_experiments(target_uri)['result'][0].experiment
    return(scientifi_object_X_experiments[target_uri])

# row = { uri,_date,timezone,target,variable,value,confidence,provenance }
def transform(row):
    default_row = {
        "uri": None,
        "experiment": None
    }
    new_row = default_row
    if row:
        new_row['uri'] = row['uri']
        new_row['experiment'] = [retry_with_reconnect(get_experiments, row['target'])['result']]
    return new_row


#    _______                   __                     
#   |__   __|                 / _|                    
#      | |_ __ __ _ _ __  ___| |_ ___  _ __ _ __ ___  
#      | | '__/ _` | '_ \/ __|  _/ _ \| '__| '_ ` _ \ 
#      | | | | (_| | | | \__ \ || (_) | |  | | | | | |
#      |_|_|  \__,_|_| |_|___/_| \___/|_|  |_| |_| |_|
#                                                     
#  

# source_file = '/home/heinrich/code/ANSWER-data/data/transform_CSV/new_data.csv'
# target_file = '/home/heinrich/code/ANSWER-data/data/transform_CSV/provenanceData.csv'

# etl(source_file, transform, target_file)


source_file = '/home/heinrich/code/ANSWER-data/data/transform_CSV/obs_taihu.csv'
target_file = '/home/heinrich/code/ANSWER-data/data/transform_CSV/provenanceData_taihu.csv'
etl(source_file, transform, target_file)
print(f'There is {len(scientifi_object_X_experiments)} different SO found for {len(set(scientifi_object_X_experiments.values()))} experiments')
pprint(scientifi_object_X_experiments)
