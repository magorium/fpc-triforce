program istr;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : istr
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, Utility,
  SysUtils;


procedure Main;
var
  butter    : PChar = 'B∞tervl∞∞t';
  bread     : PChar = 'Kn’ckerbr∞t';
  ch1, ch2  : Char;
  res       : LONG;
begin
  // FPC Note:
  // awkward ifdef, to match original source with opening and closing
  // utility.library, which isn't needed for Amiga, AROS and MorphOS as
  // FPC auto-opens this library for us.

  //* Fails silently if < 37 */
  {$IFNDEF HASAMIGA}  
  if SetAndTest(UtilityBase, OpenLibrary('utility.library', 37)) then
  {$ENDIF}
  begin
    res := Stricmp(butter, bread);

    WriteLn(Format('comparing %s with %s yields %d', [butter, bread, res]) );

    res := Strnicmp(bread, butter, strlen(bread));

    WriteLn(Format('comparing (with length) %s with %s yields %d', [bread, butter, res]) );

    ch1 := ToUpper($E6); // µ /* ASCII character 230 ae ligature */
    ch2 := ToLower($D0); //  /* ASCII character 208 Icelandic Eth */

    WriteLn(Format('Chars %s %s', [ch1, ch2]) );

    {$IFNDEF HASAMIGA}
    CloseLibrary(UtilityBase);
    {$ENDIF}
  end;
end;


begin
  Main;
end.
