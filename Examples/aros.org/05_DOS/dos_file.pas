program dos_file;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : dos_file
  Topic   : Reads a file and writes content to another file
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/dos_file.c
  ===========================================================================

  This example was originally written in c by The AROS Development Team.

  The original examples are available online and published at the AROS
  website (http://www.aros.org/documentation/developers/samples.php)

  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc

  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Conversion from c to Free Pascal was done by Magorium in 2015.

  ===========================================================================

           Unless otherwise noted, these examples must be considered
                 copyrighted by their respective owner(s)

  ===========================================================================
}

{*
    DOS read/write example
*}



Uses
  Exec, AmigaDOS,
  {$IFDEF AMIGA}
  trinity,
  {$ENDIF}
  chelpers;


Var
  buffer    : packed array[0..100-1] of Char;

function  main: integer;
var
  infile    : BPTR = Default(Bptr);
  outfile   : BPTR = Default(bptr);
label
  cleanup;
begin
  if not( SetAndTest (infile, DOSOpen('s:startup-sequence', MODE_OLDFILE))) then
  begin
    goto cleanup;
  end;
    
  if not( SetAndTest (outfile, DOSOpen('ram:startup-copy', MODE_NEWFILE))) then
  begin
    goto cleanup;
  end;

  while (FGets(infile, buffer, sizeof(buffer)) <> nil) do
  begin
    if (FPuts(outfile, @buffer[0]) <> 0) then // FPuts returns 0 on error
    begin
      writeln('FPuts() returned a non zero value');
      goto cleanup;
    end
    else writeln('FPuts() returned zero');
  end;
    
cleanup:
  {*
      Some may argue that "goto" is bad programming style,
      but for function cleanup it still makes sense.
  *}
  PrintFault(IoErr(), 'Error'); // Does nothing when error code is 0
  if ( infile <> default(BPTR)) then DOSClose(infile);
  if (outfile <> default(BPTR)) then DOSClose(outfile);
   
  result := 0;
end;



begin
  ExitCode := Main();
end.
