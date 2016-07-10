program lines;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : lines
  Topic     : implements a superbitmap with scroll gadgets
  Source    : RKRM
}
 {
 ** This example shows how to implement a superbitmap, and uses a host of
 ** Intuition facilities.  Further reading of other Intuition and graphics
 ** chapters may be required for a complete understanding of this example.
 **
 ** This program requires V37, as it uses calls to OpenWindowTags(),
 ** LockPubScreen().
 }


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

Uses
  {$IFDEF AROS}
  AmigaLib, 
  {$ENDIF}
  Exec, AGraphics, Layers, Intuition, Utility,
  {$IFDEF AMIGA}
  SystemVartags,
  {$ENDIF}  
  CHelpers,
  Trinity;


Const
  WIDTH_SUPER       = (800);
  HEIGHT_SUPER      = (600);
 
  UP_DOWN_GADGET    = (0);
  LEFT_RIGHT_GADGET = (1);
  NO_GADGET         = (2);
 
  MAXPROPVAL        = ($0000FFFF);
 

{* A string with this format will be found by the version command
** supplied by Amiga, Inc.  This will allow users to give version
** numbers with error reports.
*}
  vers  : PChar = '$VER: lines 37.2';

var
  win           : PWindow   = nil;          //* window pointer */

  BotGadInfo    : TPropInfo;
  BotGadImage   : TImage;
  BotGad        : TGadget;
  SideGadInfo   : TPropInfo;
  SideGadImage  : TImage;
  SideGad       : TGadget;


  //* Prototypes for our functions */
  procedure initBorderProps(myscreen: PScreen); forward;
  procedure doNewSize; forward;
  procedure doDrawStuff; forward;
  procedure doMsgLoop; forward;
  procedure superWindow(myscreen: PScreen); forward;


  // Macro's
  function  GADGETID(x: PIntuiMessage): UWORD; inline;
  begin
    GADGETID := PGadget(x^.IAddress)^.GadgetID;
  end;

  function  LAYERXOFFSET(x: PWindow): SmallInt; inline;
  begin
    LAYERXOFFSET := x^.RPort^.Layer^.Scroll_X;
  end;

  function  LAYERYOFFSET(x: PWindow): SmallInt; inline;
  begin
    LAYERYOFFSET := x^.RPort^.Layer^.Scroll_Y;
  end;


{*
** main
** Open all required libraries and get a pointer to the default public screen.
** Cleanup when done or on error.
*}
procedure main(argc: integer; argv: PPChar);
var
  myscreen  : PScreen;
