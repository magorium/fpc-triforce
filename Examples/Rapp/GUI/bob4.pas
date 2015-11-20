program bob4;

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
  Project : bob4
  Topic   : Example of how to implement drag and drop
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/bob4.c
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
  Exec, AmigaDOS, AGraphics, CyberGraphics, Intuition, inputEvent, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


function ifthen(val: Boolean; const iftrue: Integer; const iffalse: Integer = 0): Integer; overload;
begin
  if val then result := iftrue else result := iffalse;
end;

//*-------------------------------------------------------------------------*/
//* Constants and macros                                                    */
//*-------------------------------------------------------------------------*/

const
  WINX      = 80;
  WINY      = 40;
  WINW      = 200;
  WINH      = 100;
 
  BOBW      = 80;
  BOBH      = 40;
  BOBMINX   = 40;
  BOBMINY   = 20;
  BOBMAXX   = (BOBMINX + BOBW - 1);
  BOBMAXY   = (BOBMINY + BOBH - 1);


//*-------------------------------------------------------------------------*/
//* Type definitions                                                        */
//*-------------------------------------------------------------------------*/


Type
  Pbob = ^Tbob;
  Tbob = record
    rp      : PRastPort;
    x       : SmallInt;
    y       : SmallInt;
    w       : SmallInt;
    h       : SmallInt;
    bm      : PBitMap;
    backx   : SmallInt;
    backy   : SmallInt;
    backw   : SmallInt;
    backh   : SmallInt;
    back    : PBitMap;
  end;

//*-------------------------------------------------------------------------*/
//*  Global variables                                                       */
//*-------------------------------------------------------------------------*/


//*-------------------------------------------------------------------------*/
//*  Prototypes                                                             */
//*-------------------------------------------------------------------------*/

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure cut_bob(bob: Pbob; rp: PRastPort; x: LongInt; y: LongInt);
var
  temprp : TRastPort;
begin
  if assigned(bob) then
  begin
    InitRastPort(@temprp);
    temprp.BitMap := bob^.bm;
    ClipBlit(rp, x, y, @temprp, 0, 0, bob^.w, bob^.h, $C0);
  end;
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure remove_bob(bob: Pbob);
begin
  if assigned(bob) then if assigned(bob^.rp) then
  begin
    BltBitMap(bob^.back, bob^.backx, bob^.backy, bob^.rp^.BitMap, bob^.x + bob^.backx, bob^.y + bob^.backy, bob^.backw, bob^.backh, $C0, $FF, nil);
    bob^.rp := nil;
  end;
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure add_bob(rp: PRastPort; bob: Pbob);
var
  scrw, scrh, x, y: LongInt;
begin
  if assigned(bob) then
  begin
    if assigned(bob^.rp)
        then remove_bob(bob);
    bob^.rp := rp;
    bob^.backw := bob^.w;
    bob^.backh := bob^.h;
    scrw := GetBitMapAttr(rp^.BitMap, BMA_WIDTH);
    scrh := GetBitMapAttr(rp^.BitMap, BMA_HEIGHT);
    if ((bob^.x + bob^.backw) > scrw)
        then bob^.backw := scrw - bob^.x;
    if ((bob^.y + bob^.backh) > scrh)
        then bob^.backh := scrh - bob^.y;
    bob^.backx := 0;
    bob^.backy := 0;
    if (bob^.x < 0) then
    begin
      bob^.backx := -bob^.x;
      bob^.backw := bob^.backw - bob^.backx;
    end;
    if (bob^.y < 0) then
    begin
      bob^.backy := -bob^.y;
      bob^.backh := bob^.backh - bob^.backy;
    end;
    x := bob^.x + bob^.backx;
    y := bob^.y + bob^.backy;
    BltBitMap(rp^.BitMap,          x,          y, bob^.back , bob^.backx, bob^.backy, bob^.backw, bob^.backh, $C0, $ff, nil);
    BltBitMap(bob^.bm   , bob^.backx, bob^.backy, rp^.BitMap,          x,          y, bob^.backw, bob^.backh, $C0, $ff, nil);
  end;
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure move_bob(bob: Pbob; x: LongInt; y: LongInt);
var
  rp    : PRastPort = nil;
begin
  if assigned(bob) then
  begin
    if SetAndTest(rp, bob^.rp)
        then remove_bob(bob);
    bob^.x := x;
    bob^.y := y;
    if assigned(rp)
        then add_bob(rp, bob);
  end;
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

procedure free_bob(bob: Pbob);
begin
  if assigned(bob) then
  begin
    if assigned(bob^.rp)
        then remove_bob(bob);
    if assigned(bob^.bm)
        then FreeBitMap(bob^.bm);
    if assigned(bob^.back)
        then FreeBitMap(bob^.back);
    ExecFreeMem(bob, sizeof(Tbob));
  end;
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function new_bob(w: LongInt; h: LongInt; d: LongInt): Pbob;
var
  bob : Pbob;
