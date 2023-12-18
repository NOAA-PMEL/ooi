;
; File: GetShortTermDataSets.pro
;
; This IDL program will gerenate the Short-Term data sets
; to be stored into 3DayMJ03[D/E/F]-[HEAT/IRIS/LILY/NANO].idl
; which will be used for the RSN data processing programs.
;
; There are 2 sets of the procedures in this program.
;
; 1st Set: the GET_ST_[HEAT/IRIS/LILY/NANO]_DATA procedures.
; They are used to set up the initial Short-Term Data Set,
; usually 3-Days long before the RSN data processing starts.
;
; 2nd Set: the REDUCE_[HEAT/IRIS/LILY/NANO]_DATA procedures.
; They are used to set up the cumulative Data Set before the
; RSN data processing starts.
;
; Both sets of procedures will also be used for testings.
;
; This program requires the functions in the program: SplitRSNdata.pro
; in order to run.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on March     10th, 2015
; Created on March      5th, 2015
;

;
; This procedure will use the provided cumulative HEAT data set
; to created a Short-Term Data Set, usually 3-Day long.
;
; This procedure will also allow the users to Save the Short-Term
; data set into an IDL Save File.  Note that when that option is
; used, the Short-Term Data arrays will be named to the same
; arrays'names used in the the cumulative data set!
; 
; Callers: Users.
;
PRO GET_ST_HEAT_DATA,  HEAT_FILE,  $ ;  Input: 'MJ03D-HEAT.idl' e.g.
                          N_DAYS,  $ ;  Input: Number of days.
     TIME,  TEMP,  XTILT,  YTILT,  $ ; Output: Short-Term 1-D arrays.
    SAVE2FILE=IDL_FILE  ; Input: Save the Short-Term arrays into the IDL_FILE.
;   LTIME, LTEMP, LXTILT, LYTILT     ; Output:  Long-Term 1-D arrays.
;
  RESTORE, HEAT_FILE  ; to Get HEAT_TIME, HEAT_TEMP, HEAT_[X/Y]TILE.
;
  N = N_ELEMENTS( HEAT_TIME )  ; Total data points in the HEAT_* arrays.
;
; Get the Date of the last data point in the HEAT_* arrays.
;  
  CALDAT, HEAT_TIME[N-1], M, D, Y  ;, H, M, S
  PRINT, FORMAT='(A,C())', 'The Last HEAT Time: ', HEAT_TIME[N-1]
;
; Get the Time Indexes of the beginning of the 3 Days before
; and the beginning of the latest day.
; Note the function: LOCATE_TIME_POSITION() is in the
; file: ~/4Chadwick/RSN/SplitRSNdata.pro
;  
  S  = LOCATE_TIME_POSITION( HEAT_TIME, JULDAY( M, D-N_DAYS, Y, 0,0,0 ) )
; N  = LOCATE_TIME_POSITION( HEAT_TIME, JULDAY( M, D,     Y, 0,0,0 ) )
  N -= 1
;
; Assgin the Short-Term 1-D arrays.
;
   TIME  = HEAT_TIME [S:N]
   TEMP  = HEAT_TEMP [S:N]
   XTILT = HEAT_XTILT[S:N]
   YTILT = HEAT_YTILT[S:N]
;
   PRINT, 'The HEAT Short-Term Data Range is'
   PRINT, FORMAT='(C(),A,C())', HEAT_TIME[S], ' to ', HEAT_TIME[N]
;
; Get the Time Indexes of the beginning of the 3 day before.
; and the beginning of the N_DAYS before
; Note the function: LOCATE_TIME_POSITION() is in the
; file: ~/4Chadwick/RSN/SplitRSNdata.pro
;
; N  = S - 1
; S  = LOCATE_TIME_POSITION( HEAT_TIME, JULDAY( M, D-N_DAYS, Y, 0,0,0 ) )
; N  = LOCATE_TIME_POSITION( HEAT_TIME, JULDAY( M, D,        Y, 0,0,0 ) )
; N -= 1
;
; Assgin the  Long-Term 1-D arrays.
;
; LTIME  = HEAT_TIME [S:N]
; LTEMP  = HEAT_TEMP [S:N]
; LXTILT = HEAT_XTILT[S:N]
; LYTILT = HEAT_YTILT[S:N]
;
; Save the Short-Term Data Set if it is asked for.
;
IF KEYWORD_SET( IDL_FILE ) THEN  BEGIN  ; IDL_FILE is provided.
   HEAT_TIME  = 0  &  HEAT_TEMP  = 0    ; Free them before
   HEAT_XTILT = 0  &  HEAT_YTILT = 0    ; reusing them.
