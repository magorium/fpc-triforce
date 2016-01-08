unit expansionbase;

{$UNITPATH .}

interface

uses 
  Exec, configvars;

  {$IFDEF AMIGA}   {$PACKRECORDS 2} {$ENDIF}
  {$IFDEF MORPHOS} {$PACKRECORDS 2} {$ENDIF}

const
  TOTALSLOTS  = 256;    // no idea where this value is coming from, not available in autodocs

Type
  {*
     BootNodes are used by dos.library to determine which device to boot
     from. Items found on the list are added to DOS's list of available
     devices before the system boot, and the highest priority node will
     be used to attempt to boot. You add BootNodes with the expansion
     AddBootNode() call.

     If you use the AddDosNode() call, you will have to create and add
     your own BootNode. It is preferred to use AddBootNode().
  *}

  PBootNode = ^TBootNode;
  TBootNode = record
    bn_Node         : TNode;
    bn_Flags        : UWORD;
    bn_DeviceNode   : APTR;
  end;

  {*
     Most of this data is private, but you can use the expansion.library
     functions to scan the information.

     Use FindConfigDev() to scan the board list.
  *}
  
  PExpansionBase = ^TExpansionBase;
  TExpansionBase = record
    LibNode         : TLibrary;
    Flags           : UBYTE;
    eb_Private01    : UBYTE;
    eb_Private02    : ULONG;
    eb_Private03    : ULONG;
    eb_Private04    : TCurrentBinding;
    eb_Private05    : TList;
    MountList       : TList;
    // private
  end;


const
  //*  The error codes from expansion boards */
  EE_OK             =  0;           //* no error */
  EE_LASTBOARD      = 40;           //* board could not be shut up */
  EE_NOEXPANSION    = 41;           //* no space expansion slots, board shut up */
  EE_NOMEMORY       = 42;           //* no normal memory */
  EE_NOBOARD        = 43;           //* no board at that address */
  EE_BADMEM         = 44;           //* tried to add a bad memory card */

  //* ExpansionBase flags, READ ONLY !! */
  EBB_CLOGGED       = 0;            //* a board could not be shut up */
  EBF_CLOGGED       = (1 shl 0);
  EBB_SHORTMEM      = 1;            //* ran out of expansion memory */
  EBF_SHORTMEM      = (1 shl 1);
  EBB_BADMEM        = 2;            //* tried to add bad memory card */
  EBF_BADMEM        = (1 shl 2);
  EBB_DOSFLAG       = 3;            //* reserved by AmigaDOS */
  EBF_DOSFLAG       = (1 shl 3);
  EBB_KICKBACK33    = 4;            //* reserved by AmigaDOS */
  EBF_KICKBACK33    = (1 shl 4);
  EBB_KICKBACK36    = 5;            //* reserved by AmigaDOS */
  EBF_KICKBACK36    = (1 shl 5);

  {*  
      If the following flag is set by a floppy's boot code, then when DOS
      awakes, it will not open its initial console window until the first
      output is written to that shell. Otherwise the old behaviour will
      apply.
  *}
  EBB_SILENTSTART   = 6;
  EBF_SILENTSTART   = (1 shl 6);

  EBB_START_CC0     = 7;            //* allow/try boot from CC0 */
  EBF_START_CC0     = (1 shl 7);


implementation


end.
