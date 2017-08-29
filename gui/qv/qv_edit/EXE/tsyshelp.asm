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

.486p
.MODEL FLAT, STDCALL
option casemap :none

include windows.inc
include masm32.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include comctl32.inc
include advapi32.inc


;
; Toby's System Helper
;
;    This project is not intended for "feature bloat".  I am not simply throwing
;  every single piece of information I can find into this project, that would be
;  tedious and undermind the real goals of this application.  This application's
;  intent is the following:
;
;
;     1)  Generally, when debugging we use many tools.  I do not want to
;         replace those tools, they do their job well.  However, we have
;         too many and a lot of the time we only use the simplest of
;         their features, sometimes we just need to use the simple feature
;         to see if we want to use the advanced features, etc.  Instead
;         of bloating this code, I have just found the "simplest" features
;         and "most commonly" used features to put into this tool.
;
;     2)  There is information that I would like to get that is not 
;         available in the tools we use.  I am adding this information to
;         this project. (For Example, GetLastError(!gle or fs:34) and
;         NTSTATUS codes.
;
;     3)  Low Memory.  A lot of times, the systems get into a low memory
;         condition and it's impossible to launch an application.  Though
;         I'm really optimizing this code yet, I hope to keep it simple so
;         it doesn't have a large memory footprint and can easily be loaded
;         and more likely to load when the system it out of memory.  Writing
;         this in assembly and using the masm linker is one way to help accomplish
;         this goal.  This also depends on what operation you want to do.  If you
;         want to see all windows, all handles, etc, you're going to use up a lot of
;         memory.  On startup, the memory footprint is small.  We may be able to change
;         this in the future with something like a "dont display" option but rather
;         "dump to file"
;
;
;     4)  Terminal Services crashes, RPC down, etc.  Sometimes the system
;         goes down and task manager hangs and will not display a tasklist.
;         qprocess will not work either, this is because these tools use
;         winsta* calls and they lock since TS is down.  The goal in this
;         project is to use winsta* as little as possible so in this situtation
;         we are still able to be useable.
;
;
;


; TB_AUTOSIZE                   EQU <WM_USER + 33>

L                             EQU <DWORD>
LVS_EX_FULLROWSELECT          EQU 020h
LVM_SETEXTENDEDLISTVIEWSTYLE  EQU 01036h
LVS_EX_GRIDLINES              EQU 1
LVM_SORTITEMSEX               EQU 1051h
 
; Process Information
    ProcessBasicInformation          EQU 0
    ProcessQuotaLimits               EQU 1
    ProcessIoCounters                EQU 2
    ProcessVmCounters                EQU 3
    ProcessTimes                     EQU 4
    ProcessBasePriority              EQU 5
    ProcessRaisePriority             EQU 6
    ProcessDebugPort                 EQU 7
    ProcessExceptionPort             EQU 8
    ProcessAccessToken               EQU 9
    ProcessLdtInformation            EQU 10
    ProcessLdtSize                   EQU 11
    ProcessDefaultHardErrorMode      EQU 12
    ProcessIoPortHandlers            EQU 13
    ProcessPooledUsageAndLimits      EQU 14
    ProcessWorkingSetWatch           EQU 15
    ProcessUserModeIOPL              EQU 16
    ProcessEnableAlignmentFaultFixup EQU 17
    ProcessPriorityClass             EQU 18
    ProcessWx86Information           EQU 19
    ProcessHandleCount               EQU 20
    ProcessAffinityMask              EQU 21
    ProcessPriorityBoost             EQU 22
    ProcessDeviceMap                 EQU 23
    ProcessSessionInformation        EQU 24
    ProcessForegroundInformation     EQU 25
    ProcessWow64Information          EQU 26
    ProcessNameInformation           EQU 27
    

; System Information
 SystemModuleInformation EQU 11
 SystemHandleInformation EQU 16


; Object Handle information
 ObjectBasicInformation        EQU 0
 ObjectNameInformation         EQU 1
 ObjectTypeInformation         EQU 2
 ObjectAllTypesInformation     EQU 3
 ObjectHandleInformation       EQU 4


IDM_SAVE                      EQU 100
IDM_EXIT                      EQU 101
IDM_PROCVIEW                  EQU 102
IDM_ABOUT                     EQU 103
IDM_REFRESH                   EQU 104
IDM_DRIVEVIEW                 EQU 105
IDM_MODVIEW                   EQU 106
IDM_NT_STATUS                 EQU 107
IDM_GLE                       EQU 108
IDM_WINHANDLE                 EQU 109
IDC_ERROR                     EQU 110
IDM_HANDLES                   EQU 111
IDM_WINDOWS                   EQU 112
IDM_SYMBOLS                   EQU 113
IDM_PLUGIN                    EQU 114
IDM_UNLOAD                    EQU 115

IDM_MIDVIEW                   EQU 116
IDM_PROCVIEWF                 EQU 117
IDM_DRIVEVIEWF                EQU 118
IDM_MODVIEWF                  EQU 119
IDM_HANDLESF                  EQU 120
IDM_MIDVIEWF                  EQU 121
IDM_WINDOWSF                  EQU 122
IDM_SYMBOLSF                  EQU 123
IDM_CMDVIEW                   EQU 124

IDM_TOOLBAR                   EQU 126

IDM_TOOLBAR_WINDOW            EQU 200 ; Reserved
IDM_HEX                       EQU 201
IDM_DEC                       EQU 202
IDM_NOTUSED                   EQU 203
IDM_NTA                       EQU 204
IDM_NTB                       EQU 205
IDM_GLE2                      EQU 206
IDM_MSG                       EQU 207
IDM_EDIT_WINDOW               EQU 208
IDM_BUTTON_OK                 EQU 209

SYMBOLIC_LINK_QUERY           EQU 1
SYMBOLIC_LINK_ALL_ACCESS      EQU (STANDARD_RIGHTS_REQUIRED or 1)

OBJ_INHERIT                   EQU   02h
OBJ_PERMANENT                 EQU  010h
OBJ_EXCLUSIVE                 EQU  020h
OBJ_CASE_INSENSITIVE          EQU  040h
OBJ_OPENIF                    EQU  080h
OBJ_OPENLINK                  EQU 0100h
OBJ_VALID_ATTRIBUTES          EQU 01F2h

;OBJ_KERNEL_HANDLE             EQU
;OBJ_FORCE_ACCESS_CHECK        EQU

DIRECTORY_QUERY               EQU 1
DIRECTORY_TRAVERSE            EQU 2
DIRECTORY_CREATE_OBJECT       EQU 4 
DIRECTORY_CREATE_SUBDIRECTORY EQU 8
DIRECTORY_ALL_ACCESS          EQU (STANDARD_RIGHTS_REQUIRED or 0Fh)

DUPLICATE_CLOSE_SOURCE        EQU 1
DUPLICATE_SAME_ACCESS         EQU 2
DUPLICATE_SAME_ATTRIBUTES     EQU 4





SYNCHRONIZE_ACCESS            EQU 0100000h

IDC_USER_DEFINED              EQU 500

;*********************************************************
; Process View Commands
;*********************************************************
IDM_PROCTERM                  EQU 500
IDM_PROCINFO                  EQU 501
IDM_PROCDEBUG                 EQU 502


