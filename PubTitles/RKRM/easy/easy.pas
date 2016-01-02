program easy;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : easy (well, that was the initial idea ;-) )
  Source    : RKRM
}
 {
 * easy.c: a complete example of how to open an Amiga function library in
 * C. In this case the function library is Intuition.  Once the Intuition
 * function library is open, any Intuition function can be called.  This
 * example uses the DisplayBeep() function of Intuition to flash the
 * screen With SAS/C (Lattice), compile with lc -L easy.c
 }
 {
   FPC Note:
   This conversion does not really follow the original c-example as that
   would result in really absurd code. Instead the Pascal counterpart for
   the supported platforms is shown including Pascal related comments.
   
   Do note however that one should not follow the code presented in this 
   example unless being absolutely sure what's going on.
   
   Also note that things _will_ change in the future.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{
  FPC Note:
  Free Pascal comes with support units for Amiga, AROS and MorphOS.
  
  As such, one can find the declarations of the used functions inside the
  corresponding support units.
  
  Some libraries are automatically opened (depending on the platform for
  which this example is compiled), or support units offer helpful functions 
  to open and/or close a library.
  
  Also the library's base pointer variables are already declared.
  
  Because this example actualy calls a library function, we are obligated to
  use the correct Basename variable, which unfortunately (and currently) isn't 
  the same (and in the same location) for all supported platforms.
  
  For the sake of this example, we manually open the library and store the 
  base-address in the corresponding basename variable in order to let the
  example work.
}

{
  FPC Note:
  Since we need Exec to be able to invoke the OpenLibrary and CloseLibrary 
  functions as well as intuition to call DisplayBeep, we need to include
  both their support units.
}
Uses
  Exec, Intuition;


Var
  {
    FPC Note:
    Here we declare variable IntuitionBase to store the base pointer of
    Intuition Library. We make this variable point to the absolute address
    of the already declared/present Intuitionbase variable.
    
    Note that it shows the curent 'kludge' that we have to deal with, and 
    which _will_ change in the future.
    
    Also note that using this solution is to be discouraged as storing a
    variable inside IntuitionBase will now 'overwrite' the system declared
    and used library base that was already defined. If the library was already
    opened (true for Amiga and AROS, not for MorphOS) then the initial 
    variable will be overwritten.

    The latter can have severe consequences, if you are not sure what you are 
    doing.
    (in that regards the code shown here is dead wrong, as it does not 
    provide a clean solution in case an invalid base-address is written
    into the intuitionbase variable -> can result in crashes inside FPC RTL).
  }

  {$IFDEF AMIGA}
  IntuitionBase: PIntuitionBase absolute _IntuitionBase;
  {$ENDIF}
  {$IFDEF AROS}
  IntuitionBase: PIntuitionBase absolute Intuition.Intuitionbase;
  {$ENDIF}
  {$IFDEF MORPHOS}
  IntuitionBase: PIntuitionBase absolute Intuition.Intuitionbase;
  {$ENDIF}


{
  FPC NOTE:
  Now that we solved the platform related incompatibilities, we can follow 
  the original c-code again.
}
function Main: LONG;
begin
  IntuitionBase := PIntuitionBase(OpenLibrary('intuition.library', 33));

  if Assigned(IntuitionBase) then   //* Check to see if it actually opened.   */
  begin                             //* The Intuition library is now open so  */
    DisplayBeep(nil);               //* any of its functions may be used.     */

    CloseLibrary(PLibrary(IntuitionBase));  //* Always close a library if not in use. */
  end
  else                              //* The library did not open so return an */
  begin                             //* error code.  The exit() function is   */
    exit(20);                       //* not part of the OS, it is part of the */
  end;                              //* compiler link library.                */
end;


begin
  Main;
end.
