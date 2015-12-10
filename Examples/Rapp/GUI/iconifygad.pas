program iconifygad;

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
  Project : iconifygad
  Topic   : BOOPSI Image for displaying an Iconify symbol
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/iconifygad.c
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
  Exec, AmigaDOS, AGraphics, Intuition, Gadtools, Utility,
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  amigalib,
  {$ENDIF}
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;

Type
  PUWord = ^UWORD;

//*-------------------------------------------------------------------------*/
//* Constants & macro's                                                     */
//*-------------------------------------------------------------------------*/

const
  GID_ICONIFY  = 1001;

//*-------------------------------------------------------------------------*/
//* Type definitions                                                        */
//*-------------------------------------------------------------------------*/

Type
  Piconifyimg_data = ^Ticonifyimg_data;
  Ticonifyimg_data = 
  record
    drawinfo    : PDrawInfo;
  end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function  iconifyimg_set(cl: PIClass; o: PImage; msg: PopSet; initial: boolean): ULONG;
var
  tags, ti  : PTagItem;
  data      : Piconifyimg_data;
  retval    : ULONG;
begin
  data := Piconifyimg_data(INST_DATA(cl, o));
  retval := 0;

  If not(initial)
    then retval := DoSuperMethodA(cl, PObject_(o), msg);

  tags := msg^.ops_AttrList;
  while SetAndTest(ti, NextTagItem(@tags)) do
  begin
    case (ti^.ti_Tag) of
      SYSIA_DrawInfo:
      begin
        data^.drawinfo := PDrawInfo(ti^.ti_Data);
        retval := 1;
      end;
    end;
  end;

  result := (retval);
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function  iconifyimg_draw(cl: PIClass; o: PImage; msg: PimpDraw): ULONG;
var
  data      : Piconifyimg_data;
  left, 
  top, 
  right, 
  bottom    : LongInt;
  x0, y0,
  x1,y1     : LongInt;
  rp        : PRastPort;
  dri       : PDrawInfo;
  _bgpen, _linepen, _fillpen, _shinepen, _shadowpen: UBYTE;
  active    : boolean;
