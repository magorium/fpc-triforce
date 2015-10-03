unit datatypes;


{
  DataTypes.library
  
  Note: pictureclass.h inclusion is still a mess
  
}

{$MODE OBJFPC}
{$UNITPATH ../Trinity/}

Interface


uses 
  TriniTypes, Exec, Amigados, AGraphics, intuition, iffparse, amigaprinter, utility;


//
// global
//



//
//  datatypes.h
//

const
  ID_DTYP           = ord('D') shl 24 + ord('T')  shl 16 + ord('Y') shl 8 + ord('P');
  ID_DTHD           = ord('D') shl 24 + ord('T')  shl 16 + ord('H') shl 8 + ord('D');


Type
  PDataTypeHeader = ^TDataTypeHeader;
  TDataTypeHeader = record
    dth_Name        : STRPTR;       //* Name of the data type */
    dth_BaseName    : STRPTR;       //* Base name of the data type */ 
    dth_Pattern     : STRPTR;       //* File name match pattern */ 
    dth_Mask        : PSWORD;       //* Comparison mask (binary) */ 
    dth_GroupID     : ULONG;        //* DataType Group */ 
    dth_ID          : ULONG;        //* DataType ID (same as IFF FORM type) */ 
    dth_MaskLen     : SWORD;        //* Length of the comparison mask */ 
    dth_Pad         : SWORD;        //* Unused at present (must be 0) */ 
    dth_Flags       : UWORD;        //* Flags -- see below */ 
    dth_Priority    : UWORD;         
 end;


