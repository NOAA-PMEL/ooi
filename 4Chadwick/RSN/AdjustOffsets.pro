;
; File: AdjustOffsets.pro
;
; This IDL program contains routines for adjusting the Offsets caused
; by releveling the Tilt sensors such as the LILY and IRIS.
;
; The procedures in this program will be using the procerdures
; in the file: SplitRSNdata.pro
;
; Revised on September 10th, 2018
; Created on October   10th, 2017
;

;
; This is a test procedure and it works.
; This procedure has been replaced by two procedures:
; GET_OFFSETS and APPLY_OFFSETS below.  
; These 2 procedures together will be more effection
; since the determenting of the Offsets value will be only done once.
;
; Callers: Users.
; Revised: October   10th, 2017
;
PRO ADJUST_OFFSETS,  RLT,  $ ;  Input: 2-D array of the Releveling Time Periods.
                    TIME,  $ ;  Input: 1-D array of the JULDAY() values.
                    TILT,  $ ;  Input: 1-D array of either X-/Y-Tilt or Resultant Magnitudes.
           T,   ADJ_TILT     ; Output: 1-D arrays of the Offset Adjust TILT values.
;
  S = SIZE( RLT )  ; Get the size and information of RLT.  August 29th, 2017.
;
  IF S[0] EQ 0 THEN  BEGIN  ; RLT could be Undefined or Not a 2-D array.
     PRINT, 'The 1st parameter (RLT) is either Undefined or Not a 2-D array.'
     PRINT, 'No offset Adjustment is made.  Return to caller.'
     ADJ_TILT = -1
     RETURN   ; to caller.
  ENDIF ELSE IF S[0] EQ 2 THEN  BEGIN
     N = S[2] ; Total elements in the 2nd dimension of RLT.
  ENDIF  ELSE  BEGIN  ; RLT is an 2-Elements array.
     N = S[1] ; 
  ENDELSE   ; Checking RLT
;
 ;ADJ_TILT = TILT  ; Set them equal to start.
;
; RLT is a 2xN array where RLT[0,i] & RLT[1,i] contain the Start & End times
; (in JULDAY()s) of the Releveling Period respectively.
;
  M = N_ELEMENTS( TIME )
;
  PRINT, FORMAT="( C(), ' <--> ', C() )", RLT  ; Show the Times for checking. 
  PRINT, STRTRIM( N, 2 ) + ' of them.'
;
  HELP, RLT, TIME, TILT, ADJ_TILT
  STOP
;
; Apply the Offsets to TILT:
; Each of RLT[0:1,i] contains the Start & End times of the data range
; for i = 0, 1, ..., n
;
; Locate the 1st Releveling Time: RLT[0,0] (on) and RLT[1,0] (off)
;
  K = WHERE( TIME GT RLT[0,0] )
  I = K[0] - 1  ; for DRT[0,0] < TIME[I].
  K = WHERE( TIME GT RLT[1,0] )
  J = K[0]      ; for TIME[J]  < RLT[1,0].
;
; Determine the Offset value for TILT
;
    OFFSET = TILT[I] - TILT[J]
;
; Apply the Tilt Offset for the 1st data range in TIME[DRT[0,0]] to the TIME[M-1].
;
  ADJ_TILT = [ TILT[0:I], TILT[J:M-1] + OFFSET ]
         T = [ TIME[0:I], TIME[J:M-1] ]
         M = N_ELEMENTS( T )
;
  HELP, I, J, M, OFFSET
; STOP
;
; Get and Apply the Offset for the data range DRT[0:1,i] for i = 0,2,...n-1.
;
  FOR S = 1, N-1 DO  BEGIN ; Get the Tilt Differences at each data interval.
      K = WHERE( T GT RLT[0,S] )
      I = K[0] - 1  ; for RLT[0,S] <= TIME[I].
      K = WHERE( T GT RLT[1,S] )
      J = K[0]      ; for TIME[I] < RLT[1,S] < TIME[J].
;     Determine the Offset value for TILT
        OFFSET = ADJ_TILT[I] - ADJ_TILT[J] ;  + OFFSET
;     Apply the Offset to the data range: RLT[1,i] to TIME[M-1].
      ADJ_TILT = [ ADJ_TILT[0:I], ADJ_TILT[J:M-1] + OFFSET ]
         K = J + I - 1
      IF K GT 0 THEN  BEGIN  ; Adjust the array time: T.
         T = [ T[0:I], T[J:M-1] ]
         M = N_ELEMENTS( T )
      ENDIF  ; Reducing the size of the T(ime).
      HELP, I, J, K, M, OFFSET
  ENDFOR  ; S
;
; STOP
;
RETURN
END  ; ADJUST_OFFSETS
;
; To run this procedure, users must run the procedure: GET_OFFSETS 1st to
; obtain the array paramters: DRT and OFFSET.
;
; Callers: Users.
; Revised: October   19th, 2017
;
PRO APPLY_OFFSETS,  DRT,  $ ;  Input: 2-D array of the Releveling Time Periods.
                 OFFSET,  $ ;  Input: 1-D array of the Offset values at each relevel.
                   TIME,  $ ;  Input: 1-D array of the JULDAY() values.
                   TILT,  $ ;  Input: 1-D array of either X-/Y-Tilt or Resultant Magnitudes.
           T,  ADJ_TILT     ; Output: 1-D arrays of the Offset Adjust TILT values.
;
  S =       SIZE( DRT  )    ; Get the size and information of DRT.
  M = N_ELEMENTS( TIME )
  N = N_ELEMENTS( OFFSET )  ; Also = 2nd dimensional size of DRT - 1.
;
  N_OFFSETS = N_ELEMENTS( OFFSET )
;
; Get the 1st data range before the 1st releveling.
;
                    S = DRT[1,0]
         T = TIME[0:S]  ; Note that DRT[0,0] = 0, the 1st data point &
  ADJ_TILT = TILT[0:S]  ; DRT[1,0] = The last point before releveling.
  STEP     = 0.0        ; Cumulated Offset.
;
  FOR S = 1, N DO  BEGIN
      T = [ TEMPORARY( T ), TIME[DRT[0,S]:DRT[1,S]] ]
      D =   TILT[DRT[0,S]:DRT[1,S]] + OFFSET[S-1] + STEP
      HELP, ADJ_TILT, T, D, STEP
      ADJ_TILT = [ TEMPORARY( ADJ_TILT ), TEMPORARY( D ) ]
      STEP    += OFFSET[S-1]
  ENDFOR  ; S  Adjusting the Offsets.
;
RETURN
END  ; APPLY_OFFSETS
;
; This procedure will generate 3 figures using the magnitude change rates of the
; last 2 weeks, 12 months and the last 1-week ans 2-week of the fitted data.
;
; Tested OK on December 13th, 2017  codes only,
;
; Callers: Users.
; Revised: May  22nd, 2018
;
PRO DISPLAY_RATES, ID,  $ ; RSN Station ID: 'MJ03D' to 'MJ03F' for example.
;        JUNE15TH2015,  $ ; Aray index for arrays: TIME & RTM1DAY
       LILY_RATE_FILE,  $ ; IDL save file name: 'MJ03F/MJ03F-LilyRates.idl' e.g.
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
  PRINT, 'In DISPLAY_RATES,'
;
; Retrieve the array variables: T, RTM, XTILT, YTILT,  TIME, RTM1DAY,
;                     XOFFSET, YOFFSET, SRTIME, SRATE, LRTIME, LRATE
; plus an index variable: OFFSET-DATE.
;
  PRINT, SYSTIME() + ' Retrieving data from the file: ' + LILY_RATE_FILE
  S = SYSTIME( 1 )         ; Mark the time.
  RESTORE, LILY_RATE_FILE  ; Get the Rate data for plotting.
  N = SYSTIME( 1 ) - S     ; Total seconds use to retrieve the data in the  LILY_RATE_FILE.
  PRINT, SYSTIME() + ' Done Retrieving.  Total seconds used: ', N
;
; Note that when the SHOW_PLOT=DISPLAY_PLOT2SCREEN keyword is set,
; The displayed figures will Not be saved!
;
  IF KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
     DISPLAY_PLOT2SCREEN = BYTE( 1 )  ; Yes.
     WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=512
;    PRINT, 'Plotting Window: ', !D.WINDOW
  ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
     DISPLAY_PLOT2SCREEN = BYTE( 0 )  ;  No.
     WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=512, /PIXMAP
     PRINT, 'PIXMAP Window: ', !D.WINDOW
  ENDELSE
;
; Display the Tilt magnitudes with its the 1-Day Means.
;
  PLOT_RTM1DAYMEANS, TIME, RTM1DAY, T, RTM, ID
;
  IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN  ; Pixmap option was used.
;    Graphic file name:  'MJ03F/MJ03F-RTM-Since2015.png'  for example
     TITLE4PLOT =   ID + '/' + ID + '-RTM1DayMeans.png'  ; Graphic Output file name.
     WRITE_PNG, TITLE4PLOT, TVRD(/TRUE)
     PRINT,     TITLE4PLOT + ' generated.'
     WDELETE,   !D.WINDOW  ; Remove the pixmap window.
  ENDIF  ; Save the displayed figure.
