#!/bin/bash
# cleanup

#Email="brian.kahn@noaa.gov william.w.chadwick@gmail.com andy.lau@noaa.gov"
Email="brian.kahn@noaa.gov"
# how many days to check - use command line parameter $1 if present else two weeks
checkdays=${1:-14}
# exclude certain days that do not and never will have data
# exclude="2020-08-15 2020-08-16 2020-08-17 2020-08-18 2020-08-19 2020-08-20"
exclude=""

base=$(basename $0 .sh)
dir=$(dirname $0)
cd $dir

days=$checkdays
( while [ $days -gt 0 ]; do
    day=$(date -u -d "$days days ago" '+%Y-%m-%d')
    if echo "$exclude" | grep -v -q $day; then
      ./checkDay.sh $day
    fi
    days=$((days-1))
  done

  # remove segments older than days
  find segments/ -type f -mtime +$checkdays -delete
) >& $base.out

if [ -n "$Email" -a -s "$base.out" ]; then 
  if grep -q fail $base.out; then
    cat $base.out | mailx -r "brian.kahn@noaa.gov" -s "$0 short" $Email 
  fi
fi
