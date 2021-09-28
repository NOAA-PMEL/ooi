;
; File: PlotTILTSdata.pro
;
; This IDL program will generate figures using the RSN data from
; HEAT or IRIS sensors.  The HEAT/IRIS records contain Time Stamps in
; Year/MM/DD Hr:Mm:Sd  temperatues in C, X-Tilt & Y-Tilt data in degrees.
;
; The figures will be either 3-Day plots or the Cumulative 1-Year Plot.
;
; The RSN data are collected by the OOI Regional Scale Nodes program
; statred on August 2014 from the Axial Summit.
;
; The procedures in this program will be used by the procerdures
; in the file: PlotRSNdata.pro
;
; Revised on May       14th, 2015
; Created on October    8th, 2014
;

;
; Callers: Most of the Plotting Procedures in the files:
;          Plot[LILY/TITLS]data.pro
;
; Revised on Auguet  23, 2010
;
FUNCTION COMBINE_RANGE, RANGE1, RANGE2  ; Two 1-D arrays.
;
; Note both the RANGE1, RANGE2 are 2-Element arrays.
; and RANGE1[0] = Min. and RANGE1[1] = Max of RANGE1
;  &  RANGE2[0] = Min. and RANGE2[1] = Max of RANGE2
;
; Determine whether the 2 ranges intersect each other or not.
;
INTERSECT = NOT ( ( RANGE1[0] GT RANGE2[1] )  $
               OR ( RANGE1[1] LT RANGE2[0] )  )
;
IF INTERSECT THEN  BEGIN  ; RANGE1 & RANGE2 intersect each other.
;  Combined Range is Min( RANGE1, RANGE2 ) and
;                    Max( RANGE1, RANGE2 ) 
   MX = MAX( [ RANGE1, RANGE2 ], MIN=MN )
ENDIF  ELSE  BEGIN  ; RANGE1 & RANGE2 do Not intersect each other.
   IF RANGE1[1] LE RANGE2[0] THEN  BEGIN  ; RANGE1 <= RANGE2.
      MN = RANGE1[0]
      MX = RANGE1[1] + ( ( RANGE2[1] - RANGE2[0] ) + 1 )
   ENDIF  ELSE  BEGIN  ; RANGE2 < RANGE1
      MX = RANGE1[1]
      MN = RANGE1[0] - ( ( RANGE2[1] - RANGE2[0] ) + 1 )
   ENDELSE
ENDELSE
;
RETURN, [ MN, MX ]
END   ; COMBINE_RANGE
;
; Callers: PLOT_[HEAT/IRIS]_DATA in the PlotRSNdata.pro
;
; Revised: October 23rd, 2014
;
PRO RSN_PLOT_TILTS,            $  ; X & Y Tilts plus Temperatures.
    TIME_STAMP, XTILT, YTILT,  $  ; Input: 1-D arrays of the same size.
                 TEMPERATURE,  $  ; Input: 1-D array, same size as above.
                 OUTPUT_FILE,  $  ; for saving the plotted into a *.png file.
 EXTEND_YRANGE=EXTEND_YRANGE,  $  ; for extending the Y-Plotting Range.
        TITLE=    TITLE4PLOT,  $  ; Default = 'Inclinometer Data.'
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
;  PRINT, 'Use Z-Buffer Plotting.'
;  SET_PLOT, 'Z'
;  DEVICE, Z_BUFFERING=1, SET_PIXEL_DEPTH=24,  $
;          SET_RESOLUTION=[800,256]  ; X & Y Sizes.
ENDELSE
;
IF NOT KEYWORD_SET( EXTEND_YRANGE ) THEN  BEGIN
   EXTEND_YRANGE = BYTE( 0 )  ; No.
ENDIF
;
IF NOT KEYWORD_SET( TITLE4PLOT ) THEN  BEGIN
   TITLE4PLOT = 'RSN Inclinometer Data.'
ENDIF
;
; The following 2 procedures are in the file IDLcolors.pro
;
  SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
; Get the Max & Min TEMPERATURE and add on the additional ranges
; for X,Y tilts plotting later.
;
  MXT = MAX(  [ XTILT, YTILT ], MIN=MNT )  ; in Degrees.
  MT  = MAX(    TEMPERATURE   , MIN= NT )  ; in Degrees C.
; M  = COMBINE_RANGE( [NT,MT], [MNT,MXT] )
; MX = M[1] + 1
; MN = M[0] - 1
  M  = ( MT - NT )/2.0  ; Half of the TEMPERATURE range.
  M  = EXTEND_YRANGE*M  ; Extand the range if it is asked for.
  MX =  CEIL( MT + M )  ; Use Max. & Min values of
  MN = FLOOR( NT - M )  ; the TEMPERATURE range.
;
  IF ( MX - MN ) LT 2 THEN  BEGIN  ; TEMPERATURE range < 2 degrees.
     M  = ( MX + MN )/2.0  ; Mid-Point of Min & Max of the TEMPERATURE range.
     MX = M + 1.0          ; Make the (MX,MN) range
     MN = M - 1.0          ; to be at least 2 degrees.
  ENDIF 
