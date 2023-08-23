;
; File: PlotForecastDates.pro
;
; This program contains 3 individual procedures:
; PLOT_FORECAST_HISTOGRAM, PLOT_FORECAST_PROJECTION, and PLOT_SCATTER_DATES
; to generate 3 different figures: ForecastHistogramMJ03F.png,
; ForecastDatesMJ03F.png, ScatterDatesMJ03F.png
;
; Note that PLOT_FORECAST_HISTOGRAM will be calling the procedure:
; GET_PREDICTED_DATE which is in the file: GetPredictedDates.pro
;
; See the file: RunForecastDates.pro and RunDiffForecastDates.pro for the preparations of the
; input parameters for these 3 procedures.
;
; Revised on Dec 7, 2022 by Bill Chadwick (change to axis range)
; Revised on Sep 25, 2021 by Bill Chadwick (changes to axis ranges and rate threshold)
; Revised on February 12th, 2020
; Created on May       1st, 2018
;
;
; Callers: From Run[Diff]ForecastDates.pro and Users.
;
PRO PLOT_FORECAST_HISTOGRAM,  DATA,  $ ; Input: 2-D array of Dates, Depths & Rates info.
;            TIME_XRANGE,  $ ;  Input: Start and End Dates of the X-Plotting Range.
                  PERIOD,  $ ;  Input: 1-D array of Dates in JULDAY()s for color codings.
                   COLOR,  $ ;  Input: Colors for each period, see example below.
;        RESENT_FORECAST,  $ ;  Input: The most resent Forecasted date to the threshold.
         DEPTH_THRESHOLD,  $ ;  Input: The eruption threshold in meters.
            GRAPHIC_FILE,  $ ;  Input: Graphic output file name.
       DISPLAY=SHOW_PLOT,  $ ;  Input: 0 = Not display the figure on the screen or 1 = yes.
   MAX_XRANGE=END_XRANGE,  $ ;  Input: JULDAY() for the max. time range to be shown.
          PLOT_OBJECT=P      ; Output: Return P = BARPLOT() to the caller. 
;
; COLOR = ['PURPLE','BLUE','GREEN','YELLOW','ORANGE','RED'] for example.
;
  PRINT, SYSTIME() + ' Plotting the Forecast Histogram...'
;
  IF N_PARAMS( ) LT 5 THEN  BEGIN  ; GRAPHIC_FILE is not provided.
     GRAPHIC_FILE = ''  ; The created figure will not be saved.
  ENDIF  ; Defining the GRAPHIC_FILE.
;
; Get the END_DATEs from PERIOD.
;
                         N = N_ELEMENTS( PERIOD )
  END_DATE  = [ PERIOD[1:N-1] - 1.0D0/86400.0, SYSTIME(/JULIAN) ]
  N_PERIODS =            N
;
; Get the 1st dimension of the DATA array.
;
  S = SIZE( DATA, /DIMENSION )  ; DATA is a 2-D array where
;           DATA[*,0] = JULDAY()'s,
;           DATA[*,1] = 1-Day average of the NANO (detided) Depths in meters.
;           DATA[*,2] = 8-Week Rate of the depth being change in cm/yr. <- Not being used here.
;           DATA[*,3] = 4-Week, 12- or 24-Week Rate of the depth being change in cm/yr.
  N = S[0]  ; The length of the 1st dimension of the DATA array.
;
; If the 4-, 12- or 24-Week Rate of the depth being change in cm/yr is negative,
; No Forecast Histogram figure will be created.
;
  IF ( DATA[N-1,3] LE 0.0 ) THEN  BEGIN  ; The current 4-Week or 12-Week Rate < 0.
     PRINT, SYSTIME() + ' The current 4-Week or 12-Week Rate is < 0 on '  $
                      +   STRING( FORMAT='(C())', DATA[N-1,0] )
     PRINT, SYSTIME() + ' No Forecast Histogram figure will be created.'
     P = -1  ; For BARPLOT_OBJECT=P to indicate No figure is created.
     RETURN  ; to Caller.
  ENDIF  ; Checking the current 4- or 12-Week Rate.
;
; Get all the index positions of the 12-Week Rates that are positive
; just in case there are any value are less or equal to zero.
;
  R = WHERE( DATA[0:N-1,3] GT 0.0, N )  ;  So that all DATA[R,3] > 0.
;
; Compute the distances to the threshold.
;
; D =    ( DATA[R,1]   -      DEPTH_THRESHOLD ) ; Distances to the top: 1509.79 meters, e.g.
  D = ABS( DATA[R,1] ) - ABS( DEPTH_THRESHOLD )  ; in case all DATA[R,1] are < 0.  8/23/2018
;
  I = WHERE( D LT 0.0, M )   ; Look for any distances pass the threshold.
  IF ( M GT 0 ) THEN  BEGIN  ; There are at least 1 point across the threshold.
     PRINT, SYSTIME() + ' There are at least 1 depth value across the threshold: '  $
                      +   STRTRIM( DEPTH_THRESHOLD, 2 )
;    N = I[0]  ; So that D[0:N-1] >= 0.
;    PRINT, SYSTIME() + ' No Forecast Histogram figure will be created.'
;    RETURN  ; to Caller.
  ENDIF  ; Checking distances across the threshold.
;
; Compute the Forecasted Times.
;
  T = D*100.0/DATA[R,3]               ; Times in years to the top & DATA[0:*,3]=12-Week Rate.
  T = DATA[R,0] + TEMPORARY( T )*365  ; Forecasted Times to the top.
  S = MIN( T, MAX=M )                 ; Min. & Max. Time Range in T.
;
    TIME_XRANGE   =  [S,M]
  RESENT_FORECAST = T[N-1]
        P         =   N     ; Last DATA point before reach the  used the Threshold.
;
  PRINT, 'Date & Time values for the TIME_XRANGE & RESENT_FORECAST'
  PRINT, FORMAT='(C())', TIME_XRANGE, RESENT_FORECAST
;
; July 31st, 2018
;
  IF NOT KEYWORD_SET( END_XRANGE ) THEN  BEGIN
     END_XRANGE = M
  ENDIF  ; Defining END_XRANGE  
;
; Compute the counts from the 1st time period.
;
  I = 0          ; The very 1st date.
  J = WHERE( DATA[R,0] GT END_DATE[0] )  ; Look for DATA[R[J[0]],0] = END_DATE[0].
  N = J[0] - 1   ; Now DATA[R[I:N],0] contain times from PERIOD[0] to END_DATE[0]
                 ;                   for example from  April to  December 2015
; GET_PREDICTED_DATE, TIME_RANGE=TIME_XRANGE, DATA[I:N,*], DEPTH_THRESHOLD,  $ ; Inputs
  GET_PREDICTED_DATE, TIME_RANGE=TIME_XRANGE, DATA[R[I:N] ,*], DEPTH_THRESHOLD,  $ ; Inputs
                      T, M  ; Outputs: Time array and M array contains Counts.
