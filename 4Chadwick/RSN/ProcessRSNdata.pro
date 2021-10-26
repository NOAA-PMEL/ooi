;
; File: ProcessRSNdata.pro
;
; This IDL program will process the provided RSN data files.
; The RSN data are collected by the OOI Regional Scale Nodes program
; statred on August 2014 from the Axial Summit.
;
; The provided RSN data file contains records from 4 different sensors:
; LILY, HEAT, IRIS and NANO.
; All records contain Time Stamps in Year/MM/DD Hr:Mm:Sd
; The NANO   records contain pressure and temperature values.
; The others records contain at least X-Tilt, Y-Tilt and temperatue.
; The LILY   records contain extra values: Compass & Voltage.
;
; Note that the main procedure: PROCESS_RSN_FILES will be calling
; the procedure: PROCESS_RSN_DATA (the main logic of the processing),
; the PLOT_*_DATA routines (stored in the file: PlotRSNdata.pro)
; and the WRITE_LAST_PROCESSED_FILE_NAME procedure (in the file:
; StatusFile4RSN.pro).
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on June       7th, 2021
; Created on September 16th, 2014
;

;
; Callers: GET_[HEAT/IRIS/LILY/NANO]_DATA or Any
; Revised: March    29th, 2021
;
FUNCTION GET_JULDAY, DATE_TIME  ; = '2014/08/29 23:17:57' for example.
;
; Declare an error label.
; When encounter a problem reading the DATE_TIME, then Goto BAD.
;
  ON_IOERROR, BAD  ; Declare error label.
;
  MT  = 12      ; 1-12
  DY  = 31      ; 1-31
  YR  = 2010
  HR  = 00      ; 00-23
  MN  = 00      ; 00-59
  SD  = 59.000  ; 00-59
;
  READS, DATE_TIME, FORMAT='(I4,2(1X,I2),2(1X,I2),1X,F6.3)',  $
                             YR, MT, DY,  HR, MN,    SD
  GOTO,  DONE  ; For returning to the caller.
;
   BAD:  ; Problem Reading the DATE_TIME
      PRINT, 'In Function GET_JULDAY:'
      PRINT, 'Problem Recoding the variable: ', DATE_TIME
      PRINT, !ERROR_STATE.MSG
      PRINT, 'This record will be skipped.'
      MT  = 12      ; Make sure
      DY  = 31      ; the
      YR  = 2010    ; year is < 2014.
;     Since JULDAY( MT,DY,YR, HR,MN,SD ) = JULDAY( 12,31,2010,0,0,59)
;     is < 2014.  The caller routine will skip the record.
      HELP, MT, DY, YR, HR, MN, SD
  DONE:
;
RETURN, JULDAY( MT,DY,YR, HR,MN,SD )
END  ; GET_JULDAY
;
; This funcion produces the index: I so that TIDAL_TIME[I] = TARGET_TIME.
; To save time, this function is Not using the IDL WHERE() to locate I.
; It counts the seconds to find the Index: I.  This works due to the
; TIDAL_TIME in the array are at every 15 seconds.
;
; Caller: DETIDE_NANO_DATA
;
FUNCTION RSN_TIDAL_TIME_INDEX, TIDAL_TIME,  $ ; 1-D array in Julian Days.
                                 N_TIDALS,  $ ; Size of TIDAL_TIME.
                              TARGET_TIME     ; Time to look up in TIDAL_TIME.
;
S = SYSTIME( 1 )  ; Mark the Start time.
;
   N = TARGET_TIME - TIDAL_TIME[0]
IF N LT 0.0 THEN  BEGIN
;  TARGET_TIME is Before the 1st time in TIDAL_TIME.
   I = -1  ; No Match & indicates TARGET_TIME < TIDAL_TIME.
ENDIF  ELSE  BEGIN  ; TARGET_TIME is After the 1st time in TIDAL_TIME.
;  Note that it is assumed the TARGET_TIME is at every 15 seconds.
;  Convert the time difference: N in days into total number of sample
;  point at every 15 seconds and
;  5760 = Total number of sample point at every 15 seconds in 24 hours.
   N = ROUND( N*5760.0D0  )  ; Convert the time difference into points.
   IF N GE N_TIDALS THEN  BEGIN  ; TARGET_TIME is Not in TIDAL_TIME.
;     TARGET_TIME is After the Last time in TIDAL_TIME.
      I = -N_TIDALS   ; indicate as TIDAL_TIME < TARGET_TIME.
   ENDIF  ELSE  BEGIN
      I =  N          ; TARGET_TIME = TIDAL_TIME[I[0]].
      IF ( TIDAL_TIME[I] - TARGET_TIME ) GT 5.0D-10 THEN  BEGIN ; No Match.
         I = -I
      ENDIF
   ENDELSE
ENDELSE
;
PRINT, 'Total seconds used: ' + STRTRIM( SYSTIME( 1 ) - S, 2 )
;
RETURN, I
END     ;  RSN_TIDAL_TIME_INDEX
;
; Callers: PLOT_LILY_DATA or Users
;
FUNCTION RSN_TILT_DIRECTION, XTILT, YTILT,  $ ; Inputs: 1-D arrays.
                             CCMP             ; Input : in degrees.
;
; The XTILT & YTILT are in micro-randians. 
;
; The following pseudo codes are provided by Dr. Bill Chadwick.
; This subroutine computes the Resultant Tilt Direction using
; the X-Tilt Y-Tilt, and the Corrected Compass Direction (CCMP):
;
; CS1) Compute an ANGLE using one of the following cases:
;         If X-Tilt = 0 and Y-Tilt > 0, then ANGLE = +90
;         If X-Tilt = 0 and Y-Tilt < 0, then ANGLE = -90
;         If Y-Tilt = 0, then ANGLE =  0
;         else ANGLE = arctan( Y-Tilt/X-Tilt )
; CS2) Then compute the Resultant Tilt Direction as follows: 
;         If X-Tilt > 0 or X-Tilt=0, then
;           Resultant Tilt Direction = 90 - ANGLE + CCMP
;         Else If X-Tilt < 0, then
;           Resultant Tilt Direction = 270 - ANGLE + CCMP
; CS3) Apply Modulus 360 to the Resultant Tilt Direction
;      so that it will be between 0-360
;      e.g. if Resultant Tilt Direction = 450, it will become 90.
; CS4) Return the Resultant Tilt Direction value to the main program.
;
; It is assummed the XTILT & YTILT are the same size.
; Get the total data points in the array: XTILT or YTILT
;
; N = N_ELEMENTS( XTILT )  ; = N_ELEMENTS( YTILT )
;
; Locate all the Zero values in XTILT if any.
;
  Z = WHERE( XTILT EQ 0.0, N_ZEROS )
;
; Assgin XTILT to a temporary array (RTD) in case XTILT is passed
; as an expression instead of an variable by the callers.
;
  RTD = FLOAT( XTILT )  ; 
;
IF N_ZEROS GT 0 THEN  BEGIN  ; Zeros are found
   RTD[Z] = 1.0  ;  Set them to 1's so that YTILT/XTILT below will be OK.
ENDIF
;
; Compute the ANGLE in degrees.
;
  ANGLE = ATAN( FLOAT( YTILT )/TEMPORARY( RTD )  )*!RADEG
;
; Recompute the correct ANGLE's for the XTILT[Z] that are == 0's.
; The following statement will do the followings.
; if XTILT = 0, and YTILT > 0, then ANGLE = +90
; if XTILT = 0, and YTILT < 0, then ANGLE = -90
;
IF N_ZEROS GT 0 THEN  BEGIN  ; There are Zero XTILT values.
   ANGLE[Z] =  90*( YTILT[Z] GT 0.0 ) -  90*( YTILT[Z] LT 0.0 )
ENDIF
;
; Locate all the Zero values in YTILT if any.
; 
  Z = WHERE( YTILT EQ 0.0, N_ZEROS )
;
IF N_ZEROS GT 0 THEN  BEGIN  ; There are Zero YTILT values.
   ANGLE[Z] = 0              ; Reset the value to 0.
ENDIF
;
; Get all the I indexes for XTILT[I] <  0 and
;         the J indexes for XTILT[J] >= 0.
; 
  I = WHERE( XTILT LT 0.0, N, COMPLEMENT=J, NCOMPLEMENT=M )
               ; Note that N + M = N_ELEMENTS( XTILT )
;
; Compute the Resultant Tilt Directions (RTD).
; 
  RTD = CCMP - ANGLE
; 
  IF N GT 0 THEN  BEGIN
;    Resultant Tilt Direction = 270 - ANGLE + CCMP
     RTD[I] = 270 + RTD[I]
  ENDIF
  IF M GT 0 THEN  BEGIN
;    Resultant Tilt Direction =  90 - ANGLE + CCMP
     RTD[J] =  90 + RTD[J]
  ENDIF
;
; Apply Modulus 360 to the Resultant Tilt Direction
; 
  RTD = TEMPORARY( RTD ) MOD 360.0  ; So that 0 <= RTD < 360. 
;
; If the "Resultant Tilt Directions" are < 0, add 360 to them.
;  
   Z = WHERE( RTD LT 0.0, N_ZEROS )
IF N_ZEROS GT 0 THEN  BEGIN
   RTD[Z] = RTD[Z] + 360
ENDIF
;
RETURN, RTD
END   ; RSN_TILT_DIRECTION
;
; Caller: PROCESS_RSN_DATA
;
PRO ALLOCATE_STORGES, RSN_FILE  ; For storing the data from the records.
;
COMMON HEAT, HTIME, XHTILT, YHTILT, HTEMP, N_HEAT
COMMON IRIS, ITIME, XITILT, YITILT, ITEMP, N_IRIS
COMMON LILY, LTIME, XLTILT, YLTILT, COMPASS, LTEMP, VOLTAGE, N_LILY
COMMON NANO, PTIME, PSIA,   PTEMP,  N_NANO
;
; Using the UNIX commands to find out how many records of the 4
; sensors: LILY, HEAT, IRIS and NANO in the RSN_FILE.
;
UNIX   = 'grep LILY ' + RSN_FILE + ' | wc -l'
SPAWN, UNIX, N
N_LILY = ULONG( N[0] )  ; Total LILY records.
;
UNIX   = 'grep HEAT ' + RSN_FILE + ' | wc -l'
SPAWN, UNIX, N
N_HEAT = ULONG( N[0] )  ; Total HEAT records.
;
UNIX   = 'grep IRIS ' + RSN_FILE + ' | wc -l'
SPAWN, UNIX, N
N_IRIS = ULONG( N[0] )  ; Total IRIS records.
;
UNIX   = 'grep NANO ' + RSN_FILE + ' | wc -l'
SPAWN, UNIX, N
N_NANO = ULONG( N[0] ) ; Total NANO records.
;
; Define the size of the arrays in the COMMON Blocks.
;
IF N_HEAT GT 0 THEN  BEGIN
    HTIME  = DBLARR( N_HEAT )
   XHTILT  = INTARR( N_HEAT )
   YHTILT  = INTARR( N_HEAT )
    HTEMP  = INTARR( N_HEAT )
ENDIF
;
IF N_IRIS GT 0 THEN  BEGIN
    ITIME  = DBLARR( N_IRIS )
   XITILT  = FLTARR( N_IRIS )
   YITILT  = FLTARR( N_IRIS )
    ITEMP  = FLTARR( N_IRIS )
ENDIF
;
IF N_LILY GT 0 THEN  BEGIN
    LTIME  = DBLARR( N_LILY )
   XLTILT  = FLTARR( N_LILY )
   YLTILT  = FLTARR( N_LILY )
   COMPASS = FLTARR( N_LILY )
    LTEMP  = FLTARR( N_LILY )
   VOLTAGE = FLTARR( N_LILY )
ENDIF
;
IF N_NANO GT 0 THEN  BEGIN
    PTIME  = DBLARR( N_NANO )
    PSIA   = DBLARR( N_NANO )
    PTEMP  = DBLARR( N_NANO )
ENDIF
;
RETURN
END  ; ALLOCATE_STORGES
;
; Callers:  PROCESS_RSN_FILES
;
PRO CHECK4PASSING_NEW_YEAR, OUTPUT_DIRECTORY  ; Input: String.
;
MONTH = 12    ; 1-12
DAY   = 31    ; 1-31
YEAR  = 2014  ; e.g.
;
        DATE = SYSTIME( /JULIAN )  ; Get the surrent date and time.
CALDAT, DATE,  MONTH, DAY, YEAR    ; Get the MONTH, DAY, YEAR
;
DAY = ROUND( DATE - JULDAY( 1, 0, YEAR, 0,0,0 ) )
;
IF DAY EQ 10 THEN  BEGIN
   PRINT, 'It is about 10 days after the new years.'
   PRINT, 'Save the last year RSN data into differenct files.'
   NOTIFY_ADMINISTRATOR, 'Time2SetNewFiles'
