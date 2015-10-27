unit workbench;


{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$IFDEF AMIGA}   {$PACKRECORDS 2} {$ENDIF}
{$IFDEF AROS}    {$PACKRECORDS C} {$ENDIF}
{$IFDEF MORPHOS} {$PACKRECORDS 2} {$ENDIF}

{$UNITPATH ../Trinity/}


interface


uses
  trinitypes, Exec, AGraphics, Intuition, Utility;


// ###### workbench/startup.h ###############################################


type
  PWBArg = ^TWBArg;
  TWBArg = record
    wa_Lock : BPTR;                 // A lock descriptor.
    wa_Name : PChar;                // A string relative to that lock.
  end;


// ###### <freepascal> ######################################################

  PWBArgList = ^TWBArgList;
  TWBArgList = array[1..100] of TWBArg; // Only 1..smNumArgs are valid

// ###### </freepascal> #####################################################

  PWBStartup = ^TWBStartup;
  TWBStartup = record
    sm_Message      : TMessage;     // A standard message structure.
    sm_Process      : PMsgPort;     // The process descriptor for you.
    sm_Segment      : BPTR;         // A descriptor for your code.
    sm_NumArgs      : SLONG;        // The number of elements in ArgList.
    sm_ToolWindow   : PChar;        // Description of window.
    sm_ArgList      : PWBArgList;   // The arguments themselves
  end;


// ###### workbench/workbench.h #############################################


const
  WORKBENCHNAME     : PChar = 'workbench.library';  // Workbench library name.

const
  WBDISK    = 1;
  WBDRAWER  = 2;
  WBTOOL    = 3;
  WBPROJECT = 4;
  WBGARBAGE = 5;
  WBDEVICE  = 6;
  WBKICK    = 7;
  WBAPPICON = 8;

type
  POldDrawerData = ^TOldDrawerData;
  TOldDrawerData = record
    dd_NewWindow    : TNewWindow;   // Args to open window.
    dd_CurrentX     : SLONG;        // Current x coordinate of origin.
    dd_CurrentY     : SLONG;        // Current y coordinate of origin.
  end;

const
  OLDDRAWERDATAFILESIZE = SizeOf(TOldDrawerData);  // Amount of DrawerData actually written to disk.

type
  PDrawerData = ^TDrawerData;
  TDrawerData = record
     dd_NewWindow   : TNewWindow;   // Args to open window.
     dd_CurrentX    : SLONG;        // Current x coordinate of origin.
     dd_CurrentY    : SLONG;        // Current y coordinate of origin.
     dd_Flags       : ULONG;        // Flags for drawer.
     dd_ViewModes   : UWORD;        // View mode for drawer.
  end;

const
  DRAWERDATAFILESIZE = SizeOf(TDrawerData);  // Amount of DrawerData actually written to disk.

  // Definitions for dd_ViewModes
  DDVM_BYDEFAULT = 0;               // Default (inherit parent's view mode).
  DDVM_BYICON    = 1;               // View as icons.
  DDVM_BYNAME    = 2;               // View as text, sorted by name.
  DDVM_BYDATE    = 3;               // View as text, sorted by date.
  DDVM_BYSIZE    = 4;               // View as text, sorted by size.
  DDVM_BYTYPE    = 5;               // View as text, sorted by type.

  // Definitions for dd_Flags
  DDFLAGS_SHOWDEFAULT = 0;  // Default (show only icons).
  DDFLAGS_SHOWICONS   = 1;  // Show only icons.
  DDFLAGS_SHOWALL     = 2;  // Show all files.

type
  PDiskObject = ^TDiskObject;
  TDiskObject = record
    do_Magic        : UWORD;        // A magic number at the start of the file.
    do_Version      : UWORD;        // A version number, so we can change it.
    do_Gadget       : TGadget;      // A copy of in core gadget.
    do_type         : UBYTE;
    do_DefaultTool  : STRPTR;
    do_Tooltypes    : PSTRPTR;
    do_CurrentX     : SLONG;
    do_CurrentY     : SLONG;
    do_DrawerData   : PDrawerData;
    do_ToolWindow   : STRPTR;       // Only applies to tools.
    do_StackSize    : SLONG;        // Only applies to tools.
  end;

const
  WB_DISKMAGIC          = $E310;    // A magic number, not easily impersonated.

  WB_DISKVERSION        = 1;        // Current version number.
  WB_DISKREVISION       = 1;        // Current revision number.
  WB_DISKREVISIONMASK   = $FF;      // Only use the lower 8 bits of Gadget.UserData for the revision #.


type
  PFreeList = ^TFreeList;
  TFreeList = record
    fl_NumFree  : SWORD;
    fl_MemList  : TList;
  end;

const
  //
  // workbench does different complement modes for its gadgets.
  // It supports separate images, complement mode, and backfill mode.
  // The first two are identical to intuitions GADGIMAGE and GADGHCOMP.
  // backfill is similar to GADGHCOMP, but the region outside of the
  // image (which normally would be color three when complemented)
  // is flood-filled to color zero.
  //
  GFLG_GADGBACKFILL = $0001;
  // GADGBACKFILL = $0001;          // an old synonym
  NO_ICON_POSITION  = ($80000000);  // If an icon does not really live anywhere, set its current position to here.

type
  PAppMessage = ^TAppMessage;
  TAppMessage = record
    am_Message  : TMessage;         // Standard message structure.
    am_type     : UWORD;            // Message type.
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    am_UserData : ULONG;            // Application specific.
    am_ID       : ULONG;            // Application definable ID.
    {$ENDIF}
    {$IFDEF AROS}
    am_UserData : IPTR;             // Application specific.    
    am_ID       : IPTR;             // Application definable ID.
    {$ENDIF}
    am_NumArgs  : SLONG;            // # of elements in arglist.
    am_ArgList  : PWBArgList;       // The arguements themselves.
    am_Version  : UWORD;            // Will be AM_VERSION.
    am_Class    : UWORD;            // Message class.
    am_MouseX   : SWORD;            // Mouse x position of event.
    am_MouseY   : SWORD;            // Mouse y position of event.
    am_Seconds  : ULONG;            // Current system clock time.
    am_Micros   : ULONG;            // Current system clock time.
    am_Reserved : array[0..7] of ULONG;  // Avoid recompilation.
  end;

