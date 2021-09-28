;
; This procedure has the same function as the PLOT_LILY_DATA except
; here it will only plot the LILY Tilt Magenitdes and Directions.
;
; Callers: Users
; Revised: December   5th, 2018
;
PRO PLOT_LILY_RTMD, IDL_FILE,   $ ;  Input: IDL Save File name.
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
; Note that LILY_TEMP, LILY_XTILT and LILY_YTILT array values will not be used here.
;
  RESTORE, IDL_FILE
;
  LILY_TEMP  = 0
  LILY_XTILT = 0  ; Free up these arrays
  LILY_YTILT = 0  ; so that IDL has more memories.
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
   RTMD3DAYPNG_FILE = ID + '7DaysRTMD.png'  ; plotting the LILY's
  ALL_RTMD_PNG_FILE = ID + 'AllRTMD.png'    ; Resultant Tilt Magnitudes + Directions.
ENDIF  ELSE  BEGIN
   RTMD3DAYPNG_FILE = 'Do Not Save'         ; will Not be saved.
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
  DAY_OFFSET = WHAT2PLOT[0]  ; e.g -3 = Plot the last 3 days, data.
  LONG_TERM  = WHAT2PLOT[1]  ; e.g  1 = Plot All the data.
;
IF LONG_TERM  GT 0 THEN  BEGIN  ; Plot the Long  Term Data Set.
   TITLE4PLOT = 'RSN-LILY (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
              + ') Resultant Tilt Magnitudes and Directions, '
      T = LILY_TIME[N-1] - LILY_TIME[0]  ; Total days in the data.
   IF T LT 1200 THEN  BEGIN  ; Display every data points.
      RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN,           $
                     TITLE=TITLE4PLOT + 'Start to Present.',  $
                     LILY_TIME, RTM, RTD, ALL_RTMD_PNG_FILE
   ENDIF  ELSE  BEGIN  ; LILY_TIME[S:N] > 1200 Days.  Display only every 3600th points.
;     Note that LILY data are 1 second per data point.                 December 5th, 2018.
;     Create an array indexes at every 3600th point including the end point.
      S = [ ULINDGEN( N/3600 )*3600, N-1 ]  ; Array indexes at every 3600th point + the end point.
      RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
                     LILY_TIME[S], RTM[S], RTD[S], ALL_RTMD_PNG_FILE
      S = 0 ; Free the variable.
   ENDELSE  ; Plotting LILY's Resultant Tilt Magnitudes and Directions.
ENDIF
;
;
IF DAY_OFFSET LT 0 THEN  BEGIN  ; Plot the last few days of the data.
   T = JDAY_TIME_INDEX( LILY_TIME, DAY_OFFSET )
;  IF T GT 0 THEN  BEGIN  ; Time Index is found.
;     TITLE4PLOT = TITLE4PLOT + 'last ' + STRTRIM( ABS( DAY_OFFSET ), 2 )  $
;                             + ' days.'
;  ENDIF  ELSE  BEGIN  ; Time Index is Not found.
;     T =  0  ; All data will be plotted.
;     IF STRPOS( IDL_FILE, '3Day' ) GE 0 THEN  BEGIN  ; It is a Short-Term File.
;        TITLE4PLOT = TITLE4PLOT + 'last 7 days.'; Started on December 5th, 2017
;     ENDIF  ELSE  BEGIN
;        TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
;     ENDELSE
;  ENDELSE
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
   ALL_RTMD_PNG_FILE = ID + '25Apr2015onRTMD.png'    ; Resultant Tilt Magnitudes + Directions.
;
   DAY_OFFSET  =  STRING( FORMAT='(C(CDI2.2,X,CMoa,X,CYI))', T )
   TITLE4PLOT = 'RSN-LILY (' + ID  $
              + ') Resultant Tilt Magnitudes and Directions, since '  + DAY_OFFSET
      T = LILY_TIME[N-1] - LILY_TIME[S]  ; Total days in the data.
   IF T LT 1200 THEN  BEGIN  ; Display every data points.
      RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
          LILY_TIME[S:N-1], RTM[S:N-1], RTD[S:N-1], ALL_RTMD_PNG_FILE
   ENDIF  ELSE  BEGIN  ; LILY_TIME[S:N] > 1200 Days.  Display only every 3600th points.
;     Note that LILY data are 1 second per data point.                 December 5th, 2018.
;     Create an array indexes at every 3600th point including the end point.
      T = [ ( ULINDGEN( ( N - S )/3600 )*3600 + S ), N-1 ]  ; where the N-1 is the end point.
      RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
          LILY_TIME[T], RTM[T], RTD[T], ALL_RTMD_PNG_FILE
      T = 0 ; Free the variable.
   ENDELSE  ; Plotting LILY's Resultant Tilt Magnitudes and Directions.
;
ENDIF
;
  CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_LILY_RTMD
;
; This procedure has the same function as the PLOT_LILY_DATA except
; here it will only plot the LILY Temperature and X & Y Tilt data.
;
; Callers: Users
; Revised: December   5th, 2018
;
PRO PLOT_LILY_TXYT, IDL_FILE,   $ ;  Input: IDL Save File name.
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
; Note that LILY_RTM and LILY_RTD array values will not be used here.
;
  RESTORE, IDL_FILE
