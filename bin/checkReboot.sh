#!/bin/bash
# touch reboot
#  will reboot at 4pm
bk="brian.kahn@noaa.gov"
mailto="brian.kahn@noaa.gov william.w.chadwick@gmail.com"
if [ -f /home/kahn/reboot ]; then 
  rm /home/kahn/reboot
  echo "caldera reboot $(date)" | mailx -r $bk -s "caldera reboot" $mailto
  /sbin/reboot
fi
