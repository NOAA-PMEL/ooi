;
; File: UpdateRSNsaveFiles.pro
;
; This IDL program will Update the IDL Save files:
; 3DayMJ03[D/E/F]-[HEAT/IRIS/LILY/NANO].idl containing the
; Short-Term (3-Day) data  Or
; MJ03[D/E/F]-[HEAT/IRIS/LILY/NANO].idl containing the 
; Long-Term (Cumulative) data for the RSN data processing.
; see the File: ProcessRSNdata.pro comments at the top page for details.
;
; The main procedure is UPDATE_RSN_SAVE_FILES which will calling the
; procedures UPDATE_[HEAT/IRIS/LILY/NANO]_SAVE_FILE
;
; This program requires the functions in the programs: SplitRSNdata.pro
; StatusFile4RSN.pro in order to run.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on August     1st, 2019
; Created on March      2nd, 2014
;

;
; This is an independent routine and it is used for testing.
;
; Callers: Users.
;
PRO GET_DATA4TESTINGS, HEAT_FILE,  $ ;  Input: 'MJ03D-HEAT.idl' e.g.
                          N_DAYS,  $ ;  Input: Whole Integer.
     TIME,  TEMP,  XTILT,  YTILT,  $ ; Output: Short-Term 1-D arrays.
    LTIME, LTEMP, LXTILT, LYTILT     ; Output:  Long-Term 1-D arrays.
;
  RESTORE, HEAT_FILE  ; to Get HEAT_TIME, HEAT_TEMP, HEAT_[X/Y]TILE.
;
  N = N_ELEMENTS( HEAT_TIME )  ; Total data points in the HEAT_* arrays.
;
; Get the Date of the last data point in the HEAT_* arrays.
; 
  CALDAT, HEAT_TIME[N-1], M, D, Y  ;, H, M, S
;
; Get the Time Indexes of the beginning of the 3 Days before
; and the beginning of the latest day.
; Note the function: LOCATE_TIME_POSITION() is in the
; file: ~/4Chadwick/RSN/SplitRSNdata.pro
;
  S  = LOCATE_TIME_POSITION( HEAT_TIME, JULDAY( M, D-3, Y, 0,0,0 ) )
; N  = LOCATE_TIME_POSITION( HEAT_TIME, JULDAY( M, D,   Y, 0,0,0 ) )
  N -= 1
;
; Assgin the Short-Term 1-D arrays.
;
   TIME  = HEAT_TIME [S:N]
   TEMP  = HEAT_TEMP [S:N]
   XTILT = HEAT_XTILT[S:N]
   YTILT = HEAT_YTILT[S:N]
;
; Get the Time Indexes of the beginning of the 3 day before.
; and the beginning of the N_DAYS before
; Note the function: LOCATE_TIME_POSITION() is in the
; file: ~/4Chadwick/RSN/SplitRSNdata.pro
;
  N  = S - 1
  S  = LOCATE_TIME_POSITION( HEAT_TIME, JULDAY( M, D-N_DAYS, Y, 0,0,0 ) )
  N  = LOCATE_TIME_POSITION( HEAT_TIME, JULDAY( M, D,   Y, 0,0,0 ) )
  N -= 1
;
; Assgin the  Long-Term 1-D arrays.
;
  LTIME  = HEAT_TIME [S:N]
  LTEMP  = HEAT_TEMP [S:N]
  LXTILT = HEAT_XTILT[S:N]
  LYTILT = HEAT_YTILT[S:N]
;
RETURN
END  ; GET_DATA4TESTING
;
; Callers: UPDATE_RSN_SAVE_FILES or Users
;
PRO UPDATE_HEAT_SAVE_FILE,  STATION_ID,  $ ; Input: 'MJ03D' for  example.
                         RSN_DIRECTORY     ; Input: '~/4Chadwick/RSN/', e.g.
;
IF N_PARAMS() LT 1 THEN  BEGIN  ; No STATION_ID & directorys are provided.
   PRINT, 'Must provide the Station ID & the directory path for the new RSN data files.'
   RETURN
ENDIF
IF N_PARAMS() LT 2 THEN  BEGIN  ; OUTPUT_DIRECTORY is not provided.
   RSN_DIRECTORY = '~/4Chadwick/RSN/'  ; for now.
ENDIF
;
; Define the directory path: '~/4Chadwick/RSN/MJ03E/' for example.
;
                          N = STRLEN( RSN_DIRECTORY )
IF STRMID( RSN_DIRECTORY, N-1, 1 ) NE PATH_SEP() THEN  BEGIN
   DIR_PATH = RSN_DIRECTORY + PATH_SEP() + STATION_ID + PATH_SEP()
