program example13a;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$IFDEF AROS}
{$WARNING Zune does not support AREXX commands atm}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example13a
  Topic   : MUI and Arexx
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-12.html
  Sources : http://www.ppa.pl/artykuly/download/mui12.lha
  ===========================================================================
 
  This example was originally written in c as part of the MUI tutorials,
  which were written by Grzegorz Kraszewski.
  
  The original articles (written in the Polish language) are still available 
  online at PPA.pl (http://www.ppa.pl/programy/szkolki/) in 14 different
  pages.
  
  The tutorials and examples were also released in a (Polish) printed 
  magazine by ACS publisher (which doesn't exist anymore).
  
  The c-sources were converted to Free Pascal, and (variable) names and 
  comments were translated into English as much as possible.
  
  Free Pascal sources were adjusted in order to support the following targets 
  out of the box:
  - Amiga-m68k, AROS-i386 and MorphOS-ppc
  
  In order to accomplish that goal, some use of support units is used that 
  aids compilation in a more or less uniform way.

  Some additional Pascal code was added to make the examples (hopefully) more 
  clear for beginners.
  
  Conversion to Free Pascal was done by Magorium in 2015, with kind permission 
  from Krashan to be able to publish.

  ===========================================================================

           Unless otherwise noted, these examples must be considered
                 copyrighted by their respective owner(s)

  ===========================================================================
}

Uses
  Exec, AmigaDOS, Intuition, MUI, Utility,
  CHelpers,
  Sugar,
  Trinity;  


Type
  PPLONG        = ^PLONG;

const
  OBJ_WINDOW    = 123456;   //* Shortcut ID to the window object for use in  */
                            //* functions MainLoop() and SetNotifications    */
  OBJ_COLOR     = 123457;   //* Shortcut identifier to user defined data     */
                            //* for use in the Arexx hook                    */
Var
  App,
  Win           : pObject_;


// Hooks called by Arexx commands

function  ArexxSetColor(hook: pHook; app: pObject_; paramtable: ppLong): ULONG;
Const ProcName = 'ArexxSetColor';
Var
  i : integer;
  colorfield : pObject_;
begin
  Enter(ProcName);

  colorfield := pObject_(DoMethod (app, MUIM_FindUData, [TAG_(OBJ_COLOR)]));        //* retrieve the color field */
  for i := 0 to pred(3) do paramtable^[i] := paramtable^[i] shl 24;                 //* Scale the color */
  SetAttrs (colorfield, [TAG_(MUIA_Coloradjust_RGB), TAG_(paramtable^), TAG_END]);  //* and set */
  result := 0;

  Leave(ProcName);
end;


Var
  h_ARexxSetColor : THook;


function  ArexxGetColor(hook: pHook; app: pObject_; paramtable: ppLong): ULONG;
Const ProcName = 'ArexxGetColor';
Const
  res        : ShortString = '';   //* 3 times 3 numbers + two spaces + 0 lineendings = up to 12 characters */
Var
  colorfield : pObject_;
  rgb        : pULONG;
begin
  Enter(ProcName);

  colorfield := pObject_(DoMethod (app, MUIM_FindUData, [TAG_(OBJ_COLOR)]));    //* retrieve the color field */
  GetAttr (MUIA_Coloradjust_RGB, colorfield, @rgb);                             //* get RGB fields */
  System.WriteStr(res, rgb[0] shr 24, ' ', rgb[1] shr 24, ' ', rgb[2] shr 24, #0);
  SetAttrs (app, [TAG_(MUIA_Application_RexxString), TAG_(@res[1]), TAG_END]);
  result := 0;

  Leave(ProcName);
end;


var
  h_ARexxGetColor : THook;


//* Table structure of MUI_Command */

Const
  ARexxCommands : array[0..2] of TMUI_Command =
  (
    (
      mc_Name       : 'setcolor';                   //* command name                          */
      mc_Template   : 'RED/N/A,GREEN/N/A,BLUE/N/A'; //* template parameters (like in DOS)     */
      mc_Parameters : 3;                            //* (max) number of parameters in pattern */
      mc_Hook       : @h_ARexxSetColor;             //* hook called for the command           */
    )
    ,
    (
      mc_Name       : 'getcolor';
      mc_Template   : '';
      mc_Parameters : 0;
      mc_Hook       : @h_ARexxGetColor;
    )
    ,
    (
      mc_Name       : nil;                          //* Close array with empty entry */
      mc_Template   : nil;
      mc_Parameters : 0;
      mc_Hook       : nil;
    )    
  );


//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);

  App := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)       , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)         , TAG_(PChar('EXAMPLE13A')),
    TAG_(MUIA_Application_Copyright)    , TAG_(PChar('© 2000 by BlaBla Corp.')),
    TAG_(MUIA_Application_Description)  , TAG_(PChar('Example 13a to the MUI tutorial')),
    TAG_(MUIA_Application_Title)        , TAG_(PChar('Example13a')),
    TAG_(MUIA_Application_Version)      , TAG_(PChar('$VER: example13a 1.0 (6.8.2000) BLABLA PRODUCT')),
    TAG_(MUIA_Application_Commands)     , TAG_(@ARexxCommands),
    TAG_(MUIA_Application_Window)       , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)           , TAG_(PChar('Example 13a')),
      TAG_(MUIA_Window_ID)              , $50525A4B,
      TAG_(MUIA_UserData)               , TAG_(OBJ_WINDOW),
      TAG_(MUIA_Window_Width)           , TAG(MUIV_Window_Width_Visible(30)),
      TAG_(MUIA_Window_Height)          , TAG(MUIV_Window_Height_Visible(25)),
      TAG_(MUIA_Window_RootObject)      , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)          , TAG_(MUI_NewObject (MUIC_ColorAdjust,      
        [                                                                        
          TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_Group),
          TAG_(MUIA_FrameTitle)         , TAG_(PChar('Colour')),
          TAG_(MUIA_UserData)           , TAG_(OBJ_COLOR),
          TAG_END
        ])),
        TAG_END
      ])),
      TAG_END
    ]))),
    TAG_END
  ]);

  Result := (App <> nil);

  Leave(ProcName);
