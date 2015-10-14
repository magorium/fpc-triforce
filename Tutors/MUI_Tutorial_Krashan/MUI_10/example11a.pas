program example11a;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example11a
  Topic   : Modify behaviour of an existing class
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-10.html
  Sources : http://www.ppa.pl/artykuly/download/mui10.lha
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
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  AmigaLib,
  {$ENDIF}
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Sugar,
  Trinity;  

const
  OBJ_WINDOW    = 123456;   //* Shortcut ID to the window object for use in  */
                            //* functions MainLoop() and SetNotifications    */

Var
  App,
  Win           : pObject_;


Var
  SuperSliderClass  : PMUI_CustomClass;


//* =============== begin of class specific code =============== */


//* substituted method for MUIM_Numeric_Stringify */

function Stringify(cl: pIClass; obj: pObject_; msg: Intuition.pMsg): ULONG;
Const ProcName = 'Stringify';
begin
  Enter(ProcName);

  if ( pMUIP_Numeric_Stringify(msg)^.value = 13 )
  then result := ULONG(PChar('--'))
  else result := DoSuperMethodA (cl, obj, msg);

  Leave(ProcName);
end;


//* dispatcher */

function  SuperSliderDispatcher(cl: pIClass; obj: PObject_; msg: Intuition.pMsg): ULONG;
Const ProcName = 'SuperSliderDispatcher';
begin
  Enter(ProcName);

  case msg^.MethodID of
    MUIM_Numeric_Stringify: result := StringiFy(cl, obj, msg);
    else                    result := DoSuperMethodA (cl, obj, msg);
  end;

  Leave(ProcName);
end;

//* ================ end of class specific code ================ */


//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);
  
  App := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)           , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)             , TAG_(PChar('EXAMPLE11A')),
    TAG_(MUIA_Application_Copyright)        , TAG_(PChar('© 2000 by BlaBla Corp.')),
    TAG_(MUIA_Application_Description)      , TAG_(PChar('Example 11a to the MUI tutorial')),
    TAG_(MUIA_Application_Title)            , TAG_(PChar('Example11a')),
    TAG_(MUIA_Application_Version)          , TAG_(PChar('$VER: example11a 1.0 (19.3.2000) BLABLA PRODUCT')),
    TAG_(MUIA_Application_Window)           , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)               , TAG_(PChar('Example 11a')),
      TAG_(MUIA_Window_ID)                  , $50525A4B,
      TAG_(MUIA_UserData)                   , TAG_(OBJ_WINDOW),
      TAG_(MUIA_Window_RootObject)          , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)              , TAG_(MUI_NewObject (MUIC_Group,
        [                                                                  
          TAG_(MUIA_Group_Horiz)            , TAG_(TRUE),                           
          TAG_(MUIA_Group_Child)            , TAG_(NewObject (SuperSliderClass^.mcc_Class, nil,
          [
            TAG_(MUIA_Numeric_Min)          , 8,
            TAG_(MUIA_Numeric_Max)          , 16,
            TAG_(MUIA_Slider_Horiz)         , TAG_(FALSE),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Rectangle,
          [
            TAG_END
          ])),
          TAG_END
        ])),
        TAG_(MUIA_Group_Child)              , TAG_(NewObject (SuperSliderClass^.mcc_Class, nil,
        [
          TAG_(MUIA_Numeric_Min)            , 4,
          TAG_(MUIA_Numeric_Max)            , 30,
          TAG_(MUIA_Numeric_CheckAllSizes)  , 0,
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
    {$IFNDEF HASAMIGA}
    if SetAndTest(UtilityBase, OpenLibrary('utility.library', 37)) then
    {$ENDIF}
    begin
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      if SetAndTest(MUIMasterBase, OpenLibrary('muimaster.library', 16)) then
      {$ENDIF}
      begin
        if SetAndtest(SuperSliderClass, MUI_CreateCustomClass(nil, MUIC_Slider, nil, 0, nil)) then
        begin
          { FPC Note: Cross platform compatible initialization of the hooks }
          InitHook(SuperSliderClass^.mcc_Class^.cl_Dispatcher , THookFunction(@SuperSliderDispatcher) , nil);

          if BuildApplication then
          begin
            SetNotifications;
            MainLoop;
            MUI_DisposeObject(App);
          end;
          MUI_DeleteCustomClass(SuperSliderClass);
        end;
        {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
        CloseLibrary(MuiMasterBase);
        {$ENDIF}
      end;
      {$IFNDEF HASAMIGA}
      CloseLibrary(UtilityBase);
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
