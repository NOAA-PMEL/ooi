;
; File: PlotRSN-MARSdata.pro
;
; This IDL program will generate figures using the RSN-MARS data from
; 4 different sensors: HEAT, IRSIS, LILY and NANO.
; All records contain Time Stamps in Year/MM/DD Hr:Mm:Sd
; The NANO   records contain pressure and temperature values.
; The others records contain at least X-Tilt, Y-Tilt and temperatue.
; The LILY   records contain extra values: Compass & Voltage.
;
; The figures will be either 3-Day plots or the Cumulative 1-Year Plot.
;
; The MARS data are collected by the OOI Regional Scale Nodes program
; statred on August 2014 from the Axial Summit.
;
; The procedures in this program will be used by the
; PRO PROCESS_MARS_DATA_FILE in the file: ProcessRSN-MARSdata.pro
;
; This program also calls the routines in the files:
; Plot[LILY/NANO/TILTS]data.pro
;
; Revised on October    8th, 2014
; Created on Septmeber 24th, 2014
;

;
; Callers: PLOT_*_DATA
;
PRO CHECK_OPEN_WINDOW_STATUS, CONDITION
;
    CATCH, ERROR_STATUS
    IF ERROR_STATUS NE 0 THEN  BEGIN  ; There is a problem
       PRINT, 'In CHECK_OPEN_WINDOW_STATUS: Cannot Open a PIXMAP Window!'
       PRINT, 'Error   index: ', Error_STATUS
       PRINT, 'Error message: ', !ERROR_STATE.MSG
       PRINT, 'Plottings will be Skipped!'
;      CATCH, /CANCEL
       CONDITION = 'Not OK'  ; Cannot Open a graphic window.
       RETURN  ; to the Caller.
    ENDIF
;   If a PIXMAP window Cannot be Opened, the current process Cannot
;   generate graphic and IF statement above will be executed.
;   If a window Can ne Opened, the current process Can generate
;   graphic.  Delete the opened window and return to the caller.
    WINDOW, /FREE, /PIXMAP  ; Try to Open a PIXMAP window.
    WDELETE                 ; Remove the PIXMAP window.
    CONDITION = 'OK'        ; Current process Can Open a graphic window.
    PRINT, 'In CHECK_OPEN_WINDOW_STATUS: Opening a PIXMAP Window is OK.'
;
RETURN
END  ; CHECK_OPEN_WINDOW_STATUS
;
; Callers: PLOT_*_DATA
;
FUNCTION JDAY_TIME_INDEX,  TIME,  $ ; 1-D arrays in JULDAY(...)
                    TIME_OFFSET     ; in +/- days.
;
    N = N_ELEMENTS( TIME )
MONTH = FIX( STRING( FORMAT='( C(CMOI) )', TIME[N-1] ) )
JDAY  = FIX( STRING( FORMAT='( C(CDI)  )', TIME[N-1] ) )
YEAR  = FIX( STRING( FORMAT='( C(CYI)  )', TIME[N-1] ) )
;
JDAY  = JULDAY( MONTH, JDAY, YEAR, 0,0,0 ) + TIME_OFFSET
;
; Locate the 1st Index that TIME[INDEX] will be >= the Offset JDAY.
;
INDEX = WHERE( TIME GE JDAY, N )
;
; If INDEX[0] is >=0, then the time index is located;
; otherwse, INDEX[0] < 0 and time index is Not found.
;
RETURN, INDEX[0]
END   ; JDAY_TIME_INDEX
;
; Callers: PLOT_LILY_DATA or Users
;
FUNCTION MARS_TILT_DIRECTION, XTILT, YTILT,  $ ; Inputs: 1-D arrays.
                              CCMP             ; Input : in degrees.