begin
  WriteLn('enter - main');
  {* open all of the required libraries for the program.
  **
  ** require version 37 of the Intuition library.
  *}
  {$IFDEF MORPHOS}
  if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
  {$ENDIF}
  begin
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    if SetAndTest(GfxBase, OpenLibrary('graphics.library', 33)) then
    {$ENDIF}
    begin
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      if SetAndtest(LayersBase, OpenLibrary('layers.library', 33)) then
      {$ENDIF}
      begin
        {* LockPubScreen()/UnlockPubScreen is only available under V36
        ** and later... Use GetScreenData() under V34 systems to get a
        ** copy of the screen structure...
        *}
        if (nil <> SetAndGet(myscreen, LockPubScreen(nil))) then
        begin
          WriteLn('public screen was locked');
          superWindow(myscreen);
          UnlockPubScreen(nil, myscreen);
        end;
        {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
        CloseLibrary(LayersBase);
        {$ENDIF}
      end;
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      CloseLibrary(GfxBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
  WriteLn('leave - main');
end;


{*
** Create, initialize and process the super bitmap window.
** Cleanup if any error.
*}
procedure superWindow(myscreen: PScreen);
var
  bigBitMap         : PBitMap;
  planeNum          : SmallInt;
  allocatedBitMaps  : WordBool;
begin
  WriteLn('enter - superWindow');
  //* set-up the border prop gadgets for the OpenWindow() call. */
  initBorderProps(myscreen);

  {* The code relies on the allocation of the BitMap structure with
  ** the MEMF_CLEAR flag.  This allows the assumption that all of the
  ** bitmap pointers are NULL, except those successfully allocated
  ** by the program.
  *}
  if SetAndTest(bigBitMap, ExecAllocMem(sizeof(TBitMap), MEMF_PUBLIC or MEMF_CLEAR)) then
  begin
    InitBitMap(bigBitMap, myscreen^.BitMap.Depth, WIDTH_SUPER, HEIGHT_SUPER);

    allocatedBitMaps := TRUE;

    planeNum := 0;
    While (( planeNum < myscreen^.BitMap.Depth) and (allocatedBitMaps = TRUE)) do
    begin
      WriteLn('planenum = ', planeNum);
      bigBitMap^.Planes[planeNum] := AllocRaster(WIDTH_SUPER, HEIGHT_SUPER);
      if (nil = bigBitMap^.Planes[planeNum])
      then allocatedBitMaps := FALSE;

      inc(planeNum);
    end;

    {* Only open the window if the bitplanes were successfully
    ** allocated.  Fail silently if they were not.
    *}
    if (TRUE = allocatedBitMaps) then
    begin
      WriteLn('Bitmaps where allocated');
      {* OpenWindowTags() and OpenWindowTagList() are only available
      ** when the library version is at least V36.  Under earlier
      ** versions of Intuition, use OpenWindow() with a NewWindow
      ** structure.
      *}
      Writeln('opening window tags');
      if (nil <> SetAndGet(Win, OpenWindowTags(nil,
      [
        TAG_(WA_Width)      , 150,
        TAG_(WA_Height)     , 4 * (myscreen^.WBorTop + myscreen^.Font^.ta_YSize + 1),
        TAG_(WA_MaxWidth)   , WIDTH_SUPER,
        TAG_(WA_MaxHeight)  , HEIGHT_SUPER,
        TAG_(WA_IDCMP)      , IDCMP_GADGETUP or IDCMP_GADGETDOWN or IDCMP_NEWSIZE or IDCMP_INTUITICKS or IDCMP_CLOSEWINDOW,
        TAG_(WA_Flags)      , WFLG_SIZEGADGET or WFLG_SIZEBRIGHT or WFLG_SIZEBBOTTOM or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_CLOSEGADGET or WFLG_SUPER_BITMAP or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH,
        TAG_(WA_Gadgets)    , TAG_(@(SideGad)),
        TAG_(WA_Title)      , TAG_(@vers[6]),     //* take title from version string */
        TAG_(WA_PubScreen)  , TAG_(myscreen),
        TAG_(WA_SuperBitMap), TAG_(bigBitMap),
        TAG_DONE
      ]))) then
      begin
        Writeln('openwindowtags succeeded');
        //* set-up the window display */
        SetRast(Win^.RPort, 0); //* clear the bitplanes */
        SetDrMd(Win^.RPort, JAM1);
        writeln('doNewSize');
	    doNewSize;            //* adjust props to represent portion visible */
        writeln('doDrawStuff');
        doDrawStuff;

        //* process the window, return on IDCMP_CLOSEWINDOW */
        writeln('doMsgLoop');
        doMsgLoop;

        CloseWindow(Win);
      end;
    end;

    planeNum := 0;
    while (planeNum < myscreen^.BitMap.Depth) do
    begin
      //* free only the bitplanes actually allocated... */
      if (nil <> bigBitMap^.Planes[planeNum])
      then FreeRaster(bigBitMap^.Planes[planeNum], WIDTH_SUPER, HEIGHT_SUPER);

      inc(planeNum);
    end;
    FreeMem(bigBitMap, sizeof(TBitMap));
  end;
  WriteLn('leave - superWindow');
end;


{*
** Set-up the prop gadgets--initialize them to values that fit
** into the window border.  The height of the prop gadget on the side
** of the window takes the height of the title bar into account in its
** set-up. note the initialization assumes a fixed size "sizing" gadget.
**
** Note also, that the size of the sizing gadget is dependent on the
** screen resolution.  The numbers given here are only valid if the
** screen is NOT lo-res.  These values must be re-worked slightly
** for lo-res screens.
**
** The PROPNEWLOOK flag is ignored by 1.3.
*}
procedure initBorderProps(myscreen: PScreen);
begin
  {* initializes the two prop gadgets.
  **
  ** Note where the PROPNEWLOOK flag goes.  Adding this flag requires
  ** no extra storage, but tells the system that our program is
  ** expecting the new-look prop gadgets under 2.0.
  *}
  BotGadInfo.Flags      := AUTOKNOB or FREEHORIZ or PROPNEWLOOK;
  BotGadInfo.HorizPot   := 0;
  BotGadInfo.VertPot    := 0;
  BotGadInfo.HorizBody  := UWORD(-1);
  BotGadInfo.VertBody   := UWORD(-1);

  BotGad.LeftEdge       := 3;
  BotGad.TopEdge        := -7;
  BotGad.Width          := -23;
  BotGad.Height         := 6;

  BotGad.Flags          := GFLG_RELBOTTOM or GFLG_RELWIDTH;
  BotGad.Activation     := GACT_RELVERIFY or GACT_IMMEDIATE or GACT_BOTTOMBORDER;
  BotGad.GadgetType     := GTYP_PROPGADGET or GTYP_GZZGADGET;
  BotGad.GadgetRender   := APTR(@(BotGadImage));
  BotGad.SpecialInfo    := APTR(@(BotGadInfo));
  BotGad.GadgetID       := LEFT_RIGHT_GADGET;

  SideGadInfo.Flags     := AUTOKNOB or FREEVERT or PROPNEWLOOK;
  SideGadInfo.HorizPot  := 0;
  SideGadInfo.VertPot   := 0;
  SideGadInfo.HorizBody := UWORD(-1);
  SideGadInfo.VertBody  := UWORD(-1);

  {* NOTE the TopEdge adjustment for the border and the font for V36.
  *}
  SideGad.LeftEdge      := -14;
  SideGad.TopEdge       := myscreen^.WBorTop + myscreen^.Font^.ta_YSize + 2;
  SideGad.Width         := 12;
  SideGad.Height        := -SideGad.TopEdge - 11;

  SideGad.Flags         := GFLG_RELRIGHT or GFLG_RELHEIGHT;
  SideGad.Activation    := GACT_RELVERIFY or GACT_IMMEDIATE or GACT_RIGHTBORDER;
  SideGad.GadgetType    := GTYP_PROPGADGET or GTYP_GZZGADGET;
  SideGad.GadgetRender  := APTR(@(SideGadImage));
  SideGad.SpecialInfo   := APTR(@(SideGadInfo));
  SideGad.GadgetID      := UP_DOWN_GADGET;
  SideGad.NextGadget    := @(BotGad);
end;


{*
** This function does all the work of drawing the lines
*}
procedure doDrawStuff;
var
  x1,y1,x2,y2               : SmallInt;
  pen,ncolors,deltx,delty   : SmallInt;
begin
  ncolors := 1 shl PScreen(Win^.WScreen)^.BitMap.Depth;
  {$IFDEF AROS}
  deltx := RangeRand(6)+2;
  delty := RangeRand(6)+2;
  {$ELSE}
  deltx := Random(6)+2;
  delty := Random(6)+2;
  {$ENDIF}

  writeln('deltax = ', deltx);
  writeln('deltay = ', delty);

  {$IFDEF AROS}
  pen := RangeRand(ncolors-1) + 1;
  {$ELSE}
  pen := Random(ncolors-1) + 1;
  {$ENDIF}
  SetAPen(Win^.RPort,pen);
  
  x1 := 0; y1 :=0; x2 := WIDTH_SUPER-1; y2 := HEIGHT_SUPER-1;

  while x1 < WIDTH_SUPER do
  begin
    GfxMove(Win^.RPort, x1, y1);
    Draw(Win^.RPort, x2, y2);

    x1 := x1 + deltx; x2 := x2 - deltx;
  end;

  {$IFDEF AROS}
  pen := RangeRand(ncolors-1) + 1;
  {$ELSE}
  pen := Random(ncolors-1) + 1;
  {$ENDIF}
  SetAPen(Win^.RPort,pen);

  x1 := 0; y1 :=0; x2 := WIDTH_SUPER-1; y2 := HEIGHT_SUPER-1;
  while y1 < HEIGHT_SUPER do
  begin
    GfxMove(Win^.RPort, x1, y1);
    Draw(Win^.RPort, x2, y2);

    y1 := y1 + delty; y2 := y2 - delty;
  end;
end;


{*
** This function provides a simple interface to ScrollLayer
*}
procedure slideBitMap(Dx: SmallInt; Dy: SmallInt);
begin
  ScrollLayer(0, Win^.RPort^.Layer, Dx, Dy);
end;


{*
** Update the prop gadgets and bitmap positioning when the size changes.
*}
procedure doNewSize;
var
  tmp   : ULONG;
begin
  tmp := LAYERXOFFSET(Win) + Win^.GZZWidth;
  if (tmp >= WIDTH_SUPER)
  then slideBitMap(WIDTH_SUPER - tmp, 0);

  NewModifyProp
  (
    @(BotGad), 
    Win, 
    nil, 
    AUTOKNOB or FREEHORIZ,
    ((LAYERXOFFSET(Win) * MAXPROPVAL) div (WIDTH_SUPER - Win^.GZZWidth)),
    0,
    ((Win^.GZZWidth * MAXPROPVAL) div WIDTH_SUPER),
    MAXPROPVAL,
    1
  );

  tmp := LAYERYOFFSET(Win) + Win^.GZZHeight;
  if (tmp >= HEIGHT_SUPER)
  then slideBitMap(0, HEIGHT_SUPER - tmp);

  NewModifyProp
  (
    @(SideGad), 
    Win, 
    nil, 
    AUTOKNOB or FREEVERT,
    0,
    ((LAYERYOFFSET(Win) * MAXPROPVAL) div (HEIGHT_SUPER - Win^.GZZHeight)),
    MAXPROPVAL,
    ((Win^.GZZHeight * MAXPROPVAL) div HEIGHT_SUPER),
    1
  );
end;


{*
** Process the currently selected gadget.
** This is called from IDCMP_INTUITICKS and when the gadget is released
** IDCMP_GADGETUP.
*}
procedure checkGadget(gadgetID : UWORD);
var
  tmp   : ULONG;
  dX    : SmallInt = 0;
  dY    : SmallInt = 0;
begin
  case (gadgetID) of
    UP_DOWN_GADGET:
    begin
      tmp := HEIGHT_SUPER - Win^.GZZHeight;
      tmp := tmp * SideGadInfo.VertPot;
      tmp := tmp div MAXPROPVAL;
      dY := tmp - LAYERYOFFSET(Win);
    end;
    LEFT_RIGHT_GADGET:
    begin
      tmp := WIDTH_SUPER - Win^.GZZWidth;
      tmp := tmp * BotGadInfo.HorizPot;
      tmp := tmp div MAXPROPVAL;
      dX := tmp - LAYERXOFFSET(Win);
    end;
  end;
  if ((dX <> 0) or (dY <> 0))
  then slideBitMap(dX, dY);
end;


{*
** Main message loop for the window.
*}
procedure doMsgLoop;
var
  msg           : PIntuiMessage;
  flag          : WordBool = TRUE;
  currentGadget : UWORD = NO_GADGET;
begin
  while (flag) do
  begin
    //* Whenever you want to wait on just one message port */
    //* you can use WaitPort(). WaitPort() doesn't require */
    //* the setting of a signal bit. The only argument it  */
    //* requires is the pointer to the window's UserPort   */
    WaitPort(Win^.UserPort);
    while SetAndTest(msg, PIntuiMessage(GetMsg(Win^.UserPort))) do
    begin
      case (msg^.IClass) of
        IDCMP_CLOSEWINDOW:
        begin
          flag := FALSE;
        end;
        IDCMP_NEWSIZE:
        begin
          doNewSize;
          doDrawStuff;
        end;
        IDCMP_GADGETDOWN:
        begin
          currentGadget := GADGETID(msg);
        end;
        IDCMP_GADGETUP:
        begin
          checkGadget(currentGadget);
          currentGadget := NO_GADGET;
        end;
        IDCMP_INTUITICKS:
        begin
          checkGadget(currentGadget);
        end;
      end;
      ReplyMsg(PMessage(msg));
    end;
  end;
end;


begin
  WriteLn('enter');
  BotGadInfo    := Default(TPropInfo);
  BotGadImage   := Default(TImage);
  BotGad        := Default(TGadget);
  SideGadInfo   := Default(TPropInfo);
  SideGadImage  := Default(TImage);
  SideGad       := Default(TGadget);

  Main(ArgC, ArgV);
  WriteLn('leave');
end.
