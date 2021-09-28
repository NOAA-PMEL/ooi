;
; File: GetATD-RTMD.pro
;
; This IDL program will allow users to retrieve a range of Tilt
; values, compute their average in a fix-interval,
; [ then their relative differences.  These Tilt Difference (TD) ]
; ^ The (TD) has not been implemented yet.         May 1st, 2015 ^
; The Average Tilt values will be used
; to compute the Resultant Tilt Magnitudes and Directions.
;
; This program requires the rouitnes in the Files:
; SplitRSNdata.pro and
; GetLongTermNANOdataProducts.pro  in order to work.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OEI Program Newport, Oregon.
;
; Revised on September 30th, 2015
; Created on May        1st, 2015
;

;
; Callers: Users.
;
PRO GET_ATD,  XTILT, YTILT,  $ ; Inputs: 1-D arrays of Degrees or µradians
     TIME,         $ ;  Input : 1-D  array of JULDAY()s.
    STIME, ETIME,  $ ;  Inputs: Time Range in JULDAY()s for the X/YTILTs.
    N_SECONDS,     $ ;  Input : Number of seconds of data to be averaged.
    XT, YT,        $ ; Outputs: 1-D array of Averged interval Tilt Differences.
     T,            $ ; Output : 1-D array of the Time for the XT & YT.
    OFFSET=OFFSET_ORIGIN,    $ ; Input: At least 1 element Array of JULDAY() Values.
    PRINT2FILE=OUTPUT_FILE,  $ ; Output File name for saving the XT, YT, T.
    TO_MICRORADIAN=MICRORADIAN ; Set the units for XT & YT to be µradians.
;
; Note that the XTILT, YTILT and TIME are the same size and can be either
; from the HEAT, IRIS or LILY data but not mixed.
;
; The LILY Tilts are in microrandian and the Tiltes from others sensor are
; in degrees.  1 radian = 57.2957795 degrees
; or 1 degree = 10000/57.2957795 = 17453.2925 µradians.
;
; Get the indexes: [I,J] so that TIME[I:J] will contain the time
; range of STIME and ETIME.
; Note the GET_DATA_RANGE_INDEXES procedure is in the file:
; GetLongTermNANOdataProducts.pro
;
  GET_DATA_RANGE_INDEXES,  TIME,  $ ;
           STIME, ETIME,  $ ; use the Start & End Times
           I,     J,      $ ; to the indexes: I,J
           STATUS          ; STATUS = 1 means OK.
;
  IF STATUS EQ 0 THEN  BEGIN  ; All Data in the NANO_DETIDE will be used.
     I = 0
     J = N_ELEMENTS( TIME ) - 1
     PRINT, 'Data of the following time range:'
     PRINT, FORMAT='(C())', TIME[I], TIME[J] 
     PRINT, 'will be used.'
  ENDIF  ;
;
  IF N_SECONDS LE 0 THEN  BEGIN  ; Assume No averaging.
     PRINT, 'No averaging is requested.'
     PRINT, 'Retrieved Tilt data will be return.'
     XT = XTILT[I:J]
     YT = YTILT[I:J]
      T =  TIME[I:J]
      S = -1  ; for skipping the averaging process.
;    RETURN   ; to Called.
  ENDIF  ELSE  BEGIN
;
;    Total seconds between TIME[I] & TIME[J].
;
     S = ( TIME[J] - TIME[I] )*86400.0D0
;
     IF S LT N_SECONDS THEN  BEGIN
        PRINT, 'Data Range is too short for doing any average.'
        PRINT, 'Not averaging will be done.'
        PRINT, 'Retrieved Tilt data will be return.'
        XT = XTILT[I:J]
        YT = YTILT[I:J]
         T =  TIME[I:J]
         S = -1  ; for skipping the averaging process.
     ENDIF
;
  ENDELSE
;
; N = J - I + 1  ; Total data count between I & J.
;
  IF S GT 0 THEN  BEGIN  ; Get the average X & T Tilt values.
;
;    Get the Start Time at Zero second.
;
     CALDAT, TIME[I], M,D,Y, H,N      ;, second is skipped.
     TIME0 = JULDAY(  M,D,Y, H,0,0 )  ; Time start at H:0:0.
;    TIME0 = JULDAY(  M,D,Y, H,N,0 )  ; Time start at H:N:0.
;
;    Compute the average tilt values at every N_SECONDS.
;
     N = FLOOR( S/N_SECONDS )  ; Total number of the averages to be computed.
;
;    Add 1 more to the N value if S/N_SECONDS is not even.
;
     IF ( S MOD N_SECONDS ) GT 0 THEN N += 1
;
     XT = DBLARR( N )  ; Arrays for storing
     YT = DBLARR( N )  ; the average tilt values
      T = DBLARR( N )  ; Time.