;
; The XTILT & YTILT are in micro-randians. 
;
; The following pseudo codes are provided by Dr. Bill Chadwick.
; This subroutine computes the Resultant Tilt Direction using
; the X-Tilt Y-Tilt, and the Corrected Compass Direction (CCMP):
;
; CS1) Compute an ANGLE using one of the following cases:
;         If X-Tilt = 0 and Y-Tilt > 0, then ANGLE = +90
;         If X-Tilt = 0 and Y-Tilt < 0, then ANGLE = -90
;         If Y-Tilt = 0, then ANGLE =  0
;         else ANGLE = arctan( Y-Tilt/X-Tilt )
; CS2) Then compute the Resultant Tilt Direction as follows: 
;         If X-Tilt > 0 or X-Tilt=0, then
;           Resultant Tilt Direction = 90 - ANGLE + CCMP
;         Else If X-Tilt < 0, then
;           Resultant Tilt Direction = 270 - ANGLE + CCMP
; CS3) Apply Modulus 360 to the Resultant Tilt Direction
;      so that it will be between 0-360
;      e.g. if Resultant Tilt Direction = 450, it will become 90.
; CS4) Return the Resultant Tilt Direction value to the main program.
;
; It is assummed the XTILT & YTILT are the same size.
; Get the total data points in the array: XTILT or YTILT
;
; N = N_ELEMENTS( XTILT )  ; = N_ELEMENTS( YTILT )
;
; Locate all the Zero values in XTILT if any.
;
  Z = WHERE( XTILT EQ 0.0, N_ZEROS )
;
; Assgin XTILT to a temporary array (RTD) in case XTILT is passed
; as an expression instead of an variable by the callers.
;
  RTD = FLOAT( XTILT )  ; 
;
IF N_ZEROS GT 0 THEN  BEGIN  ; Zeros are found
   RTD[Z] = 1.0  ;  Set them to 1's so that YTILT/XTILT below will be OK.
ENDIF
;
; Compute the ANGLE in degrees.
;
  ANGLE = ATAN( FLOAT( YTILT )/TEMPORARY( RTD )  )*!RADEG
;
; Recompute the correct ANGLE's for the XTILT[Z] that are == 0's.
; The following statement will do the followings.
; if XTILT = 0, and YTILT > 0, then ANGLE = +90
; if XTILT = 0, and YTILT < 0, then ANGLE = -90
;
IF N_ZEROS GT 0 THEN  BEGIN  ; There are Zero XTILT values.
   ANGLE[Z] =  90*( YTILT[Z] GT 0.0 ) -  90*( YTILT[Z] LT 0.0 )
ENDIF
;
; Locate all the Zero values in YTILT if any.
;
  Z = WHERE( YTILT EQ 0.0, N_ZEROS )
;
IF N_ZEROS GT 0 THEN  BEGIN  ; There are Zero YTILT values.
   ANGLE[Z] = 0              ; Reset the value to 0.
ENDIF
;
; Get all the I indexes for XTILT[I] <  0 and
;         the J indexes for XTILT[J] >= 0.
;
  I = WHERE( XTILT LT 0.0, N, COMPLEMENT=J, NCOMPLEMENT=M )
               ; Note that N + M = N_ELEMENTS( XTILT )
;
; Compute the Resultant Tilt Directions (RTD).
;
  RTD = ANGLE + CCMP
;
  IF N GT 0 THEN  BEGIN
;    Resultant Tilt Direction = 270 - ANGLE + CCMP
     RTD[I] = 270 - RTD[I]
  ENDIF
  IF M GT 0 THEN  BEGIN
;    Resultant Tilt Direction =  90 - ANGLE + CCMP
     RTD[J] =  90 - RTD[J]
  ENDIF
;
; Apply Modulus 360 to the Resultant Tilt Direction
;
  RTD = TEMPORARY( RTD ) MOD 360.0  ; So that 0 <= RTD < 360. 
;
; If the "Resultant Tilt Directions" are < 0, add 360 to them.
;
   Z = WHERE( RTD LT 0.0, N_ZEROS )
IF N_ZEROS GT 0 THEN  BEGIN
   RTD[Z] = RTD[Z] + 360