const
  //
  // If you find am_Version >= AM_VERSION, you know this structure has
  // at least the fields defined in this version of the include file
  //
  AM_VERSION                =  1;   // Definition for am_Version.

  // Definitions for member am_type of structure TAppMessage.
  AMTYPE_APPWINDOW          =  7;   // App window message.
  AMTYPE_APPICON            =  8;   // App icon message.
  AMTYPE_APPMENUITEM        =  9;   // App menu item message.
  AMTYPE_APPWINDOWZONE      = 10;   // App window drop zone message.

  // Definitions for member am_Class of structure TAppMessage for AppIcon messages (V44)
  AMCLASSICON_Open          =  0;   // The "Open" menu item was invoked, the icon got double-clicked or an icon got dropped on it.
  AMCLASSICON_Copy          =  1;   // The "Copy" menu item was invoked.
  AMCLASSICON_Rename        =  2;   // The "Rename" menu item was invoked.
  AMCLASSICON_Information   =  3;   // The "Information" menu item was invoked.
  AMCLASSICON_Snapshot      =  4;   // The "Snapshot" menu item was invoked.
  AMCLASSICON_UnSnapshot    =  5;   // The "UnSnapshot" menu item was invoked.
  AMCLASSICON_LeaveOut      =  6;   // The "Leave Out" menu item was invoked.
  AMCLASSICON_PutAway       =  7;   // The "Put Away" menu item was invoked.
  AMCLASSICON_Delete        =  8;   // The "Delete" menu item was invoked.
  AMCLASSICON_FormatDisk    =  9;   // The "Format Disk" menu item was invoked.
  AMCLASSICON_EmptyTrash    = 10;   // The "Empty Trash" menu item was invoked.

  AMCLASSICON_Selected      = 11;   // The icon is now selected.
  AMCLASSICON_Unselected    = 12;   // The icon is now unselected.

Type
  {$IFDEF AMIGA}
  pAppWindow = ^tAppWindow;
  tAppWindow = record
    aw_PRIVATE      : Pointer;
  end;

  pAppWindowDropZone = ^tAppWindowDropZone;
  tAppWindowDropZone = record
    awdz_PRIVATE    : pointer;
  end;

  pAppIcon = ^tAppIcon;
  tAppIcon = record
    ai_PRIVATE      : Pointer;
  end;

  pAppMenuItem = ^tAppMenuItem;
  tAppMenuItem = record
    ami_PRIVATE     : Pointer;
  end;
  {$ENDIF}
  {$IFDEF AROS}
  PAppWindow = ^TAppWindow;
  TAppWindow = record
  end;

  PAppWindowDropZone = ^TAppWindowDropZone;
  TAppWindowDropZone = record
  end;

  PAppIcon = ^TAppIcon;
  TAppIcon = record
  end;

  PAppMenuItem = ^TAppMenuItem;
  TAppMenuItem = record
  end;
  {$ENDIF}
  {$IFDEF MORPHOS}
  pAppWindow = ^tAppWindow;
  tAppWindow = record
    aw_PRIVATE      : APTR;
  end;

  pAppWindowDropZone = ^tAppWindowDropZone;
  tAppWindowDropZone = record
    awdz_PRIVATE    : APTR;
  end;

  pAppIcon = ^tAppIcon;
  tAppIcon = record
    ai_PRIVATE      : APTR;
  end;

  pAppMenuItem = ^tAppMenuItem;
  tAppMenuItem = record
    ami_PRIVATE     : APTR;
  end;

  PAppMenu = ^tAppMenu;
  tAppMenu = record
    am_PRIVATE      : APTR;
  end;
  {$ENDIF}


