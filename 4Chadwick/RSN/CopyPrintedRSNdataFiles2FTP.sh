#copy summary files to ftp
cd ~/4Chadwick/RSN/

rm  -f CopyPrintedRSNdataFiles2FTP.log
date > CopyPrintedRSNdataFiles2FTP.log
echo Copying RSN Text Files to OOI-BOTPT-NANO >> CopyPrintedRSNdataFiles2FTP.log

# syspc:/data
cd /data/lau/4Chadwick/RSN/
yr=$(date +"%Y")
rsync -a MJ03*${yr}NANO.Data /ftpdata/pub/chadwick/OOI-BOTPT-NANO/
rsync -a MJ03*${yr}LILY.Data /ftpdata/pub/chadwick/OOI-BOTPT-LILY/
rsync -a MJ03E-F${yr}NANOdiff.Data /ftpdata/pub/chadwick/OOI-NANO-DIFF/
rsync -a *.log /ftpdata/pub/chadwick/OOI-LOG
for i in MJ03B  MJ03D  MJ03E  MJ03F; do 
  rsync -a $i/*.log /ftpdata/pub/chadwick/OOI-LOG/$i
done

echo Copying RSN Graphs to OOI-RSN-GRAPHS >> CopyPrintedRSNdataFiles2FTP.log
rsync -a /internet/httpd/html/new-eoi/rsn/numbered_plots/*.png \
  /ftpdata/pub/chadwick/OOI-RSN-GRAPHS/
rsync -a /internet/httpd/html/new-eoi/rsn/graphs/*.png \
  /ftpdata/pub/chadwick/OOI-RSN-GRAPHS/

cd ~/4Chadwick/RSN/
echo Copy Complete >> CopyPrintedRSNdataFiles2FTP.log

date >> CopyPrintedRSNdataFiles2FTP.log
