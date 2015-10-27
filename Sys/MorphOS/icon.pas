unit icon;


{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$IFDEF AMIGA}   {$PACKRECORDS 2} {$ENDIF}
{$IFDEF AROS}    {$PACKRECORDS C} {$ENDIF}
{$IFDEF MORPHOS} {$PACKRECORDS 2} {$ENDIF}

{$UNITPATH ../Trinity/}
{$UNITPATH .}


interface


uses
  trinitypes, exec, amigados, agraphics, intuition, workbench, datatypes, utility;


// ###### workbench/icon.h ##################################################


const
  ICONNAME      : PChar = 'icon.library';  


const

  //*** V44 ***/


  ICONA_Dummy                           = (TAG_USER + $9000);
  ICONA_ErrorCode                       = (ICONA_Dummy + 1);

  ICONCTRLA_SetGlobalScreen             = (ICONA_Dummy + 2);
  ICONCTRLA_GetGlobalScreen             = (ICONA_Dummy + 3);

  ICONCTRLA_SetGlobalPrecision          = (ICONA_Dummy + 4);
  ICONCTRLA_GetGlobalPrecision          = (ICONA_Dummy + 5);

  ICONCTRLA_SetGlobalEmbossRect         = (ICONA_Dummy + 6);
  ICONCTRLA_GetGlobalEmbossRect         = (ICONA_Dummy + 7);

  ICONCTRLA_SetGlobalFrameless          = (ICONA_Dummy + 8);
  ICONCTRLA_GetGlobalFrameless          = (ICONA_Dummy + 9);

  ICONCTRLA_SetGlobalNewIconsSupport    = (ICONA_Dummy + 10);
  ICONCTRLA_GetGlobalNewIconsSupport    = (ICONA_Dummy + 11);

  ICONCTRLA_SetGlobalIdentifyHook       = (ICONA_Dummy + 12);
  ICONCTRLA_GetGlobalIdentifyHook       = (ICONA_Dummy + 13);

  ICONCTRLA_GetImageMask1               = (ICONA_Dummy + 14);
  ICONCTRLA_GetImageMask2               = (ICONA_Dummy + 15);

  ICONCTRLA_SetTransparentColor1        = (ICONA_Dummy + 16);
  ICONCTRLA_GetTransparentColor1        = (ICONA_Dummy + 17);
  ICONCTRLA_SetTransparentColor2        = (ICONA_Dummy + 18);
  ICONCTRLA_GetTransparentColor2        = (ICONA_Dummy + 19);

  ICONCTRLA_SetPalette1                 = (ICONA_Dummy + 20);
  ICONCTRLA_GetPalette1                 = (ICONA_Dummy + 21);
  ICONCTRLA_SetPalette2                 = (ICONA_Dummy + 22);
  ICONCTRLA_GetPalette2                 = (ICONA_Dummy + 23);

  ICONCTRLA_SetPaletteSize1             = (ICONA_Dummy + 24);
  ICONCTRLA_GetPaletteSize1             = (ICONA_Dummy + 25);
  ICONCTRLA_SetPaletteSize2             = (ICONA_Dummy + 26);
  ICONCTRLA_GetPaletteSize2             = (ICONA_Dummy + 27);

  ICONCTRLA_SetImageData1               = (ICONA_Dummy + 28);
  ICONCTRLA_GetImageData1               = (ICONA_Dummy + 29);
  ICONCTRLA_SetImageData2               = (ICONA_Dummy + 30);
  ICONCTRLA_GetImageData2               = (ICONA_Dummy + 31);

  ICONCTRLA_SetFrameless                = (ICONA_Dummy + 32);
  ICONCTRLA_GetFrameless                = (ICONA_Dummy + 33);

  ICONCTRLA_SetNewIconsSupport          = (ICONA_Dummy + 34);
  ICONCTRLA_GetNewIconsSupport          = (ICONA_Dummy + 35);

  ICONCTRLA_SetAspectRatio              = (ICONA_Dummy + 36);
  ICONCTRLA_GetAspectRatio              = (ICONA_Dummy + 37);

  ICONCTRLA_SetWidth                    = (ICONA_Dummy + 38);
  ICONCTRLA_GetWidth                    = (ICONA_Dummy + 39);
  ICONCTRLA_SetHeight                   = (ICONA_Dummy + 40);
  ICONCTRLA_GetHeight                   = (ICONA_Dummy + 41);

  ICONCTRLA_IsPaletteMapped             = (ICONA_Dummy + 42);
  ICONCTRLA_GetScreen                   = (ICONA_Dummy + 43);
  ICONCTRLA_HasRealImage2               = (ICONA_Dummy + 44);

  ICONGETA_GetDefaultType               = (ICONA_Dummy + 45);
  ICONGETA_GetDefaultName               = (ICONA_Dummy + 46);

  ICONGETA_FailIfUnavailable            = (ICONA_Dummy + 47);
  ICONGETA_GetPaletteMappedIcon         = (ICONA_Dummy + 48);
  ICONGETA_IsDefaultIcon                = (ICONA_Dummy + 49);
  ICONGETA_RemapIcon                    = (ICONA_Dummy + 50);
  ICONGETA_GenerateImageMasks           = (ICONA_Dummy + 51);
  ICONGETA_Label                        = (ICONA_Dummy + 52);

  ICONPUTA_NotifyWorkbench              = (ICONA_Dummy + 53);
  ICONPUTA_PutDefaultType               = (ICONA_Dummy + 54);
  ICONPUTA_PutDefaultName               = (ICONA_Dummy + 55);
  ICONPUTA_DropPlanarIconImage          = (ICONA_Dummy + 56);
  ICONPUTA_DropChunkyIconImage          = (ICONA_Dummy + 57);
  ICONPUTA_DropNewIconToolTypes         = (ICONA_Dummy + 58);
  ICONPUTA_OptimizeImageSpace           = (ICONA_Dummy + 59);

  ICONDUPA_DuplicateDrawerData          = (ICONA_Dummy + 60);
  ICONDUPA_DuplicateImages              = (ICONA_Dummy + 61);
  ICONDUPA_DuplicateImageData           = (ICONA_Dummy + 62);
  ICONDUPA_DuplicateDefaultTool         = (ICONA_Dummy + 63);
  ICONDUPA_DuplicateToolTypes           = (ICONA_Dummy + 64);
  ICONDUPA_DuplicateToolWindow          = (ICONA_Dummy + 65);

  ICONDRAWA_DrawInfo                    = (ICONA_Dummy + 66);

  ICONCTRLA_SetGlobalMaxNameLength      = (ICONA_Dummy + 67);
  ICONCTRLA_GetGlobalMaxNameLength      = (ICONA_Dummy + 68);

  ICONGETA_Screen                       = (ICONA_Dummy + 69);

  ICONDRAWA_Frameless                   = (ICONA_Dummy + 70);
  ICONDRAWA_EraseBackground             = (ICONA_Dummy + 71);

  ICONPUTA_OnlyUpdatePosition           = (ICONA_Dummy + 72);

  ICONA_Reserved1                       = (ICONA_Dummy + 73);
  ICONA_Reserved2                       = (ICONA_Dummy + 74);

  ICONA_ErrorTagItem                    = (ICONA_Dummy + 75);

  ICONA_Reserved3                       = (ICONA_Dummy + 76);

  ICONCTRLA_SetGlobalColorIconSupport   = (ICONA_Dummy + 77);
  ICONCTRLA_GetGlobalColorIconSupport   = (ICONA_Dummy + 78);

  ICONCTRLA_IsNewIcon                   = (ICONA_Dummy + 79);
  ICONCTRLA_IsNativeIcon                = (ICONA_Dummy + 80);

  ICONA_Reserved4                       = (ICONA_Dummy + 81);

  ICONDUPA_ActivateImageData            = (ICONA_Dummy + 82);

  ICONDRAWA_Borderless                  = (ICONA_Dummy + 83);

  ICONPUTA_PreserveOldIconImages        = (ICONA_Dummy + 84);

  ICONA_Reserved5                       = (ICONA_Dummy + 85);
  ICONA_Reserved6                       = (ICONA_Dummy + 86);
  ICONA_Reserved7                       = (ICONA_Dummy + 87);
  ICONA_Reserved8                       = (ICONA_Dummy + 88);

  //*** V45 ***/
  {$IFDEF MORPHOS}
  ICONDRAWA_IsLink                      = (ICONA_Dummy + 89);
  ICONA_LAST_TAG                        = ICONDRAWA_IsLink;
  {$ELSE}
  ICONA_LAST_TAG                        = (ICONA_Dummy + 88);
  {$ENDIF}

  ICON_ASPECT_RATIO_UNKNOWN             = (0);



