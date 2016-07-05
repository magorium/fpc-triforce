program simplemenu;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : simplemenu
  Topic     : how to use the menu system with a window under all OS versions.
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AGraphics, Intuition,
  {$IFDEF AMIGA}
  //SystemVarTags,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;


const
  //*  These values are based on the ROM font Topaz8. Adjust these  */
  //*  values to correctly handle the screen's current font.        */
  MENWIDTH  = (56+8);   //* Longest menu item name * font width + 8 pixels for trim  */
  MENHEIGHT = (10);     //* Font height + 2 pixels              */



  //* To keep this example simple, we'll hard-code the font used for menu */
  //* items.  Algorithmic layout can be used to handle arbitrary fonts.   */
  //* Under Release 2, GadTools provides font-sensitive menu layout.      */
  //* Note that we still must handle fonts for the menu headers.          */
  Topaz80 : TTextAttr  =
  (
    ta_name  : 'topaz.font';
    ta_YSize : 8;
    ta_Style : 0;
    ta_Flags : 0;    
  );


  menuIText : Array[0..5] of TIntuiText =
  (
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 0; TopEdge: 1; 
      ITextFont: @Topaz80; IText: 'Open...';     NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 0; TopEdge: 1; 
      ITextFont: @Topaz80; IText: 'Save';        NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 0; TopEdge: 1; 
      ITextFont: @Topaz80; IText: 'Print '#27#3; NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 0; TopEdge: 1; 
      ITextFont: @Topaz80; IText: 'Draft';       NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 0; TopEdge: 1; 
      ITextFont: @Topaz80; IText: 'NLQ';         NextText: nil ),
    ( FrontPen: 0; BackPen: 1; DrawMode: JAM2; LeftEdge: 0; TopEdge: 1; 
      ITextFont: @Topaz80; IText: 'Quit';        NextText: nil )
  );

  submenu1: Array[0..1] of TMenuItem =
  (
    ( //* Draft  */
      NextItem: @submenu1[1]; 
      LeftEdge: MENWIDTH-2; TopEdge: -2; Width: MENWIDTH; Height: MENHEIGHT;
      Flags: ITEMTEXT or MENUTOGGLE or ITEMENABLED or HIGHCOMP;
      MutualExclude: 0; ItemFill: APTR(@menuIText[3]); SelectFill: nil; 
      Command: #0; SubItem: nil; NextSelect: 0;
    ),
    ( //* NLQ    */
      NextItem: nil;
      LeftEdge: MENWIDTH-2; TopEdge: MENHEIGHT-2; Width: MENWIDTH; Height: MENHEIGHT;
      Flags: ITEMTEXT or MENUTOGGLE or ITEMENABLED or HIGHCOMP;
      MutualExclude: 0; ItemFill: APTR(@menuIText[4]); SelectFill: nil;
      Command: #0; SubItem: nil; NextSelect: 0;
    )
  );

  menu1: array[0..3] of TMenuItem =
  (
    ( //* Open... */
      NextItem: @menu1[1];
      LeftEdge: 0; TopEdge: 0; Width: MENWIDTH; Height: MENHEIGHT;
      Flags: ITEMTEXT or MENUTOGGLE or ITEMENABLED or HIGHCOMP;
      MutualExclude: 0; ItemFill: APTR(@menuIText[0]); SelectFill: nil; 
      Command: #0; SubItem: nil; NextSelect: 0;
    ),
    ( //* Save    */
      NextItem: @menu1[2]; 
      LeftEdge: 0; TopEdge: MENHEIGHT; Width: MENWIDTH; Height: MENHEIGHT;
      Flags: ITEMTEXT or MENUTOGGLE or ITEMENABLED or HIGHCOMP;
      MutualExclude: 0; ItemFill: APTR(@menuIText[1]); SelectFill: nil; 
      Command: #0; SubItem: nil; NextSelect: 0;
    ),
    ( //* Print   */
      NextItem: @menu1[3]; 
      LeftEdge: 0; TopEdge: 2*MENHEIGHT; Width: MENWIDTH; Height: MENHEIGHT;
      Flags: ITEMTEXT or MENUTOGGLE or ITEMENABLED or HIGHCOMP;
      MutualExclude: 0; ItemFill: APTR(@menuIText[2]); SelectFill: nil; 
      Command: #0; SubItem: @submenu1[0]; NextSelect: 0;
    ),
    ( //* Quit    */
      NextItem: nil; 
      LeftEdge: 0; TopEdge: 3*MENHEIGHT; Width: MENWIDTH; Height: MENHEIGHT;
      Flags: ITEMTEXT or MENUTOGGLE or ITEMENABLED or HIGHCOMP;
      MutualExclude: 0; ItemFill: APTR(@menuIText[5]); SelectFill: nil; 
      Command: #0; SubItem: nil; NextSelect: 0;
    )
  );

  //* We only use a single menu, but the code is generalizable to */
  //* more than one menu.                                         */
  NUM_MENUS = 1;

  menutitle : array[0..Pred(NUM_MENUS)] of STRPTR = ( 'Project' );

  menustrip : array[0..Pred(NUM_MENUS)] of TMenu =
  (
    (
      NextMenu  : nil;          //* Next Menu          */
      LeftEdge  : 0;            //* LeftEdge, TopEdge, */
      TopEdge   : 0;            
      Width     : 0;            //* Width, Height,     */
      Height    : MENHEIGHT;
      Flags     : MENUENABLED;  //* Flags              */
      MenuName  : nil;          //* Title              */
      FirstItem : @menu1[0];    //* First item         */
    )
  );

  mynewWindow   : TNewWindow  =
  (
    LeftEdge    : 40;
    TopEdge     : 40;
    Width       : 300;
    Height      : 100;
    DetailPen   : 0;
    BlockPen    : 1;
    IDCMPFlags  : IDCMP_CLOSEWINDOW or IDCMP_MENUPICK;
    Flags       : WFLG_DRAGBAR or WFLG_ACTIVATE or WFLG_CLOSEGADGET;
    FirstGadget : nil;
    CheckMark   : nil;
    Title       : 'Menu Test Window';
    Screen      : nil;
    BitMap      : nil;
    MinWidth    : 0;
    MinHeight   : 0;
    MaxWidth    : 0;
    MaxHeight   : 0;
    WType       : WBENCHSCREEN_f;
  );



  //* our function prototypes */
  procedure handleWindow(win: PWindow; menuStrip: PMenu); forward;


  //*      Main routine.         */
  //*                            */
