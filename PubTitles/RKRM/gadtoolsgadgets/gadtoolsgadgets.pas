program gadtoolsgadgets;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

{
  Project   : gadtoolsgadgets
  Source    : RKRM
}

 {*
 ** Simple example of using a number of gadtools gadgets.
 *}


Uses
  Exec, AGraphics, Intuition, Gadtools, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;


//Type
//  PPGadget        = ^PGadget;

Const
  {/* Gadget defines of our choosing, to be used as GadgetID's,
  ** also used as the index into the gadget array my_gads[].
  *}
  MYGAD_SLIDER    = (0);
  MYGAD_STRING1   = (1);
  MYGAD_STRING2   = (2);
  MYGAD_STRING3   = (3);
  MYGAD_BUTTON    = (4);

  //* Range for the slider: */
  SLIDER_MIN      = (1);
  SLIDER_MAX      = (20);

  Topaz80       : TTextAttr =
  (
    ta_Name     : 'topaz.font';
    ta_YSize    : 8;
    ta_Style    : 0;
    ta_Flags    : 0;
  );



{* Print any error message.  We could do more fancy handling (like
** an EasyRequest()), but this is only a demo.
*}
procedure errorMessage(error: STRPTR);
begin
  if assigned(error)
  then WriteLn('Error: ', error);
end;


{*
** Function to handle a GADGETUP or GADGETDOWN event.  For GadTools gadgets,
** it is possible to use this function to handle MOUSEMOVEs as well, with
** little or no work.
*}
procedure handleGadgetEvent(win: PWindow; gad: PGadget; code: UWORD; slider_level: PSmallInt; my_gads: Array of PGadget);
begin
  case (gad^.GadgetID) of
    MYGAD_SLIDER:
    begin
      //* Sliders report their level in the IntuiMessage Code field: */
      WriteLn('Slider at level ', code);
      slider_level^ := code;
    end;
    MYGAD_STRING1:
    begin
      //* String gadgets report GADGETUP's */
      WriteLn('String gadget 1: "', PStringInfo(gad^.SpecialInfo)^.Buffer ,'".');
    end;
    MYGAD_STRING2:
    begin
      //* String gadgets report GADGETUP's */
      WriteLn('String gadget 2: "', PStringInfo(gad^.SpecialInfo)^.Buffer ,'".');
    end;
    MYGAD_STRING3:
    begin
      //* String gadgets report GADGETUP's */
      WriteLn('String gadget 3: "', PStringInfo(gad^.SpecialInfo)^.Buffer ,'".');
    end;
    MYGAD_BUTTON:
    begin
      //* Buttons report GADGETUP's (button resets slider to 10) */
      WriteLn('Button was pressed, slider reset to 10.');
      slider_level^ := 10;
      GT_SetGadgetAttrs(my_gads[MYGAD_SLIDER], win, nil,
      [
        TAG_(GTSL_Level), slider_level^,
        TAG_END
      ]);
    end;
  end;
end;


{*
** Function to handle vanilla keys.
*}
procedure handleVanillaKey(win: PWindow; code: UWORD; slider_level: PSmallInt; my_gads: Array of PGadget);
begin
  case Chr(code) of
    'v':
    begin
      //* increase slider level, but not past maximum */
      inc(slider_level^);
      if (slider_level^ > SLIDER_MAX) then slider_level^ := SLIDER_MAX;
      GT_SetGadgetAttrs(my_gads[MYGAD_SLIDER], win, nil,
      [
        TAG_(GTSL_Level), slider_level^,
        TAG_END
      ]);
    end;
    'V':
    begin
      //* decrease slider level, but not past minimum */
      dec(slider_level^);
      if (slider_level^ < SLIDER_MIN) then slider_level^ := SLIDER_MIN;
      GT_SetGadgetAttrs(my_gads[MYGAD_SLIDER], win, nil,
      [
        TAG_(GTSL_Level), slider_level^,
        TAG_END
      ]);
    end;
    'c', 'C':
    begin
      //* button resets slider to 10 */
      slider_level^ := 10;
      GT_SetGadgetAttrs(my_gads[MYGAD_SLIDER], win, nil,
      [
        TAG_(GTSL_Level), slider_level^,
        TAG_END
      ]);
    end;
    'f', 'F':
    begin
      ActivateGadget(my_gads[MYGAD_STRING1], win, nil);
    end;
    's', 'S':
    begin
      ActivateGadget(my_gads[MYGAD_STRING2], win, nil);
    end;
    't', 'T':
    begin
      ActivateGadget(my_gads[MYGAD_STRING3], win, nil);
    end;
  end;
end;


{*
** Here is where all the initialization and creation of GadTools gadgets
** take place.  This function requires a pointer to a NULL-initialized
** gadget list pointer.  It returns a pointer to the last created gadget,
** which can be checked for success/failure.
*}
function  createAllGadgets(glistptr: PPGadget; vi: Pointer;
    topborder: UWORD; slider_level: SmallInt; var my_gads: Array of PGadget): PGadget;
var
  ng    : TNewGadget;
  gad   : PGadget;
begin
  {* All the gadget creation calls accept a pointer to the previous gadget, and
  ** link the new gadget to that gadget's NextGadget field.  Also, they exit
  ** gracefully, returning NULL, if any previous gadget was NULL.  This limits
  ** the amount of checking for failure that is needed.  You only need to check
  ** before you tweak any gadget structure or use any of its fields, and finally
  ** once at the end, before you add the gadgets.
  *}

  {* The following operation is required of any program that uses GadTools.
  ** It gives the toolkit a place to stuff context data.
  *}
  gad := CreateContext(glistptr);

  {* Since the NewGadget structure is unmodified by any of the CreateGadget()
  ** calls, we need only change those fields which are different.
  *}
  ng.ng_LeftEdge    := 140;
  ng.ng_TopEdge     := 20 + topborder;
  ng.ng_Width       := 200;
  ng.ng_Height      := 12;
  ng.ng_GadgetText  := '_Volume:   ';
  ng.ng_TextAttr    := @Topaz80;
  ng.ng_VisualInfo  := vi;
  ng.ng_GadgetID    := MYGAD_SLIDER;
  ng.ng_Flags       := NG_HIGHLABEL;

  my_gads[MYGAD_SLIDER] := SetAndGet(gad, CreateGadget(SLIDER_KIND, gad, @ng,
  [
    TAG_(GTSL_Min)         , SLIDER_MIN,
    TAG_(GTSL_Max)         , SLIDER_MAX,
    TAG_(GTSL_Level)       , slider_level,
    TAG_(GTSL_LevelFormat) , TAG_(PChar('%2ld')),
    TAG_(GTSL_MaxLevelLen) , 2,
    TAG_(GT_Underscore)    , Ord('_'),
    TAG_END
  ]));

  ng.ng_TopEdge     := ng.ng_TopEdge + 20;
  ng.ng_Height      := 14;
  ng.ng_GadgetText  := '_First:';
  ng.ng_GadgetID    := MYGAD_STRING1;
  my_gads[MYGAD_STRING1] := SetAndGet(gad, CreateGadget(STRING_KIND, gad, @ng,
  [
    TAG_(GTST_String)   , TAG_(PChar('Try pressing')),
    TAG_(GTST_MaxChars) , 50,
    TAG_(GT_Underscore) , Ord('_'),
    TAG_END
  ]));

  ng.ng_TopEdge     := ng.ng_TopEdge + 20;
  ng.ng_GadgetText  := '_Second:';
  ng.ng_GadgetID    := MYGAD_STRING2;
  my_gads[MYGAD_STRING2] := SetAndGet(gad, CreateGadget(STRING_KIND, gad, @ng,
  [
    TAG_(GTST_String)   , TAG_(PChar('TAB or Shift-TAB')),
    TAG_(GTST_MaxChars) , 50,
    TAG_(GT_Underscore) , Ord('_'),
    TAG_END
  ]));

  ng.ng_TopEdge     := ng.ng_TopEdge + 20;
  ng.ng_GadgetText  := '_Third:';
  ng.ng_GadgetID    := MYGAD_STRING3;
  my_gads[MYGAD_STRING3] := SetAndGet(gad, CreateGadget(STRING_KIND, gad, @ng,
  [
    TAG_(GTST_String)   , TAG_(PChar('To see what happens!')),
    TAG_(GTST_MaxChars) , 50,
    TAG_(GT_Underscore) , Ord('_'),
    TAG_END
  ]));

  ng.ng_LeftEdge    := ng.ng_LeftEdge + 50;
  ng.ng_TopEdge     := ng.ng_TopEdge + 20;
  ng.ng_Width       := 100;
  ng.ng_Height      := 12;
  ng.ng_GadgetText  := '_Click Here';
  ng.ng_GadgetID    := MYGAD_BUTTON;
  ng.ng_Flags       := 0;
  gad := CreateGadget(BUTTON_KIND, gad, @ng,
  [
    TAG_(GT_Underscore) , Ord('_'),
    TAG_END
  ]);
  Result := (gad);
end;


{*
** Standard message handling loop with GadTools message handling functions
** used (GT_GetIMsg() and GT_ReplyIMsg()).
*}
procedure process_window_events(mywin: PWindow; slider_level: PSmallInt; my_gads: Array of PGadget);
var
  imsg       : PIntuiMessage;
  imsgClass  : ULONG;
  imsgCode   : UWORD;
  gad        : PGadget;
  terminated : Boolean = FALSE;
begin
  while not(terminated) do
  begin
    Wait(1 shl mywin^.UserPort^.mp_SigBit);

    {* GT_GetIMsg() returns an IntuiMessage with more friendly information for
    ** complex gadget classes.  Use it wherever you get IntuiMessages where
    ** using GadTools gadgets.
    *}
    while ( not(terminated) and SetAndTest(imsg, GT_GetIMsg(mywin^.UserPort))) do
    begin
      {* Presuming a gadget, of course, but no harm...
      ** Only dereference this value (gad) where the Class specifies
      ** that it is a gadget event.
      *}
      gad := PGadget(imsg^.IAddress);

      imsgClass := imsg^.IClass;
      imsgCode := imsg^.Code;

      //* Use the toolkit message-replying function here... */
      GT_ReplyIMsg(imsg);

      case (imsgClass) of
        {*  --- WARNING --- WARNING --- WARNING --- WARNING --- WARNING ---
        ** GadTools puts the gadget address into IAddress of IDCMP_MOUSEMOVE
        ** messages.  This is NOT true for standard Intuition messages,
        ** but is an added feature of GadTools.
        *}
        IDCMP_GADGETDOWN,
        IDCMP_MOUSEMOVE,
        IDCMP_GADGETUP:
        begin
          handleGadgetEvent(mywin, gad, imsgCode, slider_level, my_gads);
        end;
        IDCMP_VANILLAKEY:
        begin
          handleVanillaKey(mywin, imsgCode, slider_level, my_gads);
        end;
        IDCMP_CLOSEWINDOW:
        begin
          terminated := TRUE;
        end;
        IDCMP_REFRESHWINDOW:
        begin
          {* With GadTools, the application must use GT_BeginRefresh()
          ** where it would normally have used BeginRefresh()
          *}
           GT_BeginRefresh(mywin);
           GT_EndRefresh(mywin, Ord(TRUE));
        end;
      end;
    end;
  end;
end;


{*
** Prepare for using GadTools, set up gadgets and open window.
** Clean up and when done or on error.
*}
procedure gadtoolsWindow;
var
  font          : PTextFont;
  mysc          : PScreen;
  mywin         : PWindow;
  glist         : PGadget;
  slider_level  : SmallInt = 5;
  vi            : Pointer;
  topborder     : UWORD;
  my_gads       : Array[0..Pred(4)] of PGadget;    
begin
  {* Open topaz 8 font, so we can be sure it's openable
  ** when we later set ng_TextAttr to &Topaz80:
  *}
  if (nil = SetAndGet(font, OpenFont(@Topaz80)))
  then errorMessage('Failed to open Topaz 80')
  else
  begin
    if (nil = SetAndGet(mysc, LockPubScreen(nil)))
    then errorMessage('Couldn''t lock default public screen"')
    else
    begin
      // if (nil = SetAndGet(vi, GetVisualInfo(mysc, [TAG_END])))
      if (nil = SetAndGet(vi, GetVisualInfo(mysc, [TAG_END, 0])))  // aros bug in tagitems
      then errorMessage('GetVisualInfo() failed')
      else
      begin
        //* Here is how we can figure out ahead of time how tall the  */
        //* window's title bar will be:                               */
        topborder := mysc^.WBorTop + (mysc^.Font^.ta_YSize + 1);

        if (nil = createAllGadgets(@glist, vi, topborder, slider_level, my_gads))
        then errorMessage('createAllGadgets() failed')
        else
        begin
          if (nil = SetAndGet(mywin, OpenWindowTags(nil,
          [
            TAG_(WA_Title)        , TAG_(PChar('GadTools Gadget Demo')),
            TAG_(WA_Gadgets)      , TAG_(glist),
            TAG_(WA_AutoAdjust)   , TAG_(TRUE),
            TAG_(WA_Width )       , 400,
            TAG_(WA_MinWidth)     ,  50,
            TAG_(WA_InnerHeight)  , 140,
            TAG_(WA_MinHeight)    ,  50,
            TAG_(WA_DragBar)      , TAG_(TRUE),
            TAG_(WA_DepthGadget)  , TAG_(TRUE),
            TAG_(WA_Activate)     , TAG_(TRUE),
            TAG_(WA_CloseGadget)  , TAG_(TRUE),
            TAG_(WA_SizeGadget)   , TAG_(TRUE),
            TAG_(WA_SimpleRefresh), TAG_(TRUE),
            TAG_(WA_IDCMP)        , IDCMP_CLOSEWINDOW or IDCMP_REFRESHWINDOW or IDCMP_VANILLAKEY or SLIDERIDCMP or STRINGIDCMP or BUTTONIDCMP,
            TAG_(WA_PubScreen)    , TAG_(mysc),
            TAG_END
          ])))
          then errorMessage('OpenWindow() failed')
          else
          begin
            {* After window is open, gadgets must be refreshed with a
            ** call to the GadTools refresh window function.
            *}
             GT_RefreshWindow(mywin, nil);

             process_window_events(mywin, @slider_level, my_gads);

             CloseWindow(mywin);
          end;
        end;
        {* FreeGadgets() even if createAllGadgets() fails, as some
        ** of the gadgets may have been created...If glist is NULL
        ** then FreeGadgets() will do nothing.
        *}
        FreeGadgets(glist);
        FreeVisualInfo(vi);
      end;
      UnlockPubScreen(nil, mysc);
    end;
    CloseFont(font);
  end;
end;


{*
** Open all libraries and run.  Clean up when finished or on error..
*}
procedure main;
begin
  {$IF DEFINED(MORPHOS)}
  if (nil = SetAndGet(IntuitionBase, OpenLibrary('intuition.library', 37)))
  then errorMessage('Requires V37 intuition.library')
  else
  {$ENDIF}
  begin
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    if (nil = SetAndGet(GfxBase, OpenLibrary('graphics.library', 37))) 
    then errorMessage('Requires V37 graphics.library')
    else
    {$ENDIF}
    begin
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
      if (nil = SetAndGet(GadtoolsBase, OpenLibrary('gadtools.library', 37)))
      then errorMessage('Requires V37 gadtools.library')
      else
      {$ENDIF}
      begin
        gadtoolsWindow;

        {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
        CloseLibrary(GadToolsBase);
        {$ENDIF}
      end;
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      CloseLibrary(GfxBase);
      {$ENDIF}
    end;
    {$IF DEFINED(MORPHOS)}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


begin
  Main;
end.
