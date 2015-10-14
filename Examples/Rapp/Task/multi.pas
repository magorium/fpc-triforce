program multi;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : multi
  Topic   : Example for multitasking
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/multi.c
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
  Exec, AmigaDOS, Utility,
  {$IFDEF AMIGA}
  AmigaLib,
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


//*-------------------------------------------------------------------------*/
//* Subtask                                                                 */
//*-------------------------------------------------------------------------*/

procedure subtask;
var
  win           : BPTR;
  mainport      : pMsgPort;
  replyport     : pMsgPort;
  mymsg         : TMessage;
  buffer        : packed array[0..Pred(200)] of char;
  mysignal      : ULONG;
  dt            : _TDateTime;
begin
  if SetAndTest(win, DOSOpen('con:20/20/400/300/Subtask_Window/AUTO/CLOSE/WAIT/INACTIVE', MODE_OLDFILE)) then
  begin
    if SetAndTest(replyport, CreatePort(nil, 0)) then
    begin
      FPrintf(win, 'Subtask started.' + LineEnding);
      DOSDelay(50);

      mysignal := 1 shl replyport^.mp_SigBit;
      if SetAndTest(mainport, FindPort('multi_port')) then
      begin
        while not ((SetSignal(0,0) and SIGBREAKF_CTRL_C) <> 0) do
        begin
          DateStamp(@dt.dat_Stamp);
          dt.dat_Format  := FORMAT_DOS;
          dt.dat_Flags   := 0;
          dt.dat_StrDay  := nil;
          dt.dat_StrDate := nil;
          dt.dat_StrTime := @buffer[0];
          AmigaDOS.DateToStr(@dt);

          mymsg.mn_Node.ln_Name := @buffer[0];
          mymsg.mn_ReplyPort := replyport;
          mymsg.mn_Length := sizeof(mymsg);

          FPrintf(win, 'Send message. Text = %s' + LineEnding, [UIntPtr(@buffer[0])]);
          PutMsg(mainport, @mymsg);

          FPrintf(win, 'Waiting for reply.' + LineEnding, [UIntPtr(@buffer[0])]);
          Wait(mysignal or SIGBREAKF_CTRL_C);
          GetMsg(replyport);

          FPrintf(win, 'Pause...' + LineEnding);
          DOSDelay(50);
        end;
      end
      else
        FPrintf(win, 'Could not find MsgPort of main task !!' + LineEnding);

      DeletePort(replyport);
    end;

    FPrintf(win, 'Subtask has stopped.' + LineEnding);
    FPrintf(win, 'Please close the window using the close button.' + LineEnding);
    DOSClose(win);
  end;
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main(argc: Integer; argv: PPChar): Integer;
var
  port      : pMsgPort;
  msg       : pMessage;
  task      : pTask;
  go_on     : boolean;
  portsig   : ULONG;
  signals   : ULONG;
  i         : LongInt;
begin
  if SetAndTest(port, CreatePort('multi_port', 0)) then
  begin
    WriteLn('Start subtask.');
    CreateNewProcTags(
    [
      TAG_(NP_Entry)    , TAG_(@subtask),
      TAG_(NP_Name)     , TAG_(PChar('multi_subtask')),
      TAG_END
    ]);

    WriteLn('Subtask is set up.');
    WriteLn('Waiting for messages. ');
    WriteLn('Press Ctrl-C to quit.');

    portsig := (1 shl port^.mp_SigBit);
    go_on   := true;
    while (go_on) do
    begin
      signals := Wait(portsig or SIGBREAKF_CTRL_C);
      if ((signals and SIGBREAKF_CTRL_C) <> 0)
        then go_on := false;
      if ((signals and portsig) <> 0) then
      begin
        while SetAndTest(msg, GetMsg(port)) do
        begin
          WriteLn('Message received. Text = ', msg^.mn_Node.ln_Name);
          ReplyMsg(msg);
        end;
      end;
    end;

    WriteLn('Stopping subtask..');
    i := 0;
    while ((i < 100) and SetAndTest(task, FindTask('multi_subtask'))) do
    begin
      Signal(task, SIGBREAKF_CTRL_C);
      DOSDelay (1);
      inc(i);
    end;
    if not assigned(task)
    then WriteLn('Subtask ended.')
    else
    begin
      WriteLn('*** Subtask could not be stopped !!');
      WriteLn('Removing subtask unsafely from the system.');
      WriteLn('Resources are not released.');
      Forbid();
      RemTask(task);
      Permit();
    end;

    DeletePort(port);
  end;

  WriteLn('End of program.');
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
  then ExitCode := Main(ArgC, ArgV)
  else ExitCode := RETURN_FAIL;

  CloseLibs;
  
  WriteLn('leave');
end.
