;
; File: GetDetectionParameters.pro
;
; This is an IDL program will be used to compute the Detection Paramters
; that are done in the procedures: CHECK4TSUNAMI_EVENT and GET_AVE_DEPTHS
; in the file: CheckNANOdata4Alerts.pro.
;
; Some procedures in this program also the function in the SplitRSNdata.pro
; in order to run.
;
; This program will be used mostly to recover the missing Detection
; Paramters when the RSN data processing was stopped running for while.
;
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on October   26th, 2015
; Created on January   30th, 2015
;

;
; Caller: GET_DETECTION_PRARMETERS
;
PRO COMPUTE_DETECTION_PRARMETERS, ID,  $  ; Input: = 'Test' e.g.
                           NANO_TIME,  $  ; Input: = JULDAY() value.
                     D, AVE1D, AVE2D      ; Outputs
;
; Get the depth difference between now & 5 minutes ago with 5 cm limit
; and the Average 10-minute Depths from 10 minutes and and 20 minutes ago. 
;
  GET_DEPTH_DIFFERENCE,  ID, 5, 5, D  ; D = 'Gap' or Depth Difference in cm.
  GET_AVE_DEPTHS,  10, 20, AVE1D, AVE2D, DATA_GAPS
; PRINT, 'From COMPUTE_DETECTION_PRARMETERS:'
; HELP, ID, D, AVE1D, AVE2D, DATA_GAPS
; PRINT, STRING( FORMAT='(C())', NANO_TIME ) + STRTRIM( D )  $
;      + STRTRIM( AVE1D ) + STRTRIM( AVE2D ) + ' '  + STRTRIM( DATA_GAPS, 1 )
;
RETURN
END  ; COMPUTE_DETECTION_PRARMETERS
;
; This is the main procedure for calling all the procedures
; such as COMPUTE_DETECTION_PRARMETERS.
;
; Callers: Users.
; Revised: February 24th, 2015
;
PRO GET_DETECTION_PRARMETERS, TIME,  $  ; Input: 1-D array of JULDAY() values.
        DETIDED,  $  ; Input: 1-D array of pressure data in meters.
        S,        $  ; Input: Starting index for TIME & DETIDED.
        M,        $  ; Input: Numebr of increment.
        DATA         ;Output: 2-D array of [Time,D,AVE1D,AVE2D] x n.
;
; Get the total data points in the arrays TIME & DETIDED.
; Note that it is assumed that TIME & DETIDED have the same size.
;
  N = N_ELEMENTS( DETIDED )
;  
IF ( S LT 0 ) or ( N LE S ) THEN  BEGIN  ; S is Not within the range 0 & N-1.
   PRINT, 'From the GET_DETECTION_PRARMETERS,'
   PRINT, 'Illegal index values of S: ', S
   PRINT, 'It must be within 0 and ', N - 1, ' Please try again'
   RETURN  ; to the caller.
ENDIF
;
  ID = 'Test'  ;
;
  COMMON  NANO, NANO_TIME, NANO_PSIA, NANO_DETIDE, NANO_TEMP
; Note that in this test program, variables NANO_PSIA & NANO_TEMP
; are not being used.
;
; Assign the 1st data into the NANO arrays' variables:
; NANO_TIME and NANO_DETIDE.
;
  NANO_TIME   =    TIME[0:S]
  NANO_DETIDE = DETIDED[0:S]
  COMPUTE_DETECTION_PRARMETERS, ID, TIME[S], D, AVE1D, AVE2D
;
; RATE = ( AVE2D - AVE1D )*600.0D0  ; Get the Rate as cm/hour.
;
; Repeatly accumulate the data and check for alerts.
;
  L  = ( N - S )/M  ; Integer calculations
; L  = I*M          ; Last Index for the FOR loop.
  L += 1            ; The lenght for the 2-D array of DATA.
;
; Define a 2-D array: DATA for storing the results
; and Save the 1st set of the computed Detection Parameters.
;
  DATA = DBLARR( 3, L )
  J    =   LONG( 0 )  ; Index for the DATA as J = 0, ..., L-1.
  IF ( AVE2D EQ -1 ) OR ( AVE1D EQ -1 ) THEN  BEGIN  ; There are data gaps
     DATA[0:2,J] = [ TIME[S], D,   -1 ]    ;  when computing AVE1D & AVE2D.
  ENDIF  ELSE  BEGIN
     DATA[0:2,J] = [ TIME[S], D, ( AVE2D - AVE1D )*600.0D0 ]
  ENDELSE
