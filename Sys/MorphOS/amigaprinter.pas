unit amigaprinter;


{
  printer device 
}


{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$IFDEF AMIGA}   {$PACKRECORDS 2} {$ENDIF}
{$IFDEF AROS}    {$PACKRECORDS C} {$ENDIF}
{$IFDEF MORPHOS} {$PACKRECORDS 2} {$ENDIF}

{$UNITPATH ../Trinity/}


interface


uses
  TriniTypes, Exec, AGraphics, Intuition, Utility, prefs;



//
// Global
//



//
//  printer.h
//

Const
  //* V30-V40 commands */

  PRD_RAWWRITE        = (CMD_NONSTD);
  PRD_PRTCOMMAND      = (CMD_NONSTD + 1);
  PRD_DUMPRPORT       = (CMD_NONSTD + 2);
  PRD_QUERY           = (CMD_NONSTD + 3);

  //* V44 commands */

  PRD_RESETPREFS      = (CMD_NONSTD + 4);       // PRIVATE: do not use!
  PRD_LOADPREFS       = (CMD_NONSTD + 5);       // PRIVATE: do not use!
  PRD_USEPREFS        = (CMD_NONSTD + 6);       // PRIVATE: do not use!
  PRD_SAVEPREFS       = (CMD_NONSTD + 7);       // PRIVATE: do not use!
  PRD_READPREFS       = (CMD_NONSTD + 8);
  PRD_WRITEPREFS      = (CMD_NONSTD + 9);
  PRD_EDITPREFS       = (CMD_NONSTD + 10);
  PRD_SETERRHOOK      = (CMD_NONSTD + 11);
  PRD_DUMPRPORTTAGS   = (CMD_NONSTD + 12);

  //* printer command definitions */

  aRIS        = 0;          // ESCc  reset                      ISO
  aRIN        = 1;          // ESC#1 initialize                 +++
  aIND        = 2;          // ESCD  lf                         ISO
  aNEL        = 3;          // ESCE  return,lf                  ISO
  aRI         = 4;          // ESCM  reverse lf                 ISO

  aSGR0       = 5;          // ESC[0m normal char set           ISO
  aSGR3       = 6;          // ESC[3m italics on                ISO
  aSGR23      = 7;          // ESC[23m italics off              ISO
  aSGR4       = 8;          // ESC[4m underline on              ISO
  aSGR24      = 9;          // ESC[24m underline off            ISO
  aSGR1       = 10;         // ESC[1m boldface on               ISO
  aSGR22      = 11;         // ESC[22m boldface off             ISO
  aSFC        = 12;         // SGR30-39 set foreground color    ISO
  aSBC        = 13;         // SGR40-49 set background color    ISO

  aSHORP0     = 14;         // ESC[0w normal pitch              DEC
  aSHORP2     = 15;         // ESC[2w elite on                  DEC
  aSHORP1     = 16;         // ESC[1w elite off                 DEC
  aSHORP4     = 17;         // ESC[4w condensed fine on         DEC
  aSHORP3     = 18;         // ESC[3w condensed off             DEC
  aSHORP6     = 19;         // ESC[6w enlarged on               DEC
  aSHORP5     = 20;         // ESC[5w enlarged off              DEC

  aDEN6       = 21;         // ESC[6"z shadow print on          DEC (sort of)
  aDEN5       = 22;         // ESC[5"z shadow print off         DEC
  aDEN4       = 23;         // ESC[4"z doublestrike on          DEC
  aDEN3       = 24;         // ESC[3"z doublestrike off         DEC
  aDEN2       = 25;         // ESC[2"z NLQ on                   DEC
  aDEN1       = 26;         // ESC[1"z NLQ off                  DEC

  aSUS2       = 27;         // ESC[2v superscript on            +++
  aSUS1       = 28;         // ESC[1v superscript off           +++
  aSUS4       = 29;         // ESC[4v subscript on              +++
  aSUS3       = 30;         // ESC[3v subscript off             +++
  aSUS0       = 31;         // ESC[0v normalize the line        +++
  aPLU        = 32;         // ESCL  partial line up            ISO
  aPLD        = 33;         // ESCK  partial line down          ISO

  aFNT0       = 34;         // ESC(B US char set        or Typeface  0 (default)
  aFNT1       = 35;         // ESC(R French char set    or Typeface  1
  aFNT2       = 36;         // ESC(K German char set    or Typeface  2
  aFNT3       = 37;         // ESC(A UK char set        or Typeface  3
  aFNT4       = 38;         // ESC(E Danish I char set  or Typeface  4
  aFNT5       = 39;         // ESC(H Sweden char set    or Typeface  5
  aFNT6       = 40;         // ESC(Y Italian char set   or Typeface  6
  aFNT7       = 41;         // ESC(Z Spanish char set   or Typeface  7
  aFNT8       = 42;         // ESC(J Japanese char set  or Typeface  8
  aFNT9       = 43;         // ESC(6 Norweign char set  or Typeface  9
  aFNT10      = 44;         // ESC(C Danish II char set or Typeface 10

  aPROP2      = 45;         // ESC[2p  proportional on          +++
  aPROP1      = 46;         // ESC[1p  proportional off         +++
  aPROP0      = 47;         // ESC[0p  proportional clear       +++
  aTSS        = 48;         // ESC[n E set proportional offset  ISO
  aJFY5       = 49;         // ESC[5 F auto left justify        ISO
  aJFY7       = 50;         // ESC[7 F auto right justify       ISO
  aJFY6       = 51;         // ESC[6 F auto full justify        ISO
  aJFY0       = 52;         // ESC[0 F auto justify off         ISO
  aJFY3       = 53;         // ESC[3 F letter space (justify)   ISO (special)
  aJFY1       = 54;         // ESC[1 F word fill(auto center)   ISO (special)

  aVERP0      = 55;         // ESC[0z  1/8" line spacing        +++
  aVERP1      = 56;         // ESC[1z  1/6" line spacing        +++
  aSLPP       = 57;         // ESC[nt  set form length n        DEC
  aPERF       = 58;         // ESC[nq  perf skip n (n>0)        +++
  aPERF0      = 59;         // ESC[0q  perf skip off            +++

  aLMS        = 60;         // ESC#9   Left margin set          +++
  aRMS        = 61;         // ESC#0   Right margin set         +++
  aTMS        = 62;         // ESC#8   Top margin set           +++
  aBMS        = 63;         // ESC#2   Bottom marg set          +++
  aSTBM       = 64;         // ESC[Pn1;Pn2r  T&B margins        DEC
  aSLRM       = 65;         // ESC[Pn1;Pn2s  L&R margin         DEC
  aCAM        = 66;         // ESC#3   Clear margins            +++

  aHTS        = 67;         // ESCH    Set horiz tab            ISO
  aVTS        = 68;         // ESCJ    Set vertical tabs        ISO
  aTBC0       = 69;         // ESC[0g  Clr horiz tab            ISO
  aTBC3       = 70;         // ESC[3g  Clear all h tab          ISO
  aTBC1       = 71;         // ESC[1g  Clr vertical tabs        ISO
  aTBC4       = 72;         // ESC[4g  Clr all v tabs           ISO
  aTBCALL     = 73;         // ESC#4   Clr all h & v tabs       +++
  aTBSALL     = 74;         // ESC#5   Set default tabs         +++
  aEXTEND     = 75;         // ESC[Pn"x extended commands       +++

  aRAW        = 76;         // ESC[Pn"r Next 'Pn' chars are raw +++

