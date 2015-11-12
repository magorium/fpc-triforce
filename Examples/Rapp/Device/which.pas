program which;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : which
  Topic   : Search for a command in DOS-path
  Author  : Thomas Rapp
  Source  : http://thomas-rapp.homepage.t-online.de/examples/which.c
  ===========================================================================

  This example was originally written in c by Thomas Rapp.

  The original examples are available online and published at Thomas Rapp's 
  website (http://thomas-rapp.homepage.t-online.de/examples)

  The c-sources were converted to Free Pascal, and (variable) names and 
  comments were translated from German into English as much as possible.

  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc

  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Conversion to Free Pascal and translation was done by Magorium in 2015, 
  with kind permission from Thomas Rapp to be able to publish.

  ===========================================================================

           Unless otherwise noted, these examples must be considered
                 copyrighted by their respective owner(s)

  ===========================================================================
}

Uses
  Exec, AmigaDOS,
  Trinity;


Type
  Ppathnode =^Tpathnode;
  Tpathnode = 
  record
    next    : BPTR;
    path    : BPTR;
  end;


//*-------------------------------------------------------------------------*/
//* Lock only files                                                         */
//*-------------------------------------------------------------------------*/
function  LockFile(name: PChar): BPTR;
var
  alock : BPTR;
  fib   : PFileInfoBlock;
begin
  alock := Lock(name, SHARED_LOCK);

  if (alock <> default(BPTR)) then
  begin
    fib := AllocVec(sizeof(TFileInfoBlock), MEMF_CLEAR);
    if assigned(fib) then
    begin
      if LongBool(Examine(alock, fib)) then
        if (fib^.fib_DirEntryType > 0) then
        begin
          UnLock(alock);
          alock := default(BPTR);  //* don't allow directories */
        end;

      FreeVec(fib);
    end;
  end;
  Result := (alock);
end;


//*-------------------------------------------------------------------------*/
//* check if file is in directory                                           */
//*-------------------------------------------------------------------------*/
function  check_dir(dir: BPTR; fil: PChar): BPTR;
var
  oldcd : BPTR;
  alock : BPTR;
begin
  oldcd := CurrentDir(dir);
  alock := LockFile(fil);
  CurrentDir(oldcd);

  result := (alock);
end;


//*-------------------------------------------------------------------------*/
//* find command in DOS path                                                */
//*-------------------------------------------------------------------------*/
function whicher(command: PChar): BPTR;
var
  cmdlock : BPTR;
var
  acli  : PCommandLineInterface;
  n     : Ppathnode;
var
  dl    : PDosList;
  al    : PAssignList;

begin
  cmdlock := LockFile(command); //* look in current directory */

  if ( not(cmdlock <> default(BPTR)) and (command = FilePart(command)) ) then //* check DOS path only if no path is given in command name */
  begin
    acli := Cli();
    if assigned(acli) then
    begin
      n := BADDR(acli^.cli_CommandDir);
      
      while ( not(cmdlock <> default(BPTR)) and assigned(n) ) do
      begin
        cmdlock := check_dir(n^.path, command);
        n := BADDR(n^.next);
      end;        
    end;

	if not(cmdlock <> default(BPTR)) then //* C: is not contained in the path list */
    begin
      dl := LockDosList(LDF_ASSIGNS or LDF_READ);
      dl := FindDosEntry (dl, PChar('C'), LDF_ASSIGNS);
      if assigned(dl) then //* because C: may be a multi-assign we cannot just Lock("C:") */
      begin
        cmdlock := check_dir(dl^.dol_Lock,command);
        
//        al := dl^.dol_misc.dol_assign.dol_List;
        al := dl^.dol_assign.dol_List;
        while ( not(cmdlock <> default(BPTR)) and assigned(al) ) do
        begin
          cmdlock := check_dir(al^.al_lock, command);
          al := al^.al_Next;
        end;        
      end;
      UnLockDosList(LDF_ASSIGNS or LDF_READ);
    end;
  end;

  result := (cmdlock);  //* whatever we found or NULL */
end;



//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
type
  TArgs = record
    fil : PChar;
  end;
var
  rdargs    : PRDArgs;
  args      : TArgs = (fil: nil);
  alock     : BPTR;
  buffer    : packed array[0..256-1] of Char;
begin

  rdargs := ReadArgs('FILE/A', @args, nil);
  if assigned(rdargs) then
  begin
    alock := whicher(args.fil);
    if (alock <> default(BPTR)) then
    begin
      NameFromLock(alock, @buffer, 256);
      WriteLn(buffer);
      UnLock(alock);
    end;
    FreeArgs(rdargs);
  end;

  PrintFault(IoErr(), nil);

  Result := (0);
end;



//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/



Function OpenLibs: boolean;
begin
  Result := False;

  Result := True;
end;


Procedure CloseLibs;
begin
end;


begin
//  WriteLn('enter');

  if OpenLibs 
  then ExitCode := Main
  else ExitCode := RETURN_FAIL;

  CloseLibs;
  
//  WriteLn('leave');
end.