;
  PRINT, SYSTIME() + ' S, N, M, L + S: ',  S, N, M, L + S
;
FOR I = S + 1, N-M, M DO  BEGIN
;   PRINT, I, S, N, M, L + S
;   Assign the data into the NANO arrays' variables: NANO_TIME and NANO_DETIDE.
    NANO_TIME   = [ TEMPORARY( NANO_TIME   ),    TIME[I:I+M-1] ]
    NANO_DETIDE = [ TEMPORARY( NANO_DETIDE ), DETIDED[I:I+M-1] ]
    COMPUTE_DETECTION_PRARMETERS, ID, TIME[I+M-1], D, AVE1D, AVE2D
             J +=1
    IF ( AVE2D EQ -1 ) OR ( AVE1D EQ -1 ) THEN  BEGIN  ; There are data gaps
       DATA[0:2,J] = [ TIME[S], D,   -1 ]    ;  when computing AVE1D & AVE2D.
    ENDIF  ELSE  BEGIN
       DATA[0:2,J] = [ TIME[I+M-1], D, ( AVE2D - AVE1D )*600.0D0 ]
    ENDELSE
ENDFOR  ; I
;
  HELP, S, I, N, M, L, J, DATA
;
; IF I LT N THEN  BEGIN  ; There are data remaining.
;    NANO_TIME   = 0  ; Free them before
;    NANO_DETIDE = 0  ; before use them again
;    NANO_TIME   = TIME
;    NANO_DETIDE = DETIDED
;    COMPUTE_DETECTION_PRARMETERS, ID, TIME[N-1], D, AVE1D, AVE2D
;       S  = ( AVE2D - AVE1D )*600.0D0
;       J += 1
;    IF J GE L THEN  BEGIN  ; DATA's size needs to be increased
;       L += 1   ; to show DATA's size has increased by 1.
;       DATA = [ [ TEMPORARY( DATA ) ], [ TIME[N-1], D, S ] ]
;    ENDIF  ELSE  BEGIN  ; DATA's size is big enough to store 1 more record.
;       DATA[0:2,J] = [ TIME[N-1], D, S ]
;    ENDELSE
; ENDIF
;
IF J LT L THEN  BEGIN  ; Not all the spaces in DATA are used up.
   I    = DATA[*,0:J]  ; Reduce the size of DATA.
   DATA = 0  ; Free it before reusing it.
   DATA = TEMPORARY( I )  ; Resized DATA.
ENDIF  ;
;
; Save the values used for the Detections.
;
; SAVE_DETECTION_PARAMTERS, 'EventDetectionParametersID.idl', DATA
;
  PRINT, SYSTIME() + ' Done.'
;
RETURN
END  ; GET_DETECTION_PRARMETERS
;
; This procedure will compute the average depth from the current
; time to the MIN1AGO minutes and the average depth between the
; MIN1AGO & MIN2AGO minutes.
;
; Callers: CHECK_NANO4ALERTS or Users.
;
PRO GET_AVE_DEPTHS,  MIN1AGO, MIN2AGO,  $ ;  Inputs: Time Lengths in minutes.
        AVE1D, AVE2D,  $ ; Outputs: Average Depths in meters.
        STATUS           ; Output : 0 (No Data Gap) or >0 (Data Gaps)
;
; If STATUS =  1, Data Gaps between current time & MIN1AGO only
; If STATUS = -1, Data Gaps between current time & MIN2AGO only.
; If STATUS =  2, Data Gaps between current time & MIN1AGO & MIN2AGO.
;
  STATUS = 0  ; Assuming No Data Gaps to begin.
; 
; Define the shorter NANO arrays' variable names in the COMMON NANO.
;
  COMMON NANO, TIME, PSIA, DETIDE, TEMP  ; names' w/o the "NANO_".
;
; All the total data points in the arrays.  All arrays are the same size.
;
  N = N_ELEMENTS( TIME )
;
  STATUS = 0  ; Assuming No Data Gaps to begin.
;
; Get the the indexes (S) for the MIN1AGO minutes ago.
; Note the it is assummed the NANO data time is 15 seconds apart,
; i.e. there 4 data points per minutes.
;
  J = MIN1AGO*LONG( 4 )  ; = MIN1AGO*LONG( 60 )/15
