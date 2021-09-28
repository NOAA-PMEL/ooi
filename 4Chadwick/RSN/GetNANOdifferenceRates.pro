;
; File: GetNANOdifferenceRates.pro
;
; This IDL program will use the data in the IDL Save file: NANOdiffMJ03E-F.idl
; to get the 1-Day mean and save it into the NANOdiffRatesMJ03E-F.idl
; where it contains the past 1-Day means and 28 days (4 weeks), 56 days ( 8 weeks)
; and 84 days (12 weeks) Average Linear Rate of Depth Changes.
;
;
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on August    21st, 2018
; Created on August    10th, 2018
;

;
; Callers: GET_NANO_DIFF_RATES2START and Users
; Revised: August  13th, 2018
;
PRO COMPUTE_RATE,           $ ; To compute the 4-,8-,& 12-week rates by a line fitting.
            NANO_TIME ,     $ ;  Input: 1-D Array of JULDAY() and each one at 12:00:00.
            NANO1DAY_MEAN,  $ ;  Input: 1-D Array of Detided Depth differences, e.g. MJ03E-MJ03F.
            N,              $ ;  Input: Index of the 2 arrays above.
            N_DAYS,         $ ;  Input: Number Days for the 4-wk, 8-wk or 12 wk rate.
            RATE              ; Output: The computed  4-week rate.
;
  CALDAT, NANO_TIME[N],  M, D, YR  ; Get the Year from NANO_TIME[S]
  TIME =  NANO_TIME[N] - N_DAYS    ; Get the date for N_DAYS before, e.g.28=7x4=N_DAYS for the 4-wk rate.
  I    = LOCATE_TIME_POSITION( NANO_TIME, TIME )  ; where TIME <= NANO_TIME[I].
  I   -= ( I GT 0 )
;
  IF ( N - I ) LT 3 THEN  BEGIN  ; Not enough points for fitting a line.
     RATE = -1                   ; To indicate No RATE is computed.
  ENDIF  ELSE  BEGIN  ; ( N - I ) >= 3. There are at least 3 points for fitting a line.
     X = NANO_TIME[I:N] - NANO_TIME[I] ; in Days.
     Y = NANO1DAY_MEAN[I:N]             ; 1-Day Averaged Depthed.
     R = LINFIT( X, Y )     ; A Linear least-square fit method where R = [A,B] as y = A + B*X.
     D = JULDAY( 12,31,YR ) - JULDAY( 1,0,YR )  ; Total Days of the Current Year = 365 or 366.
;    Convert the Rate of Depth (meters) Change/Day into cm/year.
     RATE =  R[1]           ; The uplift should > 0 if depths < 0.
     RATE =  RATE*100.0*D   ; where 100 cm = 1 meter
  ENDELSE  ; Compute the Rate.
;
RETURN
END  ; COMPUTE_RATE
;
; This procedure compute the differences between 2 detided NANO pressure data
; with their matched times.
;
; This procedure requires the procedure: MATCH in ~/idl/match.pro in order to work.
;
; Callers: Users.
; Revised: August  13th, 2018
;
PRO GET_NANO_DIFFERECES, TIME1, TIME2,  $ ;  Inputs: Arrays: NANO Times in JULDAY()s.
                         NANO1, NANO2,  $ ;  Inputs: Arrays: Detided NANO pressure data.
                         TIME , DIFF,   $ ; Outputs: Arrays: TIME for DIFF = NANO1 - NANO2.
                         I1,    I2        ; Outputs: Array indexes for checking TIME1[I1] = TIMES[I2].
;
; (M): Locate  All  the  indexes in  TIME1  and  TIME2   so that  TIME1[I1] = TIMES[I2].
; (D): Compute the tidal differences between NANO1 & NANO2, i.e., NANO1[I1] - NANO2[I2].
;
  MATCH, TIME1, TIME2,  I1, I2, EPSILON=0.000001  ; (M)
  DIFF = NANO1[I1] - NANO2[I2]                    ; (D)
  TIME = TIME1[I1]                                ; = TIME2[I2]
