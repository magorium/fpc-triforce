program verzeichnis;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : verzeichnis (directory)
  Topic   : Read a directory recursively and sort all files according to size
  Author  : Thomas Rapp
  Source  : http://thomas-rapp.homepage.t-online.de/examples/verzeichnis.c
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
  {$IFDEF AMIGA}
  AmigaLib,
  {$ENDIF}
  Trinity,
  CHelpers,
  Strings;


//*-------------------------------------------------------------------------*/
//* Type definitions                                                        */
//*-------------------------------------------------------------------------*/


Type
  PdirectoryItem = ^TdirectoryItem;
  TdirectoryItem = record
    node    : TMinNode;
    name    : array[0..1-1] of Char;
  end;

  PfileItem = ^TfileItem;
  TfileItem = record
    node    : TMinNode;
    parent  : PdirectoryItem;
    size    : ULONG;
    name    : array[0..1-1] of Char;
  end;


//*-------------------------------------------------------------------------*/
//* Global variables                                                        */
//*-------------------------------------------------------------------------*/


var
  directoriesList   : TMinList;
  filesList         : TMinList;
  
  verbose           : boolean = false;


//*-------------------------------------------------------------------------*/
//* Check if CTRL-C is being pressed                                        */
//*-------------------------------------------------------------------------*/

function check_interrupted: boolean;
const
  interrupted : boolean = false;
begin
  if not(interrupted) then
    if ((SetSignal(0,0) and SIGBREAKF_CTRL_C) <> 0) then
    begin
      WriteLn('*** Interrupted');
      interrupted := true;
    end;

  result := (interrupted);
end;


//*-------------------------------------------------------------------------*/
//* Attach a new directory to the end of the list                           */
//*-------------------------------------------------------------------------*/

procedure new_directory(parent: PdirectoryItem; name: PChar);
var
  new   : PdirectoryItem;
  len   : LongInt;
begin
  if assigned(parent) 
  then len := strlen(parent^.name) + 1 + strlen(name)
  else len := 0 + strlen(name);

  new := GetMem(sizeof(TdirectoryItem) + len);
  if assigned(new) then
  begin
    if assigned(parent) then
    begin
      strcopy(new^.name, parent^.name);
      AddPart(new^.name, name, len+1);
    end
    else
      strcopy(new^.name, name);

    if (verbose) then WriteLn('new directory: ' , PChar(new^.name));

    AddTail( PList(@directoriesList), PNode(new));
  end;
end;


//*-------------------------------------------------------------------------*/
//* Sort a new file into the list                                           */
//*-------------------------------------------------------------------------*/


procedure new_file(parent: PdirectoryItem; name: PChar; size: ULONG);
var
  new   : PfileItem;
  previous, next : PfileItem;
begin
  if SetAndTest(new, GetMem(sizeof(TfileItem) + strlen(name))) then
  begin
    strcopy(new^.name, name);
    new^.parent := parent;
    new^.size := size;

    if (verbose) then WriteLn('new file: ', PChar(new^.name));

    previous := PfileItem(filesList.mlh_Head);
    next     := PfileItem(previous^.node.mln_Succ);

    while assigned(next) do
    begin
      previous := next;
      if (previous^.size > new^.size)
      then break;

      next := PfileItem(previous^.node.mln_Succ);
    end;

    if assigned(next)
    then ExecInsert (PList(@filesList), PNode(new), PNode(previous^.node.mln_Pred))
    else AddTail ( PList(@filesList), PNode(new));
  end;
end;    


//*-------------------------------------------------------------------------*/
//* Read a directory and its subdirectories                                 */
//*-------------------------------------------------------------------------*/


procedure read_directory(parent: PdirectoryItem);
var
  lck   : BPTR;
  fib   : PFileInfoBlock;
  last, next: PdirectoryItem;
begin
  if (verbose) then WriteLn('reading directory: ', PChar(parent^.name));

  next := PdirectoryItem(directoriesList.mlh_TailPred); //* mark last entry in list */

  if SetAndTest(fib, AllocDosObject(DOS_FIB, nil)) then
  begin
    if SetAndTest(lck, Lock(PChar(parent^.name), SHARED_LOCK)) then
    begin
      if LongBool(Examine(lck, fib)) then
      begin
        if (fib^.fib_DirEntryType > 0) then
        begin
          while ((not check_interrupted) and LongBool(ExNext(lck, fib)) ) do
          begin
            if (fib^.fib_DirEntryType > 0)
            then new_directory(parent, fib^.fib_FileName)
            else new_file(parent, fib^.fib_FileName, fib^.fib_Size);
          end;
        end;
      end;
      UnLock (lck);
    end;
    FreeDosObject (DOS_FIB,fib);
  end;

  {*

    Read subdirectories: We only read the directories that we have added. 
    Therefor we've marked the last entry in the list as "next" before further
    processing. Then the new items are added. Then we mark the last entry in
    "last". This is the last entry that we have inserted. All subdirectories
    are inserted behind and we do not further process those by reading.

  *}

  last := PdirectoryItem(directoriesList.mlh_TailPred);
  while (not check_interrupted) and (next <> last) do
  begin
    next := PdirectoryItem(next^.node.mln_Succ);
    read_directory(next);
  end;
end;


//*-------------------------------------------------------------------------*/
//* Print the file list                                                     */
//*-------------------------------------------------------------------------*/


procedure print_filelist;
var
  fileItem, nextItem: PfileItem;
  name  : array[0..1000-1] of char;
begin
  fileItem := PfileItem(filesList.mlh_Head);
  nextItem := PfileItem(fileItem^.node.mln_Succ);
  
  while not(check_interrupted) and assigned(nextItem) do
  begin
    strcopy(name, fileItem^.parent^.name);
    AddPart (name, PChar(fileItem^.name), 1000);
    WriteLn('   ', fileItem^.size:8, ' ', name);

    fileItem := nextItem;
    nextItem := PfileItem(fileItem^.node.mln_Succ);
  end;
end;



//*-------------------------------------------------------------------------*/
//* Free all nodes from the list                                            */
//*-------------------------------------------------------------------------*/

procedure list_free(list: PMinList);
var
  node  : PNode;
begin
  while SetAndTest(node, RemHead( PList(list))) 
    do freemem(node);
end;


//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/


function  main: integer;
type
  TArgs = record
    path    : PPChar;
    verbose : LongInt;
  end;
var
  rdargs    : PRDArgs;
  args      : TArgs; //  = default(TArgs);
  p         : PPChar;
begin
  args := default(TArgs);
  rdargs := ReadArgs('PATH/A/M,VERBOSE/S', PLONG(@args), nil);
  if not assigned(rdargs) then
  begin
    PrintFault(IoErr(), 'Error in arguments');
    exit(RETURN_ERROR);
  end;

  if (args.verbose <> 0)
    then verbose := TRUE;

  NewList( PList(@filesList));
  NewList( PList(@directoriesList));

  p := args.path;
  while assigned(p^) do
  begin
    new_directory( nil, p^);
    read_directory( PdirectoryItem(directoriesList.mlh_TailPred) );
    inc(p);
  end;  

  print_filelist();

  list_free(@filesList);
  list_free(@directoriesList);

  FreeArgs(rdargs);

  result := (RETURN_OK);
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
  WriteLn('enter');

  if OpenLibs 
  then ExitCode := Main
  else ExitCode := RETURN_FAIL;

  CloseLibs;
  
  WriteLn('leave');
end.
