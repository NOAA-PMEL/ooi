;
; File: StatusFile4RSN.pro
;
; This IDL program contains 2 parts.
;
; 1st) to Read and Print out the
; Last RSN data file name and the processing date.  They are
; done (October 2014) by the follwing 3 routines: GET_FILE_ORIGIN,
; GET_LAST_PROCESSED_FILE_NAME and WRITE_LAST_PROCESSED_FILE_NAME.
;
; 2nd) to Lock a status file by setting a flag so that other
; processing programs will not be run until the status file is
; Free.  This is done (since March 2015) by the follwing routines:
;
; Revised on August  24th, 2017
; Created on October  3rd, 2014
;

;
; Begin of 1st) Part. October 10th, 2014
;
; Callers: GET_LAST_PROCESSED_FILE_NAME & WRITE_LAST_PROCESSED_FILE_NAME
; Revised: August  24th, 2017
;
FUNCTION GET_FILE_ORIGIN, RSN_FILE_NAME  ; Input: Strings.
;
; The RSN_FILE_NAME will be, for example,
; = '/RSN/mj03d/BOTPTA303_10.31.9.6_9338_20140924T0000_UTC.dat'
;
; Determine the file's origin (Power Junction-Box) from the file name.
; For this project, it will be looking for the following file types:
; A301 - MJ03F - Central Caldera        (LILY s/n N9676)
; A302 - MJ03E - East    Caldera        (LILY s/n N9652)
; A303 - MJ03D - International District (LILY s/n N9655)
; A304 - MJ03B - Ashes Vent Fiels       (LILY s/n N96??)  Since August 16th, 2017.
;
  S    = STRPOS( RSN_FILE_NAME, 'A30' )
  TYPE = STRMID( RSN_FILE_NAME, S, 4  )  ; = 'A301', 'A302' or 'A303'
;
  CASE TYPE OF
      'A301' : FILE_ORIG = 'MJ03F'
      'A302' : FILE_ORIG = 'MJ03E'
      'A303' : FILE_ORIG = 'MJ03D'
      'A304' : FILE_ORIG = 'MJ03B'   ; Added on August  24th, 2017
       ELSE  : BEGIN
               PRINT, 'Unknown File: ',  RSN_FILE_NAME
               FILE_ORIG = ''
       END
  ENDCASE
;
RETURN, FILE_ORIG
END   ; GET_FILE_ORIGIN
;
; Callers: PROCESS_RSN_FILES or Users.
; Revised: October 10th, 2014
;
PRO GET_LAST_PROCESSED_FILE_NAME,  RSN_FILE,  $ ;  Input; File name.
                                  DIRECTORY,  $ ;  Input: Path name.
                   LAST_PROCESSED_FILE_NAME,  $ ; Output: String.
                   LAST_PROCESSED_DATE          ; Output: in JULADAY().
;
; Define the Output variables before reading them from the STATUS_FILE.
; Note that the name assigns to the LAST_PROCESSED_FILE_NAME is an example
; what the last processed file name would looks like.
;
LAST_PROCESSED_FILE_NAME = '/RSN/mj03d/BOTPTA303_10.31.9.6_9338_20140924T0000_UTC.dat'
LAST_PROCESSED_DATE      = DOUBLE( 0 )  ; will be in JULADAY(). 
;
; Get the STATUS_FILE name.  It is assumed the STATUS_FILE will be located
; in the DIRECTORY = '/RSN/MJ03D/' for example.
;
; FILE_ORIG = STRMID( DIRECTORY, STRPOS( DIRECTORY, 'MJ03' ), 5 )
; FILE_ORIG will be = 'MJ03D', 'MJ03E', or 'MJ03F'.
; STATUS_FILE = DIRECTORY + PATH_SEP() + 'LastProcessedFileName.' + FILE_ORIG
;
; User the RSN_FILE name to deteremine the the file's origin
; (Power Junction-Box) from the file name.
; For this project, it will be looking for the following file types:
; A301 - MJ03F - Central Caldera        (LILY s/n N9676)
; A302 - MJ03E - East    Caldera        (LILY s/n N9652)
; A303 - MJ03D - International District (LILY s/n N9655)
; A304 - MJ03B - Ashes Vent Fiels       (LILY s/n N96??)  Since August 16th, 2017.
;
  FILE_ORIG = GET_FILE_ORIGIN( RSN_FILE )
; FILE_ORIG will be = 'MJ03D', 'MJ03E', or 'MJ03F'.
;
; The STATUS_FILE name will be, for example,
;     STATUS_FILE = '/RSN/MJ03E/LastProcessedFileName.MJ03E'
;
  STATUS_FILE = DIRECTORY + FILE_ORIG + PATH_SEP()  $
              + 'LastProcessedFileName.' + FILE_ORIG
;
; Look for the STATUS_FILE.
;
  UNIT = FILE_SEARCH( STATUS_FILE, COUNT=N )
;
IF N LE 0 THEN  BEGIN  ; No STATUS_FILE is found.
   PRINT, 'Cannot find the Status File: ' + STATUS_FILE
   LAST_PROCESSED_DATE      = -1
   LAST_PROCESSED_FILE_NAME = 'None'
ENDIF  ELSE  BEGIN    ; STATUS_FILE exists. 
          UNIT = 0    ; Free it before reusing.
   OPENR, UNIT, STATUS_FILE, /GET_LUN
   READF, UNIT, LAST_PROCESSED_FILE_NAME
   READF, UNIT, LAST_PROCESSED_DATE, FORMAT='(C())'  ; in JULDAY().
   CLOSE,    UNIT
   FREE_LUN, UNIT
