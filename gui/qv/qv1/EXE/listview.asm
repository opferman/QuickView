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
; ListView_InsertColumn
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_InsertColumn PROC hWnd:DWORD, iColumn:DWORD, pListViewInfo:DWORD
  
  PUSH [pListViewInfo]
  PUSH [iColumn]
  PUSH LVM_INSERTCOLUMN
  PUSH [hWnd]
  CALL SendMessage
  
  RET
ListView_InsertColumn ENDP



;*********************************************************
; ListView_SetExtendedListViewStyle
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_SetExtendedListViewStyle PROC hWnd:DWORD

 PUSH LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES
 PUSH 0
 PUSH LVM_SETEXTENDEDLISTVIEWSTYLE 
 PUSH [hWnd]
 CALL SendMessage
 
 RET
ListView_SetExtendedListViewStyle ENDP
        
        


;*********************************************************
; ListView_InsertColumn
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_InsertItem PROC hWnd:DWORD, pListViewInfo:DWORD
  
  PUSH [pListViewInfo]
  PUSH 0
  PUSH LVM_INSERTITEM
  PUSH [hWnd]
  CALL SendMessage
  
  RET
ListView_InsertItem ENDP

;*********************************************************
; ListView_InsertColumn
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_InsertItemW PROC hWnd:DWORD, pListViewInfo:DWORD, dwMaxSize:DWORD
  PUSH EBX
  SUB ESP, 264
  MOV EBX, ESP
  
  PUSH 0
  PUSH 0
  PUSH 264
  PUSH EBX
  PUSH [dwMaxSize]
  MOV  EAX, [pListViewInfo]
  MOV EAX, [EAX + 20]
  PUSH EAX
  PUSH 0
  PUSH CP_ACP
  CALL WideCharToMultiByte
  
  CMP [dwMaxSize], 264
  JAE @ListView_NullIt
  
  MOV EAX, [dwMaxSize]
  MOV BYTE PTR [EBX + EAX], 0
  
 @ListView_NullIt:
  MOV BYTE PTR [EBX + 263], 0  ; Make sure we're NULL.
  
  MOV  EAX, [pListViewInfo]
  MOV [EAX + 20], EBX
  
  PUSH [pListViewInfo]
  PUSH 0
  PUSH LVM_INSERTITEM
  PUSH [hWnd]
  CALL SendMessage
  
  ADD ESP, 264
  POP EBX
  
  RET
ListView_InsertItemW ENDP

;*********************************************************
; ListView_SetItemText
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_SetItemText PROC hWnd:DWORD, iItem:DWORD, iSubItem:DWORD, pszText:DWORD
 LOCAL lvItem :LVITEM

  MOV [lvItem.imask], LVIF_TEXT
  
  MOV EAX, [pszText]
  MOV [lvItem.pszText], EAX
  
  MOV EAX, [iSubItem]
  MOV [lvItem.iSubItem], EAX
  
  LEA EAX, [lvItem]
  PUSH EAX
  PUSH [iItem]
  PUSH LVM_SETITEMTEXT
  PUSH [hWnd]
  CALL SendMessage
 
  RET
  
ListView_SetItemText ENDP


;*********************************************************
; ListView_SetItemText
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_SetItemTextW PROC hWnd:DWORD, iItem:DWORD, iSubItem:DWORD, pszText:DWORD
 LOCAL lvItem :LVITEM

  MOV [lvItem.imask], LVIF_TEXT
  
  PUSH EBX
  SUB ESP, 256
  MOV EBX, ESP
  
  PUSH 0
  PUSH 0
  PUSH 256
  PUSH EBX
  PUSH 512
  PUSH [pszText]
  PUSH 0
  PUSH CP_ACP
  CALL WideCharToMultiByte  

  MOV [lvItem.pszText], EBX
  
  MOV EAX, [iSubItem]
  MOV [lvItem.iSubItem], EAX
  
  LEA EAX, [lvItem]
  PUSH EAX
  PUSH [iItem]
  PUSH LVM_SETITEMTEXT
  PUSH [hWnd]
  CALL SendMessage
  
  ADD ESP, 256
  
  POP EBX
  
  RET
  
