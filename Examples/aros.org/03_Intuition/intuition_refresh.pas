Program intuition_refresh;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : intuition_refresh
  Topic   : Examine difference between simplerefresh and smartrefresh windows
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/intuition_refresh.c
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
    Example for refresh handling of intuition windows

    Two windows are opened, one with simplerefresh, the other one with
    smartrefresh. You can watch what messages are sent when you move around
    or resize the windows. There is intentionally no redrawing in the
    event handler, so that you can clearly see the result of your window
    manipulation.
*}



Uses
  exec, agraphics, intuition, utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  chelpers,
  trinity;



var
  window1, window2  : pWindow;
  cm                : pColorMap;



const
  {*
    ObtainBestPen() returns -1 when it fails, therefore we
    initialize the pen numbers with -1 to simplify cleanup.
  *}
  pen1      : LONG = -1;
  pen2      : LONG = -1;


  procedure draw_stuff(win: pWindow);  forward;
  procedure clean_exit(const s: STRPTR); forward;
  function  handle_events(win: pWindow; terminated: Boolean): Boolean; forward;



function  main: Integer;
var
  signals       : ULONG;
  terminated    : Boolean;
begin
  window1 := OpenWindowTags(nil,
  [
    TAG_(WA_Left)           , 50,
    TAG_(WA_Top)            , 70,
    TAG_(WA_InnerWidth)     , 300,
    TAG_(WA_InnerHeight)    , 300,

    {*
      When we have a size gadget we must additionally
      define the limits.
    *}
    TAG_(WA_MinWidth)       , 100,
    TAG_(WA_MinHeight)      , 100,
    TAG_(WA_MaxWidth)       , TAG_(-1),
    TAG_(WA_MaxHeight)      , TAG_(-1),

    TAG_(WA_Title)          , TAG_(PChar('Simplerefresh window')),
    TAG_(WA_Activate)       , TAG_(TRUE),
    TAG_(WA_SimpleRefresh)  , TAG_(TRUE),
    TAG_(WA_CloseGadget)    , TAG_(TRUE),
    TAG_(WA_SizeGadget)     , TAG_(TRUE),
    TAG_(WA_DragBar)        , TAG_(TRUE),
    TAG_(WA_DepthGadget)    , TAG_(TRUE),
    TAG_(WA_GimmeZeroZero)  , TAG_(TRUE),
    TAG_(WA_IDCMP)          , TAG_(IDCMP_CLOSEWINDOW or IDCMP_CHANGEWINDOW or IDCMP_NEWSIZE or IDCMP_REFRESHWINDOW or IDCMP_SIZEVERIFY),
    TAG_END
  ]);

  if not assigned(window1) then clean_exit('Can''t open window 1' + LineEnding);

  window2 := OpenWindowTags(nil,
  [
    TAG_(WA_Left)           , 400,
    TAG_(WA_Top)            , 70,
    TAG_(WA_InnerWidth)     , 300,
    TAG_(WA_InnerHeight)    , 300,
    TAG_(WA_MinWidth)       , 100,
    TAG_(WA_MinHeight)      , 100,
    TAG_(WA_MaxWidth)       , TAG_(-1),
    TAG_(WA_MaxHeight)      , TAG_(-1),
    TAG_(WA_Title)          , TAG_(PChar('Smartrefresh window')),
    TAG_(WA_Activate)       , TAG_(TRUE),
    TAG_(WA_SmartRefresh)   , TAG_(TRUE),
    TAG_(WA_CloseGadget)    , TAG_(TRUE),
    TAG_(WA_SizeGadget)     , TAG_(TRUE),
    TAG_(WA_DragBar)        , TAG_(TRUE),
    TAG_(WA_DepthGadget)    , TAG_(TRUE),
    TAG_(WA_GimmeZeroZero)  , TAG_(TRUE),
    TAG_(WA_IDCMP)          , TAG_(IDCMP_CLOSEWINDOW or IDCMP_CHANGEWINDOW or IDCMP_NEWSIZE or IDCMP_REFRESHWINDOW or IDCMP_SIZEVERIFY),
    TAG_END
  ]);

  if not assigned(window2) then clean_exit('Can''t open window 2' + LineEnding);

  {$IFNDEF AROS}
  cm := pScreen(window1^.WScreen)^.ViewPort.Colormap;
  {$ELSE}
  cm := window1^.WScreen^.ViewPort.Colormap;
  {$ENDIF}

  // Let's obtain two pens
  {$IFDEF AROS}
  pen1 := ObtainBestPenA(cm, $FFFF0000, 0, 0, nil);
  pen2 := ObtainBestPenA(cm, 0 ,0, $FFFF0000, nil);
  {$ELSE}
  pen1 := ObtainBestPen(cm, $FFFF0000, 0, 0, [TAG_END]);
  pen2 := ObtainBestPen(cm, 0 ,0, $FFFF0000, [TAG_END]);
  {$ENDIF}
  if (not (pen1 <> 0) or not (pen2 <> 0)) then clean_exit('Can''t allocate pen' + LineEnding);

  draw_stuff(window1);
  draw_stuff(window2);

  terminated := FALSE;

  while not(terminated) do
  begin
    {*
        If we want to wait for signals of more than one window
        we have to combine the signal bits.
    *}
     signals := Wait
     (
       ( 1 shl window1^.UserPort^.mp_SigBit) or
       ( 1 shl window2^.UserPort^.mp_SigBit)
     );
     {*
        Now we can check which window has received the signal and
        then we call the event handler for that window.
     *}
      if (signals and (1 shl window1^.UserPort^.mp_SigBit) <> 0)
      then terminated := handle_events(window1, terminated)
      else 
      if (signals and (1 shl window2^.UserPort^.mp_SigBit) <> 0)
      then terminated := handle_events(window2, terminated);
  end;

  clean_exit(nil);

  result := 0;
