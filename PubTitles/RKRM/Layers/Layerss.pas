program Layerss;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : layers
  Source    : RKRM
}
 {*
 ** For the sake of brevity, the example is a single task.  No Layer
 ** locking is done.  Also note that the routine myLabelLayer() is used
 ** to redraw a given layer.  It is called only when a layer needs
 ** refreshing.
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AmigaDOS, AGraphics, Layers,
  Trinity;


Type
  PUWORD        = ^UWORD;

Const
  L_DELAY       = (100);
  S_DELAY       =  (50);

  DUMMY         =   (0);

  RED_PEN       =   (1);
  GREEN_PEN     =   (2);
  BLUE_PEN      =   (3);

  SCREEN_D      =   (2);
  SCREEN_W      = (320);
  SCREEN_H      = (200);

  //* the starting size of example layers, offsets are used for placement */
  W_H           = (50);
  W_T           = (5);
  W_B           = ((W_T+W_H)-1);
  W_W           = (80);
  W_L           = ((SCREEN_W div 2) - (W_W div 2));
  W_R           = ((W_L+W_W)-1);

  //* size of the superbitmap */
  SUPER_H       = SCREEN_H;
  SUPER_W       = SCREEN_W;

  //* starting size of the message layer */
  M_H           = (10);
  M_T           = (SCREEN_H-M_H);
  M_B           = ((M_T+M_H)-1);
  M_W           = (SCREEN_W);
  M_L           = (0);
  M_R           = ((M_L+M_W)-1);


  //* global constant data for initializing the layers */
  theLayerFlags : Array[0..Pred(3)] of LONG = 
  ( 
    LAYERSUPER, LAYERSMART, LAYERSIMPLE 
  );

  colortable    : array [0..3] of UWORD = ( $000, $f44, $4f4, $44f );


{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
function RasSize(w, h: Word): Integer; inline;
begin
  Result := h * (((w + 15) shr 3) and $FFFE);
end;
{$ENDIF}


{*
** Clear the layer then draw in a text string.
*}
procedure myLabelLayer(layer: PLayer; color: LONG; str: PChar);
begin
  //* fill layer with color */
  SetRast(layer^.rp, color);

  //* set up for writing text into layer */
  SetDrMd(layer^.rp, JAM1);
  SetAPen(layer^.rp, 0);
  GfxMove(layer^.rp, 5, 7);

  //* write into layer */
  GfxText(layer^.rp, str, strlen(str));
end;


{*
** write a message into a layer with a delay.
*}
procedure pMessage(layer: PLayer; str: PChar);
begin
  DOSDelay(S_DELAY);
  myLabelLayer(layer, GREEN_PEN, str);
end;


{*
** write an error message into a layer with a delay.
*}
procedure error(layer: PLayer; str: PChar);
begin
  myLabelLayer(layer, RED_PEN, str);
  DOSDelay(L_DELAY);
end;


{*
** do some layers manipulations to demonstrate their abilities.
*}
procedure doLayers(msgLayer: PLayer; layer_array: Array of PLayer);
var
  ktr   : SmallInt;
  ktr_2 : SmallInt;
begin
  pMessage(msgLayer, 'Label all Layers');
  myLabelLayer(layer_array[0], RED_PEN,   'Super');
  myLabelLayer(layer_array[1], GREEN_PEN, 'Smart');
  myLabelLayer(layer_array[2], BLUE_PEN,  'Simple');

  pMessage(msgLayer, 'MoveLayer 1 InFrontOf 0');
  if not LongBool(MoveLayerInFrontOf(layer_array[1], layer_array[0]))
  then error(msgLayer, 'MoveLayerInFrontOf() failed.');

  pMessage(msgLayer, 'MoveLayer 2 InFrontOf 1');
  if not LongBool(MoveLayerInFrontOf(layer_array[2], layer_array[1]))
  then error(msgLayer, 'MoveLayerInFrontOf() failed.');

  pMessage(msgLayer, 'Refresh Simple Refresh Layer');
  myLabelLayer(layer_array[2], BLUE_PEN, 'Simple');

  pMessage(msgLayer, 'Incrementally MoveLayers...');
  for ktr := 0 to Pred(30) do
  begin
    if not LongBool(MoveLayer(DUMMY, layer_array[1], -1, 0))
    then error(msgLayer, 'MoveLayer() failed.');
    if not LongBool(MoveLayer(DUMMY, layer_array[2], -2, 0))
    then error(msgLayer, 'MoveLayer() failed.');
  end;

  pMessage(msgLayer, 'Refresh Simple Refresh Layer');
  myLabelLayer(layer_array[2], BLUE_PEN, 'Simple');

  pMessage(msgLayer, 'make Layer 0 the UpfrontLayer');
  if not LongBool(UpfrontLayer(DUMMY, layer_array[0]))
  then error(msgLayer, 'UpfrontLayer() failed.');

  pMessage(msgLayer, 'make Layer 2 the BehindLayer');
  if not LongBool(BehindLayer(DUMMY, layer_array[2]))
  then error(msgLayer, 'BehindLayer() failed.');

  pMessage(msgLayer, 'Incrementally MoveLayers again...');
  for ktr := 0 to Pred(30) do
  begin
    if not LongBool(MoveLayer(DUMMY, layer_array[1], 0, 1))
    then error(msgLayer, 'MoveLayer() failed.');
    if not LongBool(MoveLayer(DUMMY, layer_array[2], 0, 2))
    then error(msgLayer, 'MoveLayer() failed.');
  end;

  pMessage(msgLayer, 'Refresh Simple Refresh Layer');
  myLabelLayer(layer_array[2], BLUE_PEN, 'Simple');

  pMessage(msgLayer, 'Big MoveLayer');
  for ktr := 0 to Pred(3) do
  begin
    if not LongBool(MoveLayer(DUMMY, layer_array[ktr], -layer_array[ktr]^.bounds.MinX, 0))
    then error(msgLayer, 'MoveLayer() failed.');
  end;


  pMessage(msgLayer, 'Incrementally increase size');
  for ktr := 0 to Pred(5) do
  begin
    for ktr_2 := 0 to Pred(3) do
    begin
      if not LongBool(SizeLayer(DUMMY, layer_array[ktr_2], 1, 1))
      then error(msgLayer, 'SizeLayer() failed.');
    end;
  end;

  pMessage(msgLayer, 'Refresh Smart Refresh Layer');
  myLabelLayer(layer_array[1], GREEN_PEN, 'Smart');
  pMessage(msgLayer, 'Refresh Simple Refresh Layer');
  myLabelLayer(layer_array[2], BLUE_PEN,  'Simple');

  pMessage(msgLayer, 'Big SizeLayer');
  for ktr := 0 to Pred(3) do
  begin
    if not LongBool(SizeLayer(DUMMY,layer_array[ktr],
                SCREEN_W - (layer_array[ktr]^.bounds.MaxX)-1,0))
    then error(msgLayer, 'SizeLayer() failed.');
  end;

  pMessage(msgLayer, 'Refresh Smart Refresh Layer');
  myLabelLayer(layer_array[1], GREEN_PEN, 'Smart');
  pMessage(msgLayer, 'Refresh Simple Refresh Layer');
  myLabelLayer(layer_array[2], BLUE_PEN,  'Simple');

  pMessage(msgLayer, 'ScrollLayer down');
  for ktr := 0 to Pred(30) do
  begin
    for ktr_2 := 0 to Pred(3) do
    begin
      ScrollLayer(DUMMY, layer_array[ktr_2], 0, -1);
    end;
  end;

  pMessage(msgLayer, 'Refresh Smart Refresh Layer');
  myLabelLayer(layer_array[1], GREEN_PEN, 'Smart');
  pMessage(msgLayer, 'Refresh Simple Refresh Layer');
  myLabelLayer(layer_array[2], BLUE_PEN,  'Simple');

  pMessage(msgLayer, 'ScrollLayer up');
  for ktr := 0 to Pred(30) do
  begin
    for ktr_2 := 0 to Pred(3) do
    begin
      ScrollLayer(DUMMY, layer_array[ktr_2], 0, 1);
    end;
  end;

  pMessage(msgLayer, 'Refresh Smart Refresh Layer');
  myLabelLayer(layer_array[1], GREEN_PEN, 'Smart');
  pMessage(msgLayer, 'Refresh Simple Refresh Layer');
  myLabelLayer(layer_array[2], BLUE_PEN,  'Simple');

  DOSDelay(L_DELAY);
end;


{*
** delete the layer array created by allocLayers().
*}
procedure disposeLayers(msgLayer: PLayer; layer_array: array of PLayer);
var
  ktr : SmallInt;
begin
  for ktr := 0 to Pred(3) do
  begin
    if (layer_array[ktr] <> nil) then
    begin
      if not LongBool(DeleteLayer(DUMMY, layer_array[ktr]))
      then error(msgLayer, 'Error deleting layer');
    end;
  end;
end;


{*
** Create some hard-coded layers.  The first must be super-bitmap, with
** the bitmap passed as an argument.  The others must not be super-bitmap.
** The pointers to the created layers are returned in layer_array.
**
** Return FALSE on failure.  On a FALSE return, the layers are
** properly cleaned up.
*}
function  allocLayers(msgLayer: PLayer; layer_array: array of PLayer;
          super_bitmap: PBitmap; theLayerInfo: PLayer_Info;
          theBitMap: PBitMap): Boolean;
var
  ktr: SmallInt;
  create_layer_ok   : Boolean = TRUE;
begin
  ktr := 0;
  while ((ktr < 3) and (create_layer_ok)) do
  begin
    pMessage(msgLayer, 'Create BehindLayer');
    if (ktr = 0) then
    begin
      layer_array[ktr] := CreateBehindLayer(theLayerInfo, theBitMap,
                  W_L+(ktr*30), W_T+(ktr*30), W_R+(ktr*30), W_B+(ktr*30),
                  theLayerFlags[ktr], super_bitmap);
    
      if (layer_array[ktr] = nil)
      then create_layer_ok := FALSE;
    end
    else
    begin
      layer_array[ktr] := CreateBehindLayer(theLayerInfo, theBitMap,
                  W_L+(ktr*30), W_T+(ktr*30), W_R+(ktr*30), W_B+(ktr*30),
                  theLayerFlags[ktr], nil);
                  
      if (layer_array[ktr] = nil)
      then create_layer_ok := FALSE;
    end;

    if (create_layer_ok) then
    begin
      pMessage(msgLayer, 'Fill the RastPort');
      SetRast(layer_array[ktr]^.rp, ktr + 1);
    end;

    inc(ktr);
  end;

  if not(create_layer_ok)
  then disposeLayers(msgLayer, layer_array);

  result := (create_layer_ok);
end;


{*
** Free the bitmap and all bitplanes created by allocBitMap().
*}
procedure disposeBitMap(bitmap: PBitMap; depth: LONG; width: LONG; height: LONG);
var
  ktr   : SmallInt;
begin
  if (nil <> bitmap) then
  begin
    for ktr := 0 to Pred(depth) do
    begin
      if (nil <> bitmap^.Planes[ktr])
      then FreeRaster(bitmap^.Planes[ktr], width, height);
    end;

    ExecFreeMem(bitmap, sizeof(bitmap^));
  end;
end;


{*
** Allocate and initialize a bitmap structure.
*}
function  allocBitMap(depth: LONG; width: LONG; height: LONG): PBitMap;
var
  ktr   : SmallInt;
  bit_map_failed    : Boolean = FALSE;
  bitmap            : PBitMap = nil;
begin
  bitmap := ExecAllocMem(sizeof(bitmap^), 0);
  if (nil <> bitmap) then
  begin
    InitBitMap(bitmap, depth, width, height);

    for ktr := 0 to Pred(depth) do
    begin
      bitmap^.Planes[ktr] := TPLANEPTR(AllocRaster(width,height));
      if (nil = bitmap^.Planes[ktr])
      then bit_map_failed := TRUE
      else
        BltClear(Pointer(bitmap^.Planes[ktr]), RASSIZE(width, height), 1);
    end;
    if (bit_map_failed) then
    begin
      disposeBitMap(bitmap, depth, width, height);
      bitmap := nil;
    end;
  end;
  result := (bitmap);
end;


{*
** Set up to run the layers example, doLayers(). Clean up when done.
*}
procedure startLayers(theLayerInfo: PLayer_Info; theBitMap: PBitMap);
var
  msgLayer          : PLayer;
  theSuperBitMap    : PBitMap;
  theLayers         : array[0..Pred(3)] of PLayer = ( nil, nil, nil );
begin
  msgLayer := CreateUpfrontLayer(theLayerInfo, theBitMap,
                     M_L, M_T, M_R, M_B, LAYERSMART, nil);
  if (nil <> msgLayer) then
  begin
    pMessage(msgLayer, 'Setting up Layers');

    theSuperBitMap := allocBitMap(SCREEN_D, SUPER_W, SUPER_H);
    if (nil <> theSuperBitMap) then
    begin
      if (allocLayers(msgLayer, theLayers, theSuperBitMap, theLayerInfo, theBitMap)) then
      begin
        doLayers(msgLayer, theLayers);

        disposeLayers(msgLayer, theLayers);
      end;
      disposeBitMap(theSuperBitMap, SCREEN_D, SUPER_W, SUPER_H);
    end;
    if not LongBool(DeleteLayer(DUMMY, msgLayer))
    then error(msgLayer, 'Error deleting layer');
  end;
end;


{*
** Set up a low-level graphics display for layers to work on.  Layers
** should not be built directly on Intuition screens, use a low-level
** graphics view.  If you need mouse or other events for the layers
** display, you have to get them directly from the input device.  The
** only supported method of using layers library calls with Intuition
** (other than the InstallClipRegion() call) is through Intuition windows.
**
** See graphics primitives chapter for details on creating and using the
** low-level graphics calls.
*}
procedure runNewView;
var
  theView       : TView;
  oldview       : PView;
  theViewPort   : TViewPort;
  theRasInfo    : TRasInfo;
  theColorMap   : PColorMap;
  theLayerInfo  : PLayer_Info;
  theBitMap     : PBitMap;
  colorpalette  : PUWORD;
  ktr           : SmallInt;
begin
  //* save current view, to be restored when done */
  oldview := PGfxBase(GfxBase)^.ActiView;
  if (nil <> oldview) then
  begin
    //* get a LayerInfo structure */
    theLayerInfo := NewLayerInfo;
    if (nil <> theLayerInfo) then
    begin
      theColorMap := GetColorMap(4);
      if (nil <> theColorMap) then
      begin
        colorpalette := PUWORD(theColorMap^.ColorTable);
        for ktr := 0 to Pred(4) do
        begin
          colorpalette^ := colortable[ktr];
          inc(colorpalette);
        end;

        theBitMap := allocBitMap(SCREEN_D, SCREEN_W, SCREEN_H);
        if (nil <> theBitMap) then
        begin
          InitView(@theView);
          InitVPort(@theViewPort);

          theView.ViewPort := @theViewPort;

          theViewPort.DWidth   := SCREEN_W;
          theViewPort.DHeight  := SCREEN_H;
          theViewPort.RasInfo  := @theRasInfo;
          theViewPort.ColorMap := theColorMap;

          theRasInfo.BitMap   := theBitMap;
          theRasInfo.RxOffset := 0;
          theRasInfo.RyOffset := 0;
          theRasInfo.Next     := nil;

          MakeVPort(@theView, @theViewPort);
          MrgCop(@theView);
          LoadView(@theView);
          WaitTOF;

          startLayers(theLayerInfo, theBitMap);

          {* put back the old view, wait for it to become
          ** active before freeing any of our display
          *}
          LoadView(oldview);
          WaitTOF;

          //* free dynamically created structures */
          FreeVPortCopLists(@theViewPort);
          FreeCprList(theView.LOFCprList);

          disposeBitMap(theBitMap, SCREEN_D, SCREEN_W, SCREEN_H);
        end;
        FreeColorMap(theColorMap);       //* free the color map */
      end;
      DisposeLayerInfo(theLayerInfo);
    end;
  end;
end;


{*
** Open the libraries used by the example.  Clean up when done.
*}
procedure main(argc: integer; argv: PPChar);
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  GfxBase := PLibrary(OpenLibrary('graphics.library', 33));
  if (nil <> GfxBase) then
  {$ENDIF}
  begin
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    LayersBase := OpenLibrary('layers.library', 33);
    if (nil <> LayersBase) then
    {$ENDIF}
    begin
      runNewView;
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      CloseLibrary(LayersBase);
      {$ENDIF}
    end;
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    CloseLibrary(PLibrary(GfxBase));
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