;*********************************************************
; Window View Commands
;*********************************************************
IDM_WINDESTROY                EQU 500
IDM_WINSENDMESSAGE            EQU 501
IDM_WINCLOSE                  EQU 502

;*********************************************************
; Extra Function Prototypes
;*********************************************************
StrCmpNIA PROTO :DWORD, :DWORD, :DWORD
wsprintfA PROTO C
SendMessageW PROTO :DWORD, :DWORD, :DWORD, :DWORD


;*********************************************************
; Extra Structure Defines
;*********************************************************
VM_COUNTERS STRUC
    PeakVirtualSize            DWORD ?
    VirtualSize                DWORD ?
    PageFaultCount             DWORD ?
    PeakWorkingSetSize         DWORD ?
    WorkingSetSize             DWORD ?
    QuotaPeakPagedPoolUsage    DWORD ?
    QuotaPagedPoolUsage        DWORD ?
    QuotaPeakNonPagedPoolUsage DWORD ?
    QuotaNonPagedPoolUsage     DWORD ?
    PagefileUsage              DWORD ?
    PeakPagefileUsage          DWORD ?
VM_COUNTERS ENDS


PROCESS_BASIC_INFORMATION STRUC
 ExitStatus                   DWORD ?
 PebBaseAddress               DWORD ?
 AffinityMask                 DWORD ?
 BasePriority                 DWORD ?
 UniqueProcessId              DWORD ?
 InheritedFromUniqueProcessId DWORD ?
PROCESS_BASIC_INFORMATION ENDS


SYSTEM_MODULE_INFO STRUC
    Reserved      DWORD ?
    Reserved2     DWORD ?
    Base          DWORD ?
    iSize         DWORD ?
    Flags         DWORD ?
    Index         WORD  ?
    Unknown       WORD  ?
    LoadCount     WORD  ?
    ModuleNameOffset  WORD ?
    ImageName     db 256 DUP(<>)
SYSTEM_MODULE_INFO ENDS


WINDOWINFO STRUC
    cbSize          DWORD ?
    rcWindow        RECT <>
    rcClient        RECT <>
    dwStyle         DWORD ?
    dwExStyle       DWORD ?
    dwWindowStatus  DWORD ?
    cxWindowBorders DWORD ?
    cyWindowBorders DWORD ?
    atomWindowType  DWORD ?
    wCreatorVersion WORD  ?
WINDOWINFO ENDS



MIB_TCPTABLE STRUC
  dwNumEntries DWORD ? 
  ; MIB_TCPROW's
MIB_TCPTABLE ENDS

MIB_UDPTABLE STRUC
  dwNumEntries DWORD ? 
  ; MIB_UDPROW's
MIB_UDPTABLE ENDS

MIB_UDPROW STRUC
 dwLocalAddr   DWORD ?
 dwLocalPort   DWORD ?
MIB_UDPROW ENDS


UNICODE_STRING STRUC
  dwLength       WORD  ?
  MaximumLength  WORD  ?
  Buffer         DWORD ?
UNICODE_STRING ENDS

MIB_TCPROW STRUC
 dwState       DWORD ?
 dwLocalAddr   DWORD ?
 dwLocalPort   DWORD ?
 dwRemoteAddr  DWORD ?
 dwRemotePort  DWORD ?
MIB_TCPROW ENDS


SYSTEM_HANDLE_INFORMATION STRUC 
   ProcessId         DWORD ?
   ObjectTypeNumber  db    ?
   Flags             db    ?   ;  0x01 = PROTECT_FROM_CLOSE, 0x02 = INHERIT
   Handle            WORD  ?
   Object            DWORD ?
   GrantedAccess     DWORD ?
SYSTEM_HANDLE_INFORMATION ENDS


DIRECTORY_BASIC_INFORMATION STRUC
  ObjectName      UNICODE_STRING <>
  ObjectTypeName  UNICODE_STRING <>
DIRECTORY_BASIC_INFORMATION ENDS


OBJECT_ATTRIBUTES STRUC
    dwLength                     DWORD ?
    RootDirectory                DWORD ?
    ObjectName                   DWORD ?
    Attributes                   DWORD ?
    SecurityDescriptor           DWORD ?
    SecurityQualityOfService     DWORD ?
OBJECT_ATTRIBUTES ENDS

OutputDebugStringW PROTO :DWORD
OutputDebugStringA PROTO :DWORD

;*********************************************************
; Global Library Data And Structures
;*********************************************************
.DATA?

; UnInitialized Variables
 WndClassEx            WNDCLASSEX          <?>
 hInstance             DWORD                ?
 Msg                   MSG                 <?>
 ghWnd                 DWORD                ?
 ghWndLVCurrent        DWORD                ?
 gRefreshFunction      DWORD                ?
 gSortFunction         DWORD                ?
 gClickFunction        DWORD                ?
 gUserDefinedFunction  DWORD                ?
 gHideFunction         DWORD                ?
 gLvc                  LVCOLUMN            <?>
 gLci                  LVITEM              <?>
 InitCmmCtrlsEx        INITCOMMONCONTROLSEX <?>
 ClientRect            RECT <?>
 NtQueryInformationProcess DWORD            ?
 NtQuerySystemInformation  DWORD            ?
 ZwQueryObject             DWORD            ?
 ZwDuplicateObject         DWORD            ?
 MIB_GetTcpTable           DWORD            ?
 MIB_GetUdpTable           DWORD            ?
 hModuleNt                 DWORD            ?
 gHandleNum                DWORD            ?
 ZwOpenDirectoryObject     DWORD            ?
 ZwOpenSymbolicLinkObject  DWORD            ?
 ZwQuerySymbolicLinkObject DWORD            ?
 ZwQueryDirectoryObject    DWORD            ?
 zwCloseHandle             DWORD            ?
 ClientRectToolbar         RECT <?>
 pfnHandleCommands         DWORD            ?
.DATA 
 ; Initialized Variables
 pszRootLink    db '\', 0, 0, 0
 
; This is the global link for XP/2003.  On 2000 it's \??, FYI.
 
