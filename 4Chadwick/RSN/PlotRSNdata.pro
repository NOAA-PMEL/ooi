;
; File: PlotRSNdata.pro
;
; This IDL program will generate figures using the RSN data from
; 4 different sensors: HEAT, IRSIS, LILY and NANO.
; All records contain Time Stamps in Year/MM/DD Hr:Mm:Sd
; The NANO   records contain pressure and temperature values.
; The others records contain at least X-Tilt, Y-Tilt and temperatue.
; The LILY   records contain extra values: Compass & Voltage.
;
; The figures will be either 3-Day plots or the Cumulative 1-Year Plot.
;
; The RSN data are collected by the OOI Regional Scale Nodes program
; statred on August 2014 from the Axial Summit.
;
; The procedures in this program will be used by the
; PRO PROCESS_RSN_DATA_FILE in the file: ProcessRSNdata.pro
;
; This program also calls the routines in the files:
; Plot[LILY/NANO/TILTS]data.pro
;
; Programmer: T-K Andy Lau NOAA/PMEL/Acoustic Program HMSC Newport Oregon.
;
; Revised on January    9th, 2018
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
; Callers: PLOT_RSN_DATA, PROCESS_RSN_DATA or Users
; Revised: January    9th, 2018
;
PRO PLOT_HEAT_DATA,  IDL_FILE,  $ ;  Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -7, 1 ]  means Plot the last 7 days, data & All the data.
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
; which will be '/RSN/MJ03E/MJ03E-HEAT.idl' for example.
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
   TILT3DAYPNG_FILE = ID + '7DaysHEAT.png'  ; Graphic files' names for
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
  CD, CURRENT=CURRENT_DIR            ; Get the Current Directory name.
  CD, CURRENT_DIR + PATH_SEP() + ID  ; e.g. '/RSN/MJ03D'
;
  TITLE4PLOT = 'RSN (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') HEAT Tilt data. '
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -7 = Plot the last 7 days, data.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Long  Term Data Set.
   RSN_PLOT_TILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN,      $
       HEAT_TIME,  HEAT_XTILT, HEAT_YTILT, HEAT_TEMP,  $
       ALL_TILTPNG_FILE, EXTEND_YRANGE=0,              $
       TITLE=TITLE4PLOT + 'Start to Present.'
ENDIF
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
   T = JDAY_TIME_INDEX( HEAT_TIME, DAY_OFFSET )
   IF T GT 0 THEN  BEGIN  ; Time Index is found.
      TITLE4PLOT = TITLE4PLOT + 'last ' + STRTRIM( ABS( DAY_OFFSET ), 2 )  $
                              + ' days or more.'
   ENDIF  ELSE  BEGIN  ; Time Index is Not found.
      T =  0  ; All data will be plotted.
      IF STRPOS( IDL_FILE, '3Day' ) GE 0 THEN  BEGIN  ; It is a Short-Term File.
         TITLE4PLOT = TITLE4PLOT + 'last 7 days.'     ; Started on January 9th, 2018.
      ENDIF  ELSE  BEGIN
         TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
      ENDELSE
   ENDELSE
   RSN_PLOT_TILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,       $
       HEAT_TIME[T:*], HEAT_XTILT[T:*], HEAT_YTILT[T:*], HEAT_TEMP[T:*],  $
       TILT3DAYPNG_FILE, EXTEND_YRANGE=1
ENDIF
;
  CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
;
RETURN
END  ; PLOT_HEAT_DATA
;
; Callers: PLOT_RSN_DATA, PROCESS_RSN_DATA or Users
; Revised: March     27th, 2019
;
PRO PLOT_IRIS_DATA,  IDL_FILE,  $ ;  Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2- or 3-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -7, 1 ]  means Plot the last 7 days, data & All the data.
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
; which will be '/RSN/MJ03E/MJ03E-IRIS.idl' for example.
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
   TILT3DAYPNG_FILE = ID + '7DaysIRIS.png'  ; Graphic files' names for
   ALL_TILTPNG_FILE = ID +  '-AllIRIS.png'  ; plotting the (X,Y) tilts & Temperatures.
   XYTL3DAYPNG_FILE = ID + '7DaysIRIStilts.png'  ; Graphic files' names for
   ALL_XYTLPNG_FILE = ID +  '-AllIRIStilts.png'  ; plotting the (X,Y) tilts only.