;
  PRINT, 'TEMPERATURE range: '
  HELP, MXT,MNT, MT,NT, EXTEND_YRANGE, M, MX, MN
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
TIME_RANGE = STRING( TIME_STAMP[0],    $ ; Date & Time of the 1st data point.
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
; Display the temperature values 1st.
;
  PLOT, TIME_STAMP, TEMPERATURE, /NODATA, XMARGIN=[8,9],   $
        YRANGE=[MN,MX], YSTYLE=4,         YMARGIN=[6,2],   $
        XSTYLE=1, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]],  $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
        XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT
;       TITLE='Last 3 days of the RSN Inclinometer data.'
 XYOUTS, ALIGNMENT=1, /DEVICE, 45, 45, XUNITS[0] + ':'
 OPLOT, TIME_STAMP, TEMPERATURE, COLOR=C.GREEN;, PSYM=3
  AXIS, CHARSIZE=1.25, COLOR=C.GREEN,  $
        YAXIS=1, YRANGE=[MN,MX]        ;, YTITLE='Temperature in C.'
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.25, CHARTHICK=1, COLOR=C.GREEN, ORIENTATION=90,  $ 
         /DEVICE, 775,  70, '!17Temperature in C.'  ; Right Y-Axis's Label.
; 
; Locate the Max & Min of the X & Y Tilt and offset them by the
; TEMPERATURE range so that TEMPERATURE and the Tilts can all be seen.
;
IF EXTEND_YRANGE GT 0 THEN  BEGIN
   M  = COMBINE_RANGE( [MNT,MXT], [NT,MT] )
   MX = M[1] + 1
   MN = M[0] - 1
ENDIF  ELSE  BEGIN
   M  = ( MXT - MNT )/2.0  ; Half of the X & Y Tilt range.
;  M  = EXTEND_YRANGE*M  ; Extand the range if it is asked for.
   MX =   MXT + M   ; Use the Max & Min
   MN =   MNT - M   ; X,Y Tilt ranges only.
ENDELSE
;
  PRINT, 'X & Y Tilts range: '
  HELP, MXT,MNT, MT,NT, EXTEND_YRANGE, M, MX, MN
;
; Over plot the X- & Y-Tilt data.
;
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, TIME_STAMP, XTILT,  /NODATA, XMARGIN=[8,9],       $
        YRANGE=[MN,MX], YSTYLE=4,    YMARGIN=[6,2],       $
        XSTYLE=5, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]], /NOERASE
;       XTICKFORMAT='LABEL_DATE', XTICKUNITS='DAY', /NOERASE
;
 OPLOT, TIME_STAMP, XTILT, COLOR=C.BLUE ;, PSYM=3
 OPLOT, TIME_STAMP, YTILT, COLOR=C.PINK ;, PSYM=3
 XYOUTS, COLOR=C.BLUE,  /DEVICE,  3, 225, 'X-Tilt'
 XYOUTS, COLOR=C.PINK,  /DEVICE,  3, 210, 'Y-Tilt'
  AXIS, CHARSIZE=1.25, COLOR=C.BLUE,  $
        YAXIS=0, YRANGE=[MN,MX]       ;, YTITLE='Tilts in degrees.'
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.25, CHARTHICK=1, COLOR=C.BLUE, ORIENTATION=90,  $ 
         /DEVICE,  21,  70, '!17Tilts in degrees.' ; Left  Y-Axis's Label.
;
; Plot the Y-Tilt again in case the TEMPERATURE data are masking other data.
;
; OPLOT, TIME_STAMP, YTILT, COLOR=C.GREEN
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
END  ; RSN_PLOT_TILTS
;
; Callers: PLOT_[HEAT/IRIS]_DATA in the PlotRSNdata.pro
;
; Revised: September 27th, 2017
; Created: May       14th, 2015
;
PRO RSN_PLOT_XYTILTS,          $  ; X & Y Tilts plus Temperatures.
    TIME_STAMP, XTILT, YTILT,  $  ; Input: 1-D arrays of the same size.
                 OUTPUT_FILE,  $  ; for saving the plotted into a *.png file.
 EXTEND_YRANGE=EXTEND_YRANGE,  $  ; for extending the Y-Plotting Range.
        TITLE=    TITLE4PLOT,  $  ; Default = 'Inclinometer Data.'
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
;  PRINT, 'Use Z-Buffer Plotting.'
;  SET_PLOT, 'Z'
;  DEVICE, Z_BUFFERING=1, SET_PIXEL_DEPTH=24,  $
;          SET_RESOLUTION=[800,256]  ; X & Y Sizes.
ENDELSE
;
IF NOT KEYWORD_SET( EXTEND_YRANGE ) THEN  BEGIN
   EXTEND_YRANGE = BYTE( 0 )  ; No.
ENDIF
;
IF NOT KEYWORD_SET( TITLE4PLOT ) THEN  BEGIN
   TITLE4PLOT = 'RSN Inclinometer Data.'
