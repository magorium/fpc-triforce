Program MUI_Cradle;


{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}


{
  Subject   : MUI Cradle based on Krashan's MUI tutorials
  Source    : http://krashan.ppa.pl/mph
  Date      : august 2015
  Remark    : converted to Free Pascal by Magorium
              compatible with AROS, Amiga and MorphOS (using unit trinity)
}

{
-----------------------------------------------------------------------------
History
-----------------------------------------------------------------------------
}


{$MODE OBJFPC}{$H+}{$HINTS ON}
{$UNITPATH ../CHelpers}
{$UNITPATH ../Sugar}
{$UNITPATH ../Trinity}


Uses
  Exec, AmigaDOS, Intuition, MUI, Utility,
  CHelpers,
  Sugar,
  Trinity;


  //=========================================================================
  //  Some defines to aid cross compatible opening/closing of libraries
  //=========================================================================
  // Auto opened libraries
  // - Amiga      : exec, dos, utility, intuition
  // - AROS       : all
  // - MorphOS    : exec, dos, utility

  // MorphOS specific
  {$IF DEFINED(MORPHOS)}
    {$IF DECLARED(IntuitionBase)} {$DEFINE DO_INTUITION} {$ENDIF}
  {$ENDIF}

  // MorphOS and Amiga Specific (= all other libraries that needs to be opened
  // and/or closed).
  // Add new definitions or comment existing ones, depending on the needs.
  // Don't forget to add new libraries to the open_libs and close_libs sub 
  // routines accordingly.
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
    {$IF DECLARED(GfxBase)}       {$DEFINE DO_GRAPHICS}  {$ENDIF}
    {$IF DECLARED(MUIMasterBase)} {$DEFINE DO_MUIMASTER} {$ENDIF}
    {$IF DECLARED(ASLBase)}       {$DEFINE DO_ASL}       {$ENDIF}
  {$ENDIF}
  //=========================================================================
  

//===========================================================================
//        Normal program flow
//===========================================================================

Const
  APP_VER           = '1.0';
  APP_DATE          = '24.08.2015';
  APP_AUTHOR        = 'Magorium';
  APP_NAME          = 'MUI Cradle';
  APP_CYEARS        = '2015';
  APP_BASE          = 'MUICRADLE';
  APP_DESC          = 'MUI Cradle based on Krashan''s MUI tutorials';
  APP_ABOUT         = Esc_C + Esc_B +  APP_DESC + Esc_N + #10 +
                      'for' + #10 + 'Free Pascal' + #10 + 'by' + #10 + APP_AUTHOR;

Var
  ThisApp,
  ThisWin,
  ThisGroup,
  ThisAboutText     : pObject_;


//===========================================================================
//        build_gui()
//===========================================================================

Function  build_gui: pObject_;
Const ProcName = 'build_gui()';
begin
  Enter(ProcName);

  ThisAboutText  := MUI_NewObject(MUIC_Text,
  [
    TAG_(MUIA_Text_Contents)           , TAG_(PChar(APP_ABOUT)),
    TAG_(MUIA_Frame)                   , MUIV_Frame_Text,
    TAG_END
  ]);

  ThisGroup := MUI_NewObject(MUIC_Group,
  [
    TAG_(MUIA_Group_Child)             , TAG_(ThisAboutText),
    TAG_END
  ]);  

  ThisWin := MUI_NewObject(MUIC_Window,
  [
    TAG_(MUIA_Window_Title)            , TAG_(PChar(APP_NAME)),
    TAG_(MUIA_Window_RootObject)       , TAG_(ThisGroup),
    TAG_END
  ]);

  ThisApp := MUI_NewObject(MUIC_Application, 
  [
    TAG_(MUIA_Application_Author)      , TAG_(PChar(APP_AUTHOR)),
    TAG_(MUIA_Application_Base)        , TAG_(PChar(APP_BASE)),
    TAG_(MUIA_Application_Copyright)   , TAG_(PChar('(c) ' + APP_CYEARS + ' ' + APP_AUTHOR)),
    TAG_(MUIA_Application_Description) , TAG_(PChar(APP_DESC)),
    TAG_(MUIA_Application_Title)       , TAG_(PChar(APP_NAME)),
    TAG_(MUIA_Application_Version)     , TAG_(PChar('$VER: ' + APP_NAME + ' ' + APP_VER + ' (' + APP_DATE + ')')),
    TAG_(MUIA_Application_Window)      , TAG_(ThisWin),
    TAG_END
  ]);

  Result := ThisApp;

  Leave(ProcName);
end;


//===========================================================================
//        setup_hooks()
//===========================================================================

Procedure setup_hooks();
Const ProcName = 'setup_hooks()';
begin
  Enter(ProcName);

  Leave(ProcName);
