program publicscreen;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : publicscreen
  Title     : open a screen with the pens from a public screen
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDOS, intuition, Utility,
  Trinity;


  procedure usePubScreenPens; Forward;


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



{* main(): open libraries, clean up when done.
*}
procedure main(argc: integer; argv: PPChar);
begin
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  {$ENDIF}
  if ( IntuitionBase <> nil ) then
  begin
    //* Check the version number; Release 2 is */
    //* required for public screen functions   */
    if (IntuitionBase^.lib_Version >= 37) then
    begin
      usePubScreenPens();
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(IntuitionBase);
    {$ENDIF}
  end;
end;


{* Open a screen that uses the pens of an existing public screen
** (the Workbench screen in this case).
*}
procedure usePubScreenPens;
var
  my_screen         : PScreen;
  screen_tags       : array[0..Pred(2)] of TTagItem;

  pubScreenName     : PChar     = 'Workbench';

  pub_screen        : PScreen   = nil;
  screen_drawinfo   : PDrawInfo = nil;
begin
  //* Get a lock on the Workbench screen */
  pub_screen := LockPubScreen(pubScreenName);
  if ( pub_screen <> nil ) then
  begin
    //* get the DrawInfo structure from the locked screen */
    screen_drawinfo := GetScreenDrawInfo(pub_screen);
    if ( screen_drawinfo <> nil ) then
    begin
      {* the pens are copied in the OpenScreenTagList() call,
      ** so we can simply use a pointer to the pens in the tag list.
      **
      ** This works better if the depth and colors of the new screen
      ** matches that of the public screen.  Here we are forcing the
      ** workbench screen pens on a monochrome screen (which may not
      ** be a good idea).  You could add the tag:
      **      (SA_Depth, screen_drawinfo->dri_Depth)
      *}
      screen_tags[0].ti_Tag  := SA_Pens;
      screen_tags[0].ti_Data := TAG_(screen_drawinfo^.dri_Pens);
      screen_tags[0].ti_Tag  := TAG_END;
      screen_tags[0].ti_Data := TAG_(0);

      my_screen := OpenScreenTagList(nil, @screen_tags);
      if (my_screen <> nil) then
      begin
        {* We no longer need to hold the lock on the public screen
        ** or a copy of its DrawInfo structure as we now have our
        ** own screen.  Release the screen.
        *}
        FreeScreenDrawInfo(pub_screen, screen_drawinfo);
        screen_drawinfo := nil;
        UnlockPubScreen(pubScreenName, pub_screen);
        pub_screen := nil;

        DOSDelay(90);   //* should be rest_of_program */

        CloseScreen(my_screen);
      end;
    end;
  end;

  {* These are freed in the main loop if OpenScreenTagList() does
  ** not fail.  If something goes wrong, free them here.
  *}
  if ( screen_drawinfo <> nil )
    then FreeScreenDrawInfo(pub_screen, screen_drawinfo);
  if ( pub_screen <> nil )
    then UnlockPubScreen(pubScreenName, pub_screen);
end;


begin
  Main(ArgC, ArgV);
end.
