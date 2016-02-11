program mapansi;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : mapansi
  Topic     : Map Intuition RAWKEY events to ANSI with MapRawKey().
  Source    : RKRM
}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDos, InputEvent, KeyMap, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  Trinity,
  CHelpers,
  SysUtils;


Var
  Window    : PWindow = nil;


  //* our function prototypes */
  procedure openall; forward;
  procedure closeall; forward;
  procedure closeout(errstring: PChar; rc: LONG); forward;



function  Main(argc: Integer; argv: PPChar): Integer;
var
  imsg          : PIntuiMessage;
  eventptr      : APTR;
  inputevt      : TInputEvent;
  windowsignal  : LONG;
  buffer        : array[0..Pred(8)] of Char;
  i             : Integer;
  done          : Boolean = FALSE;
begin
  inputevt := default(TInputEvent);
  
  openall();

  window := OpenWindowTags(nil,
  [
    TAG_(WA_Width)   , 500,
    TAG_(WA_Height)  , 60,
    TAG_(WA_Title)   , TAG_(PChar('MapRawKey - Press Keys')),
    TAG_(WA_Flags)   , WFLG_CLOSEGADGET or WFLG_ACTIVATE,
    TAG_(WA_IDCMP)   , IDCMP_RAWKEY or IDCMP_CLOSEWINDOW,
    TAG_DONE
  ]);
  if (window = nil) then closeout('Can''t open window', RETURN_FAIL);

  windowsignal := 1 shl window^.UserPort^.mp_SigBit;

  //* Initialize InputEvent structure (already cleared to 0) */
  inputevt.ie_Class := IECLASS_RAWKEY;

  while not(Done) do
  begin
    Wait(windowsignal);

    while SetAndTest(imsg, PIntuiMessage(GetMsg(window^.UserPort))) do
    begin
      case (imsg^.IClass) of
        IDCMP_CLOSEWINDOW:
        begin
          Done := TRUE;
        end;
        IDCMP_RAWKEY:
        begin
          inputevt.ie_Code := imsg^.Code;
          inputevt.ie_Qualifier := imsg^.Qualifier;

          WriteLn(Format('RAWKEY: Code=$%.4x  Qualifier=$%.4x', [imsg^.Code, imsg^.Qualifier]));

          {* Make sure deadkeys and qualifiers are taken
           * into account.
           *}
          eventptr := imsg^.IAddress;
          inputevt.ie_position.ie_addr := APTR(eventptr^);

          //* Map RAWKEY to ANSI */
          i := MapRawKey(@inputevt, @buffer, 8, nil);

          if (i = -1) then DOSWrite(DOSOutput, PChar('*Overflow*'), 10)
          else if (i <> 0) then
          begin
            //* This key or key combination mapped to something */
            Write('MAPS TO: ');
            DOSWrite(DOSOutput, @buffer, i);
            WriteLn;
          end;
        end;
      end;
      ReplyMsg(PMessage(imsg));
    end;
  end;
  CloseWindow(window);
  closeall();
  Result := (RETURN_OK);
end;


procedure openall;
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  KeymapBase := OpenLibrary('keymap.library', 37);
  if (KeymapBase = nil)    then closeout('Kickstart 2.0 required', RETURN_FAIL);
  {$ENDIF}
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  if (IntuitionBase = nil) then closeout('Can''t open intuition', RETURN_FAIL);
  {$ENDIF}
end;


procedure closeall;
begin
  {$IFDEF MORPHOS}
  if assigned(IntuitionBase) then CloseLibrary(PLibrary(IntuitionBase));
  {$ENDIF}
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if assigned(KeymapBase) then CloseLibrary(KeymapBase);
  {$ENDIF}
end;


procedure closeout(errstring: PChar; rc: LONG);
begin
  if (errstring^ <> #0) then WriteLn(errstring);
  closeall;
  halt(rc);
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