const
  {$IFDEF AROS}
  WBA_BASE  = (TAG_USER + $A000);
  {$ENDIF}
  WBA_DUMMY = (TAG_USER + $A000);

  // Tags for use with AddAppIconA()
  // The different menu items the AppIcon responds to (BOOL).
  WBAPPICONA_SupportsOpen        = (WBA_DUMMY +  1); // AppIcon responds to the "Open" menu item (LongBool).
  WBAPPICONA_SupportsCopy        = (WBA_DUMMY +  2); // AppIcon responds to the "Copy" menu item (LongBool).
  WBAPPICONA_SupportsRename      = (WBA_DUMMY +  3); // AppIcon responds to the "Rename" menu item (LongBool).
  WBAPPICONA_SupportsInformation = (WBA_DUMMY +  4); // AppIcon responds to the "Information" menu item (LongBool).
  WBAPPICONA_SupportsSnapshot    = (WBA_DUMMY +  5); // AppIcon responds to the "Snapshot" menu item (LongBool).
  WBAPPICONA_SupportsUnSnapshot  = (WBA_DUMMY +  6); // AppIcon responds to the "UnSnapshot" menu item (LongBool).
  WBAPPICONA_SupportsLeaveOut    = (WBA_DUMMY +  7); // AppIcon responds to the "LeaveOut" menu item (LongBool).
  WBAPPICONA_SupportsPutAway     = (WBA_DUMMY +  8); // AppIcon responds to the "PutAway" menu item (LongBool).
  WBAPPICONA_SupportsDelete      = (WBA_DUMMY +  9); // AppIcon responds to the "Delete" menu item (LongBool).
  WBAPPICONA_SupportsFormatDisk  = (WBA_DUMMY + 10); // AppIcon responds to the "FormatDisk" menu item (LongBool).
  WBAPPICONA_SupportsEmptyTrash  = (WBA_DUMMY + 11); // AppIcon responds to the "EmptyTrash" menu item (LongBool).
  WBAPPICONA_PropagatePosition   = (WBA_DUMMY + 12); // AppIcon position should be propagated back to original DiskObject (LongBool).
  WBAPPICONA_RenderHook          = (WBA_DUMMY + 13); // Callback hook to be invoked when rendering this icon (pHook).
  WBAPPICONA_NotifySelectState   = (WBA_DUMMY + 14); // AppIcon wants to be notified when its select state changes (LongBool).
  // Tags for use with AddAppMenuA()
  WBAPPMENUA_CommandKeyString    = (WBA_DUMMY + 15); // Command key string for this AppMenu (STRPTR).
  // Tags for use with OpenWorkbenchObjectA()
  WBOPENA_ArgLock                = (WBA_DUMMY + 16); // Corresponds to the wa_Lock member of a struct WBArg.
  WBOPENA_ArgName                = (WBA_DUMMY + 17); // Corresponds to the wa_Name member of a struct WBArg.
  // Tags for use with WorkbenchControlA()
  WBCTRLA_IsOpen                 = (WBA_DUMMY + 18); // Check if the named drawer is currently open (PLongInt).
  WBCTRLA_DuplicateSearchPath    = (WBA_DUMMY + 19); // Create a duplicate of the Workbench private search path list (PBPTR).
  WBCTRLA_FreeSearchPath         = (WBA_DUMMY + 20); // Free the duplicated search path list (BPTR).
  WBCTRLA_GetDefaultStackSize    = (WBA_DUMMY + 21); // Get the default stack size for launching programs with (PLongWord).
  WBCTRLA_SetDefaultStackSize    = (WBA_DUMMY + 22); // Set the default stack size for launching programs with (LongWord).
  WBCTRLA_RedrawAppIcon          = (WBA_DUMMY + 23); // Cause an AppIcon to be redrawn (pAppIcon).
  WBCTRLA_GetProgramList         = (WBA_DUMMY + 24); // Get a list of currently running Workbench programs (pList).
  WBCTRLA_FreeProgramList        = (WBA_DUMMY + 25); // Release the list of currently running Workbench programs (pList).
  // Tags for use with AddAppWindowDropZoneA()
  WBDZA_Left                     = (WBA_DUMMY + 26); // Zone left edge (SmallInt)
  WBDZA_RelRight                 = (WBA_DUMMY + 27); // Zone left edge, if relative to the right edge of the window (SmallInt)
  WBDZA_Top                      = (WBA_DUMMY + 28); // Zone top edge (SmallInt)
  WBDZA_RelBottom                = (WBA_DUMMY + 29); // Zone top edge, if relative to the bottom edge of the window (SmallInt)
  WBDZA_Width                    = (WBA_DUMMY + 30); // Zone width (SmallInt)
  WBDZA_RelWidth                 = (WBA_DUMMY + 31); // Zone width, if relative to the window width (SmallInt)
  WBDZA_Height                   = (WBA_DUMMY + 32); // Zone height (SmallInt)
  WBDZA_RelHeight                = (WBA_DUMMY + 33); // Zone height, if relative to the window height (SmallInt)
  WBDZA_Box                      = (WBA_DUMMY + 34); // Zone position and size (pIBox).
  WBDZA_Hook                     = (WBA_DUMMY + 35); // Hook to invoke when the mouse enters or leave a drop zone (pHook).

  WBCTRLA_GetSelectedIconList    = (WBA_DUMMY + 36); // Get a list of currently selected icons (pList).
  WBCTRLA_FreeSelectedIconList   = (WBA_DUMMY + 37); // Release the list of currently selected icons (pList).
  WBCTRLA_GetOpenDrawerList      = (WBA_DUMMY + 38); // Get a list of currently open drawers (pList).
  WBCTRLA_FreeOpenDrawerList     = (WBA_DUMMY + 39); // Release the list of currently open icons (pList).

  WBA_Reserved1                  = (WBA_DUMMY + 40);
  WBA_Reserved2                  = (WBA_DUMMY + 41);

  WBCTRLA_GetHiddenDeviceList    = (WBA_DUMMY + 42); // Get the list of hidden devices (pList).
  WBCTRLA_FreeHiddenDeviceList   = (WBA_DUMMY + 43); // Release the list of hidden devices (pList).
  WBCTRLA_AddHiddenDeviceName    = (WBA_DUMMY + 44); // Add the name of a device which Workbench should never try to read a disk icon from (STRPTR).
  WBCTRLA_RemoveHiddenDeviceName = (WBA_DUMMY + 45); // Remove a name from list of hidden devices (STRPTR).

  WBA_Reserved3                  = (WBA_DUMMY + 46);

  WBCTRLA_GettypeRestartTime     = (WBA_DUMMY + 47); // Get the number of seconds that have to pass before typing the next character in a drawer window will restart with a new file name (PLongWord).
  WBCTRLA_SettypeRestartTime     = (WBA_DUMMY + 48); // Set the number of seconds that have to pass before typing the next character in a drawer window will restart with a new file name (LongWord).

  WBA_Reserved4                  = (WBA_DUMMY + 49);

  WBA_Reserved5                  = (WBA_DUMMY + 50);
  WBA_Reserved6                  = (WBA_DUMMY + 51);
  WBA_Reserved7                  = (WBA_DUMMY + 52);
  WBA_Reserved8                  = (WBA_DUMMY + 53);
  WBA_Reserved9                  = (WBA_DUMMY + 54);
  WBA_Reserved10                 = (WBA_DUMMY + 55);
  WBA_Reserved11                 = (WBA_DUMMY + 56);
  WBA_Reserved12                 = (WBA_DUMMY + 57);
  WBA_Reserved13                 = (WBA_DUMMY + 58);
  WBA_Reserved14                 = (WBA_DUMMY + 59);
  WBA_Reserved15                 = (WBA_DUMMY + 60);
  WBA_Reserved16                 = (WBA_DUMMY + 61);
  WBA_Reserved17                 = (WBA_DUMMY + 62);
  WBA_Reserved18                 = (WBA_DUMMY + 63);
  WBA_Reserved19                 = (WBA_DUMMY + 64);

  {$IF DEFINED(AROS) or DEFINED(MORPHOS)}
  WBAPPMENUA_GetKey              = (WBA_DUMMY + 65); // Item to be added should get sub menu items attached to; make room for it, then return the key to use later for attaching the items (A_PUL
  WBAPPMENUA_UseKey              = (WBA_DUMMY + 66); // This item should be attached to a sub menu; the key provided refers to the sub menu it should be attached to (LongWord).

  WBA_Reserved20                 = (WBA_DUMMY + 67);
  WBA_Reserved21                 = (WBA_DUMMY + 68);

  // V45 

  WBCTRLA_GetCopyHook            = (WBA_DUMMY + 69); // Obtain the hook that will be invoked when Workbench starts to copy files and data (pHook); (V45)
  WBCTRLA_SetCopyHook            = (WBA_DUMMY + 70); // Install the hook that will be invoked when Workbench starts to copy files and data (pHook); (V45)
  WBCTRLA_GetDeleteHook          = (WBA_DUMMY + 71); // Obtain the hook that will be invoked when Workbench discards files and drawers or empties the trashcan (pHook);  (V45).
  WBCTRLA_SetDeleteHook          = (WBA_DUMMY + 72); // Install the hook that will be invoked when Workbench discards  files and drawers or empties the trashcan (pHook); (V45).
  WBCTRLA_GetTextInputHook       = (WBA_DUMMY + 73); // Obtain the hook that will be invoked when Workbench requests that the user enters text, such as when a file is to be renamed  or a new drawer is to be created (pHook); (V45)
  WBCTRLA_SetTextInputHook       = (WBA_DUMMY + 74); // Install the hook that will be invoked when Workbench requests that the user enters text, such as when a file is to be renamed or a new drawer is to be created (pHook); (V45)

  WBOPENA_Show                   = (WBA_DUMMY + 75); // When opening a drawer, show all files or only icons? This must be one out of DDFLAGS_SHOWICONS, or DDFLAGS_SHOWALL; (Byte); (V45)
  WBOPENA_ViewBy                 = (WBA_DUMMY + 76); // When opening a drawer, view the contents by icon, name, date, size or type? This must be one out of DDVM_BYICON, DDVM_BYNAME, DDVM_BYDATE, DDVM_BYSIZE or DDVM_BYTYPE; (UBYTE); (V45)

  WBAPPMENUA_GetTitleKey         = (WBA_DUMMY + 77); // Item to be added is in fact a new menu title; make room for it, then return the key to use later for attaching the items (??? ULONG ???).

  WBCTRLA_AddSetupCleanupHook    = (WBA_DUMMY + 78); // Add a hook that will be invoked when Workbench is about to shut down (cleanup), and when Workbench has returned to operational state (setup) (pHook); (V45)
  WBCTRLA_RemSetupCleanupHook    = (WBA_DUMMY + 79); // Remove a hook that has been installed with the WBCTRLA_AddSetupCleanupHook tag (pHook); (V45)
  {$ENDIF}

  // V50
  {$IFDEF MORPHOS}
  WBAPPICONA_Clone               = (WBA_Dummy + 80);    //* V50 Clone appicon (default: FALSE) */  
  {$ENDIF}
  
  
  // Last Tag
  {$IFDEF AMIGA}
  WBA_LAST_TAG                   = (WBA_DUMMY + 63);    // ???
  {$ENDIF}
  {$IFDEF AROS}
  WBA_LAST_TAG                   = (WBA_DUMMY + 64);    // ???
  {$ENDIF}
  {$IFDEF MORPHOS}
  WBA_LAST_TAG                   = WBAPPICONA_Clone;    // sensible
  {$ENDIF}