ENDIF
;
RETURN
END  ; ALLOCATE_STORGES
;
; Callers: PROCESS_RSN_DATA
;
PRO CHECK_OPEN_WINDOW_STATUS, CONDITION
;
    CATCH, ERROR_STATUS
    IF ERROR_STATUS NE 0 THEN  BEGIN  ; There is a problem
       PRINT, 'In CHECK_OPEN_WINDOW_STATUS: Cannot Open a PIXMAP Window!'
       HELP, /STRUCTURE, !ERROR_STATE
       PRINT, 'Error   index: ', Error_STATUS
       PRINT, '     SYS_CODE: ', !ERROR_STATE.SYS_CODE
       PRINT, 'SYS_CODE_TYPE: ', !ERROR_STATE.SYS_CODE_TYPE
       PRINT, '          MSG: ', !ERROR_STATE.MSG
       PRINT, '      SYS_MSG: ', !ERROR_STATE.SYS_MSG
       PRINT, '   MSG_PREFIX: ', !ERROR_STATE.MSG_PREFIX
       PRINT, 'Plottings will be Skipped!'
;      CATCH, /CANCEL
       CONDITION = 'Not OK'  ; Cannot Open a graphic window.
       RETURN  ; to the Caller.
    ENDIF
;   If a PIXMAP window Cannot be Opened, the current process Cannot
;   generate graphic and IF statement above will be executed.
;   If a window Can be Opened, the current process Can generate
;   graphic.  Delete the opened window and return to the caller.
    WINDOW, /FREE, /PIXMAP  ; Try to Open a PIXMAP window as a Test.
    WDELETE                 ; Remove the PIXMAP window, i.e. the Test is OK.
    CONDITION = 'OK'        ; Current process Can Open a graphic window.
    PRINT, 'In CHECK_OPEN_WINDOW_STATUS: Opening a PIXMAP Window is OK.'
;
RETURN
END  ; CHECK_OPEN_WINDOW_STATUS
;
; This procedure will be computing the Tilt Magnitudes & Directions
; from the LILY data.
;
; Callers: PROCESS_RSN_DATA or Users.
; Revised: February 22nd, 2018
;
PRO COMPUTE_LILY_RTMD, ID,  $ ; Input: 'MJ03D', 'MJ03E' or 'MJ03F'.
               N_LILY_CNT     ; Input: Total number of data points
;
COMMON LILY, TIME, XTILT, YTILT, COMPASS, TEMP, VOLTAGE, N_LILY
;
; Use the ID value: 'MJ03D', 'MJ03E' or 'MJ03F' and the following
; conditions to determine the compass value: CCMP.
; A304 - MJ03B - Ashes Vent Fiels       (LILY s/n N96??) - CCMP = 201°  Since August 16th, 2017.
; A304 - MJ03B - Ashes Vent Fiels       (LILY s/n N96??) - CCMP = 345°  Correct value to use.
; A303 - MJ03D - International District (LILY s/n N9655) - CCMP = 106°
; A302 - MJ03E - East Caldera           (LILY s/n N9652) - CCMP = 195°
; A301 - MJ03F - Central Caldera        (LILY s/n N9676) - CCMP = 345°
;
  CASE  ID  OF
;   'MJ03B' : CCMP = 201  ; Added on August 16th, 2017.
    'MJ03B' : CCMP = 345  ; 354 is the "Corrected" value to used.  February 22nd, 2018
    'MJ03D' : CCMP = 106
    'MJ03E' : CCMP = 195
    'MJ03F' : CCMP = 345
     ELSE   : BEGIN
              PRINT, 'Data ID: ' + ID + ' Not from MJ03B,MJ03D,MJ03E or MJ03F!'
              PRINT, 'No plotting LILY data.'
              RETURN
     END
  ENDCASE
;
; Compute the Resultant Tilt Megnitudes (RTM),
; and     the Resultant Tilt Directions (RTD).
;
  RTM = XTILT[0:N_LILY_CNT-1]*XTILT[0:N_LILY_CNT-1]
  RTD = YTILT[0:N_LILY_CNT-1]*YTILT[0:N_LILY_CNT-1]
  RTM = SQRT( TEMPORARY( RTM ) + TEMPORARY( RTD ) )
  RTD = RSN_TILT_DIRECTION( XTILT[0:N_LILY_CNT-1],      $
                            YTILT[0:N_LILY_CNT-1], CCMP )
;
; Use the COMPASS and VOLTAGE arrays for storing the RTM & RTD values.
;
  COMPASS[0:N_LILY_CNT-1] = RTM
  VOLTAGE[0:N_LILY_CNT-1] = RTD
;
RETURN
END  ; COMPUTE_LILY_RTMD
;
; This procedure will Remove the Tidal Signals from the NANO pressure
; data stored in the array: PSIA of the COMMON Block: NANO
;
; Callers: PROCESS_RSN_DATA or users.
; Revised: December  8th, 2020
;
PRO DETIDE_NANO_DATA, STATION_ID,  $ ; Input: 'MJ03D', 'MJ03E', 'MJ03F' or ''.
                      N_NANO_CNT,  $ ; Input: Integer.
                      STATUS       ;  Output: Unused.
;
; Note that this routine assumes the NANO data in the COMMON NANO
; have been subsampled into every 15th seconds.
;
COMMON NANO,   TIME, PSIA, TEMP, N_NANO
COMMON DETIDE,       METER ; for storing the de-tided press data in meters.
;
; Define a factor for converting pressure in psia into millimeters.
;
  PSIA2MM = 670.0D0    ; 1 psia = 670 mm.
;
; MM = PSIA * PSIA2MM  ; Convert pressure in psia into millimeters.
;
;
; Retrieve the predicate Tidal Signal Data in meters at every 15 seconds.
; Note the TIDAL array stores the Tidal Signals in meters as Heights. 
;
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/Aug-Dec2014AxialTidalData.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/Dec2014Jan2015AxialTidalData.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/2015AxialTidalData.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/Dec2015-2016AxialTidalData' + STATION_ID + '.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/' + STATION_ID + '2016AxialTidalData.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/Dec2016-2017AxialTidalData' + STATION_ID + '.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/' + STATION_ID + '2017AxialTidalData.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/Dec2017-2018AxialTidalData' + STATION_ID + '.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/' + STATION_ID + '2018AxialTidalData.idl'
; TIDAL_DATA_FILE = '~/4Chadwick/RSN/Dec2019-2020AxialTidalData' + STATION_ID + '.idl'
  TIDAL_DATA_FILE = '~/4Chadwick/RSN/Dec2020-2021AxialTidalData' + STATION_ID + '.idl'
;
RESTORE, TIDAL_DATA_FILE  ; to get TIDAL_TIME (Julian Days), TIDAL (m)
;                         ; and N_TIDALS.
;
; Note that TIDAL_TIME interval is also at every 15 seconds in days.
;
;
; Locate the 1st index in TIDAL_TIME that is = to the TIME[0].
;
  S = RSN_TIDAL_TIME_INDEX( TIDAL_TIME, N_TIDALS, TIME[0] )
;
; Note that when S = -N_TIDALS, it indicates the TIME[0] is Not within
; the range of TIDAL_TIME.
; When S < 0 and within the range of -N_TIDALS < S < 0,
; it indicates the Not times in TIDAL_TIME match the TIME[0] exactly.
; But the TIDAL_TIME[ABS( S )] could be close to TIME[0].
; In this routine, it is assumed the
; | TIME[0] - TIDAL_TIME[ABS( S )] | = +/- 1 second the most
;
  S = ABS( S )  ; is used.
;
; Compute the time differences in seconds since the 1st data points.
;
  P = ROUND( ( TIME - TIME[0] )*86400.0D0 )  ; Indexes
;
; Check to see whether they are any indexes are Not in 15 seconds increment.
;
  I = WHERE( ( P MOD 15 ) NE 0, N )  ; Locate indexes that out of order.
;
IF N GT 0 THEN  BEGIN  ; There are indexes Not in 15 seconds increment.
;  STOP
   P[I] = P[I] - ( P[I] MOD 15 )  ; Correct the orders.
ENDIF
;
; Create an index array: P so that TIDAL_TIME[P] = TIME[0:*].
;
; Note that P/15 will convert the values in P = [ 0, 15, 30, 45, ... ]
; into [ 0, 1, 2, 3, ... ].  When there is a gap, for example
;      P    = [ 0, 15, 30, 45, 75, 90 ] <-- 60 is missing in between 45 & 75,
; then P/15 = [ 0,  1,  2,  3,  5,  6 ] <-- & 4 from 60/15 will not be there.
;
; P = P/15 + S where S is offset index so that the adjust P can point to
; the values in TIDAL_TIME & TIDAL correctly. 
;
  P = TEMPORARY( P )/15 + S
;
; Now TIDAL[P] will match the positions in the P_MM[0:N_POINTS-1].
;
; Remove the tidal affect from the subsampled NANO pressure data.
;
;         PSIA*PSIA2MM  = Convert pressure in psia into millimeters.
  METER = PSIA*PSIA2MM/1000.0 - TIDAL[P]  ; PINM = Height in Meters.
;
RETURN
END  ; DETIDE_NANO_DATA
;
; Caller : PROCESS_RSN_DATA
; Revised: February 5th, 2015
;
PRO GET_HEAT_DATA, RCD,  $ ;  Input: Data Record in characters.
                 N_RCD,  $ ;  I/O  : Total Record counts.
                STATUS     ; Output: will be 'OK' or 'Incomplete Record'
;
COMMON HEAT, TIME, XTILT, YTILT, TEMP, N_HEAT
;
; An example of the HEAT record:
; RCD = 'HEAT,2014/08/29 23:17:57,0000,0001,0003'
;
; Extract all the information from the data record: RCD
; It is assumed the information fields are separated by either a space
; or a comma.
;
  S = STRSPLIT( RCD, ' ,', /EXTRACT, COUNT=N )  ; N=Number of substrings.
;
; Then S will be a string array of 6 elements, e.g. 
; S   = ['HEAT','2014/08/29','23:17:57','0000','0001','0003']
;
IF N LT 6 THEN  BEGIN
   STATUS = 'Incomplete Record'  ; RCD does not contains all the HEAT data.
   RETURN ; to caller.
ENDIF
;
  STATUS = 'OK'  ; RCD contains all the HEAT data.
;
; Convert the Date & Time: '2014/08/29 23:17:57' for example,
; into a Julain Day from the IDL funcition: JULDAY().
;
  T = GET_JULDAY( S[1] + ' ' + S[2] )
;
; If Time: T is before November 2014 which is before RSN data started,
; assume the Time is having problem and skip this record.
;
IF T LT JULDAY( 11,1,2014, 0,0,0 ) THEN  BEGIN  ; February 5th, 2015
   STATUS = 'Time Index Porbem'
   RETURN ; to caller.
ENDIF
;
; Get the X & Y Tilts & Temperature values in integers.
; 
  X = FIX( S[3] )  ; X-Tilt  in
  Y = FIX( S[4] )  ; Y-Tilt  Degrees.
TMP = FIX( S[5] )  ; Temperature in degree: C.
;
S = N_RCD  ; N_RCD also used as the array's index for the COMMON black arrays.
;
; Increase the size of the COMMON black arrays if they are all used up.
;
IF N_RCD GE N_HEAT THEN  BEGIN  ; All spaces are filled.
;  Increase the size of the COMMON black arrays by 10 more records.
   TIME    = [ TEMPORARY(  TIME ), DBLARR( 10 ) ]
  XTILT    = [ TEMPORARY( XTILT ), INTARR( 10 ) ]
  YTILT    = [ TEMPORARY( YTILT ), INTARR( 10 ) ]
   TEMP    = [ TEMPORARY(  TEMP ), INTARR( 10 ) ]
   N_HEAT += 10  ; Update the arrays' sizes.
ENDIF
;
; Store the retrieved data into the COMMON black arrays.
;
    TIME[S] = T
   XTILT[S] = X
   YTILT[S] = Y
    TEMP[S] = TMP
;
      N_RCD = S + 1  ; Update the Total Record counts.
;
RETURN
END  ; GET_HEAT_DATA
;
; Caller : PROCESS_RSN_DATA
; Revised: February 5th, 2015
;
PRO GET_IRIS_DATA, RCD,  $ ;  Input: Data Record in characters.
                 N_RCD,  $ ;  I/O  : Total Record counts.
                STATUS     ; Output: will be 'OK' or 'Incomplete Record'
;
COMMON IRIS, TIME, XTILT, YTILT, TEMP, N_IRIS
;
; An example of the IRIS record:
; RCD = 'IRIS,2014/08/29 23:17:55,  0.9977,  1.7926, 2.18,N3616'
;
; Extract all the information from the data record: RCD
; It is assumed the information fields are separated by either a space
; or a comma.
;
S = STRSPLIT( RCD, ' ,', /EXTRACT, COUNT=N )  ; N=Number of substrings.
;
; Then S will be a string array of 7 elements, e.g. 
; S   = ['IRIS','2014/08/29','23:17:55','0.9977','1.7926','2.18','N3616']
; Note the last values is the Serial number & it will not be used.
;
IF N LT 6 THEN  BEGIN
   STATUS = 'Incomplete Record'  ; RCD does not contains all the IRIS data.
   RETURN ; to caller.
ENDIF
;
  STATUS = 'OK'  ; RCD contains all the IRIS data.
;
; Convert the Date & Time: '2014/08/29 23:17:55' for example,
; into a Julain Day from the IDL funcition: JULDAY().
;
  T = GET_JULDAY( S[1] + ' ' + S[2] )
;
; If Time: T is before November 2014 which is before RSN data started,
; assume the Time is having problem and skip this record.
;
IF T LT JULDAY( 11,1,2014, 0,0,0 ) THEN  BEGIN  ; February 5th, 2015
   STATUS = 'Time Index Porbem'
   RETURN ; to caller.
