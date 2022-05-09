;
; File: CheckNANOdata4Alerts.pro
; This program is to replace the program: ChkNANOdata4Alerts.pro
; Started on February 10th, 2015.
;
; This IDL program will use the data in the IDL Save file: MJ03?-NANO.idl
; to check for Alert conditions.  When the conditions are met, Alerts'
; messages will be sent to the monitors (email addresses included below).
;
; There are 3 kinds of the Alerts:
; 1) A tsunami event when the |depth change: 5 min & current| is >  10 cm. 
; 2) A pre-eruption uplift event    when rate of depth change is > +10 cm/hr.
; 3) A co-eruption subsidence event when rate of depth change is < -10 cm/hr.
;
; This program also produces an Alert Statistics Table as an image file
;
; Any of the procedures below will be called by the routines in the
; file: ProcessRSNdata.pro
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on January 19, 2022 by Bill Chadwick to update email recipients
; Revised on June       7th, 2021
; Created on February   9th, 2015
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
  LAST_STATUS_TIME = JULDAY( MTH,D,Y, H,M,S )  ; November  21st, 2014
  PRINT, FORMAT="(A,X,C())", 'LAST_STATUS_TIME = ', LAST_STATUS_TIME
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
   TIME  = SYSTIME( /JULIAN ) - LAST_STATUS_TIME
   PRINT, 'SYSTIME( /JULIAN ) - LAST_STATUS_TIME = ', TIME
   PRINT, 'SYSTIME( /JULIAN ) = ', SYSTIME( /JULIAN )
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
; Revised: May      12th, 2015
;
PRO CHECK_NANO4ALERTS,   ID,  $ ; Input: 'MJ03D', 'MJ03E', 'MJ03F' or 'MJ03B.
                       RATE     ; Input: 2-D array: n x 3.
;
; The 2-D array: RATE has the following settings:
; RATE[*,0] = Date and Time in JULDAY() values.
; RATE[*,1] = Depth Differences in cm/5-minute.
; RATE[*,2] = Depth Differences in cm/hour of two 10-minute averaged Depths
;
  S = SIZE( RATE, /DIMENSION )
  N_RATE = S[0]        ; 1st Dimension and S[1] = 3.
  N      = N_RATE - 1  ; Use as the last 1st dimensional index for RATE.
;
; The following Limits used since the beginning till May 12th, 2015.
;
; HIGHT_LIMIT =  5  ; cm for      checking Tsunami events.
;  RATE_LIMIT =  5  ; cm/hour for checking Uplift & Subsidence events.
;
; Increased the Limits to 10 since May 12th, 2015 at 4:30 pm U.S. West Coast time.
;
  HIGHT_LIMIT = 10  ; cm for      checking Tsunami events.
   RATE_LIMIT = 10  ; cm/hour for checking Uplift & Subsidence events.
;
; PRINT, 'From CHECK_NANO4ALERTS:'
; HELP, ID, RATE, N_RATE, HIGHT_LIMIT, RATE_LIMIT
;
; Check the Depth Differences in RATE[*,1] (cm/5-minute) for Tsunami events.
;
  S = WHERE( ABS( RATE[0:N_RATE-1,1] ) GT HIGHT_LIMIT, N )
  IF N GT 0 THEN  BEGIN  ; There are Tsunami events
     FOR I = 0, N-1 DO  BEGIN
         TSUNAMI_EVENT, ID, RATE[S[I],0], RATE[S[I],1], HIGHT_LIMIT
     ENDFOR ; S
  ENDIF  ELSE  BEGIN  ; No Tsunami events.
     ALERT_STATUS_FILE = '~/4Chadwick/RSN/'    + ID + PATH_SEP() $
                       + 'TsunamiAlertStatus.' + ID
     SEND = ALERT_PERMISSION( ALERT_STATUS_FILE,  $
                    GET_STATUS_TIME=STATUS_TIME   )
     IF SEND LT 0 THEN  BEGIN ; The Last Alert message was sent a while ago.
        SEND =  0 ; For reseting the TSUNAMI_ALERT_STATUS_FILE.
        UPDATE_ALERT_STATUS, ALERT_STATUS_FILE, STATUS_TIME, SEND
     ENDIF
  ENDELSE  ; Tsunami events.