end;


//* Initialize notification for closing the window */

procedure SetNotifications;
Const ProcName = 'SetNotifications';
begin
  Enter(ProcName);

  DoMethod (Win, MUIM_Notify, 
  [
    TAG_(MUIA_Window_CloseRequest), TAG_(MUIV_EveryTime), TAG_(App), 
    2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
  ]);

  Leave(ProcName);
end;


//* Main loop of the application */

procedure MainLoop;
Const ProcName = 'MainLoop';
Var
  signals: LONG;
begin
  Enter(ProcName);

  SetAttrs(Win, [ TAG_(MUIA_Window_Open), TAG_(True), TAG_END ]);
  
  while (DoMethod ( Pointer(App), MUIM_Application_NewInput, [TAG_(@Signals)] ) <> LongWord(MUIV_Application_ReturnID_Quit)) do
  begin
    if (signals <> 0) then
    begin
      signals := Wait (signals or SIGBREAKF_CTRL_C);
      if ((signals and SIGBREAKF_CTRL_C) <> 0) then break;
    end;
  end;

  SetAttrs (Win, [TAG_(MUIA_Window_Open), TAG_(FALSE), TAG_END]); 

  Leave(ProcName);
end;


//* opening all libraries */

function OpenLibs: boolean;
Const ProcName = 'OpenLibs';
begin
  Enter(ProcName);

  {$IFDEF MORPHOS}
  if not ( SetAndTest( IntuitionBase, OpenLibrary('intuition.library' , 39))) then exit(false);
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}  
  if not ( SetAndTest( MUIMasterBase, OpenLibrary('muimaster.library' , 19))) then exit(false);
  {$ENDIF}
  result := true;

  Leave(ProcName);
end;


//* closing all libraries */

procedure CloseLibs;
Const ProcName = 'CloseLibs';
begin
  Enter(ProcName);

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if (MUIMasterBase  <> nil) then CloseLibrary(MUIMasterBase);
  {$ENDIF}
  {$IFDEF MORPHOS}
  if (IntuitionBase  <> nil) then CloseLibrary(pointer(IntuitionBase));
  {$ENDIF}

  Leave(ProcName);
end;


//* Main function of the application */

Function Main: integer;
Const ProcName = 'Main';
begin
  Enter(ProcName);

  if OpenLibs then
  begin
    { FPC Note: Cross platform compatible initialization of the hooks }    
    inithook(h_ARexxSetColor, THookFunction(@ArexxSetColor) , nil);
    inithook(h_ARexxGetColor, THookFunction(@ArexxGetColor) , nil);
  
    if BuildApplication then
    begin
      SetNotifications;
      MainLoop;
      MUI_DisposeObject(App);
    end;
  end;
  CloseLibs;
  result := 0;

  Leave(ProcName);
end;


//
//        Startup
//

begin
  WriteLn('enter');

  ExitCode := Main;

  WriteLn('leave');
end.
