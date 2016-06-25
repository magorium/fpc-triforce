unit aros_debug;

{$MODE OBJFPC}{$H+}

interface

Uses
  Exec, AmigaDos, Utility;



Const
  //* Tags for DecodeLocation() */
  DL_Dummy                = (TAG_USER + $03e00000);
  DL_ModuleName           = (DL_Dummy + 1);
  DL_SegmentName          = (DL_Dummy + 2);
  DL_SegmentPointer       = (DL_Dummy + 3);
  DL_SegmentNumber        = (DL_Dummy + 4);
  DL_SegmentStart         = (DL_Dummy + 5);
  DL_SegmentEnd           = (DL_Dummy + 6);
  DL_SymbolName           = (DL_Dummy + 7);
  DL_SymbolStart          = (DL_Dummy + 8);
  DL_SymbolEnd            = (DL_Dummy + 9);
  DL_FirstSegment         = (DL_Dummy + 10);

  //* Known debug information types */
  DEBUG_NONE              = 0;
  DEBUG_ELF               = 1;
  DEBUG_PARTHENOPE        = 2;
  DEBUG_HUNK              = 3;


Type

  //* ELF module debug information */
  TELF_DebugInfo = record
    eh : pelfheader;
    sh : psheader;
  end;

  //* Kickstart module debug information (pointed to by KRN_DebugInfo ti_Data) */
  PELF_ModuleInfo = ^TELF_ModuleInfo;
  TELF_ModuleInfo = record
    Next  : pELF_ModuleInfo;    //* Pointer to next module in list */
    Name  : PChar;              //* Pointer to module name         */
    Type_ : Byte;               //* DEBUG_ELF, for convenience     */
    eh    : pelfheader;         //* ELF file header                */
    sh    : psheader;           //* ELF section header             */
  end;


  //* Structure received as message of EnumerateSymbols hook */
  PSymbolInfo = ^TSymbolInfo;
  TSymbolInfo = record
    si_Size        : LongInt;   //* Size of the structure */
    si_ModuleName  : STRPTR;
    si_SymbolName  : STRPTR;
    si_SymbolStart : APTR;
    si_SymbolEnd   : APTR;
  end;

  // Parthenope module debug information (pointed to by KRN_DebugInfo ti_Data)
  //
  // (This structure has the same layout as Parthenope's "module_t")
  //
  Parthenope_ModuleInfo = record
    m_node      : TMinNode;
    m_name      : STRPTR;
    m_str       : STRPTR;
    m_lowest    : ULONG;
    m_highest   : ULONG;
    m_symbols   : TMinList;
  end;


  Parthenope_Symbol = record
    s_node    : TMinNode;
    s_name    : STRPTR;
    s_lowest  : ULONG;
    s_highest : ULONG;
  
  end;
  
  //* HUNK module debug information */
  HUNK_DebugInfo = record
    dummy:  APTR;
  end;


Type
  cint  = LongInt;
  pvoid = pointer;
  
  
Const
  DEBUGNAME : pchar = 'debug.library';


Type
  PDebugLibrary = ^TDebugLibrary;
  TDebugLibrary = record
    db_lib        : TLibrary;
    db_Modules    : TMinList;
    db_ModSem     : TSignalSemaphore;
    db_KernelBase : APTR;
  end;

Var
  DebugBase : PDebugLibrary;

  
  Procedure RegisterModule(const name: pchar; segList: BPTR; debugType: ULONG; debugInfo: APTR); SysCall DebugBase 5;
  Procedure UnregisterModule(segList: BPTR);                                                     SysCall DebugBase 6;
  Function  DecodeLocationA(addr: pvoid; tags: pTagItem): cint;                                  SysCall DebugBase 7;
  Procedure EnumerateSymbolsA(handler: PHook; tags: PTagItem);                                   SysCall DebugBase 8;

  Function  DecodeLocation(addr: pvoid; const Tags: array of const): cint;
  Procedure EnumerateSymbols(handler: PHook; const Tags: array of const);


implementation

Uses
  tagsarray;


Function  DecodeLocation(addr: pvoid; const Tags: array of const): cint;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  DecodeLocation := DecodeLocationA(addr, GetTagPtr(TagList));
end;


Procedure EnumerateSymbols(handler: PHook; const Tags: array of const);
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  EnumerateSymbolsA(handler, GetTagPtr(TagList));
end;



Initialization

  PLibrary(DebugBase) := OpenLibrary(DEBUGNAME, 0);


Finalization;

  CloseLibrary(PLibrary(DebugBase));


end.