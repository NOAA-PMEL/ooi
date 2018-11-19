## Downsampling cabled ASHES Seafloor CTD data - 03
## (request 15 min of data)
#*Written by Friedrich Knuth, Rutgers University*
#*Revised by Lori Garzio, Rutgers University, July 12, 2018*
#*Adapted by Bill Chadwick, August 6, 2018*

import requests
import time
import warnings

# This example demonstrates how to download data via the OOI API,
# downsample the data (in this case, because cabled data are collected
# at a high frequency), and save the more manageable downsampled data
# as a CSV file.
warnings.filterwarnings("ignore")

# Enter your API username and password
username = 'OOIAPI-8PGYR9GA7YHVXX'
token = '0MT4ME7UEL5Y8L'

# Instrument Information for the Seafloor CTD in the ASHES vent field at Axial Seamount
subsite = 'RS03ASHS'
node = 'MJ03B'
sensor = '10-CTDPFB304'
method = 'streamed'
stream = 'ctdpf_optode_sample'

# Time interval for data requested
beginDT = '2018-08-01T00:30:00.000Z'
endDT = '2018-08-01T00:45:00.000Z'
# "Build and send the data request."
# "#### Note: Data request lines are commented out below
# to prevent accidental resubmission when running through
# the entire notebook quickly."
base_url = 'https://ooinet.oceanobservatories.org/api/m2m/12576/sensor/inv/'
data_request_url ='/'.join((base_url,subsite,node,sensor,method,stream))
params = {
    'beginDT':beginDT,
    'endDT':endDT,
}
# BELOW ARE THE DATA REQUEST LINES (usually commented out)
r = requests.get(data_request_url, params=params, auth=(username, token))
data = r.json()
# https://opendap.oceanobservatories.org/thredds/catalog/ooi/bill.chadwick@oregonstate.edu/20180807T172111-RS03ASHS-MJ03B-10-CTDPFB304-streamed-ctdpf_optode_sample/catalog.html
# THREDDs directory containing data files
data['allURLs'][0]

# "Check for the data request to complete. Note: this may take a while if you have requested a large time range of cabled data."
time.ctime()
check_complete  = data['allURLs'][1] + '/status.txt'
for i in range(1800):
    r = requests.get(check_complete)
    if r.status_code == requests.codes.ok:
        print('request completed')
        break
    else:
        time.sleep(1)
## Loading xarray

# "Before we proceed, we first need to install and load the xarray library into Google Colab."
import re
import xarray as xr
import pandas as pd
import os

# "Next, we can use the following code to automatically find all of the available .nc files in the THREDDS directory."
# https://opendap.oceanobservatories.org/thredds/dodsC/ooi/bill.chadwick@oregonstate.edu/20180807T172111-RS03ASHS-MJ03B-10-CTDPFB304-streamed-ctdpf_optode_sample/deployment0004_RS03ASHS-MJ03B-10-CTDPFB304-streamed-ctdpf_optode_sample_20180801T003000.496131-20180801T004459.226956.nc
# List all of the .nc files in the THREDDs directory
url = data['allURLs'][0]
#
tds_url = 'https://opendap.oceanobservatories.org/thredds/dodsC'
datasets = requests.get(url).text
urls = re.findall(r'href=[\'"]?([^\'" >]+)', datasets)
x = re.findall(r'(ooi/.*?.nc)', datasets)
for i in x:
    if i.endswith('.nc') == False:
        x.remove(i)
for i in x:
    try:
        float(i[-4])
    except:
        x.remove(i)
datasets = [os.path.join(tds_url, i) for i in x]
datasets

# "For each .nc file: open the file, resample the CTD data
# by taking minute averages, and save the information."
num = 0
for i in datasets:
    print('Downsampling file {} of {}'.format(str(num + 1), str(len(datasets))))
    ds = xr.open_dataset(i)
    ds = ds.swap_dims({'obs': 'time'})
    CTD_min = pd.DataFrame()
    CTD_min['seawater_temperature'] = ds['seawater_temperature'].to_pandas().resample('T').mean()
    CTD_min['practical_salinity'] = ds['practical_salinity'].to_pandas().resample('T').mean()
    CTD_min['density'] = ds['density'].to_pandas().resample('T').mean()
    CTD_min = CTD_min.dropna()

# "Complete!"
# "Output subsampled data to a csv file"
# Create the CSV file - Note it has a 1-line header with columnn names
CTD_min = CTD_min.sort_values(by=['time'])
#CTD_min.to_csv('Chadwick_CTD_subsample_15_min.csv') # Create the CSV file
CTD_min.to_csv(beginDT+'.csv')
