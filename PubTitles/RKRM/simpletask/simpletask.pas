program simpletask;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : simpletask
  Source    : RKRM
}

 {
  Uses the amiga.lib function CreateTask() to create a simple
  subtask.  See the Includes and Autodocs manual for CreateTask() source code
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

Uses
  Exec, AmigaDOS, AmigaLib, SysUtils;


const
  STACK_SIZE        = 1000;
  
var
  //* Task name, pointers for allocated task struct and stack */
  task              : PTask = nil;
  simpletaskname    : PChar = 'SimpleTask';

  sharedvar         : ULONG;


  //* our function prototypes */
  procedure simpletasker; forward;
  procedure cleanexit(s: PChar; e: LONG); forward;
  

Procedure Main(argc: Integer; argv: PPChar);
begin
  sharedvar := 0;

  task := CreateTask(simpletaskname, 0, @simpletasker, STACK_SIZE);
  if not assigned(task) then cleanexit('Can''t create task', RETURN_FAIL);

  WriteLn('This program initialized a variable to zero, then started a');
  WriteLn('separate task which is incrementing that variable right now,');
  WriteLn('while this program waits for you to press RETURN.');
  Write('Press RETURN now: ');
  ReadLn;

  WriteLn(Format('The shared variable now equals %d', [sharedvar]));

  //* We can simply remove the task we added because our simpletask does not make */
  //* any system calls which could cause it to be awakened or signalled later.    */
  Forbid();
  DeleteTask(task);
  Permit();
  cleanexit('', RETURN_OK);
end;


procedure simpletasker;
begin
  while (sharedvar < $8000000) do inc(sharedvar);
  //* Wait forever because main() is going to RemTask() us */
  Wait(0);
end;


procedure cleanexit(s: PChar; e: LONG);
begin
  if (s^ <> #0) then WriteLn(s);
  Halt(e);
end;


begin
  Main(ArgC, ArgV);
end.
