program maus;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

{
  ===========================================================================
  Project : maus
  Topic   : How to query the mouse in an intuition-window
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/maus.c
  ===========================================================================

  This example was originally written in c by Thomas Rapp.

  The original examples are available online and published at Thomas Rapp's 
  website (http://thomas-rapp.homepage.t-online.de/examples)

  The c-sources were converted to Free Pascal, and (variable) names and 
  comments were translated from German into English as much as possible.

  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc

  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Conversion to Free Pascal and translation was done by Magorium in 2015, 
  with kind permission from Thomas Rapp to be able to publish.

  ===========================================================================  

        Unless otherwise noted, you must consider these examples to be 
                 copyrighted by their respective owner(s)

  ===========================================================================  
}

//*-------------------------------------------------------------------------*/
//* System Includes                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AGraphics, Intuition, InputEvent, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure print_text(rp: PRastPort; x: LongInt; y: LongInt; txt: PChar);
begin
  GfxMove(rp, x, y);
  SetABPenDrMd(rp, 1, 0, JAM2);
  GfxText(rp, txt, strlen(txt));
  ClearEOL(rp);
end;


//*-------------------------------------------------------------------------*/
//* Main routine                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  win       : PWindow;
  cont      : Boolean;
  mess      : PIntuiMessage;
  buffer    : String[80];
begin
  if SetAndTest(win, OpenWindowTags( nil,
  [
    TAG_(WA_Left)         , 100,
    TAG_(WA_Top)          , 100,
    TAG_(WA_Width)        , 250,
    TAG_(WA_Height)       , 150,
    TAG_(WA_Flags)        , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH or WFLG_RMBTRAP or WFLG_REPORTMOUSE),
    TAG_(WA_IDCMP)        , TAG_(IDCMP_CLOSEWINDOW or IDCMP_MOUSEMOVE or IDCMP_MOUSEBUTTONS),
    TAG_END
  ])) then
  begin
    cont := TRUE;

    while (cont) do
    begin
      WaitPort(win^.UserPort);
      while SetAndTest(mess, PIntuiMessage(GetMsg(win^.UserPort))) do
      begin
        case (mess^.IClass) of
          IDCMP_CLOSEWINDOW:
            cont := FALSE;
          IDCMP_MOUSEMOVE:
          begin
            WriteStr(buffer, 'Mouseposition: x=', mess^.MouseX, ' y=', mess^.MouseY, #0);
            print_text(win^.RPort, 10, 30, @buffer[1]);
          end;
          IDCMP_MOUSEBUTTONS:
          case (mess^.Code) of
            IECODE_LBUTTON                      : print_text(win^.RPort, 10, 60, 'Left mousebutton pressed');
            IECODE_LBUTTON or IECODE_UP_PREFIX  : print_text(win^.RPort, 10, 60, 'Left mousebutton released');
            IECODE_RBUTTON                      : print_text(win^.RPort, 10, 90, 'Right mousebutton pressed');
            IECODE_RBUTTON or IECODE_UP_PREFIX  : print_text(win^.RPort, 10, 90, 'Right mousebutton released');
          end;
        end; // case
        ReplyMsg(pMessage(mess));
      end;
    end; // while
    CloseWIndow(win);
  end;

  result := (0);
end;

//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/

Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  GfxBase := OpenLibrary(GRAPHICSNAME, 0);
  if not assigned(GfxBase) then Exit;
  {$ENDIF}
  {$IF DEFINED(MORPHOS)}
  IntuitionBase := OpenLibrary(INTUITIONNAME, 0);
  if not assigned(IntuitionBase) then Exit;
  {$ENDIF}

  Result := True;
end;


Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS)}
  if assigned(IntuitionBase) then CloseLibrary(pLibrary(IntuitionBase));
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  if assigned(GfxBase) then CloseLibrary(pLibrary(GfxBase));
  {$ENDIF}
end;


begin
  WriteLn('enter');

  if OpenLibs 
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
  
  WriteLn('leave');
end.
