program clip;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : clip
  Topic   : Offline bitmap example with clipping
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/clip.c
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
//* System includes                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AmigaDOS, AGraphics, Layers, Intuition, utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


  function  MACRO_RASSIZE(w,h: integer): integer; inline;
  begin
    MACRO_RASSIZE := ((h)*( ((w)+15) shr 3 and $FFFE));
  end;
  
//*-------------------------------------------------------------------------*/
//* Constants and macros                                                    */
//*-------------------------------------------------------------------------*/

Const
  MAXVEC    = 20;   //* maximum number of Area calls before AreaEnd */

//*-------------------------------------------------------------------------*/
//* Type definitions                                                        */
//*-------------------------------------------------------------------------*/

Type
  Pdraw_area = ^Tdraw_area;
  Tdraw_area = record
    bm          : PBitMap;
    rp          : PRastPort;
    layerinfo   : PLayer_Info;
    layer       : PLayer;
    tmpbuf      : ^UBYTE;
    tmpras      : TTmpRas;
    areabuf     : ^UBYTE;
    areainfo    : TAreaInfo;
  end;


//*-------------------------------------------------------------------------*/
//* Free resources of a draw_area structure                                 */
//*-------------------------------------------------------------------------*/

procedure free_draw_area(da: Pdraw_area);
begin
  if (da^.areabuf <> nil)
    then FreeVec(da^.areabuf);

  if (da^.tmpbuf <> nil)
    then FreeVec(da^.tmpbuf);

  if (da^.layer <> nil)
    then DeleteLayer(0, da^.layer);

  if (da^.layerinfo <> nil)
    then DisposeLayerInfo(da^.layerinfo);

  if (da^.bm <> nil)
    then FreeBitMap(da^.bm);

  FreeVec(da);
end;

//*-------------------------------------------------------------------------*/
//* Allocate and initialize draw area for off-screen drawing with clipping  */
//*-------------------------------------------------------------------------*/

function  new_draw_area(width: Longint; height: Longint; friend: PBitMap): Pdraw_area;
var
  da        : Pdraw_area;
  rassize   : ULONG;
begin
  da := AllocVec(sizeof(Tdraw_area), MEMF_CLEAR);
  if not(da <> nil)
    then exit(nil);

  da^.bm := AllocBitMap(width, height, GetBitMapAttr(friend, BMA_DEPTH), BMF_CLEAR or BMF_MINPLANES, friend);

  if (da^.bm <> nil)
    then da^.layerinfo := NewLayerInfo();

  if (da^.layerinfo <> nil)
    then da^.layer := CreateUpfrontLayer(da^.layerinfo, da^.bm, 0, 0, width-1, height-1, 0, nil);

  if (da^.layer <> nil)
    then da^.rp := da^.layer^.rp;

  if not(da^.rp <> nil) then
  begin
    free_draw_area(da);
    exit(nil);
  end;

  //* the following is needed to use the Area commands. It is not related to clipping */

  rassize := MACRO_RASSIZE(width*2+16, height*2+16);    //* the tmpras must cover the entire area which is calculated before
                                                        //* clipping and not only the part which is drawn after clipping */
  if SetAndTest(da^.tmpbuf, AllocVec(rassize, MEMF_CHIP or MEMF_CLEAR)) then
  begin
    InitTmpRas(@da^.tmpras, da^.tmpbuf, rassize);
    da^.rp^.TmpRas := @da^.tmpras;
  end;

  if SetAndTest(da^.areabuf, AllocVec(5*MAXVEC, MEMF_CLEAR)) then
  begin
    InitArea(@da^.areainfo, da^.areabuf, MAXVEC);
    da^.rp^.AreaInfo := @da^.areainfo;
  end;

  Result := (da);
end;


//*-------------------------------------------------------------------------*/
//* Draw a sequence of circles into the drawing area                        */
//*-------------------------------------------------------------------------*/

procedure draw_something(rp: PRastPort; size: LongInt);
var
  r              : LongInt;
  pen            : Longint = 1;
  reg, oldregion : PRegion;
var
  rect           : AGraphics.TRectangle;
begin
  SetAPen(rp,pen);
  RectFill(rp, 0, 0, size-1, size-1);       //* fill the entire area */

  r := size;
  while (r > 0) do                          //* draw colored circles */
  begin                                     //* center is in the lower left of the drawing area */
    inc(pen);
    SetAPen(rp, pen);                       //* so that only the top right quarter of the circles */
    AreaEllipse(rp, 0, size-1, r, r);       //* is drawn. */
    AreaEnd(rp);
    r := r - 10;
  end;
  
  //* install a smaller clip region into the rastport */

  if SetAndTest(reg, NewRegion()) then       //* create a new region structure */
  begin
    rect.MinX := size div 2;
    rect.MinY := size div 2 - size div 3;
    rect.MaxX := size div 2 + size div 3;
    rect.MaxY := size div 2;

    OrRectRegion(reg, @rect);                //* add an area where can be drawn into to the region */
  end;

  oldregion := InstallClipRegion(rp^.Layer, reg);    //* install the region */

  r := size div 3;
  while  (r > 0) do
  begin
    inc(pen);
    SetAPen(rp, pen);
    AreaEllipse(rp, size div 2 + size div 3, size div - size div 3, r, r);
    AreaEnd(rp);
    r := r - 5;
  end;

  InstallClipRegion(rp^.Layer, oldregion);  //* remove the new region and reinstall the old region */

  if assigned(reg) then DisposeRegion(reg);
end;

//*-------------------------------------------------------------------------*/
//* Return the smaller of two numbers (signed)                              */
//*------------------------------------------------------------------------*/

function min(a: LongInt; b: longint): LongInt;
begin
  if a < b then result := a else result := b;
end;


//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  win       : pWindow;
  imsg      : pIntuiMessage;
  cont      : Boolean;
  size      : LongInt;
  da        : Pdraw_area;
begin

  if SetAndTest(win, OpenWindowTags( nil,
  [
    TAG_(WA_Title)    , TAG_(PChar('Clip')),
    TAG_(WA_Width)    , 320,
    TAG_(WA_Height)   , 240,
    TAG_(WA_Flags)    , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_NOCAREREFRESH),
    TAG_(WA_IDCMP)    , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY),
    TAG_END
  ])) then
  begin

    size := min(win^.GZZWidth, win^.GZZHeight) - 10;

    if SetAndTest(da, new_draw_area(size, size, win^.RPort^.BitMap)) then
    begin

      draw_something(da^.rp, size);

      BltBitMapRastPort(da^.bm, 0, 0, win^.RPort, win^.BorderLeft + (win^.GZZWidth - size) div 2, win^.BorderTop + (win^.GZZHeight - size) div 2, size, size, $c0);

      free_draw_area(da);
    end;

    cont := TRUE;
    while (cont) do
    begin
      if (Wait((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
        then cont := FALSE;

      while SetAndTest(imsg, PIntuiMessage(GetMsg(win^.UserPort))) do
      begin
        case (imsg^.IClass) of
          IDCMP_VANILLAKEY:
            if (imsg^.Code = $1b)
            then cont := FALSE;
          IDCMP_CLOSEWINDOW:
            cont := FALSE;
        end;
        ReplyMsg(pMessage(imsg));
      end;
    end;

    CloseWindow(win);
  end;

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
  Writeln('NOTE: Clipregion will only make (visible) sense when enough pens aren''t using black colour');

  if OpenLibs 
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
  
  WriteLn('leave');
end.
