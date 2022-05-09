#!/usr/bin/python3
# ooiftp.py v2
# download daily data files from UW ftp site - reimplements download.sh 
# Mon Nov 19 09:43:33 PST 2018
# .1 move from syspc to caldera and put in git
# .2 status to data/node/ftp.out
# .3 make style closer to the newer api/*.py
# .4 checks this month and last month 
# .5 corrects year error in january

# https://pysftp.readthedocs.io/en/release_0.2.8/cookbook.html
# Use the pysftp.Connection.listdir_attr to get file listing with attributes
# Then, iterate the list and compare against local files.
# ssh = paramiko.SSHClient()
# ssh.connect(host, username=username, password=password, timeout=timeout)
# sftp = ssh.open_sftp()


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

nodeInst=(('mj03b', 'BOTPTA304'),
          ('mj03d', 'BOTPTA303'),
          ('mj03e', 'BOTPTA302'),
          ('mj03f', 'BOTPTA301')) 

now=datetime.utcnow()

# with Connection, for nodeInst, for months, for listdir: get
with pysftp.Connection(site, username=user, 
                       private_key=keyF, private_key_pass=keyP ) as sftp:
  print("connected")
  sftp.timeout=10.0
  for node, inst in nodeInst:
    os.chdir("%s/data/%s" % (here, node))
    # check last month also
    months = [now, now - timedelta(days=now.day)]
    for mon in months:
      # cd to month directory on ftp server
      path="/data/%s/%s/%4d/%02d/" % (node, inst, mon.year, mon.month)
      # this fails out if data is not updating
      try: sftp.cwd(path)
      except: print("could not cd to %s at ftp server" % path); continue
      # for all files in directory
      ls = sftp.listdir_attr()
      if len(ls)<1: print("empty dir %s" % path); continue
      for f in ls:
        # ignore dirs
        if not stat.S_ISDIR(f.st_mode):
          # is file new or newer?
          if ((not os.path.isfile(f.filename)) or
              (f.st_mtime > os.path.getmtime(f.filename))):
            # download with server timestamp preserved
            try: 
              print("trying %s/%s" % (node, f.filename))
              sftp.get(f.filename, preserve_mtime=True)
              print("got %s/%s" % (node, f.filename))
            except: print("could not get %s" % (f.filename))

# to run, requires .ssh/noaa-pmel4uw{.pub}  and known_hosts:
#ftp.ooirsn.uw.edu,128.95.195.8 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWgwuFVWkOJpW4GMBv4ob77/i+bMjul1kQkzsWkFXq0d+EduakhHWE7mY8y5JiMpYdrjnBDktT5s9Ay5vfdl+tMeF+4Zb1fosVPVdZ60do0XePVsJ7junqwzclvZdrg4iiiwqtbS2Olw0UtIglUOY9us0VM4UTemOsFI6Uip6BLbg8FZOtVc9FNFdgzXtd8yrakTCMmZaOdh8AFWlJcSHt33Bv4uf2Aa8s+9MXDS4yb+zL+L3BcbxdfuCUAuDHQUUawZCZ/nl3JTMgzM+wOrFzsF1xzB3FnlK0d49Nw2ZMKaTruiuqsg1uEISlJ/uz0jbTBOLa0n5idqsnVNbdpbxL
