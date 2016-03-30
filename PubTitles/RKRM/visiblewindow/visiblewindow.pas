program visiblewindow;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : visiblewindow
  Source    : RKRM
}

 {*
 ** open a window on the visible part of a screen, with the window as large
 ** as the visible part of the screen.  It is assumed that the visible part
 ** of the screen is OSCAN_TEXT, which how the user has set their preferences.
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AGraphics, Intuition, utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  CHelpers,
  Trinity;


const
  {* Minimum window width and height:
  ** These values should really be calculated dynamically given the size
  ** of the font and the window borders.  Here, to keep the example simple
  ** they are hard-coded values.
  *}
  MIN_WINDOW_WIDTH  = (100);
  MIN_WINDOW_HEIGHT = (50);

  {* minimum and maximum calculations...Note that each argument is
  ** evaluated twice (don't use max(a++,foo(c))).
  *}
  function max(a: LongInt; b: LongInt): LongInt; inline;
  begin
    if ( (a) > (b) ) then max := (a) else max := (b);
  end;

  function min(a: LongInt; b: LongInt): LOngInt; inline;
  begin
    if ( (a) <= (b) ) then min := (a) else min := (b);
  end;


  procedure fullScreen; forward;
  procedure handle_window_events(win: PWindow); forward;


{*
** open all the libraries and run the code.  Cleanup when done.
*}
procedure Main(argc: integer; argv: PPChar);
begin
  //* these calls are only valid if we have Intuition version 37 or greater */
  {$IFNDEF HASAMIGA}
  if SetAndTest(GfxBase, OpenLibrary('graphics.library', 37)) then
  {$ENDIF}
  begin
    {$IFDEF MORPHOS}
    if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
    {$ENDIF}
    begin
      fullScreen;

      {$IFDEF MORPHOS}
      CloseLibrary(PLibrary(IntuitionBase));
      {$ENDIF}
    end;
    {$IFNDEF HASAMIGA}
    CloseLibrary(GfxBase);
    {$ENDIF}
  end;
end;


{*
** Open a window on the default public screen, then leave it open until the
** user selects the close gadget. The window is full-sized, positioned in the
** currently visible OSCAN_TEXT area.
*}
procedure fullScreen;
var
  test_window   : PWindow;
  pub_screen    : PScreen;
  rect          : TRectangle;
  screen_modeID : ULONG;
  width, 
  height, 
  left, 
  top           : LONG;
begin
  left   := 0;   //* set some reasonable defaults for left, top, width and height. */
  top    := 0;   //* we'll pick up the real values with the call to QueryOverscan(). */
  width  := 640;
  height := 200;

  //* get a lock on the default public screen */
  if (nil <> SetAndGet(pub_screen, LockPubScreen(nil))) then
  begin
    {* this technique returns the text overscan rectangle of the screen that we
    ** are opening on.  If you really need the actual value set into the display
    ** clip of the screen, use the VideoControl() command of the graphics library
    ** to return a copy of the ViewPortExtra structure.  See the Graphics
    ** library chapter and Autodocs for more details.
    **
    ** GetVPModeID() is a graphics call...
    *}

    screen_modeID := GetVPModeID(@pub_screen^.ViewPort);
    if (screen_modeID <> ULONG(INVALID_ID)) then
    begin
      if (QueryOverscan(screen_modeID, @rect, OSCAN_TEXT) <> 0) then
      begin
        //* make sure window coordinates are positive or zero */
        left := max(0, -pub_screen^.LeftEdge);
        top  := max(0, -pub_screen^.TopEdge);

        //* get width and height from size of display clip */
        width  := rect.MaxX - rect.MinX + 1;
        height := rect.MaxY - rect.MinY + 1;

        //* adjust height for pulled-down screen (only show visible part) */
        if (pub_screen^.TopEdge > 0)
        then height := height - pub_screen^.TopEdge;

        //* insure that window fits on screen */
        height := min(height, pub_screen^.Height);
        width  := min(width,  pub_screen^.Width);

        //* make sure window is at least minimum size */
        width  := max(width,  MIN_WINDOW_WIDTH);
        height := max(height, MIN_WINDOW_HEIGHT);
      end;
    end;

    //* open the window on the public screen */
    test_window := OpenWindowTags(nil,
    [
      TAG_(WA_Left)         , left,
      TAG_(WA_Width)        , width,
      TAG_(WA_Top)          , top,
      TAG_(WA_Height)       , height,
      TAG_(WA_CloseGadget)  , TAG_(TRUE),
      TAG_(WA_IDCMP)        , IDCMP_CLOSEWINDOW,
      TAG_(WA_PubScreen)    , TAG_(pub_screen),
      TAG_END
    ]);

    {* unlock the screen.  The window now acts as a lock on the screen,
    ** and we do not need the screen after the window has been closed.
    *}
    UnlockPubScreen(nil, pub_screen);

    {* if we have a valid window open, run the rest of the
    ** program, then clean up when done.
    *}
    if assigned(test_window) then
    begin
      handle_window_events(test_window);
      CloseWindow(test_window);
    end;
  end;
end;


{*
** Wait for the user to select the close gadget.
*}
procedure handle_window_events(win: PWindow);
var
  msg   : PIntuiMessage;
  done  : Boolean = FALSE;
begin
  while not(done) do
  begin
    {* we only have one signal bit, so we do not have to check which
    ** bit(s) broke the Wait() (i.e. the return value of Wait)
    *}
    Wait(1 shl win^.UserPort^.mp_SigBit);

    while ( not(done) and SetAndTest(msg, PIntuiMessage(GetMsg(win^.UserPort)))) do
    begin
      //* use a case statement if looking for multiple event types */
      if (msg^.IClass = IDCMP_CLOSEWINDOW)
      then done := TRUE;

      ReplyMsg(PMessage(msg));
    end;
  end;
end;


begin
  Main(ArgC, ArgV);
end.
