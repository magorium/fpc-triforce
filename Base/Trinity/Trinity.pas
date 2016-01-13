unit Trinity;


// ---------------------------------------------------------------------------
// Edit Date   $ Entry 
// ---------------------------------------------------------------------------
// 2016-01-12  $ AROS: NewCreateTask()
// 2016-01-11  $ Amiga + AROS: CreateContext() + PPGadget;
// 2015-12-29  $ MorphOS: SetPointer()
// 2015-12-16  $ MorphOS: SystemTags()
// 2015-12-06  $ MorphOS: BestModeID()
// 2015-12-04  $ Amiga: CloseScreen(), returns a bool since v36.
// 2015-11-29  $ Amiga + MorphOS: SetWindowPointer()
// 2015-11-22  $ Amiga + MorphOS: Missing DrawCircle macro
// 2015-11-22  $ All: Overload version of INST_DATA accepting generic pointer
//               for object parameter
// 2015-11-21  $ Amiga: AddAppIconA = AddAppIcon
// 2015-11-16  $ AROS: gadtools varargs version routines
// 2015-11-10  $ Amiga: DoDTMethod()
//             $ MorphOS: NewDTObject(), DoDTMethod(), GetDTAttrs(), 
//               DisposeDTObject()
// 2015-11-06  $ MorphOS: NewList()
// 2015-10-16  $ AROS: ReadLink()
// 2015-10-08  $ AROS + MORPHOS: PrintF()
// 2015-10-04  $ AROS: ASL functions
//             $ Amiga: AslRequest(), RequestFile()
//             $ Amiga: FPuts()
// 2015-09-27  $ MorphOS: ObtainBestPen()
//             $ Amiga + MorphOS: PolyDraw()
//             $ Amiga + MorphOS: macro RASSIZE
//             $ Amiga + MorphOS: MIDDLEUP and MIDDLEDOWN consts
//             $ All: EasyRequest()
// 2015-09-26  $ all: FPrintf()
// 2015-09-25  $ Fix: TDateTime, let original unit decide structure + size
// 2015-09-23  $ Amiga + AROS + MorphOS: ReadArgs()
//             $ MorphOS: ReadPixelArray8() & WritePixelArray8()
// 2015-09-22  $ MorphOS AllocDosObjectTags()
//             $ MorphOS const ACTION_WRITE + ACTION_READ
// 2015-09-21  $ MorphOS TextLength, fix for string parameter being pShortint
//             $ MorphOS, Text() -> GfxText() + string parameter, see above
//             $ Amiga + AROS, structure TDateTime from AmigaDOS conflicts
//               with TDateTime from Free Pascal
// 2015-09-11  $ AROS + MorphOS: 
//             $ - CreatePort(), DeletePort()
//             $ - CreateExtIO(), DeleteExtIO()
// 2015-09-01  $ Amiga + MorphOS OBJ_xxx macros
// 2015-08-30  $ ExecAllocMem() for Amiga and AROS
//             $ VFPrintf() overloads for Amiga and MorphOS.
//             $ Info() overload for Amiga
// 2015-08-29  $ Type PPObject_ for Amiga and MorphOS
// 2015-08-27  $ Use out parameters instead of var to shut up compiler hints.
// 2015-08-26  $ GetTagData(), Amiga sugar-coating hints.
//             $ Be (somewhat) more descriptive in entries (needs more work)
//             $ SetAndTest() functions removed (moved to unit CHelpers).
// 2015-08-25  $ NextTagItem(), AROS compatibility
// 2015-08-23  $ Some cleanup, no changes.
// 2015-08-22  $ CoerceMethod(), Missing
//             $ GetAttr(), MorphOS compatibility
// 2015-08-21  $ SetAndTest Longint version
// 2015-08-11  $ SetAttrs() 
//             $ additional TAG_() functions for Amiga
//             $ additional TAG_() functions for MorphOS
//             $ array of const for Amiga's DoMethod() instead of LW's
//             $ workaround "Conversion between ordinals and pointers 
//               is not portable" hint messages
//             $ Useful MUI text macro's
// 2015-08-06  $ initial release
// ---------------------------------------------------------------------------


{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}


{$MODE OBJFPC}{$H+}


interface


Uses
  Exec, AmigaDOS, 
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  AGraphics,  // for the OBJ_xxx macro's and TextLenght()
  InputEvent, // For IECODE_MBUTTON to aid MIDDLEDOWN & MIDDLEUP consts
  {$ENDIF}
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  Workbench,
  Icon,
  asl,
  GadTools,
  {$ENDIF}
  {$IFDEF MORPHOS}
  DataTypes,
  {$ENDIF}
  {$IFDEF AROS}
  AGraphics,
  {$ENDIF}
  Intuition, Utility;



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Hooks -> cross-platform support
//
//////////////////////////////////////////////////////////////////////////////



Type
  // THookFunction = function(Hook: pHook; obj: PObject_; Msg: Pointer): LongWord;
  THookFunction = function(Hook: pHook; obj: APTR; Msg: APTR): LongWord;

  Procedure InitHook(Out Hook: THook; Func: THookFunction; Data: APTR);



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Tags and TagValue's. Array of const = LongInt vs. Array of long
//         Cosmetic only e.g. get rid of compiler warnings
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AROS}
  Function  TAG_(TagItem: LongWord): LongInt; overload; inline;
  //Function TAG_(TagItem: LongInt ): LongInt; overload; inline;
  Function  TAG_(TagItem: Pointer ): LongInt; overload; inline;
  function  TAG_(TagItem: boolean ): LongInt; overload; inline; 
  {$ENDIF}
  {$IFDEF AMIGA}
  Function  TAG_(TagItem: LongWord): LongInt; overload; inline;
  //Function TAG_(TagItem: LongInt ): LongInt; overload; inline;
  Function  TAG_(TagItem: Pointer ): LongInt; overload; inline;
  function  TAG_(TagItem: boolean ): LongInt; overload; inline; 
  {$ENDIF}
  {$IFDEF MORPHOS}
  //Function TAG_(TagItem: LongWord): LongWord; overload; inline;
  Function  TAG_(TagItem: LongInt ): LongWord; overload; inline;
  Function  TAG_(TagItem: Pointer ): LongWord; overload; inline;
  function  TAG_(TagItem: boolean ): LongWord; overload; inline;  
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: SetGadgetAttrs(), missing from MorphOS
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function  SetGadgetAttrs(Gadget: PGadget; Window: PWindow; Requester: PRequester; const Tags: array of long): ULONG;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: DoMethod()
//         Amiga   : Missing
//         MorphOS : wrong parameter declaration
//         ALL     : missing none msg version
//
//////////////////////////////////////////////////////////////////////////////



  function  DoMethod(obj : pointer; MethodID: ULONG): ULONG; overload;
  {$IFDEF AMIGA}
  function  DoMethod(obj : pointer; MethodID: ULONG; const msg : array of const): ULONG; overload;
  {$ENDIF}
  {$IFDEF MORPHOS}
  function  DoMethod(obj : pointer; MethodID: ULONG; const msg : array of ULONG): ULONG; overload;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: DoSuperMethod()
