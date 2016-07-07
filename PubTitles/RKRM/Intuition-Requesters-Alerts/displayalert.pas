program displayalert;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : displayalert
  Source    : RKRM
}
 {*
 ** This program demonstrates an alert.  An explanation of the positioning
 ** values for the alert strings is in the comment that precedes the
 ** alertMsg string.
 **
 ** displayalert.c -  This program implements a recoverable alert
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, intuition,
  CHelpers;


{* Each string requires its own positioning information, as explained
** in the manual.  Hex notation has been used to specify the positions of
** the text. Hex numbers start with a backslash, an "x" and the characters
** that make up the number.
**
** Each line needs 2 bytes of X position, and 1 byte of Y position.
**   In our 1st line: x = \x00\xF0 (2 bytes) and y = \x14 (1 byte)
**   In our 2nd line: x = \x00\xA0 (2 bytes) and y = \x24 (1 byte)
** Each line is null terminated plus a continuation character (0=done).
** This example assumes that the complier will concatenate adjacent
** strings into a single string with no extra NULLs.  The compiler does
** add the terminating NULL at the end of the entire string...The entire
** alert must end in TWO NULLs, one for the end of the string, and one
** for the NULL continuation character.
*}
const
  alertMsg  : PChar = #$00 + #$F0 + #$14 + 'OH NO, NOT AGAIN!' + #$00 + #$01 +
                      #$00 + #$80 + #$24 + 'PRESS MOUSEBUTTON:   LEFT=TRUE   RIGHT=FALSE' + #$00;


procedure Main(argc: integer; argv: PPChar);
begin
  {$IFDEF MORPHOS}
  if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 33)) then
  {$ENDIF}
  begin
    if (Intuition.DisplayAlert(RECOVERY_ALERT, alertMsg, 52))
    then WriteLn('Alert returned TRUE')
    else WriteLn('Alert returned FALSE');

    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
