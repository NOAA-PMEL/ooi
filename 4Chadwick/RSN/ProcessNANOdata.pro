;
; File: ProcessNANOdata.pro
; It will be called by the program: ProcessRSNdata.pro
;
; This IDL program will process the Newly Collected RSN-NANO data
; (by the program: ProcessRSNdata.pro).  The processing includes
; 1) Computing the Short-Term Rates and Save time,
; 2) Checking for earthquake & Tsuname events using the Short-Term Rates,
; 3) Plotting the Short-Term Rates,  and
; 4) Plotting the Newly Collected RSN-NANO data and from the beginning
;    to present.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on December   5th, 2017
; Created on February   9th, 2015
;

;
; Callers: PROCESS_RSN_FILES (in ProcessRSNdata.pro) or Users.
; Revised: December   5th, 2017
;
PRO PROCESS_NANO_DATA, FILE_ORIG,  $ ; Input = 'MJ03F', 'MJ03E', or 'MJ03D'.
                OUTPUT_DIRECTORY     ; Input names.
;
IF N_PARAMS() LT 2 THEN  BEGIN  ; OUTPUT_DIRECTORY is not provided.
   OUTPUT_DIRECTORY = '~/4Chadwick/RSN/'  ; for now.
ENDIF
;
; Get an IDL Save File name: '~/4Chadwick/RSN/MJ03E/MJ03E-NANO.idl' e.g.
;
  IDL_FILE = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()  $
;                             + FILE_ORIG + '-NANO.idl' ; Before March 11th, 2015
                     + '3Day' + FILE_ORIG + '-NANO.idl' ; After  March 11th, 2015
;
; Restrieve the NANO data arrays:
; NANO_TIME, NANO_PSIA, NANO_DETIDE, NANO_TEMP
;
  RESTORE, IDL_FILE
;
; Get an IDL Save File name for the Short-Term Rates, for example,
; '~/4Chadwick/RSN/MJ03E/EventDetectionParametersMJ03F.idl'
;
  IDL_FILE = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()  $
           + 'EventDetectionParameters' + FILE_ORIG + '.idl'
;
; Restrieve the Short-Term Rates' 2-D array: DATA in N_DATA x 3.
; where
; DATA[*,0] = Date and Time in JULDAY() values.
; DATA[*,1] = Depth Differences in cm/5-minute.
; DATA[*,2] = Depth Differences in cm/hour of two 10-minute averaged Depths
;
; RETRIEVE_DETECTED_RATES procedure is in the file:
; GetShortTermNANOdataProducts.pro
;
  RETRIEVE_DETECTED_RATES, IDL_FILE, DATA, STATUS  ; or
; RESTORE, IDL_FILE  ; to get DATA
;
IF STATUS EQ 0 THEN  BEGIN  ; IDL_FILE is not available.
   PRINT, [ 'From PROCESS_NANO_DATA, No DATA have been retrieved!',  $
            'No Detection Parameter will be computed!'  ]
   S = 0  ; Indicate No New Detection Parameters will be computed.
ENDIF  ELSE  BEGIN  ; DATA are available.
;
;  Locate where the within the DATA for computing the new Detection Parameter. 
;
            S = SIZE( DATA, /DIMENSION )
   N_DATA = S[0]        ; 1st Dimension and S[1] = 3.
   N      = N_DATA - 1  ; Use as the last 1st dimensional index for DATA.
;
;  Locate the last date/time in DATA from the NANO_TIME.
;
   S  = LOCATE_TIME_POSITION( NANO_TIME, DATA[N,0] )
;
;  Note that S index from LOCATE_TIME_POSITION() will have the following
;  property: NANO_TIME[S-1] <= DATA[N,0] < NANO_TIME[S]
;
   S -= 1  ; Assume NANO_TIME[S-1] = DATA[N,0].
;
;  Assign the NANO data into the COMMON NANO block's arrays.
;
;  COMMON NANO,    TIME, PSIA, TEMP, N_NANO
;  COMMON DETIDE,  METER ; for storing the de-tided press data in meters.
;
   N_NANO = N_ELEMENTS( NANO_TIME )
;    TIME = NANO_TIME  [S:N_NANO-1]
;    PSIA = NANO_PSIA  [S:N_NANO-1]
;    TEMP = NANO_TEMP  [S:N_NANO-1]
;   METER = NANO_DETIDE[S:N_NANO-1]
;  N_NANO = N_NANO - S  ; = N_ELEMENTS( TIME )
;
;  S = Index for NANO_TIME[S] where the 1st Detection Parameter
;      to be computed.  The next one will be M data points later.
;
   PRINT, 'The New Detection Parameter will be computed at ',  $
           NANO_TIME[S], FORMAT='(A,C())' 
;
;  Compute the Starting index: S for sending the NANO arrays,
;  and the Offset Starting index: I for starting the Detection Parameters
;  Note that only part of the 2 NANO arrays will be sent such as
;  NANO_TIME[S-20:*] and NANO_DETIDE[S-20:*].
;  Then the Offset index for the 2 sub-arrays above will be 60 + 20
;  where the 20 is the Offset and the M see below.
;
   M  = 60  ; = 15*4  ; <--15-minute Time Interval in terms of data points.
   S -= 20  ; Move back 20 points for the Short_Term Rates Calculations.
