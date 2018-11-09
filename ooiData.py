#!/opt/anaconda2/bin/python2.7
## 
# ooiData.py v2
# .1 make an URL describing the instrument sensor data stream
# .2 create time interval - round time to nearest part of hour
# .3 stream into data[] array, select certain data items
# .4 write out to file with name like ./2018-10-11+16:03
# Thu Oct 11 16:15:09 PDT 2018
# make a monthly dir data/2018/10 - 3000 files / month
# Thu Nov  8 10:04:00 PST 2018
# v2: no monthly dir, no header

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
segPath = 'segments'	  # dir for segments
verbose = False

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
    print "bad datetime '%s', defaulting to now" % sys.argv[1]

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
if response.status_code!=200:
  sys.stderr.write( "=== %s" % beginDT.strftime(dtFmt) )
  sys.stderr.write( data['message']['status'] )
  sys.stderr.write( params )
  sys.stderr.write( dataRequestUrl )
  print( "%s fail: %s", progName, 'request error' )
  sys.exit(response.status_code)

# should have close to 1/sec
sec = 60*(sampMinutes-1)
if len(data) < sec:
  sys.stderr.write( "=== %s" % beginDT.strftime(dtFmt) )
  sys.stderr.write( "short data length = %s" % len(data))
  print( "%s fail: %s", progName, 'no data' )
  sys.exit(response.status_code)

# go there
os.chdir( progName[:progName.rfind('/')] )
if not os.path.isdir(segPath):
  os.makedirs(segPath)

## write segment
# insert datetime into the filename, ie 2018-10-11+16.30.csv
fName = segPath + '/' + beginDT.strftime(dtFmt) + '.csv'
# write data segment
with open(fName, "w") as f:
  if verbose: print "writing %s" % fName
  # data
  for j in range(len(data)):
    ntpSec = data[j]['time']
    tStr = dtFromNtpSec(ntpSec).strftime(tFmt)
    line = "%.2f, %s" % (ntpSec, tStr)
    for i in selectData:
      line = line + ", %f" % data[j][i]
    if verbose: print line
    f.write(line+'\n')

print( "%s success: %s" % (progName, len(data)) )
sys.exit(0)
