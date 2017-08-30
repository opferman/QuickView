;*********************************************************
; Toby's System Helper
;  Written in Assemblyfor WIN32
;
;  Toby Opferman
;    Copyright (c) 2004 All Rights Reserved
;
;*********************************************************
;       D I S C L A I M E R  AND  L I C E N S E    
;   
; I license out this code for educational use only.
; There are no warranties implied.  Use at your own RISK.  
; I am NOT responsible for any catastrophic results which 
; may occur from using or replicating of this code in any
; shape or form.
;    
; Free to use this code for reference as an educational  
; tool only.  If you use any of the subroutines give credit
; where credit is due.  
;
; You may not use any of this source for commerical use
; without notifying the author for permission.
;
;*********************************************************

.486p
.MODEL FLAT, STDCALL
option casemap :none

include windows.inc
include masm32.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include comctl32.inc
include advapi32.inc

               
;
; NOTE: These commands are duplicated in the QV.EXE source.
;               
IDM_TOOLBAR_WINDOW            EQU 200
IDM_HEX                       EQU 201
IDM_DEC                       EQU 202
IDM_NOTUSED                   EQU 203
IDM_NTA                       EQU 204
IDM_NTB                       EQU 205
IDM_GLE                       EQU 206
IDM_MSG                       EQU 207
IDM_EDIT_WINDOW               EQU 208
IDM_BUTTON_OK                 EQU 209



; Defined in the latest masm32 headers
;TBSTYLE_AUTOSIZE              EQU <10h>
;BTNS_SEP                      EQU <1>

;*********************************************************
; Global Library Data And Structures
;*********************************************************
.DATA?

; UnInitialized Variables
 hInstance             DWORD                ?
 ghWnd                 DWORD                ?
 
.DATA    
 gNtDllInstance         DWORD  0
 szButtonString1        db "HEX", 0
 szButtonString2        db "DEC", 0
 
 szButtonString3_a      db "NT1", 0 
 szButtonString3_b      db "NT2", 0
 szButtonString4        db "GLE", 0
 szButtonString5        db "MSG", 0
 szTOOLBARCLASSNAME     db "ToolbarWindow32", 0
 szEditClass            db "EDIT", 0
 szButtonClass          db "BUTTON", 0
 szButtonName           db "OK", 0
 
 pszGLEText          db "GetLastError Hex = %0x Dec = %i",0
 pszWindowText       db "Window Message Hex = %0x Dec = %i", 0
 pszNTStatus         db "NT Status Hex = %0x Dec = %i", 0
 pszDefaultMsg       db "?! <Not Found> !?", 0
 pszNTDLL            db "ntdll.dll", 0


;*********************************************************
; Application Code
;*********************************************************
.CODE

TsysDll_EntryPoint:

DllMain PROC dwhInstance:DWORD, dwReason:DWORD, dwNothing:DWORD
  MOV EAX, [dwhInstance]
  MOV [hInstance], EAX
  MOV EAX, 1
  RET
DllMain ENDP



