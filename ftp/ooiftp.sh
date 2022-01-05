#!/usr/bin/bash
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
Prev=$(grep -s -c mj.*dat $base.out)
./$base.py "$dateTime" > $base.out 2>> $base.err

# count lines with "mj"
Curr=$(grep -s -c mj.*dat $base.out)
if [ $Curr -ne $Prev ]; then
  if [ -n "$Email" ]; then
    (ls -l $base.out; cat $base.out) | \
      mailx -r "brian.kahn@noaa.gov" -s "$0 $Prev to $Curr" $Email
  fi
fi