;
  LILY_RTM = 0  ; Free up these arrays
  LILY_RTD = 0  ; so that IDL has more memories.
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
;  RTMD3DAYPNG_FILE = ID + '7DaysRTMD.png'  ; plotting the LILY's
  ALL_TILT_PNG_FILE = ID + 'AllLILY.png'    ; X,Y Tilts, temperature &
; ALL_RTMD_PNG_FILE = ID + 'AllRTMD.png'    ; Resultant Tilt Magnitudes + Directions.
ENDIF  ELSE  BEGIN
   TILT3DAYPNG_FILE = 'Do Not Save'         ; Indicate the plotted displays
;  RTMD3DAYPNG_FILE = 'Do Not Save'         ; will Not be saved.
  ALL_TILT_PNG_FILE = 'Do Not Save'         ;
; ALL_RTMD_PNG_FILE = 'Do Not Save'         ;
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
      T = LILY_TIME[N-1] - LILY_TIME[0]  ; Total days in the data.
   IF T LT 1200 THEN  BEGIN  ; Display every data points.
      RSN_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN,     $
               TITLE=TITLE4PLOT + 'Start to Present.',  $
               LILY_TIME, LILY_XTILT, LILY_YTILT,       $
               LILY_TEMP, ALL_TILT_PNG_FILE
   ENDIF  ELSE  BEGIN  ; LILY_TIME > 1200 Days.  Display only every 3600th points.
;     Note that LILY data are 1 second per data point.
      S = [ ULINDGEN( N/3600 )*3600, N-1 ]  ; Array indexes at every 3600th point + the end point.
      RSN_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN,         $
               TITLE=TITLE4PLOT + 'Start to Present.',      $
               LILY_TIME[S], LILY_XTILT[S], LILY_YTILT[S],  $
               LILY_TEMP[S], ALL_TILT_PNG_FILE
      S = 0 ; Free the variable.
   ENDELSE  ; Plotting LILY's Tilts, and Temperature.
;  TITLE4PLOT = 'RSN-LILY (' + ID  $  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
;             + ') Resultant Tilt Magnitudes and Directions, '
;  RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN,           $
;                 TITLE=TITLE4PLOT + 'Start to Present.',  $
;                 LILY_TIME, RTM, RTD, ALL_RTMD_PNG_FILE
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
         TITLE4PLOT = TITLE4PLOT + 'last 7 days.'; Started on December 5th, 2017
      ENDIF  ELSE  BEGIN
         TITLE4PLOT = TITLE4PLOT + 'Start to Present.'
      ENDELSE
   ENDELSE
   RSN_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
       LILY_TIME[T:N-1], LILY_XTILT[T:N-1], LILY_YTILT[T:N-1],      $
       LILY_TEMP[T:N-1], TILT3DAYPNG_FILE
;  TITLE4PLOT = 'RSN-LILY (' + ID  $
;             + ') Resultant Tilt Magnitudes and Directions, last '  $
;             + STRTRIM( ABS( DAY_OFFSET ), 2 ) + ' days or more.'
;  RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
;      LILY_TIME[T:N-1], RTM[T:N-1], RTD[T:N-1], RTMD3DAYPNG_FILE
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
;  ALL_RTMD_PNG_FILE = ID + '25Apr2015onRTMD.png'    ; Resultant Tilt Magnitudes + Directions.
;
   DAY_OFFSET  =  STRING( FORMAT='(C(CDI2.2,X,CMoa,X,CYI))', T )
   TITLE4PLOT  = 'RSN-LILY (' + ID  +  '), '  ; ID = 'MJ03D', 'MJ03E' or 'MJ03F'
   TITLE4PLOT += 'Tilts and Temperature Data since ' + DAY_OFFSET
;
      T = LILY_TIME[N-1] - LILY_TIME[S]  ; Total days in the data.
   IF T LT 1200 THEN  BEGIN  ; Display every data points.
      RSN_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
          LILY_TIME[S:N-1], LILY_XTILT[S:N-1], LILY_YTILT[S:N-1],      $
          LILY_TEMP[S:N-1], ALL_TILT_PNG_FILE
   ENDIF  ELSE  BEGIN  ; LILY_TIME[S:N] > 1200 Days.  Display only every 3600th points.
;     Note that LILY data are 1 second per data point.              December 5th, 2018
;     Create an array indexes at every 3600th point including the end point.
      T = [ ( ULINDGEN( ( N - S )/3600 )*3600 + S ), N-1 ]  ; where the N-1 is the end point.
      RSN_PLOT_LILY, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
          LILY_TIME[T], LILY_XTILT[T], LILY_YTILT[T],      $
          LILY_TEMP[T], ALL_TILT_PNG_FILE
      T = 0 ; Free the variable.
   ENDELSE  ; Plotting LILY's Tilts, and Temperature.
;  TITLE4PLOT = 'RSN-LILY (' + ID  $
;             + ') Resultant Tilt Magnitudes and Directions, since '  + DAY_OFFSET
;  RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
;      LILY_TIME[S:N-1], RTM[S:N-1], RTD[S:N-1], ALL_RTMD_PNG_FILE
ENDIF
;
  CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; PLOT_LILY_TXYT
