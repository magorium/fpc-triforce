program example12a;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example12a
  Topic   : Subclassing Area - follow the pointer
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-11.html
  Sources : http://www.ppa.pl/artykuly/download/mui11.lha
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
  Exec, AmigaDOS, AGraphics, Intuition, MUI, Utility,
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
  MouseArrowClass   : PMUI_CustomClass;


{
  FPC Note:
  The original c-source uses fastmath include file, but for FPC we made
  its implementation here (lazy solution)
}
function sqrt32(Arg: LongWord): Word;
begin
  Result := Round(System.Sqrt(Arg));
end;


//* =============== begin of class specific code =============== */

//* object data */

Type
  PMouseArrow = ^TMouseArrow;
  TMouseArrow = record
    DeltaX : SmallInt;
    DeltaY : SmallInt;
    EHNode : TMUI_EventHandlerNode;
  end;
  

//* method AskMinMax */

function mAskMinMax(cl: pIClass; obj: pObject_; msg: pMUIP_AskMinMax): ULONG;
Const ProcName = 'mAskMinMax';
begin
  Enter(ProcName);

  DoSuperMethodA (cl, obj, msg);
  msg^.MinMaxInfo^.MinWidth  := msg^.MinMaxInfo^.MinWidth  + 40;
  msg^.MinMaxInfo^.DefWidth  := msg^.MinMaxInfo^.DefWidth  + 40;
  msg^.MinMaxInfo^.MaxWidth  := msg^.MinMaxInfo^.MaxWidth  + 40;
  msg^.MinMaxInfo^.MinHeight := msg^.MinMaxInfo^.MinHeight + 40;
  msg^.MinMaxInfo^.DefHeight := msg^.MinMaxInfo^.DefHeight + 40;
  msg^.MinMaxInfo^.MaxHeight := msg^.MinMaxInfo^.MaxHeight + 40;
  result := 0;

  Leave(ProcName);
end;

 
//* method Draw */

Const
  RADIUS    = 18;   //* Radius of the arrows */


function  mDraw(cl: pIClass; obj: pObject_; msg: pMUIP_Draw): ULONG;
Const ProcName = 'mDraw';
var
  big_radius : word;
  dx,dy      : Longint;
  rp         : pRastPort;
  data       : pMouseArrow;
begin
  Enter(ProcName);

  rp   := OBJ_rp(obj);

  data := INST_DATA(cl,pointer(obj));

  DoSuperMethodA (cl, obj, msg);
  big_radius := sqrt32 (data^.DeltaX * data^.DeltaX + data^.DeltaY * data^.DeltaY);
  if (big_radius <> 0) then
  begin
    dx := (data^.DeltaX * RADIUS) div big_radius;
    dy := (data^.DeltaY * RADIUS) div big_radius;
  end
  else
  begin
    dx := 0;
    dy := 0;
  end;
  SetAPen    (rp, 1);
  GfxMove    (rp, OBJ_mleft(obj) + 20 + dx, OBJ_mtop(obj) + 20 + dy);
  Draw       (rp, OBJ_mleft(obj) + 20 - dx, OBJ_mtop(obj) + 20 - dy);
  SetAPen    (rp, 2);
  WritePixel (rp, OBJ_mleft(obj) + 20 + dx, OBJ_mtop(obj) + 20 + dy);
  WritePixel (rp, OBJ_mleft(obj) + 21 + dx, OBJ_mtop(obj) + 20 + dy);
  WritePixel (rp, OBJ_mleft(obj) + 20 + dx, OBJ_mtop(obj) + 21 + dy);
  WritePixel (rp, OBJ_mleft(obj) + 19 + dx, OBJ_mtop(obj) + 20 + dy);
  WritePixel (rp, OBJ_mleft(obj) + 20 + dx, OBJ_mtop(obj) + 19 + dy);
  result := 0;

  Leave(ProcName);
end;


//* method Setup */

function  mSetup(cl: pIClass; obj: pObject_; msg: intuition.pMsg): ULONG;
Const ProcName = 'mSetup';
var
  data: pMouseArrow;
begin
  Enter(ProcName);

  data := INST_DATA(cl,pointer(obj));

  if (DoSuperMethodA (cl, obj, msg) <> 0) then
  begin
    data^.EHNode.ehn_Priority   := 0;
    data^.EHNode.ehn_Flags      := 0;
    data^.EHNode.ehn_Object     := obj;
    data^.EHNode.ehn_Class      := cl;
    data^.EHNode.ehn_Events     := IDCMP_MOUSEMOVE;
    DoMethod (OBJ_win(obj), MUIM_Window_AddEventHandler, [TAG_(@data^.EHNode)]);
    longbool(result) := TRUE;
    exit(result);
  end;
  longbool(result) := FALSE;

  Leave(ProcName);
end;


//* method Cleanup */

function  mCleanup(cl: pIClass; obj: pObject_; msg: intuition.pMsg): ULONG;
Const ProcName = 'mCleanup';
var
  data: pMouseArrow;
begin
  Enter(ProcName);

  data := INST_DATA(cl,pointer(obj));
  DoMethod (OBJ_win(obj), MUIM_Window_RemEventHandler, [TAG_(@data^.EHNode)]);

  Leave(ProcName);
end;


//* method HandleEvent */

function  mHandleEvent(cl: pIClass; obj: pObject_; msg: pMUIP_HandleEvent): ULONG;
Const ProcName = 'mHandleEvent';
var
  data: pMouseArrow;
