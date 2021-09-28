;
; File: RunForecastDates.pro
;
; The IDL steps will generate 3 figures using the data stored in the
; files: ~/4Chadwick/RSN/MJ03F/LongTermNANOdataProducts.MJ03F
; and    ~/4Chadwick/RSN/MJ03F/MJ03F-NANO.idl
;
; The 3 figures are: ForecastHistogramMJ03F.png
;                         SCatterDatesMJ03F.png
;              and  ForecastProjectionMJ03F.png
;
; Revised on January   12th, 2021
; Created on May        1st, 2018
;
 .RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
 .RUN ~/4Chadwick/RSN/GetPredictedDates.pro
 .RUN ~/4Chadwick/RSN/PlotForecastDates.pro  ; For PRO PLOT_FORECAST_[STOGRAM/PORJECTION]
;
; Get the 1-Day average of the NANO (detided) Depths and the 12-Week Rate (cm/yr)
; from the file: ~/4Chadwick/RSN/MJ03F/LongTermNANOdataProducts.MJ03F.
;
  RETRIEVE_NANO_DATA_PRODUCTS,'~/4Chadwick/RSN/MJ03F/LongTermNANOdataProducts.MJ03F',DATA,S
;
; DATA = 2-D arrays where
; DATA[*,0] = JULDAY()'s,
; DATA[*,1] = 1-Day average of the NANO (detided) Depths in meters.
; DATA[*,2] =  8-Week Rate of the depth being change in cm/yr.
; DATA[*,3] = 12-Week Rate of the depth being change in cm/yr.
;
  S = SIZE( DATA, /DIMENSION )  ; DATA is a 2-D array.
  N = S[0]   ; The length of the 1st dimension.
;
; Define the Top Depth Threshold value in meters
;
  DEPTH_THRESHOLD = 1509.79  ; from the April 25th, 2015 Eruption.
;
; Get the Forecasted Times.
;
; D = ( DATA[0:N-1,1] - DEPTH_THRESHOLD ) ; Distances to the top: 1509.79 meters, e.g.
; T = D*100.0/DATA[0:N-1,3]               ; Times in years to the top & DATA[0:*,3]=12-Week Rate.
; T = DATA[0:N-1,0] + TEMPORARY( T )*365  ; Forecasted Times to the top.
; S = MIN( T, MAX=M )                     ; Min. & Max. Time Range in T.
;
; Set the Time Period for color coding the histogram's bars.
; Note that each JULDAY() below is start date for a new color.
;
;-----------------------------------------------------------------------
  PERIOD = [ JULDAY( 6,1,2015, 0,0,0 ),  $  ; Started on January 14th, 2020.
             JULDAY( 1,1,2016, 0,0,0 ),  JULDAY( 1,1,2017, 0,0,0 ),  $
             JULDAY( 1,1,2018, 0,0,0 ),  JULDAY( 1,1,2019, 0,0,0 ),  $
             JULDAY( 1,1,2020, 0,0,0 ),  JULDAY( 1,1,2021, 0,0,0 )   ]
;                                        ^Added on January  14th, 2021.
; Define the colors for each PERIOD above
; and added 'CYAN' on January  20th, 2021.
;
  COLOR = ['PURPLE','BLUE','CYAN','GREEN','YELLOW','ORANGE','RED']