Type
  //* For PRD_PRTCOMMAND */

  PIOPrtCmdReq = ^TIOPrtCmdReq;
  TIOPrtCmdReq = record
    io_Message      : TMessage;
    io_Device       : PDevice;      // (DevicePtr) device node pointer
    io_Unit         : PUnit;        // (UnitPtr) unit (driver private)
    io_Command      : UWORD;        // device command
    io_Flags        : UBYTE;
    io_Error        : SBYTE;        // error or warning num
    io_PrtCommand   : UWORD;        // printer command
    io_Parm0        : UBYTE;        // first command parameter
    io_Parm1        : UBYTE;        // second command parameter
    io_Parm2        : UBYTE;        // third command parameter
    io_Parm3        : UBYTE;        // fourth command parameter
  end;

  //* For PRD_DUMPRPORT */
  
  PIODRPReq = ^TIODRPReq;
  TIODRPReq = record
    io_Message      : TMessage;
    io_Device       : PDevice;      // (DevicePtr) device node pointer
    io_Unit         : PUnit;        // (UnitPtr) unit (driver private)
    io_Command      : UWORD;        // device command
    io_Flags        : UBYTE;
    io_Error        : SBYTE;        // error or warning num
    io_RastPort     : PRastPort;    // (RastPortPtr) raster port
    io_ColorMap     : PColorMap;    // (ColorMapPtr) color map
    {$IFDEF AROS}
    io_Modes        : UIPTR;        //* Holds a pointer for TurboPrint extensions */
    {$ELSE}
    io_Modes        : ULONG;
    {$ENDIF}
    io_SrcX         : UWORD;        // source x origin
    io_SrcY         : UWORD;        // source y origin
    io_SrcWidth     : UWORD;        // source x width
    io_SrcHeight    : UWORD;        // source x height
    io_DestCols     : SLONG;        // destination x width
    io_DestRows     : SLONG;        // destination y height
    io_Special      : UWORD;        // option flags
  end;

  //* For PRD_DUMPRPORTTAGS (V44) */

  PIODRPTagsReq = ^TIODRPTagsReq;
  TIODRPTagsReq = record
    io_Message  : TMessage;
    io_Device   : PDevice;          // device node pointer
    io_Unit     : PUnit;            // unit (driver private)
    io_Command  : UWORD;            // device command
    io_Flags    : UBYTE;
    io_Error    : SBYTE;            // error or warning num
    io_RastPort : PRastPort;        // raster port
    io_ColorMap : PColorMap;        // color map
    io_Modes    : ULONG;            // graphics viewport modes
    io_SrcX     : UWORD;            // source x origin
    io_SrcY     : UWORD;            // source y origin
    io_SrcWidth : UWORD;            // source x width
    io_SrcHeight: UWORD;            // source x height
    io_DestCols : SLONG;            // destination x width
    io_DestRows : SLONG;            // destination y height
    io_Special  : UWORD;            // option flags 
    io_TagList  : PTagItem;         // tag list with additional info
  end;


