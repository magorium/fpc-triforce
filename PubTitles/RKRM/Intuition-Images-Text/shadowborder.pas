program shadowborder;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : shadowborder
  Topic     : program to show the use of an Intuition Border.
  Source    : RKRM
}

  {*
  ** The following example draws a double border using two pens to create a
  ** shadow effect.  The border is drawn in two positions to show the
  ** flexibility in positioning borders, note that it could also be attached
  ** to a menu, gadget or requester.
  *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}


{$DEFINE INTUI_V36_NAMES_ONLY}

Uses
  Exec, AmigaDOS, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  CHelpers,
  Trinity;


Type
  PUWORD = ^UWORD;


var
  {$IFDEF AMIGA}
  IntuitionBase : PLibrary absolute _Intuitionbase;
  {$ENDIF}
  {$IFDEF AROS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  {$ENDIF}
  {$IFDEF MORPHOS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  {$ENDIF}


const
  MYBORDER_LEFT   = (0);
  MYBORDER_TOP    = (0);


var
  //* This is the border data. */
  myBorderData : array [0..9] of SmallInt =
  (
    0,0, 50,0, 50,30, 0,30, 0,0
  );


{*
** main routine. Open required library and window and draw the images.
** This routine opens a very simple window with no IDCMP.  See the
** chapters on "Windows" and "Input and Output Methods" for more info.
** Free all resources when done.
*}
procedure Main(argc: integer; argv: PPChar);
var
  screen        : PScreen;
  drawinfo      : PDrawInfo;
  win           : PWindow;
  shineBorder   : TBorder;
  shadowBorder  : TBorder;

  mySHADOWPEN   : ULONG = 1;  //* set default values for pens */
  mySHINEPEN    : ULONG = 2;  //* in case can't get info...   */
begin
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  {$ENDIF}
  if assigned(IntuitionBase) then
  begin
    if SetAndTest(screen, LockPubScreen(nil)) then
    begin
      if SetAndTest(drawinfo, GetScreenDrawInfo(screen)) then
      begin
        {* Get a copy of the correct pens for the screen.
        ** This is very important in case the user or the
        ** application has the pens set in a unusual way.
        *}
        mySHADOWPEN := PUWORD(drawinfo^.dri_Pens)[SHADOWPEN];
        mySHINEPEN  := PUWORD(drawinfo^.dri_Pens)[SHINEPEN];

        FreeScreenDrawInfo(screen, drawinfo);
      end;
      UnlockPubScreen(nil, screen);
    end;

    {* open a simple window on the workbench screen for displaying
    ** a border.  An application would probably never use such a
    ** window, but it is useful for demonstrating graphics...
    *}
    if SetAndTest(win, OpenWindowTags(nil,
    [
      TAG_(WA_PubScreen) , TAG_(screen),
      TAG_(WA_RMBTrap)   , TAG_(TRUE),
      TAG_END
    ])) then
    begin
      //* set information specific to the shadow component of the border */
      shadowBorder.LeftEdge   := MYBORDER_LEFT + 1;
      shadowBorder.TopEdge    := MYBORDER_TOP + 1;
      shadowBorder.FrontPen   := mySHADOWPEN;
      shadowBorder.NextBorder := @shineBorder;

      //* set information specific to the shine component of the border */
      shineBorder.LeftEdge    := MYBORDER_LEFT;
      shineBorder.TopEdge     := MYBORDER_TOP;
      shineBorder.FrontPen    := mySHINEPEN;
      shineBorder.NextBorder  := nil;

      //* the following attributes are the same for both borders. */
      shineBorder.BackPen     := 0;
      shineBorder.DrawMode    := JAM1;
      shineBorder.Count       := 5;
      shineBorder.XY          := @myBorderData;

      shadowBorder.BackPen    := shineBorder.BackPen;
      shadowBorder.DrawMode   := shineBorder.DrawMode;
      shadowBorder.Count      := shineBorder.Count;
      shadowBorder.XY         := shineBorder.XY;

      //* Draw the border at 10,10 */
      DrawBorder(win^.RPort, @shadowBorder, 10, 10);

      //* Draw the border again at 100,10 */
      DrawBorder(win^.RPort, @shadowBorder, 100, 10);

      {* Wait a bit, then quit.
      ** In a real application, this would be an event loop, like the
      ** one described in the Intuition Input and Output Methods chapter.
      *}
      DOSDelay(200);

      CloseWindow(win);
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(IntuitionBase);
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
