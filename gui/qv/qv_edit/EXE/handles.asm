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
; Handle_Create
;
;
;  Creates the Process View List View
;
;*********************************************************
Handle_Create PROC

  ; Create The Child Window
  CALL ListView_CreateListViewWindow

  MOV EBX, EAX
  PUSH EAX
  PUSH EAX
  CALL ListView_SetExtendedListViewStyle
 
  ; Create The Columns
  PUSH OFFSET pszHandlePid
  PUSH 0
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszHandleName
  PUSH 1
  PUSH EBX 
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszHandleTypeName
  PUSH 2
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszHandleNumber
  PUSH 3
  PUSH EBX 
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszHandleFlags
  PUSH 4
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszHandleObject
  PUSH 5
  PUSH EBX 
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszHandlePort
  PUSH 6
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH EBX
  CALL HandView_Refresh
  
  POP EAX
  RET
Handle_Create ENDP



;*********************************************************
; HandView_Refresh
;
;

;*********************************************************
HandView_Refresh PROC hWnd:DWORD
LOCAL pModule    :DWORD
LOCAL pModInfo   :DWORD
LOCAL dwCount    :DWORD           
LOCAL dwSystemLength :DWORD
LOCAL dwShortToLong  :DWORD
LOCAL dwTempLong     :DWORD
LOCAL hProcHandle    :DWORD
LOCAL hObject        :DWORD
LOCAL dwOldEBX       :DWORD
LOCAL SockAddr4       :sockaddr_in
LOCAL SockAddr2      :sockaddr_in
LOCAL SockAddr       :sockaddr_in
LOCAL dwReturnSize   :DWORD
LOCAL dwPossiblePort :DWORD

  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  XOR EDX, EDX
  MOV EBX, size SYSTEM_HANDLE_INFORMATION
  MOV EAX, [gHandleNum]
  
  MUL EBX
  
  ADD EAX, 4  
  MOV [dwSystemLength], EAX
  
  SUB ESP, 16
  MOV EBX, ESP
  
  PUSH [hWnd]
  CALL ListView_DeleteAll
   
  MOV [pModule], 0
  
 @HandView_ReAllocate:
  
  MOV EAX, [pModule]
  TEST EAX, EAX
  JZ @HandView_FirstTime
  
  PUSH EAX
  CALL LocalFree
  
 @HandView_FirstTime:
  
  MOV EAX, [dwSystemLength]
  ADD EAX, size SYSTEM_HANDLE_INFORMATION * 10
  MOV [dwSystemLength], EAX
  
  PUSH EAX
  PUSH LMEM_ZEROINIT
  CALL LocalAlloc
  
  MOV [pModule], EAX
  
  PUSH 0
  PUSH [dwSystemLength]
  MOV EAX, [pModule]
  PUSH EAX
  PUSH SystemHandleInformation
  CALL [NtQuerySystemInformation]
  
  CMP EAX, 0C0000004h
  JE @HandView_ReAllocate
  
  CMP EAX, 0
  JL @HandView_ExitWithFree
  
  MOV EAX, [pModule]
  MOV ECX, [EAX]
  ADD EAX, 4
  MOV [pModInfo], EAX
  MOV [dwCount], 0
  
 @HandView_ModuleListLoop:
    CMP ECX, 0
    JE @HandView_ExitWithFree
    
    PUSH ECX
    
    MOV EAX, [pModInfo]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf 
    
    
    MOV [gLci.imask], LVIF_TEXT       ; PID
    MOV [gLci.pszText], EBX
    
    PUSH OFFSET gLci
    PUSH [hWnd]
    CALL ListView_InsertItem 
    
    MOV [dwCount], EAX  

    MOV EAX, [pModInfo]
    XOR EDX, EDX
    MOV DL, [EAX + 5]                 ; Flags
    MOV [dwShortToLong], EDX
    LEA EAX, [dwShortToLong]

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
    LEA EAX, [EAX +  6]                   ; Handle
    MOV AX, [EAX]
    MOVZX EAX, AX
    MOV [dwShortToLong], EAX
   
    PUSH EBX
    MOV [dwOldEBX], EBX
    SUB ESP, 512                         ; Get Handle Name And Crap
    MOV EBX, ESP
    
    MOV EAX, [pModInfo]
    MOV EAX, [EAX]
    
    PUSH EAX
    PUSH 0
    PUSH PROCESS_DUP_HANDLE
    CALL OpenProcess
    MOV [hProcHandle], EAX
    
    TEST EAX, EAX
    JZ @HandView_SkipHandleInfo

    PUSH DUPLICATE_SAME_ATTRIBUTES
    PUSH 0
    PUSH 0
    LEA EAX, [hObject]
    MOV DWORD PTR [EAX], 0
    PUSH EAX
    CALL GetCurrentProcess
    PUSH EAX
    PUSH [dwShortToLong]
    PUSH [hProcHandle]
    CALL [ZwDuplicateObject]
    
    PUSH EAX
    
    PUSH [hProcHandle]
    CALL CloseHandle
    
    POP EAX
    
    CMP EAX, 0
    JL @HandView_SkipWithClose
    
    MOV [dwPossiblePort], 0
    
    ; HandView_IsFileW  For Future - Attempt to use this?
    
    MOV EAX, [pModInfo]
    CMP DWORD PTR [EAX + 12], 01f01ffh    ; *SOME* Sync Objects can cause deadlock! 
                                          ; I want to find Objects that may possibly be
                                          ; port objects.
                                          
                                          ;
                                          ; TODO: Tweak this access check.
                                          ;
                                          
    JNE @HandView_NoPortInfo
    
    ; PUSH 10
    ; PUSH [hObject]
    ; CALL WaitForSingleObject
    ; CMP EAX, WAIT_OBJECT_0              ; If the above isn't enough, I was going to try
    ; JNE @HandView_NoPortInfo            ; this.
                                          
    PUSH 0
    LEA EAX, [dwReturnSize]
    PUSH EAX
    PUSH size sockaddr_in * 3
    LEA EAX, [SockAddr]
    PUSH EAX
    PUSH 0
    PUSH 0
    PUSH  01202fh
    PUSH  [hObject]
    CALL DeviceIoControl
    
    TEST EAX, EAX
    JZ @HandView_NoPortInfo
    
    XOR EAX, EAX
    LEA EDX, [SockAddr]
    ADD EDX, 12
    MOV AH, [EDX]
    INC EDX
    MOV AL, [EDX]
    MOV [dwPossiblePort], EAX
   
   @HandView_NoPortInfo: 
    LEA EAX, [dwTempLong]
    PUSH EAX
    PUSH 512
    PUSH EBX                    ; Unicode String is appened to the END of the  structure.
    PUSH ObjectTypeInformation
    PUSH [hObject]
    CALL [ZwQueryObject]
    
    CMP EAX, 0
    JL @HandView_SkipWithCloseAndCloseObject
    
    CMP DWORD PTR [EBX + 4] , 0
    JZ @HandView_SkipWithCloseAndCloseObject
    

    MOV EAX, [EBX + 4]
    PUSH EAX
    PUSH 2
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemTextW     
    
    MOV WORD PTR [EBX], 500
    MOV WORD PTR [EBX + 2], 500
    LEA EAX, [EBX + 8]
    MOV [EBX + 4], EAX
    
  
    MOV EAX, [pModInfo]
    
    MOV EAX, [pModInfo]
  
    TEST DWORD PTR [EAX + 12], SYNCHRONIZE_ACCESS    ; *SOME* Sync Objects can cause deadlock! Unfortunately, this is the only way to
    JZ @HandView_Good                                ; tell right now, excluding all sync objects. 
    
    CMP DWORD PTR [EAX + 12], 01f01ffh               ; This seems to be OK access.
    JNE @HandView_SkipWithCloseAndCloseObject
     
   @HandView_Good:
    
    ; TODO: See if you can remove Sync Access or another way to get the
    ;       object name from user-mode without having to acquire the lock.
    ;       could be bad though and bluescreen?  Also, irrelevant if I
    ;       change this to use a driver. The driver would be able to
    ;       directly read the object's memory location in the kernel
    ;       and read the name directly from there without the need to lock.
    
    LEA EAX, [dwTempLong]
    MOV DWORD PTR [EAX], 0
    PUSH EAX
    PUSH 500
    PUSH EBX                    ; Unicode String is appened to the END of the UNICODE_STRING structure.
    PUSH ObjectNameInformation
    PUSH [hObject]
    CALL [ZwQueryObject]        
    
    ; TODO: Try ZwQueryInformationFile with "name".
    
    ; Sysinternals uses their own driver to do this and does not deadlock.
    ; If we aren't getting all the information, I may need to write a driver.
    ; TODO: Write a driver for this application, we need one anyway for
    ;       a force bluescreen option when Ctrl ScrollLock ScrollLock is not set.
    
    CMP EAX, 0
    JL @HandView_SkipWithCloseAndCloseObject
    
    MOV EAX, [EBX + 4]
    
    TEST EAX, EAX
    JZ @HandView_SkipWithCloseAndCloseObject
    
    PUSH EAX
    PUSH 1
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemTextW
     
    
   @HandView_SkipWithCloseAndCloseObject:
   
    MOV EAX, [pModInfo]
    
    TEST BYTE PTR [EAX + 5], 1    ; We need to fix this in order to close the handle.
    JZ @HandView_CloseIt        
    
    PUSH 0
    PUSH 0FFFFFFFEh
    PUSH [hObject]
    CALL SetHandleInformation     ; Clear the "protect from close" bit so we can close the handle.
    
  @HandView_CloseIt:
    PUSH [hObject]
    CALL CloseHandle
    
   @HandView_SkipWithClose:
   @HandView_SkipHandleInfo:
    ADD ESP, 512
    POP EBX
    LEA EAX, [dwShortToLong]
    
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
    LEA EAX, [EAX + 8]                    ; Kernel Info
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 5
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText      

    LEA EAX, [dwPossiblePort]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 6
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText 
    
    MOV EAX, [pModInfo]
    ADD EAX, size SYSTEM_HANDLE_INFORMATION
    MOV [pModInfo], EAX
    
  
    POP ECX
    DEC ECX
    JMP @HandView_ModuleListLoop
  
 @HandView_ExitWithFree:
  MOV EAX, [pModule]
  PUSH EAX
  CALL LocalFree
  
 @HandView_Exit:
  ADD ESP, 16
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
HandView_Refresh ENDP





