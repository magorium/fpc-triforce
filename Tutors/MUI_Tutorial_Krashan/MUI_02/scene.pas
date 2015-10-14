program scene;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : scene
  Topic   : From Boopsi to MUI
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-2.html
  Sources : http://www.ppa.pl/artykuly/download/mui2.lha
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


//* This version of the program differs a little from the previous one, but */
//* operates in exactly the same way. The differences are:                  */
//* - All private classes are now MUI classes.                              */
//* - The complete program is an object of class MUIC_Application, and is   */
//*   therefore also a commodity and, has a AREXX port.                     */
//* - The program does not automatically terminates its process, but rather */
//*   waits for a press on the "Exit" gadget before doing so.               */
//*                                                                         */
//* NOTE: some of the techniques used in this program will be discussed in  */
//* the next installment of the tutorial.



uses
  Exec, AmigaDOS, Intuition, Utility, MUI,
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  AmigaLib,
  {$ENDIF}
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Sugar,
  Trinity;

Var
  Scener            : pMUI_CustomClass; //* Generic description of class sceners

Type
  TScenerInfo       = 
  record
    handle          : packed array[0..pred(20)] of Char;
    group           : packed array[0..pred(20)] of Char;
    firstname       : packed array[0..pred(20)] of Char;
    lastname        : packed array[0..pred(30)] of Char;
  end;


const
  SCEN_handle       = $9A870001;    //* These are the attribute numbers for scener */
  SCEN_Group        = $9A870002;
  SCEN_FirstName    = $9A870003;
  SCEN_LastName     = $9A870004;
  SCEN_M_Print      = $9A873333;    //* And a number for a method */


Var
  Swapper           : pMUI_CustomClass; //* And the description of the swapper. */
                                        //* We only define the characteristic   */ 
                                        //* features of a swapper               */
Type
  TSwapperInfo      =
  record      
    Nr_Contacts     : LONG;
    stamps_back     : BOOL;
  end;

Const
  SWAP_Contacts     = $9A880001;
  SWAP_StampsBack   = $9A880002;


Var
  Coder             : pMUI_CustomClass;
  
Type
  TCoderInfo        = 
  record
    Language        : packed array[0..pred(20)] of Char;
    SkillLevel      : WORD;
  end;


Const
  CODR_Language     = $9A890001;
  CODR_SkillLevel   = $9A890002;


Var
  Lamer             : pMUI_CustomClass;
  table             : array[0..pred(10)] of PChar =
  (
    'wannabe',              // "zupeînie dennym",
    'hopeless',             // "beznadziejnym",
    'beginning',            // "cienkim",
    'mediocre',             // "miernym",
    'average',              // "przeciëtnym",
    'overall pretty good',  // "w sumie niezîym",
    'good',                 // "dobrym",
    'very good',            // "bardzo dobrym",
    'fantastic',            // "fantastycznym",
    'great'                 // "doskonaîym"
  );

  Unknown           : PChar = '???';

  //* Sorry to all the musicians, graphic designers, writers, ascii-makers */
  //* and others, but this is just a tiny example.                         */


  //* Declarations of the methods for our classes */
  function  ScenerNew    (cl: pIClass; obj: pObject_; msg: Pmsg): ULONG; forward;
  function  ScenerPrint  (cl: pIClass; obj: pObject_; msg: Pmsg): ULONG; forward;
  function  SwapperNew   (cl: pIClass; obj: pObject_; msg: Pmsg): ULONG; forward;
  function  SwapperPrint (cl: pIClass; obj: pObject_; msg: Pmsg): ULONG; forward;
  function  CoderNew     (cl: pIClass; obj: pObject_; msg: Pmsg): ULONG; forward;
  function  CoderPrint   (cl: pIClass; obj: pObject_; msg: Pmsg): ULONG; forward;
  function  ScenerSet    (cl: pIClass; obj: pObject_; msg: Pmsg): ULONG; forward;

  //* Dispatcher declarations */
  function  ScenerDisp   (cl: pIClass; obj: PObject_; msg: Pmsg): ULONG; forward;
  function  SwapperDisp  (cl: pIClass; obj: PObject_; msg: Pmsg): ULONG; forward;
  function  CoderDisp    (cl: pIClass; obj: PObject_; msg: Pmsg): ULONG; forward;
  function  LamerDisp    (cl: pIClass; obj: PObject_; msg: Pmsg): ULONG; forward;

  //* Function declarations */
  procedure CreateClasses;  forward;
  procedure DestroyClasses; forward;


//**********************************************************************/


