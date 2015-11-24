program WaitForClick;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


{
  ===========================================================================
  Project : WaitForClick
  Topic   : Wait for a mouse click, without the need for an intuition-window
  Author  : Thomas Rapp
  Source  : http://thomas-rapp.homepage.t-online.de/examples/WaitForClick.c
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
  Exec, AmigaDOS, Input, InputEvent,
  Trinity,
  CHelpers;



Const
  NT_EXTINTERRUPT   = NT_INTERRUPT;
  MEMF_SHARED       = MEMF_PUBLIC;



{$ifdef MorphOS}
procedure IOARG(var event; var port); assembler;
asm
  lwz r6,32(r2) // REG_a0
  stw r6,(r3)   // event
  lwz r6,36(r2) // REG_a1
  stw r6,(r4)   // port
end;

function  handlerproc: PInputEvent; {$ifdef AROS}cdecl;{$endif}
var
  ieList: PInputEvent;
  port: PMsgPort;
  ie, prev: pInputEvent;
begin
  IOARG(ieList, port);
{$else}
function  handlerproc(ieList: PInputEvent; port: PMsgPort): PInputEvent; {$ifdef AROS}cdecl;{$endif}
var
  ie, prev: pInputEvent;
begin
{$endif}
  ie := ielist;
  prev := nil;

  repeat
    if (ie^.ie_Class = IECLASS_RAWMOUSE) and (ie^.ie_Code = IECODE_LBUTTON) then
    begin
      if assigned(prev)
      then prev^.ie_NextEvent := ie^.ie_NextEvent
      else ielist := ie^.ie_NextEvent;
      Signal (port^.mp_SigTask, 1 shl port^.mp_SigBit);
    end
  else
      prev := ie;
    ie := ie^.ie_NextEvent;
  until not assigned(ie);

  result := (ielist);
end;

{$ifdef MorphOS}
const
  ENTRY_TRAP: TEmulLibEntry = ( Trap: TRAP_LIB; Extension: 0; Func: @handlerproc);
{$endif}


//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  rc        : integer    = RETURN_FAIL;
  port      : PMsgPort   = nil;
  handler   : PInterrupt = nil;
  req       : PIOStdReq  = nil;
  dev_open  : boolean    = FALSE;
var
  sigs      : ULONG;
begin
  If SetAndTest(port, CreateMsgPort) then
    if SetAndTest(handler, AllocVec(sizeof(TInterrupt), MEMF_SHARED or MEMF_CLEAR)) then
      if SetAndTest(req, PIOStdReq(CreateIORequest(port, sizeof(TIOStdReq)))) then
        if not(OpenDevice('input.device', 0, PIORequest(req),0) <> 0)
          then dev_open := TRUE;

  if not(dev_open)
  then WriteLn('could not open input.device')
  else
  begin
    {$ifdef MorphOS}
    handler^.is_Code := APTR(@ENTRY_TRAP);
    {$else}
    handler^.is_Code := APTR(@handlerproc);
    {$endif}
    handler^.is_Data := APTR(port);
    handler^.is_Node.ln_Type := NT_EXTINTERRUPT;
    handler^.is_Node.ln_Pri  := 60; //* above intuition's handler */
    req^.io_Data := APTR(handler);
    req^.io_Command := IND_ADDHANDLER;
    DoIO ( PIORequest(req) );

   {*
     "port" is not used by the device at this time so we can "mis-use" it as
     signal for the mouse click. The MsgPort structure comes handy because it
     already has the task pointer and signal number filled in.
     If we could not use the port, we would have to allocate a second signal
     and put the signal number and a pointer to the main task into is_Data so
     that the handler can use them to signal us.
   *}

    SetSignal(0, 1 shl port^.mp_SigBit); //* clear port's signal in case DoIO didn't do that */

  sigs := Wait ( (1 shl port^.mp_SigBit) or SIGBREAKF_CTRL_C);

    rc := RETURN_OK;

    if ((sigs and SIGBREAKF_CTRL_C) <> 0) then
    begin
      WriteLn('*** Break');
      rc := RETURN_WARN;
    end;

    req^.io_Data  := APTR(handler);
    req^.io_Command := IND_REMHANDLER;
    DoIO( PIORequest(req));
  end;


  if (dev_open)       then CloseDevice( PIORequest(req) );
  if (req     <> nil) then DeleteIORequest( PIORequest(req) );
  if (handler <> nil) then FreeVec(handler);
  if (port    <> nil) then DeleteMsgPort(port);

  result := RC;
end;


//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/



Function OpenLibs: boolean;
begin
  Result := False;

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
