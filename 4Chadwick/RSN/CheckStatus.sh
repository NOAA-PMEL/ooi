#!/usr/bin/bash
# status should be 0 if IDL is not running
idl=$( ps -C idl )
data=$(grep 'Data are currently being processed' ~/ooi/rsn/*/*ProcessingStatus)
#if test $? -a ! $idl; then
if [[ $? -eq 0 ]]; then
  bk="brian.kahn@noaa.gov"
  subj="alert: $0 on caldera" 
  echo "$idl" "$data" | mailx -r $bk -s "$subj" $bk
fi
