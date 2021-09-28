;
; File: ChkRSNdataTimes.pro  will check out the time stamps in the IDL
; save files from the MJ03*-[HEAT/IRIS/LILY/NANO].idl and the outcasted
; files: BOTPTA30*[HEAT/IRIS/LILY/NANO]*.idl
;
; Note that this program require the routines in the file: SplitRSNdata.pro
; in order to work.
;
; Revised on December  9th, 2014
; Created on November  4th, 2014
;

;
; This is the main program.
;
; Callers: Users
;
PRO CHECK_RSN_DATA_TIMES, RSN_FILE,  $ ; Input: IDL Save File name.
                    OUTCASTED_FILE,  $ ; Input: IDL Save File name.
      DELETE=DELETE_OUTCASTED_FILE     ; Input: 1 = Yes & 0 = No (default)
;
; Note that even the caller sets the DELETE_OUTCASTED_FILE = 1 for Yes.
; The program will make sure all the arrays' contents in the OUTCASTED_FILE
; will match with all the arrays' contents in the HEAT_FILE before the
; OUTCASTED_FILE will be deleted.  If the contents do not match, No file
; will be deleted.
;
; Set the default value for the DELETE_OUTCASTED_FILE varaible
; if it is not set.
;
IF NOT KEYWORD_SET( DELETE_OUTCASTED_FILE ) THEN  BEGIN
   DELETE_OUTCASTED_FILE = BYTE( 0 )  ; No.
ENDIF
;
; Note that the RSN_FILE name will be
; MJ03?-HEAT.idl, MJ03?-IRIS.idl, MJ03?-LILY.idl or MJ03?-NANO.idl
; where ? will be = 'D', 'E' OR 'F'.
;
; The OUTCASTED_FILE name can be, for example:
; BOTPTA303HEAT20141104T0000.idl
;
; Look for the 'HEAT', 'IRIS', 'LILY' or 'NANO' Labels.
; from the RSN_FILE name.
;
; Get the file name w/o the directory path.
;
  S    = STRLEN( RSN_FILE )
  NAME = STRMID( RSN_FILE, S-8, 4 )  ; = 'IRIS' for example.
;
; Call the correct routine to check out the time.
;
  CASE NAME OF
      'HEAT' : CHK_HEAT_DATA_TIMES, RSN_FILE, OUTCASTED_FILE,  $
                                DELETE=DELETE_OUTCASTED_FILE
      'IRIS' : CHK_IRIS_DATA_TIMES, RSN_FILE, OUTCASTED_FILE,  $
                                DELETE=DELETE_OUTCASTED_FILE
      'LILY' : CHK_LILY_DATA_TIMES, RSN_FILE, OUTCASTED_FILE,  $
                                DELETE=DELETE_OUTCASTED_FILE
      'NANO' : CHK_NANO_DATA_TIMES, RSN_FILE, OUTCASTED_FILE,  $
                                DELETE=DELETE_OUTCASTED_FILE
       ELSE  : BEGIN
                PRINT, RSN_FILE + ' type is unknown!'
                PRINT, 'Please try again with a correct file.'
               END
  ENDCASE
;
RETURN
END  ; CHECK_RSN_DATA_TIMES
;
; Callers: CHECK_RSN_DATA_TIMES or users.
;
PRO CHK_HEAT_DATA_TIMES, HEAT_FILE,  $ ; Input: IDL Save File name.
                    OUTCASTED_FILE,  $ ; Input: IDL Save File name.
      DELETE=DELETE_OUTCASTED_FILE     ; Input: 1 = Yes & 0 = No (default)
;
; Note that even the caller sets the DELETE_OUTCASTED_FILE = 1 for Yes.
; The program will make sure all the arrays' contents in the OUTCASTED_FILE
; will match with all the arrays' contents in the HEAT_FILE before the
; OUTCASTED_FILE will be deleted.  If the contents do not match, No file
; will be deleted.
;
; Set the default value for the DELETE_OUTCASTED_FILE varaible
; if it is not set.
;
IF NOT KEYWORD_SET( DELETE_OUTCASTED_FILE ) THEN  BEGIN
   DELETE_OUTCASTED_FILE = BYTE( 0 )  ; No.
