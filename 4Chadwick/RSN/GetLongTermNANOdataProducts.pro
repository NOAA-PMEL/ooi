;
; File: GetLongTermNANOdataProducts.pro
;
; This  IDL program will use the data in the IDL Save file: MJ03?-NANO.idl
; to get the 1-Day mean and save it into the MJ03?-NANO1DayMeans.idl
; where it contains the past 56 or 84 1-Day means.  They will be used for
; getting the Average Linear Rate of Depth Change from the past
; 28 days (4 weeks) and the past 56 days ( 8 weeks)
;  Or
; 56 days (8 weeks) and the past 84 days (12 weeks).
;
; The results: the most recent 1-Day mean, the Average Linear Rate of
; Depth Changes for the 28 & 56 days will be printed out to the output
; file: LongTermNANOdataProducts.MJ03?   where '?' = 'B', 'D', 'E' or 'F'.
;
; Note that this program require the routines in the file: SplitRSNdata.pro
; in order to work.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on January   26th, 2018
; Created on November  12th, 2014
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
; The procedure will use the specified time ranges to retrieve
; 2 indexes: I & N so that [I:N] will indicate the data range
; as specified by the callers.
;
; Callers: GET1DAY_MEANS2START, GET_NANO_DATA_PRODUCTS, or Users
; Revised: June  10th, 2015
;
PRO GET_DATA_RANGE_INDEXES,  TIME, $  ; Input: 1-D array of Time.
        START_TIME, END_TIME,  $ ; Inputs: in JULDAY() values
        S,          N,      $  ;  Outputs: Indexes in integers.
        D                      ;  Output : Status: D == 1 means OK.
;
; Define the shorter NANO arrays' variable names in the COMMON NANO.
;
; COMMON NANO,      TIME, PSIA, DETIDE, TEMP      ; names' w/o the "NANO_".
;
; Get the size of the NANO's arrays.  All arrays are the same size.
;
; N_NANO = N_ELEMENTS( TIME )  ;
;
  PRINT, 'In GET_DATA_RANGE_INDEXES,  Searching for the'
  PRINT, FORMAT='(A,X,C())', 'Start Time:', START_TIME
  PRINT, FORMAT='(A,X,C())', '  End Time:',   END_TIME
;
; Get the TIME indexes.  Note that the returned index, e.g. N,
; indicates the following: TIME[N-1] <= START_TIME < TIME[N];
; therefore, the returned indexes need to be offset by -1.
;
; Note that the function: LOCATE_TIME_POSITION is located in the
; file: SplitRSNdata.pro
;
  S = LOCATE_TIME_POSITION( TIME, START_TIME ) - 1
  N = LOCATE_TIME_POSITION( TIME,   END_TIME ) - 1
;
; If N = N_NANO, then TIME[N_NANO-1] < END_TIME.  Since N is already
; offset by -1 above, then will be no more adjustment.
; If S < 0, then START_TIME < TIME[0].  When this happen, set S = 0.
;
  S = ( S LT 0 ) ? 0 : S
;
  PRINT, 'Located the Indexes: ' + STRING( STRTRIM( [S,N], 2 ), /PRINT)
  PRINT, FORMAT="(A,C(),', ',C())", ' & Times are: ', TIME[[S,N]]
;
; When the indexes: S = N, there are data gaps.
; Adjust the indexes: I & N so that the following condition will hold:
; TIME[S] < START_TIME < END_TIME < TIME[N].
;
; IF S EQ N THEN  BEGIN  ; The [START_TIME,END_TIME] range are missing.
;    IF TIME[N] LT   END_TIME THEN  BEGIN
;       IF TIME[N+1] GT END_TIME THEN  N += 1
;    ENDIF
; ENDIF  ; Adjust the indexe: N
;
; Check for the Time Gaps.
; Note the NANO TIME are 4 points point per second.
; So that there will be 5760 - 1 points per day.
;
IF S EQ N THEN  BEGIN  ; The [START_TIME,END_TIME] range are missing.
   D =  0    ; No data points.
