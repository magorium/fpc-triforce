program piechart;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : piechart
  Topic   : Draw a simple piechart
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/piechart.c
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

Uses
  Exec, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


Type
  PUByte    = ^UBYTE;
  FLOAT     = valreal;
  
  function  MACRO_RASSIZE(w,h: integer): integer; inline;
  begin
    MACRO_RASSIZE := ((h)*( ((w)+15) shr 3 and $FFFE));
  end;


Const
  M_PI      = 3.14159265358979323846;

Const
  STEP      = 10;                   //* number of degrees in the circle drawn as one straight line */

  MAXVEC    = ((360 div STEP) + 4); //* maximim number of Area calls (+2 for safety) */


  WINW      = 200;                  //* size of drawing area */
  WINH      = 200;

  CX        = (WINW shr 1);         //* center position */
  CY        = (WINH shr 1);

  RX        = (CX - 10);            //* radius */
  RY        = (CY - 10);

//*-------------------------------------------------------------------------*/
//* draw pie chart                                                          */
//*-------------------------------------------------------------------------*/

procedure draw_pie_chart(rp: pRastPort; cx: UWORD; cy: UWORD; rx: UWORD; ry: UWORD; step: UWORD; n: UWORD; values: Array of ULONG; pens: PUBYTE);
{/* Parameters:

 rp      RastPort of drawing area. TmpRas and AreaInfo must already be initialised.
 cx/cy   coordinates of the center point
 rx/ry   radius in x and y direction
 step    number of degrees drawn as one line
 n       number of pieces
 values  array with the size of each piece
 pens    array with the color for each piece

*/}
var
  sum: ULONG;         //* sum of all values (represents 360 degrees) */
  a1,a2: ULONG;       //* start and end angle of each piece in degrees */
  value: ULONG;       //* sum of values up to the end of the current piece */
  i: ULONG;           //* counter */
  a: ULONG;           //* angle in degrees */
  d: FLOAT;           //* angle in rad */
  x,y: ULONG;         //* coordinates of destination drawing point */
begin
  sum := 0;
  for i := 0 to Pred(n)     //* calculate sum */
    do sum := sum + values[i];

  value := 0;
  a2 := 0;                      //* start at zero angle and value */
  for i := 0 to pred(n) do
  begin
    a1 := a2;                   //* current start angle is end angle of previous piece */
    value := value + values[i]; //* sum values up to the end of the current piece */
    a2 := value * 360 div sum;  //* calculate current end angle */
    SetAPen(rp, pens[i]);       //* set drawing pen */
    AreaMove(rp, cx, cy);       //* start area in the center point */

    a := a1;
    while (a < a2) do
    begin
      d := a * M_PI / 180.0;            //* calculate rad from degrees */
      x := trunc(cos(d) * FLOAT(rx));   //* calculate circle point */
      y := trunc(sin(d) * FLOAT(ry));
      AreaDraw (rp, x + cx, y + cy);    //* draw to circle point */
      a := a + step;
    end;

    d := a2 * M_PI / 180.0;             //* last point is at end angle, even if step does not exactly hit it */
    x := trunc(cos(d) * FLOAT(rx));
    y := trunc(sin(d) * FLOAT(ry));
    AreaDraw(rp, x + cx, y + cy);

    AreaEnd(rp);                        //* complete area and fill it */
  end;
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  win       : pWindow;
  port      : pMsgPort;
  mess      : pIntuiMessage;
  cont      : Boolean;
  rp        : pRastPort;
  tmpras    : TTmpRas;      
  tmpbuf    : PUByte;       
  rassize   : ULONG;        
  areainfo  : TAreaInfo;    
  areabuf   : PUByte;       
const
  pie       : Array[0..3] of ULONG = (20, 60, 30, 80);
  pen       : Array[0..3] of UBYTE = ( 1,  2,  3,  4);
begin
  if SetAndTest(win, OpenWindowTags( nil,
  [
    TAG_(WA_Left)        , 10,
    TAG_(WA_Top)         , 10,
    TAG_(WA_InnerWidth)  , WINW,
    TAG_(WA_InnerHeight) , WINH,
    TAG_(WA_Title)       , TAG_(PChar('Press Esc to exit')),
    TAG_(WA_Flags)       , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO),
    TAG_(WA_IDCMP)       , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY),
    TAG_END
  ])) then
  begin
    rp := win^.RPort;

    rassize := MACRO_RASSIZE(win^.GZZWidth, win^.GZZHeight);
    if SetAndtest(tmpbuf, AllocVec(rassize, MEMF_CHIP or MEMF_CLEAR)) then
    begin
      InitTmpRas(@tmpras, tmpbuf, rassize);
      rp^.TmpRas := @tmpras;
    end;

    if SetAndtest(areabuf, AllocVec(5*MAXVEC, MEMF_CLEAR)) then
    begin
      InitArea(@areainfo, areabuf, MAXVEC);
      rp^.AreaInfo := @areainfo;
    end;

    draw_pie_chart(rp, CX, CY, RX, RY, STEP, 4, pie, pen);

    port := win^.UserPort;
    cont := TRUE;
    while (cont) do
    begin
      WaitPort(port);
      while SetAndTest(mess, pIntuiMessage(GetMsg(port))) do
      begin
        case (mess^.IClass) of
          IDCMP_CLOSEWINDOW:
            cont := FALSE;
          IDCMP_VANILLAKEY:
            if (mess^.Code = $1b)
            then cont := FALSE;
        end;
        ReplyMsg(pMessage(mess));
      end;
    end;

    if assigned(tmpbuf) then
    begin
      rp^.TmpRas := nil;
      FreeVec(tmpbuf);
    end;

    if assigned(areabuf) then
    begin
      rp^.AreaInfo := nil;
      FreeVec(areabuf);
    end;

	CloseWindow(win);
  end
  else
    exit(20);

  Result := (0);
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
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
  
  WriteLn('leave');
end.