ENDIF
;
; Retrieve the Saved HEAT data variables:
; HEAT_TIME, HEAT_XTILT, HEAT_YTILT, HEAT_TEMP
;
  RESTORE, HEAT_FILE
;
; Retrieve the Outcasted Heat data variables:
; TIME, XTILT, YTILT, TEMP, N_HEAT_CNT
;
  RESTORE, OUTCASTED_FILE
;
; Search for the time index of TIME[0] in HEAT_TIME.
; Note that the function: LOCATE_TIME_POSITION is located in the
; file: SplitRSNdata.pro
;
  I  = LOCATE_TIME_POSITION( HEAT_TIME, TIME[0] )
  J  = LOCATE_TIME_POSITION( HEAT_TIME, TIME[N_HEAT_CNT-1] )
;
; LOCATE_TIME_POSITION gives the index: I so that the following
; result: HEAT_TIME[I-1] <= TIME[0] < HEAT_TIME[I] will hold;
; therefore, offset -1 is needed to get the correct position.
;
  I -= 1
  J -= 1
;
IF I LT 0 THEN  BEGIN
   I =  0  ; Reset
   PRINT, FORMAT='(A,C(),A)', 'Cannot find Start Time: ', TIME[0]
ENDIF
;
IF J LT 0 THEN  BEGIN
   J =  N_HEAT_CNT - 1  ; Reset
   PRINT, FORMAT='(A,C(),A)', 'Cannot find End   Time: ', TIME[N_HEAT_CNT-1]
ENDIF
;
; Create a 2x2 array for printing out the matching 1st & the last times.
; 
  T  = [ [ HEAT_TIME[I], TIME[0] ], [ HEAT_TIME[J], TIME[N_HEAT_CNT-1] ] ]
  PRINT, FORMAT='(C(),X,C())', T
;
  HELP, NAME='*'  ; Show all the arrays' variables
;
; STOP, [ 'Check out the times.  If they do not match,',  $
;         'adjust the indeses: I &/or J and Type .CON to continue.'  ]
;
; Create a 2x5 array for the 1st 5 timestamps each of the HEAT_TIME & TIME.
;
  T  = TRANSPOSE( [ [ HEAT_TIME[I:I+4] ], [ TIME[0:4] ] ] )
;
  PRINT, 'The 1st 5 Time Stamps from the HEAT & the Outcasted data.'
  PRINT, '       Heat Time           Outcasted Heat Time'
  PRINT, FORMAT='(C(),X,C())', T
;
; Create a 2x5 array for the 1st 5 timestamps each of the HEAT_TIME & TIME.
;
; N  = N_ELEMENTS( HEAT_TIME )
  T  = TRANSPOSE( [ [HEAT_TIME[J-4:J]],[TIME[N_HEAT_CNT-5:N_HEAT_CNT-1]] ] )
;
  PRINT, 'The last  5 Time Stamps from the HEAT & the Outcasted data.'
  PRINT, '       Heat Time           Outcasted Heat Time'
  PRINT, FORMAT='(C(),X,C())', T
  IF ARRAY_EQUAL( HEAT_TIME[I:J], TIME[0:N_HEAT_CNT-1] ) THEN  BEGIN
     PRINT, 'All Times are the Same.'
  ENDIF  ELSE  BEGIN
     PRINT, 'The Times are Not all the same.'
  ENDELSE
;
  IF DELETE_OUTCASTED_FILE THEN  BEGIN
     T = 'Y'
  ENDIF  ELSE  BEGIN
     T  = 'N'  ; Indicate No to delete the OUTCASTED_FILE.  
     READ, 'Delete the File: ' + OUTCASTED_FILE + ' (Y/S/N)? ', T
     T  = STRUPCASE( T )
  ENDELSE
;
  IF T EQ 'S' THEN  BEGIN
     STOP, 'Check out the data? or Type .CON to continue.'
  ENDIF ELSE IF T EQ 'Y' THEN  BEGIN