;
  N_CNTS = N_ELEMENTS( T )  ; = N_ELEMENTS( M )
  COUNT  = INTARR( N_CNTS, N_PERIODS )  ; For storing the counts from GET_PREDICTED_DATE.
;
  COUNT[0:N_CNTS-1,0] = TEMPORARY( M )  ; Save the counts from the 1st period.
;
; Count the rests of the periods except the last one.
;
  FOR S = 1, N_PERIODS - 2 DO  BEGIN
      I = J[0]       ; For the next period.
      J = WHERE( DATA[R,0] GT END_DATE[S] )  ; Look for DATA[R[J[0]],S] = END_DATE[S].
      N = J[0] - 1   ; Now DATA[R[I:N],0] contain times from PERIOD[S] to END_DATE[S].
      GET_PREDICTED_DATE, TIME_RANGE=TIME_XRANGE, DATA[R[I:N],*], DEPTH_THRESHOLD,  $ ; Inputs
                          T, M  ; Outputs: Time array and M array contains Counts.
      COUNT[0:N_CNTS-1,S] = TEMPORARY( M )  ; Save the counts from the Sth period.
  ENDFOR  ; S
;
; Count the last time period.
;
  I = J[0]                  ; For the last period.
; N = N_ELEMENTS ( R ) - 1  ; Last DATA point before reach the  used the Threshold.
  N = P - 1      ; Last DATA point before reach the  used the Threshold.
  GET_PREDICTED_DATE, TIME_RANGE=TIME_XRANGE, DATA[R[I:N],*], DEPTH_THRESHOLD,  $ ; Inputs
                      T, M  ; Outputs: Time array and M array contains Counts.
  COUNT[0:N_CNTS-1,S] = TEMPORARY( M  ) ; Save the counts from the Sth period.
;
; Display the counts as the histogram bars from the sum of all the counts from each period.
;
  M = TOTAL( COUNT, 2 )  ; = COUNT[*,0] + COUNT[*,1] + ... + COUNT[*,N_PERIODS-1]
;
  I = FIX( STRING( TIME_XRANGE[0], FORMAT="(C(CYI))" ) )  ; Get the Year of the Start date.
  IF TIME_XRANGE[1] GT END_XRANGE THEN  BEGIN
     Y = FIX( STRING(  END_XRANGE   , FORMAT="(C(CYI))" ) )  ; Get the Year of the end date.
  ENDIF  ELSE  BEGIN
     Y = FIX( STRING( TIME_XRANGE[1], FORMAT="(C(CYI))" ) )  ; Get the Year of the end date.
  ENDELSE
;
  P  = BARPLOT( DIMENSION=[1024,512], FILL_COLOR='RED', XTICKDIR=1,  $
       TITLE='Distribution of predicted dates when inflation will reach 2015 threshold',  $
                YTITLE='Number of Occurrence of each Date',   $
                XTITLE='Time Bin=1 Month', XTICKUNITS='YEAR', $
                XTICKFORMAT='(C(CYI))',    XTICKINTERVAL= 2,  $
                XRANGE=[JULDAY(1,1,I),JULDAY(12,31,Y)], XMINOR=5,  T,M, $
                BUFFER=(1 - SHOW_PLOT) )  ; Note that BUFFER=1 means No showing. 
;
  J = FIX( STRING( RESENT_FORECAST, FORMAT="(C(CMOI))" ) )  ; Get the Month and Year
  Y = FIX( STRING( RESENT_FORECAST, FORMAT="(C(CYI))"  ) )  ; of the latest forecast time.
  S = WHERE( T GT JULDAY( J, 1, Y ) )            ; where T = Forecasted Times to the top.
  S = S[0] - 1
  IF ( JULDAY( J, 1, Y ) - T[S] ) GT 0 THEN S += 1
  J = SIZE( DATA, /DIMENSION )
  N = J[0]  ; The size of the 1st dimension of DATA.
;
; Bill changed position of 'triangle_down' label lines from y=0.35 to y=0.40 below, 9/2021
;
; IF TIME_XRANGE[1] GT END_XRANGE THEN  BEGIN  ; July   31st, 2018
  IF T[S]           GT END_XRANGE THEN  BEGIN  ; August 23rd, 2018
;    No plotting for the 'triangle_down' on top of a histogram bar.
;    Only label the forecast date.
;    I = SYMBOL( 0.6, 0.35, 'triangle_down', /NORMAL,      $
;                LABEL_STRING='Latest Forecast on ' +     $
;        STRING( FORMAT="(C(CMoa,X,CDI,', ',CYI))", DATA[N-1,0] ),  $
;                 LABEL_COLOR ='RED', SYM_COLOR='BLACK', SYM_THICK=2 )
     I = TEXT( COLOR='RED', /NORMAL, 0.6, 0.40,  'Latest Forecast on ' +      $
         STRING( FORMAT="(C(CMoa,X,CDI,', ',CYI))", DATA[N-1,0] ) + ' is on' ) 
     I = TEXT( COLOR='RED', /NORMAL, 0.6, 0.35,                   $
             + STRING( FORMAT="(C(CMoa,X,CDI,', ',CYI))", T[S] )  $
             + ' which is out of plotting range.' )
  ENDIF  ELSE  BEGIN
     I = SYMBOL( T[S], M[S]+0.51, 'triangle_down', /DATA, $
                 SYM_COLOR='BLACK', SYM_THICK=2           )
     I = SYMBOL( 0.6, 0.40, 'triangle_down', /NORMAL,      $
                 LABEL_STRING='Latest Forecast on ' +     $
         STRING( FORMAT="(C(CMoa-9,X,CDI,', ',CYI))", DATA[N-1,0] ),  $
                 LABEL_COLOR ='RED', SYM_COLOR='BLACK', SYM_THICK=2 )
  ENDELSE
;
; Overplot the rest of the bars with 1 less period each time to produce a stacking block affect. 
;
; Note the IDL "BOTTOM_VALUES=data_array" option for BARPLOT() does not work here; because,
; when there is any zero values in the data_array, the Stacking will not appear correctly.
; May 10th, 2018.
;
  FOR S  = N_PERIODS - 1, 1, -1 DO  BEGIN
      M -= COUNT[0:N_CNTS-1,S]  ; COUNT[*,0] + COUNT[*,1] + ... + COUNT[*,N_PERIODS-2]
      P  = BARPLOT( FILL_COLOR=COLOR[S-1], /OVERPLOT, T, M  )
  ENDFOR  ; Overplot bar from each period with each time has 1 less period.