;*********************************************************
; HandView_Sort
;
;
;  Registers The Window Class
;
;*********************************************************
HandView_Sort PROC hWnd:DWORD, iCol:DWORD

  MOV AL, [gSortType]
  INC AL
  MOV [gSortType], AL
  
  TEST AL, 1
  JE @HandView_SortOpposite
  
  MOV EAX, [iCol]
  
  CMP EAX, 0
  JE SHORT @HandView_SortByNumber
  
  CMP EAX, 6
  JE SHORT @HandView_SortByNumber  
  

  PUSH [iCol]
  PUSH ListView_CompareStr
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @HandView_Exit
  
 @HandView_SortByNumber:  
 
  PUSH [iCol]
  PUSH ListView_CompareNum
  PUSH [hWnd]
  CALL ListView_SortEx 
 
 @HandView_Exit:  
  RET
 
 @HandView_SortOpposite:
  MOV EAX, [iCol]
  
  CMP EAX, 0
  JE SHORT @HandView_SortByNumberDecsend
  
  CMP EAX, 6
  JE SHORT @HandView_SortByNumberDecsend

  PUSH [iCol]
  PUSH ListView_CompareStrDecsend
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @HandView_Exit
  
 @HandView_SortByNumberDecsend:  
 
  PUSH [iCol]
  PUSH ListView_CompareNumDecsend
  PUSH [hWnd]
  CALL ListView_SortEx 
  RET
  
