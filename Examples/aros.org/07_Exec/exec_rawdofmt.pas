program exec_rawdofmt;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : exec_rawdofmt
  Topic   : RawDoFmt allows printf()-like formatting
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/exec_rawdofmt.c
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
    Example for RawDoFmt formatting
*}



Uses
  Exec,
  {$IFDEF AMIGA}
  AmigaLib
  {$ELSE}
  Trinity
  {$ENDIF}
  ;


{$IFDEF AMIGA}
Procedure DO_RAWFMTFUNC_STRING; assembler; nostackframe;
asm
  move.b    d0,(a3)+        ;Put data to output string
  rts
end;

const
  RAWFMTFUNC_STRING : TProcedure = @DO_RAWFMTFUNC_STRING;
{$ENDIF}

{$IF DEFINED(AROS) or DEFINED(MORPHOS)}
Const
  RAWFMTFUNC_STRING = nil;                                  //* Used to act like sprintf */
  RAWFMTFUNC_SERIAL : TProcedure = TProcedure(Pointer(1));  //* Used to act like kprintf */
  RAWFMTFUNC_COUNT  : TProcedure = TProcedure(Pointer(2));  //* Used to count the chars needed */
{$ENDIF}


function  main: Integer;
type
  {*
      RawDoFmt() expects WORD alignment but the C compiler
      aligns to LONG by default. GCC can be forced to use
      WORD alignment by #pragma pack(2)
  *}
  {$PUSH}{$PACKRECORDS 2}
  TData = record
    longval : LONG;
    wordval : SmallInt;
    str     : STRPTR;
  end;
  {$POP}
var
  data          : TData = (longval : 10000000; wordval: 1001; str: 'Hello');
  formatstring  : STRPTR;
  datastream    : APTR;
  //*  Storage place for result. Note that there is no boundary check. */  
  putchdata     : packed array[0..1000-1] of Char;
  
  wordval       : SmallInt;
  longval       : LONG;
begin
  //* Format string with placeholders. */
  formatstring := 'TEST LONG %ld WORD %d STRING %s';

  //* The data which will be inserted in the placeholders. */
  datastream := @data;
    
  RawDoFmt(
        formatstring,       // CONST_STRPTR FormatString
        datastream,         // APTR DataStream
        RAWFMTFUNC_STRING,  // VOID_FUNC PutChProc
        @putchdata          // APTR PutChData
  );
  
  WriteLn(putchdata);


  {*
      The pragma trick doesn't work with variadic functions like
      Printf(), EasyRequest() etc. Here you have to use for integers
      %ld/%lu for the placeholders and the type must be converted
      to LONG/ULONG.
  *}

  wordval := 1000;
  longval := 100000;
    
  Printf('Printf: %ld %ld' + LineEnding, [LONG(wordval), longval]);
    
  result := 0;
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

  Result := True;
end;



Procedure CloseLibs;
begin
end;



begin
  writeln('enter');

  if OpenLibs
  then ExitCode := Main()
  else ExitCode := 10;

  CloseLibs;

  writeln('leave');
end.
