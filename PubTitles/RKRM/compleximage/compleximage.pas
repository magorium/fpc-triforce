program compleximage;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : compleximage
  Source    : RKRM
}
 {
 *  program to show the use of a complex Intuition Image.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDOS, intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


const
  MYIMAGE_LEFT    = (0);
  MYIMAGE_TOP     = (0);
  MYIMAGE_WIDTH   = (24);
  MYIMAGE_HEIGHT  = (10);
  MYIMAGE_DEPTH   = (2);

  {* This is the image data.  It is a two bitplane open rectangle which
  ** is 24 pixels wide and 10 high.  Make sure that it is in CHIP memory,
  ** or allocate a block of chip memory with a call like:
  **
  **     AllocMem(data_size,MEMF_CHIP)
  **
  ** and copy the data to that block.  See the Exec chapter on
  ** Memory Allocation for more information on AllocMem().
  *}
  // FPC Note: Small workaround to accomodate all supported platforms
  myImageDataData   : Array[0..Pred(40)] of UWORD =
  (
    {* first bitplane of data,
    ** open rectangle.
    *}
    $FFFF, $FF00,
    $C000, $0300,
    $C000, $0300,
    $C000, $0300,
    $C000, $0300,
    $C000, $0300,
    $C000, $0300,
    $C000, $0300,
    $C000, $0300,
    $FFFF, $FF00,

    {* second bitplane of data,
    ** filled rectangle to appear within open rectangle.
    *}
    $0000, $0000,
    $0000, $0000,
    $0000, $0000,
    $00FF, $0000,
    $00FF, $0000,
    $00FF, $0000,
    $00FF, $0000,
    $0000, $0000,
    $0000, $0000,
    $0000, $0000
  );
  // FPC Note: Small workaround to accomodate all supported platforms
  MyImageData : Pointer = @MyImageDataData;

  //* used to get the "new look" on a custom screen */
  pens  : Array[0..0] of UWORD = ( $FFFF );



{*
** main routine. Open required library and window and draw the images.
** This routine opens a very simple window with no IDCMP.  See the
** chapters on "Windows" and "Input and Output Methods" for more info.
** Free all resources when done.
*}
procedure Main(argc: integer; argv: PPChar);
var
  scr       : PScreen;
  win       : PWindow;
  myImage   : TImage;
begin
  {$IFDEF MORPHOS}
  IntuitionBase := PIntuitionBase(OpenLibrary('intuition.library', 37));
  if (IntuitionBase <> Nil) then
  {$ENDIF}
  begin
    if (nil <> SetAndGet(scr, OpenScreenTags(nil,
    [
      TAG_(SA_Depth)    , 4,
      TAG_(SA_Pens)     , TAG_(@pens),
      TAG_END
    ]))) then
    begin
      if (nil <> SetAndGet(win, OpenWindowTags(nil,
      [
        TAG_(WA_RMBTrap)        , TAG_(TRUE),
        TAG_(WA_CustomScreen)   , TAG_(scr),
        TAG_END
      ]))) then
      begin
        myImage.LeftEdge    := MYIMAGE_LEFT;
        myImage.TopEdge     := MYIMAGE_TOP;
        myImage.Width       := MYIMAGE_WIDTH;
        myImage.Height      := MYIMAGE_HEIGHT;
        myImage.Depth       := MYIMAGE_DEPTH;
        myImage.ImageData   := myImageData;
        myImage.PlanePick   := $3;              //* use first two bitplanes */
        myImage.PlaneOnOff  := $0;              //* clear all unused planes  */
        myImage.NextImage   := nil;

        //* Draw the image into the first two bitplanes */
        DrawImage(win^.RPort, @myImage, 10, 10);

        //* Draw the same image at a new location */
        DrawImage(win^.RPort, @myImage, 100, 10);

        {* Change the image to use the second and fourth bitplanes,
        ** PlanePick is 1010 binary or 0xA,
        ** and draw it again at a different location
        *}
        myImage.PlanePick := $A;
        DrawImage(win^.RPort, @myImage, 10, 50);

        {* Now set all the bits in the first bitplane with PlaneOnOff.
        ** This will make all the bits set in the second bitplane
        ** appear as color 3 (0011 binary), all the bits set in the
        ** fourth bitplane appear as color 9 (1001 binary) and all
        ** other pixels will be color 1 (0001 binary.  If there were
        ** any points in the image where both bits were set, they
        ** would appear as color 11 (1011 binary).
        ** Draw the image at a different location.
        *}
        myImage.PlaneOnOff := $1;
        DrawImage(win^.RPort, @myImage, 100, 50);

        {* Wait a bit, then quit.
        ** In a real application, this would be an event loop, like the
        ** one described in the Intuition Input and Output Methods chapter.
        *}
        DOSDelay(200);

        CloseWindow(win);
      end;
      CloseScreen(scr);
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


{$IFDEF ENDIAN_LITTLE}
Var
  index : Integer;
{$ENDIF}

begin
  // FPC Note: 
  // Small workaround to accomodate all supported platforms
  // Amiga requires image data to be stored into ChipMem
  // AROS doesn't use the chipmem concept for imagedata anymore
  // MorphOS ?
  {$IFDEF ENDIAN_LITTLE}  
  // Intuition expects image data in Big Endian format, so accomodate
  For Index := Low(MyImageDataData) to High(MyImageDataData) 
    do MyImageDataData[index] := Swap(MyImageDataData[index]);
  {$ENDIF}
  {$IFDEF AMIGA}
  // Intuition expects image data to be located into chipmem (on m68k)
  // so lets transfer the declared imagery to chip mem.
  MyImageData := ExecAllocMem(SizeOf(MyImageDataData), MEMF_CHIP);
  Move(MyImageDataData[0], MyImagedata^, SizeOf(MyImageDataData));
  {$ENDIF}
  Main(ArgC, ArgV);
  {$IFDEF AMIGA}
  // Dont forget to release the allocated chip memory.
  ExecFreeMem(MyImageData, SizeOf(MyImageDataData));
  {$ENDIF}
end.
