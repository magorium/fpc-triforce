Program intuition_appscreen;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : intuition_appscreen
  Topic   : Opens a screen for applications
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/intuition_appscreen.c
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
    Example of a custom screen

    This shows how to create a screen for an application.
    It uses the standard 3D look. An additional pen for drawing will be requested.
*}



Uses
  exec, AmigaDOS, agraphics, intuition, utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  chelpers,
  trinity;



var
  window    : pWindow;
  screen    : pScreen;
  drawinfo  : pDrawInfo;
  rp        : pRastPort;
  cm        : pColorMap;



const
  {*
    ObtainBestPen() returns -1 when it fails, therefore we
    initialize the pen numbers with -1 to simplify cleanup.
  *}
  pen       : LONG = -1;


  procedure clean_exit(const s: STRPTR); forward;
  procedure draw_stuff; forward;
  procedure handle_events; forward;



const
  pens  : Array[0..0] of UWORD = (UWORD(not(0)));



function  main: Integer;
begin
  screen := OpenScreenTags(nil,
  [
    TAG_(SA_Width)  , 800,
    TAG_(SA_Height) , 600,
    TAG_(SA_Depth)  ,  16,
    TAG_(SA_Pens)   , TAG_(@pens),              // Enables default 3D look
    TAG_(SA_Title)  , TAG_(PChar('Default screen title')),
    TAG_END
  ]);

  if not assigned(screen) then clean_exit('Can''t open screen' + LineEnding);

  window := OpenWindowTags(nil,
  [
    TAG_(WA_Left)           , 100,
    TAG_(WA_Top)            , 70,
    TAG_(WA_InnerWidth)     , 600,
    TAG_(WA_InnerHeight)    , 300,
    TAG_(WA_Title)          , TAG_(PChar('Custom screen')),
    TAG_(WA_ScreenTitle)    , TAG_(PChar('Screen title')),  // Screen title when window is active
    TAG_(WA_Activate)       , TAG_(TRUE),
    TAG_(WA_CloseGadget)    , TAG_(TRUE),
    TAG_(WA_DragBar)        , TAG_(TRUE),
    TAG_(WA_DepthGadget)    , TAG_(TRUE),
    TAG_(WA_IDCMP)          , TAG_(IDCMP_CLOSEWINDOW),
    TAG_(WA_SmartRefresh)   , TAG_(TRUE),       // Lets Intuition handle exposed regions
    TAG_(WA_NoCareRefresh)  , TAG_(TRUE),       // we don't want to listen to refresh messages
    TAG_(WA_CustomScreen)   , TAG_(screen),     // Link to screen
    TAG_END
  ]);

  if not assigned(window) then clean_exit('Can''t open window' + LineEnding);

  if not(SetAndTest(drawinfo, GetScreenDrawInfo(screen)))
  then clean_exit('Can''t get screendrawinfo' + LineEnding);

  rp := window^.RPort;
  cm := screen^.ViewPort.ColorMap;

  draw_stuff();

  handle_events();

  clean_exit(nil);

  result := 0;
end;



procedure draw_stuff;
begin
  SetAPen(rp, PWord(drawinfo^.dri_Pens)[TEXTPEN]);
  GfxMove(rp, 100, 100);
  GfxText(rp, 'This text is written in default color "TEXTPEN".', 48);

  SetAPen(rp, PWord(drawinfo^.dri_Pens)[SHINEPEN]);
  GfxMove(rp, 100, 130);
  GfxText(rp, 'This text is written in default color "SHINEPEN".', 49);

  // We ask nicely for a new pen...
  {$IFDEF AROS}
  pen := ObtainBestPenA(cm, 0 ,0, $FFFF0000, nil);
  {$ELSE}
  pen := ObtainBestPen(cm, 0 ,0, $FFFF0000, [TAG_END]);
  {$ENDIF}
  if not(pen <> 0) then clean_exit('Can''t allocate pen' + LineEnding);
    
  // ... and use it to draw a line.
  SetAPen(rp, pen);
  GfxMove(rp, 100, 200);
  Draw(rp, 500, 200);
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



procedure clean_exit(const s: STRPTR);
begin
  if assigned(s)        then PutStr(s);

  // Give back allocated resources
  if (pen <> -1)        then ReleasePen(cm, pen);
  if assigned(drawinfo) then FreeScreenDrawInfo(screen, drawinfo);
  if assigned(window)   then CloseWindow(window);
  if assigned(screen)   then CloseScreen(screen);

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

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  GfxBase := OpenLibrary(GRAPHICSNAME, 0);
  if not assigned(GfxBase) then Exit;
  {$ENDIF}
  {$IF DEFINED(MORPHOS)}
  IntuitionBase := OpenLibrary(INTUITIONNAME, 0);
  if not assigned(IntuitionBase) then Exit;
  {$ENDIF}

  Result := True;
end;



Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS)}
  if assigned(IntuitionBase) then CloseLibrary(pLibrary(IntuitionBase));
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if assigned(GfxBase) then CloseLibrary(pLibrary(GfxBase));
  {$ENDIF}
end;



begin
  if OpenLibs
  then ExitCode := Main()
  else ExitCode := 10;

  CloseLibs;
end.