;
; Open a smaller window for the rests of the displays.
;
  IF KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
     DISPLAY_PLOT2SCREEN = BYTE( 1 )  ; Yes.
     WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
;    PRINT, 'Plotting Window: ', !D.WINDOW
  ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
     DISPLAY_PLOT2SCREEN = BYTE( 0 )  ;  No.
     WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256, /PIXMAP
     PRINT, 'PIXMAP Window: ', !D.WINDOW
  ENDELSE
;
; Note the 365x[L/S]RATE change the rate units from urandian/day to urandian/year.
; Also the SRATE[28:*] will match with all the elements in LRATE in terms of TIME.
;
; WINDOW, RETAIN=2, XSIZE=800, YSIZE=512, /FREE, /PIXMAP
  TITLE4PLOT = 'RSN-' + ID + ': 1- and 2-week Average Tilt Rates Since June 2015'
  PLOT_RATES, LRTIME, LRATE*365, SRATE[7:*]*365, ID,  $  ; for the 1- & 2-week rates.
              TITLE=TITLE4PLOT                           ; Input: Title for the Figure.
;
  IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN  ; Pixmap option was used.
;    Graphic file name:  'MJ03F/MJ03F-RTM-Since2015.png'  for example
     TITLE4PLOT =   ID + '/' + ID + '-RTM-Since2015.png'  ; Graphic Output file name.
     WRITE_PNG, TITLE4PLOT, TVRD(/TRUE)
     PRINT,     TITLE4PLOT + ' generated.'
;    WDELETE,   !D.WINDOW  ; Remove the pixmap window.
  ENDIF  ; Save the displayed figure.
;
; Open up another window for the next plot.
;
  IF DISPLAY_PLOT2SCREEN THEN  BEGIN
     WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
;    PRINT, 'Plotting Window: ', !D.WINDOW
  ENDIF   ; Open another window.
; WINDOW, RETAIN=2, XSIZE=800, YSIZE=256, /FREE, /PIXMAP
  TITLE4PLOT = 'RSN-' + ID + ': 1- and 2-week Average Tilt Rates over last 12 Months'
             N = N_ELEMENTS( LRTIME )
  D = LRTIME[N-1] - 365  ; Get the date from 1 year ago.
  M = ( ( N - 365 ) LT 0 ) ? 0 : ( N - 365 )
  S = WHERE( LRTIME[M:N-1] GE D )  ; Locate the index 12 month from now.
  S = S[0] + M
  PRINT, FORMAT='(C())', LRTIME[S], SRTIME[S+7], LRTIME[N-1]  ; For checking.
  PLOT_RATES, LRTIME[S:*], LRATE[S  :*]*365,       $ ; For the last 12 months.
                           SRATE[S+7:*]*365,  ID,  $ ;  of the 1- & 2-week rates.
              TITLE=TITLE4PLOT                       ; Input: Title for the Figure.  5/22/2018
;             TITLE=TITLE4PLOT, YRANGE=[-500,500]    ; Input: Title for the Figure.
;
  IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN  ; Pixmap option was used.
;    Graphic file name:  'MJ03F/MJ03F-RTM-12MO.png'  for example
     TITLE4PLOT =   ID + '/' + ID + '-RTM-12MO.png'  ; Graphic Output file name.
     WRITE_PNG, TITLE4PLOT, TVRD(/TRUE)
     PRINT,     TITLE4PLOT + ' generated.'
  ENDIF  ; Save the displayed figure.
;
; Open up another window for the next plot.
;
  IF DISPLAY_PLOT2SCREEN THEN  BEGIN
     WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
;    PRINT, 'Plotting Window: ', !D.WINDOW
  ENDIF   ; Open another window.
;
; Display last set of the Short-/Long-Term 1-Day means on top
; of the Relevelling corrected RTM.
; Note that the input parameter: [ 7,14] below means the 1-week & 2-week in terms of days.  
;
; S = JUNE15TH2015  ; where TIME[S] = June 15th, 2015
;
; S = WHERE( TIME GE JULDAY( 6, 15, 2015, 0,0,0 ) )
; S = ( S[0] LT 0 ) ? 0 : S[0]  ; Index for TIME[S] = June 15th, 2015.
; PRINT, FORMAT='(C())', TIME[S]  ; For checking.
; PLOT_LAST_NDAY_MEANS,  TIME[S:*],RTM1DAY[S:*], T,RTM, [7,14], ID
;
; The 4 steps above are not needed.  The step below will do the work.
;
  PLOT_LAST_NDAY_MEANS,  TIME,RTM1DAY, T,RTM, [7,14], ID
;
  IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN  ; Pixmap option was used.
;    Graphic file name:  'MJ03F/MJ03F-RTM1WkRate.png'  for example
     TITLE4PLOT =   ID + '/' + ID + '-RTM1WkRate.png'  ; Graphic Output file name.
     WRITE_PNG, TITLE4PLOT, TVRD(/TRUE)
     PRINT,     TITLE4PLOT + ' generated.'
          M = !D.WINDOW
     WDELETE, !D.WINDOW  ; Remove the PIXMAP window.
     PRINT, 'Removed PIXMAP Window: ', M
  ENDIF  ; Save the displayed figure.
;
RETURN
END  ; DISPLAY_RATES
;
; This procedure is required before running the procedure: APPLY_OFFSETS.
; This procedure will generate the array paramters: DRT and OFFSET.  They
; will be used in the procedure: APPLY_OFFSETS for correcting the
; relevelling offsets.
;
; Callers: Users.
; Revised: October   18th, 2017
;
PRO GET_OFFSETS,  RLT,  $ ;  Input: 2-D array of the Releveling Time Periods.
                 TIME,  $ ;  Input: 1-D array of the JULDAY() values.
                 TILT,  $ ;  Input: 1-D array of either X-/Y-Tilt or Resultant Magnitudes.
                  DRT,  $ ; Output: 2-D array of the Indexes for the data range.
               OFFSET     ; Output: 1-D arrays of the Offset values.
;
  S =       SIZE( RLT  )  ; Get the size and information of RLT.
  M = N_ELEMENTS( TIME )
  N = 0  ; Initialize before used.
;
  IF S[0] EQ 0 THEN  BEGIN  ; RLT could be Undefined or Not a 2-D array.
     PRINT, 'The 1st parameter (RLT) is either Undefined or Not a 2-D array.'
     PRINT, 'No offset Adjustment is made.  Return to caller.'
     OFFSET = -1
     RETURN   ; to caller.
  ENDIF  ELSE  BEGIN  ; RLT will be either an 1-D or 2-D array.
     S   = SIZE( RLT )
     IF S[0] EQ 1 THEN  BEGIN
        N = 1
     ENDIF  ELSE  BEGIN  ; S[0] > 1  Assume the RLT is a 2-D array.
        N   = S[2]
     ENDELSE  ; Defining the 2nd dimension of the DRT.
     DRT = LONARR( 2, N+1 )
  ENDELSE   ; Checking RLT
;
; RLT is a 2xN array where RLT[0,i] & RLT[1,i] contain the Start & End times
; (in JULDAY()s) of the Releveling Period respectively.
;
;
  PRINT, 'The Releveling Time Ranges are: '
  PRINT, FORMAT="( C(), ' <--> ', C() )", RLT  ; Show the Times for checking. 
  PRINT, STRTRIM( N, 2 ) + ' of them.'
  HELP, NAME='*'
;
; Get the OFFSETS.
;
  OFFSET   = FLTARR( N )  ; for storing the Offset at each releveling.
  DRT[0,0] = 0            ; Data Index for the TIME[0].
;
  FOR S = 0, N-1 DO  BEGIN
;     Determine the beginnng & ending of the releveling time.
      K = WHERE( TIME GT RLT[0,S] )   ; Before releveling.
      I = K[0] - 1  ; for RLT[0,S] <= TIME[I].
      K = WHERE( TIME GT RLT[1,S] )   ; After  releveling.
      J = K[0]      ; for TIME[I] < RLT[1,S] < TIME[J].
;     Determine the Offset value for TILT
      OFFSET[S]   = TILT[I] - TILT[J]
;     Save the Data Indexes of the Ending of the current data segment & the Beginning next data. 
       DRT[1,S]   = I  ; Data Index just before the releveling.  Ending of data segment. 
       DRT[0,S+1] = J  ; Data Index just after  the releveling.  Beginning of the next data range.
      HELP, S, I, J, K, OFFSET[S]
  ENDFOR  ; S  Getting OFFSETS
;
  DRT[1,S] = M - 1         ; Data Index for the last element in the array: TIME.
;
RETURN
END  ; GET_OFFSETS
;
; This procedure will compute the new Releveling Corrected X & Y Lili Tilts values
; and append them into the arrays in the file: MJ03[B/D/E/F]/MJ03[B/D/E/F]-LilyRates.idl'.
;
; Tested on September 10th, 2018
;
; Callers: Users.
; Revised: September 10th, 2018
;
PRO GET_RELEVELING_TILTS,  ID,  $ ; RSN Station ID: 'MJ03D' to 'MJ03F' for example.
               LILY_TILT_FILE,  $ ; IDL save file name: 'MJ03F/MJ03F-LILY.idl'      e.g.
               LILY_RATE_FILE,  $ ; IDL save file name: 'MJ03F/MJ03F-LilyRates.idl' e.g.
               STATUS             ; Output: 0=No adata added and  1=New data added.
