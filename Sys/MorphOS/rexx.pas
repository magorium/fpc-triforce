unit rexx;


//
// Note that AROS uses a slightly different implementation because it uses 
// Regina as Arexx alternative -> results in messy ifdefs 
//


{$MODE OBJFPC}{$H+}

{$UNITPATH ../Trinity/}

{$PACKRECORDS 2}

interface


uses 
  Exec,
  {$IFDEF AROS}
  AmigaDOS,
  {$ENDIF}
  TriniTypes;


const
  REXXSYSLIBNAME    : PChar = 'rexxsyslib.library';

var 
  RexxSysBase       : PLibrary = nil;



// ###### rexx/storage.h ####################################################



{$IFDEF AROS}
Type
  PRexxMsg = ^TRexxMsg;
  TRexxMsg = record
    rm_Node         : TMessage;
    rm_Private1     : IPTR;     // Was rm_TaskBlock
    rm_Private2     : IPTR;     // Was rm_LibBase
    rm_Action       : SLONG;    // What to do ?
    rm_Result1      : SLONG;    // The first result as a number
    rm_Result2      : IPTR;     // The second result, most of the time an argstring
    rm_Args         : array [0..Pred(16)] of IPTR;  // 16 possible arguments for function calls
    rm_PassPort     : PMsgPort;
    rm_CommAddr     : STRPTR;   // The starting host environment
    rm_FileExt      : STRPTR;   // The file extension for macro files
    rm_Stdin        : BPTR;     // Input filehandle to use
    rm_Stdout       : BPTR;     // Output filehandle to use
    rm_Unused1      : SLONG;    // Was rm_avail
  end;
  {
  * AROS comment: rm_Private1 and rm_Private2 are implementation specific.
  * When sending a message that is meant to be handled in the same environment 
  * as another message one received from somewhere, these fields have to be 
  * copied to the new message.
  }


const
  // maximum arguments
  MAXRMARG          = 15;

  // Commands for rm_Action
  RXCOMM            = $01000000;
  RXFUNC            = $02000000;
  RXCLOSE           = $03000000;
  RXQUERY           = $04000000;
  RXADDFH           = $07000000;
  RXADDLIB          = $08000000;
  RXREMLIB          = $09000000;
  RXADDCON          = $0A000000;
  RXREMCON          = $0B000000;
  RXTCOPN           = $0C000000;
  RXTCCLS           = $0D000000;

  // Some commands added for AROS and regina only
  RXADDRSRC         = $F0000000;    // Will register a resource node to call the clean up function
                                    // from when the rexx script finishes
                                    // The rexx implementation is free to use the list node fields
                                    // for their own purpose.
  RXREMRSRC         = $F1000000;    // Will unregister an earlier registered resource node
  RXCHECKMSG        = $F2000000;    // Check if private fields are from the Rexx interpreter
  RXSETVAR          = $F3000000;    // Set a variable with a given to a given value
  RXGETVAR          = $F4000000;    // Get the value of a variable with the given name

  RXCODEMASK        = $FF000000;
  RXARGMASK         = $0000000F;

  // Flags that can be combined with the commands
  RXFB_NOIO         = 16;
  RXFB_RESULT       = 17;
  RXFB_STRING       = 18;
  RXFB_TOKEN        = 19;
  RXFB_NONRET       = 20;
  
  RXFB_FUNCLIST     = 5;    // AROS specific

  // Convert from bit number to number
  RXFF_NOIO         = (1 shl RXFB_NOIO);
  RXFF_RESULT       = (1 shl RXFB_RESULT);
  RXFF_STRING       = (1 shl RXFB_STRING);
  RXFF_TOKEN        = (1 shl RXFB_TOKEN);
  RXFF_NONRET       = (1 shl RXFB_NONRET);


