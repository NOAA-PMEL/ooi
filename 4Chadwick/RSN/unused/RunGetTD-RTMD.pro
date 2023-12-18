;
; This is a setup file: RunGetTD-RTMD.pro
; It is used for computing the average X & Y tilt values offset with the
; tilt values at the specified date.  Then the average tilts will be used
; to calculate the Resultant Tilt Magnitudes and Directions for plotting.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: June     11th, 2015 ; to be run at Garfield.
;
;
.RUN ~/idl/IDLcolors.pro
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/ProcessRSNdata.pro
.RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
.RUN ~/4Chadwick/RSN/PlotLILYdata.pro
.RUN ~/4Chadwick/RSN/PlotNANOdata.pro
.RUN ~/4Chadwick/RSN/PlotRSNdata.pro
.RUN ~/4Chadwick/RSN/GetTD-RTMD.pro
;
  CD, '~/4Chadwick/RSN/'
;
; To Run the program, see the following examples.
;
; RESTORE, 'MJ03E/MJ03E-IRIS.idl'  ; Get IRIS_XTILT, IRIS_YTILT, IRIS_TIME variables.
; GET_ATD,        IRIS_XTILT, IRIS_YTILT, IRIS_TIME,  $  ; Inputs: X,Y Tilt Data & their Times.
; JULDAY(4,23,2015,0,0,0),JULDAY(4,26,2015,23,59,59), $  ; Inputs: Start & End Time Range to use.
; OFFSET=JULDAY(4,23,2015,0,0,0),  $ ; Input: Offset time for computing the tilt differences (D).
; /TO_MICRORADIAN,          $ ; Ask the units for the XT & YT output below to be in µradians (µ).
; 300,    $  ; Input: Data points in seconds to be used for computing the average of X & Y Tilts.
; XT, YT, T  ; Outputs: 1-D arrays of the X & Y average Tilts with the Offset and Time stamps. 
;
; (D) Each value in XT & YT is computed in the following example.
;     XT[i] = MEAN( IRIS_XTILT[I:N] ) - IRIS_XTILT[S]
;  where  IRIS_XTILT[I:N] contains 600 seconds of data points,
;  and    S = the index at the time of OFFSET=JULDAY(4,23,2015,0,0,0)
;  for i within the Time Range of JULDAY(4,23,2015,0,0,0) & JULDAY(4,26,2015,23,59,59).
;
; (µ) The tilt values from the IRIS & HEAT sensors are in degrees.
;     Only the LILY tilt values are in µradians.  Therefore, the Keyword: TO_MIRCORADIAN
;     only apply to the IRIS_XTILT & IRIS_YTILT and Not the LILY_XTILT & LILY_YTILT below.
;     The conversion is 1 degree = 10000/57.2957795 = 17453.2925 µradians.
;
; Or
;
; RESTORE, '~/4Chadwick/RSN/OffsetTimes4LILY.idl'  ; Get MJ03[D/E/F]_LILY_OFFSET
; RESTORE, 'MJ03F/MJ03F-LILY.idl'   ; Get LILY_XTILT, LILY_YTILT, LILY_TIME variables.
; GET_ATD,        LILY_XTILT, LILY_YTILT, LILY_TIME,  $  ; Inputs: X,Y Tilt Data & their Times.
; JULDAY(4,23,2015,0,0,0),JULDAY(4,26,2015,23,59,59), $  ; Inputs: Start & End Time Range to use.
; OFFSET=[JULDAY(4,23,2015,0,0,0),JULDAY(4,24,2015,17,10,19),JULDAY(4,25,2015,16,28,05)],  $ ;(D+).
; 300,    $  ; Input: Data points in seconds to be used for computing the average of X & Y Tilts.
; XT, YT, T  ; Outputs: 1-D arrays of the X & Y average Tilts with the Offset and Time stamps. 
;
; Note that the
; OFFSET=[JULDAY(4,23,2015,0,0,0),JULDAY(4,24,2015,17,10,19),JULDAY(4,25,2015,16,28,05)]
; above will be same as
; OFFSET=MJ03F_LILY_OFFSET  ; i.e.
; MJ03F_LILY_OFFSET = [JULDAY(4,23,2015,0,0,0),JULDAY(4,24,2015,17,10,19),JULDAY(4,25,2015,16,28,05)]
;
; (D+) 
; Each value in XT & YT is computed as same as in the (D) above; but,
; in different segment depended on number of the OFFSETs are given.
; Using the example input in the OFFSET= in the (D+) line, there are 3 of them.
; Note that the Order of the JULDAY() values from early to later is important;
; otherwise, wrong results will occur.  The OFFSET will be applied as follow:
;
; The LILY_[X/Y]TILT at JULDAY(4,23,2015,0,0,0) will be used as the Offset for the
; for the Time Range from JULDAY(4,23,2015,0,0,0) to before JULDAY(4,24,2015,17:10:19).
; The LILY_[X/Y]TILT at JULDAY(4,24,2015,17:10:19) will be used as the Offset for the
; Time Range from JULDAY(4,24,2015,17:10:19) to before the JULDAY(4,25,2015,16,28,05).
; The LILY_[X/Y]TILT at JULDAY(4,25,2015,16,28,05) will be used as the Offset for the
; Time Range from JULDAY(4,25,2015,16,28,05) to the end of JULDAY(4,26,2015,23,59,59).
;
; Note that their will be data gaps before the times JULDAY(4,24,2015,17:10:19) and
; JULDAY(4,25,2015,16,28,05).  The reason for gaps is the Tilt meter was releveling.
;
; To Display the Resultant Tilt Magnitudes and Directions using the XT, YT, T,
; See the following example:
; PLOT_ATD_RTMD, 'IRIS-MJ03E',  $ ; Input: Show which Station. Important for (RTD).
;                 XT, YT, T,    $ ; Inputs: 1-D arrays from the GET_ATD above.
; SHOW= 1,  $ ; Ask for Displaying the plot on the screen.
; PSYM=-3,  $ ; Ask for plotting lines between pointsR; otherwise, only points plotting.
; TITLE='RSN (IRIS-MJ03E) Resultant Tilt Magnitudes and Directions (5-Min. Average)'
;
; (RTD)  Note that when 'IRIS-MJ03E', 'IRIS-MJ03D', 'IRIS-MJ03F' is used, it is not only
; showing which station is being used, it also indicate what correct parameters will be
; used for computing the Resultant Tilt Directions, i.e. if XT & YT are from station: MJ03E
; but 'IRIS-MJ03D' is passed to the PLOT_ATD_RTMD, the wrong Resultant Tilt Directions
; will be shown.
;
; WRITE_PNG, 'IRIS-MJ03E5MinODT-RTMD.png', TVRD(/TRUE)  ; When save the figure is needed.
;
; EXIT  ; End of RunGetTD-RTMD.