ENDIF
;
; Get the X & Y Tilts & Temperature values in floating points.
; 
  X = FLOAT( S[3] )  ; X-Tilt  in
  Y = FLOAT( S[4] )  ; Y-Tilt  Degrees.
TMP = FLOAT( S[5] )  ; Temperature in degree: C.
;
S = N_RCD  ; N_RCD also used as the array's index for the COMMON black arrays.
;
; Increase the size of the COMMON black arrays if they are all used up.
;
IF N_RCD GE N_IRIS THEN  BEGIN  ; All spaces are filled.
;  Increase the size of the COMMON black arrays by 10 more records.
   TIME    = [ TEMPORARY(  TIME ), DBLARR( 10 ) ]
  XTILT    = [ TEMPORARY( XTILT ), FLTARR( 10 ) ]
  YTILT    = [ TEMPORARY( YTILT ), FLTARR( 10 ) ]
   TEMP    = [ TEMPORARY(  TEMP ), FLTARR( 10 ) ]
   N_IRIS += 10  ; Update the arrays' sizes.
ENDIF
;
; Store the retrieved data into the COMMON black arrays.
;
    TIME[S] = T
   XTILT[S] = X
   YTILT[S] = Y
    TEMP[S] = TMP
;
      N_RCD = S + 1  ; Update the Total Record counts.
;
RETURN
END  ; GET_IRIS_DATA
;
; Caller : PROCESS_RSN_DATA
; Revised: February 5th, 2015
;
PRO GET_LILY_DATA, RCD,  $ ;  Input: Data Record in characters.
                 N_RCD,  $ ;  I/O  : Total Record counts.
                STATUS     ; Output: will be 'OK' or 'Incomplete Record'
;
COMMON LILY, TIME, XTILT, YTILT, COMPASS, TEMP, VOLTAGE, N_LILY
;
; An example of the LILY record:
; RCD = 'LILY,2014/08/29 23:18:03, 330.000, 330.000,143.53,  3.21,11.95,N9655'
;
; Extract all the information from the data record: RCD
; It is assumed the information fields are separated by either a space
; or a comma.
;
S = STRSPLIT( RCD, ' ,', /EXTRACT, COUNT=N )  ; N=Number of substrings.
;
; Then S will be a string array of 9 elements, e.g. 
; S   = ['LILY','2014/08/29','23:18:03','330.000','330.000',  $
;                           '143.53','3.21','11.95','N9655'   ]
; Note the last values is the Serial number & it will not be used.
;
IF N LT 8 THEN  BEGIN
   STATUS = 'Incomplete Record'  ; RCD does not contains all the LILY data.
   RETURN ; to caller.
ENDIF
;
  STATUS = 'OK'  ; RCD contains all the LILY data.
;
; Convert the Date & Time: '2014/08/29 23:18:03' for example,
; into a Julain Day from the IDL funcition: JULDAY().
;
  T = GET_JULDAY( S[1] + ' ' + S[2] )
;
; If Time: T is before November 2014 which is before RSN data started,
; assume the Time is having problem and skip this record.
;
IF T LT JULDAY( 11,1,2014, 0,0,0 ) THEN  BEGIN  ; February 5th, 2015
   STATUS = 'Time Index Porbem'
   RETURN ; to caller.
ENDIF
;
; Get the X & Y Tilts & Temperature values in integers.
; 
  X = FLOAT( S[3] )  ; X-Tilt  in
  Y = FLOAT( S[4] )  ; Y-Tilt  microrandians.
  C = FLOAT( S[5] )  ; Compass in degrees.
TMP = FLOAT( S[6] )  ; Temperature in degree: C.
  V = FLOAT( S[7] )  ; Voltage.
;
S = N_RCD  ; N_RCD also used as the array's index for the COMMON black arrays.
;
; Increase the size of the COMMON black arrays if they are all used up.
;
IF N_RCD GE N_LILY THEN  BEGIN  ; All spaces are filled.
;  Increase the size of the COMMON black arrays by 10 more records.
   TIME    = [ TEMPORARY(  TIME ), DBLARR( 10 ) ]
  XTILT    = [ TEMPORARY( XTILT ), FLTARR( 10 ) ]
  YTILT    = [ TEMPORARY( YTILT ), FLTARR( 10 ) ]
  COMPASS  = [ TEMPORARY(COMPASS), FLTARR( 10 ) ]
   TEMP    = [ TEMPORARY(  TEMP ), FLTARR( 10 ) ]
  VOLTAGE  = [ TEMPORARY(VOLTAGE), FLTARR( 10 ) ]
   N_LILY += 10  ; Update the arrays' sizes.
ENDIF
;
; Store the retrieved data into the COMMON black arrays.
;
    TIME[S] = T
   XTILT[S] = X
   YTILT[S] = Y
 COMPASS[S] = C
    TEMP[S] = TMP
 VOLTAGE[S] = V
;
      N_RCD = S + 1  ; Update the Total Record counts.
;
RETURN
END  ; GET_LILY_DATA
;
; Caller : PROCESS_RSN_DATA
; Revised: February 5th, 2015
;
PRO GET_NANO_DATA, RCD,  $ ;  Input: Data Record in characters.
                 N_RCD,  $ ;  I/O  : Total Record counts.
                STATUS     ; Output: will be 'OK' or 'Incomplete Record'
;
COMMON NANO, TIME, PSIA, TEMP, N_NANO
;
; An example of the NANO record:
; RCD = 'NANO,P,2014/08/29 23:17:59.000,2259.316763,2.725865576'
;
; Extract all the information from the data record: RCD
; It is assumed the information fields are separated by either a space
; or a comma.
;
S = STRSPLIT( RCD, ' ,', /EXTRACT, COUNT=N )  ; N=Number of substrings.
;
; Then S will be a string array of 6 elements, e.g. 
; S   = ['NANO','P','2014/08/29','23:17:59.000','2259.316763','2.725865576']
; where 'P' indicates the date/time is synced to PPS signal
; and   'V' indicates No PPS lock.
; The indicators 'P' & 'V' are not being used.
;
IF N LT 6 THEN  BEGIN
   STATUS = 'Incomplete Record'  ; RCD does not contains all the NANO data.
   RETURN ; to caller.
ENDIF
;
  STATUS = 'OK'  ; RCD contains all the NANO data.
;
; Convert the Date & Time: '2014/08/29 23:17:59.000' for example,
; into a Julain Day from the IDL funcition: JULDAY().
;
  T = GET_JULDAY( S[2] + ' ' + S[3] )
;
; If Time: T is before November 2014 which is before RSN data started,
; assume the Time is having problem and skip this record.
;
IF T LT JULDAY( 11,1,2014, 0,0,0 ) THEN  BEGIN  ; February 5th, 2015
   STATUS = 'Time Index Porbem'
   RETURN ; to caller.
ENDIF
;
; Get the X & Y Tilts & Temperature values in floating points.
; 
  P = DOUBLE( S[4] )  ; X-Tilt  in
TMP = DOUBLE( S[5] )  ; Temperature in degree: C.
;
S = N_RCD  ; N_RCD also used as the array's index for the COMMON black arrays.
;
; Increase the size of the COMMON black arrays if they are all used up.
;
IF N_RCD GE N_NANO THEN  BEGIN  ; All spaces are filled.
;  Increase the size of the COMMON black arrays by 10 more records.
   TIME    = [ TEMPORARY(  TIME ), DBLARR( 10 ) ]
   PSIA    = [ TEMPORARY(  PSIA ), DBLARR( 10 ) ]
   TEMP    = [ TEMPORARY(  TEMP ), DBLARR( 10 ) ]
   N_NANO += 10  ; Update the arrays' sizes.
ENDIF
;
; Store the retrieved data into the COMMON black arrays.
;
    TIME[S] = T
    PSIA[S] = P
    TEMP[S] = TMP
;
      N_RCD = S + 1  ; Update the Total Record counts.
;
RETURN
END  ; GET_NANO_DATA
;
;  Caller: PROCESS_RSN_DATA_FILES
; Revised: June 7th, 2021  for updating email address.
;
PRO NOTIFY_ADMINISTRATOR, SUBJECT  ; Input: Characters.
;
; Define a Notification file name.  For example,
;
  MAIL = '~/4Chadwick/RSN/Notification'
;
; Write the Notification
;
OPENW,    MAIL_OUTPUT, MAIL, /GET_LUN
;
PRINTF,   MAIL_OUTPUT, [ SYSTIME(),                           $
         'It is about 10 days after the new years.',          $
         'Save the last year RSN data into differenct files.' ]
;
CLOSE,    MAIL_OUTPUT
FREE_LUN, MAIL_OUTPUT
;
; Set up the UNIX 'mail' command.
;
MAIL = 'mail -s ' + SUBJECT + ' -r Brian.Kahn@noaa.gov Brian.Kahn@noaa.gov < ' + MAIL
;
SPAWN, MAIL  ; Send out the Notification by email.
;
PRINT, [ SYSTIME(), MAIL, 'is sent.' ]
;
RETURN
END  ; NOTIFY_ADMINISTRATOR
;
; This procedure will Process all the data records in the provided data
; file.  The data in the RSN_FILE will be Retrieved and Saved into the
; IDL files.  Then the data will be plotted.
;
; Note that plotting rountines are located in the file: PlotRSNdata.pro
;
; Callers: PROCESS_RSN_DATA_FILE or Users.
; Revised: April      2nd, 2021
;
PRO PROCESS_RSN_DATA,  RSN_FILE, FILE_ORIG,  $ ;  Inputs: Strings.
                       STATUS,  $ ; Output: 0=No records or 1=Records processed.
    OUTPUT2=OUTPUT_DIRECTORY      ;  Input: Directory name.
;
; For example,
; RSN_FILE = '/RSN/Data/BOTPTA303_10.31.9.6_9338_20140829T2334_UTC.dat'
; FILE_ORIG = 'MJ03F', 'MJ03E', or 'MJ03D'  ;
;
IF NOT KEYWORD_SET( OUTPUT_DIRECTORY ) THEN  BEGIN
   OUTPUT_DIRECTORY = ''  ;
ENDIF  ELSE  BEGIN  ; OUTPUT_DIRECTORY is provided.
;  If OUTPUT_DIRECTORY does not have the directory seperator character:
;  '/' in UNIX or '\' in Windows at the end, Add the seperator at the end.
;  For example If OUTPUT_DIRECTORY = '/RSN/Outputs', then
;      Change     OUTPUT_DIRECTORY = '/RSN/Outputs/'.
   TYPE = STRMID( OUTPUT_DIRECTORY, STRLEN( OUTPUT_DIRECTORY )-1, 1 )
   IF TYPE NE PATH_SEP() THEN  BEGIN  ; TYPE Not = '/' or '\'
      OUTPUT_DIRECTORY += PATH_SEP()  ; Append the '/' or '/'.
   ENDIF
ENDELSE
;
; Get the total number of records in the RSN_FILE
;
; N = FILE_LINES( RSN_FILE )
;
  ALLOCATE_STORGES, RSN_FILE  ; For storing the data from the records.
;
; Open the (Input Data Record) RSN_FILE.
;
  OPENR, RSN_UNIT, /GET_LUN, RSN_FILE
;
; Get the file name without the directory path and the file name's suffix.
; For example,
; RSN_FILE = '/RSN/Data/BOTPTA303_10.31.9.6_9338_20140829T2317_UTC.dat'
; then FILE_ID = 'BOTPTA303_10.31.9.6_9338_20140829T2317_UTC'
;
  FILE_ID = FILE_BASENAME( RSN_FILE, '.dat' )
;
; Open 2 of the Output files for printing out the Non-Data Records
; and the Unknow data types including Incomplete Records if any.
; The output file names will be
; '/RSN/Output/MJ03D/BOTPTA303_10.31.9.6_9338_20140829T2334_UTC.NonData' 
; '/RSN/Output/MJ03D/BOTPTA303_10.31.9.6_9338_20140829T2334_UTC.Unknown'
; for example.
;
  TYPE      = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()  ; = '/RSN/Output/MJ03D/' e.g.
  NOND_FILE = TYPE + FILE_ID + '.NonData'  ; The Output
  UNKN_FILE = TYPE + FILE_ID + '.Unknown'  ; File Names.
;
  OPENW, NOND_UNIT, /GET_LUN, NOND_FILE
  OPENW, UNKN_UNIT, /GET_LUN, UNKN_FILE
;
; In the RSN_FILE data, there are 4 differen records from 4 different
; sensors: LILY, HEAT, IRIS and NANO.
;
         RCD = 'For reading a RSN record.'
  N_LILY_CNT = ULONG( 0 )
  N_HEAT_CNT = ULONG( 0 )  ; For counting the number of
  N_IRIS_CNT = ULONG( 0 )  ; records from the respective sensors.
  N_NANO_CNT = ULONG( 0 )
;
  N_NOND_CNT = ULONG( 0 )  ; For counting the number of Non-Data
  N_UNKN_CNT = ULONG( 0 )  ; and Unknown Record Types.
