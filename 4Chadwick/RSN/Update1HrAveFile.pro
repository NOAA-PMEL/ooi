;
; File: Update1HrAveFile.pro
;
; This IDL program will Update the IDL Save files:
; MJ03[D/E/F]1HrAve[LILY/IRIS].idl containing the Long-Term
; (Cumulative) 1-Hr Long average LILY Tilt Data.
;
; This program will use the Short-Term (3-Day) data in the
; 3DayMJ03[D/E/F]-[LILY/IRIS].idl to obtain the Hourly averages
; first.  Then append them to their respective Cumulative
; Long-Term average Tilt Data in the MJ03[D/E/F]1HrAve[LILY/IRIS].idl
; files.
;
; The Short-Term (3-Day) data  and Long-Term (Cumulative) data
; files: [3Day]MJ03[D/E/F]-[HEAT/IRIS/LILY/NANO].idl
; are created & updated by the RSN data processing programs:
; ProcessRSNdata.pro and UpdateRSNsaveFiles.pro
;
; The main procedures is UPDATE_1HR_AVERAGE_FILE.
;
; This program requires the functions in the programs: SplitRSNdata.pro
; GetATD-RTMD.pro and GetLongTermNANOdataProducts.pro in order to run.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on October   26th, 2018
; Created on October    1st, 2015
;

;
; Callers: UPDATE_1HR_AVERAGE_FILE or users.
; Revised: November 11th, 2015
;
PRO GET_NEW_1HR_AVE_DATA,  RSN_SAVE_FILE,  $ ; Input: "3DayMJ03F-LILY.idl", e.g.
          TIME, XTILT, YTILT,  $  ; Outputs: 1-D arrays of the 1-Hr average data.
          STATUS                  ; Output : 1=New Average Data is readied & 0=No New Data.
;
STATUS = FILE_INFO( RSN_SAVE_FILE )  ; Get the file information.
;
IF NOT STATUS.EXISTS THEN  BEGIN
   PRINT, 'IDL Save File: ' + RSN_SAVE_FILE   + ' does not exist!'
   PRINT, SYSTIME() +  ' No New 1-Hr average will be available.'
   STATUS = BYTE( 0 )  ; No New Average Data.
ENDIF  ELSE  BEGIN  ; RSN_SAVE_FILE Exists.
   RESTORE,   RSN_SAVE_FILE  ; Retrieve array variables: LILY_TIME, LILY_XTILT & LILY_YTILT e.g.
   IF STRPOS( RSN_SAVE_FILE, 'IRIS' ) GT 0 THEN  BEGIN  ; It is for the IRIS data.
      M  = 'IRIS'
      N  = N_ELEMENTS( IRIS_TIME  )   ; = N_ELEMENTS( IRIS_XTILT or IRIS_YTILT )
      TM =  TEMPORARY( IRIS_TIME  )
      XT =  TEMPORARY( IRIS_XTILT )   ; Rename the arrays' names.
      YT =  TEMPORARY( IRIS_YTILT )
   ENDIF ELSE IF STRPOS( RSN_SAVE_FILE, 'LILY' ) GT 0 THEN  BEGIN  ; It is for the LILY data.
      M  = 'LILY'
      N  = N_ELEMENTS( LILY_TIME  )   ; = N_ELEMENTS( LILY_XTILT or LILY_YTILT )
      TM =  TEMPORARY( LILY_TIME  )
      XT =  TEMPORARY( LILY_XTILT )   ; Rename the arrays' names.
      YT =  TEMPORARY( LILY_YTILT )
   ENDIF ELSE IF STRPOS( RSN_SAVE_FILE, 'HEAT' ) GT 0 THEN  BEGIN  ; It is for the HEAT data.
      M  = 'HEAT'
      N  = N_ELEMENTS( HEAT_TIME  )   ; = N_ELEMENTS( HEAT_XTILT or HEAT_YTILT )
      TM =  TEMPORARY( HEAT_TIME  )
      XT =  TEMPORARY( HEAT_XTILT )   ; Rename the arrays' names.
      YT =  TEMPORARY( HEAT_YTILT )
   ENDIF ELSE BEGIN  ; Not a RSN data
      M = 'None'
      PRINT, 'IDL Save File: ' + RSN_SAVE_FILE   + ' is Not a 3DayMJ03[D/E/F-[LILY/IRIS/HEAT].idl file!'
      PRINT, SYSTIME() +  ' No New 1-Hr average will be available.'
      STATUS = BYTE( 0 )  ; No New Average Data.
   ENDELSE  ; Checking RSN Data
   IF M NE 'None' THEN  BEGIN
      GET_ATD, XT, YT, TM,      $ ; Inputs: 1-D arrays from the NEW_LILY_DATA_FILE.
               TM[0], TM[N-1],  $ ; Inputs: Time Ranges in JULDAY()'s for the data.
               3600,            $ ; Input  : Number of seconds of data to be averaged.
               XTILT, YTILT,    $ ; Outputs: 1-D array of Averged Tilt values.
                TIME              ; Output : 1-D array of JULDAY()'s.
      M  = N_ELEMENTS( TIME ) ; = N_ELEMENTS( XTILT or YTILT )
      M -= 1                  ; Point to the last elements in TIME.
      STATUS = 'New 1-Hr Average data are from '  $
    + STRING( FORMAT="(C(CMOI2.2,'/',CDI2.2,'/',CYI,X,CHI2.2,':',CMI2.2,':',CSI2.2))", TIME[0] )
      STATUS = STATUS + ' to '               $
    + STRING( FORMAT="(C(CMOI2.2,'/',CDI2.2,'/',CYI,X,CHI2.2,':',CMI2.2,':',CSI2.2))", TIME[M] )
      PRINT,   STATUS
      STATUS = BYTE( 1 )  ; New Average Data.
   ENDIF  ; Appending the New 1-Hr Average Data.
