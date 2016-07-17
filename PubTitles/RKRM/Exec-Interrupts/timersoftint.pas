program timersoftint;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}
{$IFDEF MORPHOS}
{$FATAL Unfortunately this source does not compile for MorphOS (yet)}
{$ENDIF}

{
  Project   : timersoftint
  Title     : Timer device software interrupt message port example.
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

Uses
  Exec, Timer, AmigaDOS, AmigaLib,
  CHelpers,
  Trinity,
  SysUtils;


const
  MICRO_DELAY = 1000;
  FLAG_OFF    = 0;
  FLAG_ON     = 1;
  STOPPED     = 2;

type
  PTSIData = ^TTSIData;
  TTSIData = record
    tsi_Counter : ULONG;
    tsi_Flag    : ULONG;
    tsi_Port    : PMsgPort;
  end;

var
  tsidata : PTSIData;


  procedure tsoftcode; forward; //* Prototype for our software interrupt code */



procedure Main;
var
  port      : PMsgPort;
  softint   : PInterrupt;
  tr        : Ptimerequest;

  endcount  : ULONG;
begin
  //* Allocate message port, data & interrupt structures. Don't use CreatePort() */
  //* or CreateMsgPort() since they allocate a signal (don't need that) for a    */
  //* PA_SIGNAL type port. We need PA_SOFTINT.                                   */
  if SetAndTest(tsidata, ExecAllocMem(sizeof(TTSIData), MEMF_PUBLIC or MEMF_CLEAR)) then
  begin
    if SetAndTest(port, ExecAllocMem(sizeof(TMsgPort), MEMF_PUBLIC or MEMF_CLEAR)) then
    begin
      NewList(@(port^.mp_MsgList));             //* Initialize message list */
      if SetAndTest(softint, ExecAllocMem(sizeof(TInterrupt), MEMF_PUBLIC or MEMF_CLEAR)) then
      begin
        //* Set up the (software)interrupt structure. Note that this task runs at  */
        //* priority 0. Software interrupts may only be priority -32, -16, 0, +16, */
        //* +32. Also not that the correct node type for a software interrupt is   */
        //* NT_INTERRUPT. (NT_SOFTINT is an internal Exec flag). This is the same  */
        //* setup as that for a software interrupt which you Cause(). If our       */
        //* interrupt code was in assembler, you could initialize is_Data here to  */
        //* contain a pointer to shared data structures. An assembler software     */
        //* interrupt routine would receive the is_Data in A1.                     */

        softint^.is_Code := @tsoftcode;    //* The software interrupt routine */
        softint^.is_Data := tsidata;
        softint^.is_Node.ln_Pri := 0;

        port^.mp_Node.ln_Type := NT_MSGPORT;    //* Set up the PA_SOFTINT message port  */
        port^.mp_Flags := PA_SOFTINT;           //* (no need to make this port public). */
        port^.mp_SigTask := PTask(softint);     //* pointer to interrupt structure */

        //* Allocate timerequest */
        if SetAndTest(tr, Ptimerequest(CreateExtIO(port, sizeof(Ttimerequest)))) then
        begin
          //* Open timer.device. NULL is success. */
          if (not( OpenDevice('timer.device', UNIT_MICROHZ, PIORequest(tr), 0) <> 0)) then
          begin
            tsidata^.tsi_Flag := FLAG_ON;   //* Init data structure to share globally. */
            tsidata^.tsi_Port := port;

            //* Send of the first timerequest to start. IMPORTANT: Do NOT   */
            //* BeginIO() to any device other than audio or timer from      */
            //* within a software or hardware interrupt. The BeginIO() code */
            //* may allocate memory, wait or perform other functions which  */
            //* are illegal or dangerous during interrupts.                 */
            WriteLn('starting softint. CTRL-C to break...');


            tr^.tr_node.io_Command := TR_ADDREQUEST;    //* Initial iorequest to start */
            tr^.tr_time.tv_micro := MICRO_DELAY;        //* software interrupt.        */
            BeginIO(PIORequest(tr));

            Wait(SIGBREAKF_CTRL_C);
            endcount := tsidata^.tsi_Counter;
            WriteLn(Format('timer softint counted %d milliseconds.', [endcount]));

            WriteLn('Stopping timer...');
            tsidata^.tsi_Flag := FLAG_OFF;

            while (tsidata^.tsi_Flag <> STOPPED) do DOSDelay(10);

            CloseDevice(PIORequest(tr));
          end
          else WriteLn('couldn''t open timer.device');
          DeleteExtIO(PIORequest(tr));
        end
        else WriteLn('couldn''t create timerequest');
        ExecFreeMem(softint, sizeof(TInterrupt));
      end;
      ExecFreeMem(port, sizeof(TMsgPort));
    end;
    ExecFreeMem(tsidata, sizeof(TTSIData));
  end;
end;


procedure tsoftcode;
var
  tr    : Ptimerequest;
begin
  //* Remove the message from the port. */
  tr := Ptimerequest(GetMsg(tsidata^.tsi_Port));

  //* Keep on going if main() hasn't set flag to OFF. */
  if (Assigned(tr) and (tsidata^.tsi_Flag = FLAG_ON)) then
  begin
    //* increment counter and re-send timerequest--IMPORTANT: This         */
    //* self-perpetuating technique of calling BeginIO() during a software */
    //* interrupt may only be used with the audio and timer device.        */
    inc(tsidata^.tsi_Counter);
    tr^.tr_node.io_Command := TR_ADDREQUEST;
    tr^.tr_time.tv_micro := MICRO_DELAY;
    BeginIO(PIORequest(tr));
  end
  //* Tell main() we're out of here. */
  else tsidata^.tsi_Flag := STOPPED;
end;


begin
  Main;
end.