//         Amiga          : Missing
//         MorphOS + AROS : wrong parameter declaration
//         ALL            : missing none msg version
//
//////////////////////////////////////////////////////////////////////////////



  function  DoSuperMethod(cl: pointer; obj : pointer; id: LongWord): LongWord; overload;
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS) or DEFINED(AROS)}
  function  DoSuperMethod(cl: pointer; obj : pointer; id: LongWord; const msg : array of LongWord): longword; overload;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Structure TWBArg, Missing from MorphOS because of lacking unit
//         Workbench
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
Type
  PWBArg = ^TWBArg;
  TWBArg = Record
    wa_lock: BPTR;   //* a lock descriptor */
    wa_Name: PChar;  //* a string relative to that lock */
  end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Function SetAttrs(), this varargs version missing from Amiga & MOS
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function  SetAttrs(Obj: APTR; tagList: Array of Const): ULONG;
  {$ENDIF}
  {$IFDEF MORPHOS}
  function  SetAttrs(Obj: APTR; tagList: Array of DWord): ULONG;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic:  Useful MUI text macro's. Used other names to avoid conflicts.
//
//////////////////////////////////////////////////////////////////////////////



const
  Esc_R             = #27#114;  //  right justified
  Esc_C             = #27#099;  //  centered
  Esc_L             = #27#108;  //  left justified
  Esc_N             = #27#110;  //  normal
  Esc_B             = #27#098;  //  bold
  Esc_I             = #27#105;  //  italic
  Esc_U             = #27#117;  //  underlined
  Esc_PT            = #27#050;  //  text pen
  Esc_PH            = #27#056;  //  highlight text pen

  // Specials
  Esc_IMS           = #27#073;  //  Standard MUI Image
  Esc_IMC           = #27#079;  //  Created MUI Image



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: CoerceMethos()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
Type
  PBoopsiObject = PObject_;
{$ENDIF}

  {$IFDEF AMIGA}
  function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: ULONG): ULONG;
  function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: ULONG; const Msg: array of const): ULONG; overload;
  {$ENDIF}
  {$IFDEF AROS}
  function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: IPTR): IPTR;
  {$ENDIF}
  {$IFDEF MORPHOS}
  function  CoerceMethodA(cl: PIClass; Obj: PObject_; Msg: Pointer): ULONG;
  function  CoerceMethod(cl: PIClass; Obj: PBoopsiobject; MethodID: ULONG): ULONG;
  function  CoerceMethod(cl: PIClass; Obj: PBoopsiObject; MethodID: ULONG; const Msg: array of ULONG): ULONG;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: GetAttr() for Morphos, complying to autodocs.
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function  GetAttr(attrID : CARDINAL location 'd0'; object1 : POINTER location 'a0'; storagePtr : PCARDINAL location 'a1') : CARDINAL; SysCall IntuitionBase 654;  
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: NextTagItem(), AROS
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AROS}
  Function  NextTagItem(Item: PPTagItem): PTagItem; syscall AOS_UtilityBase 8;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Amiga GetTagData(), hint sugarcouting
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function GetTagData(tagval : Cardinal location 'd0'; default : ULONG location 'd1'; const TagList : pTagItem location 'a0') : ULONG; syscall _UtilityBase 036;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Type PPObject
//
//////////////////////////////////////////////////////////////////////////////



  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
Type
  PPObject_     =   ^PObject_;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: ExecAllocMem()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function ExecAllocMem(byteSize: ULONG location 'd0'; requirements: ULONG location 'd1'): POINTER; syscall _ExecBase 198;
  {$ENDIF}
  {$IFDEF AROS}
  function ExecAllocMem(ByteSize: ULONG; Requirements: ULONG): APTR; syscall AOS_ExecBase 33;
  {$ENDIF}
  


//////////////////////////////////////////////////////////////////////////////
//
//  Topic: VFPrintf()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function VFPrintf(fh: LongInt location 'd1';const format: pCHAR location 'd2';const argarray : PLongInt location 'd3'): LongInt; syscall _DOSBase 354; overload;
  {$ENDIF}

  {$IFDEF MORPHOS}
  function VFPrintf(fh: LongInt location 'd1'; format: PChar location 'd2'; argarray: PLongInt location 'd3'): LongInt; SysCall MOS_DOSBase 354; overload;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Info()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function Info(lock: LongInt location 'd1'; parameterBlock: pInfoData location 'd2'): LongInt; syscall _DOSBase 114; overload;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: OBJ_xxx macro's
//
//////////////////////////////////////////////////////////////////////////////



  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  function  OBJ_App         (obj : APTR) : PObject_;
  function  OBJ_Win         (obj : APTR) : PObject_;
  function  OBJ_Dri         (obj : APTR) : pDrawInfo;
  function  OBJ_Screen      (obj : APTR) : pScreen;
  function  OBJ_Pens        (obj : APTR) : pWord;
  function  OBJ_Window      (obj : APTR) : pWindow;
  function  OBJ_Rp          (obj : APTR) : pRastPort;
  function  OBJ_Left        (obj : APTR) : smallint;
  function  OBJ_Top         (obj : APTR) : smallint;
  function  OBJ_Width       (obj : APTR) : smallint;
  function  OBJ_Height      (obj : APTR) : smallint;
  function  OBJ_Right       (obj : APTR) : smallint;
  function  OBJ_Bottom      (obj : APTR) : smallint;
  function  OBJ_AddLeft     (obj : APTR) : smallint;
  function  OBJ_AddTop      (obj : APTR) : smallint;
  function  OBJ_SubWidth    (obj : APTR) : smallint;
  function  OBJ_SubHeight   (obj : APTR) : smallint;
  function  OBJ_MLeft       (obj : APTR) : smallint;
  function  OBJ_MTop        (obj : APTR) : smallint;
  function  OBJ_MWidth      (obj : APTR) : smallint;
  function  OBJ_MHeight     (obj : APTR) : smallint;
  function  OBJ_MRight      (obj : APTR) : smallint;
  function  OBJ_MBottom     (obj : APTR) : smallint;
  function  OBJ_Font        (obj : APTR) : pTextFont;
  function  OBJ_MinWidth    (obj : APTR) : LongWord;
  function  OBJ_MinHeight   (obj : APTR) : LongWord;
  function  OBJ_MaxWidth    (obj : APTR) : LongWord;
  function  OBJ_MaxHeight   (obj : APTR) : LongWord;
  function  OBJ_DefWidth    (obj : APTR) : LongWord;
  function  OBJ_DefHeight   (obj : APTR) : LongWord;
  function  OBJ_Flags       (obj : APTR) : LongWord;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: CreatePort(), DeletePort()