Var
  Scener1,
  Scener2,
  Scener3,
  Prog, 
  Win, 
  Gad       : p_Object;


Function Main: ULONG;
Const ProcName = 'Main';
var
  signals : ULONG;
Begin
  Enter(ProcName);

  {$IFDEF MORPHOS}
  InitIntuitionLibrary;
  {$ENDIF}

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}  
  MUIMasterBase := OpenLibrary('muimaster.library', 16);
  {$ENDIF}
  if not (MUIMasterBase <> nil) then
  begin
    WriteLn('This program requires MUI version 3.5+.');
    Exit(10);
  end;

  CreateClasses;

  //* Create the application. Usually creating all objects in one function */
  //* call to MUI_NewObject() with a set of parameters or parameters to    */
  //* a subsequent invocation of function NewObject().                     */

  {
    FPC Note:
    For Free Pascal we need a little help from our CHelper function 
    SetAndTest() in order to assign a variable in the midst of a function,
    something that isn't possible to do with Pascal default constructs.
    
    Note that for providing the tags and its accompanied tag value, we use 
    helper function TAG_(). This function serves two purposes atm. The first
    being that varargs functions are not cross-compatible atm (and TAG_()
    overcomes this problem), and the second purpose is to keep the compiler
    hint mechanism happy (function TAG_() removes many hints produced by the 
    compiler otherwise). Normal positive integer values can be provived 
    without using the TAG_() function though.
  }

  PLongWord(Prog) := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)       , TAG_(PChar('Grzegorz Kraszewski (Krashan/BlaBla)')),
    TAG_(MUIA_Application_Base)         , TAG_(PChar('SCENE')),
    TAG_(MUIA_Application_Description)  , TAG_(PChar('Program example')),
    TAG_(MUIA_Application_Title)        , TAG_(PChar('Our scene')),
    TAG_(MUIA_Application_Version)      , TAG_(PChar('$VER: scene 0.1 (8.6.98)')),
    TAG_(MUIA_Application_Window)       , TAG_(SetAndGet(win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)           , TAG_(PChar('Scene')),
      TAG_(MUIA_Window_ID)              , $5343454E,
      TAG_(MUIA_Window_RootObject)      , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)          , TAG_(SetAndGet(gad, MUI_NewObject(MUIC_Text,
        [
          TAG_(MUIA_Frame)              , TAG_(MUIV_Frame_Button),
          TAG_(MUIA_Font)               , TAG_(MUIV_Font_Button),
          TAG_(MUIA_Background)         , TAG_(MUII_ButtonBack),
          TAG_(MUIA_Text_Contents)      , TAG_(PChar(Esc_C + 'Exit')),
          TAG_(MUIA_Text_HiChar)        , TAG_(PChar('E')),
          TAG_(MUIA_ControlChar)        , TAG_(PChar('E')),
          TAG_(MUIA_InputMode)          , TAG_(MUIV_InputMode_RelVerify),
          TAG_END
        ]))),
        TAG_END
      ])),    
      TAG_END
    ]))),
    TAG_END
  ]);
  
  //* We do not need to check if the creation of each individual object was  */
  //* successfull. We just need to check if the main MUIC_Application object */
  //* was created succesfully. If an object was not created then all objects */
  //* that were created up till that moment, will be automatically disposed. */

  If (Prog <> nil) then
  begin
    
    //* Create objects */
    Scener1 := NewObject (Lamer^.mcc_Class  , nil, [TAG_END, 0]);  { FPC Note: AROS' Addtags has a bug, needs two values for a single TAG_END }

    Scener2 := NewObject (Swapper^.mcc_Class, nil,
    [
      TAG_(SCEN_Handle)     , TAG_(PChar('Ziutek')),
      TAG_(SCEN_Group)      , TAG_(PChar('Warriors')),
      TAG_(SCEN_FirstName)  , TAG_(PChar('Zenobiusz')),
      TAG_(SCEN_LastName)   , TAG_(PChar('Walikoï')),
      TAG_(SWAP_Contacts)   , 10,
      TAG_(SWAP_StampsBack) , TAG_(False),
      TAG_END
    ]);

    Scener3 := NewObject (Coder^.mcc_Class, nil,
    [
      TAG_(SCEN_Handle)     , TAG_(PChar('Kiler')),
      TAG_(SCEN_Group)      , TAG_(PChar('WypierdkiMamuta')),
      TAG_(CODR_Language)   , TAG_(PChar('Amos for Windows')),
      TAG_(CODR_SkillLevel) , 6,
      TAG_END
    ]);

    //* Notifications - Here we set the communication between gadgets */


    //* Closing the window with a gadget - exits the program */

    DoMethod (pointer(Win), MUIM_Notify, 
    [
      TAG_(MUIA_Window_CloseRequest), TAG_(MUIV_EveryTime), TAG_(Prog),
      2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
    ]);

    //* Pressing the "exit" gadget will also exit the program */

    DoMethod (Pointer(Gad), MUIM_Notify, 
    [
      TAG_(MUIA_Pressed), TAG_(FALSE), TAG_(Prog), 
      2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
    ]);

    //* Open the MUI window */

    SetAttrs (Win, [TAG_(MUIA_Window_Open), TAG_(TRUE), TAG_END]);

    //* Call printing method of the class. The SCEN_M_Print method has no parameters. */
    DoMethod (Scener2, SCEN_M_Print);
    DoMethod (Scener3, SCEN_M_Print);
    DoMethod (Scener1, SCEN_M_Print);

    //* Calling a undefined class method is not prohibited */
    DoMethod (Scener2, $DEADBABA);

    //* Also, an attempt to change a non-existent attribute is not dangerous */
    SetAttrs (Scener2, [TAG_($12345678), TAG_($87654321), TAG_END]);

    //* Change an (existing) attribute of the object */
    SetAttrs (Scener2, [TAG_(SCEN_Group), TAG_(PChar('SztuczneSzczëki')), TAG_END]);

    WriteLn('Ziutek switched groups...');
    WriteLn;

    DoMethod (Scener2, SCEN_M_Print);

    //* The main loop of the program. Its only job is waiting for completion */
    //* of the program, which can be done in several ways (receiving the     */
    //* signals MUIV_Application_ReturnID_Quit, or CTRL-C).                  */
    //* Try to press CTRL-C in the console window which the program opened.  */
    
    while (DoMethod ( Pointer(Prog), MUIM_Application_NewInput, [TAG_(@Signals)] ) <> LongWord(MUIV_Application_ReturnID_Quit)) do
    begin
      if (signals <> 0) then
      begin
        signals := Wait (signals or SIGBREAKF_CTRL_C);
        if ((signals and SIGBREAKF_CTRL_C) <> 0) then break;
      end;
    end;

    //* Let's close the MUI window */
    SetAttrs (Win, [TAG_(MUIA_Window_Open), TAG_(FALSE), TAG_END]);

    //* Destroy objects */
    DisposeObject (Scener1);
    DisposeObject (Scener2);
    DisposeObject (Scener3);
    
    //* By removing the "Program" object, all its child objects will be */
    //* removed at the same time.                                       */
    MUI_DisposeObject (pointer(Prog));
    WriteLn('End of program execution');    
  end
  else WriteLn('Error: MUIC_Application class object is not created!');
    
  DestroyClasses();

  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}  
  CloseLibrary(MUIMasterBase);
  {$ENDIF}
  result := 0;

  Leave(ProcName);
