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
; Symlnk_Create
;
;
;  Creates the Process View List View
;
;*********************************************************
Symlnk_Create PROC

  ; Create The Child Window
  CALL ListView_CreateListViewWindow

  MOV EBX, EAX
  PUSH EAX
  PUSH EAX
  CALL ListView_SetExtendedListViewStyle
 

  ; Create The Columns
  PUSH OFFSET pszSymLnkLocation
  PUSH 0
  PUSH EBX
  CALL ListView_CreateColoumnLarge

  PUSH OFFSET pszSymLnkName
  PUSH 1
  PUSH EBX 
  CALL ListView_CreateColoumnLarge
  
  PUSH OFFSET pszSymLnkSymbol
  PUSH 2
  PUSH EBX
  CALL ListView_CreateColoumnLarge

  PUSH EBX
  CALL SymlnkView_Refresh
  
  POP EAX
  RET
Symlnk_Create ENDP




;*********************************************************
; SymlnkView_Refresh
;
;
;*********************************************************
SymlnkView_Refresh PROC hWnd:DWORD
LOCAL UnicodeString      :UNICODE_STRING

  PUSH EBX
  PUSH ECX
  PUSH EDX
  PUSH ESI
  PUSH EDI
  
  PUSH [hWnd]
  CALL ListView_DeleteAll
  
  ;
  ; Traverse All Symbolic Links On The System
  ;
  
  LEA EAX, [UnicodeString]
  MOV WORD PTR [EAX], 2
  MOV WORD PTR [EAX + 2], 2
  MOV DWORD PTR [EAX + 4], OFFSET pszRootLink
  
  PUSH EAX
  PUSH [hWnd]
  CALL SymlnkView_TraverseObjectDirectory
  
  POP EDI
  POP ESI
  POP EDX
  POP ECX
  POP EBX
  
  RET 
  
SymlnkView_Refresh ENDP




;*********************************************************
; SymlnkView_TraverseObjectDirectory
;
;
;  
;
;*********************************************************
SymlnkView_TraverseObjectDirectory PROC hWnd:DWORD, pszUnicodeString:DWORD
LOCAL hDirectoryHandle   :DWORD
LOCAL ObjectAttribute    :OBJECT_ATTRIBUTES
LOCAL dwContext          :DWORD
LOCAL dwRescan           :DWORD

  PUSH EBX
  MOV [dwRescan], 1
  
  PUSH 40h
  PUSH [pszUnicodeString]
  LEA  EAX, [ObjectAttribute]
  PUSH EAX
  CALL Symlnk_InitObject
  
  LEA EAX, [ObjectAttribute]
  PUSH EAX
  PUSH 020001h
  LEA EAX, [hDirectoryHandle]
  PUSH EAX
  CALL [ZwOpenDirectoryObject]
  
  CMP EAX, 0
  JL @SymlnkView_Exit
  
  MOV EAX, [hDirectoryHandle]
  
  TEST EAX, EAX
  JZ @SymlnkView_Exit
  
  SUB ESP, 800
  MOV EBX, ESP 
 
 @SymlnkView_TraverseLoop:
  
  PUSH EBX
 
  PUSH 0
  LEA  EAX, [dwContext]
  PUSH EAX
  PUSH [dwRescan]
  PUSH 1
  PUSH 800
  PUSH EBX
  PUSH [hDirectoryHandle]
  CALL [ZwQueryDirectoryObject]
  
  POP EBX
  
  CMP EAX, 0
  JL @SymlnkView_ExitWithClose
  
  CMP EAX, 08000001Ah  ; No More Entries
  JE @SymlnkView_ExitWithClose
  
  MOV [dwRescan], 0
  MOV EAX, [EBX + 12]
  MOV AL, [EAX]
  
  ;
  ; Cheap compare, find "SymLink" and "Directory" by only comparing first letter
  ;
  CMP AL, 'd'
  JE @Symlnk_Directory
  
  CMP AL, 'D'
  JE @Symlnk_Directory
  
  CMP AL, 's'
  JE @Symlnk_SymLink
  
  CMP AL, 'S'
  JE @Symlnk_SymLink
  
  ; Unknown, not supported.
  JMP @SymlnkView_TraverseLoop
 

  @Symlnk_SymLink:
   ;
   ; Check the "y" to make sure it's not a "section" or "semaphore"
   ;  We only want to display Symbolic Links at this time.
   ;
   MOV EAX, [EBX + 12]
   MOV AL, [EAX + 2]
   
   CMP AL, 'y'
   JE  @Symlnk_SymLinkForSure
   
   CMP AL, 'Y'
   JNE @SymlnkView_TraverseLoop
   
  @Symlnk_SymLinkForSure:
  
  PUSH EBX
  
  PUSH [pszUnicodeString]
  PUSH EBX
  PUSH [hWnd]
  CALL SymlnkView_DisplaySymLink
  
  POP EBX
  JMP @SymlnkView_TraverseLoop
  
  @Symlnk_Directory:

  PUSH EBX
  
  PUSH [pszUnicodeString]
  PUSH EBX
  CALL SymlnkView_AppendStrings
  
  POP EBX
  
  
  PUSH EAX
   
  PUSH EAX
  PUSH [hWnd]
  CALL SymlnkView_TraverseObjectDirectory
  
  CALL LocalFree
  
  JMP @SymlnkView_TraverseLoop
  
 @SymlnkView_ExitWithClose: 

  ADD ESP, 800
  PUSH [hDirectoryHandle]
  CALL [zwCloseHandle]
  
 @SymlnkView_Exit:
  
  POP EBX
  RET
