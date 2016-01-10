program filepat;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : filepat
  Source    : RKRM
  Note      : Examples updated to compile for OS 3.x
}

{$MODE OBJFPC}{$H+}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

Uses
  Exec, Workbench, Intuition, ASL, Utility,
  {$IFDEF AMIGA}
  AGraphics,
  SystemVarTags,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;


Const
  vers          : PChar   = '$VER: filepat 37.0';


Var
  screen        : PScreen  = nil;
  window        : PWindow  = nil;


Procedure Main(argc: integer; argv: ppchar);
var
  fr     : pFileRequester;
  frargs : pWBArg;
  x      : integer;
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  If SetAndTest(AslBase, OpenLibrary('asl.library', 37)) then
  {$ENDIF}
  begin
    {$IFDEF MORPHOS}
    If SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
    {$ENDIF}
    begin
      if SetAndTest(screen, OpenScreenTags(nil,
      [
        {$IFDEF AMIGA}  // HIRES LACE ... not really supported anymore except on classic
        TAG_(SA_DisplayID)     , HIRESLACE_KEY,
        {$ELSE}
        TAG_(SA_LikeWorkbench) , TAG_(TRUE),
        {$ENDIF}
        TAG_(SA_Title)         , TAG_(PChar('ASL Test Screen')),
        TAG_END        
      ])) then
      begin
        If SetAndTest(window, OpenWindowTags(nil,
        [
          TAG_(WA_CustomScreen)   , TAG_(screen),
          TAG_(WA_Title)          , TAG_(PChar('Demo Customscreen, File Pattern, Multi-select')),
          TAG_(WA_Flags)          , (WFLG_DEPTHGADGET or WFLG_DRAGBAR),
          TAG_END
        ])) then
        begin
          If SetAndTest(fr, AllocAslRequestTags(ASL_FileRequest,
          [
            TAG_(ASLFR_TitleText)       , TAG_(PChar('FilePat/MultiSelect Demo')),
            TAG_(ASLFR_InitialDrawer)   , TAG_(PChar('libs:')),
            TAG_(ASLFR_InitialFile)     , TAG_(PChar('asl.library')),

            //* Initial pattern string for pattern matching */
            TAG_(ASLFR_InitialPattern)  , TAG_(PChar('~(rexx#?|math#?)')),

            //* Enable multiselection and pattern match gadget */
            TAG_(ASLFR_DoMultiSelect)   , TAG_(True),
            TAG_(ASLFR_DoPatterns)      , TAG_(True),
            
            {* This requester comes up on the screen of this
            ** window (and uses window's message port, if any).
            *}
            TAG_(ASLFR_Window)          , TAG_(window),
            TAG_DONE
          ])) then
          begin
            //* Put up file requester */
            if (AslRequest(fr, nil)) then
            begin
              {* If the file requester's rf_NumArgs field
              ** is not zero, the user multiselected. The
              ** number of files is stored in rf_NumArgs.
              *}
              if ((fr^.rf_NumArgs) <> 0) then
              begin
                {* rf_ArgList is an array of WBArg structures
                ** (see <workbench/startup.h>). Each entry in
                ** this array corresponds to one of the files
                ** the user selected (in alphabetical order).
                *}
                frargs := pWBArg(fr^.rf_ArgList);

                {* The user multiselected, step through
                ** the list of selected files.
                *}
                for x := 0 to pred(fr^.rf_NumArgs) do
                begin
                  WriteLn(Format
                  (
                    'Argument %d: PATH=%s FILE=%s',
                    [x, fr^.rf_Dir, frargs[x].wa_Name]
                  ));
                end;
              end
              else
                {* The user didn't multiselect, use the
                ** normal way to get the file name.
                *}
                WriteLn(Format('PATH=%s FILE=%s', [fr^.rf_Dir, fr^.rf_File]));
            end;
            //* Done with the FileRequester, better return it */
            FreeAslRequest(fr);
          end;
          CloseWindow(window);
        end;
        CloseScreen(screen);
      end;
      {$IFDEF MORPHOS}
      CloseLibrary(PLibrary(IntuitionBase));
      {$ENDIF}
    end;
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    CloseLibrary(AslBase);
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
