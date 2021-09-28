rsn=~/4Chadwick/RSN
cd $rsn
rm *.old
# just a few executables not named .pro .job
for i in BackUpIDLfiles2data JoinBrokenLines UpdateIDLfiles2RSN; do 
  ln -s $i $i.sh
done
pj=$(ls *.{pro,job,sh})
sed --in-place=.lau 's;/home/lau;~;' $(grep -l /home/lau $pj)
sed -i.lau 's;ProcessRSNdata.crontab;crontab;' $(grep -l data.crontab $pj)
sed -i.lau 's;crontab -r;crontab crontab.null;' $(grep -l 'crontab -r' $pj)
sed -i.lau '/^at /d' $(grep -l '^at ' $pj)
sed -i.lau 's;CatchUpRSNdatalog;CatchUpRSNdata.log;' CatchUpRSNdata.job
mv CatchUpRSNdatalog CatchUpRSNdata.log
ln -s ~/crontab

# root@syspc 08:14:54 /data #
 find /data0 -user lau > /data0/files-owned-by-lau 
 find /data0 -user lau -print0 | xargs -0 chown kahn
 find /data1 -user lau -print0 | xargs -0 chown kahn
 cd /data
  mv MARS /data/lau/MARS.2012
  ln -s /data/lau/4Chadwick/MARS .
