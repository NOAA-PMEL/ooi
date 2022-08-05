#!/bin/bash
# touch reboot
#  will reboot at 4pm
bk=brian.kahn@noaa.gov
if [ -f /home/kahn/reboot ]; then 
  rm /home/kahn/reboot
  echo "caldera reboot $(date)" | mailx -r $bk -s "caldera reboot" $bk
  /sbin/reboot
fi
