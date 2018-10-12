#!/bin/bash
# EMAIL_ON_FAIL="brian.kahn@noaa.gov"

# format that OOI likes
fmt='+%Y-%m-%d+%H.%M.%S'
# parm1
if [ $# -gt 0 ]; then
  when=$1
  shift
else
  when="15 min ago"
fi
parm1=$(date -d "$when" $fmt)

py=${0/sh/py} 
if [ -x $py ]; then
  echo $py $parm1
  $py $parm1
  # check success
  if [ $? != 0 ]; then
    echo $0: failure
    if [ -n $EMAIL_ON_FAIL ]; then
      echo "$(date) $0 fail" | mailx -s "$0 fail" $EMAIL_ON_FAIL
    fi
  fi
else
  echo $0: cannot find $py 
fi

