;
; File: PlotLongTermDataProducts.pro
;
; This IDL program will display the the Long-Term Data Products
; generated by the NANO data using the GetLongTermNANOdataProducts.pro 
;
; This program will require the procerdures in the files:
; GetLongTermNANOdataProducts.pro,
; PlotNANOdata.pro, PlotRSNdata.pro, and SplitRSNdata.pro
;
; Programmer: T-K Andy Lau NOAA/PMEL/Acoustic Program HMSC Newport Oregon.
;
; Revised on February  11th, 2018
; Created on May       11th, 2015
;

;
; This procedure will display all the data in the LONGTERM_DATA_FILE
; by using the Older IDL Direct Graphic plotting procuders: PLOT, XYOUTS etc.
; Now the PRO PLT_LONGTERM_DATA (new below) is using the Object Oriented
; Graphic routine to do the plotting.
; 
; The data are: 1-Day means, 4- or 8- & 8- or 12-week avergae rates
; of the depth changes.
; 
; Callers: Users. 
; Revised: January   31st, 2018
;
PRO PLOT_LONGTERM_DATA,  LONGTERM_DATA_FILE,  $ ; Input: File name.
      SHOW_PLOT=DISPLAY_PLOT2SCREEN,  $ ; Show the plot in the display window.
    UPDATE_PLOT=SAVE_PLOT,            $ ; 0=Not Save (default) & 1=Save
     WEEK_TERMS=WEEK  ; 2-Element array = [4,8] or [8,12] to indicate the weeks.  1/29/2017
;
; Locate the LONGTERM_DATA_FILE and make sure it exists.
;
  ID = FILE_SEARCH( LONGTERM_DATA_FILE, COUNT=N )
;
IF N LE 0 THEN  BEGIN
   PRINT, 'File: ' + LONGTERM_DATA_FILE + ' does not exist!'
   PRINT, 'Please Check and tye again'
   RETURN ; to Caller.
ENDIF
; 
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
IF NOT KEYWORD_SET( SAVE_PLOT  ) THEN  BEGIN
   SAVE_PLOT  = 0B  ; Not Save.
ENDIF
;
IF NOT KEYWORD_SET(   WEEK     ) THEN  BEGIN  ; Added on January 29th, 2017
   WEEK       = [4,8]  ; Assuming the LONGTERM_DATA_FILE is for 4 & 8-week rates.
ENDIF
;
; Get the RSN's site ID = 'MJ03D', 'MJ03E' or 'MJ03F'
; from the LONGTERM_DATA_FILE where it will be = to
; '~/4Chadwick/RSN/MJ03E/LongTermNANOdataProducts.MJ03E' for example.
;
  N  = STRLEN( LONGTERM_DATA_FILE )
  ID = STRMID( LONGTERM_DATA_FILE, N-5, 5 )  ; = 'MJ03E' e.g.
;
; Get All the DATA in the LONGTERM_DATA_FILE.
;
; Note that the RETRIEVE_NANO_DATA_PRODUCTS procedure is in the
; file: GetLongTermNANOdataProducts.pro
;
  RETRIEVE_NANO_DATA_PRODUCTS, LONGTERM_DATA_FILE, DATA, STATUS
;
; Note that the DATA will be 2-D array of N x 4 and
; DATA[*,0] = Date and Time in JULDAY() values.
; DATA[*,1] = 1-Day Means.
; DATA[*,2] = 4 or  8-week avergae rates of the depth change.
; DATA[*,3] = 8 or 12-week avergae rates of the depth change.
;
; Determine the 1st dimensional size of DATA.
;
  C = SIZE( DATA, /DIMENSION )
  N = C[0]  ; = 1st dimensional size of DATA & C[1] will be = 4.
;
IF DISPLAY_PLOT2SCREEN THEN  BEGIN
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
   PRINT, 'Plotting Window: ', !D.WINDOW
ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256, /PIXMAP
   PRINT, 'PIXMAP Window: ', !D.WINDOW
ENDELSE
;
; The following 2 procedures are in the file IDLcolors.pro
;
  SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
; Locate the Max & Min values for the Y-Plotting range for the 1-Day means.
;
  MX = STDEV( DATA[0:N-1,1], MN )  ; MX = Standard Deviation & MN = Mean.
   X = MX * 4.0
  MX = MN + X
  MN = MN - X
  PRINT, 'Max & Min of the All the 1-Day Means from: ' + ID, MX, MN
;
; Determine number of Hourly or Daily marks per day.
;
  N_DAYS = ( DATA[N-1,0] - DATA[0,0] )  ; Data Range in days.
;
  RSN_GET_XTICK_UNITS, N_DAYS, XUNITS, H
;
; Where XUNITS will be returned as ['Hour','DAY'] or ['Day', 'DAY']
; and   H is the XTICKINTERVAL=H for either Hour or Day.
;
; Call LABEL_DATE() to ask for plotting Time Label.
;
IF N_DAYS LE 10 THEN  BEGIN
   H = 1
ENDIF ELSE IF N_DAYS LE 30 THEN  BEGIN
   H = 5
