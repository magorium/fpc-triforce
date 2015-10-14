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
  Topic   : Boopsi classes
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-1.html
  Sources : http://www.ppa.pl/artykuly/download/mui1.lha
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


uses
  Exec, Intuition, Utility,
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
  Scener            : pIClass;      //* Generic description of class sceners

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
  Swapper           : pIClass;      //* And the description of the swapper. */
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
  Coder             : pIClass;
  
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
  Lamer             : pIClass;
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
  Scener3 : p_Object;



Function  Main: ULONG;
Const ProcName = 'Main';
Begin
  Enter(ProcName);

  {$IFDEF MORPHOS}
  InitIntuitionLibrary;
  {$ENDIF}

  CreateClasses;
  
  //* Create objects */
  Scener1 := NewObject (Lamer  , nil, [TAG_END, 0]);  { FPC Note: AROS' Addtags has a bug, needs two values for a single TAG_END }

  Scener2 := NewObject (Swapper, nil,
  [
    TAG_(SCEN_Handle)     , TAG_(PChar('Ziutek')),
    TAG_(SCEN_Group)      , TAG_(PChar('Warriors')),
    TAG_(SCEN_FirstName)  , TAG_(PChar('Zenobiusz')),
    TAG_(SCEN_LastName)   , TAG_(PChar('Walikoï')),
    TAG_(SWAP_Contacts)   , 10,
    TAG_(SWAP_StampsBack) , TAG_(False),
    TAG_END
  ]);

  Scener3 := NewObject (Coder, nil,
  [
    TAG_(SCEN_Handle)     , TAG_(PChar('Kiler')),
    TAG_(SCEN_Group)      , TAG_(PChar('WypierdkiMamuta')),
    TAG_(CODR_Language)   , TAG_(PChar('Amos for Windows')),
    TAG_(CODR_SkillLevel) , 6,
    TAG_END
  ]);

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

  //* Destroy objects */
  DisposeObject (Scener1);
  DisposeObject (Scener2);
  DisposeObject (Scener3);
  DestroyClasses();

  result := 0;

  Leave(ProcName);
end;


//* Let's create the classes with BOOPSI. */

procedure CreateClasses; 
Const ProcName = 'CreateClasses';
begin
  Enter(ProcName);

  { 
    FPC Note:
    Note that we use InitHook() instead setting the h_entry field of 
    the dispatcher manually (as the original c-source does).
    We do that to make sure the hook works for all supported platforms as
    the InitHook() function takes care of platform specifics that have to
    be taken into account.
  }

  Scener    := MakeClass (nil, PChar('rootclass'), nil, SizeOf(TScenerInfo), 0);
  InitHook(Scener^.cl_Dispatcher, THookFunction(@ScenerDisp), nil);

  Swapper   := MakeClass (nil, nil, Scener, SizeOf(TSwapperInfo),0);
  InitHook(Swapper^.cl_Dispatcher, THookFunction(@SwapperDisp), nil);

  Coder     := MakeClass (nil, nil, Scener, SizeOf(TCoderInfo),0);
  InitHook(Coder^.cl_Dispatcher, THookFunction(@CoderDisp), nil);

  Lamer     := MakeClass (nil, nil, Scener, 0, 0);
  InitHook(Lamer^.cl_Dispatcher, THookFunction(@LamerDisp), nil);
  
  Leave(ProcName);
end;


//* destroy classes */

procedure DestroyClasses; 
Const ProcName = 'DestroyClasses';
begin
  Enter(ProcName);

  FreeClass (Lamer);
  FreeClass (Coder);
  FreeClass (Swapper);
  FreeClass (Scener);
  
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
  
  data^.Nr_Contacts := GetTagData (SWAP_Contacts            , 0   , Attributes);
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