; pszGlobalLink    db '\', 0, 'G', 0, 'L', 0, 'O', 0, 'B', 0, 'A', 0, 'L', 0, '?', 0, '?', 0, 0, 0
; pszSessionsLink  db '\', 0, 'S', 0, 'e', 0, 's', 0, 's', 0, 'i', 0, 'o', 0, 'n', 0, 's', 0, 0, 0
 hWndToolbar        DWORD 0
 hToolbar           DWORD 0
 pszToolBar         db "qv.dll", 0
 pszCreateToolBar   db "TsysDll_CreateToolbar",0
 pszHandleCommands  db "TsysDll_HandleCommands", 0
 pszWindowClass     db "TSysHelp", 0
 pszWindowCaption   db "QuickView - System Explorer", 0
 pszIconName        db "TSYSHELP", 0
 pszAboutDialog     db "AboutBox", 0
 pszListViewClass   db "SysListView32", 0
 pszProcessText     db "Process", 0
 pszThreadsText     db "Threads", 0
 pszPIDText         db "PID", 0
 pszParentPIDText   db "Parent PID", 0
 pszHandleCountText db "Handles", 0
 pszSessionText     db "Session", 0
 pszVirtualText     db "Virtual Memory (Total)", 0
 pszPagedPoolText   db "Paged Pool", 0
 pszNPPoolText      db "Non-Paged Pool", 0
 pszWorkingSet      db "Working Set", 0
 pszPageFileText    db "PageFile Use (VM)", 0
 pszProcMenu        db "TSysHelpMenu", 0
 pszGLEDialog       db "GetLastErrorBox", 0
 pszGLEStr          db "GetLastError", 0
 pszNTSStr          db "NT Status", 0
 pszNTSDialog       db "NTStatusErrorBox", 0
 pszDefaultMsg      db "Not Found", 0
 pszFormatStringInt db "%d", 0
 pszFormatStringIntK db "%dK", 0
 pszFormatStringIntHEX db "0x%08x", 0
 pszMenuString      db "ProcessPopup", 0
 pszKernel32        db "Kernel32", 0
 pszExitProcess     db "ExitProcess", 0
 pszWinsta          db "winsta.dll", 0
 pszWinstaTermProc  db "WinStationTerminateProcess", 0
 pszNtDll           db "ntdll.dll", 0
 pszNtQPI           db "NtQueryInformationProcess", 0
 pszNtProcInfo      db "NtQuerySystemInformation", 0
 pszWinMenuString   db "WindowPopup", 0
 pszZwQueryObject   db "ZwQueryObject", 0
 pszZwDuplicateObject  db "ZwDuplicateObject", 0
 pszModImageNameText   db "Image Name", 0
 pszModLoadText        db "Load Count", 0
 pszModSizeText        db "Size", 0
 pszModBaseText        db "Image Base", 0
 pszModFlagsText       db "State Flags", 0
 pszModNameOffsetText  db "Name Offset", 0
 
 pszDllImageNameText   db "Module Name", 0
 pszDllPIDText         db "Process PID", 0
 pszDllModStart        db "Module Start", 0
 pszDllModEnd          db "Module End", 0

 pszCommandLineText   db "Command Line", 0
 pszCommandPIDText    db "PID", 0
 pszzwCloseHandle     db "ZwClose",0
 
 pszWinHandleText      db "Window Handle", 0
 pszWinTitleText       db "Window Title", 0
 pszWinParentText      db "Window Parent", 0
 pszWinStylesText      db "Window Styles", 0
 pszWinClassText       db "Window Class", 0
 pszWinExStylesText    db "Window Extended Styles", 0
 pszWinModNameText     db "Window Process", 0
 pszWinStatusText      db "Window Status", 0
 pszWinProcessIdText   db "Window PID", 0
 pszWinThreadIdText    db "Window Thread", 0
 pszIpString           db "%i.%i.%i.%i", 0
 pszIpHelper           db "iphlpapi.dll", 0
 pszGetTable           db "GetTcpTable", 0
 pszGetUdpTable        db "GetUdpTable", 0
 
 pszSymLnkLocation     db "Symbol Locaiton", 0
 pszSymLnkName         db "Dos Device Name", 0
 pszSymLnkSymbol       db "Symbolic Link", 0
 
 pszHandlePid          db "Handle PID", 0
 pszHandleName         db "Handle Name", 0
 pszHandleTypeName     db "Handle Type Name", 0
 pszHandleNumber       db "Handle", 0
 pszHandleFlags        db "Handle Flags", 0
 pszHandleObject       db "Handle Kernel Object", 0
 pszNewLine       db 13, 0, 10, 0, 0, 0
 pszLocalAddress  db "Local Address", 0
 pszLocalPort     db "Local Port", 0
 pszRemoteAddress db "Remote Address", 0
 pszRemotePort    db "Remote Port", 0
 pszState         db "Connection State", 0
 pszConnectType   db "Connection Type", 0
 pszZwOpenDirectoryObject     db "ZwOpenDirectoryObject",0
 pszZwOpenSymbolicLinkObject  db "ZwOpenSymbolicLinkObject",0
 pszZwQuerySymbolicLinkObject db "ZwQuerySymbolicLinkObject",0
 pszZwQueryDirectoryObject    db "ZwQueryDirectoryObject", 0
 
 pszTcpUdpPid     db "PID (XP/2003 Only)", 0
 
 pszTcp           db "TCP", 0
 pszUdp           db "UDP", 0
 
 gEnumChild         db  0
 pszEmptyString     db  0
 gSortType          db  1
 ghToken               DWORD                0
 pszTerminateProcessesCap db "Terminate Processes", 0
 pszTerminateProcessesMsg db "Do you want to terminate selected processes?", 0
 pszDebugProcessesCap     db "Debug Processes", 0
 pszDebugProcessesMsg     db "Do you want to debug the selected processes?", 0
 pszDebugKey              db "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug", 0
 pszDebugValue            db "debugger", 0
 pszDebugPriv             db "SeDebugPrivilege", 0

 ghWndLVProcess           DWORD                0 
 ghWndLVModule            DWORD                0
 ghWndLVWindow            DWORD                0
 ghWndLVMib               DWORD                0
 ghWndLVDlls              DWORD                0
 ghWndLVHandle            DWORD                0
 ghWndCommandWindow       DWORD                0
 ghWndLVSymlnk            DWORD                0
 pszHandlePort            db "Possible Port", 0
 
 pszCannotLoad            db "Count not load QV.DLL", 0
 pszError                 db "Error", 0
 
 pszAllocateAndGetUdpExTableFromStack db "AllocateAndGetUdpExTableFromStack", 0
 pszAllocateAndGetTcpExTableFromStack db "AllocateAndGetTcpExTableFromStack", 0
 AllocateAndGetTcpExTableFromStack  DWORD 0
 AllocateAndGetUdpExTableFromStack  DWORD 0
 
; Remove later 
 pszTemp            db "Comming Soon", 0
 
 ; NOTE: The "Extra ,0" is probably not needed.  It all depends on the assembler.
 ;       In the old days, it was needed.
 
;*********************************************************
; Application Code
;*********************************************************
.CODE

