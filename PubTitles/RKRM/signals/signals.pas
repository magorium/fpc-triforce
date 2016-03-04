program signals;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : signals
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

Uses
  Exec, AmigaDOS, AmigaLib;


const
  VersTag       : PChar = '$VER: signals 37.1 (28.3.91)';

var
  mainsignum    : LONG  = -1;
  mainsig, 
  wakeupsigs    : ULONG;
  maintask      : PTask = nil;
  subtask       : PTask = nil;
  subtaskname   : PChar = 'RKM_signal_subtask';


  procedure subtaskcode; forward;   //* prototype for our subtask routine */


Procedure Main(argc: Integer; argv: PPChar);
var
  Done              : boolean = false;
  WaitingForSubtask : boolean = true;
begin
  //* We must allocate any special signals we want to receive. */
  mainsignum := AllocSignal(-1);
  if (mainsignum = -1)
  then WriteLn('No signals available')
  else
  begin
    mainsig  := 1 shl mainsignum;   //* subtask can access this global */
    maintask := FindTask(nil);      //* subtask can access this global */

    WriteLn('We alloc a signal, create a task, wait for signals');
    subtask := CreateTask(subtaskname, 0, @subtaskcode, 2000);
    if not assigned(subtask)
    then WriteLn('Can''t create subtask')
    else
    begin
      WriteLn('After subtask signals, press CTRL-C or CTRL-D to exit');

      while( not(Done) or (WaitingForSubtask)) do
      begin
        {* Wait on the combined mask for all of the signals we are
         * interested in.  All processes have the CTRL_C thru CTRL_F
         * signals.  We're also Waiting on the mainsig we allocated
         * for our subtask to signal us with.  We could also Wait on
         * the signals of any ports/windows our main task created ... 
         *}

        wakeupsigs := Wait(mainsig or SIGBREAKF_CTRL_C or SIGBREAKF_CTRL_D);

        //* Deal with all signals that woke us up - may be more than one */
        if ((wakeupsigs <> 0) and (mainsig <> 0)) then
        begin
          WriteLn('Signalled by subtask');
          WaitingForSubtask := false;   //* OK to kill subtask now */
        end;

        if (wakeupsigs and SIGBREAKF_CTRL_C <> 0) then
        begin
          WriteLn('Got CTRL-C signal');
          Done := TRUE;
        end;
        if (wakeupsigs and SIGBREAKF_CTRL_D <> 0) then
        begin
          WriteLn('Got CTRL-D signal');
          Done := TRUE;
        end;
      end;
      Forbid();
      DeleteTask(subtask);
      Permit();
    end;
    FreeSignal(mainsignum);
  end;
end;



procedure subtaskcode;
begin
  Signal(maintask, mainsig);
  Wait(0);      //* safe state in which this subtask can be deleted */
end;


begin
  Main(ArgC, ArgV);
end.
