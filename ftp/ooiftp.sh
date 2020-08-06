#!/bin/bash
##
# ooiftp.sh
# Tue Nov 20 13:58:12 PST 2018

Email="brian.kahn@noaa.gov"
#Email="brian.kahn@noaa.gov william.w.chadwick@noaa.gov andy.lau@noaa.gov"

# ooiData
base=$(basename $0 .sh)
dir=$(dirname $0)
cd $dir

# run
./$base.py "$dateTime" > $base.out 2> $base.err

# count lines with "mj"
This=$(grep -s -c mj $base.out)
if [ $This -ne 4 ]; then
  if [ -n "$Email" ]; then
    (ls -l $base.out; cat $base.out) | mailx -s "$0" $Email
  fi
fi