ENDIF  ELSE  BEGIN
   DIR_PATH = RSN_DIRECTORY + STATION_ID + PATH_SEP()
ENDELSE
;
; Define the IDL Save Files' Info.  Both the Short-Term & Long-Term.
;
  STERM_FILE = FILE_INFO( DIR_PATH + '3Day' + STATION_ID + '-HEAT.idl' )
  LTERM_FILE = FILE_INFO( DIR_PATH +          STATION_ID + '-HEAT.idl' )
; and
; STERM_FILE.NAME = '~/4Chadwick/RSN/MJ03E/3DayMJ03E-HEAT.idl'
; LTERM_FILE.NAME = '~/4Chadwick/RSN/MJ03E/MJ03E-HEAT.idl'
;
IF STERM_FILE.EXISTS AND LTERM_FILE.EXISTS THEN  BEGIN  ; Update the Save Files.
   RESTORE, STERM_FILE.NAME  ; Retrieve the Short-Term Data.
;  The Variables in IDL_FILE: STERM.FILE are assumed to be 
;  HEAT_TIME, HEAT_XTILT, HEAT_YTILT, HEAT_TEMP
;  Note the Long-Term Data variables' names in LTERM.FILE also
;  contains the same names.  Therefore, Rename the following
;  variable names are needed.
   TIME = TEMPORARY( HEAT_TIME  )  ; Rename the
   TEMP = TEMPORARY( HEAT_TEMP  )  ; Short-Term
  XTILT = TEMPORARY( HEAT_XTILT )  ; Data arrays'
  YTILT = TEMPORARY( HEAT_YTILT )  ; Variable names.
   RESTORE, LTERM_FILE.NAME  ; Retrieve the  Long-Term Data.
;  The Variables in IDL_FILE: LTERM_FILE.NAME also has the
;  same variable names as in the STERM_FILE.NAME.
   N = 0  ;  Dummy variable.
   UPDATE_RSN_DATA, RESULTS=STATUS, $  ; will be = 'No Update' or 'Updated'.
        TIME,      TEMP,      XTILT,     YTILT,  $ ; Short-Term Data.
                                          N, N,  $ ; Dummy Inputs.
   HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT    ;  Long-Term Data.
;
   IF STATUS EQ 'No Update' THEN  BEGIN
      PRINT, 'Files: ' + STERM_FILE.NAME, '  and  ' + LTERM_FILE.NAME
      PRINT, SYSTIME() + ' are Not Updated.'
   ENDIF  ELSE  BEGIN  ; STATUS == 'Updated'
      SAVE, FILE=LTERM_FILE.NAME,  $
      HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT
      PRINT, SYSTIME() + ' IDL Save File: ' + STERM_FILE.NAME + ' Updated.'
;     Free the HEAT_* variables before reusing them.
      HEAT_TIME  = 0  &  HEAT_TEMP  = 0
      HEAT_XTILT = 0  &  HEAT_YTILT = 0
      HEAT_TIME  = TEMPORARY( TIME  )  ; Rename the
      HEAT_TEMP  = TEMPORARY( TEMP  )  ; Short-Term
      HEAT_XTILT = TEMPORARY( XTILT )  ; Data arrays'
      HEAT_YTILT = TEMPORARY( YTILT )  ; Variable names.
      SAVE, FILE=STERM_FILE.NAME,  $
      HEAT_TIME, HEAT_TEMP, HEAT_XTILT, HEAT_YTILT
      PRINT, SYSTIME() + ' IDL Save File: ' + LTERM_FILE.NAME + ' Updated.'
   ENDELSE  ; STATUS == 'Updated'
ENDIF  ELSE  BEGIN  ; either 1 or Both Files do not exist.
   IF NOT STERM_FILE.EXISTS THEN  BEGIN
     PRINT, 'IDL Save File: ' + STERM_FILE.NAME + ' does not exist!'
   ENDIF
   IF NOT LTERM_FILE.EXISTS THEN  BEGIN
     PRINT, 'IDL Save File: ' + LTERM_FILE.NAME + ' does not exist!'
   ENDIF
   PRINT, 'in the directory: ' + RSN_DIRECTORY
   PRINT, SYSTIME() + ' No Update will be Done.'
ENDELSE 
;
RETURN  ; UPDATE_HEAT_SAVE_FILE
END
;
; Callers: UPDATE_RSN_SAVE_FILES or Users
;
PRO UPDATE_IRIS_SAVE_FILE,  STATION_ID,  $ ; Input: 'MJ03D' for  example.
                         RSN_DIRECTORY     ; Input: '~/4Chadwick/RSN/', e.g.
