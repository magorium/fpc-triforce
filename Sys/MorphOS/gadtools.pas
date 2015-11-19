unit gadtools;


{$MODE OBJFPC}{$H+}

{$IFDEF AMIGA}   {$PACKRECORDS 2} {$ENDIF}
{$IFDEF AROS}    {$PACKRECORDS C} {$ENDIF}
{$IFDEF MORPHOS} {$PACKRECORDS 2} {$ENDIF}

{$UNITPATH ../Trinity/}


interface


uses
  TriniTypes, Exec, intuition, agraphics, utility;


Type
  PPGadget      = ^PGadget;


Const
  GADTOOLSNAME  : PChar = 'gadtools.library';


Const
  {
    The kinds (almost classes) of gadgets that GadTools supports.
    Use these identifiers when calling CreateGadgetA()
  }
  GENERIC_KIND      =  0;       // Kinds for CreateGadgetA()
  BUTTON_KIND       =  1;       // normal button
  CHECKBOX_KIND     =  2;       // boolean gadget
  INTEGER_KIND      =  3;       // to enter numbers
  LISTVIEW_KIND     =  4;       // to list a bunch of entries
  MX_KIND           =  5;       // mutually exclusive entry gadget
  NUMBER_KIND       =  6;       // to show numbers
  CYCLE_KIND        =  7;       // like MX_KIND, but rendered differently
  PALETTE_KIND      =  8;       // to choose a color
  SCROLLER_KIND     =  9;       // to select a value of a range of values
  //* Kind number 10 is reserved
  SLIDER_KIND       = 11;       // like SCROLLER_KIND, but with a fixed range
  STRING_KIND       = 12;       // to enter texts
  TEXT_KIND         = 13;       // to show texts
  NUM_KINDS         = 14;


Type
  PNewGadget = ^TNewGadget;
  TNewGadget = 
  record
    ng_LeftEdge     : SWORD;        // gadget position
    ng_TopEdge      : SWORD;
    ng_Width        : SWORD;        // gadget size
    ng_Height       : SWORD;

    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    ng_GadgetText   : PChar;        // gadget label
    {$ELSE}
    ng_GadgetText   : STRPTR;       // gadget label
    {$ENDIF}
    ng_TextAttr     : PTextAttr;    // desired font for gadget label

    ng_GadgetID     : UWORD;        // gadget ID
    ng_Flags        : ULONG;        // see below
    ng_VisualInfo   : APTR;         // Set to retval of GetVisualInfo()
    ng_UserData     : APTR;         // gadget UserData
  end;


const
  { 
   ng_Flags
   The PLACETEXT flags (specified in <intuition/gadgetclass.h>) specify where
   to put the label(s) of the gadget
  }
  PLACETEXT_LEFT    = (1 shl 0);    // Right-align text on left side
  PLACETEXT_RIGHT   = (1 shl 1);    // Left-align text on right side
  PLACETEXT_ABOVE   = (1 shl 2);    // Center text above
  PLACETEXT_BELOW   = (1 shl 3);    // Center text below
  PLACETEXT_IN      = (1 shl 4);    // Center text on

  NG_HIGHLABEL      = (1 shl 5);    // Highlight the label


const
  // IDCMP-Flags necessary for certain gadgets
  ARROWIDCMP        = (IDCMP_GADGETUP or IDCMP_GADGETDOWN or IDCMP_INTUITICKS or IDCMP_MOUSEBUTTONS);

  BUTTONIDCMP       = (IDCMP_GADGETUP);
  CHECKBOXIDCMP     = (IDCMP_GADGETUP);
  INTEGERIDCMP      = (IDCMP_GADGETUP);
  LISTVIEWIDCMP     = (ARROWIDCMP or IDCMP_GADGETUP or IDCMP_GADGETDOWN or IDCMP_MOUSEMOVE);

  MXIDCMP           = (IDCMP_GADGETDOWN);
  NUMBERIDCMP       = (0);
  CYCLEIDCMP        = (IDCMP_GADGETUP);
  PALETTEIDCMP      = (IDCMP_GADGETUP);

  SCROLLERIDCMP     = (IDCMP_GADGETUP or IDCMP_GADGETDOWN or IDCMP_MOUSEMOVE);
  SLIDERIDCMP       = (IDCMP_GADGETUP or IDCMP_GADGETDOWN or IDCMP_MOUSEMOVE);
  STRINGIDCMP       = (IDCMP_GADGETUP);

  TEXTIDCMP         = (0);