;
WHILE NOT EOF( RSN_UNIT ) DO  BEGIN
      READF, RSN_UNIT, RCD          ; Read in 1 record.
      RCD  = STRTRIM(  RCD, 2    )  ; Remove any spaces at the front & back.
      TYPE = STRPOS(   RCD, '*'  )  ; Look for an '*' in the data record.
      IF TYPE[0] GT 0 THEN  BEGIN   ; RCD contains an '*' and
         PRINT,  'Nondata Record: ' + RCD  ; contains Info other than data.
         PRINTF, NOND_UNIT,  RCD     ; to the Non-Data Record Output File.
               N_NOND_CNT += 1
      ENDIF  ELSE  BEGIN
         RCD_LENGTH = STRLEN( STRTRIM( RCD, 2 ) )  ; Length of the record.
         NON_DATA   = ( RCD_LENGTH NE 39 )  $  ; Not a HEAT  Record.
                  AND ( RCD_LENGTH NE 54 )  $  ; Not a IRIS or NANO.
                  AND ( RCD_LENGTH NE 68 )     ; Not a LILY  Record.
         IF NON_DATA THEN  BEGIN  ; Record length is not correct.
            PRINT, 'Unknown Record: ' + RCD
            PRINTF, UNKN_UNIT,  RCD ; to the Unknown Record Output File.
                  N_UNKN_CNT += 1
         ENDIF  ELSE  BEGIN  ; Assumming the RCD is correct and Decode it.
            STATUS = ''  ; Nothing to begin.
            TYPE   = STRMID(    RCD, 0, 4 )  ; = 'LILY', 'HEAT', 'IRIS' or 'NANO'
            TYPE   = STRUPCASE( TYPE )       ; Make sure the TYPE are all Caps.
            IF TYPE EQ 'LILY' THEN  BEGIN
               GET_LILY_DATA, RCD, N_LILY_CNT, STATUS
            ENDIF ELSE IF TYPE EQ 'HEAT' THEN  BEGIN
               GET_HEAT_DATA, RCD, N_HEAT_CNT, STATUS
            ENDIF ELSE IF TYPE EQ 'IRIS' THEN  BEGIN
               GET_IRIS_DATA, RCD, N_IRIS_CNT, STATUS
            ENDIF ELSE IF TYPE EQ 'NANO' THEN  BEGIN
               GET_NANO_DATA, RCD, N_NANO_CNT, STATUS
            ENDIF ELSE BEGIN  ; Unknown Type.
               PRINT, 'Unknown Record: ' + RCD
               PRINTF, UNKN_UNIT,  RCD ; to the Unknown Record Output File.
                     N_UNKN_CNT += 1
            ENDELSE
;           IF STATUS EQ 'Incomplete Record' THEN  BEGIN
;              PRINT, 'Incomplete Record: ' + RCD
            IF ( STATUS EQ 'Incomplete Record' ) OR    $   ; April 2nd, 2021
               ( STATUS EQ 'Time Index Porbem' ) THEN  BEGIN
               PRINT, STATUS + ': ' + RCD
                                   RCD = STATUS + ': ' + TEMPORARY( RCD )
               PRINTF, UNKN_UNIT,  RCD ; to the Unknown Record Output File.
                     N_UNKN_CNT += 1
            ENDIF
         ENDELSE  ; Decoding the RSN Record.
      ENDELSE  ;  Processing the RSN Record.
ENDWHILE  ; Reading the RSN_UNIT.
;
CLOSE,    RSN_UNIT              ; Close the input RSN_FILE.
CLOSE,    NOND_UNIT, UNKN_UNIT  ; Close the Non-Data & Unknown Record Files.
FREE_LUN, RSN_UNIT, NOND_UNIT, UNKN_UNIT
;
; Remove the Non-Data & Unknown Record Output files if they are empty.
;
IF N_NOND_CNT LE 0 THEN  BEGIN       ; The *.NonData file is empty.
   FILE_DELETE, /VERBOSE, NOND_FILE  ; Delete it.
ENDIF
;
IF N_UNKN_CNT LE 0 THEN  BEGIN       ; The *.Unknown file is empty.
   FILE_DELETE, /VERBOSE, UNKN_FILE  ; Delete it.
ENDIF
;
; If No RSN data records are found in the RSN_FILE,
; Indicate that and Return to the caller.            September 2nd, 2015
;
   RCD = N_LILY_CNT + N_HEAT_CNT + N_IRIS_CNT + N_NANO_CNT
IF RCD EQ 0 THEN  BEGIN  ; No RSN data records are found in the RSN_FILE.
   PRINT, 'No RSN Data Records in the File: ' + RSN_FILE
   STATUS =  0  ; Show the caller that there are no records found.
   RETURN  ; to the caller.
ENDIF 
;
; Get a File ID from the RSN_FILE name.  For example:
; RSN_FILE = '/RSN/Data/BOTPTA303_10.31.9.6_9338_20140829T2317_UTC.dat'
; and the File name without its suffix and the directory path will be:
; FILE_ID   = 'BOTPTA303_10.31.9.6_9338_20140829T2317_UTC'
; Then from the File ID, Get the 1st part before the 1st '_' into TYPE
;                        and the 2nd part after  the 3rd '_' into RCD.
; e.g. TYPE = 'BOTPTA303'  and  RCD = '20140829T2317'
;
; FILE_ID = FILE_BASENAME( RSN_FILE, '.dat' )  ; '.dat' is the suffix.
  TYPE    = STRMID( FILE_ID,  0,  9 )  ; FILE_ID has been defined above.
  RCD     = STRMID( FILE_ID, 25, 13 )
;
  HELP, FILE_ID, TYPE, RCD
;
; The FILE_ID will be used to create an IDL Save File: FILE_ID + '.idl'
; for storing the retrieved new data when their 1st date & time is out
; of order with the last cumulative date & time.
;
; Save the new data when are they retrieved
; and Generate the figures with the new data.
;
; Note that plotting rountines are located in the file: PlotRSNdata.pro
;
; FILE_ORIG = 'MJ03F', 'MJ03E', or 'MJ03D'  ;
;
; Define the Directory Path for where the respective IDL Save Files are.
; For example,
; IDL_FILE = '/RSN/Output/'  + 'MJ03F'   + '/'  ; = '/RSN/Output/MJ03F/
;
;
IF N_LILY_CNT GT 0 THEN  BEGIN
;  Calculate the Tilt Magnitudes & Directions from the LILY data.
   COMPUTE_LILY_RTMD,  FILE_ORIG, N_LILY_CNT
   IDL_FILE  = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()
   FILE_ID   = IDL_FILE  ; Get the same Output Directory Path.
;  IDL_FILE += FILE_ORIG + '-LILY.idl'           ; Before March 11th, 2015
;  IDL_FILE will be = '/RSN/Output/MJ03F/MJ03F-LILY.idl' for example.
   IDL_FILE += '3Day' + FILE_ORIG + '-LILY.idl'  ; After March 11th, 2015
;  IDL_FILE will be = '/RSN/Output/MJ03F/3DayMJ03F-LILY.idl' for example.
   FILE_ID  += TYPE +  'LILY' + RCD  ; Get the File Base Name w/o suffix.
;  FILE_ID  will be = '/RSN/Output/MJ03F/BOTPTA303LILY20140829T2317' e.g.
   SAVE_LILY_DATA, IDL_FILE, N_LILY_CNT, FILE_ID, STATUS,  $
                   GET_SELECTED_INDEX=S
   HELP, IDL_FILE, N_LILY_CNT, FILE_ID, STATUS, S
   IF STATUS EQ 'OK' THEN  BEGIN  ; Data are Updated & Get ready to Plot.
      CHECK_OPEN_WINDOW_STATUS, STATUS  ; Can a PIXMAP window be opened?
      IF STATUS EQ 'OK' THEN  BEGIN     ; If Yes, then Plot the data.
;        Note that parameter [-3,1] was used before March  11th,2015 and the
;        [-3,0] with Only the 3-Day Plot is being used after March 11th, 2015
;        PLOT_LILY_DATA, IDL_FILE,[-3,1], SHOW_PLOT=0,UPDATE_PLOTS=1  ; 1=Yes
;        PLOT_LILY_DATA, IDL_FILE,[-3,0], SHOW_PLOT=0,UPDATE_PLOTS=1  ; 1=Yes
         PLOT_LILY_DATA, IDL_FILE,[-7,0], SHOW_PLOT=0,UPDATE_PLOTS=1  ; Started on 12/5/2017
      ENDIF  ; for plotting.
      IF S GE 0 THEN  BEGIN  ; There are new LILY data.
;        Check LILY X & Y Tilts for Alerts
         CHECK_LILY4ALERTS, FILE_ORIG, S, N_LILY_CNT-1  ; November 2014
      ENDIF  ; Check LILY X & Y Tilts for Alerts
   ENDIF  ; Checking.
ENDIF
IF N_IRIS_CNT GT 0 THEN  BEGIN
   IDL_FILE  = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()
   FILE_ID   = IDL_FILE  ; Get the same Output Directory Path.
;  IDL_FILE +=          FILE_ORIG + '-IRIS.idl'  ; Before March 11th, 2015
   IDL_FILE += '3Day' + FILE_ORIG + '-IRIS.idl'  ; After  March 11th, 2015
   FILE_ID  +=      TYPE +  'IRIS' + RCD
   SAVE_IRIS_DATA, IDL_FILE, N_IRIS_CNT, FILE_ID, STATUS
   IF STATUS EQ 'OK' THEN  BEGIN  ; Data are Updated & Get ready to Plot.
      CHECK_OPEN_WINDOW_STATUS, STATUS  ; Can a PIXMAP window be opened?
      IF STATUS EQ 'OK' THEN  BEGIN     ; If Yes, then Plot the data.
;        Note that parameter [-3,1] was used before March  11th,2015 and the
;        [-3,0] with Only the 3-Day Plot is being used after March 11th, 2015
;        PLOT_IRIS_DATA, IDL_FILE,[-3,1], SHOW_PLOT=0,UPDATE_PLOTS=1  ; 0=No
;        PLOT_IRIS_DATA, IDL_FILE,[-3,0], SHOW_PLOT=0,UPDATE_PLOTS=1  ; 0=No
         PLOT_IRIS_DATA, IDL_FILE,[-7,0], SHOW_PLOT=0,UPDATE_PLOTS=1  ; Started on 12/5/2017
      ENDIF  ;     where [-3,1] = plot the last 3 days' data (Short Term)
   ENDIF     ;     and       1  = plot all the data (Long Term).
ENDIF
IF N_HEAT_CNT GT 0 THEN  BEGIN
   IDL_FILE  = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()
   FILE_ID   = IDL_FILE  ; Get the same Output Directory Path.
;  IDL_FILE +=          FILE_ORIG + '-HEAT.idl'  ; Before March 11th, 2015
   IDL_FILE += '3Day' + FILE_ORIG + '-HEAT.idl'  ; After  March 11th, 2015
   FILE_ID  +=      TYPE +  'HEAT' + RCD
   SAVE_HEAT_DATA, IDL_FILE, N_HEAT_CNT, FILE_ID, STATUS
   IF STATUS EQ 'OK' THEN  BEGIN  ; Data are Updated & Get ready to Plot.
      CHECK_OPEN_WINDOW_STATUS, STATUS  ; Can a PIXMAP window be opened?
      IF STATUS EQ 'OK' THEN  BEGIN     ; If Yes, then Plot the data.
;        Note that parameter [-3,1] was used before March  11th,2015 and the
;        [-3,0] with Only the 3-Day Plot is being used after March 11th, 2015
;        PLOT_HEAT_DATA, IDL_FILE,[-3,1], SHOW_PLOT=0,UPDATE_PLOTS=1  ; 1=Yes
;        PLOT_HEAT_DATA, IDL_FILE,[-3,0], SHOW_PLOT=0,UPDATE_PLOTS=1  ; 1=Yes
         PLOT_HEAT_DATA, IDL_FILE,[-7,0], SHOW_PLOT=0,UPDATE_PLOTS=1  ; Started on 12/5/2017
      ENDIF  ; for plotting.
   ENDIF  ; Checking.
ENDIF
IF N_NANO_CNT GT 0 THEN  BEGIN
   IDL_FILE  = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()
   FILE_ID   = IDL_FILE  ; Get the same Output Directory Path.
;  IDL_FILE +=          FILE_ORIG + '-NANO.idl'  ; Before March 11th, 2015
   IDL_FILE += '3Day' + FILE_ORIG + '-NANO.idl'  ; After  March 11th, 2015
   SUBSAMPLE_NANO_DATA,   IDL_FILE, N_NANO_CNT, STATUS
   IF STRMID( STATUS, 0, 4 ) EQ 'NANO' THEN  BEGIN
      DETIDE_NANO_DATA, FILE_ORIG, N_NANO_CNT, STATUS
;     Note STATUS is not used in the DETIDE_NANO_DATA and
;     STATUS is being used as an output file name here below.  For example,
;     STATUS = '~/4Chadwick/RSN/MJ03D/SpikesReplacements.MJ03D'
      STATUS = FILE_ID + 'SpikesReplacements.' + FILE_ORIG  ;
      SPIKE_CHECK4NANO_DATA, STATUS, N_NANO_CNT  ; January 12, 2015
   ENDIF
   IF N_NANO_CNT GT 0 THEN  BEGIN
      FILE_ID += TYPE + 'NANO' + RCD
;     FILE_ID  = '~/4Chadwick/RSN/MJ03D/BOTPTA303NANO20Hz28Nov2014', e.g.
      SAVE_NANO_DATA,   IDL_FILE, N_NANO_CNT, FILE_ID, STATUS
