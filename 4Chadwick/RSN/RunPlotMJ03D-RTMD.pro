;
; This is a setup file: RunPlotMJ03D-RTMD.pro
; for plotting the the last 7-Day, All and data since April 25th, 2015
; fo the data in MJ03D-LILY.idl
; Then the Plot All the data.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: June      11th, 2018 ; to be run at Garfield.
;
; @~/4Chadwick/RSN/SetupRSN.pro
;
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/StatusFile4RSN.pro
.RUN ~/4Chadwick/RSN/UpdateRSNsaveFiles.pro
;
.RUN ~/rsn/IDLcolors.pro
.RUN ~/4Chadwick/RSN/PlotLILYdata.pro
.RUN ~/4Chadwick/RSN/PlotLongTermDataProducts.pro
.RUN ~/4Chadwick/RSN/PlotNANOdata.pro
.RUN ~/4Chadwick/RSN/PlotRSNdata.pro
.RUN ~/4Chadwick/RSN/PlotShortTermDataProducts.pro
.RUN ~/4Chadwick/RSN/PlotTILTSdata.pro
.RUN ~/4Chadwick/RSN/PlotLILY.pro
;
  CD, '~/4Chadwick/RSN/'
;
  PRINT, SYSTIME() + ' Plotting the Resultant Magnitudes and Directions...'
  PLOT_LILY_RTMD, 'MJ03D/MJ03D-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
                   SHOW_PLOT=0,UPDATE_PLOTS=1  ; April 17th, 2018
; PRINT, SYSTIME() + ' Plotting the last 7-Day, All and data since April 25th, 2015...'
; PLOT_LILY_TXYT, 'MJ03D/MJ03D-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; April 17th, 2018
; PRINT, SYSTIME() + ' Plotting DATA IN MJ03D-LILY.idl'
; Note that the PLOT_LILY_DATA will do the PLOT_LILY_TXYT & PLOT_LILY_RTMD combined.
; PLOT_LILY_DATA, 'MJ03D/MJ03D-LILY.idl',[ 0,1,JULDAY(4,25,2015,0,0,0)], $
;                  SHOW_PLOT=0,UPDATE_PLOTS=1  ; May   27th, 2015
;
  EXIT ; IDL.
;
; End of RunPlotMJ03D-RTMD.pro