;
   IF S LT 0 THEN  BEGIN ; Not enough data points to move back.
      PRINT, 'Not enough data points to move back!  Will Start at the beginning.'
      S  = 0
   ENDIF
;
   I  = M + 20      ; The offset index for the next Detection Parameter.
   M  = N_NANO - S  ; Total points in the subarray: NANO_TIME[S:*] 
;
   IF I GE M THEN  BEGIN  ; Total Not enough data points.
;
      PRINT, 'The Offset Index: ' + STRTRIM( I, 2 )   $
           + ' >= ' + STRTRIM( M, 2 ) + '!'
      PRINT, 'Not Enough Data Points.  Detection Parameters will not be computed!'
      S = 0  ; Indicate No New Detection Parameters will be computed.
;
   ENDIF  ELSE  BEGIN  ; Compute the Detection Parameters & Check for Events.
;
;     The GET_DETECTION_PRARMETERS routine is located in the
;     file: GetDetectionParameters.pro
;
          M = 60 ; = 15*4  ; <--15-minute Time Interval in terms of data points.
      GET_DETECTION_PRARMETERS, NANO_TIME[S:*], NANO_DETIDE[S:*],  $
          I,  $ ; Starting point for the 2 arrays above.
          M,  $ ; The next incrument for computing the Detection Parameters.  
          RATE  ; 2-D Array output: 3 x n.
          RATE = TRANSPOSE( TEMPORARY( RATE ) )  ; Change RATE to n x 3.
;
;     Append the newly computed RATE into the array: DATA
;
      PRINT, 'The Current (DATA) and New (RATE) parameters arrays:'
      HELP, DATA, RATE
      DATA = [ TEMPORARY( DATA ), RATE ]
      PRINT, 'The Update parameters array:'
      HELP, DATA
;
;     The SAVE_DETECTION_PARAMTERS routine is located in the
;     file: GetDetectionParameters.pro
;     SAVE_DETECTION_PARAMTERS, IDL_FILE, DATA  ; for interactive used only.
;     and it is not being used; because, it will ask users for input to
;     either Save, Not Save or Skip.
;
      SAVE, FILE=IDL_FILE, DATA  ; Save the Detection Parameters.
      PRINT, IDL_FILE + ' is Updated.'
;
;     Detect whether there are Tsunami/Upleft/Subsidence events or not.
;     Note that CHECK_NANO4ALERTS procedure is located in the file:
;     CheckNANOdata4Alerts.pro
;                            
      CHECK_NANO4ALERTS, FILE_ORIG, RATE
      S = 1  ; Indicate New Detection Parameters have been computed.
;
   ENDELSE  ; Compute the Detection Parameters & Check for Events.
;
ENDELSE  ; Checking the DATA, Computing the Detection Parameters & Checking for Events.
;
; The CHECK_OPEN_WINDOW_STATUS routine is located in the
; file: ProcessRSNdata.pro
;
  CHECK_OPEN_WINDOW_STATUS, STATUS  ; Can a PIXMAP window be opened?
;
IF STATUS EQ 'OK' THEN  BEGIN       ; If Yes, then Plot the data.
   IF S GT 0 THEN  BEGIN  ; New Detection Parameters have been computed.
;     IDL_FILE = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()  $
;              + 'EventDetectionParameters' + FILE_ORIG + '.idl' ; 1/2015
;     PLOT_SHORT_TERM_DATA, is in the file: PlotShortTermDataProducts.pro
;     PLOT_SHORT_TERM_DATA, IDL_FILE, [-3,1], SHOW_PLOT=0,UPDATE_PLOT=1
      PLOT_SHORT_TERM_DATA, IDL_FILE, [-7,1], SHOW_PLOT=0,UPDATE_PLOT=1  ; Started on 12/5/2017
   ENDIF  ; PLOT_SHORT_TERM_DATA.
   IDL_FILE = OUTPUT_DIRECTORY + FILE_ORIG + PATH_SEP()  $
;                              + FILE_ORIG + '-NANO.idl' ; Before March 11th, 2015
                      + '3Day' + FILE_ORIG + '-NANO.idl' ; After  March 11th, 2015
;  Note that parameter [-3,1] was used before March  11th,2015 and the
;  [-3,0] with Only the 3-Day Plot is being used after March 11th, 2015
;  PLOT_NANO_DATA, IDL_FILE, [-3,1], SHOW_PLOT=0,UPDATE_PLOTS=1
;  PLOT_NANO_DATA, IDL_FILE, [-3,0], SHOW_PLOT=0,UPDATE_PLOTS=1
   PLOT_NANO_DATA, IDL_FILE, [-7,0], SHOW_PLOT=0,UPDATE_PLOTS=1  ; Started on 12/5/2017
;  Note that the PLOT_NANO_DATA routine is in the file: PlotNANOdata.pro
ENDIF
;
RETURN
END  ; PROCESS_NANO_DATA
