;
; Callers: CHECK4TILT_EVENT or Users
;
PRO SEND_EMAIL_ALERT, N  ; Input: Integer.
;
; Note that the TIME values is being used here for now.
;
; Set the Tsunami Event warning message file's name.
;
  MAIL = '~/4Chadwick/RSN/TestEmail.Msg'
;
; Define the email's SUBJECT
;
  SUBJECT = '"Test Message: ' + STRTRIM( N, 2 ) + ' from Andy on '  $
                              + SYSTIME() + '"'
;
; Set up the UNIX 'mail' command.
;
; MAIL = 'mail -s ' + SUBJECT + ' Andy.Lau@noaa.gov < ' + MAIL
; MAIL = 'mail william.w.chadwick@noaa.gov -c Andy.Lau@noaa.gov '  $
;      +      '-s ' + SUBJECT + ' < ' + MAIL
; MAIL = 'mail $List1 $List2 -c Andy.Lau@noaa.gov -s ' + SUBJECT + ' < ' + MAIL
  MAIL = 'mail -s ' + SUBJECT + ' -c Andy.Lau@noaa.gov $List1 $List2 < ' + MAIL
; MAIL = 'mail -s ' + SUBJECT + ' -c Andy.Lau@noaa.gov manalang@uw.edu < ' + MAIL
; MAIL = 'mail -s ' + SUBJECT + ' -c Andy.Lau@noaa.gov Andy.Lau@oregonstate.edu < ' + MAIL
;
  SPAWN, MAIL  ; Send out the Notification by email.
;
  PRINT, [ SYSTIME(), MAIL, 'is sent.' ]
;
RETURN
END  ; SEND_TILT_ALERT
;
PRO SEND_SUBSIDENCE_ALERT,  TIME,  $ ; Input: Detected Time in JULDAY().
            ID,  $ ; Input: 'MJ03D', 'MJ03E' or MJ03F'
             D,  $ ; Input: Rate Change in cm/hour.
    RATE_LIMIT     ; Input: in cm/hour.
;
; Set the Tsunami Event warning message file's name.
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
