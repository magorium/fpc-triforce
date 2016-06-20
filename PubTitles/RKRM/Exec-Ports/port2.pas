program port2;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : port2
  Topic     : port and message example, run at the same time as port1
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec,
  {$IFDEF AMIGA}
  AmigaLib,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;


type
  PXYMessage = ^TXYMessage;
  TXYMessage = record
    xy_Msg  : TMessage;
    xy_X    : SmallInt;
    xy_Y    : SmallInt;
  end;


  Function  SafePutToPort(msg: PMessage; portname: STRPTR): Boolean; forward;


Procedure Main(argc: Integer; argv: PPChar);
var
  xyreplyport   : PMsgPort;
  xymsg, reply  : PXYMessage;

begin
  //* Using CreatePort() with no name because this port need not be public. */
  if SetAndTest(xyreplyport, CreatePort(nil, 0)) then
  begin
    if SetAndTest(xymsg, PXYMessage(ExecAllocMem(sizeof(TXYMessage), MEMF_PUBLIC or MEMF_CLEAR))) then
    begin
      xymsg^.xy_Msg.mn_Node.ln_Type := NT_MESSAGE;          //* make up a message,        */
      xymsg^.xy_Msg.mn_Length := sizeof(TXYMessage);        //* including the reply port. */
      xymsg^.xy_Msg.mn_ReplyPort := xyreplyport;
      xymsg^.xy_X := 10;                                    //* our special message information. */
      xymsg^.xy_Y := 20;

      WriteLn(Format('Sending to port1: x = %d y = %d', [xymsg^.xy_X, xymsg^.xy_Y]));

      //* port2 will simply try to put one message to port1 wait for the reply, and then exit
      if (SafePutToPort(PMessage(xymsg), 'xyport')) then    //* one message to port1 wait for */
      begin
        WaitPort(xyreplyport);
        if SetAndTest(reply, PXYMessage(GetMsg(xyreplyport)))
        //* We don't ReplyMsg since WE initiated the message. */
        then WriteLn(Format('Reply contains: x = %d y = %d', [xymsg^.xy_X, xymsg^.xy_Y]));

        //* Since we only use this private port for receiving replies, and we sent     */
        //* only one and got one reply there is no need to cleanup. For a public port, */
        //* or if you pass a pointer to the port to another process, it is a very good */
        //* habit to always handle all messages at the port before you delete it.      */
      end
      else WriteLn('Can''t find "xyport"; start port1 in a separate shell');
      ExecFreeMem(xymsg, sizeof(TXYMessage));
    end
    else WriteLn('Couldn''t get memory');
    DeletePort(xyreplyport);
  end
  else WriteLn('Couldn''t create xyreplyport');
end;


Function  SafePutToPort(msg: PMessage; portname: STRPTR): Boolean;
var
  port  : PMsgPort;
begin
  Forbid();
  port := FindPort(portname);
  if (port <> nil) then PutMsg(port, msg);
  Permit();
  if assigned(port)     //* FALSE if the port was not found */
  then result := True
  else result := false;
  //* Once we've done a Permit(), the port might go away and leave us with an invalid port    */
  //* address. So we return just a BOOL to indicate whether the message has been sent or not. */
end;


begin
  Main(ArgC, ArgV);
end.
