;
; This is a setup file: ProcessRSN-MJ03Fdata.pro for
; Updating & Plotting the incoming RSN data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: November 17th, 2014 ; to be run at Garfield.
;
.RUN ~/4Chadwick/RSN/TestEmailAlerts.pro
.RUN ~/idl/IDLcolors.pro
;
CD, '~/4Chadwick/RSN/'
;
  SEND_EMAIL_ALERT, 3
; WINDOW, /FREE, /PIXMAP, XSIZE=10, YSIZE=10
;
EXIT
