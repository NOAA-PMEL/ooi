;
; File: GetShortTermNANOdataProducts.pro
;
; This  IDL program will use the data in either
; the file:  EventDetectionParameters.MJ03[D/E/F]  or
; the IDL Save File: EventDetectionParametersMJ03[D/E/F].idl
; to get the Depth differences between 2 data points in 5 minute apart
; and the Average Depth differences between 2 consective 10-minute averaged
; depths.
;
; Note that this program require the routines in the file: SplitRSNdata.pro
; in order to work.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on August    24th, 2017
; Created on December   9th, 2014
;

;
; Callers: Users
;
PRO DEFINE_NANO1DAYM_ARRAYS, N  ; Input: Integer for the array size.
;
  COMMON NANO1DAYM, NANO1DAY_MEAN, NANO1DAY_TIME  ; For computed 1-Day means.
;
; Clear the variables beforo define them.
;
  NANO1DAY_MEAN = 0
  NANO1DAY_TIME = 0
;
  NANO1DAY_MEAN = DBLARR( N )  ; for storing 1-Day means.
  NANO1DAY_TIME = DBLARR( N )  ; for storing JULDAY() values.
;
RETURN
END  ;
;
; Note that this procedure will retrieve the Event Detected Paramaters
; from a Text File: MJ03E/EventDetectionParameters.MJ03E for example.
; The parameters (Short Term Data Products) are
; the Rates of Depths Changes in 5 minutes and the differencs
; between two 10-minute averaged depth differencs.
;
; This procedure has been used between November 2014 and January 23rd, 2015
;
; Callers: PLOT_SHORT_TERM_DATA and Users.
; Revised: August 24th, 2017
;
PRO GET_DETECTED_RATES,  DETECTED_RATE_FILE,  $ ; Input: Name.
    DATA,    $  ; Output: 2-D array (see DATA[*,i] comments below). 
    STATUS      ; Output: 0 = No Data are read or 1 = Data are OK. 
;
;   DATA[*,0] = JULDAY() values.
;   DATA[*,1] = 5-minute Depth Differences.
;   DATA[*,2] = Depth Differences of two 10-minute averaged Depths.
;
; Locate the LONGTERM_DATA_FILE and make sure it exists.
;
   S = FILE_SEARCH( DETECTED_RATE_FILE, COUNT=N )
;
IF N GT 0 THEN  BEGIN  ; DETECTED_RATE_FILE is located.
   STATUS = BYTE( 1 )  ; Assume DATA can be read.
ENDIF  ELSE  BEGIN     ; N <= 0
   PRINT, 'File: ' + DETECTED_RATE_FILE + ' does not exist!'
   PRINT, 'Please Check and tye again'
   STATUS = BYTE( 0 )  ; No Data are read.
   RETURN ; to Caller.
ENDELSE
;
; Use the UNIX "wc" command to find out total input lines in the
; DATA_PRODUCTS_FILE.
;
 ;SPAWN, 'wc -l ' + DETECTED_RATE_FILE, RCD  ; where
; RCD = '13 ~/4Chadwick/RSN/MJ03E/EventDetectionParameters.MJ03E' e.g.
 ;            N = 0  ; to start
 ;READS, RCD, N      ; Read off the total line number.
;
; The 4 lines above have been replaced by the IDL'sFILE_LINES() function below.
;
  N = FILE_LINES( RCD )  ; August 24th, 2017
;
; Open the data file for Event Detected Parameters.
;
  OPENR,    FILE_UNIT, /GET_LUN, DETECTED_RATE_FILE
;
                       RCD = STRARR( N )
  READF,    FILE_UNIT, RCD  ; Read in All the records.
;
  CLOSE,    FILE_UNIT  ; Close the data file.
  FREE_LUN, FILE_UNIT
;
; Each record in RCD will be for example,
; RCD[i] = '2014/12/05 05:05:30    0.25897114   -0.99892086'
;
; Convert the RCD into the variable type: LIST by the STRSPLIT() function.
;
  S   = STRSPLIT( RCD, /EXTRACT )     ; where S will be the type: LIST.
  RCD = S.ToArray( )  ; Convert the the LIST type into an String array.
; RCD = S.ToArray(/TRANSPOSE) ; Convert the the LIST type into an String array.
;
IF KEYWORD_SET( OUTPUT_AS_STRING ) THEN  BEGIN
   DATA = TEMPORARY( RCD )  ; 2-D (Nx4) string array.
ENDIF  ELSE  BEGIN  ; Convert the 2-D string array into Double.
          S  =   SIZE( RCD, /DIMENSION )
   DATE      = INTARR(   6 , N      ) ; Note that S[0] = N )
   DATA      = DBLARR( S[0], S[1]-1 ) ; S[0:1] = [ N, 4 ]
   DATA[*,1] = DOUBLE( RCD[*,2] )
   DATA[*,2] = DOUBLE( RCD[*,3] )
          S = RCD[*,0] + ' ' + RCD[*,1]
   READS, S, FORMAT='(I4,1X,I2,1X,I2,1X,I2,1X,I2,1X,I2)', DATE
   DATE      = TRANSPOSE( TEMPORARY( DATE ) )
   DATA[*,0] = JULDAY( DATE[*,1], DATE[*,2], DATE[*,0],  $
                       DATE[*,3], DATE[*,4], DATE[*,5]   )  ;