;     IF STATUS EQ 'OK' THEN  BEGIN  ; Data are Updated & Get ready to Plot. 
;
;        The following commented-out coded were used between
;        November 2014 till February 10th, 2015.
;        They are replaced by the procedure: PROCESS_NANO_DATA
;        and it is at the end of the procedure: PROCESS_RSN_FILES.
;
;        Detect whether there are Tsunami/Upleft/Subsidence events or not.
;        Note that CHECK_NANO4ALERTS procedure is located in the file:
;        CHECK_NANO4ALERTS, IDL_FILE       ; CheckNANOdata4Alerts.pro  11/2014
;        CHECK_OPEN_WINDOW_STATUS, STATUS  ; Can a PIXMAP window be opened?
;        IF STATUS EQ 'OK' THEN  BEGIN     ; If Yes, then Plot the data.
;           PLOT_NANO_DATA        is in the file: PlotNANOdata.pro
;           PLOT_NANO_DATA,       IDL_FILE,[-3,1], SHOW_PLOT=0,UPDATE_PLOTS=1
;           FILE_ID = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()  $
;                   + 'EventDetectionParameters.'  + FILE_ORIG   ;     12/2014
;                   + 'EventDetectionParameters' + FILE_ORIG + '.idl' ; 1/2015
;           PLOT_SHORT_TERM_DATA, is in the file: PlotShortTermDataProducts.pro
;           PLOT_SHORT_TERM_DATA, FILE_ID, [-3,1], SHOW_PLOT=0,UPDATE_PLOT=1
;        ENDIF  ; for plotting.
;     ENDIF  ; Checking.
   ENDIF
ENDIF
;
STATUS =  1  ; Show the caller that there are RSN records processed.
;
RETURN
END  ; PROCESS_RSN_DATA
;
; This procedure will be the process One given RSN Data File.
; It deteremines the data file's origin then pass it on to the procedure
; PROCESS_RSN_DATA for processing. 
;
; Callers: PROCESS_RSN_FILES, or Users.
; Revised: August    24th, 2017.
;
PRO PROCESS_RSN_DATA_FILE,  RSN_FILE,  $ ;  Input File Name.
            STATUS,  $ ; Output: 'MJ03D File processed' or 'MJ03D File No Records' e.g.
            OUTPUT2=OUTPUT_DIRECTORY     ; Input : Directory name.
;
; OUTPUT_DIRECTORY = '/RSN/Output/'  ; For example,
;
IF NOT KEYWORD_SET( OUTPUT_DIRECTORY ) THEN  BEGIN
   OUTPUT_DIRECTORY = '~/4Chadwick/RSN/'  ;
ENDIF  ELSE  BEGIN  ; OUTPUT_DIRECTORY is provided.
;  If OUTPUT_DIRECTORY does not have the directory seperator character:
;  '/' in UNIX or '\' in Windows at the end, Add the seperator at the end.
;  For example If OUTPUT_DIRECTORY = '/RSN/Outputs', then
;      Change     OUTPUT_DIRECTORY = '/RSN/Outputs/'.
   TYPE = STRMID( OUTPUT_DIRECTORY, STRLEN( OUTPUT_DIRECTORY )-1, 1 )
   IF TYPE NE PATH_SEP() THEN  BEGIN  ; TYPE Not = '/' or '\'
      OUTPUT_DIRECTORY += PATH_SEP()  ; Append the '/' or '/'.
   ENDIF
ENDELSE
;
; RSN_FILE = 'BOTPTA303_10.31.9.6_9338_20140829T2334_UTC.dat' ; for example.
;
IF N_PARAMS() LE 0 THEN  BEGIN
   PRINT, SYSTIME() + ' From PROCESS_RSN_DATA_FILE, No data file is given.'
   PRINT, SYSTIME() + ' Program is Stopped.'
   RETURN  ; Back to the callers.
ENDIF
;
; Determine the file's origin (Power Junction-Box) from the file name.
; For this project, it will be looking for the following file types:
; A301 - MJ03F - Central Caldera        (LILY s/n N9676)
; A302 - MJ03E - East    Caldera        (LILY s/n N9652)
; A303 - MJ03D - International District (LILY s/n N9655)
; A304 - MJ03B - Ashes Vent Fiels       (LILY s/n N96??)  Since August 16th, 2017.
;
MJ03F = STRPOS( RSN_FILE, 'A301' )  ; Look for file from the Central Caldera.
MJ03E = STRPOS( RSN_FILE, 'A302' )  ; Look for file from the East    Caldera.
MJ03D = STRPOS( RSN_FILE, 'A303' )  ; Look for file from the Internation District 2
MJ03B = STRPOS( RSN_FILE, 'A304' )  ; Look for file from the ashes Vent Fiels
;
TYPE = MJ03F + MJ03E + MJ03D + MJ03B  ; will = 0 or 1.  August 24th, 2017.
;
IF TYPE LE 0 THEN  BEGIN  ; September 2nd, 2015.
   PRINT, SYSTIME() + ' From PROCESS_RSN_DATA_FILE, Unknown File Type: '
   PRINT,               RSN_FILE
   PRINT, SYSTIME() + ' No data have been Processed'
   STATUS = 'None'  ; September 2nd, 2015.
ENDIF  ELSE  BEGIN
;
; Process the data file.
;
; Note that the following 3 IF statement, at most only 1 of them will be true.
;
  IF MJ03F GT 0 THEN  BEGIN  ; MJ03F file is found.
     PROCESS_RSN_DATA, RSN_FILE, 'MJ03F', STATUS, OUTPUT2=OUTPUT_DIRECTORY
     STATUS = ( STATUS GE 1 ) ? 'MJ03F File processed' : 'MJ03F File No Records'
  ENDIF
  IF MJ03E GT 0 THEN  BEGIN  ; MJ03E file is found.
     PROCESS_RSN_DATA, RSN_FILE, 'MJ03E', STATUS, OUTPUT2=OUTPUT_DIRECTORY
     STATUS = ( STATUS GE 1 ) ? 'MJ03E File processed' : 'MJ03E File No Records'
  ENDIF
  IF MJ03D GT 0 THEN  BEGIN  ; MJ03D file is found.
     PROCESS_RSN_DATA, RSN_FILE, 'MJ03D', STATUS, OUTPUT2=OUTPUT_DIRECTORY
     STATUS = ( STATUS GE 1 ) ? 'MJ03D File processed' : 'MJ03D File No Records'
  ENDIF
  IF MJ03B GT 0 THEN  BEGIN  ; MJ03B file is found.  Added on August 24th, 2017.
     PROCESS_RSN_DATA, RSN_FILE, 'MJ03B', STATUS, OUTPUT2=OUTPUT_DIRECTORY
     STATUS = ( STATUS GE 1 ) ? 'MJ03B File processed' : 'MJ03B File No Records'
  ENDIF
;
  PRINT, SYSTIME() + ' From PROCESS_RSN_DATA_FILE, File:'
  PRINT,               RSN_FILE
  IF STRPOS( STATUS, 'No Records' ) GT 0 THEN  BEGIN
     PRINT, SYSTIME() + ' has No RSN Data Records.'
  ENDIF  ELSE  BEGIN
     PRINT, SYSTIME() + ' has been Processed.'
  ENDELSE
;
ENDELSE
;
RETURN
END  ; PROCESS_RSN_DATA_FILE
;
; This procedure will be the Starting Point for the RSN Data Processing.
; It deteremines the whether or not the New RSN data files are available.
; If the New files are ready, they will be processed 1 at atime by the
; procedure: PROCESS_RSN_DATA_FILE. 
;
; Callers: Users.
; Revised: November   3rd, 2015
;
PRO PROCESS_RSN_FILES,    RSN_DIRECTORY,  $ ; Input Directory
                       OUTPUT_DIRECTORY,  $ ; Input names.
    LOG_THE_LAST_FILE=WRITE_DOWN_LAST_FILE  ; After processing the last file.
;
IF N_PARAMS() LT 1 THEN  BEGIN  ; No directorys are provided.
   PRINT, 'Must provide the directory path for the new RSN data files.'
   RETURN
ENDIF
IF N_PARAMS() LT 2 THEN  BEGIN  ; OUTPUT_DIRECTORY is not provided.
   OUTPUT_DIRECTORY = '~/4Chadwick/RSN/'  ; for now.
ENDIF
;
; STATUS = 1
;
; Get the Station ID from the RSN_DIRECTORY where it will be =
; '/data/chadwick/4andy/mj03d/' for example and the Station ID is mj03d.
;
  I = STRPOS( RSN_DIRECTORY, 'mj03', /REVERSE_SEARCH )
  S = STRUPCASE( STRMID( RSN_DIRECTORY, I, 5 ) )
;
; Lock the current process so that no other RSN program such as
; the UpdateRSNsaveFiles.pro can be run unit this program finish.
; Note that the LOCK_PROCESSING procedure is in the StatusFile4RSN.pro.
;
  STATUS      = OUTPUT_DIRECTORY + PATH_SEP() + S + PATH_SEP()
  STATUS_FILE = STATUS + S + '.ProcessingStatus'
; STATUS_FILE = '~/4Chadwick/RSN/MJ03D/MJ03D.ProcessingStatus' e.g.
  LOCK_PROCESSING, STATUS_FILE, STATUS
;
IF STATUS EQ 0 THEN  BEGIN  ; March 3rd, 2015
   PRINT, 'Cannot the Lock the process.  Other RSN processing is running.'
   PRINT, 'This proram will stop & wait for the next time to process the data.'
   RETURN  ; to Caller.
ENDIF
;
; Here the process is Locked and can proceed for processing the data.
;
; Get the New RSN data files which have file name started with 'BOTPT'.
;
RSN_FILE = FILE_SEARCH( RSN_DIRECTORY + PATH_SEP() + 'BOTPT*UTC.dat', COUNT=N_FILES )
;
IF N_FILES LE 0 THEN  BEGIN
   PRINT, 'No RSN files are found in ' + RSN_DIRECTORY
ENDIF  ELSE  BEGIN  ; N_FILES > 1
   PRINT, 'In ' + RSN_DIRECTORY
   PRINT, 'Total Files: ', N_FILES
   GET_LAST_PROCESSED_FILE_NAME,  RSN_FILE[0], OUTPUT_DIRECTORY,  $
       LAST_PROCESSED_FILE_NAME,  LAST_PROCESSED_DATE
   IF  LAST_PROCESSED_FILE_NAME EQ 'None' THEN  BEGIN
      I = LONG( 0 )    ; for processing all the files in the RSN_FILE.
   ENDIF  ELSE  BEGIN  ; Look for the LAST_PROCESSED_FILE_NAME in RSN_FILE.
      I = WHERE( RSN_FILE EQ LAST_PROCESSED_FILE_NAME, S )
;     If No LAST_PROCESSED_FILE_NAME is found, I = 0; otherwise, use I[0]+1.
;     I = ( S LE 0 ) ? LONG( 0 ) : ( I[0] + 1 )  ; for Daily  processing.
      I = ( S LE 0 ) ? LONG( 0 ) : ( I[0] )      ; for Hourly processing.
   ENDELSE
   IF I GE N_FILES THEN  BEGIN
      PRINT, 'No New files available for processing yet!'
   ENDIF  ELSE  BEGIN  ; I < N_FILES  There are files to be processed.
      PRINT, 'will process files from: ' + STRTRIM( I + 1,   2 )  $
                               +  ' to ' + STRTRIM( N_FILES, 2 )
      FOR S =  I, N_FILES - 1 DO  BEGIN
          PROCESS_RSN_DATA_FILE,  OUTPUT2=OUTPUT_DIRECTORY,  $
                                  RSN_FILE[S], STATUS
      ENDFOR ; S
;     Note that STATUS = 'MJ03D File processed' OR 'MJ03D File No Records' for example.
;     When "No Records" occurs, Do not Update the Last Processed file!  It can be
;     a file contains the sent command, e.g. "#### at 1440791094.000, sending pwdv".
      S = STRPOS( STATUS, 'No Records' )  ; If S >= 0, "No Records" is in STATUS.   9/2/2015
;     It is assumed the RSN_FILE[*] list contains data from the same
;     station, either 'MJ03D', 'MJ03E' or 'MJ03F'.  No mixing!
      IF KEYWORD_SET( WRITE_DOWN_LAST_FILE ) AND ( S LT 0 )  THEN  BEGIN
;        Note that the procedure below in the file: StatusFile4RSN.pro
         WRITE_LAST_PROCESSED_FILE_NAME, RSN_FILE[N_FILES-1], OUTPUT_DIRECTORY
      ENDIF
           STATUS = STRMID( STATUS, 0, 5 )   ; = 'MJ03D', 'MJ03E' or 'MJ03F'
;     IF ( STATUS NE 'None' ) AND ( S LT 0 ) THEN  BEGIN  ; Checking alert events & plotting.
      IF ( STATUS NE 'None' ) THEN  BEGIN  ; Checking alert events & plotting.  11/03/2015
         PROCESS_NANO_DATA, STATUS, OUTPUT_DIRECTORY      ; February 10th, 2015
      ENDIF
   ENDELSE
   CHECK4PASSING_NEW_YEAR, OUTPUT_DIRECTORY
ENDELSE
;
; Free the current process so that other RSN program such as
; the UpdateRSNsaveFiles.pro can be run.  March 3rd, 2015
; Note that the FREE_PROCESSING procedure is in the StatusFile4RSN.pro.
;
  FREE_PROCESSING, STATUS_FILE
