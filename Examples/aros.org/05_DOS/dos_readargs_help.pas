program dos_readargs_help;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : dos_readargs_help
  Topic   : ReadArgs() with help text
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/dos_readargs_help.c
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
    Example for ReadArgs() command line parsing
    with help text
*}



Uses
  Exec, AmigaDOS, Intuition,
  trinity;



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
Type
  IPTR  = NativeUInt;
{$ENDIF}



{*
    For this example we're using only a simple template.
    See dos_readargs.c for detailled example for a template.
*}
const
  ARG_TEMPLATE          : PChar = 'STRING';


type
  targsenum     =
  (
    ARG_STRING = 0,
    ARG_COUNT
  );


Var
  rda                   : pRDArgs;
  started_from_wanderer : Boolean;



  procedure clean_exit(const s: STRPTR); forward;



function  main(argc: integer; argv: ppchar): integer;
Var
  args: array[targsenum] of IPTR;
  
begin
  {$IFDEF MORPHOS}
  if (argc <> 0) then
  {$ELSE}  
  if (AOS_WBMsg = nil) then
  {$ENDIF}
  begin
    FillByte(args, SizeOf(Args), 0);
        
    rda := pRDArgs(AllocDosObject(DOS_RDARGS, nil));
    if not assigned(rda) then
    begin
      clean_exit('Can''t allocate RDArgs');
    end;

    rda^.RDA_ExtHelp :=
        'This text will be printed if the user calls this' + LineEnding +
        'command with a question mark as argument and types' + LineEnding +
        'again a question mark when the command requests' + LineEnding +
        'the arguments.' + LineEnding;

    if not assigned(ReadArgs(ARG_TEMPLATE, @args, rda)) then
    begin
       PrintFault(IoErr(), argv[0]);
       clean_exit('ReadArgs() failed.');
    end;

    if (args[ARG_STRING] <> 0) then
    begin
      WriteLn('Argument "STRING" ', STRPTR(args[ARG_STRING]));
    end;
  end
  else
  begin
    started_from_wanderer := TRUE;
    clean_exit('Application must be started from Shell.');
  end;

  clean_exit(nil);

  result := 0;
end;



procedure clean_exit(const s: STRPTR);
var
  es : TEasyStruct;
begin
  if assigned(s) then
  begin
    if (started_from_wanderer) then
    begin
      {* 
          We use an EasyRequest because applications started
          from Wanderer don't have an output console by default.
      *}
      es.es_StructSize  := sizeof(TEasyStruct);
      es.es_Flags       := 0;
      es.es_Title       := 'Error';
      es.es_TextFormat  := s;
      es.es_GadgetFormat:= 'OK';

      EasyRequest(nil, @es, nil);
    end
    else
    begin
      WriteLn(s);
    end;
  end;
    
  // Give back allocated resourses
  if assigned(rda) then
  begin
    FreeArgs(rda);
    FreeDOSObject(DOS_RDARGS, rda);
  end;
    
  halt(0);
end;


{
  ===========================================================================
  Some additional code is required in order to open and close libraries in a 
  cross-platform uniform way.
  Since AROS units automatically opens and closes libraries, this code is 
  only actively used when compiling for Amiga and/or MorphOS.
  ===========================================================================
}



Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS)}
  IntuitionBase := OpenLibrary(INTUITIONNAME, 0);
  if not assigned(IntuitionBase) then Exit;
  {$ENDIF}

  Result := True;
end;



Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS)}
  if assigned(IntuitionBase) then CloseLibrary(pLibrary(IntuitionBase));
  {$ENDIF}
end;



begin
  if OpenLibs
  then ExitCode := Main(Argc, Argv)
  else ExitCode := 10;

  CloseLibs;
end.
