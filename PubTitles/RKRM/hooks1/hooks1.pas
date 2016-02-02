program hooks1;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : hooks1
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}

{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, Intuition, Utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  Trinity;


Type
  PVOID         = Pointer;
  THookFunction = function(Hook: pHook; obj: APTR; Msg: APTR): LongWord;


Var
  UtilityBase   : pLibrary 
  {$IFDEF AMIGA}   absolute _UtilityBase;{$ENDIF}
  {$IFDEF AROS}    absolute AOS_UtilityBase;{$ENDIF}
  {$IFDEF MORPHOS} absolute MOS_UtilityBase;{$ENDIF}


//* This function converts register-parameter Hook calling
//* convention into standard C conventions.  It requires a C
//* compiler that supports registerized parameters, such as
//* SAS/C 5.xx or greater.
{$IFDEF CPU68}
procedure hookEntry; assembler; 
asm
  move.l a1,-(a7)    // Msg
  move.l a2,-(a7)    // Obj
  move.l a0,-(a7)    // PHook
  move.l 12(a0),a0   // h_SubEntry = Offset 12
  jsr (a0)           // Call the SubEntry
end;
{$ENDIF}

{$IFDEF CPU86}
function hookEntry(h: pHook; o: pointer; msg: PVOID): ULONG; cdecl;
var
  Func: THookFunction;
begin
  Func   := THookFunction(h^.h_SubEntry);
  result := Func(h, o, msg);
end;
{$ENDIF}

{$IFDEF CPUPOWERPC}
type
  THookSubEntryFunc = function(a, b, c: Pointer): longword;

function HookEntry: longword;
var
  hook: PHook;
begin
  hook:=REG_A0;
  HookEntry:=THookSubEntryFunc(hook^.h_SubEntry)(hook, REG_A2, REG_A1);
end;
{$ENDIF}


//* This simple function is used to initialize a Hook */
procedure InitHook (h: pHook; func: THookFunction; data: PVOID);
{$IFDEF MORPHOS}
const 
  HOOKENTRY_TRAP: TEmulLibEntry = ( Trap: TRAP_LIB; Extension: 0; Func: @HookEntry );
{$ENDIF}  
begin
  //* Make sure a pointer was passed */
  if (h <> nil) then
  begin
    //* Fill in the Hook fields */
    {$IFDEF MORPHOS}
    h^.h_Entry := @HOOKENTRY_TRAP;
    {$ELSE}
    h^.h_Entry := {$IFDEF AROS}ULONG{$ENDIF}(@hookEntry);
    {$ENDIF}
    h^.h_SubEntry := {$IFDEF AROS}ULONG{$ENDIF}(func);
    h^.h_Data := data;
  end;
end;


//* This function only prints out a message indicating that we are
//* inside the callback function.

Function MyFunction (h: pHook; o: PVOID; msg: PVoid): ULONG;
begin
  //* Obtain access to the global data segment */
  // geta4();

  //* Debugging function to send a string to the serial port */
  WriteLn('Inside MyFunction()');

  LongBool(Result) := true;
end;



function main(argc: integer; argv: ppchar): integer;
var
  h : THook;
begin
  //* Open the utility library */
  {$IFNDEF HASAMIGA}
  UtilityBase := OpenLibrary ('utility.library', 36);
  {$ENDIF}
  if (UtilityBase <> nil) then
  begin
    //* Initialize the callback Hook */
    InitHook (@h, @MyFunction, nil);

    //* Use the utility library function to invoke the Hook */
    CallHookPkt (@h, nil, nil);

    //* Close utility library now that we're done with it */
    {$IFNDEF HASAMIGA}
    CloseLibrary (UtilityBase);
    {$ENDIF}
  end
  else WriteLn ('Couldn''t open utility.library');
end;


begin
  Main(Paramcount, Argv);
end.
