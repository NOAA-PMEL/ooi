#!/bin/bash
# cleanup

#Email="brian.kahn@noaa.gov william.w.chadwick@noaa.gov andy.lau@noaa.gov"
Email="brian.kahn@noaa.gov"

base=$(basename $0 .sh)
dir=$(dirname $0)
cd $dir

( find data/ -type f -mtime -3 | 
  sed 's;data/\(.*\).csv;\1;' | 
    xargs -L1 ./checkDay.sh
find segments/ -mtime +5 -delete
) >& $base.out

a=$(cat $base.out)
if [ -n "$a" ]; then 
  echo "$a" | mailx -s $0 $Email 
fi
