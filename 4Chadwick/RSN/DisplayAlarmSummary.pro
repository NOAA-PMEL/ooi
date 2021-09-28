;
; File: Display AlarmSummary.pro
;
; This IDL program will generate a graphic file that contains the
; Summary of Number of the Alarts have been issused and the Current
; the Average  Inflation Rates in cm/year.
;
; This program can only works at an UNIX operating system.
;
; The procedures in this program will be used by the
; PRO PROCESS_RSN_DATA_FILE in the file: ProcessRSNdata.pro
;
; This program also calls the routines in the files:
; Plot[LILY/NANO/TILTS]data.pro
;
; Programmer: T-K Andy Lau NOAA/PMEL/Acoustic Program HMSC Newport Oregon.
;
; Revised on March      2nd, 2018
; Created on November  24th, 2014
;

;
; This procedure will be display a message board using all 4 of RSN stations:
; MJ03[B, D, E & F].  After this procedure is working correctly, it will be
; renamed to DIPSLAY_ALARM_SUMMARY.
;
; Callers: Users
; Revised: March 2nd, 2018
;
PRO DISPLAY_ALARM_SUMMARY, DATA_DIRECTORY,  $  ; Input: Directory name.
             SHOW_SUMMARY=DISPLAY_SUMMARY,  $
           UPDATE_SUMMARY=   SAVE_SUMMARY
;
; Get the Current Directory Name
; and put to the DATA_DIRECTORY where the Alarm Summary file will be create.
;
  CD, CURRENT=CURRENT_DIR  ; Get the Current Directory name.
  CD, DATA_DIRECTORY       ; Get to the directory: ~/4Chadwick/RSN/  e.g.
;   
IF KEYWORD_SET( DISPLAY_SUMMARY ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 1 )  ; Yes.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
   PRINT, 'Plotting Window: ', !D.WINDOW
ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256, /PIXMAP
   PRINT, 'PIXMAP Window: ', !D.WINDOW
ENDELSE
;
; GET the informations of ALARM_STATUS, RATE & DATE to Display the Summary.
; where ALARM_STATUS will be 2-D (3 stations x 3 Alarm) arrays,
; RATE will be a 2-D (3 stations x 2 inflation Rates ) array and
; DATE will be in 'Year/Month/Day H:M:S'.
;
  GET_ALARM_INFO,  ALARM_STATUS, RATE, DATE
;
; The following 2 procedures are in the file IDLcolors.pro
; 
; SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
 !P.FONT = 0  ; Use the Hardware Fonts defined below.
  ERASE       ; Erase the window before plotting.
;
; Define the Hardware Fonts to be used.
;
; DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
; DEVICE, FONT='-adobe-helvetica-bold-r-normal--18-180-75-75-p-103-iso8859-1'
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--14-100-100-100-p-82-iso10646-1'
;
; Show the Date & Time.
;
; Y_OFFSET =  0  ; Before April 27th, 2015
  Y_OFFSET = 20  ; Since  April 27th, 2015 for No showing the 'Tsunami Event Alarm'.
  XYOUTS, /DEVICE,  30, 225-Y_OFFSET, 'Status as of: ' + DATE + ' GMT'
;
; Show the Labels for the 3 stations at the Top-Right side of the Display. 
;
; XYOUTS, /DEVICE, [400,500,600], [240,240,240], ['MJ03F','MJ03E','MJ03D']
; XYOUTS, /DEVICE, [400,500,600], [230,230,230], ['BOTPT1','BOTPT2','BOTPT3']
; XYOUTS, /DEVICE, [400,500,600], [220,220,220],  $
;         ['Caldera', 'Eastern', 'International']
; XYOUTS, /DEVICE, [400,500,600], [210,210,210],  $
;         ['Center',  'Caldera', 'District'     ]
;
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--14-140-75-75-p-82-iso8859-1'
  XYOUTS, /DEVICE, [320,440,560,685], [215,215,215,215], $
          ['MJ03F-BOTPT1','MJ03E-BOTPT2','MJ03D-BOTPT3','MJ03B-BOTPT4']
