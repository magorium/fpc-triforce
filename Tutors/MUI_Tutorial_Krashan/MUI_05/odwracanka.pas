program odwracanka;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : odwracanka
  Topic   : Playing with hooks
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-5.html
  Sources : http://www.ppa.pl/artykuly/download/mui5.lha
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


var
  Prog, 
  Window, 
  Group         : pObject_;

  Fields        : Array[0..Pred(9)] of pObject_;
  
  Dependency    : Array[0..pred(9), 0..Pred(4)] of LONG =
  (
    (1, 2, 3, 6), 
    (0, 2, 4, 7), 
    (0, 1, 5, 8), 
    (0, 4, 5, 6),
    (1, 3, 5, 7), 
    (2, 3, 4, 8), 
    (0, 3, 7, 8), 
    (1, 4, 6, 8), 
    (2, 5, 6, 7)
  );
  
 
procedure InvertSingle(which: LONG);
var
  status : LongBool;
begin
  GetAttr  (MUIA_Selected, Fields[which], @status);
  SetAttrs (Fields[which], [TAG_(MUIA_NoNotify), TAG_(TRUE), TAG_(MUIA_Selected), TAG_(not(status)), TAG_END]);
end;


Function Invert(hook: PHook; obj: pObject_; number: pLong): LONG;
Var i: integer;
begin
  for i := 0 to pred(4) do InvertSingle(Dependency[Number^][i]);
  
  result := 0;
end;


Var
  h_Invert: THook;


Function  Main: LONG;
Const ProcName = 'Main';
Var
  Signals : ULONG;
  i       : integer;
begin
  Enter(ProcName);

  Result := 0;

  {$IFDEF MORPHOS}
  if SetAndTest(IntuitionBase, OpenLibrary('intuition.library',37)) then
  {$ENDIF}
  begin
    {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
    if SetAndTest(MUIMasterBase, OpenLibrary('muimaster.library', 16)) then
    {$ENDIF}
    begin
      
      if SetAndTest(Prog, MUI_NewObject (MUIC_Application,
      [
        TAG_(MUIA_Application_Author)       , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
        TAG_(MUIA_Application_Base)         , TAG_(PChar('ODWARACANKA')),
        TAG_(MUIA_Application_Copyright)    , TAG_(PChar('Public Domain')),
        TAG_(MUIA_Application_Description)  , TAG_(PChar('Program demonstrating notifications')),
        TAG_(MUIA_Application_Title)        , TAG_(PChar('Odwracanka')),
        TAG_(MUIA_Application_Window)       , TAG_(SetAndGet(Window, MUI_NewObject (MUIC_Window,
        [
          TAG_(MUIA_Window_Activate)        , TAG_(TRUE),
          TAG_(MUIA_Window_ID)              , $4F445752,     //* "ODWR" */
          TAG_(MUIA_Window_Title)           , TAG_(PChar('Odwracanka')),
          TAG_(MUIA_Window_RootObject)      , TAG_(SetAndget(Group, MUI_NewObject (MUIC_Group,
          [
            TAG_(MUIA_Group_Horiz)          , TAG_(TRUE),
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Rectangle, [TAG_END]) ),
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Group,
            [
              TAG_(MUIA_Group_Columns)      , 3,
              TAG_(MUIA_Group_Spacing)      , 0,
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[0], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[1], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[2], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_(MUIA_Selected)         , TAG_(TRUE),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[3], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[4], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_(MUIA_Selected)         , TAG_(TRUE),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[5], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[6], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_(MUIA_Selected)         , TAG_(TRUE),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[7], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(Fields[8], MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_Toggle),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_CheckMark),
                TAG_(MUIA_ShowSelState)     , TAG_(FALSE),
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_(MUIA_Selected)         , TAG_(TRUE),
                TAG_END
              ]))),
              TAG_END
            ])),
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Rectangle, [TAG_END])),
            TAG_END
          ]))),
          TAG_END
        ]))),
        TAG_END
      ])) then
      begin
        {
          FPC Note:
          Use cross-platform compatible hook intialization.
        }
        InitHook(h_Invert, THookFunction(@Invert), nil);

        for i := low(Fields) to High(Fields) 
        do 
          DoMethod ( Fields[i],  MUIM_Notify,
          [
            TAG_(MUIA_Selected), TAG_(MUIV_EveryTime), TAG_(Prog),
            3, TAG_(MUIM_CallHook), TAG_(@h_Invert), TAG_(i)
          ]);
          
          
        DoMethod (Window, MUIM_Notify, 
        [
          TAG_(MUIA_Window_CloseRequest), TAG_(MUIV_EveryTime), TAG_(Prog), 
          2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
        ]);

        SetAttrs (Window, [TAG_(MUIA_Window_Open), TAG_(TRUE), TAG_END]);
        

        while (DoMethod ( Pointer(Prog), MUIM_Application_NewInput, [TAG_(@Signals)] ) <> LongWord(MUIV_Application_ReturnID_Quit)) do
        begin
          if (signals <> 0) then
          begin
            signals := Wait (signals or SIGBREAKF_CTRL_C);
            if ((signals and SIGBREAKF_CTRL_C) <> 0) then break;
          end;
        end;


        SetAttrs (Window, [TAG_(MUIA_Window_Open), TAG_(FALSE), TAG_END]);

        MUI_DisposeObject (pointer(Prog));
      end;
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      CloseLibrary(MUIMasterBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;

  Leave(ProcName);
end;


//
//        Startup
//

begin
  WriteLn('enter');

  {
    FPC Note:
    Startup code is already part of Free Pascal, so not necesary to repeat here
  }
  ExitCode := Main;

  WriteLn('leave');
end.
