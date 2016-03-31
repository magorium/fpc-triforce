program winpubscreen;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : winpubscreen
  Title     : open a window on the default public screen (usually the 
              Workbench screen)
  Source    : RKRM
}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, Intuition, utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  CHelpers,
  Trinity;

  //* our function prototypes */
  procedure handle_window_events(win: PWindow); forward;


{*
** Open a simple window on the default public screen,
** then leave it open until the user selects the close gadget.
*}
procedure Main(argc: integer; argv: PPChar);
var
  test_window   : PWindow = nil;
  test_screen   : PScreen = nil;
begin
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  if Assigned(intuitionBase) then
  {$ENDIF}
  begin
    //* get a lock on the default public screen */
    if SetAndTest(test_screen, LockPubScreen(nil)) then
    begin
      //* open the window on the public screen */
      test_window := OpenWindowTags(nil,
      [
        TAG_(WA_Left)           ,  10,
        TAG_(WA_Top)            ,  20,
        TAG_(WA_Width)          , 300,   
        TAG_(WA_Height)         , 100,
        TAG_(WA_DragBar)        , TAG_(TRUE),
        TAG_(WA_CloseGadget)    , TAG_(TRUE),
        TAG_(WA_SmartRefresh)   , TAG_(TRUE),
        TAG_(WA_NoCareRefresh)  , TAG_(TRUE),
        TAG_(WA_IDCMP)          , IDCMP_CLOSEWINDOW,
        TAG_(WA_Title)          , TAG_(PChar('Window Title')),
        TAG_(WA_PubScreen)      , TAG_(test_screen),
        TAG_END
      ]);

      {* Unlock the screen.  The window now acts as a lock on
      ** the screen, and we do not need the screen after the
      ** window has been closed.
      *}
      UnlockPubScreen(nil, test_screen);

      {* if we have a valid window open, run the rest of the
      ** program, then clean up when done.
      *}
      if assigned(test_window) then
      begin
        handle_window_events(test_window);
        CloseWindow(test_window);
      end;
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
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
    {* We have no other ports of signals to wait on,
    ** so we'll just use WaitPort() instead of Wait()
    *}
    WaitPort(win^.UserPort);

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
