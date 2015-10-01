unit prefs;


{
  Preferences related material
}

{$UNITPATH ../Trinity/}

interface


uses
  TriniTypes, exec, agraphics, intuition, iffparse, timer;
  

//  #########################################################################
//
//  globals
//
//  #########################################################################



//  #########################################################################
//
//  prefs/asl.h
//  No idea why Amiga version has it as it seems only present in MOS sdk
//
//  #########################################################################


{$IFDEF MORPHOS}
Const
  ID_ASL       = ord('A') shl 24 + ord('S') shl 16 + ord('L') shl 8 + ord(' '); // $41534C20;


Type
  PAslPrefs = ^TAslPrefs;
  TAslPrefs = record
    ap_Reserved         : array[0..4-1] of SLONG;

    ap_SortBy           : UBYTE;
    ap_SortDrawers      : UBYTE;
    ap_SortOrder        : UBYTE;

    ap_SizePosition     : UBYTE;

    ap_RelativeLeft     : SWORD;
    ap_RelativeTop      : SWORD;

    ap_RelativeWidth    : UBYTE;
    ap_RelativeHeight   : UBYTE;
  end;
{$ENDIF}



//  #########################################################################
//
//  prefs/font.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/font.h
//
//  #########################################################################

	
Const
  ID_FONT       = ord('F') shl 24 + ord('O') shl 16 + ord('N') shl 8 + ord('T'); // 1179602516;
	
  //* The maximum length the name of a font may have. */	
  FONTNAMESIZE  = 128;


Type
  PFontPrefs = ^TFontPrefs;
  TFontPrefs = record
    fp_Reserved     : array[0..3-1] of SLONG;   //* PRIVATE */
    fp_Reserved2    : UWORD;                    //* PRIVATE */
    fp_Type         : UWORD;                    //* see below */
    fp_FrontPen     : UBYTE;
    fp_BackPen      : UBYTE;
    fp_DrawMode     : UBYTE;
    fp_TextAttr     : TTextAttr;
    fp_Name         : packed array[0..FONTNAMESIZE-1] of Char;
   end;
	

Const
  //* Values for fp_Type */
  FP_WBFONT     = 0;
  FP_SYSFONT    = 1;
  FP_SCREENFONT = 2;



//  #########################################################################
//
//  prefs/icontrol.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/icontrol.h
//
//  #########################################################################


Const
  ID_ICTL   = ord('I') shl 24 + ord('C') shl 16 + ord('T') shl 8 + ord('L'); // 1229149260;
	

Type
  PIControlPrefs = ^TIControlPrefs;
  TIControlPrefs = record
    ic_Reserved     : array[0..3-1] of SLONG;   // System reserved
    ic_TimeOut      : UWORD;                    // Verify timeout
    ic_MetaDrag     : SWORD;                    // Meta drag mouse event
    ic_Flags        : ULONG;                    // IControl flags (see below)
    ic_WBtoFront    : UBYTE;                    // CKey: WB to front
    ic_FrontToBack  : UBYTE;                    // CKey: front screen to back
    ic_ReqTrue      : UBYTE;                    // CKey: Requester TRUE
    ic_ReqFalse     : UBYTE;                    // CKey: Requester FALSE
    {$IFDEF AROS}
    ic_Reserved2    : UWORD;
    ic_VDragModes   : array[0..2-1] of UWORD;   //* Screen drag modes, see below */
    {$ENDIF}
  end;


Const
  //* Values for ic_Flags */
  ICB_COERCE_COLORS = 0;
  ICB_COERCE_LACE   = 1;
  ICB_STRGAD_FILTER = 2;
  ICB_MENUSNAP      = 3;
  ICB_MODEPROMOTE   = 4;
  {$IFDEF MORPHOS}
  ICB_SQUARE_RATIO  = 5;
  {$ENDIF}

  ICF_COERCE_COLORS = (1 shl 0);
  ICF_COERCE_LACE   = (1 shl 1);
  ICF_STRGAD_FILTER = (1 shl 2);
  ICF_MENUSNAP      = (1 shl 3);
  ICF_MODEPROMOTE   = (1 shl 4);
  {$IFDEF MORPHOS}
  ICF_SQUARE_RATIO  = (1 shl 5);
  {$ENDIF}

  // FIXME: do we want these MOS extensions?
  // FIXME: what are the correct values?
  // Mag: i can't find them in MOS sdk
  {$IFDEF AROS}
  ICF_STICKYMENUS           = (1 shl 31);
  ICF_OPAQUEMOVE            = (1 shl 30);
  ICF_PRIVILIGEDGEDREFRESH  = (1 shl 29);
  ICF_OFFSCREENLAYERS       = (1 shl 28);
  ICF_DEFPUBSCREEN          = (1 shl 27);
  ICF_SCREENACTIVATION      = (1 shl 26);
  {$ENDIF}
  
  {$IFDEF AROS}
  //* AROS extension */
  ICF_PULLDOWNTITLEMENUS    = (1 shl 17);
  ICF_POPUPMENUS            = (1 shl 16);
  ICF_3DMENUS               = (1 shl 15);
  ICF_AVOIDWINBORDERERASE   = (1 shl 14);
  {$ENDIF}

  {$IFDEF AROS}
  //* Screen drag modes */
  ICVDM_TBOUND    = $0001;  //* Bounded at the top */
  ICVDM_BBOUND    = $0002;  //* Bounded at the bottom */
  ICVDM_LBOUND    = $0004;  //* Bounded at the left */
  ICVDM_RBOUND    = $0008;  //* Bounded at the right */
   
  //* Drag mode masks */
  ICVDM_HBOUND    = (ICVDM_LBOUND or ICVDM_RBOUND); //* Horisontal bounding */
  ICVDM_VBOUND    = (ICVDM_TBOUND or ICVDM_BBOUND); //* Verticak bounding   */
  {$ENDIF}



