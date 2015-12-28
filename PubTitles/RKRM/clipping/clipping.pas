program clipping;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : clipping
  Source    : RKRM
}
 {
 * The following example shows the use of the layers library call
 * InstallClipRegion(), as well as simple use of the graphics library
 * regions functions. Be aware that it uses Release 2 functions for
 * opening and closing Intuition windows.
 }


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AmigaDOS, AGraphics, Layers, Intuition, Utility,
  {$IFDEF AMIGA}
  SystemVartags,
  {$ENDIF}  
  CHelpers,
  Trinity;


Const
  MY_WIN_WIDTH  = (300);
  MY_WIN_HEIGHT = (100);


{*
** unclipWindow()
**
** Used to remove a clipping region installed by clipWindow() or
** clipWindowToBorders(), disposing of the installed region and
** reinstalling the region removed.
*}
procedure unclipWindow(win: PWindow);
var
  old_region    : PRegion;
begin
  {* Remove any old region by installing a NULL region,
  ** then dispose of the old region if one was installed.
  *}
  if (nil <> SetAndGet(old_region, InstallClipRegion(win^.WLayer, nil)))
  then DisposeRegion(old_region);
end;


{*
** clipWindow()
** Clip a window to a specified rectangle (given by upper left and
** lower right corner.)  the removed region is returned so that it
** may be re-installed later.
*}
function clipWindow(win: PWindow; minX: LONG; minY: LONG; maxX: LONG; maxY: LONG): PRegion;
var
  new_region    : PRegion;
  my_rectangle  : TRectangle;
begin
  //* set up the limits for the clip */
  my_rectangle.MinX := minX;
  my_rectangle.MinY := minY;
  my_rectangle.MaxX := maxX;
  my_rectangle.MaxY := maxY;

  //* get a new region and OR in the limits. */
  if (nil <> SetAndGet(new_region, NewRegion)) then
  begin
    if (FALSE = OrRectRegion(new_region, @my_rectangle)) then
    begin
      DisposeRegion(new_region);
      new_region := nil;
    end;
  end;

  {* Install the new region, and return any existing region.
  ** If the above allocation and region processing failed, then
  ** new_region will be NULL and no clip region will be installed.
  *}
  Result := InstallClipRegion(win^.WLayer, new_region);
end;



{*
** clipWindowToBorders()
** clip a window to its borders.
** The removed region is returned so that it may be re-installed later.
*}
function  clipWindowToBorders(win: PWindow): PRegion;
begin
 Result := (clipWindow(win, win^.BorderLeft, win^.BorderTop,
    win^.Width - win^.BorderRight - 1, win^.Height - win^.BorderBottom - 1));
end;

{*
** Wait for the user to select the close gadget.
*}
procedure wait_for_close(win: PWindow);
var
  msg   : PIntuiMessage;
  done  : boolean;
begin
  done := FALSE;
  while (FALSE = done) do
  begin
    {* we only have one signal bit, so we do not have to check which
    ** bit broke the Wait().
    *}
    Wait(1 shl win^.UserPort^.mp_SigBit);

    while ( ( FALSE = done ) and
            ( nil <> SetAndGet(msg, PIntuiMessage(GetMsg(win^.UserPort))) )
          ) do
    begin
      //* use a switch statement if looking for multiple event types */
      if (msg^.IClass = IDCMP_CLOSEWINDOW)
      then done := TRUE;

      ReplyMsg(PMessage(msg));
    end;
  end;
end;


{*
** Simple routine to blast all bits in a window with color three to show
** where the window is clipped.  After a delay, flush back to color zero
** and refresh the window borders.
*}
procedure draw_in_window(win: PWindow; message: PChar);
begin
  Write(message, '...');
  SetRast(win^.RPort, 3);
  DOSDelay(200);
  SetRast(win^.RPort, 0);
  RefreshWindowFrame(win);
  Writeln('done');
end;


{*
** Show drawing into an unclipped window, a window clipped to the
** borders and a window clipped to a random rectangle.  It is possible
** to clip more complex shapes by AND'ing, OR'ing and exclusive-OR'ing
** regions and rectangles to build a user clip region.
**
** This example assumes that old regions are not going to be re-used,
** so it simply throws them away.
*}
procedure clip_test(win: PWindow);
var
  old_region    : PRegion;
begin
  draw_in_window(win, 'Window with no clipping');

  {* if the application has never installed a user clip region,
  ** then old_region will be NULL here.  Otherwise, delete the
  ** old region (you could save it and re-install it later...)
  *}
  if (nil <> SetAndGet(old_region, clipWindowToBorders(win)))
  then DisposeRegion(old_region);
  draw_in_window(win, 'Window clipped to window borders');
  unclipWindow(win);

  {* here we know old_region will be NULL, as that is what we
  ** installed with unclipWindow()...
  *}
  if (nil <> SetAndGet(old_region, clipWindow(win,20,20,100,50)))
  then DisposeRegion(old_region);
  draw_in_window(win, 'Window clipped from (20,20) to (100,50)');
  unclipWindow(win);

  wait_for_close(win);
end;


{*
** Open and close resources, call the test routine when ready.
*}
procedure main(argc: integer; argv: PPChar);
var
  win   : PWindow;
begin
  {$IFDEF MORPHOS}
  if (nil <> SetAndGet(IntuitionBase, PIntuitionBase(OpenLibrary('intuition.library', 37)))) then
  {$ENDIF}
  begin
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    if (nil <> SetAndGet(GfxBase, PGfxBase(OpenLibrary('graphics.library', 37)))) then
    {$ENDIF}
    begin
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      if (nil <> SetAndGet(LayersBase, OpenLibrary('layers.library', 37))) then
      {$ENDIF}
      begin
        if (nil <> SetAndGet(win, OpenWindowTags(nil,
        [
          TAG_(WA_Width)        , MY_WIN_WIDTH,
          TAG_(WA_Height)       , MY_WIN_HEIGHT,
          TAG_(WA_IDCMP)        , IDCMP_CLOSEWINDOW,
          TAG_(WA_CloseGadget)  , TAG_(TRUE),
          TAG_(WA_DragBar)      , TAG_(TRUE),
          TAG_(WA_Activate)     , TAG_(TRUE),
          TAG_END
        ]))) then
        begin
          clip_test(win);

          CloseWindow(win);
        end;
        {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
        CloseLibrary(LayersBase);
        {$ENDIF}
      end;
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      CloseLibrary(PLibrary(GfxBase));
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
