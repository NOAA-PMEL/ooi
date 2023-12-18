;
; This is a setup file: RunUpdateLILY1HrAveFile.pro
; Updating the following IDL save files:
; MJ03[D/E/F]HrAveLILY.idl
;
; Then the Plot All the data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: April     5th, 2018 ; to be run at Garfield.
;
; @~/4Chadwick/RSN/SetupRSN.pro
;
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/GetATD-RTMD.pro
.RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
.RUN ~/4Chadwick/RSN/Update1HrAveFile.pro
;
  CD, '~/4Chadwick/RSN/'
;
; Update 1-Hr Average Tilt Data for the LILY data.
;
; The UPDATE_LILY1HR_AVERAGE_FILE is in ~/4Chadwick/RSN/UpdateLILY1HrAveFile.pro
; but it is no longer being used.  February 22nd, 2018.
; UPDATE_LILY1HR_AVERAGE_FILE, 'MJ03D/MJ03D1HrAveLILY.idl', 'MJ03D/3DayMJ03D-LILY.idl'
; UPDATE_LILY1HR_AVERAGE_FILE, 'MJ03E/MJ03E1HrAveLILY.idl', 'MJ03E/3DayMJ03E-LILY.idl'
; UPDATE_LILY1HR_AVERAGE_FILE, 'MJ03F/MJ03F1HrAveLILY.idl', 'MJ03F/3DayMJ03F-LILY.idl'
;
  UPDATE_1HR_AVERAGE_FILE, 'MJ03D/MJ03D1HrAveLILY.idl', 'MJ03D/3DayMJ03D-LILY.idl'
  UPDATE_1HR_AVERAGE_FILE, 'MJ03E/MJ03E1HrAveLILY.idl', 'MJ03E/3DayMJ03E-LILY.idl'
  UPDATE_1HR_AVERAGE_FILE, 'MJ03F/MJ03F1HrAveLILY.idl', 'MJ03F/3DayMJ03F-LILY.idl'
;
; To Create the MJ03[D/E/F]1HrAveLILY.idl files, do the following:
;
; RESTORE, 'MJ03D/MJ03D-LILY.idl'  ; to get LILY_TIME, LILY_XTILT & LILY_YTILT
; RESTORE, 'MJ03E/MJ03E-LILY.idl'  ; to get LILY_TIME, LILY_XTILT & LILY_YTILT
; RESTORE, 'MJ03F/MJ03F-LILY.idl'  ; to get LILY_TIME, LILY_XTILT & LILY_YTILT
;
; LILY_RTD = 0  &  LILY_RTM = 0  & LILY_TEMP = 0  ; Clear the Unuse Array variables.
;
; N = N_ELEMENTS( LILY_TIME )
; GET_ATD, LILY_XTILT, LILY_YTILT, LILY_TIME,  $ ; Inputs: 1-D arrays from the NEW_LILY_DATA_FILE.
;          LILY_TIME[0], LILY_TIME[N-1],       $ ; Inputs: Time Ranges in JULDAY()'s for the data.
;          3600,    $ ; Input  : Number of seconds of data to be averaged.
;          XT, YT,  $ ; Outputs: 1-D array of Averged Tilt values.
;           T         ; Output : 1-D array of JULDAY()'s.
;
; SAVE, FILE='MJ03D/MJ03D1HrAveLILY.idl', T, XT, YT
; SAVE, FILE='MJ03E/MJ03E1HrAveLILY.idl', T, XT, YT
; SAVE, FILE='MJ03F/MJ03F1HrAveLILY.idl', T, XT, YT
;
; Done: Creating the MJ03[D/E/F]1HrAveLILY.idl files.
;
; Update 1-Hr Average Tilt Data for the IRIS data.
;
  UPDATE_1HR_AVERAGE_FILE, 'MJ03D/MJ03D1HrAveIRIS.idl', 'MJ03D/3DayMJ03D-IRIS.idl'
  UPDATE_1HR_AVERAGE_FILE, 'MJ03E/MJ03E1HrAveIRIS.idl', 'MJ03E/3DayMJ03E-IRIS.idl'
  UPDATE_1HR_AVERAGE_FILE, 'MJ03F/MJ03F1HrAveIRIS.idl', 'MJ03F/3DayMJ03F-IRIS.idl'
;
EXIT  ; End: RunUpdateLILY1HrAveFile.pro
