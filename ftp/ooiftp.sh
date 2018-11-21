#!/bin/bash
##
# ooiftp.sh
# Tue Nov 20 13:58:12 PST 2018

Email="brian.kahn@noaa.gov william.w.chadwick@noaa.gov andy.lau@noaa.gov"

# ooiData
base=$(basename $0 .sh)
dir=$(dirname $0)
cd $dir

# use full path
py=${0/sh/py}
if [ ! -x $py ]; then
  echo $0: cannot find $py > $base.out
  exit 1
fi

# was last run a success?
Last=$(grep -s -c mj $base.out)

# run
$py "$dateTime" > $base.out 2>> $base.log
This=$(grep -s -c mj $base.out)

# email if result differs from last time
if [ $This -ne $Last ]; then
  if [ -n "$Email" ]; then
    cat $base.out | mailx -s "$0" $Email
  fi
fi
