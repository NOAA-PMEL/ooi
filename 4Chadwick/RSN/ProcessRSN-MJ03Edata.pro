;
; This is a setup file: ProcessRSN-MJ03Edata.pro for
; Updating & Plotting the incoming RSN data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: August   22nd, 2020 ; to be run at Garfield.
;
@~/4Chadwick/RSN/SetupRSN.pro
;
CD, '~/4Chadwick/RSN/'  ; <-- Required.
PROCESS_RSN_FILES, /LOG_THE_LAST_FILE, $
  '/data/ooi/ftp/mj03e/','~/4Chadwick/RSN/'        ; August 22nd, 2020
; '/data/chadwick/4andy/mj03e/','~/4Chadwick/RSN/' ; Old Directories
;
; Print the NANO data into an ASCII file.
; May 18th, 2015 - June 1st, 2015
;
; .RUN PrintRSNdata2Files.pro
; .RUN UpdateNANOdataFiles.pro
;
; UPDATE_NANO_DATA2FILE, 'MJ03E/3DayMJ03E-NANO.idl',   $
;   '/data/lau/4Chadwick/RSN/Apr-May2015MJ03E-NANO.Data'
;
; CHECK_NANO4ALERTS,'MJ03E/MJ03E-NANO.idl'
;
EXIT