//  #########################################################################
//
//  prefs/input.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/input.h
//
//  #########################################################################


Const
  ID_INPT       = ord('I') shl 24 + ord('N') shl 16 + ord('P') shl 8 + ord('T'); // 1229869140;


Type
  pInputPrefs = ^tInputPrefs;
  tInputPrefs = record
    ip_Keymap               : packed array[0..16-1] of Char;
    ip_PointerTicks         : UWORD;
    ip_DoubleClick          : TTimeVal;
    ip_KeyRptDelay          : TTimeVal;
    ip_KeyRptSpeed          : TTimeVal;
    ip_MouseAccel           : SWORD;
    
    {$IF DEFINED(AMIGAOS) or DEFINED(AROS)}
    //* The following fields are compatible with AmigaOS v4 */
    ip_ClassicKeyboard      : ULONG;                            //* Reserved                    */
    ip_KeymapName           : packed array[0..64-1] of Char;    //* Longer version of ip_Keymap */
    ip_SwitchMouseButtons   : ULONG;                            //* Swap mouse buttons, boolean */
    {$ENDIF}
  end;


{$IFDEF AROS}
  //* Experimental and AROS-specific, subject to change */
Const
  ID_KMSW       = ord('K') shl 24 + ord('M') shl 16 + ord('S') shl 8 + ord('W');

Type  
  KMSPrefs = record
    kms_Enabled     : UBYTE;                            //* Boolean - alternate keymap enabled */
    kms_Reserved    : UBYTE;
    kms_SwitchQual  : UWORD;                            //* Switch key and qualifier           */
    kms_SwitchCode  : UWORD;
    kms_AltKeyMap   : packed array[0..64-1] of Char;    //* Alternate keymap name              */
  end;
{$ENDIF}


//  #########################################################################
//
//  prefs/locale.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/locale.h
//
//  #########################################################################


const
  ID_LCLE       = ord('L') shl 24 + ord('C') shl 16 + ord('L') shl 8 + ord('E'); // 1279478853;
  ID_CTRY       = ord('C') shl 24 + ord('T') shl 16 + ord('R') shl 8 + ord('Y'); // 1129599577;


