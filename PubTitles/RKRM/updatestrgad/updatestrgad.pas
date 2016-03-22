program updatestrgad;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : updatestrgad
  Title     : Show the use of a string gadget.
  Source    : RKRM
}

 {*
 ** Shows both the use of ActivateGadget() and how to properly modify the 
 ** contents of a string gadget.
 **
 ** The values of a string gadget may be updated by removing the gadget,
 ** modifying the information in the StringInfo structure, adding the
 ** gadget back and refreshing its imagery.
 *}



{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AGraphics, Intuition, utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;

const
  {* NOTE that the use of constant size and positioning values are
  ** not recommended; it just makes it easy to show what is going on.
  ** The position of the gadget should be dynamically adjusted depending
  ** on the height of the font in the title bar of the window.  This
  ** example adapts the gadget height to the screen font. Alternately,
  ** you could specify your font under V37 with the StringExtend structure.
  *}
  BUFSIZE        = (100);
  MYSTRGADWIDTH  = (200);
  MYSTRGADHEIGHT = (8);

  strBorderData  : array[0..9] of UWORD =
  (
    0,0, MYSTRGADWIDTH + 3,0, MYSTRGADWIDTH + 3,MYSTRGADHEIGHT + 3,
    0,MYSTRGADHEIGHT + 3, 0,0
  );

  strBorder : TBorder  =
  (
    LeftEdge    : -2;
    TopEdge     : -2;
    FrontPen    : 1;
    BackPen     : 0;
    DrawMode    : JAM1;
    Count       : 5;
    XY          : @strBorderData;
    NextBorder  : nil;
  );

var
  strBuffer     : array[0..Pred(BUFSIZE)] of Char;
  strUndoBuffer : array[0..Pred(BUFSIZE)] of Char;

const
  strInfo       : TStringInfo  =
  (
    Buffer      : @strBuffer;
    UndoBuffer  : @strUndoBuffer;
    BufferPos   : 0;
    MaxChars    : BUFSIZE;  
    //* compiler sets remaining fields to zero */
  );

  strGad        : TGadget  =
  (
    NextGadget      : nil;
    LeftEdge        : 20;
    TopEdge         : 20;
    Width           : MYSTRGADWIDTH;
    Height          : MYSTRGADHEIGHT;
    Flags           : GFLG_GADGHCOMP;
    Activation      : GACT_RELVERIFY or GACT_STRINGCENTER;
    GadgetType      : GTYP_STRGADGET;
    GadgetRender    : @strBorder;
    SelectRender    : nil;
    GadgetText      : nil;
    MutualExclude   : 0;
    SpecialInfo     : @strInfo;
    GadgetID        : 0;
    UserData        : nil;
  );

const
  ANSCNT        = 4;

  answers       : array[0..Pred(ANSCNT)] of PChar = 
  (
    'Try again','Sorry','Perhaps','A Winner'
  );

  ansnum        : Integer = 0;
  activated_txt : PChar = 'Activated';

  //* our function prototypes */
  procedure handleWindow(win: PWindow; gad: PGadget); forward;
  procedure updateStrGad(win: PWindow; gad: PGadget; newStr: PChar); forward;


{*   main - show the use of a string gadget.
*}
procedure Main(argc: integer; argv: PPChar);
var
  win  : PWindow;
begin
  //* make sure to get intuition version 37, for OpenWindowTags() */
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  if assigned(IntuitionBase) then
  {$ENDIF}
  begin
    {* Load a value into the string gadget buffer.
    ** This will be displayed when the gadget is first created.
    *}
    strcopy(@strBuffer, 'START');

    if SetAndTest(win, OpenWindowTags(nil,
    [
      TAG_(WA_Width)        , 400,
      TAG_(WA_Height)       , 100,
      TAG_(WA_Title)        , TAG_(PChar('Activate Window, Enter Text')),
      TAG_(WA_Gadgets)      , TAG_(@strGad),
      TAG_(WA_CloseGadget)  , TAG_(TRUE),
      TAG_(WA_IDCMP)        , IDCMP_ACTIVEWINDOW or IDCMP_CLOSEWINDOW or IDCMP_GADGETUP,
      TAG_END
    ])) then
    begin
      handleWindow(win, @strGad);

      CloseWindow(win);
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


{*
** Process messages received by the window.  Quit when the close gadget
** is selected, activate the gadget when the window becomes active.
*}
procedure handleWindow(win: PWindow; gad: PGadget);
var
  msg       : PIntuiMessage;
  gadget    : PGadget;
  iclass    : ULONG;
begin
  while true do
  begin
    Wait(1 shl win^.UserPort^.mp_SigBit);
    while SetAndTest(msg, PIntuiMessage(GetMsg(win^.UserPort))) do
    begin
      {* Stash message contents and reply, important when message
      ** triggers some lengthy processing
      *}
      iclass := msg^.iClass;
	  //* If it's a gadget message, IAddress points to Gadget */
      if ( (iclass = IDCMP_GADGETUP) or (iclass = IDCMP_GADGETDOWN) )
      then gadget := PGadget(msg^.IAddress);
      ReplyMsg(PMessage(msg));

      case (iclass) of
        IDCMP_ACTIVEWINDOW:
        begin
          {* activate the string gadget.  This is how to activate a
          ** string gadget in a new window--wait for the window to
          ** become active by waiting for the IDCMP_ACTIVEWINDOW
          ** event, then activate the gadget.  Here we report on
          ** the success or failure.
          *}
           if (ActivateGadget(gad, win, nil))
           then updateStrGad(win, gad, activated_txt);
        end;
        IDCMP_CLOSEWINDOW:
        begin
          {* here is the way out of the loop and the routine.
          ** be sure that the message was replied...
          *}
           exit;
        end;
        IDCMP_GADGETUP:
        begin
          {* If user hit RETURN in our string gadget for demonstration,
          ** we will change what he entered.  We only have 1 gadget,
          ** so we don't have to check which gadget.
          *}
          updateStrGad(win, @strGad, answers[ansnum]);
          inc(ansnum);
          if (ansnum > Pred(ANSCNT)) then ansnum := 0; //* point to next answer */
        end;
      end;
    end;
  end;
end;


{*
** Routine to update the value in the string gadget's buffer, then
** activate the gadget.
*}
procedure updateStrGad(win: PWindow; gad: PGadget; newStr: PChar);
begin
  {* first, remove the gadget from the window.  this must be done before
  ** modifying any part of the gadget!!!
  *}
  RemoveGList(win, gad, 1);

  {* For fun, change the value in the buffer, as well as the cursor and
  ** initial display position.
  *}
  strcopy(PStringInfo(gad^.SpecialInfo)^.Buffer, newstr);
  PStringInfo(gad^.SpecialInfo)^.BufferPos := 0;
  PStringInfo(gad^.SpecialInfo)^.DispPos  := 0;

  {* Add the gadget back, placing it at the end of the list (~0)
  ** and refresh its imagery.
  *}
  AddGList(win, gad, not 0, 1, nil);
  RefreshGList(gad, win, nil, 1);

  //* Activate the string gadget */
  ActivateGadget(gad, win, nil);
end;


begin
  Main(ArgC, ArgV);
end.
