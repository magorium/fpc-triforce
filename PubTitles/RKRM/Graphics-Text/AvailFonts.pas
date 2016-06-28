program AvailFonts;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : AvailFonts
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

Uses
  Exec, AmigaDOS, AGraphics, Layers, Intuition, diskfont, Utility,
  {$IFDEF AMIGA}
  SystemVartags,
  {$ENDIF}  
  CHelpers,
  Trinity;

  { FPC Note: some helper types }
Type
  pUWORD = ^UWORD;


Const
  vers : PChar = #0'$VER: AvailFonts 36.3';

Type
  Tstringstruct = record
    str         : PChar;
    charcount   : LONG;
    stringwidth : WORD;
  end;

Const
  alphabetstring    : PChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
Var
  fname, fheight, 
  XDPI, YDPI, 
  entrynum          : Tstringstruct;
  mywin             : PWindow;
  mycliprp          : PRastport;
  myrp              : TRastPort;
  myrect            : TRectangle;
  new_region, 
  old_region        : PRegion;
  mydrawinfo        : PDrawInfo;
  afh               : PAvailFontsHeader;
  fontheight, 
  alphabetcharcount : LONG;
  stringwidth       : WORD;



  function   StrLen(str: PChar): ULONG; forward;
  procedure  MainLoop; forward;
  

Procedure Main(argc: integer; argv: PPChar);
var
  defaultfont       : PTextFont = nil;
  defaultfontattr   : TTextAttr = (ta_Name: 'topaz.font'; ta_YSize: 9; ta_style: 0; ta_flags: 0);
  afsize, 
  afshortage, 
  cliprectside      : LONG;