type
  PIconIdentifyMsg = ^TIconIdentifyMsg;
  TIconIdentifyMsg = record
    iim_SysBase     : PLibrary;
    iim_DOSBase     : PLibrary;
    iim_UtilityBase : PLibrary;
    iim_IconBase    : PLibrary;

    iim_FileLock    : BPTR;  
    iim_ParentLock  : BPTR;  
    iim_FIB         : PFileInfoBlock;
    iim_FileHandle  : BPTR;
    iim_Tags        : PTagItem;   
  end;


var
  IconBase: PLibrary;


  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  procedure FreeFreeList(freelist: PFreeList location 'a0');                                                                      syscall IconBase 054;
  function  AddFreeList(freelist: PFreeList location 'a0'; const mem: APTR location 'a1'; size: ULONG location 'a2'): LBOOL;      syscall IconBase 072;
  function  GetDiskObject(const name: STRPTR location 'a0'): PDiskObject;                                                         syscall IconBase 078;
  function  PutDiskObject(const name: STRPTR location 'a0'; const diskobj: PDiskObject location 'a1'): LBOOL;                     syscall IconBase 084;
  procedure FreeDiskObject(diskobj: pDiskObject location 'a0');                                                                   syscall IconBase 090;
  function  FindToolType(const toolTypeArray: PSTRPTR location 'a0'; const typeName: STRPTR location 'a1'): PChar;                syscall IconBase 096;
  function  MatchToolValue(const typeString: STRPTR location 'a0'; const value: STRPTR location 'a1'): LBOOL;                     syscall IconBase 102;
  function  BumpRevision(newname: STRPTR location 'a0'; const oldname: STRPTR location 'a1'): STRPTR;                             syscall IconBase 108;
  function  GetDefDiskObject(typ: SLONG location 'd0'): PDiskObject;                                                              syscall IconBase 120;
  function  PutDefDiskObject(const diskObject: PDiskObject location 'a0'): LBOOL;                                                 syscall IconBase 126;
  function  GetDiskObjectNew(const name: STRPTR location 'a0'): PDiskObject;                                                      syscall IconBase 132;
  function  DeleteDiskObject(const name: STRPTR location 'a0'): LBOOL;                                                            syscall IconBase 138;
  // V44
  function  DupDiskObjectA(const diskObject: PDiskObject location 'a0'; const tags: PTagItem location 'a1'): PDiskObject;         syscall IconBase 150;
  function  IconControlA(icon: PDiskObject location 'a0'; const tags: PTagItem location 'a1'): ULONG;                             syscall IconBase 156;
  procedure DrawIconStateA(rp: PRastPort location 'a0'; const icon: PDiskObject location 'a1'; const labl: STRPTR location 'a2'; 
            leftOffset: SLONG location 'd0'; topOffset: SLONG location 'd1'; state: ULONG location 'd2'; 
            const tags: PTagItem location 'a3');                                                                                  syscall IconBase 162;
  function  GetIconRectangleA(rp: PRastPort location 'a0'; const icon: PDiskObject location 'a1'; 
            const labl: STRPTR location 'a2'; rect: PRectangle location 'a3'; const tags: PTagItem location 'a4'): LBOOL;         syscall IconBase 168;
  function  NewDiskObject(typ: SLONG location 'd0'): PDiskObject;                                                                 syscall IconBase 174;
  function  GetIconTagList(const name: STRPTR location 'a0'; const tags: PTagItem location 'a1'): PDiskObject;                    syscall IconBase 180;
  function  PutIconTagList(const name: STRPTR location 'a0'; const icon: PDiskObject location 'a1'; 
            const tags: PTagItem location 'a2'): LBOOL;                                                                           syscall IconBase 186;
  function  LayoutIconA(icon: PDiskObject location 'a0'; screen: PScreen location 'a1'; tags: PTagItem location 'a2'): LBOOL;     syscall IconBase 192;
  procedure ChangeToSelectedIconColor(cr: PColorRegister location 'a0');                                                          syscall IconBase 198;
  {$ELSE AROS}
  procedure FreeFreeList(freeList: PFreeList);                                          syscall IconBase  9;
  function  AddFreeList(freeList: PFreeList; const mem: APTR; size: ULONG): LBOOL;      syscall IconBase 12;
  function  GetDiskObject(const name: STRPTR): PDiskObject;                             syscall IconBase 13;
  function  PutDiskObject(const name: STRPTR; const icon: PDiskObject): LBOOL;          syscall IconBase 14;
  procedure FreeDiskObject(diskobj: PDiskObject);                                       syscall IconBase 15;
  function  FindToolType(const toolTypeArray: PSTRPTR; const typeName: STRPTR): PChar;  syscall IconBase 16;
  function  MatchToolValue(const typeString: STRPTR; const value: STRPTR): LBOOL;       syscall IconBase 17;    // inconsistency in AROS repo ?
  function  BumpRevision(newname: STRPTR; const oldname: STRPTR): STRPTR;               syscall IconBase 18;    // inconsistency in AROS repo ?
  function  GetDefDiskObject(typ: SLONG): PDiskObject;                                  syscall IconBase 20;
  function  PutDefDiskObject(const icon: PDiskObject): LBOOL;                           syscall IconBase 21;
  function  GetDiskObjectNew(const name: STRPTR): PDiskObject;                          syscall IconBase 22;
  function  DeleteDiskObject(const name: STRPTR): LBOOL;                                syscall IconBase 23;    // inconsistency in AROS repo ?
  // version 44
  function  DupDiskObjectA(const icon: PDiskObject; const tags: PTagItem): PDiskObject; syscall IconBase 25;
  function  IconControlA(icon: PDiskObject; const tags: PTagItem): ULONG;               syscall IconBase 26;
  procedure DrawIconStateA(rp: PRastPort; const icon: PDiskObject; 
            const labl: STRPTR; leftEdge: SLONG; topEdge: SLONG; State: ULONG; 
            const tags: PTagItem);                                                      syscall IconBase 27;
  function  GetIconRectangleA(rp: PRastPort; const icon: PDiskObject; 
            const labl: STRPTR; rect: PRectangle; const tags: PTagItem): LBOOL;         syscall IconBase 28;
  function  NewDiskObject(typ: ULONG): PDiskObject;                                     syscall IconBase 29;    // Note type of typ differs
  function  GetIconTagList(const name: STRPTR; const tags: PTagItem): PDiskObject;      syscall IconBase 30;
  function  PutIconTagList(const name: STRPTR; const icon: PDiskObject; 
            const tags: PTagItem): LBOOL;                                               syscall IconBase 31;
  function  LayoutIconA(icon: PDiskObject; screen: PScreen; tags: PTagItem): LBOOL;     syscall IconBase 32;
  procedure ChangeToSelectedIconColor(cr: PColorRegister);                              syscall IconBase 33;
  {$ENDIF}

  // varargs versions
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  function  DupDiskObject(const diskObject: PDiskObject; const tags: array of const): PDiskObject;
  function  PutIconTags(const name: STRPTR; const icon: PDiskObject; const tags: array of const): LBOOL;
  procedure DrawIconState(rp: PRastPort; const icon: PDiskObject; const labl: STRPTR; leftOffset: SLONG; topOffset: SLONG; state: ULONG; const tags: array of const);
  function  GetIconTags(const name: STRPTR; const tags: array of const): PDiskObject;
  function  LayoutIcon(icon: PDiskObject; screen: PScreen; tags: array of const): LBOOL;
  function  IconControl(icon: PDiskObject; const tags: array of const): ULONG;
  function  GetIconRectangle(rp: PRastPort; const icon: PDiskObject; const labl: STRPTR; rect: PRectangle; const tags: array of const): LBOOL; 
  {$ELSE MORPHOS}
  function  DupDiskObject(const diskObject: PDiskObject; const tags: array of ULONG): PDiskObject;
  function  PutIconTags(const name: STRPTR; const icon: PDiskObject; const tags: array of ULONG): LBOOL;
  procedure DrawIconState(rp: PRastPort; const icon: PDiskObject; const labl: STRPTR; leftOffset: SLONG; topOffset: SLONG; state: ULONG; const tags: array of ULONG);
  function  GetIconTags(const name: STRPTR; const tags: array of ULONG): PDiskObject;
  function  LayoutIcon(icon: PDiskObject; screen: PScreen; tags: array of ULONG): LBOOL;
  function  IconControl(icon: PDiskObject; const tags: array of ULONG): ULONG;
  function  GetIconRectangle(rp: PRastPort; const icon: PDiskObject; const labl: STRPTR; rect: PRectangle; const tags: array of ULONG): LBOOL;
  {$ENDIF}