;    Check All the contents between [I:J] of All the HEAT_* array variables
;    with the contents in the Outcasted arrays.
     T    = BYTARR( 4 )
     T[0] = ARRAY_EQUAL( HEAT_TIME [I:J],  TIME[0:N_HEAT_CNT-1] )
     T[1] = ARRAY_EQUAL( HEAT_TEMP [I:J],  TEMP[0:N_HEAT_CNT-1] )
     T[2] = ARRAY_EQUAL( HEAT_XTILT[I:J], XTILT[0:N_HEAT_CNT-1] )
     T[3] = ARRAY_EQUAL( HEAT_YTILT[I:J], YTILT[0:N_HEAT_CNT-1] )
;    Make sure all contents are the same before deleting the OUTCASTED_FILE.
     IF ARRAY_EQUAL( T, 1B ) THEN  BEGIN
        FILE_DELETE, /VERBOSE, OUTCASTED_FILE
     ENDIF  ELSE  BEGIN
        PRINT, 'Not All contents are the same!'
        PRINT, 'File: ' + OUTCASTED_FILE + ' is Not Deleted.'
     ENDELSE
  ENDIF
;
RETURN
END  ; CHK_HEAT_DATA_TIMES
;
; Callers: CHECK_RSN_DATA_TIMES or users.
;
PRO CHK_IRIS_DATA_TIMES, IRIS_FILE,  $ ; Input: IDL Save File name.
                    OUTCASTED_FILE,  $ ; Input: IDL Save File name.
      DELETE=DELETE_OUTCASTED_FILE     ; Input: 1 = Yes & 0 = No (default)
;
; Note that even the caller sets the DELETE_OUTCASTED_FILE = 1 for Yes.
; The program will make sure all the arrays' contents in the OUTCASTED_FILE
; will match with all the arrays' contents in the HEAT_FILE before the
; OUTCASTED_FILE will be deleted.  If the contents do not match, No file
; will be deleted.
;
; Set the default value for the DELETE_OUTCASTED_FILE varaible
; if it is not set.
;
IF NOT KEYWORD_SET( DELETE_OUTCASTED_FILE ) THEN  BEGIN
   DELETE_OUTCASTED_FILE = BYTE( 0 )  ; No.
ENDIF
;
; Retrieve the Saved IRIS data variables:
; IRIS_TIME, IRIS_XTILT, IRIS_YTILT, IRIS_TEMP
;
  RESTORE, IRIS_FILE
;
; Retrieve the Outcasted Heat data variables:
; TIME, XTILT, YTILT, TEMP, N_IRIS_CNT
;
  RESTORE, OUTCASTED_FILE
;
; Search for the time index of TIME[0] in IRIS_TIME.
; Note that the function: LOCATE_TIME_POSITION is located in the
; file: SplitRSNdata.pro
;
  I  = LOCATE_TIME_POSITION( IRIS_TIME, TIME[0] )
  J  = LOCATE_TIME_POSITION( IRIS_TIME, TIME[N_IRIS_CNT-1] )
;
; LOCATE_TIME_POSITION gives the index: I so that the following
; result: HEAT_TIME[I-1] <= TIME[0] < HEAT_TIME[I] will hold;
; therefore, offset -1 is needed to get the correct position.
;
  I -= 1
  J -= 1
;
IF I LT 0 THEN  BEGIN
   I =  0  ; Reset
   PRINT, FORMAT='(A,C(),A)', 'Cannot find Start Time: ', TIME[0]
ENDIF
;
IF J LT 0 THEN  BEGIN
   J =  N_IRIS_CNT - 1  ; Reset
   PRINT, FORMAT='(A,C(),A)', 'Cannot find End   Time: ', TIME[N_IRIS_CNT-1]
ENDIF
;
; Create a 2x2 array for printing out the matching 1st & the last times.
; 
  T  = [ [ IRIS_TIME[I], TIME[0] ], [ IRIS_TIME[J], TIME[N_IRIS_CNT-1] ] ]
  PRINT, FORMAT='(C(),X,C())', T
;
  HELP, NAME='*'  ; Show all the arrays' variables
