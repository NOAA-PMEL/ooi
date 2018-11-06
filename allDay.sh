#!/bin/bash
# EMAIL_ON_FAIL="brian.kahn@noaa.gov"

path=data
fmt='+%Y-%m-%d'

if [ $# -gt 0 ]; then
  when=$1
  shift
else
  when="15 min ago"
fi
date=$(date -u -d "$when" '+%Y-%m-%d')
year=$(date -u -d "$when" '+%Y')
month=$(date -u -d "$when" '+%m')

echo checking $date UTC

for hour in {00..23}; do
  for min in {00..45..15}; do
    dt=$date+$hour.$min
    fn=$path/$year/$month/$dt.csv
    if [ ! -f "$fn" ]; then
      echo ./ooiData.py $dt
      ./ooiData.py $dt
    fi
  done
done
