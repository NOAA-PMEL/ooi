;
; File: GetRelevelingTimes.pro
;
; This IDL program contains routines for getting the Releveling Periods
; from a file: MJ03E-LILYreleveling.Times  for example.
; which contains the start and end times of the Releveling Periods for
; the RSN Tilt sensors from LILY, IRIR or HEAT.
;
; The "MJ03[D/E/F]-[LILY/IRIS/HEAT]releveling.Times" file will be created
; by the following UNIX command example:
; grep "XY-LEVEL" BOTPTA302*.dat > MJ03F-IRISreleveling.Times
;
; Revised on June  16th, 2015
; Created on June  16th, 2015
;

;
; Callers: Users.
;
PRO GET_RELEVELING_TIMES, RLT_FILE,  $ ; Input: The *.Times file's name.
                          RLT        ;  Output: 2-D array of Times in JULDAY().
;
; RLT_FILE = 'MJ03D-LILYreleveling.Times'  for example.
; It contains the records like the following:
; BOTPTA302_10.31.10.6_9338_20140908T0000_UTC.dat:LILY,2014/09/08 21:56:14,*9900XY-LEVEL,1
; BOTPTA302_10.31.10.6_9338_20140908T0000_UTC.dat:LILY,2014/09/08 22:14:39,*9900XY-LEVEL,0
;   :
; BOTPTA302_10.31.10.6_9338_20150424T0000_UTC.dat:LILY,2015/04/24 16:52:30,*9900XY-LEVEL,1
; BOTPTA302_10.31.10.6_9338_20150424T0000_UTC.dat:LILY,2015/04/24 16:54:07,*990XY-LEVEL,0
; where the XY-LEVEL,1 indicates the Starting of the Releveling of the Tilt sensor
; and   the XY-LEVEL,0 indicates the Ending   of the Releveling of the Tilt sensor.
;
; So it is assumed the RLT_FILE contains Even number of records and it is up to the caller
; to make sure the RLT_FILE contains the records and their order, i.e. starts with LEVEL,1
; and ends with LEVEL,0.
;
  OPENR, INPUT_UNIT, RLT_FILE, /GET_LUN
;
  N_RCDS = FILE_LINES( RLT_FILE )  ; Get total number of records in the RLT_FILE.
  RLT    = DBLARR( 2, N_RCDS/2 )   ; Define a 2-D array for storing the Releveing Times.
  RCD    = 'For storing an input record.'
  JDAY   = 0.0D0  ; Must be defined as DOUBLE in order to get the JULDAY() value correctly.
;
  FOR S = LONG( 0 ), N_RCDS - 1 DO  BEGIN
      READF, INPUT_UNIT, RCD
      I = STRPOS( RCD, ':' )  ; Locate the position before the sensor name: ':LILY' e.g.
      READS, STRMID( RCD, I+6, 19 ),  $  ; Read the string '2014/09/08 21:56:14', e.g.
             FORMAT='(C(CYI4,X,CMOI2,X,CDI2,X,CHI,X,CMI,X,CSI2))', JDAY
      RLT[S] = JDAY  ; Store the Time as JULDAY() value.  Note that when (*)
; (*) S = Even numbers 0, 2, 4, ...etc that is same as RLT[0,1], RLT[0,2], RLT[0,3], etc.
;     S = Odd  numbers 1, 3, 5, ...etc that is same as RLT[1,1], RLT[1,2], RLT[1,3], etc.
  ENDFOR  ; S
;
  CLOSE,    INPUT_UNIT
  FREE_LUN, INPUT_UNIT
;
  PRINT, 'Retireved Releveling Periods from: ', RLT_FILE
  PRINT, FORMAT="( C(), ' <--> ', C() )", RLT  ; Show the Times for checking. 
  PRINT, STRTRIM( N_RCDS/2, 2 ) + ' of them.'
; STOP
;
RETURN
END  ; GET_RELEVELING_TIMES
