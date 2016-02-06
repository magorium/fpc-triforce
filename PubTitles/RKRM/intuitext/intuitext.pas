program intuitext;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : intuitext
  Topic     : program to show the use of an Intuition IntuiText object.
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AmigaDOS, AGraphics, Intuition, utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  CHelpers,
  Trinity;


const
  MYTEXT_LEFT   = (0);
  MYTEXT_TOP    = (0);


{*
** main routine. Open required library and window and draw the images.
** This routine opens a very simple window with no IDCMP.  See the
** chapters on "Windows" and "Input and Output Methods" for more info.
** Free all resources when done.
*}
procedure Main(argc: Integer; argv: PPChar);
var
  screen            : PScreen;
  drawinfo          : PDrawInfo;
  win               : PWindow;
  myIText           : TIntuiText;
  myTextAttr        : TTextAttr;

  myTEXTPEN         : ULONG;
  myBACKGROUNDPEN   : ULONG;

begin
  {$IFDEF MORPHOS}
  IntuitionBase := PIntuitionBase(OpenLibrary('intuition.library', 37));
  if assigned(IntuitionBase) then
  {$ENDIF}
  begin
    if SetAndTest(screen, LockPubScreen(nil)) then
    begin
      if SetAndtest(drawinfo, GetScreenDrawInfo(screen)) then
      begin
        {* Get a copy of the correct pens for the screen.
        ** This is very important in case the user or the
        ** application has the pens set in a unusual way.
        *}
        myTEXTPEN := PWORD(drawinfo^.dri_Pens)[TEXTPEN];
        myBACKGROUNDPEN := PWORD(drawinfo^.dri_Pens)[BACKGROUNDPEN];

        //* create a TextAttr that matches the specified font. */
        myTextAttr.ta_Name  := drawinfo^.dri_Font^.tf_Message.mn_Node.ln_Name;
        myTextAttr.ta_YSize := drawinfo^.dri_Font^.tf_YSize;
        myTextAttr.ta_Style := drawinfo^.dri_Font^.tf_Style;
        myTextAttr.ta_Flags := drawinfo^.dri_Font^.tf_Flags;

        {* open a simple window on the workbench screen for displaying
        ** a text string.  An application would probably never use such a
        ** window, but it is useful for demonstrating graphics...
        *}
        if SetAndTest(win, OpenWindowTags(nil,
        [
          TAG_(WA_PubScreen)    , TAG_(screen),
          TAG_(WA_RMBTrap)      , TAG_(TRUE),
          TAG_END
        ])) then
        begin
          myIText.FrontPen    := myTEXTPEN;
          myIText.BackPen     := myBACKGROUNDPEN;
          myIText.DrawMode    := JAM2;
          myIText.LeftEdge    := MYTEXT_LEFT;
          myIText.TopEdge     := MYTEXT_TOP;
          myIText.ITextFont   := @myTextAttr;
          myIText.IText       := 'Hello, World.  ;-)';
          myIText.NextText    := nil;

          //* Draw the text string at 10,10 */
          PrintIText(win^.RPort, @myIText,10,10);

          {* Wait a bit, then quit.
          ** In a real application, this would be an event loop,
          ** like the one described in the Intuition Input and
          ** Output Methods chapter.
          *}
          DOSDelay(200);

          CloseWindow(win);
        end;
        FreeScreenDrawInfo(screen, drawinfo);
      end;
      UnlockPubScreen(nil, screen);
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


begin
  Main(Argc, ArgV);
end.
