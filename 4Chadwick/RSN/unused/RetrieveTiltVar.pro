;
; File: RetrieveTiltVar.pro
;
; This program will retrieve the RSN Tile variables from a given
; IDL files: MJ03[/D/E/F]-[LILY/IRISI/HEAT].idl  and return only
; the variables of TIME, XTILT and YTILE to the callers.
; Note that the XTILT and YTILE will always be returned as in µradians.
;
; Programmer: T-K Andy Lau NOAA/PMEL/Acoustic Program HMSC Newport Oregon.
;
; Revised on June      16th, 2015
; Created on June      16th, 2015
;

;
; Callers: PLOT_TD_RTMD ans Users
;
PRO RETRIEVE_TILT_VARIABLES,  IDL_FILE,  $ ;  Input : IDL Save File name.
                    TIME, XTILT, YTILT,  $ ; Outputs: 1-D arrays.
                    SENSOR  ; Output: 'HEAT', 'IRIS' or 'LILY'.
;
; Retrieve the data from the IDL_FILE which depended on which sensor,
; the file will contain the array variables:
; HEAT_TIME, HEAT_XTILT, HEAT_YTILT; IRIS_TIME, IRIS_XTILT, IRIS_YTILT; or
; LILY_TIME, LILY_XTILT, LILY_YTILT, LILY_RTM,     LILY_TEMP, LILY_RTD
; Note that LILY_COMPASS & LILY_VOLTAGE array values will not be used here.
;
  PRINT, SYSTIME() + ' Retrieving the Tilt Data in the file: ' + IDL_FILE + ' ...'
  RESTORE, IDL_FILE  ; Get the *_XTILT, *_YTILT and *_TIME
; 
; Rename the *_XTILT, *_YTILT and *_TIME to XTILT, YTILT and TIME respectively.
; Note that the units for the X & Y tilts are in microradians (µradians) from the
; LILY sensors.  The others: IRIS & HEAT, their tilts' units are in degrees.
; The conversion is 1 degree = 10000/57.2957795 = 17453.2925 µradians.
; June 11th, 2015
;
  IF STRPOS( IDL_FILE, 'HEAT' ) GE 0 THEN  BEGIN  ; HEAT Tilts are being used.
      TIME = TEMPORARY( HEAT_TIME  )
     XTILT = TEMPORARY( HEAT_XTILT )*17453.2925   ; Convert the tilt from
     YTILT = TEMPORARY( HEAT_YTILT )*17453.2925   ; Degrees to µradians.
    SENSOR = 'HEAT'
  ENDIF ELSE IF STRPOS( IDL_FILE, 'IRIS' ) GE 0 THEN  BEGIN  ; IRIS Tilts are being used.
      TIME = TEMPORARY( IRIS_TIME  )
     XTILT = TEMPORARY( IRIS_XTILT )*17453.2925   ; Convert the tilt from
     YTILT = TEMPORARY( IRIS_YTILT )*17453.2925   ; Degrees to µradians.
    SENSOR = 'IRIS'
  ENDIF ELSE IF STRPOS( IDL_FILE, 'LILY' ) GE 0 THEN  BEGIN  ; LILY Tilts are being used.
      TIME = TEMPORARY( LILY_TIME  )
     XTILT = TEMPORARY( LILY_XTILT )
     YTILT = TEMPORARY( LILY_YTILT )
     LILY_COMPASS = 0
     LILY_VOLTAGE = 0  ; Free these variables
     LILY_RTM     = 0  ; since they are Not
     LILY_RTD     = 0  ; beign used here.
     LILY_TEMP    = 0
    SENSOR = 'LILY'
  ENDIF ELSE BEGIN  ; Assume IDL_FILE contains no tilt values.
     PRINT, 'The IDL Save File: ' + IDL_FILE
     PRINT, 'Does Not contain any correct Tilt variable names.'
     SENSOR = 'None'  ; To indicate No data.
     RETURN  ; To caller.
  ENDELSE
;
RETURN
END  ; RETRIEVE_TILT_VARIABLES.