Type
  PRexxArg = ^TRexxArg;
  TRexxArg = record
    ra_Size         : SLONG;
    ra_Length       : UWORD;
    ra_Depricated1  : UBYTE;    // Was ra_Flags but not used anymore
    ra_Depricated2  : UBYTE;    // Was ra_Hash but not used anymore
    ra_Buff         : array[0..Pred(8)] of SBYTE;
  end;


  PRexxRsrc = ^TRexxRsrc;
  TRexxRsrc = record
    rr_Node         : TNode;    
    rr_Func         : SWORD;    // Library offset of clean up function
    rr_Base         : APTR;     // Library base of clean up function
    rr_Size         : SLONG;    // Total size of structure
    rr_Arg1         : SIPTR;    // Meaning depends on type of Resource
    rr_Arg2         : SIPTR;    // Meaning depends on type of Resource
  end;


Const
  // Types for the resource nodes
  RRT_ANY           = 0;
  RRT_LIB           = 1;
  //  RRT_PORT          = 2;      // not used
  //  RRT_FILE          = 3;      // not used
  RRT_HOST          = 4;
  RRT_CLIP          = 5;

{$ENDIF}



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
type
  PNexxStr = ^TNexxStr;
  TNexxStr = record
    ns_Ivalue       : SLONG;
    ns_Length       : UWORD;
    ns_Flags        : UBYTE;
    ns_Hash         : UBYTE;
    ns_Buff         : array [0..pred(8)] of SBYTE;
  end;              


const
  NXADDLEN          = 9;

  // String attribute flag bit definitions
  NSB_KEEP          = 0;            // permanent string?
  NSB_STRING        = 1;            // string form valid?
  NSB_NOTNUM        = 2;            // non-numeric?
  NSB_NUMBER        = 3;            // a valid number?
  NSB_BINARY        = 4;            // integer value saved?
  NSB_FLOAT         = 5;            // floating point format?
  NSB_EXT           = 6;            // an external string?
  NSB_SOURCE        = 7;            // part of the program source?

  // The flag form of the string attributes
  NSF_KEEP          = (1 shl NSB_KEEP);
  NSF_STRING        = (1 shl NSB_STRING);
  NSF_NOTNUM        = (1 shl NSB_NOTNUM);
  NSF_NUMBER        = (1 shl NSB_NUMBER);
  NSF_BINARY        = (1 shl NSB_BINARY);
  NSF_FLOAT         = (1 shl NSB_FLOAT);
  NSF_EXT           = (1 shl NSB_EXT);
  NSF_SOURCE        = (1 shl NSB_SOURCE);

  // Combinations of flags
  NSF_INTNUM        = NSF_NUMBER + NSF_BINARY + NSF_STRING;
  NSF_DPNUM         = NSF_NUMBER + NSF_FLOAT;
  NSF_ALPHA         = NSF_NOTNUM + NSF_STRING;
  NSF_OWNED         = NSF_SOURCE + NSF_EXT    + NSF_KEEP;
  KEEPSTR           = NSF_STRING + NSF_SOURCE + NSF_NOTNUM;
  KEEPNUM           = NSF_STRING + NSF_SOURCE + NSF_NUMBER + NSF_BINARY;


Type
  PRexxArg = ^TRexxArg;
  TRexxArg = record
    ra_Size         : SLONG;
    ra_Length       : UWORD;
    ra_Flags        : UBYTE;
    ra_Hash         : UBYTE;
    ra_Buff         : array[0..Pred(8)] of SBYTE;
  end;

  PRexxMsg = ^TRexxMsg;
  TRexxMsg = record
    rm_Node         : TMessage;
    rm_TaskBlock    : APTR;
    rm_LibBase      : APTR;
    rm_Action       : SLONG;
    rm_Result1      : SLONG;
    rm_Result2      : SLONG;
    rm_Args         : array [0..Pred(16)] of STRPTR;

    rm_PassPort     : PMsgPort;
    rm_CommAddr     : STRPTR;
    rm_FileExt      : STRPTR;
    rm_Stdin        : SLONG;
    rm_Stdout       : SLONG;
    rm_avail        : SLONG;
  end;              // size: 128 bytes


