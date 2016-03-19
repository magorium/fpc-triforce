program tasklist;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : tasklist
  Source    : Snapshots and prints the ExecBase task list
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec,
  SysUtils,
  CHelpers,
  Trinity;


const
  VersTag   : pChar = '$VER: tasklist 37.2 (31.3.92)';

var
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  SysBase   : PExecBase absolute AOS_ExecBase;
  {$ENDIF}
  {$IFDEF MORPHOS}
  SysBase   : PExecBase absolute MOS_ExecBase;
  {$ENDIF}

type
  //* Use extended structure to hold task information */
  PTaskNode = ^TTaskNode;
  TTaskNode = record
    tn_Node         : TNode;
    tn_TaskAddress  : ULONG;
    tn_SigAlloc     : ULONG;
    tn_SigWait      : ULONG;
    tn_Name         : Array[0..32-1] of Char;
  end;



procedure Main(argc: integer; argv: PPChar);
var
  ourtasklist   : PList;
  exectasklist  : PList;
  task          : PTask;
  anode         : PTaskNode = nil;
  atnode        : PTaskNode = nil;
  arnode        : PTaskNode = nil;
  execnode      : PNode;
begin
  //* Allocate memory for our list */
  if SetAndTest(ourtasklist, ExecAllocMem(sizeof(TList), MEMF_CLEAR)) then
  begin
    //* Initialize list structure (ala NewList()) */
    ourtasklist^.lh_Head := PNode(@ourtasklist^.lh_Tail);
    ourtasklist^.lh_Tail := nil;
    ourtasklist^.lh_TailPred := PNode(@ourtasklist^.lh_Head);

    //* Make sure tasks won't switch lists or go away */
    Disable();

    //* Snapshot task WAIT list */
    exectasklist := @(SysBase^.TaskWait);

    execnode := exectasklist^.lh_Head;
    while Assigned(execnode^.ln_Succ) do
    begin
      if SetAndTest(atnode, ExecAllocMem(sizeof(TTaskNode), MEMF_CLEAR)) then
      begin
        //* Save task information we want to print */
        strlcopy(atnode^.tn_Name, execnode^.ln_Name, 32);
        atnode^.tn_Node.ln_Pri := execnode^.ln_Pri;
        atnode^.tn_TaskAddress := ULONG(execnode);
        atnode^.tn_SigAlloc := PTask(execnode)^.tc_SigAlloc;
        atnode^.tn_SigWait := PTask(execnode)^.tc_SigWait;
        AddTail(ourtasklist, PNode(atnode));
      end
      else break;

      execnode := execnode^.ln_Succ;
    end;
    
    //* Snapshot task READY list */
    exectasklist := @(SysBase^.TaskReady);

    execnode := exectasklist^.lh_Head;
    while Assigned(execnode^.ln_Succ) do
    begin
      if SetAndTest(atnode, ExecAllocMem(sizeof(TTaskNode), MEMF_CLEAR)) then
      begin
        //* Save task information we want to print */
        strlcopy(atnode^.tn_Name, execnode^.ln_Name, 32);
        atnode^.tn_Node.ln_Pri := execnode^.ln_Pri;
        atnode^.tn_TaskAddress := ULONG(execnode);
        atnode^.tn_SigAlloc := PTask(execnode)^.tc_SigAlloc;
        atnode^.tn_SigWait := PTask(execnode)^.tc_SigWait;
        AddTail(ourtasklist, PNode(atnode));
        if not assigned(arnode) then arnode := atnode;  //* first READY task */
      end
      else break;

      execnode := execnode^.ln_Succ;
    end;

    //* Re-enable interrupts and taskswitching */
    Enable();

    //* Print now (printing above would have defeated a Forbid or Disable) */
    WriteLn('Pri Address     SigAlloc    SigWait    Taskname');

    anode := PTaskNode(ourtasklist^.lh_Head);
    WriteLn(LineEnding, 'WAITING:');

    while SetAndTest(atnode, PTaskNode(anode^.tn_Node.ln_Succ)) do
    begin
      if (atnode = arnode)
      then WriteLn(LineEnding, 'READY:');  //* we set rnode above */

      Writeln(Format('%.2d  0x%.8x  0x%.8x  0x%.8x %s',
      [
        anode^.tn_Node.ln_Pri, 
        anode^.tn_TaskAddress, 
        anode^.tn_SigAlloc,
        anode^.tn_SigWait, 
        anode^.tn_Name
      ]));

      //* Free the memory, no need to remove the node, referenced once only */
      ExecFreeMem(anode, sizeof(TTaskNode));
      anode := atnode;
    end;
    ExecFreeMem(ourtasklist, sizeof(TList));

    //* Say who we are */
    WriteLn(LineEnding, 'THIS TASK:');
    task := FindTask(nil);

    Writeln(Format('%.2d  0x%.8x  0x%.8x  0x%.8x %s',
    [
      task^.tc_Node.ln_Pri, 
      ULONG(task),
      task^.tc_SigAlloc,
      task^.tc_SigWait, 
      task^.tc_Node.ln_Name
    ]));
  end;
end;


begin
  Main(ArgC, ArgV);
end.