;
; Label the color codings: (these are actually set in RunForecastDates.pro)
;
; --------- PERIOD[0:5] were used before December 19th, 2018 ---------
; PERIOD[0]: June 2015 to Dec 2016 = purple;
; PERIOD[1]: Jan-Jun 2016 = blue,   PERIOD[2]: Jul-Dec 2016 = green;
; PERIOD[3]: Jan-Jun 2017 = yellow, PERIOD[4]: Jul-Dec 2017 = orange;
; PERIOD[5]: Jan 2018-present = red.
;
; --------- PERIOD[0:6] are being used from December 19th, 2018 on ---
; PERIOD[0]: June 2015 to Dec 2016 = purple;
; PERIOD[1]: Jan-Jun 2016 = blue,  PERIOD[2]: Jul-Dec 2016 = cyan;
; PERIOD[3]: Jan-Jun 2017 = green, PERIOD[4]: Jul-Dec 2017 = yellow;
; PERIOD[5]: Jan-Jun 2018 = orange,
; PERIOD[6]: Jul 2018-present = red.
;
  M = STRING( FORMAT='(C(CMoA-9,1X,CYI))', PERIOD[N_PERIODS-1] ) + ' - present'
  I = TEXT( /NORMAL, 0.59, 0.80, 'Time when prediction was made' )
  I = SYMBOL( 0.6, 0.75, 'square', /NORMAL, /SYM_FILLED,        $
              LABEL_STRING=M, LABEL_COLOR =COLOR[N_PERIODS-1],  $
                            SYM_FILL_COLOR=COLOR[N_PERIODS-1]   )
  J = 0.75
;
  FOR S = N_PERIODS - 2, 0, -1 DO  BEGIN
      M = STRING( FORMAT='(C(CMoA-9,1X,CYI))',   PERIOD[S] ) + ' - '  $
        + STRING( FORMAT='(C(CMoA-9,1X,CYI))', END_DATE[S] )
                       J -= 0.05
      IF ( STRUPCASE( COLOR[S] ) EQ 'YELLOW' ) THEN  BEGIN  ; When COLOR[S] == Yellow,
         I = SYMBOL( 0.6, J, 'square', /NORMAL, LABEL_STRING=M,  $
                    /SYM_FILLED, SYM_FILL_COLOR=COLOR[S] )  ; Use Black for labelling
         I = SYMBOL( 0.6, J, 'square', /NORMAL )  ; to draw a line for the yellow square above.
      ENDIF  ELSE  BEGIN  ; COLOR[S] other than yellow.
         I = SYMBOL( 0.6, J, 'square', /NORMAL,             $
                     LABEL_STRING=M, LABEL_COLOR=COLOR[S],  $
                     /SYM_FILLED, SYM_FILL_COLOR=COLOR[S]   )
      ENDELSE
  ENDFOR  ; Labelling information.
;
; I = SYMBOL( 0.6, 0.75, 'square', /NORMAL, /SYM_FILLED,  $
;             LABEL_STRING='July 2017 - December 2017',   $
;             LABEL_COLOR ='ORANGE', SYM_FILL_COLOR='ORANGE' )
; I = SYMBOL( 0.6, 0.70, 'square', /NORMAL, /SYM_FILLED,  $
;             LABEL_STRING='January 2017 - June  2017',   $
;                                SYM_FILL_COLOR='YELLOW'  )
; I = SYMBOL( 0.6, 0.70, 'square', /NORMAL )  ; to drew a line for the yellow square above.
; I = SYMBOL( 0.6, 0.65, 'square', /NORMAL, /SYM_FILLED,  $
;             LABEL_STRING='July 2016 - December 2016',   $
;             LABEL_COLOR ='GREEN', SYM_FILL_COLOR='GREEN')
; I = SYMBOL( 0.6, 0.60, 'square', /NORMAL, /SYM_FILLED,  $
;             LABEL_STRING='January 2016 - June  2016',   $
;             LABEL_COLOR ='BLUE',  SYM_FILL_COLOR='BLUE' )
; I = SYMBOL( 0.6, 0.55, 'square', /NORMAL, /SYM_FILLED,  $
;             LABEL_STRING='June 2015 - December 2015',   $
;             LABEL_COLOR ='PURPLE', SYM_FILL_COLOR='PURPLE' )
;
; Save the generated figure into a graphic file if it is asked for.
;
  IF GRAPHIC_FILE NE '' THEN  BEGIN  ; Generate a graphic file.
     WRITE_PNG, GRAPHIC_FILE, P.CopyWindow( )  ; Save the figure to the GRAPHIC_FILE.
;    where
;    GRAPHIC_FILE = '~/4Chadwick/RSN/MJ03F/ForecastHistogramMJ03F.png' for example.
;    P.CopyWindow( ) is getting the figure from the graphic buffer.
     PRINT, SYSTIME() + ' ' + GRAPHIC_FILE + ' is created.'
  ENDIF
;
  RETURN
  END  ; PLOT_FORECAST_HISTOGRAM 
;------------------------------------------------------------------------------------
; Display a Forecast Projected Date.
;
; Callers: From Run[Diff]ForecastDates.pro and Users.
; Revised: February 12th, 2020
;
PRO PLOT_FORECAST_PROJECTION,  NANO_DATA_FILE,  $ ; Input: IDL Save File name.
                CURRENT_DATE,  $ ; Input: The most resent date in JULDAY().
                LATEST_DEPTH,  $ ; Input: The most resent 1-Day average depth in meters.
                 WEEKLY_RATE,  $ ; Input: For example, 12-Week Rate in cm/yr.
;             DATE2THRESHOLD,  $ ; Input: The most resent Forecasted date to the threshold.
             DEPTH_THRESHOLD,  $ ; Input: The eruption threshold in meters.
                GRAPHIC_FILE,  $ ; Input: Graphic output file name.
           DISPLAY=SHOW_PLOT,  $ ; Input: 0 = Not display the figure on the screen or 1 = yes.
       EXTENDED_CM=EXTRA_RNG,  $ ; Input: in cm for +/- range for the DEPTH_THRESHOLD.
       N_WEEK=N_WEEK_RATE,     $ ; Input: Number, e.g., 8 means WEEKLY_RATE = 8-week Rate.
       PLOT_OBJECT=P           ;  Output: Return P = PLOT() to the caller. 
;
  PRINT, SYSTIME() + ' Plotting the Forecast Projection figure..'
;
  IF NOT KEYWORD_SET( N_WEEK_RATE ) THEN  BEGIN  ; Set the default value.
     N_WEEK_RATE = 12   ; assume the WEEKLY_RATE = 12-week rate.
  ENDIF  ; Defining the N_WEEK_RATE
;
  IF NOT KEYWORD_SET( EXTRA_RNG ) THEN  BEGIN  ; Set the default value.
     EXTRA_RNG = 30   ; in cm.
  ENDIF  ; Defining the EXTRA_RNG.
;
  IF N_PARAMS( ) LT 6 THEN  BEGIN  ; GRAPHIC_FILE is not provided.
     GRAPHIC_FILE = ''  ; The created figure will not be saved.
  ENDIF  ; Defining the GRAPHIC_FILE.
;
; Compute the variable: DATE2THRESHOLD = Forecasted Times to the top of the DEPTH_THRESHOLD.
;
; D =    ( LATEST_DEPTH   -      DEPTH_THRESHOLD )  ; Distances to the top: 1509.79 meters, e.g.
  D = ABS( LATEST_DEPTH ) - ABS( DEPTH_THRESHOLD )  ; in case LATEST_DEPTH < 0.  8/23/2018
  R = D*100.0/WEEKLY_RATE  ; Times in years to the top computed from the 12-Week Rate.
  DATE2THRESHOLD = CURRENT_DATE + TEMPORARY( R )*365   ; Forecasted Times to the top.