;
  T0 =   SYSTIME( 1 )  ; Mark the time.
;
; Get the newly updated LILY_[X/Y]TILT and time data from the LILY_TILT_FILE.
; (1) Note that arrays: LILY_[RTD/RTM/TEMP] are not being used here.
;     so that ther will be free for saving memory.
;
  RESTORE, LILY_TILT_FILE  ; Get arrays: LILY_[TIME/XTILT/YTILT]  (1)
;
  LILY_RTD  = 0  ; Free
  LILY_RTM  = 0  ; them before
  LILY_TEMP = 0  ; reusing them.
;
; Get the saved arrays of the computed tilt magnitude rates: ([L/S]RATE,[L/S]RTIME),
; (T,RTM), (TIME,RTM1DAY), (XTILT,YTILT) and [X/Y]OFFSET from the LILY_RATE_FILE
; plus an index variable: OFFSET-DATE.
;
  RESTORE, LILY_RATE_FILE  ; For example: 'MJ03D/MJ03D-LilyRates.idl'
;
  N = N_ELEMENTS( T )
  S = WHERE( LILY_TIME GE T[N-1], M )  ; (*)
;
; (*) Note that it is possible that the last time in LILY_TIME could be = to T[N-1].
;     In that case, the M will be = 1.  But still there are No New tilt values yet.  9/10/2018.
;
; IF ( M LT 1 ) THEN  BEGIN  ; No New tilt values yet.
  IF ( M LT 2 ) THEN  BEGIN  ; No New tilt values yet.  9/10/2018.
     PRINT, 'From: GET_RELEVELING_TILTS, No New tilt values available and No update.'
     STATUS = 0  ; No update for the LILY_TILT_FILE.
  ENDIF  ELSE  BEGIN        ; New tilt values are available.
;
;    Apply the releveling adjustments to the X & Y tilts.
;
     S  = S[0] + 1                   ; For T[N-1] < LILY_TIME[S].
     X  = TOTAL( XOFFSET )
     Y  = TOTAL( YOFFSET )
     X += LILY_XTILT[S:*]            ; Releveling
     Y += LILY_YTILT[S:*]            ; adjustments
;
;    Compute the new additional tilt magnitudes from the releveled X & Y tilt values
;    where both X & Y tilt will be offset by the X & Y tilt values on June 15th,2015
;    for MJ03[D/E/F] and September 2nd, 2017 for the MJ03B.
;
     LILY_RTM = SQRT( ( X - XTILT[OFFSET_DATE] )^2 + ( Y - YTILT[OFFSET_DATE] )^2 ) 
;
;    Note that OFFSET_DATE is an index for arrat T stored in LILY_RATE_FILE.
;    For example,  OFFSET_DATE  = 22367312 in the MJ03F data
;            and T[OFFSET_DATE] = JULDAY( 5,15,2015, 0,0,0 )
;
;  STOP  ; Check point 1) OK.  December 6th & 11th, 2017
;
;    Append the new values.
;
     XTILT = [ TEMPORARY( XTILT ), TEMPORARY( X ) ]
     YTILT = [ TEMPORARY( YTILT ), TEMPORARY( Y ) ]
     RTM   = [ TEMPORARY(  RTM  ), LILY_RTM ]
      T    = [ TEMPORARY(   T   ), LILY_TIME[S:*] ]
;
;    Compute the new additional of the 1-Day Mean values to be appended into RTM1DAY.
;
     N = N_ELEMENTS( TIME )      ; Total Time elements in RTM1DAY.
     CALDAT, TIME[N-1], M,D,Y    ; Get the Month, Day & Year only from the last date in TIME[N-1].
     D = JULDAY( M,D,Y, 0,0,0 )  ; Get the date & time at the beginning of day.
     S = WHERE( T GE D )         ; Look for the start date & time in T for RTM.
     S = S[0]                    ; For T[S] >= JULDAY( M,D,Y, 0,0,0 ).
;
;  STOP  ; Check point 2) OK.  December 6th & 11th, 2017
;
;    If a new date is available, compute the 1-Day Means and
;    the new Short-Term and Long-Term Rate of Change values

     IF S GE 0 THEN  BEGIN  ; Located the new date.
;
        N_RTM = N_ELEMENTS( T )            ; The new total length of T & RTM.
        GET1DAY_MEANS,                   $
          T[S:N_RTM-1], RTM[S:N_RTM-1],  $ ;  Inputs: array of JULDAY()s & magnitudes.
          TM,     M      ; Outputs: 1-D arrays of JULDAY()s & the 1-Day Means of DATA.
;
; STOP  ; Check point 3) OK.  December 6th & 11th, 2017
;
;       Append the new 1-Day Mean.
;       Note that the last values in TIME & RTM1DAY are skipped; because,
;       they are recomputed, i.e. (TM[0],M[0]) = (TIME[N-1],RTM1DAY[N-1]) respectively.
;
 ;      TIME    = [    TIME[0:N-2], TEMPORARY( TM ) ]
 ;      RTM1DAY = [ RTM1DAY[0:N-2], TEMPORARY(  M ) ]
        TIME    = [    TIME[0:N-2],            TM   ]
        RTM1DAY = [ RTM1DAY[0:N-2],             M   ]
;
; STOP  ; Check point 4) OK.  December 11th, 2017
;
;       Compute the new additional Short-Term (1-week)  and Long-Term Rate (2-week)
;       of Change values using the new 1-Day Mean values obtained above.
;
        GET_RATES, TIME, RTM1DAY,  $ ; Input arrays: Time & 1-Day Mean.
                       7,  $ ; Use 1-week (7 days) for the short-term rate.
                   N - 1,  $ ; Starting point for getting the new rates.
                   S,  X     ; Output arrays: Time & the short-term rate.
        GET_RATES, TIME, RTM1DAY,  $ ; Input arrays: Time & 1-Day Mean.
                      14,  $ ; use -week=14 days for the  long-term rate.
                   N - 1,  $ ; Starting point for getting the new rates.
                   D,  Y     ; Output arrays: Time & the  long-term rate.
;
;       Append the new RATEs.  Make sure that the last data point's [S/L]RTIME
;       and the 1st data point's time: S[0]/D[0] from the new rate are different.
;       If they are the same the last data points from the [S/L]RTIME and
;       [S/L]RATE will be discarded.
;
; STOP  ; Check point 5) OK.  December 11th, 2017
;
                       M = N_ELEMENTS( SRTIME )
        IF ABS( SRTIME[M-1] - S[0] ) LT 0.0001 THEN  BEGIN  ; SRTIME[M-1] == S[0]
           SRTIME = [       SRTIME[0:M-2], TEMPORARY( S ) ] ; Append new rates
           SRATE  = [        SRATE[0:M-2], TEMPORARY( X ) ] ; w/o the last point in SRTIME.
        ENDIF  ELSE  BEGIN  ; Assuming SRTIME[M-1] < S[0]
           SRTIME = [ TEMPORARY( SRTIME ), TEMPORARY( S ) ] ; Append the new rates
           SRATE  = [ TEMPORARY( SRATE  ), TEMPORARY( X ) ] ; with all data.
        ENDELSE
                       M = N_ELEMENTS( LRTIME )
        IF ABS( LRTIME[M-1] - D[0] ) LT 0.0001 THEN  BEGIN  ; LRTIME[M-1] == D[0]
           LRTIME = [       LRTIME[0:M-2], TEMPORARY( D ) ] ; Append new rates
           LRATE  = [        LRATE[0:M-2], TEMPORARY( Y ) ] ; w/o the last point in SRTIME.
        ENDIF  ELSE  BEGIN  ; Assuming SRTIME[M-1] < D[0]
           LRTIME = [ TEMPORARY( LRTIME ), TEMPORARY( D ) ] ; Append the new rates
           LRATE  = [ TEMPORARY( LRATE  ), TEMPORARY( Y ) ] ; with all data.
        ENDELSE
;
     ENDIF  ; Getting the 1-Day Mean values.
;
     STATUS = 1  ; NEW values added.
;
  ENDELSE ; Getting the new tilt values.
;
; Save the updated array variables: ([L/S]RATE,[L/S]RTIME), (T,RTM), (TIME,RTM1DAY)
; and [X/Y]OFFSET back to the LILY_RATE_FILE plus an index variable: OFFSET_DATE.
;
  IF STATUS THEN  BEGIN  ; Update the arrays in the LILY_RATE_FILE.
     SAVE, FILE=LILY_RATE_FILE, LRTIME,LRATE, SRTIME,SRATE, T,RTM, TIME,RTM1DAY,  $
                                 XTILT,YTILT, XOFFSET,YOFFSET,     OFFSET_DATE
     PRINT, 'From: GET_RELEVELING_TILTS, File: ' + LILY_RATE_FILE + ' is updated.'
  ENDIF  ; Updating the LILY_RATE_FILE. 