; 
RETURN
END  ; GET_NANO_DIFFERECES
;
; Callers: Users.
; Revised: August  21st, 2018
;
PRO GET_NANO1DAY_MEANS4DIFF, NANO_DIFF_SAVE_FILE,  $ ; Input: 'MJ03F/NANOdifferencesMJ03E-F.idl'.
        LAST_NANO1DAY_TIME,   $ ;  Input : NANO1DAY_TIME[LastPt] in 'MJ03F/NANOdiffRatesMJ03E-F.idl'.
        TIME, DIFF1DAY_MEAN,  $ ; Outputs: Arrays of the Time & the computed 1-Day Means.
        STATUS                  ; Output : 1 = 1-Day Means computed & 0 = No new 1-Day Means.
;
  STATUS = FILE_INFO( NANO_DIFF_SAVE_FILE )
;
  IF STATUS.EXISTS  THEN  BEGIN     ; NANO_DIFF_SAVE_FILE is available.
;    Retrieve the existing NANO differences data in NANO_DIFF_SAVE_FILE
     RESTORE, NANO_DIFF_SAVE_FILE   ; NANO_DIFF, NANO_TIME
     M = N_ELEMENTS( NANO_TIME )    ; Total data points in NANO_TIME
  ENDIF  ELSE  BEGIN
     PRINT, 'From GET_NANO1DAY_MEANS4DIFF, File: ' + NANO_DIFF_SAVE_FILE + ' does not exist.'
     STATUS = -1  ; NANO_DIFF_SAVE_FILE is not available.
     RETURN
  ENDELSE
;
; Get the most recent Date: Month, Day & Year from the last
; value in the array: NANO_TIME.
;
          MTIME = LAST_NANO1DAY_TIME + 1
  CALDAT, MTIME, T, D, Y
;
  ETIME = JULDAY( T, D, Y, 23, 59, 45 )  ; and the End times.
;
  IF NANO_TIME[M-1] LT ETIME THEN  BEGIN  ; New Day is not ready yet.
     PRINT, 'From GET_NANO1DAY_MEANS4DIFF: A New Day is Not ready yet!  '
     PRINT, 'No 1-Day Means of Depth Differencs will be computed!'
     STATUS = 0  ; No 1-Day Means are computed.
  ENDIF  ELSE  BEGIN  ; A New Day is ready.
                             N_DAYS = NANO_TIME[M-1] - LAST_NANO1DAY_TIME
     TIME          = DBLARR( N_DAYS )
     DIFF1DAY_MEAN = DBLARR( N_DAYS )
         K = 0
     FOR S = 1, N_DAYS DO  BEGIN
         CALDAT, MTIME,  T, D, Y
         STIME = JULDAY( T, D, Y, 00, 00, 00 )  ; Define the Start
         ETIME = JULDAY( T, D, Y, 23, 59, 45 )  ; and the End times.
;        Get the indexes: [I,J] so that TIME[I:J] will contain the 1-Day long.
         GET_DATA_RANGE_INDEXES,   NANO_TIME, $ ; Time that contain the STIME & ETIME.
                                 STIME,ETIME, $ ; use the Start & End Times
                                 I,    J,     $ ; to the indexes: I,J
                                 STATUS         ; STATUS = 1 means OK.
         IF STATUS GT 0.5 THEN  BEGIN  ; Data range in [STIME,ETIME] are found.
                     TIME[K] = MTIME
            DIFF1DAY_MEAN[K] = MEAN( NANO_DIFF[I:J], /DOUBLE )
                          K += 1
         ENDIF
         MTIME += 1  ; Move to the day before.
     ENDFOR    ; S
     STATUS = 1  ; Assuming the lastest 1-Day Means are computed.
;    Note that there could be missing days in the lastest data set.
;    When that happens, TIME & DIFF1DAY_MEAN will not use up all the spaces.
     IF ( 0 LT K ) AND ( K LT N_DAYS ) THEN  BEGIN  ; Not all the spaces are used.
;       Reduce the sizes of the arrays: TIME & DIFF1DAY_MEAN.
        T = TIME[0:K-1]
        D = DIFF1DAY_MEAN[0:K-1]
        TIME          = 0
        DIFF1DAY_MEAN = 0
        TIME          = TEMPORARY( T )
        DIFF1DAY_MEAN = TEMPORARY( D )
     ENDIF ELSE IF K LE 0 THEN  BEGIN  ; No spaces are used!
        STATUS = 0  ; No 1-Day Means are computed.
     ENDIF  ; Reduce the sizes of the arrays: TIME & DIFF1DAY_MEAN.
  ENDELSE  ; Computing the 1-Day Means.