const
  // maximum arguments
  MAXRMARG          = 15;

  // Commands for rm_Action
  RXCOMM            = $01000000;    // a command-level invocation
  RXFUNC            = $02000000;    // a function call
  RXCLOSE           = $03000000;    // close the REXX server
  RXQUERY           = $04000000;    // query for information
  RXADDFH           = $07000000;    // add a function host
  RXADDLIB          = $08000000;    // add a function library
  RXREMLIB          = $09000000;    // remove a function library
  RXADDCON          = $0A000000;    // add/update a ClipList string
  RXREMCON          = $0B000000;    // remove a ClipList string
  RXTCOPN           = $0C000000;    // open the trace console
  RXTCCLS           = $0D000000;    // close the trace console

  RXCODEMASK        = $FF000000;
  RXARGMASK         = $0000000F;


  // Flags that can be combined with the commands
  RXFB_NOIO         = 16;       // suppress I/O inheritance?
  RXFB_RESULT       = 17;       // result string expected?
  RXFB_STRING       = 18;       // program is a "string file"? 
  RXFB_TOKEN        = 19;       // tokenize the command line?
  RXFB_NONRET       = 20;       // a "no-return" message?

  // Convert from bit number to number
  RXFF_NOIO         = (1 shl RXFB_NOIO);
  RXFF_RESULT       = (1 shl RXFB_RESULT);
  RXFF_STRING       = (1 shl RXFB_STRING);
  RXFF_TOKEN        = (1 shl RXFB_TOKEN);
  RXFF_NONRET       = (1 shl RXFB_NONRET);


Type
  PRexxRsrc = ^TRexxRsrc;
  TRexxRsrc = record
    rr_Node         : TNode;    
    rr_Func         : SWORD;    // Library offset of clean up function
    rr_Base         : APTR;     // Library base of clean up function
    rr_Size         : SLONG;    // Total size of structure
    rr_Arg1         : SLONG;
    rr_Arg2         : SLONG;
  end;


Const
  // Types for the resource nodes
  RRT_ANY           = 0;        // any node type ...
  RRT_LIB           = 1;        // a function library
  RRT_PORT          = 2;        // a public port
  RRT_FILE          = 3;        // a file IoBuff
  RRT_HOST          = 4;        // a function host
  RRT_CLIP          = 5;        // a Clip List node


Const
  GLOBALSZ          = 200;      // total size of GlobalData


Type
  PRexxTask = ^TRexxTask;
  TRexxTask = record
    rt_Global       : array [0..Pred(GLOBALSZ)] of SBYTE;
    rt_MsgPort      : TMsgPort; // global message port
    rt_Flags        : UBYTE;    // task flag bits
    rt_SigBit       : SBYTE;    // signal bit

    rt_ClientID     : APTR;     // the client's task ID
    rt_MsgPkt       : APTR;     // the packet being processed
    rt_TaskID       : APTR;     // our task ID
    rt_RexxPort     : APTR;     // the REXX public port

    rt_ErrTrap      : APTR;     // Error trap address
    rt_StackPtr     : APTR;     // stack pointer for traps

    rt_Header1      : TList;    // Environment list
    rt_Header2      : TList;    // Memory freelist
    rt_Header3      : TList;    // Memory allocation list
    rt_Header4      : TList;    // Files list
    rt_Header5      : TList;    // Message Ports List
  end;


Const
  // Definitions for RexxTask flag bits
  RTFB_TRACE        = 0;        // external trace flag
  RTFB_HALT         = 1;        // external halt flag
  RTFB_SUSP         = 2;        // suspend task?
  RTFB_TCUSE        = 3;        // trace console in use?
  RTFB_WAIT         = 6;        // waiting for reply?
  RTFB_CLOSE        = 7;        // task completed?

  // Definitions for memory allocation constants
  MEMQUANT          = 16;           // quantum of memory space
  MEMMASK           = $FFFFFFF0;    // mask for rounding the size

  MEMQUICK          = (1 shl  0);   // EXEC flags: MEMF_PUBLIC
  MEMCLEAR          = (1 shl 16);   // EXEC flags: MEMF_CLEAR


type
  PSrcNode = ^TSrcNode;
  TSrcNode = record
    sn_Succ         : PSrcNode; // next node
    sn_Pred         : PSrcNode; // previous node
    sn_Ptr          : APTR;     // pointer value
    sn_Size         : SLONG;    // size of object
  end;               
{$ENDIF}



