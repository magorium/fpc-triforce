unit input;


{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$IFDEF AMIGA}   {$PACKRECORDS 2} {$ENDIF}
{$IFDEF AROS}    {$PACKRECORDS C} {$ENDIF}
{$IFDEF MORPHOS} {$PACKRECORDS 2} {$ENDIF}


Interface


uses 
  Exec;


const
  IND_ADDHANDLER    = CMD_NONSTD + 0;
  IND_REMHANDLER    = CMD_NONSTD + 1;
  IND_WRITEEVENT    = CMD_NONSTD + 2;
  IND_SETTHRESH     = CMD_NONSTD + 3;
  IND_SETPERIOD     = CMD_NONSTD + 4;
  IND_SETMPORT      = CMD_NONSTD + 5;
  IND_SETMTYPE      = CMD_NONSTD + 6;
  IND_SETMTRIG      = CMD_NONSTD + 7;


  {$IFDEF AROS}
  IND_ADDEVENT      = (CMD_NONSTD + 15); //* V50! */
  {$ENDIF}

{$IFDEF AROS}
Type
  //* The following is AROS-specific, experimental and subject to change */
  TInputDevice      = record
    id_Device       : TDevice;
    id_Flags        : ULONG;
  end;

Const
  IDF_SWAP_BUTTONS  = $0001;
{$ENDIF}

{$IFDEF MORPHOS}
type
  TInputDeviceData = record
    Device  : PChar;
    unit_   : ULONG;
    flags   : ULONG;
  end; 

  {
  * GetInputEventAttr(),SetInputEventAttr() attributes of functons that 
  * doesn't seem to exist.. !?
  }
const
  INPUTEVENTATTR_TagBase    = TAG_USER + $8000000;
  INPUTEVENTATTR_NEXTEVENT  = (INPUTEVENTATTR_TagBase + 0);
  INPUTEVENTATTR_CLASS      = (INPUTEVENTATTR_TagBase + 1);
  INPUTEVENTATTR_SUBCLASS   = (INPUTEVENTATTR_TagBase + 2);
  INPUTEVENTATTR_CODE       = (INPUTEVENTATTR_TagBase + 3);
  INPUTEVENTATTR_QUALIFIER  = (INPUTEVENTATTR_TagBase + 4);
  INPUTEVENTATTR_X          = (INPUTEVENTATTR_TagBase + 5);
  INPUTEVENTATTR_Y          = (INPUTEVENTATTR_TagBase + 6);
  INPUTEVENTATTR_ADDR       = (INPUTEVENTATTR_TagBase + 7);
  INPUTEVENTATTR_DOWNKEYS   = (INPUTEVENTATTR_TagBase + 8);
  INPUTEVENTATTR_TIMESTAMP  = (INPUTEVENTATTR_TagBase + 9);
{$ENDIF}


Var
  InputBase: pDevice;

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  function  PeekQualifier: UWORD; syscall InputBase 042;
  {$ENDIF}
  {$IFDEF AROS}
  function  PeekQualifier: UWORD; syscall InputBase 7;
  {$ENDIF}


Implementation


end.