end;


//* Let's create the classes with MUI. */

procedure CreateClasses; 
Const ProcName = 'CreateClasses';
begin
  Enter(ProcName);

  {
    FPC Note:
    Note that we use InitHook() instead of providing the dispatcher
    as argument to MUI_CreateCustomClass().
    We do that to make sure we use a hook which works for all supported 
    platforms as the InitHook() function takes care of platform specifics 
    that have to be taken into account.
  }
  
  Scener    := MUI_CreateCustomClass (nil, MUIC_Notify,    nil, SizeOf(TScenerInfo)  , nil);
  InitHook(Scener^.mcc_Class^.cl_Dispatcher , THookFunction(@ScenerDisp) , nil);

  Swapper   := MUI_CreateCustomClass (nil,         nil, Scener, SizeOf(TSwapperInfo) , nil);
  InitHook(Swapper^.mcc_Class^.cl_Dispatcher, THookFunction(@SwapperDisp), nil);

  Coder     := MUI_CreateCustomClass (nil,         nil, Scener, SizeOf(TCoderInfo)   , nil);
  InitHook(Coder^.mcc_Class^.cl_Dispatcher  , THookFunction(@CoderDisp)  , nil);

  Lamer     := MUI_CreateCustomClass (nil,         nil, Scener,                    0 , nil);
  InitHook(Lamer^.mcc_Class^.cl_Dispatcher  , THookFunction(@LamerDisp)  , nil);

  Leave(ProcName);
end;


//* destroy classes */

