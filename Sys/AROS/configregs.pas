unit configregs;

  // TODO: check structure sizes.

interface

uses 
  exec;

  {$IFDEF AMIGA}   {$PACKRECORDS 2} {$ENDIF}
  {$IFDEF MORPHOS} {$PACKRECORDS 2} {$ENDIF}

Type
  PDiagArea = ^TDiagArea;
  TDiagArea = 
  record
    da_Config       : UBYTE;
    da_Flags        : UBYTE;
    da_Size         : UWORD;
    da_DiagPoint    : UWORD;
    da_BootPoint    : UWORD;
    da_Name         : UWORD;
    da_Reserved01   : UWORD;
    da_Reserved02   : UWORD;
  end;


const
  DAC_BUSWIDTH        = $C0;  { two bits for bus width }
  DAC_NIBBLEWIDE      = $00;
  DAC_BYTEWIDE        = $40;
  DAC_WORDWIDE        = $80;

  DAC_BOOTTIME        = $30;  { two bits for when to boot }
  DAC_NEVER           = $00;  { obvious }
  DAC_CONFIGTIME      = $10;  { call da_BootPoint when first configing the }                                {   the device }
  DAC_BINDTIME        = $20;  { run when binding drivers to boards }



Type
  PExpansionRom = ^TExpansionRom;
  TExpansionRom = 
  record
    er_Type         : UBYTE;
    er_Product      : UBYTE;
    er_Flags        : UBYTE;
    er_Reserved03   : UBYTE;
    er_Manufacturer : UWORD;
    er_SerialNumber : ULONG;
    er_InitDiagVec  : UWORD;
    {$IFDEF AMIGA}
    er_Reserved0c   : UBYTE;
    er_Reserved0d   : UBYTE;
    er_Reserved0e   : UBYTE;
    er_Reserved0f   : UBYTE;
    {$ENDIF}
    {$IFDEF AROS}
    case byte of
    0 :
      (
        er_             : 
        record
          case byte of
          0 : 
            (
              Reserved0 : 
              record
                c           : UBYTE;
                d           : UBYTE;
                e           : UBYTE;
                f           : UBYTE
              end;
            );
          1 : 
            (
              DiagArea  : PDiagArea
            );
        end;
      );
    1 :
      (
        er_Reserved0c   : UBYTE;
        er_Reserved0d   : UBYTE;
        er_Reserved0e   : UBYTE;
        er_Reserved0f   : UBYTE;
      );
    2 :
      (
        DiagArea  : PDiagArea
      );
    {$ENDIF}
    {$IFDEF MORPHOS}
    er_Reserved0c   : UBYTE;
    er_Reserved0d   : UBYTE;
    er_Reserved0e   : UBYTE;
    er_Reserved0f   : UBYTE;
    {$ENDIF}
  end;


  PExpansionControl = ^TExpansionControl;
  TExpansionControl = record
    ec_Interrupt    : UBYTE;
    ec_Z3_HighBase  : UBYTE;
    ec_BaseAddress  : UBYTE;
    ec_Shutup       : UBYTE;
    ec_Reserved14   : UBYTE;
    ec_Reserved15   : UBYTE;
    ec_Reserved16   : UBYTE;
    ec_Reserved17   : UBYTE;
    ec_Reserved18   : UBYTE;
    ec_Reserved19   : UBYTE;
    ec_Reserved1a   : UBYTE;
    ec_Reserved1b   : UBYTE;
    ec_Reserved1c   : UBYTE;
    ec_Reserved1d   : UBYTE;
    ec_Reserved1e   : UBYTE;
    ec_Reserved1f   : UBYTE;
  end;

Const
  E_SLOTSIZE            = $10000;
  E_SLOTMASK            = $FFFF;
  E_SLOTSHIFT           = 16;

  E_EXPANSIONBASE       = $00e80000;
  E_EXPANSIONSIZE       = $00080000;
  E_EXPANSIONSLOTS      = 8;

  E_MEMORYBASE          = $00200000;
  E_MEMORYSIZE          = $00800000;
  E_MEMORYSLOTS         = 128;

  EZ3_EXPANSIONBASE     = $ff000000;      {           Zorro III config address }
  EZ3_CONFIGAREA        = $40000000;      {           Zorro III space }
  EZ3_CONFIGAREAEND     = $7FFFFFFF;      {           Zorro III space }
  EZ3_SIZEGRANULARITY   = $00080000;      {           512K increments }

  //* er_Type */
  ERT_TYPEMASK          = $c0;    {Bits 7-6 }
  ERT_TYPEBIT           = 6  ;
  ERT_TYPESIZE          = 2  ;
  ERT_NEWBOARD          = $c0;
  ERT_ZORROII           = ERT_NEWBOARD;
  ERT_ZORROIII          = $80;

  ERTB_MEMLIST          = 5;           {           Link RAM into free memory list }
  ERTF_MEMLIST          = (1 shl 5);
  ERTB_DIAGVALID        = 4;           {           ROM vector is valid }
  ERTF_DIAGVALID        = (1 shl 4);
  ERTB_CHAINEDCONFIG    = 3;           {           Next config is part of the same card }
  ERTF_CHAINEDCONFIG    = (1 shl 3);

  ERT_MEMMASK           = $07;    {Bits 2-0 }
  ERT_MEMBIT            = 0  ;
  ERT_MEMSIZE           = 3  ;


  //* er_Flags */
  ERFB_MEMSPACE         = 7;            {           (NOT IMPLEMENTED) }
  ERFF_MEMSPACE         = (1 shl 7);    {           Wants to be in 8 meg space. }
  ERFB_NOSHUTUP         = 6;
  ERFF_NOSHUTUP         = (1 shl 6);    {           Board can't be shut up }
  ERFB_EXTENDED         = 5;            {                      for bits 0-2 of er_Type }
  ERFF_EXTENDED         = (1 shl 5);    {           Zorro III: Use extended size table }
  ERFB_ZORRO_III        = 4;            {           Zorro II : must be 0 }
  ERFF_ZORRO_III        = (1 shl 4);    {           Zorro III: must be 1 }

  ERT_Z3_SSMASK         = $0F;          {           Bits 3-0.  Zorro III Sub-Size.  How }
  ERT_Z3_SSBIT          = 0;            {           much space the card actually uses   }
  ERT_Z3_SSSIZE         = 4;            {           (regardless of config granularity)  }


  //* ec_Interrupt register (unused) */
  ECIB_INTENA           = 1;
  ECIF_INTENA           = (1 shl 1);
  ECIB_RESET            = 3;
  ECIF_RESET            = (1 shl 3);
  ECIB_INT2PEND         = 4;
  ECIF_INT2PEND         = (1 shl 4);
  ECIB_INT6PEND         = 5;
  ECIF_INT6PEND         = (1 shl 5);
  ECIB_INT7PEND         = 6;
  ECIF_INT7PEND         = (1 shl 6);
  ECIB_INTERRUPTING     = 7;
  ECIF_INTERRUPTING     = (1 shl 7);


implementation

end.
