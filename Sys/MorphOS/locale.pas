unit locale;


{

  Locale.library
 
}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$IFDEF AMIGA}   {$PACKRECORDS 2} {$ENDIF}
{$IFDEF AROS}    {$PACKRECORDS C} {$ENDIF}
{$IFDEF MORPHOS} {$PACKRECORDS 2} {$ENDIF}

{$UNITPATH ../Trinity/}
{$UNITPATH .}



interface


uses 
  trinitypes, exec, amigados, utility;




Type
  //* OpenLibrary("locale.library",0) returns a pointer to this structure */
  PLocaleBase = ^TLocaleBase;
  TLocaleBase = record
    lb_LibNode      : TLibrary;
    lb_SysPatches   : WBOOL;    //* TRUE if locale installed its patches
  end;


//**************************************************************************/


Type
  //* This structure must only be allocated by locale.library and is READ-ONLY!  */
  PLocale = ^TLocale;
  TLocale = record
    loc_LocaleName              : STRPTR;   //* locale's name
    loc_LanguageName            : STRPTR;   //* language of this locale
    loc_PrefLanguages           : array[0..10-1] of STRPTR; //* preferred languages
    loc_Flags                   : ULONG;    //* always 0 for now

    loc_CodeSet                 : ULONG;    //* always 0 for now
    loc_CountryCode             : ULONG;    //* user's country code
    loc_TelephoneCode           : ULONG;    //* country's telephone code
    loc_GMTOffset               : SLONG;    //* minutes from GMT
    loc_MeasuringSystem         : UBYTE;    //* what measuring system?
    loc_CalendarType            : UBYTE;    //* what calendar type?
    loc_Reserved0               : packed array[0..2-1] of UBYTE;

    loc_DateTimeFormat          : STRPTR;   //* regular date & time format
    loc_DateFormat              : STRPTR;   //* date format by itself
    loc_TimeFormat              : STRPTR;   //* time format by itself

    loc_ShortDateTimeFormat     : STRPTR;   //* short date & time format
    loc_ShortDateFormat         : STRPTR;   //* short date format by itself
    loc_ShortTimeFormat         : STRPTR;   //* short time format by itself

    //* for numeric values */
    loc_DecimalPoint            : STRPTR;   //* character before the decimals
    loc_GroupSeparator          : STRPTR;   //* separates groups of digits
    loc_FracGroupSeparator      : STRPTR;   //* separates groups of digits
    loc_Grouping                : PUBYTE;   //* size of each group
    loc_FracGrouping            : PUBYTE;   //* size of each group

    //* for monetary values */
    loc_MonDecimalPoint         : STRPTR;
    loc_MonGroupSeparator       : STRPTR;
    loc_MonFracGroupSeparator   : STRPTR;
    loc_MonGrouping             : PUBYTE;
    loc_MonFracGrouping         : PUBYTE;
    loc_MonFracDigits           : UBYTE;    //* digits after the decimal point
    loc_MonIntFracDigits        : UBYTE;    //* for international representation
    loc_Reserved1               : packed array[0..2-1] of UBYTE;

    //* for currency symbols */
    loc_MonCS                   : STRPTR;   //* currency symbol
    loc_MonSmallCS              : STRPTR;   //* symbol for small amounts
    loc_MonIntCS                : STRPTR;   //* internationl (ISO 4217) code

    //* for positive monetary values */
    loc_MonPositiveSign         : STRPTR;   //* indicate positive money value
    loc_MonPositiveSpaceSep     : UBYTE;    //* determine if separated by space
    loc_MonPositiveSignPos      : UBYTE;    //* position of positive sign
    loc_MonPositiveCSPos        : UBYTE;    //* position of currency symbol
    loc_Reserved2               : UBYTE;

    //* for negative monetary values */
    loc_MonNegativeSign         : STRPTR;   //* indicate negative money value
    loc_MonNegativeSpaceSep     : UBYTE;    //* determine if separated by space
    loc_MonNegativeSignPos      : UBYTE;    //* position of negative sign
    loc_MonNegativeCSPos        : UBYTE;    //* position of currency symbol
    loc_Reserved3               : UBYTE;
  end;