;*********************************************************
; TsysDll_CreateToolbar
;
;
;  Creates The Window 
;
;*********************************************************
TsysDll_CreateToolbar PROC hWnd:DWORD
LOCAL Button:TBBUTTON

    PUSH 0
    PUSH [hInstance]
    PUSH IDM_TOOLBAR_WINDOW 
    PUSH [hWnd]
    PUSH 0
    PUSH 0
    PUSH 0
    PUSH 0
    PUSH WS_CHILD or WS_VISIBLE
    PUSH 0
    PUSH OFFSET szTOOLBARCLASSNAME
    PUSH 0
    CALL CreateWindowEx
    MOV [ghWnd], EAX
    TEST EAX, EAX
    
    JZ @TsysDll_Failed
    
    PUSH 0
    PUSH size TBBUTTON
    PUSH TB_BUTTONSTRUCTSIZE
    PUSH [ghWnd]
    CALL SendMessage
   
    MOV [Button.fsState], TBSTATE_ENABLED or TBSTATE_CHECKED
    MOV [Button.fsStyle], TBSTYLE_BUTTON or TBSTYLE_CHECK  or TBSTYLE_AUTOSIZE
    MOV [Button.iBitmap], 0
    MOV [Button.idCommand], IDM_HEX
    MOV [Button.dwData], 0
    MOV [Button.iString], OFFSET szButtonString1
    
    LEA EAX, [Button]
    PUSH EAX
    PUSH 0
    PUSH TB_INSERTBUTTON
    PUSH [ghWnd]
    CALL SendMessage
    
    MOV [Button.fsState], TBSTATE_ENABLED
    MOV [Button.fsStyle], TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_AUTOSIZE 
    MOV [Button.iBitmap], 0
    MOV [Button.idCommand], IDM_DEC
    MOV [Button.dwData], 0
    MOV [Button.iString], OFFSET szButtonString2
    
    LEA EAX, [Button]
    PUSH EAX
    PUSH 1
    PUSH TB_INSERTBUTTON
    PUSH [ghWnd]
    CALL SendMessage
    
    MOV [Button.fsState], TBSTATE_ENABLED
    MOV [Button.fsStyle], BTNS_SEP
    MOV [Button.iBitmap], 0
    MOV [Button.idCommand], IDM_NOTUSED
    MOV [Button.dwData], 0
    MOV [Button.iString], 0
    
    LEA EAX, [Button]
    PUSH EAX
    PUSH 2
    PUSH TB_INSERTBUTTON
    PUSH [ghWnd]
    CALL SendMessage

    MOV [Button.fsState], TBSTATE_ENABLED or TBSTATE_CHECKED
    MOV [Button.fsStyle], TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_AUTOSIZE
    MOV [Button.iBitmap], 0
    MOV [Button.idCommand], IDM_NTA
    MOV [Button.dwData], 0
    MOV [Button.iString], OFFSET szButtonString3_a
    
    LEA EAX, [Button]
    PUSH EAX
    PUSH 3
    PUSH TB_INSERTBUTTON
    PUSH [ghWnd]
    CALL SendMessage
    
    MOV [Button.fsState], TBSTATE_ENABLED 
    MOV [Button.fsStyle], TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_AUTOSIZE
    MOV [Button.iBitmap], 0
    MOV [Button.idCommand], IDM_NTB
    MOV [Button.dwData], 0
    MOV [Button.iString], OFFSET szButtonString3_b
    
    LEA EAX, [Button]
    PUSH EAX
    PUSH 3
    PUSH TB_INSERTBUTTON
    PUSH [ghWnd]
    CALL SendMessage
    
    
    MOV [Button.fsState], TBSTATE_ENABLED
    MOV [Button.fsStyle], TBSTYLE_BUTTON or TBSTYLE_CHECK  or TBSTYLE_AUTOSIZE
    MOV [Button.iBitmap], 0
    MOV [Button.idCommand], IDM_GLE
    MOV [Button.dwData], 0
    MOV [Button.iString], OFFSET szButtonString4
    
    LEA EAX, [Button]
    PUSH EAX
    PUSH 3
    PUSH TB_INSERTBUTTON
    PUSH [ghWnd]
    CALL SendMessage
    
    MOV [Button.fsState], TBSTATE_ENABLED
    MOV [Button.fsStyle], TBSTYLE_BUTTON or TBSTYLE_CHECK  or TBSTYLE_AUTOSIZE
    MOV [Button.iBitmap], 0
    MOV [Button.idCommand], IDM_MSG
    MOV [Button.dwData], 0
    MOV [Button.iString], OFFSET szButtonString5
    
    LEA EAX, [Button]
    PUSH EAX
    PUSH 3
    PUSH TB_INSERTBUTTON
    PUSH [ghWnd]
    CALL SendMessage

    PUSH 0
    PUSH [hInstance]
    PUSH IDM_EDIT_WINDOW 
    PUSH [ghWnd]
    PUSH 25
    PUSH 100
    PUSH 7
    PUSH 250
    PUSH WS_CHILD or WS_VISIBLE or WS_BORDER
    PUSH 0
    PUSH OFFSET szEditClass
    PUSH 0
    CALL CreateWindowEx
    
    PUSH EAX
    
    PUSH SW_SHOWNORMAL
    PUSH EAX
    CALL ShowWindow
    CALL UpdateWindow
    
    PUSH 0
    PUSH [hInstance]
    PUSH IDM_BUTTON_OK 
    PUSH [ghWnd]
    PUSH 25
    PUSH 30
    PUSH 7
    PUSH 360
    PUSH WS_CHILD or WS_VISIBLE or WS_BORDER
    PUSH OFFSET szButtonName
    PUSH OFFSET szButtonClass
    PUSH 0
    CALL CreateWindowEx    
    
    
    PUSH EAX
    
    PUSH SW_SHOWNORMAL
    PUSH EAX
    CALL ShowWindow
    CALL UpdateWindow    
    
    MOV EAX, [ghWnd]
   @TsysDll_Failed:
    RET
