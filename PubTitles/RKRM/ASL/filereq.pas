program filepat;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : filepat
  Source    : RKRM
  Note      : Examples updated to compile for OS 3.x
}

 {*
 ** Here's a short example showing how to create a file requester with
 ** asl.library.  If AslRequest() returns TRUE then the rf_File and
 ** rf_Dir fields of the requester data structure contain the name and
 ** directory of the file the user selected.  Note that the user can type
 ** in the a name for the file and directory, which makes it possible for
 ** a file requester to return a file and directory that do not
 ** (currently) exist.
 *}

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



function TAG_(s: PChar): LongWord; inline;
begin
  Result := LongWord(S);
end;

Const
  vers          : PChar   = '$VER: filereq 37.0';

  MYLEFTEDGE    =   0;
  MYTOPEDGE     =   0;
  MYWIDTH       = 320;
  MYHEIGHT      = 400;


var
  frtags        : Array[0..9] of TTagItem =
  (
    ( ti_Tag: ASLFR_TitleText       ; ti_Data : 0 ),
    ( ti_Tag: ASLFR_InitialHeight   ; ti_Data : MYHEIGHT ),
    ( ti_Tag: ASLFR_InitialWidth    ; ti_Data : MYWIDTH ),
    ( ti_Tag: ASLFR_InitialLeftEdge ; ti_Data : MYLEFTEDGE ),
    ( ti_Tag: ASLFR_InitialTopEdge  ; ti_Data : MYTOPEDGE ),
    ( ti_Tag: ASLFR_PositiveText    ; ti_Data : 0 ),
    ( ti_Tag: ASLFR_NegativeText    ; ti_Data : 0 ),
    ( ti_Tag: ASLFR_InitialFile     ; ti_Data : 0 ),
    ( ti_Tag: ASLFR_InitialDrawer   ; ti_Data : 0 ),
    ( ti_Tag: TAG_DONE )
  );    


Procedure Main(argc: integer; argv: ppchar);
var
  fr     : pFileRequester;
begin
  frtags[0].ti_Data := TAG_(PChar('The RKM file requester'));
  frtags[5].ti_Data := TAG_(PChar('O KAY'));
  frtags[6].ti_Data := TAG_(PChar('not OK'));
  frtags[7].ti_Data := TAG_(PChar('asl.library'));
  frtags[8].ti_Data := TAG_(PChar('libs:'));
  
  
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  If SetAndTest(AslBase, OpenLibrary('asl.library', 37)) then
  {$ENDIF}
  begin
    If SetAndTest(fr, AllocAslRequest(ASL_FileRequest, @frtags)) then
    begin
      if (AslRequest(fr, nil)) then
      begin
        WriteLn(Format('PATH=%s  FILE=%s', [fr^.rf_Dir, fr^.rf_File]));
        WriteLn('To combine the path and filename, copy the path');
        WriteLn('to a buffer, add the filename with Dos AddPart().');
      end;
      FreeAslRequest(fr);
    end
    else WriteLn('User Cancelled');
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    CloseLibrary(AslBase);
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
