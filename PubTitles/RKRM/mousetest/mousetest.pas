program mousetest;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : mousetest
  Topic     : Read position and button events from the mouse.
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{ $DEFINE INTUI_V36_NAMES_ONLY}
Uses
  Exec, AGraphics, Intuition, InputEvent, utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  SysUtils,
  Math,
  CHelpers,
  Trinity;


Var
  GfxBase   : PGfxBase absolute AGraphics.GfxBase;

type
  {* something to use to track the time between messages
  ** to test for double-clicks.
  *}
  PMyTimeVal = ^TMyTImeVal;
  TMyTimeVal = record
    LeftSeconds  : ULONG;
    LeftMicros   : ULONG;
    RightSeconds : ULONG;
    RightMicros  : ULONG;
  end;


  //* our function prototypes */
  procedure doButtons(msg: PIntuiMessage; tv: PMyTimeVal); forward;
  procedure process_window(win: PWindow); forward;


{*
** main() -- set-up everything.
*}
procedure Main(argc: Integer; argv: PPChar);
var
  win               : PWindow;
  scr               : PScreen;
  dr_info           : PDrawInfo;
  width             : ULONG;
begin
  {$IFDEF MORPHOS}
  //* Open the libraries we will use.  Requires Release 2 (KS V2.04, V37) */
  If SetAndTest(IntuitionBase, PIntuitionBase(OpenLibrary('intuition.library', 37))) then
  {$ENDIF}
  begin
    {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
    if SetAndTest(GfxBase, PGfxBase(OpenLibrary('graphics.library', 37))) then
    {$ENDIF}
    begin
      //* Lock the default public screen in order to read its DrawInfo data */
      if SetAndTest(scr, LockPubScreen(nil)) then
      begin
        if SetAndtest(dr_info, GetScreenDrawInfo(scr)) then
        begin
          {* use wider of space needed for output (18 chars and spaces)
          * or titlebar text plus room for titlebar gads (approx 18 each)
          *}
          width := max((GfxBase^.DefaultFont^.tf_XSize * 18),
                       (18 * 2) + TextLength(@scr^.RastPort, 'MouseTest', 9));

          if SetAndTest(win, OpenWindowTags(nil,
          [
            TAG_(WA_Top)        ,    20,
            TAG_(WA_Left)       ,   100,
            TAG_(WA_InnerWidth) ,  width,
            TAG_(WA_Height)     , (2 * GfxBase^.DefaultFont^.tf_YSize) +
                                  scr^.WBorTop + scr^.Font^.ta_YSize + 1 +
                                  scr^.WBorBottom,
            TAG_(WA_Flags)      , WFLG_DEPTHGADGET or WFLG_CLOSEGADGET or WFLG_ACTIVATE or WFLG_REPORTMOUSE or WFLG_RMBTRAP or WFLG_DRAGBAR,
            TAG_(WA_IDCMP)      , IDCMP_CLOSEWINDOW or IDCMP_RAWKEY or IDCMP_MOUSEMOVE or IDCMP_MOUSEBUTTONS,
            TAG_(WA_Title)      , TAG_(PChar('MouseTest')),
            TAG_(WA_PubScreen)  , TAG_(scr),
            TAG_END
          ])) then
          begin
            WriteLn('Monitors the Mouse:');
            WriteLn('    Move Mouse, Click and DoubleClick in Window');

            SetAPen(win^.RPort, PWORD(dr_info^.dri_Pens)[TEXTPEN]);
            SetBPen(win^.RPort, PWORD(dr_info^.dri_Pens)[BACKGROUNDPEN]);
            SetDrMd(win^.RPort, JAM2);

            process_window(win);

            CloseWindow(win);
          end;
          FreeScreenDrawInfo(scr, dr_info);
        end;
        UnlockPubScreen(nil, scr);
      end;
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      CloseLibrary(PLibrary(GfxBase));
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


{*
** process_window() - simple message loop for processing IntuiMessages
*}
procedure process_window(win: PWindow);
var
  done          : boolean;
  msg           : PIntuiMessage;
  tv            : TMyTimeVal;
  prt_buff      : String[14];
  xText, yText  : LONG;  //* places to position text in window. */
begin
  done := FALSE;
  tv.LeftSeconds := 0;  //* initial values for testing double-click */
  tv.LeftMicros  := 0;
  tv.RightSeconds := 0;
  tv.RightMicros  := 0;
  xText := win^.BorderLeft + (win^.IFont^.tf_XSize * 2);
  yText := win^.BorderTop + 3 + win^.IFont^.tf_Baseline;

  while not(done) do
  begin
    Wait((1 shl win^.UserPort^.mp_SigBit));

    while ( not(done) and SetAndTest(msg, PIntuiMessage(GetMsg(win^.UserPort)))) do
    begin
      case (msg^.IClass) of
        IDCMP_CLOSEWINDOW:
        begin
          done := TRUE;
        end;
        
        {* NOTE NOTE NOTE:  If the mouse queue backs up a lot, Intuition
        ** will start dropping MOUSEMOVE messages off the end until the
        ** queue is serviced.  This may cause the program to lose some
        ** of the MOUSEMOVE events at the end of the stream.
        **
        ** Look in the window structure if you need the true position
        ** of the mouse pointer at any given time.  Look in the
        ** MOUSEBUTTONS message if you need position when it clicked.
        ** An alternate to this processing would be to set a flag that
        ** a mousemove event arrived, then print the position of the
        ** mouse outside of the "while (GetMsg())" loop.  This allows
        ** a single processing call for many mouse events, which speeds
        ** up processing A LOT!  Something like:
        **
        ** while (GetMsg()) do
        ** begin
        **    if (class = IDCMP_MOUSEMOVE)
        **    then mouse_flag := TRUE;
        **    ReplyMsg();   // NOTE: copy out all needed fields first !
        ** end;
        ** if (mouse_flag) then
        ** begin
        **    process_mouse_event();
        **    mouse_flag := FALSE;
        ** end;
        **
        ** You can also use IDCMP_INTUITICKS for slower paced messages
        ** (all messages have mouse coordinates.)
        *}
        IDCMP_MOUSEMOVE:
        begin
          {* Show the current position of the mouse relative to the
          ** upper left hand corner of our window
          *}
          GfxMove(win^.RPort, xText, yText);
          System.WriteStr(prt_buff, Format('X%.5d Y%.5d'#0, [msg^.MouseX, msg^.MouseY]));
          GfxText(win^.RPort, @prt_buff[1], 13);
        end;
        IDCMP_MOUSEBUTTONS:
        begin
          doButtons(msg, @tv);
        end;
      end;
      ReplyMsg(PMessage(msg));
    end;
  end;
end;


{*
** Show what mouse buttons where pushed
*}
procedure doButtons(msg: PIntuiMessage; tv: PMyTimeVal);
begin
  {* Yes, qualifiers can apply to the mouse also.  That is how
  ** we get the shift select on the Workbench.  This shows how
  ** to see if a specific bit is set within the qualifier
  *}
  if (msg^.Qualifier and (IEQUALIFIER_LSHIFT or IEQUALIFIER_RSHIFT) <> 0)
  then Write('Shift ');

  case (msg^.Code) of
    SELECTDOWN:
    begin
      Write(Format('Left Button Down at X%d Y%d', [msg^.MouseX, msg^.MouseY]));
      if (DoubleClick(tv^.LeftSeconds, tv^.LeftMicros, msg^.Seconds, msg^.Micros))
      then Write(' DoubleClick!')
      else
      begin
        tv^.LeftSeconds := msg^.Seconds;
        tv^.LeftMicros  := msg^.Micros;
        tv^.RightSeconds := 0;
        tv^.RightMicros  := 0;
      end;
    end;
    SELECTUP:
    begin
      Write(Format('Left Button Up   at X%d Y%d', [msg^.MouseX, msg^.MouseY]));
    end;
    MENUDOWN:
    begin
      Write(Format('Right Button down at X%d Y%d', [msg^.MouseX, msg^.MouseY]));
      if (DoubleClick(tv^.RightSeconds, tv^.RightMicros, msg^.Seconds, msg^.Micros))
      then Write(' DoubleClick!')
      else
      begin
        tv^.LeftSeconds := 0;
        tv^.LeftMicros  := 0;
        tv^.RightSeconds := msg^.Seconds;
        tv^.RightMicros  := msg^.Micros;
      end;
    end;
    MENUUP:
    begin
      Write(Format('Right Button Up   at X%d Y%d', [msg^.MouseX, msg^.MouseY]));
    end;
  end;
  WriteLn;
end;


begin
  Main(Argc, ArgV);
end.
