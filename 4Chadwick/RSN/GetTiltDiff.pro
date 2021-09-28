;
; File: GetLILYtiltDiff.pro
;
; This IDL program contains routines for getting the differences of
; the Tilts and the tools for get the array indexes.
;
; The procedures in this program will be using the procerdures
; in the file: SplitRSNdata.pro
;
; Revised on April     10th, 2018
; Created on April     16th, 2015
;

;
; Callers: Users.
; Revised: August   29th, 2017
;
PRO GET_TD,  RLT,        $ ;  Input: 2-D array of the Releveling Time Periods.
             N_DAYS,     $ ;  Input: for computing the Tilt Differences.
    TIME, XTILT, YTILT,  $ ;  Input: 1-D arrays of the same size.
    TM,   XTDF,  YTDF,   $ ; Output: 1-D arrays of Time & Tilt Differences.
    ADD_FRONT=ADD_FRONT_DATA,  $ ; For adding additional Output to the TM, XTDF & YTDF.
    TIME_INTERVAL=TIME_STEP      ; in seconds for data interval in TIME.
;
; For the Keyword:ADD_FRONT_DATA, see the commnets at the beginning of the
; PRO GET_TILT_DIFFERENCES below.
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
IF N_DAYS EQ 0 THEN  BEGIN
   PRINT, 'Number of Data to be offset is 0!  No Results will be provided!'
   RETURN  ; to Caller.
ENDIF  ; N_DAYS == 0
;
; This procedure assume the IDL_FILE has been verified its existence.
; The IDL_FILE can either MJ03F-LILY.idl or MJ03D-IRIS.idl for example.
;
; The procedure: RETRIEVE_TILT_VARIABLES is located in the file:
; RetrieveTiltVar.pro
;
; RETRIEVE_TILT_VARIABLES, IDL_FILE, TIME, XTILT, YTILT, SENSOR
;
; IF SENSOR EQ 'None' THEN  BEGIN
;    PRINT, 'The IDL Save File: ' + IDL_FILE
;    PRINT, 'Does Not contain any correct Tilt variable names.'
;    PRINT, 'No Resultant Magnitudes and Directions will be plotting.'
;    RETURN  ; To caller.
; ENDIF
;
  S = SIZE( RLT )  ; Get the size and information of RLT.  August 29th, 2017.
  M = N_ELEMENTS( TIME )
  N = 0  ; Initialize before used.
;
; RLT is a 2xN array where RLT[0,i] & RLT[1,i] contain the Start & End times
; (in JULDAY()s) of the Releveling Period respectively.
;
; Rearrange the RLT times in the Data Range Times (DRT).
;
IF N_DAYS LT 0 THEN  BEGIN  ; All Data will be used.  ; Use the data at the end.
;
   IF S[0] EQ 0 THEN  BEGIN  ; RLT could be Undefined or Not a 2-D array.
      DRT = [ TIME[0], TIME[M-1] ]  ; in   1-D.
   ENDIF  ELSE  BEGIN  ; Assuming RLT is a 2-D array.
;
;     Rearranging the RLT times in the Data Range Times (DRT) so that
;     (TIME[0],RLT[0,0]), (RLT[1,0],RLT[0,1]), (RLT[1,1],RLT[0,2]),
;     ... (RLT[1,N-2],RLT[0,N-1]), (RLT[1,N-1],TIME[M-1])
;     and each of the (RLT[1,N-2],RLT[0,N-1]) for example, is the Data Ranges
;     interval where 0 < N < M = the Total elements in TIME.
;
;     M   = N_ELEMENTS( TIME )
      N   = N_ELEMENTS( RLT  )
      DRT = [ TIME[0], RLT[0:N-1], TIME[M-1] ]  ; in   1-D.
;
   ENDELSE  ; Defining DRT.
;
ENDIF  ELSE  BEGIN  ; N_DAYS > 0.  Use the data at the end.
;
   IF S[0] EQ 0 THEN  BEGIN  ; RLT could be Undefined or Not a 2-D array.
      DRT = [ TIME[0], TIME[M-1] ]  ; in   1-D.
   ENDIF  ELSE  BEGIN  ; Assuming RLT is a 2-D array.
