#!/usr/bin/bash
# status should be 0 if IDL is not running
ps -ef | grep -v grep | grep bin.linux.x86_64/idl
idl=$?
grep 'Data are currently being processed' ~/ooi/rsn/*/*ProcessingStatus
stat=$?
if test $stat -a ! $idl; then
  echo 'caldera:ooi/rsn/*/*ProcessingStatus' |
    mailx -s 'alert: check ProcessingStatus on caldera' brian.kahn@noaa.gov
