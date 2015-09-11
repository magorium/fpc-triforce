program example10c;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example10c
  Topic   : Display text files with a ListView
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-9.html
  Sources : http://www.ppa.pl/artykuly/download/mui9.lha
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
  Listview,
  PopString     : pObject_;

  ThisFile      : BPTR = Default(BPTR); { FPC Note: small trick to be able to init cross-platform }


//* Hook called after the file is selected */

function FileReader(hook: pHook; filestring: PObject_; alistview: PPObject_): ULONG;
Const ProcName = 'FileReader';
Const
  line      : Packed Array[0..pred(1024)] of char = #0;  //* storage for reading lines */
Var
  name_file : PChar;
  position  : LONG;
  readbuf   : STRPTR;
begin
  Enter(ProcName);

  If (ThisFile <> default(BPTR)) then DOSClose(ThisFile);  //* close previously opened file (if any) */
  
  DoMethod( alistview^, MUIM_List_Clear);

  GetAttr (MUIA_String_Contents, filestring, @name_file);

  if SetAndTest(ThisFile, DOSOpen(name_file, MODE_OLDFILE)) then
  begin
    SetAttrs (App       , [TAG_(MUIA_Application_Sleep) , TAG_(TRUE), TAG_END]);  //* show "busy" pointer */
    SetAttrs (alistview^, [TAG_(MUIA_List_Quiet)        , TAG_(TRUE), TAG_END]);  //* disable list refreshing */

    while (true) do
    begin
      position := DOSSeek (ThisFile, 0, OFFSET_CURRENT);
      readbuf  := FGets   (ThisFile, @line[0], Pred(1024));
      if not (readbuf <> nil) then break;
      DoMethod ( alistview^, MUIM_List_InsertSingle, 
      [
        TAG_(position), TAG_(MUIV_List_Insert_Bottom),
        TAG_END
      ]);
    end;

    SetAttrs (alistview^, [TAG_(MUIA_List_Quiet)       , TAG_(FALSE), TAG_END]);   //* enable list refreshing */
    SetAttrs (App       , [TAG_(MUIA_Application_Sleep), TAG_(FALSE), TAG_END]);   //* back to normal pointer */
  end;
  result := 0;  

  Leave(ProcName);
end;


//* Hook constructor */

function  LineConstructor(hook: pHook; mempool: APTR; line: LONG): ULONG;
Const ProcName = 'LineConstructor';
var
  element: PLong;
begin
  Enter(ProcName);

  if SetAndTest(element, AllocPooled (mempool, sizeof (LONG))) then
  begin
    element^ := line;
    exit(ULONG(element));
  end;
  
  result := 0;

  Leave(ProcName);
end;


//* Hook destructor */

function  LineDestructor(hook: pHook; mempool: APTR; line: PLONG): ULONG;
Const ProcName = 'LineDestructor';
begin
  Enter(ProcName);

  if (line <> nil) then FreePooled (mempool, line, sizeof (LONG));
  result := 0;

  Leave(ProcName);
end;


//* Hook for displaying */

function  LineDisplayer(hook: pHook; teksty: ppChar; line: PLONG): ULONG;
Const ProcName = 'LineDisplayer';
Const
  text    : Packed Array[0..pred(1024)] of char = #0;  
begin
  Enter(ProcName);

  DOSSeek(ThisFile, line^, OFFSET_BEGINNING);
  FGets(ThisFile, @text[1], Pred(1024));


  {
    FPC Note:
    AROS list behaves differently in that it processes the EOL character
    while classic seems to ignore it.
  }
  {$IFDEF AROS}
  If strlen(@text[1]) > 0 then text[strlen(@text[1])] := #0;
  {$ENDIF}
  
  teksty[0] := @text[1];
  result := 0;

  Leave(ProcName);
end;


//* Hook structure definitions  */

var
  {
    FPC Note:
    Intitialization of the hooks is done below using InitHook().
  }
  h_LineConstructor : THook;
  h_LineDestructor  : THook;
  h_LineDisplayer   : THook;
  h_FileReader      : THook;