ENDIF  ELSE  BEGIN
   TILT3DAYPNG_FILE = 'Do Not Save'  ; Indicate the plotted displays
   ALL_TILTPNG_FILE = 'Do Not Save'  ; will Not be saved.
   XYTL3DAYPNG_FILE = 'Do Not Save'  ; Indicate the plotted displays
   ALL_XYTLPNG_FILE = 'Do Not Save'  ; will Not be saved.
ENDELSE
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
; Get the Current Directory Name
; and where the output graphic files will be stored.
;
  CD, CURRENT=CURRENT_DIR            ; Get the Current Directory name.
  CD, CURRENT_DIR + PATH_SEP() + ID  ; e.g. '/RSN/MJ03D'
;
  TITLE4PLOT = 'RSN (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') IRIS Tilt data. '
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -7 = Plot the last 7 days, data.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Long  Term Data Set.
   RSN_PLOT_TILTS,   SHOW_PLOT=DISPLAY_PLOT2SCREEN,    $
       IRIS_TIME,  IRIS_XTILT, IRIS_YTILT, IRIS_TEMP,  $
       ALL_TILTPNG_FILE, EXTEND_YRANGE=0,              $
       TITLE=TITLE4PLOT + 'Start to Present.'
   RSN_PLOT_XYTILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN,    $
       IRIS_TIME,  IRIS_XTILT, IRIS_YTILT,             $
       ALL_XYTLPNG_FILE, EXTEND_YRANGE=0,              $
       TITLE=TITLE4PLOT + 'Start to Present.'  ; May 15th, 2015
ENDIF
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
   T = JDAY_TIME_INDEX( IRIS_TIME, DAY_OFFSET )
   IF T GT 0 THEN  BEGIN  ; Time Index is found.
      TITLE4PLOT = TITLE4PLOT + 'last ' + STRTRIM( ABS( DAY_OFFSET ), 2 )  $
                              + ' days or more.'
   ENDIF  ELSE  BEGIN  ; Time Index is Not found.
      T =  0  ; All data will be plotted.
      IF STRPOS( IDL_FILE, '3Day' ) GE 0 THEN  BEGIN  ; It is a Short-Term File.
         TITLE4PLOT = TITLE4PLOT + 'last 7 days.'; Started on January  9th, 2018
      ENDIF  ELSE  BEGIN
         TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
      ENDELSE
   ENDELSE
   RSN_PLOT_TILTS,   SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,     $
       IRIS_TIME[T:*], IRIS_XTILT[T:*], IRIS_YTILT[T:*], IRIS_TEMP[T:*],  $
       TILT3DAYPNG_FILE, EXTEND_YRANGE=0
   RSN_PLOT_XYTILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,     $
       IRIS_TIME[T:*], IRIS_XTILT[T:*], IRIS_YTILT[T:*],                  $
       XYTL3DAYPNG_FILE, EXTEND_YRANGE=0  ; May 15th, 2015
ENDIF
;
; Check for whether the plotting data since a specified date is neededi or not.
; If it is asked for, the WHAT2PLOT will have 3rd element that contains the
; JULDAY().           May 27th, 2015
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
   S = LOCATE_TIME_POSITION( IRIS_TIME, T ) - 1
;
;  If N = N_NANO, then TIME[N_NANO-1] < END_TIME.  Since N is already
;  offset by -1 above, then will be no more adjustment.
;  If S < 0, then START_TIME < TIME[0].  When this happen, set S = 0.
;
   S = ( S LT 0 ) ? 0 : S
   N = N_ELEMENTS( IRIS_TIME ) - 1  ; Get the End  point.
;
   ALL_TILTPNG_FILE = ID +  '25Apr2015onIRIS.png'       ; File names for
   ALL_XYTLPNG_FILE = ID +  '25Apr2015onIRIStilts.png'  ; the figures.
;
   DAY_OFFSET  =  STRING( FORMAT='(C(CDI2.2,X,CMoa,X,CYI))', T )
   TITLE4PLOT  = 'RSN (' + ID  +  ') '  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
   TITLE4PLOT += 'IRIS Tilt and Temperature data since ' + DAY_OFFSET