;
  CALDAT, DATE2THRESHOLD,  M, I, Y     ; Get the Month, Day and Year from the DATE2THRESHOLD.
;
  START_DATE = JULDAY(1,1,2015,0,0,0)  ; For the plotting range.
    END_DATE = JULDAY(1,1,2026,0,0,0)  ; Started July 5th, 2021 (by Bill).
;   END_DATE = JULDAY(1,1,2025,0,0,0)  ; Started December 10th, 2020.
;   END_DATE = JULDAY(1,1,2024,0,0,0)  ; Started January 20th, 2020 until Dec 10th, 2020.
;   END_DATE = JULDAY(1,1,2022,0,0,0)  ; Used till November 19th, 2018
;
 ;IF DATE2THRESHOLD  GT END_DATE THEN  BEGIN  ; Extend the END_DATE
 ;   END_DATE = JULDAY(M+1,1,Y, 0,0,0)
 ;ENDIF  ; Resetting the END_DATE
;
; Retrieve the array variables: NANO_TIME & NANO_DETIDE from
; NANO_DATA_FILE = '~/4Chadwick/RSN/MJ03F/MJ03F-NANO.idl'
;                  ( contains: NANO_TIME, NANO_DETIDE, NANO_PSIA, NANO_TEMP )
;             or = '~/4Chadwick/RSN/MJ03F/NANOdifferencesMJ03E-F.idl'
;                  ( contains: NANO_TIME, NANO_DIFF ).
;
  RESTORE, NANO_DATA_FILE  ;
;
; Locate the date & time on January 1st, 2015.
;
; S = WHERE( NANO_TIME GT JULDAY( 12,31,2014, 23,59,59 ) )
; S = S[0]    ; = 683733
  S = 683733  ; for the NANO_TIME[S] = JULDAY( 1,1,2015, 00,00,00 ).
  N = N_ELEMENTS( NANO_TIME )
;
  STATION = 'MJ03F'
;
  IF STREGEX( FILE_BASENAME( NANO_DATA_FILE ), 'differences' ) GT 0 THEN  BEGIN
;    NANO_DATA_FILE = '~/4Chadwick/RSN/MJ03F/NANOdifferencesMJ03E-F.idl'
;    and it contains 2 array variables: NANO_TIME and NANO_DIFF
     NANO_DETIDE = TEMPORARY( NANO_DIFF )  ; Rename the NANO_DIFF to NANO_DETIDE.
     STATION     = 'MJ03E - MJ03F'
     S = 654070  ; for the NANO_TIME[S] = JULDAY( 1,1,2015, 00,00,00 ).
  ENDIF  ; Rename the NANO_DIFF to NANO_DETIDE.
;
  NANO_PSIA = 0  ; Free the arrays' variables.
  NANO_TEMP = 0  ; They are not needed.
;
  PRINT, FORMAT='(C())', NANO_TIME[S]  ; for checking
;
; Select every 240=4x60 points between S & N for plotting.
; Note that NANO_DETIDE points are at 4 seconds interval.
; So every 240th points means the select points will be at every hour.
;
  P = N - S + 1  ; Total data points in NANO_DETIDE[S:N-1].
  P = P/240      ; for selecting every 240th points. Each NANO_DETIDE point is 4 seconds. 
  S = LINDGEN( P )*240 + S  ; Indexes for every 240th points in between S & N.
;
  MAX_DEPTH =  MAX( NANO_DETIDE[S], MIN=MIN_DEPTH )
  MAX_DEPTH = CEIL( MAX_DEPTH )
  IF MIN_DEPTH LT DEPTH_THRESHOLD THEN  BEGIN
     MIN_DEPTH = FLOOR( MIN_DEPTH )
  ENDIF  ELSE  BEGIN
     MIN_DEPTH = FLOOR( DEPTH_THRESHOLD )
  ENDELSE
;
  IF ( MIN_DEPTH LT 0 ) AND ( MAX_DEPTH LT 0 ) THEN  BEGIN
         D     = MIN_DEPTH  ; Switching the
     MIN_DEPTH = MAX_DEPTH  ; MIN_DEPTH & MAX_DEPTH
     MAX_DEPTH =     D      ; values.
  ENDIF
;
  I = ( SHOW_PLOT GT 0 ) ? 0 : 1  ; for the BUFFER=I below.
  P = PLOT( NANO_TIME[S], NANO_DETIDE[S],  DIMENSION=[1024,512],           $
      TITLE='OOI NANO-BPR data from the Caldera Center (' + STATION + ') at Axial Seamount',  $
            XTICKFORMAT='(C(CMoA,1X,CYI))', YTITLE='Detided Depth (m)',    $
            XRANGE=[START_DATE, END_DATE],  XMINOR=11, POSITION=[0.1,0.13,0.95,0.89],         $
            YRANGE=[MAX_DEPTH, MIN_DEPTH],   BUFFER=I )  ; Note that BUFFER=1 means No showing.
;
; Draw the projected dash lines to the 2015 Eruption Threshold top & Beyond
; if the 12-week Rate is Positive.                          July 17th, 2018
;
; IF WEEKLY_RATE GT 0.0 THEN  BEGIN  ;  Used before August, 2018; 4.9 used until 7/2021
  IF WEEKLY_RATE GT 1.9 THEN  BEGIN  ;  OK to plot the projected lines. (bill)
;    Compute the Predicted Times to the extended top.
;    D =    ( LATEST_DEPTH   -    ( DEPTH_THRESHOLD - 0.3 ) )  ; Distances to beyond the top.
     S = EXTRA_RNG/100.0  ; Convert the extend range from cm to meters.
     D = ABS( LATEST_DEPTH ) - ABS( DEPTH_THRESHOLD - S )  ; in case LATEST_DEPTH < 0.  8/23/2018
     R = D*100.0/WEEKLY_RATE                           ; Times in years to beyond the top
     Y = CURRENT_DATE + R*365                         ; Predicted Times to the extended top.
;    Draw a Purple projected dash line to Beyond the 2015 Eruption Threshold top.
     P = PLOT( [ NANO_TIME[N-1], Y ], [NANO_DETIDE[N-1],DEPTH_THRESHOLD-S],  $
                 'o--2', COLOR='PURPLE',    SYM_FILLED=1,  /OVERPLOT   )
;    Draw a Blue projected dash line to the 2015 Eruption Threshold top.
     P = PLOT( [ NANO_TIME[N-1], DATE2THRESHOLD ], [NANO_DETIDE[N-1],DEPTH_THRESHOLD],  $
                 'ob--2',  SYM_FILLED=1,  /OVERPLOT )
  ENDIF  ; Plotting the projected lines to the 2015 Eruption Threshold top & Beyond.
