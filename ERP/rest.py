from requests.auth import HTTPBasicAuth
import requests
import base64
import json
import getpass
import pandas as pd

def set_creds():
    username = input('username:')
    password = getpass.getpass() 
    creds = {
            'username':username,
            'password':password
            }
    with open('erp_creds.json', 'w') as f:
        json.dump(creds, f)
    return



def get_creds():
    try:
        with open('erp_creds.json') as f:
            creds = json.load(f)
            username = creds['username']
            password = creds['password']  
            return username, password
    except FileNotFoundError as e:
        set_creds()
        return get_creds()
    return creds

base_url = 'https://SETME.oraclecloud.com'



    
def get_request(url,params = {}):
    data = requests.get(url, auth = get_auth(), headers = get_headers(), data = json.dumps(params))
    return data

def get_auth():
    username, password = get_creds()
    auth = HTTPBasicAuth(username, password)
    return auth
    
def get_headers():
    return {"Content-Type": "application/vnd.oracle.adf.resourceitem+json"}   



def upload_content(content, extension, file_name, account = 'budget'):
    url = base_url +'/fscmRestApi/resources/11.13.18.05/erpintegrations'
    assert account in ['budget', 'actuals']
    if account == 'budget':
        account = "fin/budgetBalance/import"
    if account == 'actuals':
        account = "fin/generalLedger/import"
    
    try:
        content = content.encode()
    except AttributeError as e:
        pass
    content = base64.b64encode(content).decode()
    params = {
    "OperationName":"importBulkData",
    "DocumentContent": content,
    "ContentType":extension.upper(),
    "DocumentAccount":account,
    "JobName":"oracle/apps/ess/financials/commonModules/shared/common/interfaceLoader,InterfaceLoaderController",
    "ParameterList":"1,7584,N,N",
    "FileName":file_name,
    "NotificationCode":"10",
    "CallbackURL": base_url + "/finFunSharedErpIntegrationCallback/ErpIntegrationCallbackservice",
    }

    data = requests.post(url, auth = get_auth(), headers = get_headers(), data = json.dumps(params))
    return data

