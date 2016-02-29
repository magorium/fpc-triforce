program RGBBoxes;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : RGBBoxes
  Source    : RKRM
}
 {*
 ** The following example creates a View consisting of one ViewPort set
 ** to an NTSC, high-resolution, interlaced display mode of nominal
 ** dimensions.  This example shows both the old 1.3 way of setting up
 ** the ViewPort and the new method used in Release 2.
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AmigaDOS, AGraphics, Utility,
  CHelpers,
  Trinity;

Type
  PUByte    = ^UBYTE;

const
  DEPTH     =   2;  //*  The number of bitplanes.  */
  WIDTH     = 640;  //*  Nominal width and height  */
  HEIGHT    = 400;  //*  used in 1.3.              */



  procedure drawFilledBox(fillcolor: SmallInt; plane: SmallInt); forward;  //* Function prototypes */
  procedure cleanup(returncode: Integer); forward;
  procedure fail(errorstring: STRPTR); forward;


Var
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  GfxBase   : PGfxBase absolute AGraphics.GfxBase;
  {$ENDIF}

  //*  Construct a simple display.  These are global to make freeing easier.   */
  view      : TView;
  oldview   : PView = nil;      //*  Pointer to old View we can restore it.*/
  viewport  : TViewPort;
  bitMap    : TBitmap;
  cm        : PColorMap = nil;

  vextra    : PViewExtra = nil; //* Extended structures used in Release 2 */
  monspec   : PMonitorSpec = nil;
  vpextra   : PViewPortExtra = nil;
  dimquery  : TDimensionInfo;

  displaymem : PByte = nil;     //*  Pointer for writing to BitMap memory.  */

Const
  BLACK = $000;                 //*  RGB values for the four colors used.   */
  RED   = $f00;
  GREEN = $0f0;
  BLUE  = $00f;


{*
 * main():  create a custom display; works under either 1.3 or Release 2
 *}
procedure main;
var
  depthidx, 
  boxidx    : SmallInt;
  rasInfo   : TRasInfo;
  modeID    : ULONG;

  vcTags    : array [0..3] of TTagItem =
  (
    ( ti_Tag: VTAG_ATTACH_CM_SET;       ti_Data: 0 ),
    ( ti_Tag: VTAG_VIEWPORTEXTRA_SET;   ti_Data: 0 ),
    ( ti_Tag: VTAG_NORMAL_DISP_SET;     ti_Data: 0 ),
    ( ti_Tag: VTAG_END_CM;              ti_Data: 0 )
  );

  //*  Offsets in BitMap where boxes will be drawn.  */
  boxoffsets: array[0..2] of SmallInt = ( 802, 2010, 3218 );

  colortable: array[0..3] of UWORD = ( BLACK, RED, GREEN, BLUE );
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  GfxBase := PGfxBase(OpenLibrary('graphics.library', 33));
  if (GfxBase = nil) 
    then fail('Could not open graphics library' + LineEnding);
  {$ENDIF}

  //*  Example steals screen from Intuition if Intuition is around.      */
  oldview := GfxBase^.ActiView; //* Save current View to restore later. */

  InitView(@view);  //*  Initialize the View and set View.Modes.     */
  view.Modes := view.Modes or LACE; //*  This is the old 1.3 way (only LACE counts). */

  if (GfxBase^.LibNode.lib_Version >= 36) then
  begin
    //* Form the ModeID from values in <displayinfo.h> */
    modeID := DEFAULT_MONITOR_ID or HIRESLACE_KEY;

    //*  Make the ViewExtra structure   */
    if SetAndTest(vextra, GfxNew(VIEW_EXTRA_TYPE) ) then
    begin
      //* Attach the ViewExtra to the View */
      GfxAssociate(@view , Pointer(vextra));
      view.Modes := view.Modes or EXTEND_VSTRUCT;

      //* Create and attach a MonitorSpec to the ViewExtra */
      if SetAndTest(monspec, OpenMonitor(nil, modeID) )
      then vextra^.Monitor := monspec
      else fail('Could not get MonitorSpec' + LineEnding);
    end
    else fail('Could not get ViewExtra' + LineEnding);
  end;

  //*  Initialize the BitMap for RasInfo.  */
  InitBitMap(@bitMap, DEPTH, WIDTH, HEIGHT);

  //* Set the plane pointers to NULL so the cleanup routine */
  //* will know if they were used.                          */
  for depthidx := 0 to Pred(DEPTH)
  do bitMap.Planes[depthidx] := nil;

  //*  Allocate space for BitMap.             */
  for depthidx :=0 to Pred(DEPTH) do
  begin
    bitMap.Planes[depthidx] := (AllocRaster(WIDTH, HEIGHT));
    if (bitMap.Planes[depthidx] = nil)
    then fail('Could not get BitPlanes' + LineEnding);
  end;

  rasInfo.BitMap := @bitMap;    //*  Initialize the RasInfo.  */
  rasInfo.RxOffset := 0;
  rasInfo.RyOffset := 0;
  rasInfo.Next := nil;

  InitVPort(@viewPort);         //*  Initialize the ViewPort.  */
  view.ViewPort := @viewPort;   //*  Link the ViewPort into the View.  */
  viewPort.RasInfo := @rasInfo;
  viewPort.DWidth := WIDTH;
  viewPort.DHeight := HEIGHT;

  //* Set the display mode the old-fashioned way */
  viewPort.Modes := HIRES or LACE;

  if (GfxBase^.LibNode.lib_Version >= 36) then
  begin
    //* Make a ViewPortExtra and get ready to attach it */
    if SetAndTest(vpextra, GfxNew(VIEWPORT_EXTRA_TYPE) ) then
    begin
      vcTags[1].ti_Data := ULONG(vpextra);

      //* Initialize the DisplayClip field of the ViewPortExtra */
      if (GetDisplayInfoData(nil, PChar(@dimquery), sizeof(dimquery), DTAG_DIMS, modeID) <> 0) then
      begin
        vpextra^.DisplayClip := dimquery.Nominal;

        //* Make a DisplayInfo and get ready to attach it */
        if not(SetAndTest(vcTags[2].ti_Data, ULONG(FindDisplayInfo(modeID))) )
        then fail('Could not get DisplayInfo' + LineEnding);
      end
      else fail('Could not get DimensionInfo ' + LineEnding);
    end
    else fail('Could not get ViewPortExtra' + LineEnding);

    //* This is for backwards compatibility with, for example,   */
    //* a 1.3 screen saver utility that looks at the Modes field */
    viewPort.Modes := UWORD((modeID and $0000ffff));
  end;

  //*  Initialize the ColorMap.  */
  //*  2 planes deep, so 4 entries (2 raised to the #_planes power).  */
  cm := GetColorMap(4);
  if (cm = nil)
  then fail('Could not get ColorMap' + LineEnding);

  if (GfxBase^.LibNode.lib_Version >= 36) then
  begin
    //* Get ready to attach the ColorMap, Release 2-style */
    vcTags[0].ti_Data := ULONG(@viewPort);

    //* Attach the color map and Release 2 extended structures */
    if ( VideoControl(cm, vcTags) )
    then fail('Could not attach extended structures' + LIneEnding);
  end
  else
    //* Attach the ColorMap, old 1.3-style */
    viewPort.ColorMap := cm;

  LoadRGB4(@viewPort, colortable, 4);   //* Change colors to those in colortable. */

  MakeVPort(@view, @viewPort);  //* Construct preliminary Copper instruction list.    */

  //* Merge preliminary lists into a real Copper list in the View structure. */
  MrgCop(@view);

  //* Clear the ViewPort */
  for depthidx := 0 to Pred(DEPTH) do 
  begin
    displaymem := PUBYTE(bitMap.Planes[depthidx]);
    BltClear(displaymem, (bitMap.BytesPerRow * bitMap.Rows), 1);
  end;

  LoadView(@view);

  //*  Now fill some boxes so that user can see something.          */
  //*  Always draw into both planes to assure true colors.          */
  for boxidx := 1 to 3 do   //* Three boxes; red, green and blue. */
  begin
    for depthidx := 0 to Pred(Depth) do //*  Two planes.   */
    begin
      displaymem := bitMap.Planes[depthidx] + boxoffsets[boxidx-1];
      drawFilledBox(boxidx, depthidx);
    end;
  end;

  DOSDelay(10 * TICKS_PER_SECOND);  //*  Pause for 10 seconds.                */
  LoadView(oldview);                //*  Put back the old View.               */
  WaitTOF();                        //*  Wait until the the View is being     */
                                    //*    rendered to free memory.           */
  FreeCprList(view.LOFCprList);     //*  Deallocate the hardware Copper list  */
  if (view.SHFCprList <> nil)       //*    created by MrgCop().  Since this   */
  then FreeCprList(view.SHFCprList);//*    is interlace, also check for a     */
                                    //*    short frame copper list to free.   */
  FreeVPortCopLists(@viewPort);     //*  Free all intermediate Copper lists   */
                                    //*    from created by MakeVPort().       */
  cleanup(RETURN_OK);               //*  Success.                             */
end;


{*
 * fail():  print the error string and call cleanup() to exit
 *}
procedure fail(errorstring: STRPTR);
begin
  Write(errorstring);
  cleanup(RETURN_FAIL);
end;


{*
 * cleanup():  free everything that was allocated.
 *}
procedure cleanup(returncode: integer);
var
  depthidx  : SmallInt;
begin
  //*  Free the color map created by GetColorMap().  */
  if assigned(cm) then FreeColorMap(cm);

  //* Free the ViewPortExtra created by GfxNew() */
  if assigned(vpextra) then GfxFree(pointer(vpextra));

  //*  Free the BitPlanes drawing area.  */
  for depthidx := 0 to Pred(DEPTH) do 
  begin
    if (bitMap.Planes[depthidx] <> nil)
    then FreeRaster(bitMap.Planes[depthidx], WIDTH, HEIGHT);
  end;

  //* Free the MonitorSpec created with OpenMonitor() */
  if assigned(monspec) then CloseMonitor(monspec);

  //* Free the ViewExtra created with GfxNew() */
  if assigned(vextra) then GfxFree(pointer(vextra));

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  //* Close the graphics library */
  CloseLibrary(PLibrary(GfxBase));
  {$ENDIF}

  halt(returncode);
end;


{*
 * drawFilledBox(): create a WIDTH/2 by HEIGHT/2 box of color
 *                  "fillcolor" into the given plane.
 *}
procedure drawFilledBox(fillcolor: SmallInt; plane: SmallInt);
var
  value: UBYTE;
  boxHeight, boxWidth, widthidx : SmallInt;
begin
  //*  Divide (WIDTH/2) by eight because each UBYTE that */
  //* is written stuffs eight bits into the BitMap.      */
  boxWidth  := (WIDTH div 2) div 8;
  boxHeight := HEIGHT div 2;

  if ((fillcolor and (1 shl plane)) <> 0)
  then value := $ff
  else value := $00;

  while (boxHeight <> 0) do
  begin
    for widthidx := 0 to Pred(boxWidth) do
    begin
      displaymem^ := value;
      inc(displaymem);
    end;
    displaymem := displaymem + (bitMap.BytesPerRow - boxWidth);
    dec(boxHeight);
  end;
end;


begin
  {$IFDEF AROS}
  WriteLn('This example does not work for AROS for various reasons');
  {$ENDIF}
  Main;
end.