;
IF N_PARAMS() LT 1 THEN  BEGIN  ; No STATION_ID & directorys are provided.
   PRINT, 'Must provide the Station ID & the directory path for the new RSN data files.'
   RETURN
ENDIF
IF N_PARAMS() LT 2 THEN  BEGIN  ; OUTPUT_DIRECTORY is not provided.
   RSN_DIRECTORY = '~/4Chadwick/RSN/'  ; for now.
ENDIF
;
; Define the directory path: '~/4Chadwick/RSN/MJ03F/' for example.
;
                          N = STRLEN( RSN_DIRECTORY )
IF STRMID( RSN_DIRECTORY, N-1, 1 ) NE PATH_SEP() THEN  BEGIN
   DIR_PATH = RSN_DIRECTORY + PATH_SEP() + STATION_ID + PATH_SEP()
ENDIF  ELSE  BEGIN
   DIR_PATH = RSN_DIRECTORY + STATION_ID + PATH_SEP()
ENDELSE
;
; Define the IDL Save Files' Info.  Both the Short-Term & Long-Term.
;
  STERM_FILE = FILE_INFO( DIR_PATH + '3Day' + STATION_ID + '-IRIS.idl' )
  LTERM_FILE = FILE_INFO( DIR_PATH +          STATION_ID + '-IRIS.idl' )
; and
; STERM_FILE.NAME = '~/4Chadwick/RSN/MJ03E/3DayMJ03F-IRIS.idl'
; LTERM_FILE.NAME = '~/4Chadwick/RSN/MJ03E/MJ03F-IRIS.idl'
;
IF STERM_FILE.EXISTS AND LTERM_FILE.EXISTS THEN  BEGIN  ; Update the Save Files.
   RESTORE, STERM_FILE.NAME  ; Retrieve the Short-Term Data.
;  The Variables in IDL_FILE: STERM_FILE.NAME are assumed to be 
;  IRIS_TIME, IRIS_XTILT, IRIS_YTILT, IRIS_TEMP
;  Note the Long-Term Data variables' names in LTERM_FILE.NAME also
;  contains the same names.  Therefore, Rename the following
;  variable names are needed.
   TIME = TEMPORARY( IRIS_TIME  )  ; Rename the
   TEMP = TEMPORARY( IRIS_TEMP  )  ; Short-Term
  XTILT = TEMPORARY( IRIS_XTILT )  ; Data arrays'
  YTILT = TEMPORARY( IRIS_YTILT )  ; Variable names.
   RESTORE, LTERM_FILE.NAME  ; Retrieve the  Long-Term Data.
;  The Variables in IDL_FILE: LTERM_FILE.NAME also has the
;  same variable names as in the STERM_FILE.NAME.
   N = 0  ;  Dummy variable.
   UPDATE_RSN_DATA, RESULTS=STATUS, $  ; will be = 'No Update' or 'Updated'.
        TIME,      TEMP,      XTILT,      YTILT,  $ ; Short-Term Data.
                                           N, N,  $ ; Dummy Inputs.
   IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT     ;  Long-Term Data.
;
   IF STATUS EQ 'No Update' THEN  BEGIN
      PRINT, 'Files: ' + STERM_FILE.NAME, '  and  ' + LTERM_FILE.NAME
      PRINT, SYSTIME() + ' are Not Updated.'
   ENDIF  ELSE  BEGIN  ; STATUS == 'Updated'
      SAVE, FILE=LTERM_FILE.NAME,  $
      IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT
      PRINT, SYSTIME() + ' IDL Save File: ' + STERM_FILE.NAME + ' Updated.'
;     Free the HEAT_* variables before reusing them.
      IRIS_TIME  = 0  &  IRIS_TEMP  = 0
      IRIS_XTILT = 0  &  IRIS_YTILT = 0
      IRIS_TIME  = TEMPORARY( TIME  )  ; Rename the
      IRIS_TEMP  = TEMPORARY( TEMP  )  ; Short-Term
      IRIS_XTILT = TEMPORARY( XTILT )  ; Data arrays'
      IRIS_YTILT = TEMPORARY( YTILT )  ; Variable names.
      SAVE, FILE=STERM_FILE.NAME,  $
      IRIS_TIME, IRIS_TEMP, IRIS_XTILT, IRIS_YTILT
      PRINT, SYSTIME() + ' IDL Save File: ' + LTERM_FILE.NAME + ' Updated.'
   ENDELSE  ; STATUS == 'Updated'