// ###### rexx/rexxio.h #####################################################



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
const
  RXBUFFSZ          = 204;          // buffer length

type
  PIoBuff = ^TIoBuff;
  TIoBuff = record
    iobNode         : TRexxRsrc;    // structure for files/strings
    iobRpt          : APTR;         // read/write pointer
    iobRct          : SLONG;        // character count
    iobDFH          : SLONG;        // DOS filehandle
    iobLock         : APTR;         // DOS lock
    iobBct          : SLONG;        // buffer length 
    iobArea         : array [0..Pred(RXBUFFSZ)] of SBYTE;
  end;


const
  // Access modes
  RXIO_EXIST        = -1;       // an external filehandle
  RXIO_STRF         = 0;        // a "string file"
  RXIO_READ         = 1;        // read-only access
  RXIO_WRITE        = 2;        // write mode
  RXIO_APPEND       = 3;        // append mode (existing file)

  // Offset modes
  RXIO_BEGIN        = -1;       // relative to start
  RXIO_CURR         =  0;       // relative to current position
  RXIO_END          =  1;       // relative to end


type
  PRexxMsgPort = ^TRexxMsgPort;
  TRexxMsgPort = record
    rmp_Node        : TRexxRsrc;    // linkage node
    rmp_Port        : TMsgPort;     // the message port
    rmp_ReplyList   : TList;        // messages awaiting reply
  end;


const
  // Device types
  DT_DEV            = 0;            // a device
  DT_DIR            = 1;            // an ASSIGNed directory
  DT_VOL            = 2;            // a volume

  // Packet types
  ACTION_STACK      = 2002;         // stack a line
  ACTION_QUEUE      = 2003;         // queue a line
{$ENDIF}



// ###### rexx/rxslib.h #####################################################



const
  RXSNAME           : PChar = 'rexxsyslib.library';
  RXSDIR            : PChar = 'REXX';
  RXSTNAME          : PChar = 'ARexx';


{$IFDEF AROS}
  {
  * RxsLib is only here to provide backwards compatibility with Amiga
  * programs. This structure should be considered read-only as a whole.
  * Only use the functions of rexxsyslib.library or send the appropriate
  * command to the REXX port if you want to change something in
  * this structure.
  }
Type
  PRxsLib = ^TRxsLib;
  TRxsLib = record
    rl_Node         : TLibrary;
    rl_Flags        : UBYTE;
    rl_Shadow       : UBYTE;
    rl_SysBase      : PExecBase;
    rl_DOSBase      : PLibrary;     // rl_DOSBase      : PDOSBase; -> not available in FPC
    rl_Unused1      : PLibrary;     // rl_IeeeCDBase
    rl_SegList      : BPTR;
    rl_Unused2      : PFileHandle;  // rl_NIL
    rl_Unused3      : SLONG;        // rl_Chunk
    rl_Unused4      : SLONG;        // rl_MaxNest
    rl_Unused5      : APTR;         // rl_NULL
    rl_Unused6      : APTR;         // rl_FALSE
    rl_Unused7      : APTR;         // rl_TRUE
    rl_Unused8      : APTR;         // rl_REXX
    rl_Unused9      : APTR;         // rl_COMMAND
    rl_Unused10     : APTR;         // rl_STDIN
    rl_Unused11     : APTR;         // rl_STDOUT
    rl_Unused12     : APTR;         // rl_STDERR
    rl_Version      : STRPTR;
    rl_Unused13     : STRPTR;       // rl_TaskName
    rl_Unused14     : SLONG;        // rl_TaskPri
    rl_Unused15     : SLONG;        // rl_TaskSeg
    rl_Unused16     : SLONG;        // rl_StackSize
    rl_Unused17     : STRPTR;       // rl_RexxDir
    rl_Unused18     : STRPTR;       // rl_CTABLE
    rl_Notice       : STRPTR;       // The copyright notice
    rl_Unused19     : TMsgPort;     // rl_REXX public port
    rl_Unused20     : UWORD;        // rl_ReadLock
    rl_Unused21     : SLONG;        // rl_TraceFH
    rl_Unused22     : TList;        // rl_TaskList
    rl_Unused23     : SWORD;        // rl_NumTask
    rl_LibList      : TList;        // Library list header
    rl_NumLib       : SWORD;        // Nodes count in library list
    rl_ClipList     : TList;        // Clip list header
    rl_NumClip      : SWORD;        // Nodes count in clip list
    rl_Unused24     : TList;        // rl_MsgList
    rl_Unused25     : SWORD;        // rl_NumMsg
    rl_Unused26     : TList;        // rl_PgmList
    rl_Unused27     : SWORD;        // rl_NumPgm
    rl_Unused28     : UWORD;        // rl_TraceCnt
    rl_Unused29     : SWORD;        // rl_avail
  end;