Const
  SPECIAL_MILCOLS       = $0001;    //* io_DestCols are in 1/1000" */
  SPECIAL_MILROWS       = $0002;    //* io_DestRows are in 1/1000" */
  SPECIAL_FULLCOLS      = $0004;    //* ignore io_DestCols */
  SPECIAL_FULLROWS      = $0008;    //* ignore io_DestRows */
  SPECIAL_FRACCOLS      = $0010;    //* io_DestCols is a 32-bit fraction of FULLCOLS */
  SPECIAL_FRACROWS      = $0020;    //* io_DestRows is a 32-bit fraction of FULLROWS */
  SPECIAL_CENTER        = $0040;    //* Center image on paper */
  SPECIAL_ASPECT        = $0080;    //* Correct aspect ratio */
  SPECIAL_DENSITY1      = $0100;    //* Lowest DPI */
  SPECIAL_DENSITY2      = $0200;
  SPECIAL_DENSITY3      = $0300;
  SPECIAL_DENSITY4      = $0400;
  SPECIAL_DENSITY5      = $0500;
  SPECIAL_DENSITY6      = $0600;
  SPECIAL_DENSITY7      = $0700;    //* Highest DPI */
  SPECIAL_NOFORMFEED    = $0800;    //* Don't eject paper after raster has rendered */
  SPECIAL_TRUSTME       = $1000;    //* Don't clear after raster has rendered */

  SPECIAL_NOPRINT       = $2000;    //* Don't actually print the raster */


  PDERR_NOERR           = 0;        //* No error */
  PDERR_CANCEL          = 1;        //* User cancelled the print */
  PDERR_NOTGRAPHICS     = 2;        //* Printer can't print graphics */
  PDERR_INVERTHAM       = 3;        //* obsolete */
  PDERR_BADDIMENSION    = 4;        //* Bad printing dimensions */
  PDERR_DIMENSIONOVFLOW = 5;        //* obsolete */
  PDERR_INTERNALMEMORY  = 6;        //* No memory for internal variables */
  PDERR_BUFFERMEMORY    = 7;        //* No memory for the output buffer */
  PDERR_TOOKCONTROL     = 8;        //* (internal) Driver rendered everything in Render Phase 0 */

  // V44
  PDERR_BADPREFERENCES  = 9;        //* Bad preferences */

  PDERR_LASTSTANDARD    = 31;
  PDERR_FIRSTCUSTOM     = 32;
  PDERR_LASTCUSTOM      = 126;

  SPECIAL_DENSITYMASK   = $0700;    // masks out density values
  SPECIAL_DIMENSIONSMASK= 
  ( 
    SPECIAL_MILCOLS or 
    SPECIAL_MILROWS or
    SPECIAL_FULLCOLS or 
    SPECIAL_FULLROWS or 
    SPECIAL_FRACCOLS or
    SPECIAL_FRACROWS or 
    SPECIAL_ASPECT
  );

  //* Tags for PRD_DUMPRPORTTAGS */

  DRPA_Dummy            = (TAG_USER + $60000);
  DRPA_ICCProfile       = (DRPA_Dummy + 1); // APTR
  DRPA_ICCName          = (DRPA_Dummy + 2); // STRPTR
  DRPA_NoColCorrect     = (DRPA_Dummy + 3); // LBOOL
  DRPA_SourceHook       = (DRPA_Dummy + 4); // struct Hook *
  DRPA_AspectX          = (DRPA_Dummy + 5); // ULONG
  DRPA_AspectY          = (DRPA_Dummy + 6); // ULONG

  