TsysHelp_EntryPoint:
  
  MOV [InitCmmCtrlsEx.dwSize], sizeof(INITCOMMONCONTROLSEX)
  MOV [InitCmmCtrlsEx.dwICC], ICC_LISTVIEW_CLASSES 
  
  PUSH OFFSET InitCmmCtrlsEx
  CALL InitCommonControlsEx

  ;
  ; --- We currently fail if we cannot load NtQueryInformationProcess ----
  ;
  
  PUSH OFFSET pszNtDll
  CALL LoadLibrary
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [hModuleNt], EAX
  
  PUSH OFFSET pszNtQPI
  PUSH EAX
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [NtQueryInformationProcess], EAX
  
  PUSH OFFSET pszNtProcInfo
  PUSH [hModuleNt]
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [NtQuerySystemInformation], EAX
  
  PUSH OFFSET pszZwQueryObject
  PUSH [hModuleNt]
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [ZwQueryObject], EAX
  
  PUSH OFFSET pszZwDuplicateObject
  PUSH [hModuleNt]
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [ZwDuplicateObject], EAX

  PUSH OFFSET pszZwOpenDirectoryObject
  PUSH [hModuleNt]
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [ZwOpenDirectoryObject], EAX

  PUSH OFFSET pszZwOpenSymbolicLinkObject
  PUSH [hModuleNt]
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [ZwOpenSymbolicLinkObject], EAX
  
  PUSH OFFSET pszZwQuerySymbolicLinkObject
  PUSH [hModuleNt]
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [ZwQuerySymbolicLinkObject],EAX
  
  PUSH OFFSET pszZwQueryDirectoryObject
  PUSH [hModuleNt]
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [ZwQueryDirectoryObject], EAX

  
  PUSH OFFSET pszzwCloseHandle
  PUSH [hModuleNt]
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_ExitProcess
  
  MOV [zwCloseHandle], EAX
  ;
  ; --- End NTDLL Functions --
  ;
  
  LEA EAX, [ghToken]
  PUSH EAX
  PUSH TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY
  CALL GetCurrentProcess
  PUSH EAX
  CALL OpenProcessToken
  
  TEST EAX, EAX
  JZ SHORT  @TsysHelp_SkipThisShit  ; Cannot Get Process Token, fuck it.
  
  PUSH 1
  PUSH OFFSET pszDebugPriv
  PUSH [ghToken]
  CALL SetPriv_SetPrivilege         ; Setting Debug Privleges.

  
 @TsysHelp_SkipThisShit:

  PUSH 0
  CALL GetModuleHandle
  MOV  [hInstance], EAX
  
  CALL TsysHelp_RegisterWindow
  CALL TsysHelp_CreateWindow
  MOV  [ghWnd], EAX

  ;  PUSH EAX -- ? I forget why I put this here.
  
  CALL Process_Create
  MOV [ghWndLVProcess], EAX
  
  CALL TsysHelp_LoadProcessView
  
  PUSH SW_SHOWNORMAL
  PUSH [ghWnd]
  CALL ShowWindow

  PUSH [ghWnd]
  CALL UpdateWindow
  
 @TsysHelp_MessageLoop:
 
        PUSH 0
        PUSH 0
        PUSH 0
        PUSH OFFSET Msg
        CALL GetMessage
  
        TEST EAX, EAX
        JZ SHORT @TsysHelp_ExitProcess
        
        PUSH OFFSET Msg
        CALL TranslateMessage
  
        PUSH OFFSET Msg
        CALL DispatchMessage
                
  JMP SHORT @TsysHelp_MessageLoop

 @TsysHelp_ExitProcess:
  
  PUSH 0
  CALL ExitProcess






;*********************************************************
; TsysHelp_RegisterWindow
;
;
;  Registers The Window Class
;
;*********************************************************
TsysHelp_RegisterWindow PROC
  
  MOV ECX, SIZE WNDCLASSEX
  XOR EAX, EAX
  MOV EDI, OFFSET WndClassEx
  REP STOSB                                                     ; Clear Window Class

  MOV EAX, [hInstance]
  MOV [WndClassEx.hInstance], EAX
  MOV [WndClassEx.lpfnWndProc], OFFSET TsysHelp_WindowProcedure
  MOV [WndClassEx.lpszClassName], OFFSET pszWindowClass
  MOV [WndClassEx.lpszMenuName], OFFSET pszProcMenu
  MOV [WndClassEx.cbSize], SIZE WNDCLASSEX
  
  PUSH OFFSET pszIconName
  PUSH EAX
  CALL LoadIcon

  MOV [WndClassEx.hIcon], EAX
  MOV [WndClassEx.hIconSm], EAX
  
  PUSH IDC_ARROW                      
  PUSH 0 
  CALL LoadCursor

  MOV [WndClassEx.hCursor], EAX

  PUSH BLACK_BRUSH
  CALL GetStockObject                  

  MOV [WndClassEx.hbrBackground], EAX

  PUSH OFFSET WndClassEx
  CALL RegisterClassEx
  RET
  
TsysHelp_RegisterWindow ENDP

;*********************************************************
; TsysHelp_LoadToolBar
;
;
;  Creates The Window 
;
;*********************************************************
TsysHelp_LoadToolBar PROC
  
  PUSH OFFSET pszToolBar
  CALL LoadLibrary
  
  TEST EAX, EAX
  JZ @TsysHelp_Fail
  
  MOV [hToolbar], EAX
  
  PUSH OFFSET pszCreateToolBar
  PUSH EAX
  CALL GetProcAddress
  
  TEST EAX, EAX
  JZ @TsysHelp_Fail
  
  PUSH EAX
  
  PUSH OFFSET pszHandleCommands
  PUSH [hToolbar]
  CALL GetProcAddress
  
  MOV [pfnHandleCommands], EAX
  
  POP EAX
  PUSH [ghWnd]
  CALL EAX
  
  MOV [hWndToolbar], EAX
  
  PUSH SW_SHOWNORMAL
  PUSH EAX
  CALL ShowWindow
  
  PUSH [hWndToolbar]
  CALL UpdateWindow
  
  PUSH MF_GRAYED or MF_BYCOMMAND
  PUSH IDM_TOOLBAR
  PUSH [ghWnd]
  CALL GetMenu
  PUSH EAX
  CALL EnableMenuItem

  
  RET
  
 @TsysHelp_Fail:

 
  PUSH MB_OK or MB_ICONWARNING
  PUSH OFFSET pszError
  PUSH OFFSET pszCannotLoad
  PUSH [ghWnd]
  CALL MessageBox
 
  RET
TsysHelp_LoadToolBar ENDP

;*********************************************************
; TsysHelp_CreateWindow
;
;
;  Creates The Window 
;
;*********************************************************
TsysHelp_CreateWindow PROC
    PUSH  0
    PUSH  [hInstance]
    PUSH  0
    PUSH  0
    PUSH  CW_USEDEFAULT
    PUSH  CW_USEDEFAULT
    PUSH  CW_USEDEFAULT
    PUSH  CW_USEDEFAULT
    PUSH  WS_OVERLAPPEDWINDOW or WS_VISIBLE or WS_CAPTION
    PUSH  OFFSET pszWindowCaption
    PUSH  OFFSET pszWindowClass
    PUSH  0
    CALL CreateWindowEx
    RET
TsysHelp_CreateWindow ENDP


;*********************************************************
; TsysHelp_GLEProc
;   
;   The Window Procedure
;   
;
;*********************************************************
;TsysHelp_GLEProc PROC hWnd:DWORD, wMsg:DWORD, wParam:DWORD, lParam:DWORD ;;


;  XOR EAX, EAX
  
 ; CMP [wMsg], WM_INITDIALO;G
;  JNE @TsysHelp_TryCommandMessage;

;  MOV EAX, 1
;  JMP @TsysHelp_ExitGLEProc 
;  
; @TsysHelp_DisplayGLE:
;  
;  SUB ESP, 1024
;  
;  PUSH 0
;  PUSH 0
;  PUSH IDC_ERROR
;  PUSH [hWnd]
;  CALL GetDlgItemInt
;  
;  MOV EBX, ESP
;  
;  MOV ESI, OFFSET pszDefaultMsg
;  MOV EDI, EBX
;  MOV ECX, 10
;  REP MOVSB
;  
;  PUSH 0
;  PUSH 1024
;  PUSH EBX
;;  PUSH 0
;  PUSH EAX
;  PUSH 0
;  PUSH FORMAT_MESSAGE_FROM_SYSTEM
;  CALL FormatMessage
;  
;  PUSH MB_OK
;  PUSH OFFSET pszGLEStr
;  PUSH EBX
;;  PUSH [hWnd]
;  CALL MessageBox
  