;
;     Rearranging the RLT times in the Data Range Times (DRT) so that
;     (TIME[B],RLT[0,I]), (RLT[1,I+1],RLT[0,I+2]), (RLT[1,I+2],RLT[0,I+3]),
;     ... (RLT[1,J-1],RLT[0,J]), (RLT[1,J],TIME[E])
;     and each of the (RLT[1,I+1],RLT[0,I+2]) for example, is the Data Ranges
;     where 0 <= B < I < J < E <= M = the Total elements in TIME.
;
;     Note that is assumed that TIME[0] < RLT[0,0] < RLT[1,N] < TIME[M]
;     where N = last elements in the 2nd dimension of RLT.
;
;     Locate the indexes: B < I < J < E.
;
;     Locate the array index of the time N_DAYS ago, e.g. 14 Days.
;     Note that the function: LOCATE_TIME_POSITION() is in the
;     File: ~/4Chadwick/RSN/SplitRSNdata.pro
;
      N = N_DAYS + N_DAYS  ; Total range requires for N_DAYS difference.
;     M   = N_ELEMENTS( TIME ) - 1
      M   = M - 1  ; = N_ELEMENTS( TIME ) - 1
;     I = LOCATE_TIME_POSITION( TIME GT ( TIME[M] - N ) )
      I =                WHERE( TIME GT ( TIME[M] - N ) )
      S = I[0]                    ;        The Start Index of the selected time.
;     M = N_ELEMENTS( TIME ) - 1  ; = E  ; The End   Index of the selected time.
;
;     Locate the time range so that TIME[S] < RLT[I] < RLT[J] < TIME[M]
;     if indexes I and J exist.
;
;     N = N_ELEMENTS( RLT )
      K = WHERE( RLT GT TIME[S] )
      I = K[0]  ; Save the least   upper bound for TIME[S] < RLT[I].
;
      IF I LT 0 THEN  BEGIN  ; No Index I is found, i.e. RLT[1,N-1] < TIME[S].
         J   = -1            ; No Index J as well since  TIME[S]    < TIME[M].
         N   =  0
         DRT = [ TIME[S], TIME[M] ]
      ENDIF  ELSE  BEGIN     ; Index I is found and
         K   = WHERE( RLT LT TIME[M], N )  ; Look for Index J.
         J   = K[N-1]     ; Save the highest lower bound for TIME[M] > RLT[J].
         N   = J - I + 1  ; Total elements in RLT[I:J].
         DRT = [ TIME[S], RLT[I:J], TIME[M] ]  ; into an 1-D array.
      ENDELSE
;
      M = M + 1  ; = N_ELEMENTS( TIME )
;
   ENDELSE  ; Defining DRT.
;
ENDELSE  ; End of Getting the DRT.
;
  N   = ( N + 2 )/2  ; 2nd Dimension of DRT that to be reformed below.
  DRT = REFORM( DRT, 2, N, /OVERWRITE ) ; into a 2-D array.
;
  PRINT, 'Arranged Data Range Times are: '
  PRINT, FORMAT="( C(), ' <--> ', C() )", DRT  ; Show the Times for checking. 
  PRINT, STRTRIM( N, 2 ) + ' of them.'
;
  HELP, RLT, DRT, SENSOR, TIME, XTILT, YTILT
; STOP
;
; Get the Tilt Differences from the DRT setting:
; Each of DRT[0:1,i] contains the Start & End times of the data range
; for i = 0, 1, ..., n
;
; Get Tilt Differences for the 1st data range in DRT[0:1,0]
;
  K = WHERE( TIME GE DRT[0,0] )
  I = K[0]      ; for DRT[0,0] <= TIME[I].
  K = WHERE( TIME GE DRT[1,0] )
  J = K[0] - 1  ; for TIME[J]  < DRT[1,0].
  K = TIME[J] - TIME[I]  ; in days.
  IF K GE ABS( N_DAYS ) THEN  BEGIN
     GET_TILT_DIFFERENCES,  ADD_FRONT=ADD_FRONT_DATA,  $  ; Option for output.
         TIME_INTERVAL=TIME_STEP,  $   ; Input: in seconds for data interval in TIME.
         N_DAYS, TIME[I:J], XTILT[I:J], YTILT[I:J],    $  ; Inputs.
         TM, XTDF, YTDF   ; Outputs.
  ENDIF  ELSE  BEGIN  ; K < |N_DAYS|
     TM   =  TIME[I:J]
     XTDF = XTILT[I:J] - XTILT[I]
     YTDF = YTILT[I:J] - YTILT[I]
  ENDELSE
;
  LAST_XT = XTILT[J]  ; Save the last tilt values
  LAST_YT = YTILT[J]  ; of 1st data range.
