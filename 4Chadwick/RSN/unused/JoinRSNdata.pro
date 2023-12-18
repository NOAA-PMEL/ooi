;
; File: JoinRSNdata.pro
;
; This IDL program will Join 2 outcasted RSN data sets in 2 IDL save files;
; and print out the Joined data set into a new IDL save file.
;
; This program requires the procedures in the file:
; in order to work.
;
; Revised on November  25th, 2014
; Created on November  25th, 2014
;

;
; This function will check a given array: VALUES to see whether or
; not their values are in either nondecreasing or nonincreasing order
; depended on what order is specified by the caller.
;
; The function return the values of the STATUS where
; STATUS = -3 ; means the values are Undefined.
;        = -2 ; means the values are Not numbers.
;        = -1 ; means the values are Not in order.
;        =  1 ; means the order is either    decreasing or    increasing.
;        =  0 ; means the order is either nondecreasing or nonincreasing.
;          i.e. there are at least 2 sconsective numbers are the same.
;
; Callers: RSN_INSERT_*_DATA and users.
;
FUNCTION CHECK_ORDER, VALUES,              $ ; Input: 1-D array of values.
         ASSCENDING=USE_ASSCENDING_ORDER,  $ ; Default.
         DESCENDING=USE_DESCENDING_ORDER
;
; Get the information of the variable: VALUES.
;
  S = SIZE( VALUES )
;
IF S[0] EQ 0 THEN  BEGIN  ; S[0] = Number of Dimensions in VALUES.
      N = S[S[0]+1]  ; = Type Code
   IF N GT 5 THEN  BEGIN  ; VALUES are NOT byte, interger or floating points.
      PRINT, 'The input values are in ' + SIZE( VALUES, /TNAME )
      PRINT, 'Not numbers including Complex numbers.'
      STATUS = -2  ; VALUES are Not numbers.
   ENDIF ELSE IF N EQ 0 THEN  BEGIN
      PRINT, 'The input value is undefined'
      STATUS = -3  ; VALUES are Undefined.
   ENDIF ELSE  BEGIN
      PRINT, 'The input value is only a single number.'
      STATUS =  0  ; Assumes the VALUES is nondecreasing or nonincreasing.
   ENDELSE
ENDIF ELSE BEGIN  ; VALUES are numbers.
   T = S[S[0]+2]  ; S[0]+2] = Last index of S & it is = N_ELEMENTS( VALUES ).
   IF T EQ 1 THEN  BEGIN
      PRINT, 'The input value is only an 1-Element array.'
      STATUS =  0  ; Assumes the VALUES is nondecreasing or nonincreasing.
   ENDIF  ELSE  BEGIN  ; N_ELEMENTS( VALUES ) > 1.
      D = VALUES[1:T-1] - VALUES[0:T-2]  ; Get the differences between numbers.
      IF KEYWORD_SET( USE_DESCENDING_ORDER ) THEN  BEGIN
         I = WHERE( D LT 0, M )
      ENDIF  ELSE  BEGIN  ; USE_ASSCENDING_ORDER
         I = WHERE( D GT 0, M )
;        I = WHERE( D LT 0, M, NCOMPLEMENT=N )
      ENDELSE
      IF M EQ ( T - 1 ) THEN  BEGIN
         STATUS =  1     ; VALUES are either Descending    or Asscending.
      ENDIF  ELSE  BEGIN  
         I = WHERE( D EQ 0, N )
         IF ( M + N ) EQ ( T - 1 ) THEN  BEGIN
            STATUS =  0  ; VALUES are either nonincreasing or nondecreasing..
         ENDIF  ELSE  BEGIN
            STATUS = -1  ; VALUES are Not in order.
         ENDELSE
      ENDELSE
   ENDELSE
ENDELSE
;
RETURN, STATUS
END   ; CHECK_ORDER
;
; This function will check a given point and check against an provide
; array of values to determine where the given point will be Outside
; the array of inside of the array.
;
; The function returns the value of the STATUS where  STATUS
; = -1   means the given point is  Before    the array: PT < ARRAY[0].
; =  0   means the point = the 1st  value in the array: PT = ARRAY[0].
; = 0.5  means the point in between 1st & Last value: ARRAY[0] < PT < ARRAY[N]
; =  1   means the point = the Last value in the array: PT = ARRAY[N].
; >  1   means the point is after the Last value in the array: ARRAY[N] < PT.
; and  ARRAY[N] = Last value in the array.
;
; Callers: RSN_INSERT_*_DATA and users.
;
FUNCTION CHECK_PT_STATUS, ARRAY,  $ ; Input: 1-D array of numbers.
                             PT     ; Input: scale value.
;
; Note that it is assumed that the values in the ARRAY & PT are
; the same type, e.g. both are integers or floating numbers.
;
  N = N_ELEMENTS( ARRAY )
;
IF PT LT ARRAY[0] THEN  BEGIN
   STATUS = -1  ; PT is Before the 1st value in the ARRAY.
ENDIF ELSE IF ARRAY[ 0 ] EQ PT THEN  BEGIN
   STATUS =  0  ; PT is Equal  the 1st value in the ARRAY.
ENDIF ELSE IF ARRAY[N-1] EQ PT THEN  BEGIN
   STATUS =  1  ; PT is Equal the Last value in the ARRAY.
ENDIF ELSE IF ARRAY[N-1] LT PT THEN  BEGIN
   STATUS =  2  ; PT is After the Last value in the ARRAY.
ENDIF ELSE BEGIN
   STATUS = 0.5 ; ARRAY[ 0 ] < PT < ARRAY[N-1]
ENDELSE
;
RETURN, STATUS
END   ; CHECK_PT_STATUS
;
; This function will locate a give time value: T to see where its position
; will be in terms of the TIME array index, i.e. to locate an index: S
; so that TIME[S-1] <= T < TIME[S].
; This function will return -1 if T < TIME[0] 
;                       and  n if TIME[n-1] < T.
; where n-1 is the last index of the array: TIME.
;
; Callers: RSN_INSERT_*_DATA and users.
;
FUNCTION LOCATE_TIME_POSITION, TIME,   $ ; Input: 1-D array of JULDAY().
                               T         ; Input: a JULDAY() value.
;
I = WHERE( TIME LE T, N, COMPLEMENT=J, NCOMPLEMENT=M )
;
IF M LE 0 THEN  BEGIN  ; TIME[N-1] < T.
   S = N
ENDIF  ELSE  BEGIN
   S = J[0]  ; TIME[S-1] <= T < TIME[S].
