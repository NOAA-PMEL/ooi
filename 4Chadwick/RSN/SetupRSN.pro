;
; This is a setup file: SetupRSN.pro for decoding
; Updating & Plotting the incoming RSN  data for the
; Reginal Scale Nodes (RSN) from Axail.
;
; Programmer: T-K Andy Lau       NOAA/PMEL/OERD  HMSC  Newport, Oregon.
;    Revised: February 10th, 2015 ; to be run at Garfield.
;
.RUN ~/idl/IDLcolors.pro
.RUN ~/idl/is_number.pro
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/ProcessRSNdata.pro
.RUN ~/4Chadwick/RSN/ProcessNANOdata.pro
.RUN ~/4Chadwick/RSN/StatusFile4RSN.pro
.RUN ~/4Chadwick/RSN/PlotRSNdata.pro
.RUN ~/4Chadwick/RSN/PlotTILTSdata.pro
.RUN ~/4Chadwick/RSN/PlotLILYdata.pro
.RUN ~/4Chadwick/RSN/PlotNANOdata.pro
.RUN ~/4Chadwick/RSN/CheckNANOdata4Alerts.pro
.RUN ~/4Chadwick/RSN/CheckTiltData4Alerts.pro
.RUN ~/4Chadwick/RSN/DisplayAlarmSummary.pro
.RUN ~/4Chadwick/RSN/Test/GetDetectionParameters.pro
.RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
.RUN ~/4Chadwick/RSN/PlotLongTermDataProducts.pro
.RUN ~/4Chadwick/RSN/GetShortTermNANOdataProducts.pro
.RUN ~/4Chadwick/RSN/PlotShortTermDataProducts.pro
; .RUN ~/4Chadwick/RSN/GetRSN1DayFiles.pro
;
; To start, do the following:
;
; CD, '~/4Chadwick/RSN/'  ;<-- Required!
; PROCESS_RSN_FILES, /LOG_THE_LAST_FILE, $
;'/data/chadwick/4andy/mj03e/','~/4Chadwick/RSN/'
; for example.
; or
; CHECK_NANO4ALERTS,'MJ03D/MJ03D-NANO.idl'  ; for example.
; or
; PLOT_LTD4CHECKING, /UPDATE_PLOT,  $ ; /SHOW_PLOT,  $
;'MJ03D/MJ03D-NANO.idl','MJ03D/MJ03D-NANO1DayMeans.idl'
;
; Ready to go.