end;



procedure draw_stuff(win: pWindow);
var
  x     : Integer;
  rp    : pRastPort;
begin
  rp := win^.RPort;
        
  x := 10;
  while (x <= 290) do 
  begin
    SetAPen(rp, pen1);
    GfxMove(rp, x, 10);
    Draw(rp, 300-x, 290);
    SetAPen(rp, pen2);
    GfxMove(rp, 10, x);
    Draw(rp, 290, 300-x);
    inc(x, 10);
  end;
end;


function  handle_events(win: pWindow; terminated: Boolean): Boolean;
var
  imsg      : pIntuiMessage;
  port      : pMsgPort;

  event_nr  : ULONG;
begin
  port := win^.userPort;

  event_nr := 0;

  while (SetAndGet(imsg, GetMsg(port)) <> nil) do
  begin
    inc(event_nr);
    Write('Event # ', event_nr, ' ');

    if (win = window1)
    then Write('Window #1 ')
    else Write('Window #2 ');

    Case (imsg^.IClass) of
      IDCMP_CLOSEWINDOW : 
      begin
        WriteLn('IDCMP_CLOSEWINDOW');
        terminated := true;
      end;

      IDCMP_CHANGEWINDOW:
      begin
        // Window has been moved or resized
        WriteLn('IDCMP_CHANGEWINDOW');
      end;

      IDCMP_NEWSIZE:
      begin
        WriteLn('IDCMP_NEWSIZE');
      end;

      IDCMP_REFRESHWINDOW:
      begin
        WriteLn('IDCMP_REFRESHWINDOW');
        BeginRefresh(win);
        {*
          Here you can add code which redraws
          exposed parts of the window.          
        *}
        EndRefresh(win, TRUE);
      end;

      IDCMP_SIZEVERIFY:
      begin
        // SIZEVERIFY blocks a window until the message has been replied
        WriteLn('IDCMP_SIZEVERIFY');
      end;

    end;
    // Every message must be replied.
    ReplyMsg(pMessage(imsg));
  end;
  result := terminated;
end;



procedure clean_exit(const s: STRPTR);
begin
  if assigned(s)       then WriteLn(s);

  // Give back allocated resources
  if (pen1 <> -1)      then ReleasePen(cm, pen1);
  if (pen2 <> -1)      then ReleasePen(cm, pen2);
  if assigned(window1) then CloseWindow(window1);
  if assigned(window2) then CloseWindow(window2);

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