;
;  Shorten the array variables: IRIS_[TIME,TEMP,XTILT & YTILT]
;  to avoid "% Unable to allocate memory." message from IDL.
;  Note that it is OK to shorten the array variables here since they are
;  local variables here and being used the last time.   March 27th, 2019
;
           T  = IRIS_TIME[S:N]
   IRIS_TIME  = TEMPORARY( T )
           T  = IRIS_XTILT[S:N]
   IRIS_XTILT = TEMPORARY( T )
           T  = IRIS_YTILT[S:N]
   IRIS_YTILT = TEMPORARY( T )
           T  = IRIS_TEMP[S:N]
   IRIS_TEMP  = TEMPORARY( T )
;
   RSN_PLOT_TILTS,   SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,     $
;      IRIS_TIME[S:N], IRIS_XTILT[S:N], IRIS_YTILT[S:N], IRIS_TEMP[S:N],  $
       IRIS_TIME,      IRIS_XTILT,      IRIS_YTILT,      IRIS_TEMP,       $
       ALL_TILTPNG_FILE, EXTEND_YRANGE=0
   TITLE4PLOT  = 'RSN (' + ID  +  ') IRIS Tilt data since ' + DAY_OFFSET
   RSN_PLOT_XYTILTS, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,     $
;      IRIS_TIME[S:N], IRIS_XTILT[S:N], IRIS_YTILT[S:N],                  $
       IRIS_TIME,      IRIS_XTILT,      IRIS_YTILT,                       $
       ALL_XYTLPNG_FILE, EXTEND_YRANGE=0  ; May 15th, 2015
ENDIF
;
  CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_IRIS_DATA
;
; Callers: Users
;
PRO PLOT_RSN_DATA,  IDL_FILE,   $ ;  Input: IDL Save File name.
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
   PRINT, 'From PLOT_RSN_DATA, the IDL Save File: ', IDL_FILE
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
                  PRINT, 'From PLOT_RNS_DATA, the IDL Save File: ', IDL_FILE
                  PRINT, 'May Not contain RSN Data.  No figures are created.'
                END
   ENDCASE
ENDELSE
;
RETURN
END  ; PLOT_RSN_DATA
;
; Callers: PLOT_RSN_DATA, PROCESS_RSN_DATA or Users
; Revised: January    9th, 2018
;
PRO PLOT_LILY_DATA, IDL_FILE,   $ ;  Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2- or 3-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -7, 1 ]  means Plot the last 7 days, data & All the data.
; When zero value is used.  That means No Plotting for the respected term.
;
IF NOT KEYWORD_SET( SAVE_PLOTS ) THEN  BEGIN
   SAVE_PLOTS = 0B  ; Not Save.
ENDIF
;
; This procedure assume the IDL_FILE has been verified its existence.
;
; Retrieve the data from the IDL_FILE and the array variables will be
; LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_RTM,     LILY_TEMP, LILY_RTD
; Note that LILY_COMPASS & LILY_VOLTAGE array values will not be used here.
;
  RESTORE, IDL_FILE
;
; Get the File ID from the 1st 5 characters of the IDL_FILE name.
; which will be '/RSN/MJ03F/MJ03F-LILY.idl' for example.
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
   TILT3DAYPNG_FILE = ID + '7DaysLILY.png'  ; Graphic files' names for
   RTMD3DAYPNG_FILE = ID + '7DaysRTMD.png'  ; plotting the LILY's
  ALL_TILT_PNG_FILE = ID + 'AllLILY.png'    ; X,Y Tilts, temperature &
  ALL_RTMD_PNG_FILE = ID + 'AllRTMD.png'    ; Resultant Tilt Magnitudes + Directions.
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
; CASE  ID  OF
;   'MJ03D' : CCMP = 106
;   'MJ03E' : CCMP = 195
;   'MJ03F' : CCMP = 345
;    ELSE   : BEGIN
;             PRINT, 'Data ID: ' + ID + ' Not from MJ03D,MJ03E or MJ03F!'
;             PRINT, 'No plotting LILY data.'
;             RETURN
;    END
; ENDCASE
;
; Compute the Resultant Tilt Magnitudes (RTM),
; and     the Resultant Tilt Directions (RTD).
;
; RTM = SQRT( LILY_XTILT*LILY_XTILT + LILY_YTILT*LILY_YTILT )
; RTD = RSN_TILT_DIRECTION( LILY_XTILT, LILY_YTILT, CCMP   )
;
  RTM = TEMPORARY( LILY_RTM )
  RTD = TEMPORARY( LILY_RTD )
