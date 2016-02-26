program RestoreShell;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : RestoreShell
  Source    : RKRM
}
 {*
   restore the BootShell as the UserShell.  Note that this
   only switches back the BootShell, it does not unload the
   current user shell ("shell" on the resident list) as it
   is possible that some instance of it can still be running.
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}


Uses
  Exec, AmigaDOS;


const
  vers  : PChar = #0'$VER: RestoreShell 1.0';


procedure Main;
var
  bootshell_seg,
  shell_seg     : PSegment;

begin
  Forbid;
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  shell_seg := FindSegment('shell', nil, CMD_SYSTEM);
  bootshell_seg := FindSegment('bootshell', nil, CMD_SYSTEM);
  {$ENDIF}
  {$IFDEF AROS}
  shell_seg := FindSegment('shell', nil, LongBool(CMD_SYSTEM));
  bootshell_seg := FindSegment('CLI', nil, LongBool(CMD_SYSTEM));
  {$ENDIF}
  if assigned(bootshell_seg)
  then shell_seg^.seg_Seg := bootshell_seg^.seg_Seg;
  Permit;
end;


begin
  {$IFDEF AROS}
  WriteLn('INFO: This example does not work for the AROS platform.');
  WriteLn;
  WriteLn('Reason is that AROS does not have a bootshell');
  WriteLn;
  Writeln('< Press enter to continue >');
  ReadLn;
  {$ENDIF}
  Main;
end.
