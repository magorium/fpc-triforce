Program graphics_simple;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : graphics_simple
  Topic   : Some simple drawing functions
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/graphics_simple.c
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
    Example for simple drawing routines
*}



Uses
  exec, agraphics, intuition, utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  chelpers,
  trinity;



var
  window    : pWindow;
  cm        : pColorMap;
  rp        : pRastPort;



const
  {*
    ObtainBestPen() returns -1 when it fails, therefore we
    initialize the pen numbers with -1 to simplify cleanup.
  *}
  pen1      : LONG = -1;
  pen2      : LONG = -1;

  procedure draw_simple;  forward;
  procedure clean_exit(const s: STRPTR); forward;
  procedure handle_events; forward;



function  main: Integer;
begin
  window := OpenWindowTags(nil,
  [
    TAG_(WA_Left)           ,  50,
    TAG_(WA_Top)            ,  70,
    TAG_(WA_Width)          , 400,
    TAG_(WA_Height)         , 350,

    TAG_(WA_Title)          , TAG_(PChar('Simple Graphics')),
    TAG_(WA_Activate)       , TAG_(TRUE),
    TAG_(WA_SmartRefresh)   , TAG_(TRUE),
    TAG_(WA_NoCareRefresh)  , TAG_(TRUE),
    TAG_(WA_GimmeZeroZero)  , TAG_(TRUE),
    TAG_(WA_CloseGadget)    , TAG_(TRUE),
    TAG_(WA_DragBar)        , TAG_(TRUE),
    TAG_(WA_DepthGadget)    , TAG_(TRUE),
    TAG_(WA_IDCMP)          , TAG_(IDCMP_CLOSEWINDOW),
    TAG_END
  ]);

  if not assigned(window) then clean_exit('Can''t open window' + LineEnding);

  rp := window^.RPort;
  {$IFNDEF AROS}
  cm := pScreen(window^.WScreen)^.ViewPort.Colormap;
  {$ELSE}
  cm := window^.WScreen^.ViewPort.Colormap;
  {$ENDIF}

  // Let's obtain two pens
  {$IFDEF AROS}
  pen1 := ObtainBestPenA(cm, $FFFF0000, 0, 0, nil);
  pen2 := ObtainBestPenA(cm, 0 ,0, $FFFF0000, nil);
  {$ELSE}
  pen1 := ObtainBestPen(cm, $FFFF0000, 0, 0, [TAG_END]);
  pen2 := ObtainBestPen(cm, 0 ,0, $FFFF0000, [TAG_END]);
  {$ENDIF}
  If (not (pen1 <> 0) or not (pen2 <> 0)) then clean_exit('Can''t allocate pen' + LineEnding);

  draw_simple();
  handle_events();

  clean_exit(nil);

  result := 0;
end;



procedure draw_simple;
var
  anarray : array[0..8-1] of SmallInt =  // Polygon for PolyDraw
  (
   50, 200,
   80, 180,
   90, 220,
   50, 200 
  ); 
begin
  SetAPen(rp, pen1);                    // Set foreground color
  SetBPen(rp, pen2);                    // Set background color

  WritePixel(rp, 30, 70);               // Plot a point

  SetDrPt(rp, $FF00);                   // Change line pattern. Set pixels are drawn
                                        // with APen, unset with BPen
  GfxMove(rp, 20, 50);                  // Move cursor to given point
  Draw(rp, 100, 80);                    // Draw a line from current to given point

  DrawEllipse(rp, 70, 30, 15, 10);      // Draw an ellipse

  {*
    Draw a polygon. Note that the first line is draw from the
    end of the last Move() or Draw() command  
  *}
  PolyDraw(rp, sizeof(anarray) div sizeof(SmallInt) div 2, anarray);

  SetDrMd(rp, JAM1);                    // We want to use only the foreground pen
  GfxMove(rp, 200, 80);
  GfxText(rp, 'Text in default font', 20);

  SetDrPt(rp, $FFFF);                   // Reset line pattern
end;



procedure handle_events;
var
  imsg       : pIntuiMessage;
  port       : pMsgPort;
  terminated : boolean;
begin
  {*
    A simple event handler. This will be exaplained ore detailed
    in the Intuition examples.
  *}
  port := window^.userPort;
  terminated := false;

  while not(terminated) do
  begin
    Wait(1 shl port^.mp_SigBit);
    if (SetAndGet(imsg, GetMsg(port)) <> nil) then
    begin
      Case imsg^.IClass of
        IDCMP_CLOSEWINDOW : terminated := true;
      end;
      ReplyMsg(pMessage(imsg));
    end;
  end;
end;



procedure clean_exit(const s: STRPTR);
begin
  if assigned(s)      then Write(s);

  // Give back allocated resources
  if (pen1 <> -1)     then ReleasePen(cm, pen1);
  if (pen2 <> -1)     then ReleasePen(cm, pen2);
  if assigned(window) then CloseWindow(window);

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