;
  N =    SYSTIME( 1 ) - T0  ; Total seconds used.
  S =    STRTRIM( N, 2 )
  PRINT, SYSTIME() + ' Total seconds used: ' + S + ' in GET_RELEVELING_TILTS.'
;
RETURN
END  ; GET_RELEVELING_TILTS
;
; Callers: GET_TD and Users.
; Revised: September 9th, 2015
;
PRO GET_TILT_DIFFERENCES, N_DAYS,  $  ;  Input: Number of days for the data length.
             TIME,  XTILT, YTILT,  $  ;  Input: 1-D arrays of the same size.
             TM,    XTDF,  YTDF,   $  ; Output: 1-D arrays of Time & Tilt Differences.
        ADD_FRONT=ADD_FRONT_DATA,  $ ; For adding additional Output to the TM, XTDF & YTDF.
        TIME_INTERVAL=TIME_STEP      ; in seconds for data interval in TIME.
;
; Note the if the Keyword: ADD_DATA_FRONT is Not set, there the 1st N_DAYS
; of the times will be missing from the Tilt Differences results, see below:
;              |<--------------Data  Range-------------->|
;             t0             t14       t(n-14)         t(n-1)  where t = time index.
; Data Range = |<-- N_DAYS -->|-----------|<-- N_DAYS -->| = data range to be processed.
;              |<------Data Range B------>|
;             t0              |<------Data Range A------>|
;                            t14                       t(n-1)  where n = total data points.
;
; When (Data Range A) - (Data Range B) for the Tilt Differences,
; the time range of the Data Range B from t14 to t(n-1) will be used
; and there will be No data for the times of the 1st N_DAYS from t0 to t14.
;
; When the Keyword: ADD_DATA_FRONT is set, the data range between t1 to t13
; will be added by computing the Tilt Differences as:
; X1-X0, X2-X0, X3-X0, ..., X13-X0 and same for the Y's.
;
IF KEYWORD_SET( ADD_FRONT_DATA ) THEN  BEGIN
   ADD_FRONT_DATA = BYTE( 1 )  ; Yes.
ENDIF  ELSE  BEGIN
   ADD_FRONT_DATA = BYTE( 0 )  ; No.
ENDELSE
;
IF NOT KEYWORD_SET( TIME_STEP ) THEN  BEGIN  ; September 9th, 2015
   TIME_STEP = 1  ; second.  To be used for calling GET_TILT_DIFFERENCES.
ENDIF
;
; TIME        = 1-D arrays in Julian Days.
; XTILT,YTILT = 1-D arrays in Degrees.
; TIME, XTILT  and YTILT are assummed to be the same size.
;
; Get Total number of data points in the arrays: TIME, XTILT & YTILT.
;
  M = N_ELEMENTS( TIME )  ; = N_ELEMENTS( XTILT ) = N_ELEMENTS( YTILT )
;
; Determine how the 2 data sets will be selected.
;
IF N_DAYS EQ 0 THEN  BEGIN
   PRINT, 'Number of Data to be offset is 0!  No Results will be provided!'
   RETURN  ; to Caller.
ENDIF  ELSE  IF N_DAYS GT 0 THEN  BEGIN
;
; Locate the array index of the time N_DAYS ago, e.g. 7 Days.
; Note that the function: LOCATE_TIME_POSITION() is in the
; File: ~/4Chadwick/RSN/SplitRSNdata.pro
;
  N = M - 1  ; The End   Index of the selected time.
; I = LOCATE_TIME_POSITION( TIME,   ( TIME[N] - N_DAYS ) )
  I =                WHERE( TIME GT ( TIME[N] - N_DAYS ) )
  S = I[0]   ; The Start Index of the selected time.
; N = M - 1  ; The End   Index of the selected time.
;
; Locate the array index of the time 2 x N_DAYS ago, e.g. 14 Days.
; To locate that, Start from the last N_DAYS ago and
; Move back for another N_DAYS.
;
  E = S - 1  ; = I[0] - 1  ; Start from the last N_DAYS ago.
  I =                WHERE( TIME GT ( TIME[E] - N_DAYS ) )
  B = I[0]   ; The Start Index of the selected time.
; E = S - 1  ; The End   Index of the selected time.
;
ENDIF  ELSE  BEGIN  ; N_DAYS < 0.  All data will be used.
;
  N =  ABS( N_DAYS )  ; Set Number of days to positive.
;
; Locate the array index of the time: N Days before the
; very end of the TIME array and that index will be Start
; of the 2nd data set.
;
  I = WHERE( TIME GT ( TIME[M-1] - N ) )
  B =   0       ; The Start Index of the selected time.  2nd Set of
  E = I[0] - 1  ; The End   Index of the selected time.  Data Range: B
;
; Locate the array index of the time: N Days after the very
; beginning of TIME[0] and that index will be Start Index
; of the 1st data set.
;
  I =   0       ; Free it before reusing it.
  I = WHERE( TIME GT ( TIME[0] + N ) )
  S = I[0] - 1  ; The Start Index of the selected time.  1st Set of
  N = M    - 1  ; The End   Index of the selected time.  Data Range: A
;
ENDELSE
;
; Save the Selected Tilt Data range: A.
;
  X1 = XTILT[S:N]
  Y1 = YTILT[S:N]
  N1 = N - S + 1             ; = N_ELEMENTS( X1 ).
  N1 = N1*LONG( TIME_STEP )  ; into seconds.
;
  PRINT, 'The 1st Data Set Range: (The Last ' + STRTRIM( N_DAYS, 2 ) + ' Days)'
  PRINT, FORMAT='(C(),A,C())', TIME[S], ' to ', TIME[N]
;
; Save the Selected Tilt Data range: B.
;
  X2 = XTILT[B:E]
  Y2 = YTILT[B:E]
  N2 = E - B + 1             ; = N_ELEMENTS( Y2 ).
  N2 = N2*LONG( TIME_STEP )  ; into seconds.
;
  PRINT, 'The 2nd Data Range (Another ' + STRTRIM( N_DAYS, 2 )  $
       + ' Days Before the 1st data set):'
  PRINT, FORMAT='(C(),A,C())', TIME[B], ' to ', TIME[E]
;
; Check for data gaps.
;
  T = ( N_DAYS GT 0 ) ? N_DAYS : ( TIME[N] - TIME[0] - ABS( N_DAYS ) )
  M = T * ULONG( 86400 )  ; Total days in seconds
  D = ( M - N2 ) + ( M - N1 )
;
; STOP
;
; Interpolate the Tilt data so that all the gaps in between will be fill in.
;
  IF ABS( D ) GT 0 THEN  BEGIN  ; There are gaps in the Tilt data.
     PRINT, 'Gaps in the data.  Interpolating them...'
;    T    = DINDGEN( M )  ; Replaced by the next 2 statements.
     M    = DOUBLE(  M )/DOUBLE( TIME_STEP )    ; Total number of the time intervals
     T    = DINDGEN( M )*DOUBLE( TIME_STEP )    ; Array of seconds in an incremental step.
     D    = ( TIME[S:N] - TIME[S] )*86400.0D0  ; into seconds.
     XTDF =  INTERPOL( X1, D, T )
     YTDF =  INTERPOL( Y1, D, T )
     D    = ( TIME[S] + T[M-1]/86400.0D0 - TIME[N] )*86400.0D0  ; in seconds.
     IF D LE 2 THEN  BEGIN
        X1 = TEMPORARY( XTDF )
        Y1 = TEMPORARY( YTDF )
     ENDIF  ELSE  BEGIN  ; | D | > 2 seconds.
;       The TIME[N] is < the TIME[S] + T[M-1]/86400.
;       Look for the Time Index: TIME[N] in T.
        I  = WHERE( T GT ( TIME[N] - TIME[S] )*86400.0D0 )
        X1 = XTDF[0:I[0]-1]  ; Save only the interpolated
        Y1 = YTDF[0:I[0]-1]  ; data points up to TIME[N].
     ENDELSE
     D    = ( TIME[B:E] - TIME[B] )*86400.0D0  ; into seconds.
     XTDF =  INTERPOL( X2, D, T )
     YTDF =  INTERPOL( Y2, D, T )
     D    = ( TIME[B] + T[M-1]/86400.0D0 - TIME[E] )*86400.0D0  ; in seconds.
     IF D LE 2 THEN  BEGIN
        X2 = TEMPORARY( XTDF )
        Y2 = TEMPORARY( YTDF )
     ENDIF  ELSE  BEGIN  ; | D | > 2 seconds.
;       The TIME[E] is < the TIME[B] + T[M-1]/86400.
;       Look for the Time Index: TIME[N] in T.
        I  = WHERE( T GT ( TIME[E] - TIME[B] )*86400.0D0 )
        X2 = XTDF[0:I[0]-1]  ; Save only the interpolated
        Y2 = YTDF[0:I[0]-1]  ; data points up to TIME[N].
     ENDELSE
  ENDIF  ; Interpolate the Tilt data.
;
  N1  = N_ELEMENTS( X1 )  ; = N_ELEMENTS( Y1 )
  N2  = N_ELEMENTS( X2 )  ; = N_ELEMENTS( Y2 )
