cd ~/4Chadwick/RSN/
export DISPLAY=:2
rm -f RunPlotMJ03E-LILY.log
crontab crontab.null
date   > RunPlotMJ03E-LILY.log
echo Stopped crontab >> RunPlotMJ03E-LILY.log
echo Running RunPlotMJ03E-LILY.pro  >> RunPlotMJ03E-LILY.log
/usr/local/bin/idl < RunPlotMJ03E-LILY.pro  >> RunPlotMJ03E-LILY.log   2>&1
date  >> RunPlotMJ03E-LILY.log
crontab crontab
echo Resummed crontab >> RunPlotMJ03E-LILY.log