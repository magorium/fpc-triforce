program fibgui;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : fibgui
  Topic   : Calculation of Fibonacci numbers with button for stopping subtask
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/fibgui.c
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
  Exec, AmigaDOS, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

Const
  MEMF_SHARED   = MEMF_PUBLIC;

  title         : PChar = '<- close to abort      ';

  aborted       : boolean = FALSE;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure gui;
var
  pr    : PProcess;
  msg   : PMessage = nil;
  scr   : PScreen;
  win   : PWindow;
  mess  : PIntuiMessage;
  cont  : boolean;
  sigs, winsig, prsig : ULONG;
  w,h   : LongInt;
begin
  pr := PProcess(FindTask(nil));

  WaitPort(@pr^.pr_MsgPort);
  msg := GetMsg(@pr^.pr_MsgPort);

  msg^.mn_Node.ln_Pri := 0;  //* show failure */

  if SetAndtest(scr, LockPubScreen(nil)) then
  begin
    w := TextLength(@scr^.RastPort, title, strlen(title)) + 64;
    h := scr^.RastPort.TxHeight + scr^.WBorTop + 1;

    if SetAndTest(win, OpenWindowTags (nil,
    [
      TAG_(WA_Left)     , scr^.MouseX - 16,     //* position window so that the close gadget is under the mouse pointer */
      TAG_(WA_Top)      , scr^.MouseY - h div 2,
      TAG_(WA_Width)    , w,
      TAG_(WA_Height)   , h,
      TAG_(WA_Title)    , TAG_(title),
      TAG_(WA_Flags)    , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE),
      TAG_(WA_IDCMP)    , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY),
      TAG_END
    ])) then
    begin
      msg^.mn_Node.ln_Pri := 1;     //* gui initialised correctly */
      ReplyMsg(msg);
      msg := nil;

      winsig := 1 shl win^.UserPort^.mp_SigBit;
      prsig  := 1 shl pr^.pr_MsgPort.mp_SigBit;

      //* Do not use DOS functions when using pr_MsgPort for your own purposes ! */

      cont := TRUE;
      while cont do
      begin
        sigs := Wait(winsig or prsig);

        if (sigs and prsig <> 0) then
        begin
          if SetAndTest(msg, GetMsg(@pr^.pr_MsgPort))
            then cont := FALSE;     //* got message from main task -> let's quit */
        end;

        while SetAndTest(mess, PIntuiMessage(GetMsg(win^.UserPort))) do
        begin
          case (mess^.IClass) of
            IDCMP_CLOSEWINDOW:
              cont := FALSE;
            IDCMP_VANILLAKEY:
              if (mess^.Code = $1b)     //* Esc pressed */
              then cont := FALSE;
          end;
          ReplyMsg(PMessage(mess));
        end;
      end;

      aborted := TRUE;

      if not assigned(msg) then         //* main task didn't react yet */
      begin
        ModifyIDCMP(win, 0);            //* tell intuition that we don't listen to window messages any more */
        SetWindowPointer(win,
        [
          TAG_(WA_BusyPointer), TAG_(TRUE), //* show user that we got his input */
          TAG_END
        ]);

        WaitPort(@pr^.pr_MsgPort);      //* wait for reaction from main task */
        msg := GetMsg(@pr^.pr_MsgPort);
      end;

      CloseWindow(win);
    end;

    UnlockPubScreen(nil, scr);
  end;

  Forbid();         //* make sure we have finished before the reply is sent */
  ReplyMsg(msg);    //* tell main task that we have finished */
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function fib(n: ULONG): ULONG;  //* recursive calculation of fibonacci numbers */
begin
  if (n = 0) then exit(0);
  if (n = 1) then exit(1);
  if (aborted) then exit(0);
  result := (fib(n-1) + fib(n-2));
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  port      : pMsgPort;
  msg       : PMessage;
  pr        : PProcess;
  i,n,f     : ULONG;
begin
  if SetAndTest(msg, AllocVec(sizeof(TMessage), MEMF_CLEAR or MEMF_SHARED)) then
  begin
    if SetAndTest(port, CreateMsgPort()) then
    begin
      if SetAndTest(pr, CreateNewProcTags(
      [
        {$IFDEF MORPHOS}
        TAG_(NP_CodeType)     , TAG_(CODETYPE_PPC),
        {$ENDIF}
        TAG_(NP_Entry)        , TAG_(@gui),
        TAG_(NP_Name)         , TAG_(PChar('fibgui')),
        TAG_(NP_StackSize)    , 10000,
        TAG_(NP_Priority)     , 1,
        TAG_END
      ])) then
      begin
        msg^.mn_ReplyPort := port;
        PutMsg(@pr^.pr_MsgPort, msg);       //* establish communication with sub task */
        WaitPort(port);                     //* wait for reply from sub task */
        GetMsg(port);

        if (msg^.mn_Node.ln_Pri = 1) then   //* subtask replied success */
        begin
          // n = 47; /* highest result which fits into an unsigned long int */
          n := 35;

          i := 0;
          while ((i <= n) and not(aborted)) do
          begin
            f := fib(i);
            if not(aborted)
                then WriteLn(i,'/',n,': ',f);
            inc(i);
          end;
          
          if (aborted)
            then WriteLn('*** Break');

          msg^.mn_ReplyPort := port;
          PutMsg(@pr^.pr_MsgPort, msg);         //* tell sub task to quit */
          WaitPort(port);                       //* wait for reply from sub task */
          GetMsg(port);
        end
        else
          WriteLn('cannot open gui');
      end;

      DeleteMsgPort(port);
    end;
    FreeVec(msg);
  end;

  exit(0);
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
  else ExitCode := 10;

  CloseLibs;
  
  WriteLn('leave');
end.
