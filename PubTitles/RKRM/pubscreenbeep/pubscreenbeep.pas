program pubscreenbeep;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : pubscreenbeep
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, intuition,
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



{* Simple example of how to find a public screen to work with in Release 2.
 *}
procedure main(argc: integer; argv: PPChar);
var
  my_wbscreen_ptr : PScreen;     //* Pointer to the Workbench screen */
begin
  //* Open the library before you call any functions */
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 0);
  {$ENDIF}
  if ( IntuitionBase <> nil ) then
  begin
    if (IntuitionBase^.lib_Version >= 36) then
    begin
      {* OK, we have the right version of the OS so we can use
      ** the new public screen functions of Release 2 (V36)
      *}
      if (nil <> SetAndGet(my_wbscreen_ptr, LockPubScreen('Workbench'))) then
      begin
          //* OK found the Workbench screen.                      */
          //* Normally the program would be here.  A window could */
          //* be opened or the attributes of the screen copied    */
          DisplayBeep(my_wbscreen_ptr);

          UnlockPubScreen(nil, my_wbscreen_ptr);
      end;
    end
    else
    begin
      //* Prior to Release 2 (V36), there were no public screens,     */
      //* just Workbench.  In those older systems, windows can be     */
      //* opened on Workbench without locking or a pointer by setting */
      //* the Type=WBENCHSCREEN in struct NewWindow.  Attributes can  */
      //* be obtained by setting the Type argument to WBENCHSCREEN in */
      //* the call to GetScreenData().                                */
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(IntuitionBase);
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
