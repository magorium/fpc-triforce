program gadtoolsexample;

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
  ===========================================================================
  Project : gadtools
  Topic   : Example of GUI programming with GadTools
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/gadtools.c
  ===========================================================================

  This example was originally written in c by Thomas Rapp.

  The original examples are available online and published at Thomas Rapp's 
  website (http://thomas-rapp.homepage.t-online.de/examples)

  The c-sources were converted to Free Pascal, and (variable) names and 
  comments were translated from German into English as much as possible.

  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc

  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Conversion to Free Pascal and translation was done by Magorium in 2015, 
  with kind permission from Thomas Rapp to be able to publish.

  ===========================================================================  

        Unless otherwise noted, you must consider these examples to be 
                 copyrighted by their respective owner(s)

  ===========================================================================  
}

Uses
  Exec, AmigaDOS, Intuition, Gadtools, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

Const
  cycletext     : Array[0..4] of PChar = ('One','Two','Three','Four', nil);

  GID_AUSWAHL   = 4711;
  GID_INPUT     = 4712;
  GID_CONTINUE  = 4713;
  GID_ABORT     = 4714;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  gad       : PGadget;      //* Pointer to the current gadget */
  glist     : PGadget;      //* Pointer to first gasget in the list */
  ng        : TNewGadget;   //* Generic information for new gadgets (Size, Font, Text etc.) */
  scr       : PScreen;
  win       : PWindow;
  imsg      : PIntuiMessage;
  cont      : Boolean;
  winw,winh : LongInt;
  num       : LongInt;
  txt       : PChar;