procedure DestroyClasses; 
Const ProcName = 'DestroyClasses';
begin
  Enter(ProcName);

  MUI_DeleteCustomClass (Lamer);
  MUI_DeleteCustomClass (Coder);
  MUI_DeleteCustomClass (Swapper);
  MUI_DeleteCustomClass (Scener);
  
  Leave(ProcName);
end;


//* method implementations */

function  ScenerNew(cl: pIClass; obj: pObject_; msg: Pmsg): ULONG;
Const ProcName = 'ScenerNew';
var
  address_string: pchar;
  attributes : pTagItem;
  data : ^TScenerInfo;
begin
  Enter(ProcName);

  obj := pObject_(DoSuperMethodA(cl, obj, msg));
  if (obj = nil) then Exit(0);
  
  Attributes := popSet(msg)^.ops_AttrList;

  data := INST_DATA(cl, pointer(obj));
  
  address_string := PChar(GetTagData (SCEN_handle, 0, Attributes));
  if (address_string <> nil)
  then strlcopy(PChar(@Data^.handle), address_string, 20)
  else strlcopy(PChar(@Data^.handle), unknown, 4);

  address_string := PChar(GetTagData (SCEN_Group, 0, Attributes));
  if (address_string <> nil)
  then strlcopy(PChar(@Data^.Group), address_string, 20)
  else strlcopy(PChar(@Data^.Group), unknown, 4);

  address_string := PChar(GetTagData (SCEN_FirstName, 0, Attributes));
  if (address_string <> nil)
  then strlcopy(PChar(@Data^.firstname), address_string, 20)
  else strlcopy(PChar(@Data^.firstname), unknown, 4);

  address_string := PChar(GetTagData (SCEN_LastName, 0, Attributes));
  if (address_string <> nil)
  then strlcopy(PChar(@Data^.lastname), address_string, 30)
  else strlcopy(PChar(@Data^.lastname), unknown, 4);
  
  result := ULONG(obj);

  Leave(ProcName);
end;


function  SwapperNew(cl: pIClass; obj: pObject_; msg: Pmsg): ULONG;
Const ProcName = 'SwapperNew';
Var
  attributes : pTagItem;
  data       : ^TSwapperInfo;
begin
  Enter(ProcName);

  obj := pObject_(DoSuperMethodA(cl, obj, msg));
  if (obj = nil) then Exit(0);
  
  Attributes := popSet(msg)^.ops_AttrList;

  data := INST_DATA(cl, pointer(obj));
  
  data^.Nr_Contacts := GetTagData (SWAP_Contacts  , 0   , Attributes);
  data^.stamps_back := GetTagData (SWAP_StampsBack, LongWord(TRUE), Attributes);

  result := ULONG(obj);

  Leave(ProcName);
end;


function  CoderNew(cl: pIClass; obj: pObject_; msg: Pmsg): ULONG;
Const ProcName = 'CoderNew';
Var
  address_string: pchar;
  attributes : pTagItem;
  data       : ^TCoderInfo;
begin
  Enter(ProcName);
  
  obj := pObject_(DoSuperMethodA(cl, obj, msg));
  if (obj = nil) then Exit(0);
  
  Attributes := popSet(msg)^.ops_AttrList;

  data := INST_DATA(cl, pointer(obj));

  address_string := PChar(GetTagData (CODR_language, 0, Attributes));
  if (address_string <> nil)
  then strlcopy(PChar(@Data^.language), address_string, 20)
  else strlcopy(PChar(@Data^.language), unknown, 4);

  data^.SkillLevel := GetTagData (CODR_SkillLevel, 0 , Attributes);

  result := ULONG(obj);

  Leave(ProcName);
end;


function  ScenerPrint(cl: pIClass; obj: pObject_; msg: Pmsg): ULONG;
Var
  data: ^TScenerInfo;
begin
  data := INST_DATA(cl, pointer(obj));
  
  WriteLn(Format('Person with handle %s from the group %s, named %s %s', 
  [
    PChar(data^.handle),
    PChar(data^.group),
    PChar(data^.firstname),
    PChar(data^.lastname)
  ] ));

  result := 0;
end;


function  SwapperPrint(cl: pIClass; obj: pObject_; msg: Pmsg): ULONG;
Var
  data : ^TSwapperInfo;
begin
  //* gain access to the data object */
  data := INST_DATA(cl, pointer(obj));

  //* divert method to superclass */
  DoSuperMethodA (cl, obj, msg);

  //* Display specific characteristics for this swapper's instance */
  Write(Format('This person is a swapper, with %d contacts. ', [data^.nr_contacts] ));

  if (data^.stamps_back <> 0) 
  then WriteLn ('Always return money.')
  else WriteLn ('Never return stamps.');
  WriteLn;

  result := 0; 