ENDIF  ELSE  BEGIN
   T = ( END_TIME - START_TIME )*5760  ; Total data points within the range.
   M = ( N - S + 1 )  ; Total data points from the within the indexes: I & N.
   D = DOUBLE( M )/T  ; D = 0 or < 1, means there are data gaps.
ENDELSE
;
IF D EQ 0 THEN  BEGIN ; Time gap: the [START_TIME,END_TIME] range.
   PRINT, 'Data Gap.  Start & End Times cannot be found!'
ENDIF ELSE IF D LT 1.0 THEN  BEGIN  ; Time gap.
   PRINT, 'Not All the data within the Start & End Times cannot be found!'
   PRINT, 'Only ' + STRTRIM( D*100, 2 ) + '% of Data points are found.'
;  i.e. D*100 = %-age of the Data within the [START_TIME,END_TIME] range.
ENDIF ELSE BEGIN  ; Assume D = 1 means [START_TIME,END_TIME] range are found.
;  Note that D will not be = 1 exactly (most likely = 1.0001736 )
;  due to the START_TIME & END_TIME  counting.  Set D = 1.
   D = 1
ENDELSE
;
RETURN
END  ; GET_DATA_RANGE_INDEXES
;
; Callers: Users.
; Revised: August  20th, 2018
;
PRO GET1DAY_MEANS4NANO  ; Name changed (added 4NANO) on October 25th, 2017
;
; Define the shorter NANO arrays' variable names in the COMMON NANO.
; Note the arrays: NANO_PSIA & NANO_TEMP will not be be used here.
;
  COMMON NANO,      NANO_TIME, NANO_PSIA, NANO_DETIDE, NANO_TEMP
  COMMON NANO1DAYM, NANO1DAY_MEAN, NANO1DAY_TIME  ; For computed 1-Day means.
;
; Get the arrays' sizes and All the arrays in the COMMON NANO
; are the same sizes.
;
  M = N_ELEMENTS( TIME )           ; = N_ELEMENTS( DETIDE )
  N = N_ELEMENTS( NANO1DAY_MEAN )  ; = N_ELEMENTS( NANO1DAY_TIME )
;
; Get the most recent Date: Month, Day & Year from the last
; value in the array: NANO_TIME.
;
          MTIME = NANO1DAY_TIME[N-1] + 1
  CALDAT, MTIME, T, D, Y 
; CALDAT, NANO_TIME[M-1], T, D, Y 
;
  ETIME = JULDAY( T, D, Y, 23, 59, 45 )  ; and the End times.
;
IF NANO_TIME[M-1] LT ETIME THEN  BEGIN  ; New Day is not ready yet.
   PRINT, 'A New Day is Not ready yet!  '
   PRINT, 'No Long-Term data products will be computed!'
ENDIF  ELSE  BEGIN  ; A New Day is ready.
   N_DAYS = NANO_TIME[M-1] - NANO1DAY_TIME[N-1]
;  S      = LONG( 1 )
   FOR S = 1 ,  N_DAYS   DO  BEGIN
         CALDAT, MTIME,  T, D, Y 
         STIME = JULDAY( T, D, Y, 00, 00, 00 )  ; Define the Start
         ETIME = JULDAY( T, D, Y, 23, 59, 45 )  ; and the End times.
;        Get the indexes: [I,J] so that TIME[I:J] will contain the 1-Day long.
         GET_DATA_RANGE_INDEXES,   NANO_TIME, $ ; Time that contain the STIME & ETIME.
                                 STIME,ETIME, $ ; use the Start & End Times
                                 I,    J,     $ ; to the indexes: I,J
                                 STATUS         ; STATUS = 1 means OK.
;        GET_DATA_RANGE_INDEXES, STIME,ETIME, $ ; use the Start & End Times
;                                I,    J,     $ ; to the indexes: I,J
;                                STATUS         ; STATUS = 1 means OK.
         IF STATUS EQ 1 THEN  BEGIN  ; Data range in [STIME,ETIME] are found.
            M1DAY = MEAN( DETIDE[I:J], /DOUBLE )
            SAVE_NEW1DAY_MEAN, M1DAY, MTIME
         ENDIF
;        S     += 1  ; Move to one position before.  <-- August 20th, 2018.
         MTIME += 1  ; Move to the day before.
   ENDFOR    ; S