; 
; Compute the time difference (D) from the current time to MIN1AGO
; in terms of minutes.  Note that the values in TIME are in JULDAY(). 
;
  J =   N - J - 1   ; Index position for the TIME array.
  D = ( TIME[N-1] - TIME[J] )*1440 ; 1440 = 24*60 = total minutes in days.
;
; Assumming MIN1AGO = 10 minutes.
; If D is > 10 or < 10 minutes, there are data gap, No average depth
; will be computed.
;
IF ABS( D - MIN1AGO ) LT 0.0001 THEN  BEGIN  ; No Time Gap. Compute the AVE1D.
   AVE1D   = MEAN( DETIDE[J+1:N-1], /DOUBLE )  ; Average Depth in meters.
;  Note that J+1 is needed to make sure total data points = MIN1AGO*4.
ENDIF  ELSE  BEGIN  ; There are Time Gap.
   AVE1D   =  -1    ; to indicate Time Gap.
   STATUS += 1
ENDELSE
;
; Get the the indexes (S) for the MIN2AGO minutes ago.
; Note the it is assummed the NANO data time is 15 seconds apart,
; i.e. there 4 data points per minutes.
;
  I = MIN2AGO*LONG( 4 )  ; = MIN2AGO*LONG( 60 )/15
; 
; Compute the time difference (D) from the current time to MIN1AGO
; in terms of minutes.  Note that the values in TIME are in JULDAY(). 
;
  I =   N - I - 1  ; Index position for the TIME array.
  D = ( TIME[N-1] - TIME[I] )*1440 ; 1440 = 24*60 = total minutes in days.
;
; Assumming MIN2AGO = 20.
; If D is > 20 or < 20 minutes, there are data gap, No average depth
; detection parameter be computed.
;
IF ABS( D - MIN2AGO ) LT 0.0001 THEN  BEGIN  ; No Time Gap. Compute the AVE2D.
   AVE2D = MEAN( DETIDE[I+1:J], /DOUBLE )    ; Average Depth in meters.
;  Note that I+1 is needed to make sure total data points = MIN2AGO*4.
ENDIF  ELSE  BEGIN  ; There are Time Gap.
   AVE2D =  -1      ; to indicate Time Gap.
   IF STATUS EQ  0 THEN  BEGIN
      STATUS  = -1     ; Only Time Gap between current time & MIN2AGO.
   ENDIF  ELSE  BEGIN  ; STATUS > 0
      STATUS +=  1     ; Time Gaps between current time & both MIN[1/2]AGO.
   ENDELSE
ENDELSE
;
; PRINT, 'From GET_AVE_DEPTHS:'
; HELP, AVE1D, AVE2D, STATUS, I, J, N, D, MIN1AGO, MIN2AGO
; STOP
;
RETURN
END  ; GET_AVE_DEPTHS
;
; Callers: CHECK_NANO4ALERTS or Users.
; Revised: February 2nd, 2015
;
PRO GET_DEPTH_DIFFERENCE, ID,  $ ; Input: 'MJ03D', 'MJ03E' or MJ03F'
                      MINAGO,  $ ; Input: in minutes.
                 HIGHT_LIMIT,  $ ; Input: in cm.
                           D   ;  Output: Depth Difference in cm or "Gap".
;
;
; Define the shorter NANO arrays' variable names in the COMMON NANO.
;
  COMMON NANO, TIME, PSIA, DETIDE, TEMP  ; names' w/o the "NANO_".
;
; All the total data points in the arrays.  All arrays are the same size.
;
  N = N_ELEMENTS( TIME )
;
; Get the the index (S) for the X minutes ago.
; Note the it is assummed the NANO data time is 15 seconds apart,
; i.e. there 4 data points per minutes.
;
  S = MINAGO*LONG( 4 )  ; = MINAGO*LONG( 60 )/15
;
; Compute the time difference (D) in terms of minutes.
; NOte that the values in TIME are in JULDAY(). 
;
  S =  N - S - 1  ; Index position for the TIME array.
  D = ( TIME[N-1] - TIME[S] )*1440 ; 1440 = 24*60 = total minutes in days.
;
; Assumming MINAGO = 5 minutes.
; If D is > 5 or < 5 minutes, there are data gap, No Tsunami event
; detection will be done; otherwise, Check for Tsunami event.
;
; PRINT, 'From CHECK4TSUNAMI_EVENT:'
;
IF ABS( D - MINAGO ) GT 0.0001 THEN  BEGIN  ; Assumes there is a data gap.
   PRINT, 'There are data gap. No Tsunami Detection will be done.'
