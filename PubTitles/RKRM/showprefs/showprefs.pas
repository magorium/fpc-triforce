program showprefs;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : showprefs
  Source    : RKRM
}
 {*
 ** The following example shows a way to read a Preferences file.
 **
 ** showprefs.c - parse and show some info from an IFF Preferences file
 ** NOTE: This example requires upcoming 2.1 prefs/ include files.
 **
 ** IMPORTANT!! This example is not linked with startup code (eg. c.o).
 ** It uses strictly direct AmigaDOS stdio, and also demonstrates
 ** direct ReadArgs argument parsing.  Therefore it is a CLI-only
 ** example.  If launched from Workbench, packet errors would occur
 ** since the WbStartup message is still sitting in the process's
 ** pr_MsgPort, and the code would never be unloaded from memory.
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

Uses
  Exec, AmigaDOS, IFFParse, Prefs,
  SysUtils,
  Trinity,
  CHelpers;




const
  IFFErrTxt : array[0..11] of PChar = 
  (
    'EOF',                  //* (end of file, not an error) */
    'EOC',                  //* (end of context, not an error) */
    'no lexical scope',
    'insufficient memory',
    'stream read error',
    'stream write error',
    'stream seek error',
    'file corrupt',
    'IFF syntax error',
    'not an IFF file',
    'required call-back hook missing',
    nil                     //* (return to client, never shown) */
  );


function  Main: Integer;
var
  rdargs    : PRDArgs = nil;
  rargs     : array [0..Pred(2)] of LongInt;
  iffhandle : PIFFHandle;
  cnode     : PContextNode;
  hdrsp     : PStoredProperty;
  sp        : PStoredProperty;
  filename  : PChar = nil;
  ifferror  : LongInt;
  error     : Longint = 0;
  rc        : LongInt = RETURN_OK;
begin
  //* FPC note: example slightly altered as FPC does provide startup code.

  //* This no-startup-code example may not be used from Workbench */
  if (PProcess(FindTask(nil))^.pr_CLI = default(BPTR))
  then exit(RETURN_FAIL);

  {$IFNDEF HASAMIGA}
  if SetAndTest(DOSBase, OpenLibrary('dos.library', 37)) then
  {$ELSE}
  if true then  // FPC: Quick workaround to let code compile: DOS is always opened automatically
  {$ENDIF}
  begin
    if SetAndTest(IFFParseBase, OpenLibrary('iffparse.library', 37)) then
    begin
      rdargs := ReadArgs('FILE/A', rargs, nil);
      if ( assigned(rdargs) and (rargs[0] <> 0) ) then
      begin
        filename := PChar(rargs[0]);

        //* allocate an IFF handle */
        if SetAndTest(iffhandle, AllocIFF) then
        begin
          //* Open the file for reading */
          if SetAndTest(iffhandle^.iff_Stream, LongInt(DOSOpen(filename, MODE_OLDFILE))) then
          begin
            //* initialize the iff handle */
            InitIFFasDOS(iffhandle);
            if (SetAndGet(ifferror, OpenIFF(iffhandle, IFFF_READ)) = 0) then
            begin
              PropChunk(iffhandle, ID_PREF, ID_PRHD);

              PropChunk(iffhandle, ID_PREF, ID_FONT);
              PropChunk(iffhandle, ID_PREF, ID_ICTL);
              PropChunk(iffhandle, ID_PREF, ID_INPT);
              PropChunk(iffhandle, ID_PREF, ID_OSCN);
              PropChunk(iffhandle, ID_PREF, ID_PGFX);
              PropChunk(iffhandle, ID_PREF, ID_PTXT);
              PropChunk(iffhandle, ID_PREF, ID_SCRM);
              PropChunk(iffhandle, ID_PREF, ID_SERL);

              While true do
              begin
                ifferror := ParseIFF(iffhandle, IFFPARSE_STEP);

                if (ifferror = IFFERR_EOC)
                then continue
                else if (ifferror <> 0)
                     then break;

                {* Do nothing is this is a PrefHeader chunk,
                 * we'll pop it later when there is a pref
                 * chunk.
                 *}
                if SetAndTest(cnode, CurrentChunk(iffhandle)) 
                then  
                  if ((cnode^.cn_ID = ID_PRHD) or (cnode^.cn_ID = ID_FORM) )
                  then continue;

                //* Get the preferences header, stored previously */
                hdrsp := FindProp(iffhandle, ID_PREF, ID_PRHD);

                if SetAndTest(sp, FindProp(iffhandle, ID_PREF, ID_FONT)) then
                begin
                  WriteLn(Format('FrontPen:  %d', [ PFontPrefs(sp^.sp_Data)^.fp_FrontPen ]));
                  WriteLn(Format('BackPen:   %d', [ PFontPrefs(sp^.sp_Data)^.fp_BackPen ]));
                  WriteLn(Format('DrawMode:  %d', [ PFontPrefs(sp^.sp_Data)^.fp_DrawMode ]));
                  WriteLn(Format('Font:      %s', [ PFontPrefs(sp^.sp_Data)^.fp_Name ]));
                  WriteLn(Format('ta_YSize:  %d', [ PFontPrefs(sp^.sp_Data)^.fp_TextAttr.ta_YSize ]));
                  WriteLn(Format('ta_Style:  %d', [ PFontPrefs(sp^.sp_Data)^.fp_TextAttr.ta_Style ]));
                  WriteLn(Format('ta_Flags:  %d', [ PFontPrefs(sp^.sp_Data)^.fp_TextAttr.ta_Flags ]));
                end 
                else
                if SetAndTest(sp, FindProp(iffhandle, ID_PREF, ID_ICTL)) then
                begin
                  WriteLn(Format('TimeOut:     %d', [ PIControlPrefs(sp^.sp_Data)^.ic_TimeOut ]));
                  WriteLn(Format('MetaDrag:    %d', [ PIControlPrefs(sp^.sp_Data)^.ic_MetaDrag ]));
                  WriteLn(Format('WBtoFront:   %d', [ PIControlPrefs(sp^.sp_Data)^.ic_WBtoFront ]));
                  WriteLn(Format('FrontToBack: %d', [ PIControlPrefs(sp^.sp_Data)^.ic_FrontToBack ]));
                  WriteLn(Format('ReqTrue:     %d', [ PIControlPrefs(sp^.sp_Data)^.ic_ReqTrue ]));
                  WriteLn(Format('ReqFalse:    %d', [ PIControlPrefs(sp^.sp_Data)^.ic_ReqFalse ]));
                  //* etc */
                end 
                else 
                if SetAndTest(sp, FindProp(iffhandle, ID_PREF, ID_INPT)) then
                begin
                  WriteLn(Format('PointerTicks:      %d', [ PInputPrefs(sp^.sp_Data)^.ip_PointerTicks ]));
                  WriteLn(Format('DoubleClick/Secs:  %d', [ PInputPrefs(sp^.sp_Data)^.ip_DoubleClick.tv_secs ]));
                  WriteLn(Format('DoubleClick/Micro: %d', [ PInputPrefs(sp^.sp_Data)^.ip_DoubleClick.tv_micro ]));
                  //* etc */
                end
                else 
                if SetAndTest(sp, FindProp(iffhandle, ID_PREF, ID_OSCN)) then
                begin
                  WriteLn(Format('DisplayID:  0x%x', [ POverscanPrefs(sp^.sp_Data)^.os_DisplayID ]));
                  //* etc */
                end
                else 
                if SetAndTest(sp, FindProp(iffhandle, ID_PREF, ID_PGFX)) then
                begin
                  WriteLn(Format('Aspect:     %d', [ PPrinterGfxPrefs(sp^.sp_Data)^.pg_Aspect ]));
                  //* etc */
                end
                else 
                if SetAndTest(sp, FindProp(iffhandle, ID_PREF, ID_PTXT)) then
                begin
                  WriteLn(Format('Driver:     %s', [ PPrinterTxtPrefs(sp^.sp_Data)^.pt_Driver ]));
                  //* etc */
                end
                else 
                if SetAndTest(sp, FindProp(iffhandle, ID_PREF, ID_SCRM)) then
                begin
                  WriteLn(Format('DisplayID:  0x%x', [ PScreenModePrefs(sp^.sp_Data)^.smp_DisplayID ]));
                  //* etc */
                end 
                else 
                if SetAndTest(sp, FindProp(iffhandle, ID_PREF, ID_SERL)) then
                begin
                  WriteLn(Format('BaudRate:   %d', [ PSerialPrefs(sp^.sp_Data)^.sp_BaudRate ]));
                  //* etc */
                end;
              end;

              CloseIFF(iffhandle);
            end;

            if (ifferror <> IFFERR_EOF) then
            begin
              rargs[1] := LongInt(IFFErrTxt[-ifferror - 1]);
              VFPrintf(DOSOutput, '%s: %s' + LineEnding, @rargs);
              rc := RETURN_FAIL;
            end;
            {$IFDEF AROS}
            DOSClose(Pointer(iffhandle^.iff_Stream));
            {$ENDIF}
            {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
            DOSClose(iffhandle^.iff_Stream);
            {$ENDIF}
          end
          else error := IoErr();

          FreeIFF(iffhandle);
        end
        else
        begin
          VFPrintf(DOSOutput, 'Can''t allocate IFF handle' + LineEnding, nil);
          rc := RETURN_FAIL;
        end;
      end
      else error := IoErr();

      CloseLibrary(IFFParseBase);

      SetIoErr(error);
      if (error <> 0) then
      begin
        rc := RETURN_FAIL;
        If Assigned(filename) 
        then PrintFault(error, filename)
        else PrintFault(error, '');
      end;
    end;

    if Assigned(rdargs) then FreeArgs(rdargs);
    {$IFNDEF HASAMIGA}
    CloseLibrary(DOSBase);
    {$ENDIF}
  end
  else
  begin
    rc := RETURN_FAIL;
    DOSWrite(DOSOutput, PChar('Kickstart 2.0 required' + LineEnding), 23);
  end;

  result := (rc);
end;


begin
  ExitCode := Main;
end.