begin
  if SetAndTest(scr, LockPubScreen(nil)) then
  begin
    glist := nil;
    gad := CreateContext(@glist);   //* This will initialize the Gadget-List. */

    //* Set values, that are the same for each gadget */
    ng.ng_VisualInfo := GetVisualInfo(scr, [TAG_END, TAG_END]);  //* bug in aros taglist
    ng.ng_TextAttr   := scr^.Font;
    ng.ng_Flags      := 0;

    //* The following block (incl. Create Gadget) is repeated for each new gadget. */
    //* Only the values that need to change are adjusted.                          */
    //* At CreateGadget the previous gadget is provided, so that they are          */
    //* concatenated.
    //* It isn't necessary to check the result each time it was obtained. If the   */
    //* previous gadget was Nil, then all further gadgets will be nil as well,     */
    //* which allows us to only check the last created gadget                      */
    ng.ng_LeftEdge   := scr^.WBorLeft + 4 + 10 * scr^.RastPort.TxWidth;
    ng.ng_TopEdge    := scr^.WBorTop + scr^.RastPort.TxHeight + 5;
    ng.ng_Width      := 20 * scr^.RastPort.TxWidth + 20;
    ng.ng_Height     := scr^.RastPort.TxHeight + 6;
    ng.ng_GadgetText := PChar('Selection');
    ng.ng_GadgetID   := GID_AUSWAHL;
    gad := CreateGadget(CYCLE_KIND, gad, @ng, [TAG_(GTCY_Labels), TAG_(@cycletext), TAG_END]);

    ng.ng_TopEdge    := ng.ng_TopEdge + ng.ng_Height + 4;
    ng.ng_GadgetText := PChar('Input');
    ng.ng_GadgetID   := GID_INPUT;
    gad := CreateGadget(STRING_KIND, gad, @ng, [TAG_END, TAG_END]);  //* bug in aros taglist

    ng.ng_LeftEdge   := scr^.WBorLeft + 4;
    ng.ng_TopEdge    := ng.ng_TopEdge + ng.ng_Height + 4;
    ng.ng_Width      := 15 * scr^.RastPort.TxWidth + 8;
    ng.ng_GadgetText := PChar('Continue');
    ng.ng_GadgetID   := GID_CONTINUE;
    gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_END, TAG_END]); //* bug in aroas taglist

    ng.ng_LeftEdge   := ng.ng_LeftEdge + ng.ng_Width + 4;
    ng.ng_GadgetText := PChar('Abort');
    ng.ng_GadgetID   := GID_ABORT;
    gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_END, TAG_END]); //* bug in aros taglist

    //* The last gadget is at the bottom right, therefore, its size and position are   */
    //* used to calculate the window size.                                             */
    winw := ng.ng_LeftEdge + ng.ng_Width  + 4 + scr^.WBorRight;
    winh := ng.ng_TopEdge  + ng.ng_Height + 4 + scr^.WBorBottom;

	if assigned(gad) then   //* Check if all the gadgets have been created */
    begin
      //* When opening the window the IDCMP flags for Gadtools gadgets must be specified. */
      //* For this, the constants are <type> IDCMP are used.*/
      if SetAndTest(win, OpenWindowTags (nil,
      [
        TAG_(WA_Width)      , winw,
        TAG_(WA_Height)     , winh,
        TAG_(WA_Left)       , (scr^.Width  - winw) div 2,    //* Center window on screen */
        TAG_(WA_Top)        , (scr^.Height - winh) div 2,
        TAG_(WA_PubScreen)  , TAG_(scr),
        TAG_(WA_Title)      , TAG_(PChar('Window')),
        TAG_(WA_Flags)      , TAG_(WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE),
        TAG_(WA_IDCMP)      , TAG_(IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_REFRESHWINDOW or BUTTONIDCMP or CYCLEIDCMP or STRINGIDCMP),
        TAG_(WA_Gadgets)    , TAG_(glist),
        TAG_END
      ])) then
      begin
        GT_RefreshWindow(win, nil);           //* Redraw all Gadtools-Gadgets.                  */
                                              //* This must be done once at the beginning.      */
        UnlockPubScreen(nil, scr);            //* The window prevents the screen from closing,  */
        scr := nil;                           //* therfor the lock is no longer needed here     */

        //* Folowing is normal window message handling.                      */
        //* Except that instead of the usual Getmsg / ReplyMsg we use Gadtools functions */
        cont := TRUE;
        while cont do
        begin
          if (Wait ((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
            then cont := FALSE;

          while SetAndTest(imsg, GT_GetIMsg(win^.UserPort)) do
          begin
            case (imsg^.IClass) of
              IDCMP_GADGETUP:
              begin
                gad := PGadget(imsg^.IAddress);
                case (gad^.GadgetID) of
                  GID_AUSWAHL:
                  begin
                    GT_GetGadgetAttrs(gad, win, nil, [TAG_(GTCY_Active), TAG_(@num), TAG_END]);
                    WriteLn('Selection: ', cycletext[num]);
                  end;
                  GID_INPUT:
                  begin
                    GT_GetGadgetAttrs(gad, win, nil, [TAG_(GTST_String), TAG_(@txt), TAG_END]);
                    WriteLn('Input: <', txt, '>');
                  end;
                  GID_CONTINUE:
                  begin
                    WriteLn('Continue');
                  end;
                  GID_ABORT:
                  begin
                    WriteLn('Abort');
                  end;
                end; // case
              end;
              IDCMP_VANILLAKEY:
              begin
                if (imsg^.Code = $1b) //* Esc */
                  then cont := FALSE;
              end;
              IDCMP_CLOSEWINDOW:
              begin
                cont := FALSE;
              end;
              IDCMP_REFRESHWINDOW:
              begin
                GT_BeginRefresh(win);
                GT_EndRefresh(win, LongInt(TRUE));
              end;
            end; // case imasg
            GT_ReplyIMsg(imsg);
          end;
        end; // while cont

        CloseWindow(win);
      end;
    end;

    FreeGadgets(glist);

    FreeVisualInfo(ng.ng_VisualInfo);

    if assigned(scr) then UnlockPubScreen(nil, scr);
  end;

  Result := (0);
end;

//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/

Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  GadToolsBase := OpenLibrary(GADTOOLSNAME, 0);
  if not assigned(GadToolsBase) then Exit;
  {$ENDIF}
  {$IF DEFINED(MORPHOS)}
  IntuitionBase := OpenLibrary(INTUITIONNAME, 0);
  if not assigned(IntuitionBase) then Exit;
  {$ENDIF}

  Result := True;
end;


Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS)}
  if assigned(IntuitionBase) then CloseLibrary(pLibrary(IntuitionBase));
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  if assigned(GadToolsBase) then CloseLibrary(pLibrary(GadToolsBase));
  {$ENDIF}
end;


begin
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
end.
