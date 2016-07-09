program remembertest;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : remembertest
  Title     : Illustrates the use of AllocRemember() and FreeRemember().
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

Uses
  Exec, AmigaDOS, intuition;


  //* our function prototypes */
  procedure methodOne; forward;
  procedure methodTwo; forward;


Var
  {$IFDEF AMIGA}
  IntuitionBase : PLibrary absolute _Intuitionbase;
  {$ENDIF}
  {$IFDEF AROS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  {$ENDIF}
  {$IFDEF MORPHOS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  {$ENDIF}


Const
  //* random sizes to demonstrate the Remember functions. */
  SIZE_A = 100;
  SIZE_B = 200;


{*
** main() - Initialize everything.
*}
function  main(argc: integer; argv: PPChar): integer;
var
  exitVal : LONG = RETURN_OK;
begin
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 33);
  {$ENDIF}
  if ( IntuitionBase = nil ) 
  then exitVal := RETURN_FAIL
  else
  begin
    methodOne;
    methodTwo;

    {$IFDEF MORPHOS}
    CloseLibrary(IntuitionBase);
    {$ENDIF}
  end;
  Result := exitVal;
end;


{*
** MethodOne
** Illustrates using AllocRemember() to allocate all memory and
** FreeRemember() to free it all.
*}
procedure methodOne;
var
  memBlockA   : APTR; 
  memBLockB   : APTR;
  rememberKey : PRemember = nil;
begin
  memBlockA := nil;
  memBlockB := nil;

  memBlockA := AllocRemember(rememberKey, SIZE_A, MEMF_CLEAR or MEMF_PUBLIC);
  if Assigned(memBlockA) then
  begin
    //*  The memBlockA allocation succeeded; try for memBlockB.  */
    memBlockB := AllocRemember(rememberKey, SIZE_B, MEMF_CLEAR or MEMF_PUBLIC);
    if Assigned(memBlockB) then
    begin
      {*  Both memory allocations succeeded.
      **  The program may now use this memory.
      *}
    end;
  end;

  {* It is not necessary to keep track of the status of each allocation.
  ** Intuition has kept track of all successful allocations by updating its
  ** linked list of Remember nodes.  The following call to FreeRemember() will
  ** deallocate any and all of the memory that was successfully allocated.
  ** The memory blocks as well as the link nodes will be deallocated because
  ** the "ReallyForget" parameter is TRUE.
  **
  ** It is possible to have reached the call to FreeRemember()
  ** in one of three states.  Here they are, along with their results.
  **
  ** 1. Both memory allocations failed.
  **       RememberKey is still NULL.  FreeRemember() will do nothing.
  ** 2. The memBlockA allocation succeeded but the memBlockB allocation failed.
  **       FreeRemember() will free the memory block pointed to by memBlockA.
  ** 3. Both memory allocations were successful.
  **       FreeRemember() will free the memory blocks pointed to by
  **       memBlockA and memBlockB.
  *}
  FreeRemember(rememberKey, Ord(TRUE));
end;


{*
** MethodTwo
** Illustrates using AllocRemember() to allocate all memory,
** FreeRemember() to free the link nodes, and FreeMem() to
** free the actual memory blocks.
*}
procedure methodTwo;
var
  memBlockA : APTR; 
  memBLockB : APTR;
  rememberKey : PRemember = nil;
begin
  memBlockA := nil;
  memBlockB := nil;

  memBlockA := AllocRemember(rememberKey, SIZE_A, MEMF_CLEAR or MEMF_PUBLIC);
  if assigned(memBlockA) then
  begin
    //*  The memBlockA allocation succeeded; try for memBlockB.  */
    memBlockB := AllocRemember(rememberKey, SIZE_B, MEMF_CLEAR or MEMF_PUBLIC);
    if assigned(memBlockB) then
    begin
      {* Both memory allocations succeeded.
      ** For the purpose of illustration, FreeRemember() is called at
      ** this point, but only to free the link nodes.  The memory pointed
      ** to by memBlockA and memBlockB is retained.
      *}
      FreeRemember(rememberKey, Ord(FALSE));

      {* Individually free the two memory blocks. The Exec FreeMem()
      ** call must be used, as the link nodes are no longer available.
      *}
      ExecFreeMem(Pointer(memBlockA), SIZE_A);
      ExecFreeMem(POinter(memBlockB), SIZE_B);
    end;
  end;

  {* It is possible to have reached the call to FreeRemember()
  ** in one of three states.  Here they are, along with their results.
  **
  ** 1. Both memory allocations failed.
  **    RememberKey is still NULL.  FreeRemember() will do nothing.
  ** 2. The memBlockA allocation succeeded but the memBlockB allocation failed.
  **    FreeRemember() will free the memory block pointed to by memBlockA.
  ** 3. Both memory allocations were successful.
  **    If this is the case, the program has already freed the link nodes
  **    with FreeRemember() and the memory blocks with FreeMem().
  **    When FreeRemember() freed the link nodes, it reset RememberKey
  **    to NULL.  This (second) call to FreeRemember() will do nothing.
  *}
  FreeRemember(rememberKey, Ord(TRUE));
end;


begin
  WriteLn('This example has no (visual) interaction. Read the source Luke.');
  ExitCode := Main(ArgC, ArgV);
end.
