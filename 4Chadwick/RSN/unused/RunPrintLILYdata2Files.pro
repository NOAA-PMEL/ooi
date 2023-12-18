;
; This is a setup file: RunPrintRSNdata2Files.pro
; to print the specified data range of the contents in the
; IDL Save files: MJ03[D/E/F]-[HEAT/IRIS/LILY/NANO].idl
; and         3DayMJ03[D/E/F]-[HEAT/IRIS/LILY/NANO].idl
;
; Programmer: T-K Andy Lau  NOAA/PMEL/Acoustic Group  HMSC  Newport, Oregon.
;    Revised: May      25th, 2017 ; to be run at Garfield.
;
;
.RUN ~/4Chadwick/RSN/SplitRSNdata.pro
.RUN ~/4Chadwick/RSN/GetLongTermNANOdataProducts.pro
.RUN ~/4Chadwick/RSN/PrintRSNdata2Files.pro
;
  CD, '~/4Chadwick/RSN/'
;
  PRINT_LILY_DATA2FILE, 'MJ03D/MJ03D-LILY.idl','/data/lau/4Chadwick/RSN/MJ03D-Lily.Data'
  PRINT_LILY_DATA2FILE, 'MJ03E/MJ03E-LILY.idl','/data/lau/4Chadwick/RSN/MJ03E-Lily.Data'
  PRINT_LILY_DATA2FILE, 'MJ03F/MJ03F-LILY.idl','/data/lau/4Chadwick/RSN/MJ03F-Lily.Data'
;
; Use the following line to print out the specified data range in the
; MJ03?/MJ03?-LILY.idl save file.
; PRINT_LILY_DATA2FILE, 'MJ03D/MJ03D-LILY.idl','/data/lau/4Chadwick/RSN/MJ03D-Lily.Data'
;
; Note that the MJ03?/MJ03?-LILY.idl contain large amount of data.  It will take at
; least 22 minutes to print out 2.5 years of data. Therefore, do this by submitting
; as bath to be run overnight is recommended.
;
; Note that in all the cases above, after the IDL save file name is the
; Output file names, e.g. '30April2015MJ03D-NANO.Data'.
;
; EXIT