//
//////////////////////////////////////////////////////////////////////////////



  {$IF DEFINED(AROS) or DEFINED(MORPHOS)}
  function  CreatePort(name: STRPTR; pri: LONG): pMsgPort;
  procedure DeletePort (mp: pMsgPort);
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: CreateExtIO(), DeleteExtIO()
//
//////////////////////////////////////////////////////////////////////////////



  {$IF DEFINED(AROS) or DEFINED(MORPHOS)}
  function  CreateExtIO(port: pMsgPort; iosize: ULONG): pIORequest;
  procedure DeleteExtIO(ioreq: pIORequest);
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: MorphOS, TextLength()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function  TextLength(rp: pRastPort location 'a1'; string1: STRPTR location 'a0'; count: CARDINAL location 'd0'): INTEGER; SysCall GfxBase 054;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: MorphOS, Text() -> GfxText() + string parameter
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function  GfxText(rp: pRastPort location 'a1'; string1: STRPTR location 'a0'; count: CARDINAL location 'd0'): LongInt; SysCall GfxBase 060;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: TDateTime Structure + pointer
//
//////////////////////////////////////////////////////////////////////////////



{$IF DEFINED(AMIGA) or DEFINED(AROS)}
type
  _PDateTime = ^_TDateTime;
  _TDateTime = AmigaDOS.TDateTime; 
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: AllocDosObjectTags()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function AllocDosObjectTags(const Type_: LongWord; const Tags: array of LONG): APTR;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: MorphOS ACTION_READ and ACTION_WRITE
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
const
  ACTION_READ   = $52;
  ACTION_WRITE  = $57;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: All ReadArgs()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  FUNCTION ReadArgs(const arg_template: STRPTR location 'd1'; var arra: LONGINT location 'd2'; args: pRDArgs location 'd3'): pRDArgs; syscall _DOSBase 798; overload;  
  {$ENDIF}
  {$IFDEF AROS}
  function ReadArgs(const Template: STRPTR; Array_: PLONG; RdArgs: PRDArgs): PRDArgs; syscall AOS_DOSBase 133; overload;
  {$ENDIF}
  {$IFDEF MORPHOS}
  function ReadArgs(const arg_template: STRPTR location 'd1'; array1: PLONG location 'd2'; args: PRDArgs location 'd3'): PRDArgs; SysCall MOS_DOSBase 798; overload;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: MorphOS ReadPixelArray8() & WritePixelArray8()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function ReadPixelArray8 (rp: pRastPort location 'a0'; xstart: CARDINAL location 'd0'; ystart: CARDINAL location 'd1'; xstop: CARDINAL location 'd2'; ystop: CARDINAL location 'd3'; array1: pBYTE location 'a2'; temprp: pRastPort location 'a1'): LongInt; SysCall GfxBase 780; overload;
  function WritePixelArray8(rp: pRastPort location 'a0'; xstart: CARDINAL location 'd0'; ystart: CARDINAL location 'd1'; xstop: CARDINAL location 'd2'; ystop: CARDINAL location 'd3'; array1: pBYTE location 'a2'; temprp: pRastPort location 'a1'): LongInt; SysCall GfxBase 786; overload;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: FPrintf()
//
//////////////////////////////////////////////////////////////////////////////



  function FPrintf(fh: BPTR; fmt: STRPTR): LONG; overload; inline;
  {$IFDEF AROS}
  function FPrintf(fh: BPTR; fmt: STRPTR; argsarray: array of IPTR): LONG; overload; inline;
  {$ENDIF}
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  function FPrintf(fh: BPTR; fmt: STRPTR; argsarray: array of NativeUInt): LONG; overload; inline;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: ObtainBestPne()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function  ObtainBestPen(cm: pColorMap; R: ULONG; G: ULONG; B: ULONG; taglist: array of DWord): LONG; Inline;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: PolyDraw()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  procedure PolyDraw(rp: pRastPort location 'a1'; count: LongInt location 'd0'; const polyTable: pSmallInt location 'a0'); syscall GfxBase 336;
  {$ENDIF}
  {$IFDEF MORPHOS}
  procedure PolyDraw(rp: pRastPort location 'a1'; count: LongInt location 'd0'; polyTable: PSmallInt location 'a0'); SysCall GfxBase 336;
  {$ENDIF}
  
  
  
//////////////////////////////////////////////////////////////////////////////
//
//  Topic: macor RASSIZE
//
//////////////////////////////////////////////////////////////////////////////



  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  function  RasSize(w, h: Word): Integer; inline;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: constants MIDDLEUP and MIDDLEDOWN
//
//////////////////////////////////////////////////////////////////////////////



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
Const
  MIDDLEDOWN = IECODE_MBUTTON;
  MIDDLEUP   = IECODE_MBUTTON or IECODE_UP_PREFIX;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: EasyRequest()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function EasyRequest(Window: PWindow; EasyStruct: PEasyStruct; IDCMP_Ptr: PULONG; const tagList: array of const): LONG;
  {$ENDIF}

  {$IFDEF MORPHOS}
  function EasyRequest(Window: PWindow; EasyStruct: PEasyStruct; IDCMP_Ptr: PULONG; tagList: array of ULONG): LONG;
  {$ENDIF}

  {$IFDEF HASAMIGA}
  function EasyRequest(Window: PWindow; EasyStruct: PEasyStruct; IDCMP_Ptr: PULONG): LONG; overload;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Asl functions