;
; Get the Current Directory Name
; and where the output graphic files will be stored.
;
  CD, CURRENT=CURRENT_DIR            ; Get the Current Directory name.
  CD, CURRENT_DIR + PATH_SEP() + ID  ; e.g. '/RSN/MJ03D'
;
  TITLE4PLOT = 'RSN-LILY (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') Tilts and Temperature Data, '
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -3 = Plot the last 3 days, data.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Long  Term Data Set.
   RSN_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN,           $
                  TITLE=TITLE4PLOT + 'Start to Present.',  $
                  LILY_TIME, LILY_XTILT, LILY_YTILT,       $
                  LILY_TEMP, ALL_TILT_PNG_FILE
   TITLE4PLOT = 'RSN-LILY (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
              + ') Resultant Tilt Magnitudes and Directions, '
   RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN,           $
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
      IF STRPOS( IDL_FILE, '3Day' ) GE 0 THEN  BEGIN  ; It is a Short-Term File.
;        TITLE4PLOT = TITLE4PLOT + 'last 3 days.'
         TITLE4PLOT = TITLE4PLOT + 'last 7 days.'; Started on December 5th, 2017
      ENDIF  ELSE  BEGIN
         TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
      ENDELSE
   ENDELSE
   RSN_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
       LILY_TIME[T:N-1], LILY_XTILT[T:N-1], LILY_YTILT[T:N-1],      $
       LILY_TEMP[T:N-1], TILT3DAYPNG_FILE
   TITLE4PLOT = 'RSN-LILY (' + ID  $
              + ') Resultant Tilt Magnitudes and Directions, last '  $
              + STRTRIM( ABS( DAY_OFFSET ), 2 ) + ' days or more.'
   RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
       LILY_TIME[T:N-1], RTM[T:N-1], RTD[T:N-1], RTMD3DAYPNG_FILE
ENDIF
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
   S = LOCATE_TIME_POSITION( LILY_TIME, T ) - 1
;
;  If N = N_NANO, then TIME[N_NANO-1] < END_TIME.  Since N is already
;  offset by -1 above, then will be no more adjustment.
;  If S < 0, then START_TIME < TIME[0].  When this happen, set S = 0.
;
   S = ( S LT 0 ) ? 0 : S
   N = N_ELEMENTS( LILY_TIME )  ; Get the End  point.
;
   ALL_TILT_PNG_FILE = ID + '25Apr2015onLILY.png'    ; X,Y Tilts, temperature &
   ALL_RTMD_PNG_FILE = ID + '25Apr2015onRTMD.png'    ; Resultant Tilt Magnitudes + Directions.
;
   DAY_OFFSET  =  STRING( FORMAT='(C(CDI2.2,X,CMoa,X,CYI))', T )
   TITLE4PLOT  = 'RSN-LILY (' + ID  +  '), '  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
   TITLE4PLOT += 'Tilts and Temperature Data since ' + DAY_OFFSET
   RSN_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
       LILY_TIME[S:N-1], LILY_XTILT[S:N-1], LILY_YTILT[S:N-1],      $
       LILY_TEMP[S:N-1], ALL_TILT_PNG_FILE
   TITLE4PLOT = 'RSN-LILY (' + ID  $
              + ') Resultant Tilt Magnitudes and Directions, since '  + DAY_OFFSET
   RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
       LILY_TIME[S:N-1], RTM[S:N-1], RTD[S:N-1], ALL_RTMD_PNG_FILE
ENDIF
;
  CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_LILY_DATA
;
; Callers: PLOT_RSN_DATA, PROCESS_RSN_DATA or Users
; Revised: January    9th, 2018
;
PRO PLOT_NANO_DATA,  IDL_FILE,  $ ; Input: IDL Save File name.
    WHAT2PLOT,  $ ; Input: 2- or 3-Element integer to indicate what to plot.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; WHAT2PLOT = [ Short Term Plot, Long Term Plot ] indicators.  For example,
