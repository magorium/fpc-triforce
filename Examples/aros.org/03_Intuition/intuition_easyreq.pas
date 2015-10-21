Program intuition_easyreq;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : intuition_easyreq
  Topic   : Demonstrates EasyRequesters
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/intuition_easyreq.c
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
    Example of an Easyrequester
*}



Uses
  exec, intuition, utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  //chelpers,
  trinity;


function  main: integer;
var
  res           : LONG;
  es_Simple     : TEasyStruct =
  (
    es_StructSize   : sizeof(TEasyStruct);
    es_Flags        : 0;
    es_Title        : 'Window Title';
    es_TextFormat   : 'Example for EasyRequest.' + LineEnding + 'Lines can be split with \n.';
    es_GadgetFormat : 'Yes|No|Cancel';
  );

  strng         : STRPTR;
  
  longnumber    : LONG;
  wordnumber    : WORD;

  es_rawdofmt   : TEasyStruct =
  (
    es_StructSize   : sizeof(TEasyStruct);
    es_Flags        : 0;
    es_Title        : 'WindowTitle';
    es_TextFormat   : 'Test for RawDoFmt()-like formatting.' + LineEnding + LineEnding +
                      'String: %s' + LineEnding +
                      'WORD: %ld' + LineEnding +
                      'LONG: %ld' + LineEnding;
    es_GadgetFormat : 'WORD: %ld';
  );
begin
  {*
      The return value is the number of the clicked button. Note to order:
      1,2,3,...,N,0. (This was done for compatibility with AutoRequest().)
  *}
  //res := EasyRequest(nil, @es_simple, nil, nil);
  //res := EasyRequest(nil, @es_simple, nil, [TAG_END, 0]);
  res := EasyRequest(nil, @es_simple, nil);
  WriteLn('Result of EasyRequest ', res);

  {*
      EasyRequest allows RawDoFmt()-like formatting. RawDoFmt() expects WORD
      alignment but the C compiler aligns to LONG. Thus we have to use for
      integer variables %ld or %lu and convert to LONG or ULONG.
  *}
    
  strng := 'Inserted string';
  longnumber := 2147483647;
  wordnumber := 32767;
    
  {*
      The arguments beginning with the 4th are used for the placeholders. First
      for es_TextFormat then es_GadgetFormat.
  *}
  EasyRequest(nil, @es_rawdofmt, nil, 
  [  
    TAG_(strng), LONG(wordnumber), longnumber, LONG(wordnumber)
  ]);
    
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
  then ExitCode := Main()
  else ExitCode := 10;

  CloseLibs;
end.
