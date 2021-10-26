;
; File: TestkNANOdata4Alerts.pro
;
; This is an IDL Testing program will use a Test data set from users
; to check for Alerts conditions.  When the conditons are met, Alerts'
; messages will be printed out.
;
; There are 3 kinds of the Alerts:
; 1) A tsunami event when the |depth change: 5 min & current| is > 5 cm. 
; 2) A pre-eruption uplift event    when rate of depth change is > +5 cm/hr.
; 3) A co-eruption subsidence event when rate of depth change is < -5 cm/hr.
;
; This program also produces a Alert Statistics Table as an image file
;
; Any of the procedures below will be called by the routines in the
; file: ProcessRSNdata.pro
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on January    6th, 2015
; Created on January    6th, 2015
;

;
; Callers: CHECK4TSUNAMI_EVENT or Users
; Revised: November  21st, 2014
;
FUNCTION ALERT_PERMISSION, ALERT_STATUS_FILE,  $ ; Input: File name.
              CHECK_TIME=TIME_LAPSE4MSG,       $ ; Input: in Days.
         GET_STATUS_TIME=LAST_STATUS_TIME      ;  Output: in JULDAY() value.
;
  D   = 31    ; Day  : 1-31
  MTH = 12    ; Month: 1-12
  Y   = 2014  ; Year : 1999,2013 e.g.
  H   = 23    ; Hour : 0-23
  M   = 59    ; Minutes: 00-59
  S   = 59    ; Seconds: 00-59
;
  STATUS = BYTE( 0 )  ; 0 = No Alert has been sent.  1 = Alert has been sent.
  OPENR,    STATUS_UNIT, ALERT_STATUS_FILE, /GET_LUN
; Read in the Alert STATUS = 0 or 1 and the Year,Month,Day, Hr,Min.Sec.
  READF,    STATUS_UNIT, FORMAT='(I2,I5,5(1X,I2))',STATUS, Y,MTH,D, H,M,S
  CLOSE,    STATUS_UNIT
  FREE_LUN, STATUS_UNIT
;
  LAST_STATUS_TIME = JULDAY( D,MTH,Y, H,M,S )  ; November  21st, 2014
;
; If STATUS = 0 which means NO Alert has been sent out,
; Return 1 to the caller indicate an Alert can be sent out.
;
; If STATUS = 1 which indicates an Alert has been sent out,
; Return 0 to the caller indicate No Alert should be sent,
; Unless the Alert was set over 7 days ago.  In that case,
; Return 1 to the caller indicate an Alert should be sent again.
;
IF STATUS LT 1 THEN  BEGIN  ; No Alert has been sent out yet.
   STATUS = BYTE( 1 )       ; Indicates an Alert can be sent out.
ENDIF  ELSE  BEGIN  ; an Alert has been sent out before.
;  In here, STATUS = 1 already.
   IF NOT KEYWORD_SET( TIME_LAPSE4MSG ) THEN  BEGIN
      TIME_LAPSE4MSG = 7  ; Days
   ENDIF
;  If the time of the Alert was sent out recently, i.e.
;  less than the TIME_LAPSE4MSG time,
;  then Return 0 to the caller indicate No Alert should be sent
;  otherwise, then Return 1 to indicate an Alert should be sent again.
   TIME = SYSTIME( /JULIAN ) - LAST_STATUS_TIME
   IF TIME LT TIME_LAPSE4MSG THEN  BEGIN
      STATUS = BYTE( 0 )  ; No alert to be sent.
   ENDIF  ELSE  BEGIN  ; TIME > TIME_LAPSE4MSG.
;     STATUS = -1 to indicate last alert was a while ago.
      STATUS = -1    ; Also any new alert should be sent.
      PRINT, 'From ALERT_PERMISSION:'
      PRINT, 'Last Alert was sent out ' + STRTRIM( TIME_LAPSE4MSG, 2 )  $
           + ' days ago!'
      PRINT, 'Alert message should be sent again.'
   ENDELSE
ENDELSE
;
RETURN, STATUS         ; = 1 (Send) or = 0 (Not to Send). 
END   ; ALERT_PERMISSION
;
; This is the main procedure for calling all 3 detection procedures:
; CHECK4TSUNAMI_EVENT, CHECK4_UPLIFT_EVENT & CHECK4SUBSIDE_EVENT.
;
; Callers: PROCESS_RSN_DATA or Users.
;
PRO TEST_NANO4ALERTS, TIME,  $  ; Input: 1-D array of JULDAY() values.
                   DETIDED,  $  ; Input: 1-D array of pressure data in meters.
                         S,  $  ; Input: Starting index for TIME & DETIDED.
                         M      ; Input: Numebr of increment.