ENDELSE
;
RETURN, S
END   ; LOCAT_TIME_POSITION
;
; This function will locate the index where a new year is starting
; from a give TIME arrays with the JULDAY() vaules.  For example,
; if the TIME contains time from 2014 into 2015, then an index: I
; will be locate so that TIME[0:I-1] will be in 2014 and
; TIME[I:*] will be in 2015.
;
; Callers: SPLIT_*2FILES and users.
; REvised: October 28th, 2014
;
FUNCTION NEW_YEAR_POSITION,  TIME  ; Input: 1-D array of JULDAY().
;
; Get all the Years' values out from the TIME
;
  YR = STRING( FORMAT='(C(CYI))', TIME )  ; = 1-D of STRING array
  YR = FIX( TEMPORARY( YR ) )             ; Change the YR into integers.
   N = N_ELEMENTS( TIME )  ; Get the size of the array.
   M = YR[N-1] - YR[0]     ; Total years.
;
IF M LE 0 THEN  BEGIN
   PRINT, "There are No new year in the data: ", YR[0], YR[N-1]
   PRINT, "Still continue (Type '.CON') or stop (Type 'RETALL')?" 
   I = -1  ; All TIME values have the same year.
ENDIF ELSE IF M EQ 1 THEN  BEGIN
   I = WHERE( YR EQ YR[N-1], M )  ; Locate all the new year positions.
   I = I[0]   ; Save only the 1st one.
   PRINT, "Check out the data before type '.CON' to continue."
ENDIF ELSE BEGIN  ; M > 1, Only 1 year.
   PRINT, "There are more 1 year in the data: ", YR[0], YR[N-1]
   PRINT, "Only the 1st new  year's position will be located!"
   PRINT, "Still continue (Type '.CON') or stop (Type 'RETALL')?"
   I = WHERE( YR EQ YR[0], M )  ; Get all the positions before the 1st new year.
   I = -( I[M-1] + 1 )          ; The 1st new year position.
ENDELSE
;
RETURN, I
END   ; NEW_YEAR_POSITION
;
; Callers: Users.
;
PRO RSN_JOIN_HEAT_DATA, HEAT1DATA_FILE, HEAT2DATA_FILE, JOIN_DATA_FILE
;
; Retrieve the save arrays' variables in the 1st IDL save file.
;
  RESTORE, HEAT1DATA_FILE  ; TEMP, TIME, [X&Y]TILT, N_HEAT_CNT
;
   STATUS = CHECK_ORDER( TIME )
   PRINT,  'CHECK_ORDER( TIME ): ', STATUS
IF STATUS EQ 1 THEN  BEGIN  ; TIMEs are in orider.
   PRINT, 'The 1st set of HEAT data times are OK!'
ENDIF  ELSE  BEGIN  ; STATUS Not = 1
   PRINT, 'The 1st set of HEAT data times are Not in order!'
   STOP,  'Are the values OK?  Type .CON to continue or RETURN to stop.'
ENDELSE
;
; Assign the data into a new array veriable names
;
  HEAT_TIME  = TIME
  HEAT_TEMP  = TEMP
  HEAT_XTILT = XTILT
  HEAT_YTILT = YTILT
  HEAT_CNT   = N_HEAT_CNT
;
; Retrieve the save arrays' variables in the 2nd IDL save file.
; Note that they contain the same variable names as in the 1st IDL file.
;
  RESTORE, HEAT2DATA_FILE  ; TEMP, TIME, [X&Y]TILT, N_HEAT_CNT
;
   STATUS = CHECK_ORDER( TIME )
   PRINT,  'CHECK_ORDER( TIME ): ', STATUS
IF STATUS EQ 1 THEN  BEGIN  ; TIMEs are in orider.
   PRINT, 'The 1st set of HEAT data times are OK!'
ENDIF  ELSE  BEGIN  ; STATUS Not = 1
   PRINT, 'The 1st set of HEAT data times are Not in order!'
   STOP,  'Are the values OK?  Type .CON to continue or RETURN to stop.'
ENDELSE
;
; Join the 1st & 2nd data sets together.
;
  HEAT_TIME  = [ TEMPORARY( HEAT_TIME  ), TIME  ]
  HEAT_TEMP  = [ TEMPORARY( HEAT_TEMP  ), TEMP  ]
  HEAT_XTILT = [ TEMPORARY( HEAT_XTILT ), XTILT ]
  HEAT_YTILT = [ TEMPORARY( HEAT_YTILT ), YTILT ]
  HEAT_CNT  += N_HEAT_CNT
;
  PRINT, 'Data are joined.'
  HELP , NAME='*'  ; Show all the variables.
;
  STATUS = CHECK_ORDER( HEAT_TIME )
  PRINT,  'CHECK_ORDER( HEAT_TIME ): ', STATUS
;
IF STATUS EQ 0 THEN  BEGIN
   PRINT, 'HEAT_TIMEs has some repeated data.'
   STOP,  'Type .CON to continue to Update or RETURN to stop.'
ENDIF
;
IF STATUS LT 0 THEN  BEGIN
   PRINT, 'Updated HEAT_TIMEs are Not in order!'
   STOP, 'Check out the data and Type .CON to continue or RETURN to stop.'
ENDIF
;
IF STATUS EQ 1 THEN  BEGIN
;  Switch the arrays' variables & their contents.
   SWITCH_VARIABLES,       TIME, HEAT_TIME
   SWITCH_VARIABLES,       TEMP, HEAT_TEMP
   SWITCH_VARIABLES,      XTILT, HEAT_XTILT
   SWITCH_VARIABLES,      YTILT, HEAT_YTILT
   SWITCH_VARIABLES, N_HEAT_CNT, HEAT_CNT
   SAVE, FILE=JOIN_DATA_FILE, TEMP, TIME, XTILT, YTILT, N_HEAT_CNT
   PRINT, 'File: ' + JOIN_DATA_FILE + ' Updated.'
   HELP , NAME='*'  ; Show all the variables.
ENDIF
;
RETURN
END  ; RSN_JOIN_HEAT_DATA
;
; Callers: Users.
;
PRO RSN_JOIN_IRIS_DATA, IRIS1DATA_FILE, IRIS2DATA_FILE, JOIN_DATA_FILE
;
; Retrieve the save arrays' variables in the 1st IDL save file.
;
  RESTORE, IRIS1DATA_FILE  ; TEMP, TIME, [X&Y]TILT, N_IRIS_CNT
;
   STATUS = CHECK_ORDER( TIME )
   PRINT,  'CHECK_ORDER( TIME ): ', STATUS
IF STATUS EQ 1 THEN  BEGIN  ; TIMEs are in orider.
   PRINT, 'The 1st set of IRIS data times are OK!'
ENDIF  ELSE  BEGIN  ; STATUS Not = 1
   PRINT, 'The 1st set of IRIS data times are Not in order!'
   STOP,  'Are the values OK?  Type .CON to continue or RETURN to stop.'
ENDELSE
;
; Assign the data into a new array veriable names
;
  IRIS_TIME  = TIME
  IRIS_TEMP  = TEMP
  IRIS_XTILT = XTILT
  IRIS_YTILT = YTILT
  IRIS_CNT   = N_IRIS_CNT