;
; STOP, [ 'Check out the times.  If they do not match,',  $
;         'adjust the indeses: I &/or J and Type .CON to continue.'  ]
;
; Create a 2x5 array for the 1st 5 timestamps each of the IRIS_TIME & TIME.
;
; T  = TRANSPOSE( [ [ IRIS_TIME[0:  4] ], [ TIME[0:4] ] ] )
  T  = TRANSPOSE( [ [ IRIS_TIME[I:I+4] ], [ TIME[0:4] ] ] )
;
  PRINT, 'The 1st 5 Time Stamps from the IRIS & the Outcasted data.'
  PRINT, '       IRIS Time           Outcasted IRIS Time'
  PRINT, FORMAT='(C(),X,C())', T
;
; Create a 2x5 array for the 1st 5 timestamps each of the IRIS_TIME & TIME.
;
; N  = N_ELEMENTS(   IRIS_TIME )
; T  = TRANSPOSE( [ [IRIS_TIME[N-5:N-1]],[TIME[N_IRIS_CNT-5:N_IRIS_CNT-1]] ] )
  T  = TRANSPOSE( [ [IRIS_TIME[J-4:J  ]],[TIME[N_IRIS_CNT-5:N_IRIS_CNT-1]] ] )
;
  PRINT, 'The last  5 Time Stamps from the IRIS & the Outcasted data.'
  PRINT, '       IRIS Time           Outcasted IRIS Time'
  PRINT, FORMAT='(C(),X,C())', T
  IF ARRAY_EQUAL( IRIS_TIME[I:J], TIME[0:N_IRIS_CNT-1] ) THEN  BEGIN
     PRINT, 'All Times are the Same.'
  ENDIF  ELSE  BEGIN
     PRINT, 'The Times are Not all the same.'
  ENDELSE
;
  IF DELETE_OUTCASTED_FILE THEN  BEGIN
     T = 'Y'
  ENDIF  ELSE  BEGIN
     T  = 'N'  ; Indicate No to delete the OUTCASTED_FILE.  
     READ, 'Delete the File: ' + OUTCASTED_FILE + ' (Y/S/N)? ', T
     T  = STRUPCASE( T )
  ENDELSE
;
  IF T EQ 'S' THEN  BEGIN
     STOP, 'Check out the data? or Type .CON to continue.'
  ENDIF ELSE IF T EQ 'Y' THEN  BEGIN
;    Check All the contents between [I:J] of All the IRIS_* array variables
;    with the contents in the Outcasted arrays.
     T    = BYTARR( 4 )
     T[0] = ARRAY_EQUAL( IRIS_TIME [I:J],  TIME[0:N_IRIS_CNT-1] )
     T[1] = ARRAY_EQUAL( IRIS_TEMP [I:J],  TEMP[0:N_IRIS_CNT-1] )
     T[2] = ARRAY_EQUAL( IRIS_XTILT[I:J], XTILT[0:N_IRIS_CNT-1] )
     T[3] = ARRAY_EQUAL( IRIS_YTILT[I:J], YTILT[0:N_IRIS_CNT-1] )
;    Makee sure all contents are the same before deleting the OUTCASTED_FILE.
     IF ARRAY_EQUAL( T, 1B ) THEN  BEGIN
        FILE_DELETE, /VERBOSE, OUTCASTED_FILE
     ENDIF  ELSE  BEGIN
        PRINT, 'Not All contents are the same!'
        PRINT, 'File: ' + OUTCASTED_FILE + ' is Not Deleted.'
     ENDELSE
  ENDIF
;
RETURN
END  ; CHK_IRIS_DATA_TIMES
;
; Callers: CHECK_RSN_DATA_TIMES or users.
;
PRO CHK_LILY_DATA_TIMES, LILY_FILE,  $ ; Input: IDL Save File name.
                    OUTCASTED_FILE,  $ ; Input: IDL Save File name.
      DELETE=DELETE_OUTCASTED_FILE     ; Input: 1 = Yes & 0 = No (default)
;
; Note that even the caller sets the DELETE_OUTCASTED_FILE = 1 for Yes.
; The program will make sure all the arrays' contents in the OUTCASTED_FILE
; will match with all the arrays' contents in the HEAT_FILE before the
; OUTCASTED_FILE will be deleted.  If the contents do not match, No file
; will be deleted.
;
; Set the default value for the DELETE_OUTCASTED_FILE varaible
; if it is not set.
;
IF NOT KEYWORD_SET( DELETE_OUTCASTED_FILE ) THEN  BEGIN
   DELETE_OUTCASTED_FILE = BYTE( 0 )  ; No.