ENDELSE  ; Get New 1-Hr Average Data.
;
; HELP, NAME='*'
; STOP
;
RETURN
END  ; GET_NEW_1HR_AVE_DATA
;
; Callers: UPDATE_1HR_AVERAGE_FILE or users.
; Revised: October  26th, 2018
;
PRO UPDATE_1HR_AVERAGE_DATA, ONE_HR_AVE_FILE,  $ ; Input: "MJ03D1HrAveLILY.idl" e.g.
            TIME,         $ ; Input : 1-D array of JULDAY()'s.
           XTILT, YTILT,  $ ; Inputs: 1-D arrays of the average Tilt values.
           STATUS           ; Output: 1=LILY1HR_AVE_FILE is Updated & 0=No Update.
;
  STATUS = FILE_INFO( ONE_HR_AVE_FILE  )  ; Get the file information.
;
IF NOT STATUS.EXISTS THEN  BEGIN
   PRINT, 'Input File: ' + ONE_HR_AVE_FILE  + ' does not exist!'
   PRINT, SYSTIME() +  ' No Update will be Done.'
   STATUS = BYTE( 0 )  ; No Update.
ENDIF  ELSE  BEGIN  ; ONE_HR_AVE_FILE  Exists.
   RESTORE, ONE_HR_AVE_FILE   ; Retrieve the Long-Term Cumulative average Tilt Data
