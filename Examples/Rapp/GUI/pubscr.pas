program pubscr;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : pubscr
  Topic   : Example of a public screen
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/pubscr.c
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
//* Open a public screen with fixed palette                                 */

//*-------------------------------------------------------------------------*/
//* System Includes                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AmigaDOS, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  Trinity;


//*-------------------------------------------------------------------------*/
//* Global variables                                                        */
//*-------------------------------------------------------------------------*/

const
  palette   : array[0..Pred(50)] of ULONG = 
  (
    $00100000,
    $99999999, $99999999, $99999999,
    $11111111, $11111111, $11111111,
    $EEEEEEEE, $EEEEEEEE, $EEEEEEEE,
    $55555555, $66666666, $EEEEEEEE,
    $77777777, $77777777, $77777777,
    $BBBBBBBB, $BBBBBBBB, $BBBBBBBB,
    $CCCCCCCC, $AAAAAAAA, $88888888,
    $EEEEEEEE, $88888888, $CCCCCCCC,
    $00000000, $77777777, $00000000,
    $77777777, $44444444, $11111111,
    $EEEEEEEE, $44444444, $22222222,
    $44444444, $44444444, $44444444,
    $BBBBBBBB, $22222222, $22222222,
    $33333333, $AAAAAAAA, $22222222,
    $44444444, $44444444, $BBBBBBBB,
    $CCCCCCCC, $77777777, $00000000,
    0
  );

//*-------------------------------------------------------------------------*/
//* Open a simple choice requester                                          */
//*-------------------------------------------------------------------------*/

function  RequestChoice(scr: PScreen; const title: PChar; const body: PChar; const gadgets: PChar): LongInt;
var
  es        : TEasyStruct;
  idcmp     : ULONG = 0;
  res       : LongInt;
  win       : PWindow;
begin
  win := OpenWindowTags(nil,
  [
    TAG_(WA_CustomScreen) , TAG_(scr),
    TAG_(WA_Width)        , 1,
    TAG_(WA_Height)       , 1,
    TAG_(WA_Flags)        , TAG_(WFLG_BORDERLESS or WFLG_NOCAREREFRESH),
    TAG_END
  ]);

  es.es_StructSize   := sizeof(TEasyStruct);
  es.es_Flags        := 0;
  es.es_Title        := STRPTR(title);
  es.es_TextFormat   := STRPTR(body);
  es.es_GadgetFormat := STRPTR(gadgets);

  res := EasyRequest(win, @es, @idcmp, [TAG_END, TAG_END]); // bug in aros taglist

  if Assigned(win) then CloseWindow(win);

  result := (res);
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  scr       : PScreen;
  pubsigbit : ShortInt;
  pubsig    : ULONG;
  signals   : ULONG;
  close     : boolean = FALSE;
  i         : LongInt;
begin
  pubsigbit := AllocSignal(-1);
  if (pubsigbit = -1) then
  begin
    WriteLn('cannot allocate a signal');
    exit(RETURN_FAIL);
  end;

  pubsig := 1 shl pubsigbit;

  scr := OpenScreenTags(nil,
  [
    TAG_(SA_LikeWorkbench)  , TAG_(TRUE),
    TAG_(SA_Title)          , TAG_(PChar('My First Public Screen')),
    TAG_(SA_Type)           , PUBLICSCREEN_f,
    TAG_(SA_PubName)        , TAG_(PChar('MYFIRSTPUB')),
    TAG_(SA_PubSig)         , pubsigbit,
    TAG_(SA_PubTask)        , TAG_(FindTask(nil)),
    TAG_(SA_Depth)          , 4,
    TAG_(SA_Colors32)       , TAG_(@palette),
    TAG_END
  ]);

  if assigned(scr) then
  begin
    for i := 0 to Pred(16) do
      ObtainPen(scr^.ViewPort.ColorMap, i, 0, 0, 0, PEN_NO_SETCOLOR);

    PubScreenStatus(scr, 0);
  end;


  while assigned(scr) do
  begin
    signals := Wait(pubsig or SIGBREAKF_CTRL_C);

    if (signals and pubsig <> 0) then
    begin
      close := 0 <> RequestChoice(scr, 'PubScreen Request', 'All windows on the screen have been closed.'#13'Should the screen be closed, too?', 'Close screen|Keep screen open');
      SetSignal(0, pubsig); //* closing the requester has set the signal, so we need to clear it again */
    end
    else //* Ctrl-C */
      close := TRUE;

    while (close and (scr <> nil)) do
    begin
      if (CloseScreen(scr))
      then scr := nil
      else close := 0 <> RequestChoice(scr, 'PubScreen Request', 'The screen cannot be closed yet because'#13'there are still some windows open on it.','Retry|Cancel');
    end;
  end;

  FreeSignal(pubsigbit);

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
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := RETURN_FAIL;

  CloseLibs;
end.
