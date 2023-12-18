;
; File: RunPlotNANOdiffE-F.pro
;
; Display the Difference between the NANO Data from the stations:
; MJ03F and MJ03[B/D/E/].
;
; Created: August   7th, 2018
; Revised: October 31st, 2018
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
;.RUN ~/rsn/match.pro
;
  PRINT, SYSTIME() + ' Start running of RunPlotNANOdiffE-F.pro ...'
;
; B = 0  ; Show the plotting on screen.  B=0 means No  Buffer is used when plotting.
  B = 1  ; No   the plotting on screen.  B=1 means Use Buffer, i.e. PIXMAP for plotting.
;
; Restrieve the NANO detided pressure difference data Array variables:
; NANO_DIFF and NANO_TIME.
;
  RESTORE, '~/4Chadwick/RSN/MJ03F/NANOdifferencesMJ03E-F.rsn'
;
; Create a Time Range for labelling.
;
  N  = N_ELEMENTS( NANO_TIME ) - 1  ; Last data points in NANO_TIME & NANO_DIFF.
  T  = STRING( NANO_TIME[0],           $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  T += ' to ' + STRING( NANO_TIME[N],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Reduce the size the of the arrays before plotting.
; This is to reduce the total points to be plotted, hence reducing the size
; figure when being saved into a png file.  If it is not beign done, Caldera
; workstation kill the process before finishing it.  October 16th, 2018.
;
; Select every 4 points between S & N for plotting.
; Note that NANO_DETIDE points are at 15 seconds interval.
; So every 4th points means the select points will be at every minute.
;
  S = 0          ; October 16th, 2018.
  P = N - S + 1  ; Total data points in NANO_DETIDE[S:N-1].
  P = P/4        ; for selecting every 4th points. Each NANO_DETIDE point is 60 seconds. 
  S = LINDGEN( P )*4 + S  ; Indexes for every 4th points in between S & N.
;
; Determine the Y-range for plotting.  October 26th, 2018.
;
  D = STDEV( NANO_DIFF[S], M )  ; where M = average and D = Standard Deviation
  Y = M + [-D,D]*3.0            ; Y[0:1] = Min. & Max. Y Plotting Range.
;
; Display the De-tide Depth Differences since the beginning to present.
;
  P = PLOT( NANO_TIME[S],NANO_DIFF[S],'r', BUFFER=B, DIMENSION=[1024,512],  $
            TITLE='OOI-BPR Difference: MJ03E - MJ03F, Start to Present.',   $
;          XRANGE=[ JULDAY(1,1,2015), JULDAY(1,1,2022) ],                   $
           XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))', XMINOR=11,  YRANGE=Y,     $
           XTITLE=T, YTITLE='De-tided Depth Difference in meters', XSTYLE=1 )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOdifferenceAllE-F.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/NANOdifferenceAllE-F.png is created.'
;
; Store the NANO Difference data and times.
;
; NANO_TIME =  MJ03JF_TIME[JF] 
; NANO_DIFF =  D
; HELP, NANO_TIME, NANO_DIFF
; SAVE, FILE='MJ03F/NANOdifferencesMJ03E-F.idl', NANO_TIME, NANO_DIFF
;
; Locate the date at 00:00:00 on May 27th, 2015 in NANO_TIME.
;
  K  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY(5,27,2015,0,0,0) ) - 1
;
; Create a Time Range for labelling.
;
  T  = '05/25/2017 00:00:00 to '  ; Date & Time of the 1st data point.
  T += STRING( NANO_TIME[N],    $ ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Select every 4 points between S & N for plotting.
; Note that NANO_DETIDE points are at 60 seconds interval.
; So every 4th points means the select points will be at every hour.
;
  S = K          ; October 16th, 2018.
  P = N - S + 1  ; Total data points in NANO_DETIDE[S:N-1].
  P = P/4        ; for selecting every 4th points. Each NANO_DETIDE point is 60 seconds. 
  S = LINDGEN( P )*4 + S  ; Indexes for every 4th points in between S & N.
;
; Determine the Y-range for plotting.  October 26th, 2018.
;
  D = STDEV( NANO_DIFF[S], M )  ; where M = average and D = Standard Deviation
  Y = M + [-D,D]*3.0            ; Y[0:1] = Min. & Max. Y Plotting Range.
;
; Display the De-tide Depth Differences from May 27th, 2015 to present.
;
; P = PLOT( NANO_TIME[K:N], NANO_DIFF[K:N], 'r', BUFFER=B, DIMENSION=[1024,512],  $
  P = PLOT( NANO_TIME[S],   NANO_DIFF[S],   'r', BUFFER=B, DIMENSION=[1024,512],  $
            TITLE='OOI-BPR Difference: MJ03E - MJ03F since 25th May 2015',        $
           XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XSTYLE=1, XMINOR=11,           $
           XTITLE=T,  YTITLE='De-tided Depth Difference in meters', YRANGE=Y )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOdifferenceSince25May2015E-F.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/NANOdifferenceSince25May2015E-F.png is created.'
;
; Locate the date 6 months from the current data.
;
  T = ROUND( NANO_TIME[N] - 183 ) - 0.5  ; Move back 183 days or 6 months.
; The ROUND( ) - 0.5 will make sure the date starts at 00:00:00.
  PRINT, FORMAT='(C())', T  ; for checking.
  K = LOCATE_TIME_POSITION( NANO_TIME, T )
;
; Create the time positions for the XTICKVALUES for plotting and labelling.
;
  CALDAT, T,  M,D,Y  ; Get M)onth, D)ay & Y)ear.
  M += ( D GT 1 )    ; If Day is > 1, Let M to be M+1.
  M  = TIMEGEN( 6, START=JULDAY(M,1,Y,0,0,0), STEP=1, UNIT='MONTHS' ) 
  IF M[5] GT NANO_TIME[N] THEN M = M[0:4]