;
; Adjust the either the arrays (X1,Y1) or (X2,Y2)
; so that they will be the same size.  June 24th, 2015.
;
  IF N1 GT N2 THEN  BEGIN
     X1 = X1[0:N2-1]
     Y1 = Y1[0:N2-1]
     N1 = N2
  ENDIF ELSE IF N2 GT N1 THEN  BEGIN
     X2 = X2[0:N1-1]
     Y2 = Y2[0:N1-1]
     N2 = N1
  ENDIF
;
; Compute the Tilt Differences.  Data Range A - B.
;
  XTDF = X1 - X2
  YTDF = Y1 - Y2
;
; STOP
;
; Add on the Front Data if it is asked for.
;
IF ADD_FRONT_DATA THEN  BEGIN  ; Get Tilt Difference between [B:S-1]
;  Need the data ranges of X2[0:I] & Y2[0:I] where I = N_DAYS after.
   IF N_DAYS GT 0 THEN  BEGIN  ; X2 & Y2 are N_DAYS long.
      I = N2 - 1
;     No Additional times are needed.
   ENDIF  ELSE  BEGIN  ; N_DAYS < 0.
;     Get the time index that X2[I] is the Greatest Lower Bound of X1[0].
      I = ABS( N_DAYS )*ULONG( 86400 ) - 1  ; Total days in seconds - 1
      I = ROUND( I/DOUBLE( TIME_STEP ) )
;     Add the Front Data with a fix point offset as the Tilt Differences 
      XTDF = [ X2[1:I] - X2[0], TEMPORARY( XTDF ) ]  ; The X2[0] & Y2[0] are
      YTDF = [ Y2[1:I] - Y2[0], TEMPORARY( YTDF ) ]  ; the fix points offsets.
   ENDELSE
ENDIF  ; Add the Front Data.
;
  N1 = N_ELEMENTS( XTDF )  ; = N_ELEMENTS( YTDF )
;
; STOP
;
; Define the Time Indexes of the Last N_DAYS in JULDAY()'s values.
;
  IF N_DAYS LT 0 THEN  BEGIN
;    TM = ( TIMEGEN( M, START=TIME[0], STEP=1, UNIT='SECOND' ) )  ;  Forward-Most  Time
     IF ADD_FRONT_DATA THEN  BEGIN
         M = ( TIME[N] - TIME[0] )*ULONG( 86400 )  ; Total days in seconds
         M = ROUND( M/DOUBLE( TIME_STEP ) )
         IF M GT N1 THEN  M = N1
         S =  1
     ENDIF  ELSE  BEGIN
         M = N1
     ENDELSE
     TM = ( TIMEGEN( M, START=TIME[S], STEP=TIME_STEP, UNIT='SECOND' ) )  ; Backward-Most Range
  ENDIF  ELSE  BEGIN
     M  = N_ELEMENTS( TIME )  ;
;    D  = TIME[E] - N_DAYS  ; Start Time of 2 x N_DAYS ago.
;    TM = ( TIMEGEN( M+1, START=D, STEP=1, UNIT='SECOND' ) )[1:M]  ;  Forward-Most  Time
;    IF ADD_FRONT_DATA THEN  BEGIN
;        D = TIME[E] - N_DAYS  ; Start Time of 2 x N_DAYS ago.
;        M = M + M
;        I = 2
;    ENDIF  ELSE  BEGIN
         M = N2
         D = TIME[N] - N_DAYS  ; Start Time of N_DAYS ago.
         I = 0
;        I = 1
;    ENDELSE
     TM = ( TIMEGEN( M+I, START=D, STEP=TIME_STEP, UNIT='SECOND' ) )  ; Backward-Most  Range
  ENDELSE  ; Create Time index: TM.
;
; STOP
;
RETURN
END  ; GET_TILT_DIFFERENCES
;
; This procedure will compute a linear fit to the (TIME[i:i+n],DATA[i:i+n])
; for i = n, n+1, ..., m = total data points in DATA and n = number of days
; provided by the callers.
;
; Note that this procedure assumes the TIME is a ascending order and the
; data gaps will ne great than the value of n/2; otherwise, this procedure
; will not compute some of the RATEs correctly.
;
; Note that this procedure is used for computing the rates from the newly
; available data whereas the procedure: GET_RATES_ALL will compute all
; rates from the beginning to the end of the given (TIME,DATA) 
;
; Callers: GET_RELEVELING_TILTS and Users.
; Revised: December 11th, 2017
;
PRO GET_RATES, TIME,  $ ;  Input : 1-D array of JULDAY()s.
               DATA,  $ ;  Input : 1-D array of Data, e.g., 1-Day means of Resultant Magnitudes.
         TIME_RANGE,  $ ;  Input : in Days.
                  S,  $ ;  Input : Starting index for getting the rates from TIME[S] on.
         T,   RATE      ; Outputs: 1-D arrays of JULDAY()s & Rate Change values
;
; This procedure will compute the magnitude change rates from
; TIME[S], TIME[S+1], ..., TIME[N] where N = last points in TIME.  
;
; Find out total number of the new days in TIME[S:N]
;
  N      = N_ELEMENTS( TIME )  ; Also = N_ELEMENTS( DATA )
  N_DAYS = FLOOR( TIME[N-1] - TIME[S] ) + 1
;
; Locate the starting position: I for (TIME[I],DATA[I]) for getting the
; the 1st rate point at TIME[S].  For example, TIME_RANGE = 7 days.
; Then TIME[I] will be 7 days before the TIME[S] and (TIME[I:S],DATA[I:S])
; will be used for computing the rate at TIME[S] and the results will be
; stored into (T[0],RATE[0]) 
;
; Note that the following 4 lones of codes are asumming the dates in
; TIME are daily.
;
     I = ( S - 1 ) - 7   ; Back 7 days for TIME index.
  IF I LT 0 THEN  BEGIN  ; Not enough days in TIME
     I = 0               ; Use the day at the beginning.
  ENDIF  ; Checking starting position: I
;
; Now use the (TIME[I:N-1],DATA[I:N-1]) to compute the rates for TIME[S:N-1]
; and Save ther results into (T=TIME[S:N-1],RATE).
;
  T    = TIME[S:N-1]  ; Save the times for the new rates that will be computed below.
  M    =      N - S   ; Total elements in T.
  RATE = DBLARR( M )  ; for storing the Change Rate values for each T[i].
;
  FOR J = S, N-1 DO  BEGIN  ; Compute each RATE.
      X = 0
      Y = 0  ; Reset the temporary variables
      M = 0  ; before reusing them.
      D = 0
      CALDAT, TIME[J],  M, D, Y       ; Get the current Month, Day & Year from TIME[J].
      D = JULDAY( M, D, Y, 00, 00, 00 ) - TIME_RANGE  ; Move the date back, e.g. 7 days.
;     Get the index: K so that the TIME[K:J] should be about 7 days for example.
      K = ( J GT TIME_RANGE ) ? ( J - TIME_RANGE ) : 0  ; K = 0 if J - TIME_RANGE < 0.
;     Look for the index: M so that TIME[M] to TIME[J] will be 7 days for example.
;     The following search is needed in case that is a gap in the range: TIME[K:J].
      M = WHERE( TIME[K:J] GE D )   ; Look for the time: D = TIME[J] - TIME_RANGE.
      M = ( M[0] LT 0 ) ? 0 : M[0]  ; Use only the M[0] value.  Use 0 if time: D is not found.
      M =   M + K       ; Add back the offset so that TIME[M] will point to the correct place.
;     Fit a line to the data set: (TIME[M:J],DATA[M:J]) 
      X = TIME[M:J] - TIME[M]  ; Time in Days.  Note that -TIME[M] just an offset.
      Y = DATA[M:J]            ; 1-Day Averaged
      R = LINFIT( X, Y )       ; A Linear least-square fit method where R=[A,B] as y=A+B*X.
;     T = TIME[J-S]
      RATE[J-S] = R[1]         ; Save the Slop:B as the Change/Day.
  ENDFOR  ; J: Computing RATE
;
RETURN
END  ; GET_RATES
;
; This procedure will compute a linear fit to the (TIME[i:i+n],DATA[i:i+n])
; for i = n, n+1, ..., m = total data points in DATA and n = number of days
; provided by the callers.
;
; Note that this procedure assumes the TIME is a ascending order and the
; data gaps will ne great than the value of n/2; otherwise, this procedure
; will not compute some of the RATEs correctly.
;
; Callers: Users.
; Revised: November 29th, 2017 and Tested OK on October   25th, 2017.
;
PRO GET_RATES_ALL, TIME,  $ ;  Input : 1-D array of JULDAY()s.
              DATA,  $ ;  Input : 1-D array of Data, e.g., 1-Day means of Resultant Magnitudes.
        TIME_RANGE,  $ ;  Input : in Days.
        T,   RATE      ; Outputs: 1-D arrays of JULDAY()s & Rate Change values
;                                   computed from (TIME,DATA).
;
; Note that it is assume that TIMEs are in unit of days and DATA units are Value/Day.
;
  N = N_ELEMENTS( TIME )  ; Also assuming M = N_ELEMENTS( DATA )
