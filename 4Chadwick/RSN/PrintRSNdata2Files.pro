;
; File: PrintRSNdata2Files.pro
; This program requires the rouitnes in the Files:
; SplitRSNdata.pro and
; GetLongTermNANOdataProducts.pro  in order to work.
;
; Programmer: T-K Andy Lau NOAA/PMEL/Acoustic Program HMSC Newport Oregon.
;
; Revised on September  1st, 2020
; Created on April     27th, 2015
;

;
; Callers: PRINT_RSN_DATA2FILE or Users.
; Revised on   November  18th  2015
;
PRO PRINT_AVE_TILTS2FILE,  IDL_FILE,  $ ; Input: IDL Save File name.
                        OUTPUT_FILE,  $ ; Input:   Output File name.
    STIME, ETIME  ; Inputs: Start & End Time of the data range to be printed
;
   N = N_PARAMS()  ; Get Total input parameters.
;
IF N LT 2 THEN  BEGIN
   PRINT, 'From PRINT_IRIS_DATA2FILE,'
   PRINT, 'Must provide an IDL Save File and an Output File names.'
   PRINT, 'NO data retrieved!'
ENDIF  ELSE  BEGIN  ; Assume at IDL_FILE & OUTPUT_FILE are provided.
;
;  Retrieve the data from the IDL_FILE and the array variables will be
;  T, XT, YT from the MJ03[D/E/F]/MJ03[D/E/F]1HrAve[IRIS/LILY].idl file.
; 
   RESTORE, IDL_FILE  ; to get the arrays: T, XT and YT.
;
   IF N EQ 2 THEN  BEGIN  ; Assume All the data will be retrieved.
      I = 0
      J = N_ELEMENTS( T ) - 1
   ENDIF  ELSE  BEGIN  ; Assume STIME & ETIME are provided.
;     Get the indexes: [I,J] so that T[I:J] will contain the
;     time range of STIME and ETIME.
;     Note the GET_DATA_RANGE_INDEXES procedure is in the file:
;     GetLongTermNANOdataProducts.pro
      GET_DATA_RANGE_INDEXES,  T,  $ ;
                     STIME,ETIME,  $ ; use the Start & End Times
                         I,    J,  $ ; to the indexes: I,J
                         STATUS      ; STATUS = 1 means OK.
      IF STATUS EQ 0 THEN  BEGIN  ; All Data in the IRIS_DETIDE will be used.
         I = 0
         J = N_ELEMENTS( TIME ) - 1
      ENDIF ;
   ENDELSE  ; Selecting data range.
;
   N = J - I + 1
   PRINT_TXYT_DATA2FILE,  T[I:J],  $  ; Selected Times.
                XT[I:J], YT[I:J],  $  ; Selected Average Tilts.
              REPLICATE( '', N ),  $  ; Dummy array.
                     OUTPUT_FILE
;
ENDELSE  ; Printing data to file.
;
RETURN
END  ; PRINT_AVE_TILTS2FILE
;
; Callers: PRINT_RSN_DATA2FILE or Users.
; Add  on  June 2nd, 2017
;
PRO PRINT_HEAT_DATA2FILE, IDL_FILE,  $ ; Input: IDL Save File name.
                       OUTPUT_FILE,  $ ; Input:   Output File name.
    STIME, ETIME  ; Inputs: Start & End Time of the data range to be printed
;
   N = N_PARAMS()  ; Get Total input parameters.
;
IF N LT 2 THEN  BEGIN
   PRINT, 'From PRINT_HEAT_DATA2FILE,'
   PRINT, 'Must provide an IDL Save File and an Output File names.'
   PRINT, 'NO data retrieved!'
ENDIF  ELSE  BEGIN  ; Assume at IDL_FILE & OUTPUT_FILE are provided.
;
;  Retrieve the data from the IDL_FILE and the array variables will be
;  HEAT_TIME, HEAT_XTILT, HEAT_YTILT and HEAT_TEMP
; 
   RESTORE, IDL_FILE
;
   IF N EQ 2 THEN  BEGIN  ; Assume All the data will be retrieved.
      I = 0
      J = N_ELEMENTS( HEAT_TIME ) - 1
   ENDIF  ELSE  BEGIN  ; Assume STIME & ETIME are provided.
;     Get the indexes: [I,J] so that HEAT_TIME[I:J] will contain the
;     time range of STIME and ETIME.
;     Note the GET_DATA_RANGE_INDEXES procedure is in the file:
;     GetLongTermNANOdataProducts.pro
      GET_DATA_RANGE_INDEXES,   HEAT_TIME,  $ ;
                              STIME,ETIME,  $ ; use the Start & End Times
                              I,    J,      $ ; to the indexes: I,J
                              STATUS          ; STATUS = 1 means OK.
      IF STATUS EQ 0 THEN  BEGIN  ; All Data in the IRIS_DETIDE will be used.
         I = 0
         J = N_ELEMENTS( HEAT_TIME ) - 1
      ENDIF  ;
   ENDELSE
;
   PRINT_TXYT_DATA2FILE,  HEAT_TIME[I:J],   $
         HEAT_XTILT[I:J], HEAT_YTILT[I:J],  $
         HEAT_TEMP[I:J] , OUTPUT_FILE
;
ENDELSE
;
RETURN
END  ; PRINT_HEAT_DATA2FILE
;
; Callers: PRINT_RSN_DATA2FILE or Users.
; Revised on November  18th  2015
;
PRO PRINT_IRIS_DATA2FILE, IDL_FILE,  $ ; Input: IDL Save File name.
                       OUTPUT_FILE,  $ ; Input:   Output File name.
    STIME, ETIME  ; Inputs: Start & End Time of the data range to be printed
;
   N = N_PARAMS()  ; Get Total input parameters.
;
IF N LT 2 THEN  BEGIN
   PRINT, 'From PRINT_IRIS_DATA2FILE,'
   PRINT, 'Must provide an IDL Save File and an Output File names.'
   PRINT, 'NO data retrieved!'
ENDIF  ELSE  BEGIN  ; Assume at IDL_FILE & OUTPUT_FILE are provided.
;
;  Retrieve the data from the IDL_FILE and the array variables will be
;  IRIS_TIME, IRIS_XTILT, IRIS_YTILT and IRIS_TEMP
; 
   RESTORE, IDL_FILE
;
   IF N EQ 2 THEN  BEGIN  ; Assume All the data will be retrieved.
      I = 0
      J = N_ELEMENTS( IRIS_TIME ) - 1
   ENDIF  ELSE  BEGIN  ; Assume STIME & ETIME are provided.
;     Get the indexes: [I,J] so that IRIS_TIME[I:J] will contain the
;     time range of STIME and ETIME.
;     Note the GET_DATA_RANGE_INDEXES procedure is in the file:
;     GetLongTermNANOdataProducts.pro
      GET_DATA_RANGE_INDEXES,   IRIS_TIME,  $ ;
                              STIME,ETIME,  $ ; use the Start & End Times
                              I,    J,      $ ; to the indexes: I,J
                              STATUS          ; STATUS = 1 means OK.
      IF STATUS EQ 0 THEN  BEGIN  ; All Data in the IRIS_DETIDE will be used.
         I = 0
         J = N_ELEMENTS( IRIS_TIME ) - 1
      ENDIF  ;
   ENDELSE
