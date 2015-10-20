Program intuition_customscreen;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : intuition_customscreen
  Topic   : Opens a screen with a backdrop window
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/intuition_customscreen.c
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

    In this example we're setting the colors directly.
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
  rp        : pRastPort;


  procedure clean_exit(const s: STRPTR); forward;
  procedure draw_stuff; forward;
  procedure handle_events; forward;


{*
    Initial color values for the screen.
    Must be an array with index, red, green, blue for each color.
    The range for each color component is between 0 and 255.
*}
const
  colors : Array[0..3] of TColorSpec =
  (
    ( ColorIndex :  0; Red : 240; Green: 100; Blue:   0 ),   // Color 0 is background
    ( ColorIndex :  1; Red : 240; Green:   0; Blue:   0 ),
    ( ColorIndex :  2; Red :   0; Green:   0; Blue: 240 ),
    ( ColorIndex : -1; )     // Array must be terminated with -1
  );



function  main: Integer;
begin
  screen := OpenScreenTags(nil,
  [
    TAG_(SA_Width)  , 800,
    TAG_(SA_Height) , 600,
    TAG_(SA_Depth)  ,  16,
    TAG_(SA_Colors) , TAG_(@colors),
    TAG_END
  ]);

  if not assigned(screen) then clean_exit('Can''t open screen' + LineEnding);

  window := OpenWindowTags(nil,
  [
    TAG_(WA_Activate)       , TAG_(TRUE),
    TAG_(WA_Borderless)     , TAG_(TRUE),
    TAG_(WA_Backdrop)       , TAG_(TRUE),
    TAG_(WA_IDCMP)          , TAG_(IDCMP_VANILLAKEY),
    TAG_(WA_RMBTrap)        , TAG_(TRUE),
    TAG_(WA_NoCareRefresh)  , TAG_(TRUE),       // We don't want to listen to refresh messages
    TAG_(WA_CustomScreen)   , TAG_(screen),     // Link to screen
    TAG_END
  ]);

  if not assigned(window) then clean_exit('Can''t open window' + LineEnding);

  rp := window^.RPort;

  draw_stuff();

  handle_events();

  clean_exit(nil);

  result := 0;
end;



procedure draw_stuff;
begin
  SetAPen(rp, 1);
  GfxMove(rp, 100, 50);
  GfxText(rp, 'Press any key to quit', 21); 
    
  GfxMove(rp, 100, 100);
  Draw(rp, 500, 100);

  SetAPen(rp, 2);
  GfxMove(rp, 100, 200);
  Draw(rp, 500, 200);
    
  {*
      We can change single colors with SetRGB32() or a range of
      colors with LoadRGB32(). In contrast to the color table above,
      we need 32-bit values for the color components.
  *}
  SetRGB32(@screen^.ViewPort, 2, 0, $FFFFFFFF, 0);
    
  {*
      Even when we use the same pen number as before, we have to set it again.
  *}
  SetAPen(rp, 2);
  GfxMove(rp, 100, 300);
  Draw(rp, 500, 300);
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
        IDCMP_VANILLAKEY: terminated := TRUE;
      end;
      ReplyMsg(pMessage(imsg));
    end;
  end;
end;



procedure clean_exit(const s: STRPTR);
begin
  if assigned(s)        then PutStr(s);

  // Give back allocated resources
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
