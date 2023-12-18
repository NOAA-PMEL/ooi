cd ~/4Chadwick/RSN/
export DISPLAY=:2
rm -f RunPlotMJ03D-LILY.log
crontab crontab.null
date   > RunPlotMJ03D-LILY.log
echo Stopped crontab >> RunPlotMJ03D-LILY.log
echo Running RunPlotMJ03D-RTMD.pro  >> RunPlotMJ03D-LILY.log
/usr/local/bin/idl < RunPlotMJ03D-RTMD.pro  >> RunPlotMJ03D-LILY.log   2>&1
date  >> RunPlotMJ03D-LILY.log
echo Running RunPlotMJ03D-LILY.pro  >> RunPlotMJ03D-LILY.log
/usr/local/bin/idl < RunPlotMJ03D-LILY.pro  >> RunPlotMJ03D-LILY.log   2>&1
date  >> RunPlotMJ03D-LILY.log
crontab crontab
echo Resummed crontab >> RunPlotMJ03D-LILY.log
