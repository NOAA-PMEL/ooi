#!/usr/bin/python3
# download daily data files from UW ftp site - reimplements download.sh 

# https://pysftp.readthedocs.io/en/release_0.2.8/cookbook.html
# Use the pysftp.Connection.listdir_attr to get file listing with attributes
# Then, iterate the list and compare against local files.
here='/data/chadwick/4andy'
site='ftp.ooirsn.uw.edu'
user='noaa'
keyp='ooirsn'
key='~/.ssh/noaa-pmel4uw'

import os
import pysftp
import stat
from time import gmtime

inst=(('mj03d', 'BOTPTA303'), ('mj03e', 'BOTPTA302'),
      ('mj03f', 'BOTPTA301'), ('mj03b', 'BOTPTA304'))
t=gmtime()

for i in inst:
    with pysftp.Connection(site, username=user, 
                           private_key=key, private_key_pass=keyp 
                           ) as sftp:
        path="/data/%s/%s/%4d/%02d" % (i[0], i[1], t.tm_year, t.tm_mon)
        print(path)
        sftp.cwd(path)
        os.chdir("%s/%s" % (here, i[0]))
        for f in sftp.listdir_attr():
            if not stat.S_ISDIR(f.st_mode):
                # print("Checking %s..." % f.filename)
                if ((not os.path.isfile(f.filename)) or
                    (f.st_mtime > os.path.getmtime(f.filename))):
                    print("Downloading %s..." % f.filename)
                    # download with server timestamp preserved
                    sftp.get(f.filename, preserve_mtime=True)