Type
  PRegionPrefs = ^TRegionPrefs;
  TRegionPrefs = record
    cp_Reserved             : array[0..4-1] of ULONG;

    cp_RegionCode           : ULONG;
    cp_TelephoneCode        : ULONG;
    cp_MeasuringSystem      : UBYTE;

    cp_DateTimeFormat       : packed array[0..80-1] of Char;
    cp_DateFormat           : packed array[0..40-1] of Char;
    cp_TimeFormat           : packed array[0..40-1] of Char;
    cp_ShortDateTimeFormat  : packed array[0..80-1] of Char;
    cp_ShortDateFormat      : packed array[0..40-1] of Char;
    cp_ShortTimeFormat      : packed array[0..40-1] of Char;

    cp_DecimalPoint         : packed array[0..10-1] of Char;
    cp_GroupSeparator       : packed array[0..10-1] of Char;
    cp_FracGroupSeparator   : packed array[0..10-1] of Char;
    cp_Grouping             : packed array[0..10-1] of UBYTE;
    cp_FracGrouping         : packed array[0..10-1] of UBYTE;

    cp_MonDecimalPoint      : packed array[0..10-1] of Char;
    cp_MonGroupSeparator    : packed array[0..10-1] of Char;
    cp_MonFracGroupSeparator: packed array[0..10-1] of Char;   
    cp_MonGrouping          : packed array[0..10-1] of UBYTE;
    cp_MonFracGrouping      : packed array[0..10-1] of UBYTE;
    cp_MonFracDigits        : UBYTE;
    cp_MonIntFracDigits     : UBYTE;

    cp_MonCS                : packed array[0..10-1] of Char;
    cp_MonSmallCS           : packed array[0..10-1] of Char;
    cp_MonIntCS             : packed array[0..10-1] of Char;

    cp_MonPositiveSign      : packed array[0..10-1] of Char;
    cp_MonPositiveSpaceSep  : UBYTE;
    cp_MonPositiveSignPos   : UBYTE;
    cp_MonPositiveCSPos     : UBYTE;

    cp_MonNegativeSign      : packed array[0..10-1] of Char;
    cp_MonNegativeSpaceSep  : UBYTE;
    cp_MonNegativeSignPos   : UBYTE;
    cp_MonNegativeCSPos     : UBYTE;

    cp_CalendarType         : UBYTE;
  end;

  TCountryPrefs = TRegionPrefs;
  PCountryPrefs = ^TCountryPrefs;
  // cp_CountryCode = cp_RegionCode
  
  PLocalePrefs = ^TLocalePrefs;
  TLocalePrefs = record
    lp_Reserved             : array[0..4-1] of ULONG;
    lp_RegionName           : packed array[0..32-1] of Char;
    lp_PreferredLanguages   : packed array[0..10-1] of packed array[0..30-1] of Char;
    lp_GMTOffset            : SLONG;
    lp_Flags                : ULONG;            //* The same as loc_Flags in struct Locale */

    lp_RegionData           : TCountryPrefs;
  end;

  (*
  #define lp_CountryName lp_RegionName
  #define lp_CountryData lp_RegionData
  *)



//  #########################################################################
//
//  prefs/overscan.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/overscan.h
//
//  #########################################################################


const
  ID_OSCN       = ord('O') shl 24 + ord('S') shl 16 + ord('C') shl 8 + ord('N'); // 1330856782;

  OSCAN_MAGIC = $FEDCBA89;


Type
  POverscanPrefs = ^TOverscanPrefs;
  TOverscanPrefs = record
    os_Reserved     : ULONG;
    os_Magic        : ULONG;
    os_HStart       : UWORD;
    os_HStop        : UWORD;
    os_VStart       : UWORD;
    os_VStop        : UWORD;
    os_DisplayID    : ULONG;
    os_ViewPos      : TPoint;
    os_Text         : TPoint;
    os_Standard     : TRectangle;
  end;



//  #########################################################################
//
//  prefs/palette.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/palette.h
//
//  #########################################################################


const
  ID_PALT       = ord('P') shl 24 + ord('A') shl 16 + ord('L') shl 8 + ord('T'); // 11346456660;


Type
  PPalettePrefs = ^TPalettePrefs;
  TPalettePrefs = record
    pap_Reserved     : Array[0..4-1]  of SLONG;         // System reserved
    pap_4ColorPens   : Array[0..32-1] of UWORD;
    pap_8ColorPens   : Array[0..32-1] of UWORD;
    pap_Colors       : Array[0..32-1] of TColorSpec;    // Used as full 16-bit RGB values
  end;



//  #########################################################################
//
//  prefs/pointer.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/pointer.h
//
//  #########################################################################


const
  ID_PNTR       = ord('P') shl 24 + ord('A') shl 16 + ord('L') shl 8 + ord('T'); // 1347310674;


Type
  PPointerPrefs = ^TPointerPrefs;
  TPointerPrefs = record
    pp_Reserved : Array[0..4-1] of ULONG;
    pp_Which    : UWORD;                    // 0=NORMAL, 1=BUSY
    pp_Size     : UWORD;                    // see <intuition/pointerclass.h>
    pp_Width    : UWORD;                    // Width in pixels
    pp_Height   : UWORD;                    // Height in pixels
    pp_Depth    : UWORD;                    // Depth
    pp_YSize    : UWORD;                    // YSize
    pp_X, pp_Y  : UWORD;                    // Hotspot
  end;


Const
  WBP_NORMAL    =  0;
  WBP_BUSY      =  1;


Type
  PRGBTable = ^TRGBTable;
  TRGBTable = record
    t_Red   : UBYTE;
    t_Green : UBYTE;
    t_Blue  : UBYTE;
  end;


{$IFDEF AROS}
  //* New preferences file, AROS-specific */
  //* Not stable yet, subject to change   */
const
  ID_NPTR       = ord('N') shl 24 + ord('P') shl 16 + ord('T') shl 8 + ord('R');

