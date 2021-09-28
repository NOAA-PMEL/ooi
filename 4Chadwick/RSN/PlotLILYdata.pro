;
; File: PlotLILYdata.pro
;
; This IDL program will generate figures using the RSN data from
; LILY sensors.  The LILY records contain Time Stamps in
; Year/MM/DD Hr:Mm:Sd  temperatues in C, X-Tilt & Y-Tilt data in micro-
; randians.  Using the X-Tilt & Y-Tilt data, the Resultant Tilt
; Magnitudes and Directions will be calculated and plotted. 
;
; The figures will be either 3-Day plots or the Cumulative 1-Year Plot.
;
; The RSN data are collected by the OOI Regional Scale Nodes program
; statred on August 2014 from the Axial Summit.
;
; The procedures in this program will be used by the procerdures
; in the file: PlotRSNdata.pro
;
; Revised on September 22nd, 2017
; Created on October    9th, 2014
;

;
; Callers: PLOT_LILY_DATA in the PlotRSNdata.pro or Users.
; Revised: Novemebr 13th, 2014
;
PRO RSN_PLOT_LILY,             $  ; X & Y Tilts plus Temperatures.
    TIME_STAMP, XTILT, YTILT,  $  ; Input: 1-D arrays of the same size.
                 TEMPERATURE,  $  ; Input: 1-D arrayi, same size as above.
                 OUTPUT_FILE,  $  ; for saving the plotted into a *.png file.
 EXTEND_YRANGE=EXTEND_YRANGE,  $  ; for extending the Y-Plotting Range.
        TITLE=    TITLE4PLOT,  $  ; Default = 'Mars Inclinometer Data.'
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
; TIME_STAMP  = 1-D arrays in Julian Days.
; XTILT,YTILT = 1-D arrays in Degrees.
;
IF DISPLAY_PLOT2SCREEN THEN  BEGIN
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
   PRINT, 'Plotting Window: ', !D.WINDOW
ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256, /PIXMAP
   PRINT, 'PIXMAP Window: ', !D.WINDOW
ENDELSE
;
IF NOT KEYWORD_SET( EXTEND_YRANGE ) THEN  BEGIN
   EXTEND_YRANGE = BYTE( 0 )  ; No.
ENDIF
;
IF NOT KEYWORD_SET( TITLE4PLOT ) THEN  BEGIN
   TITLE4PLOT = 'RSN-Mars Inclinometer Data.'
ENDIF
;
; The following 2 procedures are in the file IDLcolors.pro
;
  SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
; Determine number of Hourly or Daily marks per day.
;
N      = N_ELEMENTS( TIME_STAMP )
N_DAYS = ( TIME_STAMP[N-1] - TIME_STAMP[0] )  ; Data Range in days.
;
; The following Procedure: RSN_GET_XTICK_UNITS is located at the
; file: PLOT_NANOdata.pro.
;
RSN_GET_XTICK_UNITS, N_DAYS, XUNITS, H
;
; Where XUNITS will be returned as ['Hour','DAY'] or ['Day', 'DAY']
; and   H is the XTICKINTERVAL=H for either Hour or Day.
;
; Call LABEL_DATE() to ask for plotting Time Label
; as Hour, Month/Day/Year or Day, Month/Day/Year
;
IF XUNITS[0] EQ 'Hour' THEN  BEGIN
   TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%H','%N/%D/%Z'] )
ENDIF  ELSE  BEGIN
   TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%D','%N/%D/%Z'] )