ListView_SetItemTextW ENDP



;*********************************************************
; ListView_SetItemText
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_SetItemTextU PROC hWnd:DWORD, iItem:DWORD, iSubItem:DWORD, pszUnicodeString:DWORD
 LOCAL lvItem :LVITEM

  MOV [lvItem.imask], LVIF_TEXT
  
  PUSH EBX
  PUSH ECX
  
  SUB ESP, 256
  MOV EBX, ESP
  
  PUSH 0
  PUSH 0
  PUSH 256
  PUSH EBX
  XOR ECX, ECX
  MOV EAX, [pszUnicodeString]
  MOV CX, [EAX]
  SHR ECX, 1
  PUSH ECX
  PUSH [EAX + 4]
  PUSH 0
  PUSH CP_ACP
  CALL WideCharToMultiByte  
  
  XOR ECX, ECX
  MOV EAX, [pszUnicodeString]
  MOV CX, [EAX]
  SHR ECX, 1
  
  MOV BYTE PTR [EBX + ECX], 0
  
  MOV [lvItem.pszText], EBX
  
  MOV EAX, [iSubItem]
  MOV [lvItem.iSubItem], EAX
  
  LEA EAX, [lvItem]
  PUSH EAX
  PUSH [iItem]
  PUSH LVM_SETITEMTEXT
  PUSH [hWnd]
  CALL SendMessage
  
  ADD ESP, 256
  
  POP ECX
  POP EBX
  
  RET
  
ListView_SetItemTextU ENDP

;*********************************************************
; ListView_GetText
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_GetText PROC hWnd:DWORD, iItem:DWORD, iSubItem:DWORD, pszText:DWORD, cbTextSize:DWORD
 LOCAL lvItem :LVITEM
  PUSH EDX
  PUSH EBX
  PUSH ECX
  
  MOV EAX, [pszText]
  MOV [lvItem.pszText], EAX
  
  MOV EAX, [iSubItem]
  MOV [lvItem.iSubItem], EAX
  
  MOV EAX, [cbTextSize]
  MOV [lvItem.cchTextMax], EAX
  
  LEA EAX, [lvItem]
  PUSH EAX
  PUSH [iItem]
  PUSH LVM_GETITEMTEXT
  PUSH [hWnd]
  CALL SendMessage

  POP ECX
  POP EBX
  POP EDX

  RET
  
ListView_GetText ENDP

;*********************************************************
; ListView_GetItem
;
;
;  Registers The Window Class
;
;*********************************************************
ListView_GetItem PROC hWnd:DWORD, pLvItem:DWORD
  PUSH EDX
  PUSH EBX
  PUSH ECX
  
  PUSH [pLvItem]
  PUSH 0
  PUSH LVM_GETITEM
  PUSH [hWnd]
  CALL SendMessage
  
  POP ECX
  POP EBX
  POP EDX

  RET
  
ListView_GetItem ENDP


;*********************************************************
; ListView_CreateListViewWindow
;
;
;  Creates The Window 
;
;*********************************************************
ListView_CreateListViewWindow PROC
    PUSH OFFSET ClientRect
    PUSH [ghWnd]
    CALL GetClientRect

    PUSH  0
    PUSH  [hInstance]
    PUSH  0
    PUSH  [ghWnd]
    PUSH  [ClientRect.bottom]
    PUSH  [ClientRect.right]
    PUSH  0
    PUSH  0
    PUSH  LVS_SHOWSELALWAYS or WS_BORDER or WS_CHILD or WS_VISIBLE or LVS_REPORT
    PUSH  OFFSET pszEmptyString
    PUSH  OFFSET pszListViewClass
    PUSH  WS_EX_CLIENTEDGE
    CALL CreateWindowEx
    RET
ListView_CreateListViewWindow ENDP



;*********************************************************
; ListView_DeleteAll
;
;
;  Creates The Window 
;
;*********************************************************
ListView_DeleteAll PROC hWnd:DWORD

   PUSH 0
   PUSH 0
   PUSH LVM_DELETEALLITEMS
   PUSH [hWnd]
   CALL SendMessage
   
   RET
   
ListView_DeleteAll ENDP