//
//////////////////////////////////////////////////////////////////////////////


  {$IFDEF AMIGA}
  function  RequestFile(fileReq: pFileRequester location 'a0'): LongBool;                           syscall AslBase 042;  // Obsolete, use AslRequest
  function  AslRequest(requester: APTR location 'a0'; tagList: pTagItem location 'a1'): LongBool;   syscall AslBase 060;
  {$ENDIF}
  {$IFDEF AROS}  // i was lazy and simply overuled them all.
  function  AllocFileRequest: PFileRequester;                         syscall AslBase 5;  // Obsolete, use AllocAslRequest
  procedure FreeFileRequest(FileReq: PFileRequester);                 syscall AslBase 6;  // Obsolete, use FreeAslRequest
  function  RequestFile(FileReq: PFileRequester): LongBool;           syscall AslBase 7;  // Obsolete, use AslRequest
  function  AllocAslRequest(ReqType: ULONG; tagList: PTagItem): APTR; syscall AslBase 8;
  procedure FreeAslRequest(Requester: APTR);                          syscall AslBase 9;
  function  AslRequest(Requester: APTR; tagList: PTagItem): LongBool; syscall AslBase 10;
  procedure AbortAslRequest(Requester: APTR);                         syscall AslBase 13;
  procedure ActivateAslRequest(Requester:APTR);                       syscall AslBase 14;
  // varargs versions
  function  AllocAslRequestTags(ReqType: ULONG; const Tags: array of const): APTR;
  {$ENDIF}
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  function  AslRequestTags(Requester: APTR; const Tags: array of const): LongBool;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: FPuts()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function  FPuts(fh: BPTR location 'd1'; const str: STRPTR location 'd2'): LONG; syscall _DOSBase 342;
  function  FPuts(fh: BPTR; const str: string): LONG;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Printf()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AROS}
  function Printf(fmt: STRPTR; Argv: array of LONG): LONG;
  {$ENDIF}
  {$IFDEF MORPHOS}
  function Printf(fmt: STRPTR; Argv: array of LONG): LONG;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: ReadLink()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AROS}
  function  ReadLink(Port: PMsgPort; Lock: BPTR; const Path: STRPTR; Buffer: STRPTR; Size: LongWord): LongInt; syscall AOS_DOSBase 73;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: NewList()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  procedure NewList(list: pList);
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: DoDTMethod()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function  DoDTMethod(o: PObject_; win: PWindow; req: PRequester; const msg: array of const): ULONG; Inline;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: NewDTObject, DoDTMethod, GetDTAttrs, DisposeDTObject
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function  NewDTObjectA(name: PChar location 'd0'; attrs: pTagItem location 'a0'): PObject_; SysCall DataTypesBase 048;
  function  NewDTObject(name: PChar; attrs: array of LongWord): PObject_; Inline;

  function  DoDTMethodA(o: PObject_ location 'a0'; win: PWindow location 'a1'; req: PRequester location 'a2'; msg: pLongInt location 'a3'): ULONG; SysCall DataTypesBase 090;
  function  DoDTMethod(o: PObject_; win: PWindow; req: PRequester; msg: array of LongInt): ULONG; Inline;

  function  GetDTAttrsA(o: PObject_ location 'a0'; attrs: pTagItem location 'a2'): ULONG; SysCall DataTypesBase 066;
  function  GetDTAttrs(o: PObject_; attrs : array of LongWord): ULONG; Inline;

  procedure DisposeDTObject(o: PObject_ location 'a0'); SysCall DataTypesBase 054;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic:  AROS gadtools
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AROS}
  function  CreateGadget(kind: ULONG; previous: PGadget; ng: PNewGadget; const Tags: array of const): PGadget;
  function  CreateMenus(newmenu: PNewMenu; const Tags: array of const): PMenu;
  procedure DrawBevelBox(rport: PRastPort; left: SmallInt; top: SmallInt; width: SmallInt; Height: SmallInt; const Tags: array of const);
  function  GetVisualInfo(Screen: PScreen; const Tags: array of const): APTR;
  function  GT_GetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const Tags: array of const): LongInt;
  procedure GT_SetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const Tags: array of const);
  function  LayoutMenuItems(menuitem: PMenuItem; vi: APTR; const Tags: array of const): LongBool;
  function  LayoutMenus(menu: PMenu; vi: APTR; const Tags: array of const): LongBool;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic:  AddAppIcon()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function AddAppIconA(id: ULONG location 'd0'; userdata: ULONG location 'd1'; txt: PChar location 'a0'; msgport: PMsgPort location 'a1'; lock: BPTR location 'a2'; diskobj: PDiskObject location 'a3'; const taglist: PTagItem location 'a4'):PAppIcon; syscall WorkbenchBase 060;

  function AddAppIcon(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; const Tags: array of const): PAppIcon;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic:  INST_DATA()
//
//////////////////////////////////////////////////////////////////////////////



  function INST_DATA(cl: PIClass; o: Pointer): Pointer; overload;



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: DrawCircle
//
//////////////////////////////////////////////////////////////////////////////



  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  procedure DrawCircle(Rp: PRastPort; xCenter, yCenter, r: LongInt); inline;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: SetWindowPointer()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  Procedure SetWindowPointer(window: PWindow; const Tags: array of const);
  {$ENDIF}
  {$IFDEF MORPHOS}
  Procedure SetWindowPointer(window: PWindow; const tagArray: array of ULONG);
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: CloseScreen()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AMIGA}
  function  CloseScreen(screen: PScreen location 'a0'): LongBool; SysCall _IntuitionBase 066;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: BestModeID()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function  BestModeID(Const tagArray: Array Of ULONG): ULONG;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Systemtags()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  function  SystemTags(const Command: STRPTR; const TagArray: array of ULONG): LONG;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: SetPointer()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF MORPHOS}
  procedure SetPointer(window: PWindow location 'a0'; pointer_: PSmallInt location 'a1'; height: SmallInt location 'd0'; width: SmallInt location 'd1'; xOffset: SmallInt location 'd2'; yOffset: SmallInt location 'd3'); SysCall IntuitionBase 270;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: CreateContext() + PPGadget;
//
//////////////////////////////////////////////////////////////////////////////



{$IF DEFINED(AMIGA) or DEFINED(AROS)}
Type
  PPGadget = ^PGadget;
{$ENDIF}

  {$IFDEF AMIGA}
  function  CreateContext(glistptr: PPGadget location 'a0'): PGadget; syscall GadToolsBase 114;
  {$ENDIF}
  {$IFDEF AROS}
  function  CreateContext(GListPtr: PPGadget): PGadget; syscall GadToolsBase 19;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: NewCreateTask()
