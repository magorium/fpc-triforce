program gtmenu;

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
  ===========================================================================
  Project : gtmenu
  Topic   : Example of menus made with gadtools
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/gtmenu.c
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

Uses
  Exec, AmigaDOS, Intuition, Gadtools, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

const
  newmenu : Array[0..16-1] of TNewMenu =
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

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  win       : PWindow;
  scr       : PScreen;
  imsg      : PIntuiMessage;
  cont      : Boolean;
  vi        : APTR  = nil;
  menu      : PMenu = nil;
  item      : PMenuItem;
begin
  if SetAndTest(win, OpenWindowTags (nil,
  [
    TAG_(WA_Left)       , 20, 
    TAG_(WA_Top)        , 30,
    TAG_(WA_Width)      , 100,
    TAG_(WA_Height)     , 50,
    TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_NEWLOOKMENUS or WFLG_NOCAREREFRESH),
    TAG_(WA_IDCMP)      , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_MENUPICK),
    TAG_END
  ])) then
  begin
    scr := win^.WScreen;

    if SetAndTest(vi, GetVisualInfoA(scr, nil))
    then if SetAndTest(menu, CreateMenusA(newmenu, nil))
      then if (LayoutMenus(menu, vi, [TAG_(GTMN_NewLookMenus), TAG_(TRUE), TAG_END]))
        then SetMenuStrip(win, menu);

    cont := TRUE;
    while cont do
    begin
      if (Wait ((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
        then cont := FALSE;

      while SetAndTest(imsg, PIntuiMessage(GetMsg(win^.UserPort))) do
      begin
        case (imsg^.IClass) of
          IDCMP_VANILLAKEY:
          begin
            if (imsg^.Code = $1b) //* Esc */
            then cont := FALSE;
          end;
          IDCMP_CLOSEWINDOW:
          begin
            cont := FALSE;
          end;
          IDCMP_MENUPICK:
          begin
            item := ItemAddress(menu, imsg^.Code);

            while assigned(Item) do
            begin
              WriteLn('menu selected: ', PIntuiText(item^.ItemFill)^.IText);

              item := ItemAddress(menu, item^.NextSelect);
            end;
          end;
        end;
        ReplyMsg(PMessage(imsg));
      end;
    end;  // while

    ClearMenuStrip(win);

    if assigned(menu) then FreeMenus(menu);
    if assigned(vi) then FreeVisualInfo(vi);

    CloseWindow(win);
  end;

  result := (0);
end;


//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/

Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  GadToolsBase := OpenLibrary(GADTOOLSNAME, 0);
  if not assigned(GadToolsBase) then Exit;
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
  if assigned(GadToolsBase) then CloseLibrary(pLibrary(GadToolsBase));
  {$ENDIF}
end;


begin
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
end.