;  ADD ESP, 1024
;  
;  JMP @TsysHelp_ExitGLEProc
;  
; @TsysHelp_TryCommandMessage:
;  
;  CMP [wMsg], WM_COMMAND
;  JNE @TsysHelp_ExitGLEProc
;  
;  CMP [wParam], IDOK
;  JE @TsysHelp_DisplayGLE
;  
;  CMP [wParam], IDCANCEL
;  JNE @TsysHelp_ExitGLEProc
;  
;  PUSH 0
;  PUSH [hWnd]
;  CALL EndDialog
;  
;  @TsysHelp_ExitGLEProc:
;  RET
  
;TsysHelp_GLEProc ENDP



;*********************************************************
; TsysHelp_NTStatus
;   
;   The Window Procedure
;   
;
;*********************************************************
;TsysHelp_NTStatus PROC hWnd:DWORD, wMsg:DWORD, wParam:DWORD, lParam:DWORD ;;
;;
;
;  XOR EAX, EAX
;  
;  CMP [wMsg], WM_INITDIALOG
;  JNE @TsysHelp_TryCommandMessage;
;
 ; MOV EAX, 1
;  JMP @TsysHelp_ExitNTSProc 
;  
; @TsysHelp_DisplayNTS:
;  
;  SUB ESP, 1024
;  
;  PUSH 0
;  PUSH 0
;  PUSH IDC_ERROR
;  PUSH [hWnd]
;  CALL GetDlgItemInt
;  
;  MOV EBX, ESP
;  
;  MOV ESI, OFFSET pszDefaultMsg
;  MOV EDI, EBX
;  MOV ECX, 10
;  REP MOVSB
;  
;  PUSH 0
;  PUSH 1024
;  PUSH EBX
;  PUSH 0
;  PUSH EAX
;  PUSH 0
;  PUSH FORMAT_MESSAGE_FROM_SYSTEM
;  CALL FormatMessage
;  
;  PUSH MB_OK
;  PUSH OFFSET pszNTSStr
;  PUSH EBX
;  PUSH [hWnd]
;  CALL MessageBox
;  
;  ADD ESP, 1024
;  
;  JMP @TsysHelp_ExitNTSProc
;  
; @TsysHelp_TryCommandMessage:
;  
;  CMP [wMsg], WM_COMMAND
;  JNE @TsysHelp_ExitNTSProc
;  
;  CMP [wParam], IDOK
;  JE @TsysHelp_DisplayNTS
;  
;  CMP [wParam], IDCANCEL
;  JNE @TsysHelp_ExitNTSProc
;  
;  PUSH 0
;  PUSH [hWnd]
;  CALL EndDialog
;  
;  @TsysHelp_ExitNTSProc:
;  RET
;  
;TsysHelp_NTStatus ENDP



;*********************************************************
; TsysHelp_LoadProcessView
;   
;   
;   
;
;*********************************************************
TsysHelp_LoadProcessView PROC 

  PUSH ECX
  
  MOV EAX, [ghWndLVProcess]
  
  MOV [ghWndLVCurrent], EAX
  
  PUSH SW_SHOW
  PUSH EAX
  CALL ShowWindow  
  
  MOV EAX, OFFSET ProcView_Refresh
  MOV [gRefreshFunction], EAX
  
  MOV EAX, OFFSET ProcView_Sort
  MOV [gSortFunction], EAX
  
  MOV EAX, OFFSET ProcView_ClickFunction
  MOV [gClickFunction], EAX
  
  MOV EAX, OFFSET ProcView_Commands
  MOV [gUserDefinedFunction], EAX
  
  MOV EAX, OFFSET ProcView_Hide
  MOV [gHideFunction], EAX
  
  POP ECX
  RET
  
TsysHelp_LoadProcessView ENDP



;*********************************************************
; TsysHelp_UnLoad
;   
;   
;   
;
;*********************************************************
TsysHelp_UnLoad PROC 
  PUSH ECX
  
  PUSH [ghWndLVModule]
  PUSH [ghWnd]
  CALL [gHideFunction]
  
  PUSH SW_HIDE
  PUSH [ghWndLVCurrent]
  CALL ShowWindow
  
  POP ECX
  
  RET
  
TsysHelp_UnLoad ENDP

;*********************************************************
; TsysHelp_LoadModuleView
;   
;   
;   
;
;*********************************************************
TsysHelp_LoadModuleView PROC 
  PUSH ECX
  
  MOV EAX, [ghWndLVModule]
  
  TEST EAX, EAX
  JNZ @TsysHelp_BeginModuleLoad
  
 
  CALL Module_Create
  
  MOV [ghWndLVModule], EAX

  
 @TsysHelp_BeginModuleLoad:
  MOV [ghWndLVCurrent], EAX
  
  PUSH SW_SHOW
  PUSH EAX
  CALL ShowWindow
  
  MOV EAX, OFFSET ModView_Refresh
  MOV [gRefreshFunction], EAX
  
  MOV EAX, OFFSET ModView_Sort
  MOV [gSortFunction], EAX
  
  MOV EAX, OFFSET ModView_ClickFunction
  MOV [gClickFunction], EAX
  
  MOV EAX, OFFSET ModView_Commands
  MOV [gUserDefinedFunction], EAX
  
  MOV EAX, OFFSET ModView_Hide
  MOV [gHideFunction], EAX
  
  
  POP ECX
  
  RET
  
TsysHelp_LoadModuleView ENDP


;*********************************************************
; TsysHelp_LoadMibView
;   
;   
;   
;
;*********************************************************
TsysHelp_LoadMibView PROC
  LOCAL hHelper :DWORD
  
  PUSH ECX
  
  MOV EAX, [ghWndLVMib]
  
  TEST EAX, EAX
  JNZ @TsysHelp_BeginModuleLoad
  
  PUSH OFFSET pszIpHelper
  CALL LoadLibrary
  MOV [hHelper], EAX
  
  PUSH OFFSET pszGetTable
  PUSH EAX
  CALL GetProcAddress
  
  MOV [MIB_GetTcpTable], EAX
  
  PUSH OFFSET pszGetUdpTable
  PUSH [hHelper]
  CALL GetProcAddress
  
  MOV [MIB_GetUdpTable], EAX  
  
  PUSH OFFSET pszAllocateAndGetUdpExTableFromStack
  PUSH [hHelper]
  CALL GetProcAddress
  
  MOV [AllocateAndGetUdpExTableFromStack], EAX
  
  PUSH OFFSET pszAllocateAndGetTcpExTableFromStack
  PUSH [hHelper]
  CALL GetProcAddress
  
  MOV [AllocateAndGetTcpExTableFromStack], EAX
 
  CALL Mib_Create
  
  MOV [ghWndLVMib], EAX

  
 @TsysHelp_BeginModuleLoad:
  MOV [ghWndLVCurrent], EAX
  
  PUSH SW_SHOW
  PUSH EAX
  CALL ShowWindow
  
  MOV EAX, OFFSET MibView_Refresh
  MOV [gRefreshFunction], EAX
  
  MOV EAX, OFFSET MibView_Sort
  MOV [gSortFunction], EAX
  
  MOV EAX, OFFSET MibView_ClickFunction
  MOV [gClickFunction], EAX
  
  MOV EAX, OFFSET MibView_Commands
  MOV [gUserDefinedFunction], EAX
  
  MOV EAX, OFFSET MibView_Hide
  MOV [gHideFunction], EAX
  
  
  POP ECX
  
  RET
  