const
  {$IFDEF AROS}
  //* loc_Flags, AROS-specific */
  LOCF_GMT_CLOCK    = (1 shl 16);   //* Hardware clock stores GMT */
  {$ENDIF}

  //* loc_MeasuringSystem */
  MS_ISO            = 0;    //* international metric system
  MS_AMERICAN       = 1;    //* american system
  MS_IMPERIAL       = 2;    //* imperial system
  MS_BRITISH        = 3;    //* british system

  //* loc_CalendarType */
  CT_7SUN           = 0;    //* 7 days a week, Sunday is the first day
  CT_7MON           = 1;    //* 7 days a week, Monday is the first day
  CT_7TUE           = 2;    //* 7 days a week, Tuesday is the first day
  CT_7WED           = 3;    //* 7 days a week, Wednesday is the first day
  CT_7THU           = 4;    //* 7 days a week, Thursday is the first day
  CT_7FRI           = 5;    //* 7 days a week, Friday is the first day
  CT_7SAT           = 6;    //* 7 days a week, Saturday is the first day

  //* loc_MonPositiveSpaceSep and loc_MonNegativeSpaceSep */
  SS_NOSPACE        = 0;    //* cur. symbol is NOT separated from value with a space
  SS_SPACE          = 1;    //* cur. symbol IS separated from value with a space

  //* loc_MonPositiveSignPos and loc_MonNegativeSignPos */
  SP_PARENS         = 0;    //* () surround the quantity and currency_symbol
  SP_PREC_ALL       = 1;    //* sign string comes before amount and symbol
  SP_SUCC_ALL       = 2;    //* sign string comes after amount and symbol
  SP_PREC_CURR      = 3;    //* sign string comes right before currency symbol
  SP_SUCC_CURR      = 4;    //* sign string comes right after currency symbol

  //* loc_MonPositiveCSPos and loc_MonNegativeCSPos */
  CSP_PRECEDES      = 0;    //* currency symbol comes before value
  CSP_SUCCEEDS      = 1;    //* currency symbol comes after value


//**************************************************************************/


  //* Tags for OpenCatalog() */
  OC_TagBase         = (TAG_USER + $90000);
  OC_BuiltInLanguage = (OC_TagBase + 1);    //* language of built-in strings
  OC_BuiltInCodeSet  = (OC_TagBase + 2);    //* code set of built-in strings
  OC_Version         = (OC_TagBase + 3);    //* catalog version number required
  OC_Language        = (OC_TagBase + 4);    //* preferred language of catalog
  {$IFDEF MORPHOS}
  OC_CodeSet         = (OC_TagBase + 5);    //* V51 */
  {$ENDIF}

//**************************************************************************/


  //* Comparison types for StrnCmp() */
  SC_ASCII          = 0;
  SC_COLLATE1       = 1;
  SC_COLLATE2       = 2;

  {$IFDEF MORPHOS}
  SC_UNICODE        = SC_ASCII;

  UCF_IGNORE_CASE   = (1 shl 0);


  UNICODE_NFD       = 0;
  UNICODE_NFKD      = 1;
  {$ENDIF}


//**************************************************************************/

  //* constants for GetLocaleStr() */