TsysDll_CreateToolbar ENDP



;*********************************************************
; TsysDll_HandleCommands
;
;
;  Creates The Window 
;
;*********************************************************
TsysDll_HandleCommands PROC hWnd:DWORD, wParam:DWORD, lParam:DWORD
LOCAL dwNumber:DWORD

    MOV EAX, [wParam]
    CMP EAX, IDM_HEX
    JE @TsysDll_HEX 
    
    CMP EAX, IDM_DEC
    JE @TsysDll_DEC
    
    CMP EAX, IDM_NTA
    JE @TsysDll_NTA
    
    CMP EAX, IDM_NTB
    JE @TsysDll_NTB
    
    CMP EAX, IDM_GLE
    JE @TsysDll_GLE
    
    CMP EAX, IDM_MSG
    JE @TsysDll_MSG
    
    CMP EAX, IDM_BUTTON_OK
    JE @TsysDll_ProcessCrap
    
;    CMP EAX, IDM_EDIT_WINDOW   ;  No Filtering of input
    JMP @TsysDll_Exit
    
  @TsysDll_ProcessCrap:
    
    ;
    ; Process Toolbar Command
    ;
    
    PUSH 0
    PUSH IDM_HEX
    PUSH TB_ISBUTTONCHECKED
    PUSH [ghWnd]
    CALL SendMessage
    
    TEST EAX, EAX
    JZ @TsysDll_LoadAsInt
    
    SUB ESP, 100
    MOV EBX, ESP
    
    MOV BYTE PTR [EBX], 0
    
    PUSH 100
    PUSH EBX
    PUSH IDM_EDIT_WINDOW
    PUSH [ghWnd]
    CALL GetDlgItemText
    
    PUSH EBX
    CALL TsysDll_StrHexToNum
    
    ADD ESP, 100
    JMP @TsysDll_ProcessNextStep
    
   @TsysDll_LoadAsInt:
   
    PUSH 0
    PUSH 0
    PUSH IDM_EDIT_WINDOW
    PUSH [ghWnd]
    CALL GetDlgItemInt
    
   @TsysDll_ProcessNextStep: 
    MOV [dwNumber], EAX
    
    PUSH 0
    PUSH IDM_GLE
    PUSH TB_ISBUTTONCHECKED
    PUSH [ghWnd]
    CALL SendMessage
    
    TEST EAX, EAX
    JZ @TsysDll_TryNTA
    
    PUSH [dwNumber]
    CALL TsysDll_GLE
    
    RET
    
   @TsysDll_TryNTA:
    PUSH 0
    PUSH IDM_NTA
    PUSH TB_ISBUTTONCHECKED
    PUSH [ghWnd]
    CALL SendMessage
    
    TEST EAX, EAX
    JZ @TsysDll_TryNTB       
    
    PUSH [dwNumber]
    CALL TsysDll_NTA
    
    RET    
    
   @TsysDll_TryNTB:
    PUSH 0
    PUSH IDM_NTB
    PUSH TB_ISBUTTONCHECKED
    PUSH [ghWnd]
    CALL SendMessage
    
    TEST EAX, EAX
    JZ @TsysDll_ItHasToBeWindow       
    
    PUSH [dwNumber]
    CALL TsysDll_NTB
    
    RET
      
   @TsysDll_ItHasToBeWindow:
   
    PUSH [dwNumber]
    CALL TsysDll_WINDOW
    RET
    
  @TsysDll_HEX:
  
    PUSH 1
    PUSH IDM_HEX
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage

    PUSH 0
    PUSH IDM_DEC
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage
    
    JMP @TsysDll_Exit
    
  @TsysDll_DEC:
    PUSH 0
    PUSH IDM_HEX
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage

    PUSH 1
    PUSH IDM_DEC
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage
  
    JMP @TsysDll_Exit
    
  @TsysDll_NTA:
    PUSH 1
    PUSH IDM_NTA
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage

    PUSH 0
    PUSH IDM_NTB
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage    

    PUSH 0
    PUSH IDM_GLE
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage
  
    PUSH 0
    PUSH IDM_MSG
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage
      
    JMP @TsysDll_Exit

  @TsysDll_NTB:
    PUSH 0
    PUSH IDM_NTA
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage

    PUSH 1
    PUSH IDM_NTB
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage    

    PUSH 0
    PUSH IDM_GLE
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage
  
    PUSH 0
    PUSH IDM_MSG
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage
      
    JMP @TsysDll_Exit

    
  @TsysDll_GLE:
    PUSH 0
    PUSH IDM_NTA
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage

    PUSH 0
    PUSH IDM_NTB
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage 
    
    PUSH 1
    PUSH IDM_GLE
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage
  
    PUSH 0
    PUSH IDM_MSG
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage  
    JMP @TsysDll_Exit
    
  @TsysDll_MSG:
    PUSH 0
    PUSH IDM_NTA
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage

    PUSH 0
    PUSH IDM_NTB
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage 
    
    PUSH 0
    PUSH IDM_GLE
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage
  
    PUSH 1
    PUSH IDM_MSG
    PUSH TB_CHECKBUTTON
    PUSH [ghWnd]
    CALL SendMessage  
    JMP @TsysDll_Exit
    
  @TsysDll_Exit:
    RET