SymlnkView_TraverseObjectDirectory ENDP



;*********************************************************
; SymlnkView_DisplaySymLink
;
;
;  Registers The Window Class
;
;*********************************************************
SymlnkView_AppendStrings PROC pUnicodeString:DWORD, pUnicodeStringStart:DWORD
LOCAL dwAddSlash :DWORD

  PUSH ECX
  PUSH EDI
  PUSH ESI
  PUSH EBX
 
  MOV [dwAddSlash], 0
  XOR ECX, ECX
  MOV EAX, [pUnicodeString]
  MOV CX, [EAX]
  MOV EAX, [EAX + 4]

  CMP BYTE PTR [EAX], '\'
  JE @SymlnkView_NoSlash
  
  MOV EAX, [pUnicodeStringStart]
  XOR EBX, EBX
  MOV BX, [EAX]
  MOV EAX, [EAX + 4]
  
  CMP BYTE PTR [EAX + EBX - 2], '\'
  JE @SymlnkView_NoSlash
  
  CMP WORD PTR [EAX + EBX - 2], 0
  JNE @SymlnkView_AddSlash
  
  CMP WORD PTR [EAX + EBX - 4], '\'
  JE @SymlnkView_NoSlash
  
 @SymlnkView_AddSlash:
  
  MOV [dwAddSlash], 1
  ADD ECX, 2 
  
 @SymlnkView_NoSlash:
  MOV EAX, [pUnicodeStringStart]
  ADD CX, [EAX]
  ADD ECX, 8
 
  PUSH ECX
  
  PUSH ECX
  PUSH LMEM_ZEROINIT
  CALL LocalAlloc
  
  POP ECX
  SUB ECX, 8
  MOV [EAX], CX
  MOV [EAX + 2], CX
  MOV EDI, EAX
  ADD EDI, 8
  MOV [EAX + 4], EDI
  
  MOV ESI, [pUnicodeStringStart]
  MOV CX, [ESI]
  MOV ESI, [ESI + 4]
  
  REP MOVSB
  
  CMP WORD PTR [EDI - 2], 0
  JNE @SymlnkView_Continue
  
  SUB EDI, 2
  
 @SymlnkView_Continue:
  CMP [dwAddSlash], 0
  JE @SymlnkView_SkipSlash
  
  MOV BYTE PTR [EDI], '\'
  MOV BYTE PTR [EDI + 1], 0
  ADD EDI, 2
  
 @SymlnkView_SkipSlash:
 
  MOV ESI, [pUnicodeString]
  MOV CX, [ESI]
  MOV ESI, [ESI + 4]
  
  REP MOVSB  
  
 @SymlnkView_NoString:
  POP EBX
  
  POP ESI
  POP EDI
  POP ECX
 
  RET
SymlnkView_AppendStrings ENDP

