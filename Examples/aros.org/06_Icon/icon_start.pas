program icon_start;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{
  ===========================================================================
  Project : icon_start
  Topic   : Reads ToolTypes from icons
  Author  : The AROS Development Team.
  Source  : http://www.aros.org/documentation/developers/samplecode/icon_start.c
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
    Example of starting from Wanderer with icon handling.
*}



Uses
  Exec, AmigaDOS, Icon, Workbench,
  SysUtils;


Var
  conwinname    : STRPTR    = 'CON:30/50/500/400/Tooltype parsing/AUTO/CLOSE/WAIT';
  conwin        : TextFile;
  conwin_valid  : boolean;
  olddir        : BPTR      = BPTR(-1);


  procedure read_icon(wbarg: pWBArg); forward;
  procedure clean_exit(const s: STRPTR); forward;


function  main(argc: integer; argv: PPChar): Integer;
var
  wbarg : pWBArg;
  wbmsg : pWBStartup;
  idx   : LONG;
begin
  {$IFDEF MORPHOS}
  if (argc <> 0) then
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
    wbmsg := pWBStartup(argv);
    {$ELSE}
    wbmsg := AOS_WBMsg;
    {$ENDIF}    

    {*
        An application started from Wanderer doesn't have a console window
        for output. We have to open our own con: window or all output will
        go to Nirwana.
    *}
    AssignFile(conwin, conwinname);
    {$I-}
    Rewrite(conwin);
    {$I+}
    conwin_valid := (IOResult <> 0);

    if (conwin_valid) then
    begin
      clean_exit('Can''t open console window');
    end;

    //* Loop trough all icons. The first one is the application itself. */
    wbarg := PWbArg(wbmsg^.sm_ArgList);

    for idx := 0 to Pred(wbmsg^.sm_numArgs) do
    begin
      if ( (wbarg^.wa_Lock <> default(BPTR)) and (wbarg^.wa_Name^ <> #0) ) then
      begin
        WriteLn(conwin, Format(LineEnding + '-------------------' + LineEnding + 'Name %s', [wbarg^.wa_Name]));

        //* We must enter the directory of the icon */
        olddir := CurrentDir(wbarg^.wa_Lock);
                
        read_icon(wbarg);
                
        {*
            Switch back to old directory. It's important that the
            directory which was active at program start is set when the
            application is quit.
        *}
        if (olddir <> BPTR(-1)) then
        begin
           CurrentDir(olddir);
           olddir := BPTR(-1);
        end;
      end;
      inc(wbarg);
    end;
  end;
  
  clean_exit(nil);
  
  result := 0;
end;


procedure read_icon(wbarg: PWBArg);
var
  dobj      : PDiskObject;
  toolarray : ^STRPTR;
  res       : STRPTR;
begin
  //* Let's read some tooltypes from the icon */
  dobj := GetDiskObject(wbarg^.wa_Name);
  if assigned(dobj) then
  begin
    toolarray := dobj^.do_ToolTypes;

    res := FindToolType(toolarray, 'PUBSCREEN');
    if assigned(res) then
    begin
      WriteLn(conwin, Format('PUBSCREEN: %s', [res]));
    end
    else
    begin
      WriteLn(conwin, 'Tooltype "PUBSCREEN" doesn''t exist');
    end;
        
    res := FindToolType(toolarray, 'COLOR');
    if assigned(res) then
    begin
      if LongBool(MatchToolValue(res, 'RED')) then
      begin
        WriteLn(conwin, 'Mode "RED" set');
      end;
      if LongBool(MatchToolValue(res, 'GREEN')) then
      begin
        WriteLn(conwin, 'Mode "GREEN" set');
      end;
      if LongBool(MatchToolValue(res, 'BLUE')) then
      begin
        WriteLn(conwin, 'Mode "BLUE" set');
      end;
    end
    else
    begin
      WriteLn(conwin, 'Tooltype "COLOR" doesn''t exist');
    end;
            
    FreeDiskObject(dobj);
  end
  else
  begin
    WriteLn(conwin, 'Can''t open DiskObject');
  end;
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
