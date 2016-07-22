Program Multiple_Timers;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : Multiple_Timers
  Source    : RKRM
}
{
 *****************************************************************************
 *
 *  Multiple_Timers.c
 *
 *  This program is designed to do multiple (3) time requests using one
 *  OpenDevice.  It creates a message port - TimerMP, creates an
 *  extended I/O structure of type timerequest named TimerIO[0] and
 *  then uses that to open the device.  The other two time request
 *  structures - TimerIO[1] and TimerIO[2] - are created using AllocMem
 *  and then copying TimerIO[0] into them.  The tv_secs field of each
 *  structure is set and then three SendIOs are done with the requests.
 *  The program then goes into a while loop until all messages are received.
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
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
  Trinity;


procedure Main;
var
  TimerIO       : array[0..pred(3)] of ptimerequest;
  TimerMP       : pMsgPort;
  TimerMSG      : pMessage;

  error         : ULONG;
  seconds       : Array[0..pred(3)] of ULONG = (4,1,2);
  microseconds  : Array[0..pred(3)] of ULONG = (0,0,0);
  
  allin         : Integer;
  position      : array[0..2] of PChar = ('last','second','first');

  x             : Integer;
begin
  allin := 3;  

  TimerMP := CreatePort(Nil,0);
  if (TimerMP <> nil) then
  begin
    TimerIO[0] := ptimerequest(CreateExtIO(TimerMP, sizeof(ttimerequest)));
    If (TimerIO[0] <> nil) then
    begin  
      //* Open the device once */
      error := OpenDevice(TIMERNAME,UNIT_VBLANK, pIORequest(TimerIO[0]), 0);
      if not(error <> 0) then
      begin
        //* Set command to TR_ADDREQUEST */
        TimerIO[0]^.tr_node.io_Command := TR_ADDREQUEST;

        TimerIO[1] := ptimerequest(ExecAllocMem(sizeof(ttimerequest), MEMF_PUBLIC or MEMF_CLEAR));
        if (TimerIO[1] <> nil) then
        begin
          TimerIO[2] := ptimerequest(ExecAllocMem(sizeof(ttimerequest), MEMF_PUBLIC or MEMF_CLEAR));
          if (TimerIO[2] <> nil) then
          begin
            //* Copy fields from the request used to open the timer device */
            TimerIO[1]^ := TimerIO[0]^;
            TimerIO[2]^ := TimerIO[0]^;

            //* Initialize other fields */
            for x := 0 to pred(3) do
            begin
              TimerIO[x]^.tr_time.tv_secs   := seconds[x];
              TimerIO[x]^.tr_time.tv_micro  := microseconds[x];
              WriteLn(LineEnding, 'Initializing TimerIO[', x, ']');
            end;

            WriteLn(LineEnding, LineEnding, 'Sending multiple requests', LineEnding);

            //* Send multiple requests asynchronously */
            //* Do not got to sleep yet...            */
            SendIO(pIORequest(TimerIO[0]));
            SendIO(pIORequest(TimerIO[1]));
            SendIO(pIORequest(TimerIO[2]));

            //* There might be other processing done here */

            //* Now go to sleep with WaitPort() waiting for the requests */
            while (allin <> 0) do
            begin
              WaitPort(TimerMP);
              //* Get the reply message */
              TimerMSG := GetMsg(TimerMP);
              for x := 0 to pred(3) do 
              begin
                if (TimerMSG = pMessage(TimerIO[x])) then
                begin
                  dec(allin);
                  WriteLn('Request ', x, ' finished ', position[allin]);
                end;
              end;
            end;
            ExecFreeMem(TimerIO[2], sizeof(ttimerequest));
          end
          else
            WriteLn('Error: could not allocate TimerIO[2] memory');
        
          ExecFreeMem(TimerIO[1], sizeof(ttimerequest));
        end
        else
          WriteLn('Error could not allocate TimerIO[1] memory');

        CloseDevice(pIORequest(TimerIO[0]));
      end
      else
        WriteLn(LineEnding, 'Error: Could not OpenDevice');

      DeleteExtIO(pIORequest(TimerIO[0]));
    end
    else
      WriteLn('Error: could not create IORequest');

    DeletePort(TimerMP);
  end
  else
    WriteLn(LineEnding, 'Error: Could not CreatePort');
end;


begin
  WriteLn('enter');

  Main;  
  
  WriteLn('leave');
end.