;
; STOP
;
; Get the Tilt Differences for the data range DRT[0:1,i] for i = 1,2,...n-2.
;
  FOR S = 1, N-2 DO  BEGIN ; Get the Tilt Differences at each data interval.
      K = WHERE( TIME GT DRT[0,S] )
      I = K[0]      ; for DRT[0,S] < TIME[I].
      K = WHERE( TIME GT DRT[1,S] )
      J = K[0] - 1  ; for TIME[J] < DRT[1,S].
;     Determine the Tilts' Offsets by getting the
;     XOFFSET = LAST_XT - XTILT[I]  ; between Last tilt value of the previous data range
;     YOFFSET = LAST_YT - YTILT[I]  ; &  the First tilt value of current data range.
;     Apply the tilt Offsets to the current data range.
      XT      = XTILT[I:J] + ( LAST_XT - XTILT[I] )   ;  September 22nd, 2017
      YT      = YTILT[I:J] + ( LAST_YT - YTILT[I] )
         K = TIME[J] - TIME[I]  ; in days.
      IF K GE ABS( N_DAYS ) THEN  BEGIN
         GET_TILT_DIFFERENCES,  ADD_FRONT=ADD_FRONT_DATA,  $  ; Option for output.
             TIME_INTERVAL=TIME_STEP,  $ ; Input: in seconds for data interval in TIME.
;            N_DAYS, TIME[I:J], XTILT[I:J], YTILT[I:J],    $  ; Inputs
             N_DAYS, TIME[I:J], XT        , YT        ,    $  ; Inputs  September 22nd, 2017
             T, X, Y  ; Outputs.
      ENDIF  ELSE  BEGIN  ; K < |N_DAYS|
         T =  TIME[I:J]
         X = XT         - XT[0]    ; September 22nd, 2017
         Y = YT         - YT[0]
;        X = XTILT[I:J] - XTILT[I]
;        Y = YTILT[I:J] - YTILT[I]
      ENDELSE
;     Append the computed Tilt Differences into the last computed Tilt Differences.
      TM   = [ TEMPORARY(  TM  ), TEMPORARY( T ) ]
      XTDF = [ TEMPORARY( XTDF ), TEMPORARY( X ) ]
      YTDF = [ TEMPORARY( YTDF ), TEMPORARY( Y ) ]
; STOP
                   K  = J - I  ; = N_ELEMENTS( XT ) - 1
      LAST_XT = XT[K]          ; Save the last tilt values
      LAST_YT = YT[K]          ; of the current data range.
  ENDFOR;  S
;
; Get the Tilt Difference for the last data range in DRT[0:1,n-1].
;
  IF N GT 1 THEN  BEGIN  ;
     S = N - 1
     K = WHERE( TIME GE DRT[0,S] )
     I = K[0]      ; for DRT[0,0] <= TIME[I].
     J = M - 1     ; for TIME[J]  == TIME[M-1].
;    Determine the Tilts' Offsets by getting the
;    XOFFSET = LAST_XT - XTILT[I]  ; between Last tilt value of the previous data range
;    YOFFSET = LAST_YT - YTILT[I]  ; &  the First tilt value of current data range.
;    Apply the tilt Offsets to the current data range.
     XT      = XTILT[I:J] + ( LAST_XT - XTILT[I] )   ;  September 22nd, 2017
     YT      = YTILT[I:J] + ( LAST_YT - YTILT[I] )
        K = TIME[J] - TIME[I]  ; in days.
     IF K GE ABS( N_DAYS ) THEN  BEGIN
        GET_TILT_DIFFERENCES,  ADD_FRONT=ADD_FRONT_DATA,  $  ; Option for output.
            TIME_INTERVAL=TIME_STEP,  $ ; Input: in seconds for data interval in TIME.
;           N_DAYS, TIME[I:J], XTILT[I:J], YTILT[I:J],    $  ; Inputs
            N_DAYS, TIME[I:J], XT        , YT        ,    $  ; Inputs  September 22nd, 2017
            T, X, Y   ; Outputs.
     ENDIF  ELSE  BEGIN  ; K < |N_DAYS|
        T =  TIME[I:J]
        X = XT         - XT[0]    ; September 22nd, 2017
        Y = YT         - YT[0]
