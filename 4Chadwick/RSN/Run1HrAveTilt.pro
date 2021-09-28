;
; This is a setup file: Run1HrAveTilt.pro is based on the RunGetTiltDiff.pro
;
; It is used the 1-Hr Average Tilt values for computing the X & Y tilt
; difference values offset relative to their current date with the tilt
; values at the specified date ahead.
; Then the tilt differences will be used to calculate the Resultant Tilt
; Magnitudes and Directions for plotting.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: April   18th, 2018 ; to be run at Garfield.
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
;.RUN ~/4Chadwick/RSN/PrintRSNdata2Files.pro
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
  GET_RELEVELING_TIMES, 'MJ03B-LILYreleveling.Times', BRTL  ; September 18th, 2017
  GET_RELEVELING_TIMES, 'MJ03D-LILYreleveling.Times', DRTL  ; Get the Releveling Times
  GET_RELEVELING_TIMES, 'MJ03E-LILYreleveling.Times', ERTL  ; for each of the stations.
  GET_RELEVELING_TIMES, 'MJ03F-LILYreleveling.Times', FRTL
;
; Note that [B/D/E/F]RTL are 2-D arrays in 2 x n of the JULDAY() values.
; where [B/D/E/F]RTL[0,i] & [B/D/E/F]RTL[1,i] are the Start & End Times
; of the Releveling for i = 0, 1, ..., n-1.
;
  RESTORE, 'MJ03B/MJ03B1HrAveLILY.idl'  ; Get XT, YT, T array variables.
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
    TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
           BRTL,        $ ; 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Negative value means use All the data.
           T, XT , YT , $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
        TIME, XTD, YTD   ; Outputs: 1-D arrays of JULDAY()s, Tilt Differences.
;
; Compute the Resultant Tilt Magnitudes and Directions using the XT, YT, T
; before displaying them.
;
  RTM = SQRT( XTD*XTD + YTD*YTD )
  RTD = RSN_TILT_DIRECTION( XTD, YTD, 345 ) ; MJ03B  February 22nd, 2018
; RTD = RSN_TILT_DIRECTION( XTD, YTD, 201 ) ; 201 is the "UnCorrected" & wrong value to used.
;
; For plotting all data from September 2nd, 2017 on
; and that will be considered as for All the data.
;
  N   = N_ELEMENTS( TIME )
  S   = WHERE( TIME GE JULDAY( 9,  2, 2017, 00,00,00 ) )
  S   = S[0]   ; Get the Time Index at August 17th, 2017.
  TITLE4PLOT = 'RSN-LILY (MJ03B) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Since 2nd September 2017.'
;
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
 'MJ03B/MJ03B1WkAllRTMD.png',  $ ; Input : File name for storing the displayed figure.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For plotting the data of the last 6 months.
;
  M   = N_ELEMENTS( T )
  JDY = FLOOR( T[M-1] ) - 183.5  ; Date of 6 months ago with time: T at 00:00:00. 
  S   = WHERE( TIME GE JDY )     ; The 183.5 will make sure the time at 00:00:00.
  S   = S[0]   ; Get the Time Index at 00:00:00 of 6 months ago.
  TITLE4PLOT = 'RSN-LILY (MJ03B) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 6 months.'
;
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
               'MJ03B/MJ03B1WkLast6MonthsRTMD.png',  $ ; Input : File name for storing the displayed figure.
  PSYM= 8,       $  ; Use the Dot symbol for plotting.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; Compute the Resultant Tilt Magnitudes and Directions from the Last 7 Days.
;
  JDY = FLOOR( T[M-1] ) - 7.5    ; Date of 7 days ago  with time: T  at 00:00:00. 
  S   = WHERE( TIME GE JDY )     ; The 183.5 will make sure the time at 00:00:00.
  S   = S[0]                     ; Get the Time Index at 00:00:00 of 7 Days ago.
;
; GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
;   TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
;                 BRTL, $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
;             7,        $ ; Input: Use  7-Day offset (7).
;          T, XT , YT , $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
; TIME,   XTD,     YTD  ; Outputs: 1-D arrays of JULDAY()s, Tilt Differences.
;
;
; RTM = SQRT( XTD*XTD + YTD*YTD )
; RTD = RSN_TILT_DIRECTION( XTD, YTD, 345 ) ; MJ03B  February 22nd, 2018
; RTD = RSN_TILT_DIRECTION( XTD, YTD, 201 ) ; 201 is the "UnCorrected" & wrong value to used.
  TITLE4PLOT = 'RSN-LILY (MJ03B) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 7 Days.'