//
//////////////////////////////////////////////////////////////////////////////



  {$IFDEF AROS}
  function  NewCreateTaskA(tags: PTagItem): PTask; syscall AOS_ExecBase 153;
  function  NewCreateTask(const Tags: array of const): PTask;
  {$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////



implementation


{$IFDEF AMIGA}
Uses
  AmigaLib, tagsarray, longarray, MUI, datatypes;
{$ENDIF}

{$IFDEF MORPHOS}
Uses
  AmigaLib, MUI;
{$ENDIF}

{$IFDEF AROS}
Uses
  tagsarray;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Hooks
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF CPU68}
procedure InitHook(Out Hook: THook; Func: THookFunction; Data: APTR);
begin
  Hook.h_Entry    := @HookEntry;
  Hook.h_SubEntry := Func;
  Hook.h_Data     := Data;
end;
{$ENDIF}


{$IFDEF CPU86}
function  _hookEntry(h: PHook; obj: PObject_; Msg: Pointer): LongWord; cdecl;
var
  Func: THookFunction;
begin
  {$PUSH}{$HINTS OFF}
  Func   := THookFunction(h^.h_SubEntry);
  {$POP}
  result := Func(h, obj, msg);
end;

procedure InitHook(Out Hook: THook; Func: THookFunction; Data: APTR);
begin
  {$PUSH}{$HINTS OFF}
  Hook.h_Entry    := IPTR(@_hookEntry);
  Hook.h_SubEntry := IPTR(Func);
  {$POP}
  Hook.h_Data     := Data;
end;
{$ENDIF}


{$IFDEF CPUPOWERPC}
procedure InitHook(Out Hook: THook; Func: THookFunction; Data: APTR);
const 
  HOOKENTRY_TRAP: TEmulLibEntry = ( Trap: TRAP_LIB; Extension: 0; Func: @HookEntry );
begin
  Hook.h_Entry    := @HOOKENTRY_TRAP;
  Hook.h_SubEntry := Func;
  Hook.h_Data     := Data;
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Tags
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AROS}
Function  TAG_(TagItem: LongWord): LongInt; inline;
begin
  Result := LongInt(TagItem);
end;

Function  TAG_(TagItem: LongInt): LongInt; inline;
begin
  Result := LongInt(TagItem);
end;

Function  TAG_(TagItem: Pointer): LongInt; inline;
begin
  {$PUSH}{$HINTS OFF}
  Result := LongInt(TagItem);
  {$POP}
end;

function  TAG_(TagItem: boolean): LongInt; inline; 
begin
  Result := Ord(TagItem);
end;
{$ENDIF}



{$IFDEF AMIGA}
Function  TAG_(TagItem: LongWord): LongInt; inline;
begin
  Result := LongInt(TagItem);
end;

Function  TAG_(TagItem: LongInt): LongInt; inline;
begin
  Result := LongInt(TagItem);
end;

Function  TAG_(TagItem: Pointer): LongInt; inline;
begin
  {$PUSH}{$HINTS OFF}
  Result := LongInt(TagItem);
  {$POP}
end;

function  TAG_(TagItem: boolean): LongInt; inline; 
begin
  Result := Ord(TagItem);
end;
{$ENDIF}



{$IFDEF MORPHOS}
Function  TAG_(TagItem: LongInt): LongWord; inline;
begin
  Result := LongWord(TagItem);
end;

Function  TAG_(TagItem: LongWord): LongWord; inline;
begin
  Result := LongWord(TagItem);
end;

Function  TAG_(TagItem: Pointer): LongWord; inline;
begin
  {$PUSH}{$HINTS OFF}
  Result := LongWord(TagItem);
  {$POP}
end;

function  TAG_(TagItem: boolean): LongWord; inline;
begin
  Result := Ord(TagItem);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: SetGadgetAttrs(), missing from MorphOS
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
function  SetGadgetAttrs(Gadget: PGadget; Window: PWindow; Requester: PRequester; const Tags: array of long): ULONG;
begin
  result := SetGadgetAttrsA(Gadget, Window, Requester, @Tags[0]);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: DoMethod()
//
//////////////////////////////////////////////////////////////////////////////



function  DoMethod(obj : pointer; MethodID: ULONG): ULONG;
Var
  Tags : Array[0..0] of ULONG;
begin
  Tags[0] := MethodID;
  Result := CALLHOOKPKT(PHook(OCLASS(obj)), obj, @(Tags[0]));
end;

{$IFDEF AMIGA}
operator := (Src: TVarRec) Dest: LongWord;
begin
  Case Src.vtype of
    {$PUSH}{$HINTS OFF}
    vtinteger  : Dest := PtrInt(Src.vinteger);
    vtboolean  : Dest := PtrInt(Src.vboolean);
    vtpchar    : Dest := PtrInt(Src.vpchar);
    vtchar     : Dest := PtrInt(Src.vchar);
    vtstring   : Dest := PtrInt(PChar(string(Src.vstring^)));
    vtpointer  : Dest := PtrInt(Src.vpointer);
    {$POP}
  end; 
end;

function  DoMethod(obj : pointer; MethodID: ULONG; const msg : array of const): ULONG; overload;
Var
  Tags : Array of LongWord; i,n: integer;
begin
  SetLength(Tags, Length(msg) + 1);

  i := 0;
  Tags[i] := MethodID;

  for n := low(msg) to high(msg) do
  begin
    inc(i);   
    Tags[i] := msg[n];  // See operator
  end;

  Result := CALLHOOKPKT(PHook(OCLASS(Obj)), Obj, @(Tags[0]));
  
  SetLength(Tags, 0);
end;
{$ENDIF}

{$IFDEF MORPHOS}
function  DoMethod(obj : pointer; MethodID: ULONG; const msg : array of ULONG): ULONG; overload;
Var
  Tags : Array of LongWord; i,n: integer;
begin
  SetLength(Tags, Length(msg) + 1);

  i := 0;
  Tags[i] := MethodID;

  for n := low(msg) to high(msg) do
  begin
    inc(i);
    Tags[i] := msg[n];
  end;

  Result := CALLHOOKPKT(PHook(OCLASS(Obj)), Obj, @(Tags[0]));
  SetLength(Tags, 0);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: DoSuperMethod()
