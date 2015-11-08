program notify;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : notify
  Topic   : Example for file-Notification
  Author  : Thomas Rapp
  Source  : http://thomas-rapp.homepage.t-online.de/examples/notify.c
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
  Exec, AmigaDOS;


Const
  FILENAME  =   'ram:prefs';
  

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  nreq      : PNotifyRequest;
  signal    : LongInt;
begin
  nreq := AllocVec(sizeof(TNotifyRequest), MEMF_CLEAR or MEMF_PUBLIC);
  if (nreq <> nil) then
  begin
    signal := AllocSignal(-1);
    if (signal <> -1) then
    begin
      nreq^.nr_Name  := FILENAME;
      nreq^.nr_Flags := NRF_SEND_SIGNAL;
      nreq^.nr_stuff.nr_Signal.nr_Task := FindTask(nil);
      nreq^.nr_stuff.nr_Signal.nr_SignalNum := signal;

      if (StartNotify(nreq)) then
      begin
        while not (0 <> (Wait ((1 shl signal) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C)) do
        begin
          WriteLn(FILENAME + ' has been changed');
        end;

        EndNotify(nreq);
      end;

      FreeSignal(signal);
    end;

    FreeVec(nreq);
  end;

  Result := (0);
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
