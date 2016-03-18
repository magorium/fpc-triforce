program menulayout;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : menulayout
  Topic     : Example showing how to do menu layout in general.
  Source    : RKRM
}

 {*
 ** This example also illustrates handling menu events, including 
 ** IDCMP_MENUHELP events.
 **
 ** Note that handling arbitrary fonts is fairly complex.  Applications that require V37
 ** should use the simpler menu layout routines found in the GadTools library.
 *}
 
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


type
  pUWORD = ^UWORD;

  
const
  //* Settings Item IntuiText */
  SettText : array[0..3] of TIntuiText = 
  (
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2;          TopEdge: 1; ITextFont: nil; IText: 'Sound...';        NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: CHECKWIDTH; TopEdge: 1; ITextFont: nil; IText: ' Auto Save';      NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: CHECKWIDTH; TopEdge: 1; ITextFont: nil; IText: ' Have Your Cake'; NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: CHECKWIDTH; TopEdge: 1; ITextFont: nil; IText: ' Eat It Too';     NextText: nil )
  );

  SettItem : array[0..3] of TMenuItem = 
  (
	//* "Sound..." */
    ( 
      NextItem   : @SettItem[1]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@SettText[0]); SelectFill: nil; Command: #0; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    //* "Auto Save" (toggle-select, initially selected) */
    (
      NextItem   : @SettItem[2]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or ITEMENABLED or HIGHCOMP or CHECKIT or MENUTOGGLE or CHECKED; MutualExclude: 0;
      ItemFill   : APTR(@SettText[1]); SelectFill: nil; Command: #0; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    //* "Have Your Cake" (initially selected, excludes "Eat It Too") */
    (
      NextItem   : @SettItem[3]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or ITEMENABLED or HIGHCOMP or CHECKIT or CHECKED; MutualExclude: 0;
      ItemFill   : APTR(@SettText[2]); SelectFill: nil; Command: #0; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    //* "Eat It Too" (excludes "Have Your Cake") */
    (
      NextItem   : nil; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or ITEMENABLED or HIGHCOMP or CHECKIT; MutualExclude: 0;
      ItemFill   : APTR(@SettText[3]); SelectFill: nil; Command: #0; SubItem: nil; 
      NextSelect : MENUNULL
    )
  );

  //* Edit Menu Item IntuiText */
  EditText : array[0..4] of TIntuiText = 
  (
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Cut';   NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Copy';  NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Paste'; NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Erase'; NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Undo';  NextText: nil )
  );

  //* Edit Menu Items */
  EditItem : array[0..4] of TMenuItem =
  (
    ( //* "Cut" (key-equivalent: 'X') */
      NextItem   : @EditItem[1]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or COMMSEQ or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@EditText[0]); SelectFill: nil; Command: 'X'; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Copy" (key-equivalent: 'C') */
      NextItem   : @EditItem[2]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or COMMSEQ or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@EditText[1]); SelectFill: nil; Command: 'C'; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Paste" (key-equivalent: 'V') */
      NextItem   : @EditItem[3]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or COMMSEQ or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@EditText[2]); SelectFill: nil; Command: 'V'; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Erase" (disabled) */
      NextItem   : @EditItem[4]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@EditText[3]); SelectFill: nil; Command: #0; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Undo" MenuItem (key-equivalent: 'Z') */
      NextItem   : nil; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or COMMSEQ or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@EditText[4]); SelectFill: nil; Command: 'Z'; SubItem: nil; 
      NextSelect : MENUNULL
    )
  );


  //* IntuiText for the Print Sub-Items */
  PrtText : array[0..1] of TIntuiText = 
  (
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'NLQ';   NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Draft'; NextText: nil )
  );

  //* Print Sub-Items */
  PrtItem : array[0..1] of TMenuItem = 
  (
    ( //* "NLQ" */
      NextItem   : @PrtItem[1]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@PrtText[0]); SelectFill: nil; Command: #0; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "NLQ" */
      NextItem   : nil; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@PrtText[1]); SelectFill: nil; Command: #0; SubItem: nil; 
      NextSelect : MENUNULL
    )
  );


  {* Uses the >> character to indicate a sub-menu item.
  ** This is \273 Octal, 0xBB Hex or Alt-0 from the Keyboard.
  **
  ** NOTE that standard menus place this character at the right margin of the menu box.
  ** This may be done by using a second IntuiText structure for the single character,
  ** linking this IntuiText to the first one, and positioning the IntuiText so that the
  ** character appears at the right margin.  GadTools library will provide the correct behavior.
  *}

  //* Project Menu Item IntuiText */
  ProjText : array[0..6] of TIntuiText = 
  (
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'New';            NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Open...';        NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Save';           NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Save As...';     NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Print     '#187; NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'About';          NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 2; TopEdge: 1; ITextFont: nil; IText: 'Quit';           NextText: nil )
  );

  //* Project Menu Items */
  ProjItem : array[0..6] of TMenuItem =
  (
    ( //* "New" (key-equivalent: 'N' */
      NextItem   : @ProjItem[1]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or COMMSEQ or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@ProjText[0]); SelectFill: nil; Command: 'N'; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Open..." (key-equivalent: 'O') */
      NextItem   : @ProjItem[2]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or COMMSEQ or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@ProjText[1]); SelectFill: nil; Command: 'O'; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Save" (key-equivalent: 'S') */
      NextItem   : @ProjItem[3]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or COMMSEQ or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@ProjText[2]); SelectFill: nil; Command: 'S'; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Save As..." (key-equivalent: 'A') */
      NextItem   : @ProjItem[4]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@ProjText[3]); SelectFill: nil; Command: 'A'; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Print" (has sub-menu) */
      NextItem   : @ProjItem[5]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@ProjText[4]); SelectFill: nil; Command: #0; SubItem: @PrtItem[0]; 
      NextSelect : MENUNULL
    ),
    ( //* "About..." */
      NextItem   : @ProjItem[6]; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@ProjText[5]); SelectFill: nil; Command: #0; SubItem: nil; 
      NextSelect : MENUNULL
    ),
    ( //* "Quit" (key-equivalent: 'Q' */
      NextItem   : nil; LeftEdge: 0; TopEdge: 0; Width: 0; Height: 0; 
      Flags      : ITEMTEXT or COMMSEQ or ITEMENABLED or HIGHCOMP; MutualExclude: 0;
      ItemFill   : APTR(@ProjText[6]); SelectFill: nil; Command: 'Q'; SubItem: nil; 
      NextSelect : MENUNULL
    )
  );

  //* Menu Titles */
  Menus : array[0..2] of TMenu =
  (
    ( NextMenu: @Menus[1]; LeftEdge:   0; TopEdge: 0; Width: 63; Height: 0; Flags: MENUENABLED; MenuName: 'Project' ; FirstItem: @ProjItem[0] ),
    ( NextMenu: @Menus[2]; LeftEdge:  70; TopEdge: 0; Width: 39; Height: 0; Flags: MENUENABLED; MenuName: 'Edit'    ; FirstItem: @EditItem[0] ),
    ( NextMenu: nil;       LeftEdge: 120; TopEdge: 0; Width: 88; Height: 0; Flags: MENUENABLED; MenuName: 'Settings'; FirstItem: @SettItem[0] )
  );

  //* A pointer to the first menu for easy reference */
  FirstMenu : PMenu = @Menus[0];

  //* Window Text for Explanation of Program */
  WinText   : array[0..1] of TIntuiText =
  (
    ( FrontPen: 0; BackPen: 0; DrawMode: JAM2; LeftEdge: 0; TopEdge: 0; ITextFont: nil; IText: 'How to do a Menu'; NextText: nil         ),
    ( FrontPen: 0; BackPen: 0; DrawMode: JAM2; LeftEdge: 0; TopEdge: 0; ITextFont: nil; IText: '(with Style)'    ; NextText: @WinText[0] )
  );


  //* Our function prototypes */
  function  processMenus(selection: Word; done: Boolean): Boolean; forward;
  function  handleIDCMP(win: PWindow): boolean; forward;
  function  MaxLength(textRPort: PRastPort; first_item: PMenuItem; char_size: Word): Word; forward;
  procedure setITextAttr(first_IText: PIntuiText; textAttr: PTextAttr); forward;
  procedure adjustItems(textRPort: PRastPort; first_item: PMenuItem; textAttr: PTextAttr; char_size: Word; Height: Word; level: Word; left_edge: Word); forward;
  function  adjustMenus(first_menu: PMenu; textAttr: PTextAttr): Boolean; forward;
  function  doWindow: LONG; forward;



