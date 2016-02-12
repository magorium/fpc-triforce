Program MeasureText;
 
{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : MeasureText
  Source    : RKRM
}
 {*
 ** The following example, measuretext.c, opens a window on the default
 ** public screen and renders the contents of an ASCII file into the
 ** window.  It uses TextFit() to measure how much of a line of text will
 ** fit across the window.  If the entire line doesn't fit, measuretext
 ** will wrap the remainder of the line into the rows that follow.  This
 ** example makes use of an ASL font requester, letting the user choose
 ** the font, style, size, drawing mode, and color.  
 *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDOS, AGraphics, Intuition, DiskFont, ASL, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Trinity;

const
  BUFSIZE       = 32768;

  vers          : PChar = #0'$VER: MeasureText 37.1';

Var
  buffer        : array[0..Pred(BUFSIZE)] of UBYTE;

  myfile        : BPTR;
  wtbarheight   : UWORD;
  fr            : PFontRequester;
  myfont        : PTextFont;
  w             : PWindow;
  myrp          : PRastPort;
  mytask        : PTask;


  procedure MainLoop; forward;
  procedure EOP; forward;


procedure Main(argc: integer; argv: PPCHar);
var
  myta  : TTextAttr;
begin
  if (argc = 2) then
  begin
    if SetAndTest(myfile, DOSOpen(argv[1], MODE_OLDFILE)) then     //* Open the file to print out. */
    begin
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      if SetAndTest(DiskfontBase, OpenLibrary('diskfont.library', 37)) then    //* Open the libraries. */
      {$ENDIF}
      begin
        {$IF DEFINED(MORPHOS)}
        if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
        {$ENDIF}
        begin
          {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
          if SetAndTest(GfxBase, OpenLibrary('graphics.library', 37)) then
          {$ENDIF}
          begin
            {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
            if SetAndTest(AslBase, OpenLibrary('asl.library', 37)) then
            {$ENDIF}
            begin
              if SetAndTest(fr, PFontRequester(AllocAslRequestTags(ASL_FontRequest,
                              //* Open an ASL font requester */
              [
                //* Supply initial values for requester */
                {
                ASL_FontName      , PChar('topaz.font'),
                ASL_FontHeight    , 11,
                ASL_FontStyles    , FSF_BOLD or FSF_ITALIC,
                ASL_FrontPen      , $01,
                ASL_BackPen       , $00,
                }
                TAG_(ASLFO_InitialName)     , TAG_(PChar('topaz.font')),
                TAG_(ASLFO_InitialSize)     , 11,
                TAG_(ASLFO_InitialStyle)    , FSF_BOLD or FSF_ITALIC,
                TAG_(ASLFO_InitialFrontPen) , $01,
                TAG_(ASLFO_InitialBackPen)  , $00,

                //* Give us all the gadgetry */
                // ASL_FuncFlags, FONF_FRONTCOLOR or FONF_BACKCOLOR or FONF_DRAWMODE or FONF_STYLES,
                TAG_(ASLFO_Flags)           , FOF_DOFRONTPEN or FOF_DOBACKPEN or FOF_DODRAWMODE or FOF_DOSTYLE,
                TAG_DONE
              ]))) then
              begin
                //* Pop up the requester */
                if (AslRequest(fr, nil)) then
                begin
                  myta.ta_Name       := fr^.fo_Attr.ta_Name;         //* extract the font and */
                  myta.ta_YSize      := fr^.fo_Attr.ta_YSize;        //* display attributes   */
                  myta.ta_Style      := fr^.fo_Attr.ta_Style;        //* from the FontRequest */
                  myta.ta_Flags      := fr^.fo_Attr.ta_Flags;        //* structure.           */

                  if SetAndTest(myfont, OpenDiskFont(@myta)) then
                  begin
                    if SetAndTEst(w, OpenWindowTags(nil,
                    [
                      TAG_(WA_SizeGadget) , TAG_(TRUE),
                      TAG_(WA_MinWidth)   , 200,
                      TAG_(WA_MinHeight)  , 200,
                      TAG_(WA_DragBar)    , TAG_(TRUE),
                      TAG_(WA_DepthGadget), TAG_(TRUE),
                      TAG_(WA_Title)      , TAG_(argv[1]),
                      TAG_DONE
                    ])) then
                    begin
                      myrp := w^.RPort;
                      //* figure out where the baseline of the uppermost line should be. */
                      wtbarheight := w^.WScreen^.BarHeight + myfont^.tf_Baseline + 2;

                      //* Set the font and add software styling to the text if I asked for it */
                      //* in OpenFont() and didn't get it.  Because most Amiga fonts do not   */
                      //* have styling built into them (with the exception of the CG outline  */
                      //* fonts), if the user selected some kind of styling for the text, it  */
                      //* will to be added algorithmically by calling SetSoftStyle().         */

                      SetFont(myrp, myfont);
                      SetSoftStyle(myrp,   myta.ta_Style xor myfont^.tf_Style,
                                    (FSF_BOLD or FSF_UNDERLINED or FSF_ITALIC));
                      SetDrMd(myrp, fr^.fo_DrawMode);
                      SetAPen(myrp, fr^.fo_FrontPen);
                      SetBPen(myrp, fr^.fo_BackPen);
                      GfxMove(myrp, w^.WScreen^.WBorLeft, wtbarheight);
                      mytask := FindTask(nil);

                      MainLoop();

                      DOSDelay(25);                 //* short delay to give user a chance to */
                      CloseWindow(w);               //* see the text before it goes away.    */
                    end;
                    CloseFont(myfont);
                  end;
                end
                else
                  WriteLn('Request Cancelled');
                FreeAslRequest(fr);
              end;
              {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
              CloseLibrary(AslBase);
              {$ENDIF}
            end;
            {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
            CloseLibrary(GfxBase);
            {$ENDIF}
          end;
          {$IF DEFINED(MORPHOS)}
          CloseLibrary(IntuitionBase);
          {$ENDIF}
        end;
        {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
        CloseLibrary(DiskfontBase);
        {$ENDIF}
      end;
      DOSClose(myfile);
    end;
  end
  else
    WriteLn('template: MeasureText <file name>');
end;


procedure MainLoop;
var
  resulttextent : TTextExtent;
  fit, actual, count, printable, crrts: LONG;
  aok : Boolean = TRUE;
begin
  while (( SetAndGet(actual, DOSRead(myfile, @buffer, BUFSIZE)) > 0) and aok) do //* while there's something to */
  begin                                                                         //* read, fill the buffer.     */
    count := 0;

    while (count < actual) do
    begin
      crrts := 0;

      while 
      ( 
        ( (buffer[count] < myfont^.tf_LoChar) or            //* skip non-printable characters, but */
          (buffer[count] > myfont^.tf_HiChar)
        ) 
        and                                                 //* account for newline characters.    */
        (count < actual) 
      ) do
      begin
        if (buffer[count] = 12) then inc(crrts);           //* is this character a newline?  if it is, bump */
        inc(count);                                         //* up the newline count.                        */
      end;

      if (crrts > 0) then       //* if there where any newlines, be sure to display them. */
      begin
        GfxMove(myrp, w^.BorderLeft, myrp^.cp_y + (crrts * (myfont^.tf_YSize + 1)));
        EOP;                                          //* did we go past the end of the page? */
      end;

      printable := count;
      while 
      ( 
        (buffer[printable] >= myfont^.tf_LoChar) and      //* find the next non-printables */
        (buffer[printable] <= myfont^.tf_HiChar) and
        (printable < actual) 
      ) do
      begin
        inc(printable);
      end;                               //* print the string of printable characters wrapping  */
      while (count < printable) do       //* lines to the beginning of the next line as needed. */
      begin
        //* how many characters in the current string of printable characters will fit */
        //* between the rastport's current X position and the edge of the window?      */
        fit := TextFit(  myrp,                @(buffer[count]),
                        (printable - count), @resulttextent,
                        nil,                1,
                        (w^.Width  - (myrp^.cp_x + w^.BorderLeft + w^.BorderRight)),
                        myfont^.tf_YSize + 1  );
        if ( fit = 0 ) then
        begin
          //* nothing else fits on this line, need to wrap to the next line.         */
          GfxMove(myrp, w^.BorderLeft, myrp^.cp_y + myfont^.tf_YSize + 1);
        end
        else
        begin
          GfxText(myrp, @(buffer[count]), fit);
          count := count + fit;
        end;
        EOP;
      end;

      if (mytask^.tc_SigRecvd and SIGBREAKF_CTRL_C <> 0) then   //* did the user hit CTRL-C (the shell */
      begin                                                     //* window has to receive the CTRL-C)? */
        aok := FALSE;
        WriteLn('Ctrl-C Break');
        count := BUFSIZE + 1;
      end;
    end;
  end;
  if (actual < 0)
  then WriteLn('Error while reading');
end;


procedure EOP;
begin
  if (myrp^.cp_y > (w^.Height - (w^.BorderBottom + 2))) then    //* If we reached page bottom, clear the */
  begin                                                         //* rastport and move back to the top.   */
    DOSDelay(25);

    SetAPen(myrp, 0);
    RectFill(myrp, LONG(w^.BorderLeft), LONG(w^.BorderTop), w^.Width - (w^.BorderRight + 1),
                 w^.Height - (w^.BorderBottom + 1) );
    SetAPen(myrp, 1);
    GfxMove(myrp, w^.BorderLeft + 1, wtbarheight);
    SetAPen(myrp, fr^.fo_FrontPen);
  end;
end;


begin
  Main(ArgC, ArgV);
end.
