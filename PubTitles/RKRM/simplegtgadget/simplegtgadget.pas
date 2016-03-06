program gadtoolsexample;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : simplegad
  Topic     : Simple example of a GadTools gadget.
  Source    : RKRM
}

 {*
 ** The example listed here shows how to use the NewGadget structure and
 ** the GadTools library functions discussed above to create a simple
 ** button gadget.
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AGraphics, Intuition, Gadtools, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


const
  //* Gadget defines of our choosing, to be used as GadgetID's. */
  MYGAD_BUTTON = (4);

const
  Topaz80 : TTextAttr =
  (
    ta_name  : 'topaz.font';
    ta_YSize : 8;
    ta_Style : 0;
    ta_Flags : 0;    
  );


  procedure process_window_events(mywin: PWindow); forward;
  procedure gadtoolsWindow; forward;


{*
** Open all libraries and run.  Clean up when finished or on error..
*}

procedure main;
begin
  {$IFDEF MORPHOS}
  if (SetAndGet(IntuitionBase, OpenLibrary('intuition.library', 37)) <> nil) then
  {$ENDIF}
  begin
    {$IF DEFINED(AMIGA) OR DEFINED(MORPHOS)}
    if (SetAndGet(GadToolsBase, OpenLibrary('gadtools.library', 37)) <> nil) then
    {$ENDIF}
    begin
      gadtoolsWindow();

      {$IF DEFINED(AMIGA) OR DEFINED(MORPHOS)}
      CloseLibrary(GadToolsBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(pLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


{*
** Prepare for using GadTools, set up gadgets and open window.
** Clean up and when done or on error.
*}
procedure gadtoolsWindow;
var
  mysc  : PScreen;
  mywin : PWindow;
  glist, 
  gad   : PGadget;
  ng    : TNewGadget;
  vi    : Pointer;
begin
  glist := nil;

  if (SetAndGet(mysc, LockPubScreen(nil)) <> nil) then
  begin
    if (SetAndGet(vi, GetVisualInfo(mysc, [TAG_END])) <> nil) then
    begin
      //* GadTools gadgets require this step to be taken */
      gad := CreateContext(@glist);

      //* create a button gadget centered below the window title */
      ng.ng_TextAttr   := @Topaz80;
      ng.ng_VisualInfo := vi;
      ng.ng_LeftEdge   := 150;
      ng.ng_TopEdge    := 20 + mysc^.WBorTop + (mysc^.Font^.ta_YSize + 1);
      ng.ng_Width      := 100;
      ng.ng_Height     := 12;
      ng.ng_GadgetText := 'Click Here';
      ng.ng_GadgetID   := MYGAD_BUTTON;
      ng.ng_Flags      := 0;
      gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_END, TAG_END]);

      if (gad <> nil) then
      begin
        if (SetAndGet(mywin, OpenWindowTags(nil,
        [
          TAG_(WA_Title)      , TAG_(PChar('GadTools Gadget Demo')),
          TAG_(WA_Gadgets)    , TAG_(glist),
          TAG_(WA_AutoAdjust) , TAG_(TRUE),
          TAG_(WA_Width)      , 400,
          TAG_(WA_InnerHeight), 100,
          TAG_(WA_DragBar)    , TAG_(TRUE),
          TAG_(WA_DepthGadget), TAG_(TRUE),
          TAG_(WA_Activate)   , TAG_(TRUE),
          TAG_(WA_CloseGadget), TAG_(TRUE),
          TAG_(WA_IDCMP)      , IDCMP_CLOSEWINDOW or IDCMP_REFRESHWINDOW or BUTTONIDCMP,
          TAG_(WA_PubScreen)  , TAG_(mysc),
          TAG_END
        ])) <> nil ) then
        begin
          GT_RefreshWindow(mywin, nil);

          process_window_events(mywin);

          CloseWindow(mywin);
        end;
      end;
      {* FreeGadgets() must be called after the context has been
      ** created.  It does nothing if glist is NULL
      *}
      FreeGadgets(glist);
      FreeVisualInfo(vi);
    end;
    UnlockPubScreen(nil, mysc);
  end;
end;


{*
** Standard message handling loop with GadTools message handling functions
** used (GT_GetIMsg() and GT_ReplyIMsg()).
*}
procedure process_window_events(mywin: PWindow);
var
  imsg          : PIntuiMessage;
  gad           : PGadget;
  terminated    : boolean = FALSE;
begin
  while not(terminated) do
  begin
    Wait(1 shl mywin^.UserPort^.mp_SigBit);

    //* Use GT_GetIMsg() and GT_ReplyIMsg() for handling */
    //* IntuiMessages with GadTools gadgets.             */
    while (not(terminated) and SetAndTest(imsg, GT_GetIMsg(mywin^.UserPort))) do
    begin
      //* GT_ReplyIMsg() at end of loop */

      case (imsg^.IClass) of
        IDCMP_GADGETUP:         //* Buttons only report GADGETUP */
        begin
          gad := PGadget(imsg^.IAddress);
          if (gad^.GadgetID = MYGAD_BUTTON)
          then WriteLn('Button was pressed.');
        end;
        IDCMP_CLOSEWINDOW:
        begin
          terminated := TRUE;
        end;
        IDCMP_REFRESHWINDOW:
        begin
          //* This handling is REQUIRED with GadTools. */
          GT_BeginRefresh(mywin);
          GT_EndRefresh(mywin, LongInt(TRUE));
        end;
      end;
      //* Use the toolkit message-replying function here... */
      GT_ReplyIMsg(imsg);
    end;
  end;
end;


begin
  main;
end.
