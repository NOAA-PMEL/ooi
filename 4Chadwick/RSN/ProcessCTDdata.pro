;
; File: ProcessCTDdata.pro
;
; This IDL program will process the provided CTD data files.
; The CTD data are collected by the OOI Regional Scale Nodes program
; statred on August 2017 from the Axial Summit.
;
; The provided CTD data file contains records from 3 different sensors:
; Density in Kg/m^3, Salinity in ppt and Temperatue in degrees C.
; All records contain Time Stamps in Seconds since /1/1/1900 at 00:00:00
; and Hr:Mm:Sd
;
; Note that the main procedure: PROCESS_CTD_FILES will be calling
; the procedure: PROCESS_CTD_DATA (the main logic of the processing),
;;the PLOT_*_DATA routines (stored in the file: PlotRSNdata.pro)
;;and the WRITE_LAST_PROCESSED_FILE_NAME procedure (in the file:
;;StatusFile4RSN.pro).
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on October    7th, 2019
; Created on October   16th, 2014
;

;
; This procedure will use the provided data to compute and return
; the 1-Minute averages.
;
; Callers: PROCESS_CTD_FILES or users.
;
PRO GET_CTD1MINUTE_AVE,  TIME,     KGM3,     PPT,     TEMP,  $ ; Inputs: 1-D arrays.
                     AVE_TIME, AVE_KGM3, AVE_PPT, AVE_TEMP   ;  Outputs: 1-D arrays.
;
; Note that the arrays: TIME, KGM3, PPT and TEMP are the same size and
; TIME is at every second and TIME is in the IDL JULDAY() value.
;
  N_DATA = N_ELEMENTS( TIME )   ; = N_ELEMENTS( KGM3, PPT or TEMP ).
;
; Compute the time range from TIME.
;
  D = TIME[N_DATA-1] - TIME[0]  ; Total time range in days.
  M = D*1440     ; Total time range in minutes.  1440 = 24x60 = Total minutes/day.
;
; Defining the output arrays.
;
     N1MIN =   CEIL( M )      ; Approximately total number of minutes to be saved.
  AVE_KGM3 = DBLARR( N1MIN )
  AVE_PPT  = DBLARR( N1MIN )
  AVE_TEMP = DBLARR( N1MIN ) 
  AVE_TIME = DBLARR( N1MIN )
;
; Define the AVE_TIME array with 1-Minute interval.
;
  CALDAT,    TIME[0],                      N,D,Y,H,M,S  ; where N = Month here.
  AVE_TIME = TIMEGEN( N1MIN, START=JULDAY( N,D,Y,H,M,0 ), STEP_SIZE=1, UNITS='MINUTES' )
;
; Compute the 1-Minute averages for the KGM3, PPT and TEMP data.
;
;
; Create a Time array with 1 extra time beyond the last TIME[N_DATA-1]
; so that last 1-Minute averages can be obtained from the FOR loop below.
;
                               D = 59.999D0/86400.0D0  ; 59 seconds in terms of day.
  T = [ TIME, TIME[N_DATA-1] + D ]  ; &  PRINT, FORMAT="(C())", T[N_DATA]
  S = LONG( 0 )
;
  FOR M = 0, N1MIN-1 DO  BEGIN
      H = AVE_TIME[M] + D   ; E.G. If AVE_TIME[M]=9/11/2018 16:15:00, then H=9/11/2018 16:15:59. 
      I = WHERE( T[S:N_DATA] GT H, N )
      IF N LE 0 THEN  BEGIN  ; No T[S:N_DATA] > AVE_TIME[M]
         AVE_TIME[M] = -1    ; Indicate No data.
      ENDIF  ELSE  BEGIN     ;  T[S+I[0]] > AVE_TIME[M] is found.
         I = S + I[0] - 1
         IF S GE I THEN  BEGIN  ; No data for the time at AVE_TIME[M].
            AVE_TIME[M] = -1    ; Indicate No data.
         ENDIF  ELSE  BEGIN     ; S < I means there are data for the time at AVE_TIME[M].