;
; Retrieve the save arrays' variables in the 2nd IDL save file.
; Note that they contain the same variable names as in the 1st IDL file.
;
  RESTORE, IRIS2DATA_FILE  ; TEMP, TIME, [X&Y]TILT, N_IRIS_CNT
;
   STATUS = CHECK_ORDER( TIME )
   PRINT,  'CHECK_ORDER( TIME ): ', STATUS
IF STATUS EQ 1 THEN  BEGIN  ; TIMEs are in orider.
   PRINT, 'The 1st set of IRIS data times are OK!'
ENDIF  ELSE  BEGIN  ; STATUS Not = 1
   PRINT, 'The 1st set of IRIS data times are Not in order!'
   STOP,  'Are the values OK?  Type .CON to continue or RETURN to stop.'
ENDELSE
;
; Join the 1st & 2nd data sets together.
;
  IRIS_TIME  = [ TEMPORARY( IRIS_TIME  ), TIME  ]
  IRIS_TEMP  = [ TEMPORARY( IRIS_TEMP  ), TEMP  ]
  IRIS_XTILT = [ TEMPORARY( IRIS_XTILT ), XTILT ]
  IRIS_YTILT = [ TEMPORARY( IRIS_YTILT ), YTILT ]
  IRIS_CNT  += N_IRIS_CNT
;
  PRINT, 'Data are joined.'
  HELP , NAME='*'  ; Show all the variables.
;
  STATUS = CHECK_ORDER( IRIS_TIME )
  PRINT,  'CHECK_ORDER( IRIS_TIME ): ', STATUS
;
IF STATUS EQ 0 THEN  BEGIN
   PRINT, 'IRIS_TIMEs has some repeated data.'
   STOP,  'Type .CON to continue to Update or RETURN to stop.'
ENDIF
;
IF STATUS LT 0 THEN  BEGIN
   PRINT, 'Updated IRIS_TIMEs are Not in order!'
   STOP, 'Check out the data and Type .CON to continue or RETURN to stop.'
ENDIF
;
IF STATUS EQ 1 THEN  BEGIN
;  Switch the arrays' variables & their contents.
   SWITCH_VARIABLES,       TIME, IRIS_TIME
   SWITCH_VARIABLES,       TEMP, IRIS_TEMP
   SWITCH_VARIABLES,      XTILT, IRIS_XTILT
   SWITCH_VARIABLES,      YTILT, IRIS_YTILT
   SWITCH_VARIABLES, N_IRIS_CNT, IRIS_CNT
   SAVE, FILE=JOIN_DATA_FILE, TEMP, TIME, XTILT, YTILT, N_IRIS_CNT
   PRINT, 'File: ' + JOIN_DATA_FILE + ' Updated.'
   HELP , NAME='*'  ; Show all the variables.
ENDIF
;
RETURN
END  ; RSN_JOIN_IRIS_DATA
;
; Callers: Users.
;
PRO RSN_JOIN_LILY_DATA, LILY1DATA_FILE, LILY2DATA_FILE, JOIN_DATA_FILE
;
; Retrieve the save arrays' variables in the 1st IDL save file.
;
  RESTORE, LILY1DATA_FILE  ; TEMP, TIME, [X&Y]TILT, RTM, RTD, N_LILY_CNT
;
   STATUS = CHECK_ORDER( TIME )
   PRINT,  'CHECK_ORDER( TIME ): ', STATUS
IF STATUS EQ 1 THEN  BEGIN  ; TIMEs are in orider.
   PRINT, 'The 1st set of LILY data times are OK!'
ENDIF  ELSE  BEGIN  ; STATUS Not = 1
   PRINT, 'The 1st set of LILY data times are Not in order!'
   STOP,  'Are the values OK?  Type .CON to continue or RETURN to stop.'
ENDELSE
;
; Assign the data into a new array veriable names
;
  LILY_TIME  = TIME
  LILY_TEMP  = TEMP
  LILY_XTILT = XTILT
  LILY_YTILT = YTILT
  LILY_RTD   = RTD
  LILY_RTM   = RTM
  LILY_CNT   = N_LILY_CNT
;
; Retrieve the save arrays' variables in the 2nd IDL save file.
; Note that they contain the same variable names as in the 1st IDL file.
;
  RESTORE, LILY2DATA_FILE  ; TEMP, TIME, [X&Y]TILT, RTM, RTD, N_LILY_CNT
;
   STATUS = CHECK_ORDER( TIME )
   PRINT,  'CHECK_ORDER( TIME ): ', STATUS
IF STATUS EQ 1 THEN  BEGIN  ; TIMEs are in orider.
   PRINT, 'The 1st set of LILY data times are OK!'
ENDIF  ELSE  BEGIN  ; STATUS Not = 1
   PRINT, 'The 1st set of LILY data times are Not in order!'
   STOP,  'Are the values OK?  Type .CON to continue or RETURN to stop.'
ENDELSE
;
; Join the 1st & 2nd data sets together.
;
  LILY_TIME  = [ TEMPORARY( LILY_TIME  ), TIME  ]
  LILY_TEMP  = [ TEMPORARY( LILY_TEMP  ), TEMP  ]
  LILY_XTILT = [ TEMPORARY( LILY_XTILT ), XTILT ]
  LILY_YTILT = [ TEMPORARY( LILY_YTILT ), YTILT ]
  LILY_RTD   = [ TEMPORARY( LILY_RTD   ), RTD   ]
  LILY_RTM   = [ TEMPORARY( LILY_RTM   ), RTM   ]
  LILY_CNT  += N_LILY_CNT
;
  PRINT, 'Data are joined.'
  HELP , NAME='*'  ; Show all the variables.
;
  STATUS = CHECK_ORDER( LILY_TIME )
  PRINT,  'CHECK_ORDER( LILY_TIME ): ', STATUS
;
IF STATUS EQ 0 THEN  BEGIN
   PRINT, 'LILY_TIMEs has some repeated data.'
   STOP,  'Type .CON to continue to Update or RETURN to stop.'
ENDIF
;
IF STATUS LT 0 THEN  BEGIN
   PRINT, 'Updated LILY_TIMEs are Not in order!'
   STOP, 'Check out the data and Type .CON to continue or RETURN to stop.'
ENDIF
;
IF STATUS EQ 1 THEN  BEGIN
;  Switch the arrays' variables & their contents.
   SWITCH_VARIABLES,       TIME, LILY_TIME
   SWITCH_VARIABLES,       TEMP, LILY_TEMP
   SWITCH_VARIABLES,      XTILT, LILY_XTILT
   SWITCH_VARIABLES,      YTILT, LILY_YTILT
   SWITCH_VARIABLES,        RTD, LILY_RTD
   SWITCH_VARIABLES,        RTM, LILY_RTM
   SWITCH_VARIABLES, N_LILY_CNT, LILY_CNT
   SAVE, FILE=JOIN_DATA_FILE, TEMP, TIME, XTILT, YTILT, RTD, RTM, N_LILY_CNT
   PRINT, 'File: ' + JOIN_DATA_FILE + ' Updated.'
   HELP , NAME='*'  ; Show all the variables.
