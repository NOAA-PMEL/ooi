cd ~/4Chadwick/RSN/

crontab crontab.null

export DISPLAY=:2

date   >  RunGetRates.log
/usr/local/bin/idl < RunGetRates.pro >> RunGetRates.log 2>&1
date  >> RunGetRates.log
cp ~/4Chadwick/RSN/MJ03?/MJ03?-RTM*.png /internet/httpd/html/new-eoi/rsn/graphs/

date  >> RunGetRates.log
echo Running RunPlotNANOdiffE-F.pro >> RunGetRates.log
date   >  RunPlotNANOdiffE-F.log
/usr/local/bin/idl < RunPlotNANOdiffE-F.pro >> RunPlotNANOdiffE-F.log 2>&1
date  >> RunPlotNANOdiffE-F.log

date  >> RunGetRates.log
echo Running RunPlotNANOdiffE-Frate.pro >> RunGetRates.log
date   >  RunPlotNANOdiffE-Frates.log
/usr/local/bin/idl < RunPlotNANOdiffE-Frates.pro >> RunPlotNANOdiffE-Frates.log 2>&1
date  >> RunPlotNANOdiffE-Frates.log
cp ~/4Chadwick/RSN/MJ03F/NANO*E-F.png /internet/httpd/html/new-eoi/rsn/graphs/
date  >> RunGetRates.log

crontab crontab
echo Resummed crontab >> RunGetRates.log

rm -f /internet/httpd/html/new-eoi/rsn/graphs/MJ03?-RTM1DayMeans.png
rm -f /internet/httpd/html/new-eoi/rsn/graphs/MJ03F-RTM4WkRATE.png