Type
  PNewPointerPrefs = ^TNewPointerPrefs;
  TNewPointerPrefs = record
    npp_Which       : UWORD;                        //* Which Intuition pointer to replace               */
    npp_AlphaValue  : UWORD;                        //* Alpha channel value if not specified in the file */
    npp_WhichInFile : ULONG;                        //* Which pointer to take from the file              */
    npp_X, npp_Y    : UWORD;                        //* Hotspot coordinates                              */
    npp_File        : packed array [0..0] of Char;  //* NULL-terminated file name follows                */
  end;
{$ENDIF}


//  #########################################################################
//
//  prefs/prefhdr.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/prefhdr.h
//
//  #########################################################################


const
  ID_PREF       = ord('P') shl 24 + ord('R') shl 16 + ord('E') shl 8 + ord('F');  // 1347568966;
  ID_PRHD       = ord('P') shl 24 + ord('R') shl 16 + ord('H') shl 8 + ord('D');  // 1347569732;
  

Type
  PPrefHeader = ^TPrefHeader;
  TPrefHeader = packed record
    ph_Version  : UBYTE;        //* The version of the PrefHeader data */
    ph_Type     : UBYTE;        //* The type of the PrefHeader data */
    ph_Flags    : ULONG;        //* Flags, set to 0 for now */
  end;


{$IFDEF AROS}
Const
  PHV_AMIGAOS   = 0;            //* Format from AmigaOS v36+ */
  PHV_CURRENT   = PHV_AMIGAOS;  //* The current version */
{$ENDIF}



//  #########################################################################
//
//  prefs/printergfx.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/printergfx.h
//
//  #########################################################################


const
  ID_PGFX       = ord('P') shl 24 + ord('G') shl 16 + ord('F') shl 8 + ord('X');  // 1346848344;


Type
  PPrinterGfxPrefs = ^TPrinterGfxPrefs;
  TPrinterGfxPrefs = record
    pg_Reserved         : Array[0..4-1] of SLONG;
    pg_Aspect           : UWORD;
    pg_Shade            : UWORD;
    pg_Image            : UWORD;
    pg_Threshold        : SWORD;
    pg_ColorCorrect     : UBYTE;
    pg_Dimensions       : UBYTE;
    pg_Dithering        : UBYTE;
    pg_GraphicFlags     : UWORD;
    pg_PrintDensity     : UBYTE;
    pg_PrintMaxWidth    : UWORD;    //* in 1/10 of an inch */
    pg_PrintMaxHeight   : UWORD;    //* in 1/10 of an inch */
    pg_PrintXOffset     : UBYTE;    //* in 1/10 of an inch */
    pg_PrintYOffset     : UBYTE;    //* in 1/10 of an inch */
 end;


Const
  // pg_Aspect constants
  PA_HORIZONTAL     = 0;    //* Portrait */
  PA_VERTICAL       = 1;    //* Landscape */

  // pg_Shade constants
  PS_BW             = 0;
  PS_GREYSCALE      = 1;
  PS_COLOR          = 2;
  PS_GREY_SCALE2    = 3;

  // pg_Image constants
  PI_POSITIVE       = 0;
  PI_NEGATIVE       = 1;

  // pg_ColorCorrect flags
  PCCB_RED          = 1;        // color correct red shades
  PCCB_GREEN        = 2;        // color correct green shades
  PCCB_BLUE         = 3;        // color correct blue shades

  PCCF_RED          = (1 shl 0);
  PCCF_GREEN        = (1 shl 1);
  PCCF_BLUE         = (1 shl 2);

  // pg_Dimensions constants
  PD_IGNORE         = 0;        // ignore max width/height settings
  PD_BOUNDED        = 1;        // use max w/h as boundaries
  PD_ABSOLUTE       = 2;        // use max w/h as absolutes
  PD_PIXEL          = 3;        // use max w/h as prt pixels
  PD_MULTIPLY       = 4;        // use max w/h as multipliers

  // pg_Dithering constants
  PD_ORDERED        = 0;        // ordered dithering
  PD_HALFTONE       = 1;        // halftone dithering
  PD_FLOYD          = 2;        // Floyd-Steinberg dithering

  // pg_GraphicsFlags flags
  PGFB_CENTER_IMAGE      = 0;   // center image on paper
  PGFB_INTEGER_SCALING   = 1;   // force integer scaling
  PGFB_ANTI_ALIAS        = 2;   // anti-alias image

  PGFF_CENTER_IMAGE      = (1 shl 0);
  PGFF_INTEGER_SCALING   = (1 shl 1);
  PGFF_ANTI_ALIAS        = (1 shl 2);



//  #########################################################################
//
//  prefs/printerps.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/printerps.h
//
//  #########################################################################


const
  ID_PSPD       = ord('P') shl 24 + ord('S') shl 16 + ord('P') shl 8 + ord('D');  // 1347637316;