;
; Get the total data points in the arrays TIME & DETIDED.
; Note that it is assumed that TIME & DETIDED have the same size.
;
  N = N_ELEMENTS( DETIDED )
;  
IF ( S LT 0 ) or ( N LE S ) THEN  BEGIN  ; S is Not within the range 0 & N-1.
   PRINT, 'From TEST_NANO4ALERTS:'
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
  CHECK_NANO4ALERTS, ID, TIME[S]
;
; Repeatly accumulate the data and check for alerts.
;
  I = ( N - S )/M  ; Integer calculations
  L = I*M          ; Last Indexi for the FOR loop.

;
FOR I = S + 1, N-1, M DO  BEGIN
    PRINT, I, S, N, M, L
;  Assign the data into the NANO arrays' variables: NANO_TIME and NANO_DETIDE.
   NANO_TIME   = [ TEMPORARY( NANO_TIME   ),    TIME[I:I+M-1] ]
   NANO_DETIDE = [ TEMPORARY( NANO_DETIDE ), DETIDED[I:I+M-1] ]
   CHECK_NANO4ALERTS, ID, TIME[I+M-1]
ENDFOR  ; I
;
IF L LT N THEN  BEGIN  ; There are data remaining.
   NANO_TIME   = 0  ; Free them before
   NANO_DETIDE = 0  ; before use them again
   NANO_TIME   = TIME
   NANO_DETIDE = DETIDED
   CHECK_NANO4ALERTS, ID, NANO_TIME[N-1]
ENDIF
;
RETURN
END  ; TEST_NANO4ALERTS
;
; Caller: TEST_NANO4ALERTS
;
PRO CHECK_NANO4ALERTS, ID,  $  ; Input: = 'Test' e.g.
                NANO_TIME      ; Input: = JULDAY() value.
;
;  Check depth difference between now & 5 minutes ago with 5 cm limit.
   CHECK4TSUNAMI_EVENT, ID, 5, 5, D  ; D = 'Gap' or Depth Difference in cm.
   GET_AVE_DEPTHS,  10, 20, AVE1D, AVE2D, DATA_GAPS
;  PRINT, 'From CHECK_NANO4ALERTS:'
;  HELP, ID, D, AVE1D, AVE2D, DATA_GAPS
   PRINT, STRING( FORMAT='(C())', NANO_TIME ) + STRTRIM( D )  $
 + STRTRIM( AVE1D ) + STRTRIM( AVE2D ) + ' '  + STRTRIM( DATA_GAPS, 1 )
   IF DATA_GAPS EQ 0 THEN  BEGIN    ; No data gaps.  Check eruption events.
;     N = N_ELEMENTS( NANO_TIME )
;     AVE1D*100.D0/(10.0D0/60.0D0)  ; from meters to cm/hour.
;     AVE1D*100.D0/((20-10)/60.00)  ; from meters to cm/hour.
      CHECK4_UPLIFT_EVENT, ID, NANO_TIME, AVE1D, AVE2D,  5  ; 5 = Rate of Change
      CHECK4SUBSIDE_EVENT, ID, NANO_TIME, AVE1D, AVE2D, -5  ; in cm/hour.
   ENDIF  ELSE  BEGIN  ; There is at least 1 data gap in AVE1D &/or AVE2D.
      PRINT, 'From CHECK_NANO4ALERTS, there is at least 1 data gap'
      PRINT, 'to prevent the pre/co-eruption detections.'
   ENDELSE
;  Save the values used for the Detections.
   SAVE_DETECTION_PARAMTERS, ID, D, AVE1D, AVE2D, DATA_GAPS
;
RETURN
END  ; CHECK_NANO4ALERTS
;
; This procedure check for the co-eruption Subsidence event
; which will be detected by the following condition:
; When the Rate of Change from 2 averages: AVE1D & AVE2D
; is < RATE_LIMIT where RATE_LIMIT = -5 cm for example.
;
; Note that the main difference between this procedure and the
; procedure: CHECK4_UPLIFT_EVENT is the condition of the detection.
; In CHECK4_UPLIFT_EVENT, the condition is > RATE_LIMIT.
;
; Callers: CHECK_NANO4ALERTS or Users.
;
PRO CHECK4SUBSIDE_EVENT, ID,  $ ; Input : 'MJ03D', 'MJ03E' or MJ03F'
                      TIME ,  $ ; Input : in JULDAY() value.
               AVE1D, AVE2D,  $ ; Inputs: Average Depths in meters.
                 RATE_LIMIT     ; Input : in cm/hour.