begin
  Enter(ProcName);

  data := INST_DATA(cl,pointer(obj));

  if (msg^.imsg <> nil) then
  begin
    if (msg^.imsg^.IClass = IDCMP_MOUSEMOVE) then
    begin
      data^.DeltaX := msg^.imsg^.MouseX - OBJ_mleft(obj) - 20;
      data^.DeltaY := msg^.imsg^.MouseY - OBJ_mtop(obj)  - 20;
      MUI_Redraw (obj, MADF_DRAWOBJECT);
    end;
  end;
  result := 0;

  Leave(ProcName);
end;


//* dispatcher */

function  MouseArrowDispatcher(cl: pIClass; obj: PObject_; msg: Intuition.pMsg): ULONG;
Const ProcName = 'MouseArrowDispatcher';
begin
  Enter(ProcName);

  case msg^.MethodID of
    MUIM_Setup       : result := ( mSetup         (cl, obj, msg)                   );
    MUIM_Cleanup     : result := ( mCleanup       (cl, obj, msg)                   );
    MUIM_AskMinMax   : result := ( mAskMinMax     (cl, obj, pMUIP_AskMinMax(msg))  );
    MUIM_Draw        : result := ( mDraw          (cl, obj, pMUIP_Draw(msg))       );
    MUIM_HandleEvent : result := ( mHandleEvent   (cl, obj, pMUIP_HandleEvent(msg)));
    else               result := ( DoSuperMethodA (cl, obj, msg)                   );
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
    TAG_(MUIA_Application_Author)       , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)         , TAG_(PChar('EXAMPLE12A')),
    TAG_(MUIA_Application_Copyright)    , TAG_(PChar('© 2000 by BlaBla Corp.')),
    TAG_(MUIA_Application_Description)  , TAG_(PChar('Example 12a to the MUI tutorial')),
    TAG_(MUIA_Application_Title)        , TAG_(PChar('Example12a')),
    TAG_(MUIA_Application_Version)      , TAG_(PChar('$VER: example12a 1.0 (20.5.2000) BLABLA PRODUCT')),
    TAG_(MUIA_Application_Window)       , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)           , TAG_(PChar('Example 12a')),
      TAG_(MUIA_Window_ID)              , $50525A4B,
      TAG_(MUIA_UserData)               , TAG_(OBJ_WINDOW),
      TAG_(MUIA_Window_RootObject)      , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Group,
        [                                                                  
          TAG_(MUIA_Group_Columns)      , 3,
          TAG_(MUIA_Group_Child)        , TAG_(NewObject (MouseArrowClass^.mcc_Class, nil,
          [
            TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_Text),
            TAG_(MUIA_Background)       , TAG_(MUII_TextBack),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Rectangle,
          [
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(NewObject (MouseArrowClass^.mcc_Class, nil,
          [
            TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_Text),
            TAG_(MUIA_Background)       , TAG_(MUII_TextBack),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Rectangle,
          [
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Rectangle,
          [
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Rectangle,
          [
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(NewObject (MouseArrowClass^.mcc_Class, nil,
          [
            TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_Text),
            TAG_(MUIA_Background)       , TAG_(MUII_TextBack),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Rectangle,
          [
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)        , TAG_(NewObject (MouseArrowClass^.mcc_Class, nil,
          [
            TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_Text),
            TAG_(MUIA_Background)       , TAG_(MUII_TextBack),
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


//* opening all libraries */

function OpenLibs: boolean;
Const ProcName = 'OpenLibs';
begin
  Enter(ProcName);

  {$IFDEF MORPHOS}
  if not ( SetAndTest( IntuitionBase, OpenLibrary('intuition.library' , 39))) then exit(false);
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if not ( SetAndTest( GfxBase      , OpenLibrary('graphics.library'  , 39))) then exit(false);
  {$ENDIF}
  {$IFNDEF HASAMIGA}
  if not ( SetAndTest( UtilityBase  , OpenLibrary('utility.library'   , 39))) then exit(false);
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  if not ( SetAndTest( MUIMasterBase, OpenLibrary('muimaster.library' , 19))) then exit(false);
  {$ENDIF}
  result := true;

  Leave(ProcName);
end;


//* closing all libraries */

procedure CloseLibs;
Const ProcName = 'CloseLibs';
begin
  Enter(ProcName);

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if (MUIMasterBase  <> nil) then CloseLibrary(MUIMasterBase);
  {$ENDIF}
  {$IFNDEF HASAMIGA}
  if (UtilityBase    <> nil) then CloseLibrary(UtilityBase);
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if (GfxBase        <> nil) then CloseLibrary(pointer(GfxBase));
  {$ENDIF}
  {$IFDEF MORPHOS}
  if (IntuitionBase  <> nil) then CloseLibrary(pointer(IntuitionBase));
  {$ENDIF}

  Leave(ProcName);
end;


//* Main function of the application */

Function Main: integer;
Const ProcName = 'Main';
begin
  Enter(ProcName);

  if OpenLibs then
  begin
    if SetAndtest(MouseArrowClass, MUI_CreateCustomClass(nil, MUIC_Area, nil, sizeof(TMouseArrow), nil)) then
    begin
      { FPC Note: Cross platform compatible initialization of the hooks }    
      InitHook(MouseArrowClass^.mcc_Class^.cl_Dispatcher , THookFunction(@MouseArrowDispatcher) , nil);

      if BuildApplication then
      begin
        SetNotifications;
        MainLoop;
        MUI_DisposeObject(App);
      end;

      MUI_DeleteCustomClass (MouseArrowClass);
    end;
  end;
  CloseLibs;
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
