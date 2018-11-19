#!/bin/bash
Email="brian.kahn@noaa.gov"

# ooiData
Base=$(basename $0 .sh)

# format that OOI likes
fmt='+%Y-%m-%d+%H.%M'
# Date
if [ $# -gt 0 ]; then
  when=$1
else
  when=$(date -u -d now $fmt)
fi

# use full path
py=${0/sh/py}
if [ ! -x $py ]; then
  echo $0: cannot find $py 
  exit 1
fi

# run, capture out with std err
Out=$( $py $Date 2>&1 )
Result=$?
# log, and email if result differs from last time
if [ -n "$Out" ]; then 
  echo -e "=== $Base $(date) \n $Out" >> $Base.log
fi
if [ $Result -eq 0 ]; then
  # success
  if grep -s -q fail $Base.last; then
    if [ -n "$Email" ]; then
      echo -e "$Base success $(date) \n $Out" | mailx -s "$0 success" $Email
    fi
  fi
  echo "$Base: success $Date" > $Base.last
else
  # fail
  if grep -s -q success $Base.last; then
    if [ -n "$Email" ]; then
      echo -e "$Base fail $(date) \n $Out" | mailx -s "$0 fail" $Email
    fi
  fi
  echo "$Base: fail $Date" > $Base.last
fi

exit $Result