ENDELSE
;
RETURN
END  ; GET1DAY_MEANS4NANO
;
; This procedure May Not be Used!
;
; The procedure will be using the provided the NANO DETIDE data
; and compute the numbers of the 1-Day means and their respective
; Times into two 1-D arrays.
;
; This procedure will be used to establish the initial 1-day means
; for the Long-Term NANO data products calculations.
;
; Callers: Users.
; Revised: August  10th, 2018
;
PRO GET1DAY_MEANS2START,  $
            N_DAYS,       $ ; Input : Number of 1-Day means to compute.
            MTH,DAY,YR      ; Inputs: Month,Day,Year of the Recent Date.
;
; Define the NANO arrays' variable names in the COMMON NANO.
; Note the ony the arrays: NANO_TIME will be be used here..
;
  COMMON NANO,      NANO_TIME, NANO_PSIA, NANO_DETIDE, NANO_TEMP
  COMMON NANO1DAYM, NANO1DAY_MEAN, NANO1DAY_TIME  ; For computed 1-Day means.
;
; Get the arrays' sizes and All the arrays in the COMMON NANO
; are the same sizes.
;
; M = N_ELEMENTS( TIME )           ; = N_ELEMENTS( DETIDE )
; N = N_ELEMENTS( NANO1DAY_MEAN )  ; = N_ELEMENTS( NANO1DAY_TIME )
;
; Define the Julian Day for the most recent 1-Day Mean .
;
  MTIME = JULDAY( MTH,DAY,YR, 12, 0, 0 ) 
; K     =   LONG( 0 )           ; for counting the missing days that has no 1-Day mean.
  S     =   LONG( N_DAYS - 1 )  ; Index for the arrays in the COMMON NANO1DAYM.
;
; Define 3 integers' variables for storing Month, Day and Year.
;
  M = 12
  D = 31
  Y = 2014  ; e.g.
;
; Compute each of the 1-Day mean using DETIDE data
; from the START_DAY moving backward.
;
  CONTINUE = BYTE( 1 )  ; Yes for the WHILE loop.
;
WHILE ( S GE 0 ) AND CONTINUE DO  BEGIN
      CALDAT, MTIME,  M, D, Y  ; Get the Month, Day and Year values.
      STIME = JULDAY( M, D, Y, 00, 00, 00 )  ; Define the Start
      ETIME = JULDAY( M, D, Y, 23, 59, 45 )  ; and the End times.
      GET_DATA_RANGE_INDEXES,   NANO_TIME, $ ; Time that contain the STIME & ETIME.
                              STIME,ETIME, $ ; use the Start & End Times
                              I,    J,     $ ; to the indexes: I,J
                              STATUS         ; STATUS = 1 means OK.
;     IF STATUS EQ  1  THEN  BEGIN  ; Data range in [STIME,ETIME] are found.
      IF STATUS GT 0.5 THEN  BEGIN  ; Data range in [STIME,ETIME] are found. 8/10/2018
                            M1DAY = MEAN( NANO_DETIDE[I:J], /DOUBLE )
         NANO1DAY_MEAN[S] = M1DAY
         NANO1DAY_TIME[S] = MTIME
;        K   = 0  ; Clear the marker in case it was set.
         S  -= 1  ; Move to one position before.
      ENDIF
      MTIME -= 1  ; Move to the day before.
      CONTINUE = ( NANO_TIME[0] LT MTIME )
ENDWHILE  ; S
;
RETURN
END  ; GET1DAY_MEANS2START
;
; This is a main routine to compute the Long-Term Data Products:
; the Rates of Depths Changes if the data are avaiable.
; After the Rates of Depths Changes are calculated, they will be
; displayed into a graphic file.
;
; Callers: Users.
; Revised: January    28th, 2018
;
PRO GET_NANO_DATA_PRODUCTS, NANO_FILE,  $ ; Input: IDL Save File name.
                       NANO1DAYM_FILE     ; Input: IDL Save File name.
