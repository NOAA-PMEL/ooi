#!python2.7
username = 'OOIAPI-8PGYR9GA7YHVXX'
token = '0MT4ME7UEL5Y8L'
import datetime
import requests
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import netCDF4 as nc

class dt:
	ntp_epoch = datetime.datetime(1900, 1, 1)
	unix_epoch = datetime.datetime(1970, 1, 1)
	ntp_delta = (unix_epoch - ntp_epoch).total_seconds()
	
# Instrument Information
subsite = 'RS03ASHS'
node = 'MJ03B'
sensor = '10-CTDPFB304'
method = 'streamed'
stream = 'ctdpf_optode_sample'

base_url = 'https://ooinet.oceanobservatories.org/api/m2m/12576/sensor/inv/'
print base_url

timeBase = datetime.datetime.utcnow() - datetime.timedelta(days=30)
beginDT = timeBase.strftime("%Y-%m-%dT%H:%M:%S.000Z")
endDT = (timeBase + datetime.timedelta(minutes=15)).strftime("%Y-%m-%dT%H:%M:%S.000Z")

data_request_url ='/'.join((base_url,subsite,node,sensor,method,stream))
print data_request_url
params = { 'beginDT':beginDT, 'endDT':endDT, 'limit':1000, }

# data in this instrument:
# oxy_calphase practical_salinity seawater_pressure density_qc_executed
# driver_timestamp ctd_tc_oxygen_qc_executed conductivity
# seawater_pressure_qc_results ctd_tc_oxygen practical_salinity_qc_results
# temperature density seawater_temperature_qc_results pressure_temp
# internal_timestamp seawater_conductivity_qc_results
# ctd_tc_oxygen_qc_results dissolved_oxygen_qc_results
# preferred_timestamp': port_timestamp', ingestion_timestamp port_timestamp
# seawater_pressure_qc_executed pressure seawater_temperature oxygen
# dissolved_oxygen seawater_conductivity practical_salinity_qc_executed
# oxy_temp seawater_temperature_qc_executed density_qc_results time
# dissolved_oxygen_qc_executed seawater_conductivity_qc_executed

selectData = { 
	'density', 
	'practical_salinity', 
	'seawater_temperature', 
	'time', 
}

session = requests.session()
response = session.get(data_request_url, params=params, auth=(username, token))
data = response.json()
print data[0]
print "len(data): " len(data) 


def ntp_seconds_to_datetime(ntp_seconds):
    return datetime.datetime.utcfromtimestamp(ntp_seconds - ntp_delta).replace(microsecond=0)
time = []
seawater_temp = []
salinity = []
density = []
for i in range(len(data)):
  time.append(ntp_seconds_to_datetime(data[i]['time']))
  seawater_temp.append(data[i]['seawater_temperature'])
  salinity.append(data[i]['practical_salinity'])
  density.append(data[i]['density'])
time_stamp = []
pressure = []
temperature = []
salinity = []
oxygen = []
conductivity = []

session = requests.session()

for i in range(100):
    # send request for data
    response = session.get(data_request_url, params=params, auth=(username, token))
    data = response.json()
    # check for failed data request (200 means OK)
    if response.status_code != 200:
        print('Data request failed')
        print(data['message']['status'])
        break
    # get last time stamp in response
    last_time = nc.num2date(data[-1]['time'],'seconds since 1900-01-01').strftime("%Y-%m-%dT%H:%M:%S.000Z")
    # check if new data has been received
    if params['beginDT'] == last_time:
        continue
    # if new data is received, extract and append values to list, then plot
    else:
        # extract variables
        for i in range(len(data)):
            time_stamp.append(nc.num2date(data[i]['time'],'seconds since 1900-01-01').replace(microsecond=0))
            pressure.append(data[i]['seawater_pressure'])
            temperature.append(data[i]['seawater_temperature'])
            oxygen.append(data[i]['ctd_tc_oxygen'])
            salinity.append(data[i]['practical_salinity'])
            conductivity.append(data[i]['seawater_conductivity'])

        # remove colorbars for continuous replotting (there might be a better way to do this)

        # set x axis limit to extent of data
        ax1.set_xlim(time_stamp[0],time_stamp[-1])
        ax2.set_xlim(time_stamp[0],time_stamp[-1])
        fig.autofmt_xdate()

        # choose the colormaps. more colormaps at https://matplotlib.org/examples/color/colormaps_reference.html

        # plot the data
        ax1.plot(time_stamp, temperature, 'b.')
        ax2.plot(time_stamp, salinity, 'b.')

        # assign a colorbar 

        # label colorbars

        # label subplots
        ax1.set_title("Temperature")
        ax2.set_title("Salinity")

        ax1.set_ylabel('Temperature (C)')
        ax2.set_ylabel('Salinity')

        ax1.set_xlabel('time')
        ax2.set_xlabel('time')

        # tighten layout and display plot
        spec.tight_layout(fig)

        display.clear_output(wait=True)
        display.display(plt.gcf())
    
    
    # reset beginDT for next request    
    params['beginDT'] = last_time
    
plt.close()
import xarray as xr
import requests
import os
import re
import pandas as pd

df.to_csv('Chadwick_test1_output.csv') # Create the CSV file