//         Amiga          : Missing
//         MorphOS + AROS : wrong parameter declaration
//         ALL            : missing none msg version
//
//////////////////////////////////////////////////////////////////////////////



function  DoSuperMethod(cl: pointer; obj : pointer; id: LongWord): LongWord; overload;
Var
  Tags : Array[0..0] of LongWord;
begin
  Tags[0] := id;
  Result  := DoSuperMethodA(cl, obj, @tags[0]);
end;



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS) or DEFINED(AROS)}
function  DoSuperMethod(cl: pointer; obj : pointer; id: LongWord; const msg : array of LongWord): longword; overload;
Var
  Tags : Array of LongWord; i,n: integer;
begin
  SetLength(Tags, Length(msg) + 1);

  i := 0;
  Tags[i] := id;

  for n := low(msg) to high(msg) do
  begin
    inc(i);
    Tags[i] := msg[n];
  end;

  Result := DoSuperMethodA(cl, obj, @tags[0]);
  SetLength(Tags, 0);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: SetAttrs()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AMIGA}
function  SetAttrs(Obj: APTR; tagList: Array of Const): ULONG;
begin
  Result := SetAttrsA(Obj, ReadInTags(tagList));
end;
{$ENDIF}

{$IFDEF MORPHOS}
function  SetAttrs(Obj: APTR; tagList: Array of DWord): ULONG;
begin
  Result := SetAttrsA(Obj, @tagList);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: CoerceMethod()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
{$WARNING MORPHOS implementation of CoerceMethodA() is untested}
function  CoerceMethodA(cl: PIClass; Obj: PObject_; Msg: Pointer): ULONG;
begin
  If   ( (cl <> nil) and (Obj <> nil) ) 
  then result := CALLHOOKPKT(PHook(cl), obj, Msg)
  else result := 0;
end;
{$ENDIF}

{$IFDEF AMIGA}
function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: ULONG): ULONG;
{$ENDIF}
{$IFDEF AROS}
function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: IPTR): IPTR;
{$ENDIF}
{$IFDEF MORPHOS}
function  CoerceMethod(cl: PIClass; Obj: PBoopsiobject; MethodID: ULONG): ULONG;
{$ENDIF}
Var
  Tags : Array[0..0] of ULONG;
begin
  {$IFDEF AROS}
  if ( not(obj <> nil) or not (cl <> nil) ) then exit(0);
  {$ENDIF}
  Tags[0] := MethodID;
  Result := CoerceMethodA(cl, Obj, @(Tags[0]));
end;

{$IFDEF AMIGA}
function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: ULONG; const Msg: array of const): ULONG; overload;
Var
  Tags : Array of LongWord; i,n: integer;
begin
  SetLength(Tags, Length(Msg) + 1);

  i := 0;
  Tags[i] := MethodID;

  for n := low(Msg) to high(Msg) do
  begin
    inc(i);   
    Tags[i] := Msg[n];  // See operator
  end;

  Result := CoerceMethodA(cl, Obj, @(Tags[0]));
  
  SetLength(Tags, 0);
end;
{$ENDIF}

{$IFDEF MORPHOS}
function  CoerceMethod(cl: PIClass; Obj: PBoopsiObject; MethodID: ULONG; const Msg: array of ULONG): ULONG;
Var
  Tags : Array of LongWord; i,n: integer;
begin
  SetLength(Tags, Length(Msg) + 1);

  i := 0;
  Tags[i] := MethodID;

  for n := low(Msg) to high(Msg) do
  begin
    inc(i);
    Tags[i] := Msg[n];
  end;

  Result := CoerceMethodA(cl, Obj, @(Tags[0]));

  SetLength(Tags, 0);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: OBJ_xxx macro's (blatant copy from AROS)
//
//////////////////////////////////////////////////////////////////////////////



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
function OBJ_App(obj : APTR) : PObject_;
begin
  OBJ_App := MUIGlobalInfo(obj)^.mgi_ApplicationObject;
end;

function OBJ_Win(obj : APTR) : PObject_;
begin
  OBJ_Win := MUIRenderInfo(obj)^.mri_WindowObject;
end;

function OBJ_Dri(obj : APTR) : pDrawInfo;
begin
  OBJ_Dri := MUIRenderInfo(obj)^.mri_DrawInfo;
end;

function OBJ_Screen(obj : APTR) : pScreen;
begin
  OBJ_Screen := MUIRenderInfo(obj)^.mri_Screen;
end;

function OBJ_Pens(obj : APTR) : pWord;
begin
  OBJ_Pens := MUIRenderInfo(obj)^.mri_Pens;
end;

function OBJ_Window(obj : APTR) : pWindow;
begin
  OBJ_Window := MUIRenderInfo(obj)^.mri_Window;
end;

function OBJ_Rp(obj : APTR) : pRastPort;
begin
  OBJ_Rp := MUIRenderInfo(obj)^.mri_RastPort;
end;

function OBJ_Left(obj : APTR) : smallint;          
begin
  OBJ_Left := MUIAreaData(obj)^.mad_Box.Left;
end;

function OBJ_Top(obj : APTR) : smallint;           
Begin
  OBJ_Top := MUIAreaData(obj)^.mad_Box.Top;
end;

function OBJ_Width(obj : APTR) : smallint;         
begin
  OBJ_Width := MUIAreaData(obj)^.mad_Box.Width;
end;

function OBJ_Height(obj : APTR) : smallint;        
begin
  OBJ_Height := MUIAreaData(obj)^.mad_Box.Height;
end;

function OBJ_Right(obj : APTR) : smallint;         
begin
  OBJ_Right := OBJ_Left(obj) + OBJ_Width(obj) -1;
end;

function OBJ_Bottom(obj : APTR) : smallint;        
begin
  OBJ_Bottom := OBJ_Top(obj) + OBJ_Height(obj) -1;
end;

function OBJ_AddLeft(obj : APTR) : smallint;       
begin
  OBJ_AddLeft := MUIAreaData(obj)^.mad_AddLeft;
end;

function OBJ_AddTop(obj : APTR) : smallint;
begin
  OBJ_AddTop := MUIAreaData(obj)^.mad_AddTop;
end;

function OBJ_SubWidth(obj : APTR) : smallint;
begin
  OBJ_SubWidth := MUIAreaData(obj)^.mad_SubWidth;
end;