;
  ERUPTION_ALERT_STATUS_FILE = '~/4Chadwick/RSN/'   + ID + PATH_SEP() $ 
                             + 'SubsidenceAlertStatus.'  + ID
;
; Get the Depth differences between the Most recent average depth (AVE1D)
; and the earlier one (AVE2D).
; Note that the average Depths are under the sea level; therefore, for
; Subsidence to occur, AVE1D value will be > AVE2D.
;
  D = ( AVE2D - AVE1D )  ; Depth differences in meters.
  D =   D*600            ; Change Depth differences into cm/hr.
;
; PRINT, 'From CHECK4SUBSIDE_EVENT:'
; HELP, AVE1D, AVE2D, D, RATE_LIMIT, ERUPTION_ALERT_STATUS_FILE
;
IF D LT RATE_LIMIT THEN  BEGIN  ; Subsidence Event Detected.
;  Get permission for sending the Alert message.
;  SEND = ALERT_PERMISSION( ERUPTION_ALERT_STATUS_FILE )
   SEND = BYTE( 1 )  ; Yes.
   IF ABS( SEND ) THEN  BEGIN  ; Send out the Alert message.
;     SEND_SUBSIDENCE_ALERT, ID, D, RATE_LIMIT
;     UPDATE_ALERT_STATUS,   ERUPTION_ALERT_STATUS_FILE, TIME, ABS( SEND )
  SUBJECT = 'Subsidence Detected from: ' +  ID    $
          + ' Rate: '  + STRTRIM( D, 2 ) + ' <'   $
          + ' Limit: ' + STRTRIM( RATE_LIMIT, 2 )
  SUBJECT = STRING( FORMAT='(C())', TIME ) + ' ' + SUBJECT
  PRINT, SUBJECT
   ENDIF  ; Send out the Alert message.
ENDIF  ; Event Detected.
;
RETURN
END  ; CHECK4SUBSIDE_EVENT
;
; Callers: CHECK_NANO4ALERTS or Users.
;
PRO CHECK4TSUNAMI_EVENT, ID,  $ ; Input: 'MJ03D', 'MJ03E' or MJ03F'
                     MINAGO,  $ ; Input: in minutes.
                HIGHT_LIMIT,  $ ; Input: in cm.
                          D   ;  Output: Depth Difference in cm or "Gap".
;
  TSUNAMI_ALERT_STATUS_FILE = '~/4Chadwick/RSN/'    + ID + PATH_SEP() $
                            + 'TsunamiAlertStatus.' + ID
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
   D = 'Gap'  ; No Tsunami Detection will be done.
ENDIF  ELSE  BEGIN   ; Assumes D == MINAGO.
;  Get the permission for sending the Alert message.
;  SEND =  1 means Alert message can be sent, 0 means No
;  SEND = -1 means Last Alert message was sent a while ago.
;  SEND = ALERT_PERMISSION( TSUNAMI_ALERT_STATUS_FILE,  $
;                           GET_STATUS_TIME=STATUS_TIME  )
   SEND = BYTE( 1 )  ; Yes.
      D = ( DETIDE[N-1] - DETIDE[S] )  ; Depth differences in meters.
      D =   D*100                 ; Change Depth differences into cm.
;  PRINT, 'DETIDE[N-1] & DETIDE[S] = ', DETIDE[N-1],  DETIDE[S]
;  HELP,   D,     HIGHT_LIMIT
   IF ABS( D ) GT HIGHT_LIMIT THEN  BEGIN  ; Event is Detected.
;     HELP, SEND, TSUNAMI_ALERT_STATUS_FILE
      IF ABS( SEND ) THEN  BEGIN  ; Send out the Alert message.