;           PRINT, FORMAT='(3(I9,X),3C())', M,S,I,T[[S,I]], AVE_TIME[M]  ; For chacking.
            AVE_KGM3[M] = MEAN( KGM3[S:I] )
            AVE_PPT [M] = MEAN(  PPT[S:I] )
            AVE_TEMP[M] = MEAN( TEMP[S:I] )
            S = I + 1  ; Update S to skip the processed data points.
         ENDELSE  ; Computing the 1-Minute averages.
      ENDELSE  ; Processing data for time at AVE_TIME[M].
  ENDFOR ; M
;
; Remove the missing minutes if any.
;
  S = WHERE( AVE_TIME GT 0, N, COMPLEMENT=I, NCOMPLEMENT=M )
;
  IF M LT N1MIN THEN  BEGIN  ; There are missing minutes that have no data.
     Y =  N1MIN - N  ; Total missing minutes.
     PRINT, 'In GET_CTD1MINUTE_AVE, ', Y, ' missing minutes found.'
     PRINT, 'Removing the missing minutes points.'
     AVE_KGM3 = AVE_KGM3[S]
     AVE_PPT  = AVE_PPT [S]  ; S = 1-D array of subscripts
     AVE_TEMP = AVE_TEMP[S]  ; that all AVE_TIME[S] > 0.
     AVE_TIME = AVE_TIME[S]
  ENDIF  ; Removing the missing minutes.
;
RETURN
END  ; GET_CTD1MINUTE_AVE
;
;
; Callers: Users.
; Revised: October 7th, 2019
;
PRO PROCESS_CTD_FILES, DATA_DIRECTORY,  $  ; Input: Directory name where the CTD files are.
                  CTD_SHORT_TERM_FILE      ; Input: IDL Save file name.
;
; DATA_DIRECTORY      =  '/data/chadwick/4andy/ooiapi/'            ; for example.
; CTD_SHORT_TERM_FILE = '~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl'  ; for example.
;
; Locate and Get all the CTD data files.
;
  CTD_FILE = FILE_SEARCH( DATA_DIRECTORY + '*.csv', COUNT=N_FILES )
;
  IF N_FILES LE 0 THEN  BEGIN  ; Not CTD data files are found.
     PRINT, SYSTIME() + ' In PROCESS_CTD_FILES, No CTD (*.csv) files are found in '  $
                      +   DATA_DIRECTORY
     PRINT, SYSTIME() + ' Return back to the Caller.'
     RETURN
  ENDIF
;
; Get the WORK_DIRECTORY from the CTD_SHORT_TERM_FILE name.  October 7th, 2019
; For example, CTD_SHORT_TERM_FILE = '~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl'
;         then      WORK_DIRECTORY = '~/4Chadwick/RSN/MJ03B/'
;
  WORK_DIRECTORY = FILE_DIRNAME( CTD_SHORT_TERM_FILE, /MARK_DIRECTORY )
;
; Get the STATUS_FILE file name.
;
; STATUS_FILE = '~/4Chadwick/RSN/MJ03B/LastProcessedCTD.FileName'
  STATUS_FILE = WORK_DIRECTORY + 'LastProcessedCTD.FileName'
;
; Check for the new CTD data file to process.
;
  GET_LUN, CTD_UNIT  ; for reading a CTD data file and the STATUS_FILE.
;
  S = FILE_SEARCH( STATUS_FILE, COUNT=N )
