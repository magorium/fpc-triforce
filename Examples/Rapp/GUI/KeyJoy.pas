program KeyJoy;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

{
  ===========================================================================
  Project : KeyJoy
  Topic   : Control a point on a playground with the cursor keys - by means 
            of "intuition.library" only.
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/KeyJoy.c
  ===========================================================================

  This example was originally written in c by Thomas Rapp.

  The original examples are available online and published at Thomas Rapp's 
  website (http://thomas-rapp.homepage.t-online.de/examples)

  The c-sources were converted to Free Pascal, and (variable) names and 
  comments were translated from German into English as much as possible.

  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc

  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Conversion to Free Pascal and translation was done by Magorium in 2015, 
  with kind permission from Thomas Rapp to be able to publish.

  ===========================================================================  

        Unless otherwise noted, you must consider these examples to be 
                 copyrighted by their respective owner(s)

  ===========================================================================  
}

//*-------------------------------------------------------------------------*/
//* System Includes                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AGraphics, Intuition, InputEvent, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


//*-------------------------------------------------------------------------*/
//* Main routine                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  win       : PWindow;
  rp        : PRastPort;
  port      : PMsgPort;
  mess      : PIntuiMessage;
  cont      : Boolean;
  left, right, up, down : boolean;
  x,y       : LongInt;
  vx,vy     : LongInt;
  w,h       : LongInt;
begin
  if SetAndTest(win, OpenWindowTags( nil,
  [
    TAG_(WA_Title)  , TAG_(PChar('KeyJoy')),
    TAG_(WA_Left)   , 80,
    TAG_(WA_Top)    , 80,
    TAG_(WA_Width)  , 400,
    TAG_(WA_Height) , 300,
    TAG_(WA_Flags)  , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_GIMMEZEROZERO or WFLG_ACTIVATE),
    TAG_(WA_IDCMP)  , TAG_(IDCMP_CLOSEWINDOW or IDCMP_RAWKEY or IDCMP_INTUITICKS),
    TAG_END
  ])) then
  begin
    rp   := win^.RPort;
    w    := win^.GZZWidth - 5;
    h    := win^.GZZHeight - 5;
    x    := w div 2;
    y    := h div 2;
    vx   := 0;
    vy   := 0;
    left := FALSE;
    right := FALSE;
    up   := FALSE;
    down := FALSE;
    SetAPen(rp, 2);
    RectFill(rp, x, y, x + 3, y + 3);
    port := win^.UserPort;
    cont := TRUE;

    while (cont) do
    begin
      WaitPort (port);
      while SetAndTest(mess, PIntuiMessage(GetMsg(Port))) do
      begin
        case (mess^.IClass) of
          IDCMP_INTUITICKS:
          begin
            if (left)  then dec(vx);
            if (right) then inc(vx);
            if (up)    then dec(vy);
            if (down)  then inc(vy);
            SetAPen(rp, 1);
            RectFill(rp, x, y, x + 3, y + 3);
            x := x + vx;
            if ((x <= 0) or (x >= w)) then vx := -vx;
            y := y + vy;
            if ((y <= 0) or (y >= h)) then vy := -vy;
            SetAPen(rp, 2);
            RectFill(rp, x, y, x + 3, y + 3);
          end;
          IDCMP_CLOSEWINDOW:
            cont := FALSE;
          IDCMP_RAWKEY:
          begin
            if not((mess^.Qualifier and IEQUALIFIER_REPEAT) <> 0) then
            case (mess^.Code and not(IECODE_UP_PREFIX)) of
              $45: //* Esc */
                cont  := FALSE;
              $4f, //* Cursor left */
              $2d: //* Numpad 4 */
                left  := not(mess^.Code and IECODE_UP_PREFIX <> 0);
              $4e, //* Cursor right */
              $2f: //* Numpad 6 */
                right := not(mess^.Code and IECODE_UP_PREFIX <> 0);
              $4c, //* Cursor up */
              $3e: //* Numpad 8 */
                up    := not(mess^.Code and IECODE_UP_PREFIX <> 0);
              $4d, //* Cursor down */
              $1e: ///* Numpad 2 */
                down  := not(mess^.Code and IECODE_UP_PREFIX <> 0);
            end;
          end;
        end; // case
        ReplyMsg(pMessage(mess));
      end;
    end; // while
    CloseWIndow(win);
  end;

  result := (0);
end;

//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/

Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  GfxBase := OpenLibrary(GRAPHICSNAME, 0);
  if not assigned(GfxBase) then Exit;
  {$ENDIF}
  {$IF DEFINED(MORPHOS)}
  IntuitionBase := OpenLibrary(INTUITIONNAME, 0);
  if not assigned(IntuitionBase) then Exit;
  {$ENDIF}

  Result := True;
end;


Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS)}
  if assigned(IntuitionBase) then CloseLibrary(pLibrary(IntuitionBase));
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  if assigned(GfxBase) then CloseLibrary(pLibrary(GfxBase));
  {$ENDIF}
end;


begin
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
end.