procedure Main(argc: Integer; argv: PPChar);
var
  win: PWindow = nil;
  left, m : UWORD;
begin
  //* Open the Graphics Library */
  {$IFNDEF HASAMIGA}
  GfxBase := OpenLibrary('graphics.library', 33);
  if assigned(GfxBase) then
  {$ENDIF}
  begin
    //* Open the Intuition Library */
    {$IFDEF MORPHOS}
    IntuitionBase := OpenLibrary('intuition.library', 33);
    if assigned(IntuitionBase) then
    {$ENDIF}
    begin
      if SetAndTest(win, OpenWindow(@mynewWindow) ) then
      begin
        left := 2;
        for m := 0 to Pred(NUM_MENUS) do
        begin
          menustrip[m].LeftEdge := left;
          menustrip[m].MenuName := menutitle[m];
          menustrip[m].Width    := TextLength(@PScreen(win^.WScreen)^.RastPort,
                                   menutitle[m], strlen(menutitle[m])) + 8;
          left := left + menustrip[m].Width;
        end;
        if (SetMenuStrip(win, menustrip)) then
        begin
          handleWindow(win, menustrip);
          ClearMenuStrip(win);
        end;
        CloseWindow(win);
      end;
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
**   Wait for the user to select the close gadget.
*}
procedure handleWindow(win: PWindow; menuStrip: PMenu);
var
  msg       : PIntuiMessage;
  done      : boolean;
  iclass    : ULONG;
  menuNumber: UWORD;
  menuNum   : UWORD;
  itemNum   : UWORD;
  subNum    : UWORD;
  item      : PMenuItem;
begin
  done := FALSE;
  while (FALSE = done) do
  begin
    {* we only have one signal bit, so we do not have to check which
    ** bit broke the Wait().
    *}
    Wait(1 shl win^.UserPort^.mp_SigBit);

    while ( (FALSE = done) and
            SetAndTest(msg, PIntuiMessage(GetMsg(win^.UserPort)))) do
    begin
      iclass := msg^.IClass;
      if (Iclass = IDCMP_MENUPICK) then menuNumber := msg^.Code;

      case (iclass) of
        IDCMP_CLOSEWINDOW:
        begin
          done := TRUE;
        end;
        IDCMP_MENUPICK:
        begin
          while ((menuNumber <> MENUNULL) and not(done)) do
          begin
            item := ItemAddress(menuStrip, menuNumber);

            {* process this item
            ** if there were no sub-items attached to that item,
            ** SubNumber will equal NOSUB.
            *}
             menuNum := intuition.MENUNUM(menuNumber);
             itemNum := intuition.ITEMNUM(menuNumber);
             subNum  := intuition.SUBNUM(menuNumber);

            {* Note that we are printing all values, even things
            ** like NOMENU, NOITEM and NOSUB.  An application should
            ** check for these cases.
            *}
            WriteLn(Format('IDCMP_MENUPICK: menu %d, item %d, sub %d',
                      [menuNum, itemNum, subNum]));

            {* This one is the quit menu selection...
            ** stop if we get it, and don't process any more.
            *}
            if ((menuNum = 0) and (itemNum = 4))
            then done := TRUE;

            menuNumber := item^.NextSelect;
          end;
        end;
      end;
      ReplyMsg(PMessage(msg));
    end;
  end;
end;


begin
  Main(Argc, ArgV);
end.