;
; RSN_PLOT_RTMD,    TIME, RTM, RTD,  $ ; Inputs: 1-D arrays from the GET_TD, above.
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
 'MJ03B/MJ03B1WkLast7DaysRTMD.png',  $ ; Input : File name for storing the displayed figure.
  PSYM= 8,       $  ; Use the Dot symbol for plotting.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For printing the TIME, XTD, YTD, TIME, XTD, RTD & RTM into an output (text) file.
;
; PRINT_DATA2FILE, TIME, [[XTD],[YTD], [RTD], [RTM] ], 'MJ03B/MJ03.1HrXYTRTDM.Data'
;
  RESTORE, 'MJ03D/MJ03D1HrAveLILY.idl'  ; Get XT, YT, T array variables.
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
    TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
           DRTL,        $ ; 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Negative value means use All the data.
           T, XT , YT , $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
        TIME, XTD, YTD   ; Outputs: 1-D arrays of JULDAY()s, Tilt Differences.
;
; (7) Note that 14-Day offset has been used before (July 7th, 2015).
;     Dr. Chadwick decided that 7-Day offset is better.  September 9th, 2015.
;
; Compute the Resultant Tilt Magnitudes and Directions using the XT, YT, T
; before displaying them.
;
  RTM = SQRT( XTD*XTD + YTD*YTD )
  RTD = RSN_TILT_DIRECTION( XTD, YTD, 106 ) ; MJ03D
;
; For printing the TIME, XTD, YTD, TIME, XTD, RTD & RTM into an output (text) file.
;
; PRINT_DATA2FILE, TIME, [[XTD],[YTD], [RTD], [RTM] ], 'MJ03D/MJ03D1HrXYTRTDM.Data'
;
; For plotting all data from Start to Present.
;
  TITLE4PLOT = 'RSN-LILY (MJ03D) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Start to Present.'
  RSN_PLOT_RTMD, TIME, RTM, RTD,  $ ; Inputs: 1-D arrays from the GET_TD, above.
    'MJ03D/MJ03D1WkAllRTMD.png',  $ ; Input : File name for storing the displayed figure.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For plotting all data from April 24th, 2015 on.
;
  N   = N_ELEMENTS( TIME )
  S   = WHERE( TIME GE JULDAY( 4, 24, 2015, 00,00,00 ) )
  S   = S[0]   ; Get the Time Index at April 24th, 2015.
  TITLE4PLOT = 'RSN-LILY (MJ03D) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Since 25th April 2015.'
;
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
               'MJ03D/MJ03D1Wk25Apr2015onRTMD.png',  $ ; Input : File name for storing the displayed figure.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For plotting the data of the last 6 months.
;
  M   = N_ELEMENTS( T )
  JDY = FLOOR( T[M-1] ) - 183.5  ; Date of 6 months ago with time: T at 00:00:00. 
  S   = WHERE( TIME GE JDY )     ; The 183.5 will make sure the time at 00:00:00.
  S   = S[0]                     ; Get the Time Index at 00:00:00 of 6 months ago.
  TITLE4PLOT = 'RSN-LILY (MJ03D) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 6 months.'
;
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
               'MJ03D/MJ03D1WkLast6MonthsRTMD.png',  $ ; Input : File name for storing the displayed figure.
  PSYM= 8,       $  ; Use the Dot symbol for plotting.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; Compute the Resultant Tilt Magnitudes and Directions from the Last 7 Days.
;
;
  JDY = FLOOR( T[M-1] ) - 7.5    ; Date of 7 days ago  with time: T  at 00:00:00. 
  S   = WHERE( TIME GE JDY )     ; The 183.5 will make sure the time at 00:00:00.
  S   = S[0]                     ; Get the Time Index at 00:00:00 of 7 Days ago.
;
; GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
;   TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
;          DRTL[*,4:*], $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
;             7,        $ ; Input: Use  7-Day offset (7).
;          T, XT , YT , $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
; T[S:*], XT[S:*], YT[S:*],   $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.  (*)
; TIME,   XTD,     YTD  ; Outputs: 1-D arrays of JULDAY()s, Tilt Differences.
;
; (*) Using the index S for T[S:*], XT[S:*], YT[S:*], the results will be the same
;     w/o the index S.  October 2nd, 2015.
;
; RTM = SQRT( XTD*XTD + YTD*YTD )
; RTD = RSN_TILT_DIRECTION( XTD, YTD, 106 ) ; MJ03D
  TITLE4PLOT = 'RSN-LILY (MJ03D) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 7 Days.'
;
; RSN_PLOT_RTMD,    TIME, RTM, RTD,  $ ; Inputs: 1-D arrays from the GET_TD, above.
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
 'MJ03D/MJ03D1WkLast7DaysRTMD.png',  $ ; Input : File name for storing the displayed figure.
  PSYM= 8,       $  ; Use the Dot symbol for plotting.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For printing the TIME, XTD, YTD, TIME, XTD, RTD & RTM into an output (text) file.