// These are not necessary for client program either I think
(*
const
  // RexxMast global flags
  RLFB_TRACE        = RTFB_TRACE;
  RLFB_HALT         = RTFB_HALT;
  RLFB_SUSP         = RTFB_SUSP;
  RLFB_STOP         = 6;
  RLFB_CLOSE        = 7;

  RLFMASK           = (1 shl RLFB_TRACE) or (1 shl RLFB_HALT) or (1 shl RLFB_SUSP);

  RXSCHUNK          = 1024;
  RXSNEST           =   32;
  RXSTPRI           =    0;
  RXSSTACK          = 4096;
*)


//* I'm not sure about these ones but let's dissable them for now
(*
  // Character attribute flag bits used in REXX.
  CTB_SPACE         = 0;            // white space characters
  CTB_DIGIT         = 1;            // decimal digits 0-9
  CTB_ALPHA         = 2;            // alphabetic characters
  CTB_REXXSYM       = 3;            // REXX symbol characters
  CTB_REXXOPR       = 4;            // REXX operator characters
  CTB_REXXSPC       = 5;            // REXX special symbols
  CTB_UPPER         = 6;            // UPPERCASE alphabetic
  CTB_LOWER         = 7;            // lowercase alphabetic

  // Attribute flags
  CTF_SPACE         = (1 shl CTB_SPACE);
  CTF_DIGIT         = (1 shl CTB_DIGIT);
  CTF_ALPHA         = (1 shl CTB_ALPHA);
  CTF_REXXSYM       = (1 shl CTB_REXXSYM);
  CTF_REXXOPR       = (1 shl CTB_REXXOPR);
  CTF_REXXSPC       = (1 shl CTB_REXXSPC);
  CTF_UPPER         = (1 shl CTB_UPPER);
  CTF_LOWER         = (1 shl CTB_LOWER);
*)
{$ENDIF}



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
type
  PRxsLib = ^TRxsLib;
  TRxsLib = record
    rl_Node         : TLibrary; // EXEC library node
    rl_Flags        : UBYTE;    // global flags
    rl_pad          : UBYTE;
    rl_SysBase      : APTR;     // EXEC library base
    rl_DOSBase      : APTR;     // DOS library base
    rl_IeeeDPBase   : APTR;     // IEEE DP math library base
    rl_SegList      : SLONG;    // library seglist
    rl_NIL          : SLONG;    // global NIL: filehandle
    rl_Chunk        : SLONG;    // allocation quantum
    rl_MaxNest      : SLONG;    // maximum expression nesting
    rl_NULL         : PNexxStr; // static string: NULL
    rl_FALSE        : PNexxStr; // static string: FALSE
    rl_TRUE         : PNexxStr; // static string: TRUE
    rl_REXX         : PNexxStr; // static string: REXX
    rl_COMMAND      : PNexxStr; // static string: COMMAND
    rl_STDIN        : PNexxStr; // static string: STDIN
    rl_STDOUT       : PNexxStr; // static string: STDOUT
    rl_STDERR       : PNexxStr; // static string: STDERR
    rl_Version      : STRPTR;   // version/configuration string

    rl_TaskName     : STRPTR;   // name string for tasks
    rl_TaskPri      : SLONG;    // starting priority
    rl_TaskSeg      : SLONG;    // startup seglist
    rl_StackSize    : SLONG;    // stack size
    rl_RexxDir      : STRPTR;   // REXX directory
    rl_CTABLE       : STRPTR;   // character attribute table
    rl_Notice       : STRPTR;   // copyright notice

    rl_RexxPort     : TMsgPort; // REXX public port
    rl_ReadLock     : UWORD;    // lock count
    rl_TraceFH      : SLONG;    // global trace console
    rl_TaskList     : TList;    // REXX task list
    rl_NumTask      : SWORD;    // task count
    rl_LibList      : TList;    // Library List header
    rl_NumLib       : SWORD;    // library count
    rl_ClipList     : TList;    // ClipList header
    rl_NumClip      : SWORD;    // clip node count
    rl_MsgList      : TList;    // pending messages
    rl_NumMsg       : SWORD;    // pending count
    rl_PgmList      : TList;    // cached programs
    rl_NumPgm       : SWORD;    // program count

    rl_TraceCnt     : UWORD;    // usage count for trace console
    rl_avail        : SWORD;
  end;