; WHAT2PLOT = [ -7, 1 ]  means Plot the last 7 days, data & All the data.
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
; which will be '/RSN/MJ03D/MJ03D-NANO.idl' for example.
; and the ID will the 'MJ03D'.
;
  ID = STRMID( IDL_FILE, STRLEN( IDL_FILE )-14, 5 )  ; = 'MJ03D' e.g.
  HELP, ID
;
; Convert NANO_PSIA into Height in meters.
; Note that 1 psia = 670 mm is used and 670/1000.0 = 0.67 meters.
;
  HEIGHT = TEMPORARY( NANO_PSIA ) * 0.67  ; height in meters.
;
; Define the file names for the storing the plotted data.
;
IF SAVE_PLOTS THEN  BEGIN
   DETHGT3DAYPNG_FILE = ID + '7DaysDET.png'  ; Graphic files' names for
   ALL_DETHGTPNG_FILE = ID +  '-AllDET.png'  ; plotting the pressure,
   BPRHGT3DAYPNG_FILE = ID + '7DaysBPR.png'  ; Detided pressure and
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
  CD, CURRENT=CURRENT_DIR            ; Get the Current Directory name.
  CD, CURRENT_DIR + PATH_SEP() + ID  ; e.g. '/RSN/MJ03D'
;
  TITLE4PLOT = 'RSN-NANO-BPR  (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
             + ') raw data and with the tidal signal removed, '
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -7 = Plot the last 7 days, data.
   LONG_TERM = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Long  Term Data Set.
   RSN_PLOT_BPR, SHOW_PLOT=DISPLAY_PLOT2SCREEN,                          $
                 NANO_TIME,   HEIGHT,  NANO_DETIDE, ALL_BPRHGTPNG_FILE,  $
                 TITLE=TITLE4PLOT + 'Start to Present.'
   TITLE4PLOT='RSN-NANO-BPR (' + ID + ') data with the tidal signal removed, '
;  Define the Smoothing factor.  Using 24 hours data which
;  [1,4,7] x 24 hours x 60 minutes x 4 data points/second = [5760,23040,40320].
;  N =  5761  ; +1 is needed as required using odd values for the SMOOTH().
 ; N = 23041  ; +1 is needed as required using odd values for the SMOOTH().  ; Ended on 9/27/2017
;  N = 40321  ; +1 is needed as required using odd values for the SMOOTH().
   N = 0      ; Started on September 27th, 2017.  N was = 23041 before.
   RSN_PLOT_DET, SHOW_PLOT=DISPLAY_PLOT2SCREEN, OVERPLOT_SMOOTH_DETIDED=N, $
                 NANO_TIME, NANO_DETIDE, NANO_TEMP, ALL_DETHGTPNG_FILE,    $
                 TITLE=TITLE4PLOT + 'Start to Present.'
ENDIF
;
; Reset the TITLE4PLOT in case it has been modified after the Long-Term plots.
;
; TITLE4PLOT = 'RSN-NANO-BPR  (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
;            + ') raw data and with the tidal signal removed, '
  TITLE4PLOT = 'RSN-NANO-BPR (' + ID  +  '), '  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
;  Get the total elements (N) in the arrays.
;  Note that All the arrays are the same length.
   N = N_ELEMENTS( NANO_TIME )  ; Get the End  point.
   S = 1  ; Indicates using data till the last point.
   IF ( LONG_TERM LT 0 ) AND ( WHAT2PLOT[0] LT WHAT2PLOT[1] ) THEN  BEGIN
;     WHAT2PLOT[0] < ( LONG_TERM = WHAT2PLOT[1] ) < 0.
;     For example, WHAT2PLOT = [ -5, -2 ] which means to use data range
;     from 5 days ago to 2 days ago.
         T = JDAY_TIME_INDEX( NANO_TIME, WHAT2PLOT[1] )
      IF T GT 0 THEN  BEGIN  ; Time Index is found.
         N = T     ; Save the End in Index.
         S = 0.8   ; Indicates using data till Before the last point
      ENDIF  ; Else the last data point will be used.
   ENDIF
;  Get the Start Point.
      T = JDAY_TIME_INDEX( NANO_TIME, DAY_OFFSET )
   IF T GT 0 THEN  BEGIN  ; Time Index is found.