;
  IF N LE TIME_RANGE THEN  BEGIN  ; Not enough DATA to compute the RATE.
     PRINT, 'Only ' + STRTRIM( N, 2 ), ' data points.'
     PRINT, 'Need at least ' + STRTRIM( TIME_RANGE, 2 ) + ' data points.'
     RATE = [-1]  ; No Rate changes are computed.
  ENDIF  ELSE  BEGIN
;    Locate the starting point: TIME[J] where TIME[0:J] = TIME_RANGE.
     I = LONG( 0 ) ;
     J = WHERE( TIME GT ( TIME[0] + TIME_RANGE - 1 ) )
     J = J[0] - 1  ; The start point where TIME[0:J] will equal to the TIME_RANGE.
        DAYS = TIME[J] - TIME[0] + 1
     IF DAYS LT TIME_RANGE THEN  BEGIN  ; There is a gap in between TIME[I] & TIME[J]
;       Since all elements in TIME are in order, therefore, TIME[J] < (TIME[0]+TIME_RANGE-1)
        J += 1  ; Move to the next TIME element.
     ENDIF  ; Adjusting J.
     M =    N - J  ; Total elements for the output arrays: T and RATE.
     S = LONG( 0 ) ; for entering in the WHILE loo below.
     T    = TIME[J:N-1]
     RATE = DBLARR( M )
     FOR S = 0, M-1 DO  BEGIN
         K = WHERE( TIME[I:J] GT ( TIME[J] - TIME_RANGE ) )
;        HELP, I, J, K, S, TIME_RANGE
;        PRINT, FORMAT='(C())', TIME[[I,I+K[0],J]]
;        PRINT, 'K[0],  I = ', K[0],  I
         I = K[0] + I
         IF (  TIME[J] - TIME[I] + 1 ) GT TIME_RANGE THEN  STOP
         X = TIME[I:J] - TIME[I]
         Y = DATA[I:J]
         R       = LINFIT( X, Y )  ; where R = [A,B] as y = A + B*X.
         RATE[S] = R[1]            ; Save the Slop: B which is the Rate of Change.
            T[S] = TIME[J]         ; Save the TIME for the RATE[S].
;        HELP, X
;        PRINT, 'Fitted Results: ', R
;        Locate the next TIME range for the DATA.
;        S += 1  ; Move to the next TIME index.
         J += 1
     ENDFOR  ; Computing the RATE.
  ENDELSE  ; Getting the arrays" T and RATE.
;
RETURN  ; GET_RATES_ALL
END
;
; This procedure will compute the 1-Day means from the provide TIME & DATA arrays
; where the DATA values can be any RSN values such as Resultant Magnitudes,
; Pressure or Temperature.
;
; The purpose for this routine is for computing the 1-Day means of the
; relevelling corrected Resultant Magnitudes.
;
; Callers: Users.
; Revised: October   31st, 2017 & Tested OK.
;
PRO GET1DAY_MEANS,  TIME,  $ ;  Input : 1-D array  of JULDAY()s.
                    DATA,  $ ;  Input : 1-D array  of RSN data, e.g., LILY_RTM
                T, M1DAY,  $ ; Outputs: 1-D arrays of JULDAY()s & the 1-Day Means of DATA.
    NEW_DAY=START_AT_NEW_DAY ; So that the T[0] will be the at a beginning of the day.
;
  PRINT, SYSTIME() + ' Computing 1-Day Means...'
;
  N = N_ELEMENTS( TIME )  ; Also assuming M = N_ELEMENTS( DATA )
;
; Locate the 1st index: I in TIME so that TIME[I] is at the beginning of the data.
;
  CALDAT, TIME[0], M, D, Y
  ETIME = JULDAY(  M, D, Y, 23, 59, 59 )  ; and the End time of the end of the day.
;
  IF TIME[N-1] LE ETIME THEN  BEGIN  ; There are >= 1-Day long DATA.
;    PRINT, 'There are >= 1-Day long DATA.'
     T     = TIME[0]
     M1DAY = MEAN( DATA, /DOUBLE )
  ENDIF  ELSE  BEGIN  ; DATA are more than 1-Day long.
     S = JULDAY( M, D, Y, 0,0,0 ) + 1  ; The next new day after TIME[0]
     CALDAT, TIME[N-1], M, D, Y
     D = JULDAY( M, D, Y, 0,0,0 )      ; The beginning of the last day of TIME[N-1].
;    ETIME   = JULDAY( M,D,Y,23,59,59 )
     MTIME   = S                       ; Save the next new dat after TIME[0].
     N_DAYS  = D - S                   ; Total days in TIME[1:N-1].
     N_DAYS += 1                       ; Add 1 day for TIME[0:1]
     N_DAYS += CEIL( TIME[N-1] - D )   ; Add 1 day for between the biginning of last day & TIME[N-1]
     T     = REPLICATE( 0.0D0, N_DAYS )
     M1DAY = REPLICATE( 0.0D0, N_DAYS )
     I     = 0                               ; The 1st Data point.
     J     = WHERE( TIME GT ETIME )          ; Locate the ETIME.
     J     = J[0] - 1                        ; So that TIME[J] <= ETIME.
           S  = 0
         T[S] = TIME[0]
     M1DAY[S] = MEAN( DATA[I:J], /DOUBLE )
       OFFSET = J + 1  ; TIME offset index.
     PRINT, S, I, J, M1DAY[S]
           S += 1  ; Move to the next position or day.
     WHILE MTIME  LT TIME[N-1] DO  BEGIN  ; Compute the reset of the 1-Day means
           CALDAT, MTIME,  M, D, Y
           STIME = JULDAY( M, D, Y, 00, 00, 00 )  ; Define the Start
           ETIME = JULDAY( M, D, Y, 23, 59, 59 )  ; and the End times.
;          Get the indexes: [I,J] so that TIME[I:J] will contain the 1-Day long.
           I = WHERE( TIME[OFFSET:N-1] GT STIME )  ; Locating the starting
           J = WHERE( TIME[OFFSET:N-1] GE ETIME )  ; and Ending indexes for DATA
           IF I[0] GE 0 THEN  BEGIN    ; Adjusting the starting index: I.
              K = OFFSET + I[0]
              IF TIME[K-1] LT STIME THEN  BEGIN  ; TIME[I[0]+OFFSET-1] < STIME < TIME[I[0]+OFFSET]
                 I =  K        ; So that  STIME <= TIME[I].
              ENDIF  ELSE  BEGIN  ; Assume TIME[I[0]+OFFSET-1] == STIME
                 I =  K - 1    ; So that  STIME  = TIME[I]. 
              ENDELSE
           ENDIF  ; Adjusting the starting index: I.
           IF J[0] LT 0 THEN  BEGIN    ; Adjusting the starting index: J.
              J = N - 1        ; J[0] = -1.   Assume TIME[J[N-1]] < ETIME.
           ENDIF  ELSE  BEGIN  ; TIME[J[0]+OFFSET] <= ETIME
              K = OFFSET + J[0]
              IF ABS( ETIME - TIME[K] ) LT 0.001 THEN  BEGIN
                 J =  K  ; Assuming ETIME == TIME[J[0]+OFFSET]
              ENDIF  ELSE  BEGIN  ; ETIME <  TIME[J[0]+OFFSET] 
                 J =  K - 1    ; So that TIME[J] < ETIME. 
              ENDELSE
           ENDELSE  ; Adjusting the starting index: J
              OFFSET =   J + 1    ; Adjust the TIME index to save time for searching.
              STATUS = ( I LE J ) AND ( I GT 0 )  ; Make sure the I & J are OK.
           IF STATUS EQ 1 THEN  BEGIN  ; Data range in [STIME,ETIME] are found.
                  T[S] = STIME
              M1DAY[S] = MEAN( DATA[I:J], /DOUBLE )
;             PRINT,   S, I, J, M1DAY[S]
                    S += 1  ; Move to the next position or day.
           ENDIF
           MTIME += 1  ; Move to the next day.
     ENDWHILE    ; S
     IF S LT N_DAYS THEN  BEGIN  ; Adjust the arrays sizes for T & M1DAY.
        PRINT, SYSTIME() + ' Adjusting the arrays: T & M1DAY...'
        K =      T[0:S-1]
        D =  M1DAY[0:S-1]
        T     = 0  ; Free them before
        M1DAY = 0  ; reusing them.
        T     = TEMPORARY( K )
        M1DAY = TEMPORARY( D )
     ENDIF  ; Adjust the arrays sizes for T & M1DAY.
  ENDELSE
;
  PRINT, SYSTIME() + ' 1-Day Means computed.'
;
RETURN
END  ; GET1DAY_MEANS
;
; This routine assume the 3 input arrays are the same length
; and the plotting window has ben opend by the callers.
;
; Callers: Users
; Revised: June 25th, 2020
;
; Tested OK on May     22nd, 2018
;
PRO PLOT_RATES,  TIME,  $ ; Input : 1-D array  of JULDAY() values.
         LRATE, SRATE,  $ ; Inputs: 1-D arrays of Rates' values
                   ID,  $ ; Input : 'MJ03B' or 'MJ03F' for example.
   _EXTRA=PLOT_SETTINGS
