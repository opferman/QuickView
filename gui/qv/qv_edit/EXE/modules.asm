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
; Module_Create
;
;
;  Creates the Process View List View
;
;*********************************************************
Module_Create PROC

  ; Create The Child Window
  CALL ListView_CreateListViewWindow

  MOV EBX, EAX
  PUSH EAX
  PUSH EAX
  CALL ListView_SetExtendedListViewStyle
 
  ; Create The Columns
  PUSH OFFSET pszModImageNameText
  PUSH 0
  PUSH EBX
  CALL ListView_CreateColoumnLarge
  
  PUSH OFFSET pszModLoadText
  PUSH 1
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszModSizeText
  PUSH 2
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszModBaseText
  PUSH 3
  PUSH EBX 
  CALL ListView_CreateColoumn

  PUSH OFFSET pszModFlagsText
  PUSH 4
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszModNameOffsetText
  PUSH 5
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH EBX
  CALL ModView_Refresh
  
  POP EAX
  RET
Module_Create ENDP


;*********************************************************
; ModView_Refresh
;
;

;*********************************************************
ModView_Refresh PROC hWnd:DWORD
LOCAL pModule    :DWORD
LOCAL pModInfo   :DWORD
LOCAL dwCount    :DWORD           
LOCAL dwSystemLength :DWORD
LOCAL dwShortToLong  :DWORD

  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  SUB ESP, 16
  MOV EBX, ESP
  
  PUSH [hWnd]
  CALL ListView_DeleteAll

  LEA EAX, [dwSystemLength]
  PUSH EAX
  PUSH 4
  PUSH EBX                              ; Need to give this in order to get Windows 2000 Working.
  PUSH SystemModuleInformation
  CALL [NtQuerySystemInformation]
  
  CMP EAX, 0C0000004h
  JNE @MovView_Exit
  
  LEA EAX, [dwSystemLength]
  ADD EAX, 4
  PUSH EAX
  PUSH LMEM_ZEROINIT
  CALL LocalAlloc
  
  MOV [pModule], EAX
  
  LEA EAX, [dwSystemLength]
  PUSH EAX
  MOV EAX, [EAX]
  ADD EAX, 4
  PUSH EAX
  MOV EAX, [pModule]
  PUSH EAX
  PUSH SystemModuleInformation
  CALL [NtQuerySystemInformation]
  
  CMP EAX, 0
  JL @MovView_ExitWithFree
  
  MOV EAX, [pModule]
  MOV ECX, [EAX]
  ADD EAX, 4
  MOV [pModInfo], EAX
  MOV [dwCount], 0
  
 @MovView_ModuleListLoop:
    CMP ECX, 0
    JE @MovView_ExitWithFree
    
    PUSH ECX
    
    MOV [gLci.imask], LVIF_TEXT
    MOV EAX, [pModInfo]
    LEA EAX, [EAX + 28] ; Image Name
    MOV [gLci.pszText], EAX
    
    PUSH OFFSET gLci
    PUSH [hWnd]
    CALL ListView_InsertItem 
    
    MOV [dwCount], EAX  
    
    MOV EAX, [pModInfo]
    LEA EAX, [EAX + 24]  ; Mod Load
    
    MOV AX, [EAX]
    MOVZX EAX, AX
    MOV [dwShortToLong], EAX
    LEA EAX, [dwShortToLong]

    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 1
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  

    MOV EAX, [pModInfo]
    LEA EAX, [EAX + 12]  ; Mode Size
    SHR DWORD PTR [EAX], 10
    PUSH EAX
    PUSH OFFSET pszFormatStringIntK
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 2
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  


    MOV EAX, [pModInfo]
    LEA EAX, [EAX +  8]  ; Mode base
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 3
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  
    
    MOV EAX, [pModInfo]
    LEA EAX, [EAX + 16] ; Mode Flags
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 4
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText      
    
    MOV EAX, [pModInfo]
    LEA EAX, [EAX + 26] ; Mod Name Offset
    
    MOV AX, [EAX]
    MOVZX EAX, AX
    MOV [dwShortToLong], EAX
    LEA EAX, [dwShortToLong]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 5
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText      

    
    MOV EAX, [pModInfo]
    ADD EAX, size SYSTEM_MODULE_INFO
    MOV [pModInfo], EAX
    
  
    POP ECX
    DEC ECX
    JMP @MovView_ModuleListLoop
  
 @MovView_ExitWithFree:
  MOV EAX, [pModule]
  PUSH EAX
  CALL LocalFree
  
 @MovView_Exit:
  ADD ESP, 16
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
ModView_Refresh ENDP





;*********************************************************
; ModView_Sort
;
;
;  Registers The Window Class
;
;*********************************************************
ModView_Sort PROC hWnd:DWORD, iCol:DWORD

  MOV AL, [gSortType]
  INC AL
  MOV [gSortType], AL
  
  TEST AL, 1
  JE @ModView_SortOpposite
  
  MOV EAX, [iCol]
  
  CMP EAX, 1
  JE SHORT @ModView_SortByNumber
  
  CMP EAX, 2
  JE SHORT @ModView_SortByNumber

  
  PUSH [iCol]
  PUSH ListView_CompareStr
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @ModView_Exit
  
 @ModView_SortByNumber:  
 
  PUSH [iCol]
  PUSH ListView_CompareNum
  PUSH [hWnd]
  CALL ListView_SortEx 
 
 @ModView_Exit:  
  RET
 
 @ModView_SortOpposite:
  MOV EAX, [iCol]
  
  CMP EAX, 1
  JE SHORT @ModView_SortByNumberDecsend

  CMP EAX, 2
  JE SHORT @ModView_SortByNumberDecsend
  
  PUSH [iCol]
  PUSH ListView_CompareStrDecsend
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @ModView_Exit
  
 @ModView_SortByNumberDecsend:  
 
  PUSH [iCol]
  PUSH ListView_CompareNumDecsend
  PUSH [hWnd]
  CALL ListView_SortEx 
  RET
  
ModView_Sort ENDP



;*********************************************************
; ProcView_ClickFunction
;
;
;  Registers The Window Class
;
;*********************************************************
ModView_ClickFunction PROC hWnd:DWORD, hWndListView:DWORD, iItem:DWORD, iSubItem:DWORD
  RET
ModView_ClickFunction ENDP


;*********************************************************
; ModView_Commands
;
;
;  Registers The Window Class
;
;*********************************************************
ModView_Commands PROC hWnd:DWORD, hWndListView:DWORD, iCmd:DWORD
  RET
ModView_Commands ENDP


;*********************************************************
; ModView_Hide
;
;
;  Registers The Window Class
;
;*********************************************************
ModView_Hide PROC hWnd:DWORD, hWndListView:DWORD
  RET
ModView_Hide ENDP