;
RETURN
END  ; GET_NANO1DAY_MEANS4DIFF
;
; Compute the 4-,8-, 12- & 24-week rates of the depth chages newest differences data
; for each of the latest days. 
;
; Callers: Users.
; Revised: February 7th, 2020
;
PRO GET_NANO_DIFF_RATES,  $
    NANO1DAY_TIME,        $ ; Input : Output arrays from GET_1DAY_MEANS4DIFF: TIME above.
    DIFF1DAY_MEAN,        $ ; Input : Output arrays from GET_1DAY_MEANS4DIFF: DIFF1DAY_MEAN above. 
    RATE_4WK, RATE_8WK,   $ ; Outputs: Arrays of the computed 4-,8-,
    RATE12WK, RATE24WK,   $ ; Outputs: 12- & 24-week rates.  Added 24-week rate on 2/7/2020.
    NANO_TIME,                     $ ; Output : Array  of the RATEs above.
    N_RATES  ; Output: Can be used as a status. N_RATES = 0 mmeans no new rates.
;
; Note that it is assumed the arrays: NANO1DAY_TIME and NANO1DAY_MEAN are the same length.
; And
; The 1st 84 days or 12 weeks of the data will be skipped.  This is needed for getting
; the 1st 12-week Rate.  ;  August  21st, 2018 to February 7th, 2020
;
; The 1st 168 days or 12 weeks of the data will be skipped.  This is needed for getting
; the 1st 24-week Rate.  ; February 7th, 2020 on.
;
  N = N_ELEMENTS( NANO1DAY_TIME )
;
; Note that it is assumed that the caller have attach additional 84 data points in
; front of the arrays: NANO1DAY_TIME and DIFF1DAY_MEAN so that the N_RATES calculation
; below works.
;
  N_RATES = N -  84  ; Total number of rates will be computed for each of 4-, 8- & 12-week.
;
; Get the otal number of rates will be computed for each of 4-, 8-, 12- & 24-week
;
  N_RATES = N - 168  ; 7 x 24 weeks = 168 days.  February 7th, 2020
;
  IF N_RATES LE 0  THEN  BEGIN
     PRINT, 'From GET_NANO_DIFF_RATES: No new Rates are computed.'
  ENDIF  ELSE  BEGIN  ; N_RATES > 0.
     RATE_4WK = FLTARR( N_RATES )
     RATE_8WK = FLTARR( N_RATES )
     RATE12WK = FLTARR( N_RATES )
     RATE24WK = FLTARR( N_RATES )  ; Added on February 7th, 2020.
            I = N       - 1  ; Starting from the last data point 1st.
            S = N_RATES - 1  ; For storing the RATE*WK results.
;
     WHILE S GE 0 DO  BEGIN  ; Note that N_RATES < N.  So that S will reachs to 0 1st before N does.
           COMPUTE_RATE, NANO1DAY_TIME, DIFF1DAY_MEAN,  $ ; Inputs
                   I, 28,  $ ; Inputs: Index of the 2 arrays above and Days for the  4-wk rate.
                   RATE      ; Output: The computed  4-week rate.
           RATE_4WK[S] = RATE
           COMPUTE_RATE, NANO1DAY_TIME, DIFF1DAY_MEAN,  $ ; Inputs
                   I, 56,  $ ; Inputs: Index of the 2 arrays above and Days for the  8-wk rate.
                   RATE      ; Output: The computed  8-week rate.
           RATE_8WK[S] = RATE
           COMPUTE_RATE, NANO1DAY_TIME, DIFF1DAY_MEAN,  $ ; Inputs
                   I, 84,  $ ; Inputs: Index of the 2 arrays above and Days for the 12-wk rate.
                   RATE      ; Output: The computed 12-week rate.
           RATE12WK[S] = RATE
           COMPUTE_RATE, NANO1DAY_TIME, DIFF1DAY_MEAN,  $ ; Inputs
                   I,168,  $ ; Inputs: Index of the 2 arrays above and Days for the 24-wk rate.
                   RATE      ; Output: The computed 24-week rate.
           RATE24WK[S] = RATE  ; Added on February 7th, 2020.
                    I -= 1   ; Move to the next points.
                    S -= 1
     ENDWHILE  ; S
