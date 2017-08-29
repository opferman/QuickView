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




;  ********* PLUGIN INFORMATION **********
;
;   A DLL Plugin may be written to communicate with
;   this framework.  The plugin will get the "Load" function
;   call when "Load Plugin" is selected from the menu and
;   it will get "UnLoad" when "unLoad plugin" is selected
;   from the menu.  The following are the Plugin Functions.
;
;  bool Plugin_Load(Function Table);
;    This is called to initialize your plugin.  Return "TRUE"
;    on success.
;
;  
;  void Plugin_UnLoad(void);
;    Called to uninitialize the plugin.
;
;  
;  void Plugin_Refresh(HWND);
;    This is called when the user wants to "Refresh" the information
;    on the page.  Please delete all your current information and
;    repaste the new information.  The HWND sent to your refresh
;    is your HWND.
;
;  void Plugin_Sort(HWND, COLOMN);
;    The HWND is your HWND. The colomn is the colomn # selected.
;
;  HWND Plugin_Create(HWND);
;
;    The HWND sent is the parent HWND.  You must create your child window.
;    We reccomend this type: ListView_CreateListViewWindow (look at this function)
;    and using columns as we are setup to call into plugins that use this type
;    of window, but others may work.  You should return your window HWND.
;
;  void Plugin_Hide(HWND);
;
;    When the user switches from your plugin in the mennu, you will get this notification.
;    you do not need to do anything, your window will be hidden after this call.  When the
;    user switches back to your plugin, your window will be displayed and "Plugin_Refresh"
;    will be called.
;
;  void Plugin_PopupMenu(HWND, CONTROL HWND, SelectedItem, SelectedSubItem);
;
;    This is called when a user selects and hits "right click".  Generally, you should
;    pop up a menu.  
;
;  void Plugin_PopupMenuCommands(...);
;
;    This is the entry point for any commands that you get from the popup menu.
;    All commands for the popup will come through this.
;
;  
;  
;
;
;
;





;*********************************************************
; Plugin_Load
;
;
;  Loads a plugin
;
;*********************************************************
Plugin_Load PROC
 

  RET
Plugin_Load ENDP


