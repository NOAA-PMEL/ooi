#!/bin/bash
# cleanup

#Email="brian.kahn@noaa.gov william.w.chadwick@gmail.com andy.lau@noaa.gov"
#Email="brian.kahn@noaa.gov"
# days to check
days=10
exclude="2020-08-15 2020-08-16 2020-08-17 2020-08-18 2020-08-19 2020-08-20"

base=$(basename $0 .sh)
dir=$(dirname $0)
cd $dir

( while [ $days -gt 0 ]; do
    day=$(date -u -d "$days days ago" '+%Y-%m-%d')
    if echo "$exclude" | grep -v -q $day; then
      ./checkDay.sh $day
    fi
    days=$((days-1))
  done

  # remove segments older than 14 days
  find segments/ -mtime +$days -delete
) >& $base.out

if [ -n "$Email" -a -s "$base.out" ]; then 
  cat $base.out | mailx -s $0 $Email 
fi
