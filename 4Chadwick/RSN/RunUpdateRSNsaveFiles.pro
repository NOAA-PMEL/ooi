;
; This is a setup file: RunUpdateRSNsaveFiles.pro
; Updating the following IDL save files:
; 3DayMJ03[B/D/E/F]-[HEAT/IRIS/LILY/NANO].idl and
;     MJ03[B/D/E/F]-[HEAT/IRIS/LILY/NANO].idl
; Then the Plot All the data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: October   24th, 2019 ; to be run at Garfield.
;
; @~/4Chadwick/RSN/SetupRSN.pro
;
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/StatusFile4RSN.pro
.RUN ~/4Chadwick/RSN/UpdateRSNsaveFiles.pro
;
  CD, '~/4Chadwick/RSN/'
;
  UPDATE_RSN_SAVE_FILES, 'MJ03B', SAVE_FILE_DIRECTORY='~/4Chadwick/RSN'
  UPDATE_RSN_SAVE_FILES, 'MJ03D', SAVE_FILE_DIRECTORY='~/4Chadwick/RSN'
 ;UPDATE_RSN_SAVE_FILES, 'MJ03E', SAVE_FILE_DIRECTORY='~/4Chadwick/RSN'
 ;UPDATE_RSN_SAVE_FILES, 'MJ03F', SAVE_FILE_DIRECTORY='~/4Chadwick/RSN'
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
  PRINT, SYSTIME() + ' Plotting the MJ03B-Data...' 
  PLOT_HEAT_DATA, 'MJ03B/MJ03B-HEAT.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
