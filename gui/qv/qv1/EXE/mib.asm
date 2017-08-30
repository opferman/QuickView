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
; Mib_Create
;
;
;  Creates the Process View List View
;
;*********************************************************
Mib_Create PROC

  ; Create The Child Window
  CALL ListView_CreateListViewWindow

  MOV EBX, EAX
  PUSH EAX
  PUSH EAX
  CALL ListView_SetExtendedListViewStyle
 
  ; Create The Columns
  PUSH OFFSET pszLocalAddress
  PUSH 0
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszLocalPort
  PUSH 1
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszRemoteAddress
  PUSH 2
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszRemotePort
  PUSH 3
  PUSH EBX 
  CALL ListView_CreateColoumn

  PUSH OFFSET pszState
  PUSH 4
  PUSH EBX
  CALL ListView_CreateColoumn

  PUSH OFFSET pszConnectType
  PUSH 5
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH OFFSET pszTcpUdpPid
  PUSH 6
  PUSH EBX
  CALL ListView_CreateColoumn
  
  PUSH EBX
  CALL MibView_Refresh
  
  POP EAX
  RET
Mib_Create ENDP


;*********************************************************
; MibView_Refresh
;
;

;*********************************************************
MibView_Refresh PROC hWnd:DWORD
  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  PUSH [hWnd]
  CALL ListView_DeleteAll
  
  CMP [AllocateAndGetTcpExTableFromStack], 0
  JNE @MibView_TCPWITHPID
  
  PUSH [hWnd]
  CALL MibView_TCP
   
  JMP @MibView_DoUdp
  
 @MibView_TCPWITHPID:
  
  PUSH [hWnd]
  CALL MibView_TcpEx
  
 @MibView_DoUdp:
 
  CMP [AllocateAndGetUdpExTableFromStack], 0
  JNE @MibView_UDPWITHPID
  
  PUSH [hWnd]
  CALL MibView_UDP  
  
  JMP @MibView_Done
  
 @MibView_UDPWITHPID:
 
  PUSH [hWnd]
  CALL MibView_UdpEx
 
 @MibView_Done:
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
MibView_Refresh ENDP



;*********************************************************
; MibView_TCP
;
;

;*********************************************************
MibView_TCP PROC hWnd:DWORD
LOCAL pTcpTable   :DWORD
LOCAL pTcpPointer :DWORD
LOCAL dwTcpSize   :DWORD
LOCAL dwCount     :DWORD           
LOCAL dwPort      :DWORD

  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  SUB ESP, 40
  MOV EBX, ESP

  LEA EAX, [dwTcpSize]
  MOV DWORD PTR [EAX], 0
  
  PUSH 0
  PUSH EAX
  PUSH 0
  CALL [MIB_GetTcpTable]
  
  MOV EAX, [dwTcpSize]
  
  TEST EAX, EAX
  JZ @MibView_Exit
  
  ADD EAX, 4
  PUSH EAX
  PUSH LMEM_ZEROINIT
  CALL LocalAlloc
  
  MOV [pTcpTable], EAX
  
  PUSH 1
  LEA EAX, [dwTcpSize]
  PUSH EAX
  PUSH [pTcpTable]
  CALL [MIB_GetTcpTable]
  
  TEST EAX, EAX
  JNZ @MibView_ExitWithFree
  
  MOV EAX, [pTcpTable]
  MOV ECX, [EAX]
  
  ADD EAX, 4
  MOV [pTcpPointer], EAX
  
  MOV [dwCount], 0
  
 @MibView_TcpListLoop:
    CMP ECX, 0
    JE @MibView_ExitWithFree
    
    PUSH ECX
    
    MOV EAX, [pTcpPointer]
    
    PUSH [EAX + 4]
    PUSH EBX
    CALL Mib_CreateIPAddress
    
    
    MOV [gLci.imask], LVIF_TEXT
    MOV [gLci.pszText], EBX
    
    PUSH OFFSET gLci
    PUSH [hWnd]
    CALL ListView_InsertItem 
    
    MOV [dwCount], EAX
    
    MOV EAX, [pTcpPointer]
    MOV EAX, [EAX + 8]     ; Local Port
    XCHG AL, AH
    MOV [dwPort], EAX
    LEA EAX, [dwPort]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 1
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  

    MOV EAX, [pTcpPointer]
   
    PUSH [EAX + 12]             ; Remote Address
    PUSH EBX
    CALL Mib_CreateIPAddress
        
   
    PUSH EBX
    PUSH 2
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  


    MOV EAX, [pTcpPointer]
    MOV EAX, [EAX + 16]      ; Remote Port
    
    XCHG AL, AH
    MOV [dwPort], EAX
    LEA EAX, [dwPort]
        
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 3
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  
    
    MOV EAX, [pTcpPointer]
                              ; State
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 4
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText      
    
    PUSH OFFSET pszTcp
    PUSH 5
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText
    
    MOV EAX, [pTcpPointer]
    ADD EAX, size MIB_TCPROW
    MOV [pTcpPointer], EAX
    
  
    POP ECX
    DEC ECX
    JMP @MibView_TcpListLoop
  
 @MibView_ExitWithFree:
 
  MOV EAX, [pTcpTable]
  PUSH EAX
  CALL LocalFree
  
 @MibView_Exit:
  ADD ESP, 40
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
MibView_TCP ENDP



