#!/bin/bash
# scan the day "%Y-%m-%d" and fetch missing segments
# EMAIL_ON_FAIL="brian.kahn@noaa.gov"

dirname=$(dirname $0)
cd $dirname
#instruments="mj03b"
instruments="mj03b mj03e"

# minimum for data to be "good" - not quite one per second
mini=870
mind=$(( $mini * 24 * 4 ))

today=$(TZ=UTC date '+%Y-%m-%d')
date=$(date -u -d $1 '+%Y-%m-%d') || exit 1
if [ $today == $date ]; then exit 0; fi

for inst in $instruments; do
  file=data/$inst/$date.csv
  lines=0
  if [ -r $file ]; then
    lines=$(cat $file | wc -l)
    if [ $lines -gt $mind ]; then 
      echo $file is good
      continue # inst
    else # file is not good
      rm $file
    fi
  else 
    echo $file not found
  fi # file is not here
  echo "fetching $inst/$date ($lines lines is short)"

  for hour in {00..23}; do
    # 15min segments
    for min in {00..45..15}; do
      dt=$date+$hour.$min
      if [ ! -d segments/$inst ]; then mkdir segments/$inst; fi
      fn=segments/$inst/$dt.csv
      # if segments/inst/datetime missing or short
      if [ ! -f "$fn" ] || [ $(cat "$fn" | wc -l) -lt $mini ]; then
        ./ooiData.py $inst $dt |& head -1
      fi
    done # min
  done # hour

  segs=$(cat segments/$inst/$date*|wc -l) 
  if [ $segs -gt $lines ]; then
    echo "$date got more data, $(($segs-$lines)) lines"
    cat segments/$inst/$date* >> $file
    exit 0
  fi
done # inst

exit 1