ENDELSE
;
TIME_RANGE  = STRING( TIME_STAMP[0],  $ ; Date & Time of the 1st data point.
     FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' ) 
TIME_RANGE += ' to ' + STRING( TIME_STAMP[N-1],  $ ; to the Last data point.
     FORMAT='(C(CMOI,"/",CDI2.2,"/",CYI,X,CHI2.2,":",CMI2.2,":",CSI2.2))' )
; 
; Locate the Max & Min of the X & Y Tilt and offset them by the
; TEMPERATURE range so that TEMPERATURE and the Tilts can all be seen.
;
; IF EXTEND_YRANGE GT 0 THEN  BEGIN
;    M  = COMBINE_RANGE( [MNT,MXT], [NT,MT] )
;    MX = M[1] + 1
;    MN = M[0] - 1
; ENDIF  ELSE  BEGIN
;    M  = ( MXT - MNT )/2.0  ; Half of the X & Y Tilt range.
; ;  M  = EXTEND_YRANGE*M  ; Extand the range if it is asked for.
;    MX =   MXT + M   ; Use the Max & Min
;    MN =   MNT - M   ; X,Y Tilt ranges only.
; ENDELSE
;
; Get the Max & Min of the TEMPERATURE values.
;
  MXT = MAX( TEMPERATURE, MIN=MNT )  ; in Degrees.
;
  M  = ( MXT - MNT )/2.0  ; Half of the TEMPERATURE range.
  M  = EXTEND_YRANGE*M    ; Extand the range if it is asked for.
  MX =  CEIL( MXT + M )   ; Use Max. & Min values of
  MN = FLOOR( MNT - M )   ; the TEMPERATURE range.
;
  IF ( MX - MN ) LT 2 THEN  BEGIN  ; TEMPERATURE range < 2 degrees.
     M  = ( MX + MN )/2.0   ; Half of the TEMPERATURE range.
     MX = M + 1             ; Make the (MX,MN) range
     MN = M - 1             ; to be at least 2 degrees.
  ENDIF
;
  PRINT, 'TEMPERATURE range: ' 
  HELP, MXT,MNT, EXTEND_YRANGE,M,  MX,MN
;
; Define the Hardware Fonts to be used.
;
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
;
 !P.FONT  = 0  ; Use the hardware font above.
 !X.THICK = 1
 !Y.THICK = 1  ; for thinker line drawing.
;
; Plot the TEMPERATURE data.
;
  PLOT, TIME_STAMP, TEMPERATURE, /NODATA,                       $
        XSTYLE=5, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]],       $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, XTICKUNITS=XUNITS,  $
;       XTICKFORMAT=['LABEL_DATE','LABEL_DATE'],                $
        XMARGIN=[8,9], YMARGIN=[6,2], YSTYLE=4, YRANGE=[MN,MX]
;XYOUTS, ORIENTATION=90, /DEVICE, 17,  60, 'Temp. (C)',      COLOR=C.PINK
 OPLOT, COLOR=C.GREEN , PSYM=3, TIME_STAMP, TEMPERATURE
  AXIS, YAXIS=1, YRANGE=[MN,MX], CHARSIZE=1.25, COLOR=C.GREEN
;       YTITLE='Temperature in C.'
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.25, CHARTHICK=1, COLOR=C.GREEN, ORIENTATION=90,  $
         /DEVICE, 775,  70, '!17Temperature in C.'  ; Right Y-Axis's Label.
;
; Get the Max & Min X,Y Tilts' ranges
;
  MXT = MAX(  [ XTILT, YTILT ], MIN=MNT )  ; in micro-randians.
;
  M  = ( MXT - MNT )/2.0  ; Half of the X & Y Tilts' range.
  M  = EXTEND_YRANGE*M    ; Extand the range if it is asked for.
  MX =  CEIL( MXT + M )   ; Use Max. & Min values of
  MN = FLOOR( MNT - M )   ; the TEMPERATURE range.
;
  PRINT, 'X & Y Tilts range: ' 
  HELP, MXT,MNT, EXTEND_YRANGE,M, MX,MN
;
; Overplot the X & Y Tilts' values.
;
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, TIME_STAMP, XTILT, /NODATA, /NOERASE, XMARGIN=[8,9],      $
        YSTYLE=4, YRANGE=[MN,MX],             YMARGIN=[6,2],      $
        XSTYLE=1, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]],         $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'],                  $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, XTICKUNITS=XUNITS,    $
         TITLE=TITLE4PLOT  ;, YTITLE='Tilt in microradians.'
  AXIS,  YAXIS=0, YRANGE=[MN,MX]  ;, YTITLE='Tilt in microradians.'
 OPLOT,  COLOR=C.BLUE,  PSYM=3, TIME_STAMP, XTILT
 OPLOT,  COLOR=C.PINK,  PSYM=3, TIME_STAMP, YTILT
 XYOUTS, ALIGNMENT=1,   /DEVICE, 45,  45, XUNITS[0] + ':'
