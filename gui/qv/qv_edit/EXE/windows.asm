;*********************************************************
; Toby's System Helper
;  Written in Assemblyfor WIN32
;
;  Toby Opferman
;    Copyright (c) 2004 All Rights Reserved
;
;*********************************************************
;       D I S C L A I M E R  AND  L I S E N C E    
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



;*********************************************************
; Window_Create
;
;
;  Creates the Process View List View
;
;*********************************************************
Window_Create PROC

  ; Create The Child Window
  CALL ListView_CreateListViewWindow

  MOV EBX, EAX
  PUSH EAX
  PUSH EAX
  CALL ListView_SetExtendedListViewStyle

  ; Create The Columns
  PUSH OFFSET pszWinHandleText
  PUSH 0
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszWinTitleText
  PUSH 1
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszWinClassText
  PUSH 2
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszWinStylesText
  PUSH 3
  PUSH EBX 
  CALL ListView_CreateColoumn

  PUSH OFFSET pszWinExStylesText
  PUSH 4
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszWinStatusText
  PUSH 5
  PUSH EBX
  CALL ListView_CreateColoumn  

  PUSH OFFSET pszWinParentText
  PUSH 6
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszWinModNameText
  PUSH 7
  PUSH EBX
  CALL ListView_CreateColoumnLarge 
  
  PUSH OFFSET pszWinProcessIdText
  PUSH 8
  PUSH EBX
  CALL ListView_CreateColoumn  

  PUSH OFFSET pszWinThreadIdText
  PUSH 9
  PUSH EBX
  CALL ListView_CreateColoumn  
  
  PUSH EBX
  CALL WinView_Refresh
  
  POP EAX
  RET
Window_Create ENDP


;*********************************************************
; WinView_Refresh
;
;

;*********************************************************
WinView_Refresh PROC hWnd:DWORD
  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  PUSH [hWnd]
  CALL ListView_DeleteAll

  PUSH [hWnd]
  PUSH WinView_EnumProc
  CALL EnumWindows

  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
WinView_Refresh ENDP


;*********************************************************
; WinView_EnumProc
;
;

;*********************************************************
WinView_EnumProc PROC hWnd:DWORD, hWndListView:DWORD
LOCAL dwCount :DWORD
LOCAL WinInfo   :WINDOWINFO
LOCAL dwLocalLong :DWORD
LOCAL hProcess :DWORD

    PUSH EBX
    PUSH ECX
    PUSH EDX  
    
    CMP [gEnumChild], 0
    JNZ @WinView_SkipChildern    ; Should not enum child, can get into endless loop.
    
    MOV [gEnumChild], 1
    
    PUSH [hWndListView]
    PUSH OFFSET WinView_EnumProc
    PUSH [hWnd]
    CALL EnumChildWindows
    
    MOV [gEnumChild], 0
    
 @WinView_SkipChildern:
    SUB ESP, 256
    MOV EBX, ESP
    
    LEA EAX, [hWnd]
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf 
    
    MOV [gLci.imask], LVIF_TEXT
    MOV [gLci.pszText], EBX
    
    PUSH OFFSET gLci
    PUSH [hWndListView]
    CALL ListView_InsertItem ; Window Handle HEX
    
    MOV [dwCount], EAX  
    
    PUSH 256
    PUSH EBX
    PUSH [hWnd]
    CALL GetWindowText

    
    PUSH EBX
    PUSH 1
    PUSH [dwCount]
    PUSH [hWndListView]
    CALL ListView_SetItemText  

    PUSH 256
    PUSH EBX
    PUSH [hWnd]
    CALL RealGetWindowClass   
 
    PUSH EBX
    PUSH 2
    PUSH [dwCount]
    PUSH [hWndListView]
    CALL ListView_SetItemText  

    MOV [WinInfo.cbSize], size WINDOWINFO
    LEA EAX, [WinInfo]
    PUSH EAX
    PUSH [hWnd]
    CALL GetWindowInfo
    
    LEA EAX, [WinInfo.dwStyle]
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 3
    PUSH [dwCount]
    PUSH [hWndListView]
    CALL ListView_SetItemText  
    
    LEA EAX, [WinInfo.dwExStyle]    
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 4
    PUSH [dwCount]
    PUSH [hWndListView]
    CALL ListView_SetItemText      
    
    ; Useless Information
       LEA EAX, [WinInfo.dwWindowStatus]    
       PUSH EAX
       PUSH OFFSET pszFormatStringIntHEX
       PUSH EBX
       CALL wvsprintf    
    
       PUSH EBX
       PUSH 5
       PUSH [dwCount]
       PUSH [hWndListView]
       CALL ListView_SetItemText      
    ; End
    
    PUSH [hWnd]
    CALL GetParent
    
    MOV [dwLocalLong], EAX
    LEA EAX, [dwLocalLong]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 6
    PUSH [dwCount]
    PUSH [hWndListView]
    CALL ListView_SetItemText      
    
    MOV [dwLocalLong], 0
    LEA EAX, [dwLocalLong]
    
    PUSH EAX
    PUSH [hWnd]
    CALL GetWindowThreadProcessId 
    
    PUSH EAX

    LEA EAX, [dwLocalLong]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 8
    PUSH [dwCount]
    PUSH [hWndListView]
    CALL ListView_SetItemText      
    
    
    PUSH [dwLocalLong]
    PUSH 0
    PUSH PROCESS_QUERY_INFORMATION
    CALL OpenProcess
    
    MOV [hProcess], EAX
    
    POP [dwLocalLong]
    LEA EAX, [dwLocalLong]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 9
    PUSH [dwCount]
    PUSH [hWndListView]
    CALL ListView_SetItemText  
    
    CMP [hProcess], 0
    JE @WinView_Exit
    
    SUB ESP, 256 + 8
    MOV EBX, ESP
    
    PUSH 0
    PUSH 520
    PUSH EBX
    PUSH ProcessNameInformation         ; Not available on 2k, will return c000003 error here.
    PUSH [hProcess]
    CALL [NtQueryInformationProcess]
    
    CMP EAX, 0
    JL @WinView_ExitWithClose
    
    PUSH [EBX + 4]
    PUSH 7
    PUSH [dwCount]
    PUSH [hWndListView]
    CALL ListView_SetItemTextW  
    
 @WinView_ExitWithClose:
    ADD ESP, 256 + 8
    PUSH [hProcess]
    CALL CloseHandle
    
 @WinView_Exit:
  ADD ESP, 256
  
  POP EDX
  POP ECX
  POP EBX    
  
  MOV EAX, 1
  RET
  
