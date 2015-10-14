program example10b;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example10b
  Topic   : ListView list column titles
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-9.html
  Sources : http://www.ppa.pl/artykuly/download/mui9.lha
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
  Strings,
  CHelpers,
  Sugar,
  Trinity;  

const
  OBJ_WINDOW    = 123456;   //* Shortcut ID to the window object for use in  */
                            //* functions MainLoop() and SetNotifications    */

Var
  App,
  Win,
  Listview      : pObject_;


//* Structure of a list item */

Type
  PMerchandise = ^TMerchandise;
  TMerchandise = 
  record
    name            : PChar;
    items_in_stock  : LONG;
  end;


//* List elements that are inserted on creation */

Const
  Stationary    : array[0..3] of TMerchandise =
  (
    (name: 'crayons'      ; items_in_stock: 12),
    (name: 'highlighters' ; items_in_stock: 25),
    (name: 'ink'          ; items_in_stock: 0 ),
    (name: 'plasticine'   ; items_in_stock: 3 )
  );


Var
  DefaultList : array[0..4] of PMerchandise =
  (
    @Stationary[0], @Stationary[1], @Stationary[2], @Stationary[3], nil
  );


//* Hook constructor */

function MerchandiseConstructor(hook: pHook; mempool: APTR; Merchandise: PMerchandise): ULONG;
Const ProcName = 'MerchandiseConstructor';
var
  t_copy : PMerchandise;
  n_copy : PChar;
begin
  Enter(ProcName);

  if SetAndTest(t_copy, AllocPooled (mempool, sizeof (TMerchandise))) then
  begin
    if SetAndTest(n_copy, AllocPooled (mempool, strlen(Merchandise^.name) + 1)) then
    begin
      strcopy (n_copy, Merchandise^.Name);
      t_copy^.name := n_copy;
      t_copy^.items_in_stock := Merchandise^.items_in_stock;
      exit(ULONG(t_copy));
    end
    else FreePooled (mempool, t_copy, sizeof (TMerchandise));
  end;
  result := 0;

  Leave(ProcName);
end;


//* Hook destructor */

function  MerchandiseDestructor(hook: pHook; mempool: APTR; merchandise: PMerchandise): ULONG;
Const ProcName = 'MerchandiseDestructor';
begin
  Enter(ProcName);

  if (merchandise^.name <> nil) then FreePooled (mempool, merchandise^.name, strlen (merchandise^.name) + 1);
  if (merchandise <> nil) then FreePooled (mempool, merchandise, sizeof (TMerchandise));
  result := 0;

  Leave(ProcName);
end;


//* Hook for displaying */

function  MerchandiseDisplayer(hook: pHook; teksty: ppChar; merchandise: PMerchandise): ULONG;
Const
  textl    : ShortString = '';
  Quantity : ShortString = '';