const
  // RexxMast global flags
  RLFB_TRACE        = RTFB_TRACE;     // interactive tracing?
  RLFB_HALT         = RTFB_HALT;      // halt execution?
  RLFB_SUSP         = RTFB_SUSP;      // suspend execution?
  RLFB_STOP         = 6;              // deny further invocations
  RLFB_CLOSE        = 7;              // close the master

  RLFMASK           = (1 shl RLFB_TRACE) or (1 shl RLFB_HALT) or (1 shl RLFB_SUSP);

  // Initialization constants
  RXSCHUNK          = 1024;         // allocation quantum
  RXSNEST           =   32;         // expression nesting limit
  RXSTPRI           =    0;         // task priority
  RXSSTACK          = 4096;         // stack size

  //RXSVERS = 34;                   // main version
  //RXSREV  = 7;                    // revision
  //RXSALLOC    = $800000;          // maximum allocation
  //RXSLISTH    = 5;                // number of list headers

  // Character attribute flag bits used in REXX.
  CTB_SPACE         = 0;            // white space characters
  CTB_DIGIT         = 1;            // decimal digits 0-9
  CTB_ALPHA         = 2;            // alphabetic characters
  CTB_REXXSYM       = 3;            // REXX symbol characters
  CTB_REXXOPR       = 4;            // REXX operator characters
  CTB_REXXSPC       = 5;            // REXX special symbols
  CTB_UPPER         = 6;            // UPPERCASE alphabetic
  CTB_LOWER         = 7;            // lowercase alphabetic

  // Attribute flags
  CTF_SPACE         = (1 shl CTB_SPACE);
  CTF_DIGIT         = (1 shl CTB_DIGIT);
  CTF_ALPHA         = (1 shl CTB_ALPHA);
  CTF_REXXSYM       = (1 shl CTB_REXXSYM);
  CTF_REXXOPR       = (1 shl CTB_REXXOPR);
  CTF_REXXSPC       = (1 shl CTB_REXXSPC);
  CTF_UPPER         = (1 shl CTB_UPPER);
  CTF_LOWER         = (1 shl CTB_LOWER);
{$ENDIF}



// ###### rexx/errors.h #####################################################



