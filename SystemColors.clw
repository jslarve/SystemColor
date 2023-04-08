!This program demonstrates how the system color equates are different than the standard color equates.
!----Observations:
!     1. Clarion can only natively handle RGB colors (no transparency)
!     2. What would normally be the "alpha" byte is used for a different purpose.
!     3. If the bit 080000000h is "on", then the color is considered to be a System color.
!     4. System colors don't specify RGB, they only have an index from which to retrieve the RGB via GetSysColor()
!        https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getsyscolor
!     5. NOTE: The colors that appear are only for the currently running system. The colors can be different, depending on systems settings.

  PROGRAM

  MAP
   AddColor(LONG pColorIndex) ! Adds a record to the ColorQ based on the color index
   GetSystemColor(LONG pIndexColor),LONG ! Returns RGB of system color on currently running machine.
   GetSystemColorName(LONG pColor),STRING
   HEX(LONG pLong,LONG pLen=6),STRING
   MODULE('')
     GetSysColor(LONG pIndex),LONG,PASCAL
     ULtoA(ULONG,*CSTRING,SIGNED),ULONG,RAW,NAME('_ultoa'),PROC
   END
  END

ColorQ     QUEUE
ColorName    CSTRING(31)
SysColor     CSTRING(21)
RGBColor     CSTRING(21)
SysValue     LONG
RGBValue     LONG
           END

Window WINDOW('System Colors'),AT(,,395,224),CENTER,GRAY,FONT('Segoe UI',9)
    LIST,AT(6,4,233,211),USE(?ColorList),VSCROLL,FONT('Consolas'),FROM(ColorQ), |
        FORMAT('126L(2)|M~Color Name~C(2)55L(2)|M~System Hex~C(2)63L(2)|M~RGB He' & |
        'x~C(2)')
    PANEL,AT(244,15,149,78),USE(?SystemPanel),BEVEL(1)
    STRING('Using System Color'),AT(244,4),USE(?STRING1)
    STRING('Using RGB Color'),AT(244,97,59,10),USE(?STRING1:2)
    PANEL,AT(244,108,149,78),USE(?RGBPanel),BEVEL(1)
    PROMPT('Although the above panels appear to have the same color, one is usin' & |
        'g RGB and the other is using a system color value.'),AT(251,190,127,26), |
        USE(?PROMPT1)
  END

Ndx LONG

  CODE
  
  LOOP Ndx = 0 TO 01Dh  !Looping through the indexes as shown in EQUATES.CLW. COLOR:MenuHighlight is 01Dh 
    AddColor(Ndx)
  END
  
  OPEN(Window)
  ACCEPT
    CASE EVENT()
    OF EVENT:NewSelection
      CASE FIELD()
      OF ?ColorList
        GET(ColorQ,CHOICE(?ColorList))
        IF NOT ERRORCODE()
          ?RGBPanel{PROP:Fill} = ColorQ.RGBValue
          ?SystemPanel{PROP:Fill} = ColorQ.SysValue
        END
      END
    OF EVENT:OpenWindow
      SELECT(?ColorList,1)
      POST(EVENT:NewSelection,?ColorList)     
    END  
  END
  
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddColor            PROCEDURE(LONG pColorNdx)
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  ColorQ.SysValue = BOR(080000000h,pColorNdx)
  ColorQ.SysColor = HEX(ColorQ.SysValue,8)
  ColorQ.ColorName = GetSystemColorName(ColorQ.SysValue)
  ColorQ.RGBValue = GetSysColor(pColorNdx)
  ColorQ.RGBColor = HEX(COlorQ.RGBValue)
  IF ColorQ.ColorName
    ADD(ColorQ)
  END  


