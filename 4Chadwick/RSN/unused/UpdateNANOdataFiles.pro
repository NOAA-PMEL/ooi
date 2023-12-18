;
; File: UpdateNANOdataFiles.pro
;
; This program requires the rouitnes in the Files:
; PrintRSNdata2Files.pro
; and  This program Only works in the UNIX environment.
;
; Programmer: T-K Andy Lau NOAA/PMEL/Acoustic Program HMSC Newport Oregon.
;
; Revised on May       18th  2015
; Created on May       18th  2015
;

;
; Callers: Users.
;
PRO UPDATE_NANO_DATA2FILE, IDL_FILE,  $ ; Input: IDL Save File name.
                        OUTPUT_FILE     ; Input: Output data file name.
;
; This program assumes the RSN NANO data files are located at the
; current directory: ~/4Chadwick/RSN/ for example, set up by the callers.
;
; CD, '~/4Chadwick/RSN/'
;
; Setup the UNIX "tail" command line.
; Note that the --lines=1 means only show the very last line in the
; OUTPUT_FILE = '/data/lau/4Chadwick/RSN/Apr-May2015MJ03E-NANO.Data'  ; e.g.
;
  COMMAND = 'tail --lines=1 ' + OUTPUT_FILE
;
; Send out the UNIX command and Retrieve the results into a string
; array variable: RCD which will be only 1 element.
;
  SPAWN, COMMAND, RCD
;
; Note that RCD[0] will look like the following example.
; '2015/05/16 22:05:15        2242.4371        1502.3528        3.8324783'
; Only the Date and Time will be used.
;
  PRINT, 'The Data file to be updated: ', OUTPUT_FILE
  PRINT, 'Its last record is ', RCD
;
; Read off the Date and Time as the JULDAY() value.
;
  S = 0.0D0  ; for storing the Date and Time.
  READS, FORMAT="(C(CYI,X,CMOI2.2,X,CDI2.2,X,CHI2.2,X,CMI2.2,X,CSI2.2))",  $ 
         RCD, S
;
  NEXT = 15.0D0/86400.0D0  ; 15 seconds in term of Day.
  NDAY = 1                 ; 24 Hours or 1 Day.
;
; Get the new data set assumming they are not more than a day.
; The new data will be printed into a temporary data file: NANO.Data.
;
  PRINT_NANO_DATA2FILE, IDL_FILE, 'NANO.Data',  $
                        S + NEXT,  $ ; The Start time.
                        S + NDAY     ; The Enb   time.
;
  RCD = ''  ; Reset before reused.
  PRINT, 'The 1st  2 lines of the new data set:'
  SPAWN, 'head -2  NANO.Data',  RCD  ; Show the 1st  2 lines of the new data set.
  PRINT, 'The Last 2 lines of the new data set:'
  SPAWN, 'tail --lines=2 NANO.Data'  ; Show the last 2 lines of the new data set.
;
; Read off the Date and Time as the JULDAY() value.
;
  T = 0.0D0  ; for storing the Date and Time.
  READS, FORMAT="(C(CYI,X,CMOI2.2,X,CDI2.2,X,CHI2.2,X,CMI2.2,X,CSI2.2))",  $
         RCD[0], T
;
  IF S GT T THEN  BEGIN  ; Assuming the No new data set yet.
     PRINT, 'No New Data yet!'
     PRINT, OUTPUT_FILE + ' File is Not updated.'
  ENDIF  ELSE  BEGIN     ; S < t.  Assuming there are new data.
;    Define the UNIX command: "cat" with ">>" output so that the new data
;    will be appended into the OUTPUT_FILE
     COMMAND = 'cat NANO.Data >> ' + OUTPUT_FILE
     SPAWN, COMMAND  ; Appending the new data into the OUTPUT_FILE
     PRINT, OUTPUT_FILE + ' File is updated.  The last 2 records are: '
     SPAWN, 'tail --lines=2 ' + OUTPUT_FILE
  ENDELSE
;
  FILE_DELETE,  /VERBOSE, 'NANO.Data'  ; Remove the temporary data file.
;
RETURN
END  ; UPDATE_NANO_DATA2FILE
