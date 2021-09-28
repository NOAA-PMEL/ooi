;
; File: GetPredictedDates.pro
;
; This program will used the data retrieved from the file:
; ~/4Chadwick/RSN/MJ03F/LongTermNANOdataProducts.MJ03F (*) for example
; to compute the predicted dates that will reach the highest top
; since the last eruption, e.g. April 25th, 2015.
;
; Revised on  August 30th, 2018
; Created on  April  18th, 2018
;

;
; Callers: PLOT_FORECAST_HISTOGRAM and Users.
;
PRO GET_PREDICTED_DATE,  DATA, $ ;  Input: 2-D Array from file: (*) above.
                          TOP, $ ;  Input: Top Height in meters.
                         TIME, $ ; Output: 1-D array of the predicted time in JULDAY().
                        COUNT, $ ; Output: 1-D array of the occurences within each month.
    TIME_RANGE=START2END_TIMES   ;  Input: 2-Element array of the start & end days
;                                          in JULDAY()s.
; DATA[*,0] = Time Stamps in JULDAY().
; DATA[*,1] = 1-Day averaged heights.
; DATA[*,2] = Estimated  8-week rate in cm/yr.
; DATA[*,3] = Estimated 12-week rate in cm/yr.
;
; D2TOP = ( DATA[0:*,1] - TOP )    ; Distances to the TOP Heigth, e.g. 1509.8 meters.
  D2TOP = ABS( DATA[0:*,1] ) - ABS( TOP )       ; Distances to the TOP Heigth, e.g. 1509.8 meters.
  RATE  = TEMPORARY( D2TOP )*100.0/DATA[0:*,3]  ; Times in years to the TOP.
  T     = DATA[0:*,0] + TEMPORARY( RATE )*365   ; Predicted Times in days to the TOP.
;
  IF KEYWORD_SET( START2END_TIMES ) THEN  BEGIN
     STIME = START2END_TIMES[0]   ; Start and End Times
     ETIME = START2END_TIMES[1]   ; Provided by the caller.
  ENDIF  ELSE  BEGIN  ; Determine the Start and End Times
;
     STIME = MIN( T, MAX=ETIME )      ; Min. & Max. Time Range in TIME.
;
  ENDELSE  ; Defining the Start and End Times.
;
; Extend the time range of STIME to ETIME at both ends.
;
; DaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
;
  CALDAT, STIME,  MONTH,D,Y          ; Get the Month, Day and Year from min.day: STIME
  J = JULDAY( MONTH,1,Y,   12,0,0 )  ; Move the date:J to the beginning of the month.
  CALDAT, ETIME,  MONTH,D,Y          ; Get the Month, Day and Year from max.day: ETIME
; I = DaysInMonth[MONTH-1] + ( Y MOD 4 ) EQ 0 )
  M = JULDAY( MONTH+1,1,Y, 12,0,0 )  ; Move the date:M to the end of the month.
;
  N = M - J                     ; Total number of days in the extended time range: T.
  D = REPLICATE( 0, N )         ; For storing the occurrence counts.
  S = ROUND( T ) - ROUND( J )   ; Indexes for the array: D.
;
  FOR I = 0, N_ELEMENTS( S )-1 DO  BEGIN
      D[S[I]] += 1  ; Count up the occurrences per day.
  ENDFOR  ; I
;
  N_MONTHS = ROUND( ( M - J )/30.5 )  ; Approixmately total number of months.
    COUNT  = REPLICATE( 0, N_MONTHS )
    TIME   = TIMEGEN( N_MONTHS, START=J, STEP=1, UNIT='MONTH' )
;
; Count up events for each month.
;
  J = LONG( 0 )  ; for array: D
  S = LONG( 0 )  ; for array: COUNT
;
  FOR I = 1, N_MONTHS-1 DO  BEGIN
      K = TIME[I] - TIME[I-1]
      COUNT[S] = TOTAL( D[J:J+K-1] )
            S += 1
            J += K
  ENDFOR  ; I
;
        K  = M - TIME[I-1]
  COUNT[S] = TOTAL( D[J:J+K-1] )
;
  RETURN
  END  ; GET_PREDICTED_DATE
