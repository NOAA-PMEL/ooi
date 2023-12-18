;
; Function ISNUMBER
;
; Result = IS_NUMBER(inpnum)
;
; Result is true (1), if the string argument INPUT_STR
; contains a valid; number. It is false (0), otherwise.
;
; This function is provided by Doug Loucks, Technical Support Engineer
; from REsearch Systems Incorporated.  September 10, 1998.
;
; History:
; November 18, 2002  Modified so that it will recognize the negetive number.
;                    --Andy Lau.
;
FUNCTION IS_NUMBER, INPUT_STR
;
; Must have one argument.
;
  if (n_params() ne 1) then begin
    print, 'IS_NUMBER: String scalar argument expected.'
    return, 0
  endif
;
; Must have a string scalar argument.
;
  sz = size( INPUT_STR )
  if (not((sz[0] eq 0) and (sz[1] eq 7))) then begin
    print, 'IS_NUMBER: String scalar argument expected.'
    return, 0
  endif
;
; Trim any leading or trailing blanks.
;
  s = strcompress( strtrim( INPUT_STR, 2 ), /remove_all )
;
; Convert the string to a byte array.
;
  b = byte(s)
;
; Locate any ASCII characters '0' through '9' and any decimal points.
;
  b0    = byte( '0' )
  b9    = byte( '9' )
  bdot  = byte( '.' )
  minus = byte( '-' )
  dummy = where( (b ge b0[0]) and (b le b9[0]), count1 )
  dummy = where(  b eq bdot[0] , count2 )
  dummy = where(  b eq minus[0], count3 )
;
; The string must contain only ASCII characters '0' through '9' and
; no more than one decimal point. The way to verify this is simple:
; The sum of the two counts taken must be equal to the length of the
; string and the decimal point count must not be more than one.
;
; The minus sign must be at the beginning of the string.
;
; However, if INPUT_STR contains number in scientific notation
; such as "1.23e+5".  This function will return the value: 0.
;
  if ( ((count1 + count2 + count3) eq strlen(s)) and  $
        (count2 le 1) and (count3 le 1) ) then begin
    if  (count3 eq 1) then  begin
       if ( b[0] eq minus[0] ) then return, 1 else return, 0
    endif  else  begin
        return, 1
    endelse
  endif else begin
    return, 0
  endelse

END