;
  N = N_ELEMENTS( TIME )  ; = N_ELEMENTS( LRATE or SRATE ).
;
; The following 2 procedures are in the file IDLcolors.pro
;
  SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
  X = TOTAL( TAG_NAMES( PLOT_SETTINGS ) EQ 'YRANGE' )  ; Look for tag name YRANGE
;
  IF X GT 0 THEN  BEGIN  ; PLOT_SETTINGS.YRANGE exist
     MX = PLOT_SETTINGS.YRANGE[1]
     MN = PLOT_SETTINGS.YRANGE[0]
  ENDIF  ELSE  BEGIN     ; PLOT_SETTINGS.YRANGE does not exit.
;    Locate all the finite numbers, i.e. skip all the NaN values.
     H  = WHERE( FINITE( SRATE ) )  ; June 25th, 2020.
;    Locate the Max & Min values for the Y-Plotting range for the SRATE.
;    Note that it is assume the SRATE's Max. & MIN. range arelarger that LRATE's.
     MX = STDEV( SRATE[H], MN )     ; MX = Standard Deviation & MN = Mean.
      X = MX * 4.0
     MX =  CEIL( MN + X )
     MN = FLOOR( MN - X )
      X = MAX( SRATE, MIN=H )         ; May 22nd, 2018
     HELP, MX, MN, X, H
     IF MX LT X THEN MX =  CEIL( X )  ; Adjusting the
     IF MN LT H THEN MN = FLOOR( H )  ; Y-Range for plotting.
     PRINT, ID + ': Max & Min of the All the Short-Term Rate are: ', MX, MN
  ENDELSE
; STOP
;
; Determine number of Hourly or Daily marks per day.
;
  N_DAYS = ROUND( TIME[N-1] - TIME[0] )  ; Data Range in days.
;
  RSN_GET_XTICK_UNITS, N_DAYS, XUNITS, H
;
; Where XUNITS will be returned as ['Hour','DAY'] or ['Day', 'DAY']
; and   H is the XTICKINTERVAL=H for either Hour or Day.
;
; Call LABEL_DATE() to ask for plotting Time Label.
;
  IF N_DAYS LE 10 THEN  BEGIN
     H = 1
  ENDIF ELSE IF N_DAYS LE 30 THEN  BEGIN
     H = 5
  ENDIF
;
  XUNITS[0]   = 'Day'  ; always use Day.
  TIME_RANGE  = LABEL_DATE( DATE_FORMAT=['%D','%N/%D/%Z'] )