;XYOUTS, COLOR=C.BLUE,  /DEVICE,  5, 225, 'X-Tilt'
;XYOUTS, COLOR=C.PINK,  /DEVICE,  5, 210, 'Y-Tilt'
 XYOUTS, COLOR=C.BLUE,  /DEVICE,  5, 240, 'X-Tilt'
 XYOUTS, COLOR=C.PINK,  /DEVICE,  5, 225, 'Y-Tilt'  ; Under   the 'X-Tilt'.
;XYOUTS, COLOR=C.PINK,  /DEVICE, 45, 240, 'Y-Tilt'  ; Next to the 'X-Tilt'.
  !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.25, CHARTHICK=1, ORIENTATION=90,  $
         /DEVICE,  21,  60, '!17Tilt in microradians'  ; Left Y-Axis's Label.
;
; If an OUTPUT_FILE name is provided, Save the graph into the output file.
;
IF ( OUTPUT_FILE NE 'Do Not Save' ) AND ( OUTPUT_FILE NE '' ) THEN  BEGIN
   WRITE_PNG, OUTPUT_FILE, TVRD( TRUE=1 )  ; Save the graph as a png file.
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
END  ; RSN_PLOT_LILY
;
; Callers: PLOT_LILY_DATA in the PlotRSNdata.pro or Users.
; Revised: September 27th, 2017
; 
PRO RSN_PLOT_RTMD,  TIME_STAMP,  $ ; 1-D array in JULDAY(...).
        RTM,    RTD,    $ ; 1-D arrays in degees, Magnitudes & Angles.
        OUTPUT_FILE,    $ ; for saving the plotted into a *.png file.
   _EXTRA=OPLOTTING,    $ ; Input:   e.g. OPLOTTING = { PSYM=-3 }.
    TITLE=TITLE4PLOT,   $  ; e.g. 'RSN-Lily Compass & RTM and RTD.'
    SHOW_PLOT=DISPLAY_PLOT2SCREEN  ; Show the plot in the display window.
;
; TIME_STAMP = 1-D arrays in Julian Days.
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
   TITLE4PLOT = 'RSN-Lily Resultant Tilt Magnitudes & Directions.'
ENDIF
;
; The following 2 procedures are in the file IDLcolors.pro
;
  SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
; Get the Max & Min for the Resultant Tilt Directions range.
;
; MXC = MAX( ABS( TEMPERATURE ), MIN=MNC )
; MXR = MAX(   [ RTM, RTD ],     MIN=MNR ) 
; M   = COMBINE_RANGE( [MNC,MXC], [MNR,MXR] )  ; (*)
  MXR = MAX( RTD, MIN=MNR ) 
  MX  =  CEIL( MXR )
  MN  = FLOOR( MNR )
  PRINT, 'Max & Min of the Resultant Tilt Directions: '
  HELP, MXR,MNR, MX,MN
;
; (*) The COMBINE_RANGE() function is inside the File: PlotTILTSdata.pro
;
; Determine number of Hourly or Daily marks per day.
;
N      = N_ELEMENTS( TIME_STAMP )
N_DAYS = ( TIME_STAMP[N-1] - TIME_STAMP[0] )  ; Data Range in days.
;
; The following Procedure: RSN_GET_XTICK_UNITS is located at the
; file: PLOT_NANOdata.pro.
;  
RSN_GET_XTICK_UNITS, N_DAYS, XUNITS, H
;
; Where XUNITS will be returned as ['Hour','DAY'] or ['Day', 'DAY']
; and   H is the XTICKINTERVAL=H for either Hour or Day.
;
; Call LABEL_DATE() to ask for plotting Time Label
; as Hour, Month/Day/Year or Day, Month/Day/Year
;
IF XUNITS[0] EQ 'Hour' THEN  BEGIN
   TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%H','%N/%D/%Z'] )
ENDIF  ELSE  BEGIN
   TIME_RANGE = LABEL_DATE( DATE_FORMAT=['%D','%N/%D/%Z'] )