;       X = XTILT[I:J] - XTILT[I]
;       Y = YTILT[I:J] - YTILT[I]
     ENDELSE
     TM   = [ TEMPORARY(  TM  ), TEMPORARY( T ) ]
     XTDF = [ TEMPORARY( XTDF ), TEMPORARY( X ) ]
     YTDF = [ TEMPORARY( YTDF ), TEMPORARY( Y ) ]
  ENDIF  ; Get the Tilt Difference for the last data range.
;
; STOP
;
RETURN
END  ; GET_TD
;
; Callers: GET_TD and Users.
; Revised: April    10th, 2018
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
  HELP, S, N
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
  HELP, B, E
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
     D    = ( TIME[S:N] - TIME[S] )*86400.0D0   ; into seconds.
     XTDF =  INTERPOL( X1, D, T )
     YTDF =  INTERPOL( Y1, D, T )
;    HELP, X1, Y1, D, T, XTDF, YTDF
     D    = ( TIME[S] + T[M-1]/86400.0D0 - TIME[N] )*86400.0D0  ; in seconds.
     IF D LE 2 THEN  BEGIN
        X1 = TEMPORARY( XTDF )
        Y1 = TEMPORARY( YTDF )
     ENDIF  ELSE  BEGIN  ; | D | > 2 seconds.
;       The TIME[N] is < the TIME[S] + T[M-1]/86400.
;       Look for the Time Index: TIME[N] in T.
 ;      I  = WHERE( T GT ( TIME[N] - TIME[S] )*86400.0D0 )
        I = N_ELEMENTS( XTDF )  ; for X1 = XTDF  &  Y1 = YTDF.
        X1 = XTDF[0:I[0]-1]  ; Save only the interpolated
        Y1 = YTDF[0:I[0]-1]  ; data points up to TIME[N].
     ENDELSE
     D    = ( TIME[B:E] - TIME[B] )*86400.0D0  ; into seconds.
     XTDF =  INTERPOL( X2, D, T )
     YTDF =  INTERPOL( Y2, D, T )
;    HELP, X2, Y2, D, T, XTDF, YTDF
     D    = ( TIME[B] + T[M-1]/86400.0D0 - TIME[E] )*86400.0D0  ; in seconds.
     IF D LE 2 THEN  BEGIN
        X2 = TEMPORARY( XTDF )
        Y2 = TEMPORARY( YTDF )
     ENDIF  ELSE  BEGIN  ; | D | > 2 seconds.
;       The TIME[E] is < the TIME[B] + T[M-1]/86400.
;       Look for the Time Index: TIME[N] in T.
 ;      I  = WHERE( T GT ( TIME[E] - TIME[B] )*86400.0D0 )
        I = N_ELEMENTS( XTDF )  ; for X1 = XTDF  &  Y1 = YTDF.
        X2 = XTDF[0:I[0]-1]  ; Save only the interpolated
        Y2 = YTDF[0:I[0]-1]  ; data points up to TIME[N].
     ENDELSE
  ENDIF  ; Interpolate the Tilt data.
;
  N1  = N_ELEMENTS( X1 )  ; = N_ELEMENTS( Y1 )
  N2  = N_ELEMENTS( X2 )  ; = N_ELEMENTS( Y2 )
; HELP, X1, Y1, X2, Y2, N1, N2
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
;        IF M GT N1 THEN  M = N1
         S =  1
     ENDIF  ELSE  BEGIN
         M = N1
     ENDELSE
     TM = ( TIMEGEN( M, START=TIME[S], STEP=TIME_STEP, UNIT='SECOND' ) )  ; Backward-Most Range
  ENDIF  ELSE  BEGIN
;    M  = N_ELEMENTS( TIME )  ;
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
; Locate the indexes that contain data points,             March 14th, 2018
; i.e. Skipping the gaps that filled with the interpolated values.
;
    I  = ( TIME[S:N] - TIME[S] )*86400/TIME_STEP  ; Convert time into indexes for TM.
    I  = ROUND( TEMPORARY( I ) )
;   M  = N_ELEMENTS( I )
;   J  = ROUND( I[1:M-1] - I[0:M-2] )
;   Z  = WHERE( J GT 1, COMPLEMENT=K )  ; Locate Gaps' indexes: Z
;   I  = ROUND( I[K] )
;
    TM =   TM[I]  ; Save only the
  XTDF = XTDF[I]  ; times contain
  YTDF = YTDF[I]  ; data.
;
; STOP
;
RETURN
END  ; GET_TILT_DIFFERENCES