;
  TIME_RANGE  = STRING( TIME[0]  ,  $  ; Date of the 1st data point.
                FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' ) + ' to '
  TIME_RANGE += STRING( TIME[N-1],  $  ; to the Last data point.
                FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
;
; TITLE4PLOT  = 'RSN-' + ID + ':  1- and 2-week Average Tilt Rates over last 12 Months'
;
; Define a plotting symbel: a dot when using PSYM=8.
;
  USERSYM, [-0.3,0.3],[0,0]
  X = FINDGEN( 16 )*!PI/8.0
  USERSYM, COS( X ), SIN( X ), /FILL  ;, THICK=2
;
; Define the Hardware Fonts to be used.
;   
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
;
 !P.FONT  = 0  ; Use the hardware font above.
 !X.THICK = 1
 !Y.THICK = 1  ; for thinker line drawing.
;
; Define the Rate values' area.
; 
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, TIME, SRATE, /NODATA,  $ ; /NOERASE,   $
        YSTYLE=1, YRANGE=[MN,MX], XMARGIN=[9,9], YMARGIN=[6,2],  $
        XSTYLE=1, XRANGE=[TIME[0]-1,TIME[N-1]+1],                $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'],                 $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, XTICKUNITS=XUNITS,   $
       _EXTRA=PLOT_SETTINGS
  XYOUTS, ALIGNMENT=1, /DEVICE, 45,  45, XUNITS[0] + ':'
; where XUNITS[0] = 'Hour:' or 'Day:'
  AXIS, YAXIS=1, YRANGE=[MN,MX], YSTYLE=1, CHARSIZE=1.15
;
; Plot the Short-Term & Long-Term average Rates of changes.
;
  OPLOT, TIME, SRATE, COLOR=C.BLUE , PSYM=8  ; Short-Term rates.
  OPLOT, TIME, LRATE, COLOR=C.GREEN, PSYM=8  ;  Long-Term rates.
;
   PLOTS, /NORMAL, 0.68, 0.02, COLOR=C.BLUE,  THICK=1, PSYM=8
  XYOUTS, /NORMAL, 0.69, 0.01, '1-week Rate'
   PLOTS, /NORMAL, 0.83, 0.02, COLOR=C.GREEN, THICK=1, PSYM=8
  XYOUTS, /NORMAL, 0.84, 0.01, '2-week Rate'
;
 !P.FONT  = -1  ; Back to graphic font.
;
; Label the Left & Right Y-Axes.
;
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, ORIENTATION=90,  $
          /NORMAL, 0.03, 0.45, '!7l!17radians/year'  ; Left  Y-Axis.
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, ORIENTATION=90,  $
          /NORMAL, 0.98, 0.45, '!7l!17radians/year'  ; Right Y-Axis.
;
RETURN
END  ; PLOT_RATES
;
; This rouitne will display the must current set of the 1-Day means on top of
; the Relevelling corrected Resultant Magnitudes.  The must current data set is
; defined as the data used to compute the last Long-Term Rate.
;
; Also the fit lines for the last Long-Term and Short-Term Rate will also be
; plotted op top of the 1-Day means.
;
; Callers: Users
;
; Tested OK on November 16th, 2017
;
PRO PLOT_LAST_NDAY_MEANS,   MTIME,  $ ; Input: 1-D array of JULDAY() values.
         RTM1DAY_MEAN,  $ ; Input: 1-D array of Resultant Magnitudes' 1-Day means.
           RTIME, RTM,  $ ; Input: 1-D arrays of the times in JULDAY() & Magnitudes.
                 NDAY,  $ ; Input: 2-element arrays for [Short-Term,Long-Term] in days.
                   ID     ; Input : 'MJ03B' or 'MJ03F' for example.
;
  I = N_ELEMENTS( MTIME )  ; = N_ELEMENTS( RTM1DAY_MEAN )
;
  CALDAT, MTIME[I-1],   M, N, Y    ; as Month, Day, Year
  S = JULDAY( M, N, Y,  0, 0, 0 )  ; The begining time of the last day in MTIME.
  S = S - NDAY[1] + 1              ; The start time of the N-Day ago for Long-Term.
  T = JULDAY( M, N, Y, 23,59,59 )  ; The end time of the the last day in MTIME
;
; Get the indexes: [I,J] so that RTIME[I:J] will contain the time range of S and T.
; Note that the GET_DATA_RANGE_INDEXES routine is the SplitRSNdata.pro
;
  GET_DATA_RANGE_INDEXES, RTIME,  $ ; Time for RTM.
                          S,  T,  $ ; use the Start & End Times
                          I,  J,  $ ; to the indexes: I,J
                          STATUS    ; STATUS = 1 means OK.
;
; The following 2 procedures are in the file IDLcolors.pro
;
  SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
; Determine number of Hourly or Daily marks per day.
;
  N = ( RTIME[J] - RTIME[I] )  ; Data Range in days.
;
  RSN_GET_XTICK_UNITS, N, XUNITS, H
;
; Where XUNITS will be returned as ['Hour','DAY'] or ['Day', 'DAY']
; and   H is the XTICKINTERVAL=H for either Hour or Day.
;
; Call LABEL_DATE() to ask for plotting Time Label.
;
  IF XUNITS[0] EQ 'Hour' THEN  BEGIN
     TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%H','%N/%D/%Z'] )
  ENDIF  ELSE  BEGIN
     TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%D','%N/%D/%Z'] )
  ENDELSE
;
  TIME_RANGE  = STRING( RTIME[I],  $ ; Date & Time of the 1st data point.
                FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
  TIME_RANGE += ' to ' + STRING( RTIME[J],  $  ; to the Last data point.
                FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
  TITLE4PLOT  = 'RSN-' + ID + '  Releveling Corrected Tilt Magnitudes & 1-Day Means '
           N  = STRTRIM( NDAY[0]/7, 2 )  ; For example, if NDAY = [28,56]
           M  = STRTRIM( NDAY[1]/7, 2 )  ; then N = '4' and M = '8'.
  IF NDAY[0] EQ NDAY[1] THEN  BEGIN
     TITLE4PLOT += 'plus ' + N + '-week Average Tilt Rates'
  ENDIF  ELSE  BEGIN
     TITLE4PLOT += 'plus ' + N + ' and ' + M + '-week Average Tilt Rates'
  ENDELSE
;
; Compute the Standard Deviation (S) & Mean (M).
;
  T  = STDEV( RTM[I:J], M )
  T  = 4.0*T       ; = 4 x Standard Deviation.
  MX = M + T       ; Upper Range.
  MN = M - T       ; Lower Range.
;
  PRINT, 'Max & Min of the Y-Plotting Range: ', MX, MN
;
; Define the Hardware Fonts to be used.
;   
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
;
 !P.FONT  = 0  ; Use the hardware font above.
 !X.THICK = 1
 !Y.THICK = 1  ; for thinker line drawing.
;
  PLOT, RTIME[I:J], RTM[I:J],       XMARGIN=[9,9],  $
        YSTYLE=2+4, YRANGE=[MN,MX], YMARGIN=[6,2],  $
        XSTYLE=1,   XRANGE=[RTIME[I],RTIME[J]],     $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT, /NODATA
  AXIS, YAXIS=0, YRANGE=[MN,MX], YSTYLE=2, CHARSIZE=1.15, COLOR=C.RED
  AXIS, YAXIS=1, YRANGE=[MN,MX], YSTYLE=2, CHARSIZE=1.15, COLOR=C.RED
;
; Plot the Resultant Tilt Magnitude data in Red.
;
  OPLOT, RTIME[I:J], RTM[I:J], COLOR=C.RED, PSYM=3
;
                M = N_ELEMENTS( MTIME )  ; = N_ELEMENTS( RTM1DAY_MEAN )
; CALDAT, MTIME[M-1],   M, N, Y    ; as Month, Day, Year
; S = JULDAY( M, N, Y,  0, 0, 0 )  ; The begining time of the last day in MTIME.
; S = S - NDAY[1] + 1              ; The start time for the  Long-Term.
  T = S + NDAY[1] - NDAY[0]        ; The start time for the Short-Term
; i.e.
; T = JULDAY( M, N, Y,  0, 0, 0 ) - NDAY[0]
;
; Get the indexes: [I,J] so that MTIME[I] = S and MTIME[J] = T.
; Note that the GET_DATA_RANGE_INDEXES routine is the SplitRSNdata.pro
;
  GET_DATA_RANGE_INDEXES, MTIME,  $ ; Time for RTM1DAY_MEAN
                          S,  T,  $ ; use the Start & End Times
                          I,  J,  $ ; to the indexes: I,J
                          STATUS
;
; Overplot the 1-Day means.
;
  OPLOT, COLOR=C.BLUE,     THICK=2, PSYM=4,  $ 
         MTIME[J:M-1], RTM1DAY_MEAN[J:M-1]   ; for the Short-Term data.
  IF I LT J THEN  BEGIN    ; Long-Term data available.
     OPLOT, COLOR=C.GREEN, THICK=2, PSYM=4,  $
         MTIME[I:J-1], RTM1DAY_MEAN[I:J-1]   ; for the  Long-Term data.
  ENDIF
  XYOUTS, ALIGNMENT=1, /DEVICE, 45,  45, XUNITS[0] + ':'
; where XUNITS[0] = 'Hour:' or 'Day:'
;
; Compute the linear least-square fit using the most recent 1-Day means
; of the last number of points for the short & long-term rates.
; Then display the fitted lines.
;
  X = MTIME[I:M-1] - MTIME[I]    ; in Days.
  R = LINFIT( X, RTM1DAY_MEAN[I:M-1], YFIT=Y )
  RATE2 = R[1]        ; Save the Slop as the Change/Day for  long-term.
  OPLOT, MTIME[I:M-1], Y, THICK=2, COLOR=C.GREEN
;
  X = MTIME[J:M-1] - MTIME[J]    ; in Days.
  R = LINFIT( X, RTM1DAY_MEAN[J:M-1], YFIT=Y )
  RATE1 = R[1]        ; Save the Slop as the Change/Day for short-term.
  OPLOT, MTIME[J:M-1], Y, THICK=2, COLOR=C.BLUE
;
  HELP, I, J, X, Y, STATUS
; STOP
;
; Get the Total Days of the Current Year = 365 or 366.
;
  CALDAT, MTIME[M-1],   H, N, Y    ; as Month, Day, Year and Only need the Year (Y)
  N = JULDAY( 12,31,Y ) - JULDAY( 1,0,Y )  ; = 365 or 366.
;
; Convert the Rate of Depth (meters) Change/Day into cm/year.
;
  HELP, RATE1, RATE2, N, I, J, M
  RATE1 = RATE1*N  ; where N= Total days/year = 365 or 366.
  RATE2 = RATE2*N  ;
  HELP, RATE1, RATE2
  R     = STRING( FORMAT='(F7.1)', [RATE1,RATE2] )
;
           N = STRTRIM( NDAY[0]/7, 2 )  ; For example, if NDAY = [28,56]
           M = STRTRIM( NDAY[1]/7, 2 )  ; then N = '4' and M = '8'.
  IF NDAY[0] LT NDAY[1] THEN  BEGIN
     TITLE4PLOT = M + '-week average tilt rate: ' + R[1] + ' mircoradians/yr'
     XYOUTS, /DEVICE,  80, 70, TITLE4PLOT, COLOR=C.GREEN       ;  Long-Term.
      PLOTS, /DEVICE,  50, 15, THICK=2,    COLOR=C.GREEN, PSYM=4
  ENDIF
;
  IF NDAY[0] GT 0 THEN  BEGIN
     TITLE4PLOT = N + '-week average tilt rate: ' + R[0] + ' mircoradians/yr'
     XYOUTS, /DEVICE, 410, 70, TITLE4PLOT, COLOR=C.BLUE        ; Short-Term.
      PLOTS, /DEVICE,  40, 15, THICK=2,    COLOR=C.BLUE , PSYM=4
  ENDIF
  XYOUTS, /DEVICE,  55, 10, '1-Day Means'
;
; Label the Y-Axis.
;
 !P.FONT  = -1  ; Back to graphic font.
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.RED, ORIENTATION=90,  $
          /DEVICE,  15, 120, '!7l!17radians'      ; Left  Y-Axis.
;
RETURN
END  ; PLOT_LAST_NDAY_MEANS
;
; This rouitne will display the 1-Day means of the Resultant Magnitudes
; on top of the Relevelling corrected Resultant Magnitudes.
;
; Callers: Users
; REvised: December 15th, 2017
;
PRO PLOT_RTM1DAYMEANS,  TIME,  $ ; Input: 1-D array of JULDAY() values.
                RTM1DAY_MEAN,  $ ; Input: 1-D array of Resultant Magnitudes' 1-Day means.
                     TM, RTM,  $ ; Input: 1-D arrays of the times in JULDAY() & Magnitudes.
                          ID     ; Input : 'MJ03B' or 'MJ03F' for example.
;
  IF N_PARAMS() LT 5 THEN  BEGIN  ; ID is not provided.
     ID = 'RSN'
  ENDIF   ; Set ID to RSN.
;
; Define a plotting symbel: a dot when using PSYM=8.
;
  USERSYM, [-0.3,0.3],[0,0]
  X = FINDGEN( 16 )*!PI/8.0
  USERSYM, COS( X ), SIN( X ), /FILL  ;, THICK=2
;
  N = N_ELEMENTS( TM )  ;  Also = N_ELEMENTS( RTM )
;
; Define the Hardware Fonts to be used.
;
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
;
 !P.FONT  = 0  ; Use the hardware font above.
 !X.THICK = 1
 !Y.THICK = 1  ; for thinker line drawing.
;
  TIME_RANGE  = LABEL_DATE( DATE_FORMAT=['%N/%D/%Z'] )
;
  TIME_RANGE  = STRING( TM[0],             $  ; Date of the 1st data point.
                FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
  TIME_RANGE += ' to ' + STRING( TM[N-1],  $  ; to the Last data point.
                FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
;
  MX = MAX( RTM, MIN=MN )  ; The Max. & Min. of the RTM values.
;
; Display the Relevelling Corrected Resultant Magnitudes (RTM).
;
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, TM, RTM,  XTICKFORMAT=['LABEL_DATE'],                   $
        XSTYLE=1, XRANGE=[TM[0],TM[N-1]], XMARGIN=[9,9],        $
                  YRANGE=[MN,   MX],      YMARGIN=[5,3],        $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, XTICKUNITS=XUNITS,  $
         TITLE=ID + ' Relevelling Corrected Resultant Magnitudes and 1-Day Means'
  AXIS, YAXIS=1, YRANGE=[MN,MX], CHARSIZE=1.15
;
; Display the 1-Day Means as cycles.
;
  OPLOT, TIME, RTM1DAY_MEAN, PSYM=3, THICK=1, COLOR='FF00FF'XL  ; Red.
  PLOTS, 0.1, 0.9, /NORMAL,  PSYM=3, THICK=1, COLOR='FF00FF'XL 
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR='FF00FF'XL,  $
         /NORMAL, 0.11, 0.89, '1-Day Mean'
;
; Label the Left & Right Y-Axes.
;
 !P.FONT  = -1  ; Back to graphic font.
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, ORIENTATION=90,  $
          /NORMAL,  0.03, 0.5, '!7l!17radians'  ; Left  Y-Axis.
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, ORIENTATION=90,  $
          /NORMAL,  0.98, 0.5, '!7l!17radians'  ; Right Y-Axis.
;
RETURN
END  ; PLOT_RTM1DAYMEANS