;*********************************************************
; ListView_SortEx
;
;
;  Creates The Window 
;
;*********************************************************
ListView_SortEx PROC hWnd:DWORD, pSortFunc:DWORD, iCol:DWORD
  
   PUSH [pSortFunc]
   PUSH [iCol]
   PUSH LVM_SORTITEMSEX
   PUSH [hWnd]
   CALL SendMessage
   
   RET
ListView_SortEx ENDP

;*********************************************************
; ListView_CompareStr
;
;
;  Creates The Window 
;
;*********************************************************
ListView_CompareStr PROC p1:DWORD, p2:DWORD, col:DWORD
  PUSH EBX
  PUSH ECX
  PUSH EDX
    
  SUB ESP, 256
  MOV EBX, ESP
  SUB ESP, 256
  
  MOV EDI, ESP
  XOR EAX, EAX
  MOV ECX, 256*2/4
  REP STOSD
  
  PUSH 256
  PUSH EBX
  PUSH [col]
  PUSH [p1]
  PUSH [ghWndLVCurrent]
  CALL ListView_GetText
  
  MOV EDX, ESP
  
  PUSH 256
  PUSH EDX
  PUSH [col]
  PUSH [p2]
  PUSH [ghWndLVCurrent]
  CALL ListView_GetText  
 
  
  PUSH EDX
  PUSH EBX
  CALL lstrcmpi
 
 
  ADD ESP, 256*2
  
  POP EDX
  POP ECX
  POP EBX
  
  RET
ListView_CompareStr ENDP

;*********************************************************
; ListView_CompareNum
;
;
;  Creates The Window 
;
;*********************************************************
ListView_CompareNum PROC p1:DWORD, p2:DWORD, col:DWORD
  PUSH EDX
  PUSH ECX
  PUSH EBX
  
  SUB ESP, 256
  MOV EBX, ESP
  SUB ESP, 256
  
  MOV EDI, ESP
  XOR EAX, EAX
  MOV ECX, 256*2/4
  REP STOSD
  
  PUSH 256
  PUSH EBX
  PUSH [col]
  PUSH [p1]
  PUSH [ghWndLVCurrent]
  CALL ListView_GetText
  
  MOV EDX, ESP
  
  PUSH 256
  PUSH EDX
  PUSH [col]
  PUSH [p2]
  PUSH [ghWndLVCurrent]
  CALL ListView_GetText  
  
  PUSH EDX
  CALL ListView_StrToNum
  MOV ECX, EAX
  
  PUSH EBX
  CALL ListView_StrToNum
    
  ADD ESP, 256*2

  SUB EAX, ECX
  

  POP EBX
  POP ECX
  POP EDX
    
  RET
ListView_CompareNum ENDP


;*********************************************************
; ListView_StrToNum
;
;
;  Creates The Window 
;
;*********************************************************
ListView_StrToNum PROC pString:DWORD
  
  XOR EAX, EAX
  
  PUSH EBX
  PUSH ECX
  PUSH EDX
  
  MOV EBX, [pString]
  
 @ListView_Loop:
   CMP BYTE PTR [EBX], 0
   JE @ListView_Done
     
     XOR EDX, EDX
     MOV ECX, 10
     
     MUL ECX
     
     XOR ECX, ECX
     MOV CL, [EBX]
     SUB CL, '0'
     
     ADD EAX, ECX
     
     INC EBX
     JMP @ListView_Loop
     
 @ListView_Done:
  POP EDX
  POP ECX
  POP EBX
  
  RET
ListView_StrToNum ENDP







;*********************************************************
; ListView_CompareStr
;
;
;  Creates The Window 
;
;*********************************************************
ListView_CompareStrDecsend PROC p1:DWORD, p2:DWORD, col:DWORD
  PUSH EBX
  PUSH ECX
  PUSH EDX
    
  SUB ESP, 256
  MOV EBX, ESP
  SUB ESP, 256
  
  MOV EDI, ESP
  XOR EAX, EAX
  MOV ECX, 256*2/4
  REP STOSD
  
  PUSH 256
  PUSH EBX
  PUSH [col]
  PUSH [p1]
  PUSH [ghWndLVCurrent]
  CALL ListView_GetText
  
  MOV EDX, ESP
  
  PUSH 256
  PUSH EDX
  PUSH [col]
  PUSH [p2]
  PUSH [ghWndLVCurrent]
  CALL ListView_GetText  
 
  
  PUSH EBX
  PUSH EDX
  CALL lstrcmpi
 
 
  ADD ESP, 256*2
  
  POP EDX
  POP ECX
  POP EBX
  
  RET
