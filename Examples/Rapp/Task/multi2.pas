program multi2;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : multi2
  Topic   : Background task sending progress messages
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/multi2.c
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


//*-------------------------------------------------------------------------*/
//* System includes                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AmigaDOS, Utility,
  {$IFDEF AMIGA}
  systemvartags,  
  {$ENDIF}
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//* Type definitions                                                        */
//*-------------------------------------------------------------------------*/

Type
  pbginitmsg = ^tbginitmsg;
  tbginitmsg = record
    msg         : TMessage;
    progress    : LongInt;
    txt         : PChar;
    res         : PChar;
  end;

//*-------------------------------------------------------------------------*/
//* The background task                                                     */
//*-------------------------------------------------------------------------*/

procedure background_task;
var
  pr            : pProcess;
  initmsg       : pbginitmsg;
  win           : BPTR;
  replyport     : pMsgPort;
  progressport  : pMsgPort;
  
  i             : Integer;
  progressmsg   : pbginitmsg;
begin
  pr := pProcess(FindTask(nil));
  
  WaitPort(@pr^.pr_MsgPort);
  initmsg := pbginitmsg(GetMsg(@pr^.pr_MsgPort));

  initmsg^.progress := -1;
  initmsg^.res := 'failed to create reply port';

  if SetAndTest(replyport, CreateMsgPort) then
  begin
    initmsg^.res := 'failed to open window';

    if SetAndTest(win, DOSOpen('CON://400/200/Background Task/INACTIVE', MODE_NEWFILE)) then
    begin

      FPrintf(win, 'input: %s' + LineEnding, [UIntPtr(initmsg^.txt)]);

      progressport := initmsg^.msg.mn_ReplyPort;    //* using the main program's reply port to send progress messages to (the main program must know and expect this, of course) */

      initmsg^.res := 'success';

      for i := 10 downto Succ(0) do
      begin
        if SetAndTest(progressmsg, AllocVec(sizeof(tbginitmsg), MEMF_CLEAR or MEMF_PUBLIC)) then
        begin
          progressmsg^.msg.mn_ReplyPort := replyport;
          progressmsg^.progress := i;
          PutMsg(progressport, @progressmsg^.msg);
          WaitPort(replyport);
          GetMsg(replyport);
          FreeVec(progressmsg);
        end;

        DOSDelay(TICKS_PER_SECOND);

        if ((SetSignal(0,0) and SIGBREAKF_CTRL_C) <> 0) then
        begin
          initmsg^.res := 'stopped by break signal';
          break;
        end;
      end;

      DOSClose(win);
    end;

    DeleteMsgPort(replyport);
  end;

  Forbid();
  ReplyMsg(@initmsg^.msg);
end;

//*-------------------------------------------------------------------------*/
//* Start the background task                                               */
//*-------------------------------------------------------------------------*/

function  start_background_task(replyport: pMsgPort; txt: PChar): pProcess;
var
  pr        : pProcess;
  initmsg   : pbginitmsg;
begin
  pr := nil;
  initmsg := AllocVec(sizeof(tbginitmsg), MEMF_CLEAR or MEMF_PUBLIC);

  if Assigned(initmsg) then
  begin
    if SetAndTest(pr, CreateNewProcTags(
    [
      {$IFDEF MORPHOS}
      TAG_(NP_CodeType) , TAG_(CODETYPE_PPC),
      {$ENDIF}
      TAG_(NP_Name)     , TAG_(PChar('example_background_task')),
      TAG_(NP_Entry)    , TAG_(@background_task),
      TAG_END
    ])) then
    begin
      initmsg^.msg.mn_ReplyPort := replyport;
      initmsg^.txt := txt;
      PutMsg(@pr^.pr_MsgPort, @initmsg^.msg);
    end;
  end;

  result := (pr);
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: Integer;
var
  mainport  : pMsgPort;
  back_pr   : pProcess;
  portsig   : ULONG;
  res       : PChar;
  msg       : pbginitmsg;
begin
  mainport := CreateMsgPort();  //* this port receives a message when the background task ends */
  if assigned(mainport) then
  begin
    back_pr := start_background_task(mainport, 'test data');
    if assigned(back_pr) then
    begin
      portsig := 1 shl mainport^.mp_SigBit;

      WriteLn('Background task started; waiting for completion.');
      WriteLn('Press Ctrl-C to cancel processing.');

      repeat
        if ((Wait(portsig or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0) then
        begin
          WriteLn('*** Break');
          Signal(@back_pr^.pr_Task, SIGBREAKF_CTRL_C);
        end;

        while SetAndTest(msg, pbginitmsg(GetMsg(mainport))) do
        begin
          if (msg^.progress = -1) then  //* final message when background task dies */
          begin                         //* you could as well check for msg->mn_Node.ln_Type == NT_REPLYMSG (set by ReplyMsg), because the final message is a reply to the PutMsg in the start_background_task routine while the progress messages are of NT_MESSAGE type (set by PutMsg). */
            WriteLn('Background task stopped.');
            WriteLn('Result: ', msg^.res);

            FreeVec(msg);
            back_pr := nil;             //* background task no longer exists */
          end
          else
          begin
            WriteLn('got progress message: ', msg^.progress, ' to go');
            ReplyMsg(@msg^.msg);
          end;
        end;
      until not assigned(back_pr);
    end;

    DeleteMsgPort(mainport);
  end;

  result := (0);
end;

//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/

Function OpenLibs: boolean;
begin
  Result := True;
end;


Procedure CloseLibs;
begin
end;


begin
  WriteLn('enter');

  if OpenLibs 
  then ExitCode := Main
  else ExitCode := RETURN_FAIL;

  CloseLibs;
  
  WriteLn('leave');
end.