;
; PRINT_DATA2FILE, TIME, [[XTD],[YTD], [RTD], [RTM] ], 'MJ03D/MJ03D1HrXYTRTDM.Data'
;
  RESTORE, 'MJ03E/MJ03E1HrAveLILY.idl'  ; Get XT, YT, T array variables.
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
    TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
           ERTL,        $ ; 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
           T, XT , YT , $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
        TIME, XTD, YTD   ; Outputs: 1-D arrays of JULDAY()s, Tilt Differences.
;
; (7) Note that 14-Day offset has been used before (July 7th, 2015).
;     Dr. Chadwick decided that 7-Day offset is better.  September 9th, 2015.
;
; Compute the Resultant Tilt Magnitudes and Directions using the XT, YT, T
; before displaying them.
;
  RTM = SQRT( XTD*XTD + YTD*YTD )
  RTD = RSN_TILT_DIRECTION( XTD, YTD, 195 ) ; MJ03E
;
; For printing the TIME, XTD, YTD, TIME, XTD, RTD & RTM into an output (text) file.
;
; PRINT_DATA2FILE, TIME, [[XTD],[YTD], [RTD], [RTM] ], 'MJ03E/MJ03E1HrXYTRTDM.Data'
;
; For plotting all data from Start to Present.
;
  TITLE4PLOT = 'RSN-LILY (MJ03E) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Start to Present.'
  RSN_PLOT_RTMD, TIME, RTM, RTD,  $ ; Inputs: 1-D arrays from the GET_TD, above.
    'MJ03E/MJ03E1WkAllRTMD.png',  $ ; Input : File name for storing the displayed figure.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For plotting all data from April 24th, 2015 on.
;
  N   = N_ELEMENTS( TIME )
  S   = WHERE( TIME GE JULDAY( 4, 24, 2015, 00,00,00 ) )
  S   = S[0]   ; Get the Time Index at April 24th, 2015.
  TITLE4PLOT = 'RSN-LILY (MJ03E) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Since 25th April 2015.'
;
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
               'MJ03E/MJ03E1Wk25Apr2015onRTMD.png',  $ ; Input : File name for storing the displayed figure.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For plotting the data of the last 6 months.
;
  M   = N_ELEMENTS( T )
  JDY = FLOOR( T[M-1] ) - 183.5  ; Date of 6 months ago with time: T at 00:00:00. 
  S   = WHERE( TIME GE JDY )     ; The 183.5 will make sure the time at 00:00:00.
  S   = S[0]                     ; Get the Time Index at 00:00:00 of 6 months ago.
  TITLE4PLOT = 'RSN-LILY (MJ03E) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 6 months.'
;
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
               'MJ03E/MJ03E1WkLast6MonthsRTMD.png',  $ ; Input : File name for storing the displayed figure.
  PSYM= 8,       $  ; Use the Dot symbol for plotting.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; Compute the Resultant Tilt Magnitudes and Directions from the Last 7 Days.
;
  JDY = FLOOR( T[M-1] ) - 7.5    ; Date of 7 days ago  with time: T  at 00:00:00. 
  S   = WHERE( TIME GE JDY )     ; The 183.5 will make sure the time at 00:00:00.
  S   = S[0]                     ; Get the Time Index at 00:00:00 of 7 Days ago.
;
; GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
;   TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
;
; GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
;   TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
;          ERTL,        $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
;             7,        $ ; Input: Use  7-Day offset (7).
;          T, XT , YT , $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
;       TIME, XTD, YTD   ; Outputs: 1-D arrays of JULDAY()s, Tilt Differences.
;
; RTM = SQRT( XTD*XTD + YTD*YTD )
; RTD = RSN_TILT_DIRECTION( XTD, YTD, 195 ) ; MJ03E
  TITLE4PLOT = 'RSN-LILY (MJ03E) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 7 Days.'
;
; RSN_PLOT_RTMD,    TIME, RTM, RTD,  $ ; Inputs: 1-D arrays from the GET_TD, above.
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
 'MJ03E/MJ03E1WkLast7DaysRTMD.png',  $ ; Input : File name for storing the displayed figure.
  PSYM= 8,       $  ; Use the Dot symbol for plotting.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
  RESTORE, 'MJ03F/MJ03F1HrAveLILY.idl'  ; Get XT, YT, T array variables.
;
  GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
    TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
           FRTL,        $ ; 2-D array in JULDAY() values of the Releveling periods.
             -7,        $ ; Input: Use  7-Day offset for All data (7).
           T, XT , YT , $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
        TIME, XTD, YTD   ; Outputs: 1-D arrays of JULDAY()s, Tilt Differences.