;
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
  XYOUTS, /DEVICE, [320,440,560,695], [200,200,200,200], $
          ['Caldera Center', 'Eastern Caldera', 'International District', 'Ashes Vent Field' ]
;
; XYOUTS, COLOR=C.YELLOW, /DEVICE, 690, 45, 'Rate are'
; XYOUTS, COLOR=C.YELLOW, /DEVICE, 690, 35, 'in cm/year'
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--14-140-75-75-p-82-iso8859-1'
  XYOUTS, COLOR=C.YELLOW, /DEVICE, 715, 10, 'cm/yr'
;
; Switch to the bigger  size of the characters.
;
; DEVICE, FONT='-adobe-helvetica-bold-r-normal--24-240-75-75-p-138-iso8859-1'
; DEVICE, FONT='-adobe-helvetica-bold-r-normal--20-140-100-100-p-105-iso8859-1'   ; B4 12/21/2020
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--20-140-100-100-p-105-iso10646-1'  ; 12/22/2020
;
; Show the Labels for Alarms and Rates at the Left-Had side of the Display. 
; Turn Off the 'Tsunami Event Alarm' Display for now.  April 27th, 2015.
;
; XYOUTS, COLOR=C.YELLOW, /DEVICE, 159-25, 170, 'Tsunami Event Alarm'
  XYOUTS, COLOR=C.YELLOW, /DEVICE,  67, 130+Y_OFFSET, 'Pre-Eruption Uplift Alarm'
  XYOUTS, COLOR=C.YELLOW, /DEVICE,  15,  90+Y_OFFSET, 'Co-Eruption Subsidence Alarm'
  XYOUTS, COLOR=C.YELLOW, /DEVICE,  19,  50+Y_OFFSET, ' 8-week Average Inflation Rate'
  XYOUTS, COLOR=C.YELLOW, /DEVICE,  15,  10+Y_OFFSET, '12-week Average Inflation Rate'
;
; The following 7 statements are the measuring (test) steps.
;
; XYOUTS, COLOR=C.GREEN , /DEVICE, [405,505,610], [170,170,170],  $
;                                  [ 'NO',  'NO',  'NO'  ]
; XYOUTS, COLOR=C.GREEN , /DEVICE, [405,505,610], [130,130,130],  $
;                                  [ 'NO',  'NO',  'NO'  ]
; XYOUTS, COLOR=C.RED,    /DEVICE, [405,505,610], [ 90, 90, 90],  $
;                                  [ 'YES', 'YES', 'YES' ]
;
; X = [405,505,610, 405,505,610, 405,505,610]
; Y = [170,170,170, 130,130,130,  90, 90, 90]
; S = ['NO','YES','NO', 'NO','NO','NO', 'NO','YES','YES' ]
; XYOUTS, COLOR=C.RED,    /DEVICE, X,Y,S
;
; Define the array: YN for stroing 'YES' and 'NO'
; and    the array: RG for indicating the colors: Red and Green.
;
  S  = SIZE( ALARM_STATUS, /DIMENSION )
  X  = S[0]  ; 1st Dimension
  Y  = S[1]  ; 2nd Dimension
  YN = REPLICATE(    'NO', X, Y )  ; Inital all values to 'NO'.
  RG = REPLICATE( C.GREEN, X, Y )  ; Inital all valaus to Green.
;
; Locate all the 1 or -1 positions in the ALARM_STATUS.
;
; I  = WHERE( ALARM_STATUS EQ 0, N, COMPLEMENT=J, NCOMPLEMENT=M )
  S  = WHERE( ALARM_STATUS EQ 1, X ) ; Look for 1's.