const
  DTHSIZE           = SizeOf(TDataTypeHeader);  // 32;

  //* Basic Types */
  DTF_TYPE_MASK     = $000F;
  DTF_BINARY        = $0000;
  DTF_ASCII         = $0001;
  DTF_IFF           = $0002;
  DTF_MISC          = $0003;

  DTF_CASE          = $0010;   //* Case is important */

  DTF_SYSTEM1       = $1000;   //* For system use only */


  //*****   Group ID and ID   ************************************************/

  //* System file -- executable, directory, library, font and so on. */
  GID_SYSTEM        = ord('s') shl 24 + ord('y')  shl 16 + ord('s') shl 8 + ord('t');
  {$IFDEF AROS}
  ID_BINARY         = ord('b') shl 24 + ord('i')  shl 16 + ord('n') shl 8 + ord('a');
  ID_EXECUTABLE     = ord('e') shl 24 + ord('x')  shl 16 + ord('e') shl 8 + ord('c');
  ID_DIRECTORY      = ord('d') shl 24 + ord('i')  shl 16 + ord('r') shl 8 + ord('e');
  ID_IFF            = ord('i') shl 24 + ord('f')  shl 16 + ord('f') shl 8 + ord(#0);
  {$ENDIF}
  //* Text, formatted or not */
  GID_TEXT          = ord('t') shl 24 + ord('e')  shl 16 + ord('x') shl 8 + ord('t');
  {$IFDEF AROS}
  ID_ASCII          = ord('a') shl 24 + ord('s')  shl 16 + ord('c') shl 8 + ord('i');
  {$ENDIF}
  
  //* Formatted text combined with graphics or other DataTypes */
  GID_DOCUMENT      = ord('d') shl 24 + ord('o')  shl 16 + ord('c') shl 8 + ord('u');

  //* Sound */
  GID_SOUND         = ord('s') shl 24 + ord('o')  shl 16 + ord('u') shl 8 + ord('n');

  //* Musical instrument */
  GID_INSTRUMENT    = ord('i') shl 24 + ord('n')  shl 16 + ord('s') shl 8 + ord('t');

  //* Musical score */
  GID_MUSIC         = ord('m') shl 24 + ord('u')  shl 16 + ord('s') shl 8 + ord('i');

  //* Picture */
  GID_PICTURE       = ord('p') shl 24 + ord('i')  shl 16 + ord('c') shl 8 + ord('t');

  //* Animated pictures */
  GID_ANIMATION     = ord('a') shl 24 + ord('s')  shl 16 + ord('c') shl 8 + ord('i');

  //* Animation with audio */
  GID_MOVIE         = ord('m') shl 24 + ord('o')  shl 16 + ord('v') shl 8 + ord('i');


  //**************************************************************************/


  ID_CODE           = ord('D') shl 24 + ord('T')  shl 16 + ord('C') shl 8 + ord('D');

Type
  PTHookContext     = ^tDTHookContext;
  TDTHookContext    = record
    dthc_SysBase        : pLibrary;
    dthc_DOSBase        : pLibrary;
    dthc_IFFParseBase   : pLibrary;
    dthc_UtilityBase    : pLibrary;

    //* File context */
    dthc_Lock           : BPTR;           
    dthc_FIB            : PFileInfoBlock; 
    dthc_FileHandle     : BPTR;             //* Pointer to file handle (may be NULL) */
    dthc_IFF            : pIFFHandle;       //* Pointer to IFFHandle (may be NULL) */
    dthc_Buffer         : STRPTR;           //* Buffer... */
    dthc_BufferLength   : ULONG;            //* ... and corresponding length */
 end;


const
  ID_TOOL           = ord('D') shl 24 + ord('T')  shl 16 + ord('T') shl 8 + ord('L'); // 1146377292;


Type
  PTool = ^tTool;
  TTool = record
    tn_Which        : UWORD;
    tn_Flags        : UWORD;    //* Flags -- see below */
    tn_Program      : STRPTR;   //* Application to use */
 end;

{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
// for unknown reason this define is missing in AROS includes.
Const
  TSIZE             = SizeOf(TTool);
{$ENDIF}

Const
  //* tn_Which defines */
  {$IFDEF AROS}
  TW_MISC           = 0;
  {$ENDIF}
  TW_INFO           = 1;
  TW_BROWSE         = 2;
  TW_EDIT           = 3;
  TW_PRINT          = 4;
  TW_MAIL           = 5;

  //* tn_Flags defines */
  TF_LAUNCH_MASK    = $000F;
  TF_SHELL          = $0001;
  TF_WORKBENCH      = $0002;
  TF_RX             = $0003;


  {$IFDEF AROS}
  //* Tags for use with FindToolNodeA(), GetToolAttrsA() and so on */
  TOOLA_Dummy       = TAG_USER;
  TOOLA_Program     = (TOOLA_Dummy + 1);
  TOOLA_Which       = (TOOLA_Dummy + 2);
  TOOLA_LaunchType  = (TOOLA_Dummy + 3);
  {$ENDIF}


  //*************************************************************************/

Const
  ID_TAGS           = ord('D') shl 24 + ord('T')  shl 16 + ord('T') shl 8 + ord('G');  // 1146377287;


Type
  PDataType = ^tDataType;
  TDataType = record
    dtn_Node1       : TNode;            //* These two nodes are for... */
    dtn_Node2       : TNode;            //* ...system use only! */
    dtn_Header      : PDataTypeHeader;
    dtn_ToolList    : TList;            //* Tool nodes */
    dtn_FunctionName: STRPTR;           //* Name of comparison routine */
    dtn_AttrList    : PTagItem;         //* Object creation tags */
    dtn_Length      : ULONG;            //* Length of the memory block */
  end;


Const
  DTNSIZE           = SizeOf(TDataType);


Type
  PToolNode = ^TToolNode;
  TToolNode = Record
    tn_Node   : TNode;
    tn_Tool   : TTool;
    tn_Length : ULONG;      //* Length of the memory block */
 end;


Const
  TNSIZE            = SizeOf(TToolNode);


const
  ID_NAME           = ord('N') shl 24 + ord('A')  shl 16 + ord('M') shl 8 + ord('E');  // 1312902469;


  //* Text ID's */
  DTERROR_UNKNOWN_DATATYPE              =  2000;
  DTERROR_COULDNT_SAVE                  =  2001;
  DTERROR_COULDNT_OPEN                  =  2002;
  DTERROR_COULDNT_SEND_MESSAGE          =  2003;

  //* new for V40 */
  DTERROR_COULDNT_OPEN_CLIPBOARD        =  2004;
  DTERROR_Reserved                      =  2005;
  DTERROR_UNKNOWN_COMPRESSION           =  2006;
  DTERROR_NOT_ENOUGH_DATA               =  2007;
  DTERROR_INVALID_DATA                  =  2008;

  DTMSG_TYPE_OFFSET                     =  2100;
  
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  //* New for V44 */
  DTERROR_NOT_AVAILABLE                 =  2009;
  {$ENDIF}



//
//  datatypesclass.h
//


Const
  DATATYPESCLASS    : PChar =  'datatypesclass';


  DTA_Dummy         =  (TAG_USER + $1000);

  //* Default TextAttr to use for text within the object (struct TextAttr *) */
  DTA_TextAttr      =  (DTA_Dummy + 10);

  //* Top vertical unit (LONG) */
  DTA_TopVert       =  (DTA_Dummy + 11);

  //* Number of visible vertical units (LONG) */
  DTA_VisibleVert   =  (DTA_Dummy + 12);

  //* Total number of vertical units */
  DTA_TotalVert     =  (DTA_Dummy + 13);

  //* Number of pixels per vertical unit (LONG) */
  DTA_VertUnit      =  (DTA_Dummy + 14);

  //* Top horizontal unit (LONG) */
  DTA_TopHoriz      =  (DTA_Dummy + 15);

  //* Number of visible horizontal units (LONG) */
  DTA_VisibleHoriz  =  (DTA_Dummy + 16);

  //* Total number of horiziontal units */              // TODO: Type missing
  DTA_TotalHoriz    =  (DTA_Dummy + 17);

  //* Number of pixels per horizontal unit (LONG) */
  DTA_HorizUnit     =  (DTA_Dummy + 18);

  //* Name of the current element within the object (UBYTE *) */
  DTA_NodeName      =  (DTA_Dummy + 19);

  //* Object's title */                                 // TODO: Type missing
  DTA_Title         =  (DTA_Dummy + 20);

  //* Pointer to a NULL terminated array of trigger methods (struct DTMethod *) */
  DTA_TriggerMethods=  (DTA_Dummy + 21);

  //* Object data (APTR) */
  DTA_Data          =  (DTA_Dummy + 22);

  //* Default font to use (struct TextFont *) */
  DTA_TextFont      =  (DTA_Dummy + 23);

  //* Pointer to an array (terminated with ~0) of methods that the object */
  //* supports (ULONG *) */
  DTA_Methods       =  (DTA_Dummy + 24);

  //* Printer error message -- numbers are defined in <devices/printer.h> (LONG) */
  DTA_PrinterStatus =  (DTA_Dummy + 25);

  //* PRIVATE! Pointer to the print process (struct Process *) */
  DTA_PrinterProc   =  (DTA_Dummy + 26);

  //* PRIVATE! Pointer to the print process (struct Process *) */
  DTA_LayoutProc    =  (DTA_Dummy + 27);

  //* Turns the application's busy pointer on and off */
  DTA_Busy          =  (DTA_Dummy + 28);

  //* Indicate that new information has been loaded into an object.   */
  //* (This is used for models that cache the DTA_TopVert-like tags.) */
  DTA_Sync          =  (DTA_Dummy + 29);

  //* Base name of the class */
  DTA_BaseName      =  (DTA_Dummy + 30);

  //* Group that the object must belong to */
  DTA_GroupID       =  (DTA_Dummy + 31);

  //* Error level */
  DTA_ErrorLevel    =  (DTA_Dummy + 32);

  //* datatypes.library error number */
  DTA_ErrorNumber   =  (DTA_Dummy + 33);

  //* Argument for datatypes.library error */
  DTA_ErrorString   =  (DTA_Dummy + 34);

  //* Name of a realtime.library conductor -- defaults to "Main" (UBYTE *) */
  DTA_Conductor     =  (DTA_Dummy + 35);

  //* Specify whether a control panel should be embedded into the object or not
  //* (for example in the animation datatype) -- defaults to TRUE (BOOL) */
  DTA_ControlPanel  =  (DTA_Dummy + 36);

  //* Should the object begin playing immediately? -- defaults to FALSE (BOOL) */
  DTA_Immediate     =  (DTA_Dummy + 37);

  //* Indicate that the object should repeat playing -- defaults to FALSE (BOOL)*/
  DTA_Repeat        =  (DTA_Dummy + 38);

  //* V44: Address of object if of type DTST_MEMORY (APTR) */
  DTA_SourceAddress =  (DTA_Dummy + 39);

  //* V44: Size of object if of type DTST_MEMORY (ULONG)*/
  DTA_SourceSize    =  (DTA_Dummy + 40);

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  { Reserved tag; DO NOT USE (V44) }
  DTA_Reserved      =  (DTA_Dummy + 41);        // TODO: Missing in AROS
  {$ENDIF}

  {$IFDEF MORPHOS}
  //*** V45 ***  
  DTA_Progressive   =  (DTA_Dummy + 60);
  DTA_CurrentLevel  =  (DTA_Dummy + 61);
  DTA_Class         =  (DTA_Dummy + 62);
  {$ENDIF}


  //* DTObject attributes */
  DTA_Name          =  (DTA_Dummy + 100);
  DTA_SourceType    =  (DTA_Dummy + 101);
  DTA_Handle        =  (DTA_Dummy + 102);
  DTA_DataType      =  (DTA_Dummy + 103);
  DTA_Domain        =  (DTA_Dummy + 104);

{$IF 0}
  //* These should not be used, and is therefore not available -- use the
  //* corresponding tags in <intuition/gadgetclass> instead */
  DTA_Left          =  (DTA_Dummy + 105);
  DTA_Top           =  (DTA_Dummy + 106);
  DTA_Width         =  (DTA_Dummy + 107);
  DTA_Height        =  (DTA_Dummy + 108);
{$ENDIF}


  DTA_ObjName       =  (DTA_Dummy + 109);
  DTA_ObjAuthor     =  (DTA_Dummy + 110);
  DTA_ObjAnnotation =  (DTA_Dummy + 111);
  DTA_ObjCopyright  =  (DTA_Dummy + 112);
  DTA_ObjVersion    =  (DTA_Dummy + 113);
  DTA_ObjectID      =  (DTA_Dummy + 114);
  DTA_UserData      =  (DTA_Dummy + 115);
  DTA_FrameInfo     =  (DTA_Dummy + 116);

{$IF 0}
  //* These should not be used, and is therefore not available -- use the
  //* corresponding tags in <intuition/gadgetclass> instead */
  DTA_RelRight      =  (DTA_Dummy + 117);
  DTA_RelBottom     =  (DTA_Dummy + 118);
  DTA_RelWidth      =  (DTA_Dummy + 119);
  DTA_RelHeight     =  (DTA_Dummy + 120);
{$ENDIF}

  DTA_SelectDomain  =  (DTA_Dummy + 121);
  DTA_TotalPVert    =  (DTA_Dummy + 122);
  DTA_TotalPHoriz   =  (DTA_Dummy + 123);
  DTA_NominalVert   =  (DTA_Dummy + 124);
  DTA_NominalHoriz  =  (DTA_Dummy + 125);

  //* Printing attributes */
  
  //* Destination x width (LONG) */
  DTA_DestCols      =  (DTA_Dummy + 400);

  //* Destination y height (LONG) */
  DTA_DestRows      =  (DTA_Dummy + 401);

  //* Option flags (UWORD) */
  DTA_Special       =  (DTA_Dummy + 402);

  //* V40: RastPort used when printing (struct RastPort *) */
  DTA_RastPort      =  (DTA_Dummy + 403);

  //* V40: Pointer to base name for ARexx port (STRPTR) */
  DTA_ARexxPortName =  (DTA_Dummy + 404);


  //**************************************************************************/

  DTST_RAM          =  1;
  DTST_FILE         =  2;
  DTST_CLIPBOARD    =  3;
  DTST_HOTLINK      =  4;
  DTST_MEMORY       =  5;   //* V44 */

  //* This structure is attached to the Gadget.SpecialInfo field of the gadget.
  //* Use Get/Set calls to access it. */
Type
  PDTSpecialInfo = ^TDTSpecialInfo;
  TDTSpecialInfo = record
    si_Lock         : tSignalSemaphore;
    si_Flags        : ULONG;

    si_TopVert      : SLONG;    //* Top row (in units) */
    si_VisVert      : SLONG;    //* Number of visible rows (in units) */
    si_TotVert      : SLONG;    //* Total number of rows (in units) */
    si_OTopVert     : SLONG;    //* Previous top (in units) */
    si_VertUnit     : SLONG;    //* Number of pixels in vertical unit */

    si_TopHoriz     : SLONG;    //* Top column (in units) */
    si_VisHoriz     : SLONG;    //* Number of visible columns (in units) */
    si_TotHoriz     : SLONG;    //* Total number of columns (in units) */
    si_OTopHoriz    : SLONG;    //* Previous top (in units) */
    si_HorizUnit    : SLONG;    //* Number of pixels in horizontal unit */
 end;


const
  DTSIF_LAYOUT      =  (1 shl 0);   //* Object is in layout processing */
  DTSIF_NEWSIZE     =  (1 shl 1);   //* Object needs to be layed out */
  DTSIF_DRAGGING    =  (1 shl 2);
  DTSIF_DRAGSELECT  =  (1 shl 3);
  DTSIF_HIGHLIGHT   =  (1 shl 4);
  DTSIF_PRINTING    =  (1 shl 5);   //* Object is being printed */
  DTSIF_LAYOUTPROC  =  (1 shl 6);   //* Object is in layout process */


Type
  PDTMethod = ^TDTMethod;
  TDTMethod = record
    dtm_Label       : STRPTR;   // STACKED
    dtm_Command     : STRPTR;   // STACKED
    dtm_Method      : ULONG;    // STACKED
  end;


Const
  DTM_Dummy             =  ($600);

  //* Get the environment an object requires */
  DTM_FRAMEBOX          =  ($601);

  //* Same as GM_LAYOUT except guaranteed to be on a process already */
  DTM_PROCLAYOUT        =  ($602);

  //* Layout that is occurring on a process */
  DTM_ASYNCLAYOUT       =  ($603);

  //* When RemoveDTObject() is called */
  DTM_REMOVEDTOBJECT    =  ($604);

  DTM_SELECT            =  ($605);
  DTM_CLEARSELECTED     =  ($606);

  DTM_COPY              =  ($607);
  DTM_PRINT             =  ($608);
  DTM_ABORTPRINT        =  ($609);

  DTM_NEWMEMBER         =  ($610);
  DTM_DISPOSEMEMBER     =  ($611);

  DTM_GOTO              =  ($630);
  DTM_TRIGGER           =  ($631);

  DTM_OBTAINDRAWINFO    =  ($640);
  DTM_DRAW              =  ($641);
  DTM_RELEASEDRAWINFO   =  ($642);

  DTM_WRITE             =  ($650);

Type
  PFrameInfo = ^tFrameInfo;
  TFrameInfo = record
    fri_PropertyFlags   : ULONG;    //* DisplayInfo (graphics/displayinfo.h) */
    fri_Resolution      : TPoint;   //* DisplayInfo */

    fri_RedBits         : UBYTE;
    fri_GreenBits       : UBYTE;
    fri_BlueBits        : UBYTE;

    fri_Dimensions      : 
    record
      Width             : ULONG;
      Height            : ULONG;
      Depth             : ULONG;
    end;

    fri_Screen          : PScreen;
    fri_ColorMap        : PColorMap;

    fri_Flags           : ULONG;    //* See below */
  end;


Const
  FIF_SCALABLE      = $1;
  FIF_SCROLLABLE    = $2;
  FIF_REMAPPABLE    = $4;


  //* DTM_REMOVEDTOBJECT, DTM_CLEARSELECTED, DTM_COPY, DTM_ABORTPRINT */
Type
  PdtGeneral = ^TdtGeneral;
  TdtGeneral = record
    MethodID        : ULONG;
    dtg_GInfo       : PGadgetInfo;
  end;

  //* DTM_SELECT */
  PdtSelect = ^TdtSelect;
  TdtSelect = record
    MethodID        : ULONG;
    dts_GInfo       : pGadgetInfo;
    dts_Select      : TRectangle;
 end;

  //* DTM_FRAMEBOX */
  PdtFrameBox = ^TdtFrameBox;
  TdtFrameBox = record
    MethodID            : ULONG;
    dtf_GInfo           : PGadgetInfo;
    dtf_ContentsInfo    : PFrameInfo;
    dtf_FrameInfo       : PFrameInfo;
    dtf_SizeFrameInfo   : ULONG;
    dtf_FrameFlags      : ULONG;
  end;


{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
Const
  FRAME_SPECIFY     =   (1 shl 0);  //* Make do with the dimensions of FrameBox provided. */
{$ENDIF}


Type
  //* DTM_GOTO */
  PdtGoto = ^TdtGoto;
  TdtGoto = record
    MethodID        : ULONG;
    dtg_GInfo       : PGadgetInfo;      
    dtg_NodeName    : STRPTR;           // Node to goto
    dtg_AttrList    : PTagItem;         
  end;

  //* DTM_TRIGGER */
  PdtTrigger = ^TdtTrigger;
  TdtTrigger = record
    MethodID        : ULONG;
    dtt_GInfo       : PGadgetInfo;
    dtt_Function    : ULONG;
    dtt_Data        : APTR;
  end;


Const
  STMF_METHOD_MASK      = $0000ffff;
  STMF_DATA_MASK        = $00ff0000;
  STMF_RESERVED_MASK    = $ff000000;

  STMD_VOID             = $00010000;
  STMD_ULONG            = $00020000;
  STMD_STRPTR           = $00030000;
  STMD_TAGLIST          = $00040000;

  {$IFDEF MORPHOS}
  STM_END               =  0;
  {$ENDIF}
  {$IF DEFINED(AROS) or DEFINED(MORPHOS)}
  STM_DONE              =  0;
  {$ENDIF}
  STM_PAUSE             =  1;
  STM_PLAY              =  2;
  STM_CONTENTS          =  3;
  STM_INDEX             =  4;
  STM_RETRACE           =  5;
  STM_BROWSE_PREV       =  6;
  STM_BROWSE_NEXT       =  7;

  STM_NEXT_FIELD        =  8;
  STM_PREV_FIELD        =  9;
  STM_ACTIVATE_FIELD    = 10;

  STM_COMMAND           = 11;

  //* New for V40 */
  STM_REWIND            = 12;
  STM_FASTFORWARD       = 13;
  STM_STOP              = 14;
  STM_RESUME            = 15;
  STM_LOCATE            = 16;

  {$IFDEF MORPHOS}
  STM_HELP              = 17;  
  {$ENDIF}
  {$IFDEF AROS}
  //* 17 is reserved for help */
  {$ENDIF}
  {$IF DEFINED(AROS) or DEFINED(MORPHOS)}
  STM_SEARCH            = 18;
  STM_SEARCH_NEXT       = 19;
  STM_SEARCH_PREV       = 20;
  
  STM_USER              =100;
  {$ENDIF}


Type
  //* Printer IO request */
  PprinterIO = ^TprinterIO;
  TprinterIO = record
     ios    : TIOStdReq;
     iodrp  : TIODRPReq;
     iopc   : TIOPrtCmdReq;
  end;


  //* DTM_PRINT */
  PdtPrint = ^TdtPrint;
  TdtPrint = record
    MethodID        : ULONG;
    dtp_GInfo       : PGadgetInfo;
    dtp_PIO         : PprinterIO;
    dtp_AttrList    : PTagItem;
  end;

  //* DTM_DRAW */
  PdtDraw = ^TdtDraw;
  TdtDraw = record
    MethodID        : ULONG;
    dtd_RPort       : PRastPort;
    dtd_Left        : SLONG;
    dtd_Top         : SLONG;
    dtd_Width       : SLONG;
    dtd_Height      : SLONG;
    dtd_TopHoriz    : SLONG;
    dtd_TopVert     : SLONG;
    dtd_AttrList    : PTagItem;
  end;

  //* DTM_RELEASERAWINFO */
  PdtReleaseDrawInfo = ^TdtReleaseDrawInfo;
  TdtReleaseDrawInfo = record
    MethodID        : ULONG;
    dtr_Handle      : APTR;    
  end;

  //* DTM_WRITE */
  PdtWrite = ^TdtWrite;
  TdtWrite = record
    MethodID        : ULONG;
    dtw_GInfo       : PGadgetInfo;     
    dtw_FileHandle  : BPTR;     
    dtw_Mode        : ULONG;
    dtw_AttrList    : PTagItem;        
  end;


Const
  DTWM_IFF          = 0;    //* Save data as IFF data */
  DTWM_RAW          = 1;    //* Save data as local data format */



//
//  pictureclass.h
//
// Note: in AROS v44 support is disabled by default, it's enabled here.
//       In short: it's a mess.

Const
  PICTUREDTCLASS    : PChar =  'picture.datatype';


Const
  //* Picture attributes */
  PDTA_ModeID           = (DTA_Dummy + 200);
  PDTA_BitMapHeader     = (DTA_Dummy + 201);
  PDTA_BitMap           = (DTA_Dummy + 202);
  PDTA_ColorRegisters   = (DTA_Dummy + 203);
  PDTA_CRegs            = (DTA_Dummy + 204);
  PDTA_GRegs            = (DTA_Dummy + 205);
  PDTA_ColorTable       = (DTA_Dummy + 206);
  PDTA_ColorTable2      = (DTA_Dummy + 207);
  PDTA_Allocated        = (DTA_Dummy + 208);
  PDTA_NumColors        = (DTA_Dummy + 209);
  PDTA_NumAlloc         = (DTA_Dummy + 210);
  PDTA_Remap            = (DTA_Dummy + 211);
  PDTA_Screen           = (DTA_Dummy + 212);
  PDTA_FreeSourceBitMap = (DTA_Dummy + 213);
  PDTA_Grab             = (DTA_Dummy + 214);
  PDTA_DestBitMap       = (DTA_Dummy + 215);
  PDTA_ClassBitMap      = (DTA_Dummy + 216);
  PDTA_NumSparse        = (DTA_Dummy + 217);
  PDTA_SparseTable      = (DTA_Dummy + 218);

  // V44
  PDTA_WhichPicture     = (DTA_Dummy + 219);
  PDTA_GetNumPictures   = (DTA_Dummy + 220);
  PDTA_MaxDitherPens    = (DTA_Dummy + 221);
  PDTA_DitherQuality    = (DTA_Dummy + 222);
  PDTA_AllocatedPens    = (DTA_Dummy + 223);

  // V45

  PDTA_ScaleQuality     = (DTA_Dummy + 224);

  {$IFDEF AROS}
  PDTA_DelayRead        = (DTA_Dummy + 225);
  PDTA_DelayedRead      = (DTA_Dummy + 226);
  {$ENDIF}

  PDTANUMPICTURES_Unknown = (0);

  // V43 attribute extensions

  PDTA_SourceMode       = (DTA_Dummy + 250);  //* Set the interface mode for the sub datatype. See below. */
  PDTA_DestMode         = (DTA_Dummy + 251);  //* Set the interface mode for the app datatype. See below. */
  {$IFDEF MORHPOS}
  PDTA_PixelFormat      = (DTA_Dummy + 252);
  PDTA_TransRemapPen    = (DTA_Dummy + 253);
  PDTA_NumPixMapDir     = (DTA_Dummy + 254);
  {$ENDIF}
  PDTA_UseFriendBitMap  = (DTA_Dummy + 255);  //* Make the allocated bitmap be a "friend" bitmap (BOOL) */
  {$IFDEF MORHPOS}  
  PDTA_AlphaChannel     = (DTA_Dummy + 256);
  PDTA_MultiRemap       = (DTA_Dummy + 257);
  PDTA_MaskPlane        = (DTA_Dummy + 258);
  PDTA_Displayable      = (DTA_Dummy + 259);    //* defaults to TRUE */
  {$ENDIF}

  //* Interface modes */
  PMODE_V42 = (0);      //* Mode used for backward compatibility */
  PMODE_V43 = (1);      //* Use the new features */


  // V43 methods extensions
  PDTM_Dummy            = (DTM_Dummy + $60);
  PDTM_WRITEPIXELARRAY  = (PDTM_Dummy + 0);
  PDTM_READPIXELARRAY   = (PDTM_Dummy + 1);
  {$IFDEF MORPHOS}
  PDTM_CREATEPIXMAPDIR  = (PDTM_Dummy + 2);
  PDTM_FIRSTPIXMAPDIR   = (PDTM_Dummy + 3);
  PDTM_NEXTPIXMAPDIR    = (PDTM_Dummy + 4);
  PDTM_PREVPIXMAPDIR    = (PDTM_Dummy + 5);
  PDTM_BESTPIXMAPDIR    = (PDTM_Dummy + 6);
  {$ENDIF}


Type
  PpdtBlitPixelArray = ^TpdtBlitPixelArray;
  TpdtBlitPixelArray = record
    MethodID            : ULONG;
    pbpa_PixelData      : APTR;
    pbpa_PixelFormat    : ULONG;
    pbpa_PixelArrayMod  : ULONG;
    pbpa_Left           : ULONG;
    pbpa_Top            : ULONG;
    pbpa_Width          : ULONG;
    pbpa_Height         : ULONG;
  end;


Const
  // pixel formats
  PBPAFMT_RGB       = 0;
  PBPAFMT_RGBA      = 1;
  PBPAFMT_ARGB      = 2;
  PBPAFMT_LUT8      = 3;
  PBPAFMT_GREY8     = 4;

  // V45 methods extensions
  // TODO: How does this compute with PDTM_CREATEPIXMAPDIR from MorphOS ?
  PDTM_SCALE        = (PDTM_Dummy + 2);


{$IF DEFINED(AROS) or DEFINED(MORPHOS)}
Type
  PpdtScale = ^TpdtScale;
  TpdtScale = record
    MethodID            : ULONG;
    ps_NewWidth         : ULONG;
    ps_NewHeight        : ULONG;
    ps_Flags            : ULONG;
  end;
{$ENDIF}

{$IFDEF AROS}
Const
  PScale_KeepAspect     = $10;  //* Keep aspect ratio when scaling, fit inside given x,y coordinates */
{$ENDIF}


Type
  PBitMapHeader = ^TBitMapHeader;
  TBitMapHeader = record
    bmh_Width       : UWORD;
    bmh_Height      : UWORD;
    bmh_Left        : SWORD;
    bmh_Top         : SWORD;
    bmh_Depth       : UBYTE;
    bmh_Masking     : UBYTE;
    bmh_Compression : UBYTE;
    bmh_Pad         : UBYTE;
    bmh_Transparent : UWORD;
    bmh_XAspect     : UBYTE;
    bmh_YAspect     : UBYTE;
    bmh_PageWidth   : SWORD;
    bmh_PageHeight  : SWORD;
  end;

Const
  // Masking techniques
  mskNone                = 0;
  mskHasMask             = 1;
  mskHasTransparentColor = 2;
  mskLasso               = 3;
  mskHasAlpha            = 4;

  // Compression techniques
  cmpNone                = 0;
  cmpByteRun1            = 1;
  cmpByteRun2            = 2;


Type
  PColorRegister = ^TColorRegister;
  TColorRegister = record
    red, green, blue : UBYTE;
  end;


const
  // IFF types that may be in pictures
  ID_ILBM           = ord('I') shl 24 + ord('L')  shl 16 + ord('B') shl 8 + ord('M');
  ID_BMHD           = ord('B') shl 24 + ord('M')  shl 16 + ord('H') shl 8 + ord('D');
  ID_BODY           = ord('B') shl 24 + ord('O')  shl 16 + ord('D') shl 8 + ord('Y');
  ID_CMAP           = ord('C') shl 24 + ord('M')  shl 16 + ord('A') shl 8 + ord('P');
  ID_CRNG           = ord('C') shl 24 + ord('R')  shl 16 + ord('N') shl 8 + ord('G');
  ID_GRAB           = ord('G') shl 24 + ord('R')  shl 16 + ord('A') shl 8 + ord('B');
  ID_SPRT           = ord('S') shl 24 + ord('P')  shl 16 + ord('R') shl 8 + ord('T');
  ID_DEST           = ord('D') shl 24 + ord('E')  shl 16 + ord('S') shl 8 + ord('T');
  ID_CAMG           = ord('C') shl 24 + ord('A')  shl 16 + ord('M') shl 8 + ord('G');



  (*
  *  Support for the V44 picture.datatype
  *
  *  It is not clear, if AROS should support AmigaOS3.5 .
  *
  *  But if you want V44-support define DT_V44_SUPPORT
  *
  *  Joerg Dietrich
  *)
(*
{$IFDEF DT_V44_SUPPORT}
  PMODE_V42         = (0);
  PMODE_V43         = (1);

  PDTANUMPICTURES_Unknown = (0);


  PDTA_WhichPicture     = (DTA_Dummy + 219);
  PDTA_GetNumPictures   = (DTA_Dummy + 220);
  PDTA_MaxDitherPens    = (DTA_Dummy + 221);
  PDTA_DitherQuality    = (DTA_Dummy + 222);
  PDTA_AllocatedPens    = (DTA_Dummy + 223);
  PDTA_ScaleQuality     = (DTA_Dummy + 224);
  PDTA_DelayRead        = (DTA_Dummy + 225);
  PDTA_DelayedRead      = (DTA_Dummy + 226);

  PDTA_SourceMode       = (DTA_Dummy + 250);
  PDTA_DestMode         = (DTA_Dummy + 251);
  PDTA_UseFriendBitMap  = (DTA_Dummy + 255);
  PDTA_MaskPlane        = (DTA_Dummy + 258);  

  PDTM_Dummy            = (DTM_Dummy + $60);
  PDTM_WRITEPIXELARRAY  = (PDTM_Dummy + 0);
  PDTM_READPIXELARRAY   = (PDTM_Dummy + 1);
  PDTM_SCALE            = (PDTM_Dummy + 2);


Type
  PpdtBlitPixelArray = ^TpdtBlitPixelArray;
  TpdtBlitPixelArray = record
    MethodID            : ULONG;
    pbpa_PixelData      : APTR;
    pbpa_PixelFormat    : ULONG;
    pbpa_PixelArrayMod  : ULONG;
    pbpa_Left           : ULONG;
    pbpa_Top            : ULONG;
    pbpa_Width          : ULONG;
    pbpa_Height         : ULONG;
  end;

  {$IFDEF AROS}
  PpdtScale = ^TpdtScale;
  TpdtScale = record
    MethodID            : ULONG;
    ps_NewWidth         : ULONG;
    ps_NewHeight        : ULONG;
    ps_Flags            : ULONG;
  end;
  {$ENDIF}

Const
  //* Flags for ps_Flags, for AROS only */
  {$IFDEF AROS}
  PScale_KeepAspect     = $10;  //* Keep aspect ratio when scaling, fit inside given x,y coordinates */
  {$ENDIF}

  PBPAFMT_RGB       = 0;
  PBPAFMT_RGBA      = 1;
  PBPAFMT_ARGB      = 2;
  PBPAFMT_LUT8      = 3;
  PBPAFMT_GREY8     = 4;
{$ENDIF DT_V44_SUPPORT}
*)



//
//  pictureclassext.h
//  NOTE: empty for AROS and AMIGA
//

{$IFDEF MORPHOS}
Const
  DTM_WRITEPIXELARRAY  = PDTM_WRITEPIXELARRAY;
  DTM_READPIXELARRAY   = PDTM_READPIXELARRAY;
  DTM_CREATEPIXMAPDIR  = PDTM_CREATEPIXMAPDIR;
  DTM_FIRSTPIXMAPDIR   = PDTM_FIRSTPIXMAPDIR;
  DTM_NEXTPIXMAPDIR    = PDTM_NEXTPIXMAPDIR;
  DTM_PREVPIXMAPDIR    = PDTM_PREVPIXMAPDIR;
  DTM_BESTPIXMAPDIR    = PDTM_BESTPIXMAPDIR;


Type
  //* Identical to struct pdtBlitPixelArray, please use that instead */
  PgpBlitPixelArray = ^TgpBlitPixelArray;
  TgpBlitPixelArray = record
    MethodID        : ULONG;
    PixelArray      : PUBYTE;
    PixelArrayMode  : ULONG;
    PixelArrayMod   : ULONG;
    LeftEdge        : ULONG;
    TopEdge         : ULONG;
    Width           : ULONG;
    Height          : ULONG;
  end;


Const
  MODE_V42  = PMODE_V42;
  MODE_V43  = PMODE_V43;
{$ENDIF}



//
//  soundclass.h
//  Note: MorphOS SDK places all in soundclass.h while aros places some
//  declarations inside soundclassext.h (see below). 
//

Const
  SOUNDDTCLASS          : PChar =  'sound.datatype';

{$IFDEF MORPHOS}
Const
  //* Sound streaming methods */

  SDTM_Dummy            = (DTM_Dummy + $200);

  SDTM_FETCH            = (SDTM_Dummy + 1);
  SDTM_APPEND           = (SDTM_Dummy + 2);
  SDTM_REWIND           = (SDTM_Dummy + 3);


Type
  //* message structure for streaming methods */
  PsdtFetch = ^TsdtFetch;
  TsdtFetch = record
	MethodID            : ULONG;    //* SDTM_FETCH */
	sdtf_Buffer         : APTR;     //* pointer to application provided buffer */
	sdtf_Length         : ULONG;    //* length of the buffer in bytes*/
	sdtf_Actual         : ULONG;    //* actual length of fetched data in bytes */
	sdtf_EndOfStream    : ULONG;    //* true for end of stream */
  end;

  PsdtAppend = ^TsdtAppend;
  TsdtAppend = record
	MethodID            : ULONG;    //* SDTM_APPEND */
	sdta_Handle         : APTR;     //* DOS file handle data will be written to */
	sdta_Buffer         : APTR;     //* pointer to data provided by application */
	sdta_Length         : ULONG;    //* length of the data in bytes*/
	sdta_EndOfStream    : ULONG;    //* set to true for end of stream */
  end;
{$ENDIF}


Const
  //* Tags */
  SDTA_Dummy            = (DTA_Dummy + 500);
  SDTA_VoiceHeader      = (SDTA_Dummy + 1);
  SDTA_Sample           = (SDTA_Dummy + 2);
  SDTA_SampleLength     = (SDTA_Dummy + 3);
  SDTA_Period           = (SDTA_Dummy + 4);
  SDTA_Volume           = (SDTA_Dummy + 5);
  SDTA_Cycles           = (SDTA_Dummy + 6);
  SDTA_SignalTask       = (SDTA_Dummy + 7);
  SDTA_SignalBit        = (SDTA_Dummy + 8);
  SDTA_SignalBitMask    = SDTA_SignalBit;
  SDTA_Continuous       = (SDTA_Dummy + 9);

  //* New in V44 */

  SDTA_SignalBitNumber  = (SDTA_Dummy + 10);

  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  SDTA_SamplesPerSec    = (SDTA_Dummy + 11);
  SDTA_ReplayPeriod     = (SDTA_Dummy + 12);
  SDTA_LeftSample       = (SDTA_Dummy + 13);
  SDTA_RightSample      = (SDTA_Dummy + 14);
  SDTA_Pan              = (SDTA_Dummy + 15);
  SDTA_FreeSampleData   = (SDTA_Dummy + 16);
  SDTA_SyncSampleChange = (SDTA_Dummy + 17);
  {$ENDIF}
  {$IFDEF MORPHOS}
  // These are really not define in MorphOS SDK
  // but _are_ used in animation class, so we
  // define them here explicetly using ifdefs.
  SDTA_SamplesPerSec    = (SDTA_Dummy + 11);
  SDTA_ReplayPeriod     = (SDTA_Dummy + 12);
  SDTA_LeftSample       = (SDTA_Dummy + 13);
  SDTA_RightSample      = (SDTA_Dummy + 14);
  SDTA_Pan              = (SDTA_Dummy + 15);
  SDTA_FreeSampleData   = (SDTA_Dummy + 16);
  SDTA_SyncSampleChange = (SDTA_Dummy + 17);
  {$ENDIF}

  {$IFDEF MORPHOS}
  SDTA_Panning          = (SDTA_Dummy + 31);
  SDTA_Frequency        = (SDTA_Dummy + 32);
  SDTA_Mode             = (SDTA_Dummy + 33);
  SDTA_PreciseVolume    = (SDTA_Dummy + 34);
  SDTA_Duration         = (SDTA_Dummy + 35);
  SDTA_SampleType       = (SDTA_Dummy + 36);
  SDTA_Codec            = (SDTA_Dummy + 37); 
  {$ENDIF}

  {$IFDEF MORPHOS}
  //* SDTA_Mode sound.datatype API modes */
  SDTA_Mode_Compatible    = 0;
  SDTA_Mode_Extended      = 1;
  {$ENDIF}


  //* Data compression methods for 8svx / 16sv */
  CMP_NONE          = 0;
  CMP_FIBDELTA      = 1;
  {$IFDEF MORHPOS}
  CMP_EXPDELTA      = 2;  
  {$ENDIF}

  {$IFDEF MORHPOS}
  //* Supported data compression methods for WAVE */
  CMP_WAVE_PCM              = 1;
  CMP_WAVE_MICROSOFT_ADPCM  = 2;
  CMP_WAVE_FLOAT32          = 3;
  CMP_WAVE_ALAW             = 6;
  CMP_WAVE_ULAW             = 7;
  {$ENDIF}

  //* Unity = Fixed 1.0 = maximum volume */
  Unity             = LongWord($10000);


  {$IFDEF MORPHOS}
  //* definitions for SDTA_SampleType (all types are signed) */

  SDTST_M8S   = $00010001;   //* 8bit mono sample (default) */
  SDTST_S8S   = $00020001;   //* 8bit stereo sample (samplewise left/right) */
  SDTST_M16S  = $00010002;   //* same as SDTST_M8S but 16bit */
  SDTST_S16S  = $00020002;   //* same as SDTST_S8S but 16bit */

  //* How to construct SDTA_SampleValue for any number of channels and sample   */
  //* size? The high word of sample type contains number of channels. The low   */
  //* word contains size of single sample (not frame) in bytes.                 */
  //* example: 5-channel 48-bit sound sample has sample type of 0x00050006.     */
  ///* Some common types are defined above.                                      */
  {$ENDIF}

  {$IFDEF MORPHOS}
  //* some handy macros */
  //#define SDTM_CHANNELS(SampleType)        (SampleType >> 16)
  //#define SDTM_BYTESPERSAMPLE(SampleType)  (SampleType & 0xFFFF)
  //#define SDTM_BYTESPERPOINT(SampleType)   (SDTM_CHANNELS(SampleType) * SDTM_BYTESPERSAMPLE(SampleType))  
  {$ENDIF}



Type
  PVoiceHeader = ^TVoiceHeader;
  TVoiceHeader = record
    vh_OneShotHiSamples : ULONG;
    vh_RepeatHiSamples  : ULONG;
    vh_SamplesPerHiCycle: ULONG;
    vh_SamplesPerSec    : UWORD;
    vh_Octaves          : UBYTE;
    vh_Compression      : UBYTE;
    vh_Volume           : ULONG;
  end;

{$IF DEFINED(AMIGA) or DEFINED(AROS)}  
const
  //* Channel allocation */
  SAMPLETYPE_Left      = (2);
  SAMPLETYPE_Right     = (4);
  SAMPLETYPE_Stereo    = (6);
{$ENDIF}

{$IFDEF MORPHOS}
const
  SVX_LEFT    = (2);
  SVX_RIGHT   = (4);
  SVX_STEREO  = (6);
{$ENDIF}

{$IF DEFINED(AMIGA) or DEFINED(AROS)}  
Type
  TSampleType           =   SLONG;
{$ENDIF}

Const
  //* IFF types */
  ID_8SVX = ord('8') shl 24 + ord('S')  shl 16 + ord('V') shl 8 + ord('X');
  ID_VHDR = ord('V') shl 24 + ord('H')  shl 16 + ord('D') shl 8 + ord('R');
  ID_CHAN = ord('C') shl 24 + ord('H')  shl 16 + ord('A') shl 8 + ord('N');
  // already defined earlier
  // ID_BODY         = ord('B') shl 24 + ord('O')  shl 16 + ord('D') shl 8 + ord('Y'); // 1112491097;
  {$IFDEF MORPHOS}
  ID_16SV  = ord('1') shl 24 + ord('6')  shl 16 + ord('S') shl 8 + ord('V');
  //ID_CHAN  = ord('C') shl 24 + ord('H')  shl 16 + ord('A') shl 8 + ord('N');
  //ID_NAME  = ord('N') shl 24 + ord('A')  shl 16 + ord('M') shl 8 + ord('E');
  ID_AUTH  = ord('A') shl 24 + ord('U')  shl 16 + ord('T') shl 8 + ord('H');
  ID_ANNO  = ord('A') shl 24 + ord('N')  shl 16 + ord('N') shl 8 + ord('O');
  ID_COPY  = ord('(') shl 24 + ord('c')  shl 16 + ord(')') shl 8 + ord(' ');
  {$ENDIF}



{$IFDEF AROS}
//
//  soundclassext.h
//
Const
  SDTA_SampleType   = (SDTA_Dummy + 30);
  SDTA_Panning      = (SDTA_Dummy + 31);
  SDTA_Frequency    = (SDTA_Dummy + 32);

  SDTST_M8S         = 0;
  SDTST_S8S         = 1;
  SDTST_M16S        = 2;
  SDTST_S16S        = 3;

  (*
  TODO: macros
  25 #define SDTM_ISSTEREO(sampletype)   ((sampletype) & 1)
  26 #define SDTM_CHANNELS(sampletype)   (1 + SDTM_ISSTEREO(sampletype))
  27 #define SDTM_BYTESPERSAMPLE(x)      (((x) >= SDTST_M16S ) ? 2 : 1)
  28 #define SDTM_BYTESPERPOINT(x)       (SDTM_CHANNELS(x) * SDTM_BYTESPERSAMPLE(x))
  *)
{$ENDIF}



//
//  textclass.h
//

Const
  TEXTDTCLASS           : PChar =  'text.datatype';

  //* attributes */

  TDTA_Buffer           = (DTA_Dummy + 300);
  TDTA_BufferLen        = (DTA_Dummy + 301);
  TDTA_LineList         = (DTA_Dummy + 302);
  TDTA_WordSelect       = (DTA_Dummy + 303);
  TDTA_WordDelim        = (DTA_Dummy + 304);
  TDTA_WordWrap         = (DTA_Dummy + 305);


Type
  //* There is one line structure for every line of text in the document. */
  PLine = ^TLine;
  TLine = record
    ln_Link             : tMinNode;     // to link the lines together
    ln_Text             : STRPTR;       // pointer to the text for this line
    ln_TextLen          : ULONG;        // the character length of the text for this line
    ln_XOffset          : UWORD;        // where in the line the text starts
    ln_YOffset          : UWORD;        // line the text is on
    ln_Width            : UWORD;        // Width of line in pixels
    ln_Height           : UWORD;        // Height of line in pixels
    ln_Flags            : UWORD;        // info on the line
    ln_FgPen            : SBYTE;        // foreground pen
    ln_BgPen            : SBYTE;        // background pen
    ln_Style            : ULONG;        // Font style
    ln_Data             : APTR;         // Link data...
  end;


const
  //* ln_Flags */

  LNF_LF        = (1 shl 0);    // Line feed
  LNF_LINK      = (1 shl 1);    // link
  LNF_OBJECT    = (1 shl 2);    // ln_Data is pointer to DataTypes object
  LNF_SELECTED  = (1 shl 3);    // object is slected

  ID_FTXT       = ord('F') shl 24 + ord('T')  shl 16 + ord('X') shl 8 + ord('T'); // 1179932756;
  ID_CHRS       = ord('C') shl 24 + ord('H')  shl 16 + ord('R') shl 8 + ord('S'); // 1128813139;
  {$IFDEF MORHPOS}
  //* Encoded with UTF8                      */
  ID_UTF8       = ord('U') shl 24 + ord('T')  shl 16 + ord('F') shl 8 + ord('8'); 
  
  {* ID_CHRS and ID_UTF8 chunks can be used at the same time. Preferably applications
   * dealing with UTF8 should still write a compatible ID_CHRS chunk for legacy
   * compatibility.
   *}
  {$ENDIF}



//
//  animationclass.h
//

Const

  ANIMATIONDTCLASS      : PChar =       'animation.datatype';

  //* Tags */
  ADTA_Dummy            =  (DTA_Dummy + 600);
  ADTA_ModeID           =  PDTA_ModeID;
  ADTA_KeyFrame         =  PDTA_BitMap;
  ADTA_ColorRegisters   =  PDTA_ColorRegisters;
  ADTA_CRegs            =  PDTA_CRegs;
  ADTA_GRegs            =  PDTA_GRegs;
  ADTA_ColorTable       =  PDTA_ColorTable;
  ADTA_ColorTable2      =  PDTA_ColorTable2;
  ADTA_Allocated        =  PDTA_Allocated;
  ADTA_NumColors        =  PDTA_NumColors;
  ADTA_NumAlloc         =  PDTA_NumAlloc;
  ADTA_Remap            =  PDTA_Remap;
  ADTA_Screen           =  PDTA_Screen;
  ADTA_Width            =  (ADTA_Dummy + 1);
  ADTA_Height           =  (ADTA_Dummy + 2);
  ADTA_Depth            =  (ADTA_Dummy + 3);
  ADTA_Frames           =  (ADTA_Dummy + 4);
  ADTA_Frame            =  (ADTA_Dummy + 5);
  ADTA_FramesPerSecond  =  (ADTA_Dummy + 6);
  ADTA_FrameIncrement   =  (ADTA_Dummy + 7);

  ADTA_Sample           =  SDTA_Sample;
  ADTA_SampleLength     =  SDTA_SampleLength;
  ADTA_Period           =  SDTA_Period;
  ADTA_Volume           =  SDTA_Volume;
  ADTA_Cycles           =  SDTA_Cycles;

  //* New in V44 */
  // NOTE: nowhere in MorpOS SDK are SDTA_xxx constants below defined.
  //       i fixed it above.
  ADTA_PreloadFrameCount= (ADTA_Dummy + 8);     { (V44) }
  ADTA_LeftSample       =  SDTA_LeftSample;     { (V44) }
  ADTA_RightSample      =  SDTA_RightSample;    { (V44) }
  ADTA_SamplesPerSec    =  SDTA_SamplesPerSec;  { (V44) }


  //* IFF ANIM chunks */
  ID_ANIM   = ord('A') shl 24 + ord('N')  shl 16 + ord('I') shl 8 + ord('M'); // 1095649613;
  ID_ANHD   = ord('A') shl 24 + ord('N')  shl 16 + ord('H') shl 8 + ord('D'); // 1095649348;
  ID_DLTA   = ord('D') shl 24 + ord('L')  shl 16 + ord('T') shl 8 + ord('A'); // 1145852993;


Type
  PAnimHeader = ^TAnimHeader;
  TAnimHeader = record
    ah_Operation    : UBYTE;
    ah_Mask         : UBYTE;
    ah_Height       : UWORD;
    ah_Width        : UWORD;
    ah_Left         : SWORD;
    ah_Top          : SWORD;
    ah_AbsTime      : ULONG;
    ah_RelTime      : ULONG;
    ah_Interleave   : UBYTE;
    ah_Pad0         : UBYTE;
    ah_Flags        : ULONG;
    ah_Pad          : packed array[0..16-1] of UBYTE;
  end;


const

  //* Methods */

  ADTM_Dummy                = ($700);
  ADTM_LOADFRAME            = ($701);
  ADTM_UNLOADFRAME          = ($702);
  ADTM_START                = ($703);
  ADTM_PAUSE                = ($704);
  ADTM_STOP                 = ($705);
  ADTM_LOCATE               = ($706);

  //* New on V44 */
  ADTM_LOADNEWFORMATFRAME   = ($707);
  ADTM_UNLOADNEWFORMATFRAME = ($708);


Type
  PadtFrame = ^TadtFrame;
  TadtFrame = record
    MethodID        : ULONG;
    alf_TimeStamp   : ULONG;
    alf_Frame       : ULONG;
    alf_Duration    : ULONG;
    alf_BitMap      : PBitMap;
    alf_CMap        : PColorMap;
    alf_Sample      : PSBYTE;
    alf_SampleLength: ULONG;
    alf_Period      : ULONG;
    alf_UserData    : APTR;
  end;


  PadtNewFormatFrame = ^TadtNewFormatFrame;
  TadtNewFormatFrame = record
    MethodID            : ULONG;
    alf_TimeStamp       : ULONG;
    alf_Frame           : ULONG;
    alf_Duration        : ULONG;
    alf_BitMap          : PBitMap;
    alf_CMap            : PColorMap;
    alf_Sample          : PSBYTE;
    alf_SampleLength    : ULONG;
    alf_Period          : ULONG;
    alf_UserData        : APTR;
    alf_Size            : ULONG;
    alf_LeftSample      : PSBYTE;
    alf_RightSample     : PSBYTE;
    alf_SamplesPerSec   : ULONG;
  end;

  PadtStart = ^tadtStart;
  TadtStart = record
    MethodID            : ULONG;
    asa_Frame           : ULONG;
  end;



{$IFDEF AROS}
//
//  amigaguideclass.h
//


Const
  AMIGAGUIDEDTCLASS      : PChar =       'amigaguide.datatype';


  AGDTA_Dummy      = (DTA_Dummy + 700);
  AGDTA_Secure     = (AGDTA_Dummy + 1);
  AGDTA_HelpGroup  = (AGDTA_Dummy + 2);
{$ENDIF}



//
// protos
//

Var
  DataTypesBase : pLibrary;

Const
  DATATYPESNAME : PChar = 'datatypes.library';

{
    Just a note.
    You will see a lot of pObject_ here, pObject is
    defined in intuition.

    In c it's object * but we can't have object in fpc.
    typedef object ULONG

    pObject_ is just pULONG.

}

  {$IFDEF AMIGA}
  function  ObtainDataTypeA(typ: ULONG location 'd0'; handle: APTR location 'a0'; attrs: pTagItem location 'a1'): PDataType;                            syscall DataTypesBase 036;
  procedure ReleaseDataType(dtn: PDataType location 'a0');                                                                                              syscall DataTypesBase 042;
  function  NewDTObjectA(name: APTR location 'd0'; attrs: pTagItem location 'a0'): PObject_;                                                            syscall DataTypesBase 048;
  procedure DisposeDTObject(o: PObject_ location 'a0');                                                                                                 syscall DataTypesBase 054;
  function  SetDTAttrsA(o: pObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; attrs: pTagItem location 'a3'): ULONG;    syscall DataTypesBase 060;
  function  GetDTAttrsA(o: PObject_ location 'a0'; attrs: pTagItem location 'a2'): ULONG;                                                               syscall DataTypesBase 066;
  function  AddDTObject(win: PWindow location 'a0'; req: PRequester location 'a1'; o: PObject_ location 'a2'; pos: SLONG location 'd0'): SLONG;         syscall DataTypesBase 072;
  procedure RefreshDTObjectA(o: pObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; attrs: pTagItem location 'a3');      syscall DataTypesBase 078;
  function  DoAsyncLayout(o:PObject_ location 'a0'; gpl: pgpLayout location 'a1'): ULONG;                                                               syscall DataTypesBase 084;
  function  DoDTMethodA(o: PObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; msg: PMsg location 'a3'): ULONG;          syscall DataTypesBase 090;
  function  RemoveDTObject(win: PWindow location 'a0'; o: PObject_ location 'a1'): SLONG;                                                               syscall DataTypesBase 096;
  function  GetDTMethods(o: PObject_ location 'a0'): PULONG;                                                                                            syscall DataTypesBase 102;
  function  GetDTTriggerMethods(o: pObject_ location 'a0'): PDTMethod;                                                                                  syscall DataTypesBase 108;
  function  PrintDTObjectA(o: pObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; msg: pdtPrint location 'a3'): ULONG;   syscall DataTypesBase 114;
  function  ObtainDTDrawInfoA(o: PObject_ location 'a0'; attrs: pTagItem location 'a1'): APTR;                                                          syscall DataTypesBase 120;
  function  DrawDTObjectA(rp: pRastPort location 'a0'; o: PObject_ location 'a1'; x: SLONG location 'd0'; y: SLONG location 'd1'; 
            w: SLONG location 'd2'; h: SLONG location 'd3'; th: SLONG location 'd4'; tv: SLONG location 'd5'; attrs: pTagItem location 'a2'): SLONG;    syscall DataTypesBase 126;
  procedure ReleaseDTDrawInfo(o: pObject_ location 'a0'; handle: APTR location 'a1');                                                                   syscall DataTypesBase 132;
  function  GetDTString(id: ULONG location 'a0'): STRPTR;                                                                                               syscall DataTypesBase 138;
  {$ENDIF}


  {$IFDEF AROS}
  function  ObtainDataTypeA(typ: ULONG; handle: APTR; attrs: PTagItem): PDataType;              syscall DataTypesBase  6;
  procedure ReleaseDataType(dt: PDataType);                                                     syscall DataTypesBase  7;
  Function  NewDTObjectA(name: APTR; attrs: PTagItem): PObject_;                                syscall DataTypesBase  8;
  Procedure DisposeDTObject(o: PObject_);                                                       syscall DataTypesBase  9;
  function  SetDTAttrsA(o: PObject_; win: PWindow; req: PRequester; attrs: PTagItem): ULONG;    syscall DataTypesBase 10;
  function  GetDTAttrsA(o: PObject_; attrs: PTagItem): ULONG;                                   syscall DataTypesBase 11;
  function  AddDTObject(win: PWindow; req: PRequester; obj: PObject_; pos: SLONG): SLONG;       syscall DataTypesBase 12;
  procedure RefreshDTObjectA(o: PObject_; win: PWindow; req: PRequester; attrs: PTagItem);      syscall DataTypesBase 13;
  function  DoAsyncLayout(o: PObject_; gpl: PgpLayout): ULONG;                                  syscall DataTypesBase 14;
  function  DoDTMethodA(o: PObject_; win: PWindow; req: PRequester; msg: PMsg): UIPTR;          syscall DataTypesBase 15;
  function  RemoveDTObject(win: PWindow; o: PObject_): SLONG;                                   syscall DataTypesBase 16;
  function  GetDTMethods(o: PObject_): PULONG;                                                  syscall DataTypesBase 17;
  function  GetDTTriggerMethods(o: PObject_): PDTMethod;                                        syscall DataTypesBase 18;
  function  PrintDTObjectA(o: PObject_; win: PWindow; req: PRequester; msg: PdtPrint): ULONG;   syscall DataTypesBase 19;
  function  ObtainDTDrawInfoA(o: PObject_; attrs: PTagItem): APTR;                              syscall DataTypesBase 20;
  function  DrawDTObjectA(rp: PRastPort; o: PObject_; x: SLONG; y: SLONG; w: SLONG; h: SLONG; 
            th: SLONG; tv: SLONG; attrs: PTagItem): SLONG;                                      syscall DataTypesBase 21;
  procedure ReleaseDTDrawInfo(o: PObject_; handle: APTR);                                       syscall DataTypesBase 22;
  function  GetDTString(id: ULONG): CONST_STRPTR;                                               syscall DataTypesBase 23;
  // v45 or higher
  procedure LockDataType(dt: pDataType);                                                        SysCall DataTypesBase 40;
  function  FindToolNodeA(tl: pList; attrs: pTagItem): pToolNode;                               SysCall DataTypesBase 41;
  function  LaunchToolA(t: pTool; project: STRPTR; attrs: pTagItem): ULONG;                     SysCall DataTypesBase 42;
  function  FindMethod(methods: PULONG; smid: ULONG): PULONG;                                   SysCall DataTypesBase 43;
  function  FindTriggerMethod(methods: PDTMethod; command: STRPTR; method: ULONG): PDTMethod;   SysCall DataTypesBase 44;
  function  CopyDTMethods(methods: PULONG; include: PULONG; exclude: PULONG): PULONG;           SysCall DataTypesBase 45;
  function  CopyDTTriggerMethods(methods: PDTMethod; include: PDTMethod; exclude: PDTMethod): 
            PDTMethod;                                                                          SysCall DataTypesBase 46;
  procedure FreeDTMethods(methods: APTR);                                                       SysCall DataTypesBase 47;
  function  GetDTTriggerMethodDataFlags(method: ULONG): ULONG;                                  SysCall DataTypesBase 48;
  function  SaveDTObjectA(o: PObject_; win: PWindow; req: PRequester; filename: STRPTR; 
            mode: ULONG; saveicon: BOOL; attrs: pTagItem): ULONG;                               SysCall DataTypesBase 49;
  function  StartDragSelect(o: PObject_): ULONG;                                                SysCall DataTypesBase 50;
  function  DoDTDomainA(o: PObject_; win: PWindow; req: PRequester; rport: PRastPort; 
            which: ULONG; domain: PIBox; attrs: pTagItem): ULONG;                               SysCall DataTypesBase 51;
  {$ENDIF}

  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  // Varargs versions for Amiga and AROS
  function  ObtainDataType(typ: ULONG; handle: APTR; tags: Array of const): PDataType; inline;
  Function  NewDTObject(name: APTR; tags: Array of const): PObject_; inline;
  Function  SetDTAttrs(o: PObject_; win: PWindow; req: PRequester; tags: Array of const): ULONG; inline;
  Function  GetDTAttrs(o: PObject_; tags: Array of const): ULONG; inline;
  Procedure RefreshDTObject(o: PObject_; win: PWindow; req: PRequester; tags: Array of const); inline;
  Function  DoDTMethod(o: PObject_; win: PWindow; req: PRequester; tags: Array of const): UIPTR; inline;
  Function  PrintDTObject(o: PObject_; win: PWindow; req: PRequester; tags: Array of const): ULONG; inline;
  Function  ObtainDTDrawInfo(o: PObject_; tags: Array of const): APTR; inline;
  Function  DrawDTObject(rp: PRastPort; o: PObject_; x: SLONG; y: SLONG; w: SLONG; h: SLONG; th: SLONG; tv: SLONG; tags: Array of const): SLONG; inline;
  {$ENDIF}

  {$IFDEF AROS}
  // Additional varargs versions for AROS
  function  FindToolNode(tl: pList; tags: Array of const): pToolNode;
  function  LaunchTool(t: pTool; project: STRPTR; tags: Array of const): ULONG;
  function  SaveDTObject(o: PObject_; win: PWindow; req: PRequester; filename: STRPTR; mode: ULONG; saveicon: BOOL; tags: Array of const): ULONG;
  function  DoDTDomain(o: PObject_; win: PWindow; req: PRequester; rport: PRastPort; which: ULONG; domain: PIBox; tags: Array of const): ULONG;
  {$ENDIF}

  {$IFDEF MORPHOS}
  function  ObtainDataTypeA(typ: ULONG location 'd0'; handle: APTR location 'a0'; attrs: pTagItem location 'a1'): PDataType;                            SysCall DataTypesBase 036;
  procedure ReleaseDataType(dt: PDataType location 'a0');                                                                                               SysCall DataTypesBase 042;
  function  NewDTObjectA(name: APTR location 'd0'; attrs: pTagItem location 'a0'): PObject_;                                                            SysCall DataTypesBase 048;
  procedure DisposeDTObject(o: PObject_ location 'a0');                                                                                                 SysCall DataTypesBase 054;
  function  SetDTAttrsA(o: PObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; attrs: pTagItem location 'a3'): ULONG;    SysCall DataTypesBase 060;
  function  GetDTAttrsA(o: PObject_ location 'a0'; attrs: pTagItem location 'a2'): ULONG;                                                               SysCall DataTypesBase 066;
  function  AddDTObject(win: PWindow location 'a0'; req: PRequester location 'a1'; o: PObject_ location 'a2'; pos: SLONG location 'd0'): SLONG;         SysCall DataTypesBase 072;
  procedure RefreshDTObjectA(o: PObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; attrs: pTagItem location 'a3');      SysCall DataTypesBase 078;
  function  DoAsyncLayout(o: PObject_ location 'a0'; gpl: pgpLayout location 'a1'): ULONG;                                                              SysCall DataTypesBase 084;
  function  DoDTMethodA(o: PObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; msg: PMsg location 'a3'): UIPTR;          SysCall DataTypesBase 090;
  function  RemoveDTObject(win: PWindow location 'a0'; o: PObject_ location 'a1'): SLONG;                                                               SysCall DataTypesBase 096;
  function  GetDTMethods(o: PObject_ location 'a0'): PULONG;                                                                                            SysCall DataTypesBase 102;
  // note that MorphOS SDK returns struct DTMethods * which is not defined anywhere -> assume typo
  function  GetDTTriggerMethods(o: PObject_ location 'a0'): pDTMethod;                                                                                  SysCall DataTypesBase 108;
  function  PrintDTObjectA(o: PObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; msg: pdtPrint location 'a3'): ULONG;   SysCall DataTypesBase 114;
  function  ObtainDTDrawInfoA(o: PObject_ location 'a0'; attrs: pTagItem location 'a1'): APTR;                                                           SysCall DataTypesBase 120;
  function  DrawDTObjectA(rp: PRastPort location 'a0'; o: PObject_ location 'a1'; x: SLONG location 'd0'; y: SLONG location 'd1'; 
            w: SLONG location 'd2'; h: SLONG location 'd3'; th: SLONG location 'd4'; tv: SLONG location 'd5'; attrs: pTagItem location 'a2'): SLONG;    SysCall DataTypesBase 126;
  procedure ReleaseDTDrawInfo(o: PObject_ location 'a0'; handle: APTR location 'a1');                                                                   SysCall DataTypesBase 132;
  function  GetDTString(id: ULONG location 'd0'): STRPTR;                                                                                               SysCall DataTypesBase 138;
  // v45+
  procedure LockDataType(dt: PDataType location 'a0');                                                                                          SysCall DataTypesBase 240;
  function  FindToolNodeA(tl: pList location 'a0'; attrs: pTagItem location 'a1'): PToolNode;                                                   SysCall DataTypesBase 246;
  function  LaunchToolA(t: PTool location 'a0'; project: STRPTR location 'a1'; attrs: pTagItem location 'a2'): ULONG;                           SysCall DataTypesBase 252;
  function  FindMethod(methods: PULONG location 'a0'; id: ULONG location 'a1'): PULONG;                                                         SysCall DataTypesBase 258;
  function  FindTriggerMethod(methods: PDTMethod location 'a0'; command: STRPTR location 'a1'; method: ULONG location 'd0'): pDTMethod;         SysCall DataTypesBase 264;
  function  CopyDTMethods(src: PULONG location 'a0'; include: PULONG location 'a1'; exclude: PULONG location 'a2'): PULONG;                     SysCall DataTypesBase 270;
  function  CopyDTTriggerMethods(src: PDTMethod location 'a0'; include: PDTMethod location 'a1'; exclude: PDTMethod location 'a2'): pDTMethod;  SysCall DataTypesBase 276;
  procedure FreeDTMethods(methods: APTR location 'a0');                                                                                         SysCall DataTypesBase 282;
  function  GetDTTriggerMethodDataFlags(method: ULONG location 'd0'): ULONG;                                                                    SysCall DataTypesBase 288;
  function  SaveDTObjectA(o: PObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; 
            filename: STRPTR location 'a3'; mode: ULONG location 'd0'; saveicon: BOOL location 'd1'; attrs: pTagItem location 'a4'): ULONG;     SysCall DataTypesBase 294;
  function  StartDragSelect(o: PObject_ location 'a0'): ULONG;                                                                                  SysCall DataTypesBase 300;
  function  DoDTDomainA(o: PObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; rport: PRastPort location 'a3'; 
            which: ULONG location 'd0'; domain: PIBox location 'a4'; attrs: pTagItem location 'a5'): ULONG;                                     SysCall DataTypesBase 306;

  // varags versions  
  function  ObtainDataType(typ: ULONG; handle: APTR; attrs : array of LongWord): PDataType; inline;
  Function  NewDTObject(name: APTR; attrs : array of LongWord): PObject_; inline;
  Function  SetDTAttrs(o: PObject_; win: PWindow; req: PRequester; attrs : array of LongWord): ULONG; inline;
  Function  GetDTAttrs(o: PObject_; attrs : array of LongWord): ULONG; inline;
  Procedure RefreshDTObject(o: PObject_; win: PWindow; req: PRequester; attrs : array of LongWord); inline;
  Function  DoDTMethod(o: PObject_; win: PWindow; req: PRequester; msg: array of LongInt): UIPTR; inline;
  Function  PrintDTObject(o: PObject_; win: PWindow; req: PRequester; msg : array of LongInt): ULONG; inline;
  Function  ObtainDTDrawInfo(o: PObject_; attrs : array of LongWord): APTR; inline;
  Function  DrawDTObject(rp: PRastPort; o: PObject_; x: SLONG; y: SLONG; w: SLONG; h: SLONG; th: SLONG; tv: SLONG; attrs : array of LongWord): SLONG; inline;
  // v45+
  function  FindToolNode(tl: pList; attrs: array of LongWord): pToolNode;
  function  LaunchTool(t: pTool; project: STRPTR; attrs: array of LongWord): ULONG;
  function  SaveDTObject(o: PObject_; win: PWindow; req: PRequester; filename: STRPTR; mode: ULONG; saveicon: BOOL; attrs : array of LongWord): ULONG;
  function  DoDTDomain(o: PObject_; win: PWindow; req: PRequester; rport: PRastPort; which: ULONG; domain: PIBox; attrs : array of LongWord): ULONG;
  {$ENDIF}


implementation


  {$IFDEF AMIGA}
uses
  tagsarray;
  {$ENDIF}
  {$IFDEF AROS}
uses
  tagsarray, longarray; 
  {$ENDIF}


{$IF DEFINED(AMIGA) or DEFINED(AROS)}
function  ObtainDataType(typ: ULONG; handle: APTR; tags: Array of const): PDataType; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  ObtainDataType := ObtainDataTypeA(typ, handle, GetTagPtr(TagList));
end;

Function  NewDTObject(name: APTR; tags: Array of const): PObject_; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  NewDTObject := NewDTObjectA(name, GetTagPtr(TagList));
end;

Function  SetDTAttrs(o: PObject_; win: PWindow; req: PRequester; tags: Array of const): ULONG; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  SetDTAttrs := SetDTAttrsA(o, win, req, GetTagPtr(TagList));
end;

Function  GetDTAttrs(o: PObject_; tags: Array of const): ULONG; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  GetDTAttrs := GetDTAttrsA(o, GetTagPtr(TagList));
end;

Procedure RefreshDTObject(o: PObject_; win: PWindow; req: PRequester; tags: Array of const); inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  RefreshDTObjectA(o, win, req, GetTagPtr(TagList));
end;

Function  DoDTMethod(o: PObject_; win: PWindow; req: PRequester; tags: Array of const): UIPTR; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  DoDTMethod := DoDTMethodA(o, win, req, Pointer(GetTagPtr(TagList)));
end;

Function  PrintDTObject(o: PObject_; win: PWindow; req: PRequester; tags: Array of const): ULONG; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  PrintDTObject := PrintDTObjectA(o, win, req, Pointer(GetTagPtr(TagList)));
end;

Function  ObtainDTDrawInfo(o: PObject_; tags: Array of const): APTR; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  ObtainDTDrawInfo := ObtainDTDrawInfoA(o, GetTagPtr(TagList));
end;

Function  DrawDTObject(rp: PRastPort; o: PObject_; x: SLONG; y: SLONG; w: SLONG; h: SLONG; th: SLONG; tv: SLONG; tags: Array of const): SLONG; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  DrawDTObject := DrawDTObjectA(rp, o, x, y, w, h, th, tv, GetTagPtr(TagList));
end;
{$ENDIF}



{$IFDEF AROS}
function  FindToolNode(tl: pList; tags: Array of const): pToolNode;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  FindToolNode := FindToolNodeA(tl, GetTagPtr(TagList));
end;

function  LaunchTool(t: pTool; project: STRPTR; tags: Array of const): ULONG;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  LaunchTool := LaunchToolA(t, project, GetTagPtr(TagList));
end;

function  SaveDTObject(o: PObject_; win: PWindow; req: PRequester; filename: STRPTR; mode: ULONG; saveicon: BOOL; tags: Array of const): ULONG;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  SaveDTObject:= SaveDTObjectA(o, win, req, filename, mode, saveicon, GetTagPtr(TagList));
end;

function  DoDTDomain(o: PObject_; win: PWindow; req: PRequester; rport: PRastPort; which: ULONG; domain: PIBox; tags: Array of const): ULONG;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  DoDTDomain := DoDTDomainA(o, win, req, rport, which, domain, GetTagPtr(TagList));
end;
{$ENDIF}



{$IFDEF MORPHOS}
function  ObtainDataType(typ: ULONG; handle: APTR; attrs: Array of LongWord): pDataType;
begin
  ObtainDataType := ObtainDataTypeA(typ, handle, @attrs);
end;

Function  NewDTObject(name: APTR; attrs: Array of LongWord): PObject_;
begin
  NewDTObject := NewDTObjectA(name, @attrs);
end;

Function  SetDTAttrs(o: PObject_; win: PWindow; req: PRequester; attrs: Array of LongWord): ULONG;
begin
  SetDTAttrs := SetDTAttrsA(o, win, req, @attrs);
end;

Function  GetDTAttrs(o: PObject_; attrs: Array of LongWord): ULONG;
begin
  GetDTAttrs := GetDTAttrsA(o, @attrs);
end;

Procedure RefreshDTObject(o: PObject_; win: PWindow; req: PRequester; attrs: Array of LongWord);
begin
  RefreshDTObjectA(o, win, req, @attrs);
end;

Function  DoDTMethod(o: PObject_; win: PWindow; req: PRequester; msg: Array of LongInt): UIPTR;
begin
  DoDTMethod := DoDTMethodA(o, win, req, @msg);
end;

Function  PrintDTObject(o: PObject_; win: PWindow; req: PRequester; msg: Array of LongInt): ULONG;
begin
  PrintDTObject := PrintDTObjectA(o, win, req, @msg);
end;

Function  ObtainDTDrawInfo(o: PObject_; attrs: Array of LongWord): APTR;
begin
  ObtainDTDrawInfo := ObtainDTDrawInfoA(o, @attrs);
end;

Function  DrawDTObject(rp : PRastPort; o: PObject_; x: SLONG; y: SLONG; w: SLONG; h: SLONG; th: SLONG; tv: SLONG; attrs: Array of LongWord): SLONG;
begin
  DrawDTObject := DrawDTObjectA(rp, o, x, y, w, h, th, tv, @attrs);
end;



function FindToolNode(tl: pList; attrs: array of LongWord): pToolNode;
begin
  FindToolNode:=FindToolNodeA(tl, @attrs);
end;

function LaunchTool(t: pTool; project: STRPTR; attrs: array of LongWord): ULONG;
begin
  LaunchTool:=LaunchToolA(t, project, @attrs);
end;

function SaveDTObject(o: PObject_; win: PWindow; req: PRequester; filename: STRPTR; mode: ULONG; saveicon: BOOL; attrs: array of LongWord): ULONG;
begin
  SaveDTObject:=SaveDTObjectA(o, win, req, filename, mode, saveicon, @attrs);
end;

function DoDTDomain(o: PObject_; win: PWindow; req: PRequester; rport: PRastPort; which: ULONG; domain: PIBox; attrs: array of LongWord): ULONG;
begin
  DoDTDomain:=DoDTDomainA(o, win, req, rport, which, domain, @attrs);
end;
{$ENDIF}



Initialization
  DataTypesBase := OpenLibrary(DATATYPESNAME, 0);

finalization
  CloseLibrary(DataTypesBase);

end.