;
RETURN
END  ; PROCESS_RSN_FILES
;
; This procedure will get the last saved cumulative HEAT sensor data,
; add the retrieved new data.  Then save the updated cumulative values
; back to the IDL Save File.
;
; Callers: PROCESS_RSN_DATA or users
; Revised: January 16th, 2015
;
PRO SAVE_HEAT_DATA, IDL_FILE,  $ ;  Input: IDL Save File name.
                  N_HEAT_CNT,  $ ;  Input: Total points for the new data.
                     FILE_ID,  $ ;  Input: Name from the RSN data file.
                      STATUS     ; Output: 'OK' or 'Not OK'
;
COMMON HEAT, TIME, XTILT, YTILT, TEMP, N_HEAT
;
FILE   = FILE_INFO( IDL_FILE )  ; Get the IDL Save File's information.
STATUS = 'OK'                   ; Assume it is OK to start.
;  
IF FILE.EXISTS THEN  BEGIN
   RESTORE, IDL_FILE  ; Retrieve the past HEAT data
;  The Variables in IDL_FILE are assumed to be 
;  HEAT_TIME, HEAT_XTILT, HEAT_YTILT, HEAT_TEMP
   N = N_ELEMENTS( HEAT_TIME )
   PRINT, SYSTIME() + ' In SAVE_HEAT_DATA,'
   IF HEAT_TIME[N-1] LT TIME[0] THEN BEGIN  ; Time sequency is OK.
      PRINT, 'Appending New Data'
      HEAT_TIME   = [ TEMPORARY( HEAT_TIME  ),  TIME[0:N_HEAT_CNT-1] ]
      HEAT_XTILT  = [ TEMPORARY( HEAT_XTILT ), XTILT[0:N_HEAT_CNT-1] ]
      HEAT_YTILT  = [ TEMPORARY( HEAT_YTILT ), YTILT[0:N_HEAT_CNT-1] ]
      HEAT_TEMP   = [ TEMPORARY( HEAT_TEMP  ),  TEMP[0:N_HEAT_CNT-1] ]
   ENDIF ELSE IF HEAT_TIME[N-1] LT TIME[N_HEAT_CNT-1] THEN  BEGIN
;     TIME[0] <= HEAT_TIME[N-1] <  TIME[N_HEAT_CNT-1] Times Overlap.
;     Locate the Index: I so that TIME[I-1] <= HEAT_TIME[N-1] < TIME[I]. 
;     The Function: LOCATE_TIME_POSITION is in the file: SplitRSNdata.pro
      I = LOCATE_TIME_POSITION( TIME, HEAT_TIME[N-1] )
      PRINT, 'The Time Sequence is Overlapping at '  $
           + STRING( FORMAT='(2(C(),X))', TIME[I-1], HEAT_TIME[N-1]  )
;     Discard the all the values before I,     i.e., all the data
;     in [0:I-1] of the TIME, TEMP, etc. arrays will be discarded.
      HEAT_TIME   = [ TEMPORARY( HEAT_TIME  ),  TIME[I:N_HEAT_CNT-1] ]
      HEAT_XTILT  = [ TEMPORARY( HEAT_XTILT ), XTILT[I:N_HEAT_CNT-1] ]
      HEAT_YTILT  = [ TEMPORARY( HEAT_YTILT ), YTILT[I:N_HEAT_CNT-1] ]
      HEAT_TEMP   = [ TEMPORARY( HEAT_TEMP  ),  TEMP[I:N_HEAT_CNT-1] ]
   ENDIF  ELSE  BEGIN  ;
      IF HEAT_TIME[N-1] GE TIME[0] THEN  BEGIN   ; Times Out of Order.
         PRINT, 'The Time Sequency is Out of Order!'
         PRINT, 'The Last Time of the stored data is: '   $
              + STRING( FORMAT='( C() )', HEAT_TIME[N-1] )
         PRINT, 'which  is  After  the 1st data time: '   $
              + STRING( FORMAT='( C() )', TIME[0] ) + ' of the New data.'
      ENDIF
      STATUS   = 'Not OK'
   ENDELSE
ENDIF  ELSE  BEGIN  ; IDL_FILE does not exist.
;  Assumming it is the 1st time.
   HEAT_TIME   =  TIME[0:N_HEAT_CNT-1]
   HEAT_XTILT  = XTILT[0:N_HEAT_CNT-1]
   HEAT_YTILT  = YTILT[0:N_HEAT_CNT-1]
   HEAT_TEMP   =  TEMP[0:N_HEAT_CNT-1]
ENDELSE
;
; Save the Updated cumulative data if the STATUS is OK.
; Otherwise, only the new data will be saved into the
; IDL Save File: FILE_ID + '.idl' because, the 1st date & time in the
; new data is out of order with the last cumulative date & time.
;
IF STATUS EQ 'OK' THEN  BEGIN
;  Save the updated arrays into a temporary file 1st then replace the
;  indicated file by the temporary file.  In this way if write to an IDL
;  save file caused a problem, hopefully the 2nd around the problem will
;  be solved by itself. 
   FILE = IDL_FILE + 'save'  ; for a temporary file.
   SAVE, FILENAME=FILE, HEAT_TIME, HEAT_XTILT, HEAT_YTILT, HEAT_TEMP
   FILE_MOVE, FILE, IDL_FILE, /OVERWRITE
   PRINT, SYSTIME() + ' IDL Save File: ' + IDL_FILE + ' is updated.'
;  Replace the lastest TILT data by the cumulative data
;  before returning to the caller.
;   TIME = TEMPORARY( HEAT_TIME  )
;  XTILT = TEMPORARY( HEAT_XTILT )
;  YTILT = TEMPORARY( HEAT_YTILT )
;   TEMP = TEMPORARY( HEAT_TEMP  )
ENDIF  ELSE  BEGIN  ; STATUS == 'Not OK'
;  If the HEAT_TIME[N-1] = TIME[N_HEAT_CNT-1], it is assumed that Retrieved
;  data are already in the HEAT arrays.  So No need to save the Retrieved
;  data into a new file.
   IF ( HEAT_TIME[N-1] - TIME[N_HEAT_CNT-1] ) NE 0.0 THEN  BEGIN
;     Save only the newly received data into a different IDL save file name.
      FILE = FILE_ID + '.idl'
      SAVE, FILENAME=FILE, TIME, XTILT, YTILT, TEMP, N_HEAT_CNT
      PRINT, SYSTIME() + ' New IDL Save File: ' + FILE + ' is created.'
   ENDIF
ENDELSE
;
RETURN
END  ; SAVE_HEAT_DATA
;
; This procedure will get the last saved cumulative IRIS sensor  data,
; add the retrieved new data.  Then save the updated cumulative values
; back to the IDL Save File.
;
; Callers: PROCESS_RSN_DATA or users
; Revised: January 16th, 2015
;
PRO SAVE_IRIS_DATA, IDL_FILE,  $ ;  Input: IDL Save File name.
                  N_IRIS_CNT,  $ ;  Input: Total points for the new data.
                     FILE_ID,  $ ;  Input: Name from the RSN data file.
                      STATUS     ; Output: 'OK' or 'Not OK'
;
COMMON IRIS, TIME, XTILT, YTILT, TEMP, N_IRIS
;
FILE   = FILE_INFO( IDL_FILE )  ; Get the IDL Save File's information.
STATUS = 'OK'                   ; Assume it is OK to start.
;  
IF FILE.EXISTS THEN  BEGIN
   RESTORE, IDL_FILE  ; Retrieve the past IRIS data
;  The Variables in IDL_FILE are assumed to be 
;  IRIS_TIME, IRIS_XTILT, IRIS_YTILT, IRIS_TEMP
   N = N_ELEMENTS( IRIS_TIME )
   PRINT, SYSTIME() + ' In SAVE_IRIS_DATA,'
   IF IRIS_TIME[N-1] LT TIME[0] THEN BEGIN  ; Time sequency is OK.
      PRINT, 'Appending New Data'
      IRIS_TIME   = [ TEMPORARY( IRIS_TIME  ),  TIME[0:N_IRIS_CNT-1] ]
      IRIS_TEMP   = [ TEMPORARY( IRIS_TEMP  ),  TEMP[0:N_IRIS_CNT-1] ]
      IRIS_XTILT  = [ TEMPORARY( IRIS_XTILT ), XTILT[0:N_IRIS_CNT-1] ]
      IRIS_YTILT  = [ TEMPORARY( IRIS_YTILT ), YTILT[0:N_IRIS_CNT-1] ]
   ENDIF ELSE IF IRIS_TIME[N-1] LT TIME[N_IRIS_CNT-1] THEN  BEGIN
;     TIME[0] <= IRIS_TIME[N-1] <  TIME[N_IRIS_CNT-1] Times Overlap.
;     Locate the Index: I so that TIME[I-1] <= IRIS_TIME[N-1] < TIME[I]. 
;     The Function: LOCATE_TIME_POSITION is in the file: SplitRSNdata.pro
      I = LOCATE_TIME_POSITION( TIME, IRIS_TIME[N-1] )
      PRINT, 'The Time Sequence is Overlapping at '  $
           + STRING( FORMAT='(2(C(),X))', TIME[I-1], IRIS_TIME[N-1]  )
;     Discard the all the values before I,     i.e., all the data
;     in [0:I-1] of the TIME, TEMP, etc. arrays will be discarded.
      IRIS_TIME   = [ TEMPORARY( IRIS_TIME  ),  TIME[I:N_IRIS_CNT-1] ]
      IRIS_TEMP   = [ TEMPORARY( IRIS_TEMP  ),  TEMP[I:N_IRIS_CNT-1] ]
      IRIS_XTILT  = [ TEMPORARY( IRIS_XTILT ), XTILT[I:N_IRIS_CNT-1] ]
      IRIS_YTILT  = [ TEMPORARY( IRIS_YTILT ), YTILT[I:N_IRIS_CNT-1] ]
   ENDIF  ELSE  BEGIN  ;
      IF IRIS_TIME[N-1] GE TIME[0] THEN  BEGIN  ;  Times Out of Order.
         PRINT, 'The Time Sequency is Out of Order!'
         PRINT, 'The Last Time of the stored data is: '   $
              + STRING( FORMAT='( C() )', IRIS_TIME[N-1] )
         PRINT, 'which  is  After  the 1st data time: '   $
              + STRING( FORMAT='( C() )', TIME[0] ) + ' of the New data.'
      ENDIF
      STATUS   = 'Not OK'
   ENDELSE
ENDIF  ELSE  BEGIN  ; IDL_FILE does not exist.
;  Assumming it is the 1st time.
   IRIS_TIME   =  TIME[0:N_IRIS_CNT-1]
   IRIS_TEMP   =  TEMP[0:N_IRIS_CNT-1]
   IRIS_XTILT  = XTILT[0:N_IRIS_CNT-1]
   IRIS_YTILT  = YTILT[0:N_IRIS_CNT-1]
ENDELSE
;
; Save the Updated cumulative data if the STATUS is OK.
; Otherwise, only the new data will be saved into the
; IDL Save File: FILE_ID + '.idl' because, the 1st date & time in the
; new data is out of order with the last cumulative date & time.
;
IF STATUS EQ 'OK' THEN  BEGIN
;  Save the updated arrays into a temporary file 1st then replace the
;  indicated file by the temporary file.  In this way if write to an IDL
;  save file caused a problem, hopefully the 2nd around the problem will
;  be solved by itself. 
   FILE = IDL_FILE + 'save'  ; for a temporary file.
   SAVE, FILENAME=FILE, IRIS_TIME, IRIS_XTILT, IRIS_YTILT, IRIS_TEMP
   FILE_MOVE, FILE, IDL_FILE, /OVERWRITE
   PRINT, SYSTIME() + ' IDL Save File: ' + IDL_FILE + ' is updated.'
;  Replace the lastest TILT data by the cumulative data
;  before returning to the caller.
;   TIME = TEMPORARY( IRIS_TIME  )
;  XTILT = TEMPORARY( IRIS_XTILT )
;  YTILT = TEMPORARY( IRIS_YTILT )
;   TEMP = TEMPORARY( IRIS_TEMP  )
ENDIF  ELSE  BEGIN  ; STATUS == 'Not OK'
;  If the IRIS_TIME[N-1] = TIME[N_IRIS_CNT-1], it is assumed that Retrieved
;  data are already in the IRIS arrays.  So No need to save the Retrieved
;  data into a new file.
   IF ( IRIS_TIME[N-1] - TIME[N_IRIS_CNT-1] ) NE 0.0 THEN  BEGIN
   ;  Save only the newly received data into a different IDL save file name.
      FILE = FILE_ID + '.idl'
      SAVE, FILENAME=FILE, TIME, XTILT, YTILT, TEMP, N_IRIS_CNT
      PRINT, SYSTIME() + ' New IDL Save File: ' + FILE + ' is created.'
   ENDIF
ENDELSE
;
RETURN
END  ; SAVE_IRIS_DATA
;
; This procedure will get the last saved cumulative LILY sensor  data,
; add the retrieved new data.  Then save the updated cumulative values
; back to the IDL Save File.
;
; Callers: PROCESS_RSN_DATA or users
; Revised: January  16th, 2015
;
PRO SAVE_LILY_DATA, IDL_FILE,  $ ;  Input: IDL Save File name.
                  N_LILY_CNT,  $ ;  Input: Total points for the new data.
                     FILE_ID,  $ ;  Input: Name from the RSN data file.
                      STATUS,  $ ; Output: 'OK' or 'Not OK'
         GET_SELECTED_INDEX=I    ; Output: Start Index where the data