;     TITLE4PLOT += 'last ' + STRTRIM( ABS( DAY_OFFSET ), 2 )  $
;                           + ' days or more.'
      IF S LT 1 THEN  BEGIN
         RANGE = STRTRIM( ABS( WHAT2PLOT[1] - DAY_OFFSET ), 2 )
      ENDIF  ELSE  BEGIN  ; S = 1 means using data till the last point.
         RANGE = STRTRIM( ABS( DAY_OFFSET ), 2 )
      ENDELSE
      RANGE += ' Days, '
   ENDIF  ELSE  BEGIN  ; Time Index is Not found.
      T =  0  ; All data will be plotted.
      IF STRPOS( IDL_FILE, '3Day' ) GE 0 THEN  BEGIN  ; It is a Short-Term File.
;        RANGE = 'last 3 or 7 days.'            ; Started on December 5th, 2017.
         RANGE = 'last 7 days.'                 ; Started on January  9th, 2018.
      ENDIF  ELSE  BEGIN
         RANGE = 'Start to Present,'
      ENDELSE
;     TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
   ENDELSE
   TITLE4PLOT += RANGE + 'raw data and with the tidal signal removed.'
   RSN_PLOT_BPR, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,        $
                 NANO_TIME[T:N-1],   HEIGHT[T:N-1], NANO_DETIDE[T:N-1],  $
                 BPRHGT3DAYPNG_FILE
;  TITLE4PLOT='RSN-NANO-BPR (' + ID  $
;            + ') data with the tidal signal removed, last '  $
;            + STRTRIM( ABS( DAY_OFFSET ), 2 ) + ' days or more.'
   TITLE4PLOT = 'RSN-NANO-BPR (' + ID + '), ' + RANGE  $
              + 'data with the tidal signal removed.'
   RSN_PLOT_DET, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,        $
                 NANO_TIME[T:N-1], NANO_DETIDE[T:N-1], NANO_TEMP[T:N-1], $
                 DETHGT3DAYPNG_FILE
ENDIF
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
   S = LOCATE_TIME_POSITION( NANO_TIME, T ) - 1
;
;  If N = N_NANO, then TIME[N_NANO-1] < END_TIME.  Since N is already
;  offset by -1 above, then will be no more adjustment.
;  If S < 0, then START_TIME < TIME[0].  When this happen, set S = 0.
;
   S = ( S LT 0 ) ? 0 : S
   N = N_ELEMENTS( NANO_TIME )  ; Get the End  point.
;
   ALL_DETHGTPNG_FILE = ID +  '25Apr2015onDET.png'  ; File names for
   ALL_BPRHGTPNG_FILE = ID +  '25Apr2015onBPR.png'  ; the figures.
;
   RANGE       =  STRING( FORMAT='(C(CDI2.2,X,CMoa,X,CYI))', T )
   TITLE4PLOT  = 'RSN-NANO-BPR (' + ID  +  '), '  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
   TITLE4PLOT += 'raw data and with the tidal signal removed since ' + RANGE
;
;  Shorten the array variables: NANO_[TIME,TEMP & DETIDE] plus HEIGHT
;  to avoid "% Unable to allocate memory." message from IDL.
;  Note that it is OK to shorten the array variables here since they are
;  local variables here and being used the last time.   March 27th, 2019
;
           T   = NANO_TIME[S:N-1]
   NANO_TIME   = TEMPORARY( T )
           T   = NANO_DETIDE[S:N-1]
   NANO_DETIDE = TEMPORARY( T )
           T   =      HEIGHT[S:N-1]
        HEIGHT = TEMPORARY( T )
           T   = NANO_TEMP[S:N-1]
   NANO_TEMP   = TEMPORARY( T )
;
   RSN_PLOT_BPR, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,        $
;                NANO_TIME[S:N-1],   HEIGHT[S:N-1], NANO_DETIDE[S:N-1],  $
                 NANO_TIME,          HEIGHT,        NANO_DETIDE,         $
                 ALL_BPRHGTPNG_FILE
   TITLE4PLOT  = 'RSN-NANO-BPR (' + ID +  '), '   $
              +  'data with the tidal signal removed since ' + RANGE
   RSN_PLOT_DET, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,        $
;                NANO_TIME[S:N-1], NANO_DETIDE[S:N-1], NANO_TEMP[S:N-1], $
                 NANO_TIME,        NANO_DETIDE,        NANO_TEMP,        $
                 ALL_DETHGTPNG_FILE
ENDIF
;
  CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_NANO_DATA
