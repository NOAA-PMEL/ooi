;
; This is a setup file: RunPlotRSNdata.pro  to
; Plot Plotting the last 7-Day, All and data since April 25th, 2015 data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: March     22nd, 2019 ; to be run at Garfield & Caldera.
;
; @~/4Chadwick/RSN/SetupRSN.pro
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
;
  CD, '~/4Chadwick/RSN/'
;
; The following 4 statements are no longer being used since October 15th, 2014.
;
; PLOT_RSN_DATA,'MJ03F/MJ03F-HEAT.idl',[-3,1],SHOW_PLOT=0,/UPDATE_PLOTS
; PLOT_RSN_DATA,'MJ03F/MJ03F-IRIS.idl',[-3,1],SHOW_PLOT=0,/UPDATE_PLOTS
; PLOT_RSN_DATA,'MJ03F/MJ03F-LILY.idl',[-3,1],SHOW_PLOT=0,/UPDATE_PLOTS
; PLOT_RSN_DATA,'MJ03F/MJ03F-NANO.idl',[-3,1],SHOW_PLOT=0,/UPDATE_PLOTS
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
  PRINT, SYSTIME() + ' using    data from the station: MJ03D...'
  PLOT_HEAT_DATA, 'MJ03D/MJ03D-HEAT.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
  PLOT_IRIS_DATA, 'MJ03D/MJ03D-IRIS.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
  PLOT_NANO_DATA, 'MJ03D/MJ03D-NANO.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 26th, 2015
 ;PLOT_LILY_DATA, 'MJ03D/MJ03D-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
 ;                 SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
;
  PRINT, SYSTIME() + ' Plotting data from the station: MJ03E...'
  PLOT_HEAT_DATA, 'MJ03E/MJ03E-HEAT.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
  PLOT_IRIS_DATA, 'MJ03E/MJ03E-IRIS.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
  PLOT_NANO_DATA, 'MJ03E/MJ03E-NANO.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 26th, 2015
 ;PLOT_LILY_DATA, 'MJ03E/MJ03E-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
 ;                 SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
;
; MJ03F data will be plotted from the script: RunPlotMJ03Fdata.pro
;
; The reason the MJ03F data plotting are skipped here;
; because after plottling the data from the 2 stations above, IDL will
; have trouble to allocate memory for plotting.  March 22nd, 2019
;
; PRINT, SYSTIME() + ' Plotting data from the station: MJ03F...'
; PLOT_HEAT_DATA, 'MJ03F/MJ03F-HEAT.idl',[ 0,1],SHOW_PLOT=0,UPDATE_PLOTS=1
; PLOT_IRIS_DATA, 'MJ03F/MJ03F-IRIS.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
; PLOT_NANO_DATA, 'MJ03F/MJ03F-NANO.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 26th, 2015
;;PLOT_LILY_DATA, 'MJ03F/MJ03F-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;;                 SHOW_PLOT=0,UPDATE_PLOTS=1  ; May 27th, 2015
  PRINT, SYSTIME() + 'Done Plotting.'
;
EXIT
