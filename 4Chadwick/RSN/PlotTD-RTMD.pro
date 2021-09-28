;
; File: PlotTD-RTMD.pro
;
; This IDL program will generate figures using the Resultant Tilt Magnitudes
; and Directions for the RSN the LILY or Tilt data Differences.
;
; The figures will be either N-Day plot or the Cumulative data Plot.
;
; The RSN data are collected by the OOI Regional Scale Nodes program
; statred on August 2014 from the Axial Summit.
;
; The program  will be calling the following procedures
; PRO GET_TILT_DIFFERENCES  in the file: GetTiltDiff.pro
;
; This program also calls the routines in the files:
; Plot[LILY/NANO/TILTS]data.pro
;
; Programmer: T-K Andy Lau NOAA/PMEL/Acoustic Program HMSC Newport Oregon.
;
; Revised on August    23rd, 2017
; Created on April     21st, 2015
;

;
; Callers: PLOT_RSN_DATA, PROCESS_RSN_DATA or Users
;
PRO PLOT_TD_RTMD,   IDL_FILE,   $ ; Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2- or 3-Element integer to indicate what to plot.
    CHECK4RELEVELING=RLT,       $ ; Input: 2xN array for JULDAY()s. 
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -3, 1 ]  means Plot the last 3 days, data & All the data.
; When zero value is used.  That means No Plotting for the respected term.
;
; The RLT is a 2xN array where RLT[0,i] & RLT[1,i] contain the Start & End
; times (in JULDAY()s) of the Releveling Period respectively.
;
IF NOT KEYWORD_SET( SAVE_PLOTS ) THEN  BEGIN
   SAVE_PLOTS = 0B  ; Not Save.
ENDIF
;
; This procedure assume the IDL_FILE has been verified its existence.
; The IDL_FILE can either MJ03F-LILY.idl or MJ03D-IRIS.idl for example.
;
; Retrieve the data from the IDL_FILE and the array variables will be
; IRIS_TIME, IRIS_XTILT, IRIS_YTILT  or
; LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_RTM,     LILY_TEMP, LILY_RTD
; Note that LILY_COMPASS & LILY_VOLTAGE array values will not be used here.
;
; PRINT, SYSTIME() + ' Retrieving the Tilt Data in the file: ' + IDL_FILE + ' ...'
; RESTORE, IDL_FILE  ; Get the *_XTILT, *_YTILT and *_TIME
;
; Rename the *_XTILT, *_YTILT and *_TIME to XTILT, YTILT and TIME respectively.
; Note that the units for the X & Y tilts are in microradians (µradians) from the
; LILY sensors.  The others: IRIS & HEAT, their tilts' units are in degrees.
; The conversion is 1 degree = 10000/57.2957795 = 17453.2925 µradians.
; June 11th, 2015
;
; IF STRPOS( IDL_FILE, 'HEAT' ) GE 0 THEN  BEGIN  ; HEAT Tilts are being used.
;     TIME = TEMPORARY( HEAT_TIME  )
;    XTILT = TEMPORARY( HEAT_XTILT )*17453.2925   ; Convert the tilt from
;    YTILT = TEMPORARY( HEAT_YTILT )*17453.2925   ; Degrees to µradians.
;   SENSOR = 'HEAT'
; ENDIF ELSE IF STRPOS( IDL_FILE, 'IRIS' ) GE 0 THEN  BEGIN  ; IRIS Tilts are being used.
;     TIME = TEMPORARY( IRIS_TIME  )
;    XTILT = TEMPORARY( IRIS_XTILT )*17453.2925   ; Convert the tilt from
;    YTILT = TEMPORARY( IRIS_YTILT )*17453.2925   ; Degrees to µradians.
;   SENSOR = 'IRIS'
; ENDIF ELSE IF STRPOS( IDL_FILE, 'LILY' ) GE 0 THEN  BEGIN  ; LILY Tilts are being used.
;     TIME = TEMPORARY( LILY_TIME  )
;    XTILT = TEMPORARY( LILY_XTILT )
;    YTILT = TEMPORARY( LILY_YTILT )
;    LILY_COMPASS = 0
;    LILY_VOLTAGE = 0  ; Free these variables
;    LILY_RTM     = 0  ; since they are Not
;    LILY_RTD     = 0  ; beign used here.
;    LILY_TEMP    = 0
;   SENSOR = 'LILY'
; ENDIF ELSE BEGIN  ; Assume IDL_FILE contains no tilt values.
;    PRINT, 'The IDL Save File: ' + IDL_FILE
;    PRINT, 'Does Not contain any correct Tilt variable names.'
;    PRINT, 'No Resultant Magnitudes and Directions will be plotting.'
;    RETURN  ; To caller.
; ENDELSE
;
; The procedure: RETRIEVE_TILT_VARIABLES is located in the file:
; RetrieveTiltVar.pro
;
  RETRIEVE_TILT_VARIABLES, IDL_FILE, TIME, XTILT, YTILT, SENSOR
