program clipFTXT;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : clipFTXT
  Source    : RKRM
}
 {
 *
 * ClipFTXT.c demonstrates reading (and optional writing) of clipboard
 * device FTXT.  This example may be used as the basis for supporting
 * Release 2 console pastes.
 *
 * clipftxt.c:	Writes ASCII text to clipboard unit as FTXT
 *		(All clipboard data must be IFF)
 *
 * Usage: clipftxt unitnumber
 *
 * To convert to an example of reading only, comment out #define WRITEREAD
 }


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}


Uses
  Exec, AmigaDOS, IFFParse,
  SysUtils,
  CHelpers;


{* Causes example to write FTXT first, then read it back
 * Comment out to create a reader only
 *}
{$DEFINE WRITEREAD}


Const
  MINARGS   = 2;

  //* 2.0 Version string for c:Version to find */
  vers      : packed array[0..20] of Char = #0'$VER: clipftxt 37.2'#0;

  usage     : PChar = 'Usage: clipftxt unitnumber (use zero for primary unit)';

  {*
   * Text error messages for possible IFFERR_#? returns from various
   * IFF routines.  To get the index into this array, take your IFFERR code,
   * negate it, and subtract one.
   *  idx = -error - 1;
   *}
  errormsgs : array[0..11] of PChar =
  (
    'End of file (not an error).',
    'End of context (not an error).',
    'No lexical scope.',
    'Insufficient memory.',
    'Stream read error.',
    'Stream write error.',
    'Stream seek error.',
    'File is corrupt.',
    'IFF syntax error.',
    'Not an IFF file.',
    'Required call-back hook missing.',
    'Return to client.  You should never see this.'
  );

  RBUFSZ    = 512;

  ID_FTXT   : LongInt = Ord('F') shl 24 + Ord('T') shl 16 + Ord('X') shl 8 + Ord('T');
  ID_CHRS   : LongInt = Ord('C') shl 24 + Ord('H') shl 16 + Ord('R') shl 8 + Ord('S');

  mytext    : PChar = 'This FTXT written to clipboard by clipftxt example.' + LineEnding;



function  Main(argc: integer; argv: PPChar): Integer;
var
  iff           : PIFFHandle = nil;
  cn            : PContextNode;
  error         : LongInt = 0;
  unitnumber    : LongInt = 0;
  rlen          : LongInt; 
  textlen       : Integer;
  readbuf       : packed array[0..Pred(RBUFSZ)] of Char;
label
  bye;
begin
  //* if not enough args or '?', print usage */
  if (((argc <> 0) and (argc < MINARGS)) or (argv[argc-1][0]='?')) then
  begin
    WriteLn(usage);
    exit(RETURN_WARN);
  end;

  unitnumber := StrToIntDef(argv[1], 0);

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if (not SetAndTest(IFFParseBase, OpenLibrary ('iffparse.library', 0))) then
  begin
    WriteLn('Can''t open iff parsing library.');
    goto bye;
  end;
  {$ENDIF}

  {*
   * Allocate IFF_File structure.
   *}
  if (not SetAndTest(iff, AllocIFF)) then
  begin
    WriteLn('AllocIFF() failed.');
    goto bye;
  end;

  {*
   * Set up IFF_File for Clipboard I/O.
   *}
  if (not SetAndTest(iff^.iff_Stream, ULONG(OpenClipboard(unitnumber)) ) ) then
  begin
    WriteLn('Clipboard open failed.');
    goto bye;
  end
  else Writeln(Format('Opened clipboard unit %d', [unitnumber] ));

  InitIFFasClip(iff);