;  Rename the Short-Term 1-D arrays' names.
   HEAT_TIME  = TIME
   HEAT_TEMP  = TEMP
   HEAT_XTILT = XTILT
   HEAT_YTILT = YTILT
   SAVE, FILE=IDL_FILE, HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT
   PRINT, 'IDL Save File: ' + IDL_FILE + ' is created.'
ENDIF
;
RETURN
END  ; GET_ST_HEAT_DATA
;
; This procedure will use the provided cumulative IRIS data set
; to created a Short-Term Data Set, usually 3-Day long.
;
; This procedure will also allow the users to Save the Short-Term
; data set into an IDL Save File.  Note that when that option is
; used, the Short-Term Data arrays will be named to the same
; arrays'names used in the the cumulative data set!
;
; Callers: Users.
;
PRO GET_ST_IRIS_DATA,  IRIS_FILE,  $ ;  Input: 'MJ03E-IRIS.idl' e.g.
                          N_DAYS,  $ ;  Input: Number of days.
     TIME,  TEMP,  XTILT,  YTILT,  $ ; Output: Short-Term 1-D arrays.
    SAVE2FILE=IDL_FILE  ; Input: Save the Short-Term arrays into the IDL_FILE.
;
  RESTORE, IRIS_FILE  ; to Get IRIS_TIME, IRIS_TEMP, IRIS_[X/Y]TILE.
;
  N = N_ELEMENTS( IRIS_TIME )  ; Total data points in the IRIS_* arrays.
;
; Get the Date of the last data point in the IRIS_* arrays.
;  
  CALDAT, IRIS_TIME[N-1], M, D, Y  ;, H, M, S
  PRINT, FORMAT='(A,C())', 'The Last IRIS Time: ', IRIS_TIME[N-1]
;
; Get the Time Indexes of the beginning of the 3 Days before
; and the beginning of the latest day.
; Note the function: LOCATE_TIME_POSITION() is in the
; file: ~/4Chadwick/RSN/SplitRSNdata.pro
;  
  S  = LOCATE_TIME_POSITION( IRIS_TIME, JULDAY( M, D-N_DAYS, Y, 0,0,0 ) )
; N  = LOCATE_TIME_POSITION( IRIS_TIME, JULDAY( M, D,        Y, 0,0,0 ) )
  N -= 1
;
; Assgin the Short-Term 1-D arrays.
;
   TIME  = IRIS_TIME [S:N]
   TEMP  = IRIS_TEMP [S:N]
   XTILT = IRIS_XTILT[S:N]
   YTILT = IRIS_YTILT[S:N]
;
   PRINT, 'The IRIS Short-Term Data Range is'
   PRINT, FORMAT='(C(),A,C())', IRIS_TIME[S], ' to ', IRIS_TIME[N]
;
; Save the Short-Term Data Set if it is asked for.
;
IF KEYWORD_SET( IDL_FILE ) THEN  BEGIN  ; IDL_FILE is provided.
   IRIS_TIME  = 0  &  IRIS_TEMP  = 0    ; Free them before
   IRIS_XTILT = 0  &  IRIS_YTILT = 0    ; reusing them.
;  Rename the Short-Term 1-D arrays' names.
   IRIS_TIME  = TIME
   IRIS_TEMP  = TEMP
   IRIS_XTILT = XTILT
   IRIS_YTILT = YTILT
   SAVE, FILE=IDL_FILE, IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT
   PRINT, 'IDL Save File: ' + IDL_FILE + ' is created.'
