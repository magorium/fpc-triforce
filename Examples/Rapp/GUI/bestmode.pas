program bestmode;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : bestmode
  Topic   : Open a screen with desired dimensions
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/bestmode.c
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
//* Open a public screen with fixed palette                                 */

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
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  width     : LongInt = 640;
  height    : LongInt = 480;
  depth     : LongInt = 24;
  modeid    : ULONG;
  scr       : PScreen;
  win       : PWindow;
  imsg      : PIntuiMessage;
  rp        : pRastPort;
  cont      : boolean;
  buffer    : String[80];
begin
  modeid := BestModeID(
  [
    TAG_(BIDTAG_NominalWidth)     , width,
    TAG_(BIDTAG_NominalHeight)    , height,
    TAG_(BIDTAG_Depth)            , depth,
    TAG_END
  ]);

  if (modeid = ULONG(INVALID_ID)) then
  begin
    WriteLn('no appropiate screen mode available');
    exit(RETURN_ERROR);
  end;

  scr := OpenScreenTags(nil,
  [
    TAG_(SA_LikeWorkbench)  , TAG_(TRUE),
    TAG_(SA_DisplayID)      , modeid,
    TAG_END
  ]);

  if (scr = nil) then
  begin
    WriteLn('cannot open screen');
    exit(RETURN_ERROR);
  end;

  win := OpenWindowTags(nil,
  [
    TAG_(WA_CustomScreen)   , TAG_(scr),
    TAG_(WA_Flags)          , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_SIZEGADGET or WFLG_ACTIVATE or WFLG_NOCAREREFRESH),
    TAG_(WA_IDCMP)          , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY),
    TAG_(WA_MinWidth)       , 200,
    TAG_(WA_MinHeight)      , 100,
    TAG_END
  ]);

  if (win = nil) then
  begin
    WriteLn('cannot open window');
    CloseScreen(scr);
    exit(RETURN_ERROR);
  end;

  rp := win^.RPort;
  SetABPenDrMd(rp, 1, 0, JAM2);
  System.WriteStr(buffer, 'Width  = ', scr^.Width:4);
  GfxMove(rp, 20, 40);
  GfxText(rp, @buffer[1], Length(buffer));
  System.WriteStr(buffer, 'Height = ', scr^.Height:4);
  GfxMove(rp, 20, 60);
  GfxText(rp, @buffer[1], Length(buffer));
  System.WriteStr(buffer, 'Depth  = ', GetBitMapAttr(scr^.RastPort.BitMap, BMA_DEPTH):4);
  GfxMove(rp, 20, 80);
  GfxText(rp, @buffer[1], Length(buffer));

  cont := TRUE;
  while (cont) do
  begin
	if (Wait ((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
    then cont := FALSE;

    while SetAndTest(imsg, PIntuiMessage(GetMsg(win^.UserPort))) do
    begin
      case (imsg^.IClass) of
        IDCMP_VANILLAKEY:
          if (imsg^.Code = $1b) //* Esc */
          then cont := FALSE;
        IDCMP_CLOSEWINDOW:
          cont := FALSE;
      end;
      ReplyMsg(PMessage(imsg));
    end;
  end;

  CloseWindow(win);
  CloseScreen(scr);

  Result := (RETURN_OK);
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
