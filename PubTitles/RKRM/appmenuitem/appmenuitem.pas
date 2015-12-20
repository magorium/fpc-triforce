program appmenuitem;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : appmenuitem
  Source    : RKRM
}
 {
 * This example shows how to create an AppMenuItem.  The example adds a
 * menu item named "Browse Files" to the Workbench Tools menu.  (All
 * AppMenuItems appear in the Workbench Tools menu.)  When the menu item
 * is activated, the example program receives a message from Workbench
 * and then attempts to start up an instance of the More program. (The
 * More program is in the Utilities directory of the Workbench disk.)
 *
 * The example starts up the More program as a separate, asynchronous
 * process using the new SystemTags() function of Release 2 AmigaDOS.
 * For more about the SystemTags() function refer to the AmigaDOS
 * Manual, 3rd Edition from Bantam Books.  When the AppMenuItem has been
 * activated five times, the program exits after freeing any system
 * resources it has used.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDOS, Workbench, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


procedure Main(argc: integer; argv: PPChar);
var
  myport    : PMsgPort      = nil;
  appitem   : PAppMenuItem  = nil;
  appmsg    : PAppMessage   = nil;

  x         : LONG = 0; 
  count     : Long = 0; 
  res       : LONG = 0;
  success   : Boolean       = false;
  afile     : BPTR;
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if SetAndTest(WorkbenchBase, OpenLibrary('workbench.library', 37)) then
  {$ENDIF}
  begin
    //* The CreateMsgPort() function is in Exec version 37 and later only */
    if SetAndTest(myport, CreateMsgPort) then
    begin
      //* Add our own AppMenuItem to the Workbench Tools Menu */
      appitem := AddAppMenuItemA
      (
        0,                                  //* Our ID# for item */
        ULONG(PChar('SYS:Utilities/More')), //* Our UserData     */
        PChar('Browse Files'),              //* MenuItem Text    */
        myport, nil                        //* MsgPort, no tags */
      );        

      if assigned(appitem) then
      begin
        WriteLn('Select Workbench Tools demo menuitem "Browse Files"');

        //* For this example, we allow the AppMenuItem to be selected */
        //* only once, then we remove it and exit                     */
        WaitPort(myport);
        while SetAndTest(appmsg, PAppMessage(GetMsg(myport))) and (count < 1) do
        begin
          //* Handle messages from the AppMenuItem - we have only one  */
          //* item so we don't have to check its appmsg->am_ID number. */
          //* We'll System() the command string that we passed as      */
          //* userdata when we added the menu item.                    */
          //* We find our userdata pointer in appmsg->am_UserData      */

          WriteLn('User picked AppMenuItem with ', appmsg^.am_NumArgs, ' icons selected');

          for x := 1 to appmsg^.am_NumArgs 
            do WriteLn('  #', x, ' name=', appmsg^.am_ArgList^[x].wa_Name);

          inc(count);

          if SetAndTest(afile, DOSOpen('CON:0/40/640/150/AppMenu Example/auto/close/wait',
                         MODE_OLDFILE)  ) then    //* for any stdio output */
          begin
            res := SystemTags(PChar(appmsg^.am_UserData),
            [
              TAG_(SYS_Input)   , TAG_(afile),
              TAG_(SYS_Output)  , TAG_(nil),
              TAG_(SYS_Asynch)  , TAG_(TRUE),
              TAG_DONE
            ]);
            ///* If Asynch System() itself fails, we must close file */
            if (res = -1) then DOSClose(afile);
          end;
          ReplyMsg(PMessage(appmsg));
        end;
        success := RemoveAppMenuItem(appitem);
      end;

      //* Clear away any messages that arrived at the last moment */
      //* and let Workbench know we're done with the messages     */
      while SetAndTest(appmsg, PAppMessage(GetMsg(myport))) do
      begin
        ReplyMsg(PMessage(appmsg));
      end;

      DeleteMsgPort(myport);
    end;
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}      
    CloseLibrary(WorkbenchBase);
    {$ENDIF}
  end;
end;


begin
  {$IFDEF AROS}
  WriteLn('INFO: This example does not work for the AROS platform.');
  WriteLn;
  WriteLn('Reason is that none f the current availble desktops support adding ');
  Writeln('tools to the workbench/desktop menu.                               ');
  WriteLn;
  Writeln('< Press enter to continue >');
  ReadLn;
  {$ENDIF}
  Main(ArgC, ArgV);
end.