Type
  PDRPSourceMsg = ^TDRPSourceMsg;
  TDRPSourceMsg = record
    x       : SLONG;
    y       : SLONG;
    width   : SLONG;
    height  : SLONG;
    buf     : PULONG;   // fill this buffer with 0x00RRGGBB pixels
  end;


Const
  //* Tags for PRD_EDITPREFS */

  PPRA_Dummy        = (TAG_USER + $70000);
  PPRA_Window       = (PPRA_Dummy + 1); // struct Window *
  PPRA_Screen       = (PPRA_Dummy + 2); // struct Screen *
  PPRA_PubScreen    = (PPRA_Dummy + 3); // STRPTR


type
  //* PRD_EDITPREFS Request (V44) */

  PIOPrtPrefsReq = ^TIOPrtPrefsReq;
  TIOPrtPrefsReq = record
    io_Message  : TMessage;
    io_Device   : PDevice;      // device node pointer
    io_Unit     : PUnit;        // unit (driver private)
    io_Command  : UWORD;        // device command
    io_Flags    : UBYTE;
    io_Error    : SBYTE;        // error or warning num
    io_TagList  : PTagItem;     // requester tag list
  end;


Type
  //* PRD_SETERRHOOK Request (V44) */

  PIOPrtErrReq = ^tIOPrtErrReq;
  TIOPrtErrReq = record
    io_Message  : TMessage;
    io_Device   : PDevice;      // device node pointer
    io_Unit     : PUnit;        // unit (driver private)
    io_Command  : UWORD;        // device command
    io_Flags    : UBYTE;
    io_Error    : SBYTE;        // error or warning num
    io_Hook     : PHook;
  end;

Const
  PDHOOK_NONE   = PHook(nil);
  PDHOOK_STD    = PHook(1);
  

Const
  PDHOOK_VERSION   = 1;

Type
  PPrtErrMsg = ^TPrtErrMsg;
  TPrtErrMsg = record
    pe_Version      : ULONG;
    pe_ErrorLevel   : ULONG;
    pe_Window       : PWindow;
    pe_ES           : PEasyStruct;
    pe_IDCMP        : PULONG;
    pe_ArgList      : APTR;
  end;


Type
  //* PRIVATE: Request to change prefs temporary. DO NOT USE!!! */

  PIOPrefsReq = ^TIOPrefsReq;
  TIOPrefsReq = record
    io_Message      : TMessage;
    io_Device       : PDevice;          // device node pointer
    io_Unit         : PUnit;            // unit (driver private)
    io_Command      : UWORD;            // device command
    io_Flags        : UBYTE;
    io_Error        : SBYTE;            // error or warning num
    io_TxtPrefs     : PPrinterTxtPrefs;
    io_UnitPrefs    : PPrinterUnitPrefs;
    io_DevUnitPrefs : PPrinterDeviceUnitPrefs;
    io_GfxPrefs     : PPrinterGfxPrefs;
  end;

Implementation
 
end.
