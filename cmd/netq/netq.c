/*
 *  Network Query
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
#include <netlib.h>


/***********************************************
 * Prototypes
 ***********************************************/
void NetworkQuery_DisplayCommandLineArguments(void);
void NetworkQuery_DisplayAllNetworkInformation(void);
BOOL WINAPI NetworkQuery_DisplayNetworkInformationCallBack(PVOID pContext, PNETWORK_INFORMATION pNetInfo);
void NetworkQuery_Initialize(void);
void NetworkQuery_DumpNetworkInfoStructure(PNETWORK_INFORMATION pNetInfo);
void NetworkQuery_PerformActions(void);


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
    NetworkQuery_Initialize();
    NetworkQuery_PerformActions();

    return 0;
}



/***********************************************
 *
 * NetworkQuery_PerformActions
 *
 *  
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void NetworkQuery_PerformActions(void)
{
    DWORD dwPID = 0;
    COMMAND_LINE_MAP CommandLineMap[2] = {
        { "/?"        , CMD_FLAGS_ONLY_OPTION, 0, NULL, 0, FALSE }
    };
    
    if(Utils_ParseCommandLine(CommandLineMap, 1))
    {
        if(CommandLineMap[0].bSwitchedOn)
        {
           NetworkQuery_DisplayCommandLineArguments();
        }
        else
        {
           NetworkQuery_DisplayCommandLineArguments();
        }
    }
    else
    {
        NetworkQuery_DisplayAllNetworkInformation();
    }
}


/***********************************************
 *
 * NetworkQuery_DisplayCommandLineArguments
 *
 * Display Command Line Arguements 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void NetworkQuery_DisplayCommandLineArguments(void)
{
    printf(" Network Query Utility\r\n");
    printf("   Toby Opferman (c) Copyright 2004, All Rights Reserved\r\n\r\n");
    printf("   Usage:\r\n");
    printf("         NETQ\r\n\r\n");
    printf("              NETQ            - Display connections in all processes.\r\n");

}


/***********************************************
 *
 * NetworkQuery_DisplayAllNetworkInformation
 *
 * Display All Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void NetworkQuery_DisplayAllNetworkInformation(void)
{
   if(!NetworkLibrary_EnumerateAllNetworkConnections(NetworkQuery_DisplayNetworkInformationCallBack, NULL))
   {
       printf(" An error occured!\r\n");
   }
}



/***********************************************
 *
 * NetworkQuery_DisplayNetworkInformationCallBack
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
BOOL WINAPI NetworkQuery_DisplayNetworkInformationCallBack(PVOID pContext, PNETWORK_INFORMATION pNetInfo)
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

    NetworkQuery_DumpNetworkInfoStructure(pNetInfo);

    return TRUE;
}


/***********************************************
 *
 * NetworkQuery_DumpNetworkInfoStructure
 *
 * Dump Network Information Structure 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void NetworkQuery_DumpNetworkInfoStructure(PNETWORK_INFORMATION pNetInfo)
{

    printf("\r\n");

    if(pNetInfo->bExtendedInformationIsValid)
    {
        printf("PID %i Process '%s'\r\n", pNetInfo->dwPid, pNetInfo->szImageName);
    }

    if(pNetInfo->bConnectionIsTCP)
    {
        printf("   TCP\r\n");
        printf("      Local Address    - %i.%i.%i.%i:%i\r\n", (pNetInfo->dwLocalAddr&0xFF), (pNetInfo->dwLocalAddr>>8) & 0xFF, (pNetInfo->dwLocalAddr>>16) & 0xFF, pNetInfo->dwLocalAddr>>24, (pNetInfo->dwLocalAddr&0xFF), (pNetInfo->dwLocalPort&0xFF) | (pNetInfo->dwLocalPort>>8));
        printf("      Remote Address   - %i.%i.%i.%i:%i\r\n", (pNetInfo->dwRemoteAddr&0xFF), (pNetInfo->dwRemoteAddr>>8) & 0xFF, (pNetInfo->dwRemoteAddr>>16) & 0xFF, pNetInfo->dwRemoteAddr>>24, (pNetInfo->dwRemotePort&0xFF) | (pNetInfo->dwRemotePort>>8));
        printf("      Connection State - 0x%0x\r\n", pNetInfo->dwState);
    }
    else
    {
        printf("   UDP\r\n");
        printf("      Local Address    - %i.%i.%i.%i:%i\r\n", (pNetInfo->dwLocalAddr&0xFF), (pNetInfo->dwLocalAddr>>8) & 0xFF, (pNetInfo->dwLocalAddr>>16) & 0xFF, pNetInfo->dwLocalAddr>>24, (pNetInfo->dwLocalPort&0xFF) | (pNetInfo->dwLocalPort>>8));
    }
    
}              
                           


/***********************************************
 *
 * NetworkQuery_DisplayProcessInformationCallBackWideDisplay
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void NetworkQuery_Initialize(void)
{
    Init_ProcessLibrary();
    PrivLib_EnableProcessForDebug();
    NetworkLibrary_Initialize();
}

 