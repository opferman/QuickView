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
; ProcView_Create
;
;
;  Creates the Process View List View
;
;*********************************************************
Process_Create PROC
 
  ; Create The Child Window
  CALL ListView_CreateListViewWindow

  MOV EBX, EAX
  PUSH EAX
  PUSH EAX
  CALL ListView_SetExtendedListViewStyle
  
  PUSH OFFSET pszProcessText
  PUSH 0
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszPIDText
  PUSH 1
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszParentPIDText
  PUSH 2
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszThreadsText
  PUSH 3
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszHandleCountText
  PUSH 4
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszSessionText
  PUSH 5
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszVirtualText
  PUSH 6
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszWorkingSet
  PUSH 7
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszPageFileText
  PUSH 8
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszPagedPoolText
  PUSH 9
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszNPPoolText
  PUSH 10
  PUSH EBX
  CALL ListView_CreateColoumn
  

  PUSH EBX
  CALL ProcView_Refresh
  
  POP EAX
  RET
Process_Create ENDP



;*********************************************************
; Process_GetWindowHandle
;
;
;*********************************************************
;Process_GetWindowHandle PROC
;  MOV EAX, [ghWndLVProcess]
;  RET
;Process_GetWindowHandle ENDP

;*********************************************************
; ProcView_Refresh
;
;
; NOTICE: I have used every attempt to get as much information
;         as I could without using WINSTA* APIs.  This way,
;         if Taskmanager does not function, I can still
;         get a process list when TS is down or RPC is messed up.
;
;         Do not add any WINSTA calls here!!!  The purpose
;         is not to REPLACE TASK MANAGER but to SUPPLIEMENT IT!
;
;*********************************************************
ProcView_Refresh PROC hWnd:DWORD
LOCAL hToolHelp :DWORD
LOCAL Process32 :PROCESSENTRY32
LOCAL dwCurItem :DWORD
LOCAL hProcess  :DWORD
LOCAL dwHandles :DWORD
LOCAL dwSession :DWORD
LOCAL VmCounter :VM_COUNTERS
  MOV [gHandleNum], 0
  PUSH [hWnd]
  CALL ListView_DeleteAll
  
  PUSH 0
  PUSH TH32CS_SNAPPROCESS
  CALL CreateToolhelp32Snapshot
  
  MOV [hToolHelp], EAX
  
  MOV [Process32.dwSize], size PROCESSENTRY32
  
  LEA  EBX, [Process32]
  
  PUSH EBX
  PUSH EAX
  CALL Process32First
  
@ProcView_CreateList:  
    
    MOV [gLci.imask], LVIF_TEXT
    LEA EAX, [Process32.szExeFile]
    MOV [gLci.pszText], EAX
    
    PUSH OFFSET gLci
    PUSH [hWnd]
    CALL ListView_InsertItem   ; Process Name
    
    MOV [dwCurItem], EAX
    
    SUB ESP, 16
    
    MOV EBX, ESP
    
    LEA EAX,[Process32.th32ProcessID]
    PUSH EAX    
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf
    
    PUSH EBX
    PUSH 1
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; PID


    LEA EAX,[Process32.th32ParentProcessID]
    PUSH EAX
    
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf

    PUSH EBX
    PUSH 2
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Parent PID

    LEA EAX, [Process32.cntThreads]
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf

    PUSH EBX
    PUSH 3
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; # of Threads
   
    XOR EAX, EAX
    MOV AL, '?'
    
    MOV [dwHandles], EAX
    MOV [dwSession], EAX
    MOV [VmCounter.VirtualSize], EAX
    MOV [VmCounter.QuotaPagedPoolUsage], EAX
    MOV [VmCounter.QuotaNonPagedPoolUsage], EAX
    MOV [VmCounter.WorkingSetSize], EAX
    MOV [VmCounter.PagefileUsage], EAX
    
    PUSH [Process32.th32ProcessID]
    PUSH 0
    PUSH PROCESS_QUERY_INFORMATION
    CALL OpenProcess
    
    TEST EAX, EAX
    JZ @ProcView_SkipNtQuery
    MOV [hProcess], EAX
    
    PUSH 0
    PUSH 4
    LEA EAX, [dwHandles]
    PUSH EAX
    PUSH ProcessHandleCount
    PUSH [hProcess]
    CALL [NtQueryInformationProcess]
    
    
    PUSH 0
    PUSH 4
    LEA EAX, [dwSession]
    PUSH EAX
    PUSH ProcessSessionInformation
    PUSH [hProcess]
    CALL [NtQueryInformationProcess]    

    PUSH 0
    PUSH size VM_COUNTERS
    LEA EAX, [VmCounter]
    PUSH EAX
    PUSH ProcessVmCounters
    PUSH [hProcess]
    CALL [NtQueryInformationProcess]        
    
    PUSH EAX
    
    PUSH [hProcess]
    CALL CloseHandle
    
    POP EAX
    CMP EAX, 0
    JL @ProcView_SkipNtQuery

   