{macros}
//#define PACK_ICON_ASPECT_RATIO(num,den)      (((num)<<4)|(den))
//#define UNPACK_ICON_ASPECT_RATIO(v,num,den)  do { num = (((v)>>4)&15); den = ((v)&15); } while(0)
  function  PACK_ICON_ASPECT_RATIO(Num, Den: LongInt): LongInt;
  procedure UNPACK_ICON_ASPECT_RATIO(Aspect: LongInt; out Num, Den: LongInt);

(*
type
  TToolTypeArray= array of string;
  
function GetToolTypes(Filename: string): TToolTypeArray;
*)

implementation


{$IFDEF AROS}
Uses
  tagsarray;
{$ENDIF}
{$IFDEF AMIGA}
Uses
  tagsarray;
{$ENDIF}


(*
function GetToolTypes(Filename: string): TToolTypeArray;
var
  DObj: PDiskObject;
  Tooltype: PPChar;
  Idx: Integer;
begin
  SetLength(Result, 0);
  DObj := GetDiskObject(PChar(FileName));
  if not Assigned(Dobj) then
    Exit;
  Tooltype := DObj^.do_Tooltypes;
  while Assigned(ToolType^) do
  begin
    Idx := Length(Result);
    SetLength(Result, Idx + 1);
    Result[Idx] := ToolType^;
    Inc(ToolType);
  end;
  FreeDiskObject(DObj);
end;
*)