;
; Define the shorter NANO arrays' variable names in the COMMON NANO.
; Note the arrays: NANO_PSIA & NANO_TEMP will not be be used here.
;
  COMMON NANO,      NANO_TIME, NANO_PSIA, NANO_DETIDE, NANO_TEMP
  COMMON NANO1DAYM, NANO1DAY_MEAN, NANO1DAY_TIME  ; For the 1-Day means.
;
; Get the RSN's site ID = 'MJ03D', 'MJ03E' or 'MJ03F'
; from the NANO_FILE & NANO1DAYM_FILE. 
;
  N  = STRLEN( NANO_FILE )
  ID = STRMID( NANO_FILE,   N-14, 5 )  ; = 'MJ03D' e.g.
   D = STRMID( NANO1DAYM_FILE, 0, 5 )
;
IF ID NE D THEN  BEGIN
   PRINT, 'File: ' + NANO_FILE
   PRINT, 'File: ' + NANO1DAYM_FILE
   PRINT, 'Do Not have the Same RSN site ID: ' + ID + ' Not = ' + D + ' !'
   PRINT, 'No Long-Term data products will be computed.'
   RETURN  ; to Caller
ENDIF
;
; Retrieve the NANO arrays' variablesr for the COMMON NANO.
; from the NANO_FILE = 'MJ03D-NANO.idl' for example.
;
  RESTORE, NANO_FILE
;
; Retrieve the arrays' variables: NANO1DAY_MEAN & NANO1DAY_TIME
; from the NANO1DAYM_FILE = 'MJ03D-NANO1DayMeans.idl' for example.
;
  RESTORE, NANO1DAYM_FILE
;
; Get the arrays' sizes and All the arrays in the COMMON NANO
; are the same sizes.
;
  T = N_ELEMENTS( NANO_TIME )      ; = N_ELEMENTS( NANO_DETIDE   )
  N = N_ELEMENTS( NANO1DAY_MEAN )  ; = N_ELEMENTS( NANO1DAY_TIME )
;
; Get the most recent Date: Month, Day & Year from the last
; value in the array: NANO_TIME.
;
          MTIME = ABS( NANO1DAY_TIME[N-1] ) + 1  ; April 27th, 2015
  CALDAT, MTIME,  M, D, YR
;
  ETIME = JULDAY( M, D, YR, 23, 59, 45 )  ; and the End times.
;
  PRINT, FORMAT='(A,C())', 'Last Date of the 1-Day Mean: ', MTIME, $
                           'Looking for the next Date on ', ETIME
;
IF NANO_TIME[T-1] LT ETIME THEN  BEGIN  ; New Day is not ready yet.
   PRINT, 'A New Day is Not ready yet!  '
   PRINT, 'No Long-Term data products will be computed!'
ENDIF  ELSE  BEGIN  ; A New Day is ready.
;  Locate where are the correct times in NANO1DAY_TIME which the
;  JULDAY()'s values will be > 0.  April 27th, 2015
   I = WHERE( NANO1DAY_TIME GT 0, M )
   K = M    ; Total number of days available in the NANO1DAY_TIME.
;  IF M LT N THEN  BEGIN  ; <-- This IF...ENDIF...ENDELSE statement is NOt needed. 7/21/2015
;     K =  M    ; Total number of days aviable in the NANO1DAY_TIME.
;  ENDIF  ELSE  BEGIN  ; M >= N = N_ELEMENTS( NANO1DAY_MEAN )
;     K = 28    ; Number of days in 4 weeks.
;  ENDELSE
;  Define the number of days for the Short-Term Rate Calculations.
;  Note that NWK_DAYS = 28 was used from 2014 till January 2018
;  and  the  NWK_DAYS = 56 has been used since January 2018. 
 ; NWK_DAYS =  28  ;  Number of days in 4 weeks and the Long-Term Rate will be  8-week.
   NWK_DAYS =  56  ;  Number of days in 8 weeks and the Long-Term Rate will be 12-week.
;  Determine number of 1-Day means that need to be computed.
   N_DAYS = FLOOR( NANO_TIME[T-1] - ABS( NANO1DAY_TIME[N-1] ) )
   M_CNTS = FIX( 0 )  ; for counting number of 1-Day means that are computed.
   HELP, N_DAYS, M, D, YR, T, N, K