{* open all of the required libraries.  Note that we require
** Intuition V37, as the routine uses OpenWindowTags().
*}
function Main(argc: Integer; argv: PPChar): Integer;
var
  returnValue : LONG;
begin
  //* This gets set to RETURN_OK if everything goes well. */
  returnValue := RETURN_FAIL;

  //* Open the Intuition Library */
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  if Assigned(IntuitionBase) then
  {$ENDIF}
  begin
    //* Open the Graphics Library */
    {$IFNDEF HASAMIGA}
    GfxBase := PGfxBase(OpenLibrary('graphics.library', 33));
    if assigned(GfxBase) then
    {$ENDIF}
    begin
      returnValue := doWindow();

      {$IFNDEF HASAMIGA}
      CloseLibrary(GfxBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
  Result := (returnValue);
end;


{* Open a window with some properly positioned text.  Layout and set
** the menus, then process any events received.  Cleanup when done.
*}
function  doWindow: LONG;
var
  window        : PWindow;
  screen        : PScreen;
  drawinfo      : PDrawInfo;
  signalmask, 
  signals       : ULONG;
  win_width, 
  alt_width, 
  win_height    : ULONG;
  returnValue   : LONG = RETURN_FAIL;
  done          : Boolean = FALSE;
begin
  if SetAndTest(screen, LockPubScreen(nil)) then
  begin
    if SetAndTest(drawinfo, GetScreenDrawInfo(screen)) then
    begin
      ///* get the colors for the window text */
      WinText[0].FrontPen := PUWORD(drawinfo^.dri_Pens)[TEXTPEN];
      WinText[1].FrontPen := PUWORD(drawinfo^.dri_Pens)[TEXTPEN];
      WinText[0].BackPen  := PUWORD(drawinfo^.dri_Pens)[BACKGROUNDPEN];
      WinText[1].BackPen  := PUWORD(drawinfo^.dri_Pens)[BACKGROUNDPEN];

      //* use the screen's font for the text */
      WinText[0].ITextFont := screen^.Font;
      WinText[1].ITextFont := screen^.Font;

      //* calculate window size */
      win_width  := 100 + IntuiTextLength(@(WinText[0]));
      alt_width  := 100 + IntuiTextLength(@(WinText[1]));
      if (win_width < alt_width) then win_width  := alt_width;
      win_height := 1 + screen^.WBorTop + screen^.WBorBottom +
                     (screen^.Font^.ta_YSize * 5);

      //* calculate the correct positions for the text in the window */
      WinText[0].LeftEdge := (win_width - IntuiTextLength(@(WinText[0]))) shr 1;
      WinText[0].TopEdge  := 1 + screen^.WBorTop + (2 * screen^.Font^.ta_YSize);
      WinText[1].LeftEdge := (win_width - IntuiTextLength(@(WinText[1]))) shr 1;
      WinText[1].TopEdge  := WinText[0].TopEdge + screen^.Font^.ta_YSize;

      //* Open the window */
      window := OpenWindowTags(nil,
      [
        TAG_(WA_PubScreen)  , TAG_(screen),
        TAG_(WA_IDCMP)      , IDCMP_MENUPICK or IDCMP_CLOSEWINDOW or IDCMP_MENUHELP,
        TAG_(WA_Flags)      , WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_CLOSEGADGET or WFLG_ACTIVATE or WFLG_NOCAREREFRESH,
        TAG_(WA_Left)       , 10,
        TAG_(WA_Top)        , screen^.BarHeight + 1,
        TAG_(WA_Width)      , win_width,
        TAG_(WA_Height)     , win_height,
        TAG_(WA_Title)      , TAG_(PChar('Menu Example')),
        TAG_(WA_MenuHelp)   , TAG_(TRUE),
        TAG_END
      ]);

      if assigned(window) then
      begin
        returnValue := RETURN_OK;  //* program initialized ok */

        //* Give a brief explanation of the program */
        PrintIText(window^.RPort, @WinText[1],0,0);

        //* Adjust the menu to conform to the font (TextAttr) */
        adjustMenus(FirstMenu, PScreen(window^.WScreen)^.Font);

        //* attach the menu to the window */
        SetMenuStrip(window, FirstMenu);

        //* Set up the signals that you want to hear about ... */
        signalmask := 1 shl window^.UserPort^.mp_SigBit;

        //* And wait to hear from your signals */
        while not(done) do
        begin
          signals := Wait(signalmask);
          if (signals and signalmask <> 0) then done := handleIDCMP(window);
        end;

        //* clean up everything used here */
        ClearMenuStrip(window);
        CloseWindow(window);
      end;
      FreeScreenDrawInfo(screen, drawinfo);
    end;
    UnlockPubScreen(nil, screen);
  end;
  Result := (returnValue);
end;


{* print out what menu was selected.  Properly handle the IDCMP_MENUHELP
** events.  Set done to TRUE if quit is selected.
*}
function  processMenus(selection: Word; done: Boolean): Boolean;
var
  flags     : Word;
  menuNum, 
  itemNum, 
  subNum    : Word;
begin
  menuNum := Intuition.MENUNUM(selection);
  itemNum := Intuition.ITEMNUM(selection);
  subNum  := Intuition.SUBNUM(selection);

  {* when processing IDCMP_MENUHELP, you are not guaranteed
  ** to get a menu item.
  *}
  if (itemNum <> NOITEM) then
  begin
    flags := PMenuItem(ItemAddress(FirstMenu,LONG(selection)))^.Flags;
    if (flags and CHECKED <> 0)
    then Write('(Checked) ');
  end;

  case (menuNum) of
    0:      //* Project Menu */
        case (itemNum) of
          NOITEM: WriteLn('Project Menu');
               0: WriteLn('New');
               1: WriteLn('Open');
               2: WriteLn('Save');
               3: WriteLn('Save As');
               4: begin
                    Write('Print ');
                    case (subNum) of
                      NOSUB: WriteLn('Item');
                          0: WriteLn('NLQ');
                          1: WriteLn('Draft');
                    end;
                  end;
               5: WriteLn('About');
               6: begin
                    WriteLn('Quit'); 
                    done := TRUE;
                  end;
        end;
    1:      //* Edit Menu */
        case (itemNum) of
          NOITEM: WriteLn('Edit Menu');
               0: WriteLn('Cut');
               1: WriteLn('Copy');
               2: WriteLn('Paste');
               3: WriteLn('Erase');
               4: WriteLn('Undo');
        end;
    2:      //* Settings Menu */
        case (itemNum) of
          NOITEM: WriteLn('Settings Menu');
               0: WriteLn('Sound');
               1: WriteLn('Auto Save');
               2: WriteLn('Have Your Cake');
               3: WriteLn('Eat It Too');
        end;
    NOMENU: //* No menu selected, can happen with IDCMP_MENUHELP */
      WriteLn('no menu');
  end;
  Result := (done);
end;


//* Handle the IDCMP messages.  Set done to TRUE if quit or closewindow is selected. */
function  handleIDCMP(win: PWindow): boolean;
var
  done      : boolean;
  code, 
  selection : Word;
  imessage  : PIntuiMessage = nil;
  iclass    : ULONG;
begin
  done := FALSE;

  //* Examine pending messages */
  while SetAndTest(imessage, PIntuiMessage(GetMsg(win^.UserPort))) do
  begin
    iclass := imessage^.iClass;
    code := imessage^.Code;

    //* When we're through with a message, reply */
    ReplyMsg(PMessage(imessage));

    //* See what events occurred */
    case (iclass) of
      IDCMP_CLOSEWINDOW:
      begin
        done := TRUE;
      end;
      IDCMP_MENUHELP:
      begin
        {*
	    ** The routine that handles the menus for IDCMP_MENUHELP must be very careful
	    ** it can receive menu information that is impossible under IDCMP_MENUPICK.
	    ** For instance, the code value on a IDCMP_MENUHELP may have a valid number
	    ** for the menu, then NOITEM and NOSUB. IDCMP_MENUPICK would get MENUNULL
	    ** in this case.  IDCMP_MENUHELP never come as multi-select items, and the
	    ** event terminates the menu processing session.
        **
        ** Note that I do not keep the return value from the processMenus() routine here--the
	    ** application should not quit if the user selects "help" over the quit menu item.
        *}
         Write('IDCMP_MENUHELP: Help on ');
         processMenus(code, done);
      end;
      IDCMP_MENUPICK:
      begin
        selection := code;
        while (selection <> MENUNULL) do
        begin
          Write('IDCMP_MENUPICK: Selected ');
          done := processMenus(selection, done);

          selection := ItemAddress(FirstMenu, LONG(selection))^.NextSelect;
        end;
      end;
    end;
  end;
  Result := done;
end;


//* Steps thru each item to determine the maximum width of the strip */
function  MaxLength(textRPort: PRastPort; first_item: PMenuItem; char_size: Word): Word;
var
  maxLen            : Word;
  total_textlen     : Word;
  cur_item          : PMenuItem;
  itext             : PIntuiText;
  extra_width       : Word;
  maxCommCharWidth  : Word;
  commCharWidth     : Word;
begin
  extra_width := char_size;     //* used as padding for each item. */

  {* Find the maximum length of a command character, if any.
  ** If found, it will be added to the extra_width field.
  *}
  maxCommCharWidth := 0;
  cur_item := first_item;
  while (cur_item <> nil) do
  begin
    if (cur_item^.Flags and COMMSEQ <> 0) then
    begin
      commCharWidth := TextLength(textRPort, @(cur_item^.Command), 1);
      if (commCharWidth > maxCommCharWidth)
      then maxCommCharWidth := commCharWidth;
    end;
    cur_item := cur_item^.NextItem;
  end;

  {* if we found a command sequence, add it to the extra required space.  Add
  ** space for the Amiga key glyph plus space for the command character.  Note
  ** this only works for HIRES screens, for LORES, use LOWCOMMWIDTH.
  *}
  if (maxCommCharWidth > 0)
  then extra_width := extra_width + maxCommCharWidth + COMMWIDTH;

  //* Find the maximum length of the menu items, given the extra width calculated above. */
  maxLen := 0;

  cur_item := first_item;
  while (cur_item <> nil) do
  begin
    itext := PIntuiText(cur_item^.ItemFill);
    total_textlen := extra_width + itext^.LeftEdge +
          TextLength(textRPort, itext^.IText, strlen(itext^.IText));

    //* returns the greater of the two */
    if (total_textlen > maxLen)
    then maxLen := total_textlen;

    cur_item := cur_item^.NextItem;
  end;

  result := (maxLen);
end;


//* Set all IntuiText in a chain (they are linked through the NextText ** field) to the same font. */
procedure setITextAttr(first_IText: PIntuiText; textAttr: PTextAttr);
var
  cur_IText : PIntuiText;
begin
  cur_IText := first_IText;
  while (cur_IText <> nil) do
  begin
    cur_IText^.ITextFont := textAttr;
    cur_IText := cur_IText^.NextText;
  end;
end;


procedure adjustItems(textRPort: PRastPort; first_item: PMenuItem; textAttr: PTextAttr; char_size: Word; Height: Word; level: Word; left_edge: Word);
var
  item_num      : Word;
  cur_item      : PMenuItem;
  strip_width, 
  subitem_edge  : Word;
begin
  if (first_item = nil)
  then exit;

  //* The width of this strip is the maximum length of its members. */
  strip_width := MaxLength(textRPort, first_item, char_size);

  //* Position the items. */
  cur_item := first_item;
  item_num := 0;
  while (cur_item <> nil) do 
  begin
    cur_item^.TopEdge  := (item_num * height) - level;
    cur_item^.LeftEdge := left_edge;
    cur_item^.Width    := strip_width;
    cur_item^.Height   := height;

    //* place the sub_item 3/4 of the way over on the item. */
    subitem_edge := strip_width - (strip_width shr 2);

    setITextAttr(PIntuiText(cur_item^.ItemFill), textAttr);
    adjustItems(textRPort, cur_item^.SubItem, textAttr, char_size, height, 1, subitem_edge);

    cur_item := cur_item^.NextItem;
    inc(item_num);
  end;
end;


{* The following routines adjust an entire menu system to conform to the 
** specified fonts' width and height.  Allows for Proportional Fonts. This is 
** necessary for a clean look regardless of what the users preference in Fonts 
** may be.  Using these routines, you don't need to specify TopEdge, LeftEdge, 
** Width or Height in the MenuItem structures.
**
** NOTE that this routine does not work for menus with images, but assumes 
** that all menu items are rendered with IntuiText.
**
** This set of routines does NOT check/correct if the menu runs off
** the screen due to large fonts, too many items, lo-res screen.
*}
function  adjustMenus(first_menu: PMenu; textAttr: PTextAttr): Boolean;
var
  textrp        : TRastPort;             //* Temporary RastPort */
  cur_menu      : PMenu;
  font          : PTextFont;             //* Font to use */
  start, 
  char_size, 
  height        : Word;
  returnValue   : boolean = false;
begin
  textrp := default(TRastPort);
  
  //* open the font */
  if SetAndTest(font, OpenFont(textAttr)) then
  begin
    SetFont(@textrp, font);       //* Put font into temporary RastPort */

    char_size := TextLength(@textrp, 'n', 1);   //* Get the Width of the Font */

    {* To prevent crowding of the Amiga key when using COMMSEQ, don't allow the items to be less
    ** than 8 pixels high.  Also, add an extra pixel for inter-line spacing.
    *}
    if (font^.tf_YSize > 8)
    then height := 1 + font^.tf_YSize
    else height := 1 + 8;

    start := 2;      //* Set Starting Pixel */

    //* Step thru the menu structure and adjust it */
    cur_menu := first_menu;
    while (cur_menu <> nil) do 
    begin
      cur_menu^.LeftEdge := start;
      cur_menu^.Width := char_size + TextLength(@textrp, cur_menu^.MenuName, strlen(cur_menu^.MenuName));
      adjustItems(@textrp, cur_menu^.FirstItem, textAttr, char_size, height, 0, 0);
      start := start + cur_menu^.Width + char_size + char_size;

      cur_menu := cur_menu^.NextMenu;
    end;
    CloseFont(font);              //* Close the Font */
    returnValue := TRUE;
  end;
  result := (returnValue);
end;


begin
  ExitCode := Main(Argc, ArgV);
end.
