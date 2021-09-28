;
; This is a setup file: RunGetTiltDiff.pro
; It is used for computing the X & Y tilt difference values offset relative
; to their current date with the tilt values at the specified date ahead.
; Then the tilt differences will be used to calculate the Resultant Tilt
; Magnitudes and Directions for plotting.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: September 30th, 2015 ; to be run at Garfield.
;
;
.RUN ~/idl/IDLcolors.pro
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/ProcessRSNdata.pro
.RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
.RUN ~/4Chadwick/RSN/PlotLILYdata.pro
.RUN ~/4Chadwick/RSN/PlotNANOdata.pro
.RUN ~/4Chadwick/RSN/PlotRSNdata.pro
.RUN ~/4Chadwick/RSN/GetRelevelingTimes.pro
.RUN ~/4Chadwick/RSN/PlotTD-RTMD.pro
.RUN ~/4Chadwick/RSN/GetTiltDiff.pro
;
  CD, '~/4Chadwick/RSN/'
;
; Define a Dot symbol for plotting.  September 21st, 2015
;
  USERSYM, [-0.2,0.2],[0,0]
  S = FINDGEN( 17 )*!PI/8.0
  USERSYM, COS( S ), SIN( S ), /FILL  ;, THICK=2
;
; To Run the program, see the following examples.
;
  GET_RELEVELING_TIMES, 'MJ03D-LILYreleveling.Times', DRTL  ; Get the Releveling Times
  GET_RELEVELING_TIMES, 'MJ03E-LILYreleveling.Times', ERTL  ; for each of the stations.
  GET_RELEVELING_TIMES, 'MJ03F-LILYreleveling.Times', FRTL
;
; Note that [D/E/F]RTL are 2-D arrays in 2 x n of the JULDAY() values.
; where [D/E/F]RTL[0,i] & [D/E/F]RTL[1,i] are the Start & End Times of the Releveling
; for i = 0, 1, ..., n-1.
;
; September 21st, 2015
;
  RESTORE, 'MJ03D/MJ03D1HrAveLILY.idl'  ; Get T, XT, YT variables.
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
   TIME_INTERVAL=3600,  $ ; Input: Time spacing between data points.
           DRTL,        $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
           T , XT,  YT, $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
         TM, XTDF,YTDF  ;  Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
  RESTORE, 'MJ03E/MJ03E1HrAveLILY.idl'  ; Get T, XT, YT variables.
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
   TIME_INTERVAL=3600,  $ ; Input: Time spacing between data points.
           ERTL,        $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
           T , XT,  YT, $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
         TM, XTDF,YTDF  ;  Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
  RESTORE, 'MJ03F/MJ03F1HrAveLILY.idl'  ; Get T, XT, YT variables.
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
   TIME_INTERVAL=3600,  $ ; Input: Time spacing between data points.
           FRTL,        $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
           T , XT,  YT, $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
         TM, XTDF,YTDF  ;  Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
; The next 7 statements can be skipped by using the results from above.
; Users just have to locate the correct index value: i for TM so that
; TM[i] = APRIL 24, 2015 18:00:01 on. 
;
;
; I   = WHERE( T GE JULDAY( 4,24,2015, 18,00,01 ) )
; I   = I[0]  ; = 4996
  I   = 4996  ; for MJ03D's T[I] = April 24, 2015 18:00:01
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
   TIME_INTERVAL=3600,  $ ; Input: Time spacing between data points.
           DRTL[*,2:*], $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
  T[I:*], XT[I:*], YT[I:*],   $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
  TM,     XTDF,    YTDF ; Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
  I   = WHERE( T GE JULDAY( 4,25,2015, 00,00,00 ) )
  I   = I[0]
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
   TIME_INTERVAL=3600,  $ ; Input: Time spacing between data points.
           FRTL[*,2:*], $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
  T[I:*], XT[I:*], YT[I:*],   $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
  TM,     XTDF,    YTDF ; Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
  N   = N_ELEMENTS( T )
  I   = WHERE( T GE T[N-1] - 14 )  ; for the 7 Day Offset it require 14 days long data.
  I   = I[0]
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
   TIME_INTERVAL=3600,  $ ; Input: Time spacing between data points.
