#!/opt/anaconda2/bin/python2.7
## 
# ooiData.py
# .1 make an URL describing the instrument sensor data stream
# .2 create time interval - round time to nearest part of hour
# .3 stream into data[] array, select certain data items
# .4 write out to file with name like ./2018-10-11+16:03
# Thu Oct 11 16:15:09 PDT 2018
# make a monthly dir data/2018/10 - 3000 files / month
# Mon Nov  5 08:59:00 PST 2018

from datetime import datetime, timedelta
import requests
import sys
import os

progName = sys.argv[0]

# my params
sampMinutes = 15          # time interval and start time modulus
sampLimit = 60*60         # one hour at one sample per second
sampHeader = True	  # column header in csv file
sampPrint = False         # print to std out (as well as into file)
sampRound = True          # round down start time, e.g. nearest quarter hour
sampPath = 'data'	  # path to data store

# testing - turn these off
verbose = False
testing = False

# authen
username = 'OOIAPI-8PGYR9GA7YHVXX'
token = '0MT4ME7UEL5Y8L'
# Instrument Information
subsite = 'RS03ASHS'
node = 'MJ03B'
sensor = '10-CTDPFB304'
method = 'streamed'
stream = 'ctdpf_optode_sample'
# url
baseUrl = 'https://ooinet.oceanobservatories.org/api/m2m/12576/sensor/inv'
dataRequestUrl ='/'.join((baseUrl, subsite, node, sensor, method, stream))

# datetime formats
dtOOI = '%Y-%m-%dT%H:%M:%S.000Z'
dFmt = '%Y-%m-%d'
tFmt = '%H.%M.%S'
dtFmt = '%Y-%m-%d+%H.%M'
fnameFmt = dtFmt

# date time conversions, OOI data uses seconds since 1900
dtNtpEpoch = datetime(1900, 1, 1)
dtUnixEpoch = datetime(1970, 1, 1)
dtNtpDelta = (dtUnixEpoch - dtNtpEpoch).total_seconds()
def dtFromNtpSec(dtNtpSeconds):
  return datetime.utcfromtimestamp(dtNtpSeconds - dtNtpDelta)

# optional cmd line arg for datetime, default is now
# we use now-15minutes by default if no cmd line arg or if bad datetime
try:
  # date time from cmd line
  beginDT = datetime.strptime(sys.argv[1], dtFmt)
except (IndexError,ValueError) as ex:
  # sampMinutes ago
  beginDT = datetime.utcnow() - timedelta(minutes=sampMinutes) 
  # bad date
  if isinstance(ex, ValueError):
    print ex.message
    print "bad datetime, default is now"

# round down modulo sampMinute (e.g. to quarter hour)
if sampRound:
  sampDown = beginDT.minute % sampMinutes
  if sampDown:
    beginDT = beginDT - timedelta(minutes=sampDown)
    beginDT = beginDT.replace(second=0)
    beginDT = beginDT.replace(microsecond=0)
    if verbose: print "rounding time down to %s" % beginDT.strftime(tFmt)

endDT = beginDT + timedelta(minutes=sampMinutes)

params = { 
  'beginDT': beginDT.strftime(dtOOI),
  'endDT': endDT.strftime(dtOOI),
  'limit': sampLimit, 
}

# select data items, see list at end of file
selectData = ( 
  'density', 
  'practical_salinity', 
  'seawater_temperature', 
)

# fetch all data from beginDT to endDT
# ooi has a way to fetch only selected data, 
#  but it's poorly documented so fetch all and save selected
session = requests.session()
response = session.get(dataRequestUrl, params=params, auth=(username, token))
data = response.json()
if testing or response.status_code!=200:
  print data['message']['status']
  print params
  print dataRequestUrl
  sys.exit(response.status_code)

if len(data) < 2:
  print "data length = %s" % len(data)
  sys.exit(response.status_code)

## write data
dataPath = "%s/%s/%s" % (sampPath, beginDT.year, beginDT.month)
if not os.path.isdir(dataPath):
  os.makedirs(dataPath)

# insert datetime into the filename, ie 2018-10-11+16.00.csv
fname = beginDT.strftime(fnameFmt) + '.csv'
with open(dataPath + '/' + fname, "w+") as f:
  if verbose: print "writing %s" % fname
  # column header
  if sampHeader:
    line = "seconds, time"
    for i in selectData:
      line = "%s, %s" % (line, i)
    if verbose: print line
    f.write(line+'\n')
  # data
  for j in range(len(data)):
    ntpSec = data[j]['time']
    tStr = dtFromNtpSec(ntpSec).strftime(tFmt)
    line = "%.2f, %s" % (ntpSec, tStr)
    for i in selectData:
      line = line + ", %f" % data[j][i]
    if verbose: print line
    f.write(line+'\n')

sys.exit(0)


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

# data[0] = {
# u'oxy_calphase': -9999999, 
# u'practical_salinity': 34.51587086006168, 
# u'seawater_pressure': 1559.7261669602206, 
# u'density_qc_executed': 1, 
# u'driver_timestamp': 3745594521.770782, 
# u'ctd_tc_oxygen_qc_executed': 1, 
# u'conductivity': 1488358, 
# u'seawater_pressure_qc_results': 1, 
# u'ctd_tc_oxygen': -1009.9999, 
# u'practical_salinity_qc_results': 1, 
# u'temperature': 532116, 
# u'density': 1034.778887900451, 
# u'seawater_temperature_qc_results': 1, 
# u'pressure_temp': 12716, 
# u'internal_timestamp': 0.0, 
# u'seawater_conductivity_qc_results': 1, 
# u'pk': {
# u'node': 
# u'MJ03B', 
# u'stream': 
# u'ctdpf_optode_sample', 
# u'subsite': 
# u'RS03ASHS', 
# u'deployment': 4, 
# u'time': 3745594521.6167817, 
# u'sensor': 
# u'10-CTDPFB304', 
# u'method': 
# u'streamed'}, 
# u'ctd_tc_oxygen_qc_results': 0, 
# u'dissolved_oxygen_qc_results': 0, 
# u'preferred_timestamp': 
# u'port_timestamp', 
# u'ingestion_timestamp': 3745605883.31, 
# u'port_timestamp': 3745594521.6167817, 
# u'seawater_pressure_qc_executed': 1, 
# u'pressure': 782158, 
# u'seawater_temperature': 2.4267815572215454, 
# u'oxygen': -9999999, 
# u'dissolved_oxygen': -816.7194908028131, 
# u'seawater_conductivity': 3.1444262107656735, 
# u'practical_salinity_qc_executed': 1, 
# u'oxy_temp': -9999999, 
# u'seawater_temperature_qc_executed': 1, 
# u'density_qc_results': 1, 
# u'time': 3745594521.6167817, 
# u'dissolved_oxygen_qc_executed': 1, 
# u'seawater_conductivity_qc_executed': 1}