;-----------------------------------------------------------------------
;
;-The following PERIOD & COLOR were used between  1/21/2020 & 1/14/2021-
;-----------------------------------------------------------------------
; PERIOD = [ JULDAY( 6,1,2015, 0,0,0 ),  $
;            JULDAY( 1,1,2016, 0,0,0 ),  JULDAY( 1,1,2017, 0,0,0 ),  $
;            JULDAY( 1,1,2018, 0,0,0 ),  JULDAY( 1,1,2019, 0,0,0 ),  $
;            JULDAY( 1,1,2020, 0,0,0 )   ]
;
; Define the colors for each PERIOD above
; and removed 'CYAN' on December 19th, 2018.
;
; COLOR = ['PURPLE','BLUE','GREEN','YELLOW','ORANGE','RED']
;-----------------------------------------------------------------------
;
;-The following PERIOD & COLOR were used between 12/19/2018 & 1/20/2020-
;-----------------------------------------------------------------------
; PERIOD = [ JULDAY( 6,1,2015, 0,0,0 ),  $
;            JULDAY( 1,1,2016, 0,0,0 ),  JULDAY( 7,1,2016, 0,0,0 ),  $
;            JULDAY( 1,1,2017, 0,0,0 ),  JULDAY( 7,1,2017, 0,0,0 ),  $
;            JULDAY( 1,1,2018, 0,0,0 ),  JULDAY( 7,1,2018, 0,0,0 )   ]
;                                        ^Added on December 19th, 2018
;
; Define the colors for each PERIOD above.
; and added 'CYAN' on December 19th, 2018.
;
; COLOR = ['PURPLE','BLUE','CYAN','GREEN','YELLOW','ORANGE','RED']
;-----------------------------------------------------------------------
;
; Display the Forecast Histogram Plot.
;
; PLOT_FORECAST_HISTOGRAM, DATA, [S,M], PERIOD, COLOR, T[N-1], DEPTH_THRESHOLD,  $
  PLOT_FORECAST_HISTOGRAM, DATA,        PERIOD, COLOR,         DEPTH_THRESHOLD,  $
      '~/4Chadwick/RSN/MJ03F/ForecastHistogramMJ03F.png',  $  ; Graphic output file.
       MAX_XRANGE=JULDAY(1,1,2030 ),  $  ; Max Time range limit to be shown.  9/18/2018
;      MAX_XRANGE=JULDAY(1,1,2034 ),  $  ; Max Time range limit to be shown.  7/31/2018
;      PLOT_OBJECT=P,  $ ; for getting the displayed image: P.CopyWindow() for example.
           DISPLAY=0     ; Not display the figure on the screen.
;
; Example for checking whether or not the PLOT_FORECAST_HISTOGRAM has generated an image.
; IF SIZE( P, /TNAME ) NE 'OBJREF' THEN  PRINT, 'No image has been created.'
;
; Display a scatter plot of the predicted eruption dates versus dates of prediction.
; Note that the BUFFER=1 option is used to direct the graphics to an off-screen buffer
; and the graphics can be retrieved later.
; For the showing the graphics on screen, do not use the BUFFER=1 option.
;
; PRINT, SYSTIME() + ' Plotting the predicted eruption dates versus dates of prediction...'
;
; S = WHERE( D LE 0.0, M )
; IF M GT 0 THEN  PRINT, SYSTIME() + ' Depth at or pass over the threshold.'
;
; P = PLOT( DATA[*,0], T, LINESTYLE='NONE', SYMBOL='o', SYM_COLOR='BLUE', SYM_FILLED=1,  $
;     TITLE='Date of prediction vs. Predicted date inflation will reach 2015 threshold', $
;           XRANGE=[ JULDAY(1,1,2015), JULDAY(1,1,2022) ],                  $
;           XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))', YTICKFORMAT='(C(CYI))',  $
;           YTITLE='Predicted date inflation will reach 2015 threshold',    $
;           XTITLE='Date of prediction', BUFFER=1 )
;
; WRITE_PNG, '~/4Chadwick/RSN/MJ03F/ScatterDatesMJ03F.png', P.CopyWindow( )
; PRINT, SYSTIME() + ' ~/4Chadwick/RSN/MJ03F/ScatterDatesMJ03F.png is created.'
;
; Used between May 11 to 14th, 2018
;
; PLOT_SCATTER_FORECAST,  DATA, DEPTH_THRESHOLD,  $
; '~/4Chadwick/RSN/MJ03F/ScatterDates1MJ03F.png', $  ; Graphic output file.
; 'Date of prediction vs. Predicted date inflation will reach 2015 threshold',  $
;  DISPLAY=0  ; Not display the figure on the screen.
;
; PLOT_SCATTER_FORECAST,  DATA, DEPTH_THRESHOLD-0.3,  $
; '~/4Chadwick/RSN/MJ03F/ScatterDates2MJ03F.png',     $  ; Graphic output file.
; 'Date of prediction vs. Predicted date inflation will reach 2015 Extended threshold',  $
;  DISPLAY=0  ; Not display the figure on the screen.
;
; From May 15th, 2018 on  The following rouitne will combine the 2 figures above.
;
  PLOT_SCATTER2FORECAST,  DATA, DEPTH_THRESHOLD,  $
  '~/4Chadwick/RSN/MJ03F/ScatterDatesMJ03F.png',  $  ; Graphic output file.
  'Date of prediction vs. Predicted date inflation will reach 2015 Extended threshold',  $