TsysDll_HandleCommands ENDP




;*********************************************************
; TsysDll_GLE
;
;
;  Creates The Window 
;
;*********************************************************
TsysDll_GLE PROC dwGLE:DWORD
  PUSH EDI
  PUSH EBX
  PUSH ESI
  PUSH ECX
  
  SUB ESP, 1024
  
  MOV EBX, ESP
  
  MOV ESI, OFFSET pszDefaultMsg
  MOV EDI, EBX
  MOV ECX,18
  REP MOVSB

  PUSH 0
  PUSH 1024
  PUSH EBX
  PUSH 0
  PUSH [dwGLE]
  PUSH 0
  PUSH FORMAT_MESSAGE_FROM_SYSTEM
  CALL FormatMessage
  SUB ESP, 100
  MOV ECX, ESP
  
  PUSH ECX
  PUSH [dwGLE]
  PUSH [dwGLE]
  
  MOV EAX, ESP
 
  PUSH EAX
  PUSH OFFSET pszGLEText
  PUSH ECX
  CALL wvsprintf
  
  POP ECX
  POP ECX
  POP ECX
  
  
  PUSH MB_OK
  PUSH ECX
  PUSH EBX
  PUSH [ghWnd]
  CALL MessageBox

  ADD ESP, 1024 + 100  ; GETTING IT ALL BACK!
  
  POP ECX
  POP ESI
  POP EBX
  POP EDI
  RET
  