;  D = 'Gap'  ; No Tsunami Detection will be done.
   D =  0     ; Indicates too Detection will be done.  February 2nd, 2015
ENDIF  ELSE  BEGIN   ; Assumes D == MINAGO.
   D = ( DETIDE[N-1] - DETIDE[S] )  ; Depth differences in meters.
   D =   D*100                 ; Change Depth differences into cm.
   IF ABS( D ) GT HIGHT_LIMIT THEN  BEGIN  ; Event is Detected.
      SUBJECT = ' Tsunami Event Detected from: ' +  ID   $
              + ' |Height|: ' + STRTRIM( D, 2 )  + ' >'  $
              + ' Limit: '    + STRTRIM( HIGHT_LIMIT, 2 )
      SUBJECT = STRING( FORMAT='(C())', TIME[N-1] ) + ' ' + SUBJECT
      PRINT, SUBJECT, N-1
   ENDIF  ;  Event is Detected.
ENDELSE  ; No data gap.
;
RETURN
END  ; GET_DEPTH_DIFFERENCE
;
; This procedure to Recompute the Detection Parameters using the provided
; date and time and specified NANO data stored in 1 of the *MJ03?-NANO.idl
; files.  It is Up to the callers to RESTORE the *MJ03?-NANO.idl file 1st
; before calling this procedure.
;
; Callers: Users
; Revered: October 28th, 2015
;
PRO REDO_DETECTION_PARAMETERS,  ID,  $ ; Input: 'MJ03D' or 'MJ03E', e.g.
    NANO_TIME,    $ ; Input: 1-D array JULDAY()'s values.
    NANO_DETIDE,  $ ; Input: 1-D array pressure data in meters,
    TARGET_TIME,  $ ; Input: 1-D array JULDAY()'s values (1)
    PARAMS ;  Output: 2-D array (2)
;
; (1) Note that TIME values are from the DATA[*,0] where DATA is a 2-D
;     array stored in the IDL Save file: EventDetectionParametersMJ03F.idl e.g.
; (2) PARAMS will be storing the follow values:
;     PARAMS[*,0] = TIME in JULDAY()'s values.
;     PARAMS[*,1] = Depth Differences in cm/5-minute.
;     PARAMS[*,2] = Depth Differences in cm/hour of two 10-minute averaged Depths
;
; Define the shorter NANO arrays' variable names in the COMMON NANO.
;
  COMMON NANO, TIME, PSIA, DETIDE, TEMP  ; names' w/o the "NANO_".
;
; Define the PARAMS as a 2-D arrays.
;
                      N = N_ELEMENTS( TARGET_TIME )
  PARAMS = DBLARR( 3, N )
;
; PARAMS[0,0:N-1] = TARGET_TIME[0:N-1]  ; Save the TIME values.
;
; Recompute the Detection Parameters.
;
  PRINT, SYSTIME(), ' Start Recomupting parameters ...'
;
  I = LONG( 0 )
  S = LONG( 0 )
  M  = LOCATE_TIME_POSITION( NANO_TIME, TARGET_TIME[S] )
  M -= 1  ; Assume NANO_TIME[M-1] = TARGET_TIME[S].
  TIME   = NANO_TIME[I:M]
  DETIDE = NANO_DETIDE[I:M]
  COMPUTE_DETECTION_PRARMETERS, ID, TARGET_TIME[S], D, AVE1D, AVE2D
  IF ( AVE2D EQ -1 ) OR ( AVE1D EQ -1 ) THEN  BEGIN  ; There are data gaps
     PARAMS[0:2,S] = [ TARGET_TIME[S], D,   -1 ]     ; when computing AVE1D & AVE2D.
  ENDIF  ELSE  BEGIN
     PARAMS[0:2,S] = [ TARGET_TIME[S], D, ( AVE2D - AVE1D )*600.0D0 ]
  ENDELSE
  I = M + 1           ; Update the I for the next set of NANO_TIME[I:M].
  K = LONG( 1 )       ; The 2nd Index for the array: PARAMS.
  T = TARGET_TIME[S]  ; Save the Last processed Time.
