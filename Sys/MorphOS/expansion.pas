unit expansion;

{$MODE OBJFPC}{$H+}
{$UNITPATH ../Trinity/}
{$UNITPATH .}

interface


uses 
  Exec, AmigaDOS, configvars,
  TriniTypes;


Const
  EXPANSIONNAME         : PChar = 'expansion.library';

  //* Flag for the AddDosNode()/AddBootNode() calls */

  //* Start FileSystem process. */
  ADNB_STARTPROC      = 0;
  ADNF_STARTPROC      = (1 shl ADNB_STARTPROC);


var
  ExpansionBase: PLibrary;

  {$IFDEF AMIGA}
  function  AddBootNode(bootPri: SBYTE location 'd0'; flags: ULONG location 'd1'; deviceNode: PDeviceNode location 'a0'; configDev: PConfigDev location 'a1'): LBOOL;   syscall ExpansionBase 036;
  procedure AddConfigDev(configDev: PConfigDev location 'a0');                                                                                                          syscall ExpansionBase 030;
  function  AddDosNode(bootPri: SBYTE location 'd0'; flags: ULONG location 'd1'; deviceNode: PDeviceNode location 'a0') : LBOOL;                                        syscall ExpansionBase 150;
  procedure AllocBoardMem(slotSpec: ULONG location 'd0');                                                                                                               syscall ExpansionBase 042;
  function  AllocConfigDev: PConfigDev;                                                                                                                                 syscall ExpansionBase 048;
  function  AllocExpansionMem(numSlots: ULONG location 'd0'; slotAlign: ULONG location 'd1'): APTR;                                                                     syscall ExpansionBase 054;
  //procedure ConfigBoard(board: APTR location 'a0'; configDev: PConfigDev location 'a1');                                                                                syscall ExpansionBase 060;
  function  ConfigBoard(board: APTR location 'a0'; configDev: PConfigDev location 'a1'): LBOOL;                                                                         syscall ExpansionBase 060;
  procedure ConfigChain(baseAddr: APTR location 'a0');                                                                                                                  syscall ExpansionBase 066;
  function  FindConfigDev(const oldConfigDev: PConfigDev location 'a0'; manufacturer: SLONG location 'd0'; product: SLONG location 'd1'): PConfigDev;                   syscall ExpansionBase 072;
  procedure FreeBoardMem(startSlot: ULONG location 'd0'; slotSpec: ULONG location 'd1');                                                                                syscall ExpansionBase 078;
  procedure FreeConfigDev(configDev: PConfigDev location 'a0');                                                                                                         syscall ExpansionBase 084;
  procedure FreeExpansionMem(startSlot: ULONG location 'd0'; numSlots: ULONG location 'd1');                                                                            syscall ExpansionBase 090;
  function  GetCurrentBinding(const currentBinding: PCurrentBinding location 'a0'; bindingSize: ULONG location 'd0'): ULONG;                                            syscall ExpansionBase 138;
  function  MakeDosNode(const parmPacket: APTR location 'a0'): PDeviceNode;                                                                                             syscall ExpansionBase 144;
  procedure ObtainConfigBinding;                                                                                                                                        syscall ExpansionBase 120;
  function  ReadExpansionByte(const board: APTR location 'a0'; offset: ULONG location 'd0'): UBYTE;                                                                     syscall ExpansionBase 096;
  //procedure ReadExpansionRom(const board: APTR location 'a0'; configDev: PConfigDev location 'a1');                                                                     syscall ExpansionBase 102;
  function  ReadExpansionRom(const board: APTR location 'a0'; configDev: PConfigDev location 'a1'): LBOOL;                                                              syscall ExpansionBase 102;
  procedure ReleaseConfigBinding;                                                                                                                                       syscall ExpansionBase 126;
  procedure RemConfigDev(configDev: PConfigDev location 'a0');                                                                                                          syscall ExpansionBase 108;
  procedure SetCurrentBinding(currentBinding: PCurrentBinding location 'a0'; bindingSize: ULONG location 'd0');                                                         syscall ExpansionBase 132;
  procedure WriteExpansionByte(board: APTR location 'a0'; offset: ULONG location 'd0'; byteval: ULONG location 'd1');                                                   syscall ExpansionBase 114;
  {$ENDIF}

  {$IFDEF AROS}
  procedure AddConfigDev(configDev: PConfigDev);                                                                syscall ExpansionBase 005;
  function  AddBootNode(bootPri: SLONG; flags: ULONG; deviceNode: PDeviceNode; configDev: PConfigDev): LBOOL;   syscall ExpansionBase 006;
  procedure AllocBoardMem(slotSpec: ULONG);                                                                     syscall ExpansionBase 007; unimplemented;
  function  AllocConfigDev: PConfigDev;                                                                         syscall ExpansionBase 008; 
  function  AllocExpansionMem(numSlots: ULONG; slotAlign: ULONG): APTR;                                         syscall ExpansionBase 009; unimplemented;
  function  ConfigBoard(board: APTR; configDev: PConfigDev): LBOOL;                                             syscall ExpansionBase 010; unimplemented;
  procedure ConfigChain(baseAddr: APTR);                                                                        syscall ExpansionBase 011; unimplemented;
  function  FindConfigDev(const oldConfigDev: PConfigDev; manufacturer: SLONG; product: SLONG): PConfigDev;     syscall ExpansionBase 012;
  procedure FreeBoardMem(startSlot: ULONG; slotSpec: ULONG);                                                    syscall ExpansionBase 013; unimplemented;
  procedure FreeConfigDev(configDev: PConfigDev);                                                               syscall ExpansionBase 014;
  procedure FreeExpansionMem(startSlot: ULONG; numSlots: ULONG);                                                syscall ExpansionBase 015; unimplemented;
  function  ReadExpansionByte(const board: APTR; offset: ULONG): UBYTE;                                         syscall ExpansionBase 016; unimplemented;
  function  ReadExpansionRom(const board: APTR; configDev: PConfigDev): LBOOL;                                  syscall ExpansionBase 017; unimplemented;
  procedure RemConfigDev(configDev: PConfigDev);                                                                syscall ExpansionBase 018;
  procedure WriteExpansionByte(board: APTR; offset: ULONG; byteval: ULONG);                                     syscall ExpansionBase 019; unimplemented;
  procedure ObtainConfigBinding;                                                                                syscall ExpansionBase 020;
  procedure ReleaseConfigBinding;                                                                               syscall ExpansionBase 021;
  procedure SetCurrentBinding(currentBinding: PCurrentBinding; bindingSize: ULONG);                             syscall ExpansionBase 022;
  function  GetCurrentBinding(const currentBinding: PCurrentBinding; bindingSize: ULONG): ULONG;                syscall ExpansionBase 023;
  function  MakeDosNode(const parmPacket: APTR): PDeviceNode;                                                   syscall ExpansionBase 024;
  function  AddDosNode(bootPri: SLONG; flags: ULONG; deviceNode: PDeviceNode): LBOOL;                           syscall ExpansionBase 025;
  procedure WriteExpansionWord(board: APTR; offset: ULONG; wordval: ULONG);                                     syscall ExpansionBase 027; unimplemented;
  {$ENDIF}

  {$IFDEF MORPHOS}
  procedure WriteExpansionByte(board: APTR location 'a0'; offset: ULONG location 'd0'; byteval: ULONG location 'd1');                                                   syscall ExpansionBase 114;
  procedure ConfigChain(baseAddr: APTR location 'a0');                                                                                                                  syscall ExpansionBase 066;
  function  ReadExpansionByte(const board: APTR location 'a0'; offset: ULONG location 'd0'): UBYTE;                                                                     syscall ExpansionBase 096;
  function  MakeDosNode(const parmPacket: APTR location 'a0'): PDeviceNode;                                                                                             syscall ExpansionBase 144;
  procedure FreeExpansionMem(startSlot: ULONG location 'd0'; numSlots: ULONG location 'd1');                                                                            syscall ExpansionBase 090;
  procedure RemConfigDev(configDev: PConfigDev location 'a0');                                                                                                          syscall ExpansionBase 108;
  {+??}  // function ?
  procedure ConfigBoard(board: APTR location 'a0'; configDev: PConfigDev location 'a1');                                                                                syscall ExpansionBase 060;
  {-??}
  function  FindConfigDev(const oldConfigDev: PConfigDev location 'a0'; manufacturer: SLONG location 'd0'; product: SLONG location 'd1'): PConfigDev;                   syscall ExpansionBase 072;
  procedure AddConfigDev(configDev: PConfigDev location 'a0');                                                                                                          syscall ExpansionBase 030;
  function  GetCurrentBinding(const currentBinding: PCurrentBinding location 'a0'; bindingSize: ULONG location 'd0'): ULONG;                                            syscall ExpansionBase 138;
  procedure SetCurrentBinding(currentBinding: PCurrentBinding location 'a0'; bindingSize: ULONG location 'd0');                                                         syscall ExpansionBase 132;
  {+??}  // function ?
  procedure ReadExpansionRom(const board: APTR location 'a0'; configDev: PConfigDev location 'a1');                                                                     syscall ExpansionBase 102;
  {-??}
  procedure ReleaseConfigBinding;                                                                                                                                       syscall ExpansionBase 126;
  function  AddDosNode(bootPri: SBYTE location 'd0'; flags: ULONG location 'd1'; deviceNode: PDeviceNode location 'a0') : LBOOL;                                        syscall ExpansionBase 150;
  procedure FreeConfigDev(configDev: PConfigDev location 'a0');                                                                                                         syscall ExpansionBase 084;
  function  AllocExpansionMem(numSlots: ULONG location 'd0'; slotAlign: ULONG location 'd1'): APTR;                                                                     syscall ExpansionBase 054;
  function  AllocConfigDev: PConfigDev;                                                                                                                                 syscall ExpansionBase 048;
  function  AddBootNode(bootPri: SBYTE location 'd0'; flags: ULONG location 'd1'; deviceNode: PDeviceNode location 'a0'; configDev: PConfigDev location 'a1'): LBOOL;   syscall ExpansionBase 036;
  procedure AllocBoardMem(slotSpec: ULONG location 'd0');                                                                                                               syscall ExpansionBase 042;
  procedure FreeBoardMem(startSlot: ULONG location 'd0'; slotSpec: ULONG location 'd1');                                                                                syscall ExpansionBase 078;
  procedure ObtainConfigBinding;                                                                                                                                        syscall ExpansionBase 120;
  {$ENDIF}


implementation


Initialization

{$IFDEF AROS}
  ExpansionBase := OpenLibrary(EXPANSIONNAME, 0);
{$ENDIF}

finalization

{$IFDEF AROS}
  CloseLibrary(ExpansionBase);
{$ENDIF}

end.