type
  // The message your setup/cleanup hook gets invoked with.
  PSetupCleanupHookMsg = ^TSetupCleanupHookMsg;
  TSetupCleanupHookMsg = record
    schm_Length : ULONG;
    schm_State  : SLONG;
  end;

const
  SCHMSTATE_TryCleanup = 0;     // Workbench will attempt to shut down now.
  SCHMSTATE_Cleanup    = 1;     // Workbench will really shut down now.
  SCHMSTATE_Setup      = 2;     // Workbench is operational again or could not be shut down.

type
  // The message your AppIcon rendering hook gets invoked with.
  PAppIconRenderMsg = ^TAppIconRenderMsg;
  TAppIconRenderMsg = record
    arm_RastPort: PRastPort;    // RastPort to render into.
    arm_Icon    : PDiskObject;  // The icon to be rendered.
    arm_Label   : STRPTR;       // The icon label txt.
    arm_Tags    : PTagItem;     // Further tags to be passed on to DrawIconStateA().

    arm_Left    : SWORD;        // \ Rendering origin, not taking the
    arm_Top     : SWORD;        // / button border into account.

    arm_Width   : SWORD;        // \ Limit your rendering to
    arm_Height  : SWORD;        // / this area.

    arm_State   : ULONG;        // IDS_SELECTED, IDS_NORMAL, etc.
  end;


  // The message your drop zone hook gets invoked with. }
  PAppWindowDropZoneMsg = ^TAppWindowDropZoneMsg;
  TAppWindowDropZoneMsg = record
    adzm_RastPort   : PRastPort;    // RastPort to render into.
    adzm_DropZoneBox: TIBox;        // Limit your rendering to this area.
    adzm_ID         : ULONG;        // \ These come from straight
    {$IFDEF AROS}
    adzm_UserData   : IPTR;         // / from AddAppWindowDropZoneA().
    {$ELSE}
    adzm_UserData   : ULONG;        // / from AddAppWindowDropZoneA().   
    {$ENDIF}
    adzm_Action     : SLONG;        // See below for a list of actions.
  end;


const
  // definitions for adzm_Action
  ADZMACTION_Enter = (0);
  ADZMACTION_Leave = (1);


