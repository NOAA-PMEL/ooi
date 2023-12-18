;
; File: RunPlotNANOdiffE-Frates.pro
;
; Display the last 3 months of the Difference between the NANO (detided) Data
; from the stations: MJ03F and MJ03[B/D/E/] and overlay the 7-, 8- & 12-week
; rates of the depth changes with the fitted lines.
;
; Created: August   17th, 2018
; Revised: November 19th, 2018
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
;.RUN ~/idl/match.pro
;
  CD, '~/4Chadwick/RSN/'
  PRINT, SYSTIME() + ' Start of RunPlotNANOdiffE-Frates.pro'
;
; Get the 4-, 8- & 12-week Depth Change Rates.
;
  RESTORE, 'MJ03F/NANOdiffRatesMJ03E-F.idl'  ; NANO1DAY_MEAN,NANO1DAY_TIME, RATE_4WK,RATE_8WK,RATE12WK
;
  MN = FLOOR( MIN( RATE_4WK, MAX=MX ) )
  MX =  CEIL( MX )
   S = ( MN + MX )/2.0  ; Half of total Y-range.
  MN = FLOOR( MN - S )
  MX =  CEIL( MX + S )
;
; Create a Time Range for labelling.
;
  N  = N_ELEMENTS( NANO1DAY_TIME )
  T  = STRING( NANO1DAY_TIME[0],             $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
  T += ' to ' + STRING( NANO1DAY_TIME[N-1],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
;
; Display the 4-week, 8-week and 12-week Rates.
;
  P = PLOT( NANO1DAY_TIME, RATE_4WK,  LINESTYLE='NONE', BUFFER=1,  $
            SYMBOL='o', SYM_COLOR='BLUE', SYM_FILLED=1,  $
            TITLE='OOI-BPR Difference (MJ03E - MJ03F) Long-Term Average Rates of Depth Change.', $
;          XRANGE=[ JULDAY(1,1,2015), JULDAY(1,1,2022) ],                   $
           XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XMINOR=11, XSTYLE=1,     $
           XTITLE=T, YTITLE='cm/year', YRANGE=[MN,MX], DIMENSION=[1024,512] )
  S = SYMBOL( /NORMAL, 0.40, 0.8, 'o',  LABEL_COLOR='BLUE',  LABEL_STRING='4-week',  $
              /SYM_FILLED, SYM_COLOR='BLUE'  )
  S = PLOT( NANO1DAY_TIME, RATE_8WK,  LINESTYLE='NONE',   $
           /OVERPLOT, YRANGE=[MN,MX], $  ; So the Y-Axis will not be adjusted.
            SYMBOL='o', SYM_COLOR='GREEN', SYM_FILLED=1   )
  S = SYMBOL( /NORMAL, 0.50, 0.8, 'o',  LABEL_COLOR='GREEN', LABEL_STRING='8-week',  $
              /SYM_FILLED, SYM_COLOR='GREEN' )
  S = PLOT( NANO1DAY_TIME, RATE12WK,  LINESTYLE='NONE',   $
           /OVERPLOT, YRANGE=[MN,MX], $  ; So the Y-Axis will not be adjusted.
            SYMBOL='o', SYM_COLOR='PURPLE', SYM_FILLED=1   )
  S = SYMBOL( /NORMAL, 0.60, 0.8, 'o',  LABEL_COLOR='PURPLE', LABEL_STRING='12-week', $
              /SYM_FILLED, SYM_COLOR='PURPLE' )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOdifferenceLTratesE-F.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/NANOdifferenceLTratesE-F.png is created.'
;
; Display the depth diffienerces of the last 3 months and overplot the 1-Day Means
; plus the fitted lines for the 4-, 8- & 12-week Depth Change Rates.
;
; Retrieve the NANO differences data (De-tided pressure data from MJ03E - MJ03F ).
;
  RESTORE, 'MJ03F/NANOdifferencesMJ03E-F.idl'  ; NANO_DIFF, NANO_TIME
;
; Use the matched times: MJ03JF_TIME[JF] and locate the date 3 months from the current data.
;
  N = N_ELEMENTS( NANO_TIME )     - 1
  M = N_ELEMENTS( NANO1DAY_TIME ) - 1
  IF NANO_TIME[N] LT NANO1DAY_TIME[M] THEN T = NANO_TIME[N] ELSE T = NANO1DAY_TIME[M]
  N = LOCATE_TIME_POSITION( NANO_TIME, T )
  T = ROUND( T -  91 ) - 0.5  ; Move back 91.5 days or 3 months.
; The ROUND( ) - 0.5 will make sure the date starts at 00:00:00.
  PRINT, FORMAT='(C())', T  ; for checking.
  I = LOCATE_TIME_POSITION( NANO_TIME, T )
;
; Create a Time Range for labelling.
;
  T  = STRING( NANO_TIME[I],           $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  T += ' to ' + STRING( NANO_TIME[N],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Determine the Y-range for plotting.  October 26th, 2018.
;
  D = STDEV( NANO_DIFF[I:N], M )  ; where M = average and D = Standard Deviation
  Y = M + [-D,D]*3.0              ; Y[0:1] = Min. & Max. Y Plotting Range.
;
; Display the OOI-BPR De-tide Depth Difference for the last 3 months.
;
  P = PLOT( NANO_TIME[I:N], NANO_DIFF[I:N], 'r', BUFFER=1, DIMENSION=[1024,512],  $
            TITLE='OOI-BPR Difference: MJ03E - MJ03F, last 3 months',             $
           XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XSTYLE=1, XMINOR=29, YRANGE=Y, $
           XTITLE=T,  YTITLE='De-tided Depth Difference in meters' )
;
  CALDAT, NANO_TIME[I],  M,D,YR  ; Get M)onth, D)ay & Y)ear.
  S = LOCATE_TIME_POSITION( NANO1DAY_TIME, JULDAY( M,D,YR ) )
  CALDAT, NANO_TIME[N],  M,D,YR  ; Get M)onth, D)ay & Y)ear.
  M = LOCATE_TIME_POSITION( NANO1DAY_TIME, JULDAY( M,D,YR ) )
