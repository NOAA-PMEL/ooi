;
; This is a setup file: RunProcessRSNdata.pro for
; Updating & Plotting the incoming RSN data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: October 15th, 2014 ; to be run at Garfield.
;
@~/4Chadwick/RSN/SetupRSN.pro
;
CD, '~/4Chadwick/RSN/'
; PROCESS_RSN_FILES, /LOG_THE_LAST_FILE, $
; '/data/chadwick/4andy/mj03f/','~/4Chadwick/RSN/'
CHECK_OPEN_WINDOW_STATUS, STATUS & HELP, STATUS
EXIT
