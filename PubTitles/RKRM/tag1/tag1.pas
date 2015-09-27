program tag1;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : tag1
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}

{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, Intuition, Utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  Trinity;


function main(argc: integer; argv: ppchar): integer;
var
  tags: pTagItem;
  win : pWindow;
begin
  //* For this example we need Version 2.0 */
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary ('intuition.library', 37);
  If (Intuitionbase <> nil) then
  {$ENDIF}
  begin
    //* We need the utility library for this example */
    {$IFNDEF HASAMIGA}
    UtilityBase := OpenLibrary ('utility.library', 37);
    if (UtilityBase <> nil) then
    {$ENDIF}
    begin

      //****************************************************************/
      //* This section allocates a tag array, fills it in with values, */
      //* and then uses it.                                            */
      //****************************************************************/

        //* Allocate a tag array */
        tags := AllocateTagItems (7);
        if (tags <> nil) then
        begin
          //* Fill in our tag array */
          tags[0].ti_Tag := WA_Width;
          tags[0].ti_Data := 320;
          tags[1].ti_Tag := WA_Height;
          tags[1].ti_Data := 50;
          tags[2].ti_Tag := WA_Title;
          tags[2].ti_Data := TAG_(PChar('RKM Tag Example 1'));
          tags[3].ti_Tag := WA_IDCMP;
          tags[3].ti_Data := TAG_(IDCMP_CLOSEWINDOW);
          tags[4].ti_Tag := WA_CloseGadget;
          tags[4].ti_Data := TAG_(TRUE);
          tags[5].ti_Tag := WA_DragBar;
          tags[5].ti_Data := TAG_(TRUE);
          tags[6].ti_Tag := TAG_DONE;

          //* Open the window, using the tag attributes as the
          //* only description. */
          win := OpenWindowTagList (nil, tags);
          if (win <> nil) then
          begin
            //* Wait for an event to occur */
            WaitPort (win^.UserPort);

            //* Close the window now that we're done with it */
            CloseWindow (win);
          end;

          //* Free the tag list now that we're done with it */
          FreeTagItems(tags);
        end;

      //****************************************************************/
      //* This section builds the tag array on the stack, and passes   */
      //* the array to a function.                                     */
      //****************************************************************/

        //* Now use the VarArgs (or stack based) version. */
        win := OpenWindowTags ( Nil,
        [
          TAG_(WA_Width), 320,
          TAG_(WA_Height), 50,
          TAG_(WA_Title), TAG_(PChar('RKM Tag Example 1')),
          TAG_(WA_IDCMP), TAG_(IDCMP_CLOSEWINDOW),
          TAG_(WA_CloseGadget), TAG_(TRUE),
          TAG_(WA_DragBar), TAG_(TRUE),
          TAG_DONE
        ]);
        if (win <> nil) then
        begin
          //* Wait for an event to occur */
          WaitPort (win^.UserPort);

          //* Close the window now that we're done with it */
          CloseWindow (win);
        end;

        //* Close the library now */
        {$IFNDEF HASAMIGA}
        CloseLibrary (UtilityBase);
        {$ENDIF}
      end;

    //* Close the library now that we're done with it */
    {$IFDEF MORPHOS}
    CloseLibrary (pLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;



begin
  ExitCode := Main(Paramcount, Argv);
end.