ENDIF  ELSE  BEGIN  ; either 1 or Both Files do not exist.
   IF NOT STERM_FILE.EXISTS THEN  BEGIN
     PRINT, 'IDL Save File: ' + STERM_FILE.NAME + ' does not exist!'
   ENDIF
   IF NOT LTERM_FILE.EXISTS THEN  BEGIN
     PRINT, 'IDL Save File: ' + LTERM_FILE.NAME + ' does not exist!'
   ENDIF
   PRINT, 'in the directory: ' + RSN_DIRECTORY
   PRINT, SYSTIME() + ' No Update will be Done.'
ENDELSE
;
;
RETURN  ; UPDATE_IRIS_SAVE_FILE
END
;
; Callers: UPDATE_RSN_SAVE_FILES or Users
;
PRO UPDATE_LILY_SAVE_FILE,  STATION_ID,  $ ; Input: 'MJ03D' for  example.
                         RSN_DIRECTORY     ; Input: '~/4Chadwick/RSN/', e.g.
;
IF N_PARAMS() LT 1 THEN  BEGIN  ; No STATION_ID & directorys are provided.
   PRINT, 'Must provide the Station ID & the directory path for the new RSN data files.'
   RETURN
ENDIF
IF N_PARAMS() LT 2 THEN  BEGIN  ; OUTPUT_DIRECTORY is not provided.
   RSN_DIRECTORY = '~/4Chadwick/RSN/'  ; for now.
ENDIF
;
; Define the directory path: '~/4Chadwick/RSN/MJ03D/' for example.
;
                          N = STRLEN( RSN_DIRECTORY )
IF STRMID( RSN_DIRECTORY, N-1, 1 ) NE PATH_SEP() THEN  BEGIN
   DIR_PATH = RSN_DIRECTORY + PATH_SEP() + STATION_ID + PATH_SEP()
ENDIF  ELSE  BEGIN
   DIR_PATH = RSN_DIRECTORY + STATION_ID + PATH_SEP()
ENDELSE
;
; Define the IDL Save Files' Info.  Both the Short-Term & Long-Term.
;
  STERM_FILE = FILE_INFO( DIR_PATH + '3Day' + STATION_ID + '-LILY.idl' )
  LTERM_FILE = FILE_INFO( DIR_PATH +          STATION_ID + '-LILY.idl' )
; and
; STERM_FILE.NAME = '~/4Chadwick/RSN/MJ03E/3DayMJ03D-LILY.idl'
; LTERM_FILE.NAME = '~/4Chadwick/RSN/MJ03E/MJ03D-LILY.idl'
;
IF STERM_FILE.EXISTS AND LTERM_FILE.EXISTS THEN  BEGIN  ; Update the Save Files.
   RESTORE, STERM_FILE.NAME  ; Retrieve the Short-Term Data.
;  The Variables in IDL_FILE: STERM_FILE.NAME are assumed to be 
;  LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_TEMP
;  Note the Long-Term Data variables' names in LTERM_FILE.NAME also
;  contains the same names.  Therefore, Rename the following
;  variable names are needed.
   TIME = TEMPORARY( LILY_TIME  )  ; Rename the
   TEMP = TEMPORARY( LILY_TEMP  )  ; Short-Term
  XTILT = TEMPORARY( LILY_XTILT )  ; Data arrays'
  YTILT = TEMPORARY( LILY_YTILT )  ; Variable names.
    RTM = TEMPORARY( LILY_RTM   )
    RTD = TEMPORARY( LILY_RTD   )
   RESTORE, LTERM_FILE.NAME  ; Retrieve the  Long-Term Data.
;  The Variables in IDL_FILE: LTERM_FILE.NAME also has the
;  same variable names as in the STERM_FILE.NAME.
   N = 0  ;  Dummy variable.
   UPDATE_RSN_DATA, RESULTS=STATUS, $  ; will be = 'No Update' or 'Updated'.
          TIME, TEMP, XTILT, YTILT, RTM, RTD,   $ ; Short-Term Data.
          LILY_TIME,  LILY_TEMP, LILY_XTILT,    $ ;  Long-Term Data.
          LILY_YTILT, LILY_RTM,  LILY_RTD        
;
   IF STATUS EQ 'No Update' THEN  BEGIN
      PRINT, 'Files: ' + STERM_FILE.NAME, '  and  ' + LTERM_FILE.NAME
      PRINT, SYSTIME() + ' are Not Updated.'
   ENDIF  ELSE  BEGIN  ; STATUS == 'Updated'
      SAVE, FILE=LTERM_FILE.NAME,  LILY_TIME, LILY_TEMP,$
      LILY_XTILT, LILY_YTILT, LILY_RTM,  LILY_RTD
      PRINT, SYSTIME() + ' IDL Save File: ' + STERM_FILE.NAME + ' Updated.'
