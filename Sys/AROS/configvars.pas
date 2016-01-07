unit configvars;

{$MODE OBJFPC}{$H+}{.$HINTS ON}
{$UNITPATH .}

interface

uses 
  Exec, Configregs;

  {$IFDEF AMIGA}  {$PACKRECORDS 2}{$ENDIF}
  {$IFDEF MORPHOS}{$PACKRECORDS 2}{$ENDIF}

  {*
    Each expansion board that is found has a ConfigDev structure created
    for it very early at system startup. Software can search for boards
    by the manufacturer and product id (for Zorro/AutoConfig(TM) boards).

    For debugging, you can also look at the entire list of expansion
    boards. See the expansion.library FindConfigDev() function for more
    information.
  *}

Type
  PConfigDev = ^TConfigDev;
  TConfigDev = 
  record
    cd_Node         : TNode;
    cd_Flags        : UBYTE;            //* read/write device flags */
    cd_Pad          : UBYTE;
    cd_Rom          : TExpansionRom;    //* copy of boards expansion ROM */
    cd_BoardAddr    : APTR;             //* physical address of exp. board */
    cd_BoardSize    : ULONG;            //* size in bytes of exp. board */
    cd_SlotAddr     : UWORD;            //* private */
    cd_SlotSize     : UWORD;            //* private */
    cd_Driver       : APTR;             //* pointer to node of driver */
    cd_NextCD       : PConfigDev;       //* linked list of devices to configure */
    cd_Unused       : Array[0..Pred(4)] of ULONG;   //* for the drivers use - private */
  end;


Const
  //* Flags definitions for cd_Flags */
  CDB_SHUTUP          = 0;      //* this board has been shut up */
  CDB_CONFIGME        = 1;      //* this board needs a driver to claim it */
  CDB_BADMEMORY       = 2;      //* this board contains bad memory */
  CDB_PROCESSED       = 3;      //* private flag */

  CDF_SHUTUP          = $01;
  CDF_CONFIGME        = $02;
  CDF_BADMEMORY       = $04;
  CDF_PROCESSED       = $08;


Type
  {*
    Boards without their own drivers are normally bound to software
    drivers. This structure is used by GetCurrentBinding(), and
    SetCurrentBinding().
  *}
  PCurrentBinding = ^TCurrentBinding;
  TCurrentBinding = record
    cb_ConfigDev    : PConfigDev;   //* SLL of devices to configure */
    cb_FileName     : PChar;        //* disk file name of driver */
    cb_ProductString: PChar;        //* PRODUCT= tool type from icon */
    cb_ToolTypes    : PPChar;       //* tool types from disk object */
  end;


implementation


end.
