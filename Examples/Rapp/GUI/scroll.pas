program scroll;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

{
  ===========================================================================
  Project : scroll
  Topic   : Move text on the screen. Control via Gadtools-button
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/scroll.c
  ===========================================================================

  This example was originally written in c by Thomas Rapp.

  The original examples are available online and published at Thomas Rapp's 
  website (http://thomas-rapp.homepage.t-online.de/examples)

  The c-sources were converted to Free Pascal, and (variable) names and 
  comments were translated from German into English as much as possible.

  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc

  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Conversion to Free Pascal and translation was done by Magorium in 2015, 
  with kind permission from Thomas Rapp to be able to publish.

  ===========================================================================  

        Unless otherwise noted, you must consider these examples to be 
                 copyrighted by their respective owner(s)

  ===========================================================================  
}

//*-------------------------------------------------------------------------*/
//* System Includes                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AmigaDOS, AGraphics, Intuition, GadTools, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

const
  GID_UP    = 1001;
  GID_DOWN  = 1002;


//*-------------------------------------------------------------------------*/
//* Main routine                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  scr       : PScreen;
  win       : PWindow;
  mess      : PIntuiMessage;
  cont      : Boolean;
  scroll    : Longint = 0;
  glist     : Pgadget = nil;
  gad       : PGadget;
  ng        : TNewGadget;
  winw,winh : Longint;
  y         : LongInt = 0;
begin
  scr := LockPubScreen(nil);

  gad := CreateContext(@glist);

  ng.ng_LeftEdge   := 0;
  ng.ng_TopEdge    := 20 * scr^.RastPort.TxHeight;
  ng.ng_Width      := 20 * scr^.RastPort.TxWidth;
  ng.ng_Height     := scr^.RastPort.TxHeight + 6;
  ng.ng_GadgetText := PChar('Up');
  ng.ng_TextAttr   := scr^.Font;
  ng.ng_GadgetID   := GID_UP;
  ng.ng_Flags      := 0;
  ng.ng_VisualInfo := GetVisualInfo(scr, [TAG_END, TAG_END]); // AROS Tag implementation crashes on a single given tagitem
  gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_(GA_Immediate), TAG_(TRUE), TAG_END]);

  ng.ng_LeftEdge   := ng.ng_LeftEdge + ng.ng_Width;
  ng.ng_GadgetText := PChar('Down');
  ng.ng_GadgetID   := GID_DOWN;
  gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_(GA_Immediate), TAG_(TRUE), TAG_END]);

  winw := ng.ng_LeftEdge + ng.ng_Width  + scr^.WBorLeft + scr^.WBorRight;
  winh := ng.ng_TopEdge  + ng.ng_Height + scr^.WBorTop  + scr^.WBorBottom + scr^.RastPort.TxHeight + 1;

  win := OpenWindowTags(nil,
  [
    TAG_(WA_Left)       , (scr^.Width  - winw) div 2,
    TAG_(WA_Top)        , (scr^.Height - winh) div 2,
    TAG_(WA_Width)      , winw,
    TAG_(WA_Height)     , winh,
    TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH),
    TAG_(WA_IDCMP)      , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_GADGETUP or IDCMP_GADGETDOWN),
    TAG_(WA_Gadgets)    , TAG_(glist),
    TAG_END
  ]);

  if not assigned(win) then
  begin
    WriteLn('cannot open window');
    exit(RETURN_FAIL);
  end
  else
  begin
    GT_RefreshWindow(win, nil);

    SetFont(win^.RPort, scr^.RastPort.Font);
    SetABPenDrMd(win^.RPort, 1, 0, JAM2);

    cont := TRUE;

    While (cont) do
    begin
      if (scroll <> 0) then
      begin
        if (scroll > 0) then
        begin
          if (gad^.Flags and GFLG_SELECTED <> 0) then
          begin
            ScrollRaster(win^.RPort, 0, -1, 0, 0, win^.GZZWidth - 1, win^.GZZHeight - ng.ng_Height - 1);
            inc(y);
            if (y >= win^.RPort^.TxHeight) then
            begin
              y := 0;
              GfxMove(win^.RPort, 0, win^.RPort^.TxBaseline);
              GfxText(win^.RPort, 'Text Text Text Text Text Text Text Text Text',44);
            end;
          end;
        end
        else
        begin
          if (gad^.Flags and GFLG_SELECTED <> 0) then
          begin
            ScrollRaster(win^.RPort, 0, 1, 0, 0, win^.GZZWidth - 1, win^.GZZHeight - ng.ng_Height - 1);
            dec(y);
            if (y < 0) then
            begin
              y := win^.RPort^.TxHeight - 1;
              GfxMove(win^.RPort, 0, win^.GZZHeight - ng.ng_Height - win^.RPort^.TxHeight + win^.RPort^.TxBaseline);
              GfxText(win^.RPort, 'Text Text Text Text Text Text Text Text Text', 44);
            end;
          end;
        end;

        WaitTOF();

        if (SetSignal(0,0) and SIGBREAKF_CTRL_C <> 0)
            then cont := FALSE;
      end
      else
      begin
        if (Wait ((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
            then cont := FALSE;
      end;

      while SetAndTest(mess, GT_GetIMsg(win^.UserPort)) do
      begin
        case (mess^.IClass) of
          IDCMP_GADGETDOWN:
          begin
            gad := PGadget(mess^.IAddress);
            case (gad^.GadgetID) of
              GID_UP    : scroll := -1;
              GID_DOWN  : scroll :=  1;
            end;
          end;
          IDCMP_GADGETUP: scroll := 0;
          IDCMP_VANILLAKEY:
            if (mess^.Code = $1b) //* Esc */
              then cont := FALSE;
          IDCMP_CLOSEWINDOW:
            cont := FALSE;
        end;
        GT_ReplyIMsg(mess);
      end;
    end;  // outer while

	CloseWindow (win);
  end;

  FreeGadgets (glist);

  FreeVisualInfo(ng.ng_VisualInfo);

  UnlockPubScreen(nil, scr);

  result := (RETURN_OK);
end;

//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/

Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  GfxBase := OpenLibrary(GRAPHICSNAME, 0);
  if not assigned(GfxBase) then Exit;

  GadToolsBase := OpenLibrary(GADTOOLSNAME, 0);
  if not assigned(GadToolsBase) then Exit;
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
  if assigned(GadToolsBase) then CloseLibrary(pLibrary(GadToolsBase));

  if assigned(GfxBase) then CloseLibrary(pLibrary(GfxBase));
  {$ENDIF}
end;


begin
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := RETURN_FAIL;

  CloseLibs;
end.
