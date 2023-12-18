;
; File: GetLILYtiltDiff.pro
;
; This IDL program contains routines for getting the differences of
; the LILY Tilt differences and the tools for get the array indexes.
;
; The procedures in this program will be used by the procerdures
; in the file: SplitRSNdata.pro
;
; Revised on Novemebr  13th, 2014
; Created on April     16th, 2015
;

;
; Callers: PLOT_LILY_DATA in the PlotRSNdata.pro or Users.
; Revised: Novemebr 13th, 2014
;
PRO GET_TILT_DIFFERENCES, N_DAYS,  $  ;  Input: Number of days for the data length.
             TIME,  XTILT, YTILT,  $  ;  Input: 1-D arrays of the same size.
             T,     XTDF,  YTDF       ; Output: 1-D arrays of Time & Tilt Differences.
;
; TIME        = 1-D arrays in Julian Days.
; XTILT,YTILT = 1-D arrays in Degrees.
;
; Get Total number of data points in the arrays: TIME, XTILT & YTILT.
;
  M = N_ELEMENTS( TIME )  ; = N_ELEMENTS( XTILT ) = N_ELEMENTS( YTILT )
;
; Locate the array index of the time N_DAYS ago, e.g. 7 Days.
; Note that the function: LOCATE_TIME_POSITION() is in the
; File: ~/4Chadwick/RSN/SplitRSNdata.pro
;
  N = M - 1  ; The End   Index of the selected time.
; I = LOCATE_TIME_POSITION( TIME GT ( TIME[N] - N_DAYS ) )
  I =                WHERE( TIME GT ( TIME[N] - N_DAYS ) )
  S = I[0]   ; The Start Index of the selected time.
; N = M - 1  ; The End   Index of the selected time.
;
; Save the Selected Tilt Data range.
;
  X1 = XTILT[S:N]
  Y1 = YTILT[S:N]
;
  PRINT, 'The 1st Data Set Range: (The Last ' + STRTRIM( N_DAYS, 2 ) + ' Days)'
  PRINT, FORMAT='(C(),A,C())', TIME[S], ' to ', TIME[N]
;
; Locate the array index of the time 2 x N_DAYS ago, e.g. 14 Days.
; To locate that, Start from the last N_DAYS ago and
; Move back for another N_DAYS.
;
  E = S - 1  ; = I[0] - 1  ; Start from the last N_DAYS ago.
; I = LOCATE_TIME_POSITION( TIME GT ( TIME[E] - N_DAYS ) )
  I =                WHERE( TIME GT ( TIME[E] - N_DAYS ) )
  B = I[0]   ; The Start Index of the selected time.
; E = S - 1  ; The End   Index of the selected time.
;
; Save the Selected Tilt Data range.
;
  X2 = XTILT[B:E]
  Y2 = YTILT[B:E]
;
  PRINT, 'The 2nd Data Range (Another ' + STRTRIM( N_DAYS, 2 )  $
       + ' Days Before the 1st data set):'
  PRINT, FORMAT='(C(),A,C())', TIME[B], ' to ', TIME[E]
;
; Check for data gaps.
;
  M = N_DAYS * ULONG( 86400 )  ; Total days in seconds
  D = ( M - N_ELEMENTS( X2 ) ) + ( M - N_ELEMENTS( X1 ) )
;
; Interpolate the Tilt data so that all the gaps in between will be fill in.
;
  IF ABS( D ) GT 0 THEN  BEGIN  ; There are gaps in the Tilt data.
     T    = DINDGEN( M )
     D    = ( TIME[S:N] - TIME[S] )*86400.0D0  ; into seconds.
     XTDF =  INTERPOL( X1, D, T )
     YTDF =  INTERPOL( Y1, D, T )
     X1   = TEMPORARY( XTDF )
     Y1   = TEMPORARY( YTDF )
     D    = ( TIME[B:E] - TIME[B] )*86400.0D0  ; into seconds.
     XTDF =  INTERPOL( X2, D, T )
     YTDF =  INTERPOL( Y2, D, T )
     X2   = TEMPORARY( XTDF )
     Y2   = TEMPORARY( YTDF )
  ENDIF
;
; Compute the Tilt Differences.
;
  XTDF = X1 - X2
  YTDF = Y1 - Y2
;
; Define the Time Indexes in JULDAY()'s.
;
   D   = TIME[N] - N_DAYS
   T   = ( TIMEGEN( M+1, START=D, STEP=1, UNIT='SECOND' ) )[1:M]
;
   STOP
;
RETURN
END  ; GET_TILT_DIFFERENCES
