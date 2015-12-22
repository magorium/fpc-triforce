program appwindow;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : appwindow
  Source    : RKRM
}
 {
 * This example shows how to create an AppWindow and obtain arguments
 * from Workbench when the user drops an icon into it.  The AppWindow
 * will appear on the Workbench screen with the name "AppWindow" and
 * will run until the window's close gadget is selected.  If any icons
 * are dropped into the AppWindow, the program prints their arguments in
 * the Shell window.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, Workbench, intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


procedure Main(argc: integer; argv: PPChar);
var
  awport    : PMsgPort;
  win       : pWindow;
  appwin    : PAppWindow;
  imsg      : PIntuiMessage;
  amsg      : PAppMessage;
  argptr    : PWBArgList;

  winsig, 
  appwinsig, 
  signals   : ULONG;
  id        : ULONG = 1;
  userdata  : ULONG = 0;
  
  done      : Boolean = false;
  i         : Integer;
begin
  {$IFDEF MORPHOS}
  if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
  {$ENDIF}
  begin
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    if SetAndTest(WorkbenchBase, OpenLibrary('workbench.library', 37)) then
    {$ENDIF}
    begin
      //* The CreateMsgPort() function is in Exec version 37 and later only */
      if SetAndTest(awport, CreateMsgPort) then
      begin
        if SetAndTest(win, OpenWindowTags(nil,
        [
          TAG_(WA_Width)  , 200,        
          TAG_(WA_Height) , 50,
          TAG_(WA_IDCMP)  , IDCMP_CLOSEWINDOW,
          TAG_(WA_Flags)  , WFLG_CLOSEGADGET or WFLG_DRAGBAR,
          TAG_(WA_Title)  , TAG_(PChar('AppWindow')),
          TAG_DONE
        ])) then
        begin
          if SetAndTest(appwin, AddAppWindowA(id, userdata, win, awport, nil)) then
          begin
            WriteLn('AppWindow added... Drag files into AppWindow');
            winsig    := 1 shl win^.UserPort^.mp_SigBit;
            appwinsig := 1 shl awport^.mp_SigBit;

            while not (done) do
            begin
              //* Wait for IDCMP messages and AppMessages */
              signals := Wait( winsig or appwinsig );

              if (signals and winsig) <> 0 then     //* Got an IDCMP message */
              begin
                while SetAndTest(imsg, PIntuiMessage(GetMsg(win^.UserPort))) do
                begin
                  if (imsg^.IClass = IDCMP_CLOSEWINDOW) then done := True;
                  ReplyMsg(PMessage(imsg));
                end;
              end;
              if (signals and appwinsig) <> 0 then  //* Got an AppMessage */
              begin
                while SetAndTest(amsg, PAppMessage(GetMsg(awport))) do
                begin
                  WriteLn('AppMsg: Type=', amsg^.am_Type, ', ID=', amsg^.am_ID, ', NumArgs=', amsg^.am_NumArgs);
                  argptr := amsg^.am_ArgList;

                  for i := 1 to amsg^.am_NumArgs do
                  begin
                    WriteLn('   arg(', i , '): Name="', argptr^[i].wa_Name, '", Lock=', HexStr(LongWord(argptr^[i].wa_Lock), 8) );
                  end;

                  ReplyMsg(PMessage(amsg));
                end;
              end;
            end;     //* done */

            RemoveAppWindow(appwin);
          end;
          CloseWindow(win);
	    end;
        //* Make sure there are no more outstanding messages */
        while SetAndTest(amsg, PAppMessage(GetMsg(awport)))
           do ReplyMsg(PMessage(amsg));
        DeleteMsgPort(awport);
      end;
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      CloseLibrary(WorkbenchBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
