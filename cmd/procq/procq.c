/*
 *  Process Query
 *
 *  Command Line Application
 *
 *  Toby Opferman
 *
 *  Copyright 2004, All Rights Reserved
 *
 */
 
 
#include <windows.h>
#include <stdio.h>
#include <proclib.h>
#include <privlib.h>
#include <utils.h>


/***********************************************
 * Prototypes
 ***********************************************/
void ProcessQuery_DisplayCommandLineArguments(void);
void ProcessQuery_DisplayAllProcessInformation(void);
void ProcessQuery_DisplayProcessInformationQuick(void);
void ProcessQuery_DisplayProcessInformation(DWORD dwPID);
BOOL WINAPI ProcessQuery_DisplayProcessInformationCallBackNarrowDisplay(PVOID pContext, PPROCINFO pProcInfo);
BOOL WINAPI ProcessQuery_DisplayProcessInformationCallBackQuickDisplay(PVOID pContext, PPROCINFO pProcInfo);
void ProcessQuery_Initialize(void);
void ProcessQuery_DumpProcessInfoStructure(PPROCINFO pProcInfo);
void ProcessQuery_PerformActions(void);

/***********************************************
 *
 * WinMain
 *
 * Parameters
 *   Default Windows Parameters
 *
 * Return Value
 *   0
 ***********************************************/
int __cdecl main(int argc, char *argv[])
{
    ProcessQuery_Initialize();
    ProcessQuery_PerformActions();

    return 0;
}