;
; (7) Note that 14-Day offset has been used before (July 7th, 2015).
;     Dr. Chadwick decided that 7-Day offset is better.  September 9th, 2015.
;
; Compute the Resultant Tilt Magnitudes and Directions using the XT, YT, T
; before displaying them.
;
  RTM = SQRT( XTD*XTD + YTD*YTD )
  RTD = RSN_TILT_DIRECTION( XTD, YTD, 345 ) ; MJ03F
;
; For printing the TIME, XTD, YTD, TIME, XTD, RTD & RTM into an output (text) file.
;
; PRINT_DATA2FILE, TIME, [[XTD],[YTD], [RTD], [RTM] ], 'MJ03F/MJ03F1HrXYTRTDM.Data'
;
; For plotting all data from Start to Present.
;
  TITLE4PLOT = 'RSN-LILY (MJ03F) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Start to Present.'
  RSN_PLOT_RTMD, TIME, RTM, RTD,  $ ; Inputs: 1-D arrays from the GET_TD, above.
    'MJ03F/MJ03F1WkAllRTMD.png',  $ ; Input : File name for storing the displayed figure.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For plotting all data from April 24th, 2015 on.
;
  N   = N_ELEMENTS( TIME )
  S   = WHERE( TIME GE JULDAY( 4, 24, 2015, 00,00,00 ) )
  S   = S[0]   ; Get the Time Index at April 24th, 2015.
  TITLE4PLOT = 'RSN-LILY (MJ03F) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Since 25th April 2015.'
;
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
               'MJ03F/MJ03F1Wk25Apr2015onRTMD.png',  $ ; Input : File name for storing the displayed figure.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; For plotting the data of the last 6 months.
;
  M   = N_ELEMENTS( T )
  JDY = FLOOR( T[M-1] ) - 183.5  ; Date of 6 months ago with time: T at 00:00:00. 
  S   = WHERE( TIME GE JDY )     ; The 183.5 will make sure the time at 00:00:00.
  S   = S[0]                     ; Get the Time Index at 00:00:00 of 6 months ago.
  TITLE4PLOT = 'RSN-LILY (MJ03F) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 6 months.'
;
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
               'MJ03F/MJ03F1WkLast6MonthsRTMD.png',  $ ; Input : File name for storing the displayed figure.
  PSYM= 8,       $  ; Use the Dot symbol for plotting.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
; Compute the Resultant Tilt Magnitudes and Directions from the Last 7 Days.
;
  JDY = FLOOR( T[M-1] ) - 7.5    ; Date of 7 days ago  with time: T  at 00:00:00. 
  S   = WHERE( TIME GE JDY )     ; The 183.5 will make sure the time at 00:00:00.
  S   = S[0]                     ; Get the Time Index at 00:00:00 of 7 Days ago.
;
; GET_TD,  ADD_FRONT=1, $ ; Apply fix offset values before relative offset begins.
;   TIME_INTERVAL=3600, $ ; Input: Time spacing between data points.
;          FRTL[*,2:*], $ ; Input: 2-D array in JULDAY() values of the Releveling periods.
;             7,        $ ; Input: Use  7-Day offset (7).
;          T, XT , YT , $ ; Inputs: 1-D arrays of JULDAY()s, Tilts in radians.
;       TIME, XTD, YTD   ; Outputs: 1-D arrays of JULDAY()s, Tilt Differences.
;
; RTM = SQRT( XTD*XTD + YTD*YTD )
; RTD = RSN_TILT_DIRECTION( XTD, YTD, 345 ) ; MJ03F
  TITLE4PLOT = 'RSN-LILY (MJ03F) Resultant Tilt Magnitudes and Directions.  ' $
             + '1-Week Tilt Rate (7 Day Offset) Last 7 Days.'
;
; RSN_PLOT_RTMD,    TIME, RTM, RTD,  $ ; Inputs: 1-D arrays from the GET_TD, above.
  RSN_PLOT_RTMD, TIME[S:N-1],RTM[S:N-1],RTD[S:N-1],  $ ; Inputs: 1-D arrays from the GET_TD, above.
 'MJ03F/MJ03F1WkLast7DaysRTMD.png',  $ ; Input : File name for storing the displayed figure.
  PSYM= 8,       $  ; Use the Dot symbol for plotting.
; SHOW= 1,       $  ; Input: Ask for Displaying the plot on the screen.
  SHOW= 0,       $  ; Input: No Plotting on the screen.
  TITLE=TITLE4PLOT  ; Input: Title for the Figure.
;
EXIT  ; End of Run1HrAveTilt.pro