WinView_EnumProc ENDP





;*********************************************************
; WinView_Sort
;
;
;  Registers The Window Class
;
;*********************************************************
WinView_Sort PROC hWnd:DWORD, iCol:DWORD

  MOV AL, [gSortType]
  INC AL
  MOV [gSortType], AL
  
  TEST AL, 1
  JE @WinView_SortOpposite
  
  MOV EAX, [iCol]
  
  CMP EAX, 8
  JE SHORT @WinView_SortByNumber
  
  CMP EAX, 9
  JE SHORT @WinView_SortByNumber

  
  PUSH [iCol]
  PUSH ListView_CompareStr
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @WinView_Exit
  
 @WinView_SortByNumber:  
 
  PUSH [iCol]
  PUSH ListView_CompareNum
  PUSH [hWnd]
  CALL ListView_SortEx 
 
 @WinView_Exit:  
  RET
 
 @WinView_SortOpposite:
  MOV EAX, [iCol]
  
  CMP EAX, 9
  JE SHORT @WinView_SortByNumberDecsend

  CMP EAX, 8
  JE SHORT @WinView_SortByNumberDecsend
  
  PUSH [iCol]
  PUSH ListView_CompareStrDecsend
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @WinView_Exit
  
 @WinView_SortByNumberDecsend:  
 
  PUSH [iCol]
  PUSH ListView_CompareNumDecsend
  PUSH [hWnd]
  CALL ListView_SortEx 
  RET
  
WinView_Sort ENDP



;*********************************************************
; WinView_ClickFunction
;
;
;  Registers The Window Class
;
;*********************************************************
WinView_ClickFunction PROC hWnd:DWORD, hWndListView:DWORD, iItem:DWORD, iSubItem:DWORD
LOCAL CursorPosition :POINT
  PUSH EBX
  
  PUSH OFFSET pszWinMenuString
  PUSH NULL
  CALL LoadMenu
  
  PUSH EAX
  PUSH 0
  PUSH EAX
  CALL GetSubMenu
  MOV EBX, EAX
  
  LEA EAX, [CursorPosition]
  PUSH EAX
  CALL GetCursorPos
  
  PUSH 0
  PUSH [hWnd]
  PUSH 0
  
  XOR EAX, EAX
  
  MOV EAX, [CursorPosition.y]
  PUSH EAX
  
  MOV EAX, [CursorPosition.x]
  PUSH EAX
  PUSH TPM_LEFTBUTTON + TPM_CENTERALIGN
  
  PUSH EBX
  CALL TrackPopupMenu
  
 ; PUSH EBX
 ; CALL DestroyMenu
  
  CALL DestroyMenu
  
  XOR EAX, EAX
  POP EBX
  
  RET