;        the COMMON LILY's arrays are the new data begin.  For example,
;        [X&Y]TILT[I:N_LILY_CNT-1] appended to the LILY_[X&Y]TILT arrays.
;                                           
COMMON LILY, TIME, XTILT, YTILT, RTM,     TEMP, RTD,     N_LILY
;
; Note that the arrays: RTM & RTD were originally called
; COMPASS & VOLTAGE respectively.  Since the COMPASS & VOLTAGE are not
; being used, they were replaced by the RTM & RTD values in the
; procedure: COMPUTE_LILY_RTMD.
;
FILE   = FILE_INFO( IDL_FILE )  ; Get the IDL Save File's information.
STATUS = 'OK'                   ; Assume it is OK to start.
;  
IF FILE.EXISTS THEN  BEGIN
   RESTORE, IDL_FILE  ; Retrieve the past LILY data
;  The Variables in IDL_FILE are assumed to be 
;  LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_TEMP, LILY_RTM, LILY_RTD
   N = N_ELEMENTS( LILY_TIME )
   PRINT, SYSTIME() + ' In SAVE_LILY_DATA,'
   IF LILY_TIME[N-1] LT TIME[0] THEN BEGIN  ; Time sequency is OK.
      I = 0
      PRINT, 'Appending New Data'
      LILY_TIME   = [ TEMPORARY( LILY_TIME  ),  TIME[0:N_LILY_CNT-1] ]
      LILY_XTILT  = [ TEMPORARY( LILY_XTILT ), XTILT[0:N_LILY_CNT-1] ]
      LILY_YTILT  = [ TEMPORARY( LILY_YTILT ), YTILT[0:N_LILY_CNT-1] ]
      LILY_RTM    = [ TEMPORARY( LILY_RTM   ),   RTM[0:N_LILY_CNT-1] ]
      LILY_TEMP   = [ TEMPORARY( LILY_TEMP  ),  TEMP[0:N_LILY_CNT-1] ]
      LILY_RTD    = [ TEMPORARY( LILY_RTD   ),   RTD[0:N_LILY_CNT-1] ]
   ENDIF ELSE IF LILY_TIME[N-1] LT TIME[N_LILY_CNT-1] THEN  BEGIN
;     TIME[0] <= LILY_TIME[N-1] <  TIME[N_LILY_CNT-1] Times Overlap.
;     Locate the Index: I so that TIME[I-1] <= LILY_TIME[N-1] < TIME[I]. 
;     The Function: LOCATE_TIME_POSITION is in the file: SplitRSNdata.pro
      I = LOCATE_TIME_POSITION( TIME, LILY_TIME[N-1] )
      PRINT, 'The Time Sequence is Overlapping at '  $
           + STRING( FORMAT='(2(C(),X))', TIME[I-1], LILY_TIME[N-1]  )
;     Discard the all the values before I,     i.e., all the data
;     in [0:I-1] of the TIME, TEMP, etc. arrays will be discarded.
      LILY_TIME   = [ TEMPORARY( LILY_TIME   ),  TIME[I:N_LILY_CNT-1] ]
      LILY_XTILT  = [ TEMPORARY( LILY_XTILT  ), XTILT[I:N_LILY_CNT-1] ]
      LILY_YTILT  = [ TEMPORARY( LILY_YTILT  ), YTILT[I:N_LILY_CNT-1] ]
      LILY_RTM    = [ TEMPORARY( LILY_RTM   ),    RTM[I:N_LILY_CNT-1] ]
      LILY_TEMP   = [ TEMPORARY( LILY_TEMP   ),  TEMP[I:N_LILY_CNT-1] ]
      LILY_RTD    = [ TEMPORARY( LILY_RTD   ),    RTD[I:N_LILY_CNT-1] ]
   ENDIF  ELSE  BEGIN
      I = -1  ; Indicates No data are added to the LILY_* arrays.
      IF LILY_TIME[N-1] GE TIME[0] THEN  BEGIN  ; Times Out of Order.
         PRINT, 'The Time Sequency is Out of Order!'
         PRINT, 'The Last Time of the stored data is: '   $
              + STRING( FORMAT='( C() )', LILY_TIME[N-1] )
         PRINT, 'which  is  After  the 1st data time: '   $
              + STRING( FORMAT='( C() )', TIME[0] ) + ' of the New data.'
      ENDIF
      STATUS   = 'Not OK'
   ENDELSE
ENDIF  ELSE  BEGIN  ; IDL_FILE does not exist.
;  Assumming it is the 1st time.
   I = 0
   LILY_TIME   =  TIME[0:N_LILY_CNT-1]
   LILY_XTILT  = XTILT[0:N_LILY_CNT-1]
   LILY_YTILT  = YTILT[0:N_LILY_CNT-1]
   LILY_RTM    =   RTM[0:N_LILY_CNT-1]
   LILY_TEMP   =  TEMP[0:N_LILY_CNT-1]
   LILY_RTD    =   RTD[0:N_LILY_CNT-1]
ENDELSE
;
; Save the Updated cumulative data if the STATUS is OK.
; Otherwise, only the new data will be saved into the
; IDL Save File: FILE_ID + '.idl' because, the 1st date & time in the
; new data is out of order with the last cumulative date & time.
;
IF STATUS EQ 'OK' THEN  BEGIN
;  Save the updated arrays into a temporary file 1st then replace the
;  indicated file by the temporary file.  In this way if write to an IDL
;  save file caused a problem, hopefully the 2nd around the problem will
;  be solved by itself. 
   FILE = IDL_FILE + 'save'  ; for a temporary file.
   SAVE, FILENAME=FILE, LILY_TIME, LILY_XTILT, LILY_YTILT, $
                        LILY_RTM,  LILY_TEMP,  LILY_RTD
   FILE_MOVE, FILE, IDL_FILE, /OVERWRITE
   PRINT, SYSTIME() + ' IDL Save File: ' + IDL_FILE + ' is updated.'
;  Replace the lastest TILT data by the cumulative data
;  before returning to the caller.
;     TIME = TEMPORARY( LILY_TIME    )
;    XTILT = TEMPORARY( LILY_XTILT   )
;    YTILT = TEMPORARY( LILY_YTILT   )
;     TEMP = TEMPORARY( LILY_TEMP,   )
;      RTM = TEMPORARY( LILY_RTM     )
;      RTD = TEMPORARY( LILY_RTD     )
ENDIF  ELSE  BEGIN  ; STATUS == 'Not OK'
;  If the LILY_TIME[N-1] = TIME[N_LILY_CNT-1], it is assumed that Retrieved
;  data are already in the LILY arrays.  So No need to save the Retrieved
;  data into a new file.
   IF ( LILY_TIME[N-1] - TIME[N_LILY_CNT-1] ) NE 0.0 THEN  BEGIN
;     Save only the newly received data into a different IDL save file name.
      FILE = FILE_ID + '.idl'
      SAVE, FILENAME=FILE, TIME, XTILT, YTILT, RTM, TEMP, RTD, N_LILY_CNT
      PRINT, SYSTIME() + ' New IDL Save File: ' + FILE + ' is created.'
   ENDIF
ENDELSE
;
RETURN
END  ; SAVE_LILY_DATA
;
; This procedure will get the last saved cumulative Nano-pressure data,
; add the retrieved new data.  Then save the updated cumulative values
; back to the IDL Save File.
;
; Callers: PROCESS_RSN_DATA or users
; Revised: January 16th, 2015
;
PRO SAVE_NANO_DATA, IDL_FILE,  $ ;  Input: IDL Save File name.
                  N_NANO_CNT,  $ ;  Input: Total points for the new data.
                     FILE_ID,  $ ;  Input: Name from the RSN data file.
                      STATUS     ; Output: 'OK' or 'Not OK'
;
COMMON NANO,    TIME, PSIA, TEMP, N_NANO
COMMON DETIDE,  METER ; for storing the de-tided press data in meters.
;                     ; Note COMMON DETIDE is defined in PRO DETIDE_NANO_DATA
;
; N_NANO_CNT indicates Total data points stored in All the
; arrays: TIME, PSIA, TEMP and METER.
;
FILE   = FILE_INFO( IDL_FILE )  ; Get the IDL Save File's information.
STATUS = 'OK'                   ; Assuming it will be OK to start. 
;  
IF FILE.EXISTS THEN  BEGIN
   RESTORE, IDL_FILE  ; Retrieve the past NANO data
;  The  Variables in IDL_FILE are assumed to be
;  NANO_TIME, NANO_PSIA, NANO_DETIDE and NANO_TEMP
   N = N_ELEMENTS( NANO_TIME )
   IF NANO_TIME[N-1] LT TIME[0] THEN BEGIN  ; Time sequency is OK.
      PRINT, 'Appending New Data'
      NANO_TIME   = [ TEMPORARY( NANO_TIME   ),  TIME[0:N_NANO_CNT-1] ]
      NANO_PSIA   = [ TEMPORARY( NANO_PSIA   ),  PSIA[0:N_NANO_CNT-1] ]
      NANO_DETIDE = [ TEMPORARY( NANO_DETIDE ), METER[0:N_NANO_CNT-1] ]
      NANO_TEMP   = [ TEMPORARY( NANO_TEMP   ),  TEMP[0:N_NANO_CNT-1] ]
   ENDIF ELSE IF NANO_TIME[N-1] LT TIME[N_NANO_CNT-1] THEN  BEGIN
;     TIME[0] <= NANO_TIME[N-1] <  TIME[N_NANO_CNT-1] Times Overlap.
;     Locate the Index: I so that TIME[I-1] <= NANO_TIME[N-1] < TIME[I]. 
;     The Function: LOCATE_TIME_POSITION is in the file: SplitRSNdata.pro
      I = LOCATE_TIME_POSITION( TIME, NANO_TIME[N-1] )
      PRINT, SYSTIME() + ' In SAVE_NANO_DATA,'
      PRINT, 'The Time Sequence is Overlapping at '  $
           + STRING( FORMAT='(2(C(),X))', TIME[I-1], NANO_TIME[N-1]  )
;     Discard the all the values before I,     i.e., all the data
;     in [0:I-1] of the TIME, TEMP, etc. arrays will be discarded.
      NANO_TIME   = [ TEMPORARY( NANO_TIME   ),  TIME[I:N_NANO_CNT-1] ]
      NANO_PSIA   = [ TEMPORARY( NANO_PSIA   ),  PSIA[I:N_NANO_CNT-1] ]
      NANO_DETIDE = [ TEMPORARY( NANO_DETIDE ), METER[I:N_NANO_CNT-1] ]
      NANO_TEMP   = [ TEMPORARY( NANO_TEMP   ),  TEMP[I:N_NANO_CNT-1] ]
   ENDIF  ELSE  BEGIN
      IF NANO_TIME[N-1] GE TIME[0] THEN  BEGIN  ; Times Out of Order.
         PRINT, SYSTIME() + ' In SAVE_NANO_DATA,'
         PRINT, 'The Time Sequency is Out of Order!'
         PRINT, 'The Last Time of the stored data is: '   $
              + STRING( FORMAT='( C() )', NANO_TIME[N-1] )
         PRINT, 'which  is  After  the 1st data time: '   $
              + STRING( FORMAT='( C() )', TIME[0] ) + ' of the New data.'
      ENDIF
      STATUS   = 'Not OK'
   ENDELSE
ENDIF  ELSE  BEGIN  ; IDL_FILE does not exist.
;  Assumming it is the 1st time.
   NANO_TIME   =  TIME[0:N_NANO_CNT-1]
   NANO_PSIA   =  PSIA[0:N_NANO_CNT-1]
   NANO_DETIDE = METER[0:N_NANO_CNT-1]
   NANO_TEMP   =  TEMP[0:N_NANO_CNT-1]
ENDELSE
;
; Save the Updated cumulative data if the STATUS is OK.
; Otherwise, only the new data will be saved into the
; IDL Save File: FILE_ID + '.idl' because, the 1st date & time in the
; new data is out of order with the last cumulative date & time.
;
IF STATUS EQ 'OK' THEN  BEGIN
;  Save the updated arrays into a temporary file 1st then replace the
;  indicated file by the temporary file.  In this way if write to an IDL
;  save file caused a problem, hopefully the 2nd around the problem will
;  be solved by itself. 
   FILE = IDL_FILE + 'save'  ; for a temporary file.
   SAVE, FILENAME=FILE, NANO_TIME, NANO_PSIA, NANO_DETIDE, NANO_TEMP
   FILE_MOVE, FILE, IDL_FILE, /OVERWRITE
   PRINT, SYSTIME() + ' IDL Save File: ' + IDL_FILE + ' is updated.'
;  Replace the data in the COMMON Block by the cumulative data
;  before returning to the caller.
;  TIME  = TEMPORARY( NANO_TIME  )
;  PSIA  = TEMPORARY( NANO_PSIA  )
;  TEMP  = TEMPORARY( NANO_TEMP  )
ENDIF  ELSE  BEGIN  ; STATUS == 'Not OK'
;  If the NANO_TIME[N-1] = TIME[N_NANO_CNT-1], it is assumed that Retrieved
;  data are already in the NANO arrays.  So No need to save the Retrieved
;  data into a new file.
   IF ( NANO_TIME[N-1] - TIME[N_NANO_CNT-1] ) NE 0.0 THEN  BEGIN