;
; Draw 2 dashed lines above and below the 2015 Eruption Threshold: 1509.79
; and 1 solid line at the Threshold.  All lines are in Red.
;
  R = EXTRA_RNG/100.0  ; Convert the extend range from cm to meters.
  P = PLOT( [START_DATE,END_DATE], DEPTH_THRESHOLD+[ R , R ],       'r--', /OVERPLOT )
  P = PLOT( [START_DATE,END_DATE], DEPTH_THRESHOLD-[ R , R ],       'r--', /OVERPLOT )
  P = PLOT( [START_DATE,END_DATE], [DEPTH_THRESHOLD,DEPTH_THRESHOLD], 'r', /OVERPLOT )
;
; The following 3 are Testing statements.
; Note that the problem only happened in this program when TEXT( /DATA, ... ) or
; SYMBOL( /DATA, LABEL_TEXT='...', ... ) IS USED WITH THE /DATA option in IDL 8.2.2.!
; To fixed it, the BASELINE=[1,0],UPDIR=[0,-1] are used.
;
; I = TEXT( /DATA, JULDAY( 1,1,2018 ), 1510.5, 'Am I Up Side Down?' )  ; <-- Text flipped downward!
; I = TEXT( /DATA, JULDAY( 1,1,2018 ), 1510.5, 'Am I Up Side Down?', $
;           BASELINE=[1,0],UPDIR=[0,-1]  )  ; <-- Required to fixed the program. (*)
; I = TEXT( /NORMAL, 0.5, 0.5, 'Am I Right Side Up?', 'g' )  ;<-- Tested OK!
;
; Label the Red Lines. 
;
                I = STRTRIM( ABS( EXTRA_RNG ), 2 )
  IF EXTRA_RNG GT 0 THEN  BEGIN  ; August 24th, 2018
     S = '- ' + I  ; = '- 30'
     D = '+ ' + I  ; = '+ 30' e.g.
  ENDIF  ELSE  BEGIN  ; EXTRA_RNG < 0
     S = '+ ' + I  ; = '+ 20'
     D = '- ' + I  ; = '- 20' e.g.
  ENDELSE ; Defining the 2 dash lines' labels.
                      Y = JULDAY( 1,1,2016 )
;
; After add using the variable S & D to be used in the TEXT(),
; the BASELINE= option (see below) is no longer needed.  August 24th, 2018.
;
; IF !VERSION.RELEASE EQ '8.2.2' THEN  BEGIN
  IF ( STATION EQ 'MJ03F' ) AND ( !VERSION.RELEASE EQ '8.2.2' ) THEN  BEGIN  ; August 27th, 2018
;    The following 3 statements work for EXTRA_RNG=30 cm; but not for EXTRA_RNG= -20 cm.
;    at !VERSION.RELEASE = '8.2.2'.  Not sure why?
     I = TEXT( /DATA, Y, DEPTH_THRESHOLD - R, '   '   + S + ' cm   ',  $
               BASELINE=[1,0],UPDIR=[0,-1] )  ; <-- for fixing the Text flipped downward problem.
     I = TEXT( /DATA, Y, DEPTH_THRESHOLD,     '2015 threshold depth',  $
               BASELINE=[1,0],UPDIR=[0,-1] )  ; <-- See (*) above.
     I = TEXT( /DATA, Y, DEPTH_THRESHOLD + R, '   '   + D + ' cm   ',  $
               BASELINE=[1,0],UPDIR=[0,-1] )
; ENDIF  ELSE  BEGIN  ; Assuming !VERSION.RELEASE is after 8.2.2.
  ENDIF  ELSE  BEGIN  ; Assuming Depth Difference data or !VERSION.RELEASE is after 8.2.2.
;    The following 3 statements work for EXTRA_RNG=-20 cm; but not for EXTRA_RNG= 30 cm.
;    at !VERSION.RELEASE = '8.2.2'.  Not sure why?
     I = TEXT( /DATA, Y, DEPTH_THRESHOLD - R, '   '   + S + ' cm   ' )
     I = TEXT( /DATA, Y, DEPTH_THRESHOLD,     '2015 threshold depth' )
     I = TEXT( /DATA, Y, DEPTH_THRESHOLD + R, '   '   + D + ' cm   ' )
  ENDELSE
;
; Label the Latest Date, Depth and 4-Week, 12-Week or 6-Month (24-Week) Rate.
;
  Y = STRING( FORMAT="(C(CMoA,1X,CDI,', 'CYI))", CURRENT_DATE )
  I = TEXT( /NORMAL, 0.22, 0.30, 'Current date = ' + Y )
;
  D = STRING( FORMAT='(F7.2)', LATEST_DEPTH ) + ' m'  ; Started on September 7th, 2018.
; D = STRTRIM( LATEST_DEPTH, 2 ) + ' m'
; I = TEXT( /NORMAL, 0.22, 0.25, 'Latest depth = ' + D )
;
  R = STRING( FORMAT='(F7.2)', WEEKLY_RATE ) + ' cm/yr'
; I = TEXT( /NORMAL, 0.22, 0.20, 'Latest 12-week inflation rate =' + R )
;
; Label all the Latest Date, and Depth (Diff) for either 4-Week or 12-Week Rate.
;
  M = STRTRIM( N_WEEK_RATE, 2 )  ; If N_WEEK_RATE = '4', then M = '4'.  11/19/2018.
;
  IF STATION EQ 'MJ03F' THEN  BEGIN  ; August 27th, 2018
     I = TEXT( /NORMAL, 0.22, 0.25, 'Latest depth = ' + D )
     I = TEXT( /NORMAL, 0.22, 0.20, 'Latest ' + M + '-week inflation rate =' + R )
     I = TEXT( ALIGNMENT=1, /NORMAL, 0.75, 0.40,      'Threshold depth: ' )
  ENDIF  ELSE  BEGIN  ; STATION == 'MJ03E - MJ03F' for depth difference data.
     I = TEXT( /NORMAL, 0.22, 0.25, 'Latest depth diff = ' + D )
     IF ( N_WEEK_RATE EQ 24 ) THEN  BEGIN  ; February 12th, 2020
        Y = 'Latest 6-month diff inflation rate =' + R
     ENDIF  ELSE  BEGIN  ; N_WEEK_RATE = 4 or 12
        Y = 'Latest ' + M + '-week diff inflation rate ='  + R
     ENDELSE
     I = TEXT( /NORMAL, 0.22, 0.20, Y )
     I = TEXT( ALIGNMENT=1, /NORMAL, 0.75, 0.40, 'Threshold depth diff: ' )
  ENDELSE  ; Done Labelling the Latest Date, and Depth (Diff) for either 4-Week or 12-Week Rate.