;
  IF N LE 0 THEN  BEGIN  ; No STATUS_FILE is found.
     PRINT, 'Cannot find the Status File: ' + STATUS_FILE
     LAST_PROCESSED_DATE      = -1
     LAST_PROCESSED_FILE_NAME = 'None'
  ENDIF  ELSE  BEGIN    ; STATUS_FILE exists. 
     LAST_PROCESSED_DATE      =  DOUBLE( 0 )  ; will be in JULADAY(). 
     LAST_PROCESSED_FILE_NAME = '/data/chadwick/4andy/ooiapi/2018-11-01.csv' ; e.g.
     OPENR, CTD_UNIT, STATUS_FILE
     READF, CTD_UNIT, LAST_PROCESSED_FILE_NAME
     READF, CTD_UNIT, LAST_PROCESSED_DATE, FORMAT='(C())'  ; in JULDAY().
     CLOSE, CTD_UNIT
  ENDELSE
;
  IF LAST_PROCESSED_FILE_NAME EQ 'None' THEN  BEGIN
     I = LONG( 0 )    ; for processing all the files in the CTD_FILE.
  ENDIF  ELSE  BEGIN  ; Look for the LAST_PROCESSED_FILE_NAME in CTD_FILE.
     I = WHERE( CTD_FILE EQ LAST_PROCESSED_FILE_NAME, S )
;    If No LAST_PROCESSED_FILE_NAME is found, I = 0; otherwise, use I[0]+1.
     I = ( S LE 0 ) ? LONG( 0 ) :   I[0]        ;
  ENDELSE
;
  IF I GE N_FILES THEN  BEGIN
     PRINT, SYSTIME() + ' In PROCESS_CTD_FILES, No New files available for processing yet!'
     FREE_LUN, CTD_UNIT
     RETURN
  ENDIF
;
; STOP
  PRINT, SYSTIME() + ' In PROCESS_CTD_FILES, Number files to be process: ', N_FILES - I
;
; For each CTD data file, do the following.
;
  FOR S = I, N_FILES - 1 DO  BEGIN
;
      PRINT, SYSTIME() + ' Processing CTD file: ' + CTD_FILE[S] + ' ...'
      N   = FILE_LINES( CTD_FILE[S] )  ; Get total records in the CTD_FILE[S].
      OPENR, CTD_UNIT, CTD_FILE[S]
;     RCD = 'For skipping the header line'
;     READF, CTD_UNIT, RCD  ; Skip the header line.
;     RCD = STRARR( N - 1 )
      RCD = STRARR( N )     ; June 21st, 2019
      READF, CTD_UNIT, RCD  ; Read in all the records & each record contains the following
    ;            for example: '3745671302.37, 16:15:02, 1034.769984, 34.516499, 2.436749'.
      CLOSE, CTD_UNIT       ; Close the current CTD_FILE[S].
;
;     Decode the records in the 1-D array: RCD that contain the CTD Time,
;     Density (Kg/m^3), Salinity (ppt) and Temperatue (C).
;
      DATA = STRSPLIT( RCD, ',', /EXTRACT )  ; DATA will be a LIST variable.
      CTD  = DATA.ToArray( )   ; Convert the DATA in LIST into a string array.
;
      KGM3 = DOUBLE( CTD[*,2] )  ; Density  in Kg/m^3.
      PPT  = DOUBLE( CTD[*,3] )  ; Salinity in ppt.
      TEMP = DOUBLE( CTD[*,4] )  ; Temperature in degrees C.
      TIME = DOUBLE( CTD[*,0] )  ; Seconds since 1/1/1900 at 00:00:00.
      TIME = TEMPORARY( TIME )/86400.0D0  $ ; Convert seconds into days
           + JULDAY( 1,1,1900,00,00,00 )    ; then into the IDL JULDAY() times.
;     where TIME interval is at 1 second.
;
;     Compute the 1-Minute Averages for KGM3, PPT & TEMP (Temperatre).
;
      GET_CTD1MINUTE_AVE,  TIME,   KGM3,   PPT,   TEMP,  $ ; Inputs: 1-D arrays.
                         A_TIME, A_KGM3, A_PPT, A_TEMP   ;  Outputs: 1-D arrays.
