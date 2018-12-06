#!/opt/anaconda2/bin/python2.7
## 
# ooiData.py v3
# .1 make an URL describing the instrument sensor data stream
# .2 create time interval - round time to nearest part of hour
# .3 stream into data[] array, select certain data items
# .4 write out to file with name like ./2018-10-11+16:03
# Thu Oct 11 16:15:09 PDT 2018
# make a monthly dir data/2018/10 - 3000 files / month
# Thu Nov  8 10:04:00 PST 2018
# v2: no monthly dir, no header
# Fri Nov  9 16:10:55 PST 2018
# v3: reorganized for exception handling. retry fetch 3 times.

from datetime import datetime, timedelta
from time import sleep
import requests
import sys
import os

progName = sys.argv[0]
# go there
path = progName[:progName.rfind('/')] 
os.chdir( path )

# my params
sampMinutes = 15          # time interval and start time modulus
sampLimit = 60*60         # one hour at one sample per second
sampHeader = True	  # column header in csv file
sampPrint = False         # print to std out (as well as into file)
sampRound = True          # round down start time, e.g. nearest quarter hour
segPath = 'segments'	  # dir for segments

# datetime formats
dFmt = '%Y-%m-%d'
tFmt = '%H.%M.%S'
dtFmt = '%Y-%m-%d+%H.%M'

# date time conversions, OOI data uses seconds since 1900
dtNtpEpoch = datetime(1900, 1, 1)
dtUnixEpoch = datetime(1970, 1, 1)
dtNtpDelta = (dtUnixEpoch - dtNtpEpoch).total_seconds()
def dtFromNtpSec(dtNtpSeconds):
  global dtNtpDelta
  return datetime.utcfromtimestamp(dtNtpSeconds - dtNtpDelta)

def dataSegment(dtStr, url, params, auth):
  "fetch data in time segment. return: response"
  global dtFmt, tFmt
  # retry if no success does not help, transient failure > 1minute
  session = requests.session()
  response = session.get(url, params=params, auth=auth)
  if response.status_code != 200: 
    sys.stderr.write( "=== %s\n" % dtStr )
    sys.stderr.write( "fetch fail %s: %s\n" % 
        (response.status_code, response.reason) )
    raise ValueError(('request error', response))
  data = response.json()
  # should have close to 1 sec data intervals (actual 1.014?)
  sec = 60*sampMinutes
  if len(data) < sec-5:
    sys.stderr.write( "=== %s\n" % dtStr )
    sys.stderr.write( "fetch short, length = %s\n" % len(data) )
    raise ValueError(('request error', response))
  return data

def saveSegment(dtStr, path, data, select):
  "write data to file in path (may be relative)"
  global tFmt
  # ooi has a way to fetch only selected data, 
  #  but it's poorly documented so fetch all and save selected
  if not os.path.isdir(path):
    os.makedirs(path)
  # insert datetime into the filename, ie 2018-10-11+16.30.csv
  fName = path + '/' + dtStr + '.csv'
  with open(fName, "w") as f:
    for j in range(len(data)):
      ntpSec = data[j]['time']
      tStr = dtFromNtpSec(ntpSec).strftime(tFmt)
      line = "%.2f, %s" % (ntpSec, tStr)
      for i in select:
	line = line + ", %f" % data[j][i]
      f.write(line+'\n')

def beginDateTime():
  "optional cmd line arg for datetime, default is now"
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
  return beginDT

##
# setup parameters
beginDT = beginDateTime()
dtStr = beginDT.strftime(dtFmt)

endDT = beginDT + timedelta(minutes=sampMinutes)
dtOOI = '%Y-%m-%dT%H:%M:%S.000Z'
params = { 
  'beginDT': beginDT.strftime(dtOOI),
  'endDT': endDT.strftime(dtOOI),
  'limit': sampLimit, 
}

# authentication
username = 'OOIAPI-8PGYR9GA7YHVXX'
token = '0MT4ME7UEL5Y8L'
auth = (username, token)
# Instrument Information
subsite = 'RS03ASHS'
node = 'MJ03B'
sensor = '10-CTDPFB304'
method = 'streamed'
stream = 'ctdpf_optode_sample'
# url
baseUrl = 'https://ooinet.oceanobservatories.org/api/m2m/12576/sensor/inv'
dataRequestUrl ='/'.join((baseUrl, subsite, node, sensor, method, stream))

# select data items, see list in README
select = ( 
  'density', 
  'practical_salinity', 
  'seawater_temperature', 
)

# main
try:
  data = dataSegment( dtStr, url=dataRequestUrl, params=params, auth=auth )
  saveSegment( dtStr, segPath, data, select )
except ValueError as ex:
  msg = ex.message[0]
  rsp = ex.message[1]
  sys.stderr.write( "=== %s\n" % dtStr )
  sys.stderr.write( "code %s, reason %s\n%s\n" %
      (rsp.status_code, rsp.reason, rsp.url) )
  print( "%s fail: %s" % (dtStr, ex.message) )
  raise
except Exception as ex:
  print( "%s fail: (unexpected) %s" % (dtStr, ex.message) )
  raise

print( "%s success: %s" % (dtStr, len(data)) )
sys.exit(0)