;  PLOT_OBJECT=P,  $ ; for getting the displayed image: P.CopyWindow() for example.
   MAX_YRANGE=JULDAY(1,1,2035),  $  ; For limiting the upper Y-Range plotting.  August 1st, 2018
   DISPLAY=0         ; Not display the figure on the screen.
;
; Example for checking whether or not the PLOT_SCATTER2FORECAST,  has generated an image.
; IF SIZE( P, /TNAME ) NE 'OBJREF' THEN  PRINT, 'No image has been created.'
;
; Display the Forecast Projection Date Plot.
;
; Get the Forecasted Times.  Used till July 16th, 2018.
;
; D = ( DATA[N-1,1] - DEPTH_THRESHOLD ) ; Distances to the top: 1509.79 meters, e.g.
; T = D*100.0/DATA[N-1,3]               ; Times in years to the top & DATA[0:*,3]=12-Week Rate.
; T = DATA[N-1,0] + TEMPORARY( T )*365  ; Forecasted Times to the top.
;
  PLOT_FORECAST_PROJECTION, '~/4Chadwick/RSN/MJ03F/MJ03F-NANO.idl',  $  ; for NANO_[TIME/DETIDE]
                DATA[N-1,0],  $ ; The most resent date in JULDAY().
                DATA[N-1,1],  $ ; The most resent 1-Day average depth in meters.
                DATA[N-1,3],  $ ; The most resent 12-Week Rate in cm/yr.
;                  T       ,  $ ; The most resent Forecasted date to the threshold.
            DEPTH_THRESHOLD,  $ ; The eruption threshold in meters.
                '~/4Chadwick/RSN/MJ03F/ForecastDatesMJ03F.png',  $  ; Graphic output file.
;             PLOT_OBJECT=P,  $ ; for getting the displayed image: P.CopyWindow() for example.
                DISPLAY=0       ; Not display the figure on the screen.
;
; Note that the PLOT_FORECAST_PROJECTION will always genrate a display,
; so that SIZE( P, /TNAME ) will always == 'OBJREF'.
;
; May 14th, 2018
; Changed from /internet/httpd/html/new-eoi/rsn/graphs/ForecastDatesMJ03F-xxxxx.png
;           to /internet/httpd/html/new-eoi/rsn/numbered_plots/ForecastDatesMJ03F-xxxxx.png.
;
; Look for the /internet/httpd/html/new-eoi/rsn/numbered_plots/ForecastDatesMJ03F-xxxxx.png files
; where xxxxx are numbers.
;
  F = FILE_SEARCH( '/internet/httpd/html/new-eoi/rsn/numbered_plots/ForecastDatesMJ03F-*.png', COUNT=N )
  M = 100000  ; Skip the last IF statement in case N < 0 after FILE_SEARCH() above.
  IF N LE 0 THEN FILE_COPY, '~/4Chadwick/RSN/MJ03F/ForecastDatesMJ03F.png',  $
    '/internet/httpd/html/new-eoi/rsn/numbered_plots/ForecastDatesMJ03F-00000.png'
  IF N GT 0 THEN BEGIN & S = STRPOS( F[N-1], 'MJ03F-' )  & $
                         M = STRMID( F[N-1], S+6, 5 )    & $
     IF M GE 99999 THEN  PRINT, 'ForecastDatesMJ03F-99999.png is reached'  & $
  ENDIF  ; Check the "-xxxxx" file index.
  IF M LT 99999 THEN BEGIN & F = STRMID( F[N-1], 0, S+6 )    $
                + STRING( FORMAT='(I5.5)', M+1 ) + '.png'  & $
      FILE_COPY, '~/4Chadwick/RSN/MJ03F/ForecastDatesMJ03F.png', F  & $
  ENDIF  ; Creating a new ForecastDatesMJ03F-xxxxx.png file.
;
; End of File: RunForecastDates.pro
