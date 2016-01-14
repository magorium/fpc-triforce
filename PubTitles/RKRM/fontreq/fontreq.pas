program fontreq;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : fontreq
  Source    : RKRM
  Note      : Examples updated to compile for OS 3.x
  FPC Note  : Example update to use new style ASL Tags
}

 {*
 ** The following example illustrates how to use a font requester.
 *}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}

Uses
  Exec, AGraphics, ASL, Utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;



Const
  vers      : PChar   = '$VER: fontreq 37.0';


  {* Our replacement strings for the "mode" cycle gadget.  The
  ** first string is the cycle gadget's label.  The other strings
  ** are the actual strings that will appear on the cycle gadget.
  *}
  modelist  : array[0..6] of PChar = 
  (
    'RKM Modes',
    'Mode 0',
    'Mode 1',
    'Mode 2',
    'Mode 3',
    'Mode 4',
    nil
  );


Procedure Main(argc: integer; argv: ppchar);
var
  fr    : PFontRequester;
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  If SetAndTest(AslBase, OpenLibrary('asl.library', 37)) then
  {$ENDIF}
  begin
    If SetAndTest(fr, AllocAslRequestTags(ASL_FontRequest, 
    [
      //* tell the requester to use my custom mode names */
      TAG_(ASLFO_ModeList)          , TAG_(@modelist),              //  TAG_(ASL_ModeList)    , TAG_(@modelist),

      //* Supply initial values for requester */
      TAG_(ASLFO_InitialName)       , TAG_(PChar('topaz.font')),    //  TAG_(ASL_FontName)    , TAG_(PChar('topaz.font')),
      TAG_(ASLFO_InitialSize)       , 11,                           //  TAG_(ASL_FontHeight)  , 11,
      TAG_(ASLFO_InitialStyle)      , FSF_BOLD or FSF_ITALIC,       //  TAG_(ASL_FontStyles)  , FSF_BOLD or FSF_ITALIC,
      TAG_(ASLFO_InitialFrontPen)   , $00,                          //  TAG_(ASL_FrontPen)    , $00,
      TAG_(ASLFO_InitialBackPen)    , $01,                          //  TAG_(ASL_BackPen)     , $01,

      //* Only display font sizes between 8 and 14, inclusive. */
      TAG_(ASLFO_MinHeight)         , 8,                            //  TAG_(ASL_MinHeight)   , 8,
      TAG_(ASLFO_MaxHeight)         , 14,                           //  TAG_(ASL_MaxHeight)   , 14,

      //* Give all the gadgetry, but only display fixed width fonts */
      //    TAG_(ASL_FuncFlags)   , FONF_FRONTCOLOR or FONF_BACKCOLOR or FONF_DRAWMODE or FONF_STYLES or FONF_FIXEDWIDTH,
      TAG_(ASLFO_Flags)   , FOF_DOFRONTPEN or FOF_DOBACKPEN or FOF_DODRAWMODE or FOF_DOSTYLE or FOF_FIXEDWIDTHONLY,
      TAG_DONE
    ])) then
    begin
      //* Pop up the requester */
      if (AslRequest(fr, nil)) then
      begin
        //* The user selected something,  report their choice */
        WriteLn(Format
        (
          '%s' + LineEnding + 
          '  YSize = %d  Style = 0x%x   Flags = 0x%x' + LineEnding + 
          '  FPen = 0x%x   BPen = 0x%x   DrawMode = 0x%x',
          [
            fr^.fo_Attr.ta_Name,
            fr^.fo_Attr.ta_YSize,
            fr^.fo_Attr.ta_Style,
            fr^.fo_Attr.ta_Flags,
            fr^.fo_FrontPen,
            fr^.fo_BackPen,
            fr^.fo_DrawMode
          ])
        );
      end
      else
        //* The user cancelled the requester, or some kind of error
        //* occurred preventing the requester from opening. */
        WriteLn('Request Cancelled');
      FreeAslRequest(fr);
    end;
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    CloseLibrary(AslBase);
    {$ENDIF}
  end;
end;


begin
  Main(ArgC, ArgV);
end.