{$ifdef WRITEREAD}

  {*
   * Start the IFF transaction.
   *}
  if SetAndTest(error, OpenIFF(iff, IFFF_WRITE)) then
  begin
    WriteLn('OpenIFF for write failed.');
    goto bye;
  end;

  {*
   * Write our text to the clipboard as CHRS chunk in FORM FTXT
   *
   * First, write the FORM ID (FTXT)
   *}
  if (not SetAndTest(error, PushChunk(iff, ID_FTXT, ID_FORM, IFFSIZE_UNKNOWN))) then
  begin
    {* Now the CHRS chunk ID followed by the chunk data
     * We'll just write one CHRS chunk.
     * You could write more chunks.
     *}
    if (not SetAndTest(error, PushChunk(iff, 0, ID_CHRS, IFFSIZE_UNKNOWN))) then
    begin
      //* Now the actual data (the text) */
      textlen := strlen(mytext);
      if (WriteChunkBytes(iff, mytext, textlen) <> textlen) then
      begin
        WriteLn('Error writing CHRS data.');
        error := IFFERR_WRITE;
      end;
    end;
    if not (error <> 0) then error := PopChunk(iff);
  end;
  if not (error <> 0) then error := PopChunk(iff);


  if (error <> 0) then
  begin
    WriteLn(Format('IFF write failed, error %d: %s', [error, errormsgs[-error - 1]]));
    goto bye;
  end
  else WriteLn('Wrote text to clipboard as FTXT');

  {*
   * Now let's close it, then read it back
   * First close the write handle, then close the clipboard
   *}
  CloseIFF(iff);
  if (iff^.iff_Stream <> 0) then CloseClipboard(PClipboardHandle(iff^.iff_Stream));

  if (not SetAndTest(iff^.iff_Stream, ULONG(OpenClipboard(unitnumber)))) then
  begin
    WriteLn('Reopen of Clipboard failed.');
    goto bye;
  end
  else WriteLn(Format('Reopened clipboard unit %d', [unitnumber] ));

{$endif} //* WRITEREAD */

  if SetAndTest(error, OpenIFF(iff, IFFF_READ)) then
  begin
    WriteLn('OpenIFF for read failed.');
    goto bye;
  end;

  //* Tell iffparse we want to stop on FTXT CHRS chunks */
  if SetAndTest(error, StopChunk(iff, ID_FTXT, ID_CHRS)) then
  begin
    WriteLn('StopChunk failed.');
    goto bye;
  end;

  //* Find all of the FTXT CHRS chunks */
  while (true) do
  begin
    error := ParseIFF(iff,IFFPARSE_SCAN);
    if (error = IFFERR_EOC) then continue   //* enter next context */
    else if (error <> 0) then break;

    {* We only asked to stop at FTXT CHRS chunks
     * If no error we've hit a stop chunk
     * Read the CHRS chunk data
     *}
    cn := CurrentChunk(iff);

    if ( assigned(cn) and (cn^.cn_Type = ID_FTXT) and (cn^.cn_ID = ID_CHRS) ) then
    begin
      WriteLn('CHRS chunk contains:');
      while ( SetAndGet(rlen, ReadChunkBytes(iff, @readbuf[0], RBUFSZ)) > 0) do
      begin
        DOSWrite(DOSOutput, @readbuf[0], rlen);
      end;
      if (rlen < 0)	then error := rlen;
    end;
  end;

  if ( (error <> 0) and (error <> IFFERR_EOF)) then
  begin
    WriteLn(Format('IFF read failed, error %d: %s', [error, errormsgs[-error - 1]]));
  end;

bye:
  if assigned(iff) then
  begin
    {*
     * Terminate the IFF transaction with the stream.  Free
     * all associated structures.
     *}
    CloseIFF(iff);

    {*
     * Close the clipboard stream
     *}
    if (iff^.iff_Stream <> 0) 
    then CloseClipboard(PClipboardHandle(iff^.iff_Stream));
    {*
     * Free the IFF_File structure itself.
     *}
    FreeIFF(iff);
  end;
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if assigned(IFFParseBase) then CloseLibrary(IFFParseBase);
  {$ENDIF}

  Result := (RETURN_OK);
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