ENDIF
;
RETURN, RTD
END   ; MARS_TILT_DIRECTION
;
; Callers: PLOT_MARS_DATA, PROCESS_MARS_DATA or Users
;
PRO PLOT_HEAT_DATA,  IDL_FILE,  $ ;  Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -3, 1 ]  means Plot the last 3 days, data & All the data.
; When zero value is used.  That means No Plotting for the respected term.
;
;
IF NOT KEYWORD_SET( SAVE_PLOTS ) THEN  BEGIN
   SAVE_PLOTS = 0B  ; Not Save.
ENDIF
;
; This procedure assume the IDL_FILE has been verified its existence.
;
; Retrieve the data from the IDL_FILE and the array variables will be
; HEAT_TIME, HEAT_XTILT, HEAT_YTILT, HEAT_TEMP.
; 
  RESTORE, IDL_FILE
;
; Get the File ID from the 1st 5 characters of the IDL_FILE name.
; which will be '/MARS/MJ03E/MJ03E-HEAT.idl' for example.
; and the ID will the 'MJ03E'.
;
  ID = STRMID( IDL_FILE, STRLEN( IDL_FILE )-14, 5 )  ; = 'MJ03E' e.g.
  HELP, ID
;
; Get the total elements (N) in the arrays.
; Note that All the arrays are the same length.
;
; N = N_ELEMENTS( HEAT_TIME )
;
; Define the file names for the storing the plotted data.
;
IF SAVE_PLOTS THEN  BEGIN
   TILT3DAYPNG_FILE = ID + '3DaysHEAT.png'  ; Graphic files' names for
   ALL_TILTPNG_FILE = ID +  '-AllHEAT.png'  ; plotting the (X,Y) tilts.
ENDIF  ELSE  BEGIN
   TILT3DAYPNG_FILE = 'Do Not Save'  ; Indicate the plotted displays
   ALL_TILTPNG_FILE = 'Do Not Save'  ; will Not be saved.
ENDELSE
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
; Get the Current Directory Name
; and where the output graphic files will be stored.
;
; CD, CURRENT=CURRENT_DIR, '/Mars/graphs/'
;
  TITLE4PLOT = 'RSN-MARS (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') HEAT Tilt data. '
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -3 = Plot the last 3 days, data.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Short Term Data Set.
   MARS_PLOT_TILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN,      $
        HEAT_TIME,  HEAT_XTILT, HEAT_YTILT, HEAT_TEMP,  $
        ALL_TILTPNG_FILE, EXTEND_YRANGE=0,              $
        TITLE=TITLE4PLOT + 'Start to Present.'
ENDIF
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
   T = JDAY_TIME_INDEX( HEAT_TIME, DAY_OFFSET )
   IF T GT 0 THEN  BEGIN  ; Time Index is found.
      TITLE4PLOT = TITLE4PLOT + 'last ' + STRTRIM( ABS( DAY_OFFSET ), 2 )  $
                              + ' days.'
   ENDIF  ELSE  BEGIN  ; Time Index is Not found.
      T =  0  ; All data will be plotted.
      TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
   ENDELSE
   MARS_PLOT_TILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,       $
        HEAT_TIME[T:*], HEAT_XTILT[T:*], HEAT_YTILT[T:*], HEAT_TEMP[T:*],  $
        TILT3DAYPNG_FILE, EXTEND_YRANGE=1
ENDIF
;
; CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
;
RETURN
END  ; PLOT_HEAT_DATA
;
; Callers: PLOT_MARS_DATA, PROCESS_MARS_DATA or Users
;
PRO PLOT_IRIS_DATA,  IDL_FILE,  $ ;  Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -3, 1 ]  means Plot the last 3 days, data & All the data.
; When zero value is used.  That means No Plotting for the respected term.
;
;
IF NOT KEYWORD_SET( SAVE_PLOTS ) THEN  BEGIN
   SAVE_PLOTS = 0B  ; Not Save.