;     Free the HEAT_* variables before reusing them.
      LILY_TIME  = 0  &  LILY_TEMP  = 0
      LILY_XTILT = 0  &  LILY_YTILT = 0
      LILY_RTM   = 0  &  LILY_RTD   = 0
      LILY_TIME  = TEMPORARY( TIME  )  ; Rename the
      LILY_TEMP  = TEMPORARY( TEMP  )  ; Short-Term
      LILY_XTILT = TEMPORARY( XTILT )  ; Data arrays'
      LILY_YTILT = TEMPORARY( YTILT )  ; Variable names.
      LILY_RTM   = TEMPORARY( RTM   )
      LILY_RTD   = TEMPORARY( RTD   )
      SAVE, FILE=STERM_FILE.NAME,  $
      LILY_TIME, LILY_TEMP, LILY_XTILT, LILY_YTILT, LILY_RTM, LILY_RTD
      PRINT, SYSTIME() + ' IDL Save File: ' + LTERM_FILE.NAME + ' Updated.'
   ENDELSE  ; STATUS == 'Updated'
ENDIF  ELSE  BEGIN  ; either 1 or Both Files do not exist.
   IF NOT STERM_FILE.EXISTS THEN  BEGIN
     PRINT, 'IDL Save File: ' + STERM_FILE.NAME + ' does not exist!'
   ENDIF
   IF NOT LTERM_FILE.EXISTS THEN  BEGIN
     PRINT, 'IDL Save File: ' + LTERM_FILE.NAME + ' does not exist!'
   ENDIF
   PRINT, 'in the directory: ' + RSN_DIRECTORY
   PRINT, SYSTIME() + ' No Update will be Done.'
ENDELSE
;
RETURN  ; UPDATE_LILY_SAVE_FILE
END
;
; Callers: UPDATE_RSN_SAVE_FILES or Users
;
PRO UPDATE_NANO_SAVE_FILE,  STATION_ID,  $ ; Input: 'MJ03D' for  example.
                         RSN_DIRECTORY     ; Input: '~/4Chadwick/RSN/', e.g.
;
IF N_PARAMS() LT 1 THEN  BEGIN  ; No STATION_ID & directorys are provided.
   PRINT, 'Must provide the Station ID & the directory path for the new RSN data files.'
   RETURN
ENDIF
IF N_PARAMS() LT 2 THEN  BEGIN  ; OUTPUT_DIRECTORY is not provided.
   RSN_DIRECTORY = '~/4Chadwick/RSN/'  ; for now.
ENDIF
;
; Define the directory path: '~/4Chadwick/RSN/MJ03E/' for example.
;
                          N = STRLEN( RSN_DIRECTORY )
IF STRMID( RSN_DIRECTORY, N-1, 1 ) NE PATH_SEP() THEN  BEGIN
   DIR_PATH = RSN_DIRECTORY + PATH_SEP() + STATION_ID + PATH_SEP()
ENDIF  ELSE  BEGIN
   DIR_PATH = RSN_DIRECTORY + STATION_ID + PATH_SEP()
ENDELSE
;
; Define the IDL Save Files' Info.  Both the Short-Term & Long-Term.
;
  STERM_FILE = FILE_INFO( DIR_PATH + '3Day' + STATION_ID + '-NANO.idl' )
  LTERM_FILE = FILE_INFO( DIR_PATH +          STATION_ID + '-NANO.idl' )
; and
; STERM_FILE.NAME = '~/4Chadwick/RSN/MJ03E/3DayMJ03E-NANO.idl'
; LTERM_FILE.NAME = '~/4Chadwick/RSN/MJ03E/MJ03E-NANO.idl'
;
IF STERM_FILE.EXISTS AND LTERM_FILE.EXISTS THEN  BEGIN  ; Update the Save Files.
   RESTORE, STERM_FILE.NAME  ; Retrieve the Short-Term Data.
;  The Variables in IDL_FILE: STERM_FILE.NAME are assumed to be 
;  NANO_TIME, NANO_XTILT, NANO_YTILT, NANO_TEMP
;  Note the Long-Term Data variables' names in LTERM_FILE.NAME also
;  contains the same names.  Therefore, Rename the following
;  variable names are needed.
   TIME   = TEMPORARY( NANO_TIME   )  ; Rename the
   TEMP   = TEMPORARY( NANO_TEMP   )  ; Short-Term
   PSIA   = TEMPORARY( NANO_PSIA   )  ; Data arrays'
   DETIDE = TEMPORARY( NANO_DETIDE )  ; Variable names.
   RESTORE, LTERM_FILE.NAME  ; Retrieve the  Long-Term Data.
