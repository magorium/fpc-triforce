unit commodities;


{$MODE OBJFPC}{$H+}

{$UNITPATH ../Trinity/}


{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
{$PACKRECORDS 2}
{$ENDIF}


interface


uses 
  Exec, InputEvent, Keymap,
  TriniTypes;


const
  COMMODITIESNAME   : PChar     = 'commodities.library';
  CXBase            : PLibrary  = nil;


// ###### libraries/commodity.h #############################################


Type
  CxObj     = SLONG;
  pCxObj    = ^CxObj;

  CxMsg     = SLONG;
  pCXMsg    = ^CxMsg;

  TPFL      = function: PLONG;


Type
  PNewBroker = ^TNewBroker;
  TNewBroker = 
  record
   nb_Version           : SBYTE;
   nb_Name              : STRPTR;
   nb_Title             : STRPTR;
   nb_Descr             : STRPTR;
   nb_Unique            : SWORD;
   nb_Flags             : SWORD;
   nb_Pri               : SBYTE;
   nb_Port              : pMsgPort;
   nb_ReservedChannel   : SWORD;
  end;


Const
  //* nb_Version */
  NB_VERSION        =  5;           // Version of NewBroker structure

  //* nb_Unique */
  NBU_DUPLICATE     = 0;
  NBU_UNIQUE        = (1 shl 0);    // will not allow duplicates
  NBU_NOTIFY        = (1 shl 1);    // sends CXM_UNIQUE to existing broker

  //* nb_Flags */
  COF_SHOW_HIDE     = (1 shl 2);
  {$IFDEF AROS}
  COF_ACTIVE        = (1 shl 1);    //* Object is active - undocumented in AmigaOS */
  {$ENDIF}

  CBD_NAMELEN       = 24;           //* length of nb_Name */
  CBD_TITLELEN      = 40;           //* length of nb_Title */
  CBD_DESCRLEN      = 40;           //* length of nb_Descr */

  //* return values of CxBroker() */
  CBERR_OK          =  0;           // No error
  CBERR_SYSERR      =  1;           // System error , no memory, etc
  CBERR_DUP         =  2;           // uniqueness violation
  CBERR_VERSION     =  3;           // didn't understand nb_VERSION

  //* return values of CxObjError() */
  COERR_ISNULL      =  1;           // you called CxError(nil)
  COERR_NULLATTACH  =  2;           // someone attached NULL to my list
  COERR_BADFILTER   =  4;           // a bad filter description was given
  COERR_BADTYPE     =  8;           // unmatched type-specific operation

  {$IFDEF AMIGA}
  CXM_UNIQUE        = 16;           // sent down broker by CxBroker() - obsolete
  {$ENDIF}
  CXM_IEVENT        = (1 shl 5);
  CXM_COMMAND       = (1 shl 6);

  // ID values
  CXCMD_DISABLE     = (15);         // please disable yourself
  CXCMD_ENABLE      = (17);         // please enable yourself
  CXCMD_APPEAR      = (19);         // open your window, if you can
  CXCMD_DISAPPEAR   = (21);         // go dormant
  CXCMD_KILL        = (23);         // go away for good 
  CXCMD_UNIQUE      = (25);         // someone tried to create a broker with your name.  Suggest you Appear.
  CXCMD_LIST_CHG    = (27);         // Used by Exchange program. Someone has changed the broker list

  // Commodities Object Types
  CX_INVALID        =  0;           // not a valid object (probably mil)
  CX_FILTER         =  1;           // input event messages only
  CX_TYPEFILTER     =  2;           // filter on message type
  CX_SEND           =  3;           // sends a message
  CX_SIGNAL         =  4;           // sends a signal
  CX_TRANSLATE      =  5;           // translates IE into chain
  CX_BROKER         =  6;           // application representative
  CX_DEBUG          =  7;           // dumps kprintf to serial port
  CX_CUSTOM         =  8;           // application provids function
  CX_ZERO           =  9;           // system terminator node

  {$IFDEF AMIGA}
  // return values for BrokerCommand(): obsolete
  CMDE_OK           = (0);
  CMDE_NOBROKER     = (-1);
  CMDE_NOPORT       = (-2);
  CMDE_NOMEM        = (-3);
  {$ENDIF}


  function  CxFilter(d: STRPTR): PCxObj; inline;
  function  CxSender(port: PMsgPort; id: SLONG): PCxObj; inline;
  function  CxSignal(task: PTask; signal: SLONG): PCxObj; inline;
  function  CxTranslate(ie: PInputEvent): PCxObj; inline;
  function  CxDebug(id: SLONG): PCxObj; inline;
  function  CxCustom(action: Pointer; id: SLONG): PCxObj; inline;


Type
  PInputXpression = ^TInputXpression;
  TInputXpression = 
  record
   ix_Version   : UBYTE;            // must be set to IX_VERSION 
   ix_Class     : UBYTE;            // class must match exactly

   ix_Code      : UWORD;            // Bits that we want
   ix_CodeMask  : UWORD;            // Set bits here to indicate which bits in ix_Code are don't care bits.

   ix_Qualifier : UWORD;            // Bits that we want
   ix_QualMask  : UWORD;            // Set bits here to indicate which bits in ix_Qualifier are don't care bits
   ix_QualSame  : UWORD;            // synonyms in qualifier
  end;

  PIX = ^TIX;
  IX  = tInputXpression;
  TIX = IX;



Const
  //* ix_Version */
  IX_VERSION        = 2;

  //* ix_QualMask */
  IX_NORMALQUALS    = $7FFF;        // for QualMask field: avoid RELATIVEMOUSE

  //* ix_QualSame */
  IXSYM_SHIFT       = (1 shl 0);    // left- and right- shift are equivalent
  IXSYM_CAPS        = (1 shl 1);    // either shift or caps lock are equivalent
  IXSYM_ALT         = (1 shl 2);    // left- and right- alt are equivalent
  // corresponding QualSame masks
  IXSYM_SHIFTMASK   = ( IEQUALIFIER_LSHIFT + IEQUALIFIER_RSHIFT   );
  IXSYM_CAPSMASK    = ( IXSYM_SHIFTMASK    + IEQUALIFIER_CAPSLOCK );
  IXSYM_ALTMASK     = ( IEQUALIFIER_LALT   + IEQUALIFIER_RALT     );

  {$IF DEFINED(AROS) or DEFINED(MORPHOS)}
  // macro 122 #define NULL_IX(ix) ((ix)->ix_Class == IECLASS_NULL)
  {$ENDIF}


  {$IFDEF AROS}
Type
  {
  * Nodes of the list got from CopyBrokerList(). This function is used by
  * Exchange to get the current brokers. This structure is the same as
  * in AmigaOS and MorphOS, but it is undocumented there. 
  }
  PBrokerCopy = ^TBrokerCopy;
  TBrokerCopy = 
  record
     bc_Node    : TNode;
     bc_Name    : packed array [0..Pred(CBD_NAMELEN)] of Char;
     bc_Title   : packed array [0..Pred(CBD_TITLELEN)] of Char;
     bc_Descr   : packed array [0..Pred(CBD_DESCRLEN)] of Char;
     bc_Task    : PTask;            //* Private, do not use this */
     bc_Port    : PMsgPort;         //* Private, do not use this */
     bc_Dummy   : UWORD;
     bc_Flags   : ULONG;
  end;  
  {$ENDIF}


  {$IFDEF AMIGA}
  function  ActivateCxObj(co: PCxObj location 'a0'; tru: SLONG location 'd0'): SLONG;                                           syscall CxBase 042;
  procedure AddIEvents(events: PInputEvent location 'a0');                                                                      syscall CxBase 180;
  procedure AttachCxObj(headObj: PCxObj location 'a0'; co: PCxObj location 'a1');                                               syscall CxBase 084;
  procedure ClearCxObjError(co: PCxObj location 'a0');                                                                          syscall CxBase 072;
  //function  CreateCxObj(typ: ULONG location 'd0'; arg1: SLONG location 'a1'; arg2: SLONG location 'a2'): PCxObj;                syscall CxBase 030;
  function  CreateCxObj(typ: ULONG location 'd0'; arg1: SLONG location 'a0'; arg2: SLONG location 'a1'): PCxObj;                syscall CxBase 030;
  function  CxBroker(nb: PNewBroker location 'a0'; error: PSLONG location 'd0'): PCxObj;                                        syscall CxBase 036;
  function  CxMsgData(cxm: PCxMsg location 'a0'): APTR;                                                                         syscall CxBase 144;
  function  CxMsgID(cxm: PCxMsg location 'a0'): SLONG;                                                                          syscall CxBase 150;
  function  CxMsgType(cxm: PCxMsg location 'a0'): ULONG;                                                                        syscall CxBase 138;
  function  CxObjError(co: PCxObj location 'a0'): SLONG;                                                                        syscall CxBase 066;
  function  CxObjType(co: PCxObj location 'a0'): ULONG;                                                                         syscall CxBase 060;
  procedure DeleteCxObj(co: PCxObj location 'a0');                                                                              syscall CxBase 048;
  procedure DeleteCxObjAll(co: PCxObj location 'a0');                                                                           syscall CxBase 054;
  procedure DisposeCxMsg(cxm: PCxMsg location 'a0');                                                                            syscall CxBase 168;
  procedure DivertCxMsg(cxm: PCxMsg location 'a0'; headObj: PCxObj location 'a1'; returnObj: PCxObj location 'a2');             syscall CxBase 156;
  procedure EnqueueCxObj(headObj: PCxObj location 'a0'; co: PCxObj location 'a1');                                              syscall CxBase 090;
  procedure InsertCxObj(headObj: PCxObj location 'a0'; co: PCxObj location 'a1'; pred: PCxObj location 'a2');                   syscall CxBase 096;
  function  InvertKeyMap(ansiCode: ULONG location 'd0'; event: PInputEvent location 'a0'; km: PKeyMap location 'a1'): LBOOL;    syscall CxBase 174;
  function  MatchIX(event: PInputEvent location 'a0'; ix: PIX location 'a1'): LBOOL;                                            syscall CxBase 204;
  function  ParseIX(description: STRPTR location 'a0'; ix: PIX location 'a1'): SLONG;                                           syscall CxBase 132;
  procedure RemoveCxObj(co: PCxObj location 'a0');                                                                              syscall CxBase 102;
  procedure RouteCxMsg(cxm: PCxMsg location 'a0'; co: PCxObj location 'a1');                                                    syscall CxBase 162;
  function  SetCxObjPri(co: PCxObj location 'a0'; pri: SLONG location 'd0'): SLONG;                                             syscall CxBase 078;
  procedure SetFilter(filter: PCxObj location 'a0'; txt: STRPTR location 'a1');                                                 syscall CxBase 120;
  procedure SetFilterIX(filter: PCxObj location 'a0'; ix: PIX location 'a1');                                                   syscall CxBase 126;
  procedure SetTranslate(translator: PCxObj location 'a0'; events: PInputEvent location 'a1');                                  syscall CxBase 114;
  { overlay functions}
  function  ParseIX(description: string; ix: PIX): SLONG;
  procedure SetFilter(filter: PCxObj; txt: string);
  {$ENDIF}


  {$IFDEF AROS}
  function  CreateCxObj(typ: ULONG; arg1: IPTR; arg2: IPTR): PCxObj;                  syscall CxBase 005;
  function  CxBroker(nb: PNewBroker; error: PSLONG): PCxObj;                          syscall CxBase 006;
  function  ActivateCxObj(co: PCxObj; tru: SLONG): SLONG;                             syscall CxBase 007;
  procedure DeleteCxObj(co: PCxObj);                                                  syscall CxBase 008;
  procedure DeleteCxObjAll(co: PCxObj);                                               syscall CxBase 009;
  function  CxObjType(co: PCxObj): ULONG;                                             syscall CxBase 010;
  function  CxObjError(co: PCxObj): SLONG;                                            syscall CxBase 011;
  procedure ClearCxObjError(co: PCxObj);                                              syscall CxBase 012;
  function  SetCxObjPri(co: PCxObj; pri: SLONG): SLONG;                               syscall CxBase 013;
  procedure AttachCxObj(headObj: PCxObj; co: PCxObj);                                 syscall CxBase 014;
  procedure EnqueueCxObj(headObj: PCxObj; co: PCxObj);                                syscall CxBase 015;
  procedure InsertCxObj(headObj: PCxObj; co: PCxObj; pred: PCxObj);                   syscall CxBase 016;
  procedure RemoveCxObj(co: PCxObj);                                                  syscall CxBase 017;

  procedure SetTranslate(translator: PCxObj; events: PInputEvent);                    syscall CxBase 019;
  procedure SetFilter(filter: PCxObj; txt: STRPTR);                                   syscall CxBase 020;
  procedure SetFilterIX(filter: PCxObj; ix: PIX);                                     syscall CxBase 021;
  function  ParseIX(const desc: STRPTR; ix: PIX): SLONG;                              syscall CxBase 022;
  function  CxMsgType(cxm: PCxMsg): ULONG;                                            syscall CxBase 023;
  function  CxMsgData(cxm: PCxMsg): APTR;                                             syscall CxBase 024;
  function  CxMsgID(cxm: PCxMsg): SLONG;                                              syscall CxBase 025;
  procedure DivertCxMsg(cxm: PCxMsg; headObj: PCxObj; returnObj: PCxObj);             syscall CxBase 026;
  procedure RouteCxMsg(cxm: PCxMsg; co: PCxObj);                                      syscall CxBase 027;
  procedure DisposeCxMsg(cxm: PCxMsg);                                                syscall CxBase 028;
  function  InvertKeyMap(ansiCode: ULONG; event: PInputEvent; km: PKeyMap): LBOOL;    syscall CxBase 029;
  procedure AddIEvents(events: PInputEvent);                                          syscall CxBase 030;
  function  CopyBrokerList(CopyofList: PList): SLONG;                                 syscall CxBase 031;
  procedure FreeBrokerList(brokerList: PList);                                        syscall CxBase 032;
  function  BrokerCommand(name: STRPTR; command: ULONG): ULONG;                       syscall CxBase 033;
  function  MatchIX(event: PInputEvent; ix: PIX): LBOOL;                              syscall CxBase 034;
  {$ENDIF}


  {$IFDEF MORPHOS}
  function  CxBroker(const nb: PNewBroker location 'a0'; error: PSLONG location 'd0'): PCxObj;                                      syscall CxBase 036;
  function  CxObjError(const co: PCxObj location 'a0'): SLONG;                                                                      syscall CxBase 066;
  procedure DeleteCxObjAll(co: PCxObj location 'a0');                                                                               syscall CxBase 054;
  procedure RemoveCxObj(co: PCxObj location 'a0');                                                                                  syscall CxBase 102;
  function  CxMsgType(const cxm: PCxMsg location 'a0'): ULONG;                                                                      syscall CxBase 138;
  function  ActivateCxObj(co: PCxObj location 'a0'; tru: SLONG location 'd0'): SLONG;                                               syscall CxBase 042;
  procedure ClearCxObjError(co: PCxObj location 'a0');                                                                              syscall CxBase 072;
  procedure AddIEvents(events: PInputEvent location 'a0');                                                                          syscall CxBase 180;
  procedure DeleteCxObj(co: PCxObj location 'a0');                                                                                  syscall CxBase 048;
  function  CreateCxObj(typ: ULONG location 'd0'; arg1: SLONG location 'a0'; arg2: SLONG location 'a1'): PCxObj;                    syscall CxBase 030;
  procedure AttachCxObj(headObj: PCxObj location 'a0'; co: PCxObj location 'a1');                                                   syscall CxBase 084;
  procedure InsertCxObj(headObj: PCxObj location 'a0'; co: PCxObj location 'a1'; pred: PCxObj location 'a2');                       syscall CxBase 096;
  function  SetCxObjPri(co: PCxObj location 'a0'; pri: SLONG location 'd0'): SLONG;                                                 syscall CxBase 078;
  procedure EnqueueCxObj(headObj: PCxObj location 'a0'; co: PCxObj location 'a1');                                                  syscall CxBase 090;
  function  MatchIX(const event: PInputEvent location 'a0'; const ix: PIX location 'a1'): LBOOL;                                    syscall CxBase 204;
  function  CxMsgID(const cxm: PCxMsg location 'a0'): SLONG;                                                                        syscall CxBase 150;
  procedure DivertCxMsg(cxm: PCxMsg location 'a0'; headObj: PCxObj location 'a1'; returnObj: PCxObj location 'a2');                 syscall CxBase 156;
  procedure RouteCxMsg(cxm: PCxMsg location 'a0'; co: PCxObj location 'a1');                                                        syscall CxBase 162;
  procedure SetFilter(filter: PCxObj location 'a0'; const txt: STRPTR location 'a1');                                               syscall CxBase 120;
  procedure SetFilterIX(filter: PCxObj location 'a0'; const ix: PIX location 'a1');                                                 syscall CxBase 126;
  function  CxObjType(const co: PCxObj location 'a0'): ULONG;                                                                       syscall CxBase 060;
  procedure DisposeCxMsg(cxm: PCxMsg location 'a0');                                                                                syscall CxBase 168;
  procedure SetTranslate(translator: PCxObj location 'a0'; events: PInputEvent location 'a1');                                      syscall CxBase 114;
  function  ParseIX(const description: STRPTR location 'a0'; ix: PIX location 'a1'): SLONG;                                         syscall CxBase 132;
  function  CxMsgData(const cxm: PCxMsg location 'a0'): APTR;                                                                       syscall CxBase 144;
  function  InvertKeyMap(ansiCode: ULONG location 'd0'; event: PInputEvent location 'a0'; const km: PKeyMap location 'a1'): LBOOL;  syscall CxBase 174;
  {$ENDIF}


implementation


//
// macro's
//


function  CxFilter(d: STRPTR): PCxObj;
begin
  {$IFDEF AROS} 
  Result := CreateCxObj(SLONG(CX_FILTER),    IPTR(d),      0);
  {$ELSE}
  Result := CreateCxObj(     (CX_FILTER),   SLONG(d),      0);
  {$ENDIF}  
end;


function  CxSender(port: PMsgPort; id: SLONG): PCxObj;
begin 
  {$IFDEF AROS} 
  Result := CreateCxObj(SLONG(CX_SEND),      IPTR(port),   SLONG(id));
  {$ELSE}
  Result := CreateCxObj(     (CX_SEND),     SLONG(port),   SLONG(id));
  {$ENDIF}
end;


function  CxSignal(task: PTask; signal: SLONG): PCxObj;
begin 
  {$IFDEF AROS} 
  Result := CreateCxObj(SLONG(CX_SIGNAL),    IPTR(task),   SLONG(signal));
  {$ELSE}
  Result := CreateCxObj(     (CX_SIGNAL),   SLONG(task),   SLONG(signal));
  {$ENDIF}
end;


function  CxTranslate(ie: PInputEvent): PCxObj;
begin
  {$IFDEF AROS} 
  Result := CreateCxObj(SLONG(CX_TRANSLATE), IPTR(ie),     0);
  {$ELSE}
  Result := CreateCxObj(     (CX_TRANSLATE),SLONG(ie),     0);
  {$ENDIF}
end;


function  CxDebug(id: SLONG): PCxObj;
begin
  {$IFDEF AROS} 
  Result := CreateCxObj(SLONG(CX_DEBUG),     IPTR(id),     0);
  {$ELSE}
  Result := CreateCxObj(     (CX_DEBUG),         (id),     0);
  {$ENDIF}
end;


function  CxCustom(action: Pointer; id: SLONG): PCxObj;
begin
  {$IFDEF AROS} 
  Result := CreateCxObj(SLONG(CX_CUSTOM),    IPTR(action), SLONG(id));
  {$ELSE}
  Result := CreateCxObj(     (CX_CUSTOM),   SLONG(action), SLONG(id));
  {$ENDIF}
end;


//
// overloads
//


{$IFDEF AMIGA}
function  ParseIX(description: string; ix: PIX): SLONG;
begin
  ParseIX := ParseIX(PChar(description), ix);
end;


procedure SetFilter(filter: PCxObj; txt: string);
begin
  SetFilter(filter, PChar(txt));
end;
{$ENDIF}



Initialization

{$IFDEF AROS}
  CxBase := OpenLibrary(COMMODITIESNAME, 0);
{$ENDIF}



Finalization

{$IFDEF AROS}
  CloseLibrary(CxBase);
{$ENDIF}

end.
