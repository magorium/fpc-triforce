program easyrequest;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : easyrequest
  Source    : RKRM
}
 {*
 ** easyrequest.c - show the use of an easy requester.
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, intuition, Utility,
  Trinity,
  CHelpers;


{* declare the easy request structure.
** this uses many features of EasyRequest(), including:
**     multiple lines of body text separated by '\n'.
**     variable substitution of a string (%s) in the body text.
**     multiple button gadgets separated by '|'.
**     variable substitution in a gadget (long decimal '%ld').
*}
var
  myES  : TEasyStruct =
  (
    es_StructSize   : sizeof(TEasyStruct);
    es_Flags        : 0;
    es_Title        : 'Request Window Name';
    es_TextFormat   : 'Text for the request\nSecond line of %s text'#13'Third line of text for the request';
    es_GadgetFormat : 'Yes|%ld|No';
  );


{*
** Main routine to show the use of EasyRequest()
*}
procedure Main(argc: integer; argv: PPChar);
var
  answer    : LONG;
  number    : LONG;
begin
  number := 3125794;    //* for use in the middle button */
  {$IFDEF MORPHOS}
  if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
  {$ENDIF}
  begin
    {* note in the variable substitution:
    **     the string goes in the first open variable (in body text).
    **     the number goes in the second open (gadget text).
    *}
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    answer := Trinity.EasyRequest(nil, @myES, nil, [TAG_(PChar('(Variable)')), TAG_(number), TAG_END]);
    {$ELSE}
    answer := Intuition.EasyRequest(nil, @myES, nil, [TAG_(PChar('(Variable)')), TAG_(number), TAG_END]);
    {$ENDIF}

    {* Process the answer.  Note that the buttons are numbered in
    ** a strange order.  This is because the rightmost button is
    ** always a negative reply.  The code can use this if it chooses,
    ** with a construct like:
    **
    **     if (EasyRequest())
    **          positive_response();
    *}
    case (answer) of
      1: WriteLn('selected "Yes"');
      2: WriteLn('selected "', number, '"');
      0: WriteLn('selected "No"');
    end;

    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
