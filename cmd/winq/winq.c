/*
 *  Windows Query
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
#include <winlib.h>

/***********************************************
 * Prototypes
 ***********************************************/
void WindowQuery_DisplayCommandLineArguments(void);
void WindowQuery_DisplayAllWindowsInformation(void);
void WindowQuery_DisplayWindowInformationByPid(DWORD dwPID);
BOOL WINAPI WindowQuery_DisplayWindowInformationCallBack(PVOID pContext, PWININFO pWinInfo);
void WindowQuery_Initialize(void);
void WindowQuery_DumpWindowInfoStructure(PWININFO pWinInfo);
void WindowQuery_PerformActions(void);
void WindowQuery_DisplayWindowInformationByWindow(DWORD dwHandle);
                                        


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
    WindowQuery_Initialize();
    WindowQuery_PerformActions();

    return 0;
}


/***********************************************
 *
 * WindowQuery_PerformActions
 *
 *  
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void WindowQuery_PerformActions(void)
{
    DWORD dwPID = 0, dwRetValue;
    HWND hSendMessage = NULL, hPostMessage = NULL, hCancel = NULL, hDestroy = NULL, hClose = NULL;
    DWORD dwWindowHandle = 0;
    LPARAM lParam = 0;
    WPARAM wParam = 0;
    UINT Msg = 0;
    COMMAND_LINE_MAP CommandLineMap[] = {
        { "/?"        , CMD_FLAGS_ONLY_OPTION, 0, NULL, 0, FALSE },
        { "/pid"      , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_DEC, &dwPID, sizeof(dwPID), FALSE },
        { "/window"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &dwWindowHandle, sizeof(dwWindowHandle), FALSE },
        { "/sendmessage"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &hSendMessage, sizeof(hSendMessage), FALSE },
        { "/postmessage"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &hPostMessage, sizeof(hPostMessage), FALSE },
        { "/sendcancel"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &hCancel, sizeof(hCancel), FALSE },
        { "/senddestroy"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &hDestroy, sizeof(hDestroy), FALSE },
        { "/sendclose"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &hClose, sizeof(hClose), FALSE },
        { "/msg"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &Msg, sizeof(Msg), FALSE },
        { "/wparam"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &wParam, sizeof(wParam), FALSE },
        { "/lparam"   , CMD_FLAGS_VARIABLE, CMD_VARIABLE_TYPE_DWORD_HEX, &lParam, sizeof(lParam), FALSE }

    };
  
    if(Utils_ParseCommandLine(CommandLineMap, sizeof(CommandLineMap)/sizeof(COMMAND_LINE_MAP)))
    {
        if(CommandLineMap[0].bSwitchedOn)
        {
           WindowQuery_DisplayCommandLineArguments();
        }

        if(CommandLineMap[1].bSwitchedOn)
        {
           WindowQuery_DisplayWindowInformationByPid(dwPID);
        }

        if(CommandLineMap[2].bSwitchedOn)
        {
           WindowQuery_DisplayWindowInformationByWindow(dwWindowHandle);
        }

        if(CommandLineMap[3].bSwitchedOn)
        {
            dwRetValue = SendMessage(hSendMessage, Msg, wParam, lParam);
            printf("SendMessage(0x%0x, 0x%0x, 0x%0x, 0x%0x) = 0x%0x\r\n", hSendMessage, Msg, wParam, lParam, dwRetValue); 
        }

        if(CommandLineMap[4].bSwitchedOn)
        {
            dwRetValue = PostMessage(hPostMessage, Msg, wParam, lParam);
            printf("PostMessage(0x%0x, 0x%0x, 0x%0x, 0x%0x) = 0x%0x\r\n", hPostMessage, Msg, wParam, lParam, dwRetValue); 
        } 

        if(CommandLineMap[5].bSwitchedOn)
        {
            dwRetValue = SendMessage(hCancel, WM_COMMAND, IDCANCEL, IDCANCEL);
            printf("SendMessage(0x%0x, WM_COMMAND, IDCANCEL, IDCANCEL) = 0x%0x\r\n", hCancel, dwRetValue); 
        }

        if(CommandLineMap[6].bSwitchedOn)
        {
            dwRetValue = DestroyWindow(hDestroy);
            printf("DestroyWindow(0x%0x) = 0x%0x\r\n", hDestroy, dwRetValue); 
        }

        if(CommandLineMap[7].bSwitchedOn)
        {
            dwRetValue = SendMessage(hClose, WM_CLOSE, 0, 0);
            printf("SendMessage(0x%0x, WM_CLOSE, 0, 0) = 0x%0x\r\n", hClose, dwRetValue); 
        }


    }
    else
    {
        WindowQuery_DisplayAllWindowsInformation();
    }
}


/***********************************************
 *
 * WindowQuery_DisplayCommandLineArguments
 *
 * Display Command Line Arguements 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void WindowQuery_DisplayCommandLineArguments(void)
{
    printf(" Window Query Utility\r\n");
    printf("   Toby Opferman (c) Copyright 2004, All Rights Reserved\r\n\r\n");
    printf("   Usage:\r\n");
    printf("         WINQ [ /pid <PID> | /window <HANDLE> | /sendmessage <HANDLE> /msg <id> /wparam <data> /lparam <data> | /postmessage <HANDLE> /msg <id> /wparam <data> /lparam <data> | /sendcancel <HANDLE> | /senddestroy <HANDLE> | /sendclose <HANDLE> ]\r\n\r\n");
    printf("                WINQ            - Display all window information\r\n");
    printf("                WINQ /pid <PID> - Display all windows with this PID.\r\n");
    printf("                WINQ /window <HANDLE> - Display information on this window handle (In Hex)\r\n");
    printf("                WINQ /sendmessage <HANDLE> /msg <id> /wparam <data> /lparam <data> - Send Message to this window handle (All In Hex)\r\n");
    printf("                WINQ /postmessage <HANDLE> /msg <id> /wparam <data> /lparam <data> - Post message to this window handle (All In Hex)\r\n");
    printf("                WINQ /sendcancel <HANDLE>  - Send a cancel message to this window handle (In Hex)\r\n");
    printf("                WINQ /senddestroy <HANDLE> - Send a destroy message to this window handle (In Hex)\r\n");
    printf("                WINQ /sendclose <HANDLE>   - Send a close message to this window handle (In Hex)\r\n");

}


/***********************************************
 *
 * WindowQuery_DisplayAllWindowsInformation
 *
 * Display All Handle Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void WindowQuery_DisplayAllWindowsInformation(void)
{
   if(!WinLib_EnumerateAllWindows(WindowQuery_DisplayWindowInformationCallBack, NULL))
   {
       printf("\r\nFailed to enumerate handle information\r\n");
   }
}

/***********************************************
 *
 * WindowQuery_DisplayWindowInformationByPid
 *
 * Display Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void WindowQuery_DisplayWindowInformationByPid(DWORD dwPID)
{
   if(!WinLib_EnumerateWindowsByPID(dwPID, WindowQuery_DisplayWindowInformationCallBack, NULL))
   {
      printf("\r\nFailed to enumerate handle information for PID %i\r\n", dwPID);
   }
}

/***********************************************
 *
 * WindowQuery_DisplayWindowInformationByWindow
 *
 * Display Process Information 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void WindowQuery_DisplayWindowInformationByWindow(DWORD dwHandle)
{
   WININFO WinInfo = {0};
   
   WinInfo.dwSize = sizeof(WinInfo);

   if(!WinLib_QueryWindowInformationByHandle((HWND)dwHandle, &WinInfo))
   {
       printf("\r\nFailed to retrieve information for HWND 0x%0x\r\n", dwHandle);
   }
   else
   {
       WindowQuery_DumpWindowInfoStructure(&WinInfo);
   }
}


/***********************************************
 *
 * WindowQuery_DisplayWindowInformationCallBack
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
BOOL WINAPI WindowQuery_DisplayWindowInformationCallBack(PVOID pContext, PWININFO pWinInfo)
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

    WindowQuery_DumpWindowInfoStructure(pWinInfo);

    return TRUE;
}


/***********************************************
 *
 * WindowQuery_DumpWindowInfoStructure
 *
 * Dump Module Information Structure 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void WindowQuery_DumpWindowInfoStructure(PWININFO pWinInfo)
{

    printf("\r\nProcess      '%s'\r\n", pWinInfo->szImageName);
    printf("Window Title     '%s'\r\n", pWinInfo->szWindowTitle);
    printf("Window ClassName '%s'\r\n", pWinInfo->szWindowClassName);
    printf("PID:             %i\r\n", pWinInfo->dwPID);
    printf("Thread ID:       %i\r\n", pWinInfo->dwThreadId);
    printf("Handle:          0x%0x\r\n", pWinInfo->dwWindowHandle);
    printf("Parent Window:   0x%0x\r\n", pWinInfo->dwWindowParent);
    printf("Styles:          0x%0x\r\n", pWinInfo->dwWindowStyles);
    printf("Extended Styles: 0x%0x\r\n", pWinInfo->dwExtendedStyles);
    
}


/***********************************************
 *
 * WindowQuery_Initialize
 *
 * Callback For Process Enumeration 
 * 
 * Parameters
 *   None
 *
 * Return Value
 *   None
 ***********************************************/
void WindowQuery_Initialize(void)
{
    Init_ProcessLibrary();
    PrivLib_EnableProcessForDebug();
}

