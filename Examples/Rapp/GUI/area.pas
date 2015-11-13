program area;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : area
  Topic   : Example using area functions (AreaMove, AreaDraw, AreaEnd)
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/area.c
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
  Exec, AmigaDOS, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  Trinity;


Type
  PUByte    = ^UBYTE;

  function  MACRO_RASSIZE(w,h: integer): integer; inline;
  begin
    MACRO_RASSIZE := ((h)*( ((w)+15) shr 3 and $FFFE));
  end;

  
Const
  MAXVEC    = 10;   //* maximum number of Area function calls */


//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/


function  main: integer;
var
  win       : pWindow;
  port      : pMsgPort;
  mess      : pIntuiMessage;
  go_on     : Boolean;
  rp        : pRastPort;
  tmpras    : TTmpRas;      //* TmpRas-structure        */
  tmpbuf    : PUByte;       //* Buffer for TmpRas       */
  rassize   : ULONG;        //* Size fo TmpRas-buffer   */
  areainfo  : TAreaInfo;    //* AreaInfo-structure      */
  areabuf   : PUByte;       //* Buffer for AreaInfo     */
begin
  win := OpenWindowTags( nil,
  [
    TAG_(WA_Left)        , 400,
    TAG_(WA_Top)         , 300,
    TAG_(WA_InnerWidth)  , 100,
    TAG_(WA_InnerHeight) , 100,
    TAG_(WA_Title)       , TAG_(PChar('Window')),
    TAG_(WA_Flags)       , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_GIMMEZEROZERO or WFLG_NOCAREREFRESH),
    TAG_(WA_IDCMP)       , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY),
    TAG_END
  ]);


  if (win <> nil) then
  begin
    rp := win^.RPort;

    rassize := MACRO_RASSIZE(win^.GZZWidth, win^.GZZHeight);
    tmpbuf := AllocVec(rassize, MEMF_CHIP or MEMF_CLEAR);   //* Create buffer for TmpRas */
    if (tmpbuf <> nil) then
    begin
      InitTmpRas(@tmpras, tmpbuf, rassize);                 //* Initialize TmpRas */
      rp^.TmpRas := @tmpras;                                //* and assign to the RastPort */
    end;

    areabuf := AllocVec(5*MAXVEC, MEMF_CLEAR);              //* Create buffer for AreaInfo */
    if (areabuf <> nil) then                                //* (5 bytes per call to Area function) */
    begin
      InitArea(@areainfo, areabuf, MAXVEC);                 //* Initialize AreaInfo */
      rp^.AreaInfo := @areainfo;                            //* and assign to the RastPort */
    end;

    SetAPen(rp, 2);             //* Set color (Pen 2 is generally white) */
    AreaMove(rp, 10, 50);       //* Set starting corner */
    AreaDraw(rp, 50, 10);       //* Set next corner */
    AreaDraw(rp, 90, 50);
    AreaDraw(rp, 50, 90);
    AreaEnd(rp);                //* Complete Area and fill */
                                //* The line to the starting point will be automatically added */

                                //* To complete, enclose the frame with lines */
    SetAPen(rp, 1);             //* Pen 1 = Black */
    GfxMove(rp, 10, 50);
    Draw(rp, 50, 10);
    Draw(rp, 90, 50);
    Draw(rp, 50, 90);
    Draw(rp, 10, 50);           //* This time the last line must be drawn on screen */


    port := win^.UserPort;
    go_on := TRUE;
    while (go_on) do
    begin
      WaitPort(port);
      mess := pIntuiMessage(GetMsg(port));
      while (mess <> nil) do
      begin
        case (mess^.IClass) of
          IDCMP_CLOSEWINDOW:
            go_on := FALSE;
          IDCMP_VANILLAKEY:
            if (mess^.Code = $1b)
            then go_on := FALSE;
        end;
        ReplyMsg(pMessage(mess));
        mess := pIntuiMessage(GetMsg(port));
      end;
    end;

    if (tmpbuf <> nil) then
    begin
      rp^.TmpRas := nil;    //* Remove TmpRas from RastPort */
      FreeVec(tmpbuf);      //* Release buffer */
    end;

    if (areabuf <> nil) then
    begin
      rp^.AreaInfo := nil;      //* Remove AreaInfo from RastPort */
      FreeVec(areabuf);         //* Release buffer */
    end;

	CloseWindow(win);
  end
  else
  begin
    WriteLn('Unable to open window !');
    exit(RETURN_FAIL);
  end;

  Result := (RETURN_OK);
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
  else ExitCode := RETURN_FAIL;

  CloseLibs;
  
  WriteLn('leave');
end.