; PLOT_IRIS_DATA, 'MJ03B/MJ03B-IRIS.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
; PLOT_LILY_DATA, 'MJ03B/MJ03B-LILY.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
; PLOT_NANO_DATA, 'MJ03B/MJ03B-NANO.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
;
; Note that [ 0,0,JULDAY(8,17,2017,0,0,0)] parameter will plot only the
; the data start from August 17th, 2017 on. and the middle value: 0 means
; No plot for All the data.  This is used for the MJ03B NANO data.
; For the IRIS and LILY data, use JULDAY(9,2,2017,0,0,0).
;
  PLOT_IRIS_DATA, 'MJ03B/MJ03B-IRIS.idl',[ 0,1,JULDAY(9, 2,2017,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; September 15th, 2017
  PLOT_LILY_DATA, 'MJ03B/MJ03B-LILY.idl',[ 0,0,JULDAY(9, 2,2017,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; September 15th, 2017
  PLOT_NANO_DATA, 'MJ03B/MJ03B-NANO.idl',[ 0,0,JULDAY(8,17,2017,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; September  2nd, 2017
;
; Rename the MJ03B/MJ03B25Apr2015on[IRIS/IRIStilts].png & MJ03B/MJ03B25Apr2015on[LILY/RTMD].png
; files to MJ03B/MJ03BAll[IRIS/IRIStilts].png and MJ03B/MJ03BAll[LILY/RTMD].png respectively
; so that the RSN web site will pick up the correct files to display,
; i.e. MJ03B25Apr2015on[LILY/RTMD].png files will be the figures for the All the data
; from the biginning to present for example.
;
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onIRIS.png',      'MJ03B/MJ03B-AllIRIS.png'
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onIRIStilts.png', 'MJ03B/MJ03B-AllIRIStilts.png'
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onLILY.png',      'MJ03B/MJ03BAllLILY.png'
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onRTMD.png',      'MJ03B/MJ03BAllRTMD.png'
;
; Rename the MJ03B/MJ03B25Apr2015on[BPR & DET].png files to
; MJ03B/MJ03B-All[BPR & DET].png so that the RSN web site will pick up
; the correct files to display,
; i.e. the MJ03B/MJ03B25Apr2015on[BPR & DET].png files will be the figures
; for  the All the dat from the biginning to present.  September 5th, 2017
;
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onBPR.png', 'MJ03B/MJ03B-AllBPR.png'
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onDET.png', 'MJ03B/MJ03B-AllDET.png'
;
; March 20th, 2018
;
; Generate figures for the last 6 months of the NANO and LILY data.
;
  JDAY = FLOOR( SYSTIME( /JULIAN) ) - 183.5  ; Date of 6 months ago with Time at 00:00:00.
;
  PRINT, SYSTIME() + ' Plotting the last 6-Month of the RSN-Data...' 
  PLOT_LILY_DATA, 'MJ03B/MJ03B-LILY.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
  PLOT_NANO_DATA, 'MJ03B/MJ03B-NANO.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
  PLOT_LILY_DATA, 'MJ03D/MJ03D-LILY.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
  PLOT_NANO_DATA, 'MJ03D/MJ03D-NANO.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
 ;PLOT_LILY_DATA, 'MJ03E/MJ03E-LILY.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
 ;PLOT_NANO_DATA, 'MJ03E/MJ03E-NANO.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
 ;PLOT_LILY_DATA, 'MJ03F/MJ03F-LILY.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
 ;PLOT_NANO_DATA, 'MJ03F/MJ03F-NANO.idl',[ 0,0,JDAY], SHOW_PLOT=0,UPDATE_PLOTS=1
;
; Note that the statements above create figures to have the name of MJ03?/MJ03?25Apr2015on*.png.
; Therefore, they need to be create 1st so that they can be renamed to
; MJ03?/MJ03?Last6Months*.png.
;
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onLILY.png', 'MJ03B/MJ03BLast6MonthsLILY.png'
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onRTMD.png', 'MJ03B/MJ03BLast6MonthsRTMD.png'
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onDET.png',  'MJ03B/MJ03BLast6MonthsDET.png'
  FILE_MOVE, /OVERWRITE, 'MJ03B/MJ03B25Apr2015onBPR.png',  'MJ03B/MJ03BLast6MonthsBPR.png'
; FILE_DELETE, /ALLOW_NONEXISTENT. 'MJ03B/MJ03B25Apr2015onBPR.png'  ; Not needed.
  FILE_MOVE, /OVERWRITE, 'MJ03D/MJ03D25Apr2015onLILY.png', 'MJ03D/MJ03DLast6MonthsLILY.png'
  FILE_MOVE, /OVERWRITE, 'MJ03D/MJ03D25Apr2015onRTMD.png', 'MJ03D/MJ03DLast6MonthsRTMD.png'
  FILE_MOVE, /OVERWRITE, 'MJ03D/MJ03D25Apr2015onDET.png',  'MJ03D/MJ03DLast6MonthsDET.png'
  FILE_MOVE, /OVERWRITE, 'MJ03D/MJ03D25Apr2015onBPR.png',  'MJ03D/MJ03DLast6MonthsBPR.png'
; FILE_DELETE, /ALLOW_NONEXISTENT. 'MJ03D/MJ03D25Apr2015onBPR.png'  ; Not needed.
 ;FILE_MOVE, /OVERWRITE, 'MJ03E/MJ03E25Apr2015onLILY.png', 'MJ03E/MJ03ELast6MonthsLILY.png'
 ;FILE_MOVE, /OVERWRITE, 'MJ03E/MJ03E25Apr2015onRTMD.png', 'MJ03E/MJ03ELast6MonthsRTMD.png'
 ;FILE_MOVE, /OVERWRITE, 'MJ03E/MJ03E25Apr2015onDET.png',  'MJ03E/MJ03ELast6MonthsDET.png'
 ;FILE_MOVE, /OVERWRITE, 'MJ03E/MJ03E25Apr2015onBPR.png',  'MJ03E/MJ03ELast6MonthsBPR.png'
; FILE_DELETE, /ALLOW_NONEXISTENT. 'MJ03E/MJ03E25Apr2015onBPR.png'  ; Not needed.
 ;FILE_MOVE, /OVERWRITE, 'MJ03F/MJ03F25Apr2015onLILY.png', 'MJ03F/MJ03FLast6MonthsLILY.png'
 ;FILE_MOVE, /OVERWRITE, 'MJ03F/MJ03F25Apr2015onRTMD.png', 'MJ03F/MJ03FLast6MonthsRTMD.png'
 ;FILE_MOVE, /OVERWRITE, 'MJ03F/MJ03F25Apr2015onDET.png',  'MJ03F/MJ03FLast6MonthsDET.png'
 ;FILE_MOVE, /OVERWRITE, 'MJ03F/MJ03F25Apr2015onBPR.png',  'MJ03F/MJ03FLast6MonthsBPR.png'
; FILE_DELETE, /ALLOW_NONEXISTENT, 'MJ03F/MJ03F25Apr2015onBPR.png'  ; Not needed.
;
; Done Generating the figures for the last 6 months of data.
;
; Below, generate figures for the data of the last 7-Day, All the data and
;                                 data since April 25th, 2015
; The following steps are being run at the script: RunPlotRSNdata.pro
;
; PRINT, SYSTIME() + ' Plotting the last 7-Day, All and data since April 25th, 2015...' 
; PLOT_HEAT_DATA, 'MJ03D/MJ03D-HEAT.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
; PLOT_IRIS_DATA, 'MJ03D/MJ03D-IRIS.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
; PLOT_NANO_DATA, 'MJ03D/MJ03D-NANO.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 26th, 2015
;;PLOT_LILY_DATA, 'MJ03D/MJ03D-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;;                 SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
;
; PLOT_HEAT_DATA, 'MJ03E/MJ03E-HEAT.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
; PLOT_IRIS_DATA, 'MJ03E/MJ03E-IRIS.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
; PLOT_NANO_DATA, 'MJ03E/MJ03E-NANO.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 26th, 2015
;;PLOT_LILY_DATA, 'MJ03E/MJ03E-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;;                 SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
;
; PLOT_HEAT_DATA, 'MJ03F/MJ03F-HEAT.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
; PLOT_IRIS_DATA, 'MJ03F/MJ03F-IRIS.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
; PLOT_NANO_DATA, 'MJ03F/MJ03F-NANO.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 26th, 2015
;;PLOT_LILY_DATA, 'MJ03F/MJ03F-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;;                 SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
;
EXIT
