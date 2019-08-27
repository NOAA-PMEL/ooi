#!/bin/bash
# cleanup

#Email="brian.kahn@noaa.gov william.w.chadwick@noaa.gov andy.lau@noaa.gov"
Email="brian.kahn@noaa.gov"
# days to check
days=14

base=$(basename $0 .sh)
dir=$(dirname $0)
cd $dir

( while [ $days -gt 1 ]; do
    ./checkDay.sh $(date -u -d "$days days ago" '+%Y-%m-%d')
    days=$((days-1))
  done

  # remove segments older than 14 days
  find segments/ -mtime +14 -delete
) >& $base.out

a=$(cat $base.out)
if [ -n "$a" ]; then 
  echo "$a" | mailx -s $0 $Email 
fi
