;
; File: RunUpdateNANOdiffE-Frates.pro
;
; The IDL steps will Update the Deteided NANO pressure differences (MJ03E-MJ03F) data
; and the Compute & Save the 1-Day means, 7-, 8- and 12-week rates of the depth chages
; from the newest data.
;
; Created: August  20th, 2018
; Revised: February 7th, 2020
;
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
 .RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
 .RUN ~/4Chadwick/RSN/GetNANOdifferenceRates.pro
 .RUN ~/4Chadwick/RSN/match.pro     ; At Caldera.
;.RUN           ~/idl/match.pro     ; At Garfiled.
;
  PRINT, SYSTIME() + ' Start running of RunUpdateNANOdiffE-Frates.pro ...'
;
  CD, '~/4Chadwick/RSN/'
;
; Restrieve the NANO data Array variables:
; NANO_DETIDE, NANO_PSIA, NANO_TEMP and NANO_TIME.
;
  RESTORE, '~/4Chadwick/RSN/MJ03E/3DayMJ03E-NANO.idl'  ; It contains 7 Day data.
  MJ03JE_TIME   = TEMPORARY( NANO_TIME   )
  MJ03JE_DETIDE = TEMPORARY( NANO_DETIDE )  ; Rename the arrays' variables.
; MJ03JE_PSIA   = TEMPORARY( NANO_PSIA   )
; MJ03JE_TEMP   = TEMPORARY( NANO_TEMP   )  ; Temperature values will not be used.
  RESTORE, '~/4Chadwick/RSN/MJ03F/3DayMJ03F-NANO.idl'
  MJ03JF_TIME   = TEMPORARY( NANO_TIME   )
  MJ03JF_DETIDE = TEMPORARY( NANO_DETIDE )  ; Rename the arrays' variables.
; MJ03JF_PSIA   = TEMPORARY( NANO_PSIA   )
; MJ03JF_TEMP   = TEMPORARY( NANO_TEMP   )  ; Temperature values will not be used.
;
  NANO_PSIA     = 0  ; These 2 variables
  NANO_TEMP     = 0  ; and not being used.
;
; Compute the differences between MJ03JE & MJ03JF, i.e., MJ03JE - MJ03JF
;
  MATCH, MJ03JF_TIME, MJ03JE_TIME, JF, JE, EPSILON=0.000001
  NANO_DIFF = ( MJ03JE_DETIDE[JE] - MJ03JF_DETIDE[JF] )
  NANO_TIME =   MJ03JF_TIME[JF]   ; Also = MJ03JE_TIME[JE].
;
; Append the newest differences data in: NANO_TIME & NANO_DIFF in any to the
; data stored in the file: ~/4Chadwick/RSN/MJ03F/NANOdifferencesMJ03E-F.idl
;
  UPDATE_NANO_DIFF_SAVE_FILE, 'MJ03F/NANOdifferencesMJ03E-F.idl',  $ ; File to be updates.
         NANO_TIME, NANO_DIFF,  $ ; Inputs: Arrays contain the Newest data from (7-Day)
         STATUS     ; Output: = 'Updated' or 'No Update'
;
  NANO_TIME = 0  ; Free the variables before reusing them.
  NANO_DIFF = 0  ; It will be reused for storing 1-Day Means of the pressure differences below.
;
; Restrieve the arrays for the 1-Day Mean & Time plus 4-, 8-, 12- & 24-week rates of depth
; changes compute from the Detided pressure ( MJ03JE - MJ03JF ).
;
  RESTORE, 'MJ03F/NANOdiffRatesMJ03E-F.idl'  ; to get
;           NANO1DAY_MEAN, NANO1DAY_TIME, RATE_4WK, RATE_8WK, RATE12WK, RATE24WK
;
  N = N_ELEMENTS( NANO1DAY_TIME )  ; = N_ELEMENTS( NANO1DAY_MEAN ) = N_ELEMENTS( RATE*WK )
;
; Compute the 1-Day means from the newest differences data.
;
  GET_NANO1DAY_MEANS4DIFF, 'MJ03F/NANOdifferencesMJ03E-F.idl',  $ ; File contains the latest data.
      NANO1DAY_TIME[N-1],   $ ;  Input : The last computed 1-Day Mean's time.
      NANO_TIME, NANO_DIFF, $ ; Outputs: Arrays of the Time & the computed 1-Day Means.
      STATUS                  ; Output : 1 = 1-Day Means computed & 0 = No new 1-Day Means.
;
; Attach  84 more days or 12 weeks of times and averages in front of the NANO_TIME & NANO_DIFF
; so that the 1st 12-week rate can be computed.  From August 21st, 2018 to February 7th, 2020.
;
; Attach 168 more days or 24 weeks of times and averages in front of the NANO_TIME & NANO_DIFF
; so that the 1st 24-week rate can be computed.  From February 7th, 2020 on.
;
  IF STATUS GT 0 THEN  NANO_TIME = [ NANO1DAY_TIME[N-168:N-1], TEMPORARY( NANO_TIME ) ]
  IF STATUS GT 0 THEN  NANO_DIFF = [ NANO1DAY_MEAN[N-168:N-1], TEMPORARY( NANO_DIFF ) ]
;
; Compute the 4-, 8-, 12- and 24-week rates of the depth chages newest differences data.
;
  GET_NANO_DIFF_RATES, NANO_TIME, NANO_DIFF,  $ ; Inputs: Output arrays from GET_1DAY_MEANS4DIFF.
                RATE4 , RATE8 ,  $ ; Outputs: Arrays of the computed 4-,8-,
                RATE12, RATE24,  $ ; Outputs: 12- & 24-week rates.  Added 24-week rate on 2/7/2020.
                TIME,            $ ; Output : Array  of the RATEs above.
                STATUS             ; Output : = Total elements in TIME & = 0 means No new rates.
;
  N = N_ELEMENTS( NANO_TIME )  ; = N_ELEMENTS( NANO_DIFF )
;
; Append the 1-Day Means and the Rates into the file: MJ03F/NANOdiffRatesMJ03E-F.idl .
;
  IF STATUS GT 0 THEN  NANO1DAY_TIME = [ TEMPORARY(NANO1DAY_TIME), TEMPORARY( TIME   ) ]
  IF STATUS GT 0 THEN  NANO1DAY_MEAN = [ TEMPORARY(NANO1DAY_MEAN), TEMPORARY(NANO_DIFF[N-STATUS:*]) ]
  IF STATUS GT 0 THEN  RATE_4WK      = [ TEMPORARY(   RATE_4WK  ), TEMPORARY( RATE4  ) ]
  IF STATUS GT 0 THEN  RATE_8WK      = [ TEMPORARY(   RATE_8WK  ), TEMPORARY( RATE8  ) ]
  IF STATUS GT 0 THEN  RATE12WK      = [ TEMPORARY(   RATE12WK  ), TEMPORARY( RATE12 ) ]
  IF STATUS GT 0 THEN  RATE24WK      = [ TEMPORARY(   RATE24WK  ), TEMPORARY( RATE24 ) ] ; Feb.7th,2020.
;
  IF STATUS GT 0 THEN  SAVE, FILE='MJ03F/NANOdiffRatesMJ03E-F.idl',  $
  NANO1DAY_MEAN, NANO1DAY_TIME, RATE_4WK, RATE_8WK, RATE12WK, RATE24WK
;
  PRINT, SYSTIME() + ' Finish running of RunUpdateNANOdiffE-Frates.pro.'
;
; End of RunUpdateNANOdiffE-Frates.pro
