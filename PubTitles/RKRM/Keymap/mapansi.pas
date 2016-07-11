program mapansi;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : mapansi
  Topic     : converts a string to input events using MapANSI() function.
  Source    : RKRM
}
 {
  This example will also take the created input events
  and add them to the input stream using the simple
  commodities.library function AddIEvents().  Alternately,
  you could open the input.device and use the input device
  command IND_WRITEEVENT to add events to the input stream.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDos, InputEvent, KeyMap, Commodities,
  Trinity;


var
  InputEvt  : PInputEvent = nil;    //* we'll allocate this */

  //* prototypes for our program functions */

  procedure openall; forward;
  procedure closeall; forward;
  procedure closeout(errstring: PChar; rc: LONG); forward;


function  Main(argc: Integer; argv: PPChar): Integer;
var
  str       : PChar;
  tmp1      : PChar;
  tmp2      : PChar;
  iebuffer  : array[0..Pred(6)] of Char;    //* Space for two dead keys */
                                            //* + 1 key + qualifiers    */
  i         : Integer;
  rc        : LONG  = 0;
begin
  openall();

  str := ';String converted to input events and sent to input device' + LineEnding;

  InputEvt^.ie_Class := IECLASS_RAWKEY;

  //* Turn each character into an InputEvent */
  tmp1 := str;

  while (tmp1^ <> #0) do
  begin
    //* Convert one character, use default key map */
    {$IFDEF MORPHOS}
    i := KeyMap.MapANSI(PShortInt(tmp1), 1, @iebuffer, 3, nil);
    {$ELSE}
    i := KeyMap.MapANSI(tmp1, 1, @iebuffer, 3, nil);
    {$ENDIF}

    //* Make sure we start without deadkeys */
    InputEvt^.ie_position.ie_dead.ie_Prev1DownCode := 0; InputEvt^.ie_position.ie_dead.ie_Prev1DownQual := 0;
    InputEvt^.ie_position.ie_dead.ie_Prev2DownCode := 0; InputEvt^.ie_position.ie_dead.ie_Prev2DownQual := 0;

    tmp2 := iebuffer;

    case (i) of
      -2:
      begin
        WriteLn('Internal error');
        rc := RETURN_FAIL;
      end;

      -1:
      begin
        WriteLn('Overflow');
        rc := RETURN_FAIL;
      end;

      0:
      begin
        WriteLn('Can''t generate code');
      end;

      3,2,1:
      begin
        If (i = 3) then
        begin
          InputEvt^.ie_position.ie_dead.ie_Prev2DownCode := UBYTE(tmp2^);
          inc(tmp2);
          InputEvt^.ie_position.ie_dead.ie_Prev2DownQual := UBYTE(tmp2^);
          inc(tmp2);
        end;

        if ((i = 3) or (i = 2)) then
        begin
          InputEvt^.ie_position.ie_dead.ie_Prev1DownCode := UBYTE(tmp2^);
          inc(tmp2);
          InputEvt^.ie_position.ie_dead.ie_Prev1DownQual := UBYTE(tmp2^);
          inc(tmp2);
        end;

        if ((i = 3) or (i = 2) or (i = 1)) then
        begin
          InputEvt^.ie_Code := UBYTE(tmp2^);
          inc(tmp2);
          InputEvt^.ie_Qualifier := UBYTE(tmp2^);
        end;
      end;
    end;

    if (rc = RETURN_OK) then
    begin
      //* Send the key down event */
      AddIEvents(InputEvt);

      //* Create a key up event */
      InputEvt^.ie_Code := InputEvt^.ie_Code or IECODE_UP_PREFIX;

      //* Send the key up event */
      AddIEvents(InputEvt);
    end;

    if (rc <> RETURN_OK)
    then break;

    inc(tmp1);
  end;

  closeall();
  result := (rc);
end;


procedure openall;
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  KeymapBase := OpenLibrary('keymap.library', 37);
  if (KeymapBase = nil)  then closeout('Kickstart 2.0 required', RETURN_FAIL);
  {$ENDIF}
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  CxBase := OpenLibrary('commodities.library', 37);
  if (CxBase = nil) then  closeout('Kickstart 2.0 required', RETURN_FAIL);
  {$ENDIF}
  InputEvt := ExecAllocMem(sizeof(TInputEvent), MEMF_CLEAR);
  if (InputEvt = nil)  then closeout('Can''t allocate input event', RETURN_FAIL);
end;


procedure closeall;
begin
  if assigned(InputEvt)   then ExecFreeMem(InputEvt, sizeof(TInputEvent));
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if assigned(CxBase)     then CloseLibrary(CxBase);
  {$ENDIF}
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if assigned(KeymapBase) then CloseLibrary(KeymapBase);
  {$ENDIF}
end;


procedure closeout(errstring: PChar; rc: LONG);
begin
  if (errstring^ <> #0) then WriteLn(errstring);
  closeall;
  halt(rc);
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
