program example15c;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example15c
  Topic   : Use MUIM_Application_ReturnID to close a subwindow
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-14.html
  Sources : http://www.ppa.pl/artykuly/download/mui14.lha
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


Var
  App,  Win         : pObject_;
  DestructWin       : pObject_;     //* address of window to destroy */

Const
  DESTROY_WINDOW    = $6EDA40F2;    //* for useage in ReturnID */

Var
  AppClass          : pMUI_CustomClass;


//* small enhancement in order to ease things up a little

function  DoSuperNew(cl: pIClass; obj: pObject_; const tags: Array of LongWord): pObject_;
begin
  result := pObject_(DoSuperMethod (cl, obj, OM_NEW, [TAG_(@tags), TAG_(nil)]));
end;



//* ======= Our class derived from the Application class ================== */


//* method identifiers */

Const
  APPM_AddSubWindow = $6EDA0001;
  APPM_RemSubWindow = $6EDA0002;


//* object data */

Type
  Papp_data = ^Tapp_data;
  Tapp_data = record
    subwindow : pObject_;   //* to keep track of the second window */
    button    : pObject_;
  end;


//* method "New" */

function app_New(cl: pIClass; obj: pObject_; msg: popSet): LONG;
Const ProcName = 'app_New';
var
  data : papp_data;
  _win, _button, _obj : pObject_;
begin
  Enter(ProcName);
  
  _obj := DoSuperNew (cl, obj,
  [
    TAG_(MUIA_Application_Window)   , TAG_(SetAndGet(_win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)       , TAG_(PChar('Example 15c')),
      TAG_(MUIA_Window_RootObject)  , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)      , TAG_(SetAndGet(_button, MUI_NewObject (MUIC_Text,
        [
          TAG_(MUIA_Text_Contents)  , TAG_(PChar(Esc_C + 'Open a second window')),
          TAG_(MUIA_Text_HiChar)    , TAG_(PChar('o')),
          TAG_(MUIA_ControlChar)    , TAG_(PChar('o')),
          TAG_(MUIA_Frame)          , TAG_(MUIV_Frame_Button),
          TAG_(MUIA_Background)     , TAG_(MUII_ButtonBack),
          TAG_(MUIA_Font)           , TAG_(MUIV_Font_Button),
          TAG_(MUIA_InputMode)      , TAG_(MUIV_InputMode_RelVerify),
          TAG_END
        ]))),
        TAG_END
      ])),
      TAG_END
    ]))),
    TAG_MORE                        , TAG_(msg^.ops_AttrList)
  ]);

  if (_obj <> nil) then
  begin
    data := INST_DATA (cl, pointer(_obj));
    Win := _win;                    //* not the best solution, so be it */

    DoMethod (_win, MUIM_Notify, 
    [
      TAG_(MUIA_Window_CloseRequest), TAG_(TRUE), TAG_(_obj), 
      2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
    ]);

    DoMethod (_button, MUIM_Notify, 
    [
      TAG_(MUIA_Pressed), TAG_(FALSE), TAG_(_obj), 
      1, TAG_(APPM_AddSubWindow)
    ]);

    data^.subwindow := nil;         //* Just for good measures */
    data^.button    := _button;

    exit(ULONG(_obj));
  end;
  result := 0;
  
  Leave(ProcName);  
end;


//* method "AddSubWindow" */

function app_AddSubWindow(cl: pIClass; obj: pObject_; msg: intuition.pmsg): LONG;
Const ProcName = 'app_AddSubWindow';
var
  data   : papp_data;
  subwin : pObject_;
begin
  Enter(ProcName);
  
  data := INST_DATA (cl, pointer(obj));

  subwin := MUI_NewObject (MUIC_Window,
  [
    TAG_(MUIA_Window_Title)         , TAG_(PChar('The second window')),
    TAG_(MUIA_Window_RootObject)    , TAG_(MUI_NewObject (MUIC_Group,
    [
      TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Text,
      [
        TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_Text),
        TAG_(MUIA_Background)       , TAG_(MUII_TextBack),
        TAG_(MUIA_Text_Contents)    , TAG_(PChar('The second window opened')),
        TAG_END
      ])),
      TAG_END
    ])),
    TAG_END
  ]);

  if (subwin <> nil) then
  begin
    data^.subwindow := subwin;

    //* Lock the button in order to prevent multiple creations of  */
    //* 'a second window' infinitely.                              */

    SetAttrs (data^.button, [TAG_(MUIA_Disabled), TAG_(TRUE), TAG_END]);
    DoMethod (subwin, MUIM_Notify, 
    [
      TAG_(MUIA_Window_CloseRequest), TAG_(TRUE), TAG_(obj), 
      1, TAG_(APPM_RemSubWindow)
    ]);
    DoMethod (obj, OM_ADDMEMBER, [TAG_(subwin)]);
    SetAttrs (subwin, [TAG_(MUIA_Window_Open), TAG_(TRUE), TAG_END]);
  end;
  result := 0;
  
  Leave(ProcName);  
