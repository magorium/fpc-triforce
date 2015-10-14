program multi3;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : multi3
  Topic   : Background task waiting for commands and replies
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/multi3.c
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
  Trinity,
  Strings;

//*-------------------------------------------------------------------------*/
//* Type definitions                                                        */
//*-------------------------------------------------------------------------*/

Type
  pservermsg = ^tservermsg;
  tservermsg = record
    msg         : TMessage;
    data        : record
      case boolean of
      true        : 
      (
        init : record
          txt         : PChar;
          cmdport     : pMsgPort;    
        end;
      );
      false       :
      (
        cmd : record
          command     : PChar;
          res         : PChar;
        end;
      );
    end;
  end;

//*-------------------------------------------------------------------------*/
//* The background task                                                     */
//*-------------------------------------------------------------------------*/

procedure background_task;
var
  pr            : pProcess;
  serverport    : pMsgPort;
  msg           : pservermsg;
  win           : BPTR;
  cont          : Boolean;
begin
  pr := pProcess(FindTask(nil));

  WaitPort(@pr^.pr_MsgPort);
  msg := pservermsg(GetMsg(@pr^.pr_MsgPort));

  msg^.data.init.cmdport := nil;

  if SetAndTest(win, DOSOpen('CON://400/200/Background Task/INACTIVE', MODE_NEWFILE)) then
  begin
    if SetAndTest(serverport, CreateMsgPort()) then
    begin
      FPrintf(win, 'input: %s' + LineEnding, [UIntPtr(msg^.data.init.txt)]);

      msg^.data.init.cmdport := serverport;
      ReplyMsg(@msg^.msg);

      cont := TRUE;

      repeat
        WaitPort(serverport);

        while SetAndTest(msg, pservermsg(GetMsg(serverport))) do
        begin
          FPrintf(win, 'received command: %s' + LineEnding, [UIntPtr(msg^.data.cmd.command)]);

          if (strcomp(msg^.data.cmd.command, 'QUIT') = 0) then
          begin
            msg^.data.cmd.res := 'server stopped';
            cont := FALSE;
            break;
          end
          else
          begin
            DOSDelay(TICKS_PER_SECOND);
            msg^.data.cmd.res := 'ok';
            ReplyMsg(@msg^.msg);
          end;
        end;
      until not(cont);

      DeleteMsgPort(serverport);
    end
    else
      msg^.data.init.txt := 'failed to create port';

    DOSClose(win);
  end
  else
    msg^.data.init.txt := 'failed to open window';

  Forbid();
  ReplyMsg(@msg^.msg);
end;

//*-------------------------------------------------------------------------*/
//* Start the background task                                               */
//*-------------------------------------------------------------------------*/

function  start_background_task(replyport: pMsgPort; txt: PChar): pMsgPort;
var
  cmdport   : pMsgPort;
  initmsg   : pservermsg;
  
  pr        : pProcess;
begin
  cmdport := nil;
  initmsg := AllocVec(sizeof(tservermsg), MEMF_CLEAR or MEMF_PUBLIC);

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
      initmsg^.data.init.txt := txt;
      PutMsg(@pr^.pr_MsgPort, @initmsg^.msg);
      WaitPort(replyport);
      GetMsg(replyport);
      cmdport := initmsg^.data.init.cmdport;

      if not assigned(cmdport)
      then WriteLn('failed to start server; error text: ', initmsg^.data.init.txt);

    end;
  end;

  result := (cmdport);
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function  send_background_cmd(replyport: pMsgPort; cmdport: pMsgPort; const txt: PChar): Boolean;
var
  cmdmsg    : pservermsg;
  success   : Boolean;
begin
  success := FALSE;

  if SetAndTest(cmdmsg, AllocVec(sizeof(tservermsg), MEMF_CLEAR or MEMF_PUBLIC)) then
  begin
    cmdmsg^.msg.mn_ReplyPort := replyport;
    cmdmsg^.data.cmd.command := txt;

    PutMsg(cmdport, @cmdmsg^.msg);

    success := TRUE;
  end;

  result := (success);
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function  get_background_response(replyport: pMsgPort): PChar;
var
  cmdmsg    : pservermsg;
  res       : PChar;
begin
  res := nil;

  if SetAndTest(cmdmsg, pservermsg(GetMsg(replyport))) then
  begin
    res := cmdmsg^.data.cmd.res;
    FreeVec(cmdmsg);
  end;

  Result := (res);
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: Integer;
const
  commands      : array[0..9] of PChar = ('one','two','three','four','five','six','seven','eight','nine','ten');  
var
  replyport     : pMsgPort;
  serverport    : pMsgPort;
  cont          : Boolean;
  res           : PChar;
  i             : Integer;
begin
  replyport := CreateMsgPort(); //* this port receives a message when the background task ends */
  if assigned(replyport) then
  begin
    serverport := start_background_task(replyport, 'test data');
    if assigned(serverport) then
    begin
      WriteLn('Background task started; waiting for completion.');
      WriteLn('Press Ctrl-C to cancel processing.');

      for i := 0 to Pred(10) do
      begin
        if (send_background_cmd(replyport, serverport, commands[i])) then
        begin
          WriteLn('send command: ', commands[i]);
          WaitPort(replyport);
          res := get_background_response(replyport);
          WriteLn('response: ', res);
        end
        else
          WriteLn('failed to send command: ', commands[i]);

        if ((SetSignal(0,0) and SIGBREAKF_CTRL_C) <> 0) then
        begin
          WriteLn('*** Break');
          break;
        end;
      end;

      send_background_cmd(replyport, serverport, 'QUIT');
      WriteLn('sent quit command');
      WaitPort(replyport);
      res := get_background_response(replyport);
      WriteLn('response: ', res);
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
