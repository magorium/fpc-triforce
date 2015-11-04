program async;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : async
  Topic   : Demonstrating asyncronous input from a console window
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/async.c
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

           Unless otherwise noted, these examples must be considered
                 copyrighted by their respective owner(s)

  ===========================================================================
}

Uses
  Exec, AmigaDOS, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,  
  {$ENDIF}
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//* Start asyncronous read from a file                                      */
//*-------------------------------------------------------------------------*/

function  StartRead(afile: BPTR; buffer: APTR; size: LONG; port: pMsgPort): pMsgPort;
var
  fh     : pFileHandle;
  packet : pDosPacket;
begin
  fh := BADDR(afile);

  if (fh <> nil) and (fh^.fh_Type <> nil) then
  begin
    { FPC Note: AROS trips on taglists containing only TAG_END }
    if SetAndTest(packet, AllocDosObjectTags(DOS_STDPKT, [TAG_END, 0])) then
    begin
      packet^.dp_Port := port;

      packet^.dp_Type := ACTION_READ;
      packet^.dp_Arg1 := fh^.fh_Arg1;
      packet^.dp_Arg2 := LONG(buffer);
      packet^.dp_Arg3 := LONG(size);

      PutMsg(fh^.fh_Type, packet^.dp_Link);
      exit(port);
    end;
  end;

  result := nil;
end;

//*-------------------------------------------------------------------------*/
//* Start asyncronous write to a file                                       */
//*-------------------------------------------------------------------------*/

function  StartWrite(afile: BPTR; buffer: APTR; size: LONG; port: pMsgPort): pMsgPort;
var
  fh     : pFileHandle;
  packet : pDosPacket;
begin
  fh := BADDR(afile);

  if (fh <> nil) and (fh^.fh_Type <> nil) then
  begin
    if SetAndTest(packet, AllocDosObjectTags(DOS_STDPKT, [TAG_END])) then
    begin
      packet^.dp_Port := port;

      packet^.dp_Type := ACTION_WRITE;
      packet^.dp_Arg1 := fh^.fh_Arg1;
      packet^.dp_Arg2 := LONG(buffer);
      packet^.dp_Arg3 := LONG(size);

      PutMsg(fh^.fh_Type, packet^.dp_Link);
      exit(port);
    end;
  end;

  result := (nil);
end;

//*-------------------------------------------------------------------------*/
//* Wait for asyncronous read/write to complete and fetch the result        */
//*-------------------------------------------------------------------------*/

function  WaitDosIO(port: pMsgPort): LONG;
var
  msg    : pMessage;
  packet : pDosPacket;
  rc     : LongInt;
begin
  WaitPort(port);
  msg := GetMsg(port);
  packet := pDosPacket(msg^.mn_Node.ln_Name);
  rc := packet^.dp_Res1;
  FreeDosObject(DOS_STDPKT, packet);

  result := (rc);
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  asyncport  : pMsgPort;    //* message port where the asyncronous request is replied to */
  console    : BPTR;        //* AmigaDOS file handler of the console window */ 

  win        : pWindow;

  cont       : boolean;
  winsig     : ULONG;
  consig     : ULONG;
  buffer     : array[0..Pred(80)] of Char;
  sigs       : ULONG;
  
  imsg       : pIntuiMessage;
  textvalue  : String[Pred(80)];
  
  bytes_read : LongInt;
  
begin
  console := DOSInput();

  if SetAndTest(asyncport, CreateMsgPort()) then
  begin
    if SetAndTest(win, OpenWindowTags( nil,
    [
      TAG_(WA_Width)      , 300,
      TAG_(WA_Height)     , 100,
      TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_REPORTMOUSE or WFLG_ACTIVATE or WFLG_NOCAREREFRESH),
      TAG_(WA_IDCMP)      , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_MOUSEMOVE),
      TAG_END
    ])) then
    begin
      cont := TRUE;

      winsig := (1 shl win^.UserPort^.mp_SigBit);
      consig := (1 shl asyncport^.mp_SigBit);

      StartRead(console, @buffer[0], 79, asyncport);

      repeat
        sigs := Wait(winsig or consig or SIGBREAKF_CTRL_C);

        if ((sigs and winsig) <> 0) then
        begin
          while SetAndTest(imsg, pIntuiMessage(GetMsg(win^.UserPort))) do
          begin
            case (imsg^.IClass) of
              IDCMP_MOUSEMOVE:
              begin
                System.WriteStr(textvalue, 'Mouse moved to x=', imsg^.MouseX, '; y=', imsg^.MouseY, '    ');
                GfxMove(win^.RPort, win^.BorderLeft + 10, win^.BorderTop + 10 + win^.RPort^.TxBaseline);
                SetABPenDrMd(win^.RPort, 1, 0, JAM2);
                GfxText(win^.RPort, @textvalue[1], Length(textvalue));
              end;

              IDCMP_VANILLAKEY:
                if (imsg^.Code = $1b) //* Esc */
                then cont := FALSE;

              IDCMP_CLOSEWINDOW:
                cont := FALSE;
            end;
            ReplyMsg(pMessage(imsg));
          end;
        end;

        if ((sigs and consig) <> 0) then
        begin
          bytes_read := WaitDosIO(asyncport);
          buffer[bytes_read] := #0;
          WriteLn('input from the conole: ', buffer);
          StartRead(console, @buffer[0], 79, asyncport);
        end;

        if ((sigs and SIGBREAKF_CTRL_C) <> 0)
          then cont := FALSE;
      until not(cont);

      CloseWindow(win);

      WriteLn('Please press enter to end the program');
      WaitDosIO(asyncport);
    end;

    DeleteMsgPort(asyncport);
  end;

  result := (RETURN_OK);
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