;
     NANO_TIME = NANO1DAY_TIME[I+1:N-1]  ; Time indexes for the arrays: RATE[_4/_8/12/24]WK.
     PRINT, 'Output Arrays: '
     HELP, NANO_TIME, RATE_4WK,RATE_8WK,RATE12WK,RATE24WK  ; All should be the same size.
  ENDELSE  ; Computing RATE4WK, RATE8WK, RATE12WK and RATE24WK.
;
RETURN
END  ; GET_NANO_DIFF_RATES
;
; Using the provided Time and Detided Depth difference to compute the 4-,8-,12-week rates/
;
; This procedure use the provided Time and Detided Depth difference data from the
; IDL Save file: NANOdiffMJ03E-F.idl to get the 1-Day mean and the 28 days (4 weeks),
; 56 days ( 8 weeks) and 84 days (12 weeks) Average Linear Rate of Depth Changes
; as the outputs for the callers.
;
; Callers: Users.
; Revised: February  7th, 2020
;
PRO GET_NANO_DIFF_RATES2START,  $  ; To compute all available (4,8,12) week rates.
        NANO1DAY_TIME, $ ;  Input: 1-D Array of JULDAY() and each one at 12:00:00.
        NANO1DAY_MEAN, $ ;  Input: 1-D Array of Average Detided Depth differences, e.g. MJ03E-MJ03F.
        RATE_4WK,      $ ; Output: 1-D Array of the  4-wk rates.  All rates
        RATE_8WK,      $ ; Output: 1-D Array of the  8-wk rates.  corresponded
        RATE12WK,      $ ; Output: 1-D Array of the 12-wk rates.  to the NANO_TIME.
        RATE24WK,      $ ; Output: 1-D Array of the 24-wk rates.  Added on Feb.7th,2020.
        NANO_TIME        ; Output: 1-D Array of JULDAY() for the arrays: RATE[4/8/12/24]WK.
;
; Note that it is assumed the arrays: NANO1DAY_TIME and NANO1DAY_MEAN are the same length.
;
  N = N_ELEMENTS( NANO1DAY_TIME )
;
            M = ROUND( NANO1DAY_TIME[N-1] - NANO1DAY_TIME[0] )   ; Total number of days.
; N_RATES = M -  84  ; Total days that will contain all rates and  84=7x12.  August  13th,2018
  N_RATES = M - 168  ; Total days that will contain all rates and 168=7x24.  February 7th,2020
;
  RATE_4WK = FLTARR( N_RATES )  ; Started
  RATE_8WK = FLTARR( N_RATES )  ;   on
  RATE12WK = FLTARR( N_RATES )  ; August 13th, 2018
  RATE24WK = FLTARR( N_RATES )  ; Added on Feb.7th,2020.
;
        I = N       - 1  ; Starting from the last data point 1st.
        S = N_RATES - 1  ; For storing the RATE*WK results.
;
  WHILE S GE 0 DO  BEGIN  ; Note that N_RATES < N.  So that S will reachs to 0 1st before N does.
        COMPUTE_RATE, NANO1DAY_TIME, NANO1DAY_MEAN,  $ ; Inputs
                I, 28,  $ ; Inputs: Index of the 2 arrays above and Days for the  4-wk rate.
                RATE      ; Output: The computed  4-week rate.
        RATE_4WK[S] = RATE
        COMPUTE_RATE, NANO1DAY_TIME, NANO1DAY_MEAN,  $ ; Inputs
                I, 56,  $ ; Inputs: Index of the 2 arrays above and Days for the  8-wk rate.
                RATE      ; Output: The computed  8-week rate.
        RATE_8WK[S] = RATE
        COMPUTE_RATE, NANO1DAY_TIME, NANO1DAY_MEAN,  $ ; Inputs
                I, 84,  $ ; Inputs: Index of the 2 arrays above and Days for the 12-wk rate.
                RATE      ; Output: The computed 12-week rate.
        RATE12WK[S] = RATE
        COMPUTE_RATE, NANO1DAY_TIME, NANO1DAY_MEAN,  $ ; Inputs
                I,168,  $ ; Inputs: Index of the 2 arrays above and Days for the 24-wk rate.
                RATE      ; Output: The computed 24-week rate.
        RATE24WK[S] = RATE  ; Added on February 7th, 2020.
                 I -= 1   ; Move to the next points.
                 S -= 1
  ENDWHILE  ; S