//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);

  App := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)           , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)             , TAG_(PChar('EXAMPLE10C')),
    TAG_(MUIA_Application_Copyright)        , TAG_(PChar('© 1999 by BlaBla Corp.')),
    TAG_(MUIA_Application_Description)      , TAG_(PChar('Example 10c to the MUI tutorial')),
    TAG_(MUIA_Application_Title)            , TAG_(PChar('Example10c')),
    TAG_(MUIA_Application_Version)          , TAG_(PChar('$VER: example10c 1.0 (10.2.2000) BLABLA PRODUCT')),
    TAG_(MUIA_Application_Window)           , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)               , TAG_(PChar('Example 10c')),
      TAG_(MUIA_Window_ID)                  , $50525A4B,
      TAG_(MUIA_UserData)                   , TAG_(OBJ_WINDOW),
      TAG_(MUIA_Window_RootObject)          , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)              , TAG_(MUI_NewObject (MUIC_Group,
        [
          TAG_(MUIA_Group_Horiz)            , TAG_(TRUE),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)        , TAG_(PChar(Esc_R + 'File')),
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_(MUIA_FramePhantomHoriz)    , TAG_(TRUE),
            TAG_(MUIA_HorizWeight)          , 0,
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Popasl,
          [
            TAG_(MUIA_Popstring_String)     , TAG_(SetAndGet(PopString, MUI_NewObject (MUIC_String,
            [
              TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_String),
              TAG_END
            ]))),
            TAG_(MUIA_Popstring_Button)     , TAG_(MUI_NewObject (MUIC_Image,
            [
              TAG_(MUIA_Image_Spec)         , TAG_(MUII_PopFile),
              TAG_(MUIA_Image_FontMatch)    , TAG_(TRUE),
              TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_ImageButton),
              TAG_(MUIA_InputMode)          , TAG_(MUIV_InputMode_RelVerify),
              TAG_END
            ])),
            TAG_END
          ])),
          TAG_END
        ])),
        TAG_(MUIA_Group_Child)              , TAG_(SetAndGet(Listview, MUI_NewObject (MUIC_Listview,
        [
          TAG_(MUIA_Listview_Input)         , TAG_(FALSE),                      //* A read-only list - without cursor */
          TAG_(MUIA_Listview_List)          , TAG_(MUI_NewObject (MUIC_List,
          [      
            TAG_(MUIA_List_ConstructHook)   , TAG_(@h_LineConstructor),
            TAG_(MUIA_List_DestructHook)    , TAG_(@h_LineDestructor),
            TAG_(MUIA_List_DisplayHook)     , TAG_(@h_LineDisplayer),
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_ReadList),
            TAG_(MUIA_Font)                 , TAG_(MUIV_Font_Fixed),
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


//* Initialize notifications

procedure SetNotifications;
Const ProcName = 'MainLoop';
begin
  Enter(ProcName);

  //* notification for closing the window */

  DoMethod (Win, MUIM_Notify, 
  [
    TAG_(MUIA_Window_CloseRequest), TAG_(MUIV_EveryTime), TAG_(App), 
    2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
  ]);
  
  //* notification for entering a file name */

  DoMethod (PopString, MUIM_Notify, 
  [
    TAG_(MUIA_String_Acknowledge), TAG_(MUIV_EveryTime), TAG_(MUIV_Notify_Self),
    3, TAG_(MUIM_CallHook), TAG_(@h_FileReader), TAG_(Listview)
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

  SetAttrs (Win, [ TAG_(MUIA_Window_Open), TAG_(FALSE), TAG_END ]); 

  Leave(ProcName);
end;


//* Main function of the application */

Function  Main: integer;
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
        {
          FPC Note:
          Cross platform compatible initialization of the hooks
        }
        initHook(h_LineConstructor, THookFunction(@LineConstructor), nil);
        initHook(h_LineDestructor , THookFunction(@LineDestructor) , nil);
        initHook(h_LineDisplayer  , THookFunction(@LineDisplayer)  , nil);
        initHook(h_FileReader     , THookFunction(@FileReader)     , nil);

        if BuildApplication then
        begin
          SetNotifications;
          MainLoop;
          MUI_DisposeObject(App);
          if (ThisFile <> default(BPTR)) then DOSClose (ThisFile);  //* Close file in case it's still open */
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