ENDELSE
;
TIME_RANGE  = STRING( TIME_STAMP[0],  $ ; Date & Time of the 1st data point.
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
; Display the RTD in PURPLE.
;
  PLOT, TIME_STAMP, RTD, /NODATA, PSYM=3,                            $
        XMARGIN=[8,9], YMARGIN=[6,2], YRANGE=[MN,MX], YSTYLE=2+4,    $
        XSTYLE=1, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]],            $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT
 OPLOT, COLOR=C.PURPLE, PSYM=3, _EXTRA=OPLOTTING, TIME_STAMP, RTD  ; Resultant Tilt Direction.
  AXIS, YAXIS=0, YRANGE=[MN,MX]  ;, YTITLE='Degrees'
 XYOUTS, ALIGNMENT=1,    /DEVICE, 45,  45, XUNITS[0] + ':'
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.PURPLE, ORIENTATION=90,  $
 /DEVICE, 15, 70, '!17Tilt Direction in Degrees'  ; Left Y-Axis's Label.
;XYOUTS, ORIENTATION=90, /DEVICE, 17, 185, 'Tilt Direction', COLOR=C.PURPLE
;
; Display the RTM in Red.
;
   H = N_TAGS( OPLOTTING )  ; September 25th, 2017
IF H LE 0 THEN  BEGIN  ; NO extra plotting keywords are set by the caller.
   Y = -1              ; No keyword: YRANGE is provided.
ENDIF  ELSE  BEGIN     ; H > 0 which means Extra plotting keywords are set by the caller.
   H = TAG_NAMES( OPLOTTING )
   Y = WHERE( H EQ 'YRANGE' )  ; Look for keyword: YRANGE
ENDELSE  ; Determine whether or not 'YRANGE' keyword is provided.
;
IF Y[0] GE 0 THEN  BEGIN     ; 'YRANGE' keyword is provided.
   MN = OPLOTTING.YRANGE[0]  ; Min. YRANGE
   MX = OPLOTTING.YRANGE[1]  ; Max. YRANGE
ENDIF  ELSE  BEGIN   ; No keyword: 'YRANGE'
;
;  Locate the Max & Min of the Resultant Tilt Magnitudes.
;
        MX = MAX( RTM, MIN=MN ) 
   IF ( MX - MN ) GT 0.5 THEN  BEGIN  ; June 8th, 2015
        MX =  CEIL( MX )
        MN = FLOOR( MN )
   ENDIF
;
   PRINT, 'Max & Min of the Resultant Tilt Magnitudes: '
   HELP, MX,MN  ; September 22nd, 2017
;
;  Set the Resultant Tilt Magnitudes plotting range to be the
;  Average of Magnitudes +/- 2 x its Standard Deviation.
;
   MXR = STDEV( RTM, MNR )  ; Compute the Standard Deviation (MXR) & Mean (MNX).
   PRINT, 'Standard Deviation (MXR) & Mean (MNR) & Min of the Resultant Tilt: '
   HELP, MXR, MNR
   H   = MNR + 2.0*MXR
   MX  = ( H LT MX ) ? H : MX
   H   = MNR - 2.0*MXR
   MN  = ( H GT MN ) ? H : MN
   PRINT, 'Max & Min of the Resultant Tilt Magnitudes Plotting Range: '
;
ENDELSE  ; Setting the Min, & Max. values for the YRANGE.
;
  HELP, MX, MN
;
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, TIME_STAMP, RTM,         /NODATA, /NOERASE,        $
        XSTYLE=5, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]],  $
;       XTICKFORMAT='LABEL_DATE', XTICKUNITS='DAY',        $
        XMARGIN=[8,9], YMARGIN=[6,2], YSTYLE=2+4, YRANGE=[MN,MX]
 OPLOT, COLOR=C.RED, PSYM=3, _EXTRA=OPLOTTING, TIME_STAMP, RTM  ; Resultant Tilt Magnitude.
  AXIS, YAXIS=1, YRANGE=[MN,MX], CHARSIZE=1.25, COLOR=C.RED
;       YTITLE='Tilt Magnitude (!7l!3rad)'
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.00, CHARTHICK=1, COLOR=C.RED, ORIENTATION=90,  $
 /DEVICE, 775, 80, '!17Tilt Magnitude (!7l!3rad)' ; Right Y-Axis's Label.
;
; If an OUTPUT_FILE name is provided, Save the graph into the output file.
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
END  ; RSN_PLOT_RTMD