;*********************************************************
; MibView_TcpEx
;
;

;*********************************************************
MibView_TcpEx PROC hWnd:DWORD
LOCAL pTcpTable   :DWORD
LOCAL pTcpPointer :DWORD
LOCAL dwCount     :DWORD           
LOCAL dwPort      :DWORD

  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  SUB ESP, 40
  MOV EBX, ESP

  PUSH 2
  PUSH 0
  CALL GetProcessHeap
  PUSH EAX
  LEA EAX, [pTcpTable]
  PUSH 1
  PUSH EAX
  CALL [AllocateAndGetTcpExTableFromStack]
  
  TEST EAX, EAX
  JNZ @MibView_ExitWithFree
  
  MOV EAX, [pTcpTable]
  MOV ECX, [EAX]
  
  ADD EAX, 4
  MOV [pTcpPointer], EAX
  
  MOV [dwCount], 0
  
 @MibView_TcpListLoop:
    CMP ECX, 0
    JE @MibView_ExitWithFree
    
    PUSH ECX
    
    MOV EAX, [pTcpPointer]
    
    PUSH [EAX + 4]
    PUSH EBX
    CALL Mib_CreateIPAddress
    
    
    MOV [gLci.imask], LVIF_TEXT
    MOV [gLci.pszText], EBX
    
    PUSH OFFSET gLci
    PUSH [hWnd]
    CALL ListView_InsertItem 
    
    MOV [dwCount], EAX
    
    MOV EAX, [pTcpPointer]
    MOV EAX, [EAX + 8]     ; Local Port
    XCHG AL, AH
    MOV [dwPort], EAX
    LEA EAX, [dwPort]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 1
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  

    MOV EAX, [pTcpPointer]
   
    PUSH [EAX + 12]             ; Remote Address
    PUSH EBX
    CALL Mib_CreateIPAddress
        
   
    PUSH EBX
    PUSH 2
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  


    MOV EAX, [pTcpPointer]
    MOV EAX, [EAX + 16]      ; Remote Port
    
    XCHG AL, AH
    MOV [dwPort], EAX
    LEA EAX, [dwPort]
        
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 3
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  
    
    MOV EAX, [pTcpPointer]
                              ; State
    PUSH EAX
    PUSH OFFSET pszFormatStringIntHEX
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 4
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText      
    
    PUSH OFFSET pszTcp
    PUSH 5
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText
    
    
    MOV EAX, [pTcpPointer]
    ADD EAX, 20
                              ; State
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 6
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText          
    
    
    MOV EAX, [pTcpPointer]
    ADD EAX, size MIB_TCPROW + 4
    MOV [pTcpPointer], EAX
    
  
    POP ECX
    DEC ECX
    JMP @MibView_TcpListLoop
  
 @MibView_ExitWithFree:
 
  MOV EAX, [pTcpTable]
  
  PUSH EAX
  PUSH 0
  CALL GetProcessHeap
  PUSH EAX
  CALL HeapFree

  
 @MibView_Exit:
  ADD ESP, 40
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
MibView_TcpEx ENDP

;*********************************************************
; MibView_UdpEx
;
;