Type
  PPrinterPSPrefs = ^TPrinterPSPrefs;
  TPrinterPSPrefs = record
    ps_Reserved     : Array[0..4-1] of SLONG;               // System reserved

    ps_DriverMode   : UBYTE;
    ps_PaperFormat  : UBYTE;
    ps_Reserved1    : packed array[0..2-1] of UBYTE;
    ps_Copies       : SLONG;
    ps_PaperWidth   : SLONG;
    ps_PaperHeight  : SLONG;
    ps_HorizontalDPI: SLONG;
    ps_VerticalDPI  : SLONG;

    ps_Font         : UBYTE;
    ps_Pitch        : UBYTE;
    ps_Orientation  : UBYTE;
    ps_Tab          : UBYTE;
    ps_Reserved2    : packed array[0..8-1] of UBYTE;

    ps_LeftMargin   : SLONG;
    ps_RightMargin  : SLONG;
    ps_TopMargin    : SLONG;
    ps_BottomMargin : SLONG;
    ps_FontPointSize: SLONG;
    ps_Leading      : SLONG;
    ps_Reserved3    : packed array[0..8-1] of UBYTE;

    ps_LeftEdge     : SLONG;
    ps_TopEdge      : SLONG;
    ps_Width        : SLONG;
    ps_Height       : SLONG;
    ps_Image        : UBYTE;
    ps_Shading      : UBYTE;
    ps_Dithering    : UBYTE;
    ps_Reserved4    : packed array[0..9-1] of UBYTE;

    // Graphics Scaling
    ps_Aspect       : UBYTE;
    ps_ScalingType  : UBYTE;
    ps_Reserved5    : UBYTE;
    ps_Centering    : UBYTE;
    ps_Reserved6    : packed array[0..8-1] of UBYTE;
  end;


Const
  // ps_DriverMode constants
  DM_POSTSCRIPT     = 0;
  DM_PASSTHROUGH    = 1;

  // ps_PaperFormat constants
  PF_USLETTER       = 0;
  PF_USLEGAL        = 1;
  PF_A4             = 2;
  PF_CUSTOM         = 3;

  // ps_Font constants
  FONT_COURIER      = 0;
  FONT_TIMES        = 1;
  FONT_HELVETICA    = 2;
  FONT_HELV_NARROW  = 3;
  FONT_AVANTGARDE   = 4;
  FONT_BOOKMAN      = 5;
  FONT_NEWCENT      = 6;
  FONT_PALATINO     = 7;
  FONT_ZAPFCHANCERY = 8;

  // ps_Pitch constants
  PITCH_NORMAL      = 0;
  PITCH_COMPRESSED  = 1;
  PITCH_EXPANDED    = 2;

  // ps_Orientation constants
  ORIENT_PORTRAIT   = 0;
  ORIENT_LANDSCAPE  = 1;

  // ps_Tab constants
  TAB_4             = 0;
  TAB_8             = 1;
  TAB_QUART         = 2;
  TAB_HALF          = 3;
  TAB_INCH          = 4;

  // ps_Image constants
  IM_POSITIVE       = 0;
  IM_NEGATIVE       = 1;

  // ps_Shading constants
  SHAD_BW           = 0;
  SHAD_GREYSCALE    = 1;
  SHAD_COLOR        = 2;

  // ps_Dithering constants
  DITH_DEFAULT      = 0;
  DITH_DOTTY        = 1;
  DITH_VERT         = 2;
  DITH_HORIZ        = 3;
  DITH_DIAG         = 4;

  // ps_Aspect constants
  ASP_HORIZ         = 0;
  ASP_VERT          = 1;

  // ps_ScalingType constants
  ST_ASPECT_ASIS    = 0;
  ST_ASPECT_WIDE    = 1;
  ST_ASPECT_TALL    = 2;
  ST_ASPECT_BOTH    = 3;
  ST_FITS_WIDE      = 4;
  ST_FITS_TALL      = 5;
  ST_FITS_BOTH      = 6;

  // ps_Centering constants
  CENT_NONE         = 0;
  CENT_HORIZ        = 1;
  CENT_VERT         = 2;
  CENT_BOTH         = 3;



//  #########################################################################
//
//  prefs/printertxt.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/printertxt.h
//
//  #########################################################################


const
  ID_PTXT       = ord('P') shl 24 + ord('T') shl 16 + ord('X') shl 8 + ord('T');  // 1347704916;
  ID_PUNT       = ord('P') shl 24 + ord('U') shl 16 + ord('N') shl 8 + ord('T');  // 1347767892;
  ID_PDEV       = ord('P') shl 24 + ord('D') shl 16 + ord('E') shl 8 + ord('V');  // $50444556;
  // already defined
  //ID_PGFX       = ord('P') shl 24 + ord('G') shl 16 + ord('F') shl 8 + ord('X');

  DRIVERNAMESIZE = 30;               // Filename size
  DEVICENAMESIZE = 32;               // .device name size
  UNITNAMESIZE   = 32;


