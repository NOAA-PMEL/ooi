cd ~/4Chadwick/RSN/

crontab crontab.null

export DISPLAY=:2

date   >  RunForecastDates.log
/usr/local/bin/idl < RunForecastDates.pro     >> RunForecastDates.log 2>&1
date  >>  RunForecastDates.log
/usr/local/bin/idl < RunDiffForecastDates.pro >> RunForecastDates.log 2>&1
date  >>  RunForecastDates.log

crontab crontab
echo Resummed crontab >> RunForecastDates.log
cp ~/4Chadwick/RSN/MJ03F/Forecast*.png     /internet/httpd/html/new-eoi/rsn/graphs/
cp ~/4Chadwick/RSN/MJ03F/ScatterDates*.png /internet/httpd/html/new-eoi/rsn/graphs/