ENDIF
;
; Retrieve the Saved LILY data variables:
; LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_TEMP, LILY_RTM, LILY_RTD
;
  RESTORE, LILY_FILE
;
; Retrieve the Outcasted Heat data variables:
; TIME, XTILT, YTILT, RTM, TEMP, RTD, N_LILY_CNT
;
  RESTORE, OUTCASTED_FILE
;
; Search for the time index of TIME[0] in LILY_TIME.
; Note that the function: LOCATE_TIME_POSITION is located in the
; file: SplitRSNdata.pro
;
  I  = LOCATE_TIME_POSITION( LILY_TIME, TIME[0] )
  J  = LOCATE_TIME_POSITION( LILY_TIME, TIME[N_LILY_CNT-1] )
;
; LOCATE_TIME_POSITION gives the index: I so that the following
; result: HEAT_TIME[I-1] <= TIME[0] < HEAT_TIME[I] will hold;
; therefore, offset -1 is needed to get the correct position.
;
  I -= 1
  J -= 1
;
IF I LT 0 THEN  BEGIN
   I =  0  ; Reset
   PRINT, FORMAT='(A,C(),A)', 'Cannot find Start Time: ', TIME[0]
ENDIF
;
IF J LT 0 THEN  BEGIN
   J =  N_LILY_CNT - 1  ; Reset
   PRINT, FORMAT='(A,C(),A)', 'Cannot find End   Time: ', TIME[N_LILY_CNT-1]
ENDIF
;
; Create a 2x2 array for printing out the matching 1st & the last times.
; 
  T  = [ [ LILY_TIME[I], TIME[0] ], [ LILY_TIME[J], TIME[N_LILY_CNT-1] ] ]
  PRINT, FORMAT='(C(),X,C())', T
;
  HELP, NAME='*'  ; Show all the arrays' variables
;
; STOP, [ 'Check out the times.  If they do not match,',  $
;         'adjust the indeses: I &/or J and Type .CON to continue.'  ]
;
; Create a 2x5 array for the 1st 5 timestamps each of the LILY_TIME & TIME.
;
; T  = TRANSPOSE( [ [ LILY_TIME[0:  4] ], [ TIME[0:4] ] ] )
  T  = TRANSPOSE( [ [ LILY_TIME[I:I+4] ], [ TIME[0:4] ] ] )
;
  PRINT, 'The 1st 5 Time Stamps from the LILY & the Outcasted data.'
  PRINT, '       LILY Time           Outcasted LILY Time'
  PRINT, FORMAT='(C(),X,C())', T
;
; Create a 2x5 array for the 1st 5 timestamps each of the LILY_TIME & TIME.
;
; N  = N_ELEMENTS(   LILY_TIME )
; T  = TRANSPOSE( [ [LILY_TIME[N-5:N-1]],[TIME[N_LILY_CNT-5:N_LILY_CNT-1]] ] )
  T  = TRANSPOSE( [ [LILY_TIME[J-4:J  ]],[TIME[N_LILY_CNT-5:N_LILY_CNT-1]] ] )
;
  PRINT, 'The last  5 Time Stamps from the LILY & the Outcasted data.'
  PRINT, '       LILY Time           Outcasted LILY Time'
  PRINT, FORMAT='(C(),X,C())', T
  IF ARRAY_EQUAL( LILY_TIME[I:J], TIME[0:N_LILY_CNT-1] ) THEN  BEGIN
     PRINT, 'All Times are the Same.'
  ENDIF  ELSE  BEGIN
     PRINT, 'The Times are Not all the same.'
  ENDELSE
;
  IF DELETE_OUTCASTED_FILE THEN  BEGIN
     T = 'Y'
  ENDIF  ELSE  BEGIN
     T  = 'N'  ; Indicate No to delete the OUTCASTED_FILE.  
     READ, 'Delete the File: ' + OUTCASTED_FILE + ' (Y/S/N)? ', T
     T  = STRUPCASE( T )
  ENDELSE
