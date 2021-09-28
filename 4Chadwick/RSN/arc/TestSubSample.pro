;
; This procedure will check for unusual large psia values in the array: PSIA.
; If the large values are found, the avrage values of the 2 values: 1 before
; and 1 after the large value will be replace the large value.
;
; Callers: PROCESS_RSN_DATA or users
;  
PRO SPIKE_CHECK4NANO_DATA,  TIME,  $ ; Input: 1-D array OF julday()
                            PSIA,  $ ; I / O: 1-D array in meters.
                      N_NANO_CNT     ; Input: Total points for the new data.
;  
; Use the psia values in from the 2nd to the 1 before the last data point
; to Check for Spikes.
;
FOR S = 1, N_NANO_CNT - 2 DO  BEGIN
    STD = ( TIME[S+1] - TIME[S-1] )*86400  ; Time difference in seconds.
    IF ROUND( STD ) EQ 30 THEN  BEGIN  ; No Time Gap.  OK to check for spike.
;      Compute the standard deviation and the mean of the values
;      from 1 before and 1 after the PSIA[S] value.
       STD = STDEV( PSIA[[S-1,S+1]], M )  ; M = the Mean.
;      IF PSIA[S] GT ( M + 20.0*STD ) THEN  BEGIN  ; PSIA[S] is a spike.
       IF PSIA[S] GT ( M + 0.050D0  ) THEN  BEGIN  ; PSIA[S] is a spike.
          PRINT, FORMAT='(A,C(),A)', 'On ', TIME[S],          $
                 STRCOMPRESS( STRING( PSIA[S-1:S+1], /PRINT ) )
          PRINT, 'Replaced the Spike value: ' + STRTRIM( PSIA[S], 2 )  $
               + ' by the arevage: '          + STRTRIM(      M , 2 ), S
          PSIA[S] = M  ; Replace the large (spike) value by the average.
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
   STD = STDEV( PSIA[1:2], M )  ; M = the Mean.
   IF PSIA[S] GT ( M + 0.050D0  ) THEN  BEGIN  ; PSIA[S] is a spike.
      PRINT, FORMAT='(A,C(),A)', 'On ', TIME[S],      $
             STRCOMPRESS( STRING( PSIA[0:2], /PRINT ) )
      PRINT, 'Replaced the Spike value: ' + STRTRIM( PSIA[S], 2 )  $
           + ' by the arevage: '          + STRTRIM(      M , 2 ), S
      PSIA[S] = M  ; Replace the large (spike) value by the average.
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
;
   STD = STDEV( PSIA[S-2:S-1], M )  ; M = the Mean.
;
   IF PSIA[S] GT ( M + 0.050D0  ) THEN  BEGIN  ; PSIA[S] is a spike.
      PRINT, FORMAT='(A,C(),A)', 'On ', TIME[S],      $
             STRCOMPRESS( STRING( PSIA[S-2:S], /PRINT ) )
      PRINT, 'Replaced the Spike value: ' + STRTRIM( PSIA[S], 2 )  $
           + ' by the arevage: '          + STRTRIM(      M , 2 ), S
      PSIA[S] = M  ; Replace the large (spike) value by the average.
   ENDIF  ; Checking Spike value.
ENDIF  ; ROUND( STD ) EQ 30
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
PRO SUBSAMPLE_NANO_DATA,     TIME,  $ ;  Input: 1-D array of JULDAY() values.
                       N_NANO_CNT,  $ ;  I / O: Total points for the new data.
                         STATUS       ; Output: 'NANO at ...' or 'No NANO ...'
;
; Estimate the sample rate: data points per second.
;
  S = ( TIME[N_NANO_CNT-1] - TIME[0] )*86400.0D0  ; Total time in seconds.
  R = ROUND( DOUBLE( N_NANO_CNT )/S )             ; Data points/second.
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
   FOR I = ULONG( 1 ), N_NANO_CNT - 1 DO  BEGIN
               X = S[I] - SCD
       IF ABS( X ) LT 0.001 THEN  BEGIN  ; S[I] = 0, 15, 30 or 45.
          T[I] = 1                    ; Mark the position.
          SCD  = ( SCD + 15 ) MOD 60  ; If SCD = 15, set SCD = 30. e.g.
