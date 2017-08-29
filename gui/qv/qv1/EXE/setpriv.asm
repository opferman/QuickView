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
; SetPriv_SetPrivilege
;   
;   Setting Debug Privleges
;   
;
;*********************************************************
SetPriv_SetPrivilege PROC hToken:DWORD, pszPriv:DWORD, bEnable:DWORD
ASSUME FS:nothing
LOCAL iluid   :LUID
LOCAL tokenp  :TOKEN_PRIVILEGES
LOCAL tpPrevious :TOKEN_PRIVILEGES
LOCAL cbPrevious :DWORD

   LEA EAX, [iluid]
   
   PUSH EAX
   PUSH [pszPriv]
   PUSH 0
   CALL LookupPrivilegeValue
   
   TEST EAX, EAX
   JZ @SetPriv_Exit
   
   MOV [tokenp.PrivilegeCount], 1
   
   LEA EDI, [tokenp.Privileges.Luid]
   LEA ESI, [iluid]
   MOV ECX, size LUID
   
   REP MOVSB
   
   MOV [tokenp.Privileges.Attributes], 0
   
   MOV [cbPrevious], size TOKEN_PRIVILEGES
   
   LEA EAX, [cbPrevious]
   PUSH EAX
   LEA EAX, [tpPrevious]
   PUSH EAX
   PUSH size TOKEN_PRIVILEGES
   LEA EAX, [tokenp]
   PUSH EAX
   PUSH 0
   PUSH [hToken]
   CALL AdjustTokenPrivileges
   
   MOV EAX, FS:[34h]
   
   TEST EAX, EAX
   MOV EAX, 0               ; MOV does not set flags
   JNZ  @SetPriv_Exit
   
   MOV [tpPrevious.PrivilegeCount], 1
   LEA EDI, [tpPrevious.Privileges.Luid]
   LEA ESI, [iluid]
   MOV ECX, size LUID
   
   REP MOVSB
   
   MOV EAX, [bEnable]
   TEST EAX, EAX
   JZ @SetPriv_Disable
   
  @SetPriv_Enable:
   MOV EAX, SE_PRIVILEGE_ENABLED
   OR [tpPrevious.Privileges.Attributes], EAX
   JMP @SetPriv_SetThem
   
  @SetPriv_Disable: 
   MOV EAX, [tpPrevious.Privileges.Attributes]
   AND EAX, SE_PRIVILEGE_ENABLED
   XOR [tpPrevious.Privileges.Attributes], EAX
   
  @SetPriv_SetThem:
   PUSH 0
   PUSH 0
   PUSH [cbPrevious]
   LEA EAX, [tpPrevious]
   PUSH EAX
   PUSH 0
   PUSH [hToken]
   CALL AdjustTokenPrivileges
   
   MOV EAX, FS:[34h]
   TEST EAX, EAX
   MOV EAX, 0               ; MOV does not set flags
   JNZ  @SetPriv_Exit
   
   MOV EAX, 1
   
  @SetPriv_Exit:
   RET
SetPriv_SetPrivilege ENDP



