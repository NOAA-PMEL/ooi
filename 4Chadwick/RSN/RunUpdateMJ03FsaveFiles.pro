;
; This is a setup file: RunUpdateMJ03FsaveFiles.pro
; Updating the following IDL save files:
; 3DayMJ03F-[HEAT/IRIS/LILY/NANO].idl and
;     MJ03F-[HEAT/IRIS/LILY/NANO].idl
; Then the Plot All the data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: October   30th, 2019 ; to be run at Garfield.
;
; @~/4Chadwick/RSN/SetupRSN.pro
;
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/StatusFile4RSN.pro
.RUN ~/4Chadwick/RSN/UpdateRSNsaveFiles.pro
;
  CD, '~/4Chadwick/RSN/'
;
  UPDATE_RSN_SAVE_FILES, 'MJ03F', SAVE_FILE_DIRECTORY='~/4Chadwick/RSN'
;
; Plot all the data (No last 3-Day plots).
;
.RUN ~/idl/IDLcolors.pro
.RUN ~/4Chadwick/RSN/PlotLILYdata.pro
.RUN ~/4Chadwick/RSN/PlotLongTermDataProducts.pro
.RUN ~/4Chadwick/RSN/PlotNANOdata.pro
.RUN ~/4Chadwick/RSN/PlotRSNdata.pro
.RUN ~/4Chadwick/RSN/PlotShortTermDataProducts.pro
.RUN ~/4Chadwick/RSN/PlotTILTSdata.pro
;
;
; Generate figures for the last 6 months of the NANO and LILY data.
;
  JDAY = FLOOR( SYSTIME( /JULIAN) ) - 183.5  ; Date of 6 months ago with Time at 00:00:00.
;
  PRINT, SYSTIME() + ' Plotting the last 6-Month of the RSN-Data...' 
  PLOT_LILY_DATA, 'MJ03F/MJ03F-LILY.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
  PLOT_NANO_DATA, 'MJ03F/MJ03F-NANO.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
;
; Note that the statements above create figures to have the name of MJ03?/MJ03?25Apr2015on*.png.
; Therefore, they need to be create 1st so that they can be renamed to
; MJ03?/MJ03?Last6Months*.png.
;
  FILE_MOVE, /OVERWRITE, 'MJ03F/MJ03F25Apr2015onLILY.png', 'MJ03F/MJ03FLast6MonthsLILY.png'
  FILE_MOVE, /OVERWRITE, 'MJ03F/MJ03F25Apr2015onRTMD.png', 'MJ03F/MJ03FLast6MonthsRTMD.png'
  FILE_MOVE, /OVERWRITE, 'MJ03F/MJ03F25Apr2015onDET.png',  'MJ03F/MJ03FLast6MonthsDET.png'
  FILE_MOVE, /OVERWRITE, 'MJ03F/MJ03F25Apr2015onBPR.png',  'MJ03F/MJ03FLast6MonthsBPR.png'
; FILE_DELETE, /ALLOW_NONEXISTENT, 'MJ03F/MJ03F25Apr2015onBPR.png'  ; Not needed.
;
;
EXIT  ; RunUpdateMJ03FsaveFiles.pro
