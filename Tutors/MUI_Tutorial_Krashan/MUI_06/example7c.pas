program example7c;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example7c
  Topic   : 
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-6.html
  Sources : http://www.ppa.pl/artykuly/download/mui6.lha
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
  App,
  Win           : pObject_;


//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);
  
  App := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)       , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)         , TAG_(PChar('EXAMPLE7C')),
    TAG_(MUIA_Application_Copyright)    , TAG_(PChar('© 1999 by BlaBla Corp.')),
    TAG_(MUIA_Application_Description)  , TAG_(PChar('Example 7c to the MUI tutorial')),
    TAG_(MUIA_Application_Title)        , TAG_(PChar('Example7c')),
    TAG_(MUIA_Application_Version)      , TAG_(PChar('$VER: example7c 1.0 (2.9.1999) BLABLA PRODUCT')),
    TAG_(MUIA_Application_Window)       , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)           , TAG_(PChar('Example 7c')),
      TAG_(MUIA_Window_ID)              , $50525A4B,
      TAG_(MUIA_UserData)               , TAG_(OBJ_WINDOW),
      TAG_(MUIA_Window_RootObject)      , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Horiz)          , TAG_(TRUE),
        TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Group,       //* a group of labels */
        [
          TAG_(MUIA_HorizWeight)        , 0,
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)    , TAG_(PChar(Esc_R + 'Vertical group')),
            TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_String),
            TAG_(MUIA_FramePhantomHoriz), TAG_(TRUE),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)    , TAG_(PChar(Esc_R + 'with phantom frame')),
            TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_String),
            TAG_(MUIA_FramePhantomHoriz), TAG_(TRUE),
            TAG_END
          ])),
          TAG_END
        ])),
        TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Group,       //* a groupf of strings */
        [
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_String,
          [
            TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_String),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_String,
          [
            TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_String),
            TAG_END
          ])),
          TAG_END
        ])),
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
        MainLoop;
        MUI_DisposeObject(App);
      end;
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      CloseLibrary(MuiMasterBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(pLibrary(IntuitionBase));
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