ENDIF
;
RETURN
END  ; RSN_JOIN_LILY_DATA
;
; Callers: RSN_DATA_INSERT
;
PRO RSN_INSERT_NANO_DATA, CUMULATIVE_NANO_DATA, OUTCASTED_NANO_DATA
;
; Retrieve the save arrays' variables in the IDL save files.
;
RESTORE, CUMULATIVE_NANO_DATA  ; NANO_TEMP, NANO_TIME, NANO_PSIA, NANO_DETIDE
RESTORE,  OUTCASTED_NANO_DATA  ; TIME, PSIA, TEMP, METER, N_NANO_CNT
;
PRINT, 'The Cumulative NANO Data (array) variables:'
HELP, NANO_TEMP, NANO_TIME, NANO_PSIA, NANO_DETIDE
PRINT, 'The Outcasted  NANO Data (array) variables:'
HELP, TIME, PSIA, TEMP, METER, N_NANO_CNT
;
   STATUS = CHECK_ORDER( TIME )
   PRINT,  'CHECK_ORDER( TIME ): ', STATUS
IF STATUS EQ 1 THEN  BEGIN
   PRINT, 'The Outcasted NANO data times are OK!'
ENDIF  ELSE  BEGIN
   PRINT, 'The Outcasted NANO data times are Not in order!'
   PRINT, 'No Data Insert will been done.'
   RETURN
ENDELSE
;
; Check the following conditions (from the Most to Least occurrence):
; NANO_TIME[0] < TIME[0]   < TIME[N_NANO_CNT-1] <  NANO_TIME[N-1],
; TIME[0] < NANO_TIME[N-1] < TIME[N_NANO_CNT-1],
; TIME[0] < NANO_TIME[0]   < TIME[N_NANO_CNT-1],
; TIME[N_NANO_CNT-1] < NANO_TIME[0], NANO_TIME[N-1] < TIME[0]
;
I = CHECK_PT_STATUS( NANO_TIME, TIME[0] )
J = CHECK_PT_STATUS( NANO_TIME, TIME[N_NANO_CNT-1] )
N = N_ELEMENTS( NANO_TIME )
;
STATUS = 'No Update'
;
HELP, I, J, N, STATUS
;
IF ( I EQ 0.5 ) AND ( J EQ 0.5 ) THEN  BEGIN
;  NANO_TIME[0] < TIME[0] < TIME[N_NANO_CNT-1] < NANO_TIME[N-1]
   I = LOCATE_TIME_POSITION( NANO_TIME, TIME[0] )
   J = LOCATE_TIME_POSITION( NANO_TIME, TIME[N_NANO_CNT-1] )
;  Note that NANO_TIME[I-1] <= TIME[0] & TIME[N_NANO_CNT-1] < NANO_TIME[J]
   HELP, I, J, N_NANO_CNT, N  ; Check out the values.
   PRINT, FORMAT="(C(),' - ',C())",  NANO_TIME[I-1], NANO_TIME[J-1],  $
                                     TIME[0],    TIME[N_NANO_CNT-1]
   STOP, 'Are the values OK?  Type .CON to continue or RETURN to stop.'
   NANO_TEMP   = [ NANO_TEMP  [0:I-2],  TEMP,  NANO_TEMP  [J:N-1] ]
   NANO_TIME   = [ NANO_TIME  [0:I-2],  TIME,  NANO_TIME  [J:N-1] ]
   NANO_PSIA   = [ NANO_PSIA  [0:I-2],  PSIA,  NANO_PSIA  [J:N-1] ]
   NANO_DETIDE = [ NANO_DETIDE[0:I-2], METER,  NANO_DETIDE[J:N-1] ]
   STATUS      = 'Updated'
ENDIF ELSE IF ( I LE 1 ) AND ( J GT 1 ) THEN  BEGIN
;  TIME[0] <= NANO_TIME[N-1] < TIME[N_NANO_CNT-1]
   I = LOCATE_TIME_POSITION( TIME, NANO_TIME[N-1] )
   HELP, I,    N_NANO_CNT, N  ; Check out the values.
   PRINT, FORMAT="(C(),' = ',C())",  TIME[I-1], NANO_TIME[N-1]
   STOP, 'Are the values OK?  Type .CON to continue or RETURN to stop.'
   NANO_TEMP   = [ TEMPORARY( NANO_TEMP  ),   TEMP[I:N_NANO_CNT-1] ]
   NANO_TIME   = [ TEMPORARY( NANO_TIME  ),   TIME[I:N_NANO_CNT-1] ]
   NANO_PSIA   = [ TEMPORARY( NANO_PSIA  ),   PSIA[I:N_NANO_CNT-1] ]
   NANO_DETIDE = [ TEMPORARY( NANO_DETIDE), DETIDE[I:N_NANO_CNT-1] ]
   STATUS      = 'Updated'
ENDIF ELSE IF ( I LE 0 ) AND ( J EQ 0.5 ) THEN  BEGIN
;  TIME[0] < NANO_TIME[0]   < TIME[N_NANO_CNT-1]
   J = LOCATE_TIME_POSITION( TIME, NANO_TIME[0] )
   HELP,    J, N_NANO_CNT, N  ; Check out the values.
   PRINT, FORMAT="(C(),' = ',C())",  TIME[J-1], NANO_TIME[0]
   STOP, 'Are the values OK?  Type .CON to continue or RETURN to stop.'
   NANO_TEMP   = [   TEMP[0:J-1], TEMPORARY( NANO_TEMP   ) ]
   NANO_TIME   = [   TIME[0:J-1], TEMPORARY( NANO_TIME   ) ]
   NANO_PSIA   = [   PSIA[0:J-1], TEMPORARY( NANO_PSIA   ) ]
   NANO_DETIDE = [ DETIDE[0:J-1], TEMPORARY( NANO_DETIDE ) ]
   STATUS      = 'Updated'
ENDIF ELSE IF ( J LT 0 ) THEN  BEGIN
;  TIME[0] <  TIME[N_NANO_CNT-1] < NANO_TIME[0]
   PRINT, FORMAT="(C(),' < ',C(),' < ',C())",  $
          TIME[0], TIME[N_NANO_CNT-1], NANO_TIME[0]
   STOP, 'Are the values OK?  Type .CON to continue or RETURN to stop.'
   NANO_TEMP   = [ TEMPORARY( NANO_TEMP  ),  TEMPORARY(  TEMP  ) ]
   NANO_TIME   = [ TEMPORARY( NANO_TIME  ),  TEMPORARY(  TIME  ) ]
   NANO_PSIA   = [ TEMPORARY( NANO_PSIA  ),  TEMPORARY(  PSIA  ) ]
   NANO_DETIDE = [ TEMPORARY( NANO_DETIDE ), TEMPORARY( DETIDE ) ]
   STATUS      = 'Updated'
