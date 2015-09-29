unit diskfont;


// unit diskfont for morphos


{$PACKRECORDS 2}


interface


uses
  Exec, AGraphics;


const
  MAXFONTPATH = 256;

type
  PFontContents = ^TFontContents;
  TFontContents = record
    fc_FileName     : packed array[0..MAXFONTPATH-1] of char;
    fc_YSize        : UWORD;
    fc_Style        : UBYTE;
    fc_Flags        : UBYTE;
  end;

  PTFontContents = ^TTFontContents;
  TTFontContents = record
    tfc_FileName    : packed array[0..MAXFONTPATH-3] of char; 
    tfc_TagCount    : UWORD;
    tfc_YSize       : UWORD;
    tfc_Style       : UBYTE;
    tfc_Flags       : UBYTE;
  end;

const
  FCH_ID            = $0f00;
  TFCH_ID           = $0f02;
  OFCH_ID           = $0f03;


type
  PFontContentsHeader = ^TFontContentsHeader;
  TFontContentsHeader = record
    fch_FileID      : UWORD;
    fch_NumEntries  : UWORD;
  end;


const
  DFH_ID            = $0f80;

  MAXFONTNAME       = 32;

type
  PDiskFontHeader = ^TDiskFontHeader;
  TDiskFontHeader = record
    dfh_DF          : TNode;
    dfh_FileID      : UWORD;
    dfh_Revision    : UWORD;
    dfh_Segment     : LONG;
    dfh_Name        : packed array [0..MAXFONTNAME-1] of char;
    dfh_TF          : TTextFont;
  end;

//const
//  dfh_TagList  dfh_Segment

const
  AFB_MEMORY        = 0;
  AFF_MEMORY        = (1 shl AFB_MEMORY);
  AFB_DISK          = 1;
  AFF_DISK          = (1 shl AFB_DISK);
  AFB_SCALED        = 2;
  AFF_SCALED        = (1 shl AFB_SCALED);
  AFB_BITMAP        = 3;
  AFF_BITMAP        = (1 shl AFB_BITMAP);

  AFB_TAGGED        = 16;
  AFF_TAGGED        = (1 shl AFB_TAGGED);


type
  PAvailFonts = ^TAvailFonts;
  TAvailFonts = record
    af_Type         : UWORD;
    af_Attr         : TTextAttr;
  end;

  PTAvailFonts = ^TTAvailFonts;
  TTAvailFonts = record
    taf_Type        : UWORD;
    taf_Attr        : TTextAttr;
  end;

  PAvailFontsHeader = ^TAvailFontsHeader;
  TAvailFontsHeader = record
    afh_NumEntries: UWORD;
  end;


const
  DISKFONTNAME      : PChar = 'diskfont.library';


var
  DiskfontBase      : pLibrary;


  function  OpenDiskFont(textAttr: pTextAttr location 'a0'): pTextFont; syscall DiskfontBase 030;
  function  AvailFonts(buffer: STRPTR location 'a0'; bufBytes: LONG location 'd0'; flags: LONG location 'd1'): LONG; syscall DiskfontBase 036;
  function  NewFontContents(fontsLock: BPTR location 'a0'; fontName: STRPTR location 'a1'): pFontContentsHeader; syscall DiskfontBase 042;
  procedure DisposeFontContents(fontContentsHeader: pFontContentsHeader location 'a1'); syscall DiskfontBase 048;
  function  NewScaledDiskFont(sourceFont: pTextFont location 'a0'; destTextAttr: pTextAttr location 'a1'): pDiskFontHeader; syscall DiskfontBase 054;
  //*** V45 ***/
  function  GetDiskFontCtrl(tagid: LONG location 'd0'): LONG; syscall DiskfontBase 060;
  procedure SetDiskFontCtrlA(taglist: pTagItem location 'a0'); syscall DiskfontBase 066;

  // Varargs version
  procedure SetDiskFontCtrl(tagArray: array of ULONG);


implementation


procedure SetDiskFontCtrl(tagArray: array of ULONG);
begin
  SetDiskFontCtrlA(@tagArray);
end;


end.
