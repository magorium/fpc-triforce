program multi1;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : multi1
  Topic   : Process a task in the background.
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/multi1.c
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
    msg : TMessage;
    txt : PChar;
    res : PChar;
  end;

//*-------------------------------------------------------------------------*/
//* The background task                                                     */
//*-------------------------------------------------------------------------*/

procedure background_task;
var
  pr        : pProcess;
  initmsg   : pbginitmsg;
  win       : BPTR;
  
  i         : Integer;
begin
  pr := pProcess(FindTask(nil));
  
  WaitPort(@pr^.pr_MsgPort);
  initmsg := pbginitmsg(GetMsg(@pr^.pr_MsgPort));

  initmsg^.res := 'failed to open window';

  if SetAndTest(win, DOSOpen('CON://400/200/Background Task/INACTIVE', MODE_NEWFILE)) then
  begin
    initmsg^.res := 'success';

    for i := 10 downto Succ(0) do
    begin
      FPrintf(win, 'processing %s ... %ld to go' + LineEnding, [UIntPtr(initmsg^.txt), i]);
      DOSDelay(TICKS_PER_SECOND);

      if ((SetSignal(0,0) and SIGBREAKF_CTRL_C) <> 0) then
      begin
        initmsg^.res := 'stopped by break signal';
        break;
      end;
    end;

    DOSClose(win);
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
      TAG_(NP_Name) , TAG_(PChar('example_background_task')),
      TAG_(NP_Entry), TAG_(@background_task),
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
//* Stop the background task                                                */
//*-------------------------------------------------------------------------*/

function  stop_background_task(replyport: pMsgPort; pr: pProcess): PChar;
var
  msg   : pbginitmsg;
  res   : PChar;
begin
  msg := pbginitmsg(GetMsg(replyport));     //* get reply from backgroung task */

  if not assigned(msg) then                 //* reply not yet sent */
  begin
    Signal(@pr^.pr_Task, SIGBREAKF_CTRL_C); //* send break signal to background task */
    repeat
      DOSDelay(TICKS_PER_SECOND div 10);    //* avoid busy-waiting */
      msg := pbginitmsg(GetMsg(replyport)); //* check if response is here now */
    until assigned(msg);
  end;

  res := msg^.res;                          //* get result from message */

  FreeVec(msg);                             //* free message memory */

  result := (res);
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: Integer;
var
  replyport : pMsgPort;
  back_pr   : pProcess;
  portsig   : ULONG;
  res       : PChar;
begin
  replyport := CreateMsgPort(); //* this port receives a message when the background task ends */
  if Assigned(replyport) then
  begin
    back_pr := start_background_task(replyport, 'test data');
    if assigned(back_pr) then
    begin
      portsig := 1 shl replyport^.mp_SigBit;

      WriteLn('Background task started; waiting for completion.');
      WriteLn('Press Ctrl-C to cancel processing.');

      Wait(portsig or SIGBREAKF_CTRL_C);

      res := stop_background_task(replyport, back_pr);

      WriteLn('Background task stopped.');
      WriteLn('Result: ', res);
    end;

    DeleteMsgPort(replyport);
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
