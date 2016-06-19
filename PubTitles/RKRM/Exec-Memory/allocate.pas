program allocate;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : allocate
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec,
  SysUtils,
  CHelpers,
  Trinity;


const
  BLOCKSIZE = 4000;     //* or whatever you need */


Function Main: Integer;
var
  mh        : PMemHeader;
  mc        : PMemChunk;
  block1, 
  block2    : APTR;
begin
  //* Get the MemHeader needed to keep track of our new block. */
  mh := PMemHeader(ExecAllocMem(LONG(sizeof(TMemHeader)), MEMF_CLEAR));
  if not assigned(mh) then exit(10);

  //* Get the actual block the above MemHeader will manage. */
  if not(SetAndTest(mc, PMemChunk(ExecAllocMem(BLOCKSIZE, 0))) ) then
  begin
    ExecFreeMem(mh, LONG(sizeof(TMemHeader)));
    exit(10);
  end;
  mh^.mh_Node.ln_Type := NT_MEMORY;
  mh^.mh_First        := mc;
  mh^.mh_Lower        := APTR(mc);
  mh^.mh_Upper        := APTR((BLOCKSIZE + ULONG(mc) ));
  mh^.mh_Free         := BLOCKSIZE;

  // FPC Note: 
  // MorphOS uses incorrect field names, so we need to workaround
  {$IFNDEF MORPHOS}
  mc^.mc_Next  := nil;                 //* Set up first chunk in the freelist */
  mc^.mc_Bytes := BLOCKSIZE;
  {$ELSE}
  mc^.nc_Next  := nil;                 //* Set up first chunk in the freelist */
  mc^.nc_Bytes := BLOCKSIZE; 
  {$ENDIF}

  // FPC Note: 
  // Because our current program is also called Allocate, we need to  make FPC 
  // aware that we meant to call function Alllocate() from unit Exec.
  block1 := APTR(Exec.Allocate(mh,  20));
  block2 := APTR(Exec.Allocate(mh, 314));

  WriteLn(Format('Our MemHeader struct at $%p. Our block of memory at $%p', [mh, mc]));
  WriteLn(Format('Allocated from our pool: block1 at $%p, block2 at $%p', [block1, block2]));

  ExecFreeMem(mh, LONG(sizeof(TMemHeader)));
  ExecFreeMem(mc, LONG(BLOCKSIZE));
end;


begin
  ExitCode := Main;
end.