ListView_CompareStrDecsend ENDP

;*********************************************************
; ListView_CompareNum
;
;
;  Creates The Window 
;
;*********************************************************
ListView_CompareNumDecsend PROC p1:DWORD, p2:DWORD, col:DWORD
  PUSH EDX
  PUSH ECX
  PUSH EBX
  
  SUB ESP, 256
  MOV EBX, ESP
  SUB ESP, 256
  
  MOV EDI, ESP
  XOR EAX, EAX
  MOV ECX, 256*2/4
  REP STOSD
  
  PUSH 256
  PUSH EBX
  PUSH [col]
  PUSH [p1]
  PUSH [ghWndLVCurrent]
  CALL ListView_GetText
  
  MOV EDX, ESP
  
  PUSH 256
  PUSH EDX
  PUSH [col]
  PUSH [p2]
  PUSH [ghWndLVCurrent]
  CALL ListView_GetText  
  
  PUSH EDX
  CALL ListView_StrToNum
  MOV ECX, EAX
  
  PUSH EBX
  CALL ListView_StrToNum
    
  ADD ESP, 256*2

  SUB ECX, EAX
  
  MOV EAX, ECX

  POP EBX
  POP ECX
  POP EDX
    
  RET
ListView_CompareNumDecsend ENDP


;*********************************************************
; ListView_StrHexToNum
;
;
;  Creates The Window 
;
;*********************************************************
ListView_StrHexToNum PROC pszString :DWORD

  PUSH EDX
  PUSH EBX
  
  MOV EDX, [pszString]
  ADD EDX, 2
  XOR EBX, EBX
  XOR EAX, EAX
  
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
  
  POP EBX
  POP EDX

  RET
ListView_StrHexToNum ENDP

;*********************************************************
; ListView_GetSelectedCount
;
;
;  Creates The Window 
;
;*********************************************************
ListView_GetSelectedCount PROC hWnd :DWORD
  PUSH EDX
  PUSH EBX
  PUSH ECX
  
  PUSH 0
  PUSH 0
  PUSH LVM_GETSELECTEDCOUNT
  PUSH [hWnd]
  CALL SendMessage
  
  POP ECX
  POP EBX
  POP EDX

  RET
ListView_GetSelectedCount ENDP




;*********************************************************
; ListView_CreateColoumn
;
;
;  Registers The Window Class
;
;*********************************************************

ListView_CreateColoumn PROC hWnd:DWORD, iItem:DWORD, pszListText:DWORD
  PUSH EBX
  PUSH ECX
  PUSH EDX

  MOV [gLvc.imask], LVCF_TEXT or LVCF_WIDTH
  MOV [gLvc.lx], 100
  
  MOV EAX, [pszListText]
  MOV [gLvc.pszText],EAX
  
  PUSH OFFSET gLvc
  PUSH [iItem]
  PUSH [hWnd]
  CALL ListView_InsertColumn

  POP EDX
  POP ECX
  POP EBX
  
  RET
ListView_CreateColoumn ENDP



;*********************************************************
; ListView_CreateColoumnLarge
;
;
;  Registers The Window Class
;
;*********************************************************

ListView_CreateColoumnLarge PROC hWnd:DWORD, iItem:DWORD, pszListText:DWORD
  PUSH EBX
  PUSH ECX
  PUSH EDX

  MOV [gLvc.imask], LVCF_TEXT or LVCF_WIDTH
  MOV [gLvc.lx], 300
  
  MOV EAX, [pszListText]
  MOV [gLvc.pszText],EAX
  
  PUSH OFFSET gLvc
  PUSH [iItem]
  PUSH [hWnd]
  CALL ListView_InsertColumn

  POP EDX
  POP ECX
  POP EBX
  
  RET
ListView_CreateColoumnLarge ENDP