ENDELSE
;
RETURN
END  ; GET_LAST_PROCESSED_FILE_NAME
;
; Callers: PROCESS_RSN_FILES or Users.
; Revised: October 10th, 2014
;
PRO WRITE_LAST_PROCESSED_FILE_NAME,  LAST_RSN_FILE_NAME,  $ ; Input
                                     OUTPUT_DIRECTORY        ; Path Name.
;
; The examples of the LAST_RSN_FILE_NAME & OUTPUT_DIRECTORY are
; LAST_RSN_FILE_NAME = '/RSN/mj03d/BOTPTA303_10.31.9.6_9338_20140924T0000_UTC.dat'
; OUTPUT_DIRECTORY    = '/RSN/MJ03D/'
;
; User the RSN_FILE name to deteremine the the file's origin
; (Power Junction-Box) from the file name.
; See the FUNCTION GET_FILE_ORIGIN for the Junction-Box names.
;
  FILE_ORIG = GET_FILE_ORIGIN( LAST_RSN_FILE_NAME )
; FILE_ORIG will be = 'MJ03D', 'MJ03E', or 'MJ03F'.
;
; Define the Output File (STATUS_FILE) name.
;
   TYPE = STRMID( OUTPUT_DIRECTORY, STRLEN( OUTPUT_DIRECTORY )-1, 1 )
IF TYPE NE PATH_SEP() THEN  BEGIN  ; TYPE Not = '/' or '\'
   OUTPUT_DIRECTORY += PATH_SEP()  ; Append the '/' or '/'.
ENDIF
;
; Define the Directory Path for the STATUS_FILE file.
;
   TYPE = OUTPUT_DIRECTORY + FILE_ORIG + '/'  ; = '/RSN/Output/MJ03D/' e.g.
;
; Define the Output File (STATUS_FILE) name.  So that the STATUS_FILE will
; = '/RSN/Output/MJ03D/LastProcessedFileName.MJ03D'  for example.
;
STATUS_FILE = TYPE + 'LastProcessedFileName.' + FILE_ORIG
;
; If the file: 'LastProcessedFileName.MJ03D' for example is already exist,
; Rename it to  L1B4ProcessedFileName.MJ03D'.
;
   S = FILE_INFO( STATUS_FILE )
IF S.EXISTS THEN  BEGIN  ; STATUS_FILE is already exist.
   STATUS_OUTPUT = TYPE + 'L1B4ProcessedFileName.' + FILE_ORIG
   FILE_MOVE, STATUS_FILE, STATUS_OUTPUT, /OVERWRITE  ; Rename the file.
   STATUS_OUTPUT = 0  ; Clear it before reusing it.
ENDIF
;
; Open the STATUS_FILE='/RSN/Output/MJ03D/LastProcessedFileName.MJ03D' e.g.
; and print out the Last Processed RSN Data File name and its processed date.
;
OPENW,  STATUS_OUTPUT, STATUS_FILE, /GET_LUN
;  
PRINTF, STATUS_OUTPUT, LAST_RSN_FILE_NAME
PRINTF, STATUS_OUTPUT, SYSTIME()         ; = 'Fri Oct  3 12:53:07 2014' e.g.
;
CLOSE,    STATUS_OUTPUT
FREE_LUN, STATUS_OUTPUT
;
RETURN
END  ; WRITE_LAST_PROCESSED_FILE_NAME
;
; End   of 1st) Part.
;
; Begin of 2nd) Part.  March 3rd, 2015
;
; Callers: PROCESS_RSN_FILES, UPDATE_RSN_SAVE_FILES or Users.
; Revised: March    3rd, 2015
;
PRO FREE_PROCESSING, STATUS_FILE,  $ ;  Input: '/RSN/MJ03E/MJ03E.ProcessingStatus' e.g.
    PRINT_NOTE=NOTE  ; Input: 'Comments from the users.'
;
IF NOT KEYWORD_SET( NOTE ) THEN  BEGIN
   NOTE = 'Currently Data are not being processed.'
ENDIF
;
  OPENW,  UNIT, STATUS_FILE, /GET_LUN
  PRINTF, UNIT, '0 ; ' + SYSTIME() + ' ' + NOTE
  CLOSE,  UNIT
FREE_LUN, UNIT
;
RETURN
END  ; FREE_PROCESSING
;
; Callers: PROCESS_RSN_FILES, UPDATE_RSN_SAVE_FILES or Users.
; Revised: March    3rd, 2015
;
PRO LOCK_PROCESSING, STATUS_FILE,  $ ;  Input: '/RSN/MJ03E/MJ03E.ProcessingStatus' e.g.
                     STATUS,       $ ; Output: 1=Lock, 0=Cannot Lock.
    PRINT_NOTE=NOTE  ; Input: 'Comments from the users.'
;
STATUS = FIX( 0 )  ; for reading the number in the STATUS_FILE.
;
OPENR, UNIT, STATUS_FILE, /GET_LUN
READF, UNIT, STATUS  ; STATUS = 0 or 1.
CLOSE, UNIT
;
IF STATUS EQ 1 THEN  BEGIN  ; Other program has locked 1st.
   STATUS =  0  ; Indicated the process "Cannot" be Locked.
ENDIF  ELSE  BEGIN  ; STATUS == 0
;  No RSN programs are being run.  Lock the process.
   IF NOT KEYWORD_SET( NOTE ) THEN  BEGIN
      NOTE = 'Data are currently being processed.'
   ENDIF
   OPENW,  UNIT, STATUS_FILE
   PRINTF, UNIT, '1 ; ' + SYSTIME() + ' ' + NOTE
   CLOSE,  UNIT
   STATUS =  1  ; Indicated the process is Locked.
ENDELSE
;
FREE_LUN, UNIT
;
RETURN
END  ; LOCK_PROCESSING
;
; End   of 2nd) Part.
