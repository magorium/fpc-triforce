Program intuition_events;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : intuition_events
  Topic   : Event handling
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/intuition_events.c
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
    Example for event handling of intuition windows
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

  procedure clean_exit(const s: STRPTR); forward;
  procedure handle_events; forward;



function  Main: Integer;
begin
  window := OpenWindowTags(nil,
  [
    TAG_(WA_Left)           , 400,
    TAG_(WA_Top)            , 70,
    TAG_(WA_InnerWidth)     , 300,
    TAG_(WA_InnerHeight)    , 300,
    TAG_(WA_Title)          , TAG_(PChar('Intuition events')),
    TAG_(WA_Activate)       , TAG_(TRUE),
    TAG_(WA_RMBTrap)        , TAG_(TRUE),   // handle right mouse button as normal mouse button
    TAG_(WA_CloseGadget)    , TAG_(TRUE),
    TAG_(WA_DragBar)        , TAG_(TRUE),
    TAG_(WA_GimmeZeroZero)  , TAG_(TRUE),
    TAG_(WA_DepthGadget)    , TAG_(TRUE),
    TAG_(WA_NoCareRefresh)  , TAG_(TRUE),   // we don't want to listen to refresh messages
    TAG_(WA_IDCMP)          , TAG_(IDCMP_CLOSEWINDOW or IDCMP_MOUSEBUTTONS or IDCMP_VANILLAKEY or IDCMP_RAWKEY),
    TAG_END
  ]);

  if not assigned(window) then clean_exit('Can''t open window' + LineEnding);

  WriteLn(LineEnding, 'Press "r" to disable VANILLAKEY');

  handle_events();

  clean_exit(nil);

  result := 0;
end;



procedure handle_events;
var
  imsg       : pIntuiMessage;
  port       : pMsgPort;
  
  signals    : ULONG;
  
  iclass     : ULONG;
  code       : UWORD;
  qualifier  : UWORD;
  mousex, mousey : SmallInt;
  
  terminated : boolean;
begin
  port := window^.userPort;
  terminated := false;
 
  while not(terminated) do
  begin
    signals := Wait(1 shl port^.mp_SigBit);

    while (SetAndGet(imsg, GetMsg(port)) <> nil) do
    begin
      iclass := imsg^.IClass;
      code   := imsg^.Code;
      qualifier := imsg^.Qualifier;
      mousex := imsg^.MouseX;
      mousey := imsg^.MouseY;

      {*
        After we have stored the necessary values from the message
        in variables we can immediately reply the message. Note
        that this is only possible because we have no VERIFY events.
      *}
      ReplyMsg(pMessage(imsg));

      Case IClass of
        IDCMP_CLOSEWINDOW : 
        begin
          WriteLn('IDCMP_CLOSEWINDOW');
          terminated := true;
        end;

        IDCMP_MOUSEBUTTONS:
        begin
          case (code) of
            SELECTDOWN: Write('left mouse button down');
            SELECTUP:   Write('left mouse button up');
            MENUDOWN:   Write('right mouse button down');
            MENUUP:     Write('right mouse button up');
            MIDDLEDOWN: Write('middle mouse button down');
            MIDDLEUP:   Write('middle mouse button up');
          end;
          WriteLn(' at ', mousex, ' ', mousey);
        end;

        IDCMP_VANILLAKEY:
        begin
          WriteLn('Vanillakey ', code, ' ', WideChar(code));
          if (WideChar(code) = 'r') then
          begin
            // ModifyIDCMP(window, window^.IDCMPFlags &= ~IDCMP_VANILLAKEY);
            ModifyIDCMP(window, window^.IDCMPFlags and not (IDCMP_VANILLAKEY));
            WriteLn('RAWKEY only');
          end;
        end;

        IDCMP_RAWKEY:
        begin
          WriteLn('Rawkey ', code, ' ', WideChar(code));
        end;

      end;
    end;
  end;
end;



procedure clean_exit(const s: STRPTR);
begin
  if assigned(s)      then WriteLn(s);

  // Give back allocated resourses
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