HandView_Sort ENDP



;*********************************************************
; HandView_ClickFunction
;
;
;  Registers The Window Class
;
;*********************************************************
HandView_ClickFunction PROC hWnd:DWORD, hWndListView:DWORD, iItem:DWORD, iSubItem:DWORD
  RET
HandView_ClickFunction ENDP


;*********************************************************
; HandView_Commands
;
;
;  Registers The Window Class
;
;*********************************************************
HandView_Commands PROC hWnd:DWORD, hWndListView:DWORD, iCmd:DWORD
  RET
HandView_Commands ENDP


;*********************************************************
; HandView_Hide
;
;
;  Registers The Window Class
;
;*********************************************************
HandView_Hide PROC hWnd:DWORD, hWndListView:DWORD
  RET
HandView_Hide ENDP



;*********************************************************
; HandView_IsFileW
;
;
;  Check for files before attempting to query for socket
;
;*********************************************************
;HandView_IsFileW PROC pszwName :DWORD
;LOCAL dwRetValue :DWORD
;
;
; MOV [dwRetValue], 0
; PUSH EBX
; MOV EAX, [pszwName]
;@HandView_LoopHere:
;   MOV BX, [EAX]
; 
;   TEST BX, BX
;   JZ @HandView_Done
;   
;   CMP BL, 'f'
;   JE @HandView_CheckTheI
;   
;   CMP BL, 'F'
;   JE @HandView_CheckTheI
;   
;   JMP @HandView_Nope_Lets_Loop
;   
;  @HandView_CheckTheI:
;   MOV BX, [EAX + 2]
;   
;   TEST BX, BX
;   JZ @HandView_Done
;  
;   CMP BL, 'i'
;   JE @HandView_CheckTheP
;   
;   CMP BL, 'I'
;   JE @HandView_CheckTheP
;   
;   JMP @HandView_Nope_Lets_Loop
;   
;  @HandView_CheckTheP:
;   MOV BX, [EAX + 4]
;   
;   TEST BX, BX
;   JZ @HandView_Done
;  
;   CMP BL, 'L'
;   JE @HandView_CheckTheE
;   
;   CMP BL, 'l'
;   JE @HandView_CheckTheE
;   
;   JMP @HandView_Nope_Lets_Loop
;   
;  @HandView_CheckTheE:
;   MOV BX, [EAX + 6]
;   
;   TEST BX, BX
;   JZ @HandView_Done
;   
;   CMP BL, 'E'
;   JE @HandView_ThatsTheOne
;   
;   CMP BL, 'e'
;   JNE @HandView_Nope_Lets_Loop
;   
;  @HandView_ThatsTheOne:
;   
;   MOV [dwRetValue], 1
;    
;   JMP @HandView_Done
;   
;  @HandView_Nope_Lets_Loop:
;   
;   ADD EAX, 2
;   
;   JMP @HandView_LoopHere
;
;@HandView_Done:
; 
; POP EBX
; MOV EAX, [dwRetValue]
; 
; RET
;HandView_IsFileW ENDP