;;;; # of Handles Get Here!!  
    MOV EAX, [dwHandles]
    ADD [gHandleNum], EAX
      
    LEA EAX, [dwHandles]
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf

    PUSH EBX
    PUSH 4
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; # of Handles
    
    
    LEA EAX, [dwSession]
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 5
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session    
    
    
     
    
    LEA EAX, [VmCounter.VirtualSize] ; 
    SHR DWORD PTR [EAX], 10
    PUSH EAX
    PUSH OFFSET pszFormatStringIntK
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 6
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session  
    
    LEA EAX, [VmCounter.WorkingSetSize]
    SHR DWORD PTR [EAX], 10
    PUSH EAX
    PUSH OFFSET pszFormatStringIntK
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 7
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session 
    

    LEA EAX, [VmCounter.PagefileUsage] ; 
    SHR DWORD PTR [EAX], 10
    PUSH EAX
    PUSH OFFSET pszFormatStringIntK
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 8
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session 
            
    LEA EAX, [VmCounter.QuotaPagedPoolUsage]
    SHR DWORD PTR [EAX], 10
    PUSH EAX
    PUSH OFFSET pszFormatStringIntK
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 9
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session  
    
    
    LEA EAX, [VmCounter.QuotaNonPagedPoolUsage]
    SHR DWORD PTR [EAX], 10
    PUSH EAX
    PUSH OFFSET pszFormatStringIntK
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 10
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session   
    

       
    
    JMP  @ProcView_SkipNtQueryDone
    
  @ProcView_SkipNtQuery:
    LEA EAX, [dwHandles]
    
    PUSH EAX
    PUSH 4
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; # of Handles
    
    LEA EAX, [dwSession]
    
    PUSH EAX
    PUSH 5
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session   
    
    LEA EAX, [VmCounter.VirtualSize]
    
    PUSH EAX
    PUSH 6
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session 
    
    LEA EAX, [VmCounter.WorkingSetSize]
    
    PUSH EAX
    PUSH 7
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session 
    
    
    LEA EAX, [VmCounter.PagefileUsage]
    
    PUSH EAX
    PUSH 8
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session    
    
    LEA EAX, [VmCounter.QuotaPagedPoolUsage]
    
    PUSH EAX
    PUSH 9
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session 

    LEA EAX, [VmCounter.QuotaNonPagedPoolUsage]
    
    PUSH EAX
    PUSH 10
    PUSH [dwCurItem]
    PUSH [hWnd]
    CALL ListView_SetItemText  ; Session 
    
    

    
  @ProcView_SkipNtQueryDone:

    ADD ESP, 16
    
    MOV [Process32.dwSize], size PROCESSENTRY32
    
    LEA EBX, [Process32]
    PUSH EBX
    PUSH [hToolHelp]
    CALL Process32Next
  
    TEST EAX, EAX
    JNZ @ProcView_CreateList
  
  PUSH [hToolHelp]
  CALL CloseHandle
  
 @ProcView_Exit:
  RET
ProcView_Refresh ENDP








;*********************************************************
; ProcView_Sort
;
;
;  Registers The Window Class
;
;*********************************************************
ProcView_Sort PROC hWnd:DWORD, iCol:DWORD

  MOV AL, [gSortType]
  INC AL
  MOV [gSortType], AL
  
  TEST AL, 1
  JE @ProcView_SortOpposite
  
  MOV EAX, [iCol]
  
  CMP EAX, 0
  JNE SHORT @ProcView_SortByNumber
  
  PUSH [iCol]
  PUSH ListView_CompareStr
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @ProcView_Exit
  
 @ProcView_SortByNumber:  
 
  PUSH [iCol]
  PUSH ListView_CompareNum
  PUSH [hWnd]
  CALL ListView_SortEx 
 
 @ProcView_Exit:  
  RET
 
 @ProcView_SortOpposite:
  MOV EAX, [iCol]
  
  CMP EAX, 0
  JNE SHORT @ProcView_SortByNumberDecsend
  
  PUSH [iCol]
  PUSH ListView_CompareStrDecsend
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @ProcView_Exit
  
 @ProcView_SortByNumberDecsend:  
 
  PUSH [iCol]
  PUSH ListView_CompareNumDecsend
  PUSH [hWnd]
  CALL ListView_SortEx 
  RET
  
ProcView_Sort ENDP