;  Start getting the 1-Day means.  Note that if there are data gaps
;  within that day, the mean and along with its associated Rate of Changes
;  calculations will be skipped.  In other words, the following FOR loop
;  may Not get all N_DAYS of the 1-Day means when there are data gaps.
   FOR S = 1 ,  N_DAYS   DO  BEGIN
         CALDAT, MTIME,  M, D, YR 
         STIME = JULDAY( M, D, YR, 00, 00, 00 )  ; Define the Start
         ETIME = JULDAY( M, D, YR, 23, 59, 45 )  ; and the End times.
;        Get the indexes: [I,J] so that TIME[I:J] will contain the 1-Day long.
         GET_DATA_RANGE_INDEXES,  NANO_TIME,  $ ; Time that contain the STIME & ETIME.
                               STIME, ETIME,  $ ; use the Start & End Times
                                   I,     J,  $ ; to the indexes: I,J
                               STATUS           ; STATUS = 1 means OK.
         IF STATUS GT 0.9 THEN  BEGIN  ; Have enough data to continue.
;        IF STATUS == 1, there are Full Data range in [STIME,ETIME].
;           Here the condition is 0.9 < STATUS <= 1.   
            M1DAY   = MEAN( NANO_DETIDE[I:J], /DOUBLE )  ; 1-Day Mean.
            M_CNTS += 1         ; Count one of 1-Day Mean is computed.
            SAVE_NEW1DAY_MEAN, M1DAY, MTIME
               K   += 1  ; Since 1 more 1-Day Mean has been added. 
;              Note that NWK_DAYS = 28 e.g. = Number of days in 4 weeks.
;              M = ( K LT 28 ) ? K : 28   ; i.e. If K > 28, Only 28 will be used.
               M = ( K LT NWK_DAYS ) ? K : NWK_DAYS  ; i.e. If K > NWK_DAYS, Only NWK_DAYS will be used.
               X = NANO1DAY_TIME[N-M:N-1] - NANO1DAY_TIME[N-M] ; in Days.
               Y = NANO1DAY_MEAN[N-M:N-1]   ; 1-Day Averaged Depthed.
               R = LINFIT( X, Y )  ; A Linear least-square fit method.
               RATE1 = -R[1]       ; Save the Slop as the Depth Change/Day.
            IF K GE N  THEN  BEGIN  ; K == N i.e. all data available for 8 or 12 weeks e.g.
               X = NANO1DAY_TIME - NANO1DAY_TIME[0]  ; in Days.
               Y = NANO1DAY_MEAN   ; 1-Day Averaged Depthed.
               R = LINFIT( X, Y )  ; where R = [A,B] as y = A + B*X.
            ENDIF ELSE IF ( NWK_DAYS LT K ) AND ( K LT N ) THEN  BEGIN
;              Here K will be NWK_DAYS < K < N always.
               X = NANO1DAY_TIME[N-K:N-1] - NANO1DAY_TIME[N-K] ; in Days.
               Y = NANO1DAY_MEAN[N-K:N-1]   ; 1-Day Averaged Depths.
               R = LINFIT( X, Y )  ; where R = [A,B] as y = A + B*X.
            ENDIF
            RATE2 = -R[1]       ; The uplift should > 0 if depths < 0.
;           Get the Total Days of the Current Year = 365 or 366.
            D = JULDAY( 12,31,YR ) - JULDAY( 1,0,YR )
;           R = 100*DOUBLE( D )       ; Conversion factor to cm/year.
;           Convert the Rate of Depth (meters) Change/Day into cm/year.
            RATE1 = RATE1*100.0*D     ; where 100 cm = 1 meter
            RATE2 = RATE2*100.0*D     ; and D = Total days/year = 365 or 366.
;           Save the Newly computed 1-Day Means
;           and  the 2 Rate of Changes' values.
            SAVE_NANO_DATA_PRODUCTS, ID, MTIME, M1DAY, RATE1, RATE2
         ENDIF
         MTIME += 1  ; Move to the day before.
   ENDFOR    ; S
   IF M_CNTS GT 0 THEN  BEGIN  ; At least one 1 -Day mean is computed.