end;


function  CoderPrint(cl: pIClass; obj: pObject_; msg: Pmsg): ULONG;
Var
  data : ^TCoderInfo;
begin
  data := INST_DATA(cl, pointer(obj));

  DoSuperMethodA (cl, obj, msg);

  WriteLn(Format('This person is a %s coder, and his/her favorite computer-language is %s',
  [
    table[data^.SkillLevel],
    PChar(data^.Language)
  ] ));
  WriteLn;

  result := 0;
end;


function  ScenerSet(cl: pIClass; obj: pObject_; msg: Pmsg): ULONG;
Const ProcName = 'ScenerSet';
Var
  attributes : pTagItem;
  _tag       : pTagItem;
  data       : ^TScenerInfo;
begin
  Enter(ProcName);

  Attributes := popSet(msg)^.ops_AttrList;

  data := INST_DATA(cl, pointer(obj));
 
  while SetAndTest(_tag, NextTagItem(@attributes)) do 
  begin
    {$IFDEF AMIGA}
    Case LongWord(_tag^.ti_Tag) of
    {$ELSE}
    Case _tag^.ti_Tag of
    {$ENDIF}
      SCEN_Handle: 
        if (_tag^.ti_Data <> 0) 
        then strlcopy ( PChar(@data^.handle) , PChar(_tag^.ti_Data), 20)
        else strlcopy ( PChar(@data^.handle) , Unknown, 4);

      SCEN_Group:
        if (_tag^.ti_Data <> 0) 
        then strlcopy ( PChar(@data^.group) , PChar(_tag^.ti_Data), 20)
        else strlcopy ( PChar(@data^.group) , Unknown, 4);

      SCEN_FirstName:
        if (_tag^.ti_Data <> 0) 
        then strlcopy ( PChar(@data^.firstname) , PChar(_tag^.ti_Data), 20)
        else strlcopy ( PChar(@data^.firstname) , Unknown, 4);

      SCEN_LastName:
        if (_tag^.ti_Data <> 0) 
        then strlcopy ( PChar(@data^.lastname) , PChar(_tag^.ti_Data), 30)
        else strlcopy ( PChar(@data^.lastname) , Unknown, 4);

      else 
        DoSuperMethodA (cl,obj,msg);
    end;
  end;

  result := 0; 
  
  Leave(ProcName);
end;


//* Dispatchers */

function  ScenerDisp(cl: pIClass; obj: PObject_; msg: Pmsg): ULONG;
Const ProcName = 'ScenerDisp';
begin
  Enter(ProcName);

  Case msg^.MethodID of
    OM_NEW       : result := ScenerNew (cl,obj,msg);
    OM_SET       : result := ScenerSet (cl,obj,msg);
    SCEN_M_PRINT : result := ScenerPrint (cl,obj,msg);
    else           result := DoSuperMethodA (cl,obj,msg);
  end;

  Leave(ProcName);
end;


function  SwapperDisp(cl: pIClass; obj: PObject_; msg: Pmsg): ULONG;
Const ProcName = 'SwapperDisp';
begin
  Enter(ProcName);

  Case msg^.MethodID of
    OM_NEW       : result := SwapperNew (cl,obj,msg);
    SCEN_M_PRINT : result := SwapperPrint (cl,obj,msg);
    else           result := DoSuperMethodA (cl,obj,msg);
  end;

  Leave(ProcName);
end;


function  CoderDisp(cl: pIClass; obj: PObject_; msg: Pmsg): ULONG;
Const ProcName = 'CoderDisp';
begin
  Enter(ProcName);

  Case msg^.MethodID of
    OM_NEW       : result := CoderNew   (cl,obj,msg);
    SCEN_M_PRINT : result := CoderPrint (cl,obj,msg);
    else           result := DoSuperMethodA (cl,obj,msg);
  end;

  Leave(ProcName);
end;


function  LamerDisp(cl: pIClass; obj: PObject_; msg: Pmsg): ULONG;
Const ProcName = 'LamerDisp';
begin
  Enter(ProcName);

  if (msg^.MethodID = SCEN_M_Print) then
  begin
    DoSuperMethodA (cl,obj,msg);

    WriteLn ('This person is a complete Lamer and isn''t worth a bit.');
    WriteLn;
    result := 0;
  end
  else result := DoSuperMethodA (cl,obj,msg);

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
