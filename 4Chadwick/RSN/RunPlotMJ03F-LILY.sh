cd ~/4Chadwick/RSN/
export DISPLAY=:2
rm -f RunPlotMJ03F-LILY.log
crontab crontab.null
date   > RunPlotMJ03F-LILY.log
echo Stopped crontab >> RunPlotMJ03F-LILY.log
echo Running RunPlotMJ03F-LILY.pro  >> RunPlotMJ03F-LILY.log
/usr/local/bin/idl < RunPlotMJ03F-LILY.pro  >> RunPlotMJ03F-LILY.log   2>&1
date  >> RunPlotMJ03F-LILY.log
crontab crontab
echo Resummed crontab >> RunPlotMJ03F-LILY.log