;     Update the NANO 1-Day Mean Data File and Display the Long-Term Data.
      S = ( M_CNTS GT 1 ) ? ' are ' : ' is '
      R = 'Total ' + STRTRIM( M_CNTS, 2 ) + ' 1-Day Means' + S + 'computed.'
      PRINT, R
      UPDATE_NANO1DAYM_FILE,  NANO1DAYM_FILE
      PRINT, 'File: ' + NANO1DAYM_FILE + ' is updated.'
;     Generate the figure for the 1-Day Means and
;     the Least-Square Fit Lines of the 28 & 56 Days of the 1-Day Means.
;     Note that both PLOT_LTD4CHECKING and PLOT_LONGTERM_DATA procedures
;     are located in the file: PlotLongTermDataProducts.pro
      PLOT_LTD4CHECKING,  /UPDATE_PLOT, NANO_FILE, NANO1DAYM_FILE
;     Generate the figure for the 1-Day Means & Average Rates of Change Depths. 
      FILE = '~/4Chadwick/RSN/' + ID + PATH_SEP()  $
           + 'LongTermNANOdataProducts.' + ID
      IF NWK_DAYS EQ 56 THEN  BEGIN   ; Added on January 29th, 2018
         R = [8,12]  ; For 8- & 12-week rates.
      ENDIF  ELSE  BEGIN  ; Assume NWK_DAYS == 28
         R = [4, 8]  ; for 4- &  8-week rates in FILE.
      ENDELSE
      PLOT_LONGTERM_DATA, /UPDATE_PLOT, FILE, WEEK_TERM=R
   ENDIF
ENDELSE
;
RETURN
END  ; GET_NANO_DATA_PRODUCTS
;
; Callers: Users.
; Revised: December 2nd, 2014
;
PRO RETRIEVE_NANO_DATA_PRODUCTS, DATA_PRODUCTS_FILE,  $ ; Input: Name.
                                 DATA,    $ ; Output: 2-D array.
                                 STATUS,  $ ; Output:
         STRING_OUTPUT=OUTPUT_AS_STRING     ; DATA will be a 2-D string array.
;
; Locate the LONGTERM_DATA_FILE and make sure it exists.
;
   S = FILE_SEARCH( DATA_PRODUCTS_FILE, COUNT=N )
;
IF N GT 0 THEN  BEGIN  ; DATA_PRODUCTS_FILE is located.
   STATUS = BYTE( 1 )  ; Assume the DATA will be OK.
ENDIF  ELSE  BEGIN   ; N <= 0
   PRINT, 'File: ' + DATA_PRODUCTS_FILE + ' does not exist!'
   PRINT, 'Please Check and tye again'
   STATUS = BYTE( 0 )  ; No Data are read.
   RETURN ; to Caller.
ENDELSE
;
; Use the UNIX "wc" command to find out total input lines in the
; DATA_PRODUCTS_FILE.
;
  SPAWN, 'wc -l ' + DATA_PRODUCTS_FILE, RCD  ; where
; RCD = '13 ~/4Chadwick/RSN/MJ03E/LongTermNANOdataProducts.MJ03E' e.g.
              N = 0  ; to start
  READS, RCD, N      ; Read off the total line number.
;
; Open the data file for Long-Term data products.
;
  OPENR,    FILE_UNIT, /GET_LUN, DATA_PRODUCTS_FILE
;
                       RCD = STRARR( N )
  READF,    FILE_UNIT, RCD  ; Read in All the records.
;
  CLOSE,    FILE_UNIT  ; Close the data file.
  FREE_LUN, FILE_UNIT
;
; Each record in RCD will be for example,
; RCD[i] = '2014/11/17       1501.4443       10.874782       31.947210'
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
   DATE      = INTARR(    3, N    ) ; Note that S[0] = N )
   DATA      = DBLARR( S[0], S[1] ) ; S[0:1] = [ N, 4 ]
   DATA[*,1] = DOUBLE( RCD[*,1] )
   DATA[*,2] = DOUBLE( RCD[*,2] )
   DATA[*,3] = DOUBLE( RCD[*,3] )
   READS, RCD[*,0], FORMAT='(I4,1X,I2,1X,I2)', DATE
   DATE      = TRANSPOSE( TEMPORARY( DATE ) )
   DATA[*,0] = JULDAY( DATE[*,1], DATE[*,2], DATE[*,0] )  ;
