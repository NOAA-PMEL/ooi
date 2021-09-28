;
; File: PlotNANOdata.pro
;
; This IDL program will generate figures using the RSN data from
; NANO sensors.  The NANO records contain Time Stamps in Year/MM/DD Hr:Mm:Sd
; pressure, detided pressure and temperatues.
;
; The figures will be either 3-Day plots or the Cumulative 1-Year Plot.
;
; The RSN data are collected by the OOI Regional Scale Nodes program
; statred on August 2014 from the Axial Summit.
;
; The procedures in this program will be used by the procerdures
; in the file: PlotRSNdata.pro
;
; Revised on August     1st, 2018
; Created on October    6th, 2014
;

;
; Callers: All the RSN Plotting Routines.
; Revised: August   1st, 2018
;
PRO RSN_GET_XTICK_UNITS, DATA_RANGE_IN_DAYS,  $ ; Input.
                          UNITS,    $ ; Output: 2-Elements String Array.
                          INTERVAL    ; Output: Interval Spacing.
;
UNITS = ['Hour','DAY']  ; Default.
;
IF DATA_RANGE_IN_DAYS LE 4 THEN  BEGIN
   INTERVAL = 6     ; for <= 4 Days range of data.
ENDIF ELSE IF DATA_RANGE_IN_DAYS LE  30 THEN  BEGIN
;  INTERVAL = 12    ; for between  4 & 30 Days range of data.
   INTERVAL = 24    ; for between  4 & 30 Days range of data.
ENDIF ELSE IF DATA_RANGE_IN_DAYS LE  60 THEN  BEGIN
   UNITS    = ['Day', 'DAY']
   INTERVAL = 10    ; for between 31 & 60 Days range of data.
ENDIF ELSE IF DATA_RANGE_IN_DAYS LE 730 THEN  BEGIN
   UNITS    = ['Day', 'DAY']
   INTERVAL = 30    ; for >  4 Days range of data.  Oct.  24, 2014
ENDIF ELSE BEGIN  ; for DATA_RANGE_IN_DAYS > 730, i.e. > 2 years.
   UNITS    = ['Day', 'DAY']
   INTERVAL = 60    ; August 1st, 2018.
ENDELSE
;
RETURN
END  ; GET_XTICK_UNITS
;
; This procedure will plot the BPR and with De-Tided BPR data.
;
; Callers: PLOT_NANO_DATA in the file: PlotRSNdata.pro & Users.
; Revised: October   23rd, 2014
;
PRO RSN_PLOT_BPR,  TIME_STAMP,  $ ; 1-D arrays in Julian Days.
             HEIGHT,  DETIDED,  $ ; 1-D arrays in meters.
                  OUTPUT_FILE,  $ ; for the plotted graph as *.png file. 
        TITLE=TITLE4PLOT,       $ ; e.g. 'RSN-BPR Heigths.'
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; TIME_STAMP = 1-D arrays in Julian Days.
; HEIGHT     = 1-D arrays in millimeters.
;
IF DISPLAY_PLOT2SCREEN THEN  BEGIN
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
   PRINT, 'Plotting Window: ', !D.WINDOW
ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256, /PIXMAP
   PRINT, 'PIXMAP Window: ', !D.WINDOW
ENDELSE
;
IF NOT KEYWORD_SET( TITLE4PLOT ) THEN  BEGIN
   TITLE4PLOT = 'RSN-NANO-BPR Orignal & with the Tidal Signal Removed Height.'