ENDIF
;
; This procedure assume the IDL_FILE has been verified its existence.
;
; Retrieve the data from the IDL_FILE and the array variables will be
; IRIS_TIME, IRIS_XTILT, IRIS_YTILT, IRIS_TEMP.
; 
  RESTORE, IDL_FILE
;
; Get the File ID from the 1st 5 characters of the IDL_FILE name.
; which will be '/MARS/MJ03E/MJ03E-IRIS.idl' for example.
; and the ID will the 'MJ03E'.
;
  ID = STRMID( IDL_FILE, STRLEN( IDL_FILE )-14, 5 )  ; = 'MJ03E' e.g.
  HELP, ID
;
; Get the total elements (N) in the arrays.
; Note that All the arrays are the same length.
;
; N = N_ELEMENTS( IRIS_TIME )
;
; Define the file names for the storing the plotted data.
;
IF SAVE_PLOTS THEN  BEGIN
   TILT3DAYPNG_FILE = ID + '3DaysIRIS.png'  ; Graphic files' names for
   ALL_TILTPNG_FILE = ID +  '-AllIRIS.png'  ; plotting the (X,Y) tilts.
ENDIF  ELSE  BEGIN
   TILT3DAYPNG_FILE = 'Do Not Save'  ; Indicate the plotted displays
   ALL_TILTPNG_FILE = 'Do Not Save'  ; will Not be saved.
ENDELSE
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
; Get the Current Directory Name
; and where the output graphic files will be stored.
;
; CD, CURRENT=CURRENT_DIR, '/Mars/graphs/'
;
  TITLE4PLOT = 'RSN-MARS (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') IRIS Tilt data. '
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -3 = Plot the last 3 days, data.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Short Term Data Set.
   MARS_PLOT_TILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN,      $
        IRIS_TIME,  IRIS_XTILT, IRIS_YTILT, IRIS_TEMP,  $
        ALL_TILTPNG_FILE, EXTEND_YRANGE=0,              $
        TITLE=TITLE4PLOT + 'Start to Present.'
ENDIF
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
   T = JDAY_TIME_INDEX( IRIS_TIME, DAY_OFFSET )
   IF T GT 0 THEN  BEGIN  ; Time Index is found.
      TITLE4PLOT = TITLE4PLOT + 'last ' + STRTRIM( ABS( DAY_OFFSET ), 2 )  $
                              + ' days.'
   ENDIF  ELSE  BEGIN  ; Time Index is Not found.
      T =  0  ; All data will be plotted.
      TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
   ENDELSE
   MARS_PLOT_TILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,       $
        IRIS_TIME[T:*], IRIS_XTILT[T:*], IRIS_YTILT[T:*], IRIS_TEMP[T:*],  $
        TILT3DAYPNG_FILE, EXTEND_YRANGE=0
ENDIF
;
; CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_IRIS_DATA
;
; Callers: Users
;
PRO PLOT_MARS_DATA, IDL_FILE,   $ ;  Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
IF NOT KEYWORD_SET( SAVE_PLOTS ) THEN  BEGIN
   SAVE_PLOTS = 0B  ; Not Save.
ENDIF
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -3, 1 ]  means Plot the last 3 days, data & All the data.
; When zero value is used.  That means No Plotting for the respected term.
;
FILE = FILE_INFO( IDL_FILE )  ; Get the IDL Save File's information.
;  
IF NOT FILE.EXISTS THEN  BEGIN  ; The IDL_FILE cannot be found.
   PRINT, 'From PLOT_HEAT_DATA, the IDL Save File: ', IDL_FILE
   PRINT, 'Cannot be found.  No figures are created.' 