ENDIF
;
RETURN
END  ; GET_ST_IRIS_DATA
;
; This procedure will use the provided cumulative LILY data set
; to created a Short-Term Data Set, usually 3-Day long.
;
; This procedure will also allow the users to Save the Short-Term
; data set into an IDL Save File.  Note that when that option is
; used, the Short-Term Data arrays will be named to the same
; arrays'names used in the the cumulative data set!
;
; Callers: Users.
;
PRO GET_ST_LILY_DATA,  LILY_FILE,  $ ;  Input: 'MJ03F-LILY.idl' e.g.
                          N_DAYS,  $ ;  Input: Number of days.
     TIME,  TEMP,  XTILT,  YTILT,  $ ; Output: Short-Term 1-D arrays.
                   RTM,    RTD,    $
    SAVE2FILE=IDL_FILE  ; Input: Save the Short-Term arrays into the IDL_FILE.
;
; Retrieve the LILY 1-D DATA arrays: LILY_TIME, LILY_TEMP,
; LILY_[X/Y]TILE, LILY_RTM, and LILY_RTD
;
  RESTORE, LILY_FILE  ;
;
  N = N_ELEMENTS( LILY_TIME )  ; Total data points in the LILY_* arrays.
;
; Get the Date of the last data point in the LILY_* arrays.
;  
  CALDAT, LILY_TIME[N-1], M, D, Y  ;, H, M, S
  PRINT, FORMAT='(A,C())', 'The Last LILY Time: ', LILY_TIME[N-1]
;
; Get the Time Indexes of the beginning of the 3 Days before.
; Note the function: LOCATE_TIME_POSITION() is in the
; file: ~/4Chadwick/RSN/SplitRSNdata.pro
;  
  S  = LOCATE_TIME_POSITION( LILY_TIME, JULDAY( M, D-N_DAYS, Y, 0,0,0 ) )
  N -= 1  ; Index for the last data point in the LILY_* arrays.
;
; Assgin the Short-Term 1-D arrays.
;
   TIME  = LILY_TIME [S:N]
   TEMP  = LILY_TEMP [S:N]
   XTILT = LILY_XTILT[S:N]
   YTILT = LILY_YTILT[S:N]
   RTM   = LILY_RTM  [S:N]
   RTD   = LILY_RTD  [S:N]
;
   PRINT, 'The LILY Short-Term Data Range is'
   PRINT, FORMAT='(C(),A,C())', LILY_TIME[S], ' to ', LILY_TIME[N]
;
; Save the Short-Term Data Set if it is asked for.
;
IF KEYWORD_SET( IDL_FILE ) THEN  BEGIN  ; IDL_FILE is provided.
   LILY_TIME  = 0  &  LILY_TEMP  = 0    ; Free them before
   LILY_XTILT = 0  &  LILY_YTILT = 0    ; reusing them.
   LILY_RTM   = 0  &  LILY_RTD   = 0
;  Rename the Short-Term 1-D arrays' names.
   LILY_TIME  = TIME
   LILY_TEMP  = TEMP
   LILY_XTILT = XTILT
   LILY_YTILT = YTILT
   LILY_RTM   = RTM
   LILY_RTD   = RTD
   SAVE, FILE=IDL_FILE,  $
   LILY_TIME, LILY_TEMP, LILY_XTILT, LILY_YTILT, LILY_RTM, LILY_RTD
   PRINT, 'IDL Save File: ' + IDL_FILE + ' is created.'
ENDIF
;
RETURN
END  ; GET_ST_LILY_DATA
;
; This procedure will use the provided cumulative NANO data set
; to created a Short-Term Data Set, usually 3-Day long.
;
; This procedure will also allow the users to Save the Short-Term
; data set into an IDL Save File.  Note that when that option is
; used, the Short-Term Data arrays will be named to the same
; arrays'names used in the the cumulative data set!
;
; Callers: Users.
;
PRO GET_ST_NANO_DATA,  NANO_FILE,  $ ;  Input: 'MJ03D-NANO.idl' e.g.
                          N_DAYS,  $ ;  Input: Number of days.
     TIME,  TEMP,  PSIA,  DETIDE,  $ ; Output: Short-Term 1-D arrays.
    SAVE2FILE=IDL_FILE  ; Input: Save the Short-Term arrays into the IDL_FILE.