;
  PRINT, FORMAT='(C())', NANO_TIME[I], NANO1DAY_TIME[S]  ; Check the results and
  PRINT, FORMAT='(C())', NANO_TIME[N], NANO1DAY_TIME[M]  ; They should be equal.
;
  P = PLOT( NANO1DAY_TIME[S:M], NANO1DAY_MEAN[S:M],  LINESTYLE='NONE',   $
           /OVERPLOT, $  ; So the Y-Axis will not be adjusted.
            SYMBOL='o', SYM_COLOR='PURPLE', SYM_FILLED=1   )
; P.ORDER, /BRING_TO_FRONT  ; at Caldera P.C. only.
;
  X = NANO1DAY_TIME[S:M] - NANO1DAY_TIME[S] ; in Days.
  Y = NANO1DAY_MEAN[S:M]     ; 1-Day Averaged Depthed.
; Compute a Linear least-square fit method where R = [A,B] as y = A + B*X.
  R = LINFIT( X, NANO1DAY_MEAN[S:M], YFIT=Y )  ;  where Y = Fitted values.
  D = JULDAY( 12,31,YR ) - JULDAY( 1,0,YR )    ; Total Days of the Current Year = 365 or 366.
; Convert the Rate of Depth (meters) Change/Day into cm/ATE =  RATE*100.0*
  RATE =  R[1]           ; The uplift should > 0 if depths < 0.
  RATE =  RATE*100.0*D   ; where 100 cm = 1 meter
  RATE = STRING( FORMAT='(F5.1)', RATE )  ; into a string: '19.1" e.g.
;
  T = TEXT( COLOR='PURPLE',  /NORMAL, 0.10, 0.03,           $
            '12-week avg. uplift rate: ' + RATE + ' cm/yr'  )
;
  P = PLOT(  /OVERPLOT, NANO1DAY_TIME[S:M], Y, COLOR='PURPLE', THICK=2 )
; P.ORDER, /BRING_TO_FRONT  ; at Caldera P.C. only.
;
  T = ROUND( NANO1DAY_TIME[M] -  56 )  ; Move back 56 days or 8 weeks.
  S = LOCATE_TIME_POSITION( NANO1DAY_TIME, T )
;
  PRINT, FORMAT='(C())', NANO1DAY_TIME[S], T
;
  P = PLOT( NANO1DAY_TIME[S:M], NANO1DAY_MEAN[S:M],  LINESTYLE='NONE',   $
           /OVERPLOT, $  ; So the Y-Axis will not be adjusted.
            SYMBOL='o', SYM_COLOR='GREEN', SYM_FILLED=1   )
