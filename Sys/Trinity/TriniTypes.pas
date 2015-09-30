unit TriniTypes;


interface


Type
  UBYTE             = Byte;
  SBYTE             = ShortInt;

  UWORD             = Word;
  SWORD             = SmallInt;

  ULONG             = LongWord;
  SLONG             = LongInt;


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


implementation


end.