Type
  PPrinterTxtPrefs = ^TPrinterTxtPrefs;
  TPrinterTxtPrefs = record
    pt_Reserved     : array[0..4-1] of SLONG;                       // System reserved
    pt_Driver       : packed array[0..DRIVERNAMESIZE-1] of Char;    // printer driver filename
    pt_Port         : UBYTE;                                        // printer port connection

    pt_PaperType    : UWORD;
    pt_PaperSize    : UWORD;
    pt_PaperLength  : UWORD;                        //* # of lines per page */

    pt_Pitch        : UWORD;
    pt_Spacing      : UWORD;
    pt_LeftMargin   : UWORD;
    pt_RightMargin  : UWORD;
    pt_Quality      : UWORD;
  end;


const
  // pt_Port constants
  PP_PARALLEL   = 0;
  PP_SERIAL     = 1;

  // pt_PaperType constants
  PT_FANFOLD    = 0;
  PT_SINGLE     = 1;

  // pt_PaperSize constants
  PS_US_LETTER  = 0 ;
  PS_US_LEGAL   = 1 ;
  PS_N_TRACTOR  = 2 ;
  PS_W_TRACTOR  = 3 ;
  PS_CUSTOM     = 4 ;
  PS_EURO_A0    = 5 ;              // European size A0: 841 x 1189
  PS_EURO_A1    = 6 ;              // European size A1: 594 x 841
  PS_EURO_A2    = 7 ;              // European size A2: 420 x 594
  PS_EURO_A3    = 8 ;              // European size A3: 297 x 420
  PS_EURO_A4    = 9 ;              // European size A4: 210 x 297
  PS_EURO_A5    = 10;              // European size A5: 148 x 210
  PS_EURO_A6    = 11;              // European size A6: 105 x 148
  PS_EURO_A7    = 12;              // European size A7: 74 x 105
  PS_EURO_A8    = 13;              // European size A8: 52 x 74

  // pt_PrintPitch constants
  PP_PICA       = 0;        //* 10 characters per inch */
  PP_ELITE      = 1;        //* 12 characters per inch */
  PP_FINE       = 2;        //* 17.1 characters per inch */

  { pt_PrintSpacing constants }
  PS_SIX_LPI    = 0;        //* 6 lines per inch */
  PS_EIGHT_LPI  = 1;        //* 8 lines per inch */

  { pt_PrintQuality constants }
  PQ_DRAFT      = 0;        //* Density select 0 */
  PQ_LETTER     = 1;        //* Density select 1 */


Type
  PPrinterUnitPrefs = ^TPrinterUnitPrefs;
  TPrinterUnitPrefs = record
    pu_Reserved         : array[0..4-1] of SLONG;                       // System reserved
    pu_UnitNum          : SLONG;                                        // Unit number for OpenDevice()
    pu_OpenDeviceFlags  : ULONG;                                        // Flags for OpenDevice()
    pu_DeviceName       : packed array[0..DEVICENAMESIZE-1] of Char;    // Name for OpenDevice()
  end;


  PPrinterDeviceUnitPrefs = ^TPrinterDeviceUnitPrefs;
  TPrinterDeviceUnitPrefs = record
    pd_Reserved     : array[0..4-1] of SLONG;                       // System reserved
    pd_UnitNum      : SLONG;                                        // Unit number for OpenDevice()
    pd_UnitName     : packed array[0..(UNITNAMESIZE)-1] of Char;    // Symbolic name of the unit
  end;



