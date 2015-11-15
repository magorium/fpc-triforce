program region;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : region
  Topic   : Example for clip-regions
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/region.c
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

Uses
  Exec, AmigaDOS, Layers, AGraphics, Intuition, utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//* install_region                                                          */
//*-------------------------------------------------------------------------*/

function  install_region(win: PWindow): PRegion;
var
  reg   : PRegion;
  rect  : TRectangle;
begin
  reg  := NewRegion();

  rect.MinX := 20;
  rect.MinY := 20;
  rect.MaxX := win^.GZZWidth  - 21;
  rect.MaxY := win^.GZZHeight - 21;
  OrRectRegion(reg, @rect);
  rect.MinX := win^.GZZWidth  div 2 - 25;
  rect.MinY := win^.GZZHeight div 2 - 25;
  rect.MaxX := win^.GZZWidth  div 2 + 25;
  rect.MaxY := win^.GZZHeight div 2 + 25;
  XorRectRegion(reg, @rect);
  exit(InstallClipRegion(win^.RPort^.Layer, reg));
end;

//*-------------------------------------------------------------------------*/
//* remove_region                                                           */
//*-------------------------------------------------------------------------*/

procedure remove_region(win: PWindow; oldreg: PRegion);
var
  reg : PRegion;
begin
  reg := InstallClipRegion(win^.RPort^.Layer, oldreg);
  DisposeRegion(reg);
end;

//*-------------------------------------------------------------------------*/
//* draw_line                                                               */
//*-------------------------------------------------------------------------*/

procedure draw_line(win: PWindow);
var
  x1    : LongInt = 100;
  y1    : LongInt = 100;
  x2    : LongInt = 100;
  y2    : LongInt = 100;
  vx1   : LongInt = -4;
  vy1   : LongInt = 1;
  vx2   : LongInt = 2;
  vy2   : LongInt = -3;
  pen   : LongInt = 0;
begin

  x1 := x1 + vx1;
  if (x1 < 0) then
  begin
	x1 := 0;
	vx1 := -vx1;
  end
  else if (x1 >= win^.GZZWidth) then
  begin
    x1 := win^.GZZWidth - 1;
    vx1 := -vx1;
  end;

  y1 := 1 + vy1;
  if (y1 < 0) then
  begin
    y1 := 0;
    vy1 := -vy1;
  end
  else if (y1 >= win^.GZZHeight) then
  begin
    y1 := win^.GZZHeight - 1;
    vy1 := -vy1;
  end;

  x2 := x2 + vx2;
  if (x2 < 0) then
  begin
    x2 := 0;
    vx2 := -vx2;
  end
  else if (x2 >= win^.GZZWidth) then
  begin
    x2 := win^.GZZWidth - 1;
    vx2 := -vx2;
  end;

  y2 := y2 + vy2;
  if (y2 < 0) then
  begin
    y2 := 0;
    vy2 := -vy2;
  end
  else if (y2 >= win^.GZZHeight) then
  begin
    y2 := win^.GZZHeight - 1;
    vy2 := -vy2;
  end;

  pen := pen + 1;
  SetAPen(win^.RPort, pen);
  GfxMove(win^.RPort, x1, y1);
  Draw(win^.RPort, x2, y2);
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
type
  TArgs     = record
    onon    : LongInt;
  end;
var
  rdargs    : PRDArgs;
  args      : TArgs;

  win       : pWindow;
  imsg      : pIntuiMessage;
  cont      : Boolean;
  oldreg    : PRegion;
begin
  args := Default(TArgs);

  rdargs := ReadArgs ('ON/S', APTR(@args), nil);
  if not assigned(rdargs) then
  begin
    PrintFault(IoErr, nil);
    exit(RETURN_ERROR);
  end;

  if SetAndTest(win, OpenWindowTags( nil,
  [
    TAG_(WA_Left)       , 200,
    TAG_(WA_Top)        , 200,
    TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_SIZEGADGET or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH),
    TAG_(WA_IDCMP)      , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_NEWSIZE),
    TAG_(WA_MinWidth)   , 100,
    TAG_(WA_MinHeight)  , 100,
    TAG_(WA_MaxWidth)   , $7fff,
    TAG_(WA_MaxHeight)  , $7fff,
    TAG_(WA_Title)      , TAG_(PChar('Region Test')),
    TAG_END
  ])) then
  begin
    SetAPen(win^.RPort, 0);
    RectFill(win^.RPort, 0, 0, win^.GZZWidth-1, win^.GZZHeight-2);
    oldreg := install_region(win);
    SetAPen(win^.RPort, 1);
    RectFill(win^.RPort, 0, 0, win^.GZZWidth-1, win^.GZZHeight-2);

    cont := TRUE;
    while (cont) do
    begin
      WaitTOF;
      draw_line(win);

      if ((SetSignal(0, 0) and SIGBREAKF_CTRL_C) <> 0)
        then cont := FALSE;

      while SetAndTest(imsg, PIntuiMessage(GetMsg(win^.UserPort))) do
      begin
        case (imsg^.IClass) of
          IDCMP_NEWSIZE:
          begin
            remove_region(win, oldreg);
            SetAPen(win^.RPort, 0);
            RectFill(win^.RPort, 0, 0, win^.GZZWidth-1, win^.GZZHeight-2);
            oldreg := install_region(win);
            SetAPen(win^.RPort, 1);
            RectFill(win^.RPort, 0, 0, win^.GZZWidth-1, win^.GZZHeight-2);
          end;
          IDCMP_VANILLAKEY:
            if (imsg^.Code = $1b)
            then cont := FALSE;
          IDCMP_CLOSEWINDOW:
            cont := FALSE;
        end;
        ReplyMsg(pMessage(imsg));
      end;
    end;

    remove_region (win,oldreg);

    CloseWindow (win);
  end;

  FreeArgs(rdargs);

  Result := (RETURN_OK);    
end;

//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/

Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  LayersBase := OpenLibrary(LAYERSNAME, 0);
  if not assigned(LayersBase)   then Exit;
  GfxBase := OpenLibrary(GRAPHICSNAME, 0);
  if not assigned(GfxBase)      then Exit;
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
  if assigned(GfxBase)       then CloseLibrary(pLibrary(GfxBase));
  if assigned(Layersbase)    then CloseLibrary(pLibrary(LayersBase));
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
