program notification;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : notification
  Topic   : Using MUI notifications
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


  {
    FPC Note:
    Although defined in MUI, we would need to recompile MUI library in order
    to be able to use obsolete defined tag constants. Since we only require
    one definition, it's easier to just declare that one constant manually 
    here.  
  }
Const
  MUIA_Slider_Level = $8042ae3a;  //* V4  isg LONG              */



var
  Prog, 
  Window, 
  Group, 
  Slider, 
  TxtGrp, 
  TxtTxt, 
  TxtButt           : pObject_;



Function  Main: LONG;
Const ProcName = 'Main';
Var
  Signals : ULONG;
begin
  Enter(ProcName);

  Result := 0;

  {
    FPC Note:
    On AROS all libraries are auto-opened, on Amiga the Intuition library
    is auto-opened. The compiler defines takes care of these differences.
    Of course, if a library is not opened manually, we don't need to
    close it manually either (see at the bottom of this routine).
  }

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
        TAG_(MUIA_Application_Base)         , TAG_(PChar('NOTIFICATIONS')),
        TAG_(MUIA_Application_Copyright)    , TAG_(PChar('Public Domain')),
        TAG_(MUIA_Application_Description)  , TAG_(PChar('Program demonstrating notifications')),
        TAG_(MUIA_Application_Title)        , TAG_(PChar('Notifications')),
        TAG_(MUIA_Application_Window)       , TAG_(SetAndget(Window, MUI_NewObject (MUIC_Window,
        [
          TAG_(MUIA_Window_Activate)        , TAG_(TRUE),
          TAG_(MUIA_Window_ID)              , $4E4F5459,       //* "NOTY" */
          TAG_(MUIA_Window_Title)           , TAG_(PChar('Notifications')),
          TAG_(MUIA_Window_RootObject)      , TAG_(SetAndGet(Group, MUI_NewObject (MUIC_Group,
          [
            TAG_(MUIA_Group_Child)          , TAG_(SetAndGet(Slider, MUI_NewObject (MUIC_Slider,
            [
              TAG_(MUIA_Slider_Horiz)       , TAG_(TRUE),
              TAG_(MUIA_Numeric_Min)        , 5,
              TAG_(MUIA_Numeric_Max)        , 29,
              TAG_END
            ]))),
            TAG_(MUIA_Group_Child)          , TAG_(SetAndGet(TxtGrp, MUI_NewObject (MUIC_Group,
            [
              TAG_(MUIA_Group_Horiz)        , TAG_(TRUE),
              TAG_(MUIA_Group_HorizSpacing) , 0,
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(TxtTxt, MUI_NewObject (MUIC_Text,
              [
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_Text),
                TAG_(MUIA_Background)       , TAG_(MUII_TextBack),
                TAG_END
              ]))),
              TAG_(MUIA_Group_Child)        , TAG_(SetAndGet(TxtButt, MUI_NewObject (MUIC_Text,
              [
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_Button),
                TAG_(MUIA_Background)       , TAG_(MUII_ButtonBack),
                TAG_(MUIA_Font)             , TAG_(MUIV_Font_Button),
                TAG_(MUIA_InputMode)        , TAG_(MUIV_InputMode_RelVerify),
                TAG_(MUIA_Text_Contents)    , TAG_(PChar(Esc_C + 'Cancel')),
                TAG_END
              ]))),
              TAG_END
            ]))),
            TAG_END
          ]))),
          TAG_END
        ]))),
        TAG_END
      ])) then
      begin
        DoMethod (Slider, MUIM_Notify, 
        [
          TAG_(MUIA_Slider_Level), TAG_(13), TAG_(TxtTxt), 
          3, TAG_(MUIM_Set), TAG_(MUIA_Text_Contents), TAG_(PChar('Unlucky Number!'))
        ]);

        DoMethod (TxtButt, MUIM_Notify, 
        [
          TAG_(MUIA_Pressed), TAG_(FALSE), TAG_(TxtTxt), 
          3, TAG_(MUIM_Set), TAG_(MUIA_Text_Contents), TAG_(PChar(''))
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
