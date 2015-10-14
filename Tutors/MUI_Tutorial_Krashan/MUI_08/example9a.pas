program example9a;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example9a
  Topic   : Presenting and inserting data in a ListView
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-8.html
  Sources : http://www.ppa.pl/artykuly/download/mui8.lha
  ===========================================================================
 
  This example was originally written in c as part of the MUI tutorials,
  which were written by Grzegorz Kraszewski.
  
  The original articles (written in the Polish language) are still available 
  online at PPA.pl (http://www.ppa.pl/programy/szkolki/) in 14 different
  pages.
  
  The tutorials and examples were also released in a (Polish) printed 
  magazine by ACS publisher (which doesn't exist anymore).
  
  The c-sources were converted to Free Pascal, and (variable) names and 
  comments were translated into English as much as possible.
  
  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc
  
  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Some additional Pascal code was added to make the examples (hopefully) more 
  clear for beginners.
  
  Conversion to Free Pascal was done by Magorium in 2015, with kind permission 
  from Krashan to be able to publish.

  ===========================================================================

           Unless otherwise noted, these examples must be considered
                 copyrighted by their respective owner(s)

  ===========================================================================
}

Uses
  Exec, AmigaDOS, Intuition, MUI, Utility,
  CHelpers,
  Sugar,
  Trinity;  


const
  OBJ_WINDOW    = 123456;   //* Shortcut ID to the window object for use in  */
                            //* functions MainLoop() and SetNotifications    */

Var
  DefaultList   : array[0..4] of PChar =
  (
    'Acorn', 
    'IBM',
    'Sun', 
    'ZX Spectrum',
    nil
  );

Var
  App,
  Win,
  Listview      : pObject_;


//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);

  App := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)           , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)             , TAG_(PChar('EXAMPLE9A')),
    TAG_(MUIA_Application_Copyright)        , TAG_(PChar('© 1999 by BlaBla Corp.')),
    TAG_(MUIA_Application_Description)      , TAG_(PChar('Example 9a to the MUI tutorial')),
    TAG_(MUIA_Application_Title)            , TAG_(PChar('Example9a')),
    TAG_(MUIA_Application_Version)          , TAG_(PChar('$VER: example9a 1.0 (4.12.1999) BLABLA PRODUCT')),
    TAG_(MUIA_Application_Window)           , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)               , TAG_(PChar('Example 9a')),
      TAG_(MUIA_Window_ID)                  , $50525A4B,
      TAG_(MUIA_UserData)                   , TAG_(OBJ_WINDOW),
      TAG_(MUIA_Window_RootObject)          , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)              , TAG_(SetAndGet(Listview, MUI_NewObject (MUIC_Listview,
        [
          TAG_(MUIA_Listview_List)          , TAG_(MUI_NewObject (MUIC_List,
          [
            TAG_(MUIA_List_ConstructHook)   , TAG_(MUIV_List_ConstructHook_String),
            TAG_(MUIA_List_DestructHook)    , TAG_(MUIV_List_DestructHook_String),
            TAG_(MUIA_List_SourceArray)     , TAG_(@DefaultList),
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_ReadList),
            TAG_END
          ])),
          TAG_END
        ]))),
        TAG_END
      ])),
      TAG_END
    ]))),
    TAG_END
  ]);

  Result := (App <> nil);
  
  Leave(ProcName);
end;


//* Initialize notification for closing the window */

procedure SetNotifications;
Const ProcName = 'SetNotifications';
begin
  Enter(ProcName);

  DoMethod (Win, MUIM_Notify, 
  [
    TAG_(MUIA_Window_CloseRequest), TAG_(MUIV_EveryTime), TAG_(App), 
    2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
  ]);
  
  Leave(ProcName);
end;


//* Main loop of the application */

procedure MainLoop;
Const ProcName = 'MainLoop';
Var
  signals: LONG;
begin
  Enter(ProcName);

  SetAttrs(Win, [ TAG_(MUIA_Window_Open), TAG_(True), TAG_END ]);
  
  while (DoMethod ( Pointer(App), MUIM_Application_NewInput, [TAG_(@Signals)] ) <> LongWord(MUIV_Application_ReturnID_Quit)) do
  begin
    if (signals <> 0) then
    begin
      signals := Wait (signals or SIGBREAKF_CTRL_C);
      if ((signals and SIGBREAKF_CTRL_C) <> 0) then break;
    end;
  end;

  SetAttrs (Win, [TAG_(MUIA_Window_Open), TAG_(FALSE), TAG_END]); 

  Leave(ProcName);
end;


//* Use two diferent methods to insert items into the list */

procedure InsertElements;
Const ProcName = 'Main';
var
  elements : array[0..6] of PChar =
       ( Esc_B + 'Amiga' + Esc_N, 'Atari', 'C64', 'SGI', 'Sun', 'PC', nil );
begin
  Enter(ProcName);

  DoMethod (Listview, MUIM_List_Insert, 
  [
    TAG_(@elements), TAG_(-1), TAG_(MUIV_List_Insert_Top)
  ]);

  DoMethod (Listview, MUIM_List_InsertSingle,
  [ 
    TAG_(PChar('ENIAC')), TAG_(MUIV_List_Insert_Top)
  ]);
  
  Leave(ProcName);
end;


//* Main function of the application */

Function Main: integer;
Const ProcName = 'Main';
begin
  Enter(ProcName);

  {$IFDEF MORPHOS}
  if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
  {$ENDIF}
  begin
    {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
    if SetAndTest(MUIMasterBase, OpenLibrary('muimaster.library', 16)) then
    {$ENDIF}
    begin
      if BuildApplication then
      begin
        SetNotifications;
        InsertElements ();
        MainLoop;
        MUI_DisposeObject(App);
      end;
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      CloseLibrary(MuiMasterBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CLoseLibrary(pLibrary(IntuitionBase));
    {$ENDIF}
  end;
  result := 0;
  
  Leave(ProcName);
end;


//
//        Startup
//

begin
  WriteLn('enter');

  ExitCode := Main;

  WriteLn('leave');
end.
