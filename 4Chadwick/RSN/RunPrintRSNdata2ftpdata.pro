;
; This is a setup file: RunPrintRSNdata2ftpdata.pro
; to print and Append the New data range of the contents in the
; IDL Save files: MJ03[B/D/E/F]-[LILY/NANO].idl
; or          3DayMJ03[B/D/E/F]-[LILY/NANO].idl
; into the test files: MJ03[B/D/E/F]Year[LILY/NANO].Data
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: July       8th, 2019 ; to be run at Garfield.
;
;
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
.RUN ~/4Chadwick/RSN/PrintRSNdata2Files.pro
;
  CD, '~/4Chadwick/RSN/'
;
  PRINT, SYSTIME() + ' Running UPDATE_LILY_FILE...'
  UPDATE_LILY_FILE, 'MJ03B/MJ03B-LILY.idl',          $   ; Saved LILY data file. 
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03BinfoFile.LILY'  ; Info File.
  PRINT, SYSTIME() + ' Running UPDATE_NANO_FILE...'
  UPDATE_NANO_FILE, 'MJ03B/MJ03B-NANO.idl',          $   ; Saved NANO data file. 
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03BinfoFile.NANO'  ; Info File.
;
  PRINT, SYSTIME() + ' Running UPDATE_LILY_FILE...'
  UPDATE_LILY_FILE, 'MJ03D/MJ03D-LILY.idl',          $   ; Saved LILY data file. 
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03DinfoFile.LILY'  ; Info File.
  PRINT, SYSTIME() + ' Running UPDATE_NANO_FILE...'
  UPDATE_NANO_FILE, 'MJ03D/MJ03D-NANO.idl',          $   ; Saved NANO data file. 
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03DinfoFile.NANO'  ; Info File.
;
  PRINT, SYSTIME() + ' Running UPDATE_LILY_FILE...'
  UPDATE_LILY_FILE, 'MJ03E/MJ03E-LILY.idl',          $   ; Saved LILY data file. 
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03EinfoFile.LILY'  ; Info File.
  PRINT, SYSTIME() + ' Running UPDATE_NANO_FILE...'
  UPDATE_NANO_FILE, 'MJ03E/MJ03E-NANO.idl',          $   ; Saved NANO data file. 
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03EinfoFile.NANO'  ; Info File.
;
  PRINT, SYSTIME() + ' Running UPDATE_LILY_FILE...'
  UPDATE_LILY_FILE, 'MJ03F/MJ03F-LILY.idl',          $   ; Saved LILY data file. 
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03FinfoFile.LILY'  ; Info File.
  PRINT, SYSTIME() + ' Running UPDATE_NANO_FILE...'
  UPDATE_NANO_FILE, 'MJ03F/MJ03F-NANO.idl',          $   ; Saved NANO data file. 
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03FinfoFile.NANO'  ; Info File.
;
  PRINT, SYSTIME() + ' Running UPDATE_DIFF_FILE...'
  UPDATE_DIFF_FILE, 'MJ03F/NANOdifferencesMJ03E-F.idl', $  ; Saved NANO Difference data file.
 '/data/lau/4Chadwick/RSN/LastUpatedMJ03E-FinfoFile.Diff'  ; Info File.
;
; The following steps were used to establish the 1st *.Data file to start
; and then the info files need to be created, see (*) for example.
;
; PRINT_NANO_DATA2FILE, 'MJ03B/MJ03B-NANO.idl',  $
;'/ftpdata/pub/lau/RSN/MJ03B17Aug-31Dec2017NANO.Data',      $
; JULDAY( 1, 1,2017, 0,00,00 ), JULDAY(12,25,2017, 12,59,59 )  ;
; PRINT_LILY_DATA2FILE, 'MJ03B/MJ03B-LILY.idl',  $
;'/ftpdata/pub/lau/RSN/MJ03B2017LILY.Data',      $  ; (*)
; JULDAY( 1, 1,2017, 0,00,00 ), JULDAY(12,25,2017, 12,59,59 )  ;
;
; (*) Then create a info file: LastUpatedMJ03BinfoFile.NANO
;     and it will contain 2 lines:
;     MJ03B2017LILY.Data
;     Thu Dec 25 12:59:59 2014  <-- The last record Date & Time in the file above.
; where the Date & Time can be printed out
; by the IDL code: PRINT,FORMAT='(C())', JULDAY(12,25,2014,12,59,59)
;
; PRINT_NANO_DATA2FILE, 'MJ03D/MJ03D-NANO.idl', $
;'/data/lau/4Chadwick/RSN/MJ03D2014NANO.Data',  $
; JULDAY( 1, 1,2014, 0,00,00 ), JULDAY(12,25,2014, 12,59,59 )  ;
; PRINT_LILY_DATA2FILE, 'MJ03D/MJ03D-LILY.idl',  $
;'/data/lau/4Chadwick/RSN/MJ03D2014LILY.Data',   $
; JULDAY( 1, 1,2014, 0,00,00 ), JULDAY(12,25,2014, 12,59,59 )  ;
;
; PRINT_NANO_DATA2FILE, 'MJ03E/MJ03E-NANO.idl', $
;'/data/lau/4Chadwick/RSN/MJ03E2014NANO.Data',  $
; JULDAY( 1, 1,2014, 0,00,00 ), JULDAY(12,25,2014, 12,59,59 )  ; 5/15/2018
; PRINT_LILY_DATA2FILE, 'MJ03E/MJ03E-LILY.idl',  $
;'/data/lau/4Chadwick/RSN/MJ03E2014LILY.Data',   $
; JULDAY( 1, 1,2014, 0,00,00 ), JULDAY(12,25,2014, 12,59,59 )  ; 5/15/2018
;
; PRINT_NANO_DATA2FILE, 'MJ03F/MJ03F-NANO.idl', $
;'/data/lau/4Chadwick/RSN/MJ03F2014NANO.Data',  $
; JULDAY( 1, 1,2014, 0,00,00 ), JULDAY(12,25,2014, 12,59,59 )  ; 5/15/2018
; PRINT_LILY_DATA2FILE, 'MJ03F/MJ03F-LILY.idl',  $
;'/data/lau/4Chadwick/RSN/MJ03F2014LILY.Data',   $
; JULDAY( 1, 1,2014, 0,00,00 ), JULDAY(12,25,2014, 12,59,59 )  ; 5/15/2018
;
; EXIT ; RunPrintRSNdata2ftpdata.pro
