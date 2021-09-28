;
; File: CheckTiltData4Alerts.pro
;
; This IDL program will use the data passed by the procedure:
; PROCESS_RSN_DATA in the file: ProcessRSNdata.pro
; to check for X & Y Tilts conditions.  When the conditons are met,
; Alerts' messages will be sent to the monitors.
;
; There are 2 kinds of the Alerts:
; 1) X or Y Tilts' values Below -300 microrandian/degrees.
; 2) X or Y Tilts' values Above +300 microrandian/degrees.
;
; Any of the procedures below will be called by the routines in the
; file: ProcessRSNdata.pro
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on June       7th, 2021
; Created on November  20th, 2014
;

;
; This is the main procedure for calling the procedure:
; CHECK4TILT_EVENT.
;
; Callers: PROCESS_RSN_DATA or Users.
;
PRO CHECK_LILY4ALERTS,  ID,  $ ; Input : 'MJ03D', 'MJ03E', or 'MJ03F'
                      S, N     ; Inputs: Indexes for the arrays in COMMON
;
; The following arrays in the COMMON LILY are defined in the procedure
; ALLOCATE_STORGES in the file: ProcessRSNdata.pro
;
; Note that only the arrays TIME, XTILT and YTILT will be used here.
; 
  COMMON LILY, TIME, XTILT, YTILT, RTM,     TEMP, RTD,     N_LILY
;
; Send the arrays with the range that contain the new data
; to check for the X & Y Tilts condition in µ-randians.
; Note the 300 imples there will be an alert when tilts >= 300 or <= -300.   
;
  CHECK4TILT_EVENT, ID, 'LILY', 'X', TIME[S:N], XTILT[S:N], 300
  CHECK4TILT_EVENT, ID, 'LILY', 'Y', TIME[S:N], YTILT[S:N], 300
;
; Save the values used for the Detections.
; SAVE_DETECTION_PARAMTERS, ID, D, AVE1D, AVE2D, DATA_GAPS
;
RETURN
END  ; CHECK_LILY4ALERTS
;
;
; Callers: CHECK_LILY4ALERTS or Users.
;
PRO CHECK4TILT_EVENT,   ID,  $ ; Input : 'MJ03D', 'MJ03E' or MJ03F'
                    SENSOR,  $ ; Input : 'LILY', 'HEAT', 'IRIS' 
                        XY,  $ ; Input : 'X' or 'Y'
               TIME,  TILT,  $ ; Inputs: 1-D arrays in JULDAY() & microrandians.
                      LIMIT    ; Input : in microrandians or degrees.
;
  TILT_ALERT_STATUS_FILE = '~/4Chadwick/RSN/' + ID + PATH_SEP()   $ 
                         + SENSOR + '-' + XY + 'tiltAlertStatus.' + ID
; For example = '~/4Chadwick/RSN/MJ03D/LILY-XtiltAlertStatus.MJ03D'
;
  PRINT, 'From CHECK4TILT_EVENT:'
  HELP, ID, SENSOR, XY, TIME, TILT, TILT_ALERT_STATUS_FILE
;
; Locate all the values' positions in the TILT that their values are
; Above or Equal to +LIMIT.
;
; S = WHERE( TILT GE LIMIT, N )
;
; Locate the Max. & Min. TILT values and their respective array's indexes.
;
; M = MAX( TILT, B, MIN=N, SUBSCRIPT_MIN=S )  ;
;
; PRINT, 'Max. ' + XY + ': ', TILT[B]
; PRINT, 'Min. ' + XY + ': ', TILT[S]
;
; Locate the array's indexes: S & N so that TIME[S] to TIME[N] = 1 minute.
; Note the the LOCATE__TIME_POSITION function is in the file: SplitRSNdata.pro
;
  N = N_ELEMENTS( TIME ) - 1  ; Last data point.  Same as N_ELEMENTS( TILT ).
  M = 60.0D0/86400.0D0        ; 60/86400 = 1 minutes in term of day.
  S = LOCATE_TIME_POSITION( TIME, TIME[N] - M )
  HELP, M, B, N, S, LIMIT
;
IF S LT 0 THEN  BEGIN
   PRINT, 'Do not have 1-Minute long data!  No Tilt Alert Tests.'
   PRINT, FORMAT='(A,C())', 'First Time: ', TIME[0]
   PRINT, FORMAT='(A,C())', 'Last  Time: ', TIME[N]
   RETURN  ; to Caller.
ENDIF
;
; Compute the average of the 1 minute of the TILT values.
;
  M = MEAN( TILT[S:N], /DOUBLE )
  PRINT, 'Computed 1-minute average: ', STRTRIM( M, 2 )
  PRINT, 'From the 1-minute Time Range: '
  PRINT, FORMAT='(C(),A,C())', TIME[S], ' - ', TIME[N]
;
; Detect Tilt Event >= +LIMIT.
; Note that for the LILY's Tilts the the Limit is in microrandians;
; for the HEAT's or IRIS's Tilts the the Limit is in degrees.
;
; IF TILT[B] GE  LIMIT THEN  BEGIN ; Max. TILT value >= +LIMIT.
;
IF M GE  LIMIT THEN  BEGIN ; Max. TILT value >= +LIMIT.
;  Get permission for sending the Alert message.
;  Note that ALERT_PERMISSION function is located
;  in the file: CheckNANOdata4Alerts.pro
   SEND = ALERT_PERMISSION( TILT_ALERT_STATUS_FILE )
   IF ABS( SEND ) THEN  BEGIN  ; Send out the Alert message.