ENDELSE      ; where   Day        Month      Year for DATE[*,[1,2,0]].
;
RETURN
END  ; RETRIEVE_NANO_DATA_PRODUCTS
;
; Callers: GET_NANO_DATA_PRODUCTS or Users.
;
PRO SAVE_NANO_DATA_PRODUCTS, ID,  $ ; Input : 'MJ03D', 'MJ03E' or MJ03F'
            MTIME,                $ ; Input : Time in JULDAY() value.
            M1DAY, RATE1, RATE2     ; Inputs: 1-Day Mean & Rate of Changes.
;
; M1DAY = 1-Day Mean of depth in meters.
; RATE1 & RATE2 are Rate of Depth Changes in cm/year.
; All values are in Double Precision.
;
; Open the data file for Long-Term data products.
;
  FILE = '~/4Chadwick/RSN/' + ID + PATH_SEP()  $
       + 'LongTermNANOdataProducts.' + ID
;
  OPENU, /GET_LUN, FILE_UNIT, FILE, /APPEND
;  
; Set up the output record: RCD.  First: Get the time stamp.
;
  RCD  = STRING( MTIME,  $  ; to get '2014/11/06 for example.
                 FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2))" )
;
; Attach the 1-Day Mean & Rate of Changes to the RCD.
;
  RCD += STRING( [ M1DAY, RATE1, RATE2], /PRINT )
;
  PRINTF,   FILE_UNIT, RCD  ; Append the record to the data file.
;
  CLOSE,    FILE_UNIT       ; Close the data file.
  FREE_LUN, FILE_UNIT
;
  PRINT, 'Date: ' + RCD
  PRINT, 'is appendned to the File: ' + FILE
;
RETURN
END  ; SAVE_NANO_DATA_PRODUCTS
;
; Callers: GET_NANO_DATA_PRODUCTS, GET1DAY_MEANS4NANO or Users.
;
PRO SAVE_NEW1DAY_MEAN,  M1DAY,  $ ; Input: 1-Day mean.
    MTIME  ; Input: Time in JULDAY() Value for the 1-Day mean.
;
  COMMON NANO1DAYM, NANO1DAY_MEAN, NANO1DAY_TIME  ; Two 1-D arrays.
;
  N = N_ELEMENTS( NANO1DAY_MEAN )  ; = N_ELEMENTS( NANO1DAY_TIME )
;
; Shift both the arrays values so that for example:
; NANO1DAY_MEAN[0] will be = NANO1DAY_MEAN[1],
; NANO1DAY_MEAN[1] will be = NANO1DAY_MEAN[2],
; :
; NANO1DAY_MEAN[N-2] = NANO1DAY_MEAN[N-1] and
; NANO1DAY_MEAN[N-1] = NANO1DAY_MEAN[0]
;
  NANO1DAY_MEAN = SHIFT( TEMPORARY( NANO1DAY_MEAN ), -1 )
  NANO1DAY_TIME = SHIFT( TEMPORARY( NANO1DAY_TIME ), -1 )
;
; Save the most recent 1-Day mean & its time into the last positions
; of the respective arrays.
;
  NANO1DAY_MEAN[N-1] = M1DAY
  NANO1DAY_TIME[N-1] = MTIME
;
RETURN
END  ; SAVE_NEW1DAY_MEAN
;
; Callers: Users.
;
PRO UPDATE_NANO1DAYM_FILE,  NANO1DAYM_FILE  ; Input: IDL Save File name.
;
; NANO1DAYM_FILE = 'MJ03D-NANO1DayMeans.idl'  for example.
;
  COMMON NANO1DAYM, NANO1DAY_MEAN, NANO1DAY_TIME  ; Two 1-D arrays.
  SAVE, FILE=NANO1DAYM_FILE, NANO1DAY_MEAN, NANO1DAY_TIME
;
RETURN
END  ; UPDATE_NANO1DAYM_FILE