const
  { 
    Starting with V39, checkboxes and mx gadgets can be scaled to your
    specified gadget width/height.  Use the new GTCB_Scaled or GTMX_Scaled
    tags, respectively.  Under V37, and by default in V39, the imagery
    is of the following fixed size:
  }

  // MX gadget default dimensions:
  MX_WIDTH          = 17;
  MX_HEIGHT         =  9;

  // Checkbox default dimensions:
  CHECKBOX_WIDTH    = 26;
  CHECKBOX_HEIGHT   = 11;

  {$IFDEF AROS}
  // Indicate that gadget is a gadtools gadget (PRIVATE)
  GTYP_GADTOOLS     = $0100;
  {$ENDIF}


Type
  PNewMenu = ^TNewMenu;
  TNewMenu = 
  record
    nm_Type         : UBYTE;        // See below
    //nm_Pad              : SBYTE;
    nm_Label        : STRPTR;       // Menu's label
    nm_CommKey      : STRPTR;       // MenuItem Command Key Equiv
    nm_Flags        : UWORD;        // Menu OR MenuItem flags (see note)
    nm_MutualExclude: SLONG;        // MenuItem MutualExclude word
    nm_UserData     : APTR;         // For your own use, see note
  end;


const
  // nm_Type
  NM_END            = $0000;
  NM_TITLE          = $0001;
  NM_ITEM           = $0002;
  NM_SUB            = $0003;

  NM_IGNORE         = $0040;
  {$IFDEF AROS}
  IM_ITEM           = $0082;
  IM_SUB            = $0083;
  {$ENDIF}
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  MENU_IMAGE        = 128;

  IM_ITEM           = (NM_ITEM or MENU_IMAGE);
  IM_SUB            = (NM_SUB or MENU_IMAGE);
  {$ENDIF}

  // nm_Label
  NM_BARLABEL       = PChar(-1);
 
  // nm_Flags
  NM_MENUDISABLED   = MENUENABLED;
  NM_ITEMDISABLED   = ITEMENABLED;
  NM_COMMANDSTRING  = COMMSEQ;

  NM_FLAGMASK       = (not (ITEMTEXT or HIGHFLAGS or COMMSEQ));
  NM_FLAGMASK_V39   = (not (ITEMTEXT or HIGHFLAGS));


Const
  GTMENU_TRIMMED    = $00000001;
  GTMENU_INVALID    = $00000002;
  GTMENU_NOMEM      = $00000003;