;       SEND_TILT_ALERT,        ID, SENSOR, XY, TIME[B],TILT[B],  LIMIT
;     UPDATE_TILT_ALERT_STATUS, TILT_ALERT_STATUS_FILE, TIME[B],  ABS( SEND )
        SEND_TILT_ALERT,        ID, SENSOR, XY, TIME[N],  M    ,  LIMIT
      UPDATE_TILT_ALERT_STATUS, TILT_ALERT_STATUS_FILE, TIME[N],  ABS( SEND )
   ENDIF  ; Send out the Alert message.
;  Save the values used for the Detections.
;  SAVE_TILT_CHECKED_DATA, ID, SENSOR, XY, TIME[B], TILT[B], LIMIT
ENDIF  ; Event Detected: Max. TILT value >= +LIMIT.
;
; Detect Tilt Event <= -LIMIT.
;
; IF TILT[S] LE -LIMIT THEN  BEGIN ; Min. TILT value <= -LIMIT.
;
IF M LE -LIMIT THEN  BEGIN ; Min. TILT value <= -LIMIT.
;  Get permission for sending the Alert message.
   SEND = ALERT_PERMISSION( TILT_ALERT_STATUS_FILE )
   IF ABS( SEND ) THEN  BEGIN  ; Send out the Alert message.
;       SEND_TILT_ALERT,        ID, SENSOR, XY, TIME[S],TILT[S], -LIMIT
;     UPDATE_TILT_ALERT_STATUS, TILT_ALERT_STATUS_FILE, TIME[S],  ABS( SEND )
        SEND_TILT_ALERT,           ID, SENSOR, XY, TIME[N],  M, -LIMIT
      UPDATE_ALERT_STATUS, TILT_ALERT_STATUS_FILE, TIME[N],  ABS( SEND )
;     UPDATE_TILT_ALERT_STATUS, TILT_ALERT_STATUS_FILE, TIME[N],  ABS( SEND )
   ENDIF  ; Send out the Alert message.
;  Save the values used for the Detections.
;  SAVE_TILT_CHECKED_DATA, ID, SENSOR, XY, TIME[S], TILT[S], LIMIT
ENDIF  ; Event Detected: Min. TILT value <= -LIMIT.
;
RETURN
END  ; CHECK4TILT_EVENT
;
; Callers: CHECK4TILT_EVENT or Users
; Revised: September 30th, 2019
;
PRO SEND_TILT_ALERT,  ID,  $ ; Input : 'MJ03D', 'MJ03E' or MJ03F'
                  SENSOR,  $ ; Input : 'LILY', 'HEAT', 'IRIS' 
                      XY,  $ ; Input : 'X' or 'Y'
              TIME, TILT,  $ ; Inputs: values in JULDAY() & microrandians.
                   LIMIT     ; Input : in microrandians or degrees.
;
; Note that the TIME values is being used here for now.
;
; Set the Tsunami Event warning message file's name.
;
  MAIL = '~/4Chadwick/RSN/TiltEvent.Msg'
;
; Define the email's SUBJECT
;
  SIGN    = ( LIMIT GT 0 ) ? ' >=' : ' <='
  SUBJECT = '"Event Detected from: ' + ID + '. '       $
          +   SENSOR + '-' + XY + 'tilt'               $
          + ' Value: ' + STRTRIM( TILT,  2 )   + SIGN  $
          + ' Limit: ' + STRTRIM( LIMIT, 2 )   + '"'
;
; Set up the UNIX 'mail' command.
;
; MAIL = 'mail -s ' + SUBJECT + ' Andy.Lau@noaa.gov < ' + MAIL
; MAIL = 'mail -s ' + SUBJECT + ' -c Andy.Lau@noaa.gov '  $
;      + 'william.w.chadwick@gmail.com < ' + MAIL ; September 30th, 2019
;      + 'william.w.chadwick@noaa.gov < ' + MAIL  ; <-- Bill's Old email address.
  MAIL = 'mail -s ' + SUBJECT + ' -r Brian.Kahn@noaa.gov $Tlist < ' + MAIL  ; (*)
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
END  ; SEND_TILT_ALERT
;
; Callers: CHECK4TILT_EVENT or Users
;
PRO UPDATE_TILT_ALERT_STATUS, ALERT_STATUS_FILE,  $  ; Input: File name.
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
; TIME indicate when the Tilt value is Above or Below the set limit.
;
  PRINTF, STATUS_UNIT,  SEND_STATUS,  TIME,              COMMENTS,  $
  FORMAT="(I2,1X,C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2),X,A)"
;
  CLOSE,    STATUS_UNIT  ; Close the STATUS file.
  FREE_LUN, STATUS_UNIT
;
  PRINT, 'File: ' + ALERT_STATUS_FILE + ' is updated as.'
  PRINT,  SEND_STATUS,     TIME,             COMMENTS,  $
  FORMAT="(I2,1X,C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2),X,A)"
;
RETURN
END  ; UPDATE_TILT_ALERT_STATUS