function PACK_ICON_ASPECT_RATIO(Num, Den: LongInt): LongInt;
begin
  PACK_ICON_ASPECT_RATIO := (Num shl 4) or Den;
end;

procedure UNPACK_ICON_ASPECT_RATIO(Aspect: LongInt; out Num, Den: LongInt);
begin
  Num := (Aspect shr 4) and $F;
  Den := Aspect and $15;
end;



{$IF DEFINED(AMIGA) or DEFINED(AROS)}
function  DupDiskObject(const diskObject: PDiskObject; const tags: array of const): PDiskObject;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  DupDiskObject := DupDiskObjectA(diskObject, @TagList);
end;

function  PutIconTags(const name: STRPTR; const icon: PDiskObject; const tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  PutIconTags := PutIconTagList(name, icon, @TagList);
end;

procedure DrawIconState(rp: PRastPort; const icon: PDiskObject; const labl: STRPTR; leftOffset: SLONG; topOffset: SLONG; state: ULONG; const tags: array of const);
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  DrawIconStateA(rp, icon, labl, leftOffset, topOffset, state, @TagList);
end;

function  GetIconTags(const name: STRPTR; const tags: array of const): PDiskObject;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  GetIconTags := GetIconTagList(name, @TagList);
end;

function  LayoutIcon(icon: PDiskObject; screen: PScreen; tags: array of const): LBOOL;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  LayoutIcon := LayoutIconA(icon, screen, @TagList);
end;

function  IconControl(icon: PDiskObject; const tags: array of const): ULONG;
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  IconControl := IconControlA(icon, @TagList);
end;

function  GetIconRectangle(rp: PRastPort; const icon: PDiskObject; const labl: STRPTR; rect: PRectangle; const tags: array of const): LBOOL; 
var
  TagList: TTagsList;
begin
  AddTags(TagList, Tags);
  GetIconRectangle := GetIconRectangleA(rp, icon, labl, rect, @TagList);
end;

{$ELSE MORPHOS}

function  DupDiskObject(const diskObject: PDiskObject; const tags: array of ULONG): PDiskObject;
begin
  DupDiskObject := DupDiskObjectA(diskObject, @tags);
end;

function  PutIconTags(const name: STRPTR; const icon: PDiskObject; const tags: array of ULONG): LBOOL;
begin
  PutIconTags := PutIconTagList(name, icon, @tags);
end;

procedure DrawIconState(rp: PRastPort; const icon: PDiskObject; const labl: STRPTR; leftOffset: SLONG; topOffset: SLONG; state: ULONG; const tags: array of ULONG);
begin
  DrawIconStateA(rp, icon, labl, leftOffset, topOffset, state, @tags);
end;

function  GetIconTags(const name: STRPTR; const tags: array of ULONG): PDiskObject;
begin
  GetIconTags := GetIconTagList(name, @tags);
end;

function  LayoutIcon(icon: PDiskObject; screen: PScreen; tags: array of ULONG): LBOOL;
begin
  LayoutIcon := LayoutIconA(icon, screen, @tags);
end;

function  IconControl(icon: PDiskObject; const tags: array of ULONG): ULONG;
begin
  IconControl := IconControlA(icon, @tags);
end;

function  GetIconRectangle(rp: PRastPort; const icon: PDiskObject; const labl: STRPTR; rect: PRectangle; const tags: array of ULONG): LBOOL;
begin
  GetIconRectangle := GetIconRectangleA(rp, icon, labl, rect, @tags);
end;
{$ENDIF}


{$IF DEFINED(AROS) or DEFINED(AMIGA)}
initialization
  IconBase := OpenLibrary(ICONNAME, 40);
finalization
  CloseLibrary(IconBase);
{$ENDIF}
end.
