;
; This is a setup file: RunPlotMJ03Fdata.pro  to
; Plot Plotting the last 7-Day, All and data since April 25th, 2015 data
; form the station: MJ03F.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: March     25th, 2019 ; to be run at Garfield & Caldera.
;
; @~/4Chadwick/RSN/SetupRSN.pro
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
;
  CD, '~/4Chadwick/RSN/'
;
; Plot all the data (No last 3-Day plots).
;
 .RUN ~/rsn/IDLcolors.pro
 .RUN ~/4Chadwick/RSN/PlotLILYdata.pro
;.RUN ~/4Chadwick/RSN/PlotLongTermDataProducts.pro
 .RUN ~/4Chadwick/RSN/PlotNANOdata.pro
 .RUN ~/4Chadwick/RSN/PlotRSNdata.pro
;.RUN ~/4Chadwick/RSN/PlotShortTermDataProducts.pro
 .RUN ~/4Chadwick/RSN/PlotTILTSdata.pro
;
; Below, generate figures for the data of the last 7-Day, All the data and
;                                 data since April 25th, 2015
;
  PRINT, SYSTIME() + ' Plotting the last 7-Day, All and data since April 25th, 2015...' 
; PRINT, SYSTIME() + ' using    data from the station: MJ03F...'
  PRINT, SYSTIME() + ' using    data from the station: MJ03E...'
;
  PLOT_NANO_DATA, 'MJ03F/MJ03F-NANO.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 26th, 2015
  PLOT_HEAT_DATA, 'MJ03F/MJ03F-HEAT.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
  PLOT_IRIS_DATA, 'MJ03F/MJ03F-IRIS.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
 ;PLOT_LILY_DATA, 'MJ03F/MJ03F-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
 ;                 SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
;
  PRINT, SYSTIME() + 'Done Plotting MJ03F data.'
;
EXIT
