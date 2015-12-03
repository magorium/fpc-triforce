program manywindows;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : manywindows
  Topic   : Open maaaaany windows.
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/manywindows.c
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

//* How to use many windows with Intuition                                  */

//*-------------------------------------------------------------------------*/
//* System includes                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  AmigaLib,
  systemvartags,
  {$ENDIF}
  Math,
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//* Constants & Macros                                                      */
//*-------------------------------------------------------------------------*/

Const
  MIN_SPEED =   5;
  MAX_SPEED =  20;
  NUM_WIN   = 100;

  M_PI      = 3.14159265358979323846;

//*-------------------------------------------------------------------------*/
//* Type definitions                                                        */
//*-------------------------------------------------------------------------*/

Type
  Pwinnode = ^Twinnode;
  Twinnode = record
    n       : TMinNode;
    title   : String[10];
    win     : PWindow;
    angle   : UWORD;
    speed   : UWORD;
  end;

//*-------------------------------------------------------------------------*/
//* Global variables                                                        */
//*-------------------------------------------------------------------------*/

Var
  winlist   : TMinList;

//*-------------------------------------------------------------------------*/
//* Open a new window at a random position                                  */
//*-------------------------------------------------------------------------*/

function  open_win(scr: PScreen; port: PMsgPort): pWindow;
var
  w,h,x,y   : LongInt;
  node      : Pwinnode;
  win       : PWindow;
const
  n         : LongInt = 0;
begin
  w := scr^.Width  div 10;
  h := scr^.Height div 10;
  x := random (scr^.Width  - w);
  y := random (scr^.Height - h);


  if SetAndTest(node, AllocVec(sizeof(Twinnode), MEMF_CLEAR)) then
  begin
    inc(n);
    WriteStr(node^.title, n, #0);

    if SetAndTest(win, OpenWindowTags(nil,
    [
      TAG_(WA_PubScreen)  , TAG_(scr),
      TAG_(WA_Left)       , x,
      TAG_(WA_Top)        , y,
      TAG_(WA_Width)      , w,
      TAG_(WA_Height)     , h,
      TAG_(WA_Title)      , TAG_(@node^.title[1]),
      TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_NOCAREREFRESH),
      TAG_END
    ])) then
    begin
      win^.UserData := APTR(node);
      win^.UserPort := port;
      ModifyIDCMP(win, IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_INTUITICKS);
      node^.win := win;
      node^.angle := random(90);
      node^.speed := (random (MAX_SPEED - MIN_SPEED)) + MIN_SPEED;
      AddTail( PList(@winlist), PNode(node));
    end
    else
      FreeVec (node);
  end;
  result := (win);
end;

//*-------------------------------------------------------------------------*/
//* Close a window which shares its msg port with other windows             */
//*-------------------------------------------------------------------------*/

procedure CloseWindowSafely(win: PWindow);
var
  port          : PMsgPort;
  imsg, next    : PIntuiMessage;
  node          : Pwinnode;
begin
  node := Pwinnode(win^.UserData);

  Forbid();
  port := win^.UserPort;
  win^.UserPort := nil;
  ModifyIDCMP(win, 0);

  imsg := PIntuiMessage(port^.mp_MsgList.lh_Head);
  while SetAndTest(next, PIntuiMessage(imsg^.ExecMessage.mn_Node.ln_Succ)) do
  begin
    if (imsg^.IDCMPWindow = win) then
    begin
      Remove(@imsg^.ExecMessage.mn_Node);
      ReplyMsg(@imsg^.ExecMessage);
    end;

    imsg := next;
  end;
  
  CloseWindow(win);
  Permit();

  Remove(PNode(node));
  FreeVec(node);
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function  min(a: LongInt; b: LongInt): LongInt;
begin
  if (a < b) then result := a else result := b;
end;


//*-------------------------------------------------------------------------*/
//* Draw an animated object into the window                                 */
//*-------------------------------------------------------------------------*/