const
  //* Days of Week */
  DAY_1             =  1;   //* Sunday
  DAY_2             =  2;   //* Monday
  DAY_3             =  3;   //* Tuesday
  DAY_4             =  4;   //* Wednesday
  DAY_5             =  5;   //* Thursday
  DAY_6             =  6;   //* Friday
  DAY_7             =  7;   //* Saturday

  //* Abbreviated Days of Week */
  ABDAY_1           =  8;   //* Sun
  ABDAY_2           =  9;   //* Mon
  ABDAY_3           = 10;   //* Tue
  ABDAY_4           = 11;   //* Wed
  ABDAY_5           = 12;   //* Thu
  ABDAY_6           = 13;   //* Fri
  ABDAY_7           = 14;   //* Sat

  //* Months */
  MON_1             = 15;   //* January
  MON_2             = 16;   //* February
  MON_3             = 17;   //* March
  MON_4             = 18;   //* April
  MON_5             = 19;   //* May
  MON_6             = 20;   //* June 
  MON_7             = 21;   //* July
  MON_8             = 22;   //* August
  MON_9             = 23;   //* September
  MON_10            = 24;   //* October
  MON_11            = 25;   //* November
  MON_12            = 26;   //* December

  //* Abbreviated Months */
  ABMON_1           = 27;   //* Jan
  ABMON_2           = 28;   //* Feb
  ABMON_3           = 29;   //* Mar
  ABMON_4           = 30;   //* Apr
  ABMON_5           = 31;   //* May
  ABMON_6           = 32;   //* Jun
  ABMON_7           = 33;   //* Jul
  ABMON_8           = 34;   //* Aug
  ABMON_9           = 35;   //* Sep
  ABMON_10          = 36;   //* Oct
  ABMON_11          = 37;   //* Nov
  ABMON_12          = 38;   //* Dec

  YESSTR            = 39;   //* affirmative response for yes/no queries
  NOSTR             = 40;   //* negative response for yes/no queries

  AM_STR            = 41;   //* AM
  PM_STR            = 42;   //* PM

  SOFTHYPHEN        = 43;   //* soft hyphenation
  HARDHYPHEN        = 44;   //* hard hyphenation

  OPENQUOTE         = 45;   //* start of quoted block
  CLOSEQUOTE        = 46;   //* end of quoted block

  YESTERDAYSTR      = 47;   //* Yesterday
  TODAYSTR          = 48;   //* Today
  TOMORROWSTR       = 49;   //* Tomorrow
  FUTURESTR         = 50;   //* Future

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  MAXSTRMSG         = 51;   //* current number of defined strings
  {$ENDIF}
  {$IFDEF AROS}
  LANG_NAME         = 51;   //* V50 */

  MAXSTRMSG         = 52;   //* current number of defined strings
  {$ENDIF}


//**************************************************************************/


Type
  //* This structure must only be allocated by locale.library and is READ-ONLY! }
  PCatalog = ^TCatalog;
  TCatalog = record
    cat_Link    : TNode;        //* for internal linkage

    cat_Pad     : UWORD;        //* to longword align
    cat_Language: STRPTR;       //* language of the catalog
    cat_CodeSet : ULONG;        //* currently always 0
    cat_Version : UWORD;        //* version of the catalog
    cat_Revision: UWORD;        //* revision of the catalog
  end;


{$IFDEF MORPHOS}
const
  {*
    cat_CodeSet values
  *}
  CODESET_LEGACY    =  0;
  CODESET_UTF8      =  1;
  CODESET_UTF32     =  2;
  CODESET_COUNT     =  3;

  CODESET_LATIN1    = CODESET_LEGACY;
  CODESET_UCS4      = CODESET_UTF32;

  {*
   Values returned by IsUnicode()
  *}
  UNICODE_INVALID   = 0;    //* ASCII or ISO-8859-1
  UNICODE_UTF8      = 1;    //* UTF-8
  UNICODE_16_BE     = 2;    //* UCS-2/UTF-16 big endian
  UNICODE_16_LE     = 3;    //* UCS-2/UTF-16 little endian
  UNICODE_32_BE     = 4;    //* UCS-4/UTF-32 big endian
  UNICODE_32_LE     = 5;    //* UCS-4/UTF-32 little endian
{$ENDIF}


//**************************************************************************/


var
  LocaleBase    : pLocaleBase;

const
  LOCALENAME    : PChar = 'locale.library';


Type
  // MorphOS WCHAR type
  W32CHAR       = UCS4Char;
  PW32CHAR      = ^W32CHAR;

  WSTRPTR       = ^UCS4Char;