{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
//  #########################################################################
//
//  prefs/reaction.h
//
//  #########################################################################


const
  ID_RACT       = ord('R') shl 24 + ord('A') shl 16 + ord('C') shl 8 + ord('T');  // $52414354;


  // already defined
  // FONTNAMESIZE = (128)


type
  PReactionPrefs = ^tReactionPrefs;
  tReactionPrefs = record
    rp_BevelType        : UWORD;
    rp_GlyphType        : UWORD;
    rp_LayoutSpacing    : UWORD;
    rp_3DProp           : BOOL;
    rp_LabelPen         : UWORD;
    rp_LabelPlace       : UWORD;
    rp_3DLabel          : BOOL;
    rp_SimpleRefresh    : BOOL;
    rp_3DLook           : BOOL;
    rp_FallbackAttr     : TTextAttr;
    rp_LabelAttr        : TTextAttr;
    rp_FallbackName     : packed array[0..(FONTNAMESIZE)-1] of Char;
    rp_LabelName        : packed array[0..(FONTNAMESIZE)-1] of Char;
    rp_Pattern          : packed array[0..256-1] of UBYTE;
  end;
{$ENDIF}



//  #########################################################################
//
//  prefs/screenmode.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/screenmode.h
//
//  #########################################################################


Const
  ID_SCRM       = ord('S') shl 24 + ord('C') shl 16 + ord('R') shl 8 + ord('M');  // 1396920909;


Type
  PScreenModePrefs = ^TScreenModePrefs;
  TScreenModePrefs = record
    smp_Reserved    : array[0..4-1] of ULONG;
    smp_DisplayID   : ULONG;
    smp_Width       : UWORD;
    smp_Height      : UWORD;
    smp_Depth       : UWORD;
    smp_Control     : UWORD;
  end;

Const
  // smp_Control flags
  SMB_AUTOSCROLL    = 1;

  SMF_AUTOSCROLL    = (1 shl 0);



//  #########################################################################
//
//  prefs/serial.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/serial.h
//
//  #########################################################################


Const
  ID_SERL       = ord('S') shl 24 + ord('E') shl 16 + ord('R') shl 8 + ord('L');  // 1397051980;


Type
  PSerialPrefs = ^TSerialPrefs;
  TSerialPrefs = record
    sp_Reserved         : array[0..3-1] of SLONG;   // System reserved
    sp_Unit0Map         : ULONG;                    // What unit 0 really refers to
    sp_BaudRate         : ULONG;                    // Baud rate

    sp_InputBuffer      : ULONG;                    // Input buffer: 0 - 65536
    sp_OutputBuffer     : ULONG;                    // Future: Output: 0 - 65536

    sp_InputHandshake   : UBYTE;                    // Input handshaking
    sp_OutputHandshake  : UBYTE;                    // Future: Output handshaking

    sp_Parity           : UBYTE;                    // Parity
    sp_BitsPerChar      : UBYTE;                    // I/O bits per character
    sp_StopBits         : UBYTE;                    // Stop bits
  end;


Const
  // sp_Parity constants
  PARITY_NONE     = 0;
  PARITY_EVEN     = 1;
  PARITY_ODD      = 2;
  PARITY_MARK     = 3;               // Future enhancement
  PARITY_SPACE    = 4;               // Future enhancement

  // sp_Input/OutputHandshaking constants
  HSHAKE_XON      = 0;
  HSHAKE_RTS      = 1;
  HSHAKE_NONE     = 2;



//  #########################################################################
//
//  prefs/sound.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/sound.h
//
//  #########################################################################


Const
  ID_SOND       = ord('S') shl 24 + ord('O') shl 16 + ord('N') shl 8 + ord('D');  // 1397706308;


Type
  PSoundPrefs = ^TSoundPrefs;
  TSoundPrefs = record
    sop_Reserved        : array[0..4-1] of SLONG;   // System reserved
    sop_DisplayQueue    : BOOL;                     // Flash the display?
    sop_AudioQueue      : BOOL;                     // Make some sound?
    sop_AudioType       : UWORD;                    // Type of sound, see below
    sop_AudioVolume     : UWORD;                    // Volume of sound, 0..64
    sop_AudioPeriod     : UWORD;                    // Period of sound, 127..2500
    sop_AudioDuration   : UWORD;                    // Length of simple beep
    sop_AudioFileName   : packed array[0..256-1] of Char;   // Filename of 8SVX file
  end;


Const
  // sop_AudioType constants
  SPTYPE_BEEP       = 0;       // simple beep sound
  SPTYPE_SAMPLE     = 1;       // sampled sound



{$IFDEF AROS}
//  #########################################################################
//
//  prefs/trackdisk.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/trackdisk.h
//
//  #########################################################################


Const
  TD_NUMUNITS   =   2;
  
  TRACKDISK_PREFS_NAME : PChar = 'SYS:Prefs/Presets/trackdisk.prefs';

  TDPR_UnitNum  =   TAG_USER+0;
  TDPR_PubFlags =   TAG_USER+1;
  TDPR_RetryCnt =   TAG_USER+2;
{$ENDIF}



{$IFDEF AROS}
//  #########################################################################
//
//  prefs/wanderer.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/wanderer.h
//
//  #########################################################################


Const
  ID_WANDR      = ord('W') shl 24 + ord('A') shl 16 + ord('N') shl 8 + ord('R');


  //* The maximum length the path may have. */
  PATHLENGTHSIZE            = 256;
  ICON_TEXT_MAXLEN_DEFAULT  =  20;


Type
  PWandererPrefsIFFChunkHeader = ^TWandererPrefsIFFChunkHeader;
  TWandererPrefsIFFChunkHeader = record
    wpIFFch_ChunkType   : packed array[0..100-1] of Char;
    wpIFFch_ChunkSize   : ULONG;
  end;

  PWandererPrefs = ^TWandererPrefs;
  TWandererPrefs = record
    wpd_NavigationMethod : ULONG;   // Are we using the toolbar or not for navigation
    wpd_ToolbarEnabled   : ULONG;   // Is the toolbar enabled?

    wpd_IconListMode     : ULONG;   // How is it going to be listed
    wpd_IconTextMode     : ULONG;   // How is the text rendered

    wpd_IconTextMaxLen   : ULONG;   // Max length of icon text
  end;


Const
  WPD_NAVIGATION_CLASSIC    = 0;
  WPD_NAVIGATION_ENHANCED   = 1;

  WPD_ICONLISTMODE_GRID     = 0;
  WPD_ICONLISTMODE_PLAIN    = 1;

  WPD_ICONTEXTMODE_OUTLINE  = 0;
  WPD_ICONTEXTMODE_PLAIN    = 1;

  WPD_GENERAL               = 0;
  WPD_APPEARANCE            = 1;
  WPD_TOOLBAR               = 2;
{$ENDIF}



//  #########################################################################
//
//  prefs/wbpattern.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/wbpattern.h
//
//  #########################################################################


Const
  ID_PTRN       = ord('P') shl 24 + ord('T') shl 16 + ord('R') shl 8 + ord('N'); // 1347703374;


Type
  PWBPatternPrefs = ^TWBPatternPrefs;
  TWBPatternPrefs = record
    wbp_Reserved    : array[0..4-1] of ULONG;
    wbp_Which       : UWORD;                    // Which pattern is it
    wbp_Flags       : UWORD;
    wbp_Revision    : SBYTE;                    // Must be set to zero
    wbp_Depth       : SBYTE;                    // Depth of pattern
    wbp_DataLength  : UWORD;                    // Length of following data
  end;


Const
  //* Values for wbp_Which */
  WBP_ROOT          = 0;
  WBP_DRAWER        = 1;
  WBP_SCREEN        = 2;

  //* Values for wbp_Flags */
  WBPF_PATTERN      = $0001;
  WBPF_NOREMAP      = $0010;

  // V44 
  WBPF_DITHER_MASK  = $0300;
  WBPF_DITHER_DEF   = $0000;
  WBPF_DITHER_BAD   = $0100;
  WBPF_DITHER_GOOD  = $0200;
  WBPF_DITHER_BEST  = $0300;

  WBPF_PRECISION_MASK   = $0C00;
  WBPF_PRECISION_DEF    = $0000;
  WBPF_PRECISION_ICON   = $0400;
  WBPF_PRECISION_IMAGE  = $0800;
  WBPF_PRECISION_EXACT  = $0C00;

  {$IFDEF MORHPOS}
  // V45
  WBPF_PLACEMENT_MASK       = $3000;
  WBPF_PLACEMENT_TILE       = $0000;
  WBPF_PLACEMENT_CENTER     = $1000;
  WBPF_PLACEMENT_SCALE      = $2000;
  WBPF_PLACEMENT_SCALEGOOD  = $3000;
  {$ENDIF}
  
Const  
  MAXDEPTH       = 3;       //  Max depth supported (8 colors)
  DEFPATDEPTH    = 2;       //  Depth of default patterns

  PAT_WIDTH      = 16;
  PAT_HEIGHT     = 16;



//  #########################################################################
//
//  prefs/workbench.h
//  http://repo.or.cz/w/AROS.git/blob/HEAD:/compiler/include/prefs/workbench.h
//
//  #########################################################################


Const
  ID_WBNC       = ord('W') shl 24 + ord('B') shl 16 + ord('N') shl 8 + ord('C'); // $57424E43;


Type
  PWorkbenchPrefs = ^TWorkbenchPrefs;
  TWorkbenchPrefs = record
    wbp_DefaultStackSize    : ULONG;
    wbp_TypeRestartTime     : ULONG;

    wbp_IconPrecision       : ULONG;
    wbp_EmbossRect          : TRectangle;
    wbp_Borderless          : BOOL;
    wbp_MaxNameLength       : SLONG;
    wbp_NewIconsSupport     : BOOL;
    wbp_ColorIconSupport    : BOOL;

    {$IFDEF MORPHOS}
    // new for V45
    wbp_ImageMemType        : ULONG;
    wbp_LockPens            : BOOL;
    wbp_NoTitleBar          : BOOL;
    wbp_NoGauge             : BOOL;
    {$ENDIF}
  end;


Const
  ID_WBHD       = ord('W') shl 24 + ord('B') shl 16 + ord('H') shl 8 + ord('D'); // $57424844;


Type
   PWorkbenchHiddenDevicePrefs = ^TWorkbenchHiddenDevicePrefs;
   TWorkbenchHiddenDevicePrefs = record
     whdp_Name : packed array[0..0] of PChar;  // C String including NULL char
   end;


   
Implementation



End.
