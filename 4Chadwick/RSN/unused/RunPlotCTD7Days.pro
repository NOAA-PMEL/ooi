;
; File: RunPlotCTD7Days.pro
;
; Display the CTD data: {Density, Salinity & Temperature} near the station: MJ03B.
; for the last 7 Days only.
;
; Also see RunPlotCTD.pro for plotting the last 6 months and All data.
;
; Created: October  17th, 2018
; Revised: November 13th, 2018
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
;.RUN ~/idl/match.pro
;
  PRINT, SYSTIME() + ' Start running of RunPlotCTD7Days.pro ...'
;
; B = 0  ; Show the plotting on screen.  B=0 means No  Buffer is used when plotting.
  B = 1  ; No   the plotting on screen.  B=1 means Use Buffer, i.e. PIXMAP for plotting.
;
; Restrieve the CTD data Array variables: CDT_TIME, DENSITY, SALINITY & CTD_TEMP
; They are assumed to be the same size.
;
  RESTORE, '~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl'
;
; Locate the date 7 days from the current data.
; The following steps will be done by the file: RunPlotCTD7Days.pro
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
; Display the CTD Temperature data for the last 6 months.
;
  P = PLOT( CTD_TIME[K:N], CTD_TEMP[K:N], 'r',    DIMENSION=[800, 256],   $
            TITLE='MJ03B CTD Temperature data, last 7 days',   BUFFER=B,  $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',                         $
           XTITLE=T, YTITLE='$Temperature in ^{o}C$', XSTYLE=1, XMINOR=23 )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDTemp7days.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDTemp7days.png is created.'
;
; Display the CTD Density     data for the last 6 months.
;
  S  = STDEV( DENSITY[K:N],  D )  ; Get the Standard Deviation (S) and the average (M).
  P  = S*4
  MX = D + P  ; Upper  Plotting
  MN = D - P  ; Lower  Range for Y-Axis.
;
  P = PLOT( CTD_TIME[K:N],     DENSITY[K:N], 'b', DIMENSION=[800, 256],        $
            TITLE='MJ03B CTD Density data, last 7 days',   BUFFER=B,           $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',  XMINOR=23, YRANGE=[MN,MX],  $
           XTITLE=T, YTITLE='$Density: kg/m^{3}$', XSTYLE=1                    )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDDens7days.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDDens7days.png is created.'
;
; Display the CTD Salinity    data for the last 6 months.
;
  S  = STDEV( SALINITY[K:N], D )  ; Get the Standard Deviation (S) and the average (M).
  P  = S*4
  MX = D + P  ; Upper  Plotting
  MN = D - P  ; Lower  Range for Y-Axis.
;
  P = PLOT( CTD_TIME[K:N],     SALINITY[K:N],'g', DIMENSION=[800, 256],  $
            TITLE='MJ03B CTD Salinity data, last 7 days',   BUFFER=B,    $
           XTICKFORMAT='(C(CDI,1X,CMoA,1X,CYI))',  YRANGE=[MN,MX],       $
           XTITLE=T, YTITLE='Salinity: ppt', XMINOR=23,  XSTYLE=1        )
;
  WRITE_PNG, '~/4Chadwick/RSN/MJ03B/MJ03BCTDSal7days.png', P.CopyWindow()
  PRINT, SYSTIME() + ' MJ03B/MJ03BCTDSal7days.png is created.'
;
; The following steps will be done by the file: RunPlotCTD7Days.pro
;
  PRINT, SYSTIME() + ' Finish running of RunPlotCTD7Days.pro.'
;
; End of File: RunPlotCTD7Days.pro
