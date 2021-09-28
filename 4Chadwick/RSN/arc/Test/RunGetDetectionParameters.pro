;
; This is a setup file: GetDetectionParameters.pro for recomputing
; the Event Detection Parameters using the RSN NANO data stored in
; the MJ03[D/E/F]-NANO.idl files
;
; Programmer: T-K Andy Lau       NOAA/PMEL/OERD  HMSC  Newport, Oregon.
;    Revised: February 10th, 2015 ; to be run at Garfield.
;
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/Test/GetDetectionParameters.pro
;
; To Run the GetDetectionParameters.pro program do the following:
; The following steps were used to recompute the Event Detection Parameters
; from the beginning of NANO Data from RSN.
;
; CD, '~/4Chadwick/RSN/'
; RESTORE, 'MJ03D/MJ03D-NANO.idl'  ; Get the NANO_TIME & NANO_DETIDE variables.
; RESTORE, 'MJ03E/MJ03E-NANO.idl'  ; or
; RESTORE, 'MJ03F/MJ03F-NANO.idl'
; Look for the Start Time index: S in the NANO_TIME array where the
; 1st Detection Parameter will be calculated.
; S  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY( 2, 3,2015,00,00,00) ) ; (D&E)
; S += 80  &  PRINT, FORMAT='(C())', NANO_TIME[S]
; S = 856596 for (D) = Tue Feb 03 19:15:15 2015
; S = 826966 for (E) = Tue Feb 03 19:19:00 2015.
; S = 856516 for (F) = Tue Feb 03 19:20:30 2015.
;
; S = Index for NANO_TIME[S] where the 1st Detection Parameter
;     to be computed.  The next one will be M data points later.
; M = 60 ; = 15*4  ; <--15-minute Time Interval in terms of data points.
;
; RESTORE, 'MJ03D/EventDetectionParametersMJ03D.idl'
; RESTORE, 'MJ03E/EventDetectionParametersMJ03E.idl'
; RESTORE, 'MJ03F/EventDetectionParametersMJ03F.idl'
;
; GET_DETECTION_PRARMETERS, NANO_TIME, NANO_DETIDE, S,M, RATE
; RATE = TRANSPOSE( TEMPORARY( RATE ) )  ; After DATA has been checkd out.
; I = WHERE( RATE[*,1] GT -5 ) &  HELP, I    ; Skip the spikes
; D = RATE[I,*]  &  RATE = 0   &  RATE  = D  ; Save values w/o the spikes.
;
; D = [ DATA[0:14261,*], RATE ]      &  HELP, D  ; For (D)
; D = [ DATA[0:13774,*], RATE ]      &  HELP, D  ; For (E)
; D = [ DATA[0:14262,*], RATE ]      &  HELP, D  ; For (F)
; DATA = 0  & DATA = TEMPORARY( D )  &  HELP, DATA
;
; SAVE_DETECTION_PARAMTERS, 'Test/EventDetectionParametersTestF.idl', DATA
; SAVE_DETECTION_PARAMTERS, 'Test/EventDetectionParametersTestE.idl', DATA
; SAVE_DETECTION_PARAMTERS, 'Test/EventDetectionParametersTestD.idl', DATA
; and  Rename EventDetectionParametersTestD.idl   to
; ~/4Chadwick/RSN/MJ03D/EventDetectionParametersMJ03D.idl later as needed
;
; To Check the Resutls, do the following:
;
; @~/4Chadwick/RSN/SetupRSN.pro
; PLOT_SHORT_TERM_DATA, 'EventDetectionParametersTmpD.idl',  $
;                        [-3,1], SHOW_PLOT=1 ;,UPDATE_PLOT=1 ;<--Optional.
;
; End: RunGetDetectionParameters.pro