; P.ORDER, /BRING_TO_FRONT  ; at Caldera P.C. only.
;
  X = NANO1DAY_TIME[S:M] - NANO1DAY_TIME[S] ; in Days.
  Y = NANO1DAY_MEAN[S:M]      ; 1-Day Averaged Depths.
; Compute a Linear least-square fit method where R = [A,B] as y = A + B*X.
  R = LINFIT( X, NANO1DAY_MEAN[S:M], YFIT=Y )  ;  where Y = Fitted values.
; D = JULDAY( 12,31,YR ) - JULDAY( 1,0,YR )    ; Total Days of the Current Year = 365 or 366.
; Convert the Rate of Depth (meters) Change/Day into cm/year.
  RATE =  R[1]           ; The uplift should > 0 if depths < 0.
  RATE =  RATE*100.0*D   ; where 100 cm = 1 meter
  RATE = STRING( FORMAT='(F5.1)', RATE )  ; into a string: '19.1" e.g.
;
  T = TEXT( COLOR='GREEN',  /NORMAL, 0.40, 0.03,            $
            '8-week avg. uplift rate: ' + RATE + ' cm/yr'   )
;
  P = PLOT(  /OVERPLOT, NANO1DAY_TIME[S:M], Y, COLOR='GREEN', THICK=2 )
; P.ORDER, /BRING_TO_FRONT  ; at Caldera P.C. only.
;
  T = ROUND( NANO1DAY_TIME[M] -  28 )  ; Move back 28 days or 7 weeks.
  S = LOCATE_TIME_POSITION( NANO1DAY_TIME, T )
;
  PRINT, FORMAT='(C())', NANO1DAY_TIME[S], T
;
  P = PLOT( NANO1DAY_TIME[S:M], NANO1DAY_MEAN[S:M],  LINESTYLE='NONE',   $
           /OVERPLOT, $  ; So the Y-Axis will not be adjusted.
            SYMBOL='o', SYM_COLOR='BLUE', SYM_FILLED=1   )
; P.ORDER, /BRING_TO_FRONT  ; at Caldera P.C. only.
;
  X = NANO1DAY_TIME[S:M] - NANO1DAY_TIME[S] ; in Days.
  Y = NANO1DAY_MEAN[S:M]      ; 1-Day Averaged Depths.
; Compute a Linear least-square fit method where R = [A,B] as y = A + B*X.
  R = LINFIT( X, NANO1DAY_MEAN[S:M], YFIT=Y )  ;  where Y = Fitted values.
; D = JULDAY( 12,31,YR ) - JULDAY( 1,0,YR )    ; Total Days of the Current Year = 365 or 366.
; Convert the Rate of Depth (meters) Change/Day into cm/year.
  RATE =  R[1]           ; The uplift should > 0 if depths < 0.
  RATE =  RATE*100.0*D   ; where 100 cm = 1 meter
  RATE = STRING( FORMAT='(F5.1)', RATE )  ; into a string: '19.1" e.g.
;
  T = TEXT( COLOR='BLUE',   /NORMAL, 0.69, 0.03,            $
            '4-week avg. uplift rate: ' + RATE + ' cm/yr'   )
;
  P = PLOT( /OVERPLOT, NANO1DAY_TIME[S:M], Y, COLOR='BLUE', THICK=2 )
; P.ORDER, /BRING_TO_FRONT  ; at Caldera P.C. only.
;
; Label the dot symbols.
;
  S = SYMBOL( /NORMAL, 0.105, 0.07, 'o', /SYM_FILLED, SYM_COLOR='PURPLE' )
  S = SYMBOL( /NORMAL, 0.120, 0.07, 'o', /SYM_FILLED, SYM_COLOR='GREEN'  )
  S = SYMBOL( /NORMAL, 0.135, 0.07, 'o', /SYM_FILLED, SYM_COLOR='BLUE',  $
               LABEL_STRING='1-Day Means' )
;
; WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOratesLast3monthsE-F.png', P.CopyWindow()  ; IDL 8.5 or hight.
  P.SAVE,    '~/4Chadwick/RSN/MJ03F/NANOratesLast3monthsE-F.png', WIDTH=2048, HIGTH=1024
  PRINT, SYSTIME() + ' MJ03F/NANOratesLast3monthsE-F.png  is created.'
;
  PRINT, SYSTIME() + ' End of RunPlotNANOdiffE-Frates.pro'
;
; End of File: RunPlotNANOdiffE-Frates.pro
