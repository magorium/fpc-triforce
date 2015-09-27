unit Trinity;


// ---------------------------------------------------------------------------
// Edit Date   $ Entry 
// ---------------------------------------------------------------------------
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
  AmigaLib, tagsarray, MUI;
{$ENDIF}

{$IFDEF MORPHOS}
Uses
  AmigaLib, MUI;
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
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
//
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////



end.
