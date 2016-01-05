program eventloop;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : eventloop
  Source    : RKRM
}
 {*
 ** This example shows how to receive Intuition events.  It reports on a
 ** variety of events: close window, keyboard, disk insertion and removal,
 ** select button up and down and menu button up and down.  Note that the
 ** menu button events will only be received by the program if the
 ** WA_RMBTrap attribute is set for the window.
 *}
 

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

//* Force use of new variable names to help prevent errors  */
{$DEFINE INTUI_V36_NAMES_ONLY}

Uses
  Exec, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  Trinity,
  CHelpers;


{$IFDEF AMIGA}
var
  IntuitionBase : PLibrary absolute _Intuitionbase;
{$ENDIF}


  //* our function prototypes */
  function  handleIDCMP(win: PWindow; done: Boolean): boolean; forward;


{*
** main routine.
** Open required library and window, then process the events from the
** window.  Free all resources when done.
*}
procedure Main(argc: integer; argv: PPChar);
var
  signals   : ULONG;
  done      : Boolean;
  win       : PWindow;
begin
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  {$ENDIF}
  if (IntuitionBase <> nil) then
  begin
    if SetAndTest(win, OpenWindowTags(nil,
    [
      TAG_(WA_Title)        , TAG_(PChar('Press Keys and Mouse in this Window')),
      TAG_(WA_Width)        , 500,
      TAG_(WA_Height)       , 50,
      TAG_(WA_Activate)     , TAG_(TRUE),
      TAG_(WA_CloseGadget)  , TAG_(TRUE),
      TAG_(WA_RMBTrap)      , TAG_(TRUE),
      TAG_(WA_IDCMP)        , IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_RAWKEY or IDCMP_DISKINSERTED or IDCMP_DISKREMOVED or IDCMP_MOUSEBUTTONS,
      TAG_END
    ])) then
    begin
      done := FALSE;

      {* perform this loop until the message handling routine signals
      ** that we are done.
      **
      ** When the Wait() returns, check which signal hit and process
      ** the correct port.  There is only one port here, so the test
      ** could be eliminated.  If multiple ports were being watched,
      ** the test would become:
      **
      **    signals = Wait( (1L << win1->UserPort->mp_SigBit) |
      **                    (1L << win2->UserPort->mp_SigBit) |
      **                    (1L << win3->UserPort->mp_SigBit))
      **    if (signals & (1L << win1->UserPort->mp_SigBit))
      **        done = handleWin1IDCMP(win1,done);
      **    else if (signals & (1L << win2->UserPort->mp_SigBit))
      **        done = handleWin2IDCMP(win2,done);
      **    else if (signals & (1L << win3->UserPort->mp_SigBit))
      **        done = handleWin3IDCMP(win3,done);
      **
      ** Note that these could all call the same routine with different
      ** window pointers (if the handling was identical).
      **
      ** handleIDCMP() should remove all of the messages from the port.
      *}
      while not(done) do
      begin
        signals := Wait(1 shl win^.UserPort^.mp_SigBit);
        if (signals and (1 shl win^.UserPort^.mp_SigBit) <> 0)
        then done := handleIDCMP(win, done);
      end;
      CloseWindow(win);
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


{*
** handleIDCMP() - handle all of the messages from an IDCMP.
*}
function  handleIDCMP(win: PWindow; done: Boolean): boolean;
var
  imessage  : PIntuiMessage = nil;  // FPC Note: message is a reserved word
  code      : Word;
  mousex, 
  mousey    : Integer;
  iclass    : ULONG;                // FPC Note; calss is a reserved word
begin
  {* Remove all of the messages from the port by calling GetMsg()
  ** until it returns NULL.
  **
  ** The code should be able to handle three cases:
  **
  ** 1.  No messages waiting at the port, and the first call to GetMsg()
  ** returns NULL.  In this case the code should do nothing.
  **
  ** 2.  A single message waiting.  The code should remove the message,
  ** processes it, and finish.
  **
  ** 3.  Multiple messages waiting.  The code should process each waiting
  ** message, and finish.
  *}
  while (nil <> SetAndGet(imessage, PIntuiMessage(GetMsg(win^.UserPort)))) do
  begin
    {* It is often convenient to copy the data out of the message.
    ** In many cases, this lets the application reply to the message
    ** quickly.  Copying the data is not required, if the code does
    ** not reply to the message until the end of the loop, then
    ** it may directly reference the message information anywhere
    ** before the reply.
    *}
    iclass := imessage^.IClass;
    code   := imessage^.Code;
    mousex := imessage^.MouseX;
    mousey := imessage^.MouseY;

    {* The loop should reply as soon as possible.  Note that the code
    ** may not reference data in the message after replying to the
    ** message.  Thus, the application should not reply to the message
    ** until it is done referencing information in it.
    **
    ** Be sure to reply to every message received with GetMsg().
    *}
    ReplyMsg(PMessage(imessage));

    //* The class contains the IDCMP type of the message. */
    case (iclass) of
      IDCMP_CLOSEWINDOW : done := TRUE;
      IDCMP_VANILLAKEY  : WriteLn('IDCMP_VANILLAKEY ', Chr(code));
      IDCMP_RAWKEY      : WriteLn('IDCMP_RAWKEY');
      IDCMP_DISKINSERTED: WriteLn('IDCMP_DISKINSERTED');
      IDCMP_DISKREMOVED : WriteLn('IDCMP_DISKREMOVED');
      IDCMP_MOUSEBUTTONS:
      begin
        {* the code often contains useful data, such as the ASCII
        ** value (for IDCMP_VANILLAKEY), or the type of button
        ** event here.
        *}
        case (code) of
          SELECTUP  : WriteLn('SELECTUP at ', mousex, ',', mousey);
          SELECTDOWN: WriteLn('SELECTDOWN at ', mousex, ',', mousey);
          MENUUP    : WriteLn('MENUUP');
          MENUDOWN  : WriteLn('MENUDOWN');
          else        WriteLn('UNKNOWN CODE');
        end;
      end;
      else                WriteLn('Unknown IDCMP message');;
    end;
  end;
  Result := (done);
end;


begin
  Main(ArgC, ArgV);
end.
