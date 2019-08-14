from requests import Session
from requests.auth import HTTPBasicAuth  # or HTTPDigestAuth, or OAuth1, etc.
from zeep import Client
from zeep.transports import Transport
from zeep import xsd
import pandas as pd
import json
import getpass

report_url = 'https://CHANGE_ME.oraclecloud.com/xmlpserver/services/ExternalReportWSSService?wsdl'
integration_url = 'https://CHANGE_ME.oraclecloud.com//fscmService/ErpIntegrationService?WSDL'


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


def get_client(url):
    username, password = get_creds()
    #set up zeep client with basic authentication
    session = Session()
    session.auth = HTTPBasicAuth(username, password)
    client = Client(url,
        transport=Transport(session=session))
    return client
    

client = get_client(integration_url)


reports = {
        'natural_account':"/Custom/REPORT.XDO",
        'funeral_home':'/Custom/REPORT.XDO'
        }



cols = {'funeral_home':['alias', 'oracle_id']}
skiprow_mapping = {'natural_account':1,
                   'funeral_home':0}

def get_report(report_name):
    report_path = reports[report_name]
    username, password = get_creds()
    #set up zeep client with basic authentication
    session = Session()
    session.auth = HTTPBasicAuth(username, password)
    client = Client(report_url,
        transport=Transport(session=session))
    
    #create a factory to make objects which contain input parameters
    f = client.type_factory("ns0")
    
    #create a report request object and fill in the necessary params
    rr = f.ReportRequest()
    rr.reportAbsolutePath = report_path #this path is relative to "/Shared Folders/" in the Oracle Catalog
    rr.sizeOfDataChunkDownload = "-1" #I think this means get all of the bytes at once.
    
    #the report request object has a bunch of unset parameters and zeep will squawk about them
    #iterate the keys of rr, check if they're absent and tell zeep to explicitly skip them
    for k in rr:
    	if rr[k] is None:
    		rr[k] = xsd.SkipValue
    
    
    #call the run report endpoint with the ncessary request, here appParams is set to be skipped, this might be where
    #report input parameters belong.
    x = client.service.runReport(reportRequest=rr, appParams=xsd.SkipValue)
    
     ## Writes the report to disk so that pandas can read it easily. 
    dat = x['reportBytes']
    with open('temp.xlsx', 'wb') as f:
        f.write(dat)
    # Mapping to skip rows in the file. (Strips away excess header information)
    skiprows = skiprow_mapping[report_name] 
    
    try: # Try and see if the data is excel formatted.
        data = pd.read_excel('temp.xlsx', skiprows = skiprows) 
    except Exception as e:
         # If that fails try and load it as a csv.
        data = pd.read_csv('temp.xlsx', skiprows = skiprows)
        
    # IF we know the column name informaiton lcoally we can downoad it.
    if report_name in cols.keys():
        data.columns = cols[report_name]    
    return data