ENDIF ELSE BEGIN  ; Assume ( I GT 1 )
;  NANO_TIME[N-1] < TIME[0] <  TIME[N_NANO_CNT-1]
   PRINT, FORMAT="(C(),' < ',C(),' < ',C())",  $
          NANO_TIME[N-1], TIME[0],  TIME[N_NANO_CNT-1]
   STOP, 'Are the values OK?  Type .CON to continue or RETURN to stop.'
   NANO_TEMP   = [ TEMPORARY(  TEMP  ), TEMPORARY( NANO_TEMP   ) ]
   NANO_TIME   = [ TEMPORARY(  TIME  ), TEMPORARY( NANO_TIME   ) ]
   NANO_PSIA   = [ TEMPORARY(  PSIA  ), TEMPORARY( NANO_PSIA   ) ]
   NANO_DETIDE = [ TEMPORARY( DETIDE ), TEMPORARY( NANO_DETIDE ) ]
   STATUS      = 'Updated'
ENDELSE
;
    N = CHECK_ORDER( NANO_TIME )
PRINT, 'CHECK_ORDER( NANO_TIME ): ', N
;
IF N EQ 0 THEN  BEGIN
   PRINT, 'NANO_TIMEs has some repeated data.'
   STOP,  'Type .CON to continue to Update or RETURN to stop.'
ENDIF
;
IF STATUS EQ 'Updated' THEN  BEGIN
   IF CHECK_ORDER( NANO_TIME ) LT 0 THEN  BEGIN
      STATUS = 'No Updated'
      PRINT, 'Updated NANO_TIMEs are Not in order!'
       STOP, 'Check out the data and Type .CON to continue or RETURN to stop.'
   ENDIF
ENDIF
;
IF STATUS EQ 'Updated' THEN  BEGIN
   SAVE, FILE=CUMULATIVE_NANO_DATA,  $
         NANO_TEMP, NANO_TIME, NANO_PSIA, NANO_DETIDE
   PRINT, 'File: ' + CUMULATIVE_NANO_DATA + ' Updated.'
   HELP, NANO_TEMP, NANO_TIME, NANO_PSIA, NANO_DETIDE
ENDIF
;
RETURN
END  ; RSN_INSERT_NANO_DATA
;
; Callers: Users.
; Revised: October 27, 2014
;
PRO REMOVE_TAIL_HEAT,  I,  $  ; Input: Index of the Splitting points.
    HEAT_TEMP,  HEAT_TIME, HEAT_XTILT, HEAT_YTILT  ; I/O: 1-D arrays.
