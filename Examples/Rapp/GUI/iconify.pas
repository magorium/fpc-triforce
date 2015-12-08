program iconify;

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
  Project : iconify
  Topic   : Example for implementing Iconify
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/iconify.c
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


//*-------------------------------------------------------------------------*/
//* System Includes                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AmigaDOS, WorkBench, Icon, AGraphics, Intuition, Gadtools, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//* Constants & macro's                                                     */
//*-------------------------------------------------------------------------*/

const
  GID_ICONIFY  = 4711;
  GID_QUIT     = 4712;
  GID_LOAD     = 4713;
  GID_SAVE     = 4714;

//*-------------------------------------------------------------------------*/
//* Type definitions                                                        */
//*-------------------------------------------------------------------------*/

Type
  Pgui = ^Tgui;
  Tgui = 
  record
    scr         : PScreen;
    win         : PWindow;
    visualinfo  : APTR;
    glist       : PGadget;
    appport     : PMsgPort;
    appicon     : PAppIcon;
    diskobj     : PDiskObject;
    shading     : ULONG;
    shadinggad  : PGadget;
    quality     : ULONG;
    qualitygad  : PGadget;
    view        : ULONG;
    viewgad     : PGadget;
    server      : array[0..pred(256)] of char;
    servergad   : PGadget;
    path        : array[0..pred(256)] of char;
    pathgad     : PGadget;
    imgpath     : array[0..pred(256)] of char;
    imgpathgad  : PGadget;
    delay       : ULONG;
    delaygad    : PGadget;
    hotkey1     : array[0..pred(256)] of char;
    hotkey1gad  : PGadget;
    hotkey2     : array[0..pred(256)] of char;
    hotkey2gad  : PGadget;
  end;

//*-------------------------------------------------------------------------*/
//* copy string with maximal length                                         */
//*-------------------------------------------------------------------------*/
Type
  size_t = SizeInt;

function  strlcpy(dst: PChar; const src: PChar; siz: size_t): size_t;
var
  d : PChar;
  s : PChar;
  n : size_t;
