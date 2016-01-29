unit amigalib;


(*
  Unit amigalib for AROS

    NOTE: All functions inside this unit are either based on (already) 
          existing Pascal implementation(s) or are converted from C-Source
          (AROS tree). None of the functions are actually tested atm.

          Be prepared to encounter c-source to Pascal conversion errors.

          #####     Use at your own risk     #####
*) 


{$MODE OBJFPC}{$H+}  // OBJFPC for array of const :-(

{$UNITPATH .}


interface


uses
  Exec, AGraphics, Intuition, Commodities, InputEvent, KeyMap, Rexx, Utility;


type
  PIsrvstr = ^TIsrvstr;
  TIsrvstr = record
    is_Node : tNode;
    Iptr    : pIsrvstr;     { passed to srvr by os }
    code    : Pointer;
    ccode   : Pointer;
    Carg    : Pointer;
  end;


  TNewPutCharProc      = procedure;
  TSortListCompareFunc = function(n1: PMinNode; n2: PMinNode; data: pointer): integer;


  function  ACrypt(buffer: PChar; password: PChar; username: PChar): PChar;
  procedure AddTOF(i: PIsrvstr; p: APTR; a: APTR); unimplemented;
  procedure ArgArrayDone;
  function  ArgArrayInit(argc: ULONG; argv: PPChar): PPChar;
  function  ArgInt(tt: PPChar; entry: STRPTR; defaultval: LongInt): LongInt;
  function  ArgString(tt: PPChar; entry: STRPTR; defaultString: STRPTR): STRPTR;
  function  ArosInquire(Const tags: Array of Const): ULONG;
  function  AsmAllocPooled(poolHeader: APTR; memSize: ULONG): APTR;
  function  AsmCreatePool(MemFlags: ULONG; PuddleSize: ULONG; ThreshSize: ULONG): APTR;
  procedure AsmDeletePool(poolHeader: APTR);
  procedure AsmFreePooled(poolHeader: APTR; Memory: APTR; MemSize: ULONG);
  procedure BeginIO(ioRequest: PIORequest);
  function  CallHook(hook: PHook; obj: APTR; const params: Array of const): IPTR;
  function  CallHookA(hook: PHook; obj: APTR; param: APTR): IPTR;
  function  CheckRexxMsg(msg: PRexxMsg): LongBool;
  function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: IPTR; const Args: array of const): IPTR;
  function  CoerceMethodA(cl: PIClass; Obj: PObject_; Message: APTR): IPTR;
  function  CopyRegion(region: PRegion): PRegion;
  function  CreateExtIO(port: PMsgPort; iosize: ULONG): PIORequest;
  function  CreatePort(name: STRPTR; pri: LONG): PMsgPort;
  function  CreateStdIO(port: PMsgPort): PIOStdReq;
  function  CreateTask(name: STRPTR; pri: LONG; initpc: APTR; stacksize: ULONG): PTask;
  function  CxCustom(action: Pointer; id: LONG): PCxObj; 
  function  CxDebug(id: LONG): PCxObj;
  function  CxFilter(description: STRPTR): PCxObj;
  function  CxSender(port: PMsgPort; id: LONG): PCxObj;
  function  CxSignal(task: PTask; signal: LONG): PCxObj;
  function  CxTranslate(ie: PInputEvent): PCxObj;
  procedure DeleteExtIO(ioreq: PIORequest);
  procedure DeletePort(mp: PMsgPort);
  procedure DeleteStdIO(io: PIOStdReq);
  procedure DeleteTask(task: PTask);
  function  DoMethod(obj: PObject_; MethodID: IPTR; msgTags: array of const): IPTR;
  function  DoMethodA(obj: PObject_; Message: PMsg): IPTR;
  function  DoSuperMethod(cl: PIClass; obj: PObject_; MethodID: ULONG; const msgTags: array of const): IPTR;
  function  DoSuperMethodA(cl: PIClass; obj: PObject_; message: PMsg): IPTR;
  function  DoSuperNewTagList(cl: PIClass; obj: PObject_; gadgetInfo: PGadgetInfo; tagList: PTagItem): IPTR;
  function  DoSuperNewTags(cl: PIClass; obj: PObject_; gadgetInfo: PGadgetInfo; const tags: array of const): IPTR;
  function  ErrorOutput: BPTR;
  function  FastRand(seed: ULONG): ULONG;
  procedure FreeIEvents(ie: PInputEvent);
  function  GetRexxVar(msg: PRexxMsg; const varname: STRPTR; value: PPChar): LONG;
  function  HookEntry(hook: PHook; obj: APTR; param: APTR): IPTR;
  function  HotKey(description: STRPTR; port: PMsgPort; id: LONG): PCxObj;
  function  InvertString(str: STRPTR; km: PKeyMap): PInputEvent;
  function  InvertStringForwd(str: STRPTR; km: PKeyMap): PInputEvent;
  function  LibAllocAligned(memSize: APTR; requirements: ULONG; alignBytes: IPTR): APTR;
  function  LibAllocPooled(pool: APTR; memSize: ULONG): APTR;
  function  LibCreatePool(requirements: ULONG; puddleSize: ULONG; threshSize: ULONG): Pointer; 
  procedure LibDeletePool(pool: APTR);
  procedure LibFreePooled(pool: APTR; memory: APTR; memSize: ULONG);
  function  LockBitMapTags(handle: APTR; const tags: Array of const): APTR;
  procedure MergeSortList(l: PMinList; compare: TSortListCompareFunc; data: Pointer);
  procedure NewList(list: PList);
  function  NewRawDoFmt(const fomtString: STRPTR; PutChProc: TNewPutCharProc; PutChData: APTR; valueList: PLong): STRPTR;
  function  NewRectRegion(MinX: SmallInt; MinY: SmallInt; MaxX: SmallInt; MaxY: SmallInt): PRegion;
  function  RangeRand(maxValue: ULONG): ULONG;
  procedure RemTOF(i: PIsrvstr); unimplemented;
  function  SelectErrorOutput(fh: BPTR): BPTR;
  function  SetRexxVar(msg: PRexxMsg; const varname: STRPTR; value: PChar; len: ULONG): LONG;
  function  SetSuperAttrs(cl: PIClass; Obj: PObject_; Tags: array of const): IPTR;
  function  SetSuperAttrsA(cl: PIClass; Obj: PObject_; TagList: PTagItem): IPTR;
  function  TimeDelay(timerUnit: LONG; Seconds: ULONG; MicroSeconds: ULONG): LONG;
  procedure UnlockBitMapTags(handle: BPTR; const tags: Array of const);