!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetSystemColor      PROCEDURE(LONG pIndexColor)!,LONG
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CODE
  
  IF NOT BAND(pIndexColor,80000000h) !If the special bit is not turned on
    RETURN pIndexColor               !Assumed to already be a color
  END
  RETURN GetSysColor(BAND(pIndexColor,0FFFFFFh))

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetSystemColorName      PROCEDURE(LONG pColor)!,STRING
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ReturnVal CSTRING(31)

  CODE

  CASE pColor
  OF COLOR:SCROLLBAR               ; ReturnVal = 'COLOR:SCROLLBAR'
  OF COLOR:BACKGROUND              ; ReturnVal = 'COLOR:BACKGROUND'
  OF COLOR:ACTIVECAPTION           ; ReturnVal = 'COLOR:ACTIVECAPTION'
  OF COLOR:INACTIVECAPTION         ; ReturnVal = 'COLOR:INACTIVECAPTION'
  OF COLOR:MENU                    ; ReturnVal = 'COLOR:MENU'
  OF COLOR:MENUBAR                 ; ReturnVal = 'COLOR:MENUBAR'
  OF COLOR:WINDOW                  ; ReturnVal = 'COLOR:WINDOW'
  OF COLOR:WINDOWFRAME             ; ReturnVal = 'COLOR:WINDOWFRAME'
  OF COLOR:MENUTEXT                ; ReturnVal = 'COLOR:MENUTEXT'
  OF COLOR:WINDOWTEXT              ; ReturnVal = 'COLOR:WINDOWTEXT'
  OF COLOR:CAPTIONTEXT             ; ReturnVal = 'COLOR:CAPTIONTEXT'
  OF COLOR:ACTIVEBORDER            ; ReturnVal = 'COLOR:ACTIVEBORDER'
  OF COLOR:INACTIVEBORDER          ; ReturnVal = 'COLOR:INACTIVEBORDER'
  OF COLOR:APPWORKSPACE            ; ReturnVal = 'COLOR:APPWORKSPACE'
  OF COLOR:HIGHLIGHT               ; ReturnVal = 'COLOR:HIGHLIGHT'
  OF COLOR:HIGHLIGHTTEXT           ; ReturnVal = 'COLOR:HIGHLIGHTTEXT'
  OF COLOR:BTNFACE                 ; ReturnVal = 'COLOR:BTNFACE'
  OF COLOR:BTNSHADOW               ; ReturnVal = 'COLOR:BTNSHADOW'
  OF COLOR:GRAYTEXT                ; ReturnVal = 'COLOR:GRAYTEXT'
  OF COLOR:BTNTEXT                 ; ReturnVal = 'COLOR:BTNTEXT'
  OF COLOR:INACTIVECAPTIONTEXT     ; ReturnVal = 'COLOR:INACTIVECAPTIONTEXT'
  OF COLOR:BTNHIGHLIGHT            ; ReturnVal = 'COLOR:BTNHIGHLIGHT'
  OF COLOR:3DDkShadow              ; ReturnVal = 'COLOR:3DDkShadow'
  OF COLOR:3DLight                 ; ReturnVal = 'COLOR:3DLight'
  OF COLOR:InfoText                ; ReturnVal = 'COLOR:InfoText'
  OF COLOR:InfoBackground          ; ReturnVal = 'COLOR:InfoBackground'
  OF COLOR:HotLight                ; ReturnVal = 'COLOR:HotLight'
  OF COLOR:GradientActiveCaption   ; ReturnVal = 'COLOR:GradientActiveCaption'
  OF COLOR:GradientInactiveCaption ; ReturnVal = 'COLOR:GradientInactiveCaption'
  OF COLOR:MenuHighlight           ; ReturnVal = 'COLOR:MenuHighlight'
  END

  RETURN ReturnVal

!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
HEX                  PROCEDURE(LONG pLong,LONG pLen=6)!,STRING
!-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
lHexCS CSTRING(20)

  CODE

  ULtoA(pLong,lHexCS,16)
  IF pLen 
      RETURN UPPER(ALL('0',pLen - LEN(lHexCS)) & lHexCS)
  END
  RETURN lHexCS