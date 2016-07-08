program clonescreen;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : clonescreen
  Source    : RKRM
}
 {
 ** clone an existing public screen.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDOS, AGraphics, intuition, Utility,
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  SysUtils,
  Trinity;


  procedure cloneScreen(pub_screen_name: PChar); forward;


var
  {$IFDEF AMIGA}
  IntuitionBase : PLibrary absolute _Intuitionbase;
  GfxBase       : PGfxBase absolute AGraphics.GfxBase;
  {$ENDIF}
  {$IFDEF AROS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  GfxBase       : PGfxBase absolute AGraphics.GfxBase;
  {$ENDIF}
  {$IFDEF MORPHOS}
  IntuitionBase : PLibrary absolute Intuition.Intuitionbase;
  GfxBase       : PGfxBase absolute AGraphics.GfxBase;
  {$ENDIF}


{*
** Open all libraries for the cloneScreen() subroutine.
*}
procedure Main(argc: integer; argv: PPChar);
const
  pub_screen_name   : PChar = 'Workbench';
begin
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  {$ENDIF}
  if (IntuitionBase <> nil) then
  begin
    //* Require version 37 of Intuition. */
    if (IntuitionBase^.lib_Version >= 37) then
    begin
      {* Note the two methods of getting the library version
      ** that you really want.
      *}
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      GfxBase := PGfxBase(OpenLibrary('graphics.library', 37));
      {$ENDIF}
      if (GfxBase <> nil) then
      begin
        cloneScreen(pub_screen_name);
        {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
        CloseLibrary(PLibrary(GfxBase));
        {$ENDIF}
      end;
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(IntuitionBase);
    {$ENDIF}
  end;
end;

    
{* Clone a public screen whose name is passed to the routine.
**    Width, Height, Depth, Pens, Font and DisplayID attributes are
** all copied from the screen.
**    Overscan is assumed to be OSCAN_TEXT, as there is no easy way to
** find the overscan type of an existing screen.
**    AutoScroll is turned on, as it does not hurt.  Screens that are
** smaller than the display clip will not scroll.
*}

procedure cloneScreen(pub_screen_name: PChar);
var
  my_screen         : PScreen;
  screen_modeID     : ULONG;
  pub_scr_font_name : PChar;
  font_name         : PChar;
  font_name_size    : ULONG;
  pub_screen_font   : TTextAttr;
  opened_font       : PTextFont;

  pub_screen        : PScreen = nil;
  screen_drawinfo   : PDrawInfo = nil;
begin
  //* name is a (UBYTE *) pointer to the name of the public screen to clone */
  pub_screen := LockPubScreen(pub_screen_name);
  if (pub_screen <> nil) then
  begin
    {* Get the DrawInfo structure from the locked screen
    ** This returns pen, depth and font info.
    *}
    screen_drawinfo := GetScreenDrawInfo(pub_screen);
    if (screen_drawinfo <> nil) then
    begin
      screen_modeID := GetVPModeID(@(pub_screen^.ViewPort));
      if (screen_modeID <> INVALID_ID) then
      begin
        {* Get a copy of the font
        ** The name of the font must be copied as the public screen may
        ** go away at any time after we unlock it.
        ** Allocate enough memory to copy the font name, create a
        ** TextAttr that matches the font, and open the font.
        *}
        pub_scr_font_name := screen_drawinfo^.dri_Font^.tf_Message.mn_Node.ln_Name;
        font_name_size := 1 + strlen(pub_scr_font_name);
        font_name := ExecAllocMem(font_name_size, MEMF_CLEAR);
        if (font_name <> nil) then
        begin
          strcopy(font_name, pub_scr_font_name);
          pub_screen_font.ta_Name  := font_name;
          pub_screen_font.ta_YSize := screen_drawinfo^.dri_Font^.tf_YSize;
          pub_screen_font.ta_Style := screen_drawinfo^.dri_Font^.tf_Style;
          pub_screen_font.ta_Flags := screen_drawinfo^.dri_Font^.tf_Flags;

          opened_font := OpenFont(@pub_screen_font);
          if (opened_font <> nil) then
          begin
            {* screen_modeID may now be used in a call to
            ** OpenScreenTagList() with the tag SA_DisplayID.
            *}
            my_screen := OpenScreenTags(nil,
            [
              TAG_(SA_Width)      , pub_screen^.Width,
              TAG_(SA_Height)     , pub_screen^.Height,
              TAG_(SA_Depth)      , screen_drawinfo^.dri_Depth,
              TAG_(SA_Overscan)   , OSCAN_TEXT,
              TAG_(SA_AutoScroll) , TAG_(TRUE),
              TAG_(SA_Pens)       , TAG_(screen_drawinfo^.dri_Pens),
              TAG_(SA_Font)       , TAG_(@pub_screen_font),
              TAG_(SA_DisplayID)  , screen_modeID,
              TAG_(SA_Title)      , TAG_(PChar('Cloned Screen')),
              TAG_END
            ]);
            if (my_screen <> nil) then
            begin
              {* Free the drawinfo and public screen as we don't
              ** need them any more.  We now have our own screen.
              *}
               FreeScreenDrawInfo(pub_screen, screen_drawinfo);
               screen_drawinfo := nil;
               UnlockPubScreen(pub_screen_name, pub_screen);
               pub_screen := nil;

               DOSDelay(300);   //* should be rest_of_program */

               CloseScreen(my_screen);
             end;
             CloseFont(opened_font);
           end;
           ExecFreeMem(font_name, font_name_size);
         end;
       end;
     end;
   end;

  {* These are freed in the main loop if OpenScreenTagList() does
  ** not fail.  If something goes wrong, free them here.
  *}
  if (screen_drawinfo <> nil)
    then FreeScreenDrawInfo(pub_screen, screen_drawinfo);
  if (pub_screen <> nil)
    then UnlockPubScreen(pub_screen_name, pub_screen);
end;

begin
  Main(ArgC, ArgV);
end.