type
  // The message your icon selection change hook is invoked with. }
  PIconSelectMsg = ^TIconSelectMsg;
  TIconSelectMsg = record
    ism_Length      : ULONG;        // Size of this data structure (in bytes).
    ism_Drawer      : BPTR;         // Lock on the drawer this object resides in, NULL for Workbench backdrop (devices).
    ism_Name        : STRPTR;       // Name of the object in question.
    ism_type        : UWORD;        // One of WBDISK, WBDRAWER, WBTOOL, WBPROJECT, WBGARBAGE, WBDEVICE, WBKICK or WBAPPICON.
    ism_Selected    : BOOL;         // TRUE if currently selected, FALSE otherwise.
    ism_Tags        : PTagItem;     // Pointer to the list of tag items passed to ChangeWorkbenchSelectionA().
    ism_DrawerWindow: PWindow;      // Pointer to the window attached to this icon, if the icon is a drawer-like object.
    ism_ParentWindow: PWindow;      // Pointer to the window the icon resides in.

    ism_Left        : SWORD;        // Position and size of the icon; note that the icon may not entirely reside within the visible bounds of the parent window.
    ism_Top         : SWORD;
    ism_Width       : SWORD;
    ism_Height      : SWORD;
  end;


const
  // These are the values your hook code can return.
  ISMACTION_Unselect = (0);         // Unselect the icon.
  ISMACTION_Select   = (1);         // Select the icon.
  ISMACTION_Ignore   = (2);         // Do not change the selection state.
  ISMACTION_Stop     = (3);         // Do not invoke the hook code again, leave the icon as it is.


type
  // The messages your copy hook is invoked with.
  PCopyBeginMsg = ^TCopyBeginMsg;
  TCopyBeginMsg = record
    cbm_Length           : ULONG;   // Size of this data structure in bytes.
    cbm_Action           : SLONG;   // Will be set to CPACTION_Begin (see below).
    cbm_SourceDrawer     : BPTR;    // A lock on the source drawer.
    cbm_DestinationDrawer: BPTR;    // A lock on the destination drawer.
  end;

  PCopyDataMsg = ^TCopyDataMsg;
  TCopyDataMsg = record
    cdm_Length          : ULONG;    // Size of this data structure in bytes.
    cdm_Action          : SLONG;    // Will be set to CPACTION_Copy (see below).

    cdm_SourceLock      : BPTR;     // A lock on the parent directory of the source file/drawer.
    cdm_SourceName      : STRPTR;   // The name of the source file or drawer.

    cdm_DestinationLock : BPTR;     // A lock on the parent directory of the destination file/drawer.
    cdm_DestinationName : STRPTR;   // The name of the destination file/drawer.
                                    // This may or may not match the name of the source file/drawer in case the
                                    // data is to be copied under a different name. For example, this is the case
                                    // with the Workbench "Copy" command which creates duplicates of file/drawers by
                                    // prefixing the duplicate's name with "Copy_XXX_of".
    cdm_DestinationX    : SLONG;    // When the icon corresponding to the destination is written to disk, this
    cdm_DestinationY    : SLONG;    // is the position (put into its DiskObject->do_CurrentX/DiskObject->do_CurrentY.
  end;                              // fields) it should be placed at.

  PCopyEndMsg = ^TCopyEndMsg;
  TCopyEndMsg = record
    cem_Length  : ULONG;            // Size of this data structure in bytes.
    cem_Action  : SLONG;            // Will be set to CPACTION_End (see below).
  end;


const
  CPACTION_Begin = (0);
  CPACTION_Copy  = (1);             // This message arrives for each file or drawer to be copied.
  CPACTION_End   = (2);             // This message arrives when all files/drawers have been copied.


type
  // The messages your delete hook is invoked with.
  PDeleteBeginMsg = ^TDeleteBeginMsg;
  TDeleteBeginMsg = record
    dbm_Length  : ULONG;    // Size of this data structure in bytes.
    dbm_Action  : SLONG;    // Will be set to either DLACTION_BeginDiscard or DLACTION_BeginEmptyTrash (see below).
  end;

  PDeleteDataMsg = ^TDeleteDataMsg;
  TDeleteDataMsg = record
    ddm_Length  : ULONG;    // Size of this data structure in bytes.
    ddm_Action  : SLONG;    // Will be set to either DLACTION_DeleteContents or DLACTION_DeleteObject (see below).
    ddm_Lock    : BPTR;     // A Lock on the parent directory of the object whose contents or which itself should be deleted.
    ddm_Name    : STRPTR;   // The name of the object whose contents or which itself should be deleted.
  end;

  PDeleteEndMsg = ^TDeleteEndMsg;
  TDeleteEndMsg = record
    dem_Length  : ULONG;    // Size of this data structure in bytes.
    dem_Action  : SLONG;    // Will be set to DLACTION_End (see below).
  end;


const
  DLACTION_BeginDiscard    = (0);
  DLACTION_BeginEmptyTrash = (1);   // This indicates that the following delete operations are intended to empty the trashcan.
  DLACTION_DeleteContents  = (3);   // This indicates that the object described by lock and name refers to a drawer; you should empty its contents but  DO NOT  delete the drawer itself!
  DLACTION_DeleteObject    = (4);   // This indicates that the object described by lock and name should be deleted; this could be a file or an empty drawer.
  DLACTION_End             = (5);   // This indicates that the deletion process is finished.


type
  // The messages your text input hook is invoked with.
  PTextInputMsg = ^TTextInputMsg;
  TTextInputMsg = record
    tim_Length  : ULONG;    // Size of this data structure in bytes.
    tim_Action  : SLONG;    // One of the TIACTION_... values listed below.
    tim_Prompt  : STRPTR;   // The Workbench suggested result, depending on what kind of input is requested (as indicated by the tim_Action member).
  end;

const
  TIACTION_Rename        = (0); // A file or drawer is to be renamed.
  TIACTION_RelabelVolume = (1); // A volume is to be relabeled.
  TIACTION_NewDrawer     = (2); // A new drawer is to be created.
  TIACTION_Execute       = (3); // A program or script is to be executed.


  // Parameters for the UpdateWorkbench() function.
  UPDATEWB_ObjectRemoved = (0); // Object has been deleted.
  UPDATEWB_ObjectAdded   = (1); // Object is new or has changed.


// ###### workbench/handler.h ###############################################