;
;     Accumulate the 1-Minute Averages for KGM3, PPT & TEMP.
;
      IF S LT 1 THEN  BEGIN  ; The 1st time.
         AVE_TIME =   TEMPORARY( A_TIME )
         AVE_KGM3 =   TEMPORARY( A_KGM3 )
         AVE_PPT  =   TEMPORARY( A_PPT  )
         AVE_TEMP =   TEMPORARY( A_TEMP )
      ENDIF  ELSE  BEGIN  ; S > 0
         AVE_TIME = [ TEMPORARY( AVE_TIME ), TEMPORARY( A_TIME ) ]
         AVE_KGM3 = [ TEMPORARY( AVE_KGM3 ), TEMPORARY( A_KGM3 ) ]
         AVE_PPT  = [ TEMPORARY( AVE_PPT  ), TEMPORARY( A_PPT  ) ]
         AVE_TEMP = [ TEMPORARY( AVE_TEMP ), TEMPORARY( A_TEMP ) ]
      ENDELSE
;
  ENDFOR  ; Processing each of the CTD_FILE[S].
;
; Append the cummulated 1-Minute Averages: AVE_TIME, AVE_KGM3, AVE_PPT, AVE_TEMP
; into the 7-Days storage file.
;
  SAVE_CTD_DATA,  AVE_TIME, AVE_KGM3, AVE_PPT, AVE_TEMP,  $ ; into
                  CTD_SHORT_TERM_FILE
; where CTD_SHORT_TERM_FILE = '~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl'  ; for example.
;
; Save the last STATUS_FILE.
;
  IF LAST_PROCESSED_DATE GT 0 THEN  BEGIN  ; STATUS_FILE exist.
;    Rename the STATUS_FILE to the following name.
;    S = '~/4Chadwick/RSN/MJ03B/L1B4ProcessedCTD.FileName'
     S = WORK_DIRECTORY + 'L1B4ProcessedCTD.FileName'
     FILE_MOVE, STATUS_FILE, S, /OVERWRITE  ; Rename the file.
  ENDIF
;
; Update the STATUS_FILE.
;
  LAST_PROCESSED_DATE      = SYSTIME()
  LAST_PROCESSED_FILE_NAME = CTD_FILE[N_FILES-1]  ;
;
; Write a new Updated STATUS_FILE.
;
  OPENW,  CTD_UNIT, STATUS_FILE
  PRINTF, CTD_UNIT, LAST_PROCESSED_FILE_NAME
  PRINTF, CTD_UNIT, LAST_PROCESSED_DATE    ; = Fri Oct  3 12:53:07 2014' e.g.
  CLOSE,  CTD_UNIT
  FREE_LUN, CTD_UNIT
;
  PRINT, SYSTIME() + ' Done processing CTD files.'
;
RETURN
END  ; PROCESS_CTD_FILES
;
; This procedure will reduce the length of the arrays stored in the
; SHORT_TERM_CTD_SAVE_FILE = ~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl' for example.
; The reduction is specified by the used.  Default is the last 6 days.
;
; Callers: Users.
;
PRO RESET_SHORT_TERM_CTD_SAVE_FILE,  SHORT_TERM_CTD_SAVE_FILE,  $  ; Input: File name.
                                     DAY2SAVE    ; Number of days of data to be saved.
;
  IF N_PARAMS() LT 2 THEN  BEGIN  ; DAY2SAVE is not defined.
     DAY2SAVE = 6  ; to save the last 6 days of the data.
  ENDIF  ; Define DAY2SAVE
;
; The SHORT_TERM_CTD_SAVE_FILE = ~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl' contains
; four 1-D arrays variables: CTD_TIME, DENSITY, SALINITY & CTD_TEMP
;
  RESTORE, SHORT_TERM_CTD_SAVE_FILE  ; Get the 4 1-D arrays.
;
  N = N_ELEMENTS( CTD_TIME )  ; All 4 arrays are the same size.