TsysHelp_LoadMibView ENDP


;*********************************************************
; TsysHelp_LoadCommandView
;   
;   
;   
;
;*********************************************************
TsysHelp_LoadCommandView PROC
  PUSH ECX
  
  MOV EAX, [ghWndCommandWindow]
  
  TEST EAX, EAX
  JNZ @TsysHelp_BeginModuleLoad
  
 
  CALL Command_Create
  
  MOV [ghWndCommandWindow], EAX

  
 @TsysHelp_BeginModuleLoad:
  MOV [ghWndLVCurrent], EAX
  
  PUSH SW_SHOW
  PUSH EAX
  CALL ShowWindow
  
  MOV EAX, OFFSET CommandView_Refresh
  MOV [gRefreshFunction], EAX
  
  MOV EAX, OFFSET CommandView_Sort
  MOV [gSortFunction], EAX
  
  MOV EAX, OFFSET CommandView_ClickFunction
  MOV [gClickFunction], EAX
  
  MOV EAX, OFFSET CommandView_Commands
  MOV [gUserDefinedFunction], EAX
  
  MOV EAX, OFFSET CommandView_Hide
  MOV [gHideFunction], EAX
  
  
  POP ECX
  
  RET

TsysHelp_LoadCommandView ENDP

;*********************************************************
; TsysHelp_LoadWindowView
;   
;   
;   
;
;*********************************************************
TsysHelp_LoadWindowView PROC 
  PUSH ECX
  
  MOV EAX, [ghWndLVWindow]
  
  TEST EAX, EAX
  JNZ @TsysHelp_BeginModuleLoad
  
 
  CALL Window_Create
  
  MOV [ghWndLVWindow], EAX

  
 @TsysHelp_BeginModuleLoad:
  MOV [ghWndLVCurrent], EAX
  
  PUSH SW_SHOW
  PUSH EAX
  CALL ShowWindow
  
  MOV EAX, OFFSET WinView_Refresh
  MOV [gRefreshFunction], EAX
  
  MOV EAX, OFFSET WinView_Sort
  MOV [gSortFunction], EAX
  
  MOV EAX, OFFSET WinView_ClickFunction
  MOV [gClickFunction], EAX
  
  MOV EAX, OFFSET WinView_Commands
  MOV [gUserDefinedFunction], EAX
  
  MOV EAX, OFFSET WinView_Hide
  MOV [gHideFunction], EAX
  
  
  POP ECX
  
  RET
  
TsysHelp_LoadWindowView ENDP



;*********************************************************
; TsysHelp_LoadDllsView
;   
;   
;   
;
;*********************************************************
TsysHelp_LoadDllsView PROC 
  PUSH ECX
  
  MOV EAX, [ghWndLVDlls]
  
  TEST EAX, EAX
  JNZ @TsysHelp_BeginModuleLoad
  
 
  CALL Dlls_Create
  
  MOV [ghWndLVDlls], EAX

  
 @TsysHelp_BeginModuleLoad:
  MOV [ghWndLVCurrent], EAX
  
  PUSH SW_SHOW
  PUSH EAX
  CALL ShowWindow
  
  MOV EAX, OFFSET DllsView_Refresh
  MOV [gRefreshFunction], EAX
  
  MOV EAX, OFFSET DllsView_Sort
  MOV [gSortFunction], EAX
  
  MOV EAX, OFFSET DllsView_ClickFunction
  MOV [gClickFunction], EAX
  
  MOV EAX, OFFSET DllsView_Commands
  MOV [gUserDefinedFunction], EAX
  
  MOV EAX, OFFSET DllsView_Hide
  MOV [gHideFunction], EAX
  
  
  POP ECX
  
  RET
  
TsysHelp_LoadDllsView ENDP


;*********************************************************
; TsysHelp_LoadSymbolsView
;   
;   
;   
;
;*********************************************************
TsysHelp_LoadSymbolsView PROC
  PUSH ECX
  
  MOV EAX, [ghWndLVSymlnk]
  
  TEST EAX, EAX
  JNZ @TsysHelp_BeginModuleLoad
  
 
  CALL Symlnk_Create
  
  MOV [ghWndLVSymlnk], EAX

  
 @TsysHelp_BeginModuleLoad:
  MOV [ghWndLVCurrent], EAX
  
  PUSH SW_SHOW
  PUSH EAX
  CALL ShowWindow
  
  MOV EAX, OFFSET SymlnkView_Refresh
  MOV [gRefreshFunction], EAX
  
  MOV EAX, OFFSET SymlnkView_Sort
  MOV [gSortFunction], EAX
  
  MOV EAX, OFFSET SymlnkView_ClickFunction
  MOV [gClickFunction], EAX
  
  MOV EAX, OFFSET SymlnkView_Commands
  MOV [gUserDefinedFunction], EAX
  
  MOV EAX, OFFSET SymlnkView_Hide
  MOV [gHideFunction], EAX
  
  
  POP ECX
  
  RET  
TsysHelp_LoadSymbolsView ENDP

;*********************************************************
; TsysHelp_LoadHandleView
;   
;   
;   
;
;*********************************************************
TsysHelp_LoadHandleView PROC
  PUSH ECX
  
  MOV EAX, [ghWndLVHandle]
  
  TEST EAX, EAX
  JNZ @TsysHelp_BeginModuleLoad
  
 
  CALL Handle_Create
  
  MOV [ghWndLVHandle], EAX

  
 @TsysHelp_BeginModuleLoad:
  MOV [ghWndLVCurrent], EAX
  
  PUSH SW_SHOW
  PUSH EAX
  CALL ShowWindow
  
  MOV EAX, OFFSET HandView_Refresh
  MOV [gRefreshFunction], EAX
  
  MOV EAX, OFFSET HandView_Sort
  MOV [gSortFunction], EAX
  
  MOV EAX, OFFSET HandView_ClickFunction
  MOV [gClickFunction], EAX
  
  MOV EAX, OFFSET HandView_Commands
  MOV [gUserDefinedFunction], EAX
  
  MOV EAX, OFFSET HandView_Hide
  MOV [gHideFunction], EAX
  
  
  POP ECX
  
  RET
TsysHelp_LoadHandleView ENDP


;*********************************************************
; TsysHelp_AboutProc
;   
;   The Window Procedure
;   
;
;*********************************************************
TsysHelp_AboutProc PROC hWnd:DWORD, wMsg:DWORD, wParam:DWORD, lParam:DWORD 
  XOR EAX, EAX
  
  CMP [wMsg], WM_INITDIALOG
  JNE @TsysHelp_TryCommandMessage
  
  MOV EAX, 1
  JMP @TsysHelp_ExitAboutDialog 
  
