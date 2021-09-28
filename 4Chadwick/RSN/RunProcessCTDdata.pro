;
; File: RunProcessCTDdata.pro
;
; This IDL file will process the CTD data: {Density, Salinity & Temperature}
; collected near the station: MJ03B.  This file will be run at every ~15 minutes.
;
; Revised: August   22nd, 2020
; Created: November 13th, 2018
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
 .RUN ~/4Chadwick/RSN/ProcessCTDdata.pro
;
  PRINT, SYSTIME() + ' Start running of RunProcessCTDdata.pro...'
;
  PRINT, SYSTIME() + ' Processing the CTD data from the MJ03B station...'
;
; Run the following procedure to retrieve the new CTD data from the
; directory: /data/chadwick/4andy/ooiapi/  and
; compute the 1-minute averages,
; then Save them into the IDL Save File: ~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl
;
; PROCESS_CTD_FILES, '/data/chadwick/4andy/ooiapi/mj03b/',  $ ; Old direcotry 8/22/2020.
  PROCESS_CTD_FILES, '/data/ooi/api/mj03b/',   $ ; CTD data files directory.
  '~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl'      ; <-- Store the new CTD data.
;
;
  PRINT, SYSTIME() + ' Processing the CTD data from the MJ03E station...'
;
; Start on August 31st, 2020
;
; Run the following procedure to retrieve the new CTD data from the
; directory: /data/ooi/api/mj03e/ and compute the 1-minute averages,
; then Save them into the IDL Save File: ~/4Chadwick/RSN/MJ03E/CTD7DaysMJ03E.idl
;
  PROCESS_CTD_FILES, '/data/ooi/api/mj03e/',  $ ; CTD data files directory.
  '~/4Chadwick/RSN/MJ03E/CTD7DaysMJ03E.idl'     ; <-- Store the new CTD data.
;
;
  PRINT, SYSTIME() + ' Processing the CTD data from the MJ03F station...'
;
; Run the following procedure to retrieve the new CTD data from the
; directory: /data/ooi/api/mj03f/ and compute the 1-minute averages,
; then Save them into the IDL Save File: ~/4Chadwick/RSN/MJ03F/CTD7DaysMJ03F.idl
;
  PROCESS_CTD_FILES, '/data/ooi/api/mj03f/',  $ ; CTD data files directory.
  '~/4Chadwick/RSN/MJ03F/CTD7DaysMJ03F.idl'     ; <-- Store the new CTD data.
;
; See also the file: RunSaveCTDdata.pro
;
; End of File: RunProcessCTDdata.pro
