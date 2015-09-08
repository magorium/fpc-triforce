program example7e;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example7e
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

       Unless otherwise noted, you should consider these examples to be 
                 copyrighted by their respective owners

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
  Win,
  StringTop, StringBottom, Info, LeftButton, RightButton : pObject_;


function  Number(hook: PHook; info: pObject_; data: pLong): LONG;
Const ProcName = 'Number';
Var
  number_val : LONG;
begin
  Enter(ProcName);

  GetAttr (MUIA_String_Integer, StringTop, @number_val);

  DoMethod (info, MUIM_SetAsString, 
  [
    TAG_(MUIA_Text_Contents), TAG_(PChar('Entered %ld = $%lx')),
    TAG_(number_val), TAG_(number_val)
  ]);
  
  result := 0;

  Leave(ProcName);
end;


Var
  h_Number  : THook; { FPC Note: the hook is initialized with InitHook() }


//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);

  App := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)           , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)             , TAG_(PChar('EXAMPLE7E')),
    TAG_(MUIA_Application_Copyright)        , TAG_(PChar('© 1999 by BlaBla Corp.')),
    TAG_(MUIA_Application_Description)      , TAG_(PChar('Example 7e to the MUI tutorial')),
    TAG_(MUIA_Application_Title)            , TAG_(PChar('Example7e')),
    TAG_(MUIA_Application_Version)          , TAG_(PChar('$VER: example7e 1.0 (2.9.1999) BLABLA PRODUCT')),
    TAG_(MUIA_Application_Window)           , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)               , TAG_(PChar('Example 7e')),
      TAG_(MUIA_Window_ID)                  , $50525A4B,
      TAG_(MUIA_UserData)                   , TAG_(OBJ_WINDOW),
      TAG_(MUIA_Window_RootObject)          , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)              , TAG_(MUI_NewObject (MUIC_Group,   //* a group with strings */
        [
          TAG_(MUIA_Group_Horiz)            , TAG_(TRUE),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Group,   //* some labels */
          [
            TAG_(MUIA_HorizWeight)          , 0,
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Text,
            [
              TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_String),
              TAG_(MUIA_FramePhantomHoriz)  , TAG_(TRUE),
              TAG_(MUIA_Text_Contents)      , TAG_(PChar(Esc_R + 'Numeric gadget')),
              TAG_END
            ])),
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Text,
            [
              TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_String),
              TAG_(MUIA_FramePhantomHoriz)  , TAG_(TRUE),
              TAG_(MUIA_Text_Contents)      , TAG_(PChar(Esc_R + 'Write without vowels')),
              TAG_END
            ])),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Group,   //* and here the text gadget */
          [
            TAG_(MUIA_Group_Child)          , TAG_(SetAndGet(StringTop, MUI_NewObject (MUIC_String,
            [
              TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_String),
              TAG_(MUIA_String_MaxLen)      , 12,                               //* enough for an integer */
              TAG_(MUIA_String_Format)      , TAG_(MUIV_String_Format_Right),
              TAG_(MUIA_String_Accept)      , TAG_(PChar('-0123456789')),
              TAG_(MUIA_String_Integer)     , 206,
              TAG_(MUIA_String_AdvanceOnCR) , TAG_(TRUE),
              TAG_(MUIA_CycleChain)         , TAG_(TRUE),
              TAG_END
            ]))),
            TAG_(MUIA_Group_Child)          , TAG_(SetAndGet(StringBottom, MUI_NewObject (MUIC_String,
            [
              TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_String),
              TAG_(MUIA_String_Reject)      , TAG_(PChar('AÂEËIOUYaâeëiouy')),
              TAG_(MUIA_CycleChain)         , TAG_(TRUE),
              TAG_END
            ]))),
            TAG_END
          ])),
          TAG_END
        ])),
        TAG_(MUIA_Group_Child)              , TAG_(MUI_NewObject (MUIC_Group,   //* a group of buttons */
        [
          TAG_(MUIA_Group_Horiz)            , TAG_(TRUE),
          TAG_(MUIA_Group_Child)            , TAG_(SetAndGet(LeftButton, MUI_NewObject (MUIC_Text,  //* left button */
          [
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_Button),
            TAG_(MUIA_Background)           , TAG_(MUII_ButtonBack),
            TAG_(MUIA_Font)                 , TAG_(MUIV_Font_Button),
            TAG_(MUIA_Text_Contents)        , TAG_(PChar(Esc_C + 'Left')),
            TAG_(MUIA_Text_HiChar)          , TAG_(PChar('l')),
            TAG_(MUIA_ControlChar)          , TAG_(PChar('l')),
            TAG_(MUIA_InputMode)            , TAG_(MUIV_InputMode_RelVerify),
            TAG_(MUIA_CycleChain)           , TAG_(TRUE),
            TAG_END
          ]))),
          TAG_(MUIA_Group_Child)            , TAG_(SetAndGet(RightButton, MUI_NewObject (MUIC_Text, //* right button */
          [
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_Button),
            TAG_(MUIA_Background)           , TAG_(MUII_ButtonBack),
            TAG_(MUIA_Font)                 , TAG_(MUIV_Font_Button),
            TAG_(MUIA_Text_Contents)        , TAG_(PChar(Esc_C + 'Right')),
            TAG_(MUIA_Text_HiChar)          , TAG_(PChar('r')),
            TAG_(MUIA_ControlChar)          , TAG_(PChar('r')),
            TAG_(MUIA_InputMode)            , TAG_(MUIV_InputMode_Toggle),
            TAG_(MUIA_CycleChain)           , TAG_(TRUE),
            TAG_END
          ]))),
          TAG_END
        ])),
        TAG_(MUIA_Group_Child)              , TAG_(SetAndGet(Info, MUI_NewObject (MUIC_Text,    //* an information box */
        [
          TAG_(MUIA_Frame)                  , TAG_(MUIV_Frame_Text),
          TAG_(MUIA_Background)             , TAG_(MUII_TextBack),
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


//* Initialization of notifications */

procedure SetNotifications;
Const ProcName = 'SetNotifications';
begin
  Enter(ProcName);

  {
    FPC Note:
    In order to be cross-platform compatible we need to initilize the hook
    using InitHook(), which we do here for convenience.
  }
  InitHook(h_Number, THookFunction(@Number), nil);

  //* Initialize notification for closing the window */

  DoMethod (Win, MUIM_Notify, 
  [
    TAG_(MUIA_Window_CloseRequest), TAG_(MUIV_EveryTime), TAG_(App), 
    2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
  ]);

  //* notification to detect changes on the top string */

  DoMethod (StringTop, MUIM_Notify, 
  [
    TAG_(MUIA_String_Acknowledge), TAG_(MUIV_EveryTime), TAG_(Info), 
    2, TAG_(MUIM_CallHook), TAG_(@h_Number)
  ]);

  //* notification to detect changes on the lower string */

  DoMethod (StringBottom, MUIM_Notify, 
  [
    TAG_(MUIA_String_Contents), TAG_(MUIV_EveryTime), TAG_(Info), 
    4, TAG_(MUIM_SetAsString), TAG_(MUIA_Text_Contents), TAG_(PChar('Current contents: '#34'%s'#34)), TAG_(MUIV_TriggerValue)
  ]);

  //* notification to detect pressing the left button */

  DoMethod (LeftButton, MUIM_Notify, 
  [
    TAG_(MUIA_Pressed), TAG_(FALSE), TAG_(Info), 
    3, TAG_(MUIM_Set), TAG_(MUIA_Text_Contents), TAG_(PChar('Left button clicked'))
  ]);

  //* notification to enable the right button */

  DoMethod (RightButton, MUIM_Notify, 
  [
    TAG_(MUIA_Selected), TAG_(TRUE), TAG_(Info), 
    3, TAG_(MUIM_Set), TAG_(MUIA_Text_Contents), TAG_(PChar(#27'1Right button on')), TAG_(MUIV_TriggerValue)
  ]);

  //* notification to disable the right button */

  DoMethod (RightButton, MUIM_Notify, 
  [
    TAG_(MUIA_Selected), TAG_(FALSE), TAG_(Info), 
    3, TAG_(MUIM_Set), TAG_(MUIA_Text_Contents), TAG_(PChar(#27'1Right button off')), TAG_(MUIV_TriggerValue)
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
