program newloookscreen;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : newlookscreen
  Topic     : open a screen with the "new look".
  Source    : RKRM
}
 

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}


{$DEFINE INTUI_V36_NAMES_ONLY}

Uses
  Exec, AmigaDOS, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  Trinity,
  CHelpers;


var
  {$IFDEF AMIGA}
  IntuitionBase : PLibrary absolute _Intuitionbase;
  {$ENDIF}
  {$IFDEF AROS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  {$ENDIF}
  {$IFDEF MORPHOS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  {$ENDIF}


{* Simple routine to demonstrate opening a screen with the new look.
** Simply supply the tag SA_Pens along with a minimal pen specification,
** Intuition will fill in all unspecified values with defaults.
** Since we are not supplying values, all are Intuition defaults.
*}
procedure Main(argc: integer; argv: PPChar);
var
  pens      : Array[0..0] of UWORD = ($FFFF);
  my_screen : PScreen;

begin
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 0);
  {$ENDIF}
  if (nil <> IntuitionBase) then
  begin
    if (IntuitionBase^.lib_Version >= 37) then
    begin
      {* The screen is opened two bitplanes deep so that the
       * new look will show-up better.
       *}
      if (Nil <> SetAndGet(my_screen, OpenScreenTags(nil,
      [
        TAG_(SA_Pens)   , TAG_(@Pens),
        TAG_(SA_Depth)  , 2,
        TAG_DONE
      ]))) then
      begin
        //* screen successfully opened */
        DOSDelay(30);       //* normally the program would be here */

        CloseScreen(my_screen);
      end;
    end;
    {$IFDEF MORPHOS}    
    CloseLibrary(IntuitionBase);
    {$ENDIF}
  end;
end;

begin
  Main(ArgC, ArgV);
end.