ENDIF
;
; The following 2 procedures are in the file IDLcolors.pro
;
SET_BACKGROUND, /WHITE  ; Plotting background to White.
RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
MX = MAX( [ HEIGHT, DETIDED ], MIN=MN )
;
; Determine number of Hourly or Daily marks per day.
;
N      = N_ELEMENTS( TIME_STAMP )
N_DAYS = ( TIME_STAMP[N-1] - TIME_STAMP[0] )  ; Data Range in days.
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
;  TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%D','%D %M %Y'] )
ENDELSE
;
TIME_RANGE = STRING( TIME_STAMP[0], $ ; Date & Time of the 1st data point.
             FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
TIME_RANGE += ' to ' + STRING( TIME_STAMP[N-1],  $  ; to the Last data point.
             FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Define the Hardware Fonts to be used.
;
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
;
 !P.FONT  = 0  ; Use the hardware font above.
 !X.THICK = 1
 !Y.THICK = 1  ; for thinker line drawing.
;   
  PLOT, TIME_STAMP, HEIGHT,  /NODATA,  YMARGIN=[6,2],      $
;       YRANGE=[MN,MX], YSTYLE=2+4,    XMARGIN=[9,9],      $
        YRANGE=[MX,MN], YSTYLE=2+4,    XMARGIN=[9,9],      $
        XSTYLE=1, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]],  $
;       XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=['Hour','DAY'], $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT  , PSYM=3
;  e.g. TITLE4PLOT='RSN Height data, last 3 days.'
  AXIS, COLOR=C.BLUE, YAXIS=0, YRANGE=[MX,MN] ;, YTITLE='Depth in meters'
  AXIS, COLOR=C.RED , YAXIS=1, YRANGE=[MX,MN] ;, YTITLE='De-Tided Depth in meters'
;
; HEIGHT_OFFSET = 872.0  ; Meters.  July 6, 2010.
;  
  OPLOT, TIME_STAMP,  HEIGHT, COLOR=C.BLUE  , PSYM=3
  OPLOT, TIME_STAMP, DETIDED, COLOR=C.RED   , PSYM=3
  XYOUTS, ALIGNMENT=1, /DEVICE, 45,  45, XUNITS[0] + ':'
; XYOUTS, ALIGNMENT=1, /DEVICE, 45,  45, 'Hour:'
;
 !P.FONT  = -1  ; Back to graphic font.
;
; Label the Left & Right Y-Axes.
;
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.BLUE, ORIENTATION=90,  $
          /DEVICE,  15, 100, '!17Depth in meters' ; Left  Y-Axis.
  XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.RED,  ORIENTATION=90,  $
          /DEVICE, 790,  65, '!17De-Tided Depth in meters' ; Right Y-Axis.
;
; If the OUTPUT_FILE name is Not = 'Do Not Save',
; Save the graph into the output file.
;
IF ( OUTPUT_FILE NE 'Do Not Save' ) AND ( OUTPUT_FILE NE '' ) THEN  BEGIN
;  Assume the OUTPUT_FILE name is = '3DaysBPR.png' or 'AllBPR.png' e.g.
   WRITE_PNG, OUTPUT_FILE, TVRD( TRUE=1 )  ; Save the graph as a png file.
ENDIF
;
IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN
       MX = !D.WINDOW
   WDELETE, !D.WINDOW  ; Remove the PIXMAP window.
   PRINT, 'Removed PIXMAP Window: ', MX
ENDIF
;
RETURN
END  ; RSN_PLOT_BPR
;
; This procedure will plot the De-Tided BPR data
; and Temperature.
;
; Callers: PLOT_NANO_DATA in the file: PlotRSNdata.pro & Users.
; Revised: December   5th, 2017
;
PRO RSN_PLOT_DET,  TIME_STAMP,  $ ; 1-D arrays in Julian Days.
                      DETIDED,  $ ; 1-D arrays in meters.
                  TEMPERATURE,  $ ; 1-D arrays in degrees C.
                  OUTPUT_FILE,  $ ; for the plotted graph as *.png file. 
 OVERPLOT_SMOOTH_DETIDED=N_SM,  $ ; 1=Yes, 0=No (Default)
        TITLE=TITLE4PLOT,       $ ; e.g. 'RSN-BPR Heigths.'
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; TIME_STAMP = 1-D arrays in Julian Days.
; HEIGHT     = 1-D arrays in millimeters.
;
IF DISPLAY_PLOT2SCREEN THEN  BEGIN
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
   PRINT, 'Plotting Window: ', !D.WINDOW
ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256, /PIXMAP
   PRINT, 'PIXMAP Window: ', !D.WINDOW