;  There will be 3 arrays: T (in JULDAY()'s), XT, YT variables.
   N = N_ELEMENTS( T )     ; = N_ELEMENTS( XT ) = N_ELEMENTS( YT )
   M = N_ELEMENTS( TIME )  ; = N_ELEMENTS( XTILT/YTILT )
   IF TIME[M-1] LT T[N-1] THEN  BEGIN  ; No New Data to Update.
      PRINT, 'The time for the last data point: '  $
    + STRING( FORMAT="(C(CMOI2.2,'/',CDI2.2,'/',CYI,X,CHI2.2,':',CMI2.2,':',CSI2.2))", TIME[M-1] )
      PRINT, 'is Before the last data point in the Long-Term data set ',  $
    + STRING( FORMAT="(C(CMOI2.2,'/',CDI2.2,'/',CYI,X,CHI2.2,':',CMI2.2,':',CSI2.2))",    T[N-1] )
      PRINT, 'Input File: ' + ONE_HR_AVE_FILE  + ' does not exist!'
      PRINT, SYSTIME() +  ' No Update will be Done.'
      STATUS = BYTE( 0 )  ; No Update.
   ENDIF  ELSE  BEGIN  ; T[N-1] <= TIME[M-1].  New Data exisit.
;
;     Using the time of the last data point in the Long-Term arrays to
;     Locate the index in the New data arrays where the new data start.
;     Note the function: LOCATE_TIME_POSITION() is in the
;     file: ~/4Chadwick/RSN/SplitRSNdata.pro
;
      S = LOCATE_TIME_POSITION( TIME, T[N-1] )
;     Note that the result from above will be:
;     TIME[S-1] <= T[N-1] < TIME[S]
;     So that TIME[S:N-1] will be the data to be appended
;     in to the Long-Term data.
;
      IF ( S GT 0 ) THEN  S -= 1  ; October 26th, 2018
      M -= 1
;
; HELP, NAME='*'
; STOP
;
      IF ( T[N-1] - TIME[S] ) LT 0 THEN  BEGIN  ; There is a data gap.
          T = [ TEMPORARY(  T ),  TIME[S:M] ]
         XT = [ TEMPORARY( XT ), XTILT[S:M] ]
         YT = [ TEMPORARY( YT ), YTILT[S:M] ]
      ENDIF  ELSE  BEGIN  ; TIME[S] == T[N-1] & T[N-1] will be replaced by TIME[S].
          T = [        T[0:N-2],  TIME[S:M] ]
         XT = [       XT[0:N-2], XTILT[S:M] ]
         YT = [       YT[0:N-2], YTILT[S:M] ]
      ENDELSE
;
      SAVE, /VERBOSE, FILE=ONE_HR_AVE_FILE , T, XT, YT  ; Update the Cumulative Data.
;
      STATUS = 'Updated the new data from '  $
    + STRING( FORMAT="(C(CMOI2.2,'/',CDI2.2,'/',CYI,X,CHI2.2,':',CMI2.2,':',CSI2.2))", TIME[S] )
      STATUS = STATUS + ' to '               $
    + STRING( FORMAT="(C(CMOI2.2,'/',CDI2.2,'/',CYI,X,CHI2.2,':',CMI2.2,':',CSI2.2))", TIME[M] )
      PRINT,   STATUS
      PRINT, 'File: ' + ONE_HR_AVE_FILE  + ' is Updated on ' + SYSTIME()
      STATUS = BYTE( 1 )  ; ONE_HR_AVE_FILE  is Updated.
;
   ENDELSE
ENDELSE  ; Update the ONE_HR_AVE_FILE 
;
RETURN
END  ; UPDATE_1HR_AVERAGE_DATA
;
; Callers: Users.
; Revised: November 11th, 2015
;
PRO UPDATE_IRIS1HR_AVERAGE_FILE, IRIS1HR_AVE_FILE,  $ ; Input: "MJ03D1HrAveIRIS.idl" e.g.
                               NEW_IRIS_DATA_FILE     ; Input:  "3DayMJ03D-IRIS.idl" e.g.
;
; Locate the input files.
;
  IRIS1HR_AVE = FILE_INFO(   IRIS1HR_AVE_FILE )
  NEW_DATA    = FILE_INFO( NEW_IRIS_DATA_FILE )
;
IF IRIS1HR_AVE.EXISTS AND NEW_DATA.EXISTS THEN  BEGIN  ; Update the LILY1HR_AVE_FILE.
   GET_NEW1HR_AVE_DATA, NEW_IRIS_DATA_FILE,  $
                        TIME, XTILT, YTILT   ; Outputs: 1-D arrays of the 1-Hr average data.
   UPDATE_1HR_AVERAGE_DATA, IRIS1HR_AVE_FILE,  $ ; Get data in LILY1HR_AVE_FILE &
                          TIME, XTILT, YTILT     ; add the new hour average data.
ENDIF  ELSE  BEGIN  ; either 1 or Both Files do not exist.
   IF NOT LILY1HRAVE.EXISTS THEN  BEGIN
      PRINT, 'Input File: ' + IRIS1HR_AVE_FILE + ' does not exist!'
   ENDIF
   IF NOT NEW_DATA.EXISTS THEN  BEGIN
      PRINT, 'Input File: ' + NEW_IRIS_DATA_FILE + ' does not exist!'
   ENDIF
   PRINT, SYSTIME() + ' No Update will be Done.'
ENDELSE
;
RETURN
END  ; UPDATE_IRIS1HR_AVERAGE_FILE
;
; Callers: Users.
; Revised: November 11th, 2015
;
PRO UPDATE_1HR_AVERAGE_FILE, ONE_HR_AVE_FILE,  $ ; Input: "MJ03D1HrAveLILY.idl" e.g.
                           NEW_RSN_DATA_FILE     ; Input:  "3DayMJ03D-LILY.idl" e.g.
;
; Locate the input files.
;
  ONE_HR_AVE   = FILE_INFO(   ONE_HR_AVE_FILE  )
  NEW_RSN_DATA = FILE_INFO( NEW_RSN_DATA_FILE  )
;
IF ONE_HR_AVE.EXISTS AND NEW_RSN_DATA.EXISTS THEN  BEGIN  ; Update the ONE_HR_AVE_FILE .
   GET_NEW_1HR_AVE_DATA, NEW_RSN_DATA_FILE,   $
                         TIME, XTILT, YTILT,  $  ; Outputs: 1-D arrays of the 1-Hr average data.
                         STATUS        ; Output : 1=New Average Data is readied & 0=No New Data.
   IF STATUS GT 0 THEN  BEGIN  ; Compute the 1-Hr average.
      UPDATE_1HR_AVERAGE_DATA, ONE_HR_AVE_FILE,  $ ; Get data in LILY1HR_AVE_FILE &
                             TIME, XTILT, YTILT    ; add the new hour average data.
   ENDIF
ENDIF  ELSE  BEGIN  ; either 1 or Both Files do not exist.
   IF NOT ONE_HR_AVE.EXISTS THEN  BEGIN
      PRINT, 'Input File: ' + ONE_HR_AVE_FILE  + ' does not exist!'
   ENDIF
   IF NOT NEW_RSN_DATA.EXISTS THEN  BEGIN
      PRINT, 'Input File: ' + NEW_RSN_DATA_FILE  + ' does not exist!'
   ENDIF
   PRINT, SYSTIME() + ' No Update will be Done.'
ENDELSE
;
RETURN
END  ; UPDATE_1HR_AVERAGE_FILE