;*********************************************************
MibView_UdpEx PROC hWnd:DWORD
LOCAL pUdpTable   :DWORD
LOCAL pUdpPointer :DWORD
LOCAL dwCount     :DWORD           
LOCAL dwPort      :DWORD

  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  SUB ESP, 40
  MOV EBX, ESP

  PUSH 2
  PUSH 0
  CALL GetProcessHeap
  PUSH EAX
  LEA EAX, [pUdpTable]
  PUSH 1
  PUSH EAX
  CALL [AllocateAndGetUdpExTableFromStack]
  
  TEST EAX, EAX
  JNZ @MibView_UdpExitWithFree
  
  MOV EAX, [pUdpTable]
  MOV ECX, [EAX]
  
  ADD EAX, 4
  MOV [pUdpPointer], EAX
  
  MOV [dwCount], 0
  
 @MibView_UdpListLoop:
    CMP ECX, 0
    JE @MibView_UdpExitWithFree
    
    PUSH ECX
    
    MOV EAX, [pUdpPointer]
    
    PUSH [EAX]
    PUSH EBX
    CALL Mib_CreateIPAddress
    
    
    MOV [gLci.imask], LVIF_TEXT
    MOV [gLci.pszText], EBX
    
    PUSH OFFSET gLci
    PUSH [hWnd]
    CALL ListView_InsertItem 
    
    MOV [dwCount], EAX
    
    MOV EAX, [pUdpPointer]
    MOV EAX, [EAX + 4]     ; Local Port
    XCHG AL, AH
    MOV [dwPort], EAX
    LEA EAX, [dwPort]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 1
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  


    PUSH OFFSET pszUdp
    PUSH 5
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText
    
    MOV EAX, [pUdpPointer]
    LEA EAX, [EAX + 8]     ; PID
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 6
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText      
    
    MOV EAX, [pUdpPointer]
    ADD EAX, size MIB_UDPROW + 4
    MOV [pUdpPointer], EAX
    
  
    POP ECX
    DEC ECX
    JMP @MibView_UdpListLoop
  
 @MibView_UdpExitWithFree:
 
  MOV EAX, [pUdpTable]
  
  PUSH EAX
  PUSH 0
  CALL GetProcessHeap
  PUSH EAX
  CALL HeapFree
  
 @MibView_UdpExit:
  ADD ESP, 40
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
MibView_UdpEx ENDP




;*********************************************************
; MibView_UDP
;
;

;*********************************************************
MibView_UDP PROC hWnd:DWORD
LOCAL pUdpTable   :DWORD
LOCAL pUdpPointer :DWORD
LOCAL dwUdpSize   :DWORD
LOCAL dwCount     :DWORD           
LOCAL dwPort      :DWORD

  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  SUB ESP, 40
  MOV EBX, ESP

  LEA EAX, [dwUdpSize]
  MOV DWORD PTR [EAX], 0
  
  PUSH 0
  PUSH EAX
  PUSH 0
  CALL [MIB_GetUdpTable]
  
  MOV EAX, [dwUdpSize]
  
  TEST EAX, EAX
  JZ @MibView_UdpExit
  
  ADD EAX, 4
  PUSH EAX
  PUSH LMEM_ZEROINIT
  CALL LocalAlloc
  
  MOV [pUdpTable], EAX
  
  PUSH 1
  LEA EAX, [dwUdpSize]
  PUSH EAX
  PUSH [pUdpTable]
  CALL [MIB_GetUdpTable]
  
  TEST EAX, EAX
  JNZ @MibView_UdpExitWithFree
  
  MOV EAX, [pUdpTable]
  MOV ECX, [EAX]
  
  ADD EAX, 4
  MOV [pUdpPointer], EAX
  
  MOV [dwCount], 0
  
 @MibView_UdpListLoop:
    CMP ECX, 0
    JE @MibView_UdpExitWithFree
    
    PUSH ECX
    
    MOV EAX, [pUdpPointer]
    
    PUSH [EAX]
    PUSH EBX
    CALL Mib_CreateIPAddress
    
    
    MOV [gLci.imask], LVIF_TEXT
    MOV [gLci.pszText], EBX
    
    PUSH OFFSET gLci
    PUSH [hWnd]
    CALL ListView_InsertItem 
    
    MOV [dwCount], EAX
    
    MOV EAX, [pUdpPointer]
    MOV EAX, [EAX + 4]     ; Local Port
    XCHG AL, AH
    MOV [dwPort], EAX
    LEA EAX, [dwPort]
    
    PUSH EAX
    PUSH OFFSET pszFormatStringInt
    PUSH EBX
    CALL wvsprintf    
    
    PUSH EBX
    PUSH 1
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText  


    PUSH OFFSET pszUdp
    PUSH 5
    PUSH [dwCount]
    PUSH [hWnd]
    CALL ListView_SetItemText
    
    MOV EAX, [pUdpPointer]
    ADD EAX, size MIB_UDPROW
    MOV [pUdpPointer], EAX
    
  
    POP ECX
    DEC ECX
    JMP @MibView_UdpListLoop
  
 @MibView_UdpExitWithFree:
 
  MOV EAX, [pUdpTable]
  PUSH EAX
  CALL LocalFree
  
 @MibView_UdpExit:
  ADD ESP, 40
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
MibView_UDP ENDP