// these were not declared in original rexx.pas amiga unit
const
  ERRC_MSG  = (0);
  ERR10_001 = (ERRC_MSG + 1);
  ERR10_002 = (ERRC_MSG + 2);
  ERR10_003 = (ERRC_MSG + 3);
  ERR10_004 = (ERRC_MSG + 4);
  ERR10_005 = (ERRC_MSG + 5);
  ERR10_006 = (ERRC_MSG + 6);
  ERR10_007 = (ERRC_MSG + 7);
  ERR10_008 = (ERRC_MSG + 8);
  ERR10_009 = (ERRC_MSG + 9);

  ERR10_010 = (ERRC_MSG + 10);
  ERR10_011 = (ERRC_MSG + 11);
  ERR10_012 = (ERRC_MSG + 12);
  ERR10_013 = (ERRC_MSG + 13);
  ERR10_014 = (ERRC_MSG + 14);
  ERR10_015 = (ERRC_MSG + 15);
  ERR10_016 = (ERRC_MSG + 16);
  ERR10_017 = (ERRC_MSG + 17);
  ERR10_018 = (ERRC_MSG + 18);
  ERR10_019 = (ERRC_MSG + 19);

  ERR10_020 = (ERRC_MSG + 20);
  ERR10_021 = (ERRC_MSG + 21);
  ERR10_022 = (ERRC_MSG + 22);
  ERR10_023 = (ERRC_MSG + 23);
  ERR10_024 = (ERRC_MSG + 24);
  ERR10_025 = (ERRC_MSG + 25);
  ERR10_026 = (ERRC_MSG + 26);
  ERR10_027 = (ERRC_MSG + 27);
  ERR10_028 = (ERRC_MSG + 28);
  ERR10_029 = (ERRC_MSG + 29);

  ERR10_030 = (ERRC_MSG + 30);
  ERR10_031 = (ERRC_MSG + 31);
  ERR10_032 = (ERRC_MSG + 32);
  ERR10_033 = (ERRC_MSG + 33);
  ERR10_034 = (ERRC_MSG + 34);
  ERR10_035 = (ERRC_MSG + 35);
  ERR10_036 = (ERRC_MSG + 36);
  ERR10_037 = (ERRC_MSG + 37);
  ERR10_038 = (ERRC_MSG + 38);
  ERR10_039 = (ERRC_MSG + 39);

  ERR10_040 = (ERRC_MSG + 40);
  ERR10_041 = (ERRC_MSG + 41);
  ERR10_042 = (ERRC_MSG + 42);
  ERR10_043 = (ERRC_MSG + 43);
  ERR10_044 = (ERRC_MSG + 44);
  ERR10_045 = (ERRC_MSG + 45);
  ERR10_046 = (ERRC_MSG + 46);
  ERR10_047 = (ERRC_MSG + 47);
  ERR10_048 = (ERRC_MSG + 48);
  
  {$IFDEF AROS}
  ERR10_100 = 100;              // Internal error
  {$ENDIF}
  
  RC_OK     =  0;
  RC_WARN   =  5;
  RC_ERROR  = 10;
  RC_FATAL  = 20;