;
; Keep only the [0:I-1] data in HEAT* arrays' variables
; and the data in [I:*] will be discarded.
; 
                  TMP  = HEAT_TIME [0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   HEAT_TIME
                  TMP  = HEAT_TEMP [0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   HEAT_TEMP
                  TMP  = HEAT_XTILT[0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   HEAT_XTILT
                  TMP  = HEAT_YTILT[0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   HEAT_YTILT
;
RETURN
END  ; REMOVE_TAIL_HEAT
;
; Callers: Users.
; Revised: October 27, 2014
;
PRO REMOVE_TAIL_IRIS,  I,  $  ; Input: Index of the Splitting points.
    IRIS_TEMP,  IRIS_TIME, IRIS_XTILT, IRIS_YTILT  ; I/O: 1-D arrays.
;
; Keep only the [0:I-1] data in IRIS* arrays' variables
; and the data in [I:*] will be discarded.
; 
                  TMP  = IRIS_TIME [0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   IRIS_TIME
                  TMP  = IRIS_TEMP [0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   IRIS_TEMP
                  TMP  = IRIS_XTILT[0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   IRIS_XTILT
                  TMP  = IRIS_YTILT[0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   IRIS_YTILT
;
RETURN
END  ; REMOVE_TAIL_HEAT
;
; Callers: Users.
; Revised: October 27, 2014
;
PRO REMOVE_TAIL_LILY,   I,  $  ; Input: Index of the Splitting points.
                LILY_TIME,  LILY_TEMP,   $  ; I/O
                LILY_XTILT, LILY_YTILT,  $  ; I/O
                LILY_RTD,   LILY_RTM        ; I/O
;  
; Get the 1st part of the data [0:I-1] from the LILY_* arrays. 
;  
TIME  = LILY_TIME [0:I-1]
TEMP  = LILY_TEMP [0:I-1]
XTILT = LILY_XTILT[0:I-1]
YTILT = LILY_YTILT[0:I-1]
RTD   = LILY_RTD  [0:I-1]
RTM   = LILY_RTM  [0:I-1]
;  
; Store the 1st part of the data Back to the LILY_* arrays' variables.
; i.e., the data in [I:*] of LILY_* arrays' variables will be discarded.
;
SWITCH_VARIABLES,  TIME, LILY_TIME
SWITCH_VARIABLES,  TEMP, LILY_TEMP
SWITCH_VARIABLES, XTILT, LILY_XTILT
SWITCH_VARIABLES, YTILT, LILY_YTILT
SWITCH_VARIABLES,   RTD, LILY_RTD
SWITCH_VARIABLES,   RTM, LILY_RTM
;  
RETURN
END  ; REMOVE_TAIL_LILY
;
; Callers: Users.
; Revised: October 27, 2014
;
PRO REMOVE_TAIL_NANO,  I,  $  ; Input: Index of the Splitting points.
    NANO_TEMP,  NANO_TIME, NANO_PSIA, NANO_DETIDE  ; I/O: 1-D arrays.
;
; Keep only the [0:I-1] data in NANO* arrays' variables
; and the data in [I:*] will be discarded.
; 
                  TMP  = NANO_TIME[0:I-1]    ; Part of data to be save.
SWITCH_VARIABLES, TMP,   NANO_TIME
                  TMP  = NANO_TEMP[0:I-1]    ; Part of data to be save.
SWITCH_VARIABLES, TMP,   NANO_TEMP
                  TMP  = NANO_PSIA[0:I-1]    ; Part of data to be save.
SWITCH_VARIABLES, TMP,   NANO_PSIA
                  TMP  = NANO_DETIDE[0:I-1]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   NANO_DETIDE
;
RETURN
END  ; REMOVE_TAIL_HEAT
;
; Callers: Users.
; Revised: October 28, 2014
;
PRO SPLIT_HEAT,        I,      $ ; Input: Index of the Splitting points.
    HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT,  $  ; I/O: 1-D arrays.
         TIME,      TEMP,      XTILT,      YTILT   ; Output: 1-D arrays.
;
; Get the 1st part of the data [0:I-1] from the HEAT_* arrays.
;
TIME  = HEAT_TIME [0:I-1]
TEMP  = HEAT_TEMP [0:I-1]
XTILT = HEAT_XTILT[0:I-1]
YTILT = HEAT_YTILT[0:I-1]
;
; Get the 2nd part of the data [I:*] from the HEAT_* arrays  and
; Store the 2nd part of the data Back to the  HEAT_* arrays' variables.
; 
                  TMP  = HEAT_TIME [I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   HEAT_TIME
                  TMP  = HEAT_TEMP [I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   HEAT_TEMP
                  TMP  = HEAT_XTILT[I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   HEAT_XTILT
                  TMP  = HEAT_YTILT[I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   HEAT_YTILT
;
RETURN
END  ; SPLIT_HEAT
;
; This procedure will be used to break the cumulative data stored in
; the IDL save file into 2 files.  For example when the cumulative
; data reach across a new year: 2015 e.g. Then the MJ03?-HEAT.idl
; will be splited into 2 file: MJ03?2014HEAT.idl and the Store only
; the new year's data back to MJ03?-HEAT.idl.
;
; Callers: Users.
; Revised: October 28, 2014
;
PRO SPLIT_HEAT2FILES, IDL_FILE,  $ ; Input: e.g. 'MJ03E-HEAT.idl'
                    IDL_A_FILE,  $ ; Input: Output file name.
                    IDL_B_FILE,  $ ; Input: Output file name.
                    I              ; Input: Index of the Splitting point.
;
; IDL_FILE   contains the cumulative RSN data.
; IDL_A_FILE will be used for storing the 1st part of the cumulative
;            RSN data, e.g. the previous year's data.
; IDL_B_FILE will be used for storing the 2nd part or the remaining of
;            the cumulative RSN data, e.g. the new year's data.
;
; Get the HEAT (1-D arrays) variables:
;         HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT
; Note that all the HEAT_* arrays are the same sizes.
;
  RESTORE, IDL_FILE
;
; If the Index of the Splitting point (I) is Not provided,
; then assuming the the Splitting point will the New Year
; and Locate the Index for the New Year Position.
;
IF N_PARAMS( ) LE 3 THEN  BEGIN  ; No Splitting point Index is provided.
;  Locate the Index for the New Year Position.
   I = NEW_YEAR_POSITION( HEAT_TIME )
   IF I LE 0 THEN  BEGIN
      PRINT, 'Warning: No New Year is found!'
   ENDIF  ELSE  BEGIN
      PRINT, 'New Year Index: ', I
      PRINT, 'And Time Check: '
      PRINT, FORMAT='(C())', HEAT_TIME[I-1:I+1]
   ENDELSE
ENDIF
;
  HELP, I   ; Show the index values.
  HELP, HEAT_TIME,HEAT_TEMP, HEAT_XTILT,HEAT_YTILT
  STOP      ; Wait for the next move.
;
; At this point assuming the index I is set and it is OK to split
; the RSN data into 2 parts.
;
  SPLIT_HEAT,   I,  $  ; Input: Index of the Splitting points.
        HEAT_TIME,  HEAT_TEMP,   $    ; I/O
        HEAT_XTILT, HEAT_YTILT,  $    ; I/O
        TIME,TEMP, XTILT,YTILT   ; Output: 1-D arrays.
;
  HELP, HEAT_TIME,HEAT_TEMP, HEAT_XTILT,HEAT_YTILT, I, TIME,TEMP, XTILT,YTILT
  STOP      ; Wait for the next move.
;
; Now the all the HEAT_* arrays contain the data from [I:N-1] and the
; Reset of the arrays: TIME, TEMP, etc. contain the data from [0:I-1].
;
; Save the 2nd part of the data [I:N-1] into a new file name.
;
  SAVE, FILE=IDL_B_FILE,  HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT
  PRINT, '2nd Part of Data have been saved into the file: ' + IDL_B_FILE 
;
; Switch the arrays' variables so the HEAT_* arrays will contain
; the 1st part of the data [0:I-1].
;
  SWITCH_VARIABLES,  TIME, HEAT_TIME
  SWITCH_VARIABLES,  TEMP, HEAT_TEMP
  SWITCH_VARIABLES, XTILT, HEAT_XTILT
  SWITCH_VARIABLES, YTILT, HEAT_YTILT
;
; Save the 1st part of the data [0:I-1] into a new file name.
;
  SAVE, FILE=IDL_A_FILE,  HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT
  PRINT, '1st Part of Data have been saved into the file: ' + IDL_A_FILE 
;
RETURN
END  ; SPLIT_HEAT2FILES
;
; Callers: Users.
; Revised: October 28, 2014
;
PRO SPLIT_IRIS,        I,      $ ; Input: Index of the Splitting points.
    IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT,  $  ; I/O: 1-D arrays.
         TIME,      TEMP,      XTILT,      YTILT   ; Output: 1-D arrays.
;
; Get the 1st part of the data [0:I-1] from the IRIS_* arrays.
;
TIME  = IRIS_TIME [0:I-1]
TEMP  = IRIS_TEMP [0:I-1]
XTILT = IRIS_XTILT[0:I-1]
YTILT = IRIS_YTILT[0:I-1]
;
; Get the 2nd part of the data [I:*] from the IRIS_* arrays  and
; Store the 2nd part of the data Back to the  IRIS_* arrays' variables.
; 
                  TMP  = IRIS_TIME [I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   IRIS_TIME
                  TMP  = IRIS_TEMP [I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   IRIS_TEMP
                  TMP  = IRIS_XTILT[I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   IRIS_XTILT
                  TMP  = IRIS_YTILT[I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   IRIS_YTILT
;
RETURN
END  ; SPLIT_IRIS
;
; This procedure will be used to break the cumulative data stored in
; the IDL save file into 2 files.  For example when the cumulative
; data reach across a new year: 2015 e.g. Then the MJ03?-IRIS.idl
; will be splited into 2 file: MJ03?2014IRIS.idl and the Store only
; the new year's data back to MJ03?-IRIS.idl.
;
; Callers: Users.
; Revised: October 28, 2014
;
PRO SPLIT_IRIS2FILES, IDL_FILE,  $ ; Input: e.g. 'MJ03F-IRIS.idl'
                    IDL_A_FILE,  $ ; Input: Output file name.
                    IDL_B_FILE,  $ ; Input: Output file name.
                    I              ; Input: Index of the Splitting point.
;
; IDL_FILE   contains the cumulative RSN data.
; IDL_A_FILE will be used for storing the 1st part of the cumulative
;            RSN data, e.g. the previous year's data.
; IDL_B_FILE will be used for storing the 2nd part or the remaining of
;            the cumulative RSN data, e.g. the new year's data.
;
; Get the IRIS (1-D arrays) variables:
;         IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT
; Note that all the IRIS_* arrays are the same sizes.
;
  RESTORE, IDL_FILE
;
; If the Index of the Splitting point (I) is Not provided,
; then assuming the the Splitting point will the New Year
; and Locate the Index for the New Year Position.
;
IF N_PARAMS( ) LE 3 THEN  BEGIN  ; No Splitting point Index is provided.
;  Locate the Index for the New Year Position.
   I = NEW_YEAR_POSITION( IRIS_TIME )
   IF I LE 0 THEN  BEGIN
      PRINT, 'Warning: No New Year is found!'
   ENDIF  ELSE  BEGIN
      PRINT, 'New Year Index: ', I
      PRINT, 'And Time Check: '
      PRINT, FORMAT='(C())', IRIS_TIME[I-1:I+1]
   ENDELSE
ENDIF
;
  HELP, I   ; Show the index values.
  HELP, IRIS_TIME,IRIS_TEMP, IRIS_XTILT,IRIS_YTILT
  STOP      ; Wait for the next move.
;
; At this point assuming the index I is set and it is OK to split
; the RSN data into 2 parts.
;
  SPLIT_IRIS,   I,  $  ; Input: Index of the Splitting points.
        IRIS_TIME,  IRIS_TEMP,   $    ; I/O
        IRIS_XTILT, IRIS_YTILT,  $    ; I/O
        TIME,TEMP, XTILT,YTILT   ; Output: 1-D arrays.
;
  HELP, IRIS_TIME,IRIS_TEMP, IRIS_XTILT,IRIS_YTILT, I, TIME,TEMP, XTILT,YTILT
  STOP      ; Wait for the next move.
;
; Now the all the IRIS_* arrays contain the data from [I:N-1] and the
; Reset of the arrays: TIME, TEMP, etc. contain the data from [0:I-1].
;
; Save the 2nd part of the data [I:N-1] into a new file name.
;
  SAVE, FILE=IDL_B_FILE,  IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT
  PRINT, '2nd Part of Data have been saved into the file: ' + IDL_B_FILE 
;
; Switch the arrays' variables so the IRIS_* arrays will contain
; the 1st part of the data [0:I-1].
;
  SWITCH_VARIABLES,  TIME, IRIS_TIME
  SWITCH_VARIABLES,  TEMP, IRIS_TEMP
  SWITCH_VARIABLES, XTILT, IRIS_XTILT
  SWITCH_VARIABLES, YTILT, IRIS_YTILT
;
; Save the 1st part of the data [0:I-1] into a new file name.
;
  SAVE, FILE=IDL_A_FILE,  IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT
  PRINT, '1st Part of Data have been saved into the file: ' + IDL_A_FILE 
;
RETURN
END  ; SPLIT_IRIS2FILES
;
; Callers: Users.
;
PRO SPLIT_LILY,      I,  $  ; Input: Index of the Splitting points.
                LILY_TIME,  LILY_TEMP,   $  ; I/O
                LILY_XTILT, LILY_YTILT,  $  ; I/O
                LILY_RTD,   LILY_RTM,    $  ; I/O
    TIME, TEMP, XTILT, YTILT, RTD, RTM      ; Output: 1-D arrays.
;
; Get the 1st part of the data [0:I-1] from the LILY_* arrays.
;
TIME  = LILY_TIME [0:I-1]
TEMP  = LILY_TEMP [0:I-1]
XTILT = LILY_XTILT[0:I-1]
YTILT = LILY_YTILT[0:I-1]
RTD   = LILY_RTD  [0:I-1]
RTM   = LILY_RTM  [0:I-1]
;
; Get the 2nd part of the data [I:*] from the LILY_* arrays and
; Store the 2nd part of the data Back to the LILY_* arrays' variables.
;
     TMP   = LILY_TIME [I:*]   ; Get the 2nd part 1st.
SWITCH_VARIABLES, TMP, LILY_TIME
     TMP   = LILY_TEMP [I:*]   ; Get the 2nd part 1st.
SWITCH_VARIABLES, TMP, LILY_TEMP
     TMP   = LILY_XTILT[I:*]   ; Get the 2nd part 1st.
SWITCH_VARIABLES, TMP, LILY_XTILT
     TMP  = LILY_YTILT[I:*]    ; Get the 2nd part 1st.
SWITCH_VARIABLES, TMP, LILY_YTILT
     TMP   = LILY_RTD[I:*]     ; Get the 2nd part 1st.
SWITCH_VARIABLES, TMP, LILY_RTD
     TMP   = LILY_RTM[I:*]     ; Get the 2nd part 1st.
SWITCH_VARIABLES, TMP, LILY_RTM
;
RETURN
END  ; SPLIT_LILY 
;
; This procedure will be used to break the cumulative data stored in
; the IDL save file into 2 files.  For example when the cumulative
; data reach across a new year: 2015 e.g. Then the MJ03?-LILY.idl
; will be splited into 2 file: MJ03?2014LILY.idl and the Store only
; the new year's data back to MJ03?-LILY.idl.
;
; Callers: Users.
; Revised: October 28, 2014
;
PRO SPLIT_LILY2FILES, IDL_FILE,  $ ; Input: e.g. 'MJ03D-LILY.idl'
                    IDL_A_FILE,  $ ; Input: Output file name.
                    IDL_B_FILE,  $ ; Input: Output file name.
                    I              ; Input: Index of the Splitting point.
;
; IDL_FILE   contains the cumulative RSN data.
; IDL_A_FILE will be used for storing the 1st part of the cumulative
;            RSN data, e.g. the previous year's data.
; IDL_B_FILE will be used for storing the 2nd part or the remaining of
;            the cumulative RSN data, e.g. the new year's data.
;
; Get the LILY (1-D arrays) variables: LILY_TIME, LILY_TEMP,
;              LILY_XTILT, LILY_YTILT, LILY_RTD,  LILY_RTM,
; Note that all the LILY_* arrays are the same sizes.
;
  RESTORE, IDL_FILE
;
; If the Index of the Splitting point (I) is Not provided,
; then assuming the the Splitting point will the New Year
; and Locate the Index for the New Year Position.
;
IF N_PARAMS( ) LE 3 THEN  BEGIN  ; No Splitting point Index is provided.
;  Locate the Index for the New Year Position.
   I = NEW_YEAR_POSITION( LILY_TIME )
   IF I LE 0 THEN  BEGIN
      PRINT, 'Warning: No New Year is found!'
   ENDIF  ELSE  BEGIN
      PRINT, 'New Year Index: ', I
      PRINT, 'And Time Check: '
      PRINT, FORMAT='(C())', LILY_TIME[I-1:I+1]
   ENDELSE
ENDIF
;
  HELP, I             ; Show the index values.
  HELP, NAME='LILY*'  ; and All the LILY_* arrays.
  STOP                ; Wait for the next move.
;
; At this point assuming the index I is set and it is OK to split
; the RSN data into 2 parts.
;
  SPLIT_LILY,   I,  $  ; Input: Index of the Splitting points.
        LILY_TIME,  LILY_TEMP,   $    ; I/O
        LILY_XTILT, LILY_YTILT,  $    ; I/O
        LILY_RTD,   LILY_RTM,    $    ; I/O
  TIME, TEMP, XTILT, YTILT, RTD, RTM  ; Output: 1-D arrays.
;
  HELP, NAME='*'      ; Show all the variables.
  STOP                ; Wait for the next move.
;
; Now the all the LILY_* arrays contain the data from [I:N-1] and the
; Reset of the arrays: TIME, TEMP, etc. contain the data from [0:I-1].
;
; Save the 2nd part of the data [I:N-1] into a new file name.
;
  SAVE, FILE=IDL_B_FILE,  LILY_TIME, LILY_TEMP,  $
        LILY_XTILT, LILY_YTILT, LILY_RTD, LILY_RTM
  PRINT, '2nd Part of Data have been saved into the file: ' + IDL_B_FILE 
;
; Switch the arrays' variables so the LILY_* arrays will contain
; the 1st part of the data [0:I-1].
;
  SWITCH_VARIABLES,  TIME, LILY_TIME
  SWITCH_VARIABLES,  TEMP, LILY_TEMP
  SWITCH_VARIABLES, XTILT, LILY_XTILT
  SWITCH_VARIABLES, YTILT, LILY_YTILT
  SWITCH_VARIABLES,   RTD, LILY_RTD
  SWITCH_VARIABLES,   RTM, LILY_RTM
;
; Save the 1st part of the data [0:I-1] into a new file name.
;
  SAVE, FILE=IDL_A_FILE,  LILY_TIME, LILY_TEMP,  $
        LILY_XTILT, LILY_YTILT, LILY_RTD, LILY_RTM
  PRINT, '1st Part of Data have been saved into the file: ' + IDL_A_FILE 
;
RETURN
END  ; SPLIT_LILY2FILES
;
; Callers: Users.
; Revised: October 28, 2014
;
PRO SPLIT_NANO,        I,      $ ; Input: Index of the Splitting points.
    NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE,  $  ; I/O: 1-D arrays.
         TIME,      TEMP,      PSIA,      DETIDE   ; Output: 1-D arrays.
;
; Get the 1st part of the data [0:I-1] from the NANO_* arrays.
;
TIME   = NANO_TIME  [0:I-1]
TEMP   = NANO_TEMP  [0:I-1]
PSIA   = NANO_PSIA  [0:I-1]
DETIDE = NANO_DETIDE[0:I-1]
;
; Get the 2nd part of the data [I:*] from the NANO_* arrays  and
; Store the 2nd part of the data Back to the  NANO_* arrays' variables.
; 
                  TMP  = NANO_TIME[I:*]    ; Part of data to be save.
SWITCH_VARIABLES, TMP,   NANO_TIME
                  TMP  = NANO_TEMP[I:*]    ; Part of data to be save.
SWITCH_VARIABLES, TMP,   NANO_TEMP
                  TMP  = NANO_PSIA[I:*]    ; Part of data to be save.
SWITCH_VARIABLES, TMP,   NANO_PSIA
                  TMP  = NANO_DETIDE[I:*]  ; Part of data to be save.
SWITCH_VARIABLES, TMP,   NANO_DETIDE
;
RETURN
END  ; SPLIT_NANO
;
; This procedure will be used to break the cumulative data stored in
; the IDL save file into 2 files.  For example when the cumulative
; data reach across a new year: 2015 e.g. Then the MJ03?-NANO.idl
; will be splited into 2 file: MJ03?2014NANO.idl and the Store only
; the new year's data back to MJ03?-NANO.idl.
;
; Callers: Users.
; Revised: October 28, 2014
;
PRO SPLIT_NANO2FILES, IDL_FILE,  $ ; Input: e.g. 'MJ03F-NANO.idl'
                    IDL_A_FILE,  $ ; Input: Output file name.
                    IDL_B_FILE,  $ ; Input: Output file name.
                    I              ; Input: Index of the Splitting point.
;
; IDL_FILE   contains the cumulative RSN data.
; IDL_A_FILE will be used for storing the 1st part of the cumulative
;            RSN data, e.g. the previous year's data.
; IDL_B_FILE will be used for storing the 2nd part or the remaining of
;            the cumulative RSN data, e.g. the new year's data.
;
; Get the NANO (1-D arrays) variables: NANO_TIME, NANO_TEMP,
;                                 and  NANO_PSIA, NANO_DETIDE
; Note that all the NANO_* arrays are the same sizes.
;
  RESTORE, IDL_FILE
;
; If the Index of the Splitting point (I) is Not provided,
; then assuming the the Splitting point will the New Year
; and Locate the Index for the New Year Position.
;
IF N_PARAMS( ) LE 3 THEN  BEGIN  ; No Splitting point Index is provided.
;  Locate the Index for the New Year Position.
   I = NEW_YEAR_POSITION( NANO_TIME )
   IF I LE 0 THEN  BEGIN
      PRINT, 'Warning: No New Year is found!'
   ENDIF  ELSE  BEGIN
      PRINT, 'New Year Index: ', I
      PRINT, 'And Time Check: '
      PRINT, FORMAT='(C())', NANO_TIME[I-1:I+1]
   ENDELSE
ENDIF
;
  HELP, I             ; Show the index values.
  HELP, NAME='NANO*'  ; Show all the NANAO_* Arrays.
  STOP                ; Wait for the next move.
;
; At this point assuming the index I is set and it is OK to split
; the RSN data into 2 parts.
;
  SPLIT_NANO,   I,  $  ; Input: Index of the Splitting points.
        NANO_TIME,  NANO_TEMP,   $ ; I/O
        NANO_PSIA,  NANO_DETIDE, $ ; I/O
        TIME,TEMP,  PSIA,DETIDE    ; Output: 1-D arrays.
;
  HELP, NAME='*'      ; Show all the variables.
  STOP                ; Wait for the next move.
;
; Now the all the NANO_* arrays contain the data from [I:N-1] and the
; Reset of the arrays: TIME, TEMP, etc. contain the data from [0:I-1].
;
; Save the 2nd part of the data [I:N-1] into a new file name.
;
  SAVE, FILE=IDL_B_FILE,  NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE
  PRINT, '2nd Part of Data have been saved into the file: ' + IDL_B_FILE 
;
; Switch the arrays' variables so the NANO_* arrays will contain
; the 1st part of the data [0:I-1].
;
  SWITCH_VARIABLES,   TIME, NANO_TIME
  SWITCH_VARIABLES,   TEMP, NANO_TEMP
  SWITCH_VARIABLES,   PSIA, NANO_PSIA
  SWITCH_VARIABLES, DETIDE, NANO_DETIDE
;
; Save the 1st part of the data [0:I-1] into a new file name.
;
  SAVE, FILE=IDL_A_FILE,  NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE
  PRINT, '1st Part of Data have been saved into the file: ' + IDL_A_FILE 
;
RETURN
END  ; SPLIT_NANO2FILES
;
; Callers: Users.
;
PRO SWITCH_VARIABLES, A, B  ; I/O variable of any kind.
;
T = TEMPORARY( A )  ; Save A 1st.
A = TEMPORARY( B )  ; Put the contents in B into A.
B = TEMPORARY( T )  ; Put the contents in A into B.
;
RETURN
END  ; SWITCH_VARIABLES
