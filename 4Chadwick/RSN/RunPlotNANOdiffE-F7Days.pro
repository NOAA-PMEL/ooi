;
; File: RunPlotNANOdiffE-F7Days.pro
;
; Display the Difference between the NANO Data from the stations:
; MJ03F and MJ03[B/D/E/].
;
; Created: August  17th, 2018
; Revised: October 31st, 2018
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
 .RUN ~/4Chadwick/RSN/match.pro
;
  PRINT, SYSTIME() + ' Start running of RunPlotNANOdiffE-F7Days.pro'
;
; B = 0  ; Show the plotting on screen.  B=0 means No  Buffer is used when plotting.
  B = 1  ; No   the plotting on screen.  B=1 means Use Buffer, i.e. PIXMAP for plotting.
;
; Restrieve the NANO data Array variables:
; NANO_DETIDE, NANO_PSIA, NANO_TEMP and NANO_TIME.
;
  RESTORE, '~/4Chadwick/RSN/MJ03E/3DayMJ03E-NANO.idl'  ; It contains 7 Day data.
  MJ03JE_TIME   = TEMPORARY( NANO_TIME   )
  MJ03JE_DETIDE = TEMPORARY( NANO_DETIDE )  ; Rename the arrays' variables.
; MJ03JE_PSIA   = TEMPORARY( NANO_PSIA   )
; MJ03JE_TEMP   = TEMPORARY( NANO_TEMP   )  ; Temperature values will not be used.
  RESTORE, '~/4Chadwick/RSN/MJ03F/3DayMJ03F-NANO.idl'
  MJ03JF_TIME   = TEMPORARY( NANO_TIME   )
  MJ03JF_DETIDE = TEMPORARY( NANO_DETIDE )  ; Rename the arrays' variables.
; MJ03JF_PSIA   = TEMPORARY( NANO_PSIA   )
; MJ03JF_TEMP   = TEMPORARY( NANO_TEMP   )  ; Temperature values will not be used.
;
  NANO_PSIA     = 0  ; These 2 variables
  NANO_TEMP     = 0  ; and not being used.
;
; Compute the differences between MJ03JE & MJ03JF, i.e., MJ03JE - MJ03JF
;
  MATCH, MJ03JF_TIME, MJ03JE_TIME, JF, JE, EPSILON=0.000001
  NANO_DIFF = ( MJ03JE_DETIDE[JE] - MJ03JF_DETIDE[JF] )
;
; Move back 7 Days in case the 3DayMJ03[E-F]-NANO.idl contains > 7 Days of data.
;
  N = N_ELEMENTS( JF ) - 1
  T = ROUND( MJ03JF_TIME[JF[N]] - 7 ) - 0.5    ; Move back 7 days.
; The ROUND( ) - 0.5 will make sure the date starts at 00:00:00.
  PRINT, FORMAT='(C())', T  ; for checking.
  K = LOCATE_TIME_POSITION( MJ03JF_TIME[JF], T )
;
; Create a Time Range for labelling.
;
  T  = STRING( MJ03JF_TIME[JF[K[0]]],        $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  T += ' to ' + STRING( MJ03JF_TIME[JF[N]],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Determine the Y-range for plotting.  October 26th, 2018.
;
  S = STDEV( NANO_DIFF[K:N], M )  ; where M = average and S = Standard Deviation
  Y = M + [-S,S]*4.0              ; Y[0:1] = Min. & Max. Y Plotting Range.
;
; Display the OOI-BPR De-tide Depth Difference for the last 7 days.
;
  P = PLOT( MJ03JF_TIME[JF[K:N]], NANO_DIFF[K:N], 'r',  DIMENSION=[1024,512],  $
            TITLE='OOI-BPR Difference: MJ03E - MJ03F, last 7 Days.', YRANGE=Y, $
           XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XSTYLE=1, XMINOR=23,        $
           XTITLE=T,  YTITLE='De-tided Depth Difference in meters',  BUFFER=B  )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOdifferenceLast7DaysE-F.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/NANOdifferenceLast7DaysE-F.png is created.'
;
  PRINT, SYSTIME() + ' Finish running of RunPlotNANOdiffE-F7Days.pro'
;
; End of File: RunPlotNANOdiffE-F7Days.pro
