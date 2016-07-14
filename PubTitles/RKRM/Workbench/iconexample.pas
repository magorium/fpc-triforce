program iconexample;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : iconexample               
  Topic     : Workbench icon startup, creation, and parsing example
  Source    : RKRM
  Note      : Source adjusted to match FPC and updated tagnames to be able to
              compile for 3.x.
}

 {
 ** The following example demonstrates icon creation, icon reading and
 ** Tool Type parsing in the Workbench environment.  When called from the
 ** Shell, the example creates a small data file in RAM: and creates or
 ** updates a project icon for the data file.  The created project icon
 ** points to this example as its default tool.  When the new project
 ** icon is double-clicked, Workbench will invoke the default tool (this
 ** example) as a Workbench process, and pass it a description of the
 ** project data file as a Workbench argument (WBArg) in the WBStartup
 ** message.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDOS, Workbench, Icon, intuition,
  SysUtils,
  CHelpers;


Const
  projname      : PChar = 'RAM:Example_Project';
  conwinname    : PChar = 'CON:10/10/620/180/iconexample';

  deftoolname   = 'iconexample';

const
  IconImageData1 : Array[0..Pred(8*11*2)] of Word =
  (
    //* Plane 0 */
    $0000,$0000,$0000,$1000,$0000,$0000,$0000,$3000,
    $0FFF,$FFFC,$0000,$3000,$0800,$0004,$0000,$3000,
    $0800,$07FF,$FFC0,$3000,$08A8,$A400,$00A0,$3000,
    $0800,$0400,$0090,$3000,$08AA,$A400,$0088,$3000,
    $0800,$042A,$A0FC,$3000,$082A,$A400,$0002,$3000,
    $0800,$0400,$0002,$3000,$0800,$A42A,$A0A2,$3000,
    $0800,$0400,$0002,$3000,$0950,$A42A,$8AA2,$3000,
    $0800,$0400,$0002,$3000,$082A,$A400,$0002,$3000,
    $0800,$042A,$2AA2,$3000,$0FFF,$FC00,$0002,$3000,
    $0000,$0400,$0002,$3000,$0000,$07FF,$FFFE,$3000,
    $0000,$0000,$0000,$3000,$7FFF,$FFFF,$FFFF,$F000,
    //* Plane 1 */
    $FFFF,$FFFF,$FFFF,$E000,$D555,$5555,$5555,$4000,
    $D000,$0001,$5555,$4000,$D7FF,$FFF9,$5555,$4000,
    $D7FF,$F800,$0015,$4000,$D757,$5BFF,$FF55,$4000,
    $D7FF,$FBFF,$FF65,$4000,$D755,$5BFF,$FF75,$4000,
    $D7FF,$FBD5,$5F01,$4000,$D7D5,$5BFF,$FFFD,$4000,
    $D7FF,$FBFF,$FFFD,$4000,$D7FF,$5BD5,$5F5D,$4000,
    $D7FF,$FBFF,$FFFD,$4000,$D6AF,$5BD5,$755D,$4000,
    $D7FF,$FBFF,$FFFD,$4000,$D7D5,$5BFF,$FFFD,$4000,
    $D7FF,$FBD5,$D55D,$4000,$D000,$03FF,$FFFD,$4000,
    $D555,$53FF,$FFFD,$4000,$D555,$5000,$0001,$4000,
    $D555,$5555,$5555,$4000,$8000,$0000,$0000,$0000
  );

  iconimage1: TImage =
  (
    LeftEdge    :  0;   //* Top Corner *
    TopEdge     :  0;
    Width       : 52;   //* Width, Height, Depth */
    Height      : 22;
    Depth       :  2;
    ImageData   : @IconImageData1[0];
    PlanePick   : $003; //* PlanePick,PlaneOnOff */
    PlaneOnOff  : $000;
    NextImage   : nil  //* Next Image */
  );

  toolTypes     : Array[0..2] of PChar =
  (
    'FILETYPE=text',
    'FLAGS=BOLD|ITALICS',
    nil
  );

  projIcon      : TDiskObject =
  (
    do_Magic        : WB_DISKMAGIC;                 //* Magic Number */
    do_Version      : WB_DISKVERSION;               //* Version */
    do_Gadget       :                               //* Embedded Gadget Structure */
    (                             
      NextGadget    : nil;                          //* Next Gadget Pointer */
      LeftEdge      : 97;                           //* Left,Top,Width,Height */
      TopEdge       : 12;
      Width         : 52;
      Height        : 23;
      Flags         : GFLG_GADGIMAGE or GFLG_GADGHBOX;  //* Flags */
      Activation    : GACT_IMMEDIATE or GACT_RELVERIFY; //* Activation Flags */
      GadgetType    : GTYP_BOOLGADGET;              //* Gadget Type */
      GadgetRender  : APTR(@iconImage1);            //* Render Image */
      SelectRender  : nil;                          //* Select Image */
      GadgetText    : nil;                          //* Gadget Text */
      MutualExclude : 0;                            //* Mutual Exclude */
      SpecialInfo   : nil;                          //* Special Info */
      GadgetID      : 0;                            //* Gadget ID */
      UserData      : nil;                          //* User Data */
    );
    do_Type         : WBPROJECT;                    //* Icon Type */
    do_DefaultTool  : deftoolname;                  //* Default Tool */
    do_ToolTypes    : @toolTypes;                   //* Tool Type Array */
    do_CurrentX     : LONG(NO_ICON_POSITION);       //* Current X */
    do_CurrentY     : LONG(NO_ICON_POSITION);       //* Current Y */
    do_DrawerData   : nil;                          //* Drawer Structure */
    do_ToolWindow   : nil;                          //* Tool Window */
    do_StackSize    : 4000                          //* Stack Size */
  );

var
  //* Opens and allocations we must clean up */
  conwin    : TextFile;
  olddir    : BPTR = BPTR(-1);

  FromWb    : Boolean;

  //* our functions */
  procedure cleanexit(s: PChar; n: LONG); forward;
  procedure cleanup; forward;
  procedure message(s: PChar); forward;
  function  makeIcon(name: PChar; newtooltypes: PPChar; newdeftool: PChar): Boolean; forward;
  function  showToolTypes(wbArg: PWBArg): Boolean; forward;


procedure Main(argc: integer; argv: PPChar);
var
  WBenchMsg     : PWBStartup;
  wbarg         : PWBArg;
  afile         : THandle;
  wLen          : LONG;
  i             : SmallInt;
  S             : String;
begin
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  FromWB := (AOS_WbMsg <> nil);
  {$ENDIF}
  {$IFDEF MORPHOS}
  FromWB := (argc = 0);
  {$ENDIF}

  //* Open icon.library */
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if Not SetAndTest(IconBase, OpenLibrary('icon.library', 33)) 
  then cleanexit('Can''t open icon.library', RETURN_FAIL);
  {$ENDIF}
  {* If started from CLI, this example will create a small text
   * file RAM:Example_Project, and create an icon for the file
   * which points to this program as its default tool.
   *}
  if not(FromWb) then
  begin
    //* Make a sample project (data) file */
    wLen := -1;
    
    if (SetAndGet(afile, FileCreate(projname)) <> -1)  then
    begin
      s := 'Have a nice day';
      wLen := FileWrite(afile, s[1], Length(s));
      FileClose(afile);
    end;

    if (wLen < 0) then cleanexit('Error writing data file' + LineEnding, RETURN_FAIL);

    //* Now save/update icon for this data file */
    if ( makeIcon(projname, toolTypes, deftoolname) ) then
    begin
      WriteLn(Format('%s data file and icon saved.', [projname]));
      WriteLn('Use Workbench menu Icon Information to examine the icon.');
      WriteLn('Then copy this example (iconexample) to RAM:');
      WriteLn(Format('and double-click the %s project icon', [projname]));
    end
    else cleanexit('Error writing icon' + LineEnding, RETURN_FAIL);
  end
  else  {* Else we are FromWb - ie. we were either
         * started by a tool icon, or as in this case,
         * by being the default tool of a project icon.
         *}
  begin
    // FPC Note:
    // Free Pascal provides an output window for us, even when running from 
    // wb. Therefor the manual opening of a console window has been replaced
    // with pointing variable conwin to standard output handle.
    ConWin := StdOut;

    {$IF DEFINED(AMIGA) or DEFINED(AROS)}
    WBenchMsg := AOS_WbMsg;
    {$ENDIF}
    {$IFDEF MORPHOS}
    WBenchMsg := PWBStartUp(argv);
    {$ENDIF}

    {* Note wbarg++ at end of FOR statement steps through wbargs.
     * First arg is our executable (tool).  Any additional args
     * are projects/icons passed to us via either extend select
     * or default tool method.
     *}
    i := 0;
    wbarg := PWBArg(WBenchMsg^.sm_ArgList);
    while (i < WBenchMsg^.sm_NumArgs) do
    begin
      //* if there's a directory lock for this wbarg, CD there */
      olddir := BPTR(-1);
      if ( (wbarg^.wa_Lock <> default(BPTR)) and (wbarg^.wa_Name^ <> #0) )
      then olddir := CurrentDir(wbarg^.wa_Lock);

      showToolTypes(wbarg);

      if ( (i > 0) and (wbarg^.wa_Name^ <> #0))
      then WriteLn(conwin, Format('In Main. We could open the %s file here', [wbarg^.wa_Name]));

      if (olddir <> BPTR(-1)) then CurrentDir(olddir);    //* CD back where we were */

      inc(i);
      Inc(wbarg);
    end;
    DOSDelay(500);
  end;
  cleanup;
  Halt(RETURN_OK);
end;


function  makeIcon(name: PChar; newtooltypes: PPChar; newdeftool: PChar): Boolean;
var
  dobj          : PDiskObject;
  olddeftool    : PChar;
  oldtooltypes  : PPChar;
  success       : WordBool = FALSE;
begin
  if SetAndTest(dobj, GetDiskObject(name)) then
  begin
    {* If file already has an icon, we will save off any fields we
     * need to update, update those fields, put the object, restore
     * the old field pointers and then free the object.  This will
     * preserve any custom imagery the user has, and the user's
     * current placement of the icon.  If your application does
     * not know where the user currently keeps your application,
     * you should not update his dobj->do_DefaultTool.
     *}
    oldtooltypes := dobj^.do_ToolTypes;
    olddeftool := dobj^.do_DefaultTool;

    dobj^.do_ToolTypes := newtooltypes;
    dobj^.do_DefaultTool := newdeftool;

    success := LongBool(PutDiskObject(name, dobj));

    //* we must restore the original pointers before freeing */
    dobj^.do_ToolTypes := oldtooltypes;
    dobj^.do_DefaultTool := olddeftool;
    FreeDiskObject(dobj);
  end;
  //* Else, put our default icon */
  if not(success) then success := LongBool(PutDiskObject(name, @projIcon));
  result := (success);
end;


function  showToolTypes(wbArg: PWBArg): Boolean;
var
  dobj      : PDiskObject;
  toolarray : PPChar;
  s         : PChar;
  success   : Boolean = FALSE;
begin
  WriteLn(conwin, LineEnding, Format('WBArg Lock=0x%p, Name=%s', 
                            [Pointer(wbarg^.wa_Lock), wbarg^.wa_Name]));

  if ((wbarg^.wa_Name^ <> #0) and SetAndTest(dobj, GetDiskObject(wbarg^.wa_Name))) then
  begin
    WriteLn(conwin, '  We have read the DiskObject (icon) for this arg');
    toolarray := PPChar(dobj^.do_ToolTypes);

    if SetAndTest(s, PChar( FindToolType(toolarray, 'FILETYPE'))) then
    begin
      WriteLn(conwin, Format('    Found tooltype FILETYPE with value %s', [s]));
    end;
    if SetAndTest(s, PChar(FindToolType(toolarray, 'FLAGS'))) then
    begin
      WriteLn(conwin, Format('    Found tooltype FLAGS with value %s', [s]));

      if LongBool(MatchToolValue(s, 'BOLD'))
      then WriteLn(conwin, '      BOLD flag requested');

      if LongBool(MatchToolValue(s, 'ITALICS'))
      then WriteLn(conwin, '      ITALICS flag requested');
    end;
    //* Free the diskobject we got */
    FreeDiskObject(dobj);
    success := TRUE;
  end
  else if (not(wbarg^.wa_Name <> #0))
  then WriteLn(conwin, '  Must be a disk or drawer icon')
  else
    WriteLn(conwin, '  Can''t find any DiskObject (icon) for this WBArg');
  Result := (success);
end;


{* Workbench-started programs with no output window may want to display
 * messages in a different manner (requester, window title, etc)
 *}
procedure message(s: PChar);
begin
  // FPC Note:
  // Because we do not have a (real) conwin, this code slightly differs from 
  // the original c to accomodate FPC situation
  if FromWb then Write(conwin, s)
  else if not(FromWb) then Write(s);
end;


procedure cleanexit(s: PChar; n: LONG);
begin
  if Assigned(s) and (s^ <> #0) then message(s);
  cleanup;
  Halt(n);
end;


procedure cleanup;
begin
  // FPC Note:
  // Because no conwindow being open, the code to close conwin is omitted.

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if Assigned(IconBase) then CloseLibrary(IconBase);
  {$ENDIF}
end;


{$IFDEF ENDIAN_LITTLE}
Var
  index : Integer;
{$ENDIF}

begin
  {$IFDEF ENDIAN_LITTLE}  
  // FPC Note: 
  // Image data is expected to be stored in Big Endian format, so accomodate
  // for those architectures that store data in memory differently
  For Index := Low(IconImageData1) to High(IconImageData1) 
    do IconImageData1[index] := Swap(IconImageData1[index]);
  {$ENDIF}
  Main(ArgC, ArgV);
end.
