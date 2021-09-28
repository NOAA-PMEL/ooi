;
; File: RunSaveCTDdata.pro
;
; This IDL file will process the CTD data: {Density, Salinity & Temperature}
; collected on the seafloor at Axial Seamount.  This file will be run every ~15 minutes.
;
; Revised: September 2nd, 2021 - by Bill Chadwick to include CTD @ MJ03F
; Revised: August    3rd, 2020 - by Andy Lau to include CTD @ MJ03E
; Created: November 13th, 2018 - by Andy Lau for 1st seafloor CTD @ MJ03B
;
 .RUN ~/4Chadwick/RSN/SplitRSNdata.pro
 .RUN ~/4Chadwick/RSN/ProcessCTDdata.pro
;
  PRINT, SYSTIME() + ' Start running of RunSaveCTDdata.pro for the CTD data at the MJ03B...'
;
; Retrieve the CTD data Array variables: CDT_TIME, DENSITY, SALINITY & CTD_TEMP
; from the 7 Days Save file: ~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl
; All the Array variables are assumed to be the same size.
;
  RESTORE, '~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl'  ; Get CDT_TIME, CTD_TEMP, etc.
;
; Use the following procedure to save the data from the 7 Days Save file
; into the "All" CTD data file: ~/4Chadwick/RSN/MJ03B/CTD-MJ03B.idl
;
  STATUS = 'Not OK'  ; Set No Update for the SAVE_CTD_DATA to begin.
  SAVE_CTD_DATA,  CTD_TIME, DENSITY, SALINITY, CTD_TEMP,  $ ; append these data into
                 '~/4Chadwick/RSN/MJ03B/CTD-MJ03B.idl' ,  $ ; <-- this file.
                  STATUS  ; Output: "OK" = Data Saved or "Not OK" = No Update.
;
; Use the following procedure to Shorten the data stored in the
; 7 Days Save file: ~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl
; if their new data have been saved into the "All" CTD data file above.
;
  IF STATUS EQ "OK" THEN  RESET_SHORT_TERM_CTD_SAVE_FILE,  $
               '~/4Chadwick/RSN/MJ03B/CTD7DaysMJ03B.idl',  $ ; Input: File name.
                       6    ; Input: Last of Number of days of data to be saved.
;
; The following are added for including the 2nd CTD @ MJ03E in Summer 2020.
;
  PRINT, SYSTIME() + ' Start running of RunSaveCTDdata.pro for the CTD data at the MJ03E...'
;
; Retrieve the CTD data Array variables: CDT_TIME, DENSITY, SALINITY & CTD_TEMP
; from the 7 Days Save file: ~/4Chadwick/RSN/MJ03E/CTD7DaysMJ03E.idl
; All the Array variables are assumed to be the same size.
;
  RESTORE, '~/4Chadwick/RSN/MJ03E/CTD7DaysMJ03E.idl'  ; Get CDT_TIME, CTD_TEMP, etc.
;
; Use the following procedure to save the data from the 7 Days Save file
; into the "All" CTD data file: ~/4Chadwick/RSN/MJ03E/CTD-MJ03E.idl
;
  STATUS = 'Not OK'  ; Set No Update for the SAVE_CTD_DATA to begin.
  SAVE_CTD_DATA,  CTD_TIME, DENSITY, SALINITY, CTD_TEMP,  $ ; append these data into
                 '~/4Chadwick/RSN/MJ03E/CTD-MJ03E.idl' ,  $ ; <-- this file.
                  STATUS  ; Output: "OK" = Data Saved or "Not OK" = No Update.
;
; Use the following procedure to Shorten the data stored in the
; 7 Days Save file: ~/4Chadwick/RSN/MJ03E/CTD7DaysMJ03E.idl
; if their new data have been saved into the "All" CTD data file above.
;
  IF STATUS EQ "OK" THEN  RESET_SHORT_TERM_CTD_SAVE_FILE,  $
               '~/4Chadwick/RSN/MJ03E/CTD7DaysMJ03E.idl',  $ ; Input: File name.
                       6    ; Input: Last of Number of days of data to be saved.
;
;
; The following are added for including the 3rd CTD @ MJ03F in Summer 2021.
;
  PRINT, SYSTIME() + ' Start running of RunSaveCTDdata.pro for the CTD data at the MJ03F...'
;
; Retrieve the CTD data Array variables: CDT_TIME, DENSITY, SALINITY & CTD_TEMP
; from the 7 Days Save file: ~/4Chadwick/RSN/MJ03F/CTD7DaysMJ03F.idl
; All the Array variables are assumed to be the same size.
;
  RESTORE, '~/4Chadwick/RSN/MJ03F/CTD7DaysMJ03F.idl'  ; Get CDT_TIME, CTD_TEMP, etc.
;
; Use the following procedure to save the data from the 7 Days Save file
; into the "All" CTD data file: ~/4Chadwick/RSN/MJ03F/CTD-MJ03F.idl
;
  STATUS = 'Not OK'  ; Set No Update for the SAVE_CTD_DATA to begin.
  SAVE_CTD_DATA,  CTD_TIME, DENSITY, SALINITY, CTD_TEMP,  $ ; append these data into
                 '~/4Chadwick/RSN/MJ03F/CTD-MJ03F.idl' ,  $ ; <-- this file.
                  STATUS  ; Output: "OK" = Data Saved or "Not OK" = No Update.
;
; Use the following procedure to Shorten the data stored in the
; 7 Days Save file: ~/4Chadwick/RSN/MJ03F/CTD7DaysMJ03F.idl
; if their new data have been saved into the "All" CTD data file above.
;
  IF STATUS EQ "OK" THEN  RESET_SHORT_TERM_CTD_SAVE_FILE,  $
               '~/4Chadwick/RSN/MJ03F/CTD7DaysMJ03F.idl',  $ ; Input: File name.
                       6    ; Input: Last of Number of days of data to be saved.
;
; End of File: RunSaveCTDdata.pro