;
  RESTORE, NANO_FILE  ; to Get NANO_TIME, NANO_TEMP, NANO_[X/Y]TILE.
;
  N = N_ELEMENTS( NANO_TIME )  ; Total data points in the NANO_* arrays.
;
; Get the Date of the last data point in the NANO_* arrays.
;  
  CALDAT, NANO_TIME[N-1], M, D, Y  ;, H, M, S
  PRINT, FORMAT='(A,C())', 'The Last NANO Time: ', NANO_TIME[N-1]
;
; Get the Time Indexes of the beginning of the 3 Days before.
; Note the function: LOCATE_TIME_POSITION() is in the
; file: ~/4Chadwick/RSN/SplitRSNdata.pro
;  
  S  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY( M, D-N_DAYS, Y, 0,0,0 ) )
  N -= 1  ; Index for the last data point in the LILY_* arrays.
;
; Assgin the Short-Term 1-D arrays.
;
   TIME  = NANO_TIME  [S:N]
   TEMP  = NANO_TEMP  [S:N]
   PSIA  = NANO_PSIA  [S:N]
  DETIDE = NANO_DETIDE[S:N]
;
   PRINT, 'The NANO Short-Term Data Range is'
   PRINT, FORMAT='(C(),A,C())', NANO_TIME[S], ' to ', NANO_TIME[N]
;
; Save the Short-Term Data Set if it is asked for.
;
IF KEYWORD_SET( IDL_FILE ) THEN  BEGIN  ; IDL_FILE is provided.
   NANO_TIME  = 0  &  NANO_TEMP  = 0    ; Free them before
   NANO_PSIA  = 0  &  NANO_DETIDE= 0    ; reusing them.
;  Rename the Short-Term 1-D arrays' names.
   NANO_TIME  = TIME
   NANO_TEMP  = TEMP
   NANO_PSIA  = PSIA
   NANO_DETIDE= DETIDE
   SAVE, FILE=IDL_FILE, NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE
   PRINT, 'IDL Save File: ' + IDL_FILE + ' is created.'
ENDIF
;
RETURN
END  ; GET_ST_NANO_DATA
;
; This procedure will Reduce (Shorten) the privided data arrays
; by removing some of the data at the End of the arrays.
;
; Callers: REDUCE_[HEAT/IRIS/LILY/NANO]_DATA or Users.
;
PRO REDUCE_END_DATA,  N_DAYS,  $ ; Input: Number of days for reducing the data.
    TIME, TEMP, DATA1, DATA2, DATA3, DATA4,  $  ; I/O: 1-D arrays.
    RESULTS=STATUS ; Output: will be = 'Not Reduced' or 'Reduced'
;
; (*) All arrays are the same size.
;
   N = N_ELEMENTS( TIME )  ; Total data points.
;
IF N EQ N_ELEMENTS( DATA3 ) THEN  BEGIN  ; Assuming
   DATA3DATA4 = BYTE( 1 )  ;    DATA3 & DATA4 are provided.
ENDIF  ELSE  BEGIN
   DATA3DATA4 = BYTE( 0 )  ; No DATA3 & DATA4 are provided.
ENDELSE
;
; Get the Date of the last data point in the 1-D arrays.
;
  CALDAT, TIME[N-1], M, D, Y  ;, H, M, S
;
; Get the Time Index of the beginning of the N_DAYS before.
; Note the function: LOCATE_TIME_POSITION() is in the
; file: ~/4Chadwick/RSN/SplitRSNdata.pro
;
  D2 = JULDAY( M, D-N_DAYS, Y,  0,0,0 )
  S  = LOCATE_TIME_POSITION( TIME, D2 )
;
; Note that the result from above will be:
; TIME[S-1] <= JULDAY( M, D-N_DAYS, Y, 0,0,0 ) < TIME[S]
;
; Deteremine whether or not TIME[S-1] == JULDAY( M, D-N_DAYS, Y, 0,0,0 ).
;
  S -= 1
  D1 = ( TIME[S] - D2 )*84600  ; Difference in seconds.
  IF D1 EQ 0.0 THEN  BEGIN  ; TIME[S] == JULDAY( M, D-N_DAYS, Y, 0,0,0 )
     S -= 1  ; So that TIME[S] < JULDAY( M, D-N_DAYS, Y, 0,0,0 ).
  ENDIF