begin
  d := dst;
  s := src;
  n := siz;

  if (n <> 0) then
  begin
    while SetAndTest(n, n-1) do
    begin
      d^ := s^;
      if d^ = #0 then break;
      inc(d); inc(s);
    end;
  end;
  
  if (n = 0) then
  begin
    if (siz <> 0) then d^ := #0;
    while (s^ <> #0) do inc(s);
  end;
  
  result := (s - src - 1);
end;

//*-------------------------------------------------------------------------*/
//* Close window                                                            */
//*-------------------------------------------------------------------------*/

procedure close_window(g: Pgui);
var
  txt : PChar;
begin
  if ( (g^.glist <> nil) and (g^.win <> nil) ) then
  begin
    GT_GetGadgetAttrs(g^.shadinggad , g^.win, nil, [TAG_(GTCY_Active), TAG_(@g^.shading), TAG_END]);
    GT_GetGadgetAttrs(g^.qualitygad , g^.win, nil, [TAG_(GTCY_Active), TAG_(@g^.quality), TAG_END]);
    GT_GetGadgetAttrs(g^.viewgad    , g^.win, nil, [TAG_(GTCY_Active), TAG_(@g^.view)   , TAG_END]);
    GT_GetGadgetAttrs(g^.servergad  , g^.win, nil, [TAG_(GTST_String), TAG_(@txt)       , TAG_END]);
    strlcpy(g^.server, txt, 256);
    GT_GetGadgetAttrs (g^.pathgad   , g^.win, nil, [TAG_(GTST_String), TAG_(@txt)       , TAG_END]);
    strlcpy(g^.path, txt, 256);
    GT_GetGadgetAttrs (g^.imgpathgad, g^.win, nil, [TAG_(GTST_String), TAG_(@txt)       , TAG_END]);
    strlcpy(g^.imgpath, txt, 256);
    GT_GetGadgetAttrs (g^.delaygad  , g^.win, nil, [TAG_(GTIN_Number), TAG_(@g^.delay)  , TAG_END]);
    GT_GetGadgetAttrs (g^.hotkey1gad, g^.win, nil, [TAG_(GTST_String), TAG_(@txt)       , TAG_END]);
    strlcpy(g^.hotkey1, txt, 256);
    GT_GetGadgetAttrs (g^.hotkey2gad, g^.win, nil, [TAG_(GTST_String), TAG_(@txt)       , TAG_END]);
    strlcpy(g^.hotkey2, txt, 256);
  end;

  if assigned(g^.win) then
  begin
    CloseWindow(g^.win);
    g^.win := nil;
  end;

  if assigned(g^.glist) then
  begin
    FreeGadgets(g^.glist);
    g^.glist := nil;
  end;

  if assigned(g^.visualinfo) then
  begin
    FreeVisualInfo(g^.visualinfo);
    g^.visualinfo := nil;
  end;

  if assigned(g^.scr) then
  begin
    UnlockPubScreen(nil, g^.scr);
    g^.scr := nil;
  end;
end;

//*-------------------------------------------------------------------------*/
//* Rahmen mit Überschrift zeichnen                                            */
//*-------------------------------------------------------------------------*/

procedure draw_group_frame(rp: PRastPort; x: LongInt; y: LongInt; w: LongInt; h: LongInt; txt: PChar; vi: APTR);
var
  len   : LongInt;
  tx,ty : LongInt;
begin
  DrawBevelBox(rp, x, y, w, h, [TAG_(GTBB_FrameType), BBFT_RIDGE, TAG_(GTBB_Recessed), TAG_(TRUE), TAG_(GT_VisualInfo), TAG_(vi), TAG_END]);

  if assigned(txt) then
  begin
    len := strlen(txt);
    tx := x + (w - TextLength(rp, txt, len)) div 2;
    ty := y - (rp^.TxHeight - 2) div 2 + rp^.TxBaseline;
    SetABPenDrMd(rp, 1, 0, JAM2);
    GfxMove(rp, tx+1, ty+1);
    GfxText(rp, txt, len);
    SetABPenDrMd(rp, 2, 0, JAM1);
    GfxMove(rp, tx, ty);
    GfxText(rp, txt, len);
  end;
end;

//*-------------------------------------------------------------------------*/
//* Open window                                                             */
//*-------------------------------------------------------------------------*/

function  open_window(g: Pgui): boolean;
const
  labels1       : array[0..5] of STRPTR = ('Mask','Default','Simple','Good','Very good', nil);
  labels2       : array[0..5] of STRPTR = ('Mask','Default','Icon','Image','Exact', nil);
  labels3       : array[0..5] of STRPTR = ('Mask','Tiled','Centered','Modified','Good modified', nil);
var
  gad           : PGadget;
  ng            : TNewGadget;
  fontw,fonth   : LongInt;
  winw,winh     : LongInt;
  bevel1_x,bevel1_y,bevel1_w,bevel1_h: SmallInt;
  bevel2_x,bevel2_y,bevel2_w,bevel2_h: SmallInt;
  bevel3_x,bevel3_y,bevel3_w,bevel3_h: SmallInt;
begin
  ng := default(TNewgadget);

  if assigned(g^.win)
    then exit(TRUE);

  if SetAndTest(g^.scr, LockPubScreen(nil)) then
  begin
    g^.visualinfo := GetVisualInfo(g^.scr, [TAG_END, TAG_END]);

    fontw := g^.scr^.RastPort.TxWidth;
    fonth := g^.scr^.RastPort.TxHeight;

    gad := CreateContext (@g^.glist);

    bevel1_x := g^.scr^.WBorLeft + 4;
    bevel1_y := g^.scr^.WBorTop  + fonth * 3 div 2 + 3;

    ng.ng_VisualInfo  := g^.visualinfo;
    ng.ng_TextAttr    := g^.scr^.Font;
    ng.ng_LeftEdge    := bevel1_x + 8 + 13 * fontw;
    ng.ng_TopEdge     := bevel1_y + 6 + fonth div 2;
    ng.ng_Width       := 15 * fontw;
    ng.ng_Height      := fonth + 6;
    ng.ng_GadgetText  := 'Shading';
    gad := CreateGadget(CYCLE_KIND, gad, @ng, [TAG_(GTCY_Labels), TAG_(@labels1), TAG_(GTCY_Active), TAG_(g^.shading), TAG_END]);
    g^.shadinggad := gad;

    ng.ng_TopEdge     := ng.ng_TopEdge + ng.ng_Height + 4;
    ng.ng_GadgetText  := 'Colours';
    gad := CreateGadget(CYCLE_KIND, gad, @ng, [TAG_(GTCY_Labels), TAG_(@labels2), TAG_(GTCY_Active), TAG_(g^.quality), TAG_END]);
    g^.qualitygad := gad;

    ng.ng_TopEdge     := ng.ng_TopEdge + ng.ng_Height + 4;
    ng.ng_GadgetText  := 'Position';
    gad := CreateGadget(CYCLE_KIND, gad, @ng, [TAG_(GTCY_Labels), TAG_(@labels3), TAG_(GTCY_Active), TAG_(g^.view), TAG_END]);
    g^.viewgad := gad;

    bevel1_w := ng.ng_LeftEdge + ng.ng_Width  + 8 - bevel1_x;
    bevel1_h := ng.ng_TopEdge  + ng.ng_Height + 6 - bevel1_y;

    bevel2_x := bevel1_x + bevel1_w + 4;
    bevel2_y := bevel1_y;

    ng.ng_LeftEdge    := bevel2_x + 8 + 9 * fontw;
    ng.ng_TopEdge     := bevel2_y + 6 + fonth div 2;
    ng.ng_Width       := 21 * fontw;
    ng.ng_GadgetText  := 'Server';
    gad := CreateGadget(STRING_KIND, gad, @ng, [TAG_(GTST_String), TAG_(@g^.server), TAG_END]);
    g^.servergad := gad;

    ng.ng_TopEdge     := ng.ng_TopEdge + ng.ng_Height + 4;
    ng.ng_GadgetText  := 'Path';
    gad := CreateGadget(STRING_KIND, gad, @ng, [TAG_(GTST_String), TAG_(@g^.path), TAG_END]);
    g^.pathgad := gad;

    ng.ng_TopEdge     := ng.ng_TopEdge + ng.ng_Height + 4;
    ng.ng_GadgetText  := 'Imagepath';
    gad := CreateGadget(STRING_KIND, gad, @ng, [TAG_(GTST_String), TAG_(@g^.imgpath), TAG_END]);
    g^.imgpathgad := gad;

    bevel2_w := ng.ng_LeftEdge + ng.ng_Width  + 8 - bevel2_x;
    bevel2_h := ng.ng_TopEdge  + ng.ng_Height + 6 - bevel2_y;

    bevel3_x := bevel1_x;
    bevel3_y := bevel1_y + bevel1_h + 4 + fonth div 2;

    ng.ng_LeftEdge    := bevel3_x + 8 + 24 * fontw + 20;
    ng.ng_TopEdge     := bevel3_y + 6 + fonth div 2;
    ng.ng_Width       := 22 * fontw;
    ng.ng_GadgetText  := 'Time delay';
    gad := CreateGadget(INTEGER_KIND, gad, @ng, [TAG_(GTIN_Number), TAG_(g^.delay), TAG_(STRINGA_Justification), TAG_(GACT_STRINGCENTER), TAG_END]);
    g^.delaygad := gad;

    ng.ng_TopEdge     := ng.ng_TopEdge + ng.ng_Height + 4;
    ng.ng_GadgetText  := 'Hotkey abort';
    gad := CreateGadget(STRING_KIND, gad, @ng, [TAG_(GTST_String), TAG_(@g^.hotkey1), TAG_(STRINGA_Justification), TAG_(GACT_STRINGCENTER), TAG_END]);
    g^.hotkey1gad := gad;

    ng.ng_TopEdge     := ng.ng_TopEdge + ng.ng_Height + 4;
    ng.ng_GadgetText  := 'Hotkey Update';
    gad := CreateGadget(STRING_KIND, gad, @ng, [TAG_(GTST_String), TAG_(@g^.hotkey2), TAG_(STRINGA_Justification), TAG_(GACT_STRINGCENTER), TAG_END]);
    g^.hotkey2gad := gad;

    bevel3_w := ng.ng_LeftEdge + ng.ng_Width  + 8 - bevel3_x + 12 * fontw;
    bevel3_h := ng.ng_TopEdge  + ng.ng_Height + 6 - bevel3_y;

    ng.ng_LeftEdge    := bevel3_x;
    ng.ng_TopEdge     := bevel3_y + bevel3_h + 4;
    ng.ng_Width       := (bevel3_w - 12 + 2) div 4;
    ng.ng_GadgetText  := 'Stop';
    ng.ng_GadgetID    := GID_QUIT;
    gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_END, TAG_END]);

    ng.ng_LeftEdge    := ng.ng_LeftEdge + ng.ng_Width + 4;
    ng.ng_GadgetText  := 'Save';
    ng.ng_GadgetID    := GID_SAVE;
    gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_END, TAG_END]);

    ng.ng_LeftEdge    := ng.ng_LeftEdge + ng.ng_Width + 4;
    ng.ng_GadgetText  := 'Load';
    ng.ng_GadgetID    := GID_LOAD;
    gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_END, TAG_END]);

    ng.ng_LeftEdge    := ng.ng_LeftEdge + ng.ng_Width + 4;
    ng.ng_GadgetText  := 'Background';
    ng.ng_GadgetID    := GID_ICONIFY;
    gad := CreateGadget(BUTTON_KIND, gad, @ng, [TAG_END, TAG_END]);

    if assigned(gad) then
    begin

      winw := ng.ng_LeftEdge + ng.ng_Width + 4 + g^.scr^.WBorRight;
      winh := ng.ng_TopEdge + ng.ng_Height + 4 + g^.scr^.WBorBottom;

      if SetAndTest(g^.win, OpenWindowTags( nil,
      [
        TAG_(WA_Left)     , (g^.scr^.Width  - winw) div 2,
        TAG_(WA_Top)      , (g^.scr^.Height - winh) div 2,
        TAG_(WA_Width)    , winw,
        TAG_(WA_Height)   , winh,
        TAG_(WA_Title)    , TAG_(PChar('WebGround Prefs')),
        TAG_(WA_Flags)    , WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_ACTIVATE,
        TAG_(WA_IDCMP)    , IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_REFRESHWINDOW or CYCLEIDCMP or STRINGIDCMP or BUTTONIDCMP,
        TAG_(WA_Gadgets)  , TAG_(g^.glist),
        TAG_END
      ])) then
      begin
        GT_RefreshWindow(g^.win, nil);

        SetFont(g^.win^.RPort, g^.scr^.RastPort.Font);

        draw_group_frame(g^.win^.RPort, bevel1_x, bevel1_y, bevel1_w, bevel1_h, PChar(' Background image '), ng.ng_VisualInfo);
        draw_group_frame(g^.win^.RPort, bevel2_x, bevel2_y, bevel2_w, bevel2_h, PChar(' Network ')         , ng.ng_VisualInfo);
        draw_group_frame(g^.win^.RPort, bevel3_x, bevel3_y, bevel3_w, bevel3_h, PChar(' Options ')         , ng.ng_VisualInfo);

        exit(TRUE);
      end;
    end;
  end;

  close_window(g);
  result := (FALSE);
