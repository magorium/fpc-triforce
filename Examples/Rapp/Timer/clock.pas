program clock;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : clock
  Topic   : Simple digital clock
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/clock.c
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

Uses
  Exec, AmigaDOS, AGraphics, Intuition, Timer, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


//*-------------------------------------------------------------------------*/
//* Open timer.device                                                       */
//*-------------------------------------------------------------------------*/

function  open_timer(unitnr: LongInt): ptimerequest; 
var
  port: pMsgPort;
  req : ptimerequest;
begin
  if SetAndTest(port, CreateMsgPort) then
  begin
    if SetAndTest(req, CreateIORequest (port, sizeof(ttimerequest))) then
    begin
      if (0 = OpenDevice('timer.device', unitnr, pIORequest(req),0)) then
      begin
        exit(req);
      end;
      DeleteIORequest(pIORequest(req));
    end;
    DeleteMsgPort(port);
  end;

  result := nil;
end;

//*-------------------------------------------------------------------------*/
//* Close timer.device                                                      */
//*-------------------------------------------------------------------------*/

procedure close_timer(req: ptimerequest);
var
  port: pMsgPort;
begin
  if assigned(req) then
  begin
    CloseDevice(pIORequest(req));
    port := req^.tr_node.io_Message.mn_ReplyPort;
    DeleteIORequest(pIORequest(req));
    DeleteMsgPort(port);
  end;
end;

//*-------------------------------------------------------------------------*/
//* Start timer                                                             */
//*-------------------------------------------------------------------------*/

procedure start_timer(req: ptimerequest; secs: ULONG; micro: ULONG);
begin
  if assigned(req) then
  begin
    req^.tr_node.io_Command := TR_ADDREQUEST;
    req^.tr_time.tv_secs  := secs;
    req^.tr_time.tv_micro := micro;
    SendIO(pIORequest(req));
  end;
end;

//*-------------------------------------------------------------------------*/
//* Abort timer                                                             */
//*-------------------------------------------------------------------------*/

procedure stop_timer(req: ptimerequest);
begin
  if assigned(req) then
  begin
    if not( CheckIO(pIORequest(req)) <> nil) 
      then AbortIO(pIORequest(req));
    WaitIO(pIORequest(req));
  end;
end;

//*-------------------------------------------------------------------------*/
//* Wait for timer (also used to clean up an async request which has ended) */
//*-------------------------------------------------------------------------*/

procedure wait_timer(req: ptimerequest); inline;
begin
  WaitIO(pIORequest(req));
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function main: integer;
var
  scr       : pScreen;
  win       : pWindow;
  imsg      : pIntuiMessage;
  timereq   : ptimerequest;
  winsig, timersig, sigs : ULONG;
  cont      : Boolean;
  dt        : _TDateTime;

  textvalue : String[pred(LEN_DATSTRING)];
begin
  if SetAndTest(timereq, open_timer(UNIT_VBLANK)) then
  begin
    start_timer(timereq, 0, 10000);

    if SetAndTest(scr, LockPubScreen(nil)) then
    begin
      if SetAndTest(win, OpenWindowTags( nil,
      [
        TAG_(WA_Width)      , scr^.RastPort.TxWidth * 10 + 64,
        TAG_(WA_Height)     , scr^.WBorTop + scr^.RastPort.TxHeight + 1,
        TAG_(WA_PubScreen)  , TAG_(scr),
        TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_NOCAREREFRESH),
        TAG_(WA_IDCMP)      , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY),
        TAG_END
      ])) then
      begin
        winsig   := (1 shl win^.UserPort^.mp_SigBit);
        timersig := (1 shl timereq^.tr_node.io_Message.mn_ReplyPort^.mp_SigBit);

        cont := TRUE;

        repeat
          sigs := Wait (winsig or timersig or SIGBREAKF_CTRL_C);

          if ((sigs and SIGBREAKF_CTRL_C) <> 0) 
            then cont := FALSE;

          if ((sigs and timersig) <> 0) then
          begin
            wait_timer(timereq);
            start_timer(timereq, 1, 0);

            AmigaDOS.DateStamp(@dt.dat_Stamp);
            dt.dat_Format  := FORMAT_DOS;
            dt.dat_Flags   := 0;
            dt.dat_StrDay  := nil;
            dt.dat_StrDate := nil;
            dt.dat_StrTime := @textvalue[1];
            AmigaDOS.DateToStr(@dt);

            SetWindowTitles(win, @textvalue[1], Pointer(-1));
          end;

          if ((sigs and winsig) <> 0) then
          while SetAndTest(imsg, pIntuiMessage(GetMsg(win^.UserPort))) do
          begin
            case (imsg^.IClass) of
              IDCMP_VANILLAKEY:
                if (imsg^.Code = $1b) 
                then cont := FALSE;
              IDCMP_CLOSEWINDOW:
                cont := FALSE;
            end;
            ReplyMsg(pMessage(imsg));
          end;
        until not(cont);

        CloseWindow(win);
      end;

      UnlockPubScreen(nil, scr);
    end;

    stop_timer(timereq);
    close_timer(timereq);
  end;

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
  WriteLn('enter');

  if OpenLibs 
  then ExitCode := Main
  else ExitCode := RETURN_FAIL;

  CloseLibs;

  WriteLn('leave');
end.