;
; Label the Table Header
;
  S = STRCOMPRESS( S, /REMOVE_ALL) + 'cm'  ; where S = '- 30' or '+ 20' for example. 8/24/2018
  IF STATION EQ 'MJ03F' THEN  BEGIN  ; August 27th, 2018
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.76, 0.47, '  2015   ' , COLOR='BLUE'   )
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.75, 0.44, 'Threshold' , COLOR='BLUE'   )
;    I = TEXT( ALIGNMENT=0, /NORMAL, 0.83, 0.47, '2015 -30cm', COLOR='PURPLE' )
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.83, 0.47, '2015 ' + S , COLOR='PURPLE' )
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.835,0.44, 'Threshold' , COLOR='PURPLE' )
  ENDIF  ELSE  BEGIN  ; STATION == 'MJ03E - MJ03F' for depth difference data.
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.76, 0.50, '  2015   ' , COLOR='BLUE'   )
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.75, 0.47, 'Threshold' , COLOR='BLUE'   )
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.75, 0.44, 'difference', COLOR='BLUE'   )
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.83, 0.50, '2015 ' + S , COLOR='PURPLE' )
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.835,0.47, 'Threshold' , COLOR='PURPLE' )
     I = TEXT( ALIGNMENT=0, /NORMAL, 0.835,0.44, 'difference', COLOR='PURPLE' )
  ENDELSE  ; Done Labelling the Table Header.
;
; Label the Table Legends at the left-hand side.
;
; I = TEXT( ALIGNMENT=1, /NORMAL, 0.75, 0.40,         'Threshold depth: ' )  ; Done it from above.
  I = TEXT( ALIGNMENT=1, /NORMAL, 0.75, 0.35,    'Inflation  remaining: ' )
  I = TEXT( ALIGNMENT=1, /NORMAL, 0.75, 0.30, 'Time remaining to reach: ' )
  I = TEXT( ALIGNMENT=1, /NORMAL, 0.75, 0.25, 'Forecast  date to reach: ' )
;
; Label the Table Contents.
;
  S = EXTRA_RNG/100.0  ; Convert the extend range from cm to meters.
; D = STRTRIM( DEPTH_THRESHOLD,       2 ) + ' m'
; R = STRTRIM( DEPTH_THRESHOLD -  S , 2 ) + ' m'
  D = STRING( FORMAT='(F7.2)', DEPTH_THRESHOLD      ) + ' m'  ; Started on
  R = STRING( FORMAT='(F7.2)', DEPTH_THRESHOLD -  S ) + ' m'  ; September 7th, 2018.
; R = STRTRIM( DEPTH_THRESHOLD - 0.3, 2 ) + ' m'
  I = TEXT( /NORMAL, 0.75, 0.40, D, COLOR='BLUE'   )  ; for the 2015 threshold depth.
  I = TEXT( /NORMAL, 0.84, 0.40, R, COLOR='PURPLE' )  ; for the 2015 Extended threshold depth.
;
;    D =    ( LATEST_DEPTH   -      DEPTH_THRESHOLD )  ; Distances to the top: 1509.79 meters.
     D = ABS( LATEST_DEPTH ) - ABS( DEPTH_THRESHOLD )  ; Distances to the top: 1509.79 meters.
  IF D LE 0.0 THEN  BEGIN  ; Reached or Passed the threshold.
     M = 'None'
  ENDIF  ELSE  BEGIN
     M = STRING( FORMAT='(F7.2)', D ) + ' m'
  ENDELSE  ; Getting the remaining distance to the threshold.
;    R =      LATEST_DEPTH   -    ( DEPTH_THRESHOLD - 0.3 )
     R = ABS( LATEST_DEPTH ) - ABS( DEPTH_THRESHOLD - EXTRA_RNG/100.0 )
  IF R LE 0.0 THEN  BEGIN  ; Reached or Passed the extended threshold.
     R = 'None'
  ENDIF  ELSE  BEGIN
     R = STRING( FORMAT='(F7.2)', R ) + ' m'
  ENDELSE  ; ; Getting the remaining distance to the extended threshold.
  I = TEXT( /NORMAL, 0.75, 0.35, M, COLOR='BLUE'   )  ; for the 2015 threshold depth.
  I = TEXT( /NORMAL, 0.84, 0.35, R, COLOR='PURPLE' )  ; for the 2015 Extended threshold depth.
;
; D = ( LATEST_DEPTH - DEPTH_THRESHOLD )  ; Distances to the top: 1509.79 meters.
; IF WEEKLY_RATE LE 0.0 THEN  BEGIN     ; Used before August 1st, 2018.
  IF WEEKLY_RATE LT 2.0 THEN  BEGIN     ; Assume an eruption has occurred.
     Y = '  N/A'
  ENDIF  ELSE  IF D LE 0.0 THEN  BEGIN  ; Reached or Passed the threshold.
     Y = 'None'
  ENDIF  ELSE  BEGIN  ; WEEKLY_RATE > 0 & ( LATEST_DEPTH - DEPTH_THRESHOLD ) > 0.
     Y = D*100.0/WEEKLY_RATE            ; Times in years to the top
     Y = STRING( FORMAT='(F5.2)', Y ) + ' yr'
  ENDELSE  ; Getting the remaining time to the threshold.
  I = TEXT( /NORMAL, 0.75, 0.30, Y, COLOR='BLUE' )  ; Time remaining to reach the threshold depth.
;
; D = ( LATEST_DEPTH - DEPTH_THRESHOLD + 0.3 )  ; Distances to the Extended top.
  D = ABS( LATEST_DEPTH ) - ABS( DEPTH_THRESHOLD - EXTRA_RNG/100.0 )  ; Distances to the Extended top.
; IF WEEKLY_RATE LE 0.0 THEN  BEGIN     ; Used before August 1st, 2018.
  IF WEEKLY_RATE LT 2.0 THEN  BEGIN     ; Assume an eruption has occurred.
     Y = '  N/A'
  ENDIF  ELSE  IF D LE 0.0 THEN  BEGIN  ; Reached or Passed the extended threshold.
     Y = 'None'
  ENDIF  ELSE  BEGIN  ; WEEKLY_RATE > 0 & ( LATEST_DEPTH - DEPTH_THRESHOLD ) > 0.
     R = D*100.0/WEEKLY_RATE            ; Times in years to the top.
     Y = STRING( FORMAT='(F5.2)', R ) + ' yr'
  ENDELSE  ;  Getting the remaining time to the extended threshold.
  I = TEXT( /NORMAL, 0.84, 0.30, Y, COLOR='PURPLE' )  ; Time remaining to the Extended threshold depth.
;
  IF WEEKLY_RATE GT 0.0 THEN  BEGIN  ; Used before August, 2018. 4.9 cm/yr used until 7/2021 (bill)
; ... then "reinstated" on 12/7/2022 by Bill to see if could get plots running again after
; no plots from August 12, 2022 to December in the Forecast Method #2, #3, #4 plots
;  IF WEEKLY_RATE GT 1.9 THEN  BEGIN  ; Get the Forecast times only when the rate is >= +2cm/yr.
     D = CURRENT_DATE + R*365       ; Forecast times to the Extended top.
     D = STRING( FORMAT="(C(CMoA,1X,CYI))", D )
     Y = STRING( FORMAT="(C(CMoA,1X,CYI))", DATE2THRESHOLD )
  ENDIF  ELSE  BEGIN  ; WEEKLY_RATE < +2 cm/yr. (or negative rate after 12/7/2022 - Bill)
     D = '  N/A'
     Y = '  N/A'
  ENDELSE