;
; Get time that is "DAY2SAVE" ago.  Note that CTD_TIME are in Julian day.
;
  T = CTD_TIME[N-1] - DAY2SAVE
;
; Look fot the time that is "DAY2SAVE" ago.
;
  S = WHERE( CTD_TIME GT T )
  S = S[0] - 1
;
  PRINT, SYSTIME() + ' In RESET_SHORT_TERM_CTD_SAVE_FILE'
;
  IF S[0] LE 0 THEN  BEGIN  ; All data are within DAY2SAVE.
     PRINT, SYSTIME() + ' All data are within ' + STRTRIM( DAY2SAVE, 2 )  $
                      + ' days.  Not update is needed.'
  ENDIF  ELSE  BEGIN  ; There are data to be skipped.
     PRINT, SYSTIME() + ' The data in following time range are skipped:'
     PRINT, FORMAT='(C())', CTD_TIME[[0,S[0]-1]]
     CTD_TIME = CTD_TIME[S:N-1]
     CTD_TEMP = CTD_TEMP[S:N-1]
      DENSITY =  DENSITY[S:N-1]
     SALINITY = SALINITY[S:N-1]
     SAVE, FILE=SHORT_TERM_CTD_SAVE_FILE, CTD_TIME, DENSITY, SALINITY, CTD_TEMP
     PRINT, SYSTIME() + ' File: ' + SHORT_TERM_CTD_SAVE_FILE + ' is updated.'
  ENDELSE
;
RETURN
END  ; RESET_SHORT_TERM_CTD_SAVE_FILE
;
; Append the cummulated 1-Minute Averages: TIME, KGM3, PPT, TEMP
; into the either all data or 7-Days storage file depended on the users.
;
; Callers: PROCESS_CTD_FILES or users.
;
PRO SAVE_CTD_DATA,  TIME, KGM3, PPT, TEMP,  $ ; Input: 1-D Arrays.
                    CTD_SAVE_FILE,          $ ; Input: IDL Save File name.
                    STATUS       ;  Output: "OK"=Updated or "Not OK"=No Updated.
;
; CTD_SHORT_TERM_FILE = '~/4Chadwick/RSN/MJ03B/CTD-MJ03B.idl'  ; for example.
;
; Restrieve the CTD data Array variables: CTD_TIME, DENSITY, SALINITY & CTD_TEMP
; They are assumed to be the same size.
;
; RESTORE, CTD_SAVE_FILE  ; Get the 4 array variables listed above.
;
  FILE   = FILE_INFO( CTD_SAVE_FILE )  ; Get the IDL Save File's information.
  STATUS = 'OK'                        ; Assume it is OK to start.
;  
  IF FILE.EXISTS THEN  BEGIN
     RESTORE, CTD_SAVE_FILE  ; Retrieve the past CTD data.
;    The Variables in IDL_FILE are assumed to be 
;    CTD_TIME, DENSITY, SALINITY & CTD_TEMP
     N = N_ELEMENTS( CTD_TIME )
     M = N_ELEMENTS(     TIME )
     PRINT, SYSTIME() + ' In SAVE_CTD_DATA,'
     IF CTD_TIME[N-1] LT TIME[0] THEN BEGIN  ; Time sequency is OK.
        PRINT, 'Appending New Data from ' + STRING( FORMAT='(C())', TIME[0] )  $
                                 + ' to ' + STRING( FORMAT='(C())', TIME[M-1]  )
        CTD_TIME = [ TEMPORARY( CTD_TIME ), TIME ]
        CTD_TEMP = [ TEMPORARY( CTD_TEMP ), TEMP ]
        DENSITY  = [ TEMPORARY( DENSITY  ), KGM3 ]
        SALINITY = [ TEMPORARY( SALINITY ),  PPT ]
     ENDIF ELSE IF  CTD_TIME[N-1] LT TIME[M-1] THEN  BEGIN