ENDIF
;
; The following 2 procedures are in the file IDLcolors.pro
;
  SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
; M  = COMBINE_RANGE( [NT,MT], [MNT,MXT] )
; MX = M[1] + 1
; MN = M[0] - 1
;
; If the provided data are the long term one, then only use the 
; data range from 11/30/2014 on for determining the X & Y tilt ranges. 
;
IF TIME_STAMP[0] GT JULDAY( 11,30,2014, 0,0,0 ) THEN  BEGIN
   I = 0  ; Not a long term data set.  Use all data.
ENDIF  ELSE  BEGIN  ; Assuming it is a long term data set.
   S = WHERE( TIME_STAMP GT JULDAY( 11,30,2014, 0,0,0 ), N )
   IF N LE 0 THEN  BEGIN  ; No times after 11/30/2014  are found.
      I =  0              ; Use all data.
   ENDIF  ELSE  BEGIN     ; Times after 11/30/2014  are found.
      I = S[0]            ; Use the data from that date & time on.
   ENDELSE
ENDELSE
;
  N   = N_ELEMENTS( TIME_STAMP )
;
; Get the Max & Min YTILT for computing Y tilts plotting range later.
;
  MXT = MAX(  YTILT[I:N-1], MIN=MNT )  ; in Degrees.
;
; Compute the YTILT range for plotting   which will be
; M + 4 x Std  &  M - 10 x Std
; where M & Std are the Mean & Standard Deviation of XTILT.
;
  S  = STDEV( YTILT, M )   ; Compute the Standard Deviation (S) & Mean (M).
  H  = M + 0.5*S
  MX = ( H GT MXT ) ? H : MXT
  H  = M -     S
  MN = ( H LT MNT ) ? H : MNT
;
  PRINT, 'Y-Tilt range: '
  HELP, MXT, MNT, MX, MN
;
; Determine number of Hourly or Daily marks per day.
;
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
TIME_RANGE = STRING( TIME_STAMP[0],    $ ; Date & Time of the 1st data point.
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
; Display the YTILT values 1st.
;
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, TIME_STAMP, YTILT,  /NODATA, XMARGIN=[8,9],       $
        YRANGE=[MN,MX], YSTYLE=4,    YMARGIN=[6,2],       $
        XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
        XSTYLE=1, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]], $
        XTICKINTERVAL=H, XTITLE=TIME_RANGE, TITLE=TITLE4PLOT
;
 OPLOT, TIME_STAMP, YTILT, COLOR=C.PINK  ;, PSYM=3
  AXIS, CHARSIZE=1.25, COLOR=C.PINK, YAXIS=1, YRANGE=[MN,MX]
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.25, CHARTHICK=1, COLOR=C.PINK, ORIENTATION=90,  $ 
         /DEVICE, 790,  80, '!17Y-Tilts in degrees'  ; Right Y-Axis's Label.
;
; Get the Max & Min XTILT for computing X tilts plotting range later.
;
  MXT = MAX(  XTILT[I:N-1], MIN=MNT )  ; in Degrees.
;
; Compute the XTILT range for plotting   which will be
; M + 10 x Std  &  M - 4 x Std
; where M & Std are the Mean & Standard Deviation of XTILT.
;
  S  = STDEV( XTILT, M )   ; Compute the Standard Deviation (S) & Mean (M).
  H  = M +     S
  MX = ( H GT MXT ) ? H : MXT
  H  = M - 0.5*S
  MN = ( H LT MNT ) ? H : MNT
;
  PRINT, 'X-Tilt range: '
  HELP, MXT, MNT, MX, MN
;
; Over plot the X-Tilt data.
;
;
; Display the XTILT values 1st.
;
 !P.FONT  = 0  ; Use the hardware font above.
  PLOT, TIME_STAMP, XTILT,       /NODATA, XMARGIN=[8,9],   $
        YRANGE=[MN,MX], YSTYLE=4,         YMARGIN=[6,2],   $
        XSTYLE=5, XRANGE=[TIME_STAMP[0],TIME_STAMP[N-1]], /NOERASE
;       XTICKFORMAT=['LABEL_DATE','LABEL_DATE'], XTICKUNITS=XUNITS,  $
;       XTITLE=TIME_RANGE, XTICKINTERVAL=H, TITLE=TITLE4PLOT, /NOERASE
;
 OPLOT, TIME_STAMP, XTILT,       COLOR=C.BLUE  ;, PSYM=3
 XYOUTS, ALIGNMENT=1, /DEVICE, 45, 45, XUNITS[0] + ':'  ; = "Hour :" e.g.
  AXIS, CHARSIZE=1.25, COLOR=C.BLUE, YAXIS=0, YRANGE=[MN,MX]
 !P.FONT = -1  ; Back to graphic font.
 XYOUTS, CHARSIZE=1.25, CHARTHICK=1, COLOR=C.BLUE, ORIENTATION=90,  $
         /DEVICE,  13,  80, '!17X-Tilts in degrees' ; Left  X-Axis's Label.
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
END  ; RSN_PLOT_XYTILTS