;          DRTL[*,4:*], $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
           ERTL,        $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
           FRTL[*,2:*], $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
              7,        $ ; Input: Use  7-Day offset (7).
  T[I:*], XT[I:*], YT[I:*],   $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
  TM,     XTDF,    YTDF ; Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
; To Display the Resultant Tilt Magnitudes and Directions using the XT, YT, T,
; See the following example:
;
  RTM = SQRT( XTDF*XTDF + YTDF*YTDF )
  RTD = RSN_TILT_DIRECTION( XTDF, YTDF, 106 ) ; MJ03D
  TITLE4PLOT = 'RSN-LILY (MJ03D) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Start to Present.'
  RTM = SQRT( XTDF*XTDF + YTDF*YTDF )
  RTD = RSN_TILT_DIRECTION( XTDF, YTDF, 195 ) ; MJ03E
  TITLE4PLOT = 'RSN-LILY (MJ03E) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Start to Present.'
  RTM = SQRT( XTDF*XTDF + YTDF*YTDF )
  RTD = RSN_TILT_DIRECTION( XTDF, YTDF, 345 ) ; MJ03F
  TITLE4PLOT = 'RSN-LILY (MJ03F) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Start to Present.'
  S   = 0    ; All for data in TM.
  N   = N_ELEMENTS( TM )
;
; For all data from April 24th, 2015 on.
;
  N   = N_ELEMENTS( TM )
  S   = WHERE( TM GE JULDAY( 4, 24, 2015, 00,00,00 ) )
  S   = S[0]
;
  RTM = SQRT( XTDF[S:N-1]*XTDF[S:N-1]  + YTDF[S:N-1]*YTDF[S:N-1] )
  RTD = RSN_TILT_DIRECTION( XTDF[S:N-1], YTDF[S:N-1], 106 ) ; MJ03D
  TITLE4PLOT = 'RSN-LILY (MJ03D) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Since 25th April 2015.'
  RTM = SQRT( XTDF[S:N-1]*XTDF[S:N-1]  + YTDF[S:N-1]*YTDF[S:N-1] )
  RTD = RSN_TILT_DIRECTION( XTDF[S:N-1], YTDF[S:N-1], 195 ) ; MJ03E
  TITLE4PLOT = 'RSN-LILY (MJ03E) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Since 25th April 2015.'
  RTM = SQRT( XTDF[S:N-1]*XTDF[S:N-1]  + YTDF[S:N-1]*YTDF[S:N-1] )
  RTD = RSN_TILT_DIRECTION( XTDF[S:N-1], YTDF[S:N-1], 345 ) ; MJ03F
  TITLE4PLOT = 'RSN-LILY (MJ03F) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Since 25th April 2015.'
;
  RSN_PLOT_RTMD, TM[S:N-1], RTM, RTD,   $ ; Inputs: 1-D arrays from the GET_TD, above.
;               'Do Not Save',  $ ; Input : File name for storing the displayed figure or
                'Do Not Save',  $ ; Input : File name for storing the displayed figure.
   SHOW= 1,      $  ; Input: Ask for Displaying the plot on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For all data from the Last 7 Days.  September 22nd, 2015
;
  RTM = SQRT( XTDF*XTDF + YTDF*YTDF )
  RTD = RSN_TILT_DIRECTION( XTDF, YTDF, 106 ) ; MJ03D
  TITLE4PLOT = 'RSN-LILY (MJ03D) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 7 Days.'
  RTM = SQRT( XTDF*XTDF + YTDF*YTDF )
  RTD = RSN_TILT_DIRECTION( XTDF, YTDF, 195 ) ; MJ03E
  TITLE4PLOT = 'RSN-LILY (MJ03E) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 7 Days.'
  RTM = SQRT( XTDF*XTDF + YTDF*YTDF )
  RTD = RSN_TILT_DIRECTION( XTDF, YTDF, 345 ) ; MJ03F
  TITLE4PLOT = 'RSN-LILY (MJ03F) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 7 Days.'
