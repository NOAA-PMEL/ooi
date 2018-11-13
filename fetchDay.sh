#!/bin/bash
# scan the day "%Y-%m-%d" and fetch missing segments
# EMAIL_ON_FAIL="brian.kahn@noaa.gov"

dirname=$(dirname $0)
cd $dirname

path=segments
fmt='+%Y-%m-%d'

if [ $# -gt 0 ]; then
  when=$1
  shift
else
  when="yesterday"
fi

date=$(date -u -d "$when" '+%Y-%m-%d') || exit 1

echo checking $date UTC

result=0
for hour in {00..23}; do
  # 15min segments
  for min in {00..45..15}; do
    dt=$date+$hour.$min
    fn=$path/$dt.csv
    if [ ! -f "$fn" ]; then
      echo ./ooiData.py $dt
      ./ooiData.py $dt
      result=$(($result+1))
    else 
      set $(wc -l $fn)
      if [ $1 -lt 880 ]; then
	echo ./ooiData.py $dt
	./ooiData.py $dt
	result=$(($result+1))
      fi
    fi
  done
done

exit $result