;
; New TIME[S:*]   will be the data to discard.
; and TIME[0:S-1] will be the data to keep.
;
  Y  = TIME[[S+1,N]]  ; Save these 2 dates & Times for printing.
;
; Assign the Reduced (from the beginning to the N_DAYS before) data.
;
  T  =  TIME[0:S]
  M  =  TEMP[0:S]
  D1 = DATA1[0:S]
  D2 = DATA2[0:S]
  IF DATA3DATA4 THEN  BEGIN  ; DATA[3&4] are provided.
     D3 = DATA3[0:S]
     D4 = DATA4[0:S]
  ENDIF  ELSE  BEGIN
     D3 = 0
     D4 = 0
  ENDELSE
;
  HELP, NAME='*'
  STOP  ; for checking.
;
  TIME  = 0
  TEMP  = 0  ; Free them
  DATA1 = 0  ; before
  DATA2 = 0  ; Reusing
  DATA3 = 0  ; them.
  DATA4 = 0
;
; Rename the Reduced data back to their original names.
;
  TIME  = TEMPORARY( T  )
  TEMP  = TEMPORARY( M  )
  DATA1 = TEMPORARY( D1 )
  DATA2 = TEMPORARY( D2 )
  DATA3 = TEMPORARY( D3 )
  DATA4 = TEMPORARY( D4 )
;
; Now the data in the Reduced data array is N_DAYS less
; from the End.
;
  N  = N_ELEMENTS(  TIME )  ; Size of the Reduced arrays 
;
  PRINT, 'Keeping   Data between: '
  PRINT, FORMAT='(C())', TIME[[0,N-1]]
  PRINT, 'Discarded Data between: '
  PRINT, FORMAT='(C())', Y
;
  STATUS = 'Reduced'
;
RETURN
END  ; REDUCE_END_DATA
;
; This procedure will Reduce the RSN data set at the End.
; For example, Data set's range is from March 1st to April 20th, 2015
; to be reduced by 3 days from the end.  The Reduce Data set will be
; from March 1st to April 17th, 2015.  Note that if there is data gap
; between April 18th & 20th, then the result will be from March 1st
; to April 16th, 2015.
;
; Callers: Users.
;
PRO REDUCE_HEAT_DATA, HEAT_FILE, SAVE_FILE,  $ ; Input: IDL save file names.
           N_DAYS   ; Input: Number of days for reducing the data.
;
; Retrieve HEAT Data: HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT
;
  RESTORE, HEAT_FILE
  HELP, NAME='*'
;
  REDUCE_END_DATA,  N_DAYS,  $ ; Input: Number of days for reducing the data.
  HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT,  $  ; I/O: 1-D arrays.
  RESULTS=STATUS ; Output: will be = 'Not Reduced' or 'Reduced'
  HELP, NAME='*'
;
  IF STATUS EQ 'Reduced' THEN  BEGIN
     SAVE, FILE=SAVE_FILE, HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT
     PRINT, 'Reduced data are Saved to ' + SAVE_FILE
  ENDIF  ELSE  BEGIN  ; STATUS == 'Not Reduced'
     PRINT, 'Not Reduced data are Saved.'
  ENDELSE
;
RETURN
END  ; REDUCE_HEAT_DATA
;
; This procedure will Reduce the RSN data set at the End.
; For example, Data set's range is from March 1st to April 20th, 2015
; to be reduced by 3 days from the end.  The Reduce Data set will be
; from March 1st to April 17th, 2015.  Note that if there is data gap
; between April 18th & 20th, then the result will be from March 1st
; to April 16th, 2015.
;
; Callers: Users.
;
PRO REDUCE_IRIS_DATA, IRIS_FILE, SAVE_FILE,  $ ; Input: IDL save file names.
           N_DAYS   ; Input: Number of days for reducing the data.