;
  NANO_TIME = NANO1DAY_TIME[I+1:N-1]  ; Time indexes for the arrays: RATE_4WK,RATE_8WK & RATE12WK.
  PRINT, 'Output Arrays: '
  HELP, NANO_TIME, RATE_4WK,RATE_8WK,RATE12WK  ; All should be the same size.
;
RETURN
END  ; GET_NANO_DIFF_RATES2START
;
; Callers: Users
;
PRO UPDATE_NANO_DIFF_SAVE_FILE, NANO_DIFF_SAVE_FILE,  $ ; Input: 'MJ03F/NANOdifferencesMJ03E-F.idl'
                                TIME, DIFF,  $   ;  Inputs: Arrays contain the data to be appended.
                                STATUS           ; Output : 'Updated' or 'No Update'.
;
  STATUS = FILE_INFO( NANO_DIFF_SAVE_FILE )
;
  IF STATUS.EXISTS  THEN  BEGIN     ; NANO_DIFF_SAVE_FILE is available.
;    Retrieve the existing NANO differences data in NANO_DIFF_SAVE_FILE
     RESTORE, NANO_DIFF_SAVE_FILE   ; NANO_DIFF, NANO_TIME
     M = N_ELEMENTS( NANO_TIME )    ; Total data points in NANO_TIME
     N = N_ELEMENTS(      TIME )    ; and TIME.
  ENDIF  ELSE  BEGIN
     PRINT, 'File: ' + NANO_DIFF_SAVE_FILE + ' does not exist.'
     STATUS = 'No Update'
     RETURN
  ENDELSE
;
; Check to make sure that NANO_TIME[M-1] is < TIME[N-1] before proceeding.
;
  IF NOT ( NANO_TIME[M-1] LT TIME[N-1] ) THEN  BEGIN  ; NANO_TIME[M-1] >= TIME[N-1]
     PRINT, 'No New Data yet and No Update will be done.'
     STATUS = 'No Update'
  ENDIF  ELSE  BEGIN  ; NANO_TIME[M-1] < TIME[N-1], There are data to Update.
;
;    Using the time of the last data point in the NANO_TIME arrays to
;    Locate the index in the TIME arrays where the new data start.
;    Note the function: LOCATE_TIME_POSITION() is in the
;    file: ~/4Chadwick/RSN/SplitRSNdata.pro
;
;    M = N_ELEMENTS( LTIME )  ; Total data points in the Long-Term arrays.
     S = LOCATE_TIME_POSITION( TIME, NANO_TIME[M-1] )
;
;    Note that the result from above will be:
;    TIME[S-1] <= NANO_TIME[M-1] < TIME[S]
;    So that TIME[S:N-1] will be the data to be appended
;    in to the Long-Term data.
;
;    N  = N_ELEMENTS(  TIME )  ; Computed outside the IF statement above.
     N -= 1  ; So that TIME[N] is the last data point.
;
;    Append the new data (the data in the last day in the Short-Term arrays).
;
     NANO_TIME  = [ TEMPORARY( NANO_TIME ), TIME[S:N] ]
     NANO_DIFF  = [ TEMPORARY( NANO_DIFF ), DIFF[S:N] ]
;
     PRINT, 'Date/Time of the Last Cumulative Data point: '
     PRINT, FORMAT='(C())', NANO_TIME[M-1]
     PRINT, 'Added New Data between: '
     PRINT, FORMAT='(C())', TIME[[S,N]]
;
     SAVE, FILE=NANO_DIFF_SAVE_FILE, NANO_TIME, NANO_DIFF
     PRINT, SYSTIME() + ' IDL Save File: ' + NANO_DIFF_SAVE_FILE + ' Updated.'
;
     STATUS = 'Updated'  ; May 28th, 2015
;
  ENDELSE ; There are data to Update.
;
RETURN
END  ; UPDATE_NANO_DIFF_SAVE_FILE