;        SEND_TSUNAMI_ALERT,  ID, D, HIGHT_LIMIT
;        UPDATE_ALERT_STATUS, TSUNAMI_ALERT_STATUS_FILE, TIME[N-1], ABS( SEND )
  SUBJECT = ' Tsunami Event Detected from: ' +  ID   $
          + ' |Height|: ' + STRTRIM( D, 2 )  + ' >'  $
          + ' Limit: '    + STRTRIM( HIGHT_LIMIT, 2 )
  SUBJECT = STRING( FORMAT='(C())', TIME[N-1] ) + ' ' + SUBJECT
  PRINT, SUBJECT, N-1
      ENDIF  ; Send out the Alert message.
   ENDIF  ELSE  BEGIN  ;  No Event is Detected.
      IF SEND LT 0 THEN  BEGIN ; The Last Alert message was sent a while ago.
         SEND =  0 ; For reseting the TSUNAMI_ALERT_STATUS_FILE.
         UPDATE_ALERT_STATUS, TSUNAMI_ALERT_STATUS_FILE, STATUS_TIME, SEND
      ENDIF
   ENDELSE
;  Save the values used for the Detections.
;  SAVE_TSUNAMI_CHECKED_DATA, ID, S, N ;, D, HIGHT_LIMIT
ENDELSE  ; No data gap.
;
RETURN
END  ; CHECK4TSUNAMI_EVENT
;
; This procedure check for the pre-eruption Uplift event
; which will be detected by the following condition:
; When the Rate of Change from 2 averages: AVE1D & AVE2D
; is > RATE_LIMIT where RATE_LIMIT = -5 cm for example.
;
; Note that the main difference between this procedure and the
; procedure: CHECK4_SUBSIDE_EVENT is the condition of the detection.
; In CHECK4_SUDSIDE_EVENT, the condition is < RATE_LIMIT.
;
; Callers: CHECK_NANO4ALERTS or Users.
;
PRO CHECK4_UPLIFT_EVENT, ID,  $ ; Input : 'MJ03D', 'MJ03E' or MJ03F'
                      TIME ,  $ ; Input : in JULDAY() value.
               AVE1D, AVE2D,  $ ; Inputs: Average Depths in meters.
                 RATE_LIMIT     ; Input : in cm/hour.
;
  ERUPTION_ALERT_STATUS_FILE = '~/4Chadwick/RSN/'   + ID + PATH_SEP() $ 
                             + 'UpLiftAlertStatus.' + ID
;
; Get the Depth differences between the Most recent average depth (AVE1D)
; and the earlier one (AVE2D)
; Note that the average Depths are under the sea level; therefore, for
; Uplift to occur, AVE1D value will be < AVE2D.
;
  D = ( AVE2D - AVE1D )  ; Depth differences in meters.
  D =   D*600            ; Change Depth differences into cm/hr.
;
; PRINT, 'From CHECK4_UPLIFT_EVENT:'
; HELP, AVE1D, AVE2D, D, RATE_LIMIT, ERUPTION_ALERT_STATUS_FILE
;
IF D GT RATE_LIMIT THEN  BEGIN  ; Event Detected.
;  Get permission for sending the Alert message.
;  SEND = ALERT_PERMISSION( ERUPTION_ALERT_STATUS_FILE )
   SEND = BYTE( 1 )  ; Yes.
   IF ABS( SEND ) THEN  BEGIN  ; Send out the Alert message.
;     SEND_UPLIFT_ALERT,   ID, D, RATE_LIMIT
;     UPDATE_ALERT_STATUS, ERUPTION_ALERT_STATUS_FILE, TIME, ABS( SEND )
  SUBJECT = 'Uplift Event Detected from: ' + ID      $
          + ' Rate: '  + STRTRIM( D, 2 )  + ' >'     $
          + ' Limit: ' + STRTRIM( RATE_LIMIT, 2 )
  SUBJECT = STRING( FORMAT='(C())', TIME ) + ' ' + SUBJECT
       PRINT, SUBJECT
   ENDIF  ; Send out the Alert message.
ENDIF  ; Event Detected.
;
RETURN
END  ; CHECK4_UPLIFT_EVENT
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
; detection ll be computed.
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
; Callers: CHECK4TSUNAMI_EVENT or Users
; Revised: November 18th, 2014
;
PRO SAVE_DETECTION_PARAMTERS,  ID,  $ ; Input: 'MJ03D', 'MJ03E' or MJ03F'
    D,             $ ; Input : 'Gap' or Depth difference in cm.
    AVE1D, AVE2D,  $ ; Inputs: Average Depth in meters.
    DATA_GAPS   ; Input : 1=No AVE1D value, -1=NoAVE2D, 2=No Both Values.
