program easyintuition37;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : easyintuition37
  Source    : RKRM
}
 {*
  * This example shows a simple Intuition program that works with
  * Release 2 (V36) and later versions of the Amiga operating system.
  *}
 
  //* easyintuition37.c -- Simple Intuition program for V37   */
  //* (Release 2) and later versions of the operating system. */



{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

//* Force use of new variable names to help prevent errors  */
{$DEFINE INTUI_V36_NAMES_ONLY}

Uses
  Exec, AmigaDOS, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  Trinity,
  CHelpers;


{$IFDEF AMIGA}
var
  IntuitionBase : PLibrary absolute _Intuitionbase;
{$ENDIF}

//* Use lowest non-obsolete version that supplies the functions needed. */
const
  INTUITION_REV = 37;

  //* Declare the prototypes of our own functions. Prototypes for system  */
  //* functions are declared in the header files in the clib directory    */
  procedure cleanExit(scrn: PScreen; wind: PWindow; returnvalue: LONG); forward;
  function  handleIDCMP(win: PWindow): boolean; forward;



Const
  //* Position and sizes for our window */
  WIN_LEFTEDGE  =  20;
  WIN_TOPEDGE   =  20;
  WIN_WIDTH     = 400;
  WIN_MINWIDTH  =  80;
  WIN_HEIGHT    = 150;
  WIN_MINHEIGHT =  20;



{*
** Main routine to show the use of EasyRequest()
*}
procedure Main(argc: integer; argv: PPChar);
var
  //* Declare variables here */
  signalmask, 
  winsignal, 
  signals   : ULONG;
  done      : boolean = FALSE;
  pens      : Array[0..0] of UWORD = (UWORD(not 0));

  screen1   : PScreen = nil;
  window1   : PWindow = nil;  
begin
  //* Open the Intuition Library */
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', INTUITION_REV);
  {$ENDIF}
  if (IntuitionBase = nil)
  then cleanExit(screen1, window1, RETURN_WARN);

  //* Open any other required libraries and make */
  //* any assignments that were postponed above  */

  //* Open the screen */
  screen1 := OpenScreenTags(nil,
  [
    TAG_(SA_Pens)       , TAG_(@pens),
    // FPC Note: Hires is really an Amiga displayID.
    {$IFDEF AMIGA}
    TAG_(SA_DisplayID)  , HIRES_KEY,
    {$ENDIF}
    TAG_(SA_Depth)      , 2,
    TAG_(SA_Title)      , TAG_(PChar('Our Screen')),
    TAG_DONE
  ]);

  if (screen1 = nil)
  then cleanExit(screen1, window1, RETURN_WARN);

  //* ... and open the window */
  window1 := OpenWindowTags(nil,
  [
    //* Specify window dimensions and limits */
    TAG_(WA_Left)           , WIN_LEFTEDGE,
    TAG_(WA_Top)            , WIN_TOPEDGE,
    TAG_(WA_Width)          , WIN_WIDTH,
    TAG_(WA_Height)         , WIN_HEIGHT,
    TAG_(WA_MinWidth)       , WIN_MINWIDTH,
    TAG_(WA_MinHeight)      , WIN_MINHEIGHT,
    TAG_(WA_MaxWidth)       , TAG_(not 0),
    TAG_(WA_MaxHeight)      , TAG_(not 0),
    //* Specify the system gadgets we want */
    TAG_(WA_CloseGadget)    , TAG_(TRUE),
    TAG_(WA_SizeGadget)     , TAG_(TRUE),
    TAG_(WA_DepthGadget)    , TAG_(TRUE),
    TAG_(WA_DragBar)        , TAG_(TRUE),
    //* Specify other attributes           */
    TAG_(WA_Activate)       , TAG_(TRUE),
    TAG_(WA_NoCareRefresh)  , TAG_(TRUE),

    //* Specify the events we want to know about */
    TAG_(WA_IDCMP)          , IDCMP_CLOSEWINDOW,

    //* Attach the window to the open screen ...*/
    TAG_(WA_CustomScreen)   , TAG_(screen1),
    TAG_(WA_Title)          , TAG_(PChar('EasyWindow')),
    TAG_(WA_ScreenTitle)    , TAG_(PChar('Our Screen - EasyWindow is Active')),
    TAG_DONE
  ]);

  if (window1 = nil)
  then cleanExit(screen1, window1, RETURN_WARN);
  
  //* Set up the signals for the events we want to hear about ...   */
  winsignal := 1 shl window1^.UserPort^.mp_SigBit;  //* window IDCMP */
  signalmask := winsignal;    //* we are only waiting on IDCMP events */
  
  //* Here's the main input event loop where we wait for events.    */
  //* We have asked Intuition to send us CLOSEWINDOW IDCMP events   */
  //* Exec will wake us if any event we are waiting for occurs.     */
  while not(done) do
  begin
    signals := Wait(signalmask);

    //* An event occurred - now act on the signal(s) we received.*/
    //* We were only waiting on one signal (winsignal) in our    */
    //* signalmask, so we actually know we received winsignal.   */
    if (signals and winsignal) <> 0
    then done := handleIDCMP(window1);  //* done if close gadget */
  end;

  cleanExit(screen1, window1, RETURN_OK);   //* Exit the program     */
end;


function handleIDCMP(win: PWindow): boolean;
var
  done      : boolean = false;
  imessage  : PIntuiMessage = nil;  // FPC Note: message is a reserved word
  iclass    : ULONG;                // FPC Note; calss is a reserved word
begin
  //* Examine pending messages */
  while SetAndTest(imessage, PIntuiMessage(GetMsg(win^.UserPort))) do
  begin
    iclass := imessage^.IClass; //* get all data we need from message */

    //* When we're through with a message, reply */
    ReplyMsg(PMessage(imessage));

    //* See what events occurred */
    case (iclass) of
      IDCMP_CLOSEWINDOW: done := TRUE;
      else               { nothing } ;
    end;
  end;
  Result := (done);
end;


procedure cleanExit(scrn: PScreen; wind: PWindow; returnvalue: LONG);
begin
  //* Close things in the reverse order of opening */
  if assigned(wind) then CloseWindow(wind);     //* Close window if opened */
  if assigned(scrn) then CloseScreen(scrn);     //* Close screen if opened */

  //* Close the library, and then exit */
  {$IFDEF MORPHOS}
  if Assigned(IntuitionBase) then CloseLibrary(PLibrary(IntuitionBase));
  {$ENDIF}
  Halt(returnValue);
end;


begin
  Main(ArgC, ArgV);
end.