begin

  //* When a list-entry is nil, this indicates to display the title */
  If not assigned(merchandise) then
  begin
    teksty[0] := PChar(Esc_C + Esc_b + #27'1Name of article');
    teksty[1] := PChar(Esc_C + Esc_b + #27'1Number of items');
    exit(0);
  end;

  //* Otherwise it's a normal list-entry which can be displayed as usual */
  if (merchandise^.items_in_stock > 0) then 
  begin
    teksty[0] := merchandise^.name;
    System.WriteStr(Quantity, merchandise^.items_in_stock, #0);
  end
  else
  begin
    System.WriteStr(   textl, Esc_B, merchandise^.name          , Esc_N, #0);
    teksty[0] := @textl[1];     { FPC Note: Return Pascal string as PChar  }
    System.WriteStr(Quantity, Esc_B, merchandise^.items_in_stock, Esc_N, #0);
  end;
  
  teksty[1] := @Quantity[1];    { FPC Note: Return Pascal string as PChar  }
  result := 0;
end;


//* Hook for comparison */

function  MerchandiseComparer(hook: pHook; merchandise2: pMerchandise; merchandise1: pMerchandise): ULONG;
Const ProcName = 'MerchandiseComparer';
begin
  Enter(ProcName);

  result := stricomp(merchandise1^.name, merchandise2^.name);

  Leave(ProcName);
end;


//* Hook structure definitions  */

var
  {
    FPC Note:
    Intitialization of the hooks is done below using InitHook().
  }
  h_MerchandiseConstructor : THook;
  h_MerchandiseDestructor  : THook;
  h_MerchandiseDisplayer   : THook;
  h_MerchandiseComparer    : THook;


//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);

  App := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)           , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)             , TAG_(PChar('EXAMPLE10B')),
    TAG_(MUIA_Application_Copyright)        , TAG_(PChar('© 1999 by BlaBla Corp.')),
    TAG_(MUIA_Application_Description)      , TAG_(PChar('Example 10b to the MUI tutorial')),
    TAG_(MUIA_Application_Title)            , TAG_(PChar('Example10b')),
    TAG_(MUIA_Application_Version)          , TAG_(PChar('$VER: example10b 1.0 (10.2.2000) BLABLA PRODUCT')),
    TAG_(MUIA_Application_Window)           , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)               , TAG_(PChar('Example 10b')),
      TAG_(MUIA_Window_ID)                  , $50525A4B,
      TAG_(MUIA_UserData)                   , TAG_(OBJ_WINDOW),
      TAG_(MUIA_Window_RootObject)          , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)              , TAG_(SetAndGet(Listview, MUI_NewObject (MUIC_Listview,
        [
          TAG_(MUIA_Listview_List)          , TAG_(MUI_NewObject (MUIC_List,
          [
            TAG_(MUIA_List_ConstructHook)   , TAG_(@h_MerchandiseConstructor),
            TAG_(MUIA_List_DestructHook)    , TAG_(@h_MerchandiseDestructor),
            TAG_(MUIA_List_DisplayHook)     , TAG_(@h_MerchandiseDisplayer),
            TAG_(MUIA_List_CompareHook)     , TAG_(@h_MerchandiseComparer),
            TAG_(MUIA_List_SourceArray)     , TAG_(@DefaultList),
            TAG_(MUIA_List_Title)           , TAG_(TRUE),
            TAG_(MUIA_List_Format)          , TAG_(PChar('BAR MAXWIDTH=100,PREPARSE='+Esc_R)),
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_ReadList),
            TAG_END
          ])),
          TAG_END
        ]))),
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

  SetAttrs (Win, [ TAG_(MUIA_Window_Open), TAG_(FALSE), TAG_END ]); 

  Leave(ProcName);
end;


//* Here we insert items into the list using two different methods */

procedure InsertElements;
Const ProcName = 'InsertElements';
Const
  amigas   : TMerchandise = (name: 'Amiga 1200'; items_in_stock: 0);

  hardware : Array [0..2] of TMerchandise = 
  (
    (name: 'BVision'     ; items_in_stock: 4),
    (name: 'BlizzardPPC' ; items_in_stock: 12),
    (name: 'mousepad'    ; items_in_stock: 234)
  );
var
  hard     : array [0..3] of PMerchandise =
  (
    @hardware[0], @hardware[1], @hardware[2], nil
  );
  
begin  
  Enter(ProcName);

  DoMethod (Listview, MUIM_List_Insert, 
  [
    TAG_(@hard), TAG_(-1), TAG_(MUIV_List_Insert_Top)
  ]);

  DoMethod (Listview, MUIM_List_Sort);       //* sort the list */
  
  DoMethod (Listview, MUIM_List_InsertSingle,
  [ 
    TAG_(@amigas), TAG_(MUIV_List_Insert_Sorted)
  ]);

  Leave(ProcName);
end;


//* Main function of the application */

Function  Main: integer;
Const ProcName = 'Main';
begin
  Enter(ProcName);

  {$IFDEF MORPHOS}
  if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
  {$ENDIF}
  begin
    {$IFNDEF HASAMIGA}
    if SetAndTest(UtilityBase, OpenLibrary('utility.library', 37)) then
    {$ENDIF}
    begin
      {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
      if SetAndTest(MUIMasterBase, OpenLibrary('muimaster.library', 16)) then
      {$ENDIF}
      begin
        {
          FPC Note:
          Cross platform compatible initialization of the hooks
        }
        initHook(h_MerchandiseConstructor, THookFunction(@MerchandiseConstructor), nil);
        initHook(h_MerchandiseDestructor , THookFunction(@MerchandiseDestructor) , nil);
        initHook(h_MerchandiseDisplayer  , THookFunction(@MerchandiseDisplayer)  , nil);
        initHook(h_MerchandiseComparer   , THookFunction(@MerchandiseComparer)   , nil);

        if BuildApplication then
        begin
          SetNotifications;
          InsertElements ();        
          MainLoop;
          MUI_DisposeObject(App);
        end;
        {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
        CloseLibrary(MuiMasterBase);
        {$ENDIF}
      end;
      {$IFNDEF HASAMIGA}
      CloseLibrary(UtilityBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(pLibrary(IntuitionBase));
    {$ENDIF}
  end;
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