;
; Retrieve IRIS Data: IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT
;
  RESTORE, IRIS_FILE
  HELP, NAME='*'
;
  REDUCE_END_DATA,  N_DAYS,  $ ; Input: Number of days for reducing the data.
  IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT,  $  ; I/O: 1-D arrays.
  RESULTS=STATUS ; Output: will be = 'Not Reduced' or 'Reduced'
  HELP, NAME='*'
;
  IF STATUS EQ 'Reduced' THEN  BEGIN
     SAVE, FILE=SAVE_FILE, IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT
     PRINT, 'Reduced data are Saved to ' + SAVE_FILE
  ENDIF  ELSE  BEGIN  ; STATUS == 'Not Reduced'
     PRINT, 'Not Reduced data are Saved.'
  ENDELSE
;
RETURN
END  ; REDUCE_IRIS_DATA
;
; This procedure will Reduce the RSN data set at the End.
; For example, Data set's range is from March 1st to April 20th, 2015
; to be reduced by 3 days from the end.  The Reduce Data set will be
; from March 1st to April 17th, 2015.  Note that if there is data gap
; between April 18th & 20th, then the result will be from March 1st
; to April 16th, 2015.
;
; Callers: Users.
;
PRO REDUCE_LILY_DATA, LILY_FILE, SAVE_FILE,  $ ; Input: IDL save file names.
           N_DAYS   ; Input: Number of days for reducing the data.
;
; Retrieve LILY Data: LILY_TIME, LILY_TEMP, LILY_XTILT, LILY_YTILT
;
  RESTORE, LILY_FILE
  HELP, NAME='*'
;
  REDUCE_END_DATA,  N_DAYS,  $ ; Input: Number of days for reducing the data.
  LILY_TIME, LILY_TEMP, LILY_XTILT, LILY_YTILT,  $  ; I/O: 1-D arrays.
  LILY_RTM,  LILY_RTD,  $
  RESULTS=STATUS ; Output: will be = 'Not Reduced' or 'Reduced'
  HELP, NAME='*'
;
  IF STATUS EQ 'Reduced' THEN  BEGIN
     SAVE, FILE=SAVE_FILE, LILY_TIME, LILY_TEMP,  $
     LILY_XTILT, LILY_YTILT, LILY_RTM, LILY_RTD
     PRINT, 'Reduced data are Saved to ' + SAVE_FILE
  ENDIF  ELSE  BEGIN  ; STATUS == 'Not Reduced'
     PRINT, 'Not Reduced data are Saved.'
  ENDELSE
;
RETURN
END  ; REDUCE_LILY_DATA
;
; This procedure will Reduce the RSN data set at the End.
; For example, Data set's range is from March 1st to April 20th, 2015
; to be reduced by 3 days from the end.  The Reduce Data set will be
; from March 1st to April 17th, 2015.  Note that if there is data gap
; between April 18th & 20th, then the result will be from March 1st
; to April 16th, 2015.
;
; Callers: Users.
;
PRO REDUCE_NANO_DATA, NANO_FILE, SAVE_FILE,  $ ; Input: IDL save file names.
           N_DAYS   ; Input: Number of days for reducing the data.
;
; Retrieve NANO Data: NANO_TIME, NANO_TEMP, NANO_XTILT, NANO_YTILT
;
  RESTORE, NANO_FILE
  HELP, NAME='*'
;
  REDUCE_END_DATA,  N_DAYS,  $ ; Input: Number of days for reducing the data.
  NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE,  $  ; I/O: 1-D arrays.
  RESULTS=STATUS ; Output: will be = 'Not Reduced' or 'Reduced'
  HELP, NAME='*'
;
  IF STATUS EQ 'Reduced' THEN  BEGIN
     SAVE, FILE=SAVE_FILE, NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE
     PRINT, 'Reduced data are Saved to ' + SAVE_FILE
  ENDIF  ELSE  BEGIN  ; STATUS == 'Not Reduced'
     PRINT, 'Not Reduced data are Saved.'
  ENDELSE
;
RETURN
END  ; REDUCE_NANO_DATA