Const
  // Tags for GadTools functions
  GT_TagBase        = TAG_USER + $00080000;

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  GTVI_NewWindow        = (GT_TagBase +  1);    // Unused
  GTVI_NWTags           = (GT_TagBase +  2);    // Unused
  GT_Private0           = (GT_TagBase +  3);    // (private)
  {$ENDIF}

  GTCB_Checked          = (GT_TagBase +  4);    // State of checkbox
  GTLV_Top              = (GT_TagBase +  5);    // Top visible one in listview
  GTLV_Labels           = (GT_TagBase +  6);    // List to display in listview
  GTLV_ReadOnly         = (GT_TagBase +  7);    // TRUE IF listview is to be read-only
  GTLV_ScrollWidth      = (GT_TagBase +  8);    // Width of scrollbar
  GTMX_Labels           = (GT_TagBase +  9);    // NULL-terminated array of labels
  GTMX_Active           = (GT_TagBase + 10);    // Active one in mx gadget
  GTTX_Text             = (GT_TagBase + 11);    // Text to display
  GTTX_CopyText         = (GT_TagBase + 12);    // Copy text label instead of referencing it
  GTNM_Number           = (GT_TagBase + 13);    // Number to display
  GTCY_Labels           = (GT_TagBase + 14);    // NULL-terminated array of labels
  GTCY_Active           = (GT_TagBase + 15);    // The active one in the cycle gad
  GTPA_Depth            = (GT_TagBase + 16);    // Number of bitplanes in palette
  GTPA_Color            = (GT_TagBase + 17);    // Palette color
  GTPA_ColorOffset      = (GT_TagBase + 18);    // First color to use in palette
  GTPA_IndicatorWidth   = (GT_TagBase + 19);    // Width of current-color indicator
  GTPA_IndicatorHeight  = (GT_TagBase + 20);    // Height of current-color indicator
  GTSC_Top              = (GT_TagBase + 21);    // Top visible in scroller
  GTSC_Total            = (GT_TagBase + 22);    // Total in scroller area
  GTSC_Visible          = (GT_TagBase + 23);    // Number visible in scroller
  GTSC_Overlap          = (GT_TagBase + 24);    // Unused
  // GT_TagBase+25 through GT_TagBase+37 are reserved
  GTSL_Min              = (GT_TagBase + 38);    // Slider min value
  GTSL_Max              = (GT_TagBase + 39);    // Slider max value
  GTSL_Level            = (GT_TagBase + 40);    // Slider level
  GTSL_MaxLevelLen      = (GT_TagBase + 41);    // Max length of printed level
  GTSL_LevelFormat      = (GT_TagBase + 42);    // Format string for level
  GTSL_LevelPlace       = (GT_TagBase + 43);    // Where level should be placed
  GTSL_DispFunc         = (GT_TagBase + 44);    // Callback for number calculation before display
  GTST_String           = (GT_TagBase + 45);    // String gadget's displayed string
  GTST_MaxChars         = (GT_TagBase + 46);    // Max length of string
  GTIN_Number           = (GT_TagBase + 47);    // Number in integer gadget
  GTIN_MaxChars         = (GT_TagBase + 48);    // Max number of digits
  GTMN_TextAttr         = (GT_TagBase + 49);    // MenuItem font TextAttr
  GTMN_FrontPen         = (GT_TagBase + 50);    // MenuItem text pen color
  GTBB_Recessed         = (GT_TagBase + 51);    // Make BevelBox recessed
  GT_VisualInfo         = (GT_TagBase + 52);    // result of VisualInfo call
  GTLV_ShowSelected     = (GT_TagBase + 53);    // show selected entry beneath listview, set tag data = NULL for display-only, or pointer to a string gadget you've created
  GTLV_Selected         = (GT_TagBase + 54);    // Set ordinal number of selected entry in the list
  GTST_EditHook         = (GT_TagBase + 55);
  GTIN_EditHook         = (GTST_EditHook);
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  GT_Reserved0          = (GT_TagBase + 55);    // Reserved for Amiga, obsolete for Morphos
  GT_Reserved1          = (GT_TagBase + 56);    // Reserved for future use
  {$ENDIF}
  GTTX_Border           = (GT_TagBase + 57);    // Put a border around Text-display gadgets
  GTNM_Border           = (GT_TagBase + 58);    // Put a border around Number-display gadgets
  GTSC_Arrows           = (GT_TagBase + 59);    // Specify size of arrows for scroller
  GTMN_Menu             = (GT_TagBase + 60);    // Pointer to Menu for use by LayoutMenuItems()
  GTMX_Spacing          = (GT_TagBase + 61);    // Added to font height to figure spacing between mx choices. Use this instead of LAYOUTA_SPACING for mx gadgets.
  // New to V37 GadTools.  Ignored by GadTools V36
  GTMN_FullMenu         = (GT_TagBase + 62);    // Asks CreateMenus() to validate that this is a complete menu structure
  GTMN_SecondaryError   = (GT_TagBase + 63);    // ti_Data is a pointer to a LongWord to receive error reports from CreateMenus()
  GT_Underscore         = (GT_TagBase + 64);    // ti_Data points to the symbol that preceeds the character you'd like to underline in a gadget label
  // New to V39 GadTools.  Ignored by GadTools V36 and V37
  GTMN_Checkmark        = (GT_TagBase + 65);    // ti_Data is checkmark img to use
  GTMN_AmigaKey         = (GT_TagBase + 66);    // ti_Data is Amiga-key img to use
  GTMN_NewLookMenus     = (GT_TagBase + 67);    // ti_Data is boolean
  // New to V39 GadTools.  Ignored by GadTools V36 and V37.
  GTCB_Scaled           = (GT_TagBase + 68);    // ti_Data is boolean
  GTMX_Scaled           = (GT_TagBase + 69);    // ti_Data is boolean
  GTPA_NumColors        = (GT_TagBase + 70);    // Number of colors in palette
  GTMX_TitlePlace       = (GT_TagBase + 71);    // Where to put the title
  GTTX_FrontPen         = (GT_TagBase + 72);    // Text color in TEXT_KIND gad
  GTTX_BackPen          = (GT_TagBase + 73);    // Bgrnd color in TEXT_KIND gad
  GTTX_Justification    = (GT_TagBase + 74);    // See GTJ_#? constants
  GTNM_FrontPen         = (GT_TagBase + 72);    // Text color in NUMBER_KIND gad
  GTNM_BackPen          = (GT_TagBase + 73);    // Bgrnd color in NUMBER_KIND gad
  GTNM_Justification    = (GT_TagBase + 74);    // See GTJ_#? constants
  GTNM_Format           = (GT_TagBase + 75);    // Formatting string for number
  GTNM_MaxNumberLen     = (GT_TagBase + 76);    // Maximum length of number
  GTBB_FrameType        = (GT_TagBase + 77);    // defines what kind of boxes DrawBevelBox() renders. See the BBFT_#? constants for possible values
  GTLV_MakeVisible      = (GT_TagBase + 78);    // Make this item visible
  GTLV_ItemHeight       = (GT_TagBase + 79);    // Height of an individual item
  GTSL_MaxPixelLen      = (GT_TagBase + 80);    // Max pixel size of level display
  GTSL_Justification    = (GT_TagBase + 81);    // how should the level be displayed
  GTPA_ColorTable       = (GT_TagBase + 82);    // colors to use in palette
  GTLV_CallBack         = (GT_TagBase + 83);    // general-purpose listview call back
  GTLV_MaxPen           = (GT_TagBase + 84);    // maximum pen number used by call back
  GTTX_Clipped          = (GT_TagBase + 85);    // make a TEXT_KIND clip text
  GTNM_Clipped          = (GT_TagBase + 85);    // make a NUMBER_KIND clip text

  {$IFDEF AROS}
  // AROS Extensions
  GTLV_Total            = (GT_TagBase + 150);   // OM_GET
  GTLV_Visible          = (GT_TagBase + 151);   // OM_GET
  {$ENDIF}

  // GTTX_Justification and GTNM_Justification
  GTJ_LEFT          = 0;
  GTJ_RIGHT         = 1;
  GTJ_CENTER        = 2;

  // GTBB_FrameType
  BBFT_BUTTON       = 1;            // Standard button gadget box
  BBFT_RIDGE        = 2;            // Standard string gadget box
  BBFT_ICONDROPBOX  = 3;            // Standard icon drop box

  // GTLV_CallBack
  LV_DRAW           = $202;
  // return values from these hooks
  LVCB_OK           = 0;
  LVCB_UNKNOWN      = 1;

  INTERWIDTH        = 8;
  INTERHEIGHT       = 4;