;
FOR S = 1, N-1 DO  BEGIN
;   Skip any times that are out of order, i.e. TARGET_TIME[S-1] >= TARGET_TIME[S].
    IF T LT TARGET_TIME[S] THEN  BEGIN
;      Locate the TARGET_TIME[S] so that NANO_TIME[I] = TARGET_TIME[S].
;      Note that the function LOCATE_TIME_POSITION() is in the SplitRSNdata.pro
       M  = LOCATE_TIME_POSITION( NANO_TIME, TARGET_TIME[S] )
;      Note that S index from LOCATE_TIME_POSITION() will have the following
;      property: NANO_TIME[M-1] <= TARGET_TIME[S] < NANO_TIME[M]
       M -= 1  ; Assume NANO_TIME[M-1] = TARGET_TIME[S].
;      Assign the NANO data into the COMMON NANO block's arrays.
;      TIME   = 0  ; Free them
;      DETIDE = 0  ; before reusing them.
       TIME   = [ TEMPORARY( TIME   ), NANO_TIME[I:M]   ]
       DETIDE = [ TEMPORARY( DETIDE ), NANO_DETIDE[I:M] ]
;      PRINT, FORMAT='(A,C())', 'Recomupting parameters at Date & Time: ', TARGET_TIME[S]
;      PRINT, 'S, I = ', S, I
       COMPUTE_DETECTION_PRARMETERS, ID, TARGET_TIME[S], D, AVE1D, AVE2D
       IF ( AVE2D EQ -1 ) OR ( AVE1D EQ -1 ) THEN  BEGIN  ; There are data gaps
          PARAMS[0:2,K] = [ TARGET_TIME[S], D,   -1 ]     ; when computing AVE1D & AVE2D.
       ENDIF  ELSE  BEGIN
          PARAMS[0:2,K] = [ TARGET_TIME[S], D, ( AVE2D - AVE1D )*600.0D0 ]
       ENDELSE  ; Save the Detection Parameters.
       K += 1               ; for the next PARAMS.
       I  = M + 1           ; Update the I for the next set of NANO_TIME[I:M]..
       T  = TARGET_TIME[S]  ; Save the Last processed Time.
    ENDIF  ; Recomputing the Detection Parameters.
ENDFOR  ; S
;
IF K LT N THEN  BEGIN  ; Some of the TARGET_TIMEs are skipped.
        S = PARAMS[*,0:K-1]  ; Save the avialable data.
   PARAMS = 0                ; Free it before reuing it.
   PARAMS = TEMPORARY( S )   ; Rename it.
ENDIF  ; Resize the PARAMS
;
  PARAMS = TRANSPOSE( TEMPORARY( PARAMS ) )
;
  PRINT, SYSTIME(), ' Done  Recomupting parameters ...'
;
RETURN
END  ; REDO_DETECTION_PARAMTERS
;
; Callers: PROCESS_NANO_DATA   or Users
; Revised: November 18th, 2014
;
PRO SAVE_DETECTION_PARAMTERS,  IDL_FILE,  $ ; Input: IDL Save File Name.
    DATA   ; Input: 2-Data arrays to be saved.
;
; An example for the IDL_FILE name will be:
; '~/4Chadwick/RSN/MJ03F/EventDetectionParametersMJ03F.idl'
; However, users can use other name first.  After the values in the DATA
; have been checked OK, then rename the saved file to the permanent one. 
;
; It is assumed the 2-D array: DATA is n x 3 where
; DATA[*,0] = Time indexes in JULDAY() values.
; DATA[*,1] = Depth difference in cm.
; DATA[*,1] = RATE of Average Depth (cm/hour) difference
;             from ( AVE2D - AVE1D )*600.
;
IF FILE_TEST( IDL_FILE ) THEN  BEGIN
   ANSWER = DIALOG_MESSAGE( TITLE='From SAVE_DETECTION_PARAMTERS',    $
        [  'File: ' + IDL_FILE + ' already Exist.', 'Overwrite it?',  $
           'Cancel to Exit.' ], /CANCEL, /QUESTION )
ENDIF  ELSE  BEGIN  ; IDL_FILE have not been created.
   ANSWER = 'Yes'
ENDELSE
;
IF ANSWER EQ 'Yes' THEN  BEGIN
  SAVE, FILE=IDL_FILE, DATA
  PRINT, 'File: ' + IDL_FILE + ' is updated.'
ENDIF
;
RETURN
END  ; SAVE_DETECTION_PARAMTERS
