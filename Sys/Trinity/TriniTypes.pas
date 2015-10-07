unit TriniTypes;


interface


Type
  UBYTE             = Byte;
  SBYTE             = ShortInt;

  UWORD             = Word;
  SWORD             = SmallInt;

  ULONG             = LongWord;
  SLONG             = LongInt;

  WBOOL             = WordBool;
  LBOOL             = LongBool;


  PUBYTE            = ^UBYTE;
  PSBYTE            = ^SBYTE;

  PUWORD            = ^UWORD;
  PSWORD            = ^SWORD;

  PULONG            = ^ULONG;
  PSLONG            = ^SLONG;


  APTR              = Pointer;
  PAPTR             = ^APTR;

  UIPTR             = NativeUint;
  SIPTR             = NativeInt;

  PUIPTR            = ^UIPTR;
  PSIPTR            = ^SIPTR;

  STRPTR            = PChar;
  PSTRPTR           = ^STRPTR;



implementation


end.