end;


//*----------------------------------------------------------------------------*/
//* AppIcon entfernen                                                          */
//*----------------------------------------------------------------------------*/

procedure delete_appicon(g: Pgui);
var
  msg   : PMessage;
begin
  if assigned(g^.appicon) then
  begin
    while not(RemoveAppIcon(g^.appicon)) do
    begin
      while SetAndTest(msg, GetMsg(g^.appport))
        do ReplyMsg (msg);
      DOSDelay(1);
    end;
    g^.appicon := nil;
  end;

  if assigned(g^.appport) then
  begin
    while SetAndTest(msg, GetMsg(g^.appport))
      do ReplyMsg(msg);
    DeleteMsgPort(g^.appport);
    g^.appport := nil;
  end;

  if assigned(g^.diskobj) then
  begin
    FreeDiskObject(g^.diskobj);
    g^.diskobj := nil;
  end;
end;

//*----------------------------------------------------------------------------*/
//* AppIcon anlegen                                                            */
//*----------------------------------------------------------------------------*/

function  create_appicon(g: Pgui): boolean;
begin
  if SetAndTest(g^.appport, CreateMsgPort() ) then
  begin
    if SetAndTest(g^.diskobj, GetDiskObjectNew('iconify')) then
    begin
      g^.diskobj^.do_CurrentX := LongInt(NO_ICON_POSITION);
      g^.diskobj^.do_CurrentY := LongInt(NO_ICON_POSITION);
      if SetAndTest(g^.appicon, AddAppIcon(0, 0, PChar('Iconify'), g^.appport, BPTR(0), g^.diskobj, [TAG_END, TAG_END])) then
      begin
        exit(TRUE);
      end;
    end;
  end;

  delete_appicon(g);
  result := (FALSE);
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  g         : Tgui;
  cont      : boolean;
  appsig    : ULONG;
  winsig    : ULONG;
  sigs      : ULONG;

  imsg      : PIntuiMessage;
  iconif    : boolean;
  
  appmsg    : PAppMessage;
  uniconify : Boolean;