ENDELSE      ; where   Day        Month      Year for DATE[*,[1,2,0]].
;
RETURN
END  ; Get_DETECTED_RATES
;
; Callers: Users
; Revised: January 23rd, 2015
;
PRO SAVE_DETECTED_RATES2FILE,  DATA,  $ ; Input: 2-D array, Size: n x 3.
         DETECTED_RATE_FILE  ; Input: Outpu File name.
;
; Note that DATA is the array retrieved from the IDL Save File:
; ~/4Chadwick/RSN/MJ03E/EventDetectionParametersMJ03E.idl for example.
; and
; DETECTED_RATE_FILE = '~/4Chadwick/RSN/MJ03E/EventDetectionParameters.MJ03E'
; for example.
;
; DATA[*,0] = JULDAY() values.
; DATA[*,1] = 5-minute Depth Differences.
; DATA[*,2] = Depth Differences of two 10-minute averaged Depths.
;
; S = SIZE( DATA, /DIMENSION )  ; Get the DATA size.
; N = S[0]  ; Size of the 1st dimension and S[1] = 3 for the 2nd dimension.
;
; Convert the Time indexes into String of 'Year/Mt/Dy Hr:Mn:Sd'.
;
  T = STRING( DATA[*,0], $  ; T will be a 1-D of string array.
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
;
; Convert the Depth Differences and two 10-minute averaged Depths into
; 2 1-D arrays of the string.
;
  D = STRTRIM( DATA[*,1], 2 )
  R = STRTRIM( DATA[*,2], 2 )
;
; Locate the Longest string in the arrays of D * R.
;
  M = STRTRIM( MAX( STRLEN( [ D, R ] ) ), 2 )
;
  OPENW, /GET_LUN, OUTPUT_UNIT, DETECTED_RATE_FILE
;
; Print out All the records.  (The following is a faster method)
;
  PRINTF, OUTPUT_UNIT, TRANSPOSE( [ [T], [D], [R] ] ),  $
                FORMAT="(A19,1X,A" + M + ",1X,A" + M + ")"
;
; Print out each record.  (The following is a slower way to print)
;
; FOR S=0, N-1 DO  BEGIN
;   RCD  = STRING( DATA[S,0],  $
;   FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
;   RCD += ' ' +  STRTRIM(  DATA[S,1], 2 ) + ' ' + STRTRIM(  DATA[S,2], 2 )
;   PRINTF, OUTPUT_UNIT, RCD
; END ; S
;
  CLOSE,    OUTPUT_UNIT       ; Close the file.
  FREE_LUN, OUTPUT_UNIT
  PRINT, 'File: ' + DETECTED_RATE_FILE + ' is created.'
;
RETURN
END  ; SAVE_DETECTED_RATES2FILE
;
; This procedure will retrieve the Event Detected Paramaters
; from an IDL Save File: MJ03E/EventDetectionParametersMJ03E.idl for example.
; The parameters (Short Term Data Products) are
; the Rates of Depths Changes in 5 minutes and the differencs
; between two 10-minute averaged depth differencs.
;
; This procedure has started being used on Januart 23rd, 2015
;
; Callers: PLOT_SHORT_TERM_DATA and Users.
; Revised: January   23rd, 2015
;
PRO RETRIEVE_DETECTED_RATES,  DETECTED_RATE_FILE,  $ ; Input: IDL Save File.
    DATA,  $ ; Output: 2-D array (see DATA[*,i] comments below). 
    STATUS   ; Output: 0 = No Data are read or 1 = Data are OK. 
;
;   DATA[*,0] = JULDAY() values.
;   DATA[*,1] = 5-minute Depth Differences.
;   DATA[*,2] = Depth Differences of two 10-minute averaged Depths.
;
; Locate the DETECTED_RATE_FILE and make sure it exists.
;
   STATUS = FILE_SEARCH( DETECTED_RATE_FILE, COUNT=N )
;
IF N LE 0 THEN  BEGIN  ; DETECTED_RATE_FILE is Not located.
   PRINT, 'File: ' + DETECTED_RATE_FILE + ' does not exist!'
   PRINT, 'Please Check and try again'
   STATUS = BYTE( 0 )  ; No Data are read.
ENDIF  ELSE  BEGIN     ; N > 0  ==> DETECTED_RATE_FILE is located.
   STATUS = BYTE( 1 )  ; Assume DATA can be read.
   RESTORE, FILE=DETECTED_RATE_FILE   ; to get the DATA.
;  Assign the retrieved arrays into the Output variables for returning.
;  DATA[*,0] = TEMPORARY( TIME )  ; JULDAY() values.
;  DATA[*,1] = TEMPORARY( R05M )  ; 5-minute Depth Differences.
;  DATA[*,2] = TEMPORARY( R10M )  ; Depth Differences of two 10-minute averaged Depths.
ENDELSE
;
RETURN
END  ; RETRIEVE_DETECTED_RATES
