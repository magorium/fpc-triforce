Program asl_asl;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : asl_asl
  Topic   : File-, Font- and Screenmoderequester
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/asl.c
  ===========================================================================

  This example was originally written in c by The AROS Development Team.

  The original examples are available online and published at the AROS
  website (http://www.aros.org/documentation/developers/samples.php)

  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc

  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Conversion from c to Free Pascal was done by Magorium in 2015.

  ===========================================================================

           Unless otherwise noted, these examples must be considered
                 copyrighted by their respective owner(s)

  ===========================================================================
}

{*
    File-, Font- and Screenmoderequester
*}



{$IFDEF MorphOS}
{$UNITPATH ../../../Sys/MorphOS}
{$ENDIF}

Uses
  exec, AmigaDOS, agraphics, intuition, diskfont, asl, utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  chelpers,
  trinity,
  SysUtils;
  

  procedure load_file(const filename: STRPTR); forward;
  procedure handle_events; forward;
  procedure clean_exit(const s: STRPTR); forward;

var
  screen    : pScreen;
  window    : pWindow;
  rp        : pRastPort;
  font      : pTextFont;

  filereq   : pFileRequester;
  filename  : packed array[0..1000-1] of Char;
  buffer    : packed array[0..100-1] of Char;

  fontreq   : pFontRequester;
  screenreq : pScreenModeRequester;

  pens      : array[0..0] of UWORD = ( UWORD(not(0)) );



function  main: integer;
Var
  styles    : ULONG;
begin
  {*
      Filerequester
  *}
  filereq := pFileRequester(AllocAslRequestTags(ASL_FileRequest,
  [
    TAG_(ASLFR_TitleText)       , TAG_(PChar('Select a file for reading')),
    TAG_(ASLFR_DoPatterns)      , TAG_(TRUE),
    TAG_(ASLFR_InitialDrawer)   , TAG_(PChar('S:')),
    TAG_END
  ]));

  if not assigned(filereq) then clean_exit('Can''t open filerequester' + LineEnding);
    
  if ( AslRequest(filereq, nil) ) then
  begin
    strcopy(@filename[0], filereq^.rf_Dir);
    if not(AddPart(filename, filereq^.rf_File, sizeof(filename))) then
    begin
      clean_exit('AddPart() failed' + LineEnding);
    end;
  end
  else
  begin
    clean_exit('Filerequester cancelled' + LineEnding);
  end;

  {*
      Fontrequester
  *}
  fontreq := pFontRequester(AllocAslRequestTags(ASL_FontRequest,
  [
    TAG_(ASLFO_TitleText)   , TAG_(PChar('Select a font')),
    TAG_(ASLFO_DoFrontPen)  , TAG_(TRUE),
    TAG_(ASLFO_DoStyle)     , TAG_(TRUE),
    TAG_END
  ]));
  if not assigned(fontreq) then clean_exit('Can''t open fontrequester' + LineEnding);
    
  if (AslRequest(fontreq, nil)) then
  begin
  end
  else
  begin
    clean_exit('Fontrequester cancelled' + LineEnding);
  end;

  {*
      ScreenModerequester
  *}
  screenreq := pScreenModeRequester(AllocAslRequestTags(ASL_ScreenModeRequest,
  [
    TAG_(ASLSM_TitleText)   , TAG_(PChar('Select a screenmode')),
    TAG_(ASLSM_DoDepth)     , TAG_(TRUE),
    TAG_END
  ]));
  if not assigned(screenreq) then clean_exit('Can''t open screenmoderequester' + LineEnding);
    
  if (AslRequest(screenreq, nil)) then
  begin
  end
  else
  begin
    clean_exit('Screenmoderequester cancelled' + LineEnding);
  end;

  {*
      Open the screen
  *}
  screen := OpenScreenTags(nil,
  [
    TAG_(SA_Width)      , screenreq^.sm_DisplayWidth,
    TAG_(SA_Height)     , screenreq^.sm_DisplayHeight,
    TAG_(SA_Depth)      , screenreq^.sm_DisplayDepth,
    TAG_(SA_DisplayID)  , screenreq^.sm_DisplayID,
    TAG_(SA_Pens)       , TAG_(@pens), // Enables default 3D look
    TAG_(SA_Title)      , TAG_(PChar('ASL Demo')),
    TAG_END
  ]);

  if not assigned(screen) then clean_exit('Can''t open screen' + LineEnding);
    
  {*
      Open the window
  *}
  window := OpenWindowTags(nil,
  [
    TAG_(WA_Left)           ,  0,
    TAG_(WA_Top)            , 50,
    TAG_(WA_Title)          , TAG_(PChar('ASL Demo')),
    TAG_(WA_Activate)       , TAG_(TRUE),
    TAG_(WA_CloseGadget)    , TAG_(TRUE),
    TAG_(WA_DragBar)        , TAG_(TRUE),
    TAG_(WA_DepthGadget)    , TAG_(TRUE),
    TAG_(WA_SmartRefresh)   , TAG_(TRUE),
    TAG_(WA_NoCareRefresh)  , TAG_(TRUE),
    TAG_(WA_IDCMP)          , TAG_(IDCMP_CLOSEWINDOW),
    TAG_(WA_GimmeZeroZero)  , TAG_(TRUE),
    TAG_(WA_CustomScreen)   , TAG_(screen), // Link to screen
    TAG_END
  ]);

  if not assigned(window) then clean_exit('Can''t open window' + LineEnding);

  rp := window^.RPort;
    
  {*
      Load the font and prepare the rastport
  *}
  if not SetAndTest(font, OpenDiskFont(@fontreq^.fo_Attr)) then
  begin
    clean_exit('Can''t open font' + LineEnding);
  end;

  SetFont(rp, font);
  styles := AskSoftStyle(rp);
  SetSoftStyle(rp, styles, fontreq^.fo_Attr.ta_Style);
  SetAPen(rp, fontreq^.fo_FrontPen);
    
  GfxMove(rp, 5,15);
    
  load_file(filename);
    
  handle_events();
    
  clean_exit(nil);
  result := 0;
