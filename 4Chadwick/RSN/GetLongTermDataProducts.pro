;
; This is a setup file: GetLongTermNANOdataProducts.pro
; Updating & Plotting the computed 1-Day averages and
; the Rates of the Depth Changes.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: August   23rd, 2017 ; to be run at Garfield.
;
@~/4Chadwick/RSN/SetupRSN.pro
;
  CD, '~/4Chadwick/RSN/'
;
; After  March 11th, 2015, the following 3 lines must be done AFTER the
; RunUpdateRSNsaveFiles.pro finishs 1st; otherwise, No new results will be shown.
;
  GET_NANO_DATA_PRODUCTS,'MJ03B/MJ03B-NANO.idl','MJ03B/MJ03B-NANO1DayMeans.idl'
  GET_NANO_DATA_PRODUCTS,'MJ03D/MJ03D-NANO.idl','MJ03D/MJ03D-NANO1DayMeans.idl'
  GET_NANO_DATA_PRODUCTS,'MJ03E/MJ03E-NANO.idl','MJ03E/MJ03E-NANO1DayMeans.idl'
  GET_NANO_DATA_PRODUCTS,'MJ03F/MJ03F-NANO.idl','MJ03F/MJ03F-NANO1DayMeans.idl'
;
; March 11th, 2015  Do not use the following 3 lines!  They do not give the correct results.
;
; GET_NANO_DATA_PRODUCTS,'MJ03D/3DayMJ03D-NANO.idl','MJ03D/MJ03D-NANO1DayMeans.idl'
; GET_NANO_DATA_PRODUCTS,'MJ03E/3DayMJ03E-NANO.idl','MJ03E/MJ03E-NANO1DayMeans.idl'
; GET_NANO_DATA_PRODUCTS,'MJ03F/3DayMJ03F-NANO.idl','MJ03F/MJ03F-NANO1DayMeans.idl'
;
; The procedure: GET_NANO_DATA_PRODUCTS will call the PLOT_LTD4CHECKING
; and PLOT_LONGTERM_DATA routines like the one being shown below:
; PLOT_LTD4CHECKING, /UPDATE_PLOT,  $ ; /SHOW_PLOT,  $
;'MJ03D/MJ03D-NANO.idl','MJ03D/MJ03D-NANO1DayMeans.idl'
; PLOT_LONGTERM_DATA, /UPDATE_PLOT, 'MJ03E/LongTermNANOdataProducts.MJ03E'
;
EXIT
