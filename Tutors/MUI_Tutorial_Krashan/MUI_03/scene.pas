program scene;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : scene
  Topic   : Creating a GUI with MUI
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-3.html
  Sources : http://www.ppa.pl/artykuly/download/mui3.lha
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


//* This version of the program only creates the GUI, but does not respond  */
//* to user actions                                                         */
//*                                                                         */
//* NOTE: some of the techniques used in this program will be discussed in  */
//* the next installment of the tutorial.



uses
  Exec, AmigaDOS, Intuition, Utility, MUI,
  SysUtils,
  CHelpers,
  Sugar,
  Trinity;

Var
  //* Text entries for the cycle gadget */
  FunctionValues : array[0..pred(4)] of PChar = 
  (
    'coder'  ,
    'swapper',
    'lamer'  ,
    nil
  );

//**********************************************************************/


Var
  Win, 
  Prog       : p_Object;


Function Main: ULONG;
Const ProcName = 'Main';
var
  signals : ULONG;
Begin
  Enter(ProcName);

  {$IFDEF MORPHOS}
  InitIntuitionLibrary;
  {$ENDIF}

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}  
  MUIMasterBase := OpenLibrary('muimaster.library', 16);
  {$ENDIF}
  if not (MUIMasterBase <> nil) then
  begin
    WriteLn('This program requires MUI version 3.5+.');
    Exit(10);
  end;

  //* Create the application. Usually creating all objects in one function */
  //* call to MUI_NewObject() with a set of parameters or parameters to    */
  //* a subsequent invocation of function NewObject().                     */

  //* The GUI is composed using the following layout:                      */
  //* - main window group, vertical                                        */
  //*    - top group, in a 2x4 raster with frame and title                 */
  //*       - Text object, with contents "First name"                      */
  //*       - String Object                                                */
  //*       - Text object, with contents "Last name"                       */
  //*       - String object                                                */
  //*       - Text object, with contents "Handle"                          */
  //*       - horizontal group                                             */
  //*          - String object                                             */
  //*          - Text object, with contents "Group"                        */
  //*          - String object                                             */
  //*       - Text object, with contents "Function"                        */
  //*       - Cycle object                                                 */
  //*    - bottom horizontal group                                         */
  //*       - Rectangle object                                             */
  //*       - vertical group                                               */
  //*          - Rectangle object                                          */
  //*          - horizontal group                                          */
  //*             - left arrow                                             */
  //*             - Text object for numbers                                */
  //*             - right arrow                                            */
  //*          - Rectangle object                                          */
  //*       - Rectangle object                                             */
  
  PLongWord(Prog) := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)           , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)             , TAG_(PChar('SCENE')),
    TAG_(MUIA_Application_Description)      , TAG_(PChar('Program example')),
    TAG_(MUIA_Application_Title)            , TAG_(PChar('Our scene')),
    TAG_(MUIA_Application_Version)          , TAG_(PChar('$VER: scene 0.2 (13.7.98)')),
    TAG_(MUIA_Application_Window)           , TAG_(SetAndGet(win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)               , TAG_(PChar('Scene')),
      TAG_(MUIA_Window_ID)                  , $5343454E,
      TAG_(MUIA_Window_RootObject)          , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)              , TAG_(MUI_NewObject (MUIC_Text,
        [
          TAG_(MUIA_Background)             , TAG_(MUII_SHADOW),
          TAG_(MUIA_Font)                   , TAG_(MUIV_Font_Big),
          TAG_(MUIA_Text_Contents)          , TAG_(PChar(#27 + '8' + Esc_C + Esc_I + 'Black list v0.2')),
          TAG_END
        ])),
        TAG_(MUIA_Group_Child)              , TAG_(MUI_NewObject (MUIC_Group,
        [
          TAG_(MUIA_Frame)                  , TAG_(MUIV_Frame_Group),
          TAG_(MUIA_FrameTitle)             , TAG_(PChar('Member parameters')),
          TAG_(MUIA_Background)             , TAG_(MUII_GroupBack),
          TAG_(MUIA_Group_Rows)             , 4,
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)        , TAG_(PChar(Esc_R + 'First name')),
            TAG_END
          ])),

          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_String,
          [
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_END
          ])),

          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_SetMax)          , TAG_(TRUE),
            TAG_(MUIA_Text_Contents)        , TAG_(PChar(Esc_R + 'Last name')),
            TAG_END
          ])),
        
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_String,
          [
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_END
          ])),

          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)        , TAG_(PChar(Esc_R + 'Handle')),
            TAG_END
          ])),

          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Group,
          [
            TAG_(MUIA_Group_Horiz)          , TAG_(TRUE),
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_String,
            [
              TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_String),
              TAG_END
            ])),

            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Text,
            [
              TAG_(MUIA_Text_SetMax)        , TAG_(TRUE),
              TAG_(MUIA_Text_Contents)      , TAG_(PChar(Esc_R + ' Group')),
              TAG_END
            ])),
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_String,
            [
              TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_String),
              TAG_END
            ])),
            TAG_END
          ])),
        
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)        , TAG_(PChar(Esc_R + 'Function')),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Cycle,
          [
            TAG_(MUIA_Font)                 , TAG_(MUIV_Font_Button),
            TAG_(MUIA_Cycle_Entries)        , TAG_(@FunctionValues),
            TAG_END
          ])),
          TAG_END
        ])),      
      
        TAG_(MUIA_Group_Child)              , TAG_(MUI_NewObject (MUIC_Group,
        [
          TAG_(MUIA_Group_Horiz)            , TAG_(TRUE),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Rectangle, 
          [
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Group,
          [
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Rectangle, 
            [
              TAG_END
            ])),
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Group,
            [
              TAG_(MUIA_Group_Horiz)        , TAG_(TRUE),
              TAG_(MUIA_Group_HorizSpacing) , 0,
              TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_(MUIA_Background)       , TAG_(MUII_ButtonBack),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_TapePlayBack),
                TAG_(MUIA_Image_FreeVert)   , TAG_(TRUE),
                TAG_END
              ])),
              TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Text,
              [
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_Text),
                TAG_(MUIA_Background)       , TAG_(MUII_TextBack),
                TAG_(MUIA_FixWidthTxt)      , TAG_(PChar('000')),
                TAG_(MUIA_Text_PreParse)    , TAG_(PChar(Esc_B + Esc_C)),
                TAG_(MUIA_Text_Contents)    , TAG_(PChar('0')),
                TAG_END
              ])),
              TAG_(MUIA_Group_Child)        , TAG_(MUI_NewObject (MUIC_Image,
              [
                TAG_(MUIA_Frame)            , TAG_(MUIV_Frame_ImageButton),
                TAG_(MUIA_Background)       , TAG_(MUII_ButtonBack),
                TAG_(MUIA_Image_Spec)       , TAG_(MUII_TapePlay),
                TAG_(MUIA_Image_FreeVert)   , TAG_(TRUE),
                TAG_END
              ])),
              TAG_END
            ])),
            TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_Rectangle, 
            [
              TAG_END
            ])),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Rectangle, 
          [
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

  //* We do not need to check if the creation of each individual object was  */
  //* successfull. We just need to check if the main MUIC_Application object */
  //* was created succesfully. If an object was not created then all objects */
  //* that were created up till that moment, will be automatically disposed. */

  If (Prog <> nil) then
  begin
    //* Notifications - Here we set the communication between gadgets */


    //* Closing the window with a gadget - exits the program */

    DoMethod (pointer(Win), MUIM_Notify, 
    [
      TAG_(MUIA_Window_CloseRequest), TAG_(MUIV_EveryTime), TAG_(Prog), 
      2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
    ]);

    //* Open the window MUI */

    SetAttrs (Win, [TAG_(MUIA_Window_Open), TAG_(TRUE), TAG_END]);

    //* The main loop of the program. Its only job is waiting for completion */
    //* of the program, which can be done in several ways (receiving the     */
    //* signals MUIV_Application_ReturnID_Quit, or CTRL-C).                  */
    //* Try to press CTRL-C in the console window which the program opened.  */
    
    while (DoMethod ( Pointer(Prog), MUIM_Application_NewInput, [TAG_(@Signals)] ) <> LongWord(MUIV_Application_ReturnID_Quit)) do
    begin
      if (signals <> 0) then
      begin
        signals := Wait (signals or SIGBREAKF_CTRL_C);
        if ((signals and SIGBREAKF_CTRL_C) <> 0) then break;
      end;
    end;

    //* Let's close the MUI window */
    SetAttrs (Win, [TAG_(MUIA_Window_Open), TAG_(FALSE), TAG_END]);

    //* By removing the "Program" object, all its child objects will be */
    //* removed at the same time.                                       */
    MUI_DisposeObject (pointer(Prog));
    WriteLn('End of program execution');    
  end
  else WriteLn('Error: MUIC_Application class object is not created!');
    
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}  
  CloseLibrary(MUIMasterBase);
  {$ENDIF}
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