end;



procedure handle_events;
var
  imsg       : pIntuiMessage;
  port       : pMsgPort;

  signals    : ULONG;
  terminated : Boolean;
begin
  port := window^.UserPort;

  terminated := FALSE;
    
  while not(terminated) do
  begin
    signals := Wait(1 shl port^.mp_SigBit);

    while (SetAndGet(imsg, pIntuiMessage(GetMsg(port))) <> nil) do
    begin
      case (imsg^.IClass) of
        IDCMP_CLOSEWINDOW: terminated := TRUE;
      end;
      ReplyMsg(pMessage(imsg));
    end;
  end;
end;



procedure load_file(const filename: STRPTR);
var
  infile : BPTR;
  cp_x   : SmallInt;
  cp_y   : SmallInt;
  len    : ULONG;
label
  cleanup;
begin
  if not assigned(filename) then exit;
    
  infile := Default(BPTR);
  cp_x := rp^.cp_x;
  cp_y := rp^.cp_y;
    
  if not SetAndTest(infile, DOSOpen(filename, MODE_OLDFILE)) then
  begin
    goto cleanup;
  end;
    
  while (FGets(infile, buffer, sizeof(buffer)) <> nil) do
  begin
    len := strlen(buffer);
    // Remove newline
    if (buffer[len-1] = #10) then
    begin
      len := Len - 1;
    end;
        
    GfxMove(rp, cp_x, cp_y);
    GfxText(rp, buffer, len);
    cp_y := cp_y + rp^.TxHeight;
  end;

cleanup:
  PrintFault(IoErr(), 'Error');
  if (infile <> default(BPTR)) then DOSClose(infile);
end;



procedure clean_exit(const s: STRPTR);
begin
  if assigned(s)         then PutStr(s);

  // Give back allocated resources
  if assigned(filereq)   then FreeAslRequest(filereq);
  if assigned(fontreq)   then FreeAslRequest(fontreq);
  if assigned(screenreq) then FreeAslRequest(screenreq);
  if assigned(font)      then CloseFont(font);
  if assigned(window)    then CloseWindow(window);
  if assigned(screen)    then CloseScreen(screen);

  Halt(0);
end;



{
  ===========================================================================
  Some additional code is required in order to open and close libraries in a 
  cross-platform uniform way.
  Since AROS units automatically opens and closes libraries, this code is 
  only actively used when compiling for Amiga and/or MorphOS.
  ===========================================================================
}



Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS)}
  IntuitionBase := OpenLibrary(INTUITIONNAME, 0);
  if not assigned(IntuitionBase) then Exit;
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  GfxBase := OpenLibrary(GRAPHICSNAME, 0);
  if not assigned(GfxBase) then Exit;

  DiskfontBase := OpenLibrary(DISKFONTNAME, 0);
  if not assigned(DiskfontBase) then Exit;

  AslBase := OpenLibrary(ASLNAME, 0);
  if not assigned(AslBase) then Exit;
  {$ENDIF}

  Result := True;
end;



Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if assigned(AslBase) then CloseLibrary(pLibrary(Aslbase));
  if assigned(DiskfontBase) then CloseLibrary(pLibrary(DiskfontBase));
  if assigned(GfxBase) then CloseLibrary(pLibrary(GfxBase));
  {$ENDIF}
  {$IF DEFINED(MORPHOS)}
  if assigned(IntuitionBase) then CloseLibrary(pLibrary(IntuitionBase));
  {$ENDIF}
end;



begin
  if OpenLibs
  then ExitCode := Main()
  else ExitCode := 10;

  CloseLibs;
end.