@TsysHelp_TryCommandMessage:
  
  CMP [wMsg], WM_COMMAND
  JNE @TsysHelp_ExitAboutDialog
  
  PUSH 0
  PUSH [hWnd]
  CALL EndDialog
  
  @TsysHelp_ExitAboutDialog:
  RET
  
TsysHelp_AboutProc ENDP
  

;*********************************************************
; Plasma_WindowProcedure
;   
;   The Window Procedure
;   
;
;*********************************************************
TsysHelp_WindowProcedure PROC hWnd:DWORD, wMsg:DWORD, wParam:DWORD, lParam:DWORD  
  
 MOV EAX, [wMsg]
 
 ;
 ; WM_COMMAND
 ; 
 
 CMP EAX, WM_COMMAND
 JE @TsysHelp_HandleCommand

 ;
 ; WM_COMMAND
 ; 
 
 CMP EAX, WM_NOTIFY
 JE @TsysHelp_HandleNotify
  

 ;
 ; WM_SIZE
 ;    
 ;    Used to resize the List-View
 ; 
 CMP EAX, WM_SIZE
 JE @TsysHelp_HandleSize
 
  
 ;
 ; WM_CREATE
 ;    
 ;    This only happens once, so put it here at the end.
 ; 
 CMP EAX, WM_CREATE
 JE @TsysHelp_HandleCreate  
  
 ;
 ; WM_DESTROY & WM_CLOSE
 ;    
 ;    These only happen once, so put them here near the end.
 ; 
 
 CMP EAX, WM_DESTROY
 JE @TsysHelp_DestroyWindow
  
 CMP EAX, WM_CLOSE
 JE @TsysHelp_CloseWindow
 
 ;
 ;
 ; Message Not Handled, Default Procedure
 ;
 ;
 
 JMP @TsysHelp_DefaultWindow
 

 
 ; WM_DESTROY & WM_CLOSEWINDOW
 @TsysHelp_DestroyWindow:
 @TsysHelp_CloseWindow:
  PUSH 0
  CALL PostQuitMessage
  
  XOR EAX, EAX
  JMP @TsysHelp_ExitWindowsProc 
 
 ; About Box

 @TsysHelp_DisplayAbout:
 
  PUSH 0
  PUSH TsysHelp_AboutProc
  PUSH [hWnd]
  PUSH OFFSET pszAboutDialog
  PUSH [hInstance]
  CALL DialogBoxParamA
  
  ;
  ; No need to display about box on WM_CREATE
  ;
  @TsysHelp_HandleCreate:
  XOR EAX, EAX
  JMP @TsysHelp_ExitWindowsProc 


 @TsysHelp_HandleSize:
 
  PUSH OFFSET ClientRect
  PUSH [ghWnd]
  CALL GetClientRect
  
  CMP [hWndToolbar], 0
  JE @TSysHelp_NoAdjustments

  PUSH 0
  PUSH 0
  PUSH TB_AUTOSIZE
  PUSH [hWndToolbar]
  CALL SendMessage
  
  PUSH OFFSET ClientRectToolbar
  PUSH [hWndToolbar]
  CALL GetWindowRect
  
  MOV EAX, [ClientRectToolbar.bottom]
  SUB EAX, [ClientRectToolbar.top]
  MOV EBX, [ClientRect.bottom]
  SUB EBX, EAX
  
  PUSH SWP_NOZORDER
  PUSH EBX
  PUSH [ClientRect.right]
  PUSH EAX
  PUSH 0
  PUSH 0
  PUSH [ghWndLVCurrent]  
  CALL SetWindowPos  
  
  
  JMP @TsysHelp_DefaultWindow
  
 @TSysHelp_NoAdjustments:
  PUSH SWP_NOZORDER
  PUSH [ClientRect.bottom]
  PUSH [ClientRect.right]
  PUSH 0
  PUSH 0
  PUSH 0
  PUSH [ghWndLVCurrent]  
  CALL SetWindowPos
  
  JMP @TsysHelp_DefaultWindow