end;


//* method "RemSubWindow" */

function app_RemSubWindow(cl: pIClass; obj: pObject_; msg: intuition.pmsg): LONG;
Const ProcName = 'app_RemSubWindow';
var
  data   : papp_data;
begin
  Enter(ProcName);
  
  data := INST_DATA (cl, pointer(obj));

  SetAttrs (data^.subwindow, [TAG_(MUIA_Window_Open), TAG_(FALSE), TAG_END]);
  DoMethod (obj, OM_REMMEMBER, [TAG_(data^.subwindow)]);
  SetAttrs (data^.button, [TAG_(MUIA_Disabled), TAG_(FALSE), TAG_END]);

  //* Intialize the ReturnID */

  DestructWin := data^.subwindow;
  data^.subwindow := nil;
  DoMethod (obj, MUIM_Application_ReturnID, [DESTROY_WINDOW]);

  result := 0;

  Leave(ProcName);  
end;


//* The class dispatcher */

function app_dispatcher(cl: pIClass; obj: pObject_; msg: intuition.pmsg): LONG;
Const ProcName = 'app_dispatcher';
begin
  //  Enter(ProcName);    // The dispatcher is invoked _a lot_
  
  case (msg^.MethodID) of
    OM_NEW              : result := (app_New          (cl, obj, popSet(msg)));
    APPM_AddSubWindow   : result := (app_AddSubWindow (cl, obj, msg));
    APPM_RemSubWindow   : result := (app_RemSubWindow (cl, obj, msg));
    else                  result := (DoSuperMethodA   (cl, obj, msg));
  end;

  //  Leave(ProcName);    // The dispatcher is invoked _a lot_
end;


//* function to create the class */

function CreateAppClass: pMUI_CustomClass;
Const ProcName = 'CreateAppClass';
begin
  Enter(ProcName);

  result := MUI_CreateCustomClass (nil, MUIC_Application, Nil, sizeof(Tapp_data), nil);
  { FPC Note: Cross platform compatible initialization of the dispatcher hook }
  inithook(result^.mcc_Class^.cl_Dispatcher, THookFunction(@app_dispatcher), nil);
  
  Leave(ProcName);
end;

 
//* ==================== End of class code ================================ */



//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);

  App := NewObject (AppClass^.mcc_Class, nil,
  [
    TAG_(MUIA_Application_Author)       , TAG_(PChar('Grzegorz "Krashan" Kraszewski')),
    TAG_(MUIA_Application_Base)         , TAG_(PChar('EXAMPLE15C')),
    TAG_(MUIA_Application_Copyright)    , TAG_(PChar('© 2000 by Grzegorz Kraszewski')),
    TAG_(MUIA_Application_Description)  , TAG_(PChar('Example 15c to the MUI tutorial')),
    TAG_(MUIA_Application_Title)        , TAG_(PChar('Example15c')),
    TAG_(MUIA_Application_Version)      , TAG_(PChar('$VER: example15c 1.0 (25.11.2000)')),
    TAG_END
  ]);

  Result := (App <> nil);
  
  Leave(ProcName);
end;


//* Main loop of the application */

procedure MainLoop;
Const ProcName = 'MainLoop';
Var
  signals: LONG;
  Running: boolean = true;
  
begin
  Enter(ProcName);

  SetAttrs(Win, [ TAG_(MUIA_Window_Open), TAG_(True), TAG_END ]);
  
  while running do
  begin
    Case LongInt(DoMethod (App, MUIM_Application_NewInput, [TAG_(@signals)] )) of
      MUIV_Application_ReturnID_Quit:
      begin
        running := FALSE;
      end;

      DESTROY_WINDOW:
      begin
        MUI_DisposeObject (DestructWin);
      end;
    end;

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
    if SetAndTest(MUIMasterBase, OpenLibrary('muimaster.library', 19)) then
    {$ENDIF}
    begin
      If SetAndTest(AppClass, CreateAppClass) then
      begin
        if BuildApplication then
        begin
          MainLoop;
          MUI_DisposeObject(App);
        end;
        MUI_DeleteCustomClass (AppClass);
      end;
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      CloseLibrary(MUIMasterBase);
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
  Writeln('Errors and/or unexpected behaviour is to be expected in this example.');

  ExitCode := Main;

  WriteLn('leave');  
end.
