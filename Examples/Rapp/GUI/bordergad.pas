program bordergad;

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
  Project : bordergad
  Topic   : How to add gadgets to window borders
  Author  : Thomas Rapp 
  Source  : http://thomas-rapp.homepage.t-online.de/examples/bordergad.c
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
//*                                                                         */
//*-------------------------------------------------------------------------*/

Uses
  Exec, AmigaDOS, AGraphics, Intuition, Gadtools, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;

//*-------------------------------------------------------------------------*/
//*                                                                         */
//*-------------------------------------------------------------------------*/

Const
  GID_UP        = 1003;
  GID_DOWN      = 1004;
  GID_LEFT      = 1005;
  GID_RIGHT     = 1006;
  GID_TEXT      = 1007;


//*-------------------------------------------------------------------------*/
//* Main program                                                            */
//*-------------------------------------------------------------------------*/

function  main: integer;
var
  scr       : PScreen;
  win       : pWindow;
  imsg      : PIntuiMessage;  
  upimg     : PImage;
  downimg   : PImage;
  leftimg   : PImage;
  rightimg  : PImage;
  textimg   : PImage;
  upgad     : PGadget;
  downgad   : PGadget;
  leftgad   : Pgadget;
  rightgad  : PGadget;
  textgad   : PGadget;
  drawinfo  : PDrawInfo;
  wbortop   : SmallInt;
  cont      : Boolean;
  sizew, sizeh  : SmallInt;
  itext     : TIntuiText = 
  (
    FrontPen: 1; BackPen: 0; DrawMode: JAM1; LeftEdge: 0; TopEdge: 0; ITextFont: nil; IText: 'Place some text here'; Nexttext: nil
  );
