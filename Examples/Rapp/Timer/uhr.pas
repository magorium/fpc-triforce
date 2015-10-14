program uhr;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : uhr
  Topic   : A simple digital clock as an example for timer.device
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/uhr.c
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

           Unless otherwise noted, these examples must be considered
                 copyrighted by their respective owner(s)

  ===========================================================================
}

Uses
  Exec, AmigaDOS, AGraphics, Intuition, Timer, Utility,
  {$IFDEF AMIGA}
  systemvartags,  
  {$ENDIF}
  CHelpers,
  Trinity,
  SysUtils;


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
//* Starting timer                                                          */
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
//* Stopping timer                                                          */
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
//* Wait for timer e.g. get Timer-Message                                   */
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
  dragbar   : pGadget;
  winw,winh : LongInt;
  maintimer : ptimerequest;
  testtimer : ptimerequest;
  winsig    : ULONG;
  timersig  : ULONG;
  sigs      : ULONG;
  timeval   : ttimeval;
  textvalue : String[pred(10)];
  keeprunning : Boolean;
begin
  if SetAndTest(scr, LockPubScreen(nil)) then
  begin
    winw := TextLength(@scr^.RastPort, '00:00:00',8) + 7;
    winh := scr^.RastPort.TxHeight + 5;

    if SetAndTest(win, OpenWindowTags( nil,
    [
      TAG_(WA_Left)   , scr^.Width - winw,
      TAG_(WA_Top)    , scr^.BarHeight + 1,
      TAG_(WA_Width)  , winw,
      TAG_(WA_Height) , winh,
      TAG_(WA_Flags)  , TAG_(WFLG_BORDERLESS or WFLG_NOCAREREFRESH),
      TAG_(WA_IDCMP)  , TAG_(IDCMP_VANILLAKEY),
      TAG_END
    ])) then
    begin
      if SetAndTest(dragbar, NewObject(nil, 'gadgetclass',
      [
        TAG_(GA_Left)       , 0,
        TAG_(GA_Top)        , 0,
        TAG_(GA_RelWidth)   , 0,
        TAG_(GA_RelHeight)  , 0,
        TAG_(GA_SysGType)   , TAG_(GTYP_WDRAGGING),
        TAG_END
      ])) then
      begin
        AddGadget (win, dragbar, LongWord(-1));
      end;

      GfxMove (win^.RPort, 0, win^.Height - 1);
      SetAPen (win^.RPort, 2);
      Draw (win^.RPort, 0, 0);
      Draw (win^.RPort, win^.Width - 1, 0);
      SetAPen (win^.RPort, 1);
      Draw (win^.RPort, win^.Width - 1, win^.Height - 1);
      Draw (win^.RPort, 0, win^.Height - 1);
      SetFont (win^.RPort, scr^.RastPort.Font);

      maintimer := open_timer(UNIT_WAITUNTIL);
      testtimer := open_timer(UNIT_VBLANK);

      {/*
        Why two Timers ?

        In order to make the clock as accurate as possible, we make use of
        UNIT_WAITUNTIL. By waiting for the next second that is reached 
        (tv_micro = 0), we get a signal exactly when the systemclock jumps to 
        the next second. 
        That's why the display will always show an acurate system-time. If we 
        would just wait for the full second to be reached, the clock would 
        become very inaccurate, which means that the time could end up being 
        off for even up to a second.

        The second timer comes into play, if the user changes the system time 
        backwards. In that case the first timer will wait until the system 
        time corresponds again with the time for which we were waiting. This 
        can take a long time f.i. if the clock was reset for daylight savings 
        time. In that case, the second timer will wait for a second first and 
        then update the clock again.
      */}

      if (assigned(maintimer) and Assigned(testtimer)) then
      begin
        TimerBase := pLibrary(maintimer^.tr_node.io_Device);

        GetSysTime(@timeval);
        start_timer(testtimer, 0, 100000); //* Just wait shortly, to draw the clock immediately */
        start_timer(maintimer, timeval.tv_secs + 1,0); //* Not really used, but the timer has to be started in order to let stop_timer() work. */

        timersig := (1 shl maintimer^.tr_node.io_Message.mn_ReplyPort^.mp_SigBit);
        timersig := timersig or ULONG(1 shl testtimer^.tr_node.io_Message.mn_ReplyPort^.mp_SigBit);
        winsig   := (1 shl win^.UserPort^.mp_SigBit);

        keeprunning := TRUE;

        Repeat
          sigs := Wait(timersig or winsig or SIGBREAKF_CTRL_C);

          if ((sigs and timersig) <> 0) then //* Timersig contains both signals, so it does not really matter which timer ends first, this is true for every If comparison. */
          begin
            stop_timer(maintimer); //* One of the timers has not completed yet, so let's cancel it.*/
            stop_timer(testtimer); //* The function checks if the timer is still running and in case it isn't, just clean up things nicely. */
            SetSignal(0,timersig); //* Cancelling the timer without Wait() will not reset the signal, so we do it manually to make sure. */

            GetSysTime(@timeval);
            System.WriteStr
            (
              textvalue, Format('%02d:%02d:%02d', 
              [ (timeval.tv_secs mod 86400) div 3600, (timeval.tv_secs mod 3600) div 60, timeval.tv_secs mod 60 ])
            );
            SetABPenDrMd(win^.RPort, 1, 0, JAM2);
            GfxMove(win^.RPort, 4, 3 + win^.RPort^.TxBaseline);
            GfxText(win^.RPort, @textvalue[1], length(textvalue));
            SetABPenDrMd(win^.RPort, 2, 0, JAM1);
            GfxMove(win^.RPort, 3, 2 + win^.RPort^.TxBaseline);
            GfxText(win^.RPort, @textvalue[1], length(textvalue));

            start_timer(maintimer, timeval.tv_secs + 1, 0);
            start_timer(testtimer, 1, 0);
          end;

          if ((sigs and winsig) <> 0) then
          begin
            while (SetAndTest(imsg, pIntuiMessage(GetMsg(win^.UserPort)))) do
            begin
              case imsg^.IClass of
                IDCMP_VANILLAKEY: 
                  if (imsg^.Code = $1b) //* Esc */
                  then keeprunning := FALSE;
              end;
              ReplyMsg(pMessage(imsg));
            end;
          end;

          if ((sigs and SIGBREAKF_CTRL_C) <> 0)
          then keeprunning := FALSE;

        until not(keeprunning);
      end;

      stop_timer(maintimer);
      close_timer(maintimer);
      stop_timer(testtimer);
      close_timer(testtimer);

      CloseWindow(win);
      if assigned(dragbar)
      then DisposeObject(dragbar);
    end;
    UnlockPubScreen(nil, scr);
  end;

  result := 0;
end;

//*-------------------------------------------------------------------------*/
//* End of original source code                                             */
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
