import os
import glob
import shutil
import pandas as pd
import json
import getpass
import sys
import uuid 

def get_use_folder():
    platform = sys.platform
    if 'win' in platform:
        return 'epm_automate_win/bin'
    if 'linux' in platform:
        return 'epm_automate_linux/bin'

def set_creds():
    creds = {}
    creds['username'] = input('username?')
    print('Please enter the password')
    creds['password'] = getpass.getpass()
    creds['url'] = input('url')
    creds['domain'] = input('domain?')
    with open('pbcs_creds.json', 'w') as f:
        json.dump(creds, f)
        
    return creds
        
def get_creds():
    start_dir = os.getcwd()
    os.chdir(base_dir)
    try:
        with open('pbcs_creds.json', 'r') as f:
            creds = json.load(f)
    
    except FileNotFoundError:
        creds = set_creds()    
    
    os.chdir(start_dir)
    
    return creds
    
base_dir = os.getcwd()
downloads = base_dir + '\\downloads'

def login_check():
    start_dir = os.getcwd()
    os.chdir(get_use_folder())
    files = glob.glob('.prefs')
    check = '.prefs' in files
    os.chdir(start_dir)
    return check
    
def exec_command(command):
    try:
        if not login_check():
            login()
        return __exec_command(command)
    except Exception as e:
        os.chdir(base_dir)
        raise e

def logout():
    if login_check():
        os.remove(get_use_folder() + '/.prefs')

def __exec_command(command):
    start_dir = os.getcwd()
    os.chdir(get_use_folder())
    
    start_files = glob.glob('*.*')
    if get_creds()['password'] not in command:
        print(command)
        
    executor = 'epmautomate'
    if 'win' in sys.platform:
        executor = executor + '.bat'
    if 'linux' in sys.platform:
        executor = executor + '.sh'         
    ans = os.popen('epmautomate.bat {}'.format(command)).read()
    if len(ans) > 100:
        print(ans[0:100])
    else :
        print(ans)
    
    
    
    end_files = glob.glob('*.*')
    for file in end_files:
        if (file != '.prefs') and (file not in start_files) and not file.endswith('.log'):
            print('Moving File:', file)
            shutil.move(file, start_dir + '//' + 'downloads')
            
            
    os.chdir(start_dir)
    return ans


def get_files():
    files = exec_command('listfiles').split('\n ')
    files = pd.Series(files).str.replace('\n', '').values
    return files


def has_file(file):
    now = os.getcwd()
    os.chdir(downloads)
    ans = file in glob.glob('*.*')
    os.chdir(now)
    return ans


def login():
    creds = get_creds()
    username = creds['username']
    password = creds['password']
    url = creds['url']
    domain = creds['domain']
    
    command = f'login {username} {password} {url} {domain}'
    ans =  __exec_command(command)
    
    if not login_check():
        raise ValueError('Not Logged in Error: {}'.format(ans))
    
    return ans




def download_export(pre_command = 'exportdata', name = 'full_export' ):
    print(pre_command, name)
    if not os.path.exists('downloads'):
        os.makedirs('downloads')
        
    
    """ THe name and pre command need to be seperated so that the name can be used to identify the output"""
    a =exec_command(f'{pre_command} "{name}"')
    print(a)
    
    files = get_files()
    dfile = name
    for file in files:
        if (name in file):
            dfile = file
            a = exec_command(f'downloadfile "{dfile}"')
            print(a)
            a = exec_command(f'deletefile "{dfile}"')
            print(a)
    return dfile
    
    
jobs = {"metadata": ['exportmetadata', 'all_metadata']}
"BUD_4"
"GL_FUSION"
    
def load_file(data, start_period, end_period, rule_name, import_mode, export_mode):
    '''
    import_mode
    APPEND to add to the existing POV data in Data Management
    REPLACE to delete the POV data and replace it with the data from the file
    RECALCULATE to recalculate the data
    NONE to skip data import into Data Management staging table
    
    export_mode
    STORE_DATA to merge the data in the Data Management staging table with the existing data
    ADD_DATA to add the data in the Data Management staging table to the application
    SUBTRACT_DATA to subtract the data in the Data Management staging table from existing data
    REPLACE_DATA to clear the POV data and replace it with data in the Data Management staging table. The data is cleared for Scenario, Version, Year, Period, and Entity
    NONE to skip data export from Data Management to the application
    '''
    filename = '{}.csv'.format(data.index.name)
    old_name = filename
    data.to_csv(filename)
    
    filename = os.path.abspath(filename)

    if 'budget' in filename.lower():
        clear_job = 'Clear_Budget'
    if 'forecast' in filename.lower():
        clear_job = 'Clear_Forecast'
        
        
    import_mode = import_mode.upper()
    export_mode = export_mode.upper()
    
    assert import_mode in ['APPEND', 'REPLACE', 'RECALCULATE', 'NONE']
    assert export_mode in ['STORE_DATA', 'ADD_DATA', 'SUBTRACT_DATA', 'REPLACE_DATA', 'NONE']
    
    exec_command(f'deletefile "inbox/{old_name}"')
    exec_command(f'uploadfile "{filename}" inbox')
    #exec_command(f' runbusinessrule {clear_job}')
    exec_command(f'rundatarule {rule_name} {start_period} {end_period} {import_mode} {export_mode} inbox/{old_name}')
    exec_command(f'deletefile "inbox/{old_name}"')
    os.remove(filename)
    