/***********************************************
 *
 * ProcessQuery_PerformActions
 *
 *  
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ProcessQuery_PerformActions(void)
{
    DWORD dwPID = 0;
    COMMAND_LINE_MAP CommandLineMap[3] = {
        { "/?"        , CMD_FLAGS_ONLY_OPTION, 0, NULL, 0, FALSE },
        { "/quick", CMD_FLAGS_ONLY_OPTION, 0, NULL, 0, FALSE },
        { "/pid"      , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_DEC, &dwPID, sizeof(dwPID), FALSE }
    };
    
    if(Utils_ParseCommandLine(CommandLineMap, 3))
    {
        if(CommandLineMap[0].bSwitchedOn)
        {
           ProcessQuery_DisplayCommandLineArguments();
        }

        if(CommandLineMap[1].bSwitchedOn)
        {
           ProcessQuery_DisplayProcessInformationQuick();
        }

        if(CommandLineMap[2].bSwitchedOn)
        {
           ProcessQuery_DisplayProcessInformation(dwPID);
        }
    }
    else
    {
        ProcessQuery_DisplayAllProcessInformation();
    }
}

/***********************************************
 *
 * ProcessQuery_DisplayCommandLineArguments
 *
 * Display Command Line Arguements 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ProcessQuery_DisplayCommandLineArguments(void)
{
    printf(" Process Query Utility\r\n");
    printf("   Toby Opferman (c) Copyright 2004, All Rights Reserved\r\n\r\n");
    printf("   Usage:\r\n");
    printf("         PROCQ [ /pid <pid> | /quick ]\r\n\r\n");
    printf("               PROCQ          - Display all process information\r\n");
    printf("               PROCQ /quick   - Quick List\r\n");
    printf("               PROCQ /pid <pid> - Information for this PID only.\r\n");
}


/***********************************************
 *
 * ProcessQuery_DisplayAllProcessInformation
 *
 * Display All Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ProcessQuery_DisplayAllProcessInformation(void)
{
   ProcLib_EnumerateProcessInformation(ProcessQuery_DisplayProcessInformationCallBackNarrowDisplay, NULL);
}



/***********************************************
 *
 * ProcessQuery_DisplayProcessInformationQuick
 *
 * Display All Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ProcessQuery_DisplayProcessInformationQuick(void)
{
   ProcLib_EnumerateProcessInformation(ProcessQuery_DisplayProcessInformationCallBackQuickDisplay, NULL);
}


/***********************************************
 *
 * ProcessQuery_DisplayProcessInformation
 *
 * Display Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ProcessQuery_DisplayProcessInformation(DWORD dwPID)
{
   PROCINFO ProcInfo = {0};

   ProcInfo.dwSize = sizeof(ProcInfo);
   ProcInfo.dwPID = dwPID;

   if(ProcLib_QueryProcessInformationByPID(dwPID, &ProcInfo))
   {
      ProcessQuery_DumpProcessInfoStructure(&ProcInfo);
   }
   else
   {
       printf("\r\nFailed to retrieve information for PID %i\r\n", dwPID);
   }

   
}

/***********************************************
 *
 * ProcessQuery_DisplayProcessInformationCallBackWideDisplay
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
BOOL WINAPI ProcessQuery_DisplayProcessInformationCallBackNarrowDisplay(PVOID pContext, PPROCINFO pProcInfo)
{
    static BOOL bFirstTime = TRUE;

    if(bFirstTime)
    {
        bFirstTime = FALSE;
    }
    else
    {
        printf("\r\n<--------------------------->\r\n");
    }

    ProcessQuery_DumpProcessInfoStructure(pProcInfo);

    return TRUE;
}

/***********************************************
 *
 * ProcessQuery_DisplayProcessInformationCallBackQuickDisplay
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
BOOL WINAPI ProcessQuery_DisplayProcessInformationCallBackQuickDisplay(PVOID pContext, PPROCINFO pProcInfo)
{
    static BOOL bFirstTime = TRUE;

    if(bFirstTime)
    {
        printf("\r\nPROCESS                   \tPID\t\tSESSION\r\n");

        bFirstTime = FALSE;
    }

    printf("%-25s\t%i\t\t%i\r\n", pProcInfo->szShortImageName, pProcInfo->dwPID, pProcInfo->dwSession);
    
    return TRUE;
}


/***********************************************
 *
 * ProcessQuery_DumpProcessInfoStructure
 *
 * Dump Process Information Structure 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ProcessQuery_DumpProcessInfoStructure(PPROCINFO pProcInfo)
{

    printf("\r\nProcess        '%s'\r\n", pProcInfo->szImageName);
    printf("CommandLine    '%s'\r\n", pProcInfo->szCommandLine);
    printf("PID:            %i\r\n", pProcInfo->dwPID);
    printf("Parent PID:     %i\r\n", pProcInfo->dwParentPID);
    printf("Session ID:     %i\r\n", pProcInfo->dwSession);
    printf("Threads:        %i\r\n", pProcInfo->dwThreads);
    printf("Handles:        %i\r\n", pProcInfo->dwHandles);
    printf("Total VM:       %iK (%i Bytes)\r\n", pProcInfo->VmInfo.dwVirtualMemory/1024, pProcInfo->VmInfo.dwVirtualMemory);
    printf("WorkingSet:     %iK (%i Bytes)\r\n", pProcInfo->VmInfo.dwWorkingSet/1024, pProcInfo->VmInfo.dwWorkingSet);
    printf("PageFile Usage: %iK (%i Bytes)\r\n", pProcInfo->VmInfo.dwPageFileUsage/1024, pProcInfo->VmInfo.dwPageFileUsage);
    printf("PagedPool:      %iK (%i Bytes)\r\n", pProcInfo->VmInfo.dwPagedPool/1024, pProcInfo->VmInfo.dwPagedPool);
    printf("NonPagedPool:   %iK (%i Bytes)\r\n", pProcInfo->VmInfo.dwNonPagedPool/1024, pProcInfo->VmInfo.dwNonPagedPool);

    
}


/***********************************************
 *
 * ProcessQuery_DisplayProcessInformationCallBackWideDisplay
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ProcessQuery_Initialize(void)
{
    Init_ProcessLibrary();
    PrivLib_EnableProcessForDebug();
}

