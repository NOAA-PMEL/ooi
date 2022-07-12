#!/bin/bash
# four hours is too long
fourHours=$(( 60 * 60 * 4 ))
tooLong=${1:-$fourHours}
email=brian.kahn@noaa.gov
# date %s = seconds
now=$(date +"%s")
for i in ~/ooi/rsn/MJ03?/*ProcessingStatus; do
  status=$(cat $i)
  # status running?
  if [ "${status:0:1}" == "0" ]; then continue; fi
  statusTimeStamp=$(echo "$status" | cut -d' ' -f3-7)
  statusSec=$(date -d "$statusTimeStamp" +"%s")
  processing=$(( $now - $statusSec ))
  if (( $processing > $tooLong )); then
    if [[ -n "$email" ]]; then
      subj="caldera: warning, data processing for $processing seconds"
      echo "$i: $status" | mailx -r "brian.kahn@noaa.gov" -s "$subj" $email
    fi
  fi
done