;
;
; WM_NOTIFY
;
 @TsysHelp_HandleNotify:
  MOV EAX, [lParam]
  MOV EBX, [ghWndLVCurrent]
  
  CMP [EAX], EBX
  JNE @TsysHelp_DefaultWindow
  
  MOV EDX, LVN_COLUMNCLICK
  CMP [EAX + 8], EDX
  JE @TsysHelp_SortListView
  
  MOV EDX, [EAX + 8]
  CMP EDX, LVN_KEYDOWN 
  JE @TsysHelp_KeyDown
  
  CMP EDX, NM_RCLICK 
  JE @TsysHelp_RightClick  
  
  JMP @TsysHelp_DefaultWindow
 
 @TsysHelp_RightClick:
  
  PUSH [EAX + 10h] ; SubItem
  PUSH [EAX + 0Ch] ; Item
  PUSH [ghWndLVCurrent]
  PUSH [hWnd]
  MOV EAX, [gClickFunction]
  CALL EAX
 
  JMP @TsysHelp_DefaultWindow
  
 @TsysHelp_KeyDown:
  
  MOV DX, [EAX + 0Ch]
  
  CMP DX, VK_F5
  JE @TsysHelp_Refresh
 
  JMP @TsysHelp_DefaultWindow
 @TsysHelp_SortListView:
  
  MOV EDX, [gSortFunction]
  
  PUSH [EAX + 10h]
  PUSH [ghWndLVCurrent]
  CALL EDX
  
  JMP @TsysHelp_DefaultWindow
   
 @TsysHelp_HandleCommand:
  MOV EAX, [wParam]
  AND EAX, 0FFFFh                       ; Filter for Lower Word
                                     
  
  CMP EAX, IDM_ABOUT
  JE @TsysHelp_DisplayAbout
  
  CMP EAX, IDM_EXIT
  JE @TsysHelp_Exit
  
  CMP EAX, IDM_REFRESH
  JE @TsysHelp_Refresh  
  
  CMP EAX, IDM_TOOLBAR_WINDOW
  JE @TsysHelp_TBW

  CMP EAX, IDM_HEX 
  JE @TsysHelp_TBW
                        
  CMP EAX, IDM_DEC                       
  JE @TsysHelp_TBW
  
  CMP EAX, IDM_BUTTON_OK
  JE @TsysHelp_TBW
  
  CMP EAX, IDM_NOTUSED                  
  JE @TsysHelp_TBW
  
  CMP EAX, IDM_NTA                       
  JE @TsysHelp_TBW
  
  CMP EAX, IDM_NTB                       
  JE @TsysHelp_TBW

  CMP EAX, IDM_GLE2                      
  JE @TsysHelp_TBW
  
  CMP EAX, IDM_MSG                      
  JE @TsysHelp_TBW
  
  CMP EAX, IDM_EDIT_WINDOW              
  JE @TsysHelp_TBW
  
  CMP EAX, IDM_TOOLBAR
  JE @TsysHelp_LoadToolDll
  
 ; CMP EAX, IDM_GLE
 ; JE @TsysHelp_GLE
  
 ; CMP EAX, IDM_NT_STATUS
 ; JE @TsysHelp_NTS
  
  CMP EAX, IDM_PROCVIEW
  JE @TsysHelp_SwitchToProcView
  
  CMP EAX, IDM_DRIVEVIEW              
  JE @TsysHelp_SwitchToModView
  
  CMP EAX, IDM_WINDOWS
  JE @TsysHelp_SwitchToWindowView
  
  CMP EAX, IDM_MIDVIEW
  JE @TsysHelp_SwitchToMibNetwork
  
  CMP EAX, IDM_MODVIEW
  JE @TsysHelp_SwitchToDllsView
  
  CMP EAX, IDM_HANDLES
  JE @TsysHelp_SwitchToHandleView
  
  CMP EAX, IDM_CMDVIEW
  JE @TsysHelp_SwitchToCommandView 
  
  CMP EAX, IDM_SYMBOLS
  JE @TsysHelp_SwitchToSymbolsView 
  
  CMP EAX, IDC_USER_DEFINED
  JAE @TsysHelp_UserDefined
  
  JMP @TsysHelp_DefaultWindow
 
 @TsysHelp_TBW:
  PUSH [lParam]
  PUSH [wParam]
  PUSH [hWnd]
  CALL [pfnHandleCommands]
  JMP @TsysHelp_ExitWindowsProc
  
 @TsysHelp_SwitchToSymbolsView:
 
  PUSH EAX
  CALL TsysHelp_CheckBawx
  
  CALL TsysHelp_UnLoad  
  CALL TsysHelp_LoadSymbolsView
  JMP @TsysHelp_HandleSize
 
 @TsysHelp_SwitchToCommandView:
  PUSH EAX
  CALL TsysHelp_CheckBawx
  
  CALL TsysHelp_UnLoad  
  CALL TsysHelp_LoadCommandView
  JMP @TsysHelp_HandleSize
  
 @TsysHelp_LoadToolDll:
  CALL TsysHelp_LoadToolBar
  JMP @TsysHelp_HandleSize
 
 @TsysHelp_SwitchToHandleView:
  PUSH EAX
  CALL TsysHelp_CheckBawx
  
  CALL TsysHelp_UnLoad  
  CALL TsysHelp_LoadHandleView
  JMP @TsysHelp_HandleSize
  
 @TsysHelp_SwitchToDllsView:
  PUSH EAX
  CALL TsysHelp_CheckBawx
  
  CALL TsysHelp_UnLoad  
  CALL TsysHelp_LoadDllsView
  JMP @TsysHelp_HandleSize
   
 @TsysHelp_SwitchToWindowView:
  PUSH EAX
  CALL TsysHelp_CheckBawx
  
  CALL TsysHelp_UnLoad 
  CALL TsysHelp_LoadWindowView
  
  JMP @TsysHelp_HandleSize
 
 @TsysHelp_SwitchToMibNetwork:

  PUSH EAX
  CALL TsysHelp_CheckBawx
  
  CALL TsysHelp_UnLoad 
  CALL TsysHelp_LoadMibView
  
  JMP @TsysHelp_HandleSize
 
  
 @TsysHelp_SwitchToProcView:
 
  PUSH EAX
  CALL TsysHelp_CheckBawx
  
  CALL TsysHelp_UnLoad 
  CALL TsysHelp_LoadProcessView
  
  JMP @TsysHelp_HandleSize
  
 @TsysHelp_SwitchToModView:
 
  PUSH EAX
  CALL TsysHelp_CheckBawx
  
  CALL TsysHelp_UnLoad
  CALL TsysHelp_LoadModuleView
 
  JMP @TsysHelp_HandleSize
  
  
 @TsysHelp_UserDefined:
  PUSH EAX
  PUSH [ghWndLVCurrent]
  PUSH [hWnd]
  MOV EAX, [gUserDefinedFunction]
  CALL EAX
  JMP @TsysHelp_DefaultWindow
  
 @TsysHelp_Refresh:
  PUSH [ghWndLVCurrent]
  MOV EAX, [gRefreshFunction]
  CALL EAX
  JMP  @TsysHelp_DefaultWindow
  
 @TsysHelp_Exit:
  PUSH [hWnd]
  CALL DestroyWindow
  JMP @TsysHelp_DefaultWindow

 ;@TsysHelp_NTS:
  
  
 ; PUSH 0
 ; PUSH TsysHelp_NTStatus
 ; PUSH [hWnd]
 ; PUSH OFFSET pszNTSDialog
 ; PUSH [hInstance]
 ; CALL DialogBoxParamA  
  
  ;JMP @TsysHelp_DefaultWindow
  
 ;@TsysHelp_GLE:
  
  
 ; PUSH 0
 ; PUSH TsysHelp_GLEProc
 ; PUSH [hWnd]
 ; PUSH OFFSET pszGLEDialog
 ; PUSH [hInstance]
 ; CALL DialogBoxParamA  
  
 ; JMP @TsysHelp_DefaultWindow
  
 ; Default Message Procedure   
 @TsysHelp_DefaultWindow:
  PUSH [lParam]
  PUSH [wParam]
  PUSH [wMsg]
  PUSH [hWnd]
  CALL DefWindowProc
  
 @TsysHelp_ExitWindowsProc:
  RET
TsysHelp_WindowProcedure ENDP

;*********************************************************
; TsysHelp_CheckBawx
;   
;   The Window Procedure
;   
;
;*********************************************************
TsysHelp_CheckBawx PROC iChecker :DWORD
LOCAL hMenu :DWORD
  PUSHA
  PUSH [ghWnd]
  CALL GetMenu
  MOV [hMenu], EAX
  
  PUSH MF_UNCHECKED or MF_BYCOMMAND
  PUSH IDM_CMDVIEW
  PUSH [hMenu]
  CALL CheckMenuItem

  PUSH MF_UNCHECKED or MF_BYCOMMAND
  PUSH IDM_SYMBOLS
  PUSH [hMenu]
  CALL CheckMenuItem

  PUSH MF_UNCHECKED or MF_BYCOMMAND
  PUSH IDM_PROCVIEW
  PUSH [hMenu]
  CALL CheckMenuItem
  
  PUSH MF_UNCHECKED or MF_BYCOMMAND
  PUSH IDM_DRIVEVIEW
  PUSH [hMenu]
  CALL CheckMenuItem
  
  PUSH MF_UNCHECKED or MF_BYCOMMAND
  PUSH IDM_WINDOWS
  PUSH [hMenu]
  CALL CheckMenuItem
  
  PUSH MF_UNCHECKED or MF_BYCOMMAND
  PUSH IDM_MIDVIEW
  PUSH [hMenu]
  CALL CheckMenuItem
    
  PUSH MF_UNCHECKED or MF_BYCOMMAND
  PUSH IDM_MODVIEW
  PUSH [hMenu]
  CALL CheckMenuItem
  
  PUSH MF_UNCHECKED or MF_BYCOMMAND
  PUSH IDM_HANDLES
  PUSH [hMenu]
  CALL CheckMenuItem  
      
  PUSH MF_CHECKED or MF_BYCOMMAND
  PUSH [iChecker]
  PUSH [hMenu]
  CALL CheckMenuItem
  
  POPA
  RET
TsysHelp_CheckBawx ENDP

;
; External Assembly Includes
;

include listview.asm
include process.asm
include plugin.asm
include setpriv.asm
include modules.asm
include windows.asm
include mib.asm
include dlls.asm
include handles.asm
include command.asm
include symlnk.asm

END TsysHelp_EntryPoint