;
     S  = I
     K  = 0  ; Counter for XT & YT.
;
     D  = DOUBLE( N_SECONDS )/86400.0D0  ; N_SECONDS in term of Day.
;
     HELP, NAME='*'  ; Showing all the variables.
;    STOP            ; Check out the variables before continue.
;
     PRINT, SYSTIME() + ' Get the average tile values...'
     PRINT, FORMAT='(C())', TIME[S]
;
     FOR Y = 1, N DO  BEGIN
         H  = TIME0 + D*Y  ; The next even time.
         M  = LOCATE_TIME_POSITION( TIME[I:J], H )
         M += ( I - 1 )  ; Convert the index into the range of TIME.
         G  = TIME[M] - TIME[S]  ; Time Range in in days.
         PRINT, FORMAT='(C())', TIME[M]
;        IF ( TIME[M] - TIME[S] ) GT 0.0 THEN  BEGIN  ; No Data Gap.
         IF ( G LE 0.0 ) OR ( D LT G ) THEN  BEGIN  ; No Data.
            PRINT, 'No data between'
            M = ( S GT 1 ) ? ( S - 1 ) : 0
            PRINT, FORMAT='(C())', TIME[M], H
         ENDIF  ELSE  BEGIN  ; There are data & may be < N_SECONDS.
            XT[K] = MEAN( XTILT[S:M] )
            YT[K] = MEAN( YTILT[S:M] )
             T[K] = TIME[S]
               K += 1
               S  = M + 1
         ENDELSE
     ENDFOR  ; Y
;
;    STOP            ; Check out the variables before continue.
;
;    Adjust the arrays' size OF XT, YT & T
;
     IF K LT N THEN  BEGIN  ; Not all the spaces are used up.
        Y  = XT[0:K-1]
        XT = TEMPORARY( Y )
        Y  = YT[0:K-1]
        YT = TEMPORARY( Y )
        Y  =  T[0:K-1]
         T = TEMPORARY( Y )
     ENDIF
;
     PRINT, SYSTIME() + ' All averages calculated.'
;
  ENDIF  ; Averages calculations.
;
; Compute the Tilt Diffferences.
;
; XT = XT[1:N-1] - XT[0:N-2]
; YT = YT[1:N-1] - YT[0:N-2]
;  T =  T[0:N-2]
;
  IF KEYWORD_SET( OFFSET_ORIGIN ) THEN  BEGIN
     N = N_ELEMENTS( OFFSET_ORIGIN )
     M = ULONARR( N )  ; for storing each index that points to
     FOR S = 0, N - 1 DO  BEGIN  ;  each of the OFFSET_ORIGIN's.
;        Locate the Index for the OFFSET_ORIGIN[S]
         K = LOCATE_TIME_POSITION( TIME, OFFSET_ORIGIN[S] )
         M[S] = K - 1  ; So that TIME[K[S]] = OFFSET_ORIGIN[S]
     ENDFOR  ; S
;    IF N LT 2 THEN  BEGIN  ; Assume N == 1.
 ;      M  = LOCATE_TIME_POSITION( TIME, OFFSET_ORIGIN )
 ;      M -= 1  ; So that TIME[M] = OFFSET_ORIGIN.
;       PRINT, FORMAT="((C(),' =?= ',C())", TIME[M], OFFSET_ORIGIN
 ;      IF ABS(   TIME[M] - OFFSET_ORIGIN ) LT 0.001 THEN  BEGIN
 ;         XT -= XTILT[M]  ; Apply the
 ;         YT -= YTILT[M]  ; Offset.
 ;         PRINT, 'Orign Offset is applied.' 
 ;      ENDIF
;       IF ABS(   TIME[M[0]] - OFFSET_ORIGIN ) LT 0.001 THEN  BEGIN
;          XT -= XTILT[M[0]]  ; Apply the
;          YT -= YTILT[M[0]]  ; Offset.
;          PRINT, 'Orign Offset is applied.' 
;       ENDIF
;    ENDIF  ELSE  BEGIN  ; More than 1 OFFSET_ORIGIN values.
        I = LONG( 0 )
        FOR S = 0, N - 2 DO  BEGIN
            K = LOCATE_TIME_POSITION( T, OFFSET_ORIGIN[S+1] ) - 1
            XT[I:K] -= XTILT[M[S]]
            YT[I:K] -= YTILT[M[S]]
               I     = K + 1  ; Move to the next segment.
            PRINT, S, I, K, M[S]
        ENDFOR  ; S
             K   = N_ELEMENTS( XT )  ; = N_ELEMENTS( YT )
             K  -=     1  ; Points to the last elements in XT & YT.
             S   = N - 1  ; Points to the last elements in M.
        XT[I:K] -= XTILT[M[S]]
        YT[I:K] -= YTILT[M[S]]
