program helloworld;

{$MODE OBJFPC}{$H+}{$HINTS ON}

{
  ===========================================================================
  Project : helloworld
  Topic   : Prints some text to standard output
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/helloworld.c
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



function  main: Integer;
begin
  WriteLn('Hello World');
  Result := 0;
end;



begin
  ExitCode := main;
end.
