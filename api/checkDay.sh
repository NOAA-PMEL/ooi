#!/bin/bash
# scan the day "%Y-%m-%d" and fetch missing segments
# EMAIL_ON_FAIL="brian.kahn@noaa.gov"

dirname=$(dirname $0)
cd $dirname

# minimum for data to be "good" - not quite one per second
mini=870
mind=$(( $mini * 24 * 4 ))

today=$(date '+%Y-%m-%d')
date=$(date -u -d $1 '+%Y-%m-%d') || exit 1
if [ $today == $date ]; then exit 0; fi

data=$(cat data/$date.csv | wc -l)
if [ $data -gt $mind ]; then 
  echo $date is good
  exit 0
fi

echo "checking $date ($data lines looks short)"
for hour in {00..23}; do
  # 15min segments
  for min in {00..45..15}; do
    dt=$date+$hour.$min
    fn=segments/$dt.csv
    # if segments/datetime missing or short
    if [ ! -f "$fn" ] || [ $(cat "$fn" | wc -l) -lt $mini ]; then
      ./ooiData.py $dt |& head -1
    fi
  done
done

segs=$(cat segments/$date*|wc -l) 
if [ $segs -gt $data ]; then
  echo "$date got more data, $(($segs-$data)) lines"
  cat segments/$date* > data/$date.csv
  exit 0
fi

exit 1
