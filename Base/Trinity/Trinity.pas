unit Trinity;


// ---------------------------------------------------------------------------
// Edit Date   $ Entry 
// ---------------------------------------------------------------------------
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
  Exec, Intuition, Utility;



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
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////


implementation


{$IFDEF AMIGA}
Uses
  AmigaLib, tagsarray;
{$ENDIF}

{$IFDEF MORPHOS}
Uses
  AmigaLib;
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
//  Topic: 
//
//////////////////////////////////////////////////////////////////////////////


end.