program gadtoolsmenu;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

{
  Project   : gadtoolsmenu
  Source    : RKRM
}

 {*
 ** Example showing the basic usage of the menu system with a window.
 ** Menu layout is done with GadTools, as is recommended for applications.
 *}
  {$DEFINE INTUI_V36_NAMES_ONLY}

Uses
  Exec, Intuition, Gadtools, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


const
  mynewmenu : Array[0..16-1] of TNewMenu =
  (
    ( nm_Type: NM_TITLE; nm_Label: 'Project';             nm_CommKey: nil; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Open...';             nm_CommKey: 'O'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Save';                nm_CommKey: 'S'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Save As...';          nm_CommKey: 'A'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: PChar(NM_BARLABEL);    nm_CommKey: nil; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Quit';                nm_CommKey: 'Q'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),

    ( nm_Type: NM_TITLE; nm_Label: 'Edit';                nm_CommKey: nil; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Mark';                nm_CommKey: 'B'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Cut';                 nm_CommKey: 'X'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Copy';                nm_CommKey: 'C'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Paste';               nm_CommKey: 'V'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),

    ( nm_Type: NM_TITLE; nm_Label: 'Settings';            nm_CommKey: nil; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Reset to defaults';   nm_CommKey: 'D'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Reset to last saved'; nm_CommKey: 'L'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),
    ( nm_Type: NM_ITEM;  nm_Label: 'Previous settings';   nm_CommKey: 'P'; nm_Flags: 0; nm_MutualExclude: 0; nm_UserData: nil ),

    ( nm_Type: NM_END )
  );


{*
** Watch the menus and wait for the user to select the close gadget
** or quit from the menus.
*}
procedure handle_window_events(win: PWindow; menuStrip: PMenu);
var
  msg           : PIntuiMessage;
  done          : boolean;
  menuNumber    : UWORD;
  menuNum       : UWORD;
  itemNum       : UWORD;
  subNum        : UWORD;
  item          : PMenuItem;
begin
  done := FALSE;
  while (FALSE = done) do
  begin
    {* we only have one signal bit, so we do not have to check which
    ** bit broke the Wait().
    *}
    Wait(1 shl win^.UserPort^.mp_SigBit);

    while ( (FALSE = done) and (nil <> SetAndGet(msg, PIntuiMessage(GetMsg(win^.UserPort)))) ) do
    begin
      case (msg^.IClass) of
        IDCMP_CLOSEWINDOW:
        begin
          done := TRUE;
        end;
        IDCMP_MENUPICK:
        begin
          menuNumber := msg^.Code;
          while ((menuNumber <> UWORD(MENUNULL)) and not(done)) do
          begin
            item := ItemAddress(menuStrip, menuNumber);

            //* process the item here! */
            menuNum := Intuition.MENUNUM(menuNumber);
            itemNum := Intuition.ITEMNUM(menuNumber);
            subNum  := Intuition.SUBNUM(menuNumber);
            WriteLn('menunum = ', MenuNum, '   ', 'itemnum = ', ItemNum);
            //* stop if quit is selected. */
            //* FPC Note: there is a bug in original code, itemNum must be 4.
            if ( (menuNum = 0) and (itemNum = 4) )
            then done := TRUE;

            menuNumber := item^.NextSelect;
          end;
        end;
      end;
      ReplyMsg(PMessage(msg));
    end;
  end;
end;


{*
** Open all of the required libraries and set-up the menus.
*}
procedure main(argc: integer; argv: PPChar);
var
  win           : PWindow;
  my_VisualInfo : PAPTR;
  menuStrip     : PMenu;
begin
  //* Open the Intuition Library */
  {$IF DEFINED(MORPHOS)}
  IntuitionBase := PIntuitionBase(OpenLibrary('intuition.library', 37));
  if (IntuitionBase <> nil) then
  {$ENDIF}
  begin
    //* Open the gadtools Library */
    {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
    GadToolsBase := OpenLibrary('gadtools.library', 37);
    if (GadToolsBase <> nil) then
    {$ENDIF}
    begin
      if (nil <> SetAndGet(win, OpenWindowTags(nil,
      [
        TAG_(WA_Width)        , 400,
        TAG_(WA_Activate)     , TAG_(TRUE),
        TAG_(WA_Height)       , 100,
        TAG_(WA_CloseGadget)  , TAG_(TRUE),
        TAG_(WA_Title)        , TAG_(PChar('Menu Test Window')),
        TAG_(WA_IDCMP)        , IDCMP_CLOSEWINDOW or IDCMP_MENUPICK,
        TAG_END
      ]))) then
      begin
        if (nil <> SetAndGet(my_VisualInfo, GetVisualInfo(win^.WScreen, [TAG_END, 0]))) then
        begin
          if (nil <> SetAndGet(menuStrip, CreateMenus(@mynewmenu, [TAG_END, 0]))) then
          begin
            if (LayoutMenus(menuStrip, my_VisualInfo, [TAG_END, 0])) then
            begin
              if (SetMenuStrip(win, menuStrip)) then
              begin
                handle_window_events(win, menuStrip);

                ClearMenuStrip(win);
              end;
              FreeMenus(menuStrip);
            end;
          end;
          FreeVisualInfo(my_VisualInfo);
        end;
        CloseWindow(win);
      end;
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
      CloseLibrary(PLibrary(GadToolsBase));
      {$ENDIF}
    end;
    {$IF DEFINED(MORPHOS)}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