{$IFDEF AROS}
type
  TWBHM_type =
  (
    WBHM_TYPE_SHOW,     // Open all windows.
    WBHM_TYPE_HIDE,     // Close all windows.
    WBHM_TYPE_OPEN,     // Open a drawer.
    WBHM_TYPE_UPDATE    // Update an object.
  );

  PWBHandlerMessage = ^TWBHandlerMessage;
  TWBHandlerMessage = record
    wbhm_Message    : TMessage;     // Standard message structure.
    wbhm_type       : TWBHM_type;   // type of message.
    case integer of
    0 :
    (
      Open: record
        OpenName    : STRPTR;       // Name of the drawer.
      end;
    );
    1 :
    (
      Update: record
        UpdateName  : STRPTR;       // Mame of the object.
        Updatetype  : SLONG;        // type of object (WBDRAWER, WBPROJECT, ...).
      end;
    );
  end;
  
const
  WBHM_SIZE     = sizeof(TWBHandlerMessage);

  // TODO: macro/cast: WBHM(msg) ((struct WBHandlerMessage *) (msg))
{$ENDIF}


var
  WorkbenchBase: pLibrary;

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  { v36 }  
    {$IFDEF AMIGA}
  function  AddAppWindowA(id: ULONG location 'd0'; userdata: ULONG location 'd1'; window: PWindow location 'a0'; msgport: PMsgPort location 'a1'; taglist: PTagItem location 'a2'): PAppWindow;                                                         syscall WorkbenchBase 042;
    {$ELSE MORPHOS}
  function  AddAppWindowA(id: ULONG location 'd0'; userdata: ULONG location 'd1'; window: PWindow location 'a0'; msgport: PMsgPort location 'a1'; taglist: PTagItem location 'a2'): PAppWindow;                                                         syscall WorkbenchBase 048; 
    {$ENDIF}
  function  RemoveAppWindow(appWindow: PAppWindow location 'a0'): LBOOL;                                                                                                                                                                                syscall WorkbenchBase 054;
  function  AddAppIconA(id: ULONG location 'd0'; userdata: ULONG location 'd1'; txt: PChar location 'a0'; msgport: PMsgPort location 'a1'; lock: BPTR location 'a2'; diskobj: PDiskObject location 'a3'; taglist: PTagItem location 'a4'): PAppIcon;    syscall WorkbenchBase 060;
  function  RemoveAppIcon(appIcon: PAppIcon location 'a0'): LBOOL;                                                                                                                                                                                      syscall WorkbenchBase 066;
  function  AddAppMenuItemA(id: ULONG location 'd0'; userdata: ULONG location 'd1'; txt: PChar location 'a0'; msgport: PMsgPort location 'a1'; taglist: PTagItem location 'a2'): PAppMenuItem;                                                          syscall WorkbenchBase 072;
  function  RemoveAppMenuItem(appMenuItem: PAppMenuItem location 'a0'): LBOOL;                                                                                                                                                                          syscall WorkbenchBase 078;
  { v39 }
  procedure WBInfo(lock: BPTR location 'a0'; name: STRPTR location 'a1'; screen: PScreen location 'a2');                                                                                                                                                syscall WorkbenchBase 090;
  { v44 }
  function  OpenWorkbenchObjectA(name: STRPTR location 'a0'; tags: PTagItem location 'a1'): LBOOL;                                                                                                                                                      syscall WorkbenchBase 096;
  function  CloseWorkbenchObjectA(name: STRPTR location 'a0'; tags: PTagItem location 'a1'): LBOOL;                                                                                                                                                     syscall WorkbenchBase 102;
  function  WorkbenchControlA(name: STRPTR location 'a0'; tags: PTagItem location 'a1'): LBOOL;                                                                                                                                                         syscall WorkbenchBase 108;
  function  AddAppWindowDropZoneA(aw: PAppWindow location 'a0'; id: ULONG location 'd0'; userdata: ULONG location 'd1'; tags: PTagItem location 'a1'): PAppWindowDropZone;                                                                              syscall WorkbenchBase 114;
  function  RemoveAppWindowDropZone(aw: PAppWindow location 'a0'; dropZone: PAppWindowDropZone location 'a1'): LBOOL;                                                                                                                                   syscall WorkbenchBase 120;
  function  ChangeWorkbenchSelectionA(name: STRPTR location 'a0'; hook: PHook location 'a1'; tags: PTagItem location 'a2'): LBOOL;                                                                                                                      syscall WorkbenchBase 126;
  function  MakeWorkbenchObjectVisibleA(name: STRPTR location 'a0'; tags: PTagItem location 'a1'): LBOOL;                                                                                                                                               syscall WorkbenchBase 132;
  {$ENDIF}

  {$IFDEF AROS}
  { v36 }
  function UpdateWorkbench(const name: STRPTR; lock: BPTR; action: SLONG): LBOOL;                                       syscall WorkbenchBase 5;
  function QuoteWorkbench(stringNum: ULONG): LBOOL;                                                                     syscall WorkbenchBase 6; unimplemented;
  function StartWorkbench(flag: ULONG; ptr: APTR): LBOOL;                                                               syscall WorkbenchBase 7;
  function AddAppWindowA(id: IPTR; userdata: IPTR; window: PWindow; msgport: PMsgPort; taglist: PTagItem): PAppWindow;  syscall WorkbenchBase 8;
  function RemoveAppWindow(appWindow: PAppWindow): LBOOL;                                                               syscall WorkbenchBase 9;
  function AddAppIconA(id: IPTR; userdata: IPTR; const txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; taglist: PTagItem): PAppIcon; syscall WorkbenchBase 10;
  function RemoveAppIcon(appIcon: PAppIcon): LBOOL;                                                                     syscall WorkbenchBase 11;
  //function AddAppMenuItemA(id: IPTR; userdata: IPTR; txt: APTR; msgport: PMsgPort; taglist: PTagItem): PAppMenuItem;    syscall WorkbenchBase 12;
  function AddAppMenuItemA(id: IPTR; userdata: IPTR; txt: PChar; msgport: PMsgPort; taglist: PTagItem): PAppMenuItem;   syscall WorkbenchBase 12;
  function RemoveAppMenuItem(appMenuItem: PAppMenuItem): LBOOL;                                                         syscall WorkbenchBase 13;
  { v39 }
  function WBConfig(unk1: ULONG; unk2: ULONG): LBOOL;                                                                   syscall WorkbenchBase 14; unimplemented;
  function WBInfo(lock: BPTR; const name: STRPTR; screen: PScreen): LBOOL;                                              syscall WorkbenchBase 15;
  { v44 }
  function OpenWorkbenchObjectA(name: STRPTR; tags: PTagItem): LBOOL;                                                   syscall WorkbenchBase 16;
  function CloseWorkbenchObjectA(name: STRPTR; tags: PTagItem): LBOOL;                                                  syscall WorkbenchBase 17; unimplemented;
  function WorkbenchControlA(name: STRPTR; tags: PTagItem): LBOOL;                                                      syscall WorkbenchBase 18;
  function AddAppWindowDropZoneA(aw: PAppWindow; id: IPTR; userdata: IPTR; tags: PTagItem): PAppWindowDropZone;         syscall WorkbenchBase 19;
  function RemoveAppWindowDropZone(aw: PAppWindow; dropZone: PAppWindowDropZone): LBOOL;                                syscall WorkbenchBase 20;
  function ChangeWorkbenchSelectionA(name: STRPTR; hook: PHook; tags: PTagItem): LBOOL;                                 syscall WorkbenchBase 21; unimplemented;
  function MakeWorkbenchObjectVisibleA(name: STRPTR; tags: PTagItem): LBOOL;                                            syscall WorkbenchBase 22; unimplemented;
  { v45, AROS only ? }
  function RegisterWorkbench(messageport: PMsgPort): LBOOL;                                                             syscall WorkbenchBase 23;
  function UnregisterWorkbench(messageport: PMsgPort): LBOOL;                                                           syscall WorkbenchBase 24;
  function UpdateWorkbenchObjectA(name: STRPTR; typ: SLONG; tags: PTagItem): LBOOL;                                     syscall WorkbenchBase 25;
  function SendAppWindowMessage(win: PWindow; numfiles: ULONG; files: PPChar; windowclass: UWORD; mousex: SWORD; mousey: SWORD; seconds: ULONG; micros: ULONG): LBOOL; syscall WorkbenchBase 26;
  function GetNextAppIcon(lastdiskobj: PDiskObject; txt: PChar): PDiskObject;                                           syscall WorkbenchBase 27;
  {$ENDIF}

  //
  // varargs versions
  //

  {$IFDEF AMIGA}
  { v36 }
  function  AddAppWindow(id: ULONG; userdata: ULONG; window: PWindow; msgport: PMsgPort; const tags: array of const): PAppWindow;
  function  AddAppIcon(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; const tags: array of const): PAppIcon;
  function  AddAppMenuItem(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; const tags: array of const): PAppMenuItem;
  { v44 }
  function  OpenWorkbenchObject(name: STRPTR; const tags: array of const): LBOOL;
  function  CloseWorkbenchObject(name: STRPTR; const tags: array of const): LBOOL;
  function  WorkbenchControl(name: STRPTR; const tags: array of const): LBOOL;
  function  AddAppWindowDropZone(aw: PAppWindow; id: ULONG; userdata: ULONG; const tags: array of const): PAppWindowDropZone;
  function  ChangeWorkbenchSelection(name: STRPTR; hook: PHook; const tags: array of const): LBOOL;
  function  MakeWorkbenchObjectVisible(name: STRPTR; const tags: array of const): LBOOL;
  {$ENDIF}

  {$IFDEF AROS}
  { v36 }
  function AddAppWindow(id: IPTR; userdata: IPTR; window: PWindow; msgport: PMsgPort; const tags: array of const): PAppWindow;
  function AddAppIcon(id: IPTR; userdata: IPTR; const txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; const tags: array of const): PAppIcon;
  function AddAppMenuItem(id: IPTR; userdata: IPTR; txt: PChar; msgport: PMsgPort; const tags: array of const): PAppMenuItem;
  { v44 }
  function OpenWorkbenchObject(name: STRPTR; const tags: array of const): LBOOL;
  function CloseWorkbenchObject(name: STRPTR; const tags: array of const): LBOOL; unimplemented;
  function WorkbenchControl(name: STRPTR; const tags: array of const): LBOOL;
  function AddAppWindowDropZone(aw: PAppWindow; id: IPTR; userdata: IPTR; const tags: array of const): PAppWindowDropZone;
  function ChangeWorkbenchSelection(name: STRPTR; hook: PHook; const tags: array of const): LBOOL; unimplemented;
  function MakeWorkbenchObjectVisible(name: STRPTR; const tags: array of const): LBOOL; unimplemented;
  { v45 }
  function UpdateWorkbenchObject(name: STRPTR; typ: SLONG; const tags: array of const): LBOOL;
  {$ENDIF}

  {$IFDEF MORPHOS}
  { v36 }
  function  AddAppWindow(id: ULONG; userdata: ULONG; window: PWindow; msgport: PMsgPort; const tags: array of ULONG): PAppWindow;
  function  AddAppIcon(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; const tags: array of ULONG): PAppIcon;
  function  AddAppMenuItem(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; const tags: array of ULONG): PAppMenuItem;
  { v44 }
  function  OpenWorkbenchObject(name: STRPTR; const tags: array of ULONG): LBOOL;
  function  CloseWorkbenchObject(name: STRPTR; const tags: array of ULONG): LBOOL;
  function  WorkbenchControl(name: STRPTR; const tags: array of ULONG): LBOOL;
  function  AddAppWindowDropZone(aw: PAppWindow; id: ULONG; userdata: ULONG; const tags: array of ULONG): PAppWindowDropZone;
  function  ChangeWorkbenchSelection(name: STRPTR; hook: PHook; const tags: array of ULONG): LBOOL;
  function  MakeWorkbenchObjectVisible(name: STRPTR; const tags: array of ULONG): LBOOL;
  {$ENDIF}