Type
  // structure of LV_DRAW messages, object is a (struct Node *)
  PLVDrawMsg = ^tLVDrawMsg;
  TLVDrawMsg = 
  record
    lvdm_MethodID   : ULONG;        // LV_DRAW
    lvdm_RastPort   : PRastPort;    // where to render to
    lvdm_DrawInfo   : PDrawInfo;    // useful to have around
    lvdm_Bounds     : TRectangle;   // limits of where to render
    lvdm_State      : ULONG;        // how to render
  end;


const
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  // "NWay" is an old synonym for cycle gadgets
  NWAY_KIND         = CYCLE_KIND;
  NWAYIDCMP         = CYCLEIDCMP;
  GTNW_Labels       = GTCY_Labels;
  GTNW_Active       = GTCY_Active;

  GADTOOLBIT        = ($8000);
  // Use this mask to isolate the user part:
  GADTOOLMASK       =  not (GADTOOLBIT);
  {$ENDIF}

  // states for LVDrawMsg.lvdm_State
  LVR_NORMAL            = 0;        // the usual
  LVR_SELECTED          = 1;        // for selected gadgets
  LVR_NORMALDISABLED    = 2;        // for disabled gadgets
  LVR_SELECTEDDISABLED  = 8;        // disabled and selected



var
  GadToolsBase: PLibrary;

  {$IFDEF AMIGA}
  function  CreateGadgetA(kind: ULONG location 'd0'; previous: PGadget location 'a0'; newgad: PNewGadget location 'a1'; const tagList: PTagItem location 'a2'): PGadget;                                        syscall GadToolsBase 030;
  procedure FreeGadgets(glist: PGadget location 'a0');                                                                                                                                                          syscall GadToolsBase 036;
  procedure GT_SetGadgetAttrsA(gad: PGadget location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; const tagList: PTagItem location 'a3');                                                   syscall GadToolsBase 042;
  function  CreateMenusA(newmenu: PNewMenu location 'a0'; const tagList: PTagItem location 'a1'): PMenu;                                                                                                        syscall GadToolsBase 048;
  procedure FreeMenus(menu: PMenu location 'a0');                                                                                                                                                               syscall GadToolsBase 054;
  function  LayoutMenuItemsA(menuitem: PMenuItem location 'a0'; vi: APTR location 'a1'; const tagList: PTagItem location 'a2'): LBOOL;                                                                          syscall GadToolsBase 060;
  function  LayoutMenusA(menu: PMenu location 'a0'; vi: APTR location 'a1'; const tagList: PTagItem location 'a2'): LBOOL;                                                                                      syscall GadToolsBase 066;
  function  GT_GetIMsg(intuiport: PMsgPort location 'a0'): PIntuiMessage;                                                                                                                                       syscall GadToolsBase 072;
  procedure GT_ReplyIMsg(imsg: PIntuiMessage location 'a1');                                                                                                                                                    syscall GadToolsBase 078;
  procedure GT_RefreshWindow(win: PWindow location 'a0'; req: PRequester location 'a1');                                                                                                                        syscall GadToolsBase 084;
  procedure GT_BeginRefresh(win: PWindow location 'a0');                                                                                                                                                        syscall GadToolsBase 090;
  procedure GT_EndRefresh(win: PWindow location 'a0'; complete: LBOOL location 'd0');                                                                                                                           syscall GadToolsBase 096;
  function  GT_FilterIMsg(imsg: PIntuiMessage location 'a1'): PIntuiMessage;                                                                                                                                    syscall GadToolsBase 102;
  function  GT_PostFilterIMsg(modimsg: PIntuiMessage location 'a1'): PIntuiMessage;                                                                                                                             syscall GadToolsBase 108;
  function  CreateContext(glistpointer: PPGadget location 'a0'): PGadget;                                                                                                                                       syscall GadToolsBase 114;
  procedure DrawBevelBoxA(rport: PRastPort location 'a0'; left: SWORD location 'd0'; top: SWORD location 'd1'; width: SWORD location 'd2'; height: SWORD location 'd3'; const tagList: PTagItem location 'a1'); syscall GadToolsBase 120;
  function  GetVisualInfoA(screen: PScreen location 'a0'; const tagList: PTagItem location 'a1'): APTR;                                                                                                         syscall GadToolsBase 126;
  procedure FreeVisualInfo(vi: APTR location 'a0');                                                                                                                                                             syscall GadToolsBase 132;
  function  GT_GetGadgetAttrsA(gad: PGadget location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; const tagList: PTagItem location 'a3'): SLONG;                                            syscall GadToolsBase 174;

  // vargargs
  function  CreateGadget(kind: ULONG; previous: PGadget; newgad: PNewGadget; const tags: array of const): PGadget;
  procedure GT_SetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of const);
  function  CreateMenus(newmenu: PNewMenu; const tags: array of const): PMenu;
  function  LayoutMenuItems(menuitem: PMenuItem; vi: APTR; const tags: array of const): LBOOL;
  function  LayoutMenus(menu: PMenu; vi: APTR; const tags: array of const): LBOOL;
  procedure DrawBevelBox(rport: PRastPort; left: SWORD; top: SWORD; width: SWORD; height: SWORD; const tags: array of const);
  function  GetVisualInfo(screen: PScreen; const tags: array of const): APTR;
  function  GT_GetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of const): SLONG;
  {$ENDIF}
  {$IFDEF AROS}
  function  CreateGadgetA(Kind: ULONG; previous: PGadget; ng: PNewGadget; const taglist: PTagItem): PGadget;                    syscall GadToolsBase  5;
  procedure FreeGadgets(glist: PGadget);                                                                                        syscall GadToolsBase  6;
  procedure GT_SetGadgetAttrsA(gad: PGadget; win: PWindow; req: PRequester; const tagList: PTagItem);                           syscall GadToolsBase  7;
  function  CreateMenusA(newmenu: PNewMenu; const tagList: PTagItem): PMenu;                                                    syscall GadToolsBase  8;
  procedure FreeMenus(menu: PMenu);                                                                                             syscall GadToolsBase  9;
  function  LayoutMenuItemsA(menuitem: PMenuItem; vi: APTR; const tagList: PTagItem): LBOOL;                                    syscall GadToolsBase 10;
  function  LayoutMenusA(menu: PMenu; vi: APTR; const tagList: PTagItem): LBOOL;                                                syscall GadToolsBase 11;
  function  GT_GetIMsg(intuiport: PMsgPort): PIntuiMessage;                                                                     syscall GadToolsBase 12;
  procedure GT_ReplyIMsg(imsg: PIntuiMessage);                                                                                  syscall GadToolsBase 13;
  procedure GT_RefreshWindow(win: PWindow; req: PRequester);                                                                    syscall GadToolsBase 14;
  procedure GT_BeginRefresh(win: PWindow);                                                                                      syscall GadToolsBase 15;
  procedure GT_EndRefresh(win: PWindow; complete: LBOOL);                                                                       syscall GadToolsBase 16;
  function  GT_FilterIMsg(imsg: PIntuiMessage): PIntuiMessage;                                                                  syscall GadToolsBase 17;
  function  GT_PostFilterIMsg(modimsg: PIntuiMessage): PIntuiMessage;                                                           syscall GadToolsBase 18;
  function  CreateContext(glistpointer: PPGadget): PGadget;                                                                     syscall GadToolsBase 19;
  procedure DrawBevelBoxA(rport: PRastPort; left: SWORD; top: SWORD; width: SWORD; height: SWORD; const taglist: PTagItem);     syscall GadToolsBase 20;
  function  GetVisualInfoA(screen: PScreen; const tagList: PTagItem): APTR;                                                     syscall GadToolsBase 21;
  procedure FreeVisualInfo(vi: APTR);                                                                                           syscall GadToolsBase 22;
  function  GT_GetGadgetAttrsA(gad: PGadget; win: PWindow; req: PRequester; const taglist: PTagItem): SLONG;                    syscall GadToolsBase 29;

  // varargs
  function  CreateGadget(Kind: ULONG; previous: PGadget; ng: PNewGadget; const tags: array of const): PGadget;
  procedure GT_SetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of const);
  function  CreateMenus(newmenu: PNewMenu; const tags: array of const): PMenu;
  function  LayoutMenuItems(menuitem: PMenuItem; vi: APTR; const tags: array of const): LBOOL;
  function  LayoutMenus(menu: PMenu; vi: APTR; const tags: array of const): LBOOL;
  procedure DrawBevelBox(rport: PRastPort; left: SWORD; top: SWORD; width: SWORD; height: SWORD; const tags: array of const);
  function  GetVisualInfo(screen: PScreen; const tags: array of const): APTR;
  function  GT_GetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of const): SLONG;
  {$ENDIF}
  {$IFDEF MORPHOS}
  function  CreateGadgetA(kind: ULONG location 'd0'; gad: PGadget location 'a0'; const ng: PNewGadget location 'a1'; const tagList: PTagItem location 'a2'): PGadget;                                           syscall GadToolsBase 030;
  procedure FreeGadgets(gad: PGadget location 'a0');                                                                                                                                                            syscall GadToolsBase 036;
  procedure GT_SetGadgetAttrsA(gad: PGadget location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; const tagList: PTagItem location 'a3');                                                   syscall GadToolsBase 042;
  function  CreateMenusA(const newmenu: PNewMenu location 'a0'; const tagList: PTagItem location 'a1'): PMenu;                                                                                                  syscall GadToolsBase 048;
  procedure FreeMenus(menu: PMenu location 'a0');                                                                                                                                                               syscall GadToolsBase 054;
  function  LayoutMenuItemsA(firstitem: PMenuItem location 'a0'; vi: APTR location 'a1'; const tagList: PTagItem location 'a2'): LBOOL;                                                                         syscall GadToolsBase 060;
  function  LayoutMenusA(firstmenu: PMenu location 'a0'; vi: APTR location 'a1'; const tagList: PTagItem location 'a2'): LBOOL;                                                                                 syscall GadToolsBase 066;
  function  GT_GetIMsg(iport: PMsgPort location 'a0'): PIntuiMessage;                                                                                                                                           syscall GadToolsBase 072;
  procedure GT_ReplyIMsg(imsg: PIntuiMessage location 'a1');                                                                                                                                                    syscall GadToolsBase 078;
  procedure GT_RefreshWindow(win: PWindow location 'a0'; req: PRequester location 'a1');                                                                                                                        syscall GadToolsBase 084;
  procedure GT_BeginRefresh(win: PWindow location 'a0');                                                                                                                                                        syscall GadToolsBase 090;
  procedure GT_EndRefresh(win: PWindow location 'a0'; complete: SLONG location 'd0');                                                                                                                           syscall GadToolsBase 096;
  function  GT_FilterIMsg(const imsg: PIntuiMessage location 'a1'): PIntuiMessage;                                                                                                                              syscall GadToolsBase 102;
  function  GT_PostFilterIMsg(imsg: PIntuiMessage location 'a1'): PIntuiMessage;                                                                                                                                syscall GadToolsBase 108;
  function  CreateContext(glistptr: PPGadget location 'a0'): PGadget;                                                                                                                                           syscall GadToolsBase 114;
  procedure DrawBevelBoxA(rport: PRastPort location 'a0'; left: SLONG location 'd0'; top: SLONG location 'd1'; width: SLONG location 'd2'; height: SLONG location 'd3'; const tagList: PTagItem location 'a1'); syscall GadToolsBase 120;
  function  GetVisualInfoA(screen: PScreen location 'a0'; const tagList: PTagItem location 'a1'): APTR;                                                                                                         syscall GadToolsBase 126;
  procedure FreeVisualInfo(vi: APTR location 'a0');                                                                                                                                                             syscall GadToolsBase 132;
  function  GT_GetGadgetAttrsA(gad: PGadget location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; const tagList: PTagItem location 'a3'): SLONG;                                            syscall GadToolsBase 174;

  // varargs
  function  CreateGadget(kind: ULONG; gad: PGadget; const ng: PNewGadget; const tags: array of ULONG): PGadget;
  procedure GT_SetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of ULONG);
  function  CreateMenus(const newmenu: PNewMenu; const tags: array of ULONG): PMenu;
  function  LayoutMenuItems(firstitem: PMenuItem; vi: APTR; const tags: array of ULONG): LBOOL;
  function  LayoutMenus(firstmenu: PMenu; vi: APTR; const tags: array of ULONG): LBOOL;
  procedure DrawBevelBox(rport: PRastPort; left: SLONG; top: SLONG; width: SLONG; height: SLONG; const tags: array of ULONG);
  function  GetVisualInfo(screen: PScreen; const tags: array of ULONG): APTR;
  function  GT_GetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of ULONG): SLONG;
  {$ENDIF}


  // Macro's
  // amiga
  (*\
  #define GTMENU_USERDATA(menu) ( * ( (APTR * )(((struct Menu * )menu)+1) ) )
  #define GTMENUITEM_USERDATA(menuitem) ( * ( (APTR * )(((struct MenuItem * )menuitem)+1) ) )

  /* Here is an old one for compatibility.  Do not use in new code! */
  #define MENU_USERDATA(menuitem) ( * ( (APTR * )(menuitem+1) ) )
  *)
  // aros
  (*
  function GTMENUITEM_USERDATA(MenuItem: PMenuItem): Pointer;
  function GTMENU_USERDATA(Menu: PMenu): Pointer;
  *)
  // morphos
  (*
  #define GTMENU_USERDATA(menu)         ( *((APTR * )(((struct Menu * )menu) + 1)))
  #define GTMENUITEM_USERDATA(menuitem) ( *((APTR * )(((struct MenuItem * )menuitem) + 1)))
  #define MENU_USERDATA(menuitem)       ( *((APTR * )(menuitem + 1)))
  *)
  function GTMENUITEM_USERDATA(MenuItem: PMenuItem): Pointer;
  function GTMENU_USERDATA(Menu: PMenu): Pointer;


