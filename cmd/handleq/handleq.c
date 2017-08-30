/*
 *  Handle Query
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
#include <handle.h>
#include <utils.h>

#define NULL_PROTECT_STRINGW(x) (x ? x : L"")

/***********************************************
 * Prototypes
 ***********************************************/
void HandleQuery_DisplayCommandLineArguments(void);
void HandleQuery_PerformActions(void);
void HandleQuery_DisplayAllHandleInformation(void);
void HandleQuery_DisplayHandleInformation(DWORD dwPID);
BOOL WINAPI HandleQuery_DisplayHandleInformationCallBack(PVOID pContext, PHANDLEINFO pHandleInfo);
void HandleQuery_Initialize(void);
void HandleQuery_DumpHandleInfoStructure(PHANDLEINFO pHandleInfo);
void HandleQuery_DisplayHandleInformationForPortsOnly(void);
BOOL WINAPI HandleQuery_DisplayHandleInformationCallBackPortsOnly(PVOID pContext, PHANDLEINFO pHandleInfo);
             

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
    HandleQuery_Initialize();
    HandleQuery_PerformActions();

    return 0;
}


/***********************************************
 *
 * HandleQuery_PerformActions
 *
 * Parameters
 *   None
 *
 * Return Value
 *   0
 ***********************************************/
void HandleQuery_PerformActions(void)
{
    DWORD dwPID = 0;
    COMMAND_LINE_MAP CommandLineMap[3] = {
        { "/?"        , CMD_FLAGS_ONLY_OPTION, 0, NULL, 0, FALSE },
        { "/portsonly", CMD_FLAGS_ONLY_OPTION, 0, NULL, 0, FALSE },
        { "/pid"      , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_DEC, &dwPID, sizeof(dwPID), FALSE }
    };
    
    if(Utils_ParseCommandLine(CommandLineMap, 3))
    {
        if(CommandLineMap[0].bSwitchedOn)
        {
           HandleQuery_DisplayCommandLineArguments();
        }

        if(CommandLineMap[1].bSwitchedOn)
        {
           HandleQuery_DisplayHandleInformationForPortsOnly();
        }

        if(CommandLineMap[2].bSwitchedOn)
        {
           HandleQuery_DisplayHandleInformation(dwPID);
        }
    }
    else
    {
        HandleQuery_DisplayAllHandleInformation();
    }
}


/***********************************************
 *
 * HandleQuery_DisplayCommandLineArguments
 *
 * Display Command Line Arguements 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void HandleQuery_DisplayCommandLineArguments(void)
{
    printf(" Handle Query Utility\r\n");
    printf("   Toby Opferman (c) Copyright 2004, All Rights Reserved\r\n\r\n");
    printf("   Usage:\r\n");
    printf("         HANDLEQ [ /portsonly | /pid <pid> ]\r\n\r\n");
    printf("                HANDLEQ            - Display all handles for all processes.\r\n");
    printf("                HANDLEQ /portsonly - Display handles that are for possible sockets.\r\n");
    printf("                HANDLEQ /pid <pid> - Display handles for the following PID.\r\n");

}


/***********************************************
 *
 * HandleQuery_DisplayAllHandleInformation
 *
 * Display All Handle Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void HandleQuery_DisplayAllHandleInformation(void)
{
   if(!Handle_QueryAllProcessHandles(HandleQuery_DisplayHandleInformationCallBack, NULL))
   {
       printf("\r\nFailed to enumerate handle information\r\n");
   }
}



/***********************************************
 *
 * HandleQuery_DisplayHandleInformationForPortsOnly
 *
 * Display All Handle Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void HandleQuery_DisplayHandleInformationForPortsOnly(void)
{
   if(!Handle_QueryAllProcessHandles(HandleQuery_DisplayHandleInformationCallBackPortsOnly, NULL))
   {
       printf("\r\nFailed to enumerate handle information\r\n");
   }
}


/***********************************************
 *
 * HandleQuery_DisplayHandleInformation
 *
 * Display Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void HandleQuery_DisplayHandleInformation(DWORD dwPID)
{
   if(!Handle_QueryAllProcessHandlesByPID(dwPID, HandleQuery_DisplayHandleInformationCallBack, NULL))
   {
       printf("\r\nFailed to retrieve information for PID %i\r\n", dwPID);
   }
}

/***********************************************
 *
 * HandleQuery_DisplayModuleInformationCallBackNarrowDisplay
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
BOOL WINAPI HandleQuery_DisplayHandleInformationCallBack(PVOID pContext, PHANDLEINFO pHandleInfo)
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

    HandleQuery_DumpHandleInfoStructure(pHandleInfo);

    return TRUE;
}


/***********************************************
 *
 * HandleQuery_DisplayHandleInformationCallBackPortsOnly
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
BOOL WINAPI HandleQuery_DisplayHandleInformationCallBackPortsOnly(PVOID pContext, PHANDLEINFO pHandleInfo)
{
    static BOOL bFirstTime = TRUE;

    if(pHandleInfo->usPossiblePort)
    {
        if(bFirstTime)
        {
            bFirstTime = FALSE;
        }
        else
        {
            printf("\r\n<--------------------------->\r\n");
        }

        HandleQuery_DumpHandleInfoStructure(pHandleInfo);
    }

    return TRUE;
}



/***********************************************
 *
 * HandleQuery_DumpHandleInfoStructure
 *
 * Dump Module Information Structure 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void HandleQuery_DumpHandleInfoStructure(PHANDLEINFO pHandleInfo)
{

    printf("\r\nProcess     '%s'\r\n", pHandleInfo->szImageName);
    printf("PID:            %i\r\n", pHandleInfo->dwPID);
    printf("Handle:         0x%0x\r\n", pHandleInfo->wHandle);
    printf("Kernel Address: 0x%0x\r\n", pHandleInfo->dwKernelAddress);
    printf("Handle Flags:   0x%0x\r\n", pHandleInfo->bHandleFlags);
    printf("Attributes:     0x%0x\r\n", pHandleInfo->bAttributes);
    printf("Granted Access: 0x%0x\r\n", pHandleInfo->dwGrantedAccess);
    printf("Possible Port:  %i\r\n", pHandleInfo->usPossiblePort);
    printf("Handle Type:    '%ws'\r\n", NULL_PROTECT_STRINGW(pHandleInfo->usHandleTypeName.Buffer));
    printf("Handle Value:   '%ws'\r\n", NULL_PROTECT_STRINGW(pHandleInfo->usHandleValue.Buffer));
    
}

/***********************************************
 *
 * HandleQuery_Initialize
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void HandleQuery_Initialize(void)
{
    Init_ProcessLibrary();
    PrivLib_EnableProcessForDebug();
}

 