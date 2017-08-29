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
; Command_Create
;
;
;  Creates the Process View List View
;
;*********************************************************
Command_Create PROC

  ; Create The Child Window
  CALL ListView_CreateListViewWindow

  MOV EBX, EAX
  PUSH EAX
  PUSH EAX
  CALL ListView_SetExtendedListViewStyle

  ; Create The Columns
  PUSH OFFSET pszCommandLineText
  PUSH 0
  PUSH EBX
  CALL ListView_CreateColoumnLarge
  
  PUSH OFFSET pszCommandPIDText
  PUSH 1
  PUSH EBX
  CALL ListView_CreateColoumn
    
  PUSH EBX
  CALL CommandView_Refresh
  
  POP EAX
  RET
Command_Create ENDP


;*********************************************************
; CommandView_Refresh
;
;

;*********************************************************
CommandView_Refresh PROC hWnd:DWORD
LOCAL hToolHelp :DWORD
LOCAL Process32 :PROCESSENTRY32
LOCAL hProcess  :DWORD
LOCAL ProcessInfo :PROCESS_BASIC_INFORMATION
LOCAL dwCount :DWORD
LOCAL dwMaxSize :DWORD
LOCAL dwSize :DWORD

  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  PUSH [hWnd]
  CALL ListView_DeleteAll
  
  PUSH 0
  PUSH TH32CS_SNAPPROCESS
  CALL CreateToolhelp32Snapshot
  MOV [hToolHelp], EAX
  
  MOV [hToolHelp], EAX
  
  MOV [Process32.dwSize], size PROCESSENTRY32
  LEA  EBX, [Process32]
  
  PUSH EBX
  PUSH EAX
  CALL Process32First
  
  SUB ESP, 528
  MOV EBX, ESP
  
 @CommandView_TheProcessLoop:
  
    PUSH [Process32.th32ProcessID]
    PUSH 0
    PUSH PROCESS_QUERY_INFORMATION or PROCESS_VM_READ
    CALL OpenProcess
    
    TEST EAX, EAX
    JZ @CommandView_CantOpen
    
    MOV [hProcess], EAX
    
    PUSH 0
    PUSH size PROCESS_BASIC_INFORMATION
    LEA EAX, [ProcessInfo]
    PUSH EAX
    PUSH ProcessBasicInformation
    PUSH [hProcess]
    CALL [NtQueryInformationProcess]
    
    CMP EAX, 0
    JL @CommandView_CantGetProcInfo
    
    LEA EAX, [dwSize]
    PUSH EAX
    PUSH 4
    PUSH EBX
    MOV EAX, [ProcessInfo.PebBaseAddress]
    ADD EAX, 010h                                 ; Process Image Address
    PUSH EAX
    PUSH [hProcess]
    CALL ReadProcessMemory                      ; Read the PEB's PI address
    
    TEST EAX, EAX
    JZ @CommandView_CantGetProcInfo
    
    
    LEA EAX, [dwSize]
    PUSH EAX
    PUSH 8
    PUSH EBX
    MOV EAX, [EBX]
    ADD EAX, 040h                               ; Read The PI's Command Line
    PUSH EAX
    PUSH [hProcess]
    CALL ReadProcessMemory                     
    
    TEST EAX, EAX
    JZ @CommandView_CantGetProcInfo    
    
    ; Finally, Read the stupid DLL String From Memory.
        
    LEA EAX, [dwSize]
    PUSH EAX
    XOR EAX, EAX
    MOV AX, [EBX + 2]
    CMP EAX, 528
    JLE @CommandView_Good
    
    MOV EAX, 528
    
   @CommandView_Good:
    MOV [dwMaxSize], EAX
    PUSH EAX
    PUSH EBX
    MOV  EAX, [EBX + 4]
    PUSH EAX
    PUSH [hProcess]
    CALL ReadProcessMemory                      ; Read the Command Line
    
    TEST EAX, EAX
    JZ @CommandView_CantGetProcInfo
    
  
    ; Display Our Information!
    MOV [gLci.imask], LVIF_TEXT
    MOV [gLci.pszText], EBX
    MOV EAX, [dwMaxSize]
    SHR EAX, 1
    PUSH EAX
    PUSH OFFSET gLci
    PUSH [hWnd]
    CALL ListView_InsertItemW 
    
    MOV [dwCount], EAX
       
    LEA EAX, [Process32.th32ProcessID]
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
        
    PUSH EBX
    PUSH 1
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  
        
   @CommandView_CantGetProcInfo: 
    PUSH [hProcess]
    CALL CloseHandle
    
   @CommandView_CantOpen:
   
    MOV [Process32.dwSize], size PROCESSENTRY32
    LEA  EAX, [Process32]
  
    PUSH EAX
    PUSH [hToolHelp]
    CALL Process32Next
  
    TEST EAX, EAX
    JNZ @CommandView_TheProcessLoop
    
 @CommandView_Exit:
 
  PUSH [hToolHelp]
  CALL CloseHandle
  
  ADD ESP, 528
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
CommandView_Refresh ENDP



;*********************************************************
; CommandView_Sort
;
;
;  Registers The Window Class
;
;*********************************************************
CommandView_Sort PROC hWnd:DWORD, iCol:DWORD

  MOV AL, [gSortType]
  INC AL
  MOV [gSortType], AL
  
  TEST AL, 1
  JE @CommandView_SortOpposite
  
  MOV EAX, [iCol]
  
  CMP EAX, 1
  JE SHORT @CommandView_SortByNumber
  
  
  PUSH [iCol]
  PUSH ListView_CompareStr
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @CommandView_Exit
  
 @CommandView_SortByNumber:  
 
  PUSH [iCol]
  PUSH ListView_CompareNum
  PUSH [hWnd]
  CALL ListView_SortEx 
 
 @CommandView_Exit:  
  RET
 
 @CommandView_SortOpposite:
  MOV EAX, [iCol]
  
  CMP EAX, 1
  JE SHORT @CommandView_SortByNumberDecsend

  
  PUSH [iCol]
  PUSH ListView_CompareStrDecsend
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @CommandView_Exit
  
 @CommandView_SortByNumberDecsend:  
 
  PUSH [iCol]
  PUSH ListView_CompareNumDecsend
  PUSH [hWnd]
  CALL ListView_SortEx 
  RET
  
CommandView_Sort ENDP



;*********************************************************
; CommandView_ClickFunction
;
;
;  Registers The Window Class
;
;*********************************************************
CommandView_ClickFunction PROC hWnd:DWORD, hWndListView:DWORD, iItem:DWORD, iSubItem:DWORD
  RET
CommandView_ClickFunction ENDP


;*********************************************************
; CommandView_Commands
;
;
;  Registers The Window Class
;
;*********************************************************
CommandView_Commands PROC hWnd:DWORD, hWndListView:DWORD, iCmd:DWORD
  RET
CommandView_Commands ENDP


;*********************************************************
; CommandView_Hide
;
;
;  Registers The Window Class
;
;*********************************************************
CommandView_Hide PROC hWnd:DWORD, hWndListView:DWORD
  RET
CommandView_Hide ENDP