;*********************************************************
; ProcView_ClickFunction
;
;
;  Registers The Window Class
;
;*********************************************************
ProcView_ClickFunction PROC hWnd:DWORD, hWndListView:DWORD, iItem:DWORD, iSubItem:DWORD
LOCAL CursorPosition :POINT
  PUSH EBX
  
  PUSH OFFSET pszMenuString
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
ProcView_ClickFunction ENDP


;*********************************************************
; ProcView_Commands
;
;
;  Registers The Window Class
;
;*********************************************************
ProcView_Commands PROC hWnd:DWORD, hWndListView:DWORD, iCmd:DWORD
LOCAL lvItem     :LVITEM
LOCAL iNumSelect :DWORD
LOCAL hKey       :DWORD
LOCAL iSize      :DWORD
LOCAL ProcInfo   :PROCESS_INFORMATION
LOCAL StartInfo  :STARTUPINFO

  PUSH EDX
  PUSH ECX
  PUSH EBX


  MOV EAX, [iCmd]
  
  CMP EAX, IDM_PROCTERM
  JE @ProcView_ProcessTerm
  
  CMP EAX, IDM_PROCINFO
  JE @ProcView_ProcInfo
  
  CMP EAX, IDM_PROCDEBUG
  JE @ProcView_ProcDebug
  
  JMP @ProcView_ExitWithOutHassle 
  
 @ProcView_ProcDebug:
  PUSH MB_YESNO
  PUSH OFFSET pszDebugProcessesCap
  PUSH OFFSET pszDebugProcessesMsg
  PUSH [hWnd]
  CALL MessageBox
  
  CMP EAX, IDNO
  JE @ProcView_Exit
  
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
  
 @ProcView_DebugLoop:
  CMP ECX, [iNumSelect]
  JE @ProcView_Exit
    PUSH ECX
    
    LEA EAX, [lvItem]
    PUSH EAX
    PUSH [hWndListView]
    CALL ListView_GetItem
    
    TEST EAX, EAX
    JZ @ProcView_Exit
    POP ECX
    
    CMP [lvItem.state], LVIS_SELECTED
    JNE @ProcView_ContinueDebugLoop
    
    PUSH ECX
    
    SUB ESP, 256
    MOV EDX, ESP
    
    PUSH 256
    PUSH EDX
    PUSH 1
    PUSH [lvItem.iItem]
    PUSH [ghWndLVCurrent]
    CALL ListView_GetText  
    
    PUSH EDX
    CALL ListView_StrToNum        ; Here we convert the PID to a number.
    ADD ESP, 256
    
    MOV EBX, EAX
    
    LEA  EAX, [hKey]
    PUSH EAX
    PUSH KEY_READ
    PUSH 0
    PUSH OFFSET pszDebugKey
    PUSH HKEY_LOCAL_MACHINE 
    CALL RegOpenKeyEx
    
    TEST EAX, EAX
    JNZ @ProcView_CleanUpAndExit
    
    MOV [iSize], 256
    SUB ESP, 256
    MOV EDX, ESP
    LEA EAX, [iSize]
    
    PUSH EDX
    
    PUSH EAX
    PUSH EDX
    PUSH 0
    PUSH 0
    PUSH OFFSET pszDebugValue
    PUSH [hKey]
    CALL RegQueryValueEx
    POP EDX
    TEST EAX, EAX
    JNZ @ProcView_CleanUpAndExitBloated
    
    SUB ESP, 256
    MOV EAX, ESP
    
    PUSH EAX
    
    PUSH 1     ; Event Signal, Change this????
    PUSH EBX
    PUSH EDX
    PUSH EAX
    CALL wsprintfA
    ADD ESP, 10h
    
    MOV ECX, size STARTUPINFO
    LEA EDI, StartInfo
    XOR EAX, EAX
    REP STOSB
    
    MOV [StartInfo.cb], size STARTUPINFO
    
    POP EAX
    LEA EDX, [ProcInfo]
    PUSH EDX
    LEA EDX, [StartInfo]
    PUSH EDX
    PUSH 0
    PUSH 0
    PUSH 0
    PUSH 0
    PUSH 0
    PUSH 0
    PUSH EAX
    PUSH 0
    CALL CreateProcess
    ADD ESP, 512 
    
    MOV EAX, [ProcInfo.hProcess]
    TEST EAX, EAX
    JZ @ProcView_FuckIt
    
    PUSH EAX
    CALL CloseHandle
    
   @ProcView_FuckIt:
    PUSH [hKey]
    CALL RegCloseKey
    
    POP ECX
    INC ECX
    
  @ProcView_ContinueDebugLoop:
    INC [lvItem.iItem]
    
  JMP @ProcView_DebugLoop
  
 @ProcView_CleanUpAndExitBloated:
  ADD ESP, 256
  PUSH [hKey]
  CALL RegCloseKey
  
 @ProcView_CleanUpAndExit:
  ADD ESP, 12
  JMP @ProcView_DebugLoop
    
    
 @ProcView_ProcessTerm:
  
  PUSH MB_YESNO
  PUSH OFFSET pszTerminateProcessesCap
  PUSH OFFSET pszTerminateProcessesMsg
  PUSH [hWnd]
  CALL MessageBox
  
  CMP EAX, IDNO
  JE @ProcView_Exit
  
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
  
 @ProcView_Loop:
  CMP ECX, [iNumSelect]
  JE @ProcView_Exit
  
    LEA EAX, [lvItem]
    PUSH EAX
    PUSH [hWndListView]
    CALL ListView_GetItem
    
    TEST EAX, EAX
    JZ @ProcView_Exit
    
    CMP [lvItem.state], LVIS_SELECTED
    JNE @ProcView_ContinueLoop
    
    SUB ESP, 256
    MOV EDX, ESP
    
    PUSH 256
    PUSH EDX
    PUSH 1
    PUSH [lvItem.iItem]
    PUSH [ghWndLVCurrent]
    CALL ListView_GetText  
  
    PUSH EDX
    CALL ListView_StrToNum        ; Here we convert the PID to a number.
    ADD ESP, 256
    
    MOV EBX, EAX
    
    PUSH EAX
    PUSH 0
    PUSH PROCESS_ALL_ACCESS
    CALL OpenProcess
    
    PUSH EAX
    
    PUSH 0
    PUSH EAX
    PUSH EBX
    CALL Process_SafeTerminateProcess
    
    CALL CloseHandle
    
    INC ECX
    
  @ProcView_ContinueLoop:
    INC [lvItem.iItem]
    
  JMP @ProcView_Loop
  
 @ProcView_ProcInfo:

  PUSH MB_OK
  PUSH OFFSET pszTemp
  PUSH OFFSET pszTemp
  PUSH [hWnd]
  CALL MessageBox
  
 @ProcView_Exit:
  PUSH [hWndListView]
  CALL ProcView_Refresh
  
 @ProcView_ExitWithOutHassle:
  XOR EAX, EAX
  
  POP EBX
  POP ECX
  POP EDX
  
  RET
