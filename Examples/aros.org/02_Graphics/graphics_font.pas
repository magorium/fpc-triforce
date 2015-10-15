Program graphics_font;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$IFDEF MORPHOS}
{$UNITPATH ../../../Sys/MorphOS}
{$ENDIF}
(* {$UNITPATH ../../../Sys/{$I %FPCTARGETOS%}} *)

{
  ===========================================================================
  Project : graphics_font
  Topic   : Opens a font and writes some text
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/graphics_font.c
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
    Example for fonts
*}



Uses
  exec, agraphics, intuition, diskfont, utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  chelpers,
  trinity;



var
  window    : pWindow;
  cm        : pColorMap;
  rp        : pRastPort;
  font      : pTextFont;



const
  {*
    ObtainBestPen() returns -1 when it fails, therefore we
    initialize the pen numbers with -1 to simplify cleanup.
  *}
  pen1      : LONG = -1;
  pen2      : LONG = -1;

  procedure draw_font;  forward;
  procedure write_text(const s: STRPTR; x: WORD; y: WORD; mode: ULONG); forward;
  procedure clean_exit(const s: STRPTR); forward;
  procedure handle_events; forward;



function  Main: Integer;
begin
  window := OpenWindowTags(nil,
  [
    TAG_(WA_Left)           ,  50,
    TAG_(WA_Top)            ,  70,
    TAG_(WA_Width)          , 400,
    TAG_(WA_Height)         , 350,

    TAG_(WA_Title)          , TAG_(PChar('Fonts')),
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

  draw_font();
  handle_events();

  clean_exit(nil);

  result := 0;
end;



procedure draw_font;
var
  style : ULONG;
  ta    : TTextAttr =
  (
    ta_name  : 'arial.font';           // Font name
    ta_YSize : 15;                     // Font size
    ta_Style : FSF_ITALIC or FSF_BOLD; // Font style
    ta_Flags : 0;
  );
begin
  if not SetAndTest(font, OpenDiskFont(@ta)) then
  begin
    clean_exit('Can''t open font' + LineEnding);
  end;

  SetAPen(rp, pen1);
  SetBPen(rp, pen2);

  SetFont(rp, font);                    // Linking the font to the rastport

  {*
    In the TextAttr above we've queried a font with the styles italic and bold.
    OpenDiskFont() tries to open a font with this styles. If this fails
    the styles have to be generated algorithmically. To avoid that a
    style will be added to a font which has already the style intrinsically,
    we've first to ask. AskSoftStyle() returns a mask where all bits for styles
    which have to be added algorithmically are set.
  *}
  style := AskSoftStyle(rp);

  {*
    We finally set the style. SetSoftStyle() compares with the mask from
    AskSoftStyle() to avoid that an intrinsic style is applied again.
  *}
  SetSoftStyle(rp, style, FSF_ITALIC or FSF_BOLD);

  {*
    Now we write some text. Additionally the effects of the
    rastport modes are demonstrated
  *}
  write_text('JAM1'                 , 100,  60, JAM1);
  write_text('JAM2'                 , 100,  80, JAM2);
  write_text('COMPLEMENT'           , 100, 100, COMPLEMENT);
  write_text('INVERSVID'            , 100, 120, INVERSVID);
  write_text('JAM1|INVERSVID'       , 100, 140, JAM1 or INVERSVID);
  write_text('JAM2|INVERSVID'       , 100, 160, JAM2 or INVERSVID);
  write_text('COMPLEMENT|INVERSVID' , 100, 180, COMPLEMENT or INVERSVID);
end;



procedure write_text(const s: STRPTR; x: WORD; y: WORD; mode: ULONG);
begin
  SetDrMd(rp, mode);
  GfxMove(rp, x, y);
  GfxText(rp, s, strlen(s));
end; 



procedure handle_events;
var
  imsg       : pIntuiMessage;
  port       : pMsgPort;
  terminated : boolean;
begin
  {*
    A simple event handler. This will be explained more detailed
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
  If assigned(s)      then Write(s);

  // Give back allocated resources
  if (pen1 <> -1)     then ReleasePen(cm, pen1);
  if (pen2 <> -1)     then ReleasePen(cm, pen2);
  if assigned(font)   then CloseFont(font);
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
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  DiskFontBase := OpenLibrary(DISKFONTNAME, 0);
  if not assigned(DiskFontBase) then Exit;
  {$ENDIF}

  Result := True;
end;



Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if assigned(DiskFontBase) then CloseLibrary(pLibrary(DiskFontBase));
  {$ENDIF}
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