;  The Variables in IDL_FILE: LTERM_FILE.NAME also has the
;  same variable names as in the STERM_FILE.NAME.
   N = 0  ;  Dummy variable.
   UPDATE_RSN_DATA, RESULTS=STATUS, $  ; will be = 'No Update' or 'Updated'.
        TIME,      TEMP,      PSIA,    DETIDE,  $ ; Short-Term Data.
                                       N,   N,  $ ; Dummy Inputs.
   NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE   ;  Long-Term Data.
;
   IF STATUS EQ 'No Update' THEN  BEGIN
      PRINT, 'Files: ' + STERM_FILE.NAME, '  and  ' + LTERM_FILE.NAME
      PRINT, SYSTIME() + ' are Not Updated.'
   ENDIF  ELSE  BEGIN  ; STATUS == 'Updated'
      SAVE, FILE=LTERM_FILE.NAME,  $
      NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE
      PRINT, SYSTIME() + ' IDL Save File: ' + STERM_FILE.NAME + ' Updated.'
;     Free the HEAT_* variables before reusing them.
      NANO_TIME   = 0  &  NANO_TEMP   = 0
      NANO_PSIA   = 0  &  NANO_DETIDE = 0
      NANO_TIME   = TEMPORARY( TIME   )  ; Rename the
      NANO_TEMP   = TEMPORARY( TEMP   )  ; Short-Term
      NANO_PSIA   = TEMPORARY( PSIA   )  ; Data arrays'
      NANO_DETIDE = TEMPORARY( DETIDE )  ; Variable names.
      SAVE, FILE=STERM_FILE.NAME,  $
      NANO_TIME, NANO_TEMP, NANO_PSIA, NANO_DETIDE
      PRINT, SYSTIME() + ' IDL Save File: ' + LTERM_FILE.NAME + ' Updated.'
   ENDELSE  ; STATUS == 'Updated'
ENDIF  ELSE  BEGIN  ; either 1 or Both Files do not exist.
   IF NOT STERM_FILE.EXISTS THEN  BEGIN
     PRINT, 'IDL Save File: ' + STERM_FILE.NAME + ' does not exist!'
   ENDIF
   IF NOT LTERM_FILE.EXISTS THEN  BEGIN
     PRINT, 'IDL Save File: ' + LTERM_FILE.NAME + ' does not exist!'
   ENDIF
   PRINT, 'in the directory: ' + RSN_DIRECTORY
   PRINT, SYSTIME() + ' No Update will be Done.'
ENDELSE
;
RETURN  ; UPDATE_NANO_SAVE_FILE
END
;
; This routine will shorten the Short-Term data arrays'
; contents by 1 day and extend by appending the Long-
; Term arrays' contents by 1 day (the last day from the
; Short-Term data arrays).
;
; Callers: UPDATE_[HEAT/IRIS/LILY/NANO]_SAVE_FILE
; Revised: December 5th, 2017
;
PRO UPDATE_RSN_DATA,  TIME, TEMP,  $ ; I/O: Short-Term
      DATA1, DATA2, DATA3, DATA4,  $ ;      1-D arrays.
    LTIME, LTEMP, LDATA1, LDATA2,  $ ; I/O:  Long-Term
                  LDATA3, LDATA4,  $ ;      1-D arrays.
    RESULTS=STATUS ; Output: will be = 'No Update' or 'Updated'
;
; Note the DATA1, DATA2 & LDATA1, LDATA2 with be the
; XTILT & YTILT data except when they are sent by the
; UPDATE_NANO_SAVE_FILE procedure.  In that case,
; they will be the PSIA & DETIDE respectively (*).
;
; The DATA3, DATA4 & LDATA3, LDATA4 will only be used
; when the call is from the UPDATE_LILY_SAVE_FILE procedure.
; In that case, the LILY's RTM & RTD data will be placed
; in the DATA3 & DATA4 respectively (*).
;
; (*) The order can be switched.  Only the 1st & 7th variables:
; TIME & LTIME are important.  They Must be contain the times
; in JULDAT().
;
IF N_PARAMS() EQ 12 THEN  BEGIN
   DATA3DATA4 = BYTE( 1 )  ;    DATA3 & DATA4 are provided.