ENDIF  ELSE  BEGIN  ;  The IDL_FILE is Found.
;  It is assume the IDL_FILE will in 'MJ03F-LILY.idl', 'MJ03D-IRIS.idl', etc.
;  Get the IDL_FILE's ID = 'LILY', 'IRIS', etc.
   N    = STRLEN( IDL_FILE )
   TYPE = STRMID( IDL_FILE, N-8, 4 )  ; = 'NANO' e.g.
   HELP, TYPE, N
   CASE TYPE OF
       'HEAT' : PLOT_HEAT_DATA, IDL_FILE, WHAT2PLOT,  $
                SHOW_PLOT=DISPLAY_PLOT2SCREEN, UPDATE_PLOTS=SAVE_PLOTS
       'IRIS' : PLOT_IRIS_DATA, IDL_FILE, WHAT2PLOT,  $
                SHOW_PLOT=DISPLAY_PLOT2SCREEN, UPDATE_PLOTS=SAVE_PLOTS
       'LILY' : PLOT_LILY_DATA, IDL_FILE, WHAT2PLOT,  $
                SHOW_PLOT=DISPLAY_PLOT2SCREEN, UPDATE_PLOTS=SAVE_PLOTS
       'NANO' : PLOT_NANO_DATA, IDL_FILE, WHAT2PLOT,  $
                SHOW_PLOT=DISPLAY_PLOT2SCREEN, UPDATE_PLOTS=SAVE_PLOTS
        ELSE  : BEGIN
                  PRINT, 'From PLOT_HEAT_DATA, the IDL Save File: ', IDL_FILE
                  PRINT, 'May Not contain MARS Data.  No figures are created.'
                END
   ENDCASE
ENDELSE
;
RETURN
END  ; PLOT_MARS_DATA
;
; Callers: PLOT_MARS_DATA, PROCESS_MARS_DATA or Users
;
PRO PLOT_LILY_DATA, IDL_FILE,   $ ;  Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -3, 1 ]  means Plot the last 3 days, data & All the data.
; When zero value is used.  That means No Plotting for the respected term.
;
IF NOT KEYWORD_SET( SAVE_PLOTS ) THEN  BEGIN
   SAVE_PLOTS = 0B  ; Not Save.
ENDIF
;
; This procedure assume the IDL_FILE has been verified its existence.
;
; Retrieve the data from the IDL_FILE and the array variables will be
; LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_COMPASS, LILY_TEMP, LILY_VOLTAGE
; Note that LILY_COMPASS & LILY_VOLTAGE array values will not be used here.
;
  RESTORE, IDL_FILE
;
; Get the File ID from the 1st 5 characters of the IDL_FILE name.
; which will be '/MARS/MJ03F/MJ03F-LILY.idl' for example.
; and the ID will the 'MJ03F'.
;
  ID = STRMID( IDL_FILE, STRLEN( IDL_FILE )-14, 5 )  ; = 'MJ03F' e.g.
  HELP, ID
;
; Get the total elements (N) in the arrays.
; Note that All the arrays are the same length.
;
  N = N_ELEMENTS( LILY_TIME )
;
; Define the file names for the storing the plotted data.
;
IF SAVE_PLOTS THEN  BEGIN
   TILT3DAYPNG_FILE = ID + '3DaysLILY.png'  ; Graphic files' names for
   RTMD3DAYPNG_FILE = ID + '3DaysRTMD.png'  ; plotting the LILY's
  ALL_TILT_PNG_FILE = ID + 'AllLILY.png'    ; X,Y Tilts, temperature &
  ALL_RTMD_PNG_FILE = ID + 'AllRTMD.png'    ; Resultant Tilt Megnitudes + Directions.
ENDIF  ELSE  BEGIN
   TILT3DAYPNG_FILE = 'Do Not Save'         ; Indicate the plotted displays
   RTMD3DAYPNG_FILE = 'Do Not Save'         ; will Not be saved.
  ALL_TILT_PNG_FILE = 'Do Not Save'         ;
  ALL_RTMD_PNG_FILE = 'Do Not Save'         ;