begin
  if SetAndTest(scr, LockPubScreen(nil)) then
  begin
    drawinfo := GetScreenDrawInfo(scr);

    upimg    := NewObject(nil, 'sysiclass'  , [TAG_(SYSIA_Which), UPIMAGE   , TAG_(SYSIA_DrawInfo), TAG_(drawinfo), TAG_(SYSIA_Size), TAG_(SYSISIZE_MEDRES), TAG_END]);
    downimg  := NewObject(nil, 'sysiclass'  , [TAG_(SYSIA_Which), DOWNIMAGE , TAG_(SYSIA_DrawInfo), TAG_(drawinfo), TAG_(SYSIA_Size), TAG_(SYSISIZE_MEDRES), TAG_END]);
    leftimg  := NewObject(nil, 'sysiclass'  , [TAG_(SYSIA_Which), LEFTIMAGE , TAG_(SYSIA_DrawInfo), TAG_(drawinfo), TAG_(SYSIA_Size), TAG_(SYSISIZE_MEDRES), TAG_END]);
    rightimg := NewObject(nil, 'sysiclass'  , [TAG_(SYSIA_Which), RIGHTIMAGE, TAG_(SYSIA_DrawInfo), TAG_(drawinfo), TAG_(SYSIA_Size), TAG_(SYSISIZE_MEDRES), TAG_END]);
    textimg  := NewObject(nil, 'itexticlass', [TAG_(IA_Data)    , TAG_(@itext), TAG_(IA_Left),0,TAG_(IA_Top),0,TAG_(IA_FGPen),1,TAG_END]);

    sizew := upimg^.Width;
    sizeh := leftimg^.Height;

    wbortop := scr^.WBorTop + scr^.RastPort.TxHeight + 1;

    upgad   := NewObject(nil, 'buttongclass',
    [
      TAG_(GA_ID)          , GID_UP,
      TAG_(GA_Image)       , TAG_(upimg),
      TAG_(GA_RelRight)    , 1 - upimg^.Width,
      TAG_(GA_Top)         , wbortop,
      TAG_(GA_RightBorder) , TAG_(TRUE),
      TAG_END
    ]);

    downgad  := NewObject(nil, 'buttongclass',
    [
      TAG_(GA_ID)          , GID_DOWN,
      TAG_(GA_Previous)    , TAG_(upgad),
      TAG_(GA_Image)       , TAG_(downimg),
      TAG_(GA_RelRight)    , 1 - downimg^.Width,
      TAG_(GA_RelBottom)   , 1 - sizeh - downimg^.Height,
      TAG_(GA_RightBorder) , TAG_(TRUE),
      TAG_END
    ]);

    leftgad  := NewObject(nil,'buttongclass',
    [
      TAG_(GA_ID)           , GID_LEFT,
      TAG_(GA_Previous)     , TAG_(downgad),
      TAG_(GA_Image)        , TAG_(leftimg),
      TAG_(GA_Left)         , scr^.WBorLeft,
      TAG_(GA_RelBottom)    , 1 - leftimg^.Height,
      TAG_(GA_BottomBorder) , TAG_(TRUE),
      TAG_END
    ]);

    rightgad := NewObject(nil, 'buttongclass',
    [
      TAG_(GA_ID)           , GID_RIGHT,
      TAG_(GA_Previous)     , TAG_(leftgad),
      TAG_(GA_Image)        , TAG_(rightimg),
      TAG_(GA_RelRight)     , 1 - sizew - rightimg^.Width,
      TAG_(GA_RelBottom)    , 1 - rightimg^.Height,
      TAG_(GA_BottomBorder) , TAG_(TRUE),
      TAG_END
    ]);

    textgad := NewObject(nil, 'buttongclass',
    [
      TAG_(GA_ID)           , GID_TEXT,
      TAG_(GA_Previous)     , TAG_(rightgad),
      TAG_(GA_DrawInfo)     , TAG_(drawinfo),
      TAG_(GA_Image)        , TAG_(textimg),
      TAG_(GA_Left)         , scr^.WBorLeft + leftimg^.Width + 8,
      TAG_(GA_RelBottom)    , 1 - scr^.RastPort.TxHeight,
      TAG_(GA_BottomBorder) , TAG_(TRUE),
      TAG_END
    ]);

    if SetAndTest(win, OpenWindowTags(nil,
    [
      TAG_(WA_Title)        , TAG_(PChar('Border Gadgets')),
      TAG_(WA_Left)         , scr^.Width div 4,
      TAG_(WA_Top)          , scr^.Height div 4,
      TAG_(WA_Width)        , scr^.Width div 2,
      TAG_(WA_Height)       , scr^.Height div 2,
      TAG_(WA_Flags)        , WFLG_CLOSEGADGET or WFLG_DRAGBAR or WFLG_DEPTHGADGET or WFLG_SIZEGADGET or WFLG_SIZEBBOTTOM or WFLG_SIZEBRIGHT or WFLG_ACTIVATE,
      TAG_(WA_IDCMP)        , IDCMP_CLOSEWINDOW or IDCMP_VANILLAKEY,
      TAG_(WA_MinWidth)     , 100,
      TAG_(WA_MinHeight)    , 100,
      TAG_(WA_MaxWidth)     , $7fff,
      TAG_(WA_MaxHeight)    , $7fff,
      TAG_(WA_Gadgets)      , TAG_(upgad),
      TAG_END
    ])) then
    begin

      cont := TRUE;
      while cont do
      begin
        if (Wait ((1 shl win^.UserPort^.mp_SigBit) or SIGBREAKF_CTRL_C) and SIGBREAKF_CTRL_C) <> 0
            then cont := FALSE;

        while SetAndTest(imsg, PIntuiMessage(GetMsg(win^.UserPort))) do
        begin
          case (imsg^.IClass) of
            IDCMP_VANILLAKEY:
              if (imsg^.Code = $1b) //* Esc */
              then cont := FALSE;
            IDCMP_CLOSEWINDOW:
              cont := FALSE;
          end;
          ReplyMsg(PMessage(imsg));
        end;
      end;

      CloseWindow(win);
    end;

    DisposeObject(textgad);
    DisposeObject(rightgad);
    DisposeObject(leftgad);
    DisposeObject(downgad);
    DisposeObject(upgad);

    DisposeObject(textimg);
    DisposeObject(rightimg);
    DisposeObject(leftimg);
    DisposeObject(downimg);
    DisposeObject(upimg);

    FreeScreenDrawInfo(scr, drawinfo);

    UnlockPubScreen(nil, scr);
  end;

  result := (RETURN_OK);
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