begin  
  data := Piconifyimg_data(INST_DATA(cl, o));
  left   := o^.LeftEdge + msg^.imp_Offset.X - 1;
  top    := o^.TopEdge  + msg^.imp_Offset.Y;
  right  := left + o^.Width  - 1;
  bottom := top  + o^.Height - 1;

  rp := msg^.imp_RPort;
  if (msg^.imp_DrInfo <> nil) then dri := msg^.imp_DrInfo else dri := data^.drawinfo;


  case (msg^.imp_State) of
    IDS_NORMAL:
    begin
      _bgpen     := PUWORD(dri^.dri_Pens)[FILLPEN];
      _linepen   := PUWORD(dri^.dri_Pens)[SHADOWPEN];
      _fillpen   := PUWORD(dri^.dri_Pens)[SHINEPEN];
      _shinepen  := PUWORD(dri^.dri_Pens)[SHINEPEN];
      _shadowpen := PUWORD(dri^.dri_Pens)[SHADOWPEN];
      active    := FALSE;
    end;
    IDS_SELECTED:
    begin
      _bgpen     := PUWORD(dri^.dri_Pens)[FILLPEN];
      _linepen   := PUWORD(dri^.dri_Pens)[SHADOWPEN];
      _fillpen   := PUWORD(dri^.dri_Pens)[SHINEPEN];
      _shinepen  := PUWORD(dri^.dri_Pens)[SHADOWPEN];
      _shadowpen := PUWORD(dri^.dri_Pens)[SHINEPEN];
      active    := TRUE;
    end;
    IDS_INACTIVENORMAL:
    begin
      _bgpen     := PUWORD(dri^.dri_Pens)[BACKGROUNDPEN];
      _linepen   := PUWORD(dri^.dri_Pens)[SHADOWPEN];
      _fillpen   := PUWORD(dri^.dri_Pens)[BACKGROUNDPEN];
      _shinepen  := PUWORD(dri^.dri_Pens)[SHINEPEN];
      _shadowpen := PUWORD(dri^.dri_Pens)[SHADOWPEN];
      active    := FALSE;
    end;
    IDS_INACTIVESELECTED:
    begin
      _bgpen     := PUWORD(dri^.dri_Pens)[BACKGROUNDPEN];
      _linepen   := PUWORD(dri^.dri_Pens)[SHADOWPEN];
      _fillpen   := PUWORD(dri^.dri_Pens)[BACKGROUNDPEN];
      _shinepen  := PUWORD(dri^.dri_Pens)[SHADOWPEN];
      _shadowpen := PUWORD(dri^.dri_Pens)[SHINEPEN];
      active    := TRUE;
    end;
  end;

  SetAPen(rp, _bgpen);
  RectFill(rp, left, top, right, bottom);

  SetAPen(rp, _linepen);
  GfxMove(rp, left, top);
  Draw(rp, left, bottom);

  inc(left);

  GfxMove(rp, left, bottom);
  SetAPen(rp, _shinepen);
  Draw(rp, left, top);
  Draw(rp, right, top);
  SetAPen(rp, _shadowpen);
  Draw(rp, right, bottom);
  Draw(rp, left, bottom);

  if (active) then
  begin
    x0 := left + ( 4 * o^.Width  + 11) div 22;
    y0 := top  + ( 7 * o^.Height + 11) div 22;
    x1 := left + (11 * o^.Width  + 11) div 22;
    y1 := top  + (16 * o^.Height + 11) div 22;

    SetAPen(rp, _linepen);
    GfxMove(rp, x0, y1);
    Draw(rp, x0, y0);
    Draw(rp, x1, y0);
    Draw(rp, x1, y1);
    Draw(rp, x0, y1);
  end
  else
  begin
    x0 := left + ( 4 * o^.Width  + 11) div 22;
    y0 := top  + ( 4 * o^.Height + 11) div 22;
    x1 := left + (16 * o^.Width  + 11) div 22;
    y1 := top  + (16 * o^.Height + 11) div 22;

    SetAPen(rp, _linepen);
    GfxMove(rp, x0, y1);
    Draw(rp, x0, y0);
    Draw(rp, x1, y0);
    Draw(rp, x1, y1);
    Draw(rp, x0, y1);
  end;

  x0 := left + ( 6 * o^.Width  + 11) div 22;
  y0 := top  + (10 * o^.Height + 11) div 22;
  x1 := left + ( 9 * o^.Width  + 11) div 22;
  y1 := top  + (14 * o^.Height + 11) div 22;

  SetAPen(rp, _fillpen);
  RectFill(rp, x0, y0, x1, y1);

  SetAPen(rp, _linepen);
  GfxMove(rp, x0, y1);
  Draw(rp, x0, y0);
  Draw(rp, x1, y0);
  Draw(rp, x1, y1);
  Draw(rp, x0, y1);

  result := (0);
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function  iconifyimg_new(cl: PIClass; o: PImage; msg: PopSet): ULONG;
var
  retval : PImage = nil;
begin
  if SetAndTest(retval, PImage(DoSuperMethodA(cl, PObject_(o), msg))) then
  begin
    retval^.Width := 22;

    iconifyimg_set(cl, retval, msg, TRUE);
  end;

  result := ULONG(retval);
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function  iconifyimg_dispatcher(cl: PIClass; o: PObject_; msg: PMsg): ULONG;
var
  retval : ULONG = 0;
begin
  case (msg^.MethodID) of
    OM_NEW  : retval := iconifyimg_new(cl, PImage(o), PopSet(msg));
    OM_SET  : retval := iconifyimg_set(cl, PImage(o), PopSet(msg),FALSE);
    IM_DRAW : retval := iconifyimg_draw(cl, PImage(o),PimpDraw(msg));
    else      retval := DoSuperMethodA(cl, o, msg);
  end;
  result := (retval);
end;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

function  init_iconifyimg_class: PIClass;
var
  cl : PIClass;
begin
  if SetAndTest(cl, MakeClass(nil, 'imageclass', nil, sizeof(Ticonifyimg_data), 0)) then
  begin
    //cl^.cl_Dispatcher.h_Entry    := (HOOKFUNC)HookEntry;
    //cl^.cl_Dispatcher.h_SubEntry := (HOOKFUNC)iconifyimg_dispatcher;
    InitHook(cl^.cl_Dispatcher, THookFunction(@iconifyimg_dispatcher), nil);
  end;

  result := (cl);
end;

//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/


function  main: integer;
var
  scr               : PScreen;
  win               : PWindow;
  imsg              : PIntuiMessage;
  cont              : boolean;
  drawinfo          : PDrawInfo;
  iconifyimg        : PImage;
  iconifygad        : PGadget;
  iconifyimg_class  : PIClass;