;
  I = TEXT( /NORMAL, 0.75, 0.25, Y, COLOR='BLUE'   )  ; Forecast date to reach the 2015 threshold depth.
  I = TEXT( /NORMAL, 0.84, 0.25, D, COLOR='PURPLE' )  ; Forecast date to the Extended threshold depth.
;
; Save the generated figure into a graphic file if it is asked for.
;
  IF GRAPHIC_FILE NE '' THEN  BEGIN  ; Generate a graphic file.
     WRITE_PNG, GRAPHIC_FILE, P.CopyWindow( )  ; Save the figure to the GRAPHIC_FILE.
;    where
;    GRAPHIC_FILE = '~/4Chadwick/RSN/MJ03F/ForecastHistogramMJ03F.png' for example.
;    P.CopyWindow( ) is getting the figure from the graphic buffer.
     PRINT, SYSTIME() + ' ' + GRAPHIC_FILE + ' is created.'
  ENDIF
;
  RETURN
  END  ; PLOT_FORECAST_PROJECTION 
;--------------------------------------------------------------------------------------
; The following routine was only used between May 11th to 14th, 2018
; It only plots the 2015 threshold, not the extended threshold; see PLOT_SCATTER2FORECAST
; for that below (so you can ignore this until the next horizontal line)
;
; Callers: From RunForecastDates.pro and Users.
;
PRO PLOT_SCATTER_FORECAST, DATA,  $ ; Input: 2-D array of Dates, Depths & Rates info.
         DEPTH_THRESHOLD,  $ ; Input: The eruption threshold in meters.
            GRAPHIC_FILE,  $ ; Input: Graphic output file name.
            TITLE4FIGURE,  $ ; Input: Character Strings.
       DISPLAY=SHOW_PLOT,  $ ; Input: 0 = Not display the figure on the screen or 1 = yes.
       PLOT_OBJECT=P       ;  Output: Return P = PLOT() to the caller. 
;
  PRINT, SYSTIME() + ' Plotting the predicted eruption dates versus dates of prediction...'
;
; Get the Forecasted Times.
;
  D = ( DATA[0:*,1] - DEPTH_THRESHOLD )  ; Distances to the top: 1509.79 meters, e.g.
  S = WHERE( D LE 0.0, M )
;
  IF M GT 0 THEN  BEGIN
     PRINT, SYSTIME() + ' Depth at or pass over the threshold: ' + STRTRIM( DEPTH_THRESHOLD, 2 )
     PRINT, SYSTIME() + ' No Scatter Dates will be plotted.'
  ENDIF  ELSE  BEGIN  ; Depths are not pass over the threshold yet.
     T = D*100.0/DATA[0:*,3]                ; Times in years to the top & DATA[0:*,3]=12-Week Rate.
     T = DATA[0:*,0] + TEMPORARY( T )*365   ; Forecasted Times to the top.
     IF N_PARAMS() LT 4 THEN  BEGIN  ; TITLE4FIGURE is not provided.
        TITLE4FIGURE = 'Date of prediction vs. Predicted date inflation will reach 2015 threshold'
     ENDIF 
; Bill changed max XRANGE below to extend Scatter plot max x-axis range to Jan 2024 - 12/2022
     M = PLOT( DATA[*,0], T,             LINESTYLE='NONE',     $
               SYMBOL='o', SYM_COLOR='BLUE', SYM_FILLED=1,     $
               DIMENSION=[1024,512],      TITLE=TITLE4FIGURE,  $
               XRANGE=[ JULDAY(1,1,2015), JULDAY(1,1,2024) ],  XMINOR=11,    $
               XTICKFORMAT='(C(CMoA,1X,CYI))', YTICKFORMAT='(C(CYI))',       $
               YTITLE='Predicted date inflation will reach 2015 threshold',  $
               XTITLE='Date of prediction', BUFFER=( 1 - SHOW_PLOT ) )
     IF GRAPHIC_FILE NE '' THEN  BEGIN  ; Generate a graphic file.
        WRITE_PNG, GRAPHIC_FILE, M.CopyWindow( )
;       where      GRAPHIC_FILE = '~/4Chadwick/RSN/MJ03F/ScatterDates1MJ03F.png' for example.
;                  M.CopyWindow( ) is getting the figure from the graphic buffer.
        PRINT, SYSTIME() + ' ' + GRAPHIC_FILE + ' is created.'
     ENDIF 
  ENDELSE
;
  RETURN
  END  ; PLOT_SCATTER_DATES
;--------------------------------------------------------------------------------------
; This routine displays the both Forecast Dates for reaching the eruption threshold
; and the extended threshold, i.e. this has been used since May 15th, 2018
;
; Callers: From Run[Diff]ForecastDates.pro and Users.
; Revised: February 12th, 2020
;
PRO PLOT_SCATTER2FORECAST, DATA,  $ ; Input: 2-D array of Dates, Depths & Rates info.
         DEPTH_THRESHOLD,  $ ; Input: The eruption threshold in meters.
            GRAPHIC_FILE,  $ ; Input: Graphic output file name.
            TITLE4FIGURE,  $ ; Input: Character Strings.
       DISPLAY=SHOW_PLOT,  $ ; Input: 0 = Not display the figure on the screen or 1 = yes.
   EXTENDED_CM=EXTRA_RNG,  $ ; Input: in cm for +/- range for the DEPTH_THRESHOLD.
   MAX_YRANGE=END_YRANGE,  $ ; Input: JULDAY() for the max. time range to be shown.
       PLOT_OBJECT=M       ;  Output: Return P = PLOT() to the caller. 
;
  IF NOT KEYWORD_SET( EXTRA_RNG ) THEN  BEGIN  ; Set the default value.
     EXTRA_RNG = 30   ; in cm.
  ENDIF
;
; Get the 1st dimension of the DATA array.
;
  S = SIZE( DATA, /DIMENSION )  ; DATA is a 2-D array where
;           DATA[*,0] = JULDAY()'s,
;           DATA[*,1] = 1-Day average of the NANO (detided) Depths in meters.
;           DATA[*,2] = 8-Week Rate of the depth being change in cm/yr. <- Not being used here.
;           DATA[*,3] = 4-, 12- or 24-Week Rate of the depth being change in cm/yr.
  N = S[0]  ; The length of the 1st dimension of the DATA array.
;
; If the 12-Week Rate of the depth being change in cm/yr is negative,
; No Forecast scatter plot figure will be created.
;
  IF ( DATA[N-1,3] LE 0.0 ) THEN  BEGIN  ; The current 4-, 12- or 24-Week Rate < 0.
     PRINT, SYSTIME() + ' The current 12-Week Rate is < 0 on '  $
                      +   STRING( FORMAT='(C())', DATA[N-1,0] )
     PRINT, SYSTIME() + ' No Forecast scatter plot figure will be created.'
     M = -1  ; For PLOT_OBJECT=P to indicate No figure is created.
     RETURN  ; to Caller.
  ENDIF  ; Checking the current 4- or 12-Week Rate.