ENDELSE
;
IF NOT KEYWORD_SET( N_SM ) THEN  BEGIN
   N_SM = 0  ; No Overplot the smoothed De-tided Data (DETIDED).
ENDIF
;
IF NOT KEYWORD_SET( TITLE4PLOT ) THEN  BEGIN
   TITLE4PLOT = 'RSN-NANO-BPR Orignal with the Tidal Signal Removed Height.'
ENDIF
;
; The following 2 procedures are in the file IDLcolors.pro
;
SET_BACKGROUND, /WHITE  ; Plotting background to White.
RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
; Determine the Y-Plotting Range for the Temperature data.
;
  MX = MAX( TEMPERATURE, MIN=MN )  ; in dergees C.
; MX =  CEIL( MX )  ; Used before
; MN = FLOOR( MN )  ; April 27th, 2015
  HELP, MX, MN
;
; The following MX & MN calcalutions are being Tested on April 28th, 2015.
;
; M  =  LONG( MX )
; MX = ( ABS( MX MOD M ) GT 0.5 ) ?  CEIL( MX )  $
;    : ( M  + ( ( MX GT 0 ) ? 0.5 : -0.5 ) )
; M  =  LONG( MN )
; MN = ( ABS( MN MOD M ) LT 0.5 ) ? FLOOR( MN )  $
;    : ( M  + ( ( MN GT 0 ) ? 0.5 : -0.5 ) )
;
; Compute the TEMPERATURE plotting range which will be
; Average of TEMPERATURE +/- 4 x Standard Deviation of the TEMPERATURE.
;
  S  = STDEV( TEMPERATURE, M )  ; Compute the Standard Deviation (S) & Mean (M).
  H  = M + 4.0*S
  MX = ( H GT MX ) ? H : MX
  H  = M - 4.0*S
  MN = ( H LT MN ) ? H : MN
  HELP, MX, MN
;
; Determine number of Hourly or Daily marks per day.
;      
N      = N_ELEMENTS( TIME_STAMP )
N_DAYS = ( TIME_STAMP[N-1] - TIME_STAMP[0] )  ; Data Range in days.
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
; HEIGHT_OFFSET = 872.0  ; Meters.  July 6, 2010.
;
TIME_RANGE = STRING( TIME_STAMP[0], $ ; Date & Time of the 1st data point.
             FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
TIME_RANGE += ' to ' + STRING( TIME_STAMP[N-1],  $  ; to the Last data point.
             FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
;
; Define the Hardware Fonts to be used.
;
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
;
 !P.FONT  = 0  ; Use the hardware font above.
 !X.THICK = 1
 !Y.THICK = 1  ; for thinker line drawing.
;
; Display the Temperature values 1st.  Started on September 27th, 2017
;
  PLOT, TIME_STAMP, TEMPERATURE,    XMARGIN=[12,8], /NODATA,   $
        YSTYLE=1+4, YRANGE=[MN,MX], YMARGIN=[ 6,2], /NOERASE,  $
        XSTYLE=1  , XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]],    $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT, PSYM=3
;  e.g. TITLE4PLOT='RSN Height data, last 3 days.'
 OPLOT, TIME_STAMP, TEMPERATURE, COLOR=C.GREEN, PSYM=3  ; Data points in green.
  AXIS, YAXIS=1, YRANGE=[MN,MX], YSTYLE=2, COLOR=C.GREEN
;       YTITLE='Temperature in C.', CHARSIZE=1.15
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.GREEN, ORIENTATION=90,  $
         /DEVICE, 780,  90, '!17Temperature in C' ; Right Y-Axis Label.
;
; Determine the Y-Plotting Range for the Detided data.
;
  MX = MAX( DETIDED, MIN=MN )  ; Before December 1st, 2014
  HELP, MX, MN