ENDIF  ELSE  BEGIN
   DATA3DATA4 = BYTE( 0 )  ; No DATA3 & DATA4 are provided.
ENDELSE
;
; Find out the total data points in the Long-Term 1-D arrays
; Note that the LTIME, LTEMP, LDATA1, LDATA2, are all the same size
; including LDATA3, LDATA4 if they are sent by UPDATE_LILY_SAVE_FILE.
;
  M = N_ELEMENTS( LTIME )
;
; Find out the total data points in the Short-Term 1-D arrays
; Note that the TIME, TEMP, DATA1, DATA2 are all the same size
; including DATA3, DATA4 if they are sent by UPDATE_LILY_SAVE_FILE.
;
  N = N_ELEMENTS(  TIME )
;
; Check to make sure that LTIME[M-1] is < TIME[N-1] before proceeding.
;
IF NOT (LTIME[M-1] LT TIME[N-1] ) THEN  BEGIN  ; LTIME[M-1] >= TIME[N-1]
   PRINT, 'No New Data yet and No Update will be done.'
   STATUS = 'No Update'
ENDIF  ELSE  BEGIN  ; LTIME[M-1] < TIME[N-1], There are data to Update.
;
;  Using the time of the last data point in the Long-Term arrays to
;  Locate the index in the Short-Term arrays where the new data start.
;  Note the function: LOCATE_TIME_POSITION() is in the
;  file: ~/4Chadwick/RSN/SplitRSNdata.pro

   M = N_ELEMENTS( LTIME )  ; Total data points in the Long-Term arrays.
   S = LOCATE_TIME_POSITION( TIME, LTIME[M-1] )
;
;  Note that the result from above will be:
;  TIME[S-1] <= LTIME[M-1] < TIME[S]
;  So that TIME[S:N-1] will be the data to be appended
;  in to the Long-Term data.
;
;  Find out the total Shorten data points in the Short-Term 1-D arrays
;  Note that the TIME, TEMP, DATA1, DATA2 are all the same size
;  including DATA3, DATA4 if they are sent by UPDATE_LILY_SAVE_FILE.
;
   N  = N_ELEMENTS(  TIME )
   N -= 1  ; So that TIME[N] is the last data point.
;
;  HELP, NAME='*'
;  STOP  ; for checking.
;
;  Append the new data (the data in the last day in the Short-Term arrays).
;
   LTIME  = [ TEMPORARY( LTIME  ),  TIME[S:N] ]
   LTEMP  = [ TEMPORARY( LTEMP  ),  TEMP[S:N] ]
   LDATA1 = [ TEMPORARY( LDATA1 ), DATA1[S:N] ]
   LDATA2 = [ TEMPORARY( LDATA2 ), DATA2[S:N] ]
   IF DATA3DATA4 THEN  BEGIN  ; DATA[3&4] are provided.
      LDATA3 = [ TEMPORARY( LDATA3 ), DATA3[S:N] ]
      LDATA4 = [ TEMPORARY( LDATA4 ), DATA4[S:N] ]
   ENDIF
;
   PRINT, 'Date/Time of the Last Cumulative Data point: '
   PRINT, FORMAT='(C())', LTIME[M-1]
   PRINT, 'Added New Data between: '
   PRINT, FORMAT='(C())', TIME[[S,N]]
;
;  Compute the total number of days in the Short-Term arrays.
;
   T  = ROUND( TIME[N] - TIME[0] )  ; in whole days
;
;  Get total number of days to be shorten for the Short-Term
;  arrays.  Note that they need to have at least 2 days in
;  the arrays.
;
 ; T -= 2  ; T = number of days to be shorten.
   T -= 7  ; T = number of days to be shorten.  Started on December 5th, 2017.
;
;  HELP, NAME='*'
;  STOP  ; for checking.
;
   IF T LE 0 THEN  BEGIN  ; Short-Term arrays < 2 days.
      PRINT, 'Data Range in the Short-Term arrays:'
      PRINT, FORMAT='(C())', TIME[[0,N]]
      PRINT, 'are < 2 days.  No data reduction!' 
;     STATUS = 'No Update'   ; May 28th, 2015
   ENDIF  ELSE  BEGIN     ; Shorten the Short-Term arrays.
;
;     Get the Date of the 1st point in the Short-Term data.
; 
      CALDAT, TIME[0], M, D, Y  ;, H, M, S
;
;     Get the Time Index of the beginning of the next day.
;     Note the function: LOCATE_TIME_POSITION() is in the
;     file: ~/4Chadwick/RSN/SplitRSNdata.pro
;
      S = LOCATE_TIME_POSITION( TIME, JULDAY( M, D+T, Y, 0,0,0 ) )