;      ENDIF ELSE IF ABS( S[I] - S[I-1] ) GT 1.0 THEN  BEGIN  ; Time Gap.
       ENDIF ELSE IF ( ( X GT 0.0 ) AND ( SCD GT 0 ) ) $
                  OR ( ( X LT 0.0 ) AND ( SCD LE 0 ) ) THEN  BEGIN  ; S[I] > SCD
          Z = 1.0D0/DOUBLE( R )  ; Time interval between data points.
                        Y = ABS( S[I] - S[I-1] )
HELP, Z, R, X, Y
;         IF ( 0.025 LT Y ) AND ( Y LE 2.0 ) THEN  BEGIN  ; Time Gap.
          IF ( Z LT Y ) AND ( ABS( Y - Z-Z ) LT 0.001 ) THEN  BEGIN  ; Time Gap.
;            If the Time Gap is only +/- 1 second off, use the neighborhood
;            value.  E.G. If SCD = 45, use the second at either 44 or 46.
             IF SCD GT 0 THEN  BEGIN  ; SCD = 15, 30 or 45
                X = ABS( S[I-1] - SCD )
                Y = ABS( S[I]   - SCD )
             ENDIF  ELSE  BEGIN       ; SCD = 0
                X = ABS( S[I-1] - ( SCD + 60*( S[I-1] GT 45 ) ) )
                Y = ABS( S[I]   - ( SCD + 60*( S[I]   GT 45 ) ) )
             ENDELSE
;            PRINT, I, S[I-1], S[I], SCD, X, Y, Z
;            IF ( X GT 1.0 ) AND ( Y GT 1.0 ) THEN  BEGIN
;            IF ( X GT 0.025 ) AND ( Y GT 0.025 ) THEN  BEGIN
             IF ( X GT Z   ) AND ( Y GT Z   ) THEN  BEGIN
;               Reset the SCD value based on the Current second: S[I].
                Y   = S[I] LE [0,15,30,45]
                X   = WHERE( Y EQ 1, MN )
                SCD = ( MN EQ 0 ) ? 0 : ([0,15,30,45])[X[0]] 
;               PRINT, ' SCD updated to ', SCD, MN
             ENDIF  ELSE  BEGIN  ; X <= Z or Y <= Z.
                IF X LT Y THEN  BEGIN  ; |S[I-1] - SCD| < |S[I] - SCD| < Z
                   T[I-1] = 1  ; Use the  Last   position.
                   SCD  = ( SCD + 15 ) MOD 60  ; If SCD=45, set SCD =  0. e.g.
                ENDIF  ELSE  BEGIN     ; |S[I] - SCD| < |S[I-1] - SCD| < Z
                   T[I]   = 1  ; Use the current position.
                   SCD  = ( SCD + 15 ) MOD 60  ; If SCD=30, set SCD = 45. e.g.
                ENDELSE
             ENDELSE
          ENDIF  ; Time Gap.
       ENDIF
;      IF T[I] EQ 1 THEN  BEGIN
;         PRINT, FORMAT='(C(),1X,I5,I3,1X,F6.3)', TIME[I], I, SCD, S[I]
;      ENDIF
;      IF ( I EQ 1198 ) OR ( I EQ 1199 ) OR ( I EQ 1798 ) THEN STOP
   ENDFOR  ; I
   I = WHERE( T EQ 1, MN )  ; Locate all the marked positions.
   IF MN LE 0 THEN  BEGIN   ; No times at [0,15,30,45] are found.
    N_NANO = 0
    STATUS = 'No NANO at every 15th seconds are found'
   ENDIF  ELSE  BEGIN  ; MN > 0.  Save the resampled data.
      T    = TIME[I]
      TIME = TEMPORARY( T )
    N_NANO = MN
    STATUS = 'NANO at every 15th seconds with Time Gaps'
   ENDELSE
ENDIF
;
N_NANO_CNT = N_NANO  ; Update the total resampled data.
;
RETURN
END  ; SUBSAMPLE_NANO_DATA
