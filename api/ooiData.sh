#!/bin/bash
##
# ooiData.sh v2
# figure reasonable date time
# Thu Nov  8 10:04:00 PST 2018
# v2: no monthly dir. daily file up to current time. repeat fails in *.fail
# crontab daily ooiClean.sh to remove segments from previous days

Email="brian.kahn@noaa.gov william.w.chadwick@noaa.gov andy.lau@noaa.gov"

# ooiData
base=$(basename $0 .sh)
dir=$(dirname $0)
cd $dir

# Date
if [ $# -gt 0 ]; then
  when=$1
else
  when="15 minutes ago"
fi
dateTime=$(date -u -d "$when" '+%Y-%m-%d+%H.%M')
day=$(date -u -d "$when" '+%Y-%m-%d')

# use full path
py=${0/sh/py}
if [ ! -x $py ]; then
  echo $0: cannot find $py > $base.out
  exit 1
fi

# was last run a success?
grep -s -q success $base.out
Last=$?

# run
$py "$dateTime" > $base.out 2>> $base.log
This=$?

# email if result differs from last time
if [ $This -ne $Last ]; then
  if [ -n "$Email" ]; then
    cat $base.out | mailx -s "$0" $Email
  fi
fi

# make daily file
# day=$(date -u -d "$when" '+%Y-%m-%d')
seg="segments/$day??*.csv"
if [ "$(echo $seg)" != "$seg" ]; then
  cat $seg > data/$day.csv
fi

exit $This