;
IF ( MX - MN ) GT 1.0 THEN  BEGIN  ; August 10th, 2015
;
;  The following MX & MN calcalutions are being tested on April 28th, 2015.
;
   M  =  CEIL( MX )
   MX = ( ( M - MX ) GT 0.5 ) ? ( M - 0.5 ) : M
   M  = FLOOR( MN )
   MN = ( ( MN - M ) LT 0.5 ) ? M : ( M + 0.5 )
   S  = 1
ENDIF  ELSE  BEGIN
;
;  The following MX & MN calculations have been used between
;  December 1st, 2014 and April 27th, 2015
;
   S  = STDEV( DETIDED, M )  ; Compute the Standard Deviation (S) & Mean (M).
;  H  = 4.0*S   ; = 4 x Standard Deviation  Before April 27th, 2015
;  MN = M -  4.0*S    ; = Mean -  4 x Standard Deviation for the Min. Y-Range.
;  MX = M +  4.0*S    ; = Mean +  4 x Standard Deviation for the Max. Y-Range.
   H  = M + 4.0*S
   MX = ( H GT MX ) ? H : MX
   H  = M - 4.0*S
   MN = ( H LT MN ) ? H : MN
   S  = 0
ENDELSE  ; Adjusting the Y-Ploting Range.
;
  HELP, MX, MN, S
;
; Display the Detided Height values.
;
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, TIME_STAMP, DETIDED,        XMARGIN=[12,8], /NODATA,   $
        YSTYLE=S+4, YRANGE=[MX,MN], YMARGIN=[ 6,2], /NOERASE,  $
        XSTYLE=1+4, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]] ;,  $  ; December 5th, 2017
;       XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=['Hour','DAY'], $
;       XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
;       XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT  , PSYM=3
;
; XYOUTS, 22,  75, 'De-Tided Height Equivalency in meters',  $
; XYOUTS, 12,  75, 'De-Tided Depth in meters',  $
;         COLOR=C.RED, /DEVICE, ORIENTATION=90, CHARSIZE=1.15
  OPLOT, TIME_STAMP, DETIDED, COLOR=C.RED, PSYM=3  ; Plot data points in red.
   AXIS, YAXIS=0, YRANGE=[MX,MN], YSTYLE=S, CHARSIZE=1.15, COLOR=C.RED
;        YTITLE='De-Tided Depth in meters'
 XYOUTS, ALIGNMENT=1, /DEVICE, 45, 45, XUNITS[0] + ':'  ; Hour or Day.
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.RED, ORIENTATION=90,  $
         /DEVICE, 15, 70, '!17De-Tided Depth in meters' ; Left Y-Axis Label.
;
; Overplot the Smoothed De-tided Data if it is asked for.
; which is when o < N_SM < N = N_ELEMENTS( TIME_STAMP ).  March 6th, 2015
;
IF ( 0 LT N_SM ) AND( N_SM LT N ) THEN  BEGIN   ; Do the overplotting.
   MX = SMOOTH( DETIDED, N_SM, /EDGE_TRUNCATE ) ; Compute  the smoothed data.
   OPLOT, TIME_STAMP, MX, COLOR=C.BLUE, PSYM=3  ; Overplot the smoothed data.
   XYOUTS, ALIGNMENT=0,   COLOR=C.BLUE, /DEVICE,  $
           10, 12, 'Blue line is the Smoothed values.'
ENDIF
;
; If the OUTPUT_FILE name is Not = 'Do Not Save',
; Save the graph into the output file.
;
IF ( OUTPUT_FILE NE 'Do Not Save' ) AND ( OUTPUT_FILE NE '' ) THEN  BEGIN
   WRITE_PNG, OUTPUT_FILE, TVRD( TRUE=1 )  ; Save the graph as a png file.
ENDIF
;  
IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN
       MX = !D.WINDOW
   WDELETE, !D.WINDOW  ; Remove the PIXMAP window.
   PRINT, 'Removed PIXMAP Window: ', MX
ENDIF
;
RETURN
END  ; RSN_PLOT_DET