;
  PRINT, SYSTIME() + ' Plotting the predicted eruption dates versus dates of prediction...'
;
; Get all the index positions of the 12-Week Rates that are positive
; just in case there are any value are less or equal to zero.
;
  R = WHERE( DATA[0:N-1,3] GT 0.0, N )  ;  So that all DATA[R,3] > 0.
;
; Get the Forecasted Times to the top threshold (e.g 1509.79 meters) and + 30 cm.
;
; D = ( DATA[R,1] - ( DEPTH_THRESHOLD - 0.3 ) )  ; Distances to the top.
  S = EXTRA_RNG/100.0  ; Convert the extend range from cm to meters.
  D = ABS( DATA[R,1] ) - ABS( DEPTH_THRESHOLD - S )  ; in case all DATA[R,1] are < 0.  8/23/2018
  S = WHERE( D LE 0.0, M )
;
  IF M GT 0 THEN  BEGIN
     PRINT, SYSTIME() + ' Depth at or pass over the threshold: ' + STRTRIM( DEPTH_THRESHOLD, 2 )
     PRINT, SYSTIME() + ' No Scatter Dates will be plotted.'
  ENDIF  ELSE  BEGIN  ; Depths are not pass over the threshold yet.
     T = D*100.0/DATA[R,3]                ; Times in years to the top & DATA[R,3]=12-Week Rate.
     T = DATA[R,0] + TEMPORARY( T )*365   ; Forecasted Times to the top.
     IF N_PARAMS() LT 4 THEN  BEGIN  ; TITLE4FIGURE is not provided.
        TITLE4FIGURE = 'Date of prediction vs. Predicted date inflation will reach 2015 threshold'
     ENDIF
     S = MIN( T, MAX=D )  ; Get the Min. & Max. of the Forecasted Times
;    PRINT, FORMAT='(C())', S, D
     IF KEYWORD_SET( END_YRANGE ) THEN  BEGIN  ; August 1st, 2018.
        IF D GT END_YRANGE THEN  BEGIN  ; Max. Forecasted Time > END_YRANGE.
           D =  END_YRANGE  ; Replace the Max. Forecasted Time to the specified upper Y range.
        ENDIF  ; Resetting the Upper Y range.
        M =   5   ; Increments in years.
     ENDIF  ELSE  BEGIN  ; Checking the Max. Forecasted Times.
        M = 100   ; Increments in years.
     ENDELSE  ; Defining the Max. Forecasted Times and Year Increment.
     S = FIX( STRING( FORMAT='(C(CYI))', S ) )  ; Get the Year.
     S = S - ( S MOD  M  )                      ; Lower the year, e.g. 2018 will be = 2010.
     S = JULDAY( 1, 1, S, 0,0,0 )               ; Set to the beginning of the year.
     D = FIX( STRING( FORMAT='(C(CYI))', D ) )  ; Get the Year.
     D = D +  M  - ( D MOD  M  )                ; Up the year, e.g. 2024 will be = 2030
     D = JULDAY( 1, 1, D, 0,0,0 )               ; Set to the beginning of the year.
;    PRINT, FORMAT='(C())', S, D
;
; Bill changed XRANGE max in this ScatterDates Plot to Jan 2024 on 12/2022 below
;
     M = PLOT( DATA[R,0], T, LINESTYLE='NONE', YRANGE=[S,D],   $
               SYMBOL='o', SYM_COLOR='PURPLE', SYM_FILLED=1,   $
               DIMENSION=[1024,512],      TITLE=TITLE4FIGURE,  $
               XRANGE=[ JULDAY(1,1,2015), JULDAY(1,1,2024) ], XMINOR=11,     $
               XTICKFORMAT='(C(CMoA,1X,CYI))', YTICKFORMAT='(C(CYI))',       $
               YTITLE='Predicted date inflation will reach 2015 threshold',  $
               XTITLE='Date of prediction', BUFFER=( 1 - SHOW_PLOT ) )
     S = ( EXTRA_RNG GT 0 ) ? STRTRIM( -EXTRA_RNG, 2 ) : '+' + STRTRIM( ABS( EXTRA_RNG ), 2 )
     T = 'Forecast date to reach the 2015 threshold ' + STRTRIM( S, 2 ) + ' cm'  ; August 23rd, 2018
     S = TEXT( /NORMAL, 0.55,0.225, T, COLOR='PURPLE' )  ; From October 30th, 2019 on.
;    S = TEXT( /NORMAL, 0.55, 0.75, T, COLOR='PURPLE' )  ; used until October 30th, 2019.
;    S = TEXT( /NORMAL, 0.55, 0.75, 'Forecast date to reach the 2015 threshold -30 cm', COLOR='PURPLE' )
;    D =    ( DATA[R,1]   -      DEPTH_THRESHOLD )  ; Distances to the top.
     D = ABS( DATA[R,1] ) - ABS( DEPTH_THRESHOLD )  ; in case all DATA[R,1] are < 0.  8/23/2018
     S = WHERE( D LE 0.0, M )
     IF M GT 0 THEN  BEGIN
        PRINT, SYSTIME() + ' Depth at or pass over the threshold: ' + STRTRIM( DEPTH_THRESHOLD, 2 )
        PRINT, SYSTIME() + ' No Scatter Dates will be plotted.'
     ENDIF  ELSE  BEGIN  ; Depths are not pass over the threshold yet.
        T = D*100.0/DATA[R,3]                ; Times in years to the top & DATA[R,3]=12-Week Rate.
        T = DATA[R,0] + TEMPORARY( T )*365   ; Forecasted Times to the top.
        M = PLOT( DATA[R,0], T,  LINESTYLE='NONE', /OVERPLOT,  $
                  SYMBOL='o', SYM_COLOR='BLUE', SYM_FILLED=1   )
;       The following line from October 30th, 2019 on.
        S = TEXT( /NORMAL, 0.55,0.175, 'Forecast date to reach the 2015 threshold', COLOR='BLUE' )
;       The following line was used until October 30th, 2019.
;       S = TEXT( /NORMAL, 0.55, 0.70, 'Forecast date to reach the 2015 threshold', COLOR='BLUE' )
     ENDELSE
     IF GRAPHIC_FILE NE '' THEN  BEGIN  ; Generate a graphic file.
        WRITE_PNG, GRAPHIC_FILE, M.CopyWindow( )
;       where      GRAPHIC_FILE = '~/4Chadwick/RSN/MJ03F/ScatterDates1MJ03F.png' for example.
;                  M.CopyWindow( ) is getting the figure from the graphic buffer.
        PRINT, SYSTIME() + ' ' + GRAPHIC_FILE + ' is created.'
     ENDIF
  ENDELSE
;
  RETURN
  END  ; PLOT_SCATTER2DATES