;     Save only the newly received data into a different IDL save file name.
;     where FILE='~/4Chadwick/RSN/MJ03D/BOTPTA303NANO20Hz28Nov2014.idl', e.g.
      FILE = FILE_ID + '.idl'  
      SAVE, FILENAME=FILE, TIME, PSIA, TEMP, METER, N_NANO_CNT
      PRINT, SYSTIME() + ' New IDL Save File: ' + FILE + ' is created.'
   ENDIF
ENDELSE
;
RETURN
END  ; SAVE_NANO_DATA
;
; This procedure will check for unusual large psia values in the array: PSIA.
; If the large values are found, the avrage values of the 2 values: 1 before
; and 1 after the large value will be replace the large value.
;
; Callers: PROCESS_RSN_DATA or users
; Revised: December 4th, 2017
;  
PRO SPIKE_CHECK4NANO_DATA, SPIKE_LOG_FILE,  $ ; Output File name.
              N_NANO_CNT ; Input: Total points for the new data.
;  
COMMON NANO,    TIME, PSIA, TEMP, N_NANO
COMMON DETIDE,  METER ; for storing the de-tided press data in meters.
;                     ; Note COMMON DETIDE is defined in PRO DETIDE_NANO_DATA
;
   PRINT, 'From SPIKE_CHECK4NANO_DATA:'
;
; Added the following check on December 4th, 2017.
;
IF N_NANO_CNT GT 2 THEN  BEGIN  ; Enought data for checkng spikes.
   PRINT, 'Spike values (if any) will be printed to ',  SPIKE_LOG_FILE
ENDIF  ELSE  BEGIN  ; N_NANO_CNT <= 2.  Not enought data for spike check.
   PRINT, 'Not enought data.  No Spikes checking will be done!'
   RETURN  ; to caller.
ENDELSE
;
; Note that OPENW, /APPEND is same as OPENU, /APPEND.
; But  OPENW, /APPEND for both UNIX and Windows environments.
;
; SPIKE_LOG_FILE = '~/4Chadwick/RSN/MJ03D/SpikesReplacements.MJ03D', e.g.
;
  OPENW, /GET_LUN, SPIKE_UNIT, SPIKE_LOG_FILE, /APPEND
;
; Use the Detided values in METERS from the 2nd to the 1 before the last
; data point to Check for Spikes.
;
FOR S = 1, N_NANO_CNT - 2 DO  BEGIN
    STD = ( TIME[S+1] - TIME[S-1] )*86400  ; Time difference in seconds.
    IF ROUND( STD ) EQ 30 THEN  BEGIN  ; No Time Gap.  OK to check for spike.
;      Compute the standard deviation and the mean of the values
;      from 1 before and 1 after the METER[S] value.
       STD = STDEV( METER[[S-1,S+1]], M )  ; M = the Mean.
;      IF METER[S] GT ( M + 20.0*STD ) THEN  BEGIN  ; METER[S] is a spike.
       IF METER[S] GT ( M + 0.050D0  ) THEN  BEGIN  ; METER[S] is a spike.
          PRINT, FORMAT='(A,C())', 'On ', TIME[S]
          PRINT, 'Replaced the Spike value: ' + STRTRIM( METER[S], 2 )  $
               + ' by the arevage: '          + STRTRIM( M, 2 )
          PRINTF, SPIKE_UNIT, FORMAT='(C(),A)', TIME[S],  $
          STRCOMPRESS( STRING( [ METER[S], M ], /PRINT ) )
          METER[S] = M  ; Replace the large (spike) value by the average.
;         Replace the corresponding PSIA[S] values by the means of its
           PSIA[S] = ( PSIA[S-1] + PSIA[S+1] )/2.0  ; 2 adjacent values.
       ENDIF  ; Checking Spike value.
    ENDIF  ; ROUND( STD ) EQ 30
ENDFOR  ; S
;
; Check the 1st the data point for a spike value.
;
; Note the reason the 1st data point is being check after the FOR loop above
; is that if the 2nd or the 3rd data point is spike, it will be take care of
; by the checking of the FOR loop above.
;
  S   = 0  ; 1st data point.
  STD = ( TIME[2] - TIME[0] )*86400  ; Time difference in seconds.
;
IF ROUND( STD ) EQ 30 THEN  BEGIN  ; No Time Gap.  OK to check for spike.
;  Get the standard deviation and the mean of the values
;  from the 2 values after the 1st data point.
   STD = STDEV( METER[1:2], M )  ; M = the Mean.
   IF METER[S] GT ( M + 0.050D0  ) THEN  BEGIN  ; METER[S] is a spike.
      PRINT, FORMAT='(A,C())', 'On ', TIME[S]
      PRINT, 'Replaced the Spike value: ' + STRTRIM( METER[S], 2 )  $
           + ' by the arevage: '          + STRTRIM( M, 2 )
      PRINTF, SPIKE_UNIT, FORMAT='(C(),A)', TIME[S],  $
      STRCOMPRESS( STRING( [ METER[S], M ], /PRINT ) )
      METER[S] = M  ; Replace the large (spike) value by the average.
;     Replace the corresponding PSIA[S] values by the
       PSIA[S] = ( PSIA[0] + PSIA[1] )/2.0  ; mean of the next 2 values.
   ENDIF  ; Checking Spike value.
ENDIF  ; ROUND( STD ) EQ 30
;
; Check the last the data point for a spike value.
;
  S   = N_NANO_CNT - 1  ; Index for the last data point.
  STD = ( TIME[S] - TIME[S-2] )*86400  ; Time difference in seconds.
;
IF ROUND( STD ) EQ 30 THEN  BEGIN  ; No Time Gap.  OK to check for spike.
;  Get the standard deviation and the mean of the values
;  from the 2 values befor the last data point.
   STD = STDEV( METER[S-2:S-1], M )  ; M = the Mean.
   IF METER[S] GT ( M + 0.050D0  ) THEN  BEGIN  ; METER[S] is a spike.
      PRINT, FORMAT='(A,C())', 'On ', TIME[S]
      PRINT, 'Replaced the Spike value: ' + STRTRIM( METER[S], 2 )  $
           + ' by the arevage: '          + STRTRIM(      M , 2 )
      PRINTF, SPIKE_UNIT, FORMAT='(C(),A)', TIME[S],  $
      STRCOMPRESS( STRING( [ METER[S], M ], /PRINT ) )
      METER[S] = M  ; Replace the large (spike) value by the average.
;     Replace the corresponding PSIA[S] values by the  mean of
       PSIA[S] = ( PSIA[S-2] + PSIA[S-1] )/2.0  ; the 2 values before.
   ENDIF  ; Checking Spike value.
ENDIF  ; ROUND( STD ) EQ 30
;
   CLOSE, SPIKE_UNIT  ; Close the output file.
FREE_LUN, SPIKE_UNIT
;
RETURN
END  ; SPIKE_CHECK4NANO_DATA
;
; This procedure will resample the NANO data stored in the arrays of the
; COMMON Block: NANO by selecting every 15th point, i.e. every 15th seconds,
; in the order of 0,15,30,45, 0,15,30,45, ...etc.
; Then store the resampled data back to the the arrays into the
; COMMON Block: NANO
;
; Callers: PROCESS_RSN_DATA or users
;
PRO SUBSAMPLE_NANO_DATA, IDL_FILE,  $ ;  Input: IDL Save File name.
                       N_NANO_CNT,  $ ;  I / O: Total points for the new data.
                         STATUS       ; Output: 'NANO at ...' or 'No NANO ...'
;
COMMON NANO, TIME, PSIA, TEMP, N_NANO
;
; Retrieve all the values of seconds in the array: TIME
;
  S = STRING( FORMAT='(C(CSF))', TIME[0:N_NANO_CNT-1] )
;
; Convert the values from string into floating point numbers.
;
  S = FLOAT( TEMPORARY( S ) )
;
; Set all the seconds in 0, 15, 30 & 45 into zeros.
;
  M = S MOD 15
;
; Locate all the zeros positions which will be all the positions
; of 0's, 15's, 30's, 45's.
;
  Z = WHERE( M EQ 0, N )  ; N = total elements in Z
;
  STATUS = 'Time Gaps'  ; Assume there are time gaps.
;
IF N GT 2 THEN  BEGIN
   MX = MAX( Z[1:N-1] - Z[0:N-2], MIN=MN )
   IF ( MX EQ 15 ) AND ( MN EQ 15 ) THEN  BEGIN
;     All the seconds at [0,15,30,45] are found.
;     Store the values at those times.
      T    = TIME[Z]
      TIME = TEMPORARY( T )
      T    = PSIA[Z]
      PSIA = TEMPORARY( T )
      T    = TEMP[Z]
      TEMP = TEMPORARY( T )
    N_NANO = N
    STATUS = 'NANO at every 15th seconds'
   ENDIF
ENDIF
;
; At this point if the NONA data have not been resampled,
; assuming there are Time Gaps.  Then Check every Time-Stamp to
; select the seconds at [0,15,30,45] or select the one at their
; neighborhood one, e.g. [0+/-1, 15+/-1, 30+/-1, 45+/-1].
;
IF STATUS EQ 'Time Gaps' THEN  BEGIN
   T = S[0] LE [0,15,30,45]
   I = WHERE( T EQ 1, MN )
   IF MN EQ 0 THEN  BEGIN  ; 46 <= S[0] <=59
      SCD = 0              ; The next vaule to look for is 0.
   ENDIF  ELSE  BEGIN
      SCD = ([0,15,30,45])[I[0]]   ; = 0, 15, 30 or 45.
   ENDELSE
   T = REPLICATE( 0, N_NANO_CNT )  ; Get an index array of zeros.
        I  = 0
   IF S[I] EQ SCD THEN  BEGIN      ; Check out the second in the 1st index.
      T[I] = 1                     ; Mark the position.
      SCD  = ( SCD + 15 ) MOD 60   ; If SCD = 15, set it to 30. e.g.
   ENDIF
;  Select every 15th second data point.  If there are time gaps,
;  pick the neighborhood values within +/- 1 second.
   FOR  I = ULONG( 1 ), N_NANO_CNT - 1 DO  BEGIN
         IF S[I] EQ SCD THEN  BEGIN  ; S[I] = 0, 15, 30 or 45.
            T[I] = 1                    ; Mark the position.
            SCD  = ( SCD + 15 ) MOD 60  ; If SCD = 15, set SCD = 30. e.g.
         ENDIF ELSE IF ABS( S[I] - S[I-1] ) GT 1.0 THEN  BEGIN  ; Time Gap.
;           If the Time Gap is only +/- 1 second off, use the neighborhood
;           value.  E.G. If SCD = 45, use the second at either 44 or 46.
            IF SCD GT 0 THEN  BEGIN  ; SCD = 15, 30 or 45
               X = ABS( S[I-1] - SCD )
               Y = ABS( S[I]   - SCD )
            ENDIF  ELSE  BEGIN       ; SCD = 0
               X = ABS( S[I-1] - ( SCD + 60*( S[I-1] GT 45 ) ) )
               Y = ABS( S[I]   - ( SCD + 60*( S[I]   GT 45 ) ) )
            ENDELSE
;           PRINT, I, S[I-1], S[I], SCD, X, Y
            IF ( X GT 1.0 ) AND ( Y GT 1.0 ) THEN  BEGIN
;              Reset the SCD value based on the Current second: S[I].
               Y   = S[I] LE [0,15,30,45]
               X   = WHERE( Y EQ 1, MN )
               SCD = ( MN EQ 0 ) ? 0 : ([0,15,30,45])[X[0]] 
;              PRINT, ' SCD updated to ', SCD, MN
            ENDIF  ELSE  BEGIN  ; X <= 1 or Y <= 1.
               IF X LT Y THEN  BEGIN  ; |S[I-1] - SCD| < |S[I] - SCD| < 1
                  T[I-1] = 1  ; Use the  Last   position.
                  SCD  = ( SCD + 15 ) MOD 60  ; If SCD=45, set SCD =  0. e.g.
               ENDIF  ELSE  BEGIN     ; |S[I] - SCD| < |S[I-1] - SCD| < 1
                  T[I]   = 1  ; Use the current position.
                  SCD  = ( SCD + 15 ) MOD 60  ; If SCD=30, set SCD = 45. e.g.
               ENDELSE
            ENDELSE
         ENDIF
;        IF T[I] EQ 1 THEN  BEGIN
;           PRINT, FORMAT='(C(),1X,I5,I3,1X,F6.3)', TIME[I], I, SCD, S[I]
;        ENDIF
   ENDFOR  ; I
   I = WHERE( T EQ 1, MN )  ; Locate all the marked positions.
   IF MN LE 0 THEN  BEGIN   ; No times at [0,15,30,45] are found.
    N_NANO = 0
    STATUS = 'No NANO at every 15th seconds are found'
   ENDIF  ELSE  BEGIN  ; MN > 0.  Save the resampled data.
      T    = TIME[I]
      TIME = TEMPORARY( T )
      T    = PSIA[I]
      PSIA = TEMPORARY( T )
      T    = TEMP[I]
      TEMP = TEMPORARY( T )
    N_NANO = MN
    STATUS = 'NANO at every 15th seconds with Time Gaps'
   ENDELSE
ENDIF
;
N_NANO_CNT = N_NANO  ; Update the total resampled data.
;
RETURN
END  ; SUBSAMPLE_NANO_DATA