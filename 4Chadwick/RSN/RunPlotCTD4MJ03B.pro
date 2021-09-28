;
; File: RunPlotCTD4MJ03B.pro
;
; Display the CTD data: {Density, Salinity & Temperature} near the station: MJ03B.
;
; Created: October 24th, 2018
; Revised: October 17th, 2018
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
;.RUN ~/idl/match.pro
;
  PRINT, SYSTIME() + ' Start running of RunPlotCTD4MJ03B.pro ...'
;
; B = 0  ; Show the plotting on screen.  B=0 means No  Buffer is used when plotting.
  B = 1  ; No   the plotting on screen.  B=1 means Use Buffer, i.e. PIXMAP for plotting.
;
; Restrieve the CTD data Array variables: CDT_TIME, DENSITY, SALINITY & CTD_TEMP
; They are assumed to be the same size.
;
  RESTORE, '~/4Chadwick/RSN/MJ03B/CTD-MJ03B.idl'
; RESTORE, '/data/lau/4Chadwick/RSN/MJ03B/CTD-MJ03B.idl'
;
; Create a Time Range for labelling.
;
  N  = N_ELEMENTS( CTD_TIME ) - 1  ; Last data points in CDT_TIME DENSITY, SALINITY & CTD_TEMP
  T  = STRING( CTD_TIME[0],           $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  T += ' to ' + STRING( CTD_TIME[N],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Reduce the size the of the arrays before plotting.
; This is to reduce the total points to be plotted, hence reducing the size
; figure when being saved into a png file.  If it is not beign done, Caldera
; workstation kill the process before finishing it.  October 16th, 2018.
;
; Select every 4 points between S & N for plotting.
; Note that CTD points are at 15 seconds interval.
; So every 4th points means the select points will be at every minute.
;
 ;K = 0          ; October 16th, 2018.
 ;P = N - K + 1  ; Total data points in CTD_TIME[S:N-1].
 ;P = P/4        ; for selecting every 4th points. Each data point is 60 seconds. 
 ;K = LINDGEN( P )*4 + K  ; Indexes for every 4th points in between S & N.
;
; Display the CTD Temperature data since the beginning to present.
;
  I  = WHERE( CTD_TEMP GT -9000 ) ; Get only the real non-negative data.  10/24/2019
;
; P = PLOT( CTD_TIME[K], CTD_TEMP[K], 'r', BUFFER=B, DIMENSION=[800, 256],  $
; P = PLOT( CTD_TIME   , CTD_TEMP   , 'r', BUFFER=B, DIMENSION=[800, 256],  $
  P = PLOT( CTD_TIME[I], CTD_TEMP[I], 'r', BUFFER=B, DIMENSION=[800, 256],  $
            TITLE='MJ03B CTD Temperature data, Start to Present.',          $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',     XMINOR=11,            $
           XTITLE=T, YTITLE='$Temperature in ^{o}C$', XSTYLE=1 )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDTempAll.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDTempAll.png is created.'
;
; Display the CTD Density     data since the beginning to present.
;
  I  = WHERE( DENSITY  GE 0.0 ) ; Get only the real data.  10/24/2019
;
  S  = STDEV( DENSITY[I],  M )  ; Get the Standard Deviation (S) and the average (M).
  P  = S*3
  MX = M + P  ; Upper  Plotting
  MN = M - P  ; Lower  Range for Y-Axis.
;
; P = PLOT( CTD_TIME[K], DENSITY[K], 'b', BUFFER=B, DIMENSION=[800, 256],     $
; P = PLOT( CTD_TIME   , DENSITY   , 'b', BUFFER=B, DIMENSION=[800, 256],     $
  P = PLOT( CTD_TIME[I], DENSITY[I], 'b', BUFFER=B, DIMENSION=[800, 256],     $
            TITLE='MJ03B CTD Density data, Start to Present.',                $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',  XMINOR=11, YRANGE=[MN,MX], $
           XTITLE=T, YTITLE='$Density: kg/m^{3}$', XSTYLE=1 )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDDensAll.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDDensAll.png is created.'
;
; Display the CTD Salinity    data since the beginning to present.
;
  I  = WHERE( SALINITY GE 0.0 ) ; Get only the real non-negative data.  10/24/2019
;
  S  = STDEV( SALINITY[I], M )  ; Get the Standard Deviation (S) and the average (M).
  P  = S*3
  MX = M + P  ; Upper  Plotting
  MN = M - P  ; Lower  Range for Y-Axis.
;
; P = PLOT( CTD_TIME[K], SALINITY[K],'g', BUFFER=B, DIMENSION=[800, 256],     $
; P = PLOT( CTD_TIME   , SALINITY  , 'g', BUFFER=B, DIMENSION=[800, 256],     $
  P = PLOT( CTD_TIME[I], SALINITY[I],'g', BUFFER=B, DIMENSION=[800, 256],     $
            TITLE='MJ03B CTD Salinity data, Start to Present.',               $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))', XMINOR=11, YRANGE=[MN,MX],  $
           XTITLE=T, YTITLE='Salinity: ppt',      XSTYLE=1 )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDSalAll.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDSalAll.png is created.'
;
;
; Locate the date 6 months from the current data.
;
  T = ROUND( CTD_TIME[N] - 183 ) - 0.5  ; Move back 183 days or 6 months.
; The ROUND( ) - 0.5 will make sure the date starts at 00:00:00.
  PRINT, FORMAT='(C())', T  ; for checking.
  K = LOCATE_TIME_POSITION( CTD_TIME, T )
;
; Create the time positions for the XTICKVALUES for plotting and labelling.
;
  CALDAT, T,  M,D,Y  ; Get M)onth, D)ay & Y)ear.
  M += ( D GT 1 )    ; If Day is > 1, Let M to be M+1.
  M  = TIMEGEN( 6, START=JULDAY(M,1,Y,0,0,0), STEP=1, UNIT='MONTHS' ) 
  IF M[5] GT CTD_TIME[N] THEN M = M[0:4]
;
; Create a Time Range for labelling.
;
  T  = STRING( CTD_TIME[K],           $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  T += ' to ' + STRING( CTD_TIME[N],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Display the CTD Temperature data for the last 6 months.
;
  I  = WHERE( CTD_TEMP[K:N] GT -9000 ) ; Get only the real data.  10/24/2019
  I  = I + K  ; Apply the offset so that TEMP[I] are all real data values
;             ; and the data for the last 6 months.
;
; P = PLOT( CTD_TIME[K:N], CTD_TEMP[K:N], 'r',    DIMENSION=[800, 256],   $
  P = PLOT( CTD_TIME[ I ], CTD_TEMP[ I ], 'r',    DIMENSION=[800, 256],   $
            TITLE='MJ03B CTD Temperature data, last 6 months', BUFFER=B,  $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',     XTICKVALUES=M,      $
           XTITLE=T, YTITLE='$Temperature in ^{o}C$', XSTYLE=1, XMINOR=29 )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDTemp6mo.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDTemp6mo.png is created.'
;
; Display the CTD Density     data for the last 6 months.
;
 I  = WHERE( DENSITY[K:N] GE 0 ) ; Get only the non-negative values.  10/24/2019
 I  = I + K  ; Apply the offset so that DENSITY[I] are all non-negative values
;            ; and the data for the last 6 months.
  S  = STDEV( DENSITY[I], D )  ; Get the Standard Deviation (S) and the average (M).
  P  = S*3
  MX = D + P  ; Upper  Plotting
  MN = D - P  ; Lower  Range for Y-Axis.
;
; P = PLOT( CTD_TIME[K:N],     DENSITY[K:N], 'b', DIMENSION=[800, 256],        $
  P = PLOT( CTD_TIME[ I ],     DENSITY[ I ], 'b', DIMENSION=[800, 256],        $
            TITLE='MJ03B CTD Density data, last 6 months', BUFFER=B,           $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',  XMINOR=29, YRANGE=[MN,MX],  $
           XTITLE=T, YTITLE='$Density: kg/m^{3}$', XTICKVALUES=M, XSTYLE=1     )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDDens6mo.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDDens6mo.png is created.'
;
; Display the CTD Salinity    data for the last 6 months.
;
  I  = WHERE( SALINITY[K:N] GE 0 ) ; Get only the non-negative values.  10/24/2019
  I  = I + K  ; Apply the offset so that SALINITY[I] are all non-negative values
;             ; and the data for the last 6 months.
  S  = STDEV( SALINITY[I], D )  ; Get the Standard Deviation (S) and the average (M).
  P  = S*3
  MX = D + P  ; Upper  Plotting
  MN = D - P  ; Lower  Range for Y-Axis.
;
; P = PLOT( CTD_TIME[K:N],     SALINITY[K:N],'g', DIMENSION=[800, 256],       $
  P = PLOT( CTD_TIME[ I ],     SALINITY[ I ],'g', DIMENSION=[800, 256],       $
            TITLE='MJ03B CTD Salinity data, last 6 months', BUFFER=B,         $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))', XMINOR=29, YRANGE=[MN,MX],  $
           XTITLE=T, YTITLE='Salinity: ppt', XTICKVALUES=M,  XSTYLE=1          )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDSal6mo.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDSal6mo.png is created.'
;
;
; Locate the date 7 days from the current data.
; The following steps will be done by the file: RunPlotCTD7Days4MJ03B.pro
;
; T = ROUND( CTD_TIME[N] - 7 ) - 0.5    ; Move back 7 days.
; The ROUND( ) - 0.5 will make sure the date starts at 00:00:00.
; PRINT, FORMAT='(C())', T  ; for checking.
; K = LOCATE_TIME_POSITION( CTD_TIME, T )
;
; Create a Time Range for labelling.
;
; T  = STRING( CTD_TIME[0],           $  ; Date & Time of the 1st data point.
;      FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
; T += ' to ' + STRING( CTD_TIME[N],  $  ; to the Last data point.
;      FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Display the OOI-BPR De-tide Depth Difference for the last 7 days.
;
; P = PLOT( CTD_TIME[K:N], CTD_DIFF[K:N], 'r', BUFFER=B, DIMENSION=[1024,512],  $
;           TITLE='OOI-BPR Difference: MJ03E - MJ03F, last 7 Days.',              $
;          XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XSTYLE=1, XMINOR=23,           $
;          XTITLE=T,  YTITLE='De-tided Depth Difference in meters'    )
;
; WRITE_PNG, '~/4Chadwick/RSN/MJ03F/NANOdifferenceLast7DaysE-F.png', P.CopyWindow()
; PRINT, SYSTIME() + ' MJ03F/NANOdifferenceLast7DaysE-F.png is created.'
;
  PRINT, SYSTIME() + ' Finish running of RunPlotCTD4MJ03B.pro.'
;
; End of File: RunPlotCTD4MJ03B.pro
