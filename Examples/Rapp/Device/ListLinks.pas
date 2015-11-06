program ListLinks;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : ListLinks
  Topic   : Display list of links from a directory
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/ListLinks.c
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
  Exec, AmigaDOS,
  {$IFDEF AMIGA}
  AmigaLib,
  {$ENDIF}
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
type
  TArgs = record path : PChar; end;
var
  rdArgs    : PRDArgs;
  args      : TArgs = (path: '');  
  lck       : BPTR;
  fib       : PFileInfoBlock;
  buffer    : packed array[0..256-1] of char;
  link,oldcd: BPTR;
begin
  rdargs := ReadArgs('PATH', @args, nil);
  if not assigned(rdargs) then
  begin
    PrintFault(IoErr, nil);
    exit(RETURN_ERROR);
  end;

  if SetAndTest(lck, Lock(args.path, SHARED_LOCK)) then
  begin
    if SetAndTest(fib, AllocVec(sizeof(TFileInfoBlock), MEMF_CLEAR)) then
    begin
      if LongBool(Examine(lck, fib)) then
      begin
        if (fib^.fib_DirEntryType > 0) then
        begin
          while LongBool(ExNext(lck, fib)) do
          begin
            case (fib^.fib_DirEntryType) of
              ST_FILE:  
                Printf('%-24s file' + LineEnding, [LONG(@fib^.fib_FileName)]);
              ST_ROOT,
              ST_USERDIR:
                Printf('%-24s directory' + LineEnding, [LONG(@fib^.fib_FileName)]);
              ST_SOFTLINK:
              begin
                buffer[0] := #0;
                ReadLink (PFileLock(BADDR(lck))^.fl_Task, lck, @fib^.fib_FileName, @buffer, 256);
                Printf('%-24s softlink -> %s' + LineEnding, [LONG(@fib^.fib_FileName), LONG(@buffer)]);
              end;
              ST_LINKDIR,
              ST_LINKFILE:
              begin
                buffer[0] := #0;
                oldcd := CurrentDir(lck);
                if SetAndTest(link, Lock(@fib^.fib_FileName, SHARED_LOCK)) then
                begin
                  NameFromLock(link, buffer, 256);
                  UnLock(link);
                end;
                CurrentDir(oldcd);
                Printf('%-24s hardlink -> %s' + LineEnding, [LONG(@fib^.fib_FileName), LONG(@buffer)]);
              end
              else
              begin
                Printf('%-24s unknown (%ld)' + LineEnding, [LONG(@fib^.fib_FileName), fib^.fib_DirEntryType]);
              end;
            end; // case
          end; // while
        end
        else
        begin
          SetIoErr(ERROR_OBJECT_WRONG_TYPE);
          PrintFault(IoErr, args.path);
        end;
      end
      else
        PrintFault(IoErr, args.path);

      FreeVec (fib);
    end
    else
    begin
      SetIoErr(ERROR_NO_FREE_STORE);
      PrintFault(IoErr(),args.path);
    end;
    UnLock(lck);
  end
  else
    PrintFault(IoErr(),args.path);

  FreeArgs(rdargs);
  Result := (RETURN_OK);
end;



//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/



Function OpenLibs: boolean;
begin
  Result := False;

  Result := True;
end;


Procedure CloseLibs;
begin
end;


begin
  WriteLn('enter');

  if OpenLibs 
  then ExitCode := Main
  else ExitCode := RETURN_FAIL;

  CloseLibs;
  
  WriteLn('leave');
end.