end;


//===========================================================================
//        setup_notifications()
//===========================================================================

Procedure setup_notifications;
Const ProcName = 'setup_notifications()';
begin
  Enter(ProcName);

  DoMethod (ThisWin, MUIM_Notify, 
  [
    TAG_(MUIA_Window_CloseRequest) , TAG_(True), TAG_(ThisApp), 
    2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
  ]);
  
  Leave(ProcName);
end;


//===========================================================================
//        main_loop()
//===========================================================================

procedure main_loop;
Const ProcName = 'main_loop()';
Var
  RetVal  : LongWord = 0;       // For storing return ID returned by our app.
  signals : LongWord = 0;       // For storing App generated signals.
  running : boolean  = true;    // To check if main loop requires exit or not.
begin
  Enter(ProcName);

  // Attempt to open the main application's window
  SetAttrs(ThisWin, [ TAG_(MUIA_Window_Open), TAG_(True), TAG_END ]);

  While Running do
  begin
    // Retrieve application generated return value/signals.
    RetVal := DoMethod(ThisApp, MUIM_Application_NewInput, [TAG_(@signals)]);
        
    // Did the application wanted to close ?
    If ( RetVal = LongWord(MUIV_Application_ReturnID_Quit) ) then
    begin
      Running := False;
    end;

    // Check if we need to continue waiting for signals
    if (running and (signals <> 0)) then
    begin
      // Wait for application generated signals
      signals := Wait(signals or SIGBREAKF_CTRL_C);
      // Did the user press CTRL-C ?
      if ( (signals and SIGBREAKF_CTRL_C) <> 0 ) 
      then Break;               // Then force loop ending, no matter what.
    end;
  end;

  // Instruct the main application's window to close
  SetAttrs(ThisWin, [ TAG_(MUIA_Window_Open), TAG_(False), TAG_END ]);
  
  Leave(ProcName);
end;


//===========================================================================
//        OpenLibs(), cross-platform
//===========================================================================

function open_libs: boolean;
Const ProcName = 'open_libs()';
begin
  Enter(ProcName);

  result := true;

  {$IFDEF DO_GRAPHICS}
  if not ( SetAndTest( GfxBase      , OpenLibrary (GRAPHICSNAME  , 39))) then exit(false);
  {$ENDIF}
  {$IFDEF DO_INTUTION}
  if not ( SetAndTest( IntuitionBase, OpenLibrary (INTUITIONNAME , 39))) then exit(false);
  {$ENDIF}
  {$IFDEF DO_MUIMASTER}
  if not ( SetAndTest( MUIMasterBase, OpenLibrary (MUIMASTER_NAME, 19))) then exit(false);
  {$ENDIF}
  {$IFDEF DO_ASL}
  if not ( SetAndTest( ASLBase      , OpenLibrary (ASL_NAME      , 19))) then exit(false);
  {$ENDIF}

  Leave(ProcName);
end;


//===========================================================================
//        CloseLibs(), cross-platform
//===========================================================================

Procedure close_libs;
Const ProcName = 'close_libs()';
Begin
  Enter(ProcName);

  {$IFDEF DO_ASL}
  If Assigned(ASLBase)       then CloseLibrary(ASLBase);
  {$ENDIF}
  {$IFDEF DO_MUIMASTER}
  If Assigned(MUIMasterBase) then CloseLibrary(MuiMasterBase);
  {$ENDIF}
  {$IFDEF DO_INTUITION}
  if Assigned(IntuitionBase) then CloseLibrary(pLibrary(IntuitionBase));
  {$ENDIF}
  {$IFDEF DO_GRAPHICS}
  if Assigned(Gfxbase)       then CloseLibrary(pLibrary(GfxBase));
  {$ENDIF}

  Leave(ProcName);
End;


//===========================================================================
//        main()
//===========================================================================

Function main(): LongInt;
Const ProcName = 'main()';
begin
  Enter(ProcName);

  Result := RETURN_OK;          // Set default return value to 0 (OK)

  If open_libs then
  begin
    ThisApp := build_gui();

    if assigned(ThisApp) then
    begin
      setup_hooks();
      setup_notifications();
      main_loop();
      MUI_DisposeObject(ThisApp);
    end
    else result := MSG_RETURN_FAIL('Unable to build the gui.');
  end
  else result := MSG_RETURN_ERROR('Unable to open one of the required libraries.');

  close_libs;

  Leave(ProcName);
end;


//===========================================================================
//        Startup
//===========================================================================

Begin
  WriteLn('enter');

  ExitCode := main();   // Return ExitCode ( generated by main() ) to shell.
  
  WriteLn('leave');
end.
