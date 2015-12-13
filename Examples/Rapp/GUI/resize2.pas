program resize2;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : resize2
  Topic   : colourful redrawing after changing the window size, avoid 
            flickering by using an offline Bitmap
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/resize2.c
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
  Exec, AmigaDos, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;

Type
  float = single;

Const
  M_PI      = 3.14159265358979323846;


//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure set_color(vp: PViewPort; pen: longint; n: longint);
var
  r,g,b : longint;
begin
  n := n mod 1792;

  if ( (n >= 0) and (n <= 255)) then
  begin
    r := 255;
    g := 0;
    b := 255 - n;
  end
  else if ( (n >= 256) and (n <= 511)) then
  begin
    r := 255;
    g := n - 256;
    b := 0;
  end
  else if ( (n >= 512) and (n <= 767)) then
  begin
    r := 767 - n;
    g := 255;
    b := 0;
  end
  else if ((n >= 768) and (n <= 1023)) then
  begin
    r := 0;
    g := 255;
    b := n - 768;
  end
  else if ((n >= 1024) and (n <= 1279)) then
  begin
    r := 0;
    g := 1279 - n;
    b := 255;
  end
  else if ((n >= 1280) and (n <= 1535)) then
  begin
    r := n - 1280;
    g := 0;
    b := 255;
  end;

  SetRGB32(vp, pen, r * $01010101, g * $01010101, b * $01010101);
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

const
  TIMES_SLOWER = 4;


procedure draw_ellipse(rp: PRastPort; left: longint; top: longint; width: longint; height: longint; vp: PViewPort; pen: LONG);
var
  cx    : Longint;
  cy    : longint;
  rx    : longint;
  ry    : longint;
  size  : longint;
  i     : longint;
  factor: float;
var
  a : float;
  x : longint;
  y : longint;
begin
  cx     := left + width div 2;
  cy     := top + height div 2;
  rx     := width div 2 - 1;
  ry     := height div 2 - 1;
  size   := round(M_PI * sqrt(2 * (cx*cx + cy*cy))) * TIMES_SLOWER;
  factor := M_PI / (size / 2.0);
  SetAPen(rp, 2);
  RectFill(rp, left, top, left + width - 1, top + height - 1);
  SetAPen(rp, pen);
  for i := 0 to Pred(size) do
  begin
    a := i * factor;
    x := cx + round(rx * cos(a));
    y := cy + round(ry * sin(a));
    set_color(vp, pen, i * 1536 div size);
    GfxMove(rp, cx, cy);
    Draw(rp, x, y);
  end;
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function min(a: longint; b: longint): Longint;
begin
  if a < b
  then result := a
  else result := b;
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  win       : pWindow;
  imsg      : pIntuiMessage;
  cont      : Boolean;
  redraw    : Boolean;

  vp        : PViewPort;
  pen       : LONG;
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  rp_struct : TRastPort;
  {$ENDIF}
  rp        : PRastPort;
  
  w,h       : Longint;
begin
  if SetAndTest(win, OpenWindowTags( nil,
  [
    TAG_(WA_Left)       , 80,
    TAG_(WA_Top)        , 80,
    TAG_(WA_Width)      , 400,
    TAG_(WA_Height)     , 300,
    TAG_(WA_Title)      , TAG_(PChar('Resize Demo')),
    TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_SIZEGADGET or WFLG_SIZEBRIGHT or WFLG_SIZEBBOTTOM or WFLG_ACTIVATE or WFLG_NOCAREREFRESH),
    TAG_(WA_IDCMP)      , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_NEWSIZE),
    TAG_(WA_MinWidth)   , 80,
    TAG_(WA_MinHeight)  , 60,
    TAG_(WA_MaxWidth)   , $7fff,
    TAG_(WA_MaxHeight)  , $7fff,
    TAG_END
  ])) then
  begin
    vp := @win^.WScreen^.ViewPort;
    pen := ObtainPen(vp^.ColorMap, ULONG(-1), 0, 0, 0, PEN_NO_SETCOLOR);

    {$IFDEF AROS}
    rp := CreateRastPort;
    {$ELSE}
    rp_struct := default(TRastPort);
    rp := @rp_struct;
    InitRastPort(rp);
    {$ENDIF}

    cont := TRUE;
    redraw := TRUE;

    while (cont) do
    begin
      if (redraw) then
      begin
        w := win^.GZZWidth;
        h := win^.GZZHeight;
        if SetAndTest(rp^.BitMap, AllocBitMap(w, h, 8, BMF_MINPLANES, win^.RPort^.BitMap)) then
        begin
          draw_ellipse(rp, 0, 0, w, h, vp, pen);
          BltBitMapRastPort(rp^.BitMap, 0, 0, win^.RPort, win^.BorderLeft, win^.BorderTop, min(w,win^.GZZWidth), min(h, win^.GZZHeight), $c0);
          FreeBitMap(rp^.BitMap);
        end
        else
          draw_ellipse(win^.RPort, win^.BorderLeft, win^.BorderTop, w, h, vp, pen);
        redraw := FALSE;
      end;

      if (Wait ((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
        then cont := FALSE;

      while SetAndTest(imsg, PIntuiMessage(GetMsg(win^.UserPort))) do
      begin
        case (imsg^.IClass) of
          IDCMP_VANILLAKEY:
            if (imsg^.Code = $1b) //* Esc */
            then cont := FALSE;
          IDCMP_NEWSIZE:
            redraw := TRUE;
          IDCMP_CLOSEWINDOW:
            cont := FALSE;
        end;
        ReplyMsg(PMessage(imsg));
      end;
    end;

    ReleasePen(vp^.ColorMap, pen);

    {$IFDEF AROS}
    if assigned(rp) then FreeRastPort(rp);
    {$ENDIF}

    CloseWindow(win);
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
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
end.