WinView_ClickFunction ENDP


;*********************************************************
; WinView_Commands
;
;
;  Registers The Window Class
;
;*********************************************************
WinView_Commands PROC hWnd:DWORD, hWndListView:DWORD, iCmd:DWORD
LOCAL iNumSelect :DWORD
LOCAL lvItem     :LVITEM


  MOV EAX, [iCmd]
  
  CMP EAX, IDM_WINDESTROY                
  JE @WinView_DestroyWindow
  
  CMP EAX, IDM_WINSENDMESSAGE            
  JE @WinView_SendMessage
  
  CMP EAX, IDM_WINCLOSE
  JE @WinView_CloseWindow
  
  RET 
  
  @WinView_SendMessage:
   PUSH MB_OK
   PUSH OFFSET pszTemp
   PUSH OFFSET pszTemp
   PUSH [hWnd]
   CALL MessageBox
   
   RET
   
  @WinView_CloseWindow:
  
  PUSH [hWndListView]
  CALL ListView_GetSelectedCount
  
  MOV [iNumSelect], EAX
  
  LEA EDI, [lvItem]
  MOV ECX, size LVITEM
  XOR EAX, EAX
  REP STOSB
  
  MOV [lvItem.imask], LVIF_STATE
  MOV [lvItem.iItem], 0
  MOV [lvItem.stateMask], LVIS_SELECTED
  XOR ECX, ECX
  
 @WinView_CloseLoop:
  CMP ECX, [iNumSelect]
  JE @WinView_Exit
  
    PUSH ECX
    
    LEA EAX, [lvItem]
    PUSH EAX
    PUSH [hWndListView]
    CALL ListView_GetItem
    
    TEST EAX, EAX
    JZ @WinView_Exit
    POP ECX
    
    CMP [lvItem.state], LVIS_SELECTED
    JNE @WinView_ContinueCloseLoop
    
    PUSH ECX
    
    SUB ESP, 256
    MOV EDX, ESP
    
    PUSH 256
    PUSH EDX
    PUSH 0
    PUSH [lvItem.iItem]
    PUSH [ghWndLVCurrent]
    CALL ListView_GetText  
    
    PUSH EDX
    CALL ListView_StrHexToNum        ; Here we convert the WindowHandle to a number.
    
    PUSH 0    
    PUSH 0
    PUSH WM_CLOSE
    PUSH EAX
    CALL PostMessage
    
    ADD ESP, 256
    
    POP ECX
    INC ECX
    
  @WinView_ContinueCloseLoop:
    INC [lvItem.iItem]
    
  JMP @WinView_DestroyLoop

  
  
  @WinView_DestroyWindow:
  
  PUSH [hWndListView]
  CALL ListView_GetSelectedCount
  
  MOV [iNumSelect], EAX
  
  LEA EDI, [lvItem]
  MOV ECX, size LVITEM
  XOR EAX, EAX
  REP STOSB
  
  MOV [lvItem.imask], LVIF_STATE
  MOV [lvItem.iItem], 0
  MOV [lvItem.stateMask], LVIS_SELECTED
  XOR ECX, ECX
  
 @WinView_DestroyLoop:
  CMP ECX, [iNumSelect]
  JE @WinView_Exit
  
    PUSH ECX
    
    LEA EAX, [lvItem]
    PUSH EAX
    PUSH [hWndListView]
    CALL ListView_GetItem
    
    TEST EAX, EAX
    JZ @WinView_Exit
    POP ECX
    
    CMP [lvItem.state], LVIS_SELECTED
    JNE @WinView_ContinueDestroyLoop
    
    PUSH ECX
    
    SUB ESP, 256
    MOV EDX, ESP
    
    PUSH 256
    PUSH EDX
    PUSH 0
    PUSH [lvItem.iItem]
    PUSH [ghWndLVCurrent]
    CALL ListView_GetText  
    
    PUSH EDX
    CALL ListView_StrHexToNum        ; Here we convert the WindowHandle to a number.
    
    PUSH 0    
    PUSH 0
    PUSH WM_DESTROY
    PUSH EAX
    CALL PostMessage
    
    ADD ESP, 256
    
    POP ECX
    INC ECX
    
  @WinView_ContinueDestroyLoop:
    INC [lvItem.iItem]
    
  JMP @WinView_DestroyLoop
  
 @WinView_Exit:
 
  PUSH [hWndListView]
  CALL WinView_Refresh
  
  RET
WinView_Commands ENDP


;*********************************************************
; WinView_Hide
;
;
;  Registers The Window Class
;
;*********************************************************
WinView_Hide PROC hWnd:DWORD, hWndListView:DWORD
  RET
WinView_Hide ENDP









