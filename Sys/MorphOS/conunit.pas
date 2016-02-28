unit conunit;

{$UNITPATH ../Trinity/}
{$UNITPATH .}


interface


uses 
  TriniTypes,
  exec, console, keymap, inputevent,
  AGraphics, Intuition;


  {$PACKRECORDS 2}


const
  //* ----	console unit numbers for OpenDevice() */
  CONU_LIBRARY              = -1;               //* no unit, just fill in IO_DEVICE field */
  CONU_STANDARD             =  0;               //* standard unmapped console */

  //* ---- New unit numbers for OpenDevice() - (V36) */
  CONU_CHARMAP              =  1;               //* bind character map to console */
  CONU_SNIPMAP              =  3;               //* bind character map w/ snip to console */

  //* ---- New flag defines for OpenDevice() - (V37) */
  CONFLAG_DEFAULT           =  0;
  CONFLAG_NODRAW_ON_NEWSIZE =  1;

  PMB_ASM                   = (M_LNM + 1);      //* internal storage bit for AS flag */
  PMB_AWM                   = (PMB_ASM + 1);    //* internal storage bit for AW flag */
  MAXTABS                   = 80;


type
  PConUnit = ^TConUnit;
  TConUnit = record
    cu_MP           : TMsgPort;

    //* ---- read only variables */
    cu_Window       : PWindow;      //* intuition window bound to this unit */
    cu_XCP          : SWORD;        //* character position */
    cu_YCP          : SWORD;
    cu_XMax         : SWORD;        //* max character position */
    cu_YMax         : SWORD;
    cu_XRSize       : SWORD;        //* character raster size */
    cu_YRSize       : SWORD;
    cu_XROrigin     : SWORD;        //* raster origin */
    cu_YROrigin     : SWORD;
    cu_XRExtant     : SWORD;        //* raster maxima */
    cu_YRExtant     : SWORD;
    cu_XMinShrink   : SWORD;        //* smallest area intact from resize process */
    cu_YMinShrink   : SWORD;
    cu_XCCP         : SWORD;        //* cursor position */
    cu_YCCP         : SWORD;

    //* ---- read/write variables (writes must must be protected) */
    //* ---- storage for AskKeyMap and SetKeyMap */
    cu_KeyMapStruct : TKeyMap;

    //* ---- tab stops */
    cu_TabStops     : array [0..Pred(MAXTABS)] of UWORD;  //* 0 at start, 0xffff at end of list */

    //* ---- console rastport attributes */
    cu_Mask         : SBYTE;
    cu_FgPen        : SBYTE;
    cu_BgPen        : SBYTE;
    cu_AOLPen       : SBYTE;
    cu_DrawMode     : SBYTE;
    cu_Obsolete1    : SBYTE;    //* was cu_AreaPtSz -- not used in V36 */
    cu_Obsolete2    : APTR;     //* was cu_AreaPtrn -- not used in V36 */
    cu_Minterms     : array [0..Pred(8)] of UBYTE;  //* console minterms */
    cu_Font         : PTextFont;
    cu_AlgoStyle    : UBYTE;
    cu_TxFlags      : UBYTE;
    cu_TxHeight     : UWORD;
    cu_TxWidth      : UWORD;
    cu_TxBaseline   : UWORD;
    cu_TxSpacing    : SWORD;

    //* ---- console MODES and RAW EVENTS switches */
    cu_Modes        : array [0..Pred((PMB_AWM + 7) div 8)] of UBYTE;    //* one bit per mode */
    cu_RawEvents    : array [0..Pred((IECLASS_MAX + 8) div 8)] of UBYTE;
  end;


implementation


end.