;
   PRINT_TXYT_DATA2FILE,  IRIS_TIME[I:J],   $
         IRIS_XTILT[I:J], IRIS_YTILT[I:J],  $
         IRIS_TEMP[I:J] , OUTPUT_FILE
;
ENDELSE
;
RETURN
END  ; PRINT_IRIS_DATA2FILE
;
; Callers: PRINT_RSN_DATA2FILE or Users.
; Revised: May 25th, 2017
;
PRO PRINT_LILY_DATA2FILE, IDL_FILE,  $ ; Input: IDL Save File name.
                       OUTPUT_FILE,  $ ; Input:   Output File name.
    STIME, ETIME  ; Inputs: Start & End Time of the data range to be printed
;
   N = N_PARAMS()  ; Get Total input parameters.
;
IF N LT 2 THEN  BEGIN
   PRINT, 'From PRINT_IRIS_DATA2FILE,'
   PRINT, 'Must provide an IDL Save File and an Output File names.'
   PRINT, 'NO data retrieved!'
ENDIF  ELSE  BEGIN  ; Assume at IDL_FILE & OUTPUT_FILE are provided.
;
;  Retrieve the data from the IDL_FILE and the array variables will be
;  LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_TEMP, LILY_RTM and LILY_RTD
; 
   PRINT, SYSTIME() + ' Retrieving LILY data from file: ' + IDL_FILE
   S = SYSTIME( 1 ) ; Mark the time.
   RESTORE, IDL_FILE
   PRINT, SYSTIME() + ' LILY data Retrieved.  Seconds used: ', SYSTIME( 1 ) - S
;
   IF N EQ 2 THEN  BEGIN  ; Assume All the data will be retrieved.
      I = 0
      J = N_ELEMENTS( LILY_TIME ) - 1
   ENDIF  ELSE  BEGIN  ; Assume STIME & ETIME are provided.
;     Get the indexes: [I,J] so that IRIS_TIME[I:J] will contain the
;     time range of STIME and ETIME.
;     Note the GET_DATA_RANGE_INDEXES procedure is in the file:
;     GetLongTermNANOdataProducts.pro
      GET_DATA_RANGE_INDEXES,   LILY_TIME,  $ ;
                              STIME,ETIME,  $ ; use the Start & End Times
                              I,    J,      $ ; to the indexes: I,J
                              STATUS          ; STATUS = 1 means OK.
      IF STATUS EQ 0 THEN  BEGIN  ; All Data in the IRIS_DETIDE will be used.
         I = 0
         J = N_ELEMENTS( LILY_TIME ) - 1
      ENDIF  ;
   ENDELSE
;
;  The following 2 statements only work when the data lengths are short enough.
;  When use for the over 2 years long data set, "Unable to allocate memory: to make array"
;  will occur!  May 25th, 2017.
;
;  DATA = [ [LILY_XTILT[I:J]], [LILY_YTILT[I:J]],                $
;           [LILY_RTD[I:J]],   [LILY_RTM[I:J]], [LILY_TEMP[I:J]] ]
;
;  PRINT_DATA2FILE, LILY_TIME[I:J], DATA, OUTPUT_FILE
;
;
;  Note that It is assume that All the LILY_* arrays are the same size.
;
   N = J - I + 1  ;  Total data point in each array to be printed.