// ###### function declarations #############################################

  {$IFDEF AMIGA}
  procedure ClearRexxMsg(msgptr: PRexxMsg location 'a0'; count: ULONG location 'd0');                                                       syscall RexxSysBase 156;
  function  CreateArgstring(const argstring: PChar location 'a0'; length: ULONG location 'd0'): PChar;                                      syscall RexxSysBase 126;
  function  CreateRexxMsg(const port: PMsgPort location 'a0'; const extension: PChar location 'a1'; host: PChar location 'd0'): PRexxMsg;   syscall RexxSysBase 144;
  procedure DeleteArgstring(argstring: PChar location 'a0');                                                                                syscall RexxSysBase 132;
  procedure DeleteRexxMsg(packet: PRexxMsg location 'a0');                                                                                  syscall RexxSysBase 150;
  function  FillRexxMsg(msgptr: PRexxMsg location 'a0'; count: ULONG location 'd0'; mask: ULONG location 'd1'): LBOOL;                      syscall RexxSysBase 162;
  function  IsRexxMsg(const msgptr: PRexxMsg location 'a0'): LBOOL;                                                                         syscall RexxSysBase 168;
  function  LengthArgstring(const argstring: PChar location 'a0'): ULONG;                                                                   syscall RexxSysBase 138;
  procedure LockRexxBase(resource: ULONG location 'd0');                                                                                    syscall RexxSysBase 450;
  procedure UnlockRexxBase(resource: ULONG location 'd0');                                                                                  syscall RexxSysBase 456;
  {$ENDIF}
  
  {$IFDEF AROS}
  // ,skip 16
  function  CreateArgstring(const argstring: PChar; length: ULONG): PChar;          syscall RexxSysBase 021;
  procedure DeleteArgstring(argstring: PChar);                                      syscall RexxSysBase 022;
  function  LengthArgstring(argstring: PChar): ULONG;                               syscall RexxSysBase 023;
  function  CreateRexxMsg(port: PMsgPort; extension: PChar; host: PChar): PRexxMsg; syscall RexxSysBase 024;
  procedure DeleteRexxMsg(packet: PRexxMsg);                                        syscall RexxSysBase 025;
  procedure ClearRexxMsg(msgptr: PRexxMsg; count: ULONG);                           syscall RexxSysBase 026;
  function  FillRexxMsg(msgptr: PRexxMsg; count: ULONG; mask: ULONG): LBOOL;        syscall RexxSysBase 027;
  function  IsRexxMsg(msgptr: PRexxMsg): LBOOL;                                     syscall RexxSysBase 028;
  // .skip 46
  procedure LockRexxBase(resource: ULONG);                                          syscall RexxSysBase 075;
  procedure UnlockRexxBase(resource: ULONG);                                        syscall RexxSysBase 076;
  {$ENDIF}
  
  {$IFDEF MORPHOS}
  procedure LockRexxBase(resource: ULONG location 'd0');                                                                                            syscall RexxSysBase 450;
  procedure UnlockRexxBase(resource: ULONG location 'd0');                                                                                          syscall RexxSysBase 456;
  procedure DeleteRexxMsg(packet: PRexxMsg location 'a0');                                                                                          syscall RexxSysBase 150;
  procedure DeleteArgstring(argstring: STRPTR location 'a0');                                                                                       syscall RexxSysBase 132;
  function  CreateRexxMsg(const port: PMsgPort location 'a0'; const extension: STRPTR location 'a1'; const host: STRPTR location 'd0'): PRexxMsg;   syscall RexxSysBase 144;
  function  IsRexxMsg(const msgptr: PRexxMsg location 'a0'): LBOOL;                                                                                 syscall RexxSysBase 168;
  function  LengthArgstring(const argstring: STRPTR location 'a0'): ULONG;                                                                          syscall RexxSysBase 138;
  procedure ClearRexxMsg(msgptr: PRexxMsg location 'a0'; count: ULONG location 'd0');                                                               syscall RexxSysBase 156;
  function  CreateArgstring(const argstring: STRPTR location 'a0'; length: ULONG location 'd0'): PChar;                                             syscall RexxSysBase 126;
  function  FillRexxMsg(msgptr: PRexxMsg location 'a0'; count: ULONG location 'd0'; mask: ULONG location 'd1'): LBOOL;                              syscall RexxSysBase 162;
  {$ENDIF}



// ###### macros ############################################################



  (*
  // #define IVALUE(nsPtr) (nsPtr->ns_Ivalue)
  function IVALUE(nsPtr: PNexxStr): SLONG; inline;
  begin
    IVALUE := nsPtr^.ns_Ivalue;
  end;

  //* Field definitions							*/
  //#define ARG0(rmp) (rmp->rm_Args[0])    /* start of argblock		*/
  //#define ARG1(rmp) (rmp->rm_Args[1])    /* first argument		*/
  //#define ARG2(rmp) (rmp->rm_Args[2])    /* second argument		*/

  function ARG0(rmp: PRexxMsg): STRPTR; inline;
  begin
    ARG0 := rmp^.rm_Args[0];
  end;
  function ARG1(rmp: PRexxMsg): STRPTR; inline;
  begin
    ARG0 := rmp^.rm_Args[1];
  end;
  function ARG2(rmp: PRexxMsg): STRPTR; inline;
  begin
    ARG0 := rmp^.rm_Args[2];
  end;



  //* The Library List contains just plain resource nodes.		*/
  function LLOFFSET(rrp: PRexxRsrc): SLONG; inline; //* "Query" offset		*/
  begin
    LLOFFSET := rrp^.rr_Arg1;
  end;

  function LLVERS(rrp: PRexxRsrc): SLONG; inline; //* library version		*/
  begin
    LLVERS := rrp^.rr_Arg2;
  end;

  function CLVALUE(rrp: PRexxRsrc): SLONG; inline;
  begin
    CLVALUE := rrp^.rr_Arg1;
  end;
  *)

implementation


initialization


{$IFDEF AROS}
  RexxSysBase := OpenLibrary(REXXSYSLIBNAME, 0);
{$ENDIF}


finalization


{$IFDEF AROS}
  CloseLibrary(RexxSysBase);
{$ENDIF}


end.