;
  IF T EQ 'S' THEN  BEGIN
     STOP, 'Check out the data? or Type .CON to continue.'
  ENDIF ELSE IF T EQ 'Y' THEN  BEGIN
;    Check All the contents between [I:J] of All the LILY_* array variables
;    with the contents in the Outcasted arrays.
     T    = BYTARR( 6 )
     T[0] = ARRAY_EQUAL( LILY_TIME [I:J],  TIME[0:N_LILY_CNT-1] )
     T[1] = ARRAY_EQUAL( LILY_TEMP [I:J],  TEMP[0:N_LILY_CNT-1] )
     T[2] = ARRAY_EQUAL( LILY_XTILT[I:J], XTILT[0:N_LILY_CNT-1] )
     T[3] = ARRAY_EQUAL( LILY_YTILT[I:J], YTILT[0:N_LILY_CNT-1] )
     T[4] = ARRAY_EQUAL( LILY_RTD  [I:J],   RTD[0:N_LILY_CNT-1] )
     T[5] = ARRAY_EQUAL( LILY_RTM  [I:J],   RTM[0:N_LILY_CNT-1] )
;    Make sure all contents are the same before deleting the OUTCASTED_FILE.
     IF ARRAY_EQUAL( T, 1B ) THEN  BEGIN
        FILE_DELETE, /VERBOSE, OUTCASTED_FILE
     ENDIF  ELSE  BEGIN
        PRINT, 'Not All contents are the same!'
        PRINT, 'File: ' + OUTCASTED_FILE + ' is Not Deleted.'
     ENDELSE
  ENDIF
;
RETURN
END  ; CHK_LILY_DATA_TIMES
;
; Callers: CHECK_RSN_DATA_TIMES or users.
;
PRO CHK_NANO_DATA_TIMES, NANO_FILE,  $ ; Input: IDL Save File name.
                    OUTCASTED_FILE,  $ ; Input: IDL Save File name.
      DELETE=DELETE_OUTCASTED_FILE     ; Input: 1 = Yes & 0 = No (default)
;
; Note that even the caller sets the DELETE_OUTCASTED_FILE = 1 for Yes.
; The program will make sure all the arrays' contents in the OUTCASTED_FILE
; will match with all the arrays' contents in the HEAT_FILE before the
; OUTCASTED_FILE will be deleted.  If the contents do not match, No file
; will be deleted.
;
; Set the default value for the DELETE_OUTCASTED_FILE varaible
; if it is not set.
;
IF NOT KEYWORD_SET( DELETE_OUTCASTED_FILE ) THEN  BEGIN
   DELETE_OUTCASTED_FILE = BYTE( 0 )  ; No.
ENDIF
;
; Retrieve the Saved NANO data variables:
; NANO_TIME, NANO_PSIA, NANO_DETIDE and NANO_TEMP
;
  RESTORE, NANO_FILE
;
; Retrieve the Outcasted Heat data variables:
; TIME, PSIA, METER, TEMP, N_NANO_CNT
;
  RESTORE, OUTCASTED_FILE
;
; Search for the time index of TIME[0] in NANO_TIME.
; Note that the function: LOCATE_TIME_POSITION is located in the
; file: SplitRSNdata.pro
;
  I  = LOCATE_TIME_POSITION( NANO_TIME, TIME[0] )
  J  = LOCATE_TIME_POSITION( NANO_TIME, TIME[N_NANO_CNT-1] )
;
; LOCATE_TIME_POSITION gives the index: I so that the following
; result: HEAT_TIME[I-1] <= TIME[0] < HEAT_TIME[I] will hold;
; therefore, offset -1 is needed to get the correct position.
;
  I -= 1
  J -= 1
;
IF I LT 0 THEN  BEGIN
   I =  0  ; Reset
   PRINT, FORMAT='(A,C(),A)', 'Cannot find Start Time: ', TIME[0]
ENDIF
;
IF J LT 0 THEN  BEGIN
   J =  N_NANO_CNT - 1  ; Reset
   PRINT, FORMAT='(A,C(),A)', 'Cannot find End   Time: ', TIME[N_NANO_CNT-1]
