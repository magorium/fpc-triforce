program draw;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

//{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
//{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
//{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

{
  ===========================================================================
  Project : draw
  Topic   : IDCMP input: draw with the mouse
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/draw.c
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
  Exec, AmigaDOS, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


//*-------------------------------------------------------------------------*/
//* Main routine                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  win       : PWindow;
  mess      : PIntuiMessage;
  cont      : Boolean;
  lbutton   : Boolean;
  rbutton   : Boolean;
  old_x     : LongInt;
  old_y     : LongInt;
  x         : LongInt;
  y         : LongInt;
begin
  win := OpenWindowTags( nil,
  [
    TAG_(WA_Left)       , 112,
    TAG_(WA_Top)        , 84,
    TAG_(WA_Width)      , 800,
    TAG_(WA_Height)     , 600,
    TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_SIZEGADGET or WFLG_RMBTRAP or WFLG_REPORTMOUSE or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH),
    TAG_(WA_IDCMP)      , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_MOUSEBUTTONS or IDCMP_MOUSEMOVE),
    TAG_(WA_MinWidth)   , 80,
    TAG_(WA_MinHeight)  , 40,
    TAG_(WA_MaxWidth)   , TAG_(-1),
    TAG_(WA_MaxHeight)  , TAG_(-1),
    TAG_END
  ]);

  if not assigned(win) then
  begin
    WriteLn('cannot open window');
    exit(RETURN_FAIL);
  end;

  rbutton := FALSE;
  lbutton := FALSE;
  x       := win^.MouseX;
  y       := win^.MouseY;
  old_x   := x;
  old_y   := y;

  cont    := TRUE;
  repeat
    if (Wait ((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
        then cont := FALSE;

    while SetAndTest(mess, PIntuiMessage(GetMsg(win^.UserPort))) do
    begin
      case (mess^.IClass) of
        IDCMP_MOUSEMOVE:
        begin
          x := mess^.MouseX - win^.BorderLeft;
          y := mess^.MouseY - win^.BorderTop;
        end;
        IDCMP_MOUSEBUTTONS:
        case (mess^.Code) of
          SELECTDOWN    : lbutton := TRUE;
          SELECTUP      : lbutton := FALSE;
          MENUDOWN      : rbutton := TRUE;
          MENUUP        : rbutton := FALSE;
        end;
        IDCMP_VANILLAKEY:
          if (mess^.Code = $1b) //* Esc */
          then cont := FALSE;
        IDCMP_CLOSEWINDOW:
          cont := FALSE;
      end;
      ReplyMsg(pMessage(mess));
    end;

    if ((x <> old_x) or (y <> old_y)) then
    begin
      if (rbutton and lbutton) then
      begin
        SetAPen(win^.RPort, 3);
        GfxMove(win^.RPort, old_x, old_y);
        AGraphics.Draw(win^.RPort, x, y);
      end
      else if (rbutton) then
      begin
        SetAPen(win^.RPort, 2);
        GfxMove(win^.RPort, old_x, old_y);
        AGraphics.Draw(win^.RPort, x, y);
      end
      else if (lbutton) then
      begin
        SetAPen(win^.RPort, 1);
        GfxMove(win^.RPort, old_x, old_y);
        AGraphics.Draw(win^.RPort, x, y);
      end;
      old_x := x;
      old_y := y;
    end;
  until not(cont);

  CloseWindow(win);

  result := (RETURN_OK);
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
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := RETURN_FAIL;

  CloseLibs;
end.