TsysDll_GLE ENDP

                               
;*********************************************************
; TsysDll_NTA
;
;
;  Creates The Window 
;
;*********************************************************
TsysDll_NTA PROC dwNumber:DWORD
  PUSH EBX
  PUSH EDX
  PUSH ECX
  
  SUB ESP, 100
  MOV EBX, ESP
  ;
  ; Special Case This One.
  ;
  MOV EAX, 1000
  CMP [dwNumber], 0C0009898h
  JE @TsysDll_ConstructedString
  
  MOV ECX, [dwNumber]
  AND ECX, 0FFFFh
  
  ;
  ; We are trying to map 32 bit numbers into 16 bits.
  ; We need to do this uniquely.  The way we did it is that
  ; the lower 3 nibbles are never > 415h, leaving the top nibble open.
  ; The top 16 bit word is also only a combination of 14 different styles.
  ; in this manner, we can set the high nibble of the lower 16 bit value.
  ;
  
  CMP ECX, 0415h
  JA @TsysDll_NoStatus
  
  MOV EDX, [dwNumber]
  SHR EDX, 16
  
  MOV EAX, 01000h
  OR  EAX, ECX
  CMP DX, 0
  JE @TsysDll_ConstructedString
  
  MOV EAX, 02000h
  OR  EAX, ECX
  CMP DX, 0C00ah
  JE @TsysDll_ConstructedString
  
  MOV EAX, 03000h
  OR  EAX, ECX
  CMP DX, 0C000h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 04000h
  OR  EAX, ECX
  CMP DX, 0C004h		
  JE @TsysDll_ConstructedString
  
  MOV EAX, 05000h
  OR  EAX, ECX
  CMP DX, 0C003h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 06000h
  OR  EAX, ECX
  CMP DX, 0C002h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 07000h
  OR  EAX, ECX
  CMP DX, 0C013h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 08000h
  OR  EAX, ECX
  CMP DX, 0C015h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 09000h
  OR  EAX, ECX
  CMP DX, 08000h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 0A000h
  OR  EAX, ECX
  CMP DX, 08013h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 0B000h
  OR  EAX, ECX
  CMP DX, 04000h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 0C000h
  OR  EAX, ECX
  CMP DX, 04002h
  JE @TsysDll_ConstructedString
  
  MOV EAX, 0D000h
  OR  EAX, ECX
  CMP DX, 0400ah
  JE @TsysDll_ConstructedString
  
  MOV EAX, 0E000h
  OR  EAX, ECX
  CMP DX, 04015h
  JE @TsysDll_ConstructedString
  
  JMP @TsysDll_NoStatus
  
 @TsysDll_ConstructedString:

  PUSH 100
  PUSH EBX
  PUSH EAX
  PUSH [hInstance]
  CALL LoadString
  
  TEST EAX, EAX
  JZ @TsysDll_NoStatus
  
  SUB ESP, 100
  MOV EDX, ESP
  PUSH [dwNumber]
  PUSH [dwNumber]
  
  MOV EAX, ESP
 
  PUSH EAX
  PUSH OFFSET pszNTStatus
  PUSH EDX
  CALL wvsprintf
  
  ADD ESP, 8
  MOV EAX, ESP  
  
  PUSH MB_OK
  PUSH EAX 
  PUSH EBX
  PUSH [ghWnd]
  CALL MessageBox  
    
  ADD ESP, 200
  POP ECX
  POP EDX
  POP EBX
  
  RET  
 @TsysDll_NoStatus:
  
  PUSH [dwNumber]
  PUSH [dwNumber]
  
  MOV EAX, ESP
 
  PUSH EAX
  PUSH OFFSET pszNTStatus
  PUSH EBX
  CALL wvsprintf
  
  ADD ESP, 8
  
  PUSH MB_OK
  PUSH EBX 
  PUSH OFFSET pszDefaultMsg
  PUSH [ghWnd]
  CALL MessageBox  
  
  ADD ESP, 100
  POP ECX
  POP EDX
  POP EBX
  
  RET
TsysDll_NTA ENDP                               

