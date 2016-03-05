program simplegad;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : simplegad
  Topic     : show the use of a button gadget.
  Source    : RKRM
}

  {*
  ** The example below demonstrates a simple application gadget.  The
  ** program declares a Gadget structure set up as a boolean gadget with
  ** complement mode highlighting.  The gadget is attached to the window
  ** when it is opened by using the WA_Gadgets tag in the OpenWindowTags()
  ** call.
  *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}


{$DEFINE INTUI_V36_NAMES_ONLY}

Uses
  Exec, AGraphics, Intuition, Utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;


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


const
  BUTTON_GAD_NUM    =   (3);
  MYBUTTONGADWIDTH  = (100);
  MYBUTTONGADHEIGHT =  (50);

{* NOTE that the use of constant size and positioning values are
** not recommended; it just makes it easy to show what is going on.
** The position of the gadget should be dynamically adjusted depending
** on the height of the font in the title bar of the window.
*}
var
  buttonBorderData : array[0..Pred(10)] of UWORD =
  (
    0,0, MYBUTTONGADWIDTH + 1,0, MYBUTTONGADWIDTH + 1,MYBUTTONGADHEIGHT + 1,
    0,MYBUTTONGADHEIGHT + 1, 0,0
  );

  buttonBorder : TBorder  =
  (
    LeftEdge    : -1;
    TopEdge     : -1;
    FrontPen    :  1;
    BackPen     :  0;
    DrawMode    : JAM1;
    Count       :  5;
    XY          : @buttonBorderData;
    NextBorder  : nil;
  );

  buttonGad : TGadget =
  (
    NextGadget      : nil;
    LeftEdge        : 20;
    TopEdge         : 20;
    Width           : MYBUTTONGADWIDTH;
    Height          : MYBUTTONGADHEIGHT;
    Flags           : GFLG_GADGHCOMP;
    Activation      : GACT_RELVERIFY or GACT_IMMEDIATE;
    GadgetType      : GTYP_BOOLGADGET;
    GadgetRender    : @buttonBorder;
    SelectRender    : nil;
    GadgetText      : nil;
    MutualExclude   : 0;
    SpecialInfo     : nil;
    GadgetID        : BUTTON_GAD_NUM;
    UserData        : nil;
  );


{*
** routine to show the use of a button (boolean) gadget.
*}
procedure Main(argc: integer; argv: PPChar);
var
  win   : PWindow;
  msg   : PIntuiMessage; 
  gad   : PGadget;
  clss  : ULONG;
  done  : Boolean;
begin
  {$IFDEF MORPHOS}
  //* make sure to get intuition version 37, for OpenWindowTags() */
  IntuitionBase := OpenLibrary('intuition.library', 37);
  {$ENDIF}
  if assigned(IntuitionBase) then
  begin
    if SetAndTest(win, OpenWindowTags(nil,
    [
      TAG_(WA_Width)        , 400,
      TAG_(WA_Height)       , 100,
      TAG_(WA_Gadgets)      , TAG_(@buttonGad),
      TAG_(WA_Activate)     , TAG_(TRUE),
      TAG_(WA_CloseGadget)  , TAG_(TRUE),
      TAG_(WA_IDCMP)        , IDCMP_GADGETDOWN or IDCMP_GADGETUP or IDCMP_CLOSEWINDOW,
      TAG_END
    ])) then
    begin
      done := FALSE;
      while (done = FALSE) do
      begin
        Wait(1 shl win^.UserPort^.mp_SigBit);
        while ( (done = FALSE) and 
              SetAndTest(msg, PIntuiMessage(GetMsg(win^.UserPort)))) do
        begin
          {* Stash message contents and reply, important when message
           ** triggers some lengthy processing
           *}
          clss := msg^.IClass;

          //* gadget address is ONLY valid for gadget messages! */
          if ((clss = IDCMP_GADGETUP) or (clss = IDCMP_GADGETDOWN))
          then gad := PGadget(msg^.IAddress);

          ReplyMsg(PMessage(msg));

          //* switch on the type of the event */
          case (clss) of
            IDCMP_GADGETUP:
              //* caused by GACT_RELVERIFY */
              WriteLn(Format('received an IDCMP_GADGETUP, gadget number %d', [gad^.GadgetID]));
            IDCMP_GADGETDOWN:
              //* caused by GACT_IMMEDIATE */
              WriteLn(Format('received an IDCMP_GADGETDOWN, gadget number %d', [gad^.GadgetID]));
            IDCMP_CLOSEWINDOW:
              begin
                //* set a flag that we are done processing events... */
                WriteLn('received an IDCMP_CLOSEWINDOW');
                done := TRUE;
              end;
          end;
        end;
        CloseWindow(win);
      end;
      {$IFDEF MORPHOS}    
      CloseLibrary(IntuitionBase);
      {$ENDIF}
    end;
  end;
end;


begin
  Main(ArgC, ArgV);
end.