;    ENDELSE
  ENDIF
;
  IF KEYWORD_SET( MICRORADIAN ) THEN  BEGIN  ; Convert Degrees to µradians.
;    Assumming the units in XTILT & YTILT are in degrees.
;    1 degree = 10000/57.2957795 = 17453.2925 µradians.
     XT = TEMPORARY( XT )*17453.2925
     YT = TEMPORARY( YT )*17453.2925
  ENDIF
;
; Save the results into an Output (text) file if it is requeste.
;
  IF KEYWORD_SET( OUTPUT_FILE ) THEN  BEGIN
;
;    Convert the TIME in the IDL JULDAY()'s values into string as
;    2015/04/23 00:00:15 for example.
;
     S = STRING( T,  $
     FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
;
;    Put All the NANO data into a 2-D array: DATA for printing.
;
     D = TRANSPOSE( [ [ S ], [ STRING( XT ) ], [ STRING( YT ) ] ] )
;
;    Open the OUTPUT_FILE, Print the DATA into it as a ASCII/Test
;    and Close the OUTPUT_FILE.
;
     OPENW,     OUTPUT_UNIT, OUTPUT_FILE, /GET_LUN
     PRINTF,    OUTPUT_UNIT, D
     CLOSE,     OUTPUT_UNIT
     FREE_LUN,  OUTPUT_UNIT
;
  ENDIF  ; OUTPUT_FILE
;
RETURN
END  ; GET_ATD
;
; This procedure requires the routines in the files:
; IDLcolors.pro, PlotLILYdata.pro, PlotNANOdata.pro
; and ProcessRSNdata.pro in order to work.
;
; Callers: Users
; Revised: June 8th, 2015
;
PRO PLOT_ATD_RTMD, ID,  $ ; Input : '[LILY/IRIS]-MJ03[D/E/F]'
               XT, YT,  $ ; Inputs: 1-D arrays of the Tilt Differences.
                T,      $ ; Input : 1-D array of JULDAY()'s.
   _EXTRA=OPLOTTING,    $ ; Input : E.G. { PSYM=-3 }.
    TITLE=TITLE4PLOT,   $ ; Input : Title for the figure.
    UPDATE_PLOTS=SAVE_PLOTS,    $ ; 0=Not Save (default) & 1=Save
    SHOW_PLOT=DISPLAY_PLOT2SCREEN ; Show the plot in the display window.
;
IF NOT KEYWORD_SET( SAVE_PLOTS ) THEN  BEGIN
   SAVE_PLOTS = 0B  ; Not Save.
ENDIF
;
; Define the file names for the storing the plotted data.
;
IF SAVE_PLOTS THEN  BEGIN
   RTMD_PNG_FILE = ID + '-ADT-RTMD.png'  ; Resultant Tilt Magnitudes + Directions.
ENDIF  ELSE  BEGIN
   RTMD_PNG_FILE = 'Do Not Save'        ;
ENDELSE
;
IF NOT KEYWORD_SET( DISPLAY_PLOT2SCREEN ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
ENDIF
;
IF NOT KEYWORD_SET( TITLE4PLOT ) THEN  BEGIN
   TITLE4PLOT = 'RSN (' + ID  $
              + ') Resultant Tilt Magnitudes and Directions'
ENDIF
;
; Use the ID to get the Station ID: 'MJ03D', 'MJ03E' or 'MJ03F'
; and the following conditions to determine the compass value: CCMP.
; A303 - MJ03D - International District (LILY s/n N9655) - CCMP = 106°
; A302 - MJ03E - East Caldera           (LILY s/n N9652) - CCMP = 195°
; A301 - MJ03F - Central Caldera        (LILY s/n N9676) - CCMP = 345°
;
CASE  STRMID( ID, 5, 5 )  OF  ; ID = 'LILY-MJ03E' or 'IRIS-MJ03D', e.g.
  'MJ03D' : CCMP = 106
  'MJ03E' : CCMP = 195
  'MJ03F' : CCMP = 345
   ELSE   : BEGIN
            PRINT, 'Data ID: ' + ID + ' Not from MJ03D,MJ03E or MJ03F!'
            PRINT, 'No plotting for the Resultent Tilt Mag/Dir data.'
            RETURN
   END
ENDCASE
;
  RTM = SQRT( XT*XT + YT*YT )               ; The Resultant Tilt Magnitudes;
  RTD = RSN_TILT_DIRECTION( XT, YT, CCMP )  ; The Resultant Tilt Directions.
;
  RSN_PLOT_RTMD, SHOW_PLOT=DISPLAY_PLOT2SCREEN, TITLE=TITLE4PLOT,  $
                _EXTRA=OPLOTTING,   T, RTM, RTD, RTMD_PNG_FILE
;
RETURN
END  ; PLOT_ATD_RTMD