implementation


{$IFDEF AMIGA}
Uses
  tagsarray;
{$ENDIF}

{$IFDEF AROS}
Uses
  tagsarray;
{$ENDIF}



{$IFDEF AMIGA}
function  CreateGadget(kind: ULONG; previous: PGadget; newgad: PNewGadget; const tags: array of const): PGadget;
begin
  CreateGadget := CreateGadgetA(kind, previous, newgad, readintags(tags));
end;

procedure GT_SetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of const);
begin
  GT_SetGadgetAttrsA(gad, win, req, readintags(tags));
end;

function  CreateMenus(newmenu: PNewMenu; const tags: array of const): PMenu;
begin
  CreateMenus := CreateMenusA(newmenu, readintags(tags));
end;

function  LayoutMenuItems(menuitem: PMenuItem; vi: APTR; const tags: array of const): LBOOL;
begin
  LayoutMenuItems := LayoutMenuItemsA(menuitem, vi, readintags(tags));
end;

function  LayoutMenus(menu: PMenu; vi: APTR; const tags: array of const): LBOOL;
begin
  LayoutMenus := LayoutMenusA(menu, vi, readintags(tags));
end;

procedure DrawBevelBox(rport: PRastPort; left: SWORD; top: SWORD; width: SWORD; height: SWORD; const tags: array of const);
begin
  DrawBevelBoxA(rport, left, top, width, height, readintags(tags));
