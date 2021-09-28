;
; This is a setup file: RunDisplayAlarmSummary.pro
; for running the program: DisplayAlarmSummary.pro
;
; Programmer: T-K Andy Lau       NOAA/PMEL/OERD  HMSC  Newport, Oregon.
;    Revised: December 19th, 2014 ; to be run at Garfield.
;
.RUN ~/idl/IDLcolors.pro
.RUN ~/4Chadwick/RSN/CheckNANOdata4Alerts.pro
.RUN ~/4Chadwick/RSN/DisplayAlarmSummary.pro
;
 CD, '~/4Chadwick/RSN/'
 DISPLAY_ALARM_SUMMARY, '~/4Chadwick/RSN/', UPDATE=1
;
; Done.