begin
  fname.str    := 'Font Name:  ';
  fheight.str  := 'Font Height:  ';
  XDPI.str     := 'X DPI:  ';
  YDPI.str     := 'Y DPI:  ';
  entrynum.str := 'Entry #:  ';

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if SetAndTest(DiskfontBase, OpenLibrary('diskfont.library', 37)) then //* Open the libraries. */
  {$ENDIF}
  begin
    {$IFDEF MORPHOS}
    if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
    {$ENDIF}
    begin
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      if SetAndTest(GfxBase, OpenLibrary('graphics.library', 37)) then
      {$ENDIF}
      begin
        {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
        if SetAndTest(LayersBase, OpenLibrary('layers.library', 37)) then
        {$ENDIF}
        begin
          {$IFNDEF HASAMIGA}
          if SetAndTest(UtilityBase, OpenLibrary('utility.library', 37)) then
          {$ENDIF}
          begin
            if SetAndTest(mywin, OpenWindowTags(nil,        //* Open that window. */
            [
              TAG_(WA_SmartRefresh) , TAG_(TRUE),
              TAG_(WA_SizeGadget)   , TAG_(FALSE),
              TAG_(WA_CloseGadget)  , TAG_(TRUE),
              TAG_(WA_IDCMP)        , TAG_(IDCMP_CLOSEWINDOW),
              TAG_(WA_DragBar)      , TAG_(TRUE),
              TAG_(WA_DepthGadget)  , TAG_(TRUE),
              TAG_(WA_Title)        , TAG_(PChar('AvailFonts() example')),
              TAG_END
            ])) then
            begin
              myrp := (mywin^.RPort)^;  //* A structure assign: clone my window's Rastport. */
                                        //* RastPort.  This RastPort will be used to render */
                                        //* the font specs, not the actual font sample.     */
              if SetAndTest(mydrawinfo, GetScreenDrawInfo(mywin^.WScreen)) then
              begin
                SetFont(@myrp, mydrawinfo^.dri_Font);

                myrect.MinX := mywin^.BorderLeft;           //* LAYOUT THE WINDOW */
                myrect.MinY := mywin^.BorderTop;
                myrect.MaxX := mywin^.Width - (mywin^.BorderRight + 1);
                myrect.MaxY := mywin^.Height - (mywin^.BorderBottom + 1);

                cliprectside := (myrect.MaxX - myrect.MinX) div 20;

                fname.charcount    := StrLen(fname.str);
                fheight.charcount  := StrLen(fheight.str);
                XDPI.charcount     := StrLen(XDPI.str);
                YDPI.charcount     := StrLen(YDPI.str);
                entrynum.charcount := StrLen(entrynum.str);
                alphabetcharcount  := StrLen(alphabetstring);

                fontheight := (myrp.Font^.tf_YSize) + 2;

                if (fontheight > ((myrect.MaxY - myrect.MinY) div 6)) then  //* If the default screen  */
                begin                                                       //* font is more than one- */
                  defaultfont := OpenFont(@defaultfontattr);                //* sixth the size of the  */
                  SetFont(@myrp, defaultfont);                              //* window, use topaz-9.   */
                  fontheight := (myrp.Font^.tf_YSize) + 2;
                end;

                fname.stringwidth    := TextLength(@myrp, STRPTR(fname.str)  , fname.charcount);
                fheight.stringwidth  := TextLength(@myrp, STRPTR(fheight.str), fheight.charcount);
                XDPI.stringwidth     := TextLength(@myrp, STRPTR(XDPI.str)   , XDPI.charcount);
                YDPI.stringwidth     := TextLength(@myrp, STRPTR(YDPI.str)   , YDPI.charcount);
                entrynum.stringwidth := TextLength(@myrp, STRPTR(entrynum.str), entrynum.charcount);

                stringwidth := fname.stringwidth;           //* What is the largest string length? */
                if ( fheight.stringwidth > stringwidth) then stringwidth := fheight.stringwidth;
                if (    XDPI.stringwidth > stringwidth) then stringwidth := XDPI.stringwidth;
                if (    YDPI.stringwidth > stringwidth) then stringwidth := YDPI.stringwidth;
                if (entrynum.stringwidth > stringwidth) then stringwidth := entrynum.stringwidth;
                stringwidth := stringwidth + mywin^.BorderLeft;

                if (stringwidth < ((myrect.MaxX - myrect.MinX) shr 1)) then //* If the stringwidth is      */
                begin                                                       //* more than half the viewing */
                  SetAPen(@myrp, PUWORD(mydrawinfo^.dri_Pens)[TEXTPEN]);    //* area, quit because the     */
                  SetDrMd(@myrp, JAM2);                                     //* font is just too big.      */

                  GfxMove(@myrp, myrect.MinX + 8 + stringwidth - fname.stringwidth,
                                 myrect.MinY + 4 + (myrp.Font^.tf_Baseline));
                  GfxText(@myrp, fname.str, fname.charcount);

                  GfxMove(@myrp, myrect.MinX + 8 + stringwidth - fheight.stringwidth,
                           myrp.cp_y + fontheight);
                  GfxText(@myrp, fheight.str, fheight.charcount);

                  GfxMove(@myrp, myrect.MinX + 8 + stringwidth - XDPI.stringwidth,
                           myrp.cp_y + fontheight);
                  GfxText(@myrp, XDPI.str, XDPI.charcount);

                  GfxMove(@myrp, myrect.MinX + 8 + stringwidth - YDPI.stringwidth,
                              myrp.cp_y + fontheight);
                  GfxText(@myrp, YDPI.str, YDPI.charcount);

                  GfxMove(@myrp, myrect.MinX + 8 + stringwidth - entrynum.stringwidth,
                              myrp.cp_y + fontheight);
                  GfxText(@myrp, entrynum.str, entrynum.charcount);

                  myrect.MinX := myrect.MinX + cliprectside;
                  myrect.MaxX := myrect.MaxX - cliprectside;
                  myrect.MinY := myrect.MinY + (5 * fontheight) + 8;
                  myrect.MaxY := myrect.MaxY - 8;

                  SetAPen(@myrp, PUWORD(mydrawinfo^.dri_Pens)[SHINEPEN]);   //* Draw a box around */
                  GfxMove(@myrp, myrect.MinX - 1, myrect.MaxY + 1);         //* the cliprect.     */
                  Draw(@myrp, myrect.MaxX + 1, myrect.MaxY + 1);
                  Draw(@myrp, myrect.MaxX + 1, myrect.MinY - 1);

                  SetAPen(@myrp, PUWORD(mydrawinfo^.dri_Pens)[SHADOWPEN]);
                  Draw(@myrp, myrect.MinX - 1, myrect.MinY - 1);
                  Draw(@myrp, myrect.MinX - 1, myrect.MaxY);

                  SetAPen(@myrp, PUWORD(mydrawinfo^.dri_Pens)[TEXTPEN]);

                  //* Fill up a buffer with a list of the available fonts */
                  afsize := DiskFont.AvailFonts(STRPTR(afh), 0, AFF_MEMORY or AFF_DISK or AFF_SCALED or AFF_TAGGED);

                  repeat
                    afh := PAvailFontsHeader(ExecAllocMem(afsize, 0));
                    if assigned(afh) then
                    begin
                      afshortage := DiskFOnt.AvailFonts(STRPTR(afh), afsize,
                                              AFF_MEMORY or AFF_DISK or AFF_SCALED or AFF_TAGGED);
                      if (afshortage <> 0) then
                      begin
                        ExecFreeMem(afh, afsize);
                        afsize := afsize + afshortage;
                        afh := PAvailFontsHeader(-1);
                      end;
                    end;
                  until not ( (afshortage <> 0) and (afh <> nil) );

                  if assigned(afh) then
                  begin
                    //* This is for the layers.library clipping region that gets attached to */
                    //* the window.  This prevents the application from unnecessarily        */
                    //* rendering beyond the bounds of the inner part of the window. For     */
                    //* more information on clipping, see the Layers chapter of this manual. */

                    if SetAndTest(new_region, NewRegion) then       //* More layers stuff */
                    begin
                      if (OrRectRegion(new_region, @myrect) ) then  //* Even more layers stuff */
                      begin
                         //* Obtain a pointer to the window's rastport and set up some of    */
                         //* the rastport attributes.  This example obtains the text pen     */
                         //* for the window's screen using the GetScreenDrawInfo() function. */
                         mycliprp := mywin^.RPort;
                         SetAPen(mycliprp, PUWORD(mydrawinfo^.dri_Pens)[TEXTPEN]);
                         MainLoop();
                      end;
                      DisposeRegion(new_region);
                    end;
                    ExecFreeMem(afh, afsize);
                  end;
                end;
                FreeScreenDrawInfo(mywin^.WScreen, mydrawinfo);
              end;
              CloseWindow(mywin);
            end;
            {$IFNDEF HASAMIGA}
            CloseLibrary(UtilityBase);
            {$ENDIF}
          end;
          {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
          CloseLibrary(LayersBase);
          {$ENDIF}
        end;
        {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
        CloseLibrary(PLibrary(GfxBase));
        {$ENDIF}
      end;
      {$IFDEF MORPHOS}
      CloseLibrary(PLibrary(IntuitionBase));
      {$ENDIF}
    end;
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    CloseLibrary(DiskfontBase);
    {$ENDIF}
  end;
end;


procedure  MainLoop;
var
  x         : UWORD;
  mytask    : PTask;
  mymsg     : PIntuiMessage;
  aok       : boolean = TRUE;
  afont     : PTAvailFonts;
  myfont    : PTextFont;
  buf       : string[8];
  dpi       : ULONG;
begin
  mytask := FindTask(nil);
  afont := PTAvailFonts(@(afh[1]));

  x := 0;
  while (x < afh^.afh_NumEntries) do
  begin
    if (aok) then
    begin
      if SetAndTest(myfont, OpenDiskFont(@(afont^.taf_Attr))) then
      begin
        SetAPen(@myrp, PUWORD(mydrawinfo^.dri_Pens)[BACKGROUNDPEN]);    //* Print the TextFont attributes. */
        RectFill(@myrp, stringwidth, mywin^.BorderTop + 4,
                  mywin^.Width - (mywin^.BorderRight + 1), myrect.MinY - 2 );

        SetAPen( @myrp, PUWORD(mydrawinfo^.dri_Pens)[TEXTPEN]);
        GfxMove( @myrp, stringwidth + mywin^.BorderLeft,
              mywin^.BorderTop + 4 + (myrp.Font^.tf_Baseline) );
        GfxText( @myrp, PChar(myfont^.tf_Message.mn_Node.ln_Name),
              StrLen(PChar(myfont^.tf_Message.mn_Node.ln_Name)) );

        GfxMove(@myrp, stringwidth + mywin^.BorderLeft, myrp.cp_y + fontheight);    //* Print the      */
        System.WriteStr(buf, myfont^.tf_YSize, #0);                                 //* font's Y Size. */
        GfxText(@myrp, @buf[1], StrLen(@buf[1]));

        GfxMove(@myrp, stringwidth + mywin^.BorderLeft, myrp.cp_y + fontheight);    //* Print the X DPI */
        dpi := GetTagData( TA_DeviceDPI, 0,
                          (PTextFontExtension(myfont^.tf_message.mn_ReplyPort))^.tfe_Tags);
        if (dpi <> 0) then
        begin
          System.WriteStr(buf, ((dpi and $FFFF0000) shr 16), #0);
          GfxText(@myrp, @buf[1], StrLen(@buf[1]));
        end
        else GfxText(@myrp, 'nil', 3);

        GfxMove(@myrp, stringwidth + mywin^.BorderLeft, myrp.cp_y + fontheight);    //* Print the Y DPI */
        if (dpi <> 0) then
        begin
          System.WriteStr(buf, (dpi and $0000FFFF), #0);
          GfxText(@myrp, @buf[1], StrLen(@buf[1]));
        end
        else GfxText(@myrp, 'nil', 3);

        GfxMove(@myrp, stringwidth + mywin^.BorderLeft, myrp.cp_y + fontheight);     //* Print the */
        System.WriteStr(buf, x, #0);                                                 //* entrynum. */
        GfxText(@myrp, @buf[1], StrLen(@buf[1]));

        SetFont(mycliprp, myfont);
        old_region := InstallClipRegion(mywin^.WLayer, new_region); //* Install clipping rectangle */

        SetRast(mycliprp, PUWORD(mydrawinfo^.dri_Pens)[BACKGROUNDPEN]);
        GfxMove( mycliprp, myrect.MinX, myrect.MaxY - (myfont^.tf_YSize - myfont^.tf_Baseline) );
        GfxText(mycliprp, alphabetstring, alphabetcharcount);

        DOSDelay(100);

        new_region := InstallClipRegion(mywin^.WLayer, old_region); //* Remove clipping rectangle */

        while SetAndTest(mymsg, PIntuiMessage(GetMsg(mywin^.UserPort))) do
        begin
          aok := FALSE;
          x := afh^.afh_NumEntries;
          ReplyMsg(PMessage(mymsg));
        end;

        if (mytask^.tc_SigRecvd and SIGBREAKF_CTRL_C) <> 0 then //* Did the user hit CTRL-C (the shell */
        begin                                                   //* window has to receive the CTRL-C)? */
          aok := FALSE;
          x := afh^.afh_NumEntries;
          WriteLn('Ctrl-C Break');  // VPrintf('Ctrl-C Break' + LineEnding, nil);
        end;
        CloseFont(myfont);
      end;
    end;
    inc(afont);
    inc(x);
  end;
end;


function StrLen(str: PChar): ULONG;
var
  x : ULONG;
begin
  x := 0;

  while (str[x] <> #0) do inc(x);
  result := x;
end;


begin
  {$IFDEF AROS}
  WriteLn('INFO: This example does not work for the AROS platform.');
  WriteLn;
  WriteLn('Reason is that the function AvailFonts() from diskfont.library does');
  WriteLn('not allow to pass an empty (nil) pointer for the buffer parameter. ');
  WriteLn;
  WriteLn('When passing a nil as buffer parameter, the function should return ');
  Writeln('the number of bytes that are required to "store" all the available ');
  WriteLn('structures into the buffer, but instead the function crashes.      ');
  WriteLn;
  Writeln('< Press enter to continue >');
  ReadLn;
  {$ENDIF}
  Main(ArgC, ArgV);
end.