;       TIME[0] <=  CTD_TIME[N-1] <  TIME[M-1] Times Overlap.
;       Locate the Index: I so that TIME[I-1] <=  CTD_TIME[N-1] < TIME[I]. 
;       The Function: LOCATE_TIME_POSITION is in the file: SplitRSNdata.pro
        I = LOCATE_TIME_POSITION( TIME,  CTD_TIME[N-1] )
        PRINT, 'The Time Sequence is Overlapping at '  $
             + STRING( FORMAT='(2(C(),X))', TIME[I-1],  CTD_TIME[N-1]  )
;       Discard the all the values before I,     i.e., all the data
;       in [0:I-1] of the TIME, TEMP, etc. arrays will be discarded.
         CTD_TIME = [ TEMPORARY(  CTD_TIME ), TIME[I:M-1] ]
         CTD_TEMP = [ TEMPORARY(  CTD_TEMP ), TEMP[I:M-1] ]
         DENSITY  = [ TEMPORARY(  DENSITY  ), KGM3[I:M-1] ]
         SALINITY = [ TEMPORARY(  SALINITY ),  PPT[I:M-1] ]
     ENDIF  ELSE  BEGIN  ;
        IF  CTD_TIME[N-1] GE TIME[0] THEN  BEGIN  ;  Times Out of Order.
           PRINT, 'The Time Sequency is Out of Order!'
           PRINT, 'The Last Time of the stored data is: '   $
                + STRING( FORMAT='( C() )',  CTD_TIME[N-1] )
           PRINT, 'which  is  After  the 1st data time: '   $
                + STRING( FORMAT='( C() )', TIME[0] ) + ' of the New data.'
        ENDIF
        STATUS   = 'Not OK'
     ENDELSE
  ENDIF  ELSE  BEGIN  ; CTD_SAVE_FILE does not exist.
;    Assumming it is the 1st time.
      CTD_TIME = TIME
      CTD_TEMP = TEMP
      DENSITY  = KGM3
      SALINITY = PPT
  ENDELSE
;
; Save the Updated cumulative data if the STATUS is OK.
; Otherwise, only the new data will be saved into the
; IDL Save File: FILE_ID + '.idl' because, the 1st date & time in the
; new data is out of order with the last cumulative date & time.
;
  IF STATUS EQ 'OK' THEN  BEGIN
;    Save the updated arrays into a temporary file 1st then replace the
;    indicated file by the temporary file.  In this way if write to an IDL
;    save file caused a problem, hopefully the 2nd time the problem will
;    be solved by itself. 
     FILE = CTD_SAVE_FILE + 'save'  ; for a temporary file.
     SAVE, FILENAME=FILE,  CTD_TIME,  DENSITY, SALINITY, CTD_TEMP
     FILE_MOVE, FILE, CTD_SAVE_FILE, /OVERWRITE
     PRINT, SYSTIME() + ' IDL Save File: ' + CTD_SAVE_FILE + ' is updated.'
  ENDIF  ELSE  BEGIN  ; STATUS == 'Not OK'
;    If the  CTD_TIME[N-1] = TIME[M-1], it is assumed that Retrieved
;    data are already in the  CTD arrays.  So No need to save the Retrieved
;    data into a new file.
     IF (  CTD_TIME[N-1] - TIME[M-1] ) NE 0.0 THEN  BEGIN
     ;  Save only the newly received data into a different IDL save file name.
        FILE = 'CTD' +  STRING( SYSTIME(/JULIAN),  $
        FORMAT="(C(CDI2.2,CMOA,CYI,'-',CHI2.2,':',CMI2.2,':',CSI2.2))" ) + '.idl'
        SAVE, FILENAME=FILE, TIME, KGM3, PPT, TEMP
        PRINT, SYSTIME() + ' New IDL Save File: ' + FILE + ' is created.'
     ENDIF
  ENDELSE
;
RETURN
END  ; SAVE_CTD_DATA
