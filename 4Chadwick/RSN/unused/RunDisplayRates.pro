;
; This is a setup file: RunGetRates.pro
;
; The steps here are assuming the MJ03?/MJ03?-LilyRates.idl save files
; (created by the RunGetRates2Start.pro) are available.  So they can be
; updated for the accumulating the new Relevelling corrected resultant
; magnitudes values.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: January   12th, 2018 ; to be run at Caldera.
;
;
.RUN ~/idl/IDLcolors.pro
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
.RUN ~/4Chadwick/RSN/PlotNANOdata.pro
.RUN ~/4Chadwick/RSN/GetRelevelingTimes.pro
.RUN ~/4Chadwick/RSN/AdjustOffsets.pro
;
  CD, '~/4Chadwick/RSN/'
;
; Define a Dot symbol for plotting optional.
;
; USERSYM, [-0.2,0.2],[0,0]
; S = FINDGEN( 17 )*!PI/8.0
; USERSYM, COS( S ), SIN( S ), /FILL  ;, THICK=2
;
  SET_BACKGROUND, /WHITE
;
; Create  the figures with the current releveling tilts rate data.
;
  PRINT, SYSTIME() + ' Displaying the MJ03D tilt rates.'
  S =    SYSTIME( 1 )      ; Mark the time.
  DISPLAY_RATES, 'MJ03B', 'MJ03B/MJ03B-LilyRates.idl'
  N =    SYSTIME( 1 ) - S  ; Total seconds used.
  PRINT, SYSTIME() + ' Done Displaying the MJ03D tilt rates.', N
;
;
  PRINT, SYSTIME() + ' Displaying the new MJ03D tilt rates.'
  S =    SYSTIME( 1 )      ; Mark the time.
  DISPLAY_RATES, 'MJ03D', 'MJ03D/MJ03D-LilyRates.idl'
  N =    SYSTIME( 1 ) - S  ; Total seconds used.
  PRINT, SYSTIME() + ' Done Displaying the new MJ03D tilt rates.', N
;
;
  PRINT, SYSTIME() + ' Displaying the new MJ03E tilt rates.'
  S =    SYSTIME( 1 )      ; Mark the time.
  DISPLAY_RATES, 'MJ03E', 'MJ03E/MJ03E-LilyRates.idl'
  N =    SYSTIME( 1 ) - S  ; Total seconds used.
  PRINT, SYSTIME() + ' Done Displaying the new MJ03E tilt rates.', N
;
;
  PRINT, SYSTIME() + ' Displaying the new MJ03F tilt rates.'
  S =    SYSTIME( 1 )      ; Mark the time.
  DISPLAY_RATES, 'MJ03F', 'MJ03F/MJ03F-LilyRates.idl'  ; (*)
  N =    SYSTIME( 1 ) - S  ; Total seconds used.
  PRINT, SYSTIME() + ' Done Displaying the new MJ03F tilt rates.', N
;
;
; (*) All 3 figures will be genrated in the background with WINDOW, /PIXMAP option
;     and the output figure file names will be:
;     MJ03?/MJ03?-RTM[1WkRate/-12MO/-Since2015].png where '?' = 'B','D','E' & 'F'.
;
;     To display the all 3 figures on screen w/o creating the figure files,
;     Use the following example:
;     DISPLAY_RATES, 'MJ03F', 'MJ03F/MJ03F-LilyRates.idl', SHOW_PLOT=1
;
; --------------------------------------------------------------------------------
;
; Note that the MJ03?/MJ03?-LILY.idl save file contains the following
; array variables: LILY_TIME, LILY_[X/Y]TILT plus others.
; and the  MJ03?/MJ03?-LilyRates.idl save file contains the following
; array variables: T, RTM, XTILT, YTILT,  TIME, RTM1DAY,
;                  XOFFSET, YOFFSET, SRTIME, SRATE, LRTIME, LRATE
;
; RESTORE, 'MJ03F/MJ03F-LilyRates.idl'  ; Get the Rate data for reviewing.
; HELP, NAME='*'  ; Show all the variables so far.
;
; End: RunGetRates.pro
