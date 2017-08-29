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
; Dlls_Create
;
;
;  Creates the Process View List View
;
;*********************************************************
Dlls_Create PROC

  ; Create The Child Window
  CALL ListView_CreateListViewWindow

  MOV EBX, EAX
  PUSH EAX
  PUSH EAX
  CALL ListView_SetExtendedListViewStyle

  ; Create The Columns
  PUSH OFFSET pszDllImageNameText
  PUSH 0
  PUSH EBX
  CALL ListView_CreateColoumnLarge
  
  PUSH OFFSET pszDllPIDText
  PUSH 1
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszDllModStart
  PUSH 2
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszDllModEnd
  PUSH 3
  PUSH EBX
  CALL ListView_CreateColoumn

  
  PUSH EBX
  CALL DllsView_Refresh
  
  POP EAX
  RET
Dlls_Create ENDP


;*********************************************************
; DllsView_Refresh
;
;

;*********************************************************
DllsView_Refresh PROC hWnd:DWORD
LOCAL hToolHelp :DWORD
LOCAL Process32 :PROCESSENTRY32
LOCAL hProcess  :DWORD
LOCAL ProcessInfo :PROCESS_BASIC_INFORMATION
LOCAL dwSize :DWORD
LOCAL dwStart :DWORD
LOCAL dwCurrent :DWORD
LOCAL dwCount :DWORD
LOCAL dwMemStart :DWORD
LOCAL dwMemEnd :DWORD
LOCAL dwMaxSize :DWORD

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
  
 @DllsView_TheProcessLoop:
  
    PUSH [Process32.th32ProcessID]
    PUSH 0
    PUSH PROCESS_QUERY_INFORMATION or PROCESS_VM_READ
    CALL OpenProcess
    
    TEST EAX, EAX
    JZ @DllsView_CantOpen
    
    MOV [hProcess], EAX
    
    PUSH 0
    PUSH size PROCESS_BASIC_INFORMATION
    LEA EAX, [ProcessInfo]
    PUSH EAX
    PUSH ProcessBasicInformation
    PUSH [hProcess]
    CALL [NtQueryInformationProcess]
    
    CMP EAX, 0
    JL @DllsView_CantGetProcInfo
    
    LEA EAX, [dwSize]
    PUSH EAX
    PUSH 4
    PUSH EBX
    MOV EAX, [ProcessInfo.PebBaseAddress]
    ADD EAX, 0Ch                                ; LDR Address
    PUSH EAX
    PUSH [hProcess]
    CALL ReadProcessMemory                      ; Read the PEB's LDR address
    
    TEST EAX, EAX
    JZ @DllsView_CantGetProcInfo
    
    
    LEA EAX, [dwSize]
    PUSH EAX
    PUSH 4
    PUSH EBX
    MOV EAX, [EBX]
    ADD EAX, 014h                               ; Read The LDR's Module List Location
    PUSH EAX
    PUSH [hProcess]
    CALL ReadProcessMemory                      ; Read the PEB's LDR address
    
    TEST EAX, EAX
    JZ @DllsView_CantGetProcInfo    
    
    MOV EAX, [EBX]
    MOV [dwStart], EAX                          ; Save Starting Location 
    MOV [dwCurrent], EAX
    
   @DllsView_TheDllLoop:
    
        LEA EAX, [dwSize]
        PUSH EAX
        PUSH 028h
        PUSH EBX
        PUSH [dwCurrent]
        PUSH [hProcess]
        CALL ReadProcessMemory                      ; Read the PEB's LDR address
        
        TEST EAX, EAX
        JZ @DllsView_CantGetProcInfo
        
        MOV EAX, [EBX]
        MOV [dwCurrent], EAX                        ; Update Current
        
        CMP EAX, [dwStart]
        JE @DllsView_CantGetProcInfo                ; The last module in the list is garbage, ignore.
        
        CMP DWORD PTR [EBX + 20h], 0
        JE @DllsView_LoopTest
        
        MOV EAX, [EBX + 16]
        MOV [dwMemStart], EAX
        
        ADD EAX, [EBX + 24]
        MOV [dwMemEnd], EAX
        
        
        ; Finally, Read the stupid DLL String From Memory.
        
        LEA EAX, [dwSize]
        PUSH EAX
        XOR EAX, EAX
        MOV AX, [EBX + 01eh]
        
        CMP EAX, 528
        JLE @DllView_Good
        
        MOV EAX, 528
        
       @DllView_Good:
        
        MOV [dwMaxSize], EAX
        PUSH EAX
        PUSH EBX
        MOV  EAX, [EBX + 20h]
        PUSH EAX
        PUSH [hProcess]
        CALL ReadProcessMemory                      ; Read the PEB's LDR address
        
        TEST EAX, EAX
        JZ @DllsView_LoopTest
        
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
        
        LEA EAX, [dwMemStart]
        PUSH EAX
        PUSH OFFSET pszFormatStringIntHEX
        PUSH EBX
        CALL wvsprintf    
        
        PUSH EBX
        PUSH 2
        PUSH [dwCount]
        PUSH [hWnd]
        CALL ListView_SetItemText
        
        LEA EAX, [dwMemEnd]
        PUSH EAX
        PUSH OFFSET pszFormatStringIntHEX
        PUSH EBX
        CALL wvsprintf    
        
        PUSH EBX
        PUSH 3
        PUSH [dwCount]
        PUSH [hWnd]
        CALL ListView_SetItemText        
        
     @DllsView_LoopTest:
     
        ; Test For Exit Loop
        MOV EAX, [dwCurrent]
        
        TEST EAX, EAX
        JZ @DllsView_CantGetProcInfo
        
        CMP EAX, [dwStart]
        JNE @DllsView_TheDllLoop
    
    
   @DllsView_CantGetProcInfo: 
    PUSH [hProcess]
    CALL CloseHandle
    
   @DllsView_CantOpen:
   
    MOV [Process32.dwSize], size PROCESSENTRY32
    LEA  EAX, [Process32]
  
    PUSH EAX
    PUSH [hToolHelp]
    CALL Process32Next
  
    TEST EAX, EAX
    JNZ @DllsView_TheProcessLoop
    
 @DllsView_Exit:
 
  PUSH [hToolHelp]
  CALL CloseHandle
  
  ADD ESP, 528
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
DllsView_Refresh ENDP



