program Get_Systime;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : Get_Systime
  Source    : RKRM
}

{
 *****************************************************************************
 *
 * Get_Systime.c
 *
 * Get system time example
 *
 * Compile with SAS C 5.10: LC -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */
}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/Trinity}

Uses
  Exec,
  Timer,
  {$IFDEF AMIGA}
  AmigaLib,
  {$ENDIF}
  SysUtils
  {$IFNDEF AMIGA}
  ,Trinity
  {$ENDIF}
  ;


Var
  TimerIO  : ptimerequest;
  TimerMP  : pMsgPort;
  TimerMSG : pMessage;


procedure Main;
var
  error: LONG;
  days, hrs, secs, mins, mics: ULONG;
begin
  TimerMP := CreatePort(nil,0);
  if (TimerMP <> nil) then
  begin
    TimerIO := ptimerequest(CreateExtIO(TimerMP, sizeof(ttimerequest)));
    If (TimerIO <> nil) then
    begin
      //* Open with UNIT_VBLANK, but any unit can be used */
      error := OpenDevice(TIMERNAME,UNIT_VBLANK, pIORequest(TimerIO), 0);
      if not(error <> 0) then
      begin
        //* Issue the command and wait for it to finish, then get the reply */
        TimerIO^.tr_node.io_Command := TR_GETSYSTIME;
        DoIO(pIORequest(TimerIO));

        //* Get the results and close the timer device */
        mics := TimerIO^.tr_time.tv_micro;
        secs := TimerIO^.tr_time.tv_secs;

        //* Compute days, hours, etc. */
        mins := secs div 60;
        hrs  := mins div 60;
        days := hrs  div 24;
        secs := secs mod 60;
        mins := mins mod 60;
        hrs  := hrs  mod 24;

        //* Display the time */
        WriteLn;
        WriteLn('System Time (measured from Jan.1,1978)');
        WriteLn('  Days   Hours  Minutes Seconds Microseconds');
        WriteLn(Format('%6d %6d %6d %6d %10d', [days,hrs,mins,secs,mics]));

        //* Close the timer device */
        CloseDevice(pIORequest(TimerIO));
      end
      else
        WriteLn(LineEnding, 'Error: Could not open timer device');

      //* Delete the I/O request structure */
      DeleteExtIO(pIORequest(TimerIO));
    end
    else
      WriteLn(LineEnding, 'Error: Could not create I/O structure');

    //* Delete the port */
    DeletePort(TimerMP);
  end
  else
    WriteLn(LineEnding, 'Error: Could not create port');
end;


begin
  WriteLn('enter');

  Main;  
  
  WriteLn('leave');
end.