;*********************************************************
; TsysDll_NTB
;
;
;  Creates The Window 
;
;*********************************************************
TsysDll_NTB PROC dwNumber:DWORD
  PUSH EDI
  PUSH EBX
  PUSH ESI
  PUSH ECX
  
  SUB ESP, 1024
  
  MOV EBX, ESP
  
  MOV EAX, [gNtDllInstance]
  
  TEST EAX, EAX
  JNZ SHORT @TsysDll_AlreadyGotNTDLLInstance
 
  PUSH OFFSET pszNTDLL
  CALL LoadLibrary
  
  MOV [gNtDllInstance], EAX
  
  
 @TsysDll_AlreadyGotNTDLLInstance:
 
  MOV ESI, OFFSET pszDefaultMsg
  MOV EDI, EBX
  MOV ECX,18
  REP MOVSB
    
  SUB ESP, 100
  XOR EAX, EAX
  MOV EDI, ESP
  MOV ECX, 100/4
  REP STOSD
  MOV ECX, ESP
  
  PUSH ECX
  PUSH 1024
  PUSH EBX
  PUSH 0
  PUSH [dwNumber]
  PUSH [gNtDllInstance]
  PUSH FORMAT_MESSAGE_FROM_HMODULE
  CALL FormatMessage 
  
  MOV ECX, ESP
  
  PUSH ECX
  PUSH [dwNumber]
  PUSH [dwNumber]
  
  MOV EAX, ESP
 
  PUSH EAX
  PUSH OFFSET pszNTStatus
  PUSH ECX
  CALL wvsprintf
  
  ADD ESP, 8
  POP ECX
  
  PUSH MB_OK
  PUSH ECX
  PUSH EBX
  PUSH [ghWnd]
  CALL MessageBox

  ADD ESP, 1024 + 100  ; GETTING IT ALL BACK!
  
  POP ECX
  POP ESI
  POP EBX
  POP EDI
  RET
  
TsysDll_NTB ENDP