;*********************************************************
; HandView_IsPipeW
;
;
;  Check For Pipes, Pipes can cause deadlocks.
;   NOT NEEDED ANYMORE - Changed to checking for SYNC
;   flag because more than just Pipes can cause deadlocks
;   and we can deadlock before we can get the name of the object.
;
;*********************************************************
;HandView_IsPipeW PROC pszwName :DWORD
;LOCAL dwRetValue :DWORD
 

 ;MOV [dwRetValue], 0
; PUSH EBX
; MOV EAX, [pszwName]
;@HandView_LoopHere:
;   MOV BX, [EAX]
; 
;   TEST BX, BX
;   JZ @HandView_Done
;   
;   CMP BL, 'p'
;   JE @HandView_CheckTheI
;   
;   CMP BL, 'P'
;   JE @HandView_CheckTheI
;   
;   JMP @HandView_Nope_Lets_Loop
;   
;  @HandView_CheckTheI:
;   MOV BX, [EAX + 2]
;   
;   TEST BX, BX
;   JZ @HandView_Done
;   
;   CMP BL, 'i'
;   JE @HandView_CheckTheP
;   
;   CMP BL, 'I'
;   JE @HandView_CheckTheP
;   
;   JMP @HandView_Nope_Lets_Loop
;   
;  @HandView_CheckTheP:
;   MOV BX, [EAX + 4]
;   
 ;  TEST BX, BX
 ;  JZ @HandView_Done
 ; 
 ;  CMP BL, 'P'
 ;;  JE @HandView_CheckTheE
 ;  
 ;  CMP BL, 'p'
 ;  JE @HandView_CheckTheE
 ;  
 ;  JMP @HandView_Nope_Lets_Loop
   
;  @HandView_CheckTheE:
;   MOV BX, [EAX + 6]
;   
;   TEST BX, BX
;   JZ @HandView_Done
;   
;   CMP BL, 'E'
;   JE @HandView_ThatsTheOne
;   
 ;  CMP BL, 'e'
 ;  JNE @HandView_Nope_Lets_Loop
 ;  
 ; @HandView_ThatsTheOne:
 ;  
;   MOV [dwRetValue], 1
;   
 ;  JMP @HandView_Done
 ;  
 ; @HandView_Nope_Lets_Loop:
 ;  
 ;  ADD EAX, 2
 ;  
 ;;  JMP @HandView_LoopHere
 ;
;@HandView_Done:
; 
; POP EBX
; MOV EAX, [dwRetValue]
; 
; RET
;HandView_IsPipeW ENDP







