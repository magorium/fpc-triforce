program strhooks;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : strhooks
  Topic     : string gadget hooks demo
  Source    : RKRM
}
 
{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AGraphics, Intuition, utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  CHelpers,
  Trinity;


const
  SG_STRLEN     = (44);
  MYSTRGADWIDTH = (200);
  INIT_LATER    = 0;


  //* A border for the string gadget */

  strBorderData : Array[0..9] of UWORD = //* init elements 5 and 7 later (height adjust) */
  (
    0, 0,  MYSTRGADWIDTH + 3,0,  MYSTRGADWIDTH + 3, INIT_LATER,
    0, INIT_LATER,   0, 0
  );

  strBorder : TBorder =
  (
    LeftEdge    : -2;
    TopEdge     : -2;
    FrontPen    : 1;
    BackPen     : 0;
    DrawMode    : JAM1;
    Count       : 5;
    XY          : @strBorderData;
    NextBorder  : nil;
  );


Type
  //* We'll dynamically allocate/clear most structures, buffers */
  PVars = ^TVars;
  TVars = record
    sgg_Window  : PWindow;
    sgg_Gadget  : TGadget;
    sgg_StrInfo : TStringInfo;
    sgg_Extend  : TStringExtend;
    sgg_Hook    : THook;
    sgg_Buff    : array[0..Pred(SG_STRLEN)] of UBYTE;
    sgg_WBuff   : array[0..Pred(SG_STRLEN)] of UBYTE;
    sgg_UBuff   : array[0..Pred(SG_STRLEN)] of UBYTE;
  end;

Type
  THookFunction = function(Hook: pHook; obj: APTR; Msg: APTR): LongWord;

  //* our function prototypes */
  function  IsHexDigit(test_char: UBYTE): Boolean; forward;
  function  str_hookRoutine(hook: PHook; sgw: PSGWork; msg: PULONG): ULONG; forward;
  procedure initHook(out hook: THook; ccode: THookFunction); forward;
  procedure handleWindow(vars: PVars); forward;


{*   Main entry point.
**
** Open all required libraries, set-up the string gadget.
** Prepare the hook, open the sgg_Window and go...
*}
procedure Main(argc: Integer; argv: PPChar);
var
  vars      : PVars;
  screen    : PScreen;
  drawinfo  : PDrawInfo;
begin
  {$IFDEF MORPHOS}
  if SetAndtest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
  {$ENDIF}
  begin
    {$IFNDEF HASAMIGA}
    if SetAndtest(Utilitybase, OpenLibrary('utility.library', 37)) then
    {$ENDIF}
    begin
      //* get the correct pens for the screen. */
      if SetAndtest(screen, LockPubScreen(nil)) then
      begin
        if SetAndtest(drawinfo, GetScreenDrawInfo(screen)) then
        begin
          vars := PVars(ExecAllocMem(sizeof(TVars), MEMF_CLEAR));
          if (vars <> nil) then
          begin
            vars^.sgg_Extend.Pens[0] := PWord(drawinfo^.dri_Pens)[FILLTEXTPEN];
            vars^.sgg_Extend.Pens[1] := PWord(drawinfo^.dri_Pens)[FILLPEN];
            vars^.sgg_Extend.ActivePens[0] := PWord(drawinfo^.dri_Pens)[FILLTEXTPEN];
            vars^.sgg_Extend.ActivePens[1] := PWord(drawinfo^.dri_Pens)[FILLPEN];
            vars^.sgg_Extend.EditHook := @(vars^.sgg_Hook);
            vars^.sgg_Extend.WorkBuffer := @vars^.sgg_WBuff[0];
            vars^.sgg_StrInfo.Buffer := @vars^.sgg_Buff[0];
            vars^.sgg_StrInfo.UndoBuffer := @vars^.sgg_UBuff[0];
            vars^.sgg_StrInfo.MaxChars := SG_STRLEN;
            vars^.sgg_StrInfo.Extension := @(vars^.sgg_Extend);

            {* There should probably be a border around the string gadget.
            ** As is, it is hard to locate when disabled.
            *}
            vars^.sgg_Gadget.LeftEdge := 20;
            vars^.sgg_Gadget.TopEdge := 30;
            vars^.sgg_Gadget.Width := MYSTRGADWIDTH;
            vars^.sgg_Gadget.Height := screen^.RastPort.TxHeight;
            vars^.sgg_Gadget.Flags := GFLG_GADGHCOMP or GFLG_STRINGEXTEND;
            vars^.sgg_Gadget.Activation := GACT_RELVERIFY;
            vars^.sgg_Gadget.GadgetType := GTYP_STRGADGET;
            vars^.sgg_Gadget.SpecialInfo := @(vars^.sgg_StrInfo);
            vars^.sgg_Gadget.GadgetRender := APTR(@strBorder);
            strBorderData[5] := screen^.RastPort.TxHeight + 3;
            strBorderData[7] := screen^.RastPort.TxHeight + 3;
                          
            initHook(vars^.sgg_Hook, THookFunction(@str_hookRoutine));

            if SetAndTest(vars^.sgg_Window, OpenWindowTags(nil,
            [
              TAG_(WA_PubScreen)      , TAG_(screen),
              TAG_(WA_Left)           , 21,   
              TAG_(WA_Top)            , 20,
              TAG_(WA_Width)          , 500,   
              TAG_(WA_Height)         , 150,
              TAG_(WA_MinWidth)       , 50,   
              TAG_(WA_MaxWidth)       , TAG_(not(0)),
              TAG_(WA_MinHeight)      , 30,   
              TAG_(WA_MaxHeight)      , TAG_(not(0)),
              TAG_(WA_SimpleRefresh)  , TAG_(TRUE),
              TAG_(WA_NoCareRefresh)  , TAG_(TRUE),
              TAG_(WA_RMBTrap)        , TAG_(TRUE),
              TAG_(WA_IDCMP)          , IDCMP_GADGETUP or IDCMP_CLOSEWINDOW,
              TAG_(WA_Flags)          , WFLG_CLOSEGADGET or WFLG_NOCAREREFRESH or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_SIMPLE_REFRESH,
              TAG_(WA_Title)          , TAG_(PChar('String Hook Accepts HEX Digits Only')),
              TAG_(WA_Gadgets)        , TAG_(@(vars^.sgg_Gadget)),
              TAG_DONE
            ])) then
            begin
              handleWindow(vars);

              CloseWindow(vars^.sgg_Window);
            end;
            ExecFreeMem(vars, sizeof(TVars));
          end;
          FreeScreenDrawInfo(screen, drawinfo);
        end;
        UnlockPubScreen(nil, screen);
      end;
      {$IFNDEF HASAMIGA}
      CloseLibrary(UtilityBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


{*
** This is an example string editing hook, which shows the basics of
** creating a string editing function.  This hook restricts entry to
** hexadecimal digits (0-9, A-F, a-f) and converts them to upper case.
** To demonstrate processing of mouse-clicks, this hook also detects
** clicking on a character, and converts it to a zero.
**
** NOTE: String editing hooks are called on Intuition's task context,
** so the hook may not use DOS and may not cause Wait() to be called.
*}
function  str_hookRoutine(hook: PHook; sgw: PSGWork; msg: PULONG): ULONG;
var
  work_ptr   : PChar;
  return_code: ULONG;
begin
  {* Hook must return non-zero if command is supported.
  ** This will be changed to zero if the command is unsupported.
  *}
  return_code := not(0);

  if (msg^ = SGH_KEY) then
  begin
    //* key hit -- could be any key (Shift, repeat, character, etc.) */

    {* allow only upper case characters to be entered.
    ** act only on modes that add or update characters in the buffer.
    *}
    if (
         (sgw^.EditOp = EO_REPLACECHAR) or
         (sgw^.EditOp = EO_INSERTCHAR)
       ) then
    begin
      {* Code contains the ASCII representation of the character
      ** entered, if it maps to a single byte.  We could also look
      ** into the work buffer to find the new character.
      **
      **     sgw->Code == sgw->WorkBuffer[sgw->BufferPos - 1]
      **
      ** If the character is not a legal hex digit, don't use
      ** the work buffer and beep the screen.
      *}
      if not(IsHexDigit(sgw^.Code)) then
      begin
        sgw^.Actions := sgw^.Actions or SGA_BEEP;
        sgw^.Actions := sgw^.Actions and not(SGA_USE);
      end
      else
      begin
        //* And make it upper-case, for nicety */
        sgw^.WorkBuffer[sgw^.BufferPos - 1] := ToUpper(sgw^.Code);
      end;
    end;
  end
  else if (msg^ = SGH_CLICK) then
  begin
    {* mouse click
    ** zero the digit clicked on
    *}
    if (sgw^.BufferPos < sgw^.NumChars) then
    begin
      work_ptr := sgw^.WorkBuffer + sgw^.BufferPos;
      work_ptr^ := '0';
    end;
  end
  else
  begin
    {* UNKNOWN COMMAND
    ** hook should return zero if the command is not supported.
    *}
    return_code := 0;
  end;

  Result := (return_code);
end;


{*
** This is a function which converts register-parameter
** hook calling convention into standard C conventions.
** It only works with SAS C 5.0+
**
** Without the fancy __asm stuff, you'd probably need to
** write this in assembler.
**
** You could conceivably declare all your C hook functions
** this way, and eliminate the middleman (you'd initialize
** the h_Entry field to your C function's address, and not
** bother with the h_SubEntry field).
**
** This is nice and easy, though, and since we're using the
** small data model, using a single interface routine like this
** (which does the necessary __saveds), it might
** actually turn out to be smaller to use a single entry point
** like this rather than declaring each of many hooks __saveds.
*}
{$IFDEF CPU68}
procedure hookEntry; assembler; 
asm
  move.l a1,-(a7)    // Msg
  move.l a2,-(a7)    // Obj
  move.l a0,-(a7)    // PHook
  move.l 12(a0),a0   // h_SubEntry = Offset 12
  jsr (a0)           // Call the SubEntry
end;
{$ENDIF}

{$IFDEF CPU86}
function hookEntry(hookptr: PHook; obj: Pointer; msg: Pointer): ULONG; cdecl;
var
  Func: THookFunction;
begin
  func   := THookFunction(hookptr^.h_SubEntry);
  result := Func(hookptr, obj, msg);
end;
{$ENDIF}


{$IFDEF CPUPOWERPC}
type
  THookSubEntryFunc = function(a, b, c: Pointer): longword;

function HookEntry: longword;
var
  hook: PHook;
begin
  hook:=REG_A0;
  HookEntry:=THookSubEntryFunc(hook^.h_SubEntry)(hook, REG_A2, REG_A1);
end;
{$ENDIF}


{*
** Initialize the hook to use the hookEntry() routine above.
*}
{$IFDEF CPU68}
procedure initHook(out hook: THook; ccode: THookFunction);
begin
  hook.h_Entry    := @hookEntry;
  hook.h_SubEntry := ccode;
  hook.h_Data     := nil;    //* this program does not use this */
end;
{$ENDIF}

{$IFDEF CPU86}
procedure initHook(out hook: THook; ccode: THookFunction);
begin
  Hook.h_Entry    := IPTR(@hookEntry);
  Hook.h_SubEntry := IPTR(ccode);
  Hook.h_Data     := nil;
end;
{$ENDIF}

{$IFDEF CPUPOWERPC}
procedure InitHook(Out Hook: THook; ccode: THookFunction);
const 
  HOOKENTRY_TRAP: TEmulLibEntry = ( Trap: TRAP_LIB; Extension: 0; Func: @HookEntry );
begin
  Hook.h_Entry    := @HOOKENTRY_TRAP;
  Hook.h_SubEntry := ccode;
  Hook.h_Data     := nil;
end;
{$ENDIF}


{*
** Process messages received by the sgg_Window.  Quit when the close gadget
** is selected.
*}
procedure handleWindow(vars: PVars);
var
  msg       : PIntuiMessage;
  iclass    : ULONG;
  code      : SmallInt;
begin
  While true do
  begin
    Wait(1 shl vars^.sgg_Window^.UserPort^.mp_SigBit);
    while SetAndTest(msg, PIntuiMessage(GetMsg(vars^.sgg_Window^.UserPort))) do
    begin
      {* Stash message contents and reply, important when message
      ** triggers some lengthy processing
      *}
      iclass := msg^.IClass;
      code   := msg^.Code;
      ReplyMsg(PMessage(msg));

      case (iclass) of
        IDCMP_GADGETUP:
          {* if a code is set in the hook after an SGH_KEY
          ** command, where SGA_END is set on return from
          ** the hook, the code will be returned in the Code
          ** field of the IDCMP_GADGETUP message.
          *}
          break;
        IDCMP_CLOSEWINDOW:
          exit;
      end;
    end;
  end;
end;


{*
** IsHexDigit()
**
** Return TRUE if the character is a hex digit (0-9, A-F, a-f)
*}
function  IsHexDigit(test_char: UBYTE): Boolean;
var
  testchar : Char;
begin
  testchar := ToUpper(test_char);
  if (
       ((testchar >= '0') and (testchar <= '9')) or
       ((testchar >= 'A') and (testchar <= 'F'))
     )
  then Result := (TRUE)
  else Result := (FALSE);
end;


begin
  Main(Argc, ArgV);
end.