end;

function  GetVisualInfo(screen: PScreen; const tags: array of const): APTR;
begin
  GetVisualInfo := GetVisualInfoA(screen, readintags(tags));
end;

function  GT_GetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of const): SLONG;
begin
  GT_GetGadgetAttrs := GT_GetGadgetAttrsA(gad, win, req, readintags(tags));
end;
{$ENDIF}



{$IFDEF AROS}
function  CreateGadget(Kind: ULONG; previous: PGadget; ng: PNewGadget; const tags: array of const): PGadget;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  CreateGadget := CreateGadgetA(kind, previous, ng, GetTagPtr(TagList));
end;

procedure GT_SetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of const);
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  GT_SetGadgetAttrsA(gad, win, req, GetTagPtr(TagList));
end;

function  CreateMenus(newmenu: PNewMenu; const tags: array of const): PMenu;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  CreateMenus := CreateMenusA(newmenu, GetTagPtr(TagList));
end;

function  LayoutMenuItems(menuitem: PMenuItem; vi: APTR; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  LayoutMenuItems := LayoutMenuItemsA(menuitem, vi, GetTagPtr(TagList));
end;

function  LayoutMenus(menu: PMenu; vi: APTR; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  LayoutMenus := LayoutMenusA(menu, vi, GetTagPtr(TagList));
end;

procedure DrawBevelBox(rport: PRastPort; left: SWORD; top: SWORD; width: SWORD; height: SWORD; const tags: array of const);
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  DrawBevelBoxA(rport, left, top, width, height, GetTagPtr(TagList));
end;

function  GetVisualInfo(screen: PScreen; const tags: array of const): APTR;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  GetVisualInfo := GetVisualInfoA(screen, GetTagPtr(TagList));
end;

function  GT_GetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of const): SLONG;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  GT_GetGadgetAttrs := GT_GetGadgetAttrsA(gad, win, req, GetTagPtr(TagList));
end;
{$ENDIF}



{$IFDEF MORPHOS}
function  CreateGadget(kind: ULONG; gad: PGadget; const ng: PNewGadget; const tags: array of ULONG): PGadget;
begin
  CreateGadget := CreateGadgetA(kind, gad, ng, @tags);
end;

procedure GT_SetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of ULONG);
begin
  GT_SetGadgetAttrsA(gad, win, req, @tags);
