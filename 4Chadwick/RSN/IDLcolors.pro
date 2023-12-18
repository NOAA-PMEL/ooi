;
; File: IDLcolors.pro renamed from Set256Colors.pro
; will allow users to define the most used Color Indexes
; under the 24-BIT RGB color system.
; Or
; Using the procedure SET256COLORS to set the IDL Colors
; from 24-Bit True Colors into simulated 8-BIT Color Environment.
;
; Programmer: T-K Andy Lau  NOAA/PMEL/OERD HMSC Newport, Oregon 97365.
;    Revised: February 17, 2011
;    Created: February 15, 2010
;

;
; This procedure will be called by the IDL XLOADCT procedure using
; its UPDATECALLBACK Keyword.  So that the colors of displayed image
; at the current drawing window will be updated as the colors are
; being adjusted through the XLOADCT.
;
; Tested on April 20, 2010  But it is NOt working right!
;
PRO REFRESH_WINDOW, DATA=IMAGE
;
    IMAGE = TVRD()  ; Read the whole image from the currect drawing window.
TV, IMAGE   ; Plot the IMAGE again.
;
RETURN
END  ; REFRESH_WINDOW
;
; The colors indexes' settings in this procedure are based on
; the book: Dynamice HTML, The Definitive Reference by Danny Goodman
; in the Appendix A: Color names and RGB values, pages 1013 to 1017.
;
; Callers: Users.
;
PRO RGB_COLORS,  RGB  ; Output: Structure.
;
; Create a structure variable to contain the color indexes
; refered by the tag names.
;
RGB = { BLACK   : '000000'XL, WHITE : 'FFFFFF'XL, $
        RED     : '0000FF'XL, GREEN : '008000'XL, BLUE   : 'FF0000'XL,  $
        MAGENTA : 'FF00FF'XL, CYAN  : 'FFFF00'XL, YELLOW : '00FFFF'XL,  $
; From here on all the color names are in alphabetical order.
        BROWN   : '2A2AA5'XL,  $
       DARKBLUE : '8B0000'XL, DARKGRAY   : 'A9A9A9'XL,  $
       DARKGREEN: '006400'XL,  $
       DARKRED  : '00008B'XL,  $
        GOLD    : '00D7FF'XL, GOLDENROD  : '20A5DA'XL,  $
        GRAY    : '808080'XL, GREENYELLOW: '2FFFAD'XL,  $
        HOTPINK : 'B469FF'XL,  $
      LIGHT_BLUE: 'E6D8AD'XL, LIGHT_CYAN : 'FFFFE0'XL,  $
     NAVAJOWHITE: 'ADDEFF'XL, NAVY       : '080000'xl,  $
        ORANGE  : '00A5FF'XL, ORANGERED  : '0045FF'xl,  $
        PINK    : 'CB00FF'XL, PURPLE     : '800080'XL,  $
        VIOLET  : 'EE82EE'XL, WHEAT      : 'B3DEF5'XL,  $
     YELLOWGREEN: '32CD9A'XL   }
;
RETURN
END  ; RGB_COLORS
;
; Callers: Users.
;
PRO SET_BACKGROUND, WHITE=WHITE_BACKGROUND,  $
                    BLACK=BLACK_BACKGROUND
;
IF !D.WINDOW GE 0 THEN  BEGIN    ; A window has been open.
   PIXMAP_WINDOW_ON = BYTE( 0 )  ; No.
ENDIF  ELSE  BEGIN  ; No window has been open.
;  Create a small WINDOW so that !P.COLOR will retain the setting.
   WINDOW, /FREE, /PIXMAP, XSIZE=10, YSIZE=10
   PIXMAP_WINDOW_ON = BYTE( 1 )  ; Yes.
ENDELSE
;
IF KEYWORD_SET( WHITE_BACKGROUND ) THEN  BEGIN
   !P.BACKGROUND = 'FFFFFF'XL  ; WHITE
   !P.COLOR      = '000000'XL  ; BLACK  ; for plotting.
ENDIF ELSE IF KEYWORD_SET( BLACK_BACKGROUND ) THEN  BEGIN
   !P.BACKGROUND = '000000'XL  ; BLACK
   !P.COLOR      = 'FFFFFF'XL  ; WHITE  ; for plotting.
ENDIF
;
IF PIXMAP_WINDOW_ON THEN  BEGIN
   WDELETE, !D.WINDOW  ; Remove the PIXMAP window.
ENDIF
;
RETURN
END  ; SET_BACKGROUND
;
; This procedure should not be used any more!
; Users should use the SET_BACKGROUND and RGB routines instead.
;
; Callers: Users.
; Revised: February 15, 2010
;
PRO SET256COLORS,  COLOR_TBL_NUMBER,  $ ; Input: Number uses in LOADCT
              REVERSE=REVERSE_COLOR,  $ ; Input: e.g. from B&W to W&B.
           TOTAL_COLORS2BE=N_COLORS     ; Input: e.g. 256 (Default).
;
;
N = N_PARAMS()
;
IF N EQ 0 THEN  BEGIN     ; No Parameters provide
   COLOR_TBL_NUMBER = 5
   PRINT, 'Color Table: ' + STRTRIM( COLOR_TBL_NUMBER, 2 )  $
        + ' = STD GAMMA-II is used.'
ENDIF
;
IF NOT KEYWORD_SET( N_COLORS ) THEN  BEGIN
   N_COLORS = 256
ENDIF
;
; Set the IDL to deactive the 24-Bit Colors.
;
DEVICE,  DECOMPOSE=0   ; Must call this is 1st.
DEVICE, /PSEUDO_COLOR  ; Then this one 2nd.
DEVICE,  RETAIN=2      ; for all the IDL Graphic Windows.
;
LOADCT, COLOR_TBL_NUMBER  ; Load the Color Table.
;
 TVLCT, R, G, B, /GET  ; Get Color Table's index arrays.
;
; Resample the color arrays into 256-element arrays
;
R = CONGRID( TEMPORARY( R ), N_COLORS, /INTERP )
G = CONGRID( TEMPORARY( G ), N_COLORS, /INTERP )
B = CONGRID( TEMPORARY( B ), N_COLORS, /INTERP )
;
IF KEYWORD_SET( REVERSE_COLOR ) THEN  BEGIN
   S = N_COLORS - 1 - INDGEN( N_COLORS )  ; e.g. S = [255,254,...,1,0]
   R = R[S]
   G = G[S]
   B = B[S]
ENDIF
;
TVLCT, R, G, B  ; Load the modified Color Table.
;
RETURN
END  ; SET256COLORS