begin
  g := default(Tgui);

  g.shading := 2;
  g.quality := 3;
  g.view    := 3;
  g.delay   := 30;

  if (open_window(@g)) then
  begin
    cont := true;

    while cont do
    begin
      if assigned(g.appport) then appsig := 1 shl g.appport^.mp_SigBit else appsig := 0;
      if assigned(g.win) then winsig := 1 shl g.win^.UserPort^.mp_SigBit else winsig := 0;

      sigs := Wait(winsig or appsig or SIGBREAKF_CTRL_C);

      if (sigs and SIGBREAKF_CTRL_C <> 0)
        then cont := FALSE;

      if (sigs and winsig <> 0) then
      begin
        iconif := FALSE;

        while SetAndTest(imsg, GT_GetIMsg(g.win^.UserPort)) do
        begin
          case (imsg^.IClass) of
            IDCMP_GADGETUP:
            begin
              case (PGadget(imsg^.IAddress)^.GadgetID) of
                GID_ICONIFY:
                begin
                  iconif := true;
                end;
                GID_QUIT :
                begin
                  cont := false;
                end;
              end; // case
            end;
            IDCMP_REFRESHWINDOW:
            begin
              GT_BeginRefresh(g.win);
              GT_EndRefresh(g.win, LongInt(TRUE));
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
          end; // case imsg
          GT_ReplyIMsg (imsg);
        end;

        if (iconif) then
        begin
          if (create_appicon(@g))
          then close_window(@g)
          else DisplayBeep(nil);
        end;
      end;

      if (sigs and appsig <> 0) then
      begin
        uniconify := FALSE;

        while SetAndTest(appmsg, PAppMessage(GetMsg(g.appport))) do
        begin
          uniconify := TRUE;
          ReplyMsg(PMessage(appmsg));
        end;

        if (uniconify) then
        begin
          if (open_window(@g))
          then delete_appicon(@g)
          else DisplayBeep(nil);
        end;
      end;  // sigs

    end; // while cont
  end
  else
    WriteLn('cannot open window');

  close_window(@g);
  delete_appicon(@g);

  result := (RETURN_OK);
