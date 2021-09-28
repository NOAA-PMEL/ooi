;
; This is a setup file: ProcessRSN-MJ03Ddata.pro for
; Updating & Plotting the incoming RSN data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: August  22nd, 2020  ; to be run at Garfield.
;
@~/4Chadwick/RSN/SetupRSN.pro
;
CD, '~/4Chadwick/RSN/'  ; <-- Required.
PROCESS_RSN_FILES, /LOG_THE_LAST_FILE, $
  '/data/ooi/ftp/mj03d/','~/4Chadwick/RSN/'         ; August 22nd, 2020
; '/data/chadwick/4andy/mj03d/','~/4Chadwick/RSN/'  ; Old Directories
;
; Print the NANO data into an ASCII file.
; May 18th, 2015  - June 1st, 2015
;
; .RUN PrintRSNdata2Files.pro
; .RUN UpdateNANOdataFiles.pro 
;
; UPDATE_NANO_DATA2FILE, 'MJ03D/3DayMJ03D-NANO.idl',   $
;   '/data/lau/4Chadwick/RSN/Apr-May2015MJ03D-NANO.Data'
;
; CHECK_NANO4ALERTS,'MJ03D/MJ03D-NANO.idl'
;
EXIT