;
  IF SENSOR EQ 'None' THEN  BEGIN
;    PRINT, 'The IDL Save File: ' + IDL_FILE
;    PRINT, 'Does Not contain any correct Tilt variable names.'
     PRINT, 'No Resultant Magnitudes and Directions will be plotting.'
     RETURN  ; To caller.
  ENDIF
;
; Get the File ID from the 1st 5 characters of the IDL_FILE name
; which will be, for example '/RSN/MJ03F/MJ03F-LILY.idl'
; and the ID will the 'MJ03F'.
;
  ID = STRMID( IDL_FILE, STRLEN( IDL_FILE )-14, 5 )  ; = 'MJ03F' e.g.
  HELP, ID, RLT, SAVE_PLOTS, IDL_FILE
;
; Get the total elements (N) in the arrays.
; Note that All the arrays are the same length.
;
; N = N_ELEMENTS( LILY_TIME )
;
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -7  = Plot the last 7-Day offset.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  14 = Plot All the data with 14-Day offset.
;
; Define the file names for the storing the plotted data.
;
IF SAVE_PLOTS THEN  BEGIN
   RTMD_ST_PNG_FILE = ID + '14DifRTMD.png'  ; plotting the LILY's
   RTMD_LT_PNG_FILE = ID + 'allDfRTMD.png'  ; Resultant Tilt Magnitudes + Directions.
ENDIF  ELSE  BEGIN
   RTMD_ST_PNG_FILE = 'Do Not Save'         ; will Not be saved.
   RTMD_LT_PNG_FILE = 'Do Not Save'         ;
ENDELSE
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
; Use the ID value: 'MJ03D', 'MJ03E' or 'MJ03F' and the following
; conditions to determine the compass value: CCMP.
; A304 - MJ03B - Ashes Vent Fiels       (LILY s/n N96??) - CCMP = ???°  Since August 16th, 2017.
; A303 - MJ03D - International District (LILY s/n N9655) - CCMP = 106°
; A302 - MJ03E - East Caldera           (LILY s/n N9652) - CCMP = 195°
; A301 - MJ03F - Central Caldera        (LILY s/n N9676) - CCMP = 345°
;
CASE  ID  OF
  'MJ03B' : CCMP = 106  ; Added on August 16th, 2017.
  'MJ03D' : CCMP = 106
  'MJ03E' : CCMP = 195
  'MJ03F' : CCMP = 345
   ELSE   : BEGIN
            PRINT, 'Data ID: ' + ID + ' Not from MJ03B,MJ03D,MJ03E or MJ03F!'
            PRINT, 'No plotting for the Resultent Tilt Mag/Dir data.'
            RETURN
   END
ENDCASE
;
; Get the Current Directory Name
; and where the output graphic files will be stored.
;
; CD, CURRENT=CURRENT_DIR            ; Get the Current Directory name.
; CD, CURRENT_DIR + PATH_SEP() + ID  ; e.g. '/RSN/MJ03D'
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Long  Term Data Set.
   N = 'with ' + STRTRIM( LONG_TERM, 2 ) + ' Days Offset'
   PRINT, SYSTIME() + ' Getting the Tilt Data Differences ' + N + ' ...'
   IF KEYWORD_SET( RLT ) THEN  BEGIN  ;
      PRINT, 'with Releveling Time Checking.'
      GET_TD, RLT, -LONG_TERM, TIME,XTILT,YTILT, T,X,Y
   ENDIF  ELSE  BEGIN  ; No Releveling Periods check are required.
      GET_TILT_DIFFERENCES, -LONG_TERM, TIME,XTILT,YTILT, T,X,Y
   ENDELSE  ; Getting the T, X, Y arrays.
;  where the T,X,Y will be Times, X & Y Tilt Differences.
;  Compute the Resultant Tilt Magnitudes (RTM),
;  and     the Resultant Tilt Directions (RTD).
   RTM = SQRT( X*X + Y*Y )
   RTD = RSN_TILT_DIRECTION( X, Y, CCMP   )
   TITLE4PLOT = 'RSN-' + SENSOR + ' (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
              + ') Resultant Tilt Magnitudes and Directions.  '       $
              + 'All Data ' + N + '.'
   RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,    $
                  T, RTM, RTD, RTMD_LT_PNG_FILE