ENDIF
;
XUNITS[0]  = 'Day'  ; always use Day.
TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%D','%N/%D/%Z'] )
;
TIME_RANGE =           STRING( DATA[0,0],    $  ; Date of the 1st data point.
             FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
TIME_RANGE += ' to ' + STRING( DATA[N-1,0],  $  ; to the Last data point.
             FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
;
TITLE4PLOT  = 'RSN-' + ID + ':  Long-Term Average Rates of Depth Change'
;
; Define a plotting symbel: a dot when using PSYM=8.
;
  USERSYM, [-0.3,0.3],[0,0]
  X = FINDGEN( 16 )*!PI/8.0
  USERSYM, COS( X ), SIN( X ), /FILL  ;, THICK=2
;
; Define the Hardware Fonts to be used.
;   
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
;
 !P.FONT  = 0  ; Use the hardware font above.
 !X.THICK = 1
 !Y.THICK = 1  ; for thinker line drawing.
;
; Display the 1-Day Means.
;
; PLOT, DATA[0:N-1,0], DATA[0:N-1,1],     XMARGIN=[9,9],  $
;       YSTYLE=1+4, YRANGE=[MN,MX],       YMARGIN=[6,2],  $
;       XSTYLE=1,   XRANGE=[DATA[0,0]-1,DATA[N-1,0]+1],   $
;       XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
;       XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT, /NODATA
; XYOUTS, ALIGNMENT=1, /DEVICE, 55, 240, 'Meters', COLOR=C.RED
; XYOUTS, ALIGNMENT=1, /DEVICE, 45,  45, XUNITS[0] + ':'
; where XUNITS[0] = 'Hour:' or 'Day:'
; AXIS, YAXIS=0, YRANGE=[MN,MX], YSTYLE=1, CHARSIZE=1.15, COLOR=C.RED
;
; Overplot the 1-Day means by Light-Blue Dots. July 6, 2010.
;
; OPLOT, DATA[0:N-1,0], DATA[0:N-1,1], COLOR=C.RED, THICK=2, PSYM=4
;
;  PLOTS, /DEVICE,  40, 15, COLOR=C.RED, THICK=2, PSYM=4
; XYOUTS, /DEVICE,  50, 10, '1-Day Means'
;
; Locate the Max & Min values for the Y-Plotting range for the Change Rates.
;
  MX = MAX( DATA[0:N-1,2:3], MIN=MN )
  PRINT, 'Max & Min of the All the Rates from: ' + ID, MX, MN
  MX =  CEIL( MX )      ; This will make the the
  MN = FLOOR( MN )      ; Y-Range too wide to show the details.
; MX = ( (  CEIL( MX ) - MX ) GT 0.5 ) ? ( CEIL( MX ) - 0.5 ) : CEIL( MX )
; MN = ( ( MN - FLOOR( MN ) ) LT 0.5 ) ? FLOOR( MN ) : ( FLOOR( MN ) + 0.5 )
; MX =  CEIL( MX ) + 1  ;  April 28th, 2015 
; MN = FLOOR( MN ) - 1  ;
;
; Double the [MN,MX] range.
;
   R = ( MX - MN )/2.0  ; Half of the Y-Range
  MX += R   ; [MN - R, MX + R] will
  MN -= R   ; Double the Y-Range.
  HELP, MX, MN
; 
; Define the Rate values' area.
; 
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, DATA[0:N-1,0], DATA[0:N-1,2], /NODATA,   $ ; /NOERASE,   $
        YSTYLE=1, YRANGE=[MN,MX], XMARGIN=[9,9], YMARGIN=[6,2],  $
        XSTYLE=1, XRANGE=[DATA[0,0]-1,DATA[N-1,0]+1],            $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'],                 $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, XTICKUNITS=XUNITS,   $
         TITLE=TITLE4PLOT
  XYOUTS, ALIGNMENT=1, /DEVICE, 45,  45, XUNITS[0] + ':'
; where XUNITS[0] = 'Hour:' or 'Day:'
  AXIS, YAXIS=1, YRANGE=[MN,MX], YSTYLE=1, CHARSIZE=1.15
;
; Plot the 4- & 8-week or 8- & 12-week average rates of depth changes.
;
  IF WEEK[0] LE 4 THEN  BEGIN  ; Assume the data are 4- & 8-week.
     OPLOT, DATA[0:N-1,0], DATA[0:N-1,2], COLOR=C.BLUE ,  PSYM=8  ;  4-week rate.
     OPLOT, DATA[0:N-1,0], DATA[0:N-1,3], COLOR=C.GREEN,  PSYM=8  ;  8-week rate.
      PLOTS, /DEVICE, 550, 15, COLOR=C.BLUE,  THICK=2,  PSYM=8
     XYOUTS, /DEVICE, 560, 10, '4-week Rate', COLOR=C.BLUE
      PLOTS, /DEVICE, 650, 15, COLOR=C.GREEN, THICK=2,  PSYM=8
     XYOUTS, /DEVICE, 660, 10, '8-week Rate', COLOR=C.GREEN
  ENDIF  ELSE  BEGIN     ; Assume the data are 8-week & 12-week.
     OPLOT, DATA[0:N-1,0], DATA[0:N-1,2], COLOR=C.GREEN,  PSYM=8  ;  8-week rate.
     OPLOT, DATA[0:N-1,0], DATA[0:N-1,3], COLOR=C.PURPLE, PSYM=8  ; 12-week rate.
      PLOTS, /DEVICE, 500, 75, COLOR=C.GREEN,  THICK=2, PSYM=8
     XYOUTS, /DEVICE, 510, 70,  '8-week Rate', COLOR=C.GREEN
      PLOTS, /DEVICE, 600, 75, COLOR=C.PURPLE, THICK=2, PSYM=8
     XYOUTS, /DEVICE, 610, 70, '12-week Rate', COLOR=C.PURPLE
;     PLOTS, /DEVICE, 550, 15, COLOR=C.BLUE,   THICK=2, PSYM=8
;    XYOUTS, /DEVICE, 560, 10,  '8-week Rate', COLOR=C.GREEN
;     PLOTS, /DEVICE, 650, 15, COLOR=C.PURPLE, THICK=2, PSYM=8
;    XYOUTS, /DEVICE, 660, 10, '12-week Rate', COLOR=C.PURPLE
  ENDELSE
;
; OPLOT, DATA[0:N-1,0], DATA[0:N-1,2], COLOR=C.BLUE ,  PSYM=8  ; 4 or  8-week rate.
; OPLOT, DATA[0:N-1,0], DATA[0:N-1,3], COLOR=C.GREEN,  PSYM=8  ; 8 or 12-week rate.
;
;  PLOTS, /DEVICE, 550, 15, COLOR=C.BLUE,  THICK=2, PSYM=8
; XYOUTS, /DEVICE, 560, 10, '4-week Rate'
; XYOUTS, /DEVICE, 560, 10, STRTRIM( WEEK[0], 2 ) + '-week Rate'  ; 1/29/2017
;  PLOTS, /DEVICE, 650, 15, COLOR=C.GREEN, THICK=2, PSYM=8
; XYOUTS, /DEVICE, 660, 10, '8-week Rate'
; XYOUTS, /DEVICE, 660, 10, STRTRIM( WEEK[1], 2 ) + '-week Rate'  ; 1/29/2017
;
 !P.FONT  = -1  ; Back to graphic font.
;
; Label the Left & Right Y-Axes.
;
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, ORIENTATION=90,  $
          /DEVICE,  25, 130, '!17cm/year'  ; Left  Y-Axis.
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, ORIENTATION=90,  $
          /DEVICE, 780, 130, '!17cm/year'  ; Right Y-Axis.
;
IF SAVE_PLOT  THEN  BEGIN  ; If it is asked for.
;  Construct an Output File name with the directory path (from the
;  LONGTERM_DATA_FILE if any ) attached.
;  For example: '~/4Chadwick/RSN/MJ03E/MJ03E-LTrates.png'.
;  Note that the ID will be either MJ03D/, MJ03E/ or MJ03F/
   TITLE4PLOT = FILE_DIRNAME( LONGTERM_DATA_FILE, /MARK_DIRECTORY )  $
              + ID + '-LTrates.png'  ; Output File name.
   WRITE_PNG, TITLE4PLOT, TVRD( TRUE=1 )    ; Save the graph as a png file.
   PRINT, 'Graphic File: ' + TITLE4PLOT + ' is created.'
ENDIF
;
IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN
       MX = !D.WINDOW
   WDELETE, !D.WINDOW  ; Remove the PIXMAP window.
   PRINT, 'Removed PIXMAP Window: ', MX
   SET_PLOT, 'X'  ; Back to Window Plotting.
ENDIF
;
RETURN
END  ; PLOT_LONGTERM_DATA
;
; This procedure will display all the data in the LONGTERM_DATA_FILE
; by using the IDL Object Oriented Graphic routine to do the plotting.
; 
; This procedure will display all the data in the LONGTERM_DATA_FILE
; The data are: 1-Day means, 4- or 8- & 8- or 12-week avergae rates
; of the depth changes.
; 
; Callers: Users. 
; Revised: February   4th, 2019
;
PRO PLT_LONGTERM_DATA,  LONGTERM_DATA_FILE,  $ ; Input: File name.
      SHOW_PLOT=DISPLAY_PLOT2SCREEN,  $ ; Show the plot in the display window.
    UPDATE_PLOT=SAVE_PLOT,            $ ; 0=Not Save (default) & 1=Save
     WEEK_TERMS=WEEK  ; 2-Element array = [4,8] or [8,12] to indicate the weeks.  1/29/2017
;
; Locate the LONGTERM_DATA_FILE and make sure it exists.
;
  ID = FILE_SEARCH( LONGTERM_DATA_FILE, COUNT=N )
;
IF N LE 0 THEN  BEGIN
   PRINT, 'File: ' + LONGTERM_DATA_FILE + ' does not exist!'
   PRINT, 'Please Check and tye again'
   RETURN ; to Caller.
ENDIF
; 
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
IF NOT KEYWORD_SET( SAVE_PLOT  ) THEN  BEGIN
   SAVE_PLOT  = 0B  ; Not Save.
ENDIF
;
IF NOT KEYWORD_SET(   WEEK     ) THEN  BEGIN  ; Added on January 29th, 2017
   WEEK       = [4,8]  ; Assuming the LONGTERM_DATA_FILE is for 4 & 8-week rates.
ENDIF
;
; Get the RSN's site ID = 'MJ03D', 'MJ03E' or 'MJ03F'
; from the LONGTERM_DATA_FILE where it will be = to
; '~/4Chadwick/RSN/MJ03E/LongTermNANOdataProducts.MJ03E' for example.
;
  N  = STRLEN( LONGTERM_DATA_FILE )
  ID = STRMID( LONGTERM_DATA_FILE, N-5, 5 )  ; = 'MJ03E' e.g.
;
; Get All the DATA in the LONGTERM_DATA_FILE.
;
; Note that the RETRIEVE_NANO_DATA_PRODUCTS procedure is in the
; file: GetLongTermNANOdataProducts.pro
;
  RETRIEVE_NANO_DATA_PRODUCTS, LONGTERM_DATA_FILE, DATA, STATUS
;
; Note that the DATA will be 2-D array of N x 4 and
; DATA[*,0] = Date and Time in JULDAY() values.
; DATA[*,1] = 1-Day Means.
; DATA[*,2] = 4 or  8-week avergae rates of the depth change.
; DATA[*,3] = 8 or 12-week avergae rates of the depth change.
;
; Determine the 1st dimensional size of DATA.
;
  S = SIZE( DATA, /DIMENSION )
  N = S[0]  ; = 1st dimensional size of DATA & C[1] will be = 4.
;
; Locate the Max & Min values for the Y-Plotting range for the 1-Day means.
;
  MX = STDEV( DATA[0:N-1,1], MN )  ; MX = Standard Deviation & MN = Mean.
   S = MX * 4.0
  MX = MN + S
  MN = MN - S
  PRINT, 'Max & Min of the All the 1-Day Means from: ' + ID, MX, MN
;
; Define the Time Range and the Title labes.
;
  TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%D','%N/%D/%Z'] )
;
  TIME_RANGE =           STRING( DATA[0,0],    $  ; Date of the 1st data point.
               FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
  TIME_RANGE += ' to ' + STRING( DATA[N-1,0],  $  ; to the Last data point.
               FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI))' )
;
  TITLE4PLOT  = 'RSN-' + ID + ':  Long-Term Average Rates of Depth Change'
;
;
; Locate the Max & Min values for the Y-Plotting range for the Change Rates.
;
  MX = MAX( DATA[0:N-1,2:3], MIN=MN )
  PRINT, 'Max & Min of the All the Rates from: ' + ID, MX, MN
  MX =  CEIL( MX )      ; This will make the the
  MN = FLOOR( MN )      ; Y-Range too wide to show the details.
; MX = ( (  CEIL( MX ) - MX ) GT 0.5 ) ? ( CEIL( MX ) - 0.5 ) : CEIL( MX )
; MN = ( ( MN - FLOOR( MN ) ) LT 0.5 ) ? FLOOR( MN ) : ( FLOOR( MN ) + 0.5 )
; MX =  CEIL( MX ) + 1  ;  April 28th, 2015 
; MN = FLOOR( MN ) - 1  ;
;
; Double the [MN,MX] range.
;
   S = ( MX - MN )/2.0  ; Half of the Y-Range
  MX += S   ; [MN - R, MX + R] will
  MN -= S   ; Double the Y-Range.
  HELP, MX, MN
; 
;
  IF DISPLAY_PLOT2SCREEN THEN  BEGIN
     B = 0  ; For the BUFFER=0 to show the figure.
  ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
     B = 1  ; For the BUFFER=1 to Not show the figurei on the screen.
  ENDELSE
; 
; Display the 4-week, 8-week and 12-week Rates from the 1-Day Means.
;
  IF WEEK[0] LE 4 THEN  BEGIN  ; Assume the data are 4- & 8-week.
     P = PLOT( DATA[0:N-1,0], DATA[0:N-1,2],  LINESTYLE='NONE', BUFFER=B,   $
               SYMBOL='o', SYM_COLOR='BLUE', SYM_FILLED=1,  $   ; 4-week rate.
;              TITLE=TITLE4PLOT, DIMENSION=[1024,512],      $
               TITLE=TITLE4PLOT, DIMENSION=[ 805,300],      $
;              XRANGE=[ JULDAY(1,1,2015), JULDAY(1,1,2022) ],                $
               XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XMINOR=11, XSTYLE=1,  $
               XTITLE=TIME_RANGE, YTITLE='cm/year',    YRANGE=[MN,MX]        )
     S = SYMBOL( /NORMAL, 0.45, 0.8, 'o',  LABEL_COLOR='BLUE',  LABEL_STRING='4-week',  $
                 /SYM_FILLED, SYM_COLOR='BLUE'  )
     S = PLOT( DATA[0:N-1,0], DATA[0:N-1,3],  LINESTYLE='NONE',   $  ; 8-week rate.
              /OVERPLOT, YRANGE=[MN,MX], $  ; So the Y-Axis will not be adjusted.
               SYMBOL='o', SYM_COLOR='GREEN', SYM_FILLED=1   )
     S = SYMBOL( /NORMAL, 0.55, 0.8, 'o',  LABEL_COLOR='GREEN', LABEL_STRING='8-week',  $
                 /SYM_FILLED, SYM_COLOR='GREEN' )
  ENDIF  ELSE  BEGIN     ; Assume the data are 8-week & 12-week.
     P = PLOT( DATA[0:N-1,0], DATA[0:N-1,2],  LINESTYLE='NONE', BUFFER=B,   $
               SYMBOL='o', SYM_COLOR='GREEN', SYM_FILLED=1,  $  ; 8-week rate.
;              TITLE=TITLE4PLOT, DIMENSION=[1024,512],       $
               TITLE=TITLE4PLOT, DIMENSION=[ 805,300],       $
               XTICKFORMAT='(C(CDI,1x,CMoA,1X,CYI))',  XMINOR=11, XSTYLE=1,  $
               XTITLE=TIME_RANGE, YTITLE='cm/year',    YRANGE=[MN,MX]        )
     S = SYMBOL( /NORMAL, 0.45, 0.8, 'o',  LABEL_COLOR='GREEN',  LABEL_STRING='4-week',  $
                 /SYM_FILLED, SYM_COLOR='GREEN'  )
     S = PLOT( DATA[0:N-1,0], DATA[0:N-1,3],  LINESTYLE='NONE',   $  ; 12-week rate.
              /OVERPLOT, YRANGE=[MN,MX], $  ; So the Y-Axis will not be adjusted.
               SYMBOL='o', SYM_COLOR='PURPLE', SYM_FILLED=1   )
     S = SYMBOL( /NORMAL, 0.55, 0.8, 'o',  LABEL_COLOR='PURPLE', LABEL_STRING='12-week', $
                 /SYM_FILLED, SYM_COLOR='PURPLE' )
  ENDELSE
;
  IF SAVE_PLOT  THEN  BEGIN  ; If it is asked for.
;    Construct an Output File name with the directory path (from the
;    LONGTERM_DATA_FILE if any ) attached.
;    For example: '~/4Chadwick/RSN/MJ03E/MJ03E-LTrates.png'.
;    Note that the ID will be either MJ03D/, MJ03E/ or MJ03F/
     TITLE4PLOT = FILE_DIRNAME( LONGTERM_DATA_FILE, /MARK_DIRECTORY )  $
                + ID + '-LTrates.png'  ; Output File name.
     WRITE_PNG, TITLE4PLOT, P.CopyWindow()    ; Save the graph as a png file.
     PRINT, 'Graphic File: ' + TITLE4PLOT + ' is created.'
  ENDIF
; 
RETURN
END  ; PLT_LONGTERM_DATA
;
; The rouitne will use the Current NANO data and the most recent
; saved 1-Day means to display these together for verifications
; that the 1-Day means are computed correctly.
;
; Callers: Users.
; Revised: January 31st, 2018
;
PRO PLOT_LTD4CHECKING,  NANO_FILE,  $ ; Input: IDL Save File name.
                   NANO1DAYM_FILE,  $ ; Input: IDL Save File name.
    SHOW_PLOT=DISPLAY_PLOT2SCREEN,  $ ; Show the plot in the display window.
    UPDATE_PLOT=SAVE_PLOT             ; 0=Not Save (default) & 1=Save
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
IF NOT KEYWORD_SET( SAVE_PLOT  ) THEN  BEGIN
   SAVE_PLOT  = 0B  ; Not Save.
ENDIF
;
; Define the shorter NANO arrays' variable names in the COMMON NANO.
; Note the arrays: NANO_PSIA & NANO_TEMP will not be be used here.
;
  COMMON NANO,      NANO_TIME, NANO_PSIA, NANO_DETIDE, NANO_TEMP
  COMMON NANO1DAYM, NANO1DAY_MEAN, NANO1DAY_TIME  ; For the 1-Day means.
;
; Get the RSN's site ID = 'MJ03D', 'MJ03E' or 'MJ03F'
; from the NANO_FILE & NANO1DAYM_FILE. 
;
  N  = STRLEN( NANO_FILE )
  ID = STRMID( NANO_FILE,   N-14, 5 )  ; = 'MJ03D' e.g.
   D = STRMID( NANO1DAYM_FILE, 0, 5 )
;
IF ID NE D THEN  BEGIN
   PRINT, 'File: ' + NANO_FILE
   PRINT, 'File: ' + NANO1DAYM_FILE
   PRINT, 'Do Not have the Same RSN site ID: ' + ID + ' Not = ' + D + ' !'
   PRINT, 'No Long-Term data products will be computed.'
   RETURN  ; to Caller
ENDIF
;
; Retrieve the NANO arrays' variablesr for the COMMON NANO.
; from the NANO_FILE = 'MJ03D-NANO.idl' for example.
;
  RESTORE, NANO_FILE
; 
; Retrieve the arrays' variables: NANO1DAY_MEAN & NANO1DAY_TIME
; from the NANO1DAYM_FILE = 'MJ03D-NANO1DayMeans.idl' for example.
;
  RESTORE, NANO1DAYM_FILE
;
; Get the arrays' sizes and All the arrays in the COMMON NANO
; are the same sizes.
;
  T = N_ELEMENTS( NANO_TIME )      ; = N_ELEMENTS( NANO_DETIDE   )
  N = N_ELEMENTS( NANO1DAY_MEAN )  ; = N_ELEMENTS( NANO1DAY_TIME )
;
; Locate where are the correct times in NANO1DAY_TIME which the
; JULDAY()'s values will be > 0.  April 27th, 2015
;
  S = WHERE( NANO1DAY_TIME GT 0, M_DAYS )
  J = M_DAYS - 1
;
; Get the biginning and the end times from the NANO1DAY_TIME.
; The times from the 1-Day means values.
;
  CALDAT, NANO1DAY_TIME[S[0]], M, D, YR
  STIME = JULDAY( M, D, YR, 00, 00, 00 )  ; The Start time.
  CALDAT, NANO1DAY_TIME[S[J]], M, D, YR
  ETIME = JULDAY( M, D, YR, 23, 59, 45 )  ; and the End time.
;
; Get the indexes: [I,J] so that NANO_TIME[I:J] will contain the
; time range of STIME and ETIME.
;
  GET_DATA_RANGE_INDEXES, NANO_TIME,    $ ;
                          STIME,ETIME,  $ ; use the Start & End Times
                          I,    J,      $ ; to the indexes: I,J
                          STATUS          ; STATUS = 1 means OK.
;
IF STATUS EQ 0 THEN  BEGIN  ; All Data in the NANO_DETIDE will be used.
   I = 0
   J = T - 1
ENDIF  ;
;
IF DISPLAY_PLOT2SCREEN THEN  BEGIN
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
   PRINT, 'Plotting Window: ', !D.WINDOW
ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256, /PIXMAP
   PRINT, 'PIXMAP Window: ', !D.WINDOW
ENDELSE
;
; The following 2 procedures are in the file IDLcolors.pro
;
  SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
; Locate the Max & Min values for the Y-Plotting range.
;
; MX = MAX( NANO_DETIDE,      MIN=MN )  ; Before December 1st, 2014
; MX = MAX( NANO1DAY_MEAN,    MIN=MN )  ; After  December 1st, 2014
  MX = MAX( NANO1DAY_MEAN[S], MIN=MN )  ; After  April   28th, 2014
  PRINT, 'Max & Min of the All the 1-Day Means from: ' + ID, MX, MN
; MX =  CEIL( MX )      ; This will make the the
; MN = FLOOR( MN )      ; Y-Range too wide to show the details.
;
; Double the [MN,MX] range.
;
;  R = ( MX - MN )/2.0  ; Half of the Y-Range
; MX += R   ; [MN - R, MX + R] will
; MN -= R   ; Double the Y-Range.
;
; Following IF statement does not work well when the
; MX & MN values are too close to each others.  May 11th, 2015
;
; IF ( MX - MN ) LT 0.25 THEN  BEGIN  ; Extend it to at 1.
;    M   = ( MX + MN )/2.0  ; The Mid-Point between MN & MX.
;    MX  = M + 0.15
;    MN  = M - 0.15
; ENDIF  ELSE  BEGIN
;    April 28th, 2015
;    M  =  CEIL( MX )
;    MX = ( ( M - MX ) GT 0.5 ) ? ( M - 0.5 ) : M
;    M  = FLOOR( MN )
;    MN = ( ( MN - M ) LT 0.5 ) ? M : ( M + 0.5 )
; ENDELSE
;
; Compute the Standard Deviation (R) & Mean (M).  May 12th, 2015
;
  R  = STDEV( NANO_DETIDE[I:J], M )
  R  = 4.0*R       ; = 4 x Standard Deviation.
  X  = M + R       ; Upper Range.
  MX = ( X GT MX ) ? X : MX
  X  = M - R       ; Lower Range.
  MN = ( X LT MN ) ? X : MN
;
  PRINT, 'Max & Min of the Y-Plotting Range: ', MX, MN
;
; Determine number of Hourly or Daily marks per day.
;
  M      =   J - I + 1
  N_DAYS = ( NANO_TIME[J] - NANO_TIME[I] )  ; Data Range in days.
;
  RSN_GET_XTICK_UNITS, N_DAYS, XUNITS, H
;
; Where XUNITS will be returned as ['Hour','DAY'] or ['Day', 'DAY']
; and   H is the XTICKINTERVAL=H for either Hour or Day.
;
; Call LABEL_DATE() to ask for plotting Time Label.
;
IF XUNITS[0] EQ 'Hour' THEN  BEGIN
   TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%H','%N/%D/%Z'] )
ENDIF  ELSE  BEGIN
   TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%D','%N/%D/%Z'] )
ENDELSE
;
TIME_RANGE  = STRING( NANO_TIME[I],  $ ; Date & Time of the 1st data point.
              FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
TIME_RANGE += ' to ' + STRING( NANO_TIME[J],  $  ; to the Last data point.
              FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
TITLE4PLOT  = 'RSN-' + ID + '  De-Tided Depths & 1-Day Means '
;
IF N GT 56 THEN  BEGIN  ; Assuming N == 84 days or 12 weeks
   NWK_DAYS    = 56  ; 56 days or 8 weeks
   TITLE4PLOT += 'plus 8-week and 12-week average uplift rates'
ENDIF  ELSE  BEGIN   ; Assuming N == 56 days or 8 weeks
   NWK_DAYS    = 28  ; 28 days or 4 weeks.
   TITLE4PLOT += 'plus 4-week and 8-week average uplift rates'
ENDELSE
;
; Define a plotting symbel: a dot when using PSYM=8.
;
; USERSYM, [-0.3,0.3],[0,0]
; X = FINDGEN( 16 )*!PI/8.0
; USERSYM, COS( X ), SIN( X ), THICK=2
;
; Define the Hardware Fonts to be used.
;   
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
;
 !P.FONT  = 0  ; Use the hardware font above.
 !X.THICK = 1
 !Y.THICK = 1  ; for thinker line drawing.
;
  PLOT, NANO_TIME[I:J], NANO_DETIDE[I:J], XMARGIN=[9,9],  $
        YSTYLE=2+4, YRANGE=[MX,MN],       YMARGIN=[6,2],  $
        XSTYLE=1,   XRANGE=[NANO_TIME[I],NANO_TIME[J]],   $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT, /NODATA
  AXIS, YAXIS=0, YRANGE=[MX,MN], YSTYLE=2, CHARSIZE=1.15, COLOR=C.RED
  AXIS, YAXIS=1, YRANGE=[MX,MN], YSTYLE=2, CHARSIZE=1.15, COLOR=C.RED
;
; Plot the Detided data in Red.
;
  OPLOT, NANO_TIME[I:J], NANO_DETIDE[I:J], COLOR=C.RED, PSYM=3
;
; Overplot the 1-Day means by Light-Blue Dots. July 6, 2010.
;
; OPLOT, NANO1DAY_TIME[N-28:N-1], NANO1DAY_MEAN[N-28:N-1],  $
; M = ( M_DAYS LT 28 ) ? M_DAYS : 28   ; i.e. If M > 28, Only 28 will be used.
; M = ( M_DAYS LT NWK_DAYS ) ? M_DAYS : NWK_DAYS   ; i.e. If M > NWK_DAYS, Only NWK_DAYS will be used.
; J = S[M_DAYS-1]
; I = J - M
; OPLOT, COLOR=C.BLUE,  THICK=2, PSYM=4,  $      ;
;        NANO1DAY_TIME[I:J], NANO1DAY_MEAN[I:J]  ;  At Most the Last 28 data points.
; IF M_DAYS GT NWK_DAYS THEN  BEGIN
;;   OPLOT, NANO1DAY_TIME[ 0:N-29 ], NANO1DAY_MEAN[ 0:N-29 ],  $
;;   M = M_DAYS - 29
;    M = M_DAYS - NWK_DAYS
;    I = S[0]
;    J = S[M]
;    OPLOT, COLOR=C.GREEN, THICK=2, PSYM=4,  $       ; 
;           NANO1DAY_TIME[I:J], NANO1DAY_MEAN[I:J]   ; The rest of the data points.
; ENDIF
;
; Plot the 1-Day means of the most recent 4 week data.      January 30th, 2018
;
  I = WHERE( NANO1DAY_TIME[S] GE ( NANO1DAY_TIME[S[M_DAYS-1]] - 28 ), M )
  IF M LE 0 THEN  BEGIN
     PRINT, 'No Recent 4 week long of the 1-Day means are foound!  Check the data file: ', $
             NANO1DAYM_FILE
  ENDIF  ELSE  BEGIN
     I = S[I[0]]
     J = S[M_DAYS-1]
     OPLOT, COLOR=C.BLUE,  THICK=2, PSYM=4,  $
            NANO1DAY_TIME[I:J], NANO1DAY_MEAN[I:J]  ;  At Most the Last 28 data points.
  ENDELSE  ; Plotting the 1-Day means of the most recent 4 week data.
;
; Plot the 1-Day means of from the most recent 8-week till beginning of the most recent 4-week.
;
  IF M GT 0 THEN  BEGIN
     J = ( I GT 0 ) ? (I-1) : 0  ; for NANO1DAY_TIME[J] just before the most recent 4 week data.
     I = WHERE( NANO1DAY_TIME[S] GE ( NANO1DAY_TIME[S[M_DAYS-1]] - 56 ), M )
  ENDIF
  IF M LE 0 THEN  BEGIN
     PRINT, 'No Recent 8 week long of the 1-Day means are foound from the data file: ', $
             NANO1DAYM_FILE
  ENDIF  ELSE  BEGIN  ; Plotting the 1-Day means between most recent 8-week & start of 4-week.
     I = S[I[0]]      ; Starting point for the most recent 8-week.
     OPLOT, COLOR=C.GREEN,  THICK=2, PSYM=4,  $     ; Plotting the 1-Day means between most
            NANO1DAY_TIME[I:J], NANO1DAY_MEAN[I:J]  ; recent 8-week & start of the 4-week.
  ENDELSE  ; Plotting the 1-Day means of the most recent 8 week data.
;
; Plot the 1-Day means of from the most recent 12-week till
; beginning of the most recent 8-week if they are available.
;
  IF M GT 0 THEN  BEGIN
     J = ( I GT 0 ) ? (I-1) : 0  ; for NANO1DAY_TIME[J] just before the most recent 8 week data.
     I = S[0]  ; Start at the beginning since the NANO1DAY_TIME is at most 12 weeks long.
     M = J - I + 1  ; Total points between I and J.
  ENDIF
  IF M LE 0 THEN  BEGIN
     PRINT, 'No Recent 12 week long of the 1-Day means are foound from the data file: ', $
             NANO1DAYM_FILE
  ENDIF  ELSE  BEGIN  ; Plotting the 1-Day means between most recent 12-week & start of 8-week.
     OPLOT, COLOR=C.PURPLE, THICK=2, PSYM=4,  $     ; Plotting the 1-Day means between most
            NANO1DAY_TIME[I:J], NANO1DAY_MEAN[I:J]  ; recent 12-week & start of the 8-week.
  ENDELSE  ; Plotting the 1-Day means of the most recent 12 week data.
;
  XYOUTS, ALIGNMENT=1, /DEVICE, 45,  45, XUNITS[0] + ':'
; where XUNITS[0] = 'Hour:' or 'Day:'
;
; Compute the linear least-square fit using the most recent 1-Day means
; of the last 28 points of 4-week data.
;
  M = ( M_DAYS LT 28 ) ? M_DAYS : 28   ; i.e. If M > 28, Only 28 will be used.
                    I = S[M_DAYS-1]
  X = NANO1DAY_TIME[I-28:I] - NANO1DAY_TIME[I-28] ; in Days.
  R = LINFIT( X, NANO1DAY_MEAN[I-28:I], YFIT=Y )
  OPLOT, NANO1DAY_TIME[I-28:I], Y, THICK=2, COLOR=C.BLUE
; X = NANO1DAY_TIME[N-28:N-1] - NANO1DAY_TIME[N-28] ; in Days.
; R = LINFIT( X, NANO1DAY_MEAN[N-28:N-1], YFIT=Y )
; OPLOT, NANO1DAY_TIME[N-28:N-1], Y, THICK=2, COLOR=C.BLUE
; M = ( M_DAYS LT NWK_DAYS ) ? M_DAYS : NWK_DAYS  ; i.e. If M > NWK_DAYS, Only NWK_DAYS will be used.
; J = S[M_DAYS-1]
; I = S[M_DAYS-M]
; X = NANO1DAY_TIME[I:J]      - NANO1DAY_TIME[I]    ; in Days.
; R = LINFIT( X, NANO1DAY_MEAN[I:J], YFIT=Y )
; OPLOT, NANO1DAY_TIME[I:J]     , Y, THICK=2, COLOR=C.BLUE
  RATE1 = -R[1]        ; Save the Slop as the Depth Change/28 Days.
;
; Compute the linear least-square fit using the most recent 1-Day means
; of the last 56 points or 8-week data.
;
  M = ( M_DAYS LT 56 ) ? M_DAYS : 56   ; i.e. If M > 56, Only 56 will be used.
  X = NANO1DAY_TIME[I-56:I] - NANO1DAY_TIME[I-56] ; in Days.
  R = LINFIT( X, NANO1DAY_MEAN[I-56:I], YFIT=Y )
  OPLOT, NANO1DAY_TIME[I-56:I], Y, THICK=2, COLOR=C.GREEN
; X = NANO1DAY_TIME[N-56:N-1] - NANO1DAY_TIME[N-56] ; in Days.
; R = LINFIT( X, NANO1DAY_MEAN[N-56:N-1], YFIT=Y )
; OPLOT, NANO1DAY_TIME[N-56:N-1], Y, THICK=2, COLOR=C.GREEN
  RATE2 = -R[1]  ; for 8-week.
;
; Compute the linear least-square fit using the ALL the recent
; 1-Day mean data.
;
  RATE3 = 0  ; Initialize it.
; IF N GT 56 THEN  BEGIN  ; 12-week data available
  IF M_DAYS GT 56 THEN  BEGIN  ; 12-week data available
     X = NANO1DAY_TIME[S[0]:I] - NANO1DAY_TIME[I] ; in Days.
     R = LINFIT( X, NANO1DAY_MEAN[S[0]:I], YFIT=Y )
     OPLOT, NANO1DAY_TIME[S[0]:I], Y, THICK=2, COLOR=C.PURPLE
;    X = NANO1DAY_TIME - NANO1DAY_TIME[0] ; in Days.
;    R = LINFIT( X, NANO1DAY_MEAN, YFIT=Y )
;    OPLOT, NANO1DAY_TIME, Y, THICK=2, COLOR=C.PURPLE
     RATE3 = -R[1]  ; for 12-week.
  ENDIF
;
; RATE2 = -R[1]  ; If M_DAYS < 28 Days.
; IF M_DAYS GE N THEN  BEGIN  ; All 8-week or 12-week is available.
;    X = NANO1DAY_TIME - NANO1DAY_TIME[0]              ; in Days.
;    R = LINFIT( X, NANO1DAY_MEAN, YFIT=Y )
;    RATE2 = -R[1]        ; Save the Slop as the Depth Change/N Days.
;    OPLOT, NANO1DAY_TIME, Y, THICK=2, COLOR=C.GREEN
; ENDIF ELSE IF ( NWK_DAYS LT M_DAYS ) AND ( M_DAYS LT N ) THEN  BEGIN
;    X = NANO1DAY_TIME[S] - NANO1DAY_TIME[S[0]]
;    R = LINFIT( X, NANO1DAY_MEAN[S], YFIT=Y )
;    RATE2 = -R[1]        ; Save the Slop as the Depth Change/M_DAYS Days.
;    OPLOT, NANO1DAY_TIME[S], Y, THICK=2, COLOR=C.GREEN
; ENDIF
;
; Get the Total Days of the Current Year = 365 or 366.
  R = JULDAY( 12,31,YR ) - JULDAY( 1,0,YR )
; R = 100*DOUBLE( R )    ; Factor for Changing Meters/Days into cm/year.
; Convert the Rate of Depth (meters) Change/Day into cm/year.
  HELP, RATE1, RATE2, RATE3
  RATE1 = RATE1*100.0*R  ; where 100 cm = 1 meter
  RATE2 = RATE2*100.0*R  ; and R = Total days/year = 365 or 366.
  RATE3 = RATE3*100.0*R
  HELP, RATE1, RATE2, RATE3
  R     = STRTRIM( STRING( FORMAT='(F7.1)', [RATE1,RATE2,RATE3] ), 2 )
; IF M_DAYS LT NWK_DAYS THEN  BEGIN  ;
;    R[1] = ' '   ; No Rate of Change for the 8-week or 12-week
; ENDIF 
;
; IF NWK_DAYS GE 56 THEN  BEGIN  ; January 26th, 2018
;    MX = '12-week'
;    MN =  '8-week'
; ENDIF  ELSE  BEGIN  ; NWK_DAYS == 28
;    MX =  '8-week'
;    MN =  '4-week'
; ENDELSE
;
; IF M_DAYS GT NWK_DAYS THEN  BEGIN
;    TITLE4PLOT = MX + ' average uplift rate: ' + R[1] + ' cm/yr'
;    XYOUTS, /DEVICE, 100, 70, TITLE4PLOT,  COLOR=C.GREEN
;     PLOTS, /DEVICE, 50, 15, THICK=2,      COLOR=C.GREEN, PSYM=4
; ENDIF
; TITLE4PLOT = MN + ' average uplift rate: ' + R[0] + ' cm/yr'
; XYOUTS, /DEVICE, 400, 70, TITLE4PLOT,   COLOR=C.BLUE
;  PLOTS, /DEVICE,  40, 15, THICK=2,      COLOR=C.BLUE , PSYM=4
; XYOUTS, /DEVICE,  55, 10, '1-Day Means'
;
; Label the Rates.  January 30th, 2017.
;
  TITLE4PLOT =  '8-week avg. uplift rate: ' + R[1] + ' cm/yr'
  XYOUTS, /DEVICE, 300, 70, TITLE4PLOT, COLOR=C.GREEN
   PLOTS, /DEVICE,  50, 15, THICK=2,    COLOR=C.GREEN, PSYM=4
  TITLE4PLOT =  '4-week avg. uplift rate: ' + R[0] + ' cm/yr'
  XYOUTS, /DEVICE, 520, 70, TITLE4PLOT, COLOR=C.BLUE
   PLOTS, /DEVICE,  40, 15, THICK=2,    COLOR=C.BLUE , PSYM=4
  IF NWK_DAYS GT 28 THEN  BEGIN  ; 12-week data available.
     TITLE4PLOT = '12-week avg. uplift rate: ' + R[2] + ' cm/yr'
     XYOUTS, /DEVICE,  75, 70, TITLE4PLOT, COLOR=C.PURPLE
      PLOTS, /DEVICE,  30, 15, THICK=2,    COLOR=C.PURPLE, PSYM=4
  ENDIF  ; Labelling 12-week rate.
  XYOUTS, /DEVICE,  55, 10, '1-Day Means'
;
 !P.FONT  = -1  ; Back to graphic font.
;
; Label the Left & Right Y-Axes.
;
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.RED, ORIENTATION=90,  $
          /DEVICE,  12, 100, '!17Depth in meters' ; Left  Y-Axis.
; XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.RED,  ORIENTATION=90,  $
;         /DEVICE, 790,  65, '!17De-Tided Depth in meters' ; Right Y-Axis.
;
IF SAVE_PLOT  THEN  BEGIN  ; If it is asked for.
;  Construct an Output File name with the sundirectory path attached.
;  For example: 'MJ03D/MJ03D1DayMeans.png'.  Of cause, it is assumed
;  the currect directory has the sundirectories, MJ03D/, MJ03E/ & MJ03F/
   TITLE4PLOT = ID + PATH_SEP() + ID + '1DayMeans.png'  ; Output File name.
   WRITE_PNG, TITLE4PLOT, TVRD( TRUE=1 )    ; Save the graph as a png file.
   PRINT, 'Graphic File: ' + TITLE4PLOT + ' is created.'
ENDIF
;
IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN
       MX = !D.WINDOW
   WDELETE, !D.WINDOW  ; Remove the PIXMAP window.
   PRINT, 'Removed PIXMAP Window: ', MX
   SET_PLOT, 'X'  ; Back to Window Plotting.
ENDIF
;
RETURN
END ; PLOT_LTD4CHECKING