ENDIF
;
; Create a 2x2 array for printing out the matching 1st & the last times.
; 
  T  = [ [ NANO_TIME[I], TIME[0] ], [ NANO_TIME[J], TIME[N_NANO_CNT-1] ] ]
  PRINT, FORMAT='(C(),X,C())', T
;
  HELP, NAME='*'  ; Show all the arrays' variables
;
; STOP, [ 'Check out the times.  If they do not match,',  $
;         'adjust the indeses: I &/or J and Type .CON to continue.'  ]
;
; Create a 2x5 array for the 1st 5 timestamps each of the NANO_TIME & TIME.
;
; T  = TRANSPOSE( [ [ NANO_TIME[0:  4] ], [ TIME[0:4] ] ] )
  T  = TRANSPOSE( [ [ NANO_TIME[I:I+4] ], [ TIME[0:4] ] ] )
;
  PRINT, 'The 1st 5 Time Stamps from the NANO & the Outcasted data.'
  PRINT, '       NANO Time           Outcasted NANO Time'
  PRINT, FORMAT='(C(),X,C())', T
;
; Create a 2x5 array for the 1st 5 timestamps each of the NANO_TIME & TIME.
;
; N  = N_ELEMENTS(   NANO_TIME )
; T  = TRANSPOSE( [ [NANO_TIME[N-5:N-1]],[TIME[N_NANO_CNT-5:N_NANO_CNT-1]] ] )
  T  = TRANSPOSE( [ [NANO_TIME[J-4:J  ]],[TIME[N_NANO_CNT-5:N_NANO_CNT-1]] ] )
;
  PRINT, 'The last  5 Time Stamps from the NANO & the Outcasted data.'
  PRINT, '       NANO Time           Outcasted NANO Time'
  PRINT, FORMAT='(C(),X,C())', T
  IF ARRAY_EQUAL( NANO_TIME[I:J], TIME[0:N_NANO_CNT-1] ) THEN  BEGIN
     PRINT, 'All Times are the Same.'
  ENDIF  ELSE  BEGIN
     PRINT, 'The Times are Not all the same.'
  ENDELSE
;
  IF DELETE_OUTCASTED_FILE THEN  BEGIN
     T = 'Y'
  ENDIF  ELSE  BEGIN
     T  = 'N'  ; Indicate No to delete the OUTCASTED_FILE.  
     READ, 'Delete the File: ' + OUTCASTED_FILE + ' (Y/S/N)? ', T
     T  = STRUPCASE( T )
  ENDELSE
;
  IF T EQ 'S' THEN  BEGIN
     STOP, 'Check out the data? or Type .CON to continue.'
  ENDIF ELSE IF T EQ 'Y' THEN  BEGIN
;    Check All the contents between [I:J] of All the NANO_* array variables
;    with the contents in the Outcasted arrays.
; NANO_TIME, NANO_PSIA, NANO_DETIDE and NANO_TEMP
; TIME, PSIA, METER, TEMP, N_NANO_CNT
     T    = BYTARR( 4 )
     T[0] = ARRAY_EQUAL( NANO_TIME  [I:J],   TIME[0:N_NANO_CNT-1] )
     T[1] = ARRAY_EQUAL( NANO_TEMP  [I:J],   TEMP[0:N_NANO_CNT-1] )
     T[2] = ARRAY_EQUAL( NANO_PSIA  [I:J],   PSIA[0:N_NANO_CNT-1] )
     T[3] = ARRAY_EQUAL( NANO_DETIDE[I:J],  METER[0:N_NANO_CNT-1] )
;    Make sure all contents are the same before deleting the OUTCASTED_FILE.
     IF ARRAY_EQUAL( T, 1B ) THEN  BEGIN
        FILE_DELETE, /VERBOSE, OUTCASTED_FILE
     ENDIF  ELSE  BEGIN
        PRINT, 'Not All contents are the same!'
        PRINT, 'File: ' + OUTCASTED_FILE + ' is Not Deleted.'
     ENDELSE
  ENDIF
;
RETURN
END  ; CHK_NANO_DATA_TIMES