begin
  bob := ExecAllocMem(sizeof(Tbob), MEMF_CLEAR);
  if assigned(bob) then
  begin
    bob^.w := w;
    bob^.h := h;
    if (d > 8) then d := 24;
    bob^.bm   := AllocBitMap(w, h, d, ifthen(d = 24, BMF_SPECIALFMT or SHIFT_PIXFMT(PIXFMT_RGB24), 0), nil);
    bob^.back := AllocBitMap(w, h, d, ifthen(d = 24, BMF_SPECIALFMT or SHIFT_PIXFMT(PIXFMT_RGB24), 0), nil);
    if ((not assigned(bob^.bm)) or (not assigned(bob^.back))) then
    begin
      free_bob(bob);
      bob := nil;
    end;
  end;

  result := (bob);
end;


//*-------------------------------------------------------------------------*/
//* Main routine                                                            */
//*-------------------------------------------------------------------------*/

function  main(argc: integer; argv: PPChar): integer;
type
  targs       = record
    pubscreen : PChar;
  end;
var
  rdargs      : pRDArgs;
  args        : TArgs;
  scr         : pScreen;
  win         : pWindow; 
  port        : PMsgPort;
  mess        : pIntuiMessage;
  cont        : boolean;
  rp          : PRastPort;
  i           : Longint;
  bob         : Pbob;
  diffx       : LongInt = 0;
  diffy       : LongInt = 0;
begin
  args := Default(TArgs);

  if SetAndTest(rdargs, ReadArgs('PUBSCREEN/K', PLONG(@args), nil)) then
  begin
    if SetAndTest(scr, LockPubScreen(args.pubscreen)) then
    begin
      if SetAndTest(win, OpenWindowTags( nil,
      [
        TAG_(WA_CustomScreen) , TAG_(scr),
        TAG_(WA_Width)        , WINW,
        TAG_(WA_Height)       , WINH,
        TAG_(WA_Left)         , WINX,
        TAG_(WA_Top)          , WINY,
        TAG_(WA_Flags)        , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_REPORTMOUSE or WFLG_RMBTRAP or WFLG_GIMMEZEROZERO or WFLG_ACTIVATE),
        TAG_(WA_IDCMP)        , TAG_(IDCMP_CLOSEWINDOW or IDCMP_MOUSEMOVE or IDCMP_MOUSEBUTTONS),
        TAG_END
      ])) then
      begin
        rp := win^.RPort;
        for i := 0 to Pred(BOBW) do
        begin
          SetAPen(rp, (i and 3) + 1);
          GfxMove(rp, i + BOBMINX, BOBMINY);
          Draw(rp, BOBMAXX - i, BOBMAXY);
        end;
        for i := 0 to Pred(BOBH) do
        begin
          SetAPen(rp, (i and 3) + 1);
          GfxMove(rp, BOBMAXX, i + BOBMINY);
          Draw(rp, BOBMINX, BOBMAXY - i);
        end;
        bob := new_bob(BOBW, BOBH, GetBitMapAttr(scr^.RastPort.BitMap, BMA_DEPTH));
        cut_bob(bob, rp, BOBMINX,BOBMINY);
        RectFill(rp, BOBMINX, BOBMINY, BOBMAXX, BOBMAXY);
        rp := @scr^.RastPort;
        port := win^.UserPort;

        cont := TRUE;

        while (cont) do
        begin
          WaitPort(port);
          while SetAndTest(mess, PIntuiMessage(GetMsg(port))) do
          begin
            case (mess^.IClass) of
              IDCMP_CLOSEWINDOW:
                cont := FALSE;
              IDCMP_MOUSEMOVE:
                move_bob(bob, scr^.MouseX - diffx, scr^.MouseY - diffy);
              IDCMP_MOUSEBUTTONS:
              begin
                if (mess^.Code = IECODE_LBUTTON) then
                begin
                  if ( (win^.GZZMouseX >= BOBMINX) and (win^.GZZMouseX <= BOBMAXX) and (win^.GZZMouseY >= BOBMINY) and (win^.GZZMouseY <= BOBMAXY)) then
                  begin
                    diffx := scr^.MouseX - win^.LeftEdge - win^.BorderLeft - BOBMINX;
                    diffy := scr^.MouseY - win^.TopEdge  - win^.BorderTop  - BOBMINY;
                    move_bob(bob, scr^.MouseX - diffx, scr^.MouseY - diffy);
                    add_bob(@scr^.RastPort, bob);
                  end;
                end
                else
                  remove_bob(bob);
              end;
            end;
            ReplyMsg(pMessage(mess));
          end;
        end;

        remove_bob(bob);
        free_bob(bob);
        CloseWindow(win);
      end;
      UnlockPubScreen(nil, scr);
    end;
    FreeArgs(rdargs);
  end
  else 
    PrintFault(IoErr(), nil);

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
  WriteLn('enter');

  if OpenLibs 
  then ExitCode := Main(ArgC, ArgV)
  else ExitCode := RETURN_FAIL;

  CloseLibs;
  
  WriteLn('leave');
end.