;
  RSN_PLOT_RTMD, TM, RTM, RTD,  $ ; Inputs: 1-D arrays from the GET_TD, above.
                'Do Not Save',  $ ; Input : File name for storing the displayed figure.
   PSYM= 8,      $  ; Use the Dot symbol for plotting.
   SHOW= 1,      $  ; Input: Ask for Displaying the plot on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; WRITE_PNG, 'MJ03E1WkAllRTMD.png',         TVRD(/TRUE)
; WRITE_PNG, 'MJ03F1Wk25Apr2015onRTMD.png', TVRD(/TRUE)
; WRITE_PNG, 'MJ03D1WkLast7DaysRTMD.png',   TVRD(/TRUE)  ; when is needed.
;
; July  7th, 2015
;
  RESTORE, 'MJ03D/MJ03D-LILY.idl'  ; Get LILY_XTILT, LILY_YTILT, LILY_TIME variables.
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
           DRTL,        $ ; 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
  LILY_TIME, LILY_XTILT, LILY_YTILT,  $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
            T, XT, YT   ; Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
  RESTORE, 'MJ03E/MJ03E-LILY.idl'  ; Get LILY_XTILT, LILY_YTILT, LILY_TIME variables.
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
           ERTL,        $ ; 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
  LILY_TIME, LILY_XTILT, LILY_YTILT,  $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
            T, XT, YT   ; Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
  RESTORE, 'MJ03F/MJ03F-LILY.idl'  ; Get LILY_XTILT, LILY_YTILT, LILY_TIME variables.
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
           FRTL,        $ ; 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
  LILY_TIME, LILY_XTILT, LILY_YTILT,  $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
            T, XT, YT   ; Outputs:  1-D arrays of JULDAY()s, Tilt Differences.
;
; (7) Note that 14-Day offset has been used before (July 7th, 2015).
;     Dr. Chadwick decided that 7-Day offset is better.  September 9th, 2015.
;
; To Display the Resultant Tilt Magnitudes and Directions using the XT, YT, T,
; See the following example:
;
  RTM = SQRT( XT*XT + YT*YT )
  RTD = RSN_TILT_DIRECTION( XT, YT, 106 ) ; MJ03D
  TITLE4PLOT = 'RSN-LILY (MJ03D) Resultant Tilt Magnitudes and Directions.  ' $
             + 'All Data with  7 Days Offset.'
;
  RTM = SQRT( XT*XT + YT*YT )
  RTD = RSN_TILT_DIRECTION( XT, YT, 195 ) ; MJ03E
  TITLE4PLOT = 'RSN-LILY (MJ03E) Resultant Tilt Magnitudes and Directions.  ' $
             + 'All Data with  7 Days Offset.'
;
  RTM = SQRT( XT*XT + YT*YT )
  RTD = RSN_TILT_DIRECTION( XT, YT, 345 ) ; MJ03F
  TITLE4PLOT = 'RSN-LILY (MJ03F) Resultant Tilt Magnitudes and Directions.  ' $
             + 'All Data with  7 Days Offset.'
;
; WRITE_PNG, 'MJ03dAllDfRTMD.png', TVRD(/TRUE)  ; when is needed.
;
  RSN_PLOT_RTMD, T, RTM, RTD,   $ ; Inputs: 1-D arrays from the GET_TD, above.
;               'Do Not Save',  $ ; Input : File name for storing the displayed figure or
                'Do Not Save',  $ ; Input : File name for storing the displayed figure.
   SHOW= 1,      $  ; Input: Ask for Displaying the plot on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; EXIT  ; End of RunGetTiltDiff.pro
