/*
 *  Module Query
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
void ModuleQuery_DisplayCommandLineArguments(void);
void ModuleQuery_DisplayAllModuleInformation(void);
void ModuleQuery_DisplayModuleInformation(DWORD dwPID);
BOOL WINAPI ModuleQuery_DisplayModuleInformationCallBackNarrowDisplay(PVOID pContext, PMODINFO pModInfo);
void ModuleQuery_Initialize(void);
void ModuleQuery_DumpModuleInfoStructure(PMODINFO pModInfo);
void ModuleQuery_PerformActions(void);


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
    ModuleQuery_Initialize();
    ModuleQuery_PerformActions();

    return 0;
}



/***********************************************
 *
 * ModuleQuery_PerformActions
 *
 *  
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ModuleQuery_PerformActions(void)
{
    DWORD dwPID = 0;
    COMMAND_LINE_MAP CommandLineMap[2] = {
        { "/?"        , CMD_FLAGS_ONLY_OPTION, 0, NULL, 0, FALSE },
        { "/pid"      , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_DEC, &dwPID, sizeof(dwPID), FALSE }
    };
    
    if(Utils_ParseCommandLine(CommandLineMap, 2))
    {
        if(CommandLineMap[0].bSwitchedOn)
        {
           ModuleQuery_DisplayCommandLineArguments();
        }

        if(CommandLineMap[1].bSwitchedOn)
        {
           ModuleQuery_DisplayModuleInformation(dwPID);
        }
    }
    else
    {
        ModuleQuery_DisplayAllModuleInformation();
    }
}


/***********************************************
 *
 * ModuleQuery_DisplayCommandLineArguments
 *
 * Display Command Line Arguements 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ModuleQuery_DisplayCommandLineArguments(void)
{
    printf(" Module Query Utility\r\n");
    printf("   Toby Opferman (c) Copyright 2004, All Rights Reserved\r\n\r\n");
    printf("   Usage:\r\n");
    printf("         MODQ [ /pid <pid> ]\r\n\r\n");
    printf("              MODQ            - Display modules in all processes.\r\n");
    printf("              MODQ /pid <pid> - Display modules in process pid.\r\n");

}


/***********************************************
 *
 * ModuleQuery_DisplayAllModuleInformation
 *
 * Display All Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ModuleQuery_DisplayAllModuleInformation(void)
{
   ProcLib_EnumerateProcessModuleInformation(ModuleQuery_DisplayModuleInformationCallBackNarrowDisplay, NULL);
}

/***********************************************
 *
 * ModuleQuery_DisplayProcessInformation
 *
 * Display Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ModuleQuery_DisplayModuleInformation(DWORD dwPID)
{

   if(!PEB_QueryAllLoadedModulesW(dwPID, ModuleQuery_DisplayModuleInformationCallBackNarrowDisplay, NULL))
   {
       printf("\r\nFailed to retrieve information for PID %i\r\n", dwPID);
   }

   
}

/***********************************************
 *
 * ModuleQuery_DisplayModuleInformationCallBackNarrowDisplay
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
BOOL WINAPI ModuleQuery_DisplayModuleInformationCallBackNarrowDisplay(PVOID pContext, PMODINFO pModInfo)
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

    ModuleQuery_DumpModuleInfoStructure(pModInfo);

    return TRUE;
}


/***********************************************
 *
 * ModuleQuery_DumpModuleInfoStructure
 *
 * Dump Module Information Structure 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ModuleQuery_DumpModuleInfoStructure(PMODINFO pModInfo)
{

    printf("\r\nModule     '%ws'\r\n", pModInfo->szwImageName);
    printf("PID:            %i\r\n", pModInfo->dwPID);
    printf("Start Address:  0x%0x\r\n", pModInfo->dwStartAddress);
    printf("End Address:    0x%0x\r\n", pModInfo->dwStartAddress + pModInfo->dwModuleSize);
    printf("Module Entry:   0x%0x\r\n", pModInfo->dwModuleEntryPoint);
    printf("Module Length:  0x%0x\r\n", pModInfo->dwModuleSize);
    
}


/***********************************************
 *
 * ModuleQuery_DisplayProcessInformationCallBackWideDisplay
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void ModuleQuery_Initialize(void)
{
    Init_ProcessLibrary();
    PrivLib_EnableProcessForDebug();
}