;*********************************************************
; DllsView_Sort
;
;
;  Registers The Window Class
;
;*********************************************************
DllsView_Sort PROC hWnd:DWORD, iCol:DWORD

  MOV AL, [gSortType]
  INC AL
  MOV [gSortType], AL
  
  TEST AL, 1
  JE @DllsView_SortOpposite
  
  MOV EAX, [iCol]
  
  CMP EAX, 1
  JE SHORT @DllsView_SortByNumber
  
  
  PUSH [iCol]
  PUSH ListView_CompareStr
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @DllsView_Exit
  
 @DllsView_SortByNumber:  
 
  PUSH [iCol]
  PUSH ListView_CompareNum
  PUSH [hWnd]
  CALL ListView_SortEx 
 
 @DllsView_Exit:  
  RET
 
 @DllsView_SortOpposite:
  MOV EAX, [iCol]
  
  CMP EAX, 1
  JE SHORT @DllsView_SortByNumberDecsend

  
  PUSH [iCol]
  PUSH ListView_CompareStrDecsend
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @DllsView_Exit
  
 @DllsView_SortByNumberDecsend:  
 
  PUSH [iCol]
  PUSH ListView_CompareNumDecsend
  PUSH [hWnd]
  CALL ListView_SortEx 
  RET
  
DllsView_Sort ENDP



;*********************************************************
; DllsView_ClickFunction
;
;
;  Registers The Window Class
;
;*********************************************************
DllsView_ClickFunction PROC hWnd:DWORD, hWndListView:DWORD, iItem:DWORD, iSubItem:DWORD
  RET
DllsView_ClickFunction ENDP


;*********************************************************
; DllsView_Commands
;
;
;  Registers The Window Class
;
;*********************************************************
DllsView_Commands PROC hWnd:DWORD, hWndListView:DWORD, iCmd:DWORD
  RET
DllsView_Commands ENDP


;*********************************************************
; DllsView_Hide
;
;
;  Registers The Window Class
;
;*********************************************************
DllsView_Hide PROC hWnd:DWORD, hWndListView:DWORD
  RET
DllsView_Hide ENDP









