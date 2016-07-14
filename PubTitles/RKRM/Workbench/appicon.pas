program appicon;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : appicon
  Source    : RKRM
}
 {
 * The example listed here shows how to create an AppIcon and obtain
 * arguments from Workbench when the user drops other icons on top of
 * it. The AppIcon will appear as a disk icon named "TestAppIcon" on the
 * Workbench screen.  (All AppIcons appear on the Workbench screen or
 * window.)
 *
 * For convenience, this example code uses GetDefDiskObject() to create
 * the icon imagery for the AppIcon.  Applications should never do this.
 * Use your own custom imagery for AppIcons instead.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, Workbench, Icon,
  CHelpers,
  Trinity;


procedure Main(argc: integer; argv: PPChar);
var
  dobj      : PDiskObject   = nil;
  myport    : PMsgPort      = nil;
  appicon   : PAppIcon      = nil;
  appmsg    : PAppMessage   = nil;

  dropcount : LONG          = 0;
  x         : ULONG;
  success   : Boolean       = false;
begin

  //* Get the the right version of the Icon Library, initialize IconBase */
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if SetAndTest(IconBase, OpenLibrary('icon.library', 37)) then
  {$ENDIF}
  begin
    //* Get the the right version of the Workbench Library */
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    if SetAndTest(WorkbenchBase, OpenLibrary('workbench.library', 37)) then
    {$ENDIF}
    begin
      //* This is the easy way to get some icon imagery */
      //* Real applications should use custom imagery   */
      dobj := GetDefDiskObject(WBDISK);
      if (dobj <> nil) then
      begin
        //* The type must be set to NULL for a WBAPPICON */
        dobj^.do_Type := 0;

        //* The CreateMsgPort() function is in Exec version 37 and later only */
        myport := CreateMsgPort();
        if Assigned(myport) then
        begin
          //* Put the AppIcon up on the Workbench window */
          appicon := AddAppIconA(0, 0, 'TestAppIcon', myport, default(BPTR), dobj, nil);
          if assigned(appicon) then
          begin
            //* For the sake of this example, we allow the AppIcon */
            //* to be activated only five times.                   */
            WriteLn('Drop files on the Workbench AppIcon');
            WriteLn('Example exits after 5 drops');

            while (dropcount < 5) do
            begin
              //* Here's the main event loop where we wait for */
              //* messages to show up from the AppIcon         */
              WaitPort(myport);

              //* Might be more than one message at the port... */
              while SetAndTest(appmsg, PAppMessage(GetMsg(myport))) do
              begin
                if (appmsg^.am_NumArgs = 0) then
                begin
                  //* If NumArgs is 0 the AppIcon was activated directly */
                  WriteLn('User activated the AppIcon.');
                  WriteLn('A Help window for the user would be good here');
                end
                else if (appmsg^.am_NumArgs > 0) then
                begin
                  //* If NumArgs is >0 the AppIcon was activated by */
                  //* having one or more icons dropped on top of it */
                  WriteLn('User dropped ', appmsg^.am_NumArgs, ' icons on the AppIcon');
                  // FPC Note:
                  // am_arglist is declared as an array starting with index 1
                  // (one), so in FPC there is no need for correction like in c
                  // but we do have to start with x being 1 as start index 
                  // (instead of zero).
                  for x := 1 to appmsg^.am_NumArgs do
                  begin
                    WriteLn('#', x, ' name=', appmsg^.am_ArgList^[x].wa_Name);
                  end;
                end;
                //* Let Workbench know we're done with the message */
                ReplyMsg(PMessage(appmsg));
              end;
              inc(dropcount);
            end;
            success := RemoveAppIcon(appicon);
          end;
          //* Clear away any messages that arrived at the last moment */
          while SetAndTest(appmsg, PAppMessage(GetMsg(myport))) 
            do ReplyMsg(PMessage(appmsg));
          DeleteMsgPort(myport);
        end;
        FreeDiskObject(dobj);
      end;
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}      
      CloseLibrary(WorkbenchBase);
      {$ENDIF}
    end;
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    CloseLibrary(IconBase);
    {$ENDIF}
  end;
end;


begin
  {$IFDEF AROS}
  WriteLn('INFO: This example does not work for the AROS platform.');
  WriteLn;
  WriteLn('Reason is that this application is waiting for items to be dropped ');
  Writeln('on its appicon, but never seems to receive a drop message.         ');
  WriteLn;
  Writeln('< Press enter to continue >');
  ReadLn;
  {$ENDIF}
  Main(ArgC, ArgV);
end.
