;
; This is a setup file: GetDetectionParameters.pro for recomputing
; the Event Detection Parameters using the RSN NANO data stored in
; the MJ03[D/E/F]-NANO.idl files
;
; Programmer: T-K Andy Lau       NOAA/PMEL/OERD  HMSC  Newport, Oregon.
;    Revised: February  2nd, 2015 ; to be run at Garfield.
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
; Look for the Start Time index: S in the NANO_TIME array where the
; 1st Detection Parameter will be calculated.
; S  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY(11,17,2014,21,20,00) ) ; (D&E)
; S -= 1  ; and S = 453302 FOR (D) and S = 424418 for (E).
; PRINT, FORMAT='(C())', NANO_TIME[S]  ; = JULDAY(11,17,2014,21,20,00).
; S  = LOCATE_TIME_POSITION( NANO_TIME, JULDAY(11,17,2014,21,17,15) ) ; (F)
; S -= 1  ; S = 453182.   So that NANO_TIME[S] = JULDAY(11,27,2014,21,17,15)
; PRINT, FORMAT='(C())', NANO_TIME[S-1:S+1]  ; Checking the results.
;
; S = Index for NANO_TIME[S] where the 1st Detection Parameter
;     to be computed.  The next one will be M data points later.
; M = 60 ; = 15*4  ; <--15-minute Time Interval in terms of data points.
;
; GET_DETECTION_PRARMETERS, NANO_TIME, NANO_DETIDE, S,M, DATA
;
; DATA = TRANSPOSE( TEMPORARY( DATA ) )  ; After DATA has been checkd out.
; SAVE_DETECTION_PARAMTERS, 'EventDetectionParametersTestD.idl', DATA
; and  Rename EventDetectionParametersTestD.idl   to
; ~/4Chadwick/RSN/EventDetectionParametersMJ03D.idl later as needed
;
; To Check the Resutls, do the following:
;
; @~/4Chadwick/RSN/SetupRSN.pro
; PLOT_SHORT_TERM_DATA, 'EventDetectionParametersTmpD.idl',  $
;                        [-3,1], SHOW_PLOT=1 ;,UPDATE_PLOT=1 ;<--Optional.
;
; End: RunGetDetectionParameters.pro