;
; Create a Time Range for labelling.
;
  T  = STRING( NANO_TIME[K],           $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  T += ' to ' + STRING( NANO_TIME[N],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Determine the Y-range for plotting.  October 26th, 2018.
;
  D = STDEV( NANO_DIFF[K:N], S )  ; where S = Average and D = Standard Deviation
  Y = S + [-D,D]*3.0              ; Y[0:1] = Min. & Max. Y Plotting Range.
;
; Display the De-tide Depth Differences for the last 6 months.
;
  P = PLOT( NANO_TIME[K:N], NANO_DIFF[K:N], 'r', BUFFER=B, DIMENSION=[1024,512],  $
            TITLE='OOI-BPR Difference: MJ03E - MJ03F, last 6 months',  YRANGE=Y,  $
           XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))', XTICKVALUES=M, XMINOR=29,       $
           XTITLE=T,  YTITLE='De-tided Depth Difference in meters', XSTYLE=1      )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOdifferenceLast6monthsE-F.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/NANOdifferenceLast6monthsE-F.png is created.'
;
; Locate the date 3 months from the current data form NANO_TIME.
;
  T = ROUND( NANO_TIME[N] -  91 ) - 0.5  ; Move back 91.5 days or 3 months.
; The ROUND( ) - 0.5 will make sure the date starts at 00:00:00.
  PRINT, FORMAT='(C())', T  ; for checking.
  K = LOCATE_TIME_POSITION( NANO_TIME, T )
;
; Create a Time Range for labelling.
;
  T  = STRING( NANO_TIME[K],           $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  T += ' to ' + STRING( NANO_TIME[N],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Determine the Y-range for plotting.  October 26th, 2018.
;
  D = STDEV( NANO_DIFF[K:N], M )  ; where M = average and D = Standard Deviation
  Y = M + [-D,D]*3.0              ; Y[0:1] = Min. & Max. Y Plotting Range.
;
; Display the OOI-BPR De-tide Depth Difference for the last 3 months.
;
  P = PLOT( NANO_TIME[K:N], NANO_DIFF[K:N], 'r', BUFFER=B, DIMENSION=[1024,512],  $
            TITLE='OOI-BPR Difference: MJ03E - MJ03F, last 3 months',  YRANGE=Y,  $
           XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XSTYLE=1, XMINOR=29,           $
           XTITLE=T,  YTITLE='De-tided Depth Difference in meters'    )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOdifferenceLast3monthsE-F.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/NANOdifferenceLast3monthsE-F.png is created.'
;
; Locate the date 7 days from the current data.
; The following steps will be done by the file: RunPlotNANOdiffE-F7Days.pro
;
; T = ROUND( NANO_TIME[N] - 7 ) - 0.5    ; Move back 7 days.
; The ROUND( ) - 0.5 will make sure the date starts at 00:00:00.
; PRINT, FORMAT='(C())', T  ; for checking.
; K = LOCATE_TIME_POSITION( NANO_TIME, T )
;
; Create a Time Range for labelling.
;
; T  = STRING( NANO_TIME[0],           $  ; Date & Time of the 1st data point.
;      FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
; T += ' to ' + STRING( NANO_TIME[N],  $  ; to the Last data point.
;      FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Display the OOI-BPR De-tide Depth Difference for the last 7 days.
;
; P = PLOT( NANO_TIME[K:N], NANO_DIFF[K:N], 'r', BUFFER=B, DIMENSION=[1024,512],  $
;           TITLE='OOI-BPR Difference: MJ03E - MJ03F, last 7 Days.',              $
;          XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XSTYLE=1, XMINOR=23,           $
;          XTITLE=T,  YTITLE='De-tided Depth Difference in meters'    )
;
; WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOdifferenceLast7DaysE-F.png', P.CopyWindow()
; PRINT, SYSTIME() + ' MJ03F/NANOdifferenceLast7DaysE-F.png is created.'
;
  PRINT, SYSTIME() + ' Finish running of RunPlotNANOdiffE-F.pro.'
;
; End of File: RunPlotNANOdiffE-F.pro
