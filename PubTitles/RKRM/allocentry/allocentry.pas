program allocentry;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : allocentry
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec;


const
  ALLOCERROR    = $80000000;

Var
  memlist       : PMemList;         //* pointer to a MemList structure       */

  //* define a new structure because C cannot initialize unions */
  memblocks     : record  
    //* one entry in the header               */
    mn_head : TMemList; 
    //* additional entries follow directly as */
    //* part of the same data structure       */
    mn_body : array[0..Pred(3)] of TMemEntry;   
  end;


Function Main: Integer;
begin
  memblocks.mn_head.ml_NumEntries := 4; //* 4! Since the MemEntry starts at 1! */

  //* Describe the first piece of memory we want.  Because of our MemBlocks structure */
  //* setup, we reference the first MemEntry differently when initializing it.        */
  
  //* FPC Note:
  //* FPC does not allow to define union shortcut, so we ened to reach 
  //* field meu_reqs (me_reqs) manually.
  memblocks.mn_head.ml_ME[0].me_Un.meu_Reqs := MEMF_CLEAR;
  memblocks.mn_head.ml_ME[0].me_Length      := 4000;

  memblocks.mn_body[0].me_Un.meu_Reqs   := MEMF_CHIP or MEMF_CLEAR;     //* Describe the other pieces of    */
  memblocks.mn_body[0].me_Length        := 100000;                      //* memory we want. Additional      */
  memblocks.mn_body[1].me_Un.meu_Reqs   := MEMF_PUBLIC or MEMF_CLEAR;   //* MemEntries are initialized this */
  memblocks.mn_body[1].me_Length        := 200000;                      //* way. If we wanted even more en- */
  memblocks.mn_body[2].me_Un.meu_Reqs   := MEMF_PUBLIC;                 //* tries, we would need to declare */
  memblocks.mn_body[2].me_Length        := 25000;                       //* a larger MemEntry array in our  */
                                                                        //* MemBlocks structure.            */

  memlist := PMemList(Exec.AllocEntry(PMemList(@memblocks)));

  if ( ULONG(memlist) and ALLOCERROR) <> 0 then      //* 'error' bit 31 is set (see below). */
  begin
    WriteLn('AllocEntry FAILED');
    exit(200);
  end;
  //* We got all memory we wanted.  Use it and call FreeEntry() to free it */
  WriteLn('AllocEntry succeeded - now freeing all allocated blocks');
  FreeEntry(memlist);
end;


begin
  ExitCode := Main;
end.