;*********************************************************
; SymlnkView_DisplaySymLink
;
;
;  Registers The Window Class
;
;*********************************************************
SymlnkView_DisplaySymLink PROC hWnd:DWORD, pszUnicodeString:DWORD, pszDirectoryString:DWORD
LOCAL hSymLinkHandle   :DWORD
LOCAL ObjectAttribute  :OBJECT_ATTRIBUTES
LOCAL dwCount          :DWORD
LOCAL dwFullDir        :DWORD
  PUSH EDX

  MOV EAX, [pszDirectoryString]
  MOV EAX, [EAX + 4]
  MOV [gLci.imask], LVIF_TEXT
  MOV [gLci.pszText], EAX
  
  MOV EAX, [pszDirectoryString]
  XOR EDX, EDX
  MOV DX, [EAX]
  
  SHR EDX, 1
  PUSH EDX
  PUSH OFFSET gLci
  PUSH [hWnd]
  CALL ListView_InsertItemW
  
  MOV [dwCount], EAX

  PUSH [pszUnicodeString]
  PUSH 1
  PUSH [dwCount]
  PUSH [hWnd]
  CALL ListView_SetItemTextU
  

  PUSH [pszDirectoryString]
  PUSH [pszUnicodeString]
  CALL SymlnkView_AppendStrings
  
  MOV [dwFullDir], EAX
  
  PUSH 40h
  PUSH [dwFullDir]
  LEA  EAX, [ObjectAttribute]
  PUSH EAX
  CALL Symlnk_InitObject
  
  LEA EAX, [ObjectAttribute]
  PUSH EAX
  PUSH 080020001h
  LEA EAX, [hSymLinkHandle]
  PUSH EAX
  CALL [ZwOpenSymbolicLinkObject]
  
  CMP EAX, 0
  JL @SymlnkView_ExitWithFree
  
  MOV EAX, [hSymLinkHandle]
  
  TEST EAX, EAX
  JZ @SymlnkView_ExitWithFree
  
  SUB ESP, 528
  MOV EDX, ESP
  
  MOV WORD PTR [EDX], 512
  MOV WORD PTR [EDX + 2], 512
  MOV EAX, EDX
  ADD EAX, 8
  MOV [EDX + 4], EAX
  
  PUSH EDX
  
  PUSH 0
  PUSH EDX
  PUSH [hSymLinkHandle]
  CALL [ZwQuerySymbolicLinkObject]
  
  POP EDX
  
  CMP EAX, 0
  JL @SymlnkView_ExitWithClose
  
  PUSH EDX
  PUSH 2
  PUSH [dwCount]
  PUSH [hWnd]
  CALL ListView_SetItemTextU 
 
 @SymlnkView_ExitWithClose:  
  
  ADD ESP, 528
  
  PUSH [hSymLinkHandle]
  CALL CloseHandle
  
 @SymlnkView_ExitWithFree: 
  PUSH [dwFullDir]
  CALL LocalFree
  
 @SymlnkView_Exit:
  POP EDX
  
  RET
SymlnkView_DisplaySymLink ENDP



;*********************************************************
; SymlnkView_Sort
;
;
;  Registers The Window Class
;
;*********************************************************
SymlnkView_Sort PROC hWnd:DWORD, iCol:DWORD

  MOV AL, [gSortType]
  INC AL
  MOV [gSortType], AL
  
  TEST AL, 1
  JE @SymlnkView_SortOpposite
  
  MOV EAX, [iCol]
  
  CMP EAX, 0
  JE SHORT @SymlnkView_SortByNumber
  

  PUSH [iCol]
  PUSH ListView_CompareStr
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @SymlnkView_Exit
  
 @SymlnkView_SortByNumber:  
 
  PUSH [iCol]
  PUSH ListView_CompareNum
  PUSH [hWnd]
  CALL ListView_SortEx 
 
 @SymlnkView_Exit:  
  RET
 
 @SymlnkView_SortOpposite:
  MOV EAX, [iCol]
  
  CMP EAX, 0
  JE SHORT @SymlnkView_SortByNumberDecsend


  PUSH [iCol]
  PUSH ListView_CompareStrDecsend
  PUSH [hWnd]
  CALL ListView_SortEx
  
  JMP @SymlnkView_Exit
  
 @SymlnkView_SortByNumberDecsend:  
 
  PUSH [iCol]
  PUSH ListView_CompareNumDecsend
  PUSH [hWnd]
  CALL ListView_SortEx 
  RET
  
SymlnkView_Sort ENDP



;*********************************************************
; SymlnkView_ClickFunction
;
;
;  Registers The Window Class
;
;*********************************************************
SymlnkView_ClickFunction PROC hWnd:DWORD, hWndListView:DWORD, iItem:DWORD, iSubItem:DWORD
  RET
SymlnkView_ClickFunction ENDP


;*********************************************************
; SymlnkView_Commands
;
;
;  Registers The Window Class
;
;*********************************************************
SymlnkView_Commands PROC hWnd:DWORD, hWndListView:DWORD, iCmd:DWORD
  RET
SymlnkView_Commands ENDP


;*********************************************************
; SymlnkView_Hide
;
;
;  Registers The Window Class
;
;*********************************************************
SymlnkView_Hide PROC hWnd:DWORD, hWndListView:DWORD
  RET
SymlnkView_Hide ENDP



;*********************************************************
; Symlnk_InitObject
;
;
;  Registers The Window Class
;
;*********************************************************
Symlnk_InitObject PROC pObject:DWORD, pUnicodeString:DWORD, dwAttributes:DWORD
   PUSH EDX
   MOV EAX, [pObject]
   MOV DWORD PTR [EAX], size OBJECT_ATTRIBUTES
   MOV DWORD PTR [EAX + 4], 0
   MOV EDX, [pUnicodeString]
   MOV [EAX + 8], EDX
   MOV EDX, [dwAttributes]
   MOV [EAX + 12], EDX
   MOV DWORD PTR [EAX + 16], 0
   MOV DWORD PTR [EAX + 20], 0
   POP EDX
   RET
Symlnk_InitObject ENDP


 