;
;  IF N LE 864000 THEN  BEGIN  ; Data points <= 10 days long.
;     PRINT, SYSTIME() + ' Printing LILY data into ' + OUTPUT_FILE
;     S = SYSTIME( 1 ) ; Mark the time.
;     DATA = [ [LILY_XTILT[I:J]], [LILY_YTILT[I:J]],                $
;              [LILY_RTD[I:J]],   [LILY_RTM[I:J]], [LILY_TEMP[I:J]] ]
;     PRINT_DATA2FILE, LILY_TIME[I:J], DATA, OUTPUT_FILE
;     PRINT, SYSTIME() + ' Done Printing LILY data.  Seconds used:  ', SYSTIME( 1 ) - S
;  ENDIF  ELSE  BEGIN  ; Data points > 10 days long.
;
;     Convert the LILY_TIME in the IDL JULDAY()'s values into string as
;     2015/04/23 00:00:15 for example.
;
      PRINT, SYSTIME() + ' Preparing LILY Time Indexes...'
      S = SYSTIME( 1 ) ; Mark the time.
      T = STRING( LILY_TIME[I:J],  $
          FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
      N = SYSTIME( 1 ) - S  ; Total seconds used for preparing LILY Time Indexes.
      PRINT, SYSTIME() + ' Done Preparing LILY Time Indexes.  Seconds used:  ', N
      OPENW, OUTPUT_UNIT, OUTPUT_FILE, /GET_LUN
      PRINT, SYSTIME() + ' Printing LILY data into ' + OUTPUT_FILE
      N = SYSTIME( 1 ) ; Mark the time.
      FOR S = I, J DO  BEGIN 
          PRINTF, OUTPUT_UNIT, T[S-I]  + ',',  $
          STRCOMPRESS( LILY_XTILT[S] ) + ',', STRCOMPRESS( LILY_YTILT[S] ) + ',',  $
          STRCOMPRESS( LILY_RTD[S]   ) + ',', STRCOMPRESS( LILY_RTM[S]   ) + ',',  $
          STRCOMPRESS( LILY_TEMP[S]  )
      ENDFOR ; S
      PRINT, SYSTIME() + ' Done Printing LILY data.  Seconds used:  ', SYSTIME( 1 ) - N
      CLOSE,     OUTPUT_UNIT
      FREE_LUN,  OUTPUT_UNIT
;  ENDELSE  ; Printing out LILY data.
;
ENDELSE
;
RETURN
END  ; PRINT_LILY_DATA2FILE
;
; Callers: PRINT_RSN_DATA2FILE or Users.
;
PRO PRINT_NANO_DATA2FILE, IDL_FILE,  $ ; Input: IDL Save File name.
                       OUTPUT_FILE,  $ ; Input:   Output File name.
    STIME, ETIME  ; Inputs: Start & End Time of the data range to be printed
;
   N = N_PARAMS()  ; Get Total input parameters.
;
IF N LT 2 THEN  BEGIN
   PRINT, 'From PRINT_NANO_DATA2FILE,'
   PRINT, 'Must provide an IDL Save File and an Output File names.'
   PRINT, 'NO data retrieved!'
ENDIF  ELSE  BEGIN  ; Assume at IDL_FILE & OUTPUT_FILE are provided.
;
;  Retrieve the data from the IDL_FILE and the array variables will be
;  NANO_TIME, NANO_PSIA, NANO_DETIDE and NANO_TEMP
; 
   RESTORE, IDL_FILE
;
   IF N EQ 2 THEN  BEGIN  ; Assume All the data will be retrieved.
      I = 0
      J = N_ELEMENTS( NANO_TIME ) - 1
   ENDIF  ELSE  BEGIN  ; Assume STIME & ETIME are provided.
;     Get the indexes: [I,J] so that NANO_TIME[I:J] will contain the
;     time range of STIME and ETIME.
;     Note the GET_DATA_RANGE_INDEXES procedure is in the file:
;     GetLongTermNANOdataProducts.pro
      GET_DATA_RANGE_INDEXES,   NANO_TIME,  $ ;
                              STIME,ETIME,  $ ; use the Start & End Times
                              I,    J,      $ ; to the indexes: I,J
                              STATUS          ; STATUS = 1 means OK.
      IF STATUS EQ 0 THEN  BEGIN  ; All Data in the NANO_DETIDE will be used.
         I = 0
         J = N_ELEMENTS( NANO_TIME ) - 1
      ENDIF  ;
   ENDELSE
;
   PRINT_TXYT_DATA2FILE, NANO_TIME[I:J],    $
         NANO_PSIA[I:J], NANO_DETIDE[I:J],  $
         NANO_TEMP[I:J], OUTPUT_FILE
;
ENDELSE
;
RETURN
END  ; PRINT_NANO_DATA2FILE
;
; Callers: Users.
;
PRO PRINT_RSN_DATA2FILE, IDL_FILE,  $ ;  Input: IDL Save File name.
                      OUTPUT_FILE     ;  Input:   Output File name.
;
FILE = FILE_INFO( IDL_FILE )  ; Get the IDL Save File's information.
;  
IF NOT FILE.EXISTS THEN  BEGIN  ; The IDL_FILE cannot be found.
   PRINT, 'From PRINT_RSN_DATA2FILE, the IDL Save File: ', IDL_FILE
   PRINT, 'Cannot be found.  No figures are created.'
ENDIF  ELSE  BEGIN  ;  The IDL_FILE is Found.
;  It is assume the IDL_FILE will in 'MJ03F-LILY.idl', 'MJ03D-IRIS.idl', etc.
;  Get the IDL_FILE's ID = 'LILY', 'IRIS', etc.
   N    = STRLEN( IDL_FILE )
   TYPE = STRMID( IDL_FILE, N-8, 4 )  ; = 'NANO' e.g.
   HELP, TYPE, N
   CASE TYPE OF
       'HEAT' : PRINT_HEAT_DATA2FILE, IDL_FILE, OUTPUT_FILE
       'IRIS' : PRINT_IRIS_DATA2FILE, IDL_FILE, OUTPUT_FILE
       'LILY' : PRINT_LILY_DATA2FILE, IDL_FILE, OUTPUT_FILE
       'NANO' : PRINT_NANO_DATA2FILE, IDL_FILE, OUTPUT_FILE
        ELSE  : BEGIN
                  PRINT, 'From PRINT_RSN_DATA2FILE, the IDL Save File: ', IDL_FILE
                  PRINT, 'May Not contain RSN Data.  No figures are created.'
                END
   ENDCASE
ENDELSE
;
RETURN
END  ; PRINT_RSN_DATA2FILE
;
; Callers: UPDATE_DIFF_FILE or Users.
; Revised: July  5th, 2019
;
PRO PRINT_DIFF_DATA2FILE, TIME,  $ ; Input : 1-D array of JULDAY()'s values
                 DIFF,  $ ; Inputs: 1-D arrays of NANO Difference of MJ03E - MJ03F.
          OUTPUT_FILE     ; Input : Output File name.
;
; Convert the TIME in the IDL JULDAY()'s values into string as
; 2015/04/23 00:00:15 for example.
;
  PRINT, SYSTIME() + ' Preparing Time Indexes...'
  S = SYSTIME( 1 ) ; Mark the time.
  T = STRING( TIME,  $
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
  N = SYSTIME( 1 ) - S  ; Total seconds used for preparing LILY Time Indexes.
  PRINT, SYSTIME() + ' Done Preparing Time Indexes.  Seconds used:  ', N
;
; Open the OUTPUT_FILE for printing the DATA into it as a ASCII/Text.
;
  OPENW, OUTPUT_UNIT, OUTPUT_FILE, /GET_LUN
;
  PRINT, SYSTIME() + ' Printing data into ' + OUTPUT_FILE
;
  N = N_ELEMENTS( TIME )  ; Total data point in each array to be printed.
  I =    SYSTIME( 1 )     ; Mark the time.
;
  FOR S = 0, N-1  DO  BEGIN
      PRINTF, OUTPUT_UNIT,  T[S]   + ',', STRCOMPRESS( DIFF[S] )
  ENDFOR ; S
;
  PRINT, SYSTIME() + ' From: PRINT_DIFF_DATA2FILE, Done Printing data.  Seconds used:  ',  $
         SYSTIME( 1 ) - I
;
  CLOSE,     OUTPUT_UNIT
  FREE_LUN,  OUTPUT_UNIT
;
RETURN
END  ; PRINT_DIFF_DATA2FILE
;
; Callers: PRINT_[HEAT/IRIS/NANO]_DATA2FILE, or Users.
; Revised: June 24th, 2019
;
PRO PRINT_TXYT_DATA2FILE, TIME,  $ ; Input : 1-D array of JULDAY()'s values
               X, Y,  $ ; Inputs: 1-D arrays of Tilts or PSIA & Detided data.
               TEMP,  $ ; Input : 1-D array of Temperatures.
        OUTPUT_FILE     ; Input : Output File name.
;
; Convert the TIME in the IDL JULDAY()'s values into string as
; 2015/04/23 00:00:15 for example.
;
  PRINT, SYSTIME() + ' Preparing Time Indexes...'
  S = SYSTIME( 1 ) ; Mark the time.
  T = STRING( TIME,  $
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
  N = SYSTIME( 1 ) - S  ; Total seconds used for preparing LILY Time Indexes.
  PRINT, SYSTIME() + ' Done Preparing Time Indexes.  Seconds used:  ', N
;
; Open the OUTPUT_FILE for printing the DATA into it as a ASCII/Text.
;
  OPENW, OUTPUT_UNIT, OUTPUT_FILE, /GET_LUN
;
  PRINT, SYSTIME() + ' Printing data into ' + OUTPUT_FILE
;
     N = N_ELEMENTS( TIME )  ; Total data point in each array to be printed.
     I =    SYSTIME( 1 )     ; Mark the time.
;
; To be uniform for all output, the printing option for Data points <= 10 days long
; is turned off since June 21st, 2019.
;
; IF N LE 864000 THEN  BEGIN  ; Data points <= 10 days long.
;    Put All the TIME, X, Y, & TEMP data into a 2-D array: DATA for printing.
;    DATA = TRANSPOSE( [ [ T ], [ STRING( X ) ], [ STRING( Y ) ], [ STRING( TEMP ) ] ] )
;    PRINTF,    OUTPUT_UNIT, DATA
; ENDIF  ELSE  BEGIN  ; Data points > 10 days long.
      FOR S = 0, N-1  DO  BEGIN
          PRINTF, OUTPUT_UNIT,  T[S]   + ',', STRCOMPRESS(    X[S] ) + ',',   $
                   STRCOMPRESS( Y[S] ) + ',', STRCOMPRESS( TEMP[S] )
      ENDFOR ; S
; ENDELSE  ; Printing data.
;
  PRINT, SYSTIME() + ' Done Printing Time, Temperature & data.  Seconds used:  ', SYSTIME( 1 ) - I
;
  CLOSE,     OUTPUT_UNIT
  FREE_LUN,  OUTPUT_UNIT
;
RETURN
END  ; PRINT_TXYT_DATA2FILE
;
; Callers: PRINT_LILY_DATA2FILE, UPDATE_LILY_FILE or Users.
; Revised: June 24th, 2019
;
PRO PRINT_TXYDRT_DATA2FILE, TIME,  $ ; Input : 1-D array of JULDAY()'s values
                 X, Y,  $ ; Inputs: 1-D arrays of Tilts or PSIA & Detided data.
                 D, R,  $ ; Inputs: 1-D arrays of Directions and  Magnitudes.
                 TEMP,  $ ; Input : 1-D array of Temperatures.
          OUTPUT_FILE     ; Input : Output File name.
;
; Convert the TIME in the IDL JULDAY()'s values into string as
; 2015/04/23 00:00:15 for example.
;
  PRINT, SYSTIME() + ' Preparing Time Indexes...'
  S = SYSTIME( 1 ) ; Mark the time.
  T = STRING( TIME,  $
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
  N = SYSTIME( 1 ) - S  ; Total seconds used for preparing LILY Time Indexes.
  PRINT, SYSTIME() + ' Done Preparing Time Indexes.  Seconds used:  ', N
;
; Open the OUTPUT_FILE for printing the DATA into it as a ASCII/Text.
;
  OPENW, OUTPUT_UNIT, OUTPUT_FILE, /GET_LUN
;
  PRINT, SYSTIME() + ' Printing data into ' + OUTPUT_FILE
;
  N = N_ELEMENTS( TIME )  ; Total data point in each array to be printed.
  I =    SYSTIME( 1 )     ; Mark the time.
;
  FOR S = 0, N-1  DO  BEGIN
      PRINTF, OUTPUT_UNIT,    T[S]   + ',',                             $
              STRCOMPRESS(    X[S] ) + ',', STRCOMPRESS( Y[S] ) + ',',  $
              STRCOMPRESS(    D[S] ) + ',', STRCOMPRESS( R[S] ) + ',',  $
              STRCOMPRESS( TEMP[S] )
  ENDFOR ; S
;
  PRINT, SYSTIME() + ' From: PRINT_TXYDRT_DATA2FILE, Done Printing data.  Seconds used:  ',  $
         SYSTIME( 1 ) - I
;
  CLOSE,     OUTPUT_UNIT
  FREE_LUN,  OUTPUT_UNIT
;
RETURN
END  ; PRINT_TXYDRT_DATA2FILE
;
; Callers: PRINT_LILY_DATA2FILE and Users.
; Revised: October  5th, 2015
;
PRO PRINT_DATA2FILE, TIME,  $ ; Input : 1-D array of JULDAY()'s values
                     DATA,  $ ; Input : 2-D array of N_TIME x N Data Columns.
              OUTPUT_FILE     ; Input : Output File name.
;
; Note that It is assume that  N_ELEMENTS( TIME ) = the Size of 1st dimension of DATA
; and DATA is a 2-D array of the numbers.
;
; S = SIZE( DATA, /DIMENSION )  ; S[0] = N_ELEMENTS( TIME )
; N = S[1]
;
; Convert the TIME in the IDL JULDAY()'s values into string as
; 2015/04/23 00:00:15 for example.
;
  T = STRING( TIME,  $
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
;
; Combine the TIME and DATA into a 2-D array: DATA for printing.
;
  D = TRANSPOSE( [ [ T ], [ STRTRIM( DATA, 1 ) ] ] )
;
; Put All the TIME and DATA into a 2-D array.
;
  OPENW,     OUTPUT_UNIT, OUTPUT_FILE, /GET_LUN
  PRINTF,    OUTPUT_UNIT, D
  CLOSE,     OUTPUT_UNIT
  FREE_LUN,  OUTPUT_UNIT
;
RETURN
END  ; PRINT_DATA2FILE
;
; This procedure will use the information inside the
; file: LastUpatedMJ03E-FinfoFile.Diff to append the newly down loaded
; Diff data into the text file: MJ03E-F201?Diff.Data which is listed in the info file above.
;
; Callers: Users.
;
; Revised on September  1st, 2020
;
PRO UPDATE_DIFF_FILE, IDL_FILE,  $ ; Input: IDL Save File name contains the RSN data.
              UPDATE_INFO_FILE     ; Input: File name contains the Updated File name.
;
; Look for the UPDATE_INFO_FILE.  Noted that UPDATE_INFO_FILE may contains directory path.
; UPDATE_INFO_FILE = '/data/lau/LastUpatedMJ03E-FinfoFile.Diff' for example.
;
  S = FILE_SEARCH( UPDATE_INFO_FILE, COUNT=N )
;
  IF N LE 0 THEN  BEGIN  ; No UPDATE_INFO_FILE is found.
     PRINT, 'Cannot find the Info File: ' + UPDATE_INFO_FILE
     PRINT, 'UPDATE_DIFF_FILE stops.'
;    LAST_PROCESSED_RCD_DATE  = -1
;    LAST_PROCESSED_FILE_NAME = 'None'
     RETURN  ; to caller.
  ENDIF  ELSE  BEGIN    ; UPDATE_INFO_FILE exists.
;    Read in the info from the UPDATE_INFO_FILE.
     LAST_PROCESSED_RCD_DATE  = 0.0D0    ; will be a JULDAY() value.
     LAST_PROCESSED_FILE_NAME = 'MJ03E-F2019NANOdiff.Data'  ; for example.
     OPENR, 10, UPDATE_INFO_FILE
     READF, 10, LAST_PROCESSED_FILE_NAME  ; = 'MJ03E2019LILY.Data' e.g.
     READF, 10, LAST_PROCESSED_RCD_DATE, FORMAT='(C())'  ; in JULDAY().
     CLOSE, 10
  ENDELSE
;
; Look for the IDL_FILE.  Noted that IDL_FILE may contains its own directory path.
;
  S = FILE_SEARCH( IDL_FILE, COUNT=N )
;
;  Retrieve the data from the IDL_FILE and the array variables will be
;  LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_TEMP, LILY_RTM and LILY_RTD
; 
  IF N GT 0 THEN  BEGIN  ; IDL_FILE exists.
     RESTORE, IDL_FILE   ; Get the Diff array variables: NANO_TIME & NANO_DIFF
  ENDIF  ELSE  BEGIN  ; No IDL_FILE is found.
     PRINT, 'Cannot find the Diff IDL Save File: ' + IDL_FILE
     PRINT, 'UPDATE_DIFF_FILE stops.'
     RETURN  ; to caller.
  ENDELSE
;
; Get the directory path from the UPDATE_INFO_FILE, for example,
; UPDATE_INFO_FILE = '/data/lau/LastUpatedMJ03E-FinfoFile.Diff', then PATH = '/data/lau/'
; It is assumed that the MJ03E-F2019NANOdiff.Data file, for example, is located
; at the same directory: '/data/lau/'
;
  PATH = FILE_DIRNAME( UPDATE_INFO_FILE, /MARK_DIRECTORY )
;
; Get the last index in the LILY_TIME array.
;
         N  = N_ELEMENTS( NANO_TIME )    ; Total NANO records.
         N -= 1  ; Now N = the last index of the NANO arrays.
; LAST_CURRENT_RCD_TIME = NANO_TIME[N]
;
  IF NANO_TIME[N] LE LAST_PROCESSED_RCD_DATE THEN  BEGIN  ; No new data available yet.
     PRINT,    'The Last Updated Record Time is ' + STRING( FORMAT='(C())', LAST_PROCESSED_RCD_DATE )
     PRINT, '>= the Last Current Record Time is ' + STRING( FORMAT='(C())', NANO_TIME[N] )
     PRINT, 'UPDATE_DIFF_FILE stops.'
  ENDIF  ELSE  BEGIN ; LAST_PROCESSED_RCD_DATE < NANO_TIME[N], i.e., there are new data.
     CD, PATH, CURRENT=CURRENT_PATH
     OUTPUT_FILE = LAST_PROCESSED_FILE_NAME + '.BackUp'
     PRINT, SYSTIME() + ' Copying ' + LAST_PROCESSED_FILE_NAME  $
                      + ' to ' + OUTPUT_FILE
     FILE_COPY, /OVERWRITE, LAST_PROCESSED_FILE_NAME, OUTPUT_FILE
     OUTPUT_FILE = 'TemporaryDiff.Data'  ; for storing the new records.
;    The Function: LOCATE_TIME_POSITION is in the file: SplitRSNdata.pro
     S  = LOCATE_TIME_POSITION( NANO_TIME, LAST_PROCESSED_RCD_DATE )
     IF NOT ( NANO_TIME[S] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
        S += 1  ; So that NANO_TIME[S] > LAST_PROCESSED_RCD_DATE.
     ENDIF
;    Get the Year (LAST_YR) from the LAST_PROCESSED_RCD_DATE.
     CALDAT, LAST_PROCESSED_RCD_DATE, M, D, LAST_YR  ;, Hour, Minute, Second
;    Get the Year (LAST_YR) from the Last NANO_TIME record.
     CALDAT, NANO_TIME[N],       M, D, LAST_NANO_YR  ;, Hour, Minute, Second
     IF LAST_YR EQ LAST_NANO_YR THEN  BEGIN  ; Both data sets has the same year.
        D = STRING( FORMAT='(C())', NANO_TIME[S] ) + ' and '  $
          + STRING( FORMAT='(C())', NANO_TIME[N] )
        PRINT, SYSTIME() + ' Retrieving data between ' + D
        PRINT_DIFF_DATA2FILE,  NANO_TIME[S:N], NANO_DIFF[S:N], OUTPUT_FILE
        PRINT, SYSTIME() + ' Appending the retrieved data into the file: ' $
                         +   LAST_PROCESSED_FILE_NAME
        OPENR, 10, OUTPUT_FILE  ; Contains the Newly retrieved records.
        OPENU, 20, LAST_PROCESSED_FILE_NAME, /APPEND
;       Append the all records in the unit: 10 into unit: 20.
        COPY_LUN, 10, 20, /EOF, /LINES, TRANSFER_COUNT=M
        FILE_DELETE, /ALLOW_NONEXISTENT, LAST_PROCESSED_FILE_NAME + '.BackUp'  ; Not Needed.
     ENDIF  ELSE  BEGIN  ; Assume LAST_YR < LAST_NANO_YR, i.e. Data go across years.
;       Finish updating the year of the LAST_PROCESSED_FILE_NAME.
        PRINT, SYSTIME() + ' Data across to a new year. ', LAST_YR, LAST_NANO_YR
        M  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY( 12,31,LAST_YR, 23,59,59 ) )
        IF ( NANO_TIME[M] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
           M -= 1  ; So that NANO_TIME[M] <= LAST_PROCESSED_RCD_DATE.
        ENDIF
        PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', LAST_YR
        PRINT_DIFF_DATA2FILE,  NANO_TIME[S:M], NANO_DIFF[S:M], OUTPUT_FILE
        OPENR, 10, OUTPUT_FILE  ; Contains the Newly retrieved records.
        OPENU, 20, LAST_PROCESSED_FILE_NAME, /APPEND
;       Append the all records in the unit: 10 into unit: 20.
        COPY_LUN, 10, 20, /EOF, /LINES, TRANSFER_COUNT=D
        FILE_DELETE, /ALLOW_NONEXISTENT,  LAST_PROCESSED_FILE_NAME + '.BackUp'  ; Not Needed.
;       Get the 1st 5 characters from the LAST_PROCESSED_FILE_NAME which will be
        D = STRMID( LAST_PROCESSED_FILE_NAME, 0, 7 )            ; = 'MJ03E-F' e.g.
        FOR YR = ( LAST_YR + 1 ), ( LAST_NANO_YR - 1 ) DO  BEGIN
            PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', YR
            S  = M + 1  ; Index of the Beginning of the YR.
            M  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY( 12,31,YR, 23,59,59 ) )
            IF ( NANO_TIME[M] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
               M -= 1  ; So that NANO_TIME[M] <= LAST_PROCESSED_RCD_DATE.
            ENDIF
            OUTPUT_FILE = D + STRING( FORMAT='(I4)', YR ) + 'NANOdiff.Data'  ; = 'MJ03E-F2018NANOdiff.Data' e.g.
            PRINT_DIFF_DATA2FILE,  NANO_TIME[S:M], NANO_DIFF[S:M], OUTPUT_FILE
        ENDFOR  ; Processing the individual whole year.
;       Retrieve the data for the last most current year: LAST_NANO_YR
;       and their range of indexes should be S=M+1 and N.
        S  = M + 1  ; Index of the Beginning of the LAST_NANO_YR.
;       Generate a New OUTPUT_FILE name, e.g. 'MJ03D2019Diff.Data'
        PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', LAST_NANO_YR
        OUTPUT_FILE = D + STRING( FORMAT='(I4)', LAST_NANO_YR ) + 'NANOdiff.Data'
        PRINT_DIFF_DATA2FILE,  NANO_TIME[S:N], NANO_DIFF[S:N], OUTPUT_FILE
        LAST_PROCESSED_FILE_NAME = OUTPUT_FILE  ; to be updated into the UPDATE_INFO_FILE.
     ENDELSE
     CLOSE, 10, 20  ;
     FILE_DELETE, /ALLOW_NONEXISTENT, 'TemporaryDiff.Data'                  ; Not Needed.
;    Update the UPDATE_INFO_FILE.
     CD,     CURRENT_PATH      ; Must be Reset back to the original directory 1st.
     PRINT, SYSTIME() + ' Update the info file: ' +  UPDATE_INFO_FILE
     OPENW,  10, UPDATE_INFO_FILE          ; So that UPDATE_INFO_FILE can be open.
     PRINTF, 10, LAST_PROCESSED_FILE_NAME  ; = 'MJ03E-F2019NANOdiff.Data' e.g.
                 LAST_PROCESSED_RCD_DATE = NANO_TIME[N]        ; in JULDAY().
     PRINTF, 10, LAST_PROCESSED_RCD_DATE, FORMAT='(C(),A)',  $ ;
                 '  <-- The last record Date & Time in the file above.'
     CLOSE,  10
     PRINT, SYSTIME() + ' File: ' + UPDATE_INFO_FILE + ' Updated.'
  ENDELSE  ; Updating the new Diff data.
;
;  CD, CURRENT_PATH  ; Reset back to the original directory.
;
RETURN
END  ; UPDATE_DIFF_FILE
;
; This procedure will use the information inside the
; file: LastUpatedMJ03[B,D/../F]infoFile.LILY to append the newly down loaded
; LILY data into the text file: MJ03D201?LILY.Data which is listed in the info file above.
;
; Callers: Users.
;
; Revised on September  1st, 2020
;
PRO UPDATE_LILY_FILE, IDL_FILE,  $ ; Input: IDL Save File name contains the RSN data.
              UPDATE_INFO_FILE     ; Input: File name contains the Updated File name.
;
; Look for the UPDATE_INFO_FILE.  Noted that UPDATE_INFO_FILE may contains directory path.
; UPDATE_INFO_FILE = 'data/lau/LastUpatedMJ03EinfoFile.LILY' for example.
;
  S = FILE_SEARCH( UPDATE_INFO_FILE, COUNT=N )
;
  IF N LE 0 THEN  BEGIN  ; No UPDATE_INFO_FILE is found.
     PRINT, 'Cannot find the Info File: ' + UPDATE_INFO_FILE
     PRINT, 'UPDATE_LILY_FILE stops.'
;    LAST_PROCESSED_RCD_DATE  = -1
;    LAST_PROCESSED_FILE_NAME = 'None'
     RETURN  ; to caller.
  ENDIF  ELSE  BEGIN    ; UPDATE_INFO_FILE exists.
;    Read in the info from the UPDATE_INFO_FILE.
     LAST_PROCESSED_RCD_DATE  = 0.0D0    ; will be a JULDAY() value.
     LAST_PROCESSED_FILE_NAME = 'MJ03E2019LILY.Data'  ; for example.
     OPENR, 10, UPDATE_INFO_FILE
     READF, 10, LAST_PROCESSED_FILE_NAME  ; = 'MJ03E2019LILY.Data' e.g.
     READF, 10, LAST_PROCESSED_RCD_DATE, FORMAT='(C())'  ; in JULDAY().
     CLOSE, 10
  ENDELSE
;
; Look for the IDL_FILE.  Noted that IDL_FILE may contains its own directory path.
;
  S = FILE_SEARCH( IDL_FILE, COUNT=N )
;
;  Retrieve the data from the IDL_FILE and the array variables will be
;  LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_TEMP, LILY_RTM and LILY_RTD
; 
  IF N GT 0 THEN  BEGIN  ; IDL_FILE exists.
     RESTORE, IDL_FILE   ; Get the LILY array variables.
  ENDIF  ELSE  BEGIN  ; No IDL_FILE is found.
     PRINT, 'Cannot find the LILY IDL Save File: ' + IDL_FILE
     PRINT, 'UPDATE_LILY_FILE stops.'
     RETURN  ; to caller.
  ENDELSE
;
; Get the directory path from the UPDATE_INFO_FILE, for example,
; UPDATE_INFO_FILE = '/data/lau/LastUpatedMJ03EinfoFile.LILY', then PATH = '/data/lau/'
; It is assumed that the MJ03E2019LILY.Data file, for example, is located
; at the same directory: '/data/lau/'
;
  PATH = FILE_DIRNAME( UPDATE_INFO_FILE, /MARK_DIRECTORY )
;
; Get the last index in the LILY_TIME array.
;
         N  = N_ELEMENTS( LILY_TIME )    ; Total LILY records.
         N -= 1  ; Now N = the last index of the LILY arrays.
; LAST_CURRENT_RCD_TIME = LILY_TIME[N]
;
  IF LILY_TIME[N] LE LAST_PROCESSED_RCD_DATE THEN  BEGIN  ; No new data available yet.
     PRINT,    'The Last Updated Record Time is ' + STRING( FORMAT='(C())', LAST_PROCESSED_RCD_DATE )
     PRINT, '>= the Last Current Record Time is ' + STRING( FORMAT='(C())', LILY_TIME[N] )
     PRINT, 'UPDATE_LILY_FILE stops.'
  ENDIF  ELSE  BEGIN ; LAST_PROCESSED_RCD_DATE < LILY_TIME[N], i.e., there are new data.
     CD, PATH, CURRENT=CURRENT_PATH
     OUTPUT_FILE = LAST_PROCESSED_FILE_NAME + '.BackUp'
     PRINT, SYSTIME() + ' Copying ' + LAST_PROCESSED_FILE_NAME  $
                      + ' to ' + OUTPUT_FILE
     FILE_COPY, /OVERWRITE, LAST_PROCESSED_FILE_NAME, OUTPUT_FILE
     OUTPUT_FILE = 'TemporaryLILY.Data'  ; for storing the new records.
;    The Function: LOCATE_TIME_POSITION is in the file: SplitRSNdata.pro
     S  = LOCATE_TIME_POSITION( LILY_TIME, LAST_PROCESSED_RCD_DATE )
     IF NOT ( LILY_TIME[S] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
        S += 1  ; So that LILY_TIME[S] > LAST_PROCESSED_RCD_DATE.
     ENDIF
;    Get the Year (LAST_YR) from the LAST_PROCESSED_RCD_DATE.
     CALDAT, LAST_PROCESSED_RCD_DATE, M, D, LAST_YR  ;, Hour, Minute, Second
;    Get the Year (LAST_YR) from the Last LILY_TIME record.
     CALDAT, LILY_TIME[N],       M, D, LAST_LILY_YR  ;, Hour, Minute, Second
     IF LAST_YR EQ LAST_LILY_YR THEN  BEGIN  ; Both data sets has the same year.
        D = STRING( FORMAT='(C())', LILY_TIME[S] ) + ' and '  $
          + STRING( FORMAT='(C())', LILY_TIME[N] )
        PRINT, SYSTIME() + ' Retrieving data between ' + D
        PRINT_TXYDRT_DATA2FILE,  LILY_TIME[S:N], LILY_XTILT[S:N], LILY_YTILT[S:N],  $
                                 LILY_RTD[S:N],  LILY_RTM[S:N],   LILY_TEMP[S:N], OUTPUT_FILE
        PRINT, SYSTIME() + ' Appending the retrieved data into the file: ' $
                         +   LAST_PROCESSED_FILE_NAME
        OPENR, 10, OUTPUT_FILE  ; Contains the Newly retrieved records.
        OPENU, 20, LAST_PROCESSED_FILE_NAME, /APPEND
;       Append the all records in the unit: 10 into unit: 20.
        COPY_LUN, 10, 20, /EOF, /LINES, TRANSFER_COUNT=M
        FILE_DELETE, /ALLOW_NONEXISTENT, LAST_PROCESSED_FILE_NAME + '.BackUp'  ; Not Needed.
     ENDIF  ELSE  BEGIN  ; Assume LAST_YR < LAST_LILY_YR, i.e. Data go across years.
;       Finish updating the year of the LAST_PROCESSED_FILE_NAME.
        PRINT, SYSTIME() + ' Data across to a new year. ', LAST_YR, LAST_LILY_YR
        M  = LOCATE_TIME_POSITION( LILY_TIME, JULDAY( 12,31,LAST_YR, 23,59,59 ) )
        IF ( LILY_TIME[M] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
           M -= 1  ; So that LILY_TIME[M] <= LAST_PROCESSED_RCD_DATE.
        ENDIF
        PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', LAST_YR
        PRINT_TXYDRT_DATA2FILE,  LILY_TIME[S:M], LILY_XTILT[S:M], LILY_YTILT[S:M],  $
                   LILY_RTD[S:M], LILY_RTM[S:M],  LILY_TEMP[S:M], OUTPUT_FILE
        OPENR, 10, OUTPUT_FILE  ; Contains the Newly retrieved records.
        OPENU, 20, LAST_PROCESSED_FILE_NAME, /APPEND
;       Append the all records in the unit: 10 into unit: 20.
        COPY_LUN, 10, 20, /EOF, /LINES, TRANSFER_COUNT=D
        FILE_DELETE, /ALLOW_NONEXISTENT,  LAST_PROCESSED_FILE_NAME + '.BackUp'  ; Not Needed.
;       Get the 1st 5 characters from the LAST_PROCESSED_FILE_NAME which will be
        D = STRMID( LAST_PROCESSED_FILE_NAME, 0, 5 )            ; = 'MJ03D' e.g.
        FOR YR = ( LAST_YR + 1 ), ( LAST_LILY_YR - 1 ) DO  BEGIN
            PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', YR
            S  = M + 1  ; Index of the Beginning of the YR.
            M  = LOCATE_TIME_POSITION( LILY_TIME, JULDAY( 12,31,YR, 23,59,59 ) )
            IF ( LILY_TIME[M] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
               M -= 1  ; So that LILY_TIME[M] <= LAST_PROCESSED_RCD_DATE.
            ENDIF
            OUTPUT_FILE = D + STRING( FORMAT='(I4)', YR ) + 'LILY.Data'  ; = 'MJ03D2018LILY.Data' e.g.
            PRINT_TXYDRT_DATA2FILE,  LILY_TIME[S:M], LILY_XTILT[S:M], LILY_YTILT[S:M],  $
                       LILY_RTD[S:M], LILY_RTM[S:M],  LILY_TEMP[S:M], OUTPUT_FILE
        ENDFOR  ; Processing the individual whole year.
;       Retrieve the data for the last most current year: LAST_LILY_YR
;       and their range of indexes should be S=M+1 and N.
        S  = M + 1  ; Index of the Beginning of the LAST_LILY_YR.
;       Generate a New OUTPUT_FILE name, e.g. 'MJ03D2019LILY.Data'
        PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', LAST_LILY_YR
        OUTPUT_FILE = D + STRING( FORMAT='(I4)', LAST_LILY_YR ) + 'LILY.Data'
        PRINT_TXYDRT_DATA2FILE,  LILY_TIME[S:N], LILY_XTILT[S:N], LILY_YTILT[S:N],  $
                   LILY_RTD[S:N], LILY_RTM[S:N],  LILY_TEMP[S:N], OUTPUT_FILE
        LAST_PROCESSED_FILE_NAME = OUTPUT_FILE  ; to be updated into the UPDATE_INFO_FILE.
     ENDELSE
     CLOSE, 10, 20  ;
     FILE_DELETE, /ALLOW_NONEXISTENT, 'TemporaryLILY.Data'                  ; Not Needed.
;    Update the UPDATE_INFO_FILE.
     CD,     CURRENT_PATH      ; Must be Reset back to the original directory 1st.
     PRINT, SYSTIME() + ' Update the info file: ' + UPDATE_INFO_FILE
     OPENW,  10, UPDATE_INFO_FILE          ; So that UPDATE_INFO_FILE can be open.
     PRINTF, 10, LAST_PROCESSED_FILE_NAME  ; = 'MJ03E219LILY.Data' e.g.
                 LAST_PROCESSED_RCD_DATE = LILY_TIME[N]        ; in JULDAY().
     PRINTF, 10, LAST_PROCESSED_RCD_DATE, FORMAT='(C(),A)',  $ ;
                 '  <-- The last record Date & Time in the file above.'
     CLOSE,  10
     PRINT, SYSTIME() + ' File: ' + UPDATE_INFO_FILE + ' Updated.'
  ENDELSE  ; Updating the new LILY data.
;
;  CD, CURRENT_PATH  ; Reset back to the original directory.
;
RETURN
END  ; UPDATE_LILY_FILE
;
; This procedure will use the information inside the
; file: LastUpatedMJ03[B,D/../F]infoFile.NANO to append the newly down loaded
; NANO data into the text file: MJ03D201?NANO.Data which is listed in the info file above.
;
; Callers: Users.
;
; Revised on September  1st, 2020
;
PRO UPDATE_NANO_FILE, IDL_FILE,  $ ; Input: IDL Save File name contains the RSN data.
              UPDATE_INFO_FILE     ; Input: File name contains the Updated File name.
;        LILY=UPDATE_LILY_DATA,  $ ; Input: indicate the LILY data will be updated.
;        NANO=UPDATE_NANO_DATA     ; Input: indicate the NANO data will be updated.
;
; Look for the UPDATE_INFO_FILE.  Noted that UPDATE_INFO_FILE may contains directory path.
; UPDATE_INFO_FILE = 'data/lau/LastUpatedMJ03EinfoFile.NANO' for example.
;
  S = FILE_SEARCH( UPDATE_INFO_FILE, COUNT=N )
;
  IF N LE 0 THEN  BEGIN  ; No UPDATE_INFO_FILE is found.
     PRINT, 'Cannot find the Info File: ' + UPDATE_INFO_FILE
     PRINT, 'UPDATE_NANO_FILE stops.'
;    LAST_PROCESSED_RCD_DATE  = -1
;    LAST_PROCESSED_FILE_NAME = 'None'
     RETURN  ; to caller.
  ENDIF  ELSE  BEGIN    ; UPDATE_INFO_FILE exists.
;    Read in the info from the UPDATE_INFO_FILE.
     LAST_PROCESSED_RCD_DATE  = 0.0D0    ; will be a JULDAY() value.
     LAST_PROCESSED_FILE_NAME = 'MJ03E2019NANO.Data'  ; for example.
     OPENR, 10, UPDATE_INFO_FILE
     READF, 10, LAST_PROCESSED_FILE_NAME  ; = 'MJ03E2019NANO.Data' e.g.
     READF, 10, LAST_PROCESSED_RCD_DATE, FORMAT='(C())'  ; in JULDAY().
     CLOSE, 10
  ENDELSE
;
; Look for the IDL_FILE.  Noted that IDL_FILE may contains its own directory path.
;
  S = FILE_SEARCH( IDL_FILE, COUNT=N )
;
; Retrieve the data from the IDL_FILE if it exists and the array variables will be
; NANO_TIME, NANO_PSIA, NANO_DETIDE and NANO_TEMP
; 
  IF N GT 0 THEN  BEGIN  ; IDL_FILE exists.
     RESTORE, IDL_FILE   ; Get the NANO array variables.
  ENDIF  ELSE  BEGIN  ; No IDL_FILE is found.
     PRINT, 'Cannot find the NANO IDL Save File: ' + IDL_FILE
     PRINT, 'UPDATE_NANO_FILE stops.'
     RETURN  ; to caller.
  ENDELSE
;
; Get the directory path from the UPDATE_INFO_FILE, for example,
; UPDATE_INFO_FILE = '/data/lau/LastUpatedMJ03EinfoFile.NANO', then PATH = '/data/lau/'
; It is assumed that the MJ03E2019NANO.Data file, for example, is located
; at the same directory: '/data/lau/'
;
  PATH = FILE_DIRNAME( UPDATE_INFO_FILE, /MARK_DIRECTORY )
;
; Get the last index in the NANO_TIME array.
;
         N  = N_ELEMENTS( NANO_TIME )    ; Total NANO records.
         N -= 1  ; Now N = the last index of the NANO arrays.
; LAST_CURRENT_RCD_TIME = NANO_TIME[N]
;
  IF NANO_TIME[N] LE LAST_PROCESSED_RCD_DATE THEN  BEGIN  ; No new data available yet.
     PRINT,    'The Last Updated Record Time is ' + STRING( FORMAT='(C())', LAST_PROCESSED_RCD_DATE )
     PRINT, '>= the Last Current Record Time is ' + STRING( FORMAT='(C())', NANO_TIME[N] )
     PRINT, 'UPDATE_NANO_FILE stops.'
  ENDIF  ELSE  BEGIN ; LAST_PROCESSED_RCD_DATE < NANO_TIME[N], i.e., there are new data.
     CD, PATH, CURRENT=CURRENT_PATH
     OUTPUT_FILE = LAST_PROCESSED_FILE_NAME + '.BackUp'
     PRINT, SYSTIME() + ' Copying ' + LAST_PROCESSED_FILE_NAME  $
                      + ' to ' + OUTPUT_FILE
     FILE_COPY, /OVERWRITE, LAST_PROCESSED_FILE_NAME, OUTPUT_FILE
     OUTPUT_FILE = 'TemporaryNANO.Data'  ; for storing the new records.
;    The Function: LOCATE_TIME_POSITION is in the file: SplitRSNdata.pro
     S  = LOCATE_TIME_POSITION( NANO_TIME, LAST_PROCESSED_RCD_DATE )
     IF NOT ( NANO_TIME[S] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
        S += 1  ; So that NANO_TIME[S] > LAST_PROCESSED_RCD_DATE.
     ENDIF
;    Get the Year (LAST_YR) from the LAST_PROCESSED_RCD_DATE.
     CALDAT, LAST_PROCESSED_RCD_DATE, M, D, LAST_YR  ;, Hour, Minute, Second
;    Get the Year (LAST_YR) from the Last NANO_TIME record.
     CALDAT, NANO_TIME[N],       M, D, LAST_NANO_YR  ;, Hour, Minute, Second
     IF LAST_YR EQ LAST_NANO_YR THEN  BEGIN  ; Both data sets has the same year.
        D = STRING( FORMAT='(C())', NANO_TIME[S] ) + ' and '  $
          + STRING( FORMAT='(C())', NANO_TIME[N] )
        PRINT, SYSTIME() + ' Retrieving data between ' + D
        PRINT_TXYT_DATA2FILE,   NANO_TIME[S:N], NANO_PSIA[S:N],  $
              NANO_DETIDE[S:N], NANO_TEMP[S:N], OUTPUT_FILE
        PRINT, SYSTIME() + ' Appending the retrieved data into the file: ' $
                         +   LAST_PROCESSED_FILE_NAME
        OPENR, 10, OUTPUT_FILE  ; Contains the Newly retrieved records.
        OPENU, 20, LAST_PROCESSED_FILE_NAME, /APPEND
;       Append the all records in the unit: 10 into unit: 20.
        COPY_LUN, 10, 20, /EOF, /LINES, TRANSFER_COUNT=M
     ENDIF  ELSE  BEGIN  ; Assume LAST_YR < LAST_NANO_YR, Data go across years.
;       Finish updating the year of the LAST_PROCESSED_FILE_NAME.
        PRINT, SYSTIME() + ' Data across to a new year. ', LAST_YR, LAST_NANO_YR
        M  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY( 12,31,LAST_YR, 23,59,59 ) )
        IF ( NANO_TIME[M] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
           M -= 1  ; So that NANO_TIME[M] <= LAST_PROCESSED_RCD_DATE.
        ENDIF
        PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', LAST_YR
        PRINT_TXYT_DATA2FILE,   NANO_TIME[S:M], NANO_PSIA[S:M],  $
              NANO_DETIDE[S:M], NANO_TEMP[S:M], OUTPUT_FILE
        OPENR, 10, OUTPUT_FILE  ; Contains the Newly retrieved records.
        OPENU, 20, LAST_PROCESSED_FILE_NAME, /APPEND
;       Append the all records in the unit: 10 into unit: 20.
        COPY_LUN, 10, 20, /EOF, /LINES, TRANSFER_COUNT=D
        FILE_DELETE, /ALLOW_NONEXISTENT,  LAST_PROCESSED_FILE_NAME + '.BackUp'  ; Not Needed.
;       Get the 1st 5 characters from the LAST_PROCESSED_FILE_NAME which will be
        D = STRMID( LAST_PROCESSED_FILE_NAME, 0, 5 )            ; = 'MJ03D' e.g.
        FOR YR = ( LAST_YR + 1 ), ( LAST_NANO_YR - 1 ) DO  BEGIN
            PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', YR
            S  = M + 1  ; Index of the Beginning of the YR.
            M  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY( 12,31,YR, 23,59,59 ) )
            IF ( NANO_TIME[M] GT LAST_PROCESSED_RCD_DATE ) THEN  BEGIN
               M -= 1  ; So that NANO_TIME[M] <= LAST_PROCESSED_RCD_DATE.
            ENDIF
            OUTPUT_FILE = D + STRING( FORMAT='(I4)', YR ) + 'NANO.Data'  ; = 'MJ03D2018NANO.Data' e.g.
            PRINT_TXYT_DATA2FILE,   NANO_TIME[S:M], NANO_PSIA[S:M],  $
                  NANO_DETIDE[S:M], NANO_TEMP[S:M], OUTPUT_FILE
        ENDFOR  ; Processing the individual whole year.
;       Retrieve the data for the last most current year: LAST_NANO_YR
;       and their range of indexes should be S=M+1 and N.
        S  = M + 1  ; Index of the Beginning of the LAST_NANO_YR.
;       Generate a New OUTPUT_FILE name, e.g. 'MJ03D2019NANO.Data'
        PRINT, SYSTIME() + ' Retrieving  & updating rest of data in year: ', LAST_NANO_YR
        OUTPUT_FILE = D + STRING( FORMAT='(I4)', LAST_NANO_YR ) + 'NANO.Data'
        PRINT_TXYT_DATA2FILE,   NANO_TIME[S:N], NANO_PSIA[S:N],  $
              NANO_DETIDE[S:N], NANO_TEMP[S:N], OUTPUT_FILE
        LAST_PROCESSED_FILE_NAME = OUTPUT_FILE  ; to be updated into the UPDATE_INFO_FILE.
     ENDELSE
     CLOSE, 10, 20  ;
     FILE_DELETE, /ALLOW_NONEXISTENT, 'TemporaryNANO.Data'                  ; Not Needed.
     FILE_DELETE, /ALLOW_NONEXISTENT, LAST_PROCESSED_FILE_NAME + '.BackUp'  ; Not Needed.
;    Update the UPDATE_INFO_FILE.
     CD,     CURRENT_PATH      ; Must be Reset back to the original directory 1st.
     PRINT, SYSTIME() + ' Update the info file: ' + UPDATE_INFO_FILE
     OPENW,  10, UPDATE_INFO_FILE          ; So that UPDATE_INFO_FILE can be open.
     PRINTF, 10, LAST_PROCESSED_FILE_NAME  ; = 'MJ03E219NANO.Data' e.g.
                 LAST_PROCESSED_RCD_DATE = NANO_TIME[N]        ; in JULDAY().
     PRINTF, 10, LAST_PROCESSED_RCD_DATE, FORMAT='(C(),A)',  $ ;
                 '  <-- The last record Date & Time in the file above.'
     CLOSE,  10
     PRINT, SYSTIME() + ' File: ' + UPDATE_INFO_FILE + ' Updated.'
  ENDELSE  ; Updating the new NANO data.
;
;  CD, CURRENT_PATH  ; Reset back to the original directory.
;
RETURN
END  ; UPDATE_NANO_FILE