;
IF X GT 0 THEN  BEGIN  ; There are alerts issued.
   YN[S] = 'YES'  ; Alarm issued.
   RG[S] = C.RED  ; Use the color: Red.
ENDIF
;
  S = N_ELEMENTS( ALARM_STATUS )
; X = [405,505,610, 405,505,610, 405,505,610]
; X = [425,540,660, 425,540,660, 425,540,660]  ; Before April 27th 2015 for showing
; Y = [170,170,170, 130,130,130,  90, 90, 90]  ; Tsunami, Uplift & Subsidence
; XYOUTS, COLOR=RG[0:S-1], /DEVICE, X,Y, YN[0:S-1]
  X = [  350,480,600,720, 350,480,600,720]             ; Since  April 27th 2015 for
  Y = [  130,130,130,130,  90, 90, 90, 90] + Y_OFFSET  ; Not showing the Tsunami Alarm message.
  XYOUTS, COLOR=RG[4:S-1], /DEVICE, X,Y, YN[4:S-1]     ; [0:3] are for Tsunami message.
;
; Label the 8-week & 12-week average inflation rates
; (was  the 4-week &  8-week before September 17th, 2017)
; in Blue & Green respectively.
;
  XYOUTS, COLOR=C.CYAN,  /DEVICE, [350,480,600,720],[50,50,50,50]+Y_OFFSET,  $
  STRTRIM(STRING(FORMAT='(F7.1)',RATE[*,0],/PRINT),2)  ;  8-week Rate.
  XYOUTS, COLOR=C.GREEN, /DEVICE, [350,480,600,720],[10,10,10,10]+Y_OFFSET,  $
  STRTRIM(STRING(FORMAT='(F7.1)',RATE[*,1],/PRINT),2)  ; 12-week Rate.
;
; If SAVE_SUMMARY is set, Save the graph into an output file.
;
IF KEYWORD_SET( SAVE_SUMMARY ) THEN  BEGIN
   OUTPUT_FILE = DATA_DIRECTORY + 'AlarmSummary.png'
   WRITE_PNG, OUTPUT_FILE, TVRD( TRUE=1 )  ; Save the graph as a png file.
ENDIF
;
IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN
       MX = !D.WINDOW
   WDELETE, !D.WINDOW  ; Remove the PIXMAP window.
   PRINT, 'Removed PIXMAP Window: ', MX
   SET_PLOT, 'X'  ; Back to Window Plotting.
ENDIF
;
  CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; DISPLAY_ALARM_SUMMARY
;
; Callers: DISPLAY_ALARM_SUMMARY or Users.
; Revised: September 14th, 2017
;
PRO GET_ALARM_INFO,  ALARM_STATUS,  $ ; Output: 2-D array.
                             RATE,  $ ; Output: 2-Element array
                             DATE     ; Output: in 'Year/Month/Day H:M:S'
;
; ~/4Chadwick/RSN/MJ03D/LongTermNANOdataProducts.MJ03D
;
; Define an array for storing the Alarm Status from all 3 of the
; stations from: 'MJ03F', 'MJ03E' & 'MJ03D'.
;
; ALARM_STATUS = REPLICATE( 0B, 3, 3 )  ; 3 stations x 3 Alarms.  Before August 17th, 2017.
  ALARM_STATUS = REPLICATE( 0B, 4, 3 )  ; 3 stations x 3 Alarms.  After  August 17th, 2017.