function OBJ_SubHeight(obj : APTR) : smallint;
begin
  OBJ_SubHeight := MUIAreaData(obj)^.mad_SubHeight;
end;

function OBJ_MLeft(obj : APTR) : smallint;
begin
  OBJ_MLeft := OBJ_Left(obj) + OBJ_AddLeft(obj);
end;

function OBJ_MTop(obj : APTR) : smallint;
begin
  OBJ_MTop := OBJ_Top(obj) + OBJ_AddTop(obj);
end;

function OBJ_MWidth(obj : APTR) : smallint;
begin
  OBJ_MWidth := OBJ_Width(obj) -OBJ_SubWidth(obj);
end;

function OBJ_MHeight(obj : APTR) : smallint;
begin
  OBJ_MHeight := OBJ_Height(obj) - OBJ_SubHeight(obj);
end;

function OBJ_MRight(obj : APTR) : smallint;
begin
  OBJ_MRight := OBJ_MLeft(obj) + OBJ_MWidth(obj) -1;
end;

function OBJ_MBottom(obj : APTR) : smallint;
begin
  OBJ_MBottom := OBJ_MTop(obj) + OBJ_MHeight(obj) -1;
end;

function OBJ_Font(obj : APTR) : pTextFont;
begin
  OBJ_Font := MUIAreaData(obj)^.mad_Font;
end;

function OBJ_MinWidth(obj : APTR) : LongWord;
begin
  OBJ_MinWidth := MUIAreaData(obj)^.mad_MinMax.MinWidth;
end;

function OBJ_MinHeight(obj : APTR) : LongWord;
begin
  OBJ_MinHeight := MUIAreaData(obj)^.mad_MinMax.MinHeight;
end;

function OBJ_MaxWidth(obj : APTR) : LongWord;
begin
  OBJ_maxWidth := MUIAreaData(obj)^.mad_MinMax.MaxWidth;
end;

function OBJ_MaxHeight(obj : APTR) : LongWord;
begin
  OBJ_maxHeight := MUIAreaData(obj)^.mad_MinMax.MaxHeight;
end;

function OBJ_DefWidth(obj : APTR) : LongWord;
begin
  OBJ_DefWidth := MUIAreaData(obj)^.mad_MinMax.DefWidth;
end;

function OBJ_DefHeight(obj : APTR) : LongWord;
begin
  OBJ_DefHeight := MUIAreaData(obj)^.mad_MinMax.DefHeight;
end;

function OBJ_Flags(obj : APTR) : LongWord;
begin
  OBJ_Flags := MUIAreaData(obj)^.mad_Flags;
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: CreatePort(), DeletePort()
//
//////////////////////////////////////////////////////////////////////////////



{$IF DEFINED(AROS) or DEFINED(MORPHOS)}
function  CreatePort(name: STRPTR; pri: LONG): pMsgPort;
Var
  mp: pMsgPort;
begin
  mp := CreateMsgPort;

  if (mp <> nil) then
  begin
    mp^.mp_Node.ln_Name := name;
    mp^.mp_Node.ln_Pri  := pri;

    if (name <> nil) 
    then AddPort(mp);
  end;
  result := mp;
end;


procedure DeletePort (mp: pMsgPort);
begin
  if (mp^.mp_Node.ln_Name <> nil)
  then RemPort(mp);

  DeleteMsgPort (mp);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: CreateExtIO(), DeleteExtIO()
//
//////////////////////////////////////////////////////////////////////////////



{$IF DEFINED(AROS) or DEFINED(MORPHOS)}
function  CreateExtIO(port: pMsgPort; iosize: ULONG): pIORequest;
var
   ioreq: pIORequest;
begin
  ioreq := nil;

  if (port <> nil) then
  begin
    ioreq := ExecAllocMem(iosize, MEMF_CLEAR or MEMF_PUBLIC);
    if (ioreq <> nil) then
    begin
      //* Initialize the structure */
      ioreq^.io_Message.mn_Node.ln_Type := NT_MESSAGE;
      ioreq^.io_Message.mn_ReplyPort    := port;
      ioreq^.io_Message.mn_Length       := iosize;
    end;
  end;
  Result := ioreq;
end;


procedure DeleteExtIO(ioreq: pIORequest);
begin
  if (ioreq <> nil) then
  begin
    //* Erase some fields to enforce crashes */
    ioreq^.io_Message.mn_Node.ln_Type := $FF;

    ioreq^.io_Device := pDevice(-1);
    ioreq^.io_Unit   := pUnit(-1);

    //* Free the memory */
    ExecFreeMem(ioreq, ioreq^.io_Message.mn_Length);
  end;
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: AllocDosObjectTags()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
function AllocDosObjectTags(const Type_: LongWord; const Tags: array of LONG): APTR;
begin
  AllocDosObjectTags := AllocDosObject(Type_, @Tags[0]);
end;  
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: FPrintf()
//
//////////////////////////////////////////////////////////////////////////////



function FPrintf(fh: BPTR; fmt: STRPTR): LONG;
begin
  Result := VFPrintf(fh, fmt, nil);
end;

{$IFDEF AROS}
function FPrintf(fh: BPTR; fmt: STRPTR; argsarray: array of IPTR): LONG;
{$ENDIF}
{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
function FPrintf(fh: BPTR; fmt: STRPTR; argsarray: array of NativeUInt): LONG;
{$ENDIF}
begin
  Result := VFPrintf(fh, fmt, @argsarray[0]);
end;



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: ObtainBestPne()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
function  ObtainBestPen(cm: pColorMap; R: ULONG; G: ULONG; B: ULONG; taglist: array of DWord): LONG;
begin
  ObtainBestPen := ObtainBestPenA(cm, R, G, B, @taglist);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: macro RASSIZE
//
//////////////////////////////////////////////////////////////////////////////



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
function RasSize(w, h: Word): Integer;
begin
  Result := h * (((w + 15) shr 3) and $FFFE);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: EasyRequest()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AMIGA}
function EasyRequest(Window: PWindow; EasyStruct: PEasyStruct; IDCMP_Ptr: PULONG; const tagList: array of const): LONG;
begin
  EasyRequest := EasyRequestArgs(Window, EasyStruct, IDCMP_Ptr, Readintags(tagList));
end;
{$ENDIF}

{$IFDEF MORPHOS}
function EasyRequest(Window: PWindow; EasyStruct: PEasyStruct; IDCMP_Ptr: PULONG; tagList: array of ULONG): LONG;
begin
  EasyRequest := EasyRequestArgs(Window, EasyStruct, IDCMP_Ptr, @tagList);
