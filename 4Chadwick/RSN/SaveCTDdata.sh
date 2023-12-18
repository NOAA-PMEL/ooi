cd ~/4Chadwick/RSN/

crontab crontab.null
date  > SaveCTDdata.log
echo Stopped crontab            >> SaveCTDdata.log
echo Running RunSaveCTDdata.pro >> SaveCTDdata.log
/usr/local/bin/idl < RunSaveCTDdata.pro   >> SaveCTDdata.log 2>&1
/usr/local/bin/idl < RunPlotCTD4MJ03B.pro >> SaveCTDdata.log 2>&1
/usr/local/bin/idl < RunPlotCTD4MJ03E.pro >> SaveCTDdata.log 2>&1
/usr/local/bin/idl < RunPlotCTD4MJ03F.pro >> SaveCTDdata.log 2>&1
date >> SaveCTDdata.log
echo Copying CTD graphic files to /internet/httpd/html/new-eoi/rsn/graphs/ >> SaveCTDdata.log
cp ~/4Chadwick/RSN/MJ03B/*CTD*.png /internet/httpd/html/new-eoi/rsn/graphs/
crontab crontab
echo Resumed crontab >> SaveCTDdata.log