;
; Check the Rate Limits in RATE[*,1] for Uplift events.
; 
  S = WHERE( RATE[0:N_RATE-1,2] GT  RATE_LIMIT, N )
  IF N GT 0 THEN  BEGIN  ; There are Uplift events.
     FOR I = 0, N-1 DO  BEGIN  ;       Date/Time     Limit
         UPLIFT_EVENT,  ID, RATE[S[I],0], RATE[S[I],2],  RATE_LIMIT
     ENDFOR ; S
  ENDIF  ELSE  BEGIN  ; No Uplift events.
     ALERT_STATUS_FILE = '~/4Chadwick/RSN/'   + ID + PATH_SEP() $
                       + 'UpLiftAlertStatus.' + ID
     SEND = ALERT_PERMISSION( ALERT_STATUS_FILE,  $
                    GET_STATUS_TIME=STATUS_TIME   )
     IF SEND LT 0 THEN  BEGIN ; The Last Alert message was sent a while ago.
        SEND =  0 ; For reseting the UpLift Alert Status FILE.
        UPDATE_ALERT_STATUS, ALERT_STATUS_FILE, STATUS_TIME, SEND
     ENDIF
  ENDELSE  ; Uplift events.
;
; Check the Rate Limits in RATE[*,1] for Subsidence events.
; 
  S = WHERE( RATE[0:N_RATE-1,2] LT -RATE_LIMIT, N )
  IF N GT 0 THEN  BEGIN  ; There are Subsidence events.
     FOR I = 0, N-1 DO  BEGIN  ;       Date/Time     Limit
         SUBSIDE_EVENT, ID, RATE[S[I],0], RATE[S[I],2], -RATE_LIMIT
     ENDFOR ; S
  ENDIF  ELSE  BEGIN  ; No Subsidence events.
     ALERT_STATUS_FILE = '~/4Chadwick/RSN/'        + ID + PATH_SEP() $
                       + 'SubsidenceAlertStatus.'  + ID
     SEND = ALERT_PERMISSION( ALERT_STATUS_FILE,  $
                    GET_STATUS_TIME=STATUS_TIME   )
     IF SEND LT 0 THEN  BEGIN ; The Last Alert message was sent a while ago.
        SEND =  0 ; For reseting the Subsidence Alert Status FILE.
        UPDATE_ALERT_STATUS, ALERT_STATUS_FILE, STATUS_TIME, SEND
     ENDIF
  ENDELSE  ; Subsidence events.
;
RETURN
END  ; CHECK_NANO4ALERTS
;
; Callers: CHECK4SUBSIDE_EVENT or Users
; Revised: June       4th, 2021
;
PRO SEND_SUBSIDENCE_ALERT,  TIME,  $ ; Input: Detected Time in JULDAY().
        ID,  $  ; Input: 'MJ03D', 'MJ03E', 'MJ03F', or 'MJ03B'
         D,  $  ; Input: Rate Change in cm/hour.
    RATE_LIMIT  ; Input: in cm/hour.
;
; Set the Subsidence Event warning message file's name.
;
  MAIL = '~/4Chadwick/RSN/SubsidenceEvent.Msg'