end;
{$ENDIF}

{$IFDEF HASAMIGA}
function EasyRequest(Window: PWindow; EasyStruct: PEasyStruct; IDCMP_Ptr: PULONG): LONG;
begin
  EasyRequest := EasyRequestArgs(Window, EasyStruct, IDCMP_Ptr, nil);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: AllocAslRequestTags
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AROS}
function  AllocAslRequestTags(reqType: ULONG; Const tags: Array of const): APTR;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  AllocAslRequestTags := AllocAslRequest(reqType, GetTagPtr(TagList));
end;
{$ENDIF}

{$IF DEFINED(AMIGA) or DEFINED(AROS)}
function  AslRequestTags(Requester: APTR; const Tags: array of const): LongBool;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  AslRequestTags := AslRequest(Requester, GetTagPtr(TagList));
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: FPuts()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AMIGA}
function  FPuts(fh: BPTR; const str: string): LONG;
begin
  FPuts := FPuts(fh, PChar(RawByteString(str)));
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Printf()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AROS}
function Printf(fmt: STRPTR; Argv: array of LONG): LONG;
begin
  Printf := VPrintf(fmt, IPTR(Argv[0]));
end;
{$ENDIF}
{$IFDEF MORPHOS}
function Printf(fmt: STRPTR; Argv: array of LONG): LONG;
begin
  Printf := VPrintf(fmt, @Argv);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: NewList()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
procedure NewList(List: PList); inline;
begin
  if Assigned(List) then
  begin
    List^.lh_TailPred := PNode(List);
    List^.lh_Tail := nil;
    List^.lh_Head := @List^.lh_Tail;
  end;
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: DoDTMethod()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AMIGA}
function DoDTMethod(o: PObject_; win: PWindow; req: PRequester; const msg: array of const): ULONG; Inline;
begin
  DoDTMethod := DoDTMethodA(o, win, req, readinlongs(msg));
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: NewDTObject, DoDTMethod
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
function  NewDTObject(name: PChar; attrs: array of LongWord): PObject_; Inline;
begin
  NewDTObject := NewDTObjectA(name, @attrs);
end;

function  DoDTMethod(o: PObject_; win: PWindow; req: PRequester; msg: array of LongInt): ULONG; Inline;
begin
  DoDTMethod := DoDTMethodA(o, win, req, @msg);
end;

function  GetDTAttrs(o: PObject_; attrs : array of LongWord): ULONG; Inline;
begin
  GetDTAttrs := GetDTAttrsA(o, @attrs);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic:  AROS gadtools varargs version routines
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AROS}
function  CreateGadget(kind: ULONG; previous: PGadget; ng: PNewGadget; const Tags: array of const): PGadget;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  CreateGadget := CreateGadgetA(kind, previous, ng, GetTagPtr(TagList));
end;


function  CreateMenus(newmenu: PNewMenu; const Tags: array of const): PMenu;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  CreateMenus := CreateMenusA(newmenu, GetTagPtr(TagList));
end;


procedure DrawBevelBox(rport: PRastPort; left: SmallInt; top: SmallInt; width: SmallInt; Height: SmallInt; const Tags: array of const);
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  DrawBevelBoxA(rport, left, top, width, height, GetTagPtr(TagList));
end;


function  GetVisualInfo(Screen: PScreen; const Tags: array of const): APTR;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  GetVisualInfo := GetVisualInfoA(Screen, GetTagPtr(TagList));
end;


function  GT_GetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const Tags: array of const): LongInt;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  GT_GetGadgetAttrs := GT_GetGadgetAttrsA(gad, win, req, GetTagPtr(TagList));
end;


procedure GT_SetGadgetAttrs(gad: PGadget; win: PWindow; req: PRequester; const Tags: array of const);
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  GT_SetGadgetAttrsA(gad, win, req, GetTagPtr(TagList));
end;


function  LayoutMenuItems(menuitem: PMenuItem; vi: APTR; const Tags: array of const): LongBool;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  LayoutMenuItems := LayoutMenuItemsA(menuitem, vi, GetTagPtr(TagList));
end;


function  LayoutMenus(menu: PMenu; vi: APTR; const Tags: array of const): LongBool;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  LayoutMenus := LayoutMenusA(menu, vi, GetTagPtr(TagList));
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: AddAppIcon
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AMIGA}
function AddAppIcon(id: ULONG; userdata: ULONG; txt: PChar; msgport: PMsgPort; lock: BPTR; diskobj: PDiskObject; const Tags: array of const): PAppIcon;
begin
  AddAppIcon := AddAppIconA(id, userdata, txt, msgport, lock, diskobj, ReadInTags(Tags));
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////



function INST_DATA(cl: PIClass; o: Pointer): Pointer;
begin
  INST_DATA := Pointer(PtrUInt(o) + cl^.cl_InstOffset);
end;



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: DrawCircle
//
//////////////////////////////////////////////////////////////////////////////



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
procedure DrawCircle(Rp: PRastPort; xCenter, yCenter, r: LongInt); inline;
begin
  DrawEllipse(Rp, xCenter, yCenter, r, r);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: SetWindowPointer()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AMIGA}
Procedure SetWindowPointer(window: PWindow; const Tags: array of const);
begin
  SetWindowPointerA(window, ReadInTags(Tags));
end;
{$ENDIF}
{$IFDEF MORPHOS}
Procedure SetWindowPointer(window: PWindow; const tagArray: array of ULONG);
begin
  SetWindowPointerA(window, @tagArray);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: BestModeID()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
function  BestModeID(Const tagArray: Array Of ULONG): ULONG;
begin
  BestModeID := BestModeIDA(@tagArray);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: Systemtags()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF MORPHOS}
function  SystemTags(const Command: STRPTR; const TagArray: array of ULONG): LONG;
begin
  Systemtags := SystemTagList(Command, @tagArray);
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: NewCreateTask()
//
//////////////////////////////////////////////////////////////////////////////



{$IFDEF AROS}
function  NewCreateTask(const Tags: array of const): PTask;
var
  TagList: TTagsList;
begin
  {$PUSH}{$HINTS OFF}
  AddTags(TagList, Tags);
  {$POP}
  NewCreateTask := NewCreateTaskA(GetTagPtr(TagList));
end;
{$ENDIF}



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////

end.