;
;     Note that the result from above will be:
;     TIME[S-1] <= JULDAY( M, D+1, Y, 0,0,0 ) < TIME[S]
;     So that TIME[S:*] will be the data to keep
;     and   TIME[0:S-1] will be the data to discard.
;
      Y = TIME[[0,S-1]]  ; Save these 2 dates & Times for printing.
;
;     HELP, NAME='*'
;     STOP  ; for checking.
;
;     Assign the Shorten (from the beginning of the next to the end)
;     Short-Term data into the temorary variables.
;
      T  =  TIME[S:N]
      M  =  TEMP[S:N]
      D1 = DATA1[S:N]
      D2 = DATA2[S:N]
      IF DATA3DATA4 THEN  BEGIN  ; DATA[3&4] are provided.
         D3 = DATA3[S:N]
         D4 = DATA4[S:N]
      ENDIF  ELSE  BEGIN
         D3 = 0
         D4 = 0
      ENDELSE
;
      TIME  = 0
      TEMP  = 0  ; Free them
      DATA1 = 0  ; before
      DATA2 = 0  ; Reusing
      DATA3 = 0  ; them.
      DATA4 = 0
;
;     Rename the Shorten Short-Term data back to their original names.
;
      TIME  = TEMPORARY( T  )
      TEMP  = TEMPORARY( M  )
      DATA1 = TEMPORARY( D1 )
      DATA2 = TEMPORARY( D2 )
      DATA3 = TEMPORARY( D3 )
      DATA4 = TEMPORARY( D4 )
;
;     Now the data in the Short-Term data array is 1 day less.
;
      PRINT, 'Discarded Data between: '
      PRINT, FORMAT='(C())', Y
;
;     STATUS = 'Updated'
;
   ENDELSE ; Shorten the Short-Term arrays.
;
   STATUS = 'Updated'  ; May 28th, 2015
;
ENDELSE ; There are data to Update.
;
RETURN  ; UPDATE_RSN_DATA
END
;
; Callers: Users
; Revised; August 1st, 2019.
;
PRO UPDATE_RSN_SAVE_FILES, STATION_ID, $  ; Input: 'MJ03D' for  example.
    SAVE_FILE_DIRECTORY=RSN_DIRECTORY     ; Input: '~/4Chadwick/RSN/', e.g.
;
; If the Save Files' location is not provided,
; set an assummed position.
;
IF NOT KEYWORD_SET( RSN_DIRECTORY ) THEN  BEGIN
   RSN_DIRECTORY = '~/4Chadwick/RSN/'  ;
ENDIF
;
; Define the STATUS_FILE name for Locking the current process.
;
  STATUS      = RSN_DIRECTORY + PATH_SEP() + STATION_ID + PATH_SEP()
  STATUS_FILE = STATUS + STATION_ID + '.ProcessingStatus'
; STATUS_FILE = '~/4Chadwick/RSN/MJ03D/MJ03D.ProcessingStatus' e.g.
;
; Lock the current process so that no other RSN program such as
; the ProcessRSNdata.pro can be run unit this program finish.
; Note that the LOCK_PROCESSING procedure is in the StatusFile4RSN.pro.
;
  LOCK_PROCESSING, STATUS_FILE, STATUS
;
IF STATUS EQ 0 THEN  BEGIN
   PRINT, 'Cannot the Lock the process.  Other RSN processing is running.'
   PRINT, 'This proram will stop & wait for the next time to Update the data.'
ENDIF  ELSE  BEGIN  ; STATUS == 1 which means the process is locked.
;
   PRINT, 'For Station: ' + STATION_ID + ','
   PRINT, 'Updating the RSN Save Files in ' + RSN_DIRECTORY + ' ...'
;
;  Switch the processing order to do LILY and NANO 1st & other later  August 1st, 2019.
;
   UPDATE_LILY_SAVE_FILE, STATION_ID, RSN_DIRECTORY
   UPDATE_NANO_SAVE_FILE, STATION_ID, RSN_DIRECTORY
   UPDATE_HEAT_SAVE_FILE, STATION_ID, RSN_DIRECTORY
   UPDATE_IRIS_SAVE_FILE, STATION_ID, RSN_DIRECTORY
;
;  Free the current process so that other RSN program such as
;  the ProcessRSNdata.pro can be run.
;  Note that the LOCK_PROCESSING procedure is in the StatusFile4RSN.pro.
;
   FREE_PROCESSING, STATUS_FILE
;
ENDELSE
;
RETURN
END  ; UPDATE_RSN_SAVE_FILES