;
; Define the email's SUBJECT
;
  SUBJECT  = '"' + STRING(  TIME, $
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
  SUBJECT += ' Subsidence Detected from: ' +  ID   $
          +  ' Rate: '  + STRTRIM( D, 2 ) + ' <'   $
          +  ' Limit: ' + STRTRIM( RATE_LIMIT, 2 ) + '"'
;
; Set up the UNIX 'mail' command.
;
; MAIL = 'mail -s ' + SUBJECT + ' Andy.Lau@noaa.gov < ' + MAIL
; MAIL = 'mail william.w.chadwick@noaa.gov -c Andy.Lau@noaa.gov '  $
;      +      '-s ' + SUBJECT + ' < ' + MAIL
  MAIL = 'mail -s ' + SUBJECT + ' -r Brian.Kahn@noaa.gov '  $
       + 'dskelley@uw.edu kawkaoe@uw.edu manalang@uw.edu wilcock@uw.edu ' $
       + 'nooners@uncw.edu jeff.beeson@noaa.gov ' $
       + 'william.w.chadwick@gmail.com Brian.Kahn@noaa.gov < ' + MAIL     ; (*)
; MAIL = 'mail -s ' + SUBJECT + ' -c Andy.Lau@noaa.gov $Alist $Elist < ' + MAIL
;
; (*) when using the UNIX mail command, it is best to put All the mail options
;     such as "-s" &/or "-c" 1st then the email addresses at the end.
;     Some system will Not like it if the order is reversed & gives Errors!
;     For example in the Caldera P.C.   June 29th, 2013
;
  SPAWN, MAIL  ; Send out the Notification by email.
;
  PRINT, [ SYSTIME(), MAIL, 'is sent.' ]
;
RETURN
END  ; SEND_SUBSIDENCE_ALERT
;
; Callers: CHECK4TSUNAMI_EVENT or Users
; Revised: June       4th, 2021
;
PRO SEND_TSUNAMI_ALERT,  TIME,  $ ; Input: Detected Time in JULDAY().
         ID,  $  ; Input: 'MJ03D', 'MJ03E', 'MJ03F', or 'MJ03B'
          D,  $  ; Input: Depth difference in cm.
    HIGHT_LIMIT  ; Input: in cm.
;
; Set the Tsunami Event warning message file's name.
;
  MAIL = '~/4Chadwick/RSN/TsunamiEvent.Msg'
;
; Define the email's SUBJECT
;
  SUBJECT  = '"' + STRING(  TIME, $
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
  SUBJECT += ' Tsunami Event Detected from: ' +  ID   $
          +  ' Rate: '  + STRTRIM( D, 2 ) + ' >'      $
          +  ' Limit: ' + STRTRIM( HIGHT_LIMIT, 2 ) + '"'
; SUBJECT = ' Tsunami Event Detected from: ' +  ID   $
;         + ' |Height|: ' + STRTRIM( D, 2 )  + ' >'  $
;         + ' Limit: '    + STRTRIM( HIGHT_LIMIT, 2 )  + '"'
;
; Set up the UNIX 'mail' command.
;
; MAIL = 'mail -s ' + SUBJECT + ' Andy.Lau@noaa.gov < ' + MAIL
  MAIL = 'mail -s ' + SUBJECT + ' -r Brian.Kahn@noaa.gov '  $
       + 'dskelley@uw.edu kawkaoe@uw.edu manalang@uw.edu wilcock@uw.edu ' $
       + 'nooners@uncw.edu jeff.beeson@noaa.gov ' $
       + 'william.w.chadwick@gmail.com Brian.Kahn@noaa.gov < ' + MAIL   ; (*)
; MAIL = 'mail -s ' + SUBJECT + ' -c Andy.Lau@noaa.gov $Alist < ' + MAIL
;
; (*) when using the UNIX mail command, it is best to put All the mail options
;     such as "-s" &/or "-c" 1st then the email addresses at the end.
;     Some system will Not like it if the order is reversed & gives Errors!
;     For example in the Caldera P.C.   June 29th, 2013
;
  SPAWN, MAIL  ; Send out the Notification by email.
;
  PRINT, [ SYSTIME(), MAIL, 'is sent.' ]
;
RETURN
END  ; SEND_TSUNAMI_ALERT
;
; Callers: CHECK4UPLIFT_EVENT or Users
; Revised: June       4th, 2021
;
PRO SEND_UPLIFT_ALERT,  TIME,  $ ; Input: Detected Time in JULDAY().
        ID,  $  ; Input: 'MJ03D', 'MJ03E', 'MJ03F', or 'MJ03B'
         D,  $  ; Input: Rate Change in cm/hour.
    RATE_LIMIT  ; Input: in cm/hour.
;
; Set the Uplift Event warning message file's name.
;
  MAIL = '~/4Chadwick/RSN/UpliftEvent.Msg'
;
; Define the email's SUBJECT
;
  SUBJECT  = '"' + STRING(  TIME, $
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
  SUBJECT += ' Uplift Event Detected from: ' +  ID   $
          +  ' Rate: '  + STRTRIM( D, 2 ) + ' <'     $
          +  ' Limit: ' + STRTRIM( RATE_LIMIT, 2 ) + '"'
; SUBJECT = '"' + 'Uplift Event Detected from: ' + ID      $
;               + ' Rate: '  + STRTRIM( D, 2 )  + ' >'     $
;               + ' Limit: ' + STRTRIM( RATE_LIMIT, 2 ) + '"'
;
; Set up the UNIX 'mail' command.
;
; MAIL = 'mail -s ' + SUBJECT + ' Andy.Lau@noaa.gov < ' + MAIL
; MAIL = 'mail william.w.chadwick@gmail.com -c Andy.Lau@noaa.gov '  $
;      +      '-s ' + SUBJECT + ' < ' + MAIL
  MAIL = 'mail -s ' + SUBJECT + ' -r Brian.Kahn@noaa.gov '  $
       + 'dskelley@uw.edu kawkaoe@uw.edu manalang@uw.edu wilcock@uw.edu ' $
       + 'nooners@uncw.edu jeff.beeson@noaa.gov ' $
       + 'william.w.chadwick@gmail.com Brian.Kahn@noaa.gov < ' + MAIL    ; (*)
; MAIL = 'mail -s ' + SUBJECT + ' -c Andy.Lau@noaa.gov $Alist $Elist < ' + MAIL
;
; (*) when using the UNIX mail command, it is best to put All the mail options
;     such as "-s" &/or "-c" 1st then the email addresses at the end.
;     Some system will Not like it if the order is reversed & gives Errors!
;     For example in the Caldera P.C.   June 29th, 2013
;
  SPAWN, MAIL  ; Send out the Notification by email.
;
  PRINT, [ SYSTIME(), MAIL, 'is sent.' ]
;
RETURN
END  ; SEND_UPLIFT_ALERT
;
; This procedure check for the co-eruption Subsidence event
; which will be detected by the following condition:
; When the Rate of Change from 2 averages: AVE1D & AVE2D
; is < RATE_LIMIT where RATE_LIMIT = -10 cm for example.
;
; Note that the main difference between this procedure and the
; procedure: CHECK4_UPLIFT_EVENT is the condition of the detection.
; In CHECK4_UPLIFT_EVENT, the condition is > RATE_LIMIT.
;
; Callers: CHECK_NANO4ALERTS or Users.
; Revised: January  23rd, 2015
;
PRO SUBSIDE_EVENT, ID,  $ ; Input : 'MJ03D', 'MJ03E', 'MJ03F', or 'MJ03B'
                 TIME,  $ ; Input : in JULDAY() value.
                LIMIT,  $ ; Inputs: in cm/hour & < RATE_LIMIT.
           RATE_LIMIT     ; Input : in cm/hour.
;
  ERUPTION_ALERT_STATUS_FILE = '~/4Chadwick/RSN/'   + ID + PATH_SEP() $ 
                             + 'SubsidenceAlertStatus.'  + ID
;
  PRINT, 'From CHECK4SUBSIDE_EVENT:'
  HELP, ID, LIMIT, RATE_LIMIT, ERUPTION_ALERT_STATUS_FILE
;
; Get permission for sending the Alert message.
;
  SEND = ALERT_PERMISSION( ERUPTION_ALERT_STATUS_FILE )
  IF ABS( SEND ) THEN  BEGIN  ; Send out the Alert message.
     SEND_SUBSIDENCE_ALERT, TIME, ID, LIMIT, RATE_LIMIT
     UPDATE_ALERT_STATUS,   ERUPTION_ALERT_STATUS_FILE, TIME, ABS( SEND )
  ENDIF  ; Send out the Alert message.
;
RETURN
END  ; SUBSIDE_EVENT
;
; Callers: CHECK_NANO4ALERTS or Users.
; Revised: April    24th, 2015
;
PRO TSUNAMI_EVENT, ID,  $ ; Input: 'MJ03D', 'MJ03E', 'MJ03F', or 'MJ03B'
                 TIME,  $ ; Input: in minutes.
                LIMIT,  $ ; Input: Depth Difference in cm.
          HIGHT_LIMIT     ; Input: in cm.
;
  TSUNAMI_ALERT_STATUS_FILE = '~/4Chadwick/RSN/'    + ID + PATH_SEP() $
                            + 'TsunamiAlertStatus.' + ID
;
  PRINT, 'From CHECK4TSUNAMI_EVENT:'
;
; Get the permission for sending the Alert message.
; SEND =  1 means Alert message can be sent, 0 means No
; SEND = -1 means Last Alert message was sent a while ago.
  SEND = ALERT_PERMISSION( TSUNAMI_ALERT_STATUS_FILE,  $
                           GET_STATUS_TIME=STATUS_TIME  )
  HELP, NAME='*'
;
  IF ABS( SEND ) THEN  BEGIN  ; Send out the Alert message.
     SEND_TSUNAMI_ALERT,  TIME, ID, LIMIT, HIGHT_LIMIT
     UPDATE_ALERT_STATUS, TSUNAMI_ALERT_STATUS_FILE, TIME, ABS( SEND )
  ENDIF  ; Send out the Alert message.
;
RETURN
END  ; TSUNAMI_EVENT
;
; This procedure check for the pre-eruption Uplift event
; which will be detected by the following condition:
; When the Rate of Change from 2 averages: AVE1D & AVE2D
; is > RATE_LIMIT where RATE_LIMIT = -5 cm for example.
;
; Note that the main difference between this procedure and the
; procedure: CHECK4_SUBSIDE_EVENT is the condition of the detection.
; In CHECK4_SUBSIDE_EVENT, the condition is < RATE_LIMIT.
;
; Callers: CHECK_NANO4ALERTS or Users.
; Revised: January  23rd, 2015
;
PRO UPLIFT_EVENT, ID,  $ ; Input : 'MJ03D', 'MJ03E', 'MJ03F', or 'MJ03B'
                TIME,  $ ; Input : in JULDAY() value.
               LIMIT,  $ ; Inputs: Average Depths in meters.
          RATE_LIMIT     ; Input : in cm/hour.
;
  ERUPTION_ALERT_STATUS_FILE = '~/4Chadwick/RSN/'   + ID + PATH_SEP() $ 
                             + 'UpLiftAlertStatus.' + ID
;
  PRINT, 'From CHECK4_UPLIFT_EVENT:'
  HELP, ID, LIMIT, RATE_LIMIT, ERUPTION_ALERT_STATUS_FILE
;
; Get permission for sending the Alert message.
;
  SEND = ALERT_PERMISSION( ERUPTION_ALERT_STATUS_FILE )
  IF ABS( SEND ) THEN  BEGIN  ; Send out the Alert message.
     SEND_UPLIFT_ALERT,   TIME, ID, LIMIT, RATE_LIMIT
     UPDATE_ALERT_STATUS, ERUPTION_ALERT_STATUS_FILE, TIME, ABS( SEND )
  ENDIF  ; Send out the Alert message.
;
RETURN
END  ; UPLIFT_EVENT
;
; Callers: CHECK4TSUNAMI_EVENT or Users
; Revised: November 21st, 2014
;
PRO UPDATE_ALERT_STATUS, ALERT_STATUS_FILE,  $  ; Input: File name.
                         TIME,               $  ; Input: in JULDAY().
                         SEND_STATUS            ; Input: = 0 or 1.
;
; Open the ALERT_STATUS_FILE and read the comment line.
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