;
; Define the shorter NANO arrays' variable names in the COMMON NANO.
;
  COMMON NANO, TIME, PSIA, DETIDE, TEMP  ; names' w/o the "NANO_".
;
; All the total data points in the arrays.  All arrays are the same size.
;
  N = N_ELEMENTS( TIME )
;
; Set up the output record: RCD.  First: Get the time stamp.
;
  RCD   = STRING( TIME[N-1],  $  ; to get '2014/11/06 12:03:51' for example.
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
;
; Attach the Depth difference in cm if it is available.
;
IF SIZE( D, /TYPE ) EQ 7 THEN  BEGIN  ; D is a string & assuming D = 'Gaps'
   RCD += STRING( FORMAT='(A14)', '    Gap  ' )
ENDIF  ELSE  BEGIN  ; D = Depth difference in cm.
   RCD += STRING( FORMAT='(A14)', STRTRIM( D, 2 ) )
ENDELSE
;
; Attach the Rate of Change in cm/hour if the Average Depths are available.
; and Print out the output record: RCD.
;
IF DATA_GAPS EQ 0 THEN  BEGIN ; No data gaps for both AVE1D & AVE2D
;
;  Compute the RATE and Attach it into the RCD. 
;
   RATE = ( AVE2D - AVE1D )*600.0D0  ; Get the Rate as cm/hour.
   RCD += STRING( FORMAT='(A14)', STRTRIM( RATE, 2 ) )
;
;  Open the data file for Short-Term data products.
;
   FILE = '~/4Chadwick/RSN/' + ID + PATH_SEP()  $
        + 'EventDetectionParameters.' + ID
   OPENU, /GET_LUN, FILE_UNIT, FILE, /APPEND
   PRINTF,   FILE_UNIT, RCD  ; Append the record to the data file.
   CLOSE,    FILE_UNIT       ; Close the data file.
   FREE_LUN, FILE_UNIT
;  PRINT, 'File: ' + FILE + ' is updated.'
;
ENDIF  ; 
;
RETURN
END  ; SAVE_DETECTION_PARAMTERS
;
; Callers: CHECK4SUDSIDE_EVENT or Users
;
PRO SEND_SUBSIDENCE_ALERT,  ID,  $ ; Input: 'MJ03D', 'MJ03E' or MJ03F'
                             D,  $ ; Input: Rate Change in cm/hour.
                    RATE_LIMIT     ; Input: in cm/hour.
;
; Set the Tsunami Event warning message file's name.
;
  MAIL = '~/4Chadwick/RSN/SubsidenceEvent.Msg'
;
; Define the email's SUBJECT
;
  SUBJECT = '"' + 'Subsidence Detected from: ' +  ID    $
                + ' Rate: '  + STRTRIM( D, 2 ) + ' <'   $
                + ' Limit: ' + STRTRIM( RATE_LIMIT, 2 ) + '"'
;
; Set up the UNIX 'mail' command.
;
  MAIL = 'mail -s ' + SUBJECT + ' Andy.Lau@noaa.gov < ' + MAIL
; MAIL = 'mail william.w.chadwick@noaa.gov -c Andy.Lau@noaa.gov '  $
;      +      '-s ' + SUBJECT + ' < ' + MAIL
; MAIL = 'mail $Alist $Elist -c Andy.Lau@noaa.gov -s ' + SUBJECT + ' < ' + MAIL
;
  SPAWN, MAIL  ; Send out the Notification by email.
;
  PRINT, [ SYSTIME(), MAIL, 'is sent.' ]
;
RETURN
END  ; SEND_SUBSIDENCE_ALERT
;
; Callers: CHECK4TSUNAMI_EVENT or Users
;
PRO SEND_TSUNAMI_ALERT,  ID,  $ ; Input: 'MJ03D', 'MJ03E' or MJ03F'
                          D,  $ ; Input: Depth difference in cm.
                HIGHT_LIMIT     ; Input: in cm.
;
; Set the Tsunami Event warning message file's name.
;
  MAIL = '~/4Chadwick/RSN/TsunamiEvent.Msg'
;
; Define the email's SUBJECT
;
  SUBJECT = '"Tsunami Event Detected from: ' +  ID   $
          + ' |Height|: ' + STRTRIM( D, 2 )  + ' >'  $
          + ' Limit: '    + STRTRIM( HIGHT_LIMIT, 2 )  + '"'
;
; Set up the UNIX 'mail' command.
;
  MAIL = 'mail -s ' + SUBJECT + ' Andy.Lau@noaa.gov < ' + MAIL
; MAIL = 'mail william.w.chadwick@noaa.gov -c Andy.Lau@noaa.gov '  $
;      +      '-s ' + SUBJECT + ' < ' + MAIL
; MAIL = 'mail $Alist -c Andy.Lau@noaa.gov -s ' + SUBJECT + ' < ' + MAIL
;
  SPAWN, MAIL  ; Send out the Notification by email.
;
  PRINT, [ SYSTIME(), MAIL, 'is sent.' ]
;
RETURN
END  ; SEND_TSUNAMI_ALERT
;
; Callers: CHECK4UPLIFT_EVENT or Users
;
PRO SEND_UPLIFT_ALERT,   ID,  $ ; Input: 'MJ03D', 'MJ03E' or MJ03F'
                          D,  $ ; Input: Rate Change in cm/hour.
                 RATE_LIMIT     ; Input: in cm/hour.
;
; Set the Tsunami Event warning message file's name.
;
  MAIL = '~/4Chadwick/RSN/UpliftEvent.Msg'
;
; Define the email's SUBJECT
;
  SUBJECT = '"' + 'Uplift Event Detected from: ' + ID      $
                + ' Rate: '  + STRTRIM( D, 2 )  + ' >'     $
                + ' Limit: ' + STRTRIM( RATE_LIMIT, 2 ) + '"'
;
; Set up the UNIX 'mail' command.
;
  MAIL = 'mail -s ' + SUBJECT + ' Andy.Lau@noaa.gov < ' + MAIL
; MAIL = 'mail william.w.chadwick@noaa.gov -c Andy.Lau@noaa.gov '  $
;      +      '-s ' + SUBJECT + ' < ' + MAIL
; MAIL = 'mail $Alist $Elist -c Andy.Lau@noaa.gov -s ' + SUBJECT + ' < ' + MAIL
;
  SPAWN, MAIL  ; Send out the Notification by email.
;
  PRINT, [ SYSTIME(), MAIL, 'is sent.' ]
;
RETURN
END  ; SEND_UPLIFT_ALERT
;
; Callers: CHECK4TSUNAMI_EVENT or Users
; Revised: November 21st, 2014
;
PRO UPDATE_ALERT_STATUS, ALERT_STATUS_FILE,  $  ; Input: File name.
                         TIME,               $  ; Input: in JULDAY().
                         SEND_STATUS            ; Input: = 0 or 1.
;
; Open the ALERT_STATUS_FILE and read of the comment line.
; Note that the ALERT_STATUS_FILE has only 1 line.
;
  OPENR, STATUS_UNIT, ALERT_STATUS_FILE, /GET_LUN
  COMMENTS = 'for reading in the whole record line.'
  READF, STATUS_UNIT, COMMENTS
  CLOSE, STATUS_UNIT       ; Close the STATUS file.
;
; As an example, the COMMENTS will have the following line:
; ' 0 2014/11/07 15:44:25 ; Status and Date-Time'
;
; Retain only the comments after the ';' so that
; COMMENTS = '; Status and Date-Time'
;
  COMMENTS = STRMID( COMMENTS, STRPOS( COMMENTS, ';' ) )
;
; Open the ALERT_STATUS_FILE again with the Write option
; to rewrite the ALERT_STATUS_FILE.
;
  OPENW,  STATUS_UNIT, ALERT_STATUS_FILE
;
; If SEND = 1, it indicates an alert message has been sent.
; PRINTF, STATUS_UNIT,  SEND_STATUS,  SYSTIME(/JULIAN),  COMMENTS,  $
  PRINTF, STATUS_UNIT,  SEND_STATUS,     TIME,           COMMENTS,  $
  FORMAT="(I2,1X,C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2),X,A)"
;
  CLOSE,    STATUS_UNIT  ; Close the STATUS file.
  FREE_LUN, STATUS_UNIT
;
  PRINT, 'File: ' + ALERT_STATUS_FILE + ' is updated as.'
  PRINT,  SEND_STATUS,     TIME,           COMMENTS,  $
  FORMAT="(I2,1X,C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2),X,A)"
;
RETURN
END  ; UPDATE_ALERT_STATUS