ENDIF  ; LONG_TERM
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
   N = STRTRIM( ABS( DAY_OFFSET ), 2 )
   PRINT, SYSTIME() + ' Getting the Tilt Data Differences with the'   $
                    + ' last ' + N + ' Days offset ...'
   IF KEYWORD_SET( RLT ) THEN  BEGIN
      PRINT, 'with Releveling Time Checking.'
      GET_TD, RLT, -DAY_OFFSET, TIME,XTILT,YTILT, T,X,Y
   ENDIF  ELSE  BEGIN  ; No Releveling Periods check are required.
      GET_TILT_DIFFERENCES, -DAY_OFFSET, TIME,XTILT,YTILT, T,X,Y
   ENDELSE  ; Getting the T, X, Y arrays.
;  where the T,X,Y will be Times, X & Y Tilt Differences.
   RTM = SQRT( X*X + Y*Y )                 ; The Resultant Tilt Magnitudes;
   RTD = RSN_TILT_DIRECTION( X, Y, CCMP )  ; The Resultant Tilt Directions.
   TITLE4PLOT = 'RSN-' + SENSOR + ' (' + ID  $
              + ') Resultant Tilt Magnitudes and Directions with '  $
              + 'last ' + N + ' days Offset.'
   RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
                  T, RTM, RTD, RTMD_ST_PNG_FILE
ENDIF  ; DAY_OFFSET
;
; Check for whether the plotting data since a specified date is needed or not.
; If it is asked for, the WHAT2PLOT will have 3rd element that contains the
; JULDAY().           May 26th, 2015
;
   N = N_ELEMENTS( WHAT2PLOT )
IF N > 2 THEN  BEGIN  ; WHAT2PLOT has at least 3 elements.
;
;  Search for the starting time stored in the WHAT2PLOT[2].
;
   T = WHAT2PLOT[2]  ; = JULDAY() value.
;  
;  Get the TIME indexes.  Note that the returned index, e.g. N,
;  indicates the following: TIME[N-1] <= START_TIME < TIME[N];
;  therefore, the returned indexes need to be offset by -1.
;
;  The function: LOCATE_TIME_POSITION is located in the
;  file: SplitRSNdata.pro
;
   S = LOCATE_TIME_POSITION( TIME, T ) - 1
;  
;  If N = N_NANO, then TIME[N_NANO-1] < END_TIME.  Since N is already
;  offset by -1 above, then will be no more adjustment.
;  If S < 0, then START_TIME < TIME[0].  When this happen, set S = 0.
;
   S = ( S LT 0 ) ? 0 : S
   N = N_ELEMENTS( TIME ) - 1  ; Get the End point.
;
   RTM = STRING( FORMAT='(C(CDI2.2,  CMoa,  CYI))', T )  ; to get '01Apr2015' for example.
   RTMD_ST_PNG_FILE = ID + RTM + 'on14DifRTMD.png'  ; for the Tilt Magnitudes + Directions.
;
   RTM = STRING( FORMAT='(C(CDI2.2,X,CMoa,X,CYI))', T )  ; to get '01 Apr 2015' for example.
   PRINT, SYSTIME() + ' Getting the Tilt Data Differences since ' + RTM + ' ...'
   DAY_OFFSET = RTM  ; Save the Date for label.
   LONG_TERM  = 14   ; for 14 Day difference.
   GET_TILT_DIFFERENCES, -LONG_TERM, TIME[S:N],XTILT[S:N],YTILT[S:N], T,X,Y
;  where the T,X,Y will be Times, X & Y Tilt Differences.
;  Compute the Resultant Tilt Magnitudes (RTM),
;  and     the Resultant Tilt Directions (RTD).
   RTM = SQRT( X*X + Y*Y )
   RTD = RSN_TILT_DIRECTION( X, Y, CCMP   )
   TITLE4PLOT = 'RSN-' + SENSOR + ' (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
              + ') Resultant Tilt Magnitudes and Directions '         $
              + 'sicne ' +  DAY_OFFSET + '.'
   RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,    $
                  T, RTM, RTD, RTMD_LT_PNG_FILE
ENDIF  ; WHAT2PLOT[2] = JULDAY().
;
; CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_TD_RTMD
