program port1;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : port1
  Topic     : port and message example, run at the same time as port2
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AmigaDOS,
  {$IFDEF AMIGA}
  AmigaLib,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;


type
  PXYMessage = ^TXYMessage;
  TXYMessage = record
    xym_Msg : TMessage;
    xy_X    : SmallInt;
    xy_Y    : SmallInt;
  end;



Procedure Main(argc: Integer; argv: PPChar);
var
  xyport    : PMsgPort;
  xymsg     : PXYMessage;
  portsig, 
  usersig, 
  signal    : ULONG;
  ABORT     : Boolean = FALSE;
begin
  if SetAndTest(xyport, CreatePort('xyport', 0)) then
  begin
    portsig := 1 shl xyport^.mp_SigBit;     //* Give user a `break' signal. */
    usersig := SIGBREAKF_CTRL_C;

    WriteLn('Start port2 in another shell.  CTRL-C here when done.');
    Repeat                                          //* port1 will wait forever and reply   */
      signal := Wait(portsig or usersig);           //* to messages, until the user breaks. */

                                            //* Since we only have one port that might get messages we     */
      if (signal and portsig) <> 0 then     //* have to reply to, it is not really necessary to test for   */
      begin                                 //* the portsignal. If there is not message at the port, xymsg */

        while SetAndTest(xymsg, PXYMessage(GetMsg(xyport))) do   //* simply will be NULL. */
        begin
          WriteLn(Format('port1 received: x = %d y = %d', [xymsg^.xy_X, xymsg^.xy_Y]));

          inc(xymsg^.xy_X, 50);       //* Since we have not replied yet to the owner of    */
          inc(xymsg^.xy_Y, 50);       //* xymsg, we can change the data contents of xymsg. */

          WriteLn(Format('port1 replying with: x = %d y = %d', [xymsg^.xy_X, xymsg^.xy_Y]));
          ReplyMsg(PMessage(xymsg));
        end;
      end;

      if (signal and usersig) <> 0 then             //* The user wants to abort. */
      begin
        while SetAndTest(xymsg, PXYMessage(GetMsg(xyport)))     //* Make sure port is empty. */
        do ReplyMsg(PMessage(xymsg));
        ABORT := TRUE;
      end;
    until (ABORT = FALSE);
    DeletePort(xyport);
  end
  else WriteLn('Couldn''t create "xyport"');
end;


begin
  Main(ArgC, ArgV);
end.
