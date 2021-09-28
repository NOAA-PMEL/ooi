;
; This is a setup file: RunGetRates.pro
;
; The steps here are assuming the MJ03?/MJ03?-LilyRates.idl save files
; (created by the RunGetRates2Start.pro) are available.  So they can be
; updated for the accumulating the new Relevelling corrected resultant
; magnitudes values.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: December  10th, 2018 ;
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
; Get Updates of the releveling tilts and magnitudes
; and Create  the figures with the new Updated data. 
;
; From December 10th, 2018 on, 3DayMJ03[B,D-F]-LilyRates.idl is used
; instead of MJ03B,D-F]-LILY.idl to avoid Out of memories problem from IDL.
;
  PRINT, SYSTIME() + ' Updating the new MJ03B tilt rates.'
  S =    SYSTIME( 1 )      ; Mark the time.
;                 RSN Station ID  LILY_[X/Y]TILT & Others  Releveled Tilts & Rates
; GET_RELEVELING_TILTS, 'MJ03B', 'MJ03B/MJ03B-LILY.idl', 'MJ03B/MJ03B-LilyRates.idl', STATUS
  GET_RELEVELING_TILTS, 'MJ03B', 'MJ03B/3DayMJ03B-LILY.idl',  $
                                 'MJ03B/MJ03B-LilyRates.idl', STATUS
  N =    SYSTIME( 1 ) - S  ; Total seconds used.
  PRINT, SYSTIME() + ' Done Updating the new MJ03B tilt rates.', N
;
;    STATUS == 1 means New Tilt Rates are added and new figures should be plotted. 
  IF STATUS EQ 1 THEN  DISPLAY_RATES, 'MJ03B', 'MJ03B/MJ03B-LilyRates.idl'
  IF STATUS EQ 0 THEN  PRINT, 'No New Graphic Updates for MJ03B.'
;
;
  PRINT, SYSTIME() + ' Updating the new MJ03D tilt rates.'
  S =    SYSTIME( 1 )      ; Mark the time.
;                 RSN Station ID  LILY_[X/Y]TILT & Others  Releveled Tilts & Rates
; GET_RELEVELING_TILTS, 'MJ03D', 'MJ03D/MJ03D-LILY.idl', 'MJ03D/MJ03D-LilyRates.idl', STATUS
  GET_RELEVELING_TILTS, 'MJ03D', 'MJ03D/3DayMJ03D-LILY.idl', $
                                 'MJ03D/MJ03D-LilyRates.idl', STATUS
  N =    SYSTIME( 1 ) - S  ; Total seconds used.
  PRINT, SYSTIME() + ' Done Updating the new MJ03D tilt rates.', N
;
;    STATUS == 1 means New Tilt Rates are added and new figures should be plotted. 
  IF STATUS EQ 1 THEN  DISPLAY_RATES, 'MJ03D', 'MJ03D/MJ03D-LilyRates.idl'
  IF STATUS EQ 0 THEN  PRINT, 'No New Graphic Updates for MJ03D.'
;
;
  PRINT, SYSTIME() + ' Updating the new MJ03E tilt rates.'
  S =    SYSTIME( 1 )      ; Mark the time.
;                 RSN Station ID  LILY_[X/Y]TILT & Others  Releveled Tilts & Rates
; GET_RELEVELING_TILTS, 'MJ03E', 'MJ03E/MJ03E-LILY.idl', 'MJ03E/MJ03E-LilyRates.idl', STATUS
  GET_RELEVELING_TILTS, 'MJ03E', 'MJ03E/3DayMJ03E-LILY.idl',  $
                                 'MJ03E/MJ03E-LilyRates.idl', STATUS
  N =    SYSTIME( 1 ) - S  ; Total seconds used.
  PRINT, SYSTIME() + ' Done Updating the new MJ03E tilt rates.', N
;
;    STATUS == 1 means New Tilt Rates are added and new figures should be plotted. 
  IF STATUS EQ 1 THEN  DISPLAY_RATES, 'MJ03E', 'MJ03E/MJ03E-LilyRates.idl'
  IF STATUS EQ 0 THEN  PRINT, 'No New Graphic Updates for MJ03E.'
;
;
  PRINT, SYSTIME() + ' Updating the new MJ03F tilt rates.'
  S =    SYSTIME( 1 )      ; Mark the time.
;                 RSN Station ID  LILY_[X/Y]TILT & Others  Releveled Tilts & Rates
; GET_RELEVELING_TILTS, 'MJ03F', 'MJ03F/MJ03F-LILY.idl', 'MJ03F/MJ03F-LilyRates.idl', STATUS
  GET_RELEVELING_TILTS, 'MJ03F', 'MJ03F/3DayMJ03F-LILY.idl',  $
                                 'MJ03F/MJ03F-LilyRates.idl', STATUS
  N =    SYSTIME( 1 ) - S  ; Total seconds used.
  PRINT, SYSTIME() + ' Done Updating the new MJ03F tilt rates.', N
;
;    STATUS == 1 means New Tilt Rates are added and new figures should be plotted. 
  IF STATUS EQ 1 THEN  DISPLAY_RATES, 'MJ03F', 'MJ03F/MJ03F-LilyRates.idl'  ; (*)
  IF STATUS EQ 0 THEN  PRINT, 'No New Graphic Updates for MJ03F.'
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