;*********************************************************
; MibView_Sort
;
;
;  Registers The Window Class
;
;*********************************************************
MibView_Sort PROC hWnd:DWORD, iCol:DWORD

  MOV AL, [gSortType]
  INC AL
  MOV [gSortType], AL
  
  TEST AL, 1
  JE @MibView_SortOpposite
  
  MOV EAX, [iCol]
  
  CMP EAX, 1
  JE SHORT @MibView_SortByNumber
  
  CMP EAX, 3
  JE SHORT @MibView_SortByNumber

  CMP EAX, 6
  JE SHORT @MibView_SortByNumber

  PUSH [iCol]
  PUSH ListView_CompareStr
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @MibView_Exit
  
 @MibView_SortByNumber:  
 
  PUSH [iCol]
  PUSH ListView_CompareNum
  PUSH [hWnd]
  CALL ListView_SortEx 
 
 @MibView_Exit:  
  RET
 
 @MibView_SortOpposite:
  MOV EAX, [iCol]
  
  CMP EAX, 1
  JE SHORT @MibView_SortByNumberDecsend

  CMP EAX, 3
  JE SHORT @MibView_SortByNumberDecsend
  
  CMP EAX, 6
  JE SHORT @MibView_SortByNumberDecsend
    
  PUSH [iCol]
  PUSH ListView_CompareStrDecsend
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @MibView_Exit
  
 @MibView_SortByNumberDecsend:  
 
  PUSH [iCol]
  PUSH ListView_CompareNumDecsend
  PUSH [hWnd]
  CALL ListView_SortEx 
  RET
  
MibView_Sort ENDP



;*********************************************************
; MibView_ClickFunction
;
;
;  Registers The Window Class
;
;*********************************************************
MibView_ClickFunction PROC hWnd:DWORD, hWndListView:DWORD, iItem:DWORD, iSubItem:DWORD
  RET
MibView_ClickFunction ENDP


;*********************************************************
; MibView_Commands
;
;
;  Registers The Window Class
;
;*********************************************************
MibView_Commands PROC hWnd:DWORD, hWndListView:DWORD, iCmd:DWORD
  RET
MibView_Commands ENDP


;*********************************************************
; MibView_Hide
;
;
;  Registers The Window Class
;
;*********************************************************
MibView_Hide PROC hWnd:DWORD, hWndListView:DWORD
  RET
MibView_Hide ENDP



;*********************************************************
; Mib_CreateIPAddress
;
;
;  Registers The Window Class
;
;*********************************************************
Mib_CreateIPAddress PROC pszString :DWORD, dwAddress :DWORD
  PUSH ECX
  
  
  MOV EAX, [dwAddress]
  XOR ECX, ECX
  
  XCHG AH, AL
  ROL  EAX, 16
  XCHG AH, AL
  
  MOV CL, AL
  
  PUSH ECX
  ROR EAX, 8
  MOV CL, AL

  PUSH ECX
  ROR EAX, 8
  MOV CL, AL

  PUSH ECX
  ROR EAX, 8
  MOV CL, AL
  
  PUSH ECX
  MOV ECX, ESP
  PUSH ECX
  PUSH OFFSET pszIpString
  PUSH EBX
  CALL wvsprintf
  
  ADD ESP, 16
  
  POP ECX
  RET
Mib_CreateIPAddress ENDP







 