ENDELSE
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
; Use the ID value: 'MJ03D', 'MJ03E' or 'MJ03F' and the following
; conditions to determine the compass value: CCMP.
; A303 - MJ03D - International District (LILY s/n N9655) - CCMP = 106°
; A302 - MJ03E - East Caldera           (LILY s/n N9652) - CCMP = 195°
; A301 - MJ03F - Central Caldera        (LILY s/n N9676) - CCMP = 345°
;
  CASE  ID  OF
    'MJ03D' : CCMP = 106
    'MJ03E' : CCMP = 195
    'MJ03F' : CCMP = 345
     ELSE   : BEGIN
              PRINT, 'Data ID: ' + ID + ' Not from MJ03D,MJ03E or MJ03F!'
              PRINT, 'No plotting LILY data.'
              RETURN
     END
  ENDCASE
;
; Compute the Resultant Tilt Megnitudes (RTM),
; and     the Resultant Tilt Directions (RTD).
;
  RTM = SQRT( LILY_XTILT*LILY_XTILT + LILY_YTILT*LILY_YTILT )
  RTD = MARS_TILT_DIRECTION( LILY_XTILT, LILY_YTILT, CCMP   )
;
; Get the Current Directory Name
; and where the output graphic files will be stored.
;
; CD, CURRENT=CURRENT_DIR, '/Mars/graphs/'
;
  TITLE4PLOT = 'RSN-LILY (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') Tilts and Temperature Data, '
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -3 = Plot the last 3 days, data.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Short Term Data Set.
   MARS_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN,           $
                   TITLE=TITLE4PLOT + 'Start to Present.',  $
                   LILY_TIME, LILY_XTILT, LILY_YTILT,       $
                   LILY_TEMP, ALL_TILT_PNG_FILE
   TITLE4PLOT = 'RSN-LILY (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
              + ') Resultant Tilt Megnitudes and Directions, '
   MARS_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN,           $
                   TITLE=TITLE4PLOT + 'Start to Present.',  $
                   LILY_TIME, RTM, RTD, ALL_RTMD_PNG_FILE
ENDIF
;
; Reset the TITLE4PLOT in case it has been modified after the Long-Term plots.
;
  TITLE4PLOT = 'RSN-LILY  (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') Tilts and Temperature Data, '
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
   T = JDAY_TIME_INDEX( LILY_TIME, DAY_OFFSET )
   IF T GT 0 THEN  BEGIN  ; Time Index is found.
      TITLE4PLOT = TITLE4PLOT + 'last ' + STRTRIM( ABS( DAY_OFFSET ), 2 )  $
                              + ' days.'
   ENDIF  ELSE  BEGIN  ; Time Index is Not found.
      T =  0  ; All data will be plotted.
      TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
   ENDELSE
   MARS_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
        LILY_TIME[T:N-1], LILY_XTILT[T:N-1], LILY_YTILT[T:N-1],      $
        LILY_TEMP[T:N-1], TILT3DAYPNG_FILE
   TITLE4PLOT = 'MARS-LILY (' + ID  $
              + ') Resultant Tilt Megnitudes and Directions, '  $
              + STRTRIM( ABS( DAY_OFFSET ), 2 ) + ' days.'
   MARS_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
        LILY_TIME[T:N-1], RTM[T:N-1], RTD[T:N-1], RTMD3DAYPNG_FILE
ENDIF
;
; CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_LILY_DATA
;
; Callers: PLOT_MARS_DATA, PROCESS_MARS_DATA or Users
;
PRO PLOT_NANO_DATA,  IDL_FILE,  $ ; Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -3, 1 ]  means Plot the last 3 days, data & All the data.
; When zero value is used.  That means No Plotting for the respected term.
;
IF NOT KEYWORD_SET( SAVE_PLOTS ) THEN  BEGIN
   SAVE_PLOTS = 0B  ; Not Save.
ENDIF
;
; This procedure assume the IDL_FILE has been verified its existence.
;
; Retrieve the data from the IDL_FILE and the array variables will be
; NANO_TIME, NANO_PSIA, NANO_DETIDE and NANO_TEMP
; 
  RESTORE, IDL_FILE
;
; Get the File ID from the 1st 5 characters of the IDL_FILE name.
; which will be '/MARS/MJ03D/MJ03D-NANO.idl' for example.
; and the ID will the 'MJ03D'.
;
  ID = STRMID( IDL_FILE, STRLEN( IDL_FILE )-14, 5 )  ; = 'MJ03D' e.g.
  HELP, ID
