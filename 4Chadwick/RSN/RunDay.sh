#!/bin/bash
# these were in crontab individually, with an hour or two between
RunDay="\
/home/kahn/ooi/rsn/RunUpdateRSNsaveFiles.job
/home/kahn/ooi/rsn/RunGetRates.job
/home/kahn/ooi/rsn/RunPlotMJ03D-LILY.job
/home/kahn/ooi/rsn/RunPlotMJ03E-LILY.job
/home/kahn/ooi/rsn/RunPlotMJ03F-LILY.job
/home/kahn/ooi/rsn/RunForecastDates.job
/home/kahn/ooi/rsn/SaveCTDdata.job
/home/kahn/ooi/rsn/BackUpIDLfiles2data.sh
/home/kahn/ooi/rsn/RunPrintRSNdata2Files.job
/home/kahn/ooi/rsn/CopyPrintedRSNdataFiles2FTP.sh
"

cd $( dirname $0 )
ofile=$( basename -s .sh $0 ).log
if [ -f "$ofile" ]; then rm $ofile; fi

for j in $RunDay; do
  echo "$j $(date)" >> $ofile
  $j
done