;
; Use the ALERT_PERMISSION function (which is located in the file:
; CheckNANOdata4Alerts.pro to get the Alarm STATUS.
; When ALERT_PERMISSION() returns 1 will means an alert message can be sent.
; If -1 is returned, the Alart message has been sent at least > 7 day,
; so the -1 will be changed to 0.
; So  when ALERT_PERMISSION() returns 1 or -1, they should be set to 0
; and when ALERT_PERMISSION() returns 0, it should be set to 1.
;
  ALARM_STATUS[0,0] = ALERT_PERMISSION( 'MJ03F/TsunamiAlertStatus.MJ03F' )
  ALARM_STATUS[1,0] = ALERT_PERMISSION( 'MJ03E/TsunamiAlertStatus.MJ03E' )
  ALARM_STATUS[2,0] = ALERT_PERMISSION( 'MJ03D/TsunamiAlertStatus.MJ03D' )
  ALARM_STATUS[3,0] = ALERT_PERMISSION( 'MJ03B/TsunamiAlertStatus.MJ03B' )  ; from 8/17/2017 on.
;
  ALARM_STATUS[0,1] = ALERT_PERMISSION( 'MJ03F/UpLiftAlertStatus.MJ03F' )
  ALARM_STATUS[1,1] = ALERT_PERMISSION( 'MJ03E/UpLiftAlertStatus.MJ03E' )
  ALARM_STATUS[2,1] = ALERT_PERMISSION( 'MJ03D/UpLiftAlertStatus.MJ03D' )
  ALARM_STATUS[3,1] = ALERT_PERMISSION( 'MJ03B/UpLiftAlertStatus.MJ03B' )
;
  ALARM_STATUS[0,2] = ALERT_PERMISSION( 'MJ03F/SubsidenceAlertStatus.MJ03F' )
  ALARM_STATUS[1,2] = ALERT_PERMISSION( 'MJ03E/SubsidenceAlertStatus.MJ03E' )
  ALARM_STATUS[2,2] = ALERT_PERMISSION( 'MJ03D/SubsidenceAlertStatus.MJ03D' )
  ALARM_STATUS[3,2] = ALERT_PERMISSION( 'MJ03B/SubsidenceAlertStatus.MJ03B' )
;
; Switch the values in ALARM_STATUS from 0's to 1's and 1's to 0/
;
  I = WHERE( ALARM_STATUS EQ 0, N, COMPLEMENT=J, NCOMPLEMENT=M )
  IF N GT 0 THEN ALARM_STATUS[I] = BYTE( 1 )
  IF M GT 0 THEN ALARM_STATUS[J] = BYTE( 0 )
;
; Get the last date & time when all ALARM_STATUS & RATEs' data are computed.
; Note that the DATE will be returned as the JULDAY() value, see below.
;
; GET_STATUS_DATE, '~/4Chadwick/RSN/MJ03D/EventDetectionParameters.MJ03D', DATE
  GET_STATUS_DATE, '~/4Chadwick/RSN/MJ03B/EventDetectionParametersMJ03B.idl', I  ; from 8/17/2017 on.
  GET_STATUS_DATE, '~/4Chadwick/RSN/MJ03D/EventDetectionParametersMJ03D.idl', DATE
  GET_STATUS_DATE, '~/4Chadwick/RSN/MJ03E/EventDetectionParametersMJ03E.idl', RATE
  GET_STATUS_DATE, '~/4Chadwick/RSN/MJ03F/EventDetectionParametersMJ03F.idl', R
;
; DATE = MAX( [    DATE, RATE, R ] )  ; Get the Lastest Date.  Before August 17th, 2017.
  DATE = MAX( [ I, DATE, RATE, R ] )  ; Get the Lastest Date.  After  August 17th, 2017.
  R    = STRING( DATE, $              ; Convert the DATE into a string.
  FORMAT="(C(CYI,'/',CMOI2.2,'/',CDI2.2,X,CHI2.2,':',CMI2.2,':',CSI2.2))" )
  DATE = R  ; as '2015/01/27 11:37:38' for example.
;
; Define an array for storing the 4- & 8-week Average Inflation Rates.
;
; RATE = REPLICATE( 0.0D0, 2, 3 )  ; 2 Inflation Rates x 3 stations  Before August 17th, 2017.
  RATE = REPLICATE( 0.0D0, 2, 4 )  ; 2 Inflation Rates x 4 stations  After  August 17th, 2017.
;
  GET_INFLATION_RATE, 'MJ03F/LongTermNANOdataProducts.MJ03F', R
  RATE[0:1,0] = R   ; where R = 2-Elements arrays.
  GET_INFLATION_RATE, 'MJ03E/LongTermNANOdataProducts.MJ03E', R
  RATE[0:1,1] = R   ; and R[0] = 4-week Average Inflation Rate.
  GET_INFLATION_RATE, 'MJ03D/LongTermNANOdataProducts.MJ03D', R
  RATE[0:1,2] = R   ;     R[1] = 8-week Average Inflation Rate.
  GET_INFLATION_RATE, 'MJ03B/LongTermNANOdataProducts.MJ03B', R    ; Started on August 17th, 2017.
  RATE[0:1,3] = R   ;  Save the 4- & 8-week Average Inflation Rates.
;
;
; Change the RATE dimension's orientation into 3 stations x 2 Inflation Rates.
;
  RATE = TRANSPOSE( TEMPORARY( RATE ) )
;
RETURN
END  ; GET_ALARM_INFO
;
; This rouiine only works at a n UNIX operating system.
;
; Callers: GET_ALARM_INFO        or Users.
;
PRO GET_INFLATION_RATE, DATA_PRODUCT_FILE,  $ ;  Input: File name.
                        RATE                  ; Output: 2-Elements array.
;
;  DATA_PRODUCT_FILE = 'MJ03E/LongTermNANOdataProducts.MJ03E' for example
;
   RCD = FILE_SEARCH( DATA_PRODUCT_FILE, COUNT=N )
;
IF N LE 0 THEN  BEGIN  ; DATA_PRODUCT_FILE is not found!
   RATE = [-1,-1]  ; No data.
   PRINT, 'Cannot Find File: ' + DATA_PRODUCT_FILE
   PRINT, 'Rate values are set to -1.'
;  RETURN  ; to caller. 
ENDIF  ELSE  BEGIN
;
;  Use the UNIX command: tail to get the last line in the DATA_PRODUCT_FILE.
;
   RCD = 'for storing the last line in the DATA_PRODUCT_FILE'
   SPAWN, 'tail -1 ' + DATA_PRODUCT_FILE, RCD
;
;  where RCD will be = for example
;  '2014/11/23       1512.7498       49.384304       36.092448'
;
;  Get the individual columns' values in RCD into the array: R.
;
   R    = STRSPLIT( RCD, /EXTRACT, COUNT=N )
;
;  Save the Average Inflations Rates.
;           4-week Average   8-week Average Rates.
   RATE = [ FLOAT( R[N-2] ), FLOAT( R[N-1] ) ]
;
ENDELSE
;
RETURN
END  ; GET_INFLATION_RATE
;
; This rouiine only works at a n UNIX operating system.
;
; Callers: GET_ALARM_INFO        or Users.
; Revised: January 27th, 2015
;
PRO GET_STATUS_DATE, EVENT_STATUS_FILE,  $ ;  Input: File name.
                     DATE                  ; Output: in 'Year/Month/Day H:M:S'
;
; EVENT_STATUS_FILE = '~/4Chadwick/RSN/MJ03D/EventDetectionParameters.MJ03D'
; for example.  Used from November 2014 to January 23rd, 2015.
;
; EVENT_STATUS_FILE = '~/4Chadwick/RSN/MJ03D/EventDetectionParametersMJ03D.idl'
; for example.  from January 23rd, 2015 on.
;
  RCD = FILE_SEARCH( EVENT_STATUS_FILE, COUNT=M )
;
IF M LE 0 THEN  BEGIN  ; EVENT_STATUS_FILE is not found!
   DATE = 0
   PRINT, 'Cannot Find File: ' + EVENT_STATUS_FILE
   PRINT, 'DATE value is set to 0.'
   RETURN  ; to caller. 
ENDIF
;
; Use the UNIX command: tail to get the last line in the EVENT_STATUS_FILE.
; where EVENT_STATUS_FILE is a text file.
;
; RCD = 'for storing the last line in the EVENT_STATUS_FILE'
; SPAWN, 'tail -1 ' + EVENT_STATUS_FILE, RCD
;
; where RCD will be = '2014/11/24 18:35:15   0.38434496    2.0009281', e.g.
; and '2014/11/24 18:35:15' will be the last processed Date.
;
; Y  = 2014  ; Year
; M  =   12  ;  Month: 1-12
; D  =   31  ;    Day: 1-31
; HR =   23  ;   Hour: 00-23
; MN =   59  ; Minute: 00-59
; SD =   59  ; Second: 00-59
;
; READS, RCD, FORMAT='(I4,5(1X,I2))', Y,M,D, HR,MN,SD
;
; DATE = JULDAY( M,D,Y, HR,MN,SD )  ; Last processed Date.
;
; Get the Last processed Date from the beginning of the RCD.
;
; DATE = STRMID( RCD[0], 0, 19   )  ; = '2014/11/24 18:35:15' for example.
;
; Retrieve the DATA in the EVENT_STATUS_FILE, an IDL Save File
; where DATA[*,0] = JULDAY()'s
;
  RESTORE, EVENT_STATUS_FILE  ; to get a 2-D array: DATA.
;
              M = SIZE( DATA, /DIMENSION )
  DATE = DATA[M[0]-1,0]  ; Get the last date.
;
RETURN
END  ; GET_STATUS_DATE
;
; The following procedure was using between May 2015 and October 2017.
; It display the message board for the 3 of RSN stations: MJ03[D, E & F].
; On August 15th, 2017, a new station: MJ03B is added.  Therefore,
; the following procedure was renamed from DISPLAY_ALARM_SUMMARY to
; PLOT_ALARM_SUMMARY  and  it will not be used from March 2nd 2018 on
;
; Callers: Users
; Revised: September   17th, 2017
;
PRO    PLOT_ALARM_SUMMARY, DATA_DIRECTORY,  $  ; Input: Directory name.
             SHOW_SUMMARY=DISPLAY_SUMMARY,  $
           UPDATE_SUMMARY=   SAVE_SUMMARY
;
; Get the Current Directory Name
; and put to the DATA_DIRECTORY where the Alarm Summary file will be create.
;
  CD, CURRENT=CURRENT_DIR  ; Get the Current Directory name.
  CD, DATA_DIRECTORY       ; Get to the directory: ~/4Chadwick/RSN/  e.g.
;   
IF KEYWORD_SET( DISPLAY_SUMMARY ) THEN  BEGIN
   DISPLAY_PLOT2SCREEN = BYTE( 1 )  ; Yes.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256
   PRINT, 'Plotting Window: ', !D.WINDOW
ENDIF  ELSE  BEGIN  ; will plot the graph into a PIXMAP window.
   DISPLAY_PLOT2SCREEN = BYTE( 0 )  ; No.
   WINDOW, /FREE, RETAIN=2, XSIZE=800, YSIZE=256, /PIXMAP
   PRINT, 'PIXMAP Window: ', !D.WINDOW
ENDELSE
;
; GET the informations of ALARM_STATUS, RATE & DATE to Display the Summary.
; where ALARM_STATUS will be 2-D (3 stations x 3 Alarm) arrays,
; RATE will be a 2-D (3 stations x 2 inflation Rates ) array and
; DATE will be in 'Year/Month/Day H:M:S'.
;
  GET_ALARM_INFO,  ALARM_STATUS, RATE, DATE
;
; The following 2 procedures are in the file IDLcolors.pro
; 
; SET_BACKGROUND, /WHITE  ; Plotting background to White.
  RGB_COLORS,      C      ; Color name indexes, e.g. C.BLUE, C.GREEN, ... etc.
;
 !P.FONT = 0  ; Use the Hardware Fonts defined below.
  ERASE       ; Erase the window before plotting.
;
; Define the Hardware Fonts to be used.
;
; DEVICE, FONT='-adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1'
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--18-180-75-75-p-103-iso8859-1'
;
; Show the Date & Time.
;
; Y_OFFSET =  0  ; Before April 27th, 2015
  Y_OFFSET = 20  ; Since  April 27th, 2015 for No showing the 'Tsunami Event Alarm'.
  XYOUTS, /DEVICE,  50, 225-Y_OFFSET, 'Status as of: ' + DATE + ' GMT'
;
; Show the Labels for the 3 stations at the Top-Right side of the Display. 
;
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--14-140-75-75-p-82-iso8859-1'
;
; XYOUTS, /DEVICE, [400,500,600], [240,240,240], ['MJ03F','MJ03E','MJ03D']
; XYOUTS, /DEVICE, [400,500,600], [230,230,230], ['BOTPT1','BOTPT2','BOTPT3']
; XYOUTS, /DEVICE, [400,500,600], [220,220,220],  $
;         ['Caldera', 'Eastern', 'International']
; XYOUTS, /DEVICE, [400,500,600], [210,210,210],  $
;         ['Center',  'Caldera', 'District'     ]
;
  XYOUTS, /DEVICE, [400,520,640], [230,230,230], $
          ['MJ03F-BOTPT1','MJ03E-BOTPT2','MJ03D-BOTPT3']
  XYOUTS, /DEVICE, [400,520,640], [210,210,210], $
          ['Caldera Center', 'Eastern Caldera', 'International District' ]
;
; XYOUTS, COLOR=C.YELLOW, /DEVICE, 690, 45, 'Rate are'
; XYOUTS, COLOR=C.YELLOW, /DEVICE, 690, 35, 'in cm/year'
  XYOUTS, COLOR=C.YELLOW, /DEVICE, 730, 40+Y_OFFSET, 'cm/yr'
;
; Switch to the bigger  size of the characters.
;
  DEVICE, FONT='-adobe-helvetica-bold-r-normal--24-240-75-75-p-138-iso8859-1'
;
; Show the Labels for Alarms and Rates at the Left-Had side of the Display. 
; Turn Off the 'Tsunami Event Alarm' Display for now.  April 27th, 2015.
;
; XYOUTS, COLOR=C.YELLOW, /DEVICE, 159-25, 170, 'Tsunami Event Alarm'
  XYOUTS, COLOR=C.YELLOW, /DEVICE, 109-25, 130+Y_OFFSET, 'Pre-Eruption Uplift Alarm'
  XYOUTS, COLOR=C.YELLOW, /DEVICE,  25,  90+Y_OFFSET, 'Co-Eruption Subsidence Alarm'
  XYOUTS, COLOR=C.YELLOW, /DEVICE,  25,  50+Y_OFFSET, '4-week Average Inflation Rate'
  XYOUTS, COLOR=C.YELLOW, /DEVICE,  25,  10+Y_OFFSET, '8-week Average Inflation Rate'
;
; The following 7 statements are the measuring (test) steps.
;
; XYOUTS, COLOR=C.GREEN , /DEVICE, [405,505,610], [170,170,170],  $
;                                  [ 'NO',  'NO',  'NO'  ]
; XYOUTS, COLOR=C.GREEN , /DEVICE, [405,505,610], [130,130,130],  $
;                                  [ 'NO',  'NO',  'NO'  ]
; XYOUTS, COLOR=C.RED,    /DEVICE, [405,505,610], [ 90, 90, 90],  $
;                                  [ 'YES', 'YES', 'YES' ]
;
; X = [405,505,610, 405,505,610, 405,505,610]
; Y = [170,170,170, 130,130,130,  90, 90, 90]
; S = ['NO','YES','NO', 'NO','NO','NO', 'NO','YES','YES' ]
; XYOUTS, COLOR=C.RED,    /DEVICE, X,Y,S
;
; Define the array: YN for stroing 'YES' and 'NO'
; and    the array: RG for indicating the colors: Red and Green.
;
  S  = SIZE( ALARM_STATUS, /DIMENSION )
  X  = S[0]  ; 1st Dimension
  Y  = S[1]  ; 2nd Dimension
  YN = REPLICATE(    'NO', X, Y )  ; Inital all values to 'NO'.
  RG = REPLICATE( C.GREEN, X, Y )  ; Inital all valaus to Green.
;
; Locate all the 1 or -1 positions in the ALARM_STATUS.
;
; I  = WHERE( ALARM_STATUS EQ 0, N, COMPLEMENT=J, NCOMPLEMENT=M )
  S  = WHERE( ALARM_STATUS EQ 1, X ) ; Look for 1's.
;
IF X GT 0 THEN  BEGIN  ; There are alerts issued.
   YN[S] = 'YES'  ; Alarm issued.
   RG[S] = C.RED  ; Use the color: Red.
ENDIF
;
  S = N_ELEMENTS( ALARM_STATUS )
; X = [405,505,610, 405,505,610, 405,505,610]
; X = [425,540,660, 425,540,660, 425,540,660]  ; Before April 27th 2015 for showing
; Y = [170,170,170, 130,130,130,  90, 90, 90]  ; Tsunami, Uplift & Subsidence
; XYOUTS, COLOR=RG[0:S-1], /DEVICE, X,Y, YN[0:S-1]
  X = [  425,540,660, 425,540,660]             ; Since  April 27th 2015 for
  Y = [  130,130,130,  90, 90, 90] + Y_OFFSET  ; Not showing the Tsunami Alarm message.
;
; The following statement works only if ALARM_STATUS is a 3x3 array.
;
; XYOUTS, COLOR=RG[3:S-1], /DEVICE, X,Y, YN[3:S-1]  ; [0:2] are for Tsunami message.
;
; Assumming ALARM_STATUS is a 4x3  array, then the ALARM_STATUS[3,0:2] will not be shown.
;
  XYOUTS, COLOR=RG[1:2,0:2], /DEVICE, X,Y, YN[1:2,0:2]  ; [0,0:2] are for Tsunami message.
;
; Label the 4-week & 8-week average inflation rates
; in Blue & Green respectively.
;
  XYOUTS, COLOR=C.BLUE,  /DEVICE, [425,545,660],[50,50,50]+Y_OFFSET,  $
  STRTRIM(STRING(FORMAT='(F7.1)',RATE[*,0],/PRINT),2)  ; 4-week Rate.
  XYOUTS, COLOR=C.GREEN, /DEVICE, [425,545,660],[10,10,10]+Y_OFFSET,  $
  STRTRIM(STRING(FORMAT='(F7.1)',RATE[*,1],/PRINT),2)  ; 8-week Rate.
;
; If SAVE_SUMMARY is set, Save the graph into an output file.
;
IF KEYWORD_SET( SAVE_SUMMARY ) THEN  BEGIN
   OUTPUT_FILE = DATA_DIRECTORY + 'AlarmSummary.png'
   WRITE_PNG, OUTPUT_FILE, TVRD( TRUE=1 )  ; Save the graph as a png file.
ENDIF
;
IF NOT DISPLAY_PLOT2SCREEN THEN  BEGIN
       MX = !D.WINDOW
   WDELETE, !D.WINDOW  ; Remove the PIXMAP window.
   PRINT, 'Removed PIXMAP Window: ', MX
   SET_PLOT, 'X'  ; Back to Window Plotting.
ENDIF
;
  CD, CURRENT_DIR  ; Move the directory back to where it came from.
;
RETURN
END  ; DISPLAY_ALARM_SUMMARY
