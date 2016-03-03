program Sift;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : Sift
  Title     : Takes any IFF file and tells you what's in it. 
              (Verifies syntax and all that cool stuff)
  Source    : RKRM
}
 {
 * Sift.c lists the type and size of every chunk in an IFF file and
 * checks the IFF file for correct syntax.  You should use Sift to
 * check IFF files created by your programs.
 *
 *
 * Usage: sift -c		; For clipboard scanning
 *    or  sift <file>		; For DOS file scanning
 *
 * Reads the specified stream and prints an IFFCheck-like listing of the contents of the IFF file, if any.
 * Stream is a DOS file for <file> argument, or is the clipboard's primary clip for -c.
 * This program must be run from a CLI.
 }




{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}


Uses
  Exec, AmigaDOS, IFFParse, ClipBoard,
  SysUtils,
  CHelpers;



const
  MINARGS   = 2;

  vers      : PChar = #0'$VER: sift 37.1';  //* 2.0 Version string for c:Version to find */
  usage     : PChar = 'Usage: sift IFFfilename (or -c for clipboard)';

  {*
   * Text error messages for possible IFFERR_#? returns from various IFF routines.  To get the index into
   * this array, take your IFFERR code, negate it, and subtract one.
   *  idx = -error - 1;
   *}
  errormsgs : array[0..11] of PChar =
  (
    'End of file (not an error).', 'End of context (not an error).', 'No lexical scope.',
    'Insufficient memory.', 'Stream read error.', 'Stream write error.',
    'Stream seek error.', 'File is corrupt.', 'IFF syntax error.',
    'Not an IFF file.', 'Required call-back hook missing.', 'Return to client.  You should never see this.'
  );


  procedure PrintTopChunk (iff: PIFFHandle); forward;  //* proto for our function */

// struct Library *IFFParseBase;


function  Main(argc: integer; argv: PPChar): Integer;
var
  iff           : PIFFHandle = nil;
  error         : LongInt;
  cbio          : ByteBool;
label
  bye;
begin
  //* if not enough args or '?', print usage */
  if (((argc <> 0) and (argc < MINARGS)) or (argv[argc-1][0]='?')) then
  begin
    WriteLn(usage);
    goto bye;
  end;

  //* Check to see if we are doing I/O to the Clipboard. */
  cbio := ((argv[1][0] = '-')  and  (argv[1][1] = 'c'));

  if not (SetAndTest(IFFParseBase, OpenLibrary('iffparse.library', 0))) then
  begin
    WriteLn('Can''t open iff parsing library.');
    goto bye;
  end;

  //* Allocate IFF_File structure. */
  if not(SetAndTest(iff, AllocIFF)) then
  begin
    WriteLn('AllocIFF() failed.');
    goto bye;
  end;

  {*
   * Internal support is provided for both AmigaDOS files, and the clipboard.device.  This bizarre
   * 'if' statement performs the appropriate machinations for each case.
   *}
  if (cbio) then
  begin
    {*
     * Set up IFF_File for Clipboard I/O.
     *}
    if not (SetAndTest(iff^.iff_Stream, ULONG(OpenClipboard(PRIMARY_CLIP)))) then
    begin
      WriteLn('Clipboard open failed.');
      goto bye;
    end;
    InitIFFasClip(iff);
  end
  else
  begin
    //* Set up IFF_File for AmigaDOS I/O.  */
    if not(SetAndTest(BPTR(iff^.iff_Stream), DOSOpen(argv[1], MODE_OLDFILE))) then
    begin
      WriteLn('File open failed.');
      goto bye;
    end;
    InitIFFasDOS(iff);
  end;

  //* Start the IFF transaction. */
  if SetAndTest(error, OpenIFF(iff, IFFF_READ)) then
  begin
    WriteLn('OpenIFF failed.');
    goto bye;
  end;

  while (true) do
  begin
    {*
     * The interesting bit.  IFFPARSE_RAWSTEP permits us to have precision monitoring of the
     * parsing process, which is necessary if we wish to print the structure of an IFF file.
     * ParseIFF() with _RAWSTEP will return the following things for the following reasons:
     *
     * Return code:			Reason:
     * 0				Entered new context.
     * IFFERR_EOC			About to leave a context.
     * IFFERR_EOF			Encountered end-of-file.
     * <anything else>		A parsing error.
     *}
    error := ParseIFF(iff, IFFPARSE_RAWSTEP);

    {*
     * Since we're only interested in when we enter a context, we "discard" end-of-context
     * (_EOC) events.
     *}
    if (error = IFFERR_EOC)
    then continue
    else if (error <> 0)
      {*
       * Leave the loop if there is any other error.
       *}
      then break;


    //* If we get here, error was zero. Print out the current state of affairs. */
    PrintTopChunk(iff);
  end;

  {*
   * If error was IFFERR_EOF, then the parser encountered the end of
   * the file without problems.  Otherwise, we print a diagnostic.
   *}
  if (error = IFFERR_EOF)
  then WriteLn('File scan complete.')
  else WriteLn(Format('File scan aborted, error %d: %s', [error, errormsgs[-error - 1]]));

bye:
  if assigned(iff) then
  begin
    //* Terminate the IFF transaction with the stream.  Free all associated structures. */
    CloseIFF (iff);

    {*
     * Close the stream itself.
     *}
    if (iff^.iff_Stream <> 0)
    then if (cbio)
         then CloseClipboard(PClipboardHandle(iff^.iff_Stream))
         else DOSClose(BPTR(iff^.iff_Stream));

    //* Free the IFF_File structure itself. */
    FreeIFF(iff);
  end;
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if assigned(IFFParseBase) then CloseLibrary(IFFParseBase);
  {$ENDIF}
  Result := (RETURN_OK);
end;


procedure PrintTopChunk(iff: PIFFHandle);
var
  top   : PContextNode;
  i     : integer;
  idbuf : array[0..Pred(5)] of char;
begin
  //* Get a pointer to the context node describing the current context. */
  if not(SetAndTest(top, CurrentChunk(iff)))
  then exit;

  {*
   * Print a series of dots equivalent to the current nesting depth of chunks processed so far.
   * This will cause nested chunks to be printed out indented.
   *}
  for i := iff^.iff_Depth downto 0 
    do Write('. ');

  //* Print out the current chunk's ID and size. */
  Write(Format('%s %d ', [IDtoStr(top^.cn_ID, idbuf), top^.cn_Size]));

  //* Print the current chunk's type, with a newline. */
  WriteLn(IDtoStr(top^.cn_Type, idbuf));
end;


begin
  ExitCode := Main(ArgC, ArgV);
end.