end;

//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/
// open: workbench, icon, graphics, intuiton, gadtools

Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  GfxBase := OpenLibrary(GRAPHICSNAME, 0);
  if not assigned(GfxBase) then Exit;
  {$ENDIF}
  {$IF DEFINED(MORPHOS)}
  IntuitionBase := OpenLibrary(INTUITIONNAME, 0);
  if not assigned(IntuitionBase) then Exit;
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  WorkBenchBase := OpenLibrary(WORKBENCHNAME, 0);
  if not assigned(WorkBenchBase) then Exit;

  IconBase := OpenLibrary(ICONNAME, 0);
  if not assigned(IconBase) then Exit;

  GadToolsBase := OpenLibrary(GADTOOLSNAME, 0);
  if not assigned(GadToolsBase) then Exit;
  {$ENDIF}

  Result := True;
end;


Procedure CloseLibs;
begin
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  if assigned(GadToolsBase)  then CloseLibrary(pLibrary(GadToolsBase));
  if assigned(IconBase)      then CloseLibrary(pLibrary(IconBase));
  if assigned(WorkBenchBase) then CloseLibrary(pLibrary(WorkbenchBase));
  {$ENDIF}
  {$IF DEFINED(MORPHOS)}
  if assigned(IntuitionBase) then CloseLibrary(pLibrary(IntuitionBase));
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  if assigned(GfxBase)       then CloseLibrary(pLibrary(GfxBase));
  {$ENDIF}
end;


begin
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
end.