;
; Convert NANO_PSIA into Height in meters.
; Note that 1 psia = 670 mm is used and 670/1000.0 = 0.67 meters.
;
  HEIGHT = NANO_PSIA * 0.67  ; height in meters.
;
; Get the total elements (N) in the arrays.
; Note that All the arrays are the same length.
;
  N = N_ELEMENTS( NANO_TIME )
;
; Define the file names for the storing the plotted data.
;
IF SAVE_PLOTS THEN  BEGIN
   DETHGT3DAYPNG_FILE = ID + '3DaysDET.png'  ; Graphic files' names for
   ALL_DETHGTPNG_FILE = ID +  '-AllDET.png'  ; plotting the pressure,
   BPRHGT3DAYPNG_FILE = ID + '3DaysBPR.png'  ; Detided pressure and
   ALL_BPRHGTPNG_FILE = ID +  '-AllBPR.png'  ; temperature data.
ENDIF  ELSE  BEGIN
   DETHGT3DAYPNG_FILE = 'Do Not Save'  ; Indicate the plotted displays
   ALL_DETHGTPNG_FILE = 'Do Not Save'  ; will Not be saved.
   BPRHGT3DAYPNG_FILE = 'Do Not Save'  ;
   ALL_BPRHGTPNG_FILE = 'Do Not Save'  ;
ENDELSE
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
; Get the Current Directory Name
; and where the output graphic files will be stored.
;
; CD, CURRENT=CURRENT_DIR, '/Mars/graphs/'
;
  TITLE4PLOT = 'RSN-NANO-BPR  (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') raw data and with the tidal signal removed, '
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -3 = Plot the last 3 days, data.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Short Term Data Set.
   MARS_PLOT_BPR, SHOW_PLOT=DISPLAY_PLOT2SCREEN,  $
                  NANO_TIME,   HEIGHT,  NANO_DETIDE, ALL_BPRHGTPNG_FILE,  $
                  TITLE=TITLE4PLOT + 'Start to Present.'
   TITLE4PLOT='MARS-NANO-BPR (' + ID + ') data with the tidal signal removed, '
   MARS_PLOT_DET, SHOW_PLOT=DISPLAY_PLOT2SCREEN,        $
                  NANO_TIME, NANO_DETIDE, NANO_TEMP, ALL_DETHGTPNG_FILE,  $
                  TITLE=TITLE4PLOT + 'Start to Present.'
ENDIF
;
; Reset the TITLE4PLOT in case it has been modified after the Long-Term plots.
;
  TITLE4PLOT = 'RSN-NANO-BPR  (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') raw data and with the tidal signal removed, '
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
   T = JDAY_TIME_INDEX( NANO_TIME, DAY_OFFSET )
   IF T GT 0 THEN  BEGIN  ; Time Index is found.
      TITLE4PLOT = TITLE4PLOT + 'last ' + STRTRIM( ABS( DAY_OFFSET ), 2 )  $
                              + ' days.'
   ENDIF  ELSE  BEGIN  ; Time Index is Not found.
      T =  0  ; All data will be plotted.
      TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
   ENDELSE
   MARS_PLOT_BPR, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,        $
                  NANO_TIME[T:N-1],   HEIGHT[T:N-1], NANO_DETIDE[T:N-1],  $
                  BPRHGT3DAYPNG_FILE
   TITLE4PLOT='MARS-NANO-BPR (' + ID  $
             + ') data with the tidal signal removed, last '  $
             + STRTRIM( ABS( DAY_OFFSET ), 2 ) + ' days.'
   MARS_PLOT_DET, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,        $
                  NANO_TIME[T:N-1], NANO_DETIDE[T:N-1], NANO_TEMP[T:N-1], $
                  DETHGT3DAYPNG_FILE
ENDIF
;
; CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_NANO_DATA