//**************************************************************************/

  {$IFDEF AMIGA}
  //* --- functions in V38 or higher (Release 2.1) ---
  procedure CloseCatalog(catalog: PCatalog location 'a0');                                                                                                                          syscall LocaleBase 036;
  procedure CloseLocale(locale: PLocale location 'a0');                                                                                                                             syscall LocaleBase 042;
  function  ConvToLower(locale: PLocale location 'a0'; character: ULONG location 'd0'): ULONG;                                                                                      syscall LocaleBase 048;
  function  ConvToUpper(locale: PLocale location 'a0'; character: ULONG location 'd0'): ULONG;                                                                                      syscall LocaleBase 054;
  procedure FormatDate(locale: PLocale location 'a0'; fmtTemplate: STRPTR location 'a1'; date: PDateStamp location 'a2'; putCharFunc: PHook location 'a3');                         syscall LocaleBase 060;
  function  FormatString(locale: PLocale location 'a0'; fmtTemplate: STRPTR location 'a1'; dataStream: APTR location 'a2'; putCharFunc: PHook location 'a3'): APTR;                 syscall LocaleBase 066;
  function  GetCatalogStr(catalog: PCatalog location 'a0'; stringNum: SLONG location 'd0'; defaultString: STRPTR location 'a1'): STRPTR;                                            syscall LocaleBase 072;
  function  GetLocaleStr(locale: PLocale location 'a0'; stringNum: ULONG location 'd0'): STRPTR;                                                                                    syscall LocaleBase 078;
  function  IsAlNum(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 084;
  function  IsAlpha(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 090;
  function  IsCntrl(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 096;
  function  IsDigit(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 102;
  function  IsGraph(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 108;
  function  IsLower(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 114;
  function  IsPrint(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 120;
  function  IsPunct(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 126;
  function  IsSpace(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 132;
  function  IsUpper(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                          syscall LocaleBase 138;
  function  IsXDigit(locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                         syscall LocaleBase 144;
  function  OpenCatalogA(locale: PLocale location 'a0'; name: STRPTR location 'a1'; tagList: PTagItem location 'a2'): PCatalog;                                                     syscall LocaleBase 150;
  function  OpenLocale(name: STRPTR location 'a0'): PLocale;                                                                                                                        syscall LocaleBase 156;
  function  ParseDate(locale: PLocale location 'a0'; date: PDateStamp location 'a1'; fmtTemplate: STRPTR location 'a2'; getCharFunc: PHook location 'a3'): LBOOL;                   syscall LocaleBase 162;
  function  StrConvert(locale: PLocale location 'a0'; strng: STRPTR location 'a1'; buffer: APTR location 'a2'; bufferSize: ULONG location 'd0'; typ: ULONG location 'd1'): ULONG;   syscall LocaleBase 174;
  function  StrnCmp(locale: PLocale location 'a0'; string1: STRPTR location 'a1'; string2: STRPTR location 'a2'; len: SLONG location 'd0'; typ: ULONG location 'd1'): SLONG;        syscall LocaleBase 180;
  {$ENDIF}
  {$IFDEF AROS}
  procedure CloseCatalog(catalog: PCatalog);                                                                                          syscall LocaleBase 06;
  procedure CloseLocale(locale: PLocale);                                                                                             syscall LocaleBase 07;
  function  ConvToLower(const locale: PLocale; character: ULONG): ULONG;                                                              syscall LocaleBase 08;
  function  ConvToUpper(const locale: PLocale; character: ULONG): ULONG;                                                              syscall LocaleBase 09;
  procedure FormatDate(const locale: PLocale; const fmtStr: STRPTR; const date: PDateStamp; const hook: PHook);                       syscall LocaleBase 10;
  function  FormatString(const locale: PLocale; const fmtTemplate: STRPTR; const dataStream: APTR; const putCharFunc: PHook): APTR;   syscall LocaleBase 11;
  function  GetCatalogStr(const catalog: PCatalog; stringNum: ULONG; const defaultString: STRPTR): STRPTR;                            syscall LocaleBase 12;
  function  GetLocaleStr(const locale: PLocale; stringNum: ULONG): STRPTR;                                                            syscall LocaleBase 13;
  function  IsAlNum(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 14;
  function  IsAlpha(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 15;
  function  IsCntrl(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 16;
  function  IsDigit(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 17;
  function  IsGraph(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 18;
  function  IsLower(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 19;
  function  IsPrint(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 20;
  function  IsPunct(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 21;
  function  IsSpace(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 22;
  function  IsUpper(const locale: PLocale; character: ULONG): LBOOL;                                                                  syscall LocaleBase 23;
  function  IsXDigit(const locale: PLocale; character: ULONG): LBOOL;                                                                 syscall LocaleBase 24;
  function  OpenCatalogA(const locale: PLocale; const name: STRPTR; tags: PTagItem): PCatalog;                                        syscall LocaleBase 25;
  function  OpenLocale(const name: STRPTR): PLocale;                                                                                  syscall LocaleBase 26;
  function  ParseDate(locale: PLocale; date: PDateStamp; const fmtTemplate: STRPTR; getCharFunc: PHook): LBOOL;                       syscall LocaleBase 27;
  function  LocalePrefsUpdate(locale: PLocale): PLocale;                                                                              syscall LocaleBase 28;
  function  StrConvert(const locale: PLocale; const strng: STRPTR; buffer: APTR; bufferSize: ULONG; typ: ULONG): ULONG;               syscall LocaleBase 29;
  function  StrnCmp(const locale: PLocale; const string1: STRPTR; const string2: STRPTR; len: SLONG; typ: ULONG): SLONG;              syscall LocaleBase 30;
  // 9 private functions
  {$ENDIF}
  {$IFDEF MORPHOS}
  procedure CloseCatalog(const catalog: PCatalog location 'a0');                                                                                                                                syscall LocaleBase 036;
  procedure CloseLocale(const locale: PLocale location 'a0');                                                                                                                                   syscall LocaleBase 042;
  function  ConvToLower(const locale: PLocale location 'a0'; character: ULONG location 'd0'): ULONG;                                                                                            syscall LocaleBase 048;
  function  ConvToUpper(const locale: PLocale location 'a0'; character: ULONG location 'd0'): ULONG;                                                                                            syscall LocaleBase 054;
  procedure FormatDate(const locale: PLocale location 'a0'; const fmtTemplate: STRPTR location 'a1'; const date: PDateStamp location 'a2'; const putCharFunc: PHook location 'a3');             syscall LocaleBase 060;
  function  FormatString(const locale: PLocale location 'a0'; const fmtTemplate: STRPTR location 'a1'; const dataStream: APTR location 'a2'; const putCharFunc: PHook location 'a3'): APTR;     syscall LocaleBase 066;
  function  GetCatalogStr(const catalog: PCatalog location 'a0'; stringNum: SLONG location 'd0'; const defaultString: STRPTR location 'a1'): STRPTR;                                            syscall LocaleBase 072;
  function  GetLocaleStr(const locale: PLocale location 'a0'; stringNum: ULONG location 'd0'): STRPTR;                                                                                          syscall LocaleBase 078;
  function  IsAlNum(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 084;
  function  IsAlpha(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 090;
  function  IsCntrl(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 096;
  function  IsDigit(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 102;
  function  IsGraph(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 108;
  function  IsLower(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 114;
  function  IsPrint(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 120;
  function  IsPunct(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 126;
  function  IsSpace(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 132;
  function  IsUpper(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                                syscall LocaleBase 138;
  function  IsXDigit(const locale: PLocale location 'a0'; character: ULONG location 'd0'): LBOOL;                                                                                               syscall LocaleBase 144;
  function  OpenCatalogA(const locale: PLocale location 'a0'; const name: STRPTR location 'a1'; const tags: PTagItem location 'a2'): PCatalog;                                                  syscall LocaleBase 150;
  function  OpenLocale(const name: STRPTR location 'a0'): PLocale;                                                                                                                              syscall LocaleBase 156;
  function  ParseDate(const locale: PLocale location 'a0'; const date: PDateStamp location 'a1'; const fmtTemplate: STRPTR location 'a2'; const getCharFunc: PHook location 'a3'): LBOOL;       syscall LocaleBase 162;

  function  StrConvert(const locale: PLocale location 'a0'; const strng: STRPTR location 'a1'; buffer: APTR location 'a2'; bufferSize: ULONG location 'd0'; typ: ULONG location 'd1'): ULONG;   syscall LocaleBase 174;
  function  StrnCmp(const locale: PLocale location 'a0'; const string1: STRPTR location 'a1'; const string2: STRPTR location 'a2'; len: SLONG location 'd0'; typ: ULONG location 'd1'): SLONG;  syscall LocaleBase 180;

  // MorphOS specific
  // ?? utf8decodesafe 442 ??
  // ?? UTF8_EncdingLength 436 ?? 
  function  UCS4_ConvToLower(ucharacter: W32CHAR): W32CHAR;                                                                                 syscall SysV     LocaleBase 232;
  function  UCS4_ConvToUpper(ucharacter: W32CHAR): W32CHAR;                                                                                 syscall SysV     LocaleBase 238;
  function  UTF8_Decode(const utf8: STRPTR; ucharacter: PW32CHAR): ULONG;                                                                   syscall SysV     LocaleBase 244;
  function  UTF8_Encode(ucharacter: W32CHAR; strng: STRPTR): ULONG;                                                                         syscall SysV     LocaleBase 250;
  function  UCS4_GetCatalogStr(const catalog: PCatalog; stringNum: ULONG; const defaultString: WSTRPTR): WSTRPTR;                           syscall SysVBase LocaleBase 256;
  function  UCS4_IsAlNum(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 262;
  function  UCS4_IsAlpha(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 268;
  function  UCS4_IsCntrl(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 274;
  function  UCS4_IsDigit(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 280;
  function  UCS4_IsGraph(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 286;
  function  UCS4_IsLower(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 292;
  function  UCS4_IsPrint(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 298;
  function  UCS4_IsPunct(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 304;
  function  UCS4_IsSpace(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 310;
  function  UCS4_IsUpper(ucharacter: W32CHAR): LBOOL;                                                                                       syscall SysV     LocaleBase 316;
  function  UCS4_IsXDigit(ucharacter: W32CHAR): LBOOL;                                                                                      syscall SysV     LocaleBase 322;
  procedure UCS4_FormatDate(const locale: PLocale; const fmtString: WSTRPTR; const date: PDateStamp; const hook: PHook);                    syscall SysVBase LocaleBase 328;
  function  UCS4_FormatString(const locale: PLocale; const fmtTemplate: WSTRPTR; const dataStream: APTR; const putCharFunc: PHook): APTR;   syscall SysVBase LocaleBase 334;
  function  UCS4_GetLocaleStr(const locale: PLocale; stringNum: ULONG): WSTRPTR;                                                            syscall SysVBase LocaleBase 340;
  function  UCS4_StrnCmp(const locale: PLocale; const string1: WSTRPTR; const string2: WSTRPTR; len: SLONG; typ: ULONG): SLONG;             syscall SysVBase LocaleBase 346;
  function  UCS4_StrToLower(const locale: PLocale; const strng: WSTRPTR; buffer: WSTRPTR; bufferSize: ULONG; typ: ULONG): SLONG;            syscall SysVBase LocaleBase 352;
  function  UCS4_StrToUpper(const locale: PLocale; const strng: WSTRPTR; buffer: WSTRPTR; bufferSize: ULONG; typ: ULONG): SLONG;            syscall SysVBase LocaleBase 358;
  function  UCS4_Decompose(ch: W32CHAR): WSTRPTR;                                                                                           syscall SysVBase LocaleBase 364;
  function  UCS4_IsNSM(ucharacter: W32CHAR): LBOOL;                                                                                         syscall SysV     LocaleBase 370;
  function  UCS4_CanonicalDecompose(ch: W32CHAR): WSTRPTR;                                                                                  syscall SysVBase LocaleBase 376;
  procedure UCS4_Normalize(const src: WSTRPTR; dst: WSTRPTR; len: SLONG; typ: ULONG);                                                       syscall SysVBase LocaleBase 382;
  function  ConvertUTF8ToUCS4(const src: STRPTR; dst: WSTRPTR; len: SLONG): ULONG;                                                          syscall SysV     LocaleBase 388;
  function  ConvertUCS4ToUTF8(const src: WSTRPTR; dst: STRPTR; len: SLONG): ULONG;                                                          syscall SysV     LocaleBase 394;
  function  UCS4_IsCombining(ucharacter: W32CHAR): ULONG;                                                                                   syscall SysV     LocaleBase 400;
  function  UCS4_Compare(const locale: PLocale; const string1: WSTRPTR; const string2: WSTRPTR; len: SLONG; flags: ULONG): SLONG;           syscall SysVBase LocaleBase 406;
  function  UCS4_GetCombiningClass(ucharacter: W32CHAR): ULONG;                                                                             syscall SysV     LocaleBase 412;
  function  UCS4_NormalizedLength(const strng: WSTRPTR; len: SLONG; typ: ULONG): ULONG;                                                     syscall SysVBase LocaleBase 418;
  function  UTF8_CheckEncoding(const strng: STRPTR; len: SLONG): SLONG;                                                                     syscall SysVBase LocaleBase 424;
  function  IsUnicode(buffer: APTR; len: ULONG): ULONG;                                                                                     syscall SysVBase LocaleBase 430;
  function  UTF8_EncodingLength(utf32: PW32CHAR): ULONG;                                                                                    syscall SysV     LocaleBase 436;
  function  UTF8_DecodeSafe(const src: STRPTR; dest: PW32CHAR; len: ULONG): ULONG;                                                          syscall SysV     LocaleBase 442;
  procedure FormatClockData(const locale: PLocale; const fmtTemplate: STRPTR; const clockdata: PClockData; const putCharFunc: PHook);       syscall SysVBase LocaleBase 448;

  procedure UCS4_FormatClockData(const locale: PLocale; const fmtString: WSTRPTR; const cData: PClockData; const hook: PHook);              syscall SysVBase LocaleBase 460;
  // 466 SysVBase ssize_t VSNPrintf(CONST struct Locale *locale, STRPTR buffer, ssize_t bufferSize, CONST_STRPTR fmtTemplate, va_list args);
  // 472 SysV     ssize_t SNPrintf(CONST struct Locale *locale, STRPTR buffer, ssize_t bufferSize, CONST_STRPTR fmtTemplate, ...);
  {$ENDIF}


  // VarArgs versions
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  function  OpenCatalog(const locale: PLocale; const name: STRPTR; const tags: array of const): PCatalog; inline;
  {$ENDIF}
  {$IFDEF MORPHOS}
  function  OpenCatalog(const locale: PLocale; const name: STRPTR; const tags: array of ULONG): PCatalog; inline;
  {$ENDIF}



Implementation


  {$IFDEF AMIGA}
uses
  tagsarray;
  {$ENDIF}
  {$IFDEF AROS}
uses
  tagsarray, longarray; 
  {$ENDIF}



{$IF DEFINED(AMIGA) or DEFINED(AROS)}
function  OpenCatalog(const locale: PLocale; const name: STRPTR; const tags: array of const): PCatalog; inline;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  OpenCatalog := OpenCatalogA(locale, name, GetTagPtr(TagList));
end;
{$ENDIF}


{$IFDEF MORPHOS}
function  OpenCatalog(const locale: PLocale; const name: STRPTR; const tags: array of ULONG): PCatalog; inline;
begin
  OpenCatalog := OpenCatalogA(locale, name, @tags);
end;
{$ENDIF}



{$IF DEFINED(AROS) or DEFINED(AMIGA)}
initialization
  LocaleBase := PLocaleBase(OpenLibrary(LOCALENAME, 0));
finalization
  CloseLibrary(PLibrary(LocaleBase));
{$ENDIF}
end.
