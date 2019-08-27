#!/usr/bin/python3
# ooiftp.py v2
# download daily data files from UW ftp site - reimplements download.sh 
# Mon Nov 19 09:43:33 PST 2018
# .1 move from syspc to caldera and put in git
# .2 status to data/node/ftp.out
# .3 make style closer to the newer api/*.py
# .4 checks this month and last month (if now is before day 15)

# https://pysftp.readthedocs.io/en/release_0.2.8/cookbook.html
# Use the pysftp.Connection.listdir_attr to get file listing with attributes
# Then, iterate the list and compare against local files.

import os
import sys
import pysftp
import stat
from datetime import datetime, timedelta

(here, me) = os.path.split( os.path.abspath(sys.argv[0]) )
os.chdir( here )

# my params
site='ftp.ooirsn.uw.edu'
user='noaa'
keyP='ooirsn'
keyF='~/.ssh/noaa-pmel4uw'

nodeInst=(('mj03d', 'BOTPTA303'), ('mj03e', 'BOTPTA302'),
          ('mj03f', 'BOTPTA301'), ('mj03b', 'BOTPTA304'))

# if first half of month, then check last month also
now=datetime.utcnow()
#if now.day>14:
#  lastmonth = 0
#  months = [now.month,]
#else:
#  lastmonth = (now - timedelta(days=15)).month
#  months = [now.month, lastmonth]
lastmonth = now - timedelta(days=now.day)
months = [lastmonth,]

# with Connection, for nodeInst, for months, for listdir: get
with pysftp.Connection(site, username=user, 
                       private_key=keyF, private_key_pass=keyP ) as sftp:
  for node, inst in nodeInst:
    os.chdir("%s/data/%s" % (here, node))
    for mon in months:
      # cd to month directory on ftp server
      path="/data/%s/%s/%4d/%02d/" % (node, inst, mon.year, mon.month)
      sftp.cwd(path)
      # for all files in directory
      for f in sftp.listdir_attr():
        # ignore dirs
        if not stat.S_ISDIR(f.st_mode):
          # is file new or newer?
          if ((not os.path.isfile(f.filename)) or
              (f.st_mtime > os.path.getmtime(f.filename))):
            # download with server timestamp preserved
            sftp.get(f.filename, preserve_mtime=True)
    else: # for months: print last file downloaded (today's)
      print("%s/%s" % (node, f.filename))