ProcView_Commands ENDP




;*********************************************************
; Process_SafeTerminateProcess
;
;
;  "Safe" terminate is a relative assessment.  This function is
; assuming the Kernel32's ExitProcess() is mapped to the same
; virtual memory location as the current process's.  This is
; not always the case, we CAN use "TerminateProcess" instead
; if this is the case majority of the time.  We could also
; modify the code to attempt to locate ExitProcess() in the
; remote process as well.
;
;
;*********************************************************
Process_SafeTerminateProcess PROC dwPid :DWORD, hProcess:DWORD, uExitCode:DWORD
  LOCAL hHandle :DWORD
  LOCAL dwId    :DWORD
  
  PUSH EBX
  
  PUSH OFFSET pszKernel32
  CALL GetModuleHandle
  
  MOV [hHandle], EAX
  
  PUSH OFFSET pszExitProcess
  PUSH EAX
  CALL GetProcAddress
  
  MOV EBX, EAX
  
  LEA EAX, [dwId]
  PUSH EAX
  PUSH 0
  PUSH [uExitCode]
  PUSH EBX
  PUSH 0
  PUSH 0
  MOV EAX, [hProcess]
  PUSH EAX
  CALL CreateRemoteThread
  
  TEST EAX, EAX
  JNZ @Process_Wait
  
 @Process_TerminateTheFucker:
  PUSH [uExitCode]
  PUSH [hProcess]
  CALL TerminateProcess
  
  TEST EAX, EAX
  JZ @Process_TerminateUsingWinstationCommands
  
 @Process_Wait: 
  PUSH INFINITE
  PUSH [hProcess]
  CALL WaitForSingleObject
  
  XOR EAX, EAX
  
 @Process_Exit:
  POP EBX

  RET
  
 @Process_TerminateUsingWinstationCommands:
  PUSH OFFSET pszWinsta
  CALL LoadLibrary
  
  TEST EAX, EAX 
  JZ @Process_Exit
  
  PUSH EAX
  
  PUSH OFFSET pszWinstaTermProc
  PUSH EAX
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @Process_FreeWinsta
  
  PUSH 0
  PUSH [dwPid]
  PUSH 0
  CALL EAX
  
 @Process_FreeWinsta:
  CALL FreeLibrary
  JMP @Process_Exit
 
 
Process_SafeTerminateProcess ENDP



;*********************************************************
; ProcView_Hide
;
;
;  Registers The Window Class
;
;*********************************************************
ProcView_Hide PROC hWnd:DWORD, hWndListView:DWORD
  RET
ProcView_Hide ENDP




