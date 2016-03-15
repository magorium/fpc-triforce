program ssprite;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : ssprite
  Title     : Simple Sprite example
  Source    : RKRM
}

 {* The following example demonstrates how to set up, move and free a
 ** Simple Sprite.  The animtools.h file included is listed at the end of
 ** the chapter.
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}


Uses
  Exec, AmigaDOS, AGraphics, Intuition, Hardware,
  SysUtils,
  CHelpers,
  Trinity;


{$IFDEF AMIGA}
var
  Custom : TCustom absolute $DFF000;

//#define ON_SPRITE	custom.dmacon = BITSET|DMAF_SPRITE;
//#define OFF_SPRITE	custom.dmacon = BITCLR|DMAF_SPRITE;
  Procedure ON_SPRITE;
  begin
    custom.dmacon := BITSET or DMAF_SPRITE;
  end;

  Procedure OFF_SPRITE;
  begin
    custom.dmacon := BITCLR or DMAF_SPRITE;
  end;
{$ENDIF}


var
  //* real boring sprite data */
  sprite_data_data : array[0..21] of UWORD = 
  (
    0, 0,           //* position control           */
    $ffff, $0000,   //* image data line 1, color 1 */
    $ffff, $0000,   //* image data line 2, color 1 */
    $0000, $ffff,   //* image data line 3, color 2 */
    $0000, $ffff,   //* image data line 4, color 2 */
    $0000, $0000,   //* image data line 5, transparent */
    $0000, $ffff,   //* image data line 6, color 2 */
    $0000, $ffff,   //* image data line 7, color 2 */
    $ffff, $ffff,   //* image data line 8, color 3 */
    $ffff, $ffff,   //* image data line 9, color 3 */
    0, 0            //* reserved, must init to 0 0 */
  );

  sprite_data : Pointer = @sprite_data_data;




function  main(argc: integer; argv: PPChar): Integer;
var
  sprite        : TSimpleSprite;
  viewport      : PViewPort;

  sprite_num    : LongInt; // SmallInt;
  delta_move, 
  ktr1, 
  ktr2, 
  color_reg     : ShortInt;

  screen        : PScreen;
  return_code   : Integer;
begin
  return_code := RETURN_OK;
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if (nil = SetAndGet(GfxBase, PGfxBase(OpenLibrary('graphics.library', 37))))
  then return_code := RETURN_FAIL
  else
  {$ENDIF}
  begin
    {$IFDEF MORPHOS}
    if (nil = SetAndGet(IntuitionBase, PIntuitionBase(OpenLibrary('intuition.library', 37))))
    then return_code := RETURN_FAIL
    else
    {$ENDIF}
    begin
      //* opened library, need a viewport to render a sprite over. */
      if (nil = SetAndGet(screen, OpenScreenTagList(nil, nil)))
      then return_code := RETURN_FAIL
      else
      begin
        viewport := @screen^.ViewPort;
        if (-1 = SetAndGet(sprite_num, GetSprite(@sprite, 2)))
        then return_code := RETURN_WARN
        else
        begin
          //* Calculate the correct base color register number, */
          //* set up the color registers.                       */
          color_reg := 16 + ((sprite_num and $06) shl 1);
          WriteLn(Format('color_reg=%d', [color_reg]));
          SetRGB4(viewport, color_reg + 1, 12,  3,  8);
          SetRGB4(viewport, color_reg + 2, 13, 13, 13);
          SetRGB4(viewport, color_reg + 3,  4,  4, 15);

          sprite.x := 0;       //* initialize position and size info    */
          sprite.y := 0;       //* to match that shown in sprite_data   */
          sprite.height := 9;  //* so system knows layout of data later */

          //* install sprite data and move sprite to start position. */
          ChangeSprite(nil, @sprite, APTR(sprite_data));
          MoveSprite(nil, @sprite, 30, 0);

          //* move the sprite back and forth. */
          delta_move := 1;
          for ktr1 := 0 to Pred(6) do
          begin
            for ktr2 := 0 to Pred(100) do 
            begin
              MoveSprite( nil, @sprite, LONG(sprite.x + delta_move),
                                    LONG(sprite.y + delta_move) );
              WaitTOF();        //* one move per video frame */

              //* Show the effect of turning off sprite DMA. */
              {$IFDEF AMIGA}
              if (ktr2 = 40) then OFF_SPRITE ;
              if (ktr2 = 60) then ON_SPRITE ;
              {$ENDIF}
            end;
            delta_move := -delta_move;            
          end;
          {* NOTE:  if you turn off the sprite at the wrong time (when it
          ** is being displayed), the sprite will appear as a vertical bar
          ** on the screen.  To really get rid of the sprite, you must
          ** OFF_SPRITE while it is not displayed.  This is hard in a
          ** multi-tasking system (the solution is not addressed in
          ** this program).
          *}
          {$IFDEF AMIGA}
          ON_SPRITE;    //* just to be sure */
          {$ENDIF}
          FreeSprite(SmallInt(sprite_num));
        end;
        CloseScreen(screen);
      end;
      {$IFDEF MORPHOS}
      CloseLibrary(PLibrary(IntuitionBase));
      {$ENDIF}
    end;
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    CloseLibrary(PLibrary(GfxBase));
    {$ENDIF}
  end;
  Result := (return_code);
end;


{$IFDEF ENDIAN_LITTLE}
Var
  index : Integer;
{$ENDIF}

begin
  {$IF DEFINED(AROS) or DEFINED(MORPHOS)}
  Writeln('This example only makes sense to be run on an Amiga');
  {$ENDIF}

  // FPC Note: 
  // Small workaround to accomodate all supported platforms
  // Amiga requires image data to be stored into ChipMem
  // AROS doesn't use the chipmem concept for imagedata anymore
  // MorphOS ?
  {$IFDEF ENDIAN_LITTLE}  
  For Index := Low(sprite_data_data) to High(sprite_data_data) 
    do sprite_data_data[index] := Swap(sprite_data_data[index]);
  {$ENDIF}
  {$IFDEF AMIGA}
  sprite_data := ExecAllocMem(SizeOf(sprite_data_data), MEMF_CHIP);
  Move(sprite_data_data[0], sprite_data^, SizeOf(sprite_data_data));
  {$ENDIF}
  ExitCode := Main(ArgC, ArgV);
  {$IFDEF AMIGA}
  // Do not forget to release the allocated chip memory.
  ExecFreeMem(sprite_data, SizeOf(sprite_data_data));
  {$ENDIF}
end.
