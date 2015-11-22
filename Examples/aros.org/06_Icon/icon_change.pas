program icon_change;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

{
  ===========================================================================
  Project : icon_change
  Topic   : Shows how to change ToolTypes
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/icon_change.c
  ===========================================================================

  This example was originally written in c by The AROS Development Team.

  The original examples are available online and published at the AROS
  website (http://www.aros.org/documentation/developers/samples.php)

  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc

  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Conversion from c to Free Pascal was done by Magorium in 2015.

  ===========================================================================

           Unless otherwise noted, these examples must be considered
                 copyrighted by their respective owner(s)

  ===========================================================================
}

{*
    Example for changing icon tooltypes.
*}



Uses
  Exec, AmigaDOS, Icon, Workbench,
  SysUtils;


Var
  conwinname    : STRPTR    = 'CON:30/50/500/400/Tooltype parsing/AUTO/CLOSE/WAIT';
  conwin        : TextFile;
  conwin_valid  : boolean;
  olddir        : BPTR      = BPTR(-1);
  dobj          : PDiskObject;
  oldtoolarray,
  newtoolarray  : ^STRPTR;


  procedure clean_exit(const s: STRPTR); forward;


function  main(argc: integer; argv: PPChar): Integer;
var
  wbmsg     : pWBStartup;
  wbarg     : pWBArg;
  toolarray : ^STRPTR;
  toolcnt   : LONG;
  idx       : LONG;
begin
  {$IFDEF MORPHOS}
  if (MOS_ambMsg = nil) then
  {$ELSE}  
  if (AOS_WBMsg = nil) then
  {$ENDIF}
  begin
    clean_exit('Application must be started from Wanderer.');
    //* See dos_readargs.c for start from Shell. */  
  end
  else
  begin
    {$IFDEF MORPHOS}
    wbmsg := MOS_ambMsg;
    {$ELSE}
    wbmsg := AOS_WBMsg;
    {$ENDIF}    

    wbarg := PWbArg(wbmsg^.sm_ArgList);
    toolcnt := 0;

    {*
        An application started from Wanderer doesn't have a console window
        for output. We have to open our own con: window or all output will
        go to Nirwana.
    *}
    AssignFile(conwin, conwinname);
    {$I-}
    Rewrite(conwin);
    {$I+}
    conwin_valid := (IOResult = 0);

    if not(conwin_valid) then
    begin
      clean_exit('Can''t open console window');
    end;

    if ( (wbarg^.wa_Lock <> default(BPTR)) and (wbarg^.wa_Name^ <> #0) ) then
    begin
      WriteLn(conwin, Format('Trying to open %s', [wbarg^.wa_Name]));

      //* We must enter the directory of the icon */
      olddir := CurrentDir(wbarg^.wa_Lock);
                
      dobj := GetDiskObject(wbarg^.wa_Name);
      if assigned(dobj) then
      begin
        oldtoolarray := dobj^.do_ToolTypes;
        
        //* Count entries */
        if assigned(oldtoolarray) then
        begin
          toolarray := oldtoolarray;
          while assigned(toolarray^) do
          begin
            inc(toolcnt);
            inc(toolarray);
          end;
        end;                

        WriteLn(conwin, Format('Old icon has %d tooltype entries', [toolcnt]));

        //* Create new toolarray */
        newtoolarray := AllocVec(sizeof(STRPTR) * (toolcnt + 3), MEMF_ANY);
        if not assigned(newtoolarray) then
        begin
          clean_exit('Can''t allocate memory for new toolarray');
        end;
        {*
            Add two new entries and copy the pointers to the
            old values. If w'd want to change the strings we'd
            have to work with copies of the strings.
        *}
        newtoolarray[0] := 'START';
        for idx := 0 to Pred(toolcnt) do
        begin
          newtoolarray[idx+1] := oldtoolarray[idx];
        end;
        newtoolarray[toolcnt + 1] := 'END';
        newtoolarray[toolcnt + 2] := nil;
                
        //* Change toolarray pointer and save icon. */
        dobj^.do_ToolTypes := newtoolarray;
        if not LongBool(PutDiskObject(wbarg^.wa_Name, dobj)) then
        begin
          clean_exit('Can''t write Diskobject');
        end;

      end
      else
      begin
        clean_exit('Can''t open DiskObject');
      end;
    end;
  end;
  
  clean_exit(nil);
  
  result := 0;
end;



procedure clean_exit(const s: STRPTR);
begin
  if assigned(s) then 
  begin
    if (conwin_valid) then
    begin
      WriteLn(conwin, Format('%s',[s]));
    end
    else
    begin
      WriteLn(s);
    end;
  end;

  // Give back allocated resources
  if (conwin_valid) then CloseFile(conwin);
  
  {*
      Free DiskObject. We have to set back the pointer to the toolarray or
      we'll get memory corruption.
  *}
  if assigned(dobj) then
  begin
     dobj^.do_ToolTypes := oldtoolarray;
     FreeDiskObject(dobj);
  end;
    
  FreeVec(newtoolarray);
    
  {*
      Switch back to old directory. It's important that the directory which
      was active at program start is set when the application is quit.
  *}
  if (olddir <> BPTR(-1)) then
  begin
    CurrentDir(olddir);
    olddir := BPTR(-1);
  end;
    
  Halt(0);
end;



{
  ===========================================================================
  Some additional code is required in order to open and close libraries in a 
  cross-platform uniform way.
  Since AROS units automatically opens and closes libraries, this code is 
  only actively used when compiling for Amiga and/or MorphOS.
  ===========================================================================
}



Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS)}
  IconBase := OpenLibrary(ICONNAME, 0);
  if not assigned(IconBase) then Exit;
  {$ENDIF}

  Result := True;
end;



Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS)}
  if assigned(IconBase) then CloseLibrary(pLibrary(IconBase));
  {$ENDIF}
end;



begin
  if OpenLibs
  then ExitCode := Main(Argc, Argv)
  else ExitCode := 10;

  CloseLibs;
end.