procedure animate_object(win: PWindow);
var
  node  : Pwinnode;
  rp    : PRastPort;
  winx,winy,winw,winh   : LongInt;
  r,a   : Float;
  x,y   : LongInt;
  cx,cy : LongInt;
begin
  node := Pwinnode(win^.UserData);
  rp   := win^.RPort;
  winx := win^.BorderLeft;
  winy := win^.BorderTop;
  winw := win^.GZZWidth;
  winh := win^.GZZHeight;
  r    := (min(winw, winh) - 1) / 2.0;
  a    := node^.angle * M_PI / 180.0;
  x    := round(cos(a) * r + 0.5);
  y    := round(sin(a) * r + 0.5);
  cx   := winw div 2 + winx;
  cy   := winh div 2 + winy;

  SetAPen(rp, 0);
  RectFill(rp, winx, winy, winx + winw - 1, winy + winh - 1);

  SetAPen(rp, 1);
  GfxMove(rp, cx + x, cy + y);
  Draw(rp, cx - x, cy - y);
  GfxMove(rp, cx - y, cy + x);
  Draw(rp, cx + y, cy - x);

  SetAPen(rp, 2);
  GfxMove(rp, cx + x, cy + y);
  Draw(rp, cx - y, cy + x);
  Draw(rp, cx - x, cy - y);
  Draw(rp, cx + y, cy - x);
  Draw(rp, cx + x, cy + y);

  node^.angle := (node^.angle + node^.speed) mod 90;
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  scr       : PScreen;
  port      : pMsgPort;
  n,i       : LongInt;
  imsg      : pIntuiMessage;
  closewin  : pWindow = nil;
  node, 
  next      : Pwinnode;
begin
  Randomize;

  NewList(PList(@winlist));

  if SetAndTest(scr, LockPubScreen(nil)) then
  begin
    if SetAndTest(port, CreateMsgPort) then
    begin
      n := 0;
      for i := 0 to Pred(NUM_WIN) do
        if (open_win(scr, port) <> nil)
            then inc(n);

      WriteLn(n, ' windows opened');

      while (n > 0) do
      begin
        WaitPort(port);
        while SetAndTest(imsg, PIntuiMessage(GetMsg(port))) do
        begin
          case (imsg^.IClass) of
            IDCMP_INTUITICKS:
            begin
              node := Pwinnode(winlist.mlh_Head);
              while SetAndTest(next, Pwinnode(node^.n.mln_Succ)) do
              begin
                animate_object(node^.win);

                node := next;
              end;
            end;
            IDCMP_VANILLAKEY:
            begin
              case (imsg^.Code) of
                $1b: //* Esc */
                    closewin := Pointer(-1);
                Ord('c'):
                    closewin := imsg^.IDCMPWindow;
                Ord('o'):
                    if (open_win(scr, port) <> nil) then
                    begin
                      inc(n);
                      WriteLn(n, ' windows opened');
                    end;
              end;
            end;
            IDCMP_CLOSEWINDOW:
            begin
              closewin := imsg^.IDCMPWindow;
            end;
          end;
          ReplyMsg(PMessage(imsg));

          if (closewin <> nil) then
          begin
            if (closewin = Pointer(-1)) then
            begin
              node := Pwinnode(winlist.mlh_TailPred);

              while SetAndTest(next, Pwinnode(node^.n.mln_Pred)) do
              begin
                WriteLn('closing window ', node^.title);
                CloseWindowSafely(node^.win);
                dec(n);
                WriteLn(n, ' windows remaining');

                node := next;
              end;
            end
            else
            begin
              WriteLn('closing window ', closewin^.Title);
              CloseWindowSafely(closewin);
              dec(n);
              closewin := nil;
              WriteLn(n, ' windows remaining');
            end;
          end;
        end;
      end;

      DeleteMsgPort(port);
    end;
    UnlockPubScreen(nil, scr);
  end;

  result := (0);
end;

//*-------------------------------------------------------------------------*/
//* End of original source code                                             */
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
