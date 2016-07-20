program filehook;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : Filehook
  Source    : RKRM
  Note      : This FPC implementation differs from its original c-source 
              counterpart because the latter used obsolete naming scheme.
}

(*
**
** The following example illustrates the use of a hook function for
** both _DOWILDFUNC and _DOMSGFUNC.
**
*)

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AmigaDOS, Intuition, ASL, Utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  sysutils,
  CHelpers,
  Trinity;


Const
  DESTPATLENGTH = 20;

  vers: PChar   = '$VER: filehook 37.0';


Var
  Window        : pWindow  = nil;
  

  //* this is the pattern matching string that the hook function uses */
  sourcepattern : PChar = '(#?.info)';
  pat           : array[0..pred(DESTPATLENGTH)] of Char;


  function HookFunc(mask: ULONG; obj: APTR; fr: pFileRequester): ULONG; cdecl; forward;


Procedure Main(argc: integer; argv: ppchar);
var
  fr: pFileRequester;
begin
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if SetAndTest(AslBase, OpenLibrary('asl.library', 37)) then
  {$ENDIF}
  begin
    {$IFDEF MORPHOS}
    If SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
    {$ENDIF}
    begin
      {* This is a V37 dos.library function that turns a pattern matching
      ** string into something the DOS pattern matching functions can
      ** understand.
      *}
      ParsePattern(sourcepattern, pat, DESTPATLENGTH);

      //* open a window that gets ACTIVEWINDOW events */
      If SetAndTest(window, OpenWindowTags(nil,
      [
        TAG_(WA_Title) , TAG_(PChar('ASL Hook Function Example')),
        TAG_(WA_IDCMP) , IDCMP_ACTIVEWINDOW,
        TAG_(WA_Flags) , WFLG_DEPTHGADGET,
        TAG_END
      ])) then
      begin
        if SetAndTest(fr, AllocFileRequest) then
        begin
          if (AslRequestTags(fr,
          [
            // FPC Note: use modern ASL tags and option parameters
            TAG_(ASLFR_InitialDrawer)  , TAG_(PChar('SYS:Utilities')),
            TAG_(ASLFR_Window)         , TAG_(window),
            TAG_(ASLFR_InitialTopEdge) , 0,
            TAG_(ASLFR_InitialHeight)  , 200,
            TAG_(ASLFR_TitleText)      , TAG_(PChar('Pick an icon, select save')),
            TAG_(ASLFR_HookFunc)       , TAG_(@HOOKfunc), // HookFunc,
            TAG_(ASLFR_Flags1)         , (FRF_FILTERFUNC or FRF_INTUIFUNC or FRF_DOSAVEMODE),
            TAG_(ASLFR_PositiveText)   , TAG_(PChar('Save')),
            TAG_DONE
          ])) then
          begin
            WriteLn(Format('PATH=%s FILE=%s', [fr^.rf_Dir, fr^.rf_File]));
            WriteLn('To combine the path and filename, copy the path');
            WriteLn('to a buffer, add the filename with Dos AddPart().');
          end;
          FreeFileRequest(fr);
        end;
        CloseWindow(window);
      end;
      {$IFDEF MORPHOS}
      CloseLibrary(PLibrary(IntuitionBase));
      {$ENDIF}
    end;
    {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
    CloseLibrary(AslBase);
    {$ENDIF}
  end;
end;


function  HookFunc(mask: ULONG; obj: APTR; fr: pFileRequester): ULONG; cdecl;
var 
  returnvalue : LongBool;
begin
  {$IFDEF AROS}
  Writeln(System.Output, 'HookFunc() initiated:', ' mask = ', mask, ' obj = ', ULONG(OBJ), ' fr = ', ULONG(fr));
  {$ENDIF}

  case Mask of
    // Note: FRF_INTUIFUNC is never send by AROS.
    FRF_INTUIFUNC :     // FILF_DOMSGFUNC 
    begin
      //* We got a message meant for the window */
      WriteLn(System.Output, 'You activated the window');
      Exit(ULONG(obj));
    end;
    FRF_FILTERFUNC :    // FILF_DOWILDFUNC
    begin
      {$IFDEF AROS}
      WriteLn(System.Output, 'do_pattern');
      {$ENDIF}
      {* 
      ** We got an AnchorPath structure, should the requester display this file? 
      *}

      {* 
      ** MatchPattern() is a dos.library function that
      ** compares a matching pattern (parsed by the
      ** ParsePattern() DOS function) to a string and
      ** returns true if they match. 
      *}
      returnvalue := AmigaDos.MatchPattern(pchar(@pat[0]), @pAnchorPath(obj)^.ap_Info.fib_FileName[0]);
       
      {* 
      ** we have to negate MatchPattern()'s return value
      ** because the file requester expects a zero for
      ** a match not a TRUE value 
      *}
      Exit(ULONG(not(returnvalue)));
    end;
  end;
end;


begin
  {$IFDEF AROS}
  WriteLn('This example does not work 100% for AROS.');
  WriteLn('Reason: IDCMP messages are not send to HookFunc()');
  {$ENDIF}
  {$IFDEF MORPHOS}
  WriteLn('Uncertain if the callback works as expected for MorphOS');
  WriteLn('Reason: Callback function seems already prepared internally');
  WriteLn('ToDo: test and act accordingly');
  WriteLn('Note: Do not use InitHook() on Amiga/AROS, as it seems to fail');
  {$ENDIF}
  Main(argc, argv);
end.
