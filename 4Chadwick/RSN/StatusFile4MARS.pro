;
; File: StatusFile4MARS.pro
;
; This IDL program contains routines to Read and Print out the
; Last MARS data file name and the processing date.
;
; Revised on October 10th, 2014
; Created on October  3rd, 2014
;

;
; Callers: GET_LAST_PROCESSED_FILE_NAME & WRITE_LAST_PROCESSED_FILE_NAME
;
FUNCTION GET_FILE_ORIGIN, MARS_FILE_NAME  ; Input: Strings.
;
; The MARS_FILE_NAME will be, for example,
; = '/MARS/mj03d/BOTPTA303_10.31.9.6_9338_20140924T0000_UTC.dat'
;
; Determine the file's origin (Power Junction-Box) from the file name.
; For this project, it will be looking for the following file types:
; A301 - MJ03F - Central Caldera        (LILY s/n N9676)
; A302 - MJ03E - East    Caldera        (LILY s/n N9652)
; A303 - MJ03D - International District (LILY s/n N9655)
;
  S    = STRPOS( MARS_FILE_NAME, 'A30' )
  TYPE = STRMID( MARS_FILE_NAME, S, 4  )  ; = 'A301', 'A302' or 'A303'
;
  CASE TYPE OF
      'A301' : FILE_ORIG = 'MJ03F'
      'A302' : FILE_ORIG = 'MJ03E'
      'A303' : FILE_ORIG = 'MJ03D'
       ELSE  : BEGIN
               PRINT, 'Unknown File: ',  MARS_FILE
               FILE_ORIG = ''
       END
  ENDCASE
;
RETURN, FILE_ORIG
END   ; GET_FILE_ORIGIN
;
; Callers: PROCESS_MARS_FILES or Users.
;
PRO GET_LAST_PROCESSED_FILE_NAME, MARS_FILE,  $ ;  Input; File name.
                                  DIRECTORY,  $ ;  Input: Path name.
                   LAST_PROCESSED_FILE_NAME,  $ ; Output: String.
                   LAST_PROCESSED_DATE          ; Output: in JULADAY().
;
; Define the Output variables before reading them from the STATUS_FILE.
; Note that the name assigns to the LAST_PROCESSED_FILE_NAME is an example
; what the last processed file name would looks like.
;
LAST_PROCESSED_FILE_NAME = '/MARS/mj03d/BOTPTA303_10.31.9.6_9338_20140924T0000_UTC.dat'
LAST_PROCESSED_DATE      = DOUBLE( 0 )  ; will be in JULADAY(). 
;
; Get the STATUS_FILE name.  It is assumed the STATUS_FILE will be located
; in the DIRECTORY = '/MARS/MJ03D/' for example.
;
; FILE_ORIG = STRMID( DIRECTORY, STRPOS( DIRECTORY, 'MJ03' ), 5 )
; FILE_ORIG will be = 'MJ03D', 'MJ03E', or 'MJ03F'.
; STATUS_FILE = DIRECTORY + PATH_SEP() + 'LastProcessedFileName.' + FILE_ORIG
;
; User the MARS_FILE name to deteremine the the file's origin
; (Power Junction-Box) from the file name.
; For this project, it will be looking for the following file types:
; A301 - MJ03F - Central Caldera        (LILY s/n N9676)
; A302 - MJ03E - East    Caldera        (LILY s/n N9652)
; A303 - MJ03D - International District (LILY s/n N9655)
;
  FILE_ORIG = GET_FILE_ORIGIN( MARS_FILE )
; FILE_ORIG will be = 'MJ03D', 'MJ03E', or 'MJ03F'.
;
; The STATUS_FILE name will be, for example,
;     STATUS_FILE = '/MARS/MJ03E/LastProcessedFileName.MJ03E'
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
   READF, UNIT, LAST_PROCESSED_DATE, FORMAT='(C())'  ; in JULADAY().
   CLOSE,    UNIT
   FREE_LUN, UNIT
ENDELSE
;
RETURN
END  ; GET_MARS_FILE_STATUS
;
; Callers: PROCESS_MARS_FILES or Users.
;
PRO WRITE_LAST_PROCESSED_FILE_NAME,  LAST_MARS_FILE_NAME,  $ ; Input
                                     OUTPUT_DIRECTORY        ; Path Name.
;
; The examples of the LAST_MARS_FILE_NAME & OUTPUT_DIRECTORY are
; LAST_MARS_FILE_NAME = '/MARS/mj03d/BOTPTA303_10.31.9.6_9338_20140924T0000_UTC.dat'
; OUTPUT_DIRECTORY    = '/MARS/MJ03D/'
;
; User the MARS_FILE name to deteremine the the file's origin
; (Power Junction-Box) from the file name.
; See the FUNCTION GET_FILE_ORIGIN for the Junction-Box names.
;
  FILE_ORIG = GET_FILE_ORIGIN( LAST_MARS_FILE_NAME )
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
   TYPE = OUTPUT_DIRECTORY + FILE_ORIG + '/'  ; = '/MARS/Output/MJ03D/' e.g.
;
; Define the Output File (STATUS_FILE) name.  So that the STATUS_FILE will
; = '/MARS/Output/MJ03D/LastProcessedFileName.MJ03D'  for example.
;
STATUS_FILE = TYPE + 'LastProcessedFileName.' + FILE_ORIG
;
; If the file: 'LastProcessedFileName.MJ03D' for example is already exist,
; Rename it to  L1B4ProcessedFileName.MJ03D'.
;
   S = FILE_INFO( STATUS_FILE )
IF S.EXISTS THEN  BEGIN  ; STATUS_FILE is already exist.
   STATUS_OUTPUT = TYPE + 'L1B4ProcessedFileName.' + FILE_ORIG
   FILE_MOVE, STATUS_FILE, STATUS_OUTPUT   ; Rename the file.
   STATUS_OUTPUT = 0  ; Clear it before reusing it.
ENDIF
;
; Open the STATUS_FILE='/MARS/Output/MJ03D/LastProcessedFileName.MJ03D' e.g.
; and print out the Last Processed MARS Data File name and its processed date.
;
OPENW,  STATUS_OUTPUT, STATUS_FILE, /GET_LUN
;  
PRINTF, STATUS_OUTPUT, LAST_MARS_FILE_NAME
PRINTF, STATUS_OUTPUT, SYSTIME()         ; = 'Fri Oct  3 12:53:07 2014' E.G.G
;
CLOSE,    STATUS_OUTPUT
FREE_LUN, STATUS_OUTPUT
;
RETURN
END  ; WRITE_LAST_PROCESSED_FILE_NAME
