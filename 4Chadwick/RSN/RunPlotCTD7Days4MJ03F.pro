;
; File: RunPlotCTD7Days4MJ03F.pro
;
; Display the CTD data: {Density, Salinity & Temperature} near the station: MJ03F.
; for the last 7 Days only.
;
; Also see RunPlotCTD4MJ03F.pro for plotting the last 6 months and All data.
;
; Created: September 10th, 2020
; Revised: September 10th, 2020
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
;.RUN ~/rsn/match.pro
;
  PRINT, SYSTIME() + ' Start running of RunPlotCTD7Days4MJ03F.pro ...'
;
; B = 0  ; Show the plotting on screen.  B=0 means No  Buffer is used when plotting.
  B = 1  ; No   the plotting on screen.  B=1 means Use Buffer, i.e. PIXMAP for plotting.
;
; Restrieve the CTD data Array variables: CDT_TIME, DENSITY, SALINITY & CTD_TEMP
; They are assumed to be the same size.
;
  RESTORE, '~/4Chadwick/RSN/MJ03F/CTD7DaysMJ03F.rsn'
;
; Locate the date 7 days from the current data.
; The following steps will be done by the file: RunPlotCTD7Days4MJ03F.pro
;
  N = N_ELEMENTS( CTD_TIME ) - 1        ; Last data points in CTD_TIME and others.
  T = ROUND( CTD_TIME[N] - 7 ) - 0.5    ; Move back 7 days.
; The ROUND( ) - 0.5 will make sure the date starts at 00:00:00.
  PRINT, FORMAT='(C())', T  ; for checking.
  K = LOCATE_TIME_POSITION( CTD_TIME, T )
;
; Create a Time Range for labelling.
;
  T  = STRING( CTD_TIME[K],           $  ; Date & Time of the 1st data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  T += ' to ' + STRING( CTD_TIME[N],  $  ; to the Last data point.
       FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Display the CTD Temperature data for the last 7 days.
;
  I  = WHERE( CTD_TEMP[K:N] GT -9000 ) ; Get only the real data.  10/23/2019
  I  = I + K  ; Apply the offset so that TEMP[I] are all real data values
;             ; and the data for the last 7 days.
;
; P = PLOT( CTD_TIME[K:N], CTD_TEMP[K:N], 'r',    DIMENSION=[800, 256],   $
  P = PLOT( CTD_TIME[ I ], CTD_TEMP[ I ], 'r',    DIMENSION=[800, 256],   $
            TITLE='MJ03F CTD Temperature data, last 7 days',   BUFFER=B,  $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',                         $
           XTITLE=T, YTITLE='$Temperature in ^{o}C$', XSTYLE=1, XMINOR=23 )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/MJ03FCTDTemp7days.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/MJ03FCTDTemp7days.png is created.'
;
; Display the CTD Density     data for the last 7 days.
;
  I  = WHERE( DENSITY[K:N] GE 0 ) ; Get only the non-negative values.  10/23/2019
  I  = I + K  ; Apply the offset so that DENSITY[I] are all non-negative values
;             ; and the data for the last 7 days.
  S  = STDEV( DENSITY[I], D )  ; Get the Standard Deviation (S) and the average (M).
  P  = S*4
  MX = D + P  ; Upper  Plotting
  MN = D - P  ; Lower  Range for Y-Axis.
;
; P = PLOT( CTD_TIME[K:N],     DENSITY[K:N], 'b', DIMENSION=[800, 256],        $
  P = PLOT( CTD_TIME[ I ],     DENSITY[ I ], 'b', DIMENSION=[800, 256],        $
            TITLE='MJ03F CTD Density data, last 7 days',   BUFFER=B,           $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',  XMINOR=23, YRANGE=[MN,MX],  $
           XTITLE=T, YTITLE='$Density: kg/m^{3}$', XSTYLE=1                    )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/MJ03FCTDDens7days.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/MJ03FCTDDens7days.png is created.'
;
; Display the CTD Salinity    data for the last 7 days.s.
;
  I  = WHERE( SALINITY[K:N] GE 0 ) ; Get only the non-negative values.  10/23/2019
  I  = I + K  ; Apply the offset so that SALINITY[I] are all non-negative values
;             ; and the data for the last 7 days.
  S  = STDEV( SALINITY[I], D )  ; Get the Standard Deviation (S) and the average (M).
  P  = S*4
  MX = D + P  ; Upper  Plotting
  MN = D - P  ; Lower  Range for Y-Axis.
;
; P = PLOT( CTD_TIME[K:N],     SALINITY[K:N],'g', DIMENSION=[800, 256],  $
  P = PLOT( CTD_TIME[ I ],     SALINITY[ I ],'g', DIMENSION=[800, 256],  $
            TITLE='MJ03F CTD Salinity data, last 7 days',   BUFFER=B,    $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',  YRANGE=[MN,MX],       $
           XTITLE=T, YTITLE='Salinity: ppt', XMINOR=23,  XSTYLE=1        )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03F/MJ03FCTDSal7days.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03F/MJ03FCTDSal7days.png is created.'
;
; The following steps will be done by the file: RunPlotCTD7Days4MJ03F.pro
;
  PRINT, SYSTIME() + ' Finish running of RunPlotCTD7Days4MJ03F.pro.'
;
; End of File: RunPlotCTD7Days4MJ03F.pro