const
  GFLG_RELFLAGS     = (GFLG_RELRIGHT or GFLG_RELBOTTOM or GFLG_RELWIDTH or GFLG_RELHEIGHT);
var
  gad               : PGadget;
  x                 : LongInt = 0;
begin
  iconifyimg_class := init_iconifyimg_class;
  if not assigned(iconifyimg_class) then
  begin
    WriteLn('cannot initialize BOOPSI image class');
    exit(RETURN_FAIL);
  end;

  if SetAndTest(scr, LockPubScreen(nil)) then
  begin
    drawinfo := GetScreenDrawInfo(scr);

    iconifyimg := NewObject(iconifyimg_class, nil,
    [
      TAG_(SYSIA_DrawInfo)  , TAG_(drawinfo),
//      TAG_(SYSIA_Size)      , TAG_(SYSISIZE_MEDRES),
//      TAG_(SYSIA_Which)     , TAG_(ZOOMIMAGE),
      TAG_(IA_Height)       , scr^.WBorTop + scr^.RastPort.TxHeight + 1,
      TAG_END
    ]);

    iconifygad := NewObject(nil, BUTTONGCLASS,
    [
      TAG_(GA_TopBorder)  , TAG_(TRUE),
      TAG_(GA_Image)      , TAG_(iconifyimg),
      TAG_(GA_ID)         , GID_ICONIFY,
      TAG_(GA_RelVerify)  , TAG_(TRUE),
      TAG_END
    ]);

    if SetAndTest(win, OpenWindowTags(nil,
    [
      TAG_(WA_Left)       , scr^.Width div 8,
      TAG_(WA_Top)        , scr^.Height div 8,
      TAG_(WA_Width)      , scr^.Width div 4,
      TAG_(WA_Height)     , scr^.Height div 4,
      TAG_(WA_PubScreen)  , TAG_(scr),
      TAG_(WA_Flags)      , WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_SIZEGADGET or WFLG_DEPTHGADGET or WFLG_ACTIVATE or WFLG_NOCAREREFRESH,
      TAG_(WA_IDCMP)      , IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY or IDCMP_GADGETUP,
      TAG_(WA_MinWidth)   , 120,
      TAG_(WA_MinHeight)  , 80,
      TAG_(WA_MaxWidth)   , $7fff,
      TAG_(WA_MaxHeight)  , $7fff,
      TAG_END
    ])) then
    begin
      gad := win^.FirstGadget;
      while assigned(gad) do
      begin
        if ( (gad^.Flags and GFLG_RELFLAGS) = GFLG_RELRIGHT)
        then if (gad^.LeftEdge < x)
          then x := gad^.LeftEdge;
      
        gad := gad^.NextGadget;
      end;

      SetAttrs(iconifygad, [TAG_(GA_RelRight), x - iconifygad^.Width + 1, TAG_END]);
      AddGadget(win, iconifygad, 0);
      RefreshGList(iconifygad, win, nil, 1);

      cont := true;

      while cont do
      begin
        if (Wait((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
        then cont := FALSE;

        while SetAndTest(imsg, GetMsg(win^.UserPort)) do
        begin
          case (imsg^.IClass) of
            IDCMP_GADGETUP:
            begin
              case (PGadget(imsg^.IAddress)^.GadgetID) of
                GID_ICONIFY:
                begin
                  Writeln('iconify');
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
          end; // case imsg
          ReplyMsg(PMessage(imsg));
        end;
      end;

      CloseWindow (win);
    end;

    DisposeObject(iconifygad);
    DisposeObject(iconifyimg);

    FreeScreenDrawInfo(scr, drawinfo);
    UnlockPubScreen(nil, scr);
  end;

  FreeClass(iconifyimg_class);

  result := (0);
end;

//*-------------------------------------------------------------------------*/
//* End of original source text                                             */
//*-------------------------------------------------------------------------*/

Function OpenLibs: boolean;
begin
  Result := False;

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  GfxBase := OpenLibrary(GRAPHICSNAME, 0);
  if not assigned(GfxBase) then Exit;
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
  if assigned(GfxBase) then CloseLibrary(pLibrary(GfxBase));
  {$ENDIF}
end;


begin
  if OpenLibs 
  then ExitCode := Main
  else ExitCode := 10;

  CloseLibs;
end.