;*********************************************************
; TsysDll_WINDOW
;
;
;  Creates The Window 
;
;*********************************************************
TsysDll_WINDOW PROC dwNumber:DWORD
  PUSH ECX
  PUSH EBX
  PUSH EDX
  
  MOV ECX, [dwNumber]
  SUB ESP, 100
  MOV EBX, ESP
  
  ;/* Messages 0 - 169 Add 100 */
  CMP ECX, 169
  JA @TsysDll_Next1
  
  ADD ECX, 100
  JMP @TsysDll_AttemptLoad
  
 @TsysDll_Next1:
  ;/* Messages 256 - 314 Add 14 */
  CMP ECX, 314
  JA @TsysDll_Next2
  CMP ECX, 256
  JB @TsysDll_NoWindow
  
  ADD ECX, 14
  JMP @TsysDll_AttemptLoad
  
 @TsysDll_Next2:
  ;/* Messages 512 - 564 Subtract 162 */
  CMP ECX, 564
  JA @TsysDll_Next3
  CMP ECX, 512
  JB @TsysDll_NoWindow
  
  SUB ECX, 162
  JMP @TsysDll_AttemptLoad
  
 @TsysDll_Next3:
  ;/* Messages 641 to 657 Subtract 216 */
  CMP ECX, 657
  JA @TsysDll_Next4
  CMP ECX, 641
  JB @TsysDll_NoWindow
  
  SUB ECX, 216
  JMP @TsysDll_AttemptLoad
  
 @TsysDll_Next4:
  ;/* Messages 673 to 675 Subtract 223 */
  CMP ECX, 675
  JA @TsysDll_Next5
  CMP ECX, 673
  JB @TsysDll_NoWindow
  
  SUB ECX, 223
  JMP @TsysDll_AttemptLoad
  
 @TsysDll_Next5:
  ;/* Messages 768 - 792 Subtract 293 */
  CMP ECX, 792
  JA @TsysDll_Next6
  CMP ECX, 768
  JB @TsysDll_NoWindow
  
  SUB ECX, 293
  JMP @TsysDll_AttemptLoad
  
 @TsysDll_Next6:
  ;/* Messages 856 and up (last is 911) Subtract 306 */
  CMP ECX, 911
  JA @TsysDll_Next7
  CMP ECX, 856
  JB @TsysDll_NoWindow
  
  SUB ECX, 306
  JMP @TsysDll_AttemptLoad
  
  
 @TsysDll_Next7:
  ; Special case WM_APP & WM_USER
  
  CMP ECX, 8000h
  JAE @TsysDll_WM_APP
  
  CMP ECX, 400h
  JAE @TsysDll_WM_USER
  
  JMP @TsysDll_NoWindow
   
 @TsysDll_WM_APP:
 
  SUB ESP, 100
  MOV EDX, ESP

  PUSH 100
  PUSH EDX
  PUSH 611
  PUSH [hInstance]
  CALL LoadString
  
  ADD ESP, 100                   ; Fuck it.
  
  TEST EAX, EAX
  JZ @TsysDll_NoWindow
  
  SUB ESP, 100                   ; Ya, so what?
  MOV EDX, ESP
  
  MOV EAX, [dwNumber]
  SUB EAX, 8000h
  
  PUSH EAX
  PUSH EAX
  
  MOV EAX, ESP
  
  PUSH EAX
  PUSH EDX
  PUSH EBX
  CALL wvsprintf
  
  ADD ESP, 108                   ; Clean up!
  
  JMP @TsysDll_Window_Found
 
 @TsysDll_WM_USER:
  
  SUB ESP, 100
  MOV EDX, ESP

  PUSH 100
  PUSH EDX
  PUSH 610
  PUSH [hInstance]
  CALL LoadString
  
  ADD ESP, 100                   ; Fuck it.
  
  TEST EAX, EAX
  JZ @TsysDll_NoWindow
  
  SUB ESP, 100                   ; Ya, so what?
  MOV EDX, ESP
  
  MOV EAX, [dwNumber]
  SUB EAX, 400h
  
  PUSH EAX
  PUSH EAX
  
  MOV EAX, ESP
  
  PUSH EAX
  PUSH EDX
  PUSH EBX
  CALL wvsprintf
  
  ADD ESP, 108                   ; Clean up!
  
  JMP @TsysDll_Window_Found
 
 @TsysDll_AttemptLoad:
  
  PUSH 100
  PUSH EBX
  PUSH ECX
  PUSH [hInstance]
  CALL LoadString
  
  TEST EAX, EAX
  JZ @TsysDll_NoWindow
  
 @TsysDll_Window_Found:
  
  SUB ESP, 100
  
  MOV EDX, ESP
  PUSH [dwNumber]
  PUSH [dwNumber]
  
  MOV EAX, ESP
 
  PUSH EAX
  PUSH OFFSET pszWindowText
  PUSH EDX
  CALL wvsprintf
  
  ADD ESP, 8
  MOV EDX, ESP
  
  PUSH MB_OK
  PUSH EDX 
  PUSH EBX
  PUSH [ghWnd]
  CALL MessageBox
  
  ADD ESP, 200
  POP EDX
  POP EBX
  POP ECX
  RET
  
 @TsysDll_NoWindow:

  SUB ESP, 100
  
  MOV EDX, ESP
  PUSH [dwNumber]
  PUSH [dwNumber]
  
  MOV EAX, ESP
 
  PUSH EAX
  PUSH OFFSET pszWindowText
  PUSH EDX
  CALL wvsprintf
  
  ADD ESP, 8
  MOV EDX, ESP
  
  PUSH MB_OK
  PUSH EDX 
  PUSH OFFSET pszDefaultMsg
  PUSH [ghWnd]
  CALL MessageBox
  
  ADD ESP, 200
  POP EDX
  POP EBX
  POP ECX
  RET  
TsysDll_WINDOW ENDP



;*********************************************************
; TsysDll_StrHexToNum
;
;
;  Creates The Window 
;
;*********************************************************
TsysDll_StrHexToNum PROC pszString :DWORD

  PUSH EDX
  PUSH EBX
  
  MOV EDX, [pszString]

  XOR EBX, EBX
  XOR EAX, EAX
  
  CMP BYTE PTR [EDX], 0
  JZ @ListView_GotNothing
  
  
 @ListView_ConvertHexString:  
  MOV BL, [EDX]
  
  SUB BL, '0'
  CMP BL, 9
  JBE @ListView_ContinueLoop
  
  SUB BL, 'A' - '0'
  CMP BL, 6
  JB @ListView_ContinueLoopHex
    
  SUB BL, 'a' - 'A'
  
 @ListView_ContinueLoopHex:
  ADD BL, 0Ah
  
 @ListView_ContinueLoop:
  SHL EAX, 4
  OR EAX, EBX
  INC EDX
  CMP BYTE PTR [EDX], 0
  JNZ @ListView_ConvertHexString
  
 @ListView_GotNothing:
  POP EBX
  POP EDX

  RET
TsysDll_StrHexToNum ENDP

END TsysDll_EntryPoint


 