implementation

{$IFDEF AMIGA}
uses
  TagsArray;
{$ENDIF}
{$IFDEF AROS}
uses
  TagsArray;
{$ENDIF}



{$IFDEF AMIGA}
function  AddAppWindow(id: ULONG; userdata: ULONG; window: PWindow; msgport: PMsgPort; const tags: array of const): PAppWindow;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := AddAppWindowA(id, userdata, window, msgport, @TagList);
end;

function  AddAppIcon(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; const tags: array of const): PAppIcon;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := AddAppIconA(id, userdata, txt, msgport, lock, diskobj, @TagList);
end;

function  AddAppMenuItem(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; const tags: array of const): PAppMenuItem;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := AddAppMenuItemA(id, userdata, txt, msgport, @TagList);
end;

function  OpenWorkbenchObject(name: STRPTR; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := OpenWorkbenchObjectA(name, @TagList);
end;

function  CloseWorkbenchObject(name: STRPTR; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := CloseWorkbenchObjectA(name, @TagList);
end;

function  WorkbenchControl(name: STRPTR; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := WorkbenchControlA(name, @TagList);
end;

function  AddAppWindowDropZone(aw: PAppWindow; id: ULONG; userdata: ULONG; const tags: array of const): PAppWindowDropZone;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := AddAppWindowDropZoneA(aw, id, userdata, @TagList);
end;

function  ChangeWorkbenchSelection(name: STRPTR; hook: PHook; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := ChangeWorkbenchSelectionA(name, hook, @TagList);
end;

function  MakeWorkbenchObjectVisible(name: STRPTR; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := MakeWorkbenchObjectVisibleA(name, @TagList);
end;
{$ENDIF}

{$IFDEF AROS}
function AddAppWindow(id: IPTR; userdata: IPTR; window: PWindow; msgport: PMsgPort; const tags: array of const): PAppWindow;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := AddAppWindowA(id, userdata, window, msgport, @TagList);
end;

function AddAppIcon(id: IPTR; userdata: IPTR; const txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; const tags: array of const): PAppIcon;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := AddAppIconA(id, userdata, txt, msgport, lock, diskobj, @TagList);
end;

function AddAppMenuItem(id: IPTR; userdata: IPTR; txt: PChar; msgport: PMsgPort; const tags: array of const): PAppMenuItem;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := AddAppMenuItemA(id, userdata, txt, msgport, @TagList);
end;

function OpenWorkbenchObject(name: STRPTR; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := OpenWorkbenchObjectA(name, @TagList);
end;

function CloseWorkbenchObject(name: STRPTR; const tags: array of const): LBOOL;
//var
//  TagList: TTagsList;
begin
//  AddTags(TagList, tags);
//  Result := CloseWorkbenchObjectA(name, @TagList);
  Result := false;
end;

function WorkbenchControl(name: STRPTR; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := WorkbenchControlA(name, @TagList);
end;

function AddAppWindowDropZone(aw: PAppWindow; id: IPTR; userdata: IPTR; const tags: array of const): PAppWindowDropZone;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := AddAppWindowDropZoneA(aw, id, userdata, @TagList);
end;

function ChangeWorkbenchSelection(name: STRPTR; hook: PHook; const tags: array of const): LBOOL;
//var
//  TagList: TTagsList;
begin
//  AddTags(TagList, tags);
//  Result := ChangeWorkbenchSelectionA(name, hook, @TagList);
  Result := False;
end;

function MakeWorkbenchObjectVisible(name: STRPTR; const tags: array of const): LBOOL;
//var
//  TagList: TTagsList;
begin
//  AddTags(TagList, tags);
//  Result := MakeWorkbenchObjectVisibleA(name, @TagList);
  Result := false;
end;

function UpdateWorkbenchObject(name: STRPTR; typ: SLONG; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  Result := UpdateWorkbenchObjectA(name, typ, @TagList);
end;
{$ENDIF}

{$IFDEF MORPHOS}
function  AddAppWindow(id: ULONG; userdata: ULONG; window: PWindow; msgport: PMsgPort; const tags: array of ULONG): PAppWindow;
begin
  Result := AddAppWindowA(id, userdata, window, msgport, @tags);
end;

function  AddAppIcon(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; const tags: array of ULONG): PAppIcon;
begin
  Result := AddAppIconA(id, userdata, txt, msgport, lock, diskobj, @tags);
end;

function  AddAppMenuItem(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; const tags: array of ULONG): PAppMenuItem;
begin
  Result := AddAppMenuItemA(id, userdata, txt, msgport, @tags);
end;

function  OpenWorkbenchObject(name: STRPTR; const tags: array of ULONG): LBOOL;
begin
  Result := OpenWorkbenchObjectA(name, @tags);
end;

function  CloseWorkbenchObject(name: STRPTR; const tags: array of ULONG): LBOOL;
begin
  Result := CloseWorkbenchObjectA(name, @tags);
end;

function  WorkbenchControl(name: STRPTR; const tags: array of ULONG): LBOOL;
begin
  Result := WorkbenchControlA(name, @tags);
end;

function  AddAppWindowDropZone(aw: PAppWindow; id: ULONG; userdata: ULONG; const tags: array of ULONG): PAppWindowDropZone;
begin
  Result := AddAppWindowDropZoneA(aw, id, userdata, @tags);
end;

function  ChangeWorkbenchSelection(name: STRPTR; hook: PHook; const tags: array of ULONG): LBOOL;
begin
  Result := ChangeWorkbenchSelectionA(name, hook, @tags);
end;

function  MakeWorkbenchObjectVisible(name: STRPTR; const tags: array of ULONG): LBOOL;
begin
  Result := MakeWorkbenchObjectVisibleA(name, @tags);
end;
{$ENDIF}


{$IF DEFINED(AROS) or DEFINED(AMIGA)}
Initialization
  WorkbenchBase := OpenLibrary(WORKBENCHNAME,0);
Finalization
  CloseLibrary(WorkbenchBase);
{$ENDIF}
end.