end;

function  CreateMenus(const newmenu: PNewMenu; const tags: array of ULONG): PMenu;
begin
  CreateMenus := CreateMenusA(newmenu, @tags);
end;

function  LayoutMenuItems(firstitem: PMenuItem; vi: APTR; const tags: array of ULONG): LBOOL;
begin
  LayoutMenuItems := LayoutMenuItemsA(firstitem, vi, @tags);
end;

function  LayoutMenus(firstmenu: PMenu; vi: APTR; const tags: array of ULONG): LBOOL;
begin
  LayoutMenus := LayoutMenusA(firstmenu, vi, @tags);
end;

procedure DrawBevelBox(rport: PRastPort; left: SLONG; top: SLONG; width: SLONG; height: SLONG; const tags: array of ULONG);
begin
  DrawBevelBoxA(rport, left, top, width, height, @tags);
end;

function  GetVisualInfo(screen: PScreen; const tags: array of ULONG): APTR;
begin
  GetVisualInfo := GetVisualInfoA(screen, @tags);
end;

function  GT_GetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const tags: array of ULONG): SLONG;
begin
  GT_GetGadgetAttrs := GT_GetGadgetAttrsA(gad, win, req, @tags);
end;
{$ENDIF}


// Macro's

function GTMENUITEM_USERDATA(menuitem : pMenuItem): pointer;
begin
  GTMENUITEM_USERDATA := Pointer((PMenuItem(MenuItem) + 1));
end;

function GTMENU_USERDATA(Menu: PMenu): Pointer;
begin
  GTMENU_USERDATA := Pointer((PMenu(Menu) + 1));
end;


{$IFDEF AROS}
initialization
  GadToolsBase := OpenLibrary(GADTOOLSNAME, 36);

finalization
  CloseLibrary(GadToolsBase);
{$ENDIF}

end.