implementation


uses
  ArosLib, AmigaDOS, CyberGraphics, Workbench, Icon, Timer,
  tagsarray, longarray,
  SysUtils;                         // yes, this dependency needs to disappear.;



// ###########################################################################
// ###
// ###    FIXES: Remove when present in trunk/new release
// ###           Currently here to prevent dragging in trinity unit
// ###
// ###########################################################################



  function  NewCreateTaskA(tags: PTagItem): PTask; syscall AOS_ExecBase 153; 



function  NewCreateTask(const Tags: array of const): PTask; 
var 
  TagList: TTagsList; 
begin 
  {$PUSH}{$HINTS OFF} 
  AddTags(TagList, Tags); 
  {$POP} 
  NewCreateTask := NewCreateTaskA(GetTagPtr(TagList)); 
end;



// ###########################################################################
// ###
// ###    ALib
// ###
// ###########################################################################



const
  OSIZE = 12;


function  ACrypt(buffer: PChar; password: PChar; username: PChar): PChar;
var
  buf   : Array[0..Pred(OSIZE)] of LONG;
  i,d,k : LONG;
begin
  if ((buffer = nil) or (password = nil) or (username = nil)) then
  begin
    exit(nil);
  end;

  i := 0;
  while (i < OSIZE) do
  begin
    if ((password^) <> #0) then
    begin
      d := Ord(password^);
      inc(password);
    end
    else
      d := i;

    if ((username^) <> #0) then
    begin
      d := d + Ord(username^);
      inc(username);
    end
    else
      d := d + i;

    buf[i] := Ord('A') + d;
    
    inc(i);
  end;

  i := 0;
  while (i < OSIZE) do
  begin
    k := 0;
    while (k < OSIZE) do
    begin
      buf[i] := (buf[i] + buf[OSIZE - k - 1]) mod 53;
      inc(k);
    end;

    Ord(buffer[i]) := buf[i] + Ord('A');    //  buffer[i] := Chr(buf[i]) + ('A');
    
    inc(i);
  end;

  buffer[OSIZE-1] := #0;

  ACrypt := buffer;
end;


function  FastRand(seed: ULONG): ULONG;
var
  a : ULONG;
begin
  a := seed shl 1;

  if (LONG(seed) <= 0)
  then a := a xor $1d872b41;

  FastRand := a;
end;


var
  RangeSeed: ULONG;


function  RangeRand(maxValue: ULONG): ULONG;
var
  a,b   : ULONG;
  i     : UWORD;
begin
  a := RangeSeed;
  i := maxValue - 1;

  repeat
    b := a;

    a := a shl 1;

    if (LONG(b) <= 0)
    then a := a xor $1d872b41;

    i := i shr 1;
    if not(i <> 0) then break;
  until false;

  RangeSeed := a;

  if (UWORD(maxValue) <> 0)
  then exit( UWORD(UWORD(a) * UWORD(maxValue) shr 16) );

  RangeRand := UWORD(a);
end;



// ###########################################################################
// ###
// ###    ArosLib
// ###
// ###########################################################################



function  ArosInquire(Const tags: Array of Const): ULONG;
Var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  ArosInquire := ArosInquireA(GetTagPtr(TagList));
end;



// ###########################################################################
// ###
// ###    Exec
// ###
// ###########################################################################



type
  // PRIVATE! memory pool structure (_NOT_ compatible with original amiga.lib!)
  PPool = ^TPool;
  TPool = record
    PuddleList  : TMinList;
    ThreshList  : TMinList;

    MemoryFlags : ULONG;
    PuddleSize  : ULONG;
    ThreshSize  : ULONG;
  end;



function  AsmAllocPooled(poolHeader: APTR; memSize: ULONG): APTR;
begin
  AsmAllocPooled := AllocPooled(poolHeader, memSize);
end;


procedure AsmFreePooled(poolHeader: APTR; Memory: APTR; MemSize: ULONG);
begin
  FreePooled(poolHeader, Memory, MemSize);
end;


function  AsmCreatePool(MemFlags: ULONG; PuddleSize: ULONG; ThreshSize: ULONG): APTR;
begin
  AsmCreatePool := CreatePool(MemFlags, PuddleSize, ThreshSize);
end;


procedure AsmDeletePool(poolHeader: APTR);
begin
  DeletePool(poolHeader);
end;


function  LibAllocAligned(memSize: APTR; requirements: ULONG; alignBytes: IPTR): APTR;
var
  pt        : APTR;
  alignMask : IPTR;
var
  apt       : APTR;
begin
  // Verify that alignBytes is a power of two
  if ( (Ord(alignBytes) and (ord(alignBytes)-1)) <> 0)
  then exit(nil);

  // Verify that memSize is modulo alignBytes
  if ( ( IPTR(memSize) and (alignBytes - 1) ) <> 0)
  then exit(nil);

  alignMask := alignBytes - 1;

  pt := AllocMem(LongWord(memSize + alignMask), requirements);
  if (pt <> nil) then
  begin
    apt := APTR( ( IPTR(pt) + alignMask) and not alignMask);
    Forbid;
    FreeMem(pt, LongWord(memSize + alignMask));
    pt := AllocAbs(LongWord(memSize), apt);
    Permit;
  end;

  LibAllocAligned := pt;
end;


function  LibAllocPooled(pool: APTR; memSize: ULONG): APTR;
var
  poolHeader    : PPOOL absolute pool;
  puddle        : PULONG = nil;
var
  size          : ULONG;
  a             : PMemHeader;
  p             : PULONG;
begin
  // if (SysBase^.LibNode.lib_Version >= 39)
  if (PLibrary(AOS_ExecBase)^.lib_Version >= 39)
  then exit(AllocPooled(pool, memSize));

  if ((poolHeader <> nil) and (memSize <> 0)) then
  begin
    if (poolHeader^.ThreshSize > memSize) then
    begin
      a := PMemHeader(poolHeader^.PuddleList.mlh_Head);

      while true do
      begin
        if (a^.mh_Node.ln_Succ <> nil) then
        begin
          if (a^.mh_Node.ln_Type <> 0) then
          begin
            puddle := PULONG(Allocate(a, memSize));
            if (puddle <> nil) 
            then break
            else a := PMemHeader(a^.mh_Node.ln_Succ);
          end;
        end
        else
        begin
          size := poolHeader^.PuddleSize + sizeof(TMemHeader) + 2 * sizeof(ULONG);
 
          puddle := Exec.AllocMem(size, poolHeader^.MemoryFlags);
          if not (puddle <> nil)
          then exit(nil);
 
          puddle^ := size; inc(puddle);

          a := PMemHeader(puddle);

          a^.mh_Node.ln_Type    := NT_MEMORY;
          a^.mh_First           := PMemChunk(PBYTE(a) + sizeof(TMemHeader) + sizeof(PBYTE) );
          a^.mh_Lower           := a^.mh_First;
          a^.mh_First^.mc_Next  := nil;
          a^.mh_First^.mc_Bytes := poolHeader^.PuddleSize;
          a^.mh_Free            := a^.mh_First^.mc_Bytes;
          a^.mh_Upper           := PChar(a^.mh_First + a^.mh_Free);

          AddHead(PList(@poolHeader^.PuddleList), @a^.mh_Node);

          puddle := PULONG(Allocate(a, memSize));

          break;
        end;
      end;

      {*
         We do have to clear memory here. It may have been dirtied
         by somebody using it beforehand.
      *}
      if (poolHeader^.MemoryFlags and MEMF_CLEAR <> 0) then
      begin
        p := puddle;

        memSize  := memSize + 7;
        memSize  := memSize shr 3;

        while (memSize <> 0) do
        begin
          p^ := 0; inc(p);
          p^ := 0; inc(p);
          dec(memSize);
        end;
      end;
    end
    else
    begin
      size := memSize + sizeof(TMinNode) + 2 * sizeof(ULONG);

      puddle := PULONG(AllocMem(size, poolHeader^.MemoryFlags));
      if (puddle <> nil) then
      begin
        puddle^ := size; inc(puddle);

        AddTail(PList(@poolHeader^.PuddleList), PNode(puddle));

        puddle := PULONG(PMinNode(puddle) + 1);

        puddle^ := 0; inc(puddle);
      end;
    end;
  end;

  LibAllocPooled := puddle;
end;


procedure LibFreePooled(pool: APTR; memory: APTR; memSize: ULONG);
var
  poolHeader    : PPOOL absolute pool;
  puddle        : PULONG = nil;
var
  size          : ULONG;
  a             : PMemHeader;
begin
  // if (SysBase^.LibNode.lib_Version >= 39) then
  if (PLibrary(AOS_ExecBase)^.lib_Version >= 39) then
  begin
    FreePooled(poolHeader, memory, memSize);
    exit;
  end;

  if ((poolHeader <> nil) and (memory <> nil)) then
  begin
    puddle := PULONG(PMinNode(memory) - 1) - 1;

    if (poolHeader^.ThreshSize > memSize) then
    begin
      a := PMemHeader(@poolHeader^.PuddleList.mlh_Head);

      while true do
      begin
        a := PMemHeader(a^.mh_Node.ln_Succ);

        if (a^.mh_Node.ln_Succ = nil)
        then exit;

        if ((a^.mh_Node.ln_Type <> 0) and (memory >= a^.mh_Lower) and (memory < a^.mh_Upper))
        then break;
      end;

      Deallocate(a, memory, memSize);

      if (a^.mh_Free <> poolHeader^.PuddleSize)
      then exit;

      puddle := PULONG(@a^.mh_Node);
    end;

    Remove(PNode(puddle));

    dec(puddle);
    size := puddle^;

    FreeMem(puddle, size);
  end;
end;


function  LibCreatePool(requirements: ULONG; puddleSize: ULONG; threshSize: ULONG): Pointer; 
var
  pool: PPOOL;
begin
  if (PLibrary(AOS_ExecBase)^.lib_Version >= 39)
  then exit(CreatePool(requirements, puddleSize, threshSize));

  begin
    pool := nil;

    if (threshSize <= puddleSize) then
    begin
      pool := PPOOL(AllocMem(sizeof(TPOOL), MEMF_ANY));
      if (pool <> nil) then
      begin
        NEWLIST(@pool^.PuddleList);

        puddleSize := ((puddleSize + 7) and not 7);

        pool^.MemoryFlags := requirements;
        pool^.PuddleSize  := puddleSize;
        pool^.ThreshSize  := threshSize;
      end;
    end;

    result := APTR(pool);
  end;
end;


procedure LibDeletePool(pool: APTR);
var
  poolHeader    : PPOOL absolute pool;
var
  poolMem       : PULONG;
  size          : ULONG;
begin
  if (PLibrary(AOS_ExecBase)^.lib_Version >= 39)
  then DeletePool(poolHeader)
  else
  begin
    if (poolHeader <> nil) then
    begin

      poolMem := PULONG(RemHead(PList(@poolHeader^.PuddleList)));
      while (poolMem <> nil) do
      begin
        dec(poolMem);
        size := poolMem^;
        FreeMem(poolMem, size);

        poolMem := PULONG(RemHead(PList(@poolHeader^.PuddleList)));
      end;

      FreeMem(poolHeader, sizeof(TPOOL));
    end;
  end;
end;


procedure BeginIO(ioRequest: PIORequest);
Type
  TLocalCall = procedure(requester : POINTER; Base: Pointer); cdecl;
var
  Call  : TLocalCall;
  Base  : PDevice;
begin
  base := ioRequest^.io_Device;
  Call := TLocalCall(GetLibAdress(Base, 5));
  Call(ioRequest, Base);
end;


function  CreateExtIO(port: PMsgPort; iosize: ULONG): PIORequest;
var
  ioreq: PIORequest = nil;
begin
  if (port <> nil) then
  begin
    ioreq := AllocMem(iosize, MEMF_CLEAR or MEMF_PUBLIC);
    if (ioreq <> nil) then
    begin
      ioreq^.io_Message.mn_Node.ln_Type := NT_MESSAGE;
      ioreq^.io_Message.mn_Length       := iosize;
      ioreq^.io_Message.mn_ReplyPort    := port;
    end;
  end;
  CreateExtIO := ioreq;
end;


procedure DeleteExtIO(ioreq: PIORequest);
begin
  if (ioreq <> nil) then
  begin
    ioReq^.io_Message.mn_Node.ln_Type := $FF;
    ioReq^.io_Device                  := pDevice(-1);
    ioReq^.io_Unit                    := pUnit(-1);
    ExecFreeMem(ioreq, ioreq^.io_Message.mn_Length);
  end
end;


function  CreateStdIO(port: PMsgPort): PIOStdReq;
begin
  CreateStdIO := PIOStdReq(CreateExtIO(port, sizeof(TIOStdReq)))
end;


procedure DeleteStdIO(io: PIOStdReq);
begin
  DeleteExtIO(PIORequest(io))
end;


// AROS: this function was located in trinity.pas
function  CreatePort(name: STRPTR; pri: LONG): PMsgPort;
Var
  mp: PMsgPort;
begin
  mp := CreateMsgPort;

  if (mp <> nil) then
  begin
    mp^.mp_Node.ln_Name := name;
    mp^.mp_Node.ln_Pri  := pri;

    if (name <> nil) 
    then AddPort(mp);
  end;
  CreatePort := mp;
end;


// AROS: this function was located in trinity.pas
procedure DeletePort(mp: PMsgPort);
begin
  if (mp^.mp_Node.ln_Name <> nil)
  then RemPort(mp);

  DeleteMsgPort(mp);
end;


function  CreateTask(name: STRPTR; pri: LONG; initpc: APTR; stacksize: ULONG): PTask;
begin
  CreateTask := NewCreateTask(
  [
    LONG(TASKTAG_NAME)        , name,
    LONG(TASKTAG_PRI)         , pri,
    LONG(TASKTAG_PC)          , initpc,
    LONG(TASKTAG_STACKSIZE)   , stacksize,
    TAG_END
  ]);
end;


procedure DeleteTask(task: PTask);
begin
  RemTask(task);
end;


procedure NewList(list: PList); inline;
begin
  if Assigned(List) then
  begin
    List^.lh_TailPred := PNode(List);
    List^.lh_Tail := nil;
    List^.lh_Head := @List^.lh_Tail;
  end;
end;


procedure MergeSortList(l: PMinList; compare: TSortListCompareFunc; data: Pointer);
begin
  {$WARNING: MergeSortList() not implemented}
end;


function  NewRawDoFmt(const fomtString: STRPTR; PutChProc: TNewPutCharProc; PutChData: APTR; valueList: PLong): STRPTR;
var
  retVal: STRPTR = nil;
begin
  {$WARNING: NewRawDoFmt() not implemented}
  // requires generic va_list solution ?
  NewRawDoFmt := retVal;
end;



// ###########################################################################
// ###
// ###    Timer
// ###
// ###########################################################################



function  TimeDelay(timerUnit: LONG; Seconds: ULONG; MicroSeconds: ULONG): LONG;
var
  tr    : TTimeRequest;
  mp    : TMsgPort;
  error : UBYTE = 0;
begin
  //* Create a message port */
  mp.mp_Node.ln_Type := NT_MSGPORT;
  mp.mp_Node.ln_Pri := 0;
  mp.mp_Node.ln_Name := nil;
  mp.mp_Flags := PA_SIGNAL;
  mp.mp_SigTask := FindTask(nil);
  mp.mp_SigBit := SIGB_SINGLE;
  NEWLIST(@mp.mp_MsgList);

  tr.tr_node.io_Message.mn_Node.ln_Type := NT_MESSAGE;
  tr.tr_node.io_Message.mn_Node.ln_Pri := 0;
  tr.tr_node.io_Message.mn_Node.ln_Name := nil;
  tr.tr_node.io_Message.mn_ReplyPort := @mp;
  tr.tr_node.io_Message.mn_Length := sizeof(TTimeRequest);

  SetSignal(0, SIGF_SINGLE);

  if (OpenDevice('timer.device', timerUnit, PIORequest(@tr), 0) = 0) then
  begin
    tr.tr_node.io_Command := TR_ADDREQUEST;
    tr.tr_node.io_Flags := 0;
    tr.tr_time.tv_secs := Seconds;
    tr.tr_time.tv_micro := MicroSeconds;

    DoIO(PIORequest(@tr));

    CloseDevice(PIORequest(@tr));
    error := 1;
  end;

  TimeDelay := error;
end;



// ###########################################################################
// ###
// ###    DOS
// ###
// ###########################################################################



function  ErrorOutput: BPTR;
var
  me: PProcess;
begin
  me := PProcess(FindTask(nil));
  
  ErrorOutput := me^.pr_CES;
end;


function  SelectErrorOutput(fh: BPTR): BPTR;
var
  old: BPTR;
  me : PProcess;
begin
  // Get pointer to process structure
  me := PProcess(FindTask(nil));

  // Nothing spectacular
  old := me^.pr_CES;
  me^.pr_CES := fh;
  
  SelectErrorOutput := old;
end;



// ###########################################################################
// ###
// ###    Graphics
// ###
// ###########################################################################



procedure AddTOF(i: PIsrvstr; p: APTR; a: APTR);
begin
  {$WARNING: AddTOF() not implemented}
end;


procedure RemTOF(i: PIsrvstr);
begin
  {$WARNING: RemTOF() not implemented}
end;


function  CopyRegion(region: PRegion): PRegion;
var
  nreg: PRegion;
begin
  nreg := NewRegion;
  if (nreg <> nil) then
  begin
    if (OrRegionRegion(region, nreg))
    then exit(nreg);
    
    DisposeRegion(nreg);
  end;
  CopyRegion := nil;
end;


function  NewRectRegion(MinX: SmallInt; MinY: SmallInt; MaxX: SmallInt; MaxY: SmallInt): PRegion;
var
  region : PRegion;
  rect   : AGraphics.TRectangle;
  res    : LongBool;
begin
  region := NewRegion;
  
  if (region <> nil) then
  begin
    // rect := (MinX, MinY, MaxX, MaxY);
    rect.MinX := MinX;
    rect.MinY := MinY;
    rect.MaxX := MaxX;
    rect.MaxY := MaxY;
    res  := OrRectRegion(region, @rect);
    if res then exit(region);
    DisposeRegion(region);
  end;
  NewRectRegion := nil;
end;



// ###########################################################################
// ###
// ###    CyberGraphics
// ###
// ###########################################################################



function  LockBitMapTags(handle: APTR; const tags: Array of const): APTR;
var
  ArgList: TArgList;
begin
  {$WARNING: LockBitMapTag(s)List not implemented in ABIv0}
  AddArguments(ArgList, tags);
  LockBitMapTags := LockBitMapTagList(handle, @(ArgList[0]));
end;


procedure UnlockBitMapTags(handle: BPTR; const tags: Array of const);
var
  ArgList: TArgList;
begin
  {$WARNING: UnLockBitMapTag(s)List not implemented in ABIv0}
  AddArguments(ArgList, Tags);
  UnLockBitMapTagList(handle, @(ArgList[0]));
end;



// ###########################################################################
// ###
// ###    Intuition
// ###
// ###########################################################################



function  MACRO_CALLHOOKPKT(hook: PHook; object_: APTR; msg: APTR): IPTR;
var
  FuncPtr: THookFunctionProc; 
begin
  MACRO_CALLHOOKPKT := 0;
  if (hook = nil) or (object_ = nil) or (msg = nil) then Exit;
  if (hook^.h_Entry = 0) then Exit;
  FuncPtr := THookFunctionProc(Hook^.h_Entry);
  MACRO_CALLHOOKPKT := FuncPtr(hook, object_, msg);
end;


function  HookEntry(hook: PHook; obj: APTR; param: APTR): IPTR;
begin
  {$WARNING: HookEntry() not implemented}
  HookEntry := 0;
end;


function  CallHookA(hook: PHook; obj: APTR; param: APTR): IPTR;
begin
  CallHookA := MACRO_CALLHOOKPKT(hook, obj, param);
end;


function  CallHook(hook: PHook; obj: APTR; const params: Array of const): IPTR;
begin
  CallHook := MACRO_CALLHOOKPKT(hook, obj , ReadInLongs(params));
end;


// AROS: this function was located in intuition.pas
// Note: AROS' implementation adds asserts to obj, cl and message)
function  CoerceMethodA(cl: PIClass; Obj: PObject_; Message: APTR): IPTR;
begin
  if (obj = nil) or (cl = nil) then Exit(0);
  
  CoerceMethodA := MACRO_CALLHOOKPKT(PHook(cl), Obj, Message);
end;


// AROS: this function was located in intuition.pas
(*
function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: IPTR; const Args: array of const): IPTR;
var
  ArgList: TArgList;
begin
  AddArguments(ArgList,[MethodID]);
  AddArguments(ArgList, Args);
  CoerceMethod := CoerceMethodA(cl, Obj, @(ArgList[0])); 
end;
*)
// AROS: this function was located in AROS sources trunk
function  CoerceMethod(cl: PIClass; Obj: PObject_; MethodID: IPTR; const Args: array of const): IPTR;
var
  ArgList: TArgList;
begin
  if (obj = nil) or (cl = nil) then Exit(0);  

  AddArguments(ArgList,[MethodID]);
  AddArguments(ArgList, Args);
  CoerceMethod := MACRO_CALLHOOKPKT(PHook(cl), Obj, @(ArgList[0]));
end;


function  DoMethodA(obj: PObject_; Message: PMsg): IPTR;
begin
  if (obj = nil) then Exit(0);
  // AROS implements assertions on obj and message
  DoMethodA := MACRO_CALLHOOKPKT(PHook(OCLASS(obj)), obj, message);
end;


function  DoMethod(obj: PObject_; MethodID: IPTR; msgTags: array of const): IPTR;
var
  ArgList: TArgList;
begin
  // AROS implements assertion on obj
  if (obj = nil) then Exit(0);
  AddArguments(ArgList, [MethodID]);
  AddArguments(ArgList, msgTags);
  DoMethod := MACRO_CALLHOOKPKT(PHook(OCLASS(obj)), obj, @(ArgList[0]));
end;


function  DoSuperMethodA(cl: PIClass; obj: PObject_; message: PMsg): IPTR;
begin
  if (cl = nil) or (obj = nil) then Exit(0);
  DoSuperMethodA := MACRO_CALLHOOKPKT(PHook(cl^.cl_Super), obj, message);
end;


function  DoSuperMethod(cl: PIClass; obj: PObject_; MethodID: ULONG; const msgTags: array of const): IPTR;
var
  ArgList: TArgList;
begin
  if (cl = nil) or (obj = nil) then Exit(0);

  AddArguments(ArgList, [MethodID]);
  AddArguments(ArgList, msgTags);
  DoSuperMethod := MACRO_CALLHOOKPKT(PHook(cl^.cl_Super), Obj, @(ArgList[0]));
end;


function  DoSuperNewTagList(cl: PIClass; obj: PObject_; gadgetInfo: PGadgetInfo; tagList: PTagItem): IPTR;
begin
  if (cl = nil) or (obj = nil) then Exit(0);
  DoSuperNewTagList := DoSuperMethod(cl, obj, OM_NEW, [tagList, gadgetInfo]);
end;


function  DoSuperNewTags(cl: PIClass; obj: PObject_; gadgetInfo: PGadgetInfo; const tags: array of const): IPTR;
var
  ArgList: TArgList;
begin
  if (cl = nil) or (obj = nil) then Exit(0);

  AddArguments(ArgList, tags);
  DoSuperNewTags := DoSuperNewTagList(cl, obj, gadgetInfo, @(ArgList[0]));
end;


function  SetSuperAttrsA(cl: PIClass; Obj: PObject_; TagList: PTagItem): IPTR;
var
  ops: TopSet;
begin
  ops.MethodID := OM_SET;
  ops.ops_AttrList := TagList;
  ops.ops_GInfo := nil;
  Result := DoSuperMethodA(cl, obj, @ops);
end;


function  SetSuperAttrs(cl: PIClass; Obj: PObject_; Tags: array of const): IPTR;
var
  TagList: TTagsList;
  ops: TopSet;
begin
  AddTags(TagList, Tags);
  ops.MethodID := OM_SET;
  ops.ops_AttrList := GetTagPtr(TagList);
  ops.ops_GInfo := nil;
  Result := DoSuperMethodA(cl, obj, @ops);
end;



// ###########################################################################
// ###
// ###    Tooltypes
// ###
// ###########################################################################



var
  __alib_dObject : PDiskObject = nil;   //* Used for reading tooltypes */


function  ArgArrayInit(argc: ULONG; argv: PPChar): PPChar;
var
  olddir    : BPTR;
  startup   : PWBStartup;
begin
  startup := PWBStartup(argv);
  
  if (argc <> 0)
  then exit(argv);

  if (startup^.sm_NumArgs >= 1) then
  begin
    olddir := CurrentDir(PWBArg(startup^.sm_ArgList)[0].wa_Lock);
    __alib_dObject := GetDiskObject(PWBArg(startup^.sm_ArgList)[0].wa_Name);
    CurrentDir(olddir);
  end
  else
    exit(nil);

  if (__alib_dObject = nil)
  then exit(nil);
  
  ArgArrayInit := PPChar(__alib_dObject^.do_ToolTypes);
end;


procedure ArgArrayDone;
begin
  if (__alib_dObject <> nil)
  then FreeDiskObject(__alib_dObject);
end;


function  ArgInt(tt: PPChar; entry: STRPTR; defaultval: LongInt): LongInt;
var
  match : STRPTR;
begin
  match := FindToolType(tt, entry);
  if match = nil
  then ArgInt := defaultval
  else ArgInt := StrToIntDef(match, 0);
end;


function  ArgString(tt: PPChar; entry: STRPTR; defaultString: STRPTR): STRPTR;
var
  match: STRPTR;
begin
  match := FindToolType(tt, entry);
  if (match = nil)
  then ArgString := defaultstring
  else ArgString := match;
end;



// ###########################################################################
// ###
// ###    Commodities support, InputEvent
// ###
// ###########################################################################



const
  IESUBCLASS_NEWTABLET  = $03;


procedure FreeIEvents(ie: PInputEvent);
var
  next: PInputEvent;
begin
  next := ie;
  
  while (next <> nil) do
  begin
    next := ie^.ie_NextEvent;

    if (
      ( ie^.ie_Class = IECLASS_NEWPOINTERPOS ) and
      (
        (ie^.ie_SubClass = IESUBCLASS_TABLET) or
        (ie^.ie_SubClass = IESUBCLASS_NEWTABLET) or
        (ie^.ie_SubClass = IESUBCLASS_PIXEL)
      )
    )
    // then FreeVec(ie^.ie_EventAddress);
    then FreeVec(ie^.ie_position.ie_addr);

    FreeMem(ie, sizeof(TInputEvent));
    ie := next;
  end;
end;


function  InvertStringForwd(str: STRPTR; km: PKeyMap): PInputEvent;
var
  ieChain   : PInputEvent = nil;
  ie        : PInputEvent;
  first     : PInputEvent = nil;
  ansiCode  : UBYTE;
  start     : PChar;
var
  ix        : TIX;
  err       : LONG;

begin
  while (str <> nil) and (str^ <> #0) do
  begin
    ie := AllocMem(sizeof(TInputEvent), MEMF_PUBLIC or MEMF_CLEAR);
    if (ie = nil) then
    begin
      if (first <> nil)
      then FreeIEvents(first);
      exit(nil);;
    end;
         
    if (first = nil)
    then first := ie;
         
    if (ieChain <> nil)
    then ieChain^.ie_NextEvent := ie;            
         
    ieChain := ie;
        
    ie^.ie_Class := IECLASS_RAWKEY;
    //ie^.ie_EventAddress := nil;
    ie^.ie_position.ie_addr := nil;

    case (str^) of
      '\' :
      begin
        inc(str);
        case (str^) of
          't': ansiCode := Ord(#09);  // tab
          'r', 
          'n': ansiCode := Ord(#10);
          '\': ansiCode := Ord('\');
          else 
               //* FIXME: What to do if "\x" comes? */
               //* stegerg: This? */
               ansiCode := Ord(str^);
        end;
  
        if (InvertKeyMap(ansiCode, ie, km) = FALSE) then
        begin
          FreeIEvents(first);
          exit(nil);
        end;

        inc(str);
      end;

      '<' :
      begin
        inc(str);
        start := str;

        while (str^ <> #0) and (str^ <> '>') do inc(str);
        begin
          ix := default(TIX);

          str^ := #0;
          err := ParseIX(start, @ix);
          str^ := '>'; inc(str);

          if (err < 0) then
          begin
            FreeIEvents(first);
            exit(nil);
          end;

          ie^.ie_Class     := ix.ix_Class;
          ie^.ie_Code      := ix.ix_Code;
          ie^.ie_Qualifier := ix.ix_Qualifier;
        end;
      end;

      else
      begin
        if (InvertKeyMap(Ord(str^), ie, km) = FALSE) then
        begin
          inc(str);
          FreeIEvents(first);
          exit(nil);
        end;
        inc(str);
      end;
    end;
  end;
  InvertStringForwd := first;
end;


function  InvertString(str: STRPTR; km: PKeyMap): PInputEvent;
var
  first, second, third, fourth: PInputEvent;
begin
  first := InvertStringForwd(str, km);

  if (first <> nil) then
  begin
    fourth := first;
    third := first^.ie_NextEvent;
    while (third <> nil) do
    begin
      second := first;
      first := third;
      third := first^.ie_NextEvent;
      first^.ie_NextEvent := second;
    end;
    fourth^.ie_NextEvent := nil;
  end;
  InvertString := first;
end;



// ###########################################################################
// ###
// ###    Commodities
// ###
// ###########################################################################



// AROS: this function/macro was located in commodities.pas
function  CxCustom(action: Pointer; id: LONG): PCxObj;
begin
  CxCustom := CreateCxObj(LONG(CX_CUSTOM), IPTR(action), LONG(id));
end;


// AROS: this function/macro was located in commodities.pas
function  CxDebug(id: LONG): PCxObj;
begin
  CxDebug := CreateCxObj(LONG(CX_DEBUG), IPTR(id), 0);
end;


// AROS: this function/macro was located in commodities.pas
function  CxFilter(description: STRPTR): PCxObj;
begin
  CxFilter := CreateCxObj(LONG(CX_FILTER), IPTR(description), 0);
end;


// AROS: this function/macro was located in commodities.pas
function  CxSender(port: PMsgPort; id: LONG): PCxObj;
begin 
  CxSender := CreateCxObj(LONG(CX_SEND), IPTR(port), LONG(id));
end;


// AROS: this function/macro was located in commodities.pas
function  CxSignal(task: PTask; signal: LONG): PCxObj;
begin 
  CxSignal := CreateCxObj(LONG(CX_SIGNAL), IPTR(task), LONG(signal));
end;


// AROS: this function/macro was located in commodities.pas
function  CxTranslate(ie: PInputEvent): PCxObj;
begin
  CxTranslate := CreateCxObj(LONG(CX_TRANSLATE), IPTR(ie), 0);
end;


function  HotKey(description: STRPTR; port: PMsgPort; id: LONG): PCxObj;
var
  filter        : PCxObj;       //* The objects making up the hotkey */
  sender        : PCxObj;       //* functionality... */
  translator    : PCxObj;
begin
  filter := CxFilter(description);
  
  if (filter = nil)
  then exit(nil);

  sender := CxSender(port, id);
  if (sender = nil) then
  begin
    DeleteCxObj(filter);
    exit(nil);
  end;

  AttachCxObj(filter, sender);

  //* Create the commodities equivalent of NIL: */
  translator := CxTranslate(nil);
  if (translator = nil) then
  begin
    DeleteCxObjAll(filter);
    exit(nil);
  end;

  AttachCxObj(filter, translator);

  HotKey := filter;
end;



// ###########################################################################
// ###
// ###    Rexx
// ###
// ###########################################################################



function  GetRexxVar(msg: PRexxMsg; const varname: STRPTR; value: PPChar): LONG;
var
  RexxSysBase   : PLibrary = nil;
  msg2          : PRexxMsg = nil;
  msg3          : PRexxMsg;
  port          : PMsgPort = nil;
  rexxport      : PMsgPort;
  retval        : LONG = ERR10_003;
begin
  {$IFDEF AROS}
  RexxSysBase := Rexx.RexxSysBase;
  {$ELSE}
  RexxSysBase := OpenLibrary('rexxsyslib.library', 0);
  {$ENDIF}
  if (RexxSysBase <> nil) then
  begin
    if IsRexxMsg(msg) then
    begin

      rexxport := FindPort('REXX');
      if (rexxport <> nil) then
      begin
        port := CreateMsgPort;
        if (port <> nil) then
        begin
          msg2 := CreateRexxMsg(port, nil, nil);
          if (msg2 <> nil) then
          begin
            msg2^.rm_Private1 := msg^.rm_Private1;
            msg2^.rm_Private2 := msg^.rm_Private2;
            msg2^.rm_Action := LongInt(RXGETVAR) or 1;
            msg2^.rm_Args[0] := IPTR(CreateArgstring(varname, strlen(varname)));
            if (msg2^.rm_Args[0] <> 0) then
            begin
              PutMsg(rexxport, PMessage(msg2));
              msg3 := nil;
              while (msg3 <> msg2) do
              begin
                WaitPort(port);
                msg3 := PRexxMsg(GetMsg(port));
                if (msg3 <> msg2) then ReplyMsg(PMessage(msg3));
              end;

              if (msg3^.rm_Result1 = RC_OK) then
              begin
               value^ := PChar(msg3^.rm_Result2);
               retval := RC_OK;
              end
              else retval := LONG(msg3^.rm_Result2);
            end;
          end;
        end;
      end
      else retval := ERR10_013;
    end
    else retval := ERR10_010;
  end;

  if (msg2 <> nil) then
  begin
    if (msg2^.rm_Args[0] <> 0) then DeleteArgstring(PChar(msg2^.rm_Args[0]));
    DeleteRexxMsg(msg2);
  end;

  if (port <> nil) then DeletePort(port);
  {$IFNDEF AROS}
  if (RexxSysBase <> nil) then CloseLibrary(RexxSysBase);
  {$ENDIF}

  GetRexxVar := retval;
end;


function  SetRexxVar(msg: PRexxMsg; const varname: STRPTR; value: PChar; len: ULONG): LONG;
var
  RexxSysBase   : PLibrary = nil;
  msg2          : PRexxMsg = nil;
  msg3          : PRexxMsg;
  port          : PMsgPort = nil;
  rexxport      : PMsgPort;
  retval        : LONG = ERR10_003;
begin
  {$IFDEF AROS}
  RexxSysBase := Rexx.RexxSysBase;
  {$ELSE}
  RexxSysBase := OpenLibrary('rexxsyslib.library', 0);
  {$ENDIF}
  if Assigned(RexxSysBase) then
  begin
    if IsRexxMsg(msg) then
    begin
      rexxport := FindPort('REXX');
      if Assigned(rexxport) then
      begin
        port := CreateMsgPort;
        if Assigned(port) then
        begin
          msg2 := CreateRexxMsg(port, nil, nil);
          if Assigned(msg2) then
          begin

            msg2^.rm_Private1 := msg^.rm_Private1;
            msg2^.rm_Private2 := msg^.rm_Private2;
            msg2^.rm_Action := LongInt(RXSETVAR) or 2;
            msg2^.rm_Args[0] := IPTR(CreateArgstring(varname, strlen(varname)));
            msg2^.rm_Args[1] := IPTR(CreateArgstring(value, len));
            
            if ( (msg2^.rm_Args[0] <> 0) and (msg2^.rm_Args[1] <> 0)) then
            begin

              PutMsg(rexxport, PMessage(msg2));
              msg3 := nil;
              while (msg3 <> msg2) do
              begin
                WaitPort(port);
                msg3 := PRexxMsg(GetMsg(port));
                if (msg3 <> msg2) then ReplyMsg(PMessage(msg3));
              end;

              if (msg3^.rm_Result1 = RC_OK) 
              then retval := 0
              else retval := LONG(msg3^.rm_Result2);
            end;
            if (msg2^.rm_Args[0] <> 0) then DeleteArgstring(PChar(msg2^.rm_Args[0]));
            if (msg2^.rm_Args[1] <> 0) then DeleteArgstring(PChar(msg2^.rm_Args[1]));            
            DeleteRexxMsg(msg2);
          end;
          DeletePort(port);
        end;
      end
      else retval := ERR10_013;
    end
    else retval := ERR10_010;
    {$IFNDEF AROS}
    CloseLibrary(RexxSysBase);
    {$ENDIF}
  end;
  
  SetRexxVar := RetVal;
end;


function  CheckRexxMsg(msg: PRexxMsg): LongBool;
var
  RexxSysBase   : PLibrary = nil;
  msg2          : PRexxMsg = nil;
  msg3          : PRexxMsg;
  port          : PMsgPort = nil;
  rexxport      : PMsgPort;
  retval        : LongBool = FALSE;  
begin
  {$IFDEF AROS}
  RexxSysBase := Rexx.RexxSysBase;
  {$ELSE}
  RexxSysBase = OpenLibrary('rexxsyslib.library', 0);
  {$ENDIF}
  if Assigned(RexxSysBase) then
  begin
    if IsRexxMsg(msg) then
    begin
      rexxport := FindPort('REXX');
      if Assigned(rexxport) then
      begin
        port := CreateMsgPort;
        if Assigned(port) then
        begin
          msg2 := CreateRexxMsg(port, nil, nil);
          if Assigned(msg2) then
          begin

            msg2^.rm_Private1 := msg^.rm_Private1;
            msg2^.rm_Private2 := msg^.rm_Private2;
            msg2^.rm_Action := LongInt(RXCHECKMSG);

            PutMsg(rexxport, PMessage(msg2));
            msg3 := nil;
            while (msg3 <> msg2) do
            begin
              WaitPort(port);
              msg3 := PRexxMsg(GetMsg(port));
              if (msg3 <> msg2) then ReplyMsg(PMessage(msg3));
            end;

            retval := msg3^.rm_Result1 = RC_OK;

            DeleteRexxMsg(msg2);
          end;
          DeletePort(port);
        end;
      end;
    end;
    {$IFNDEF AROS}
    CloseLibrary(RexxSysBase);
    {$ENDIF}
  end;
  
  CheckRexxMsg := RetVal;
end;



end.
