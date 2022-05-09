#!/bin/bash
##
# ooiData.sh v2
# figure reasonable date time
# Thu Nov  8 10:04:00 PST 2018
# v2: no monthly dir. daily file up to current time. repeat fails in *.fail
# crontab daily ooiClean.sh to remove segments from previous days

#Email="brian.kahn@noaa.gov william.w.chadwick@gmail.com"

# ooiData
base=$(basename $0 .sh)
dir=$(dirname $0)
cd $dir

instruments="mj03b mj03e mj03f"
# Date
if [ $# -gt 0 ]; then
  when=$1
else
  when="15 minutes ago"
fi
dateTime=$(date -u -d "$when" '+%Y-%m-%d+%H.%M')
day=$(date -u -d "$when" '+%Y-%m-%d')

# use full path
py=./$base.py
if [ ! -x $py ]; then
  echo $0: cannot find $py > $base.out
  exit 1
fi

# was last run a success?
Last=$(grep -c fail $base.out)
rm $base.out
touch $base.out

# run
for inst in $instruments; do
  $py $inst "$dateTime" >> $base.out 2>> $base.err

  # make daily file
  # day=$(date -u -d "$when" '+%Y-%m-%d')
  seg="segments/$inst/$day??*.csv"
  # if there are segment files ...
  if [ "$(echo $seg)" != "$seg" ]; then
    cat $seg > data/$inst/$day.csv
  fi
done
This=$(grep -c fail $base.out)

# email if result differs from last time
if [ "$This" -ne "$Last" ]; then
  cat $base.out >> $base.log
  if [ -n "$Email" ]; then
    cat $base.out | mailx -r "brian.kahn@noaa.gov" -s "$0" $Email
  fi
fi

exit $This
