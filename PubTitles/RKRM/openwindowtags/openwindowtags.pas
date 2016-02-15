program openwindowtags;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : openwindowtags
  Topic     : open a window using tags.
  Source    : RKRM
}

  {*
  ** Here's an example showing how to open a new window using the
  ** OpenWindowTagList() function with window attributes set up
  ** in a TagItem array.
  *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}


{$DEFINE INTUI_V36_NAMES_ONLY}

Uses
  Exec, Intuition, Utility;


const
  MY_WIN_LEFT   = (20);
  MY_WIN_TOP    = (10);
  MY_WIN_WIDTH  = (300);
  MY_WIN_HEIGHT = (110);

var
  {$IFDEF AMIGA}
  IntuitionBase : PLibrary absolute _Intuitionbase;
  {$ENDIF}
  {$IFDEF AROS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  {$ENDIF}
  {$IFDEF MORPHOS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  {$ENDIF}


  win_tags      : Array[0..6] of TTagItem =
  (
    (ti_Tag : WA_Left;          ti_data : MY_WIN_LEFT),
    (ti_Tag : WA_Top;           ti_data : MY_WIN_TOP),
    (ti_Tag : WA_Width;         ti_data : MY_WIN_WIDTH),
    (ti_Tag : WA_Height;        ti_data : MY_WIN_HEIGHT),
    (ti_Tag : WA_CloseGadget;   ti_data : TAG(TRUE)),
    (ti_Tag : WA_IDCMP;         ti_data : IDCMP_CLOSEWINDOW),
    (ti_Tag : TAG_DONE;         ti_data : 0)
  );


  procedure handle_window_events(win: PWindow); forward;



{*
** Open a simple window using OpenWindowTagList()
*}
procedure Main(argc: integer; argv: PPChar);
var
  win   : PWindow;
begin
  {$IFDEF MORPHOS}
  //* these calls are only valid if we have Intuition version 37 or greater */
  IntuitionBase := OpenLibrary('intuition.library', 37);
  {$ENDIF}
  if (nil <> IntuitionBase) then
  begin
    win := OpenWindowTagList(nil, @win_tags);
    if (win = nil) then
    begin
      //* window failed to open */
    end
    else
    begin
      //* window successfully opened here */
      handle_window_events(win);

      CloseWindow(win);
    end;
    {$IFDEF MORPHOS}    
    CloseLibrary(IntuitionBase);
    {$ENDIF}
  end;
end;


{* Normally this routine would contain an event loop like the one given
** in the chapter "Intuition Input and Output Methods".  Here we just
** wait for any messages we requested to appear at the Window's port.
*}
procedure handle_window_events(win: PWindow);
begin
  WaitPort(win^.UserPort);
end;


begin
  Main(ArgC, ArgV);
end.
