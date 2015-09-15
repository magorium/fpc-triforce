program example14a;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/Sugar}

{
  ===========================================================================
  Project : example14a
  Topic   : Graphic sample viewer
  Author  : Grzegorz "Krashan" Kraszewski
  Date    : 1998-2005-2015
  Article : http://www.ppa.pl/programy/kurs-mui-czesc-13.html
  Sources : http://www.ppa.pl/artykuly/download/mui13.lha
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

       Unless otherwise noted, you should consider these examples to be 
                 copyrighted by their respective owners

  ===========================================================================  
}

Uses
  Exec, AmigaDOS, AGraphics, Intuition, MUI, Utility,
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  AmigaLib,
  {$ENDIF}
  {$IFDEF AMIGA}
  systemvartags,
  {$ENDIF}
  CHelpers,
  Sugar,
  Trinity;  

  {
    FPC Note:
    The original example 'peeked' into Chip-ram, which can not be done
    on the other platforms. Therefor we create a samplebuffer to contain 
    some sample data to be viewed.
  }
Var
  SampleData        : Array[0..(1024*8)-1] of SmallInt;


Var
  App,
  Win,
  BStr,
  SStr,
  EStr,
  Wyk               : pObject_;


//* Class attribute definitions */

Const
  WYKA_Buffer       = $6EDA7230;    //* [ISG] Start address of the sample  */
  WYKA_SampleStart  = $6EDA7232;    //* [ISG] Sample number which is drawn */
  WYKA_SampleLenght = $6EDA7233;    //* [ISG] Number of samples visible    */


//* Here's the Viewer class */

Var
  SampleviewClass   : pMUI_CustomClass;
  

//* Object data */

Type
  PSampleviewData = ^TSampleviewData;
  TSampleviewData = record
    buffer  : PWORD;    //* Pointer to sample buffer (memory address) */
    first   : LONG;
    lenght  : LONG;  
  end;


  //* Function definition for the dispatcher (implementation is located further down) */
  function SampleviewDispatcher(cl: pIClass; obj: pObject_; msg: intuition.pMsg): LONG; forward;

  
//* Function for creating a class diagram */

Function CreateSampleviewClass: Boolean;
Const ProcName = 'CreateSampleviewClass';
begin
  Enter(ProcName);

  SampleviewClass := MUI_CreateCustomClass (nil, MUIC_Area, nil, sizeof(TSampleviewData), nil);
  InitHook(SampleViewClass^.mcc_Class^.cl_Dispatcher, THookFunction(@SampleViewDispatcher), nil);
  result := (SampleviewClass <> nil);

  Leave(ProcName);
end;
  

//* Function Chart eliminating classes */

procedure DeleteSampleviewClass;
Const ProcName = 'DeleteSampleviewClass';
begin
  Enter(ProcName);

  if (SampleviewClass <> nil) then MUI_DeleteCustomClass (SampleviewClass);

  Leave(ProcName);
end;


//* method New */

function mNew(cl: pIClass; obj: pObject_; msg: popSet): LONG;
Const ProcName = 'mNew';
Var
  Data : PSampleviewData;
begin
  Enter(ProcName);

  if SetAndTest(obj, pObject_(DoSuperMethodA (cl, obj, msg))) then
  begin
    data := INST_DATA (cl,pointer(obj));
    data^.buffer  := pWord(GetTagData (WYKA_Buffer      , 0, msg^.ops_AttrList));
    data^.first   :=       GetTagData (WYKA_SampleStart , 0, msg^.ops_AttrList);
    data^.lenght  :=       GetTagData (WYKA_SampleLenght, 0, msg^.ops_AttrList);
    exit(LongWord(obj));
  end;
  CoerceMethod (cl, obj, OM_DISPOSE);
  result := 0;

  Leave(ProcName);
end;


//* method Draw */

function mDraw(cl: pIClass; obj: pObject_; msg: pMUIP_Draw): LONG;
Const ProcName = 'mDraw';
Var
  data    : PSampleViewData;
  samples : LONG;
  half    : WORD;
Var
  samplevalue     : SmallInt; //* original (stored) sample value */
  step            : LONG;
  height          : LONG;     //* Height of a sample expressed in pixels */
var
  sample_numberW  : WORD;
  positionL       : LONG;     //* Horizontal position of the sample expressed in pixels */
var
  sample_numberL  : LONG;
  positionW       : WORD;     //* Horizontal position of the sample expressed in pixels */
  remd            : LONG;
  remdacc         : LONG;

begin
  Enter(ProcName);

  data    := INST_DATA(cl, pointer(obj));
  samples := data^.lenght;
  half    := (OBJ_mtop(obj) + OBJ_mbottom(obj)) shr 1;

  DoSuperMethodA (cl, obj, intuition.pMsg(msg));

  //* use a black background */
  SetAPen  (OBJ_rp(obj), 1);
  RectFill (OBJ_rp(obj), OBJ_mleft(obj), OBJ_mtop(obj), OBJ_mright(obj), OBJ_mbottom(obj));
  SetAPen  (OBJ_rp(obj), 2);
  GfxMove  (OBJ_rp(obj), OBJ_mleft(obj), half);

  //* Drawing for when there's no valid buffer or there are no sample values to display */
  if ( ( data^.buffer = nil ) or ( samples <= 0 ) ) then
  begin
    Draw (OBJ_rp(obj), OBJ_mright(obj), half);
  end

  //* Drawing for when there are more pixels then sample data */
  else if (samples <= OBJ_mwidth(obj)) then
  begin
    step      := (OBJ_mwidth(obj) shl 16) div samples;
    positionL := OBJ_mleft(obj)   shl 16;

    for sample_numberW := data^.first to ( data^.first + data^.lenght - 1 ) do
    begin
      samplevalue := data^.buffer[sample_numberW];
      height := OBJ_mbottom(obj) - ((OBJ_mheight(obj) * (samplevalue + 32768)) shr 16);
      Draw (OBJ_rp(obj), positionL shr 16, height);
      positionL := positionL + step;
      Draw (OBJ_rp(obj), positionL shr 16, height);
    end;
  end

  //* Drawing for when there are less pixels then sample data */
  else
  begin
    step  := samples div OBJ_mwidth(obj);  //* the total fraction of the number of samples per pixel */
    remd  := samples mod OBJ_mwidth(obj);  //* part of the "fractional" number of samples per pixel */
    sample_numberL := data^.first;         //* the total sample part number */
    remdacc  := 0;                         //* a fraction of the sample number */

    for positionW := OBJ_mleft(obj) to OBJ_mright(obj) do
    begin
      samplevalue := data^.buffer[sample_numberL];
      height := OBJ_mbottom(obj) - ((OBJ_mheight(obj) * (samplevalue + 32768)) shr 16);
      Draw (OBJ_rp(obj), positionW, height);
      sample_numberL := sample_numberL + step;
      remdacc := remdacc + remd;
      if (remdacc >= OBJ_mwidth(obj)) then
      begin
        remdacc := remdacc - OBJ_mwidth(obj);
        sample_numberL := sample_numberL + 1;
      end;
    end;
  end;

  Leave(ProcName);
end;


//* method Set */

function mSet(cl: pIClass; obj: pObject_; msg: popSet): LONG;
Const ProcName = 'mSet';
var
  data   : pSampleViewData;
  tag    : pTagItem;
  tagPtr : pTagItem;
begin
  Enter(ProcName);

  data   := INST_DATA(cl, pointer(obj));
  tagPtr := msg^.ops_AttrList;

  while SetAndTest(Tag, NextTagItem(@TagPtr)) do
  begin
    case (tag^.ti_Tag) of
      WYKA_Buffer:
      begin
        data^.buffer := pWORD(tag^.ti_Data);
        MUI_Redraw (obj, MADF_DRAWUPDATE);
      end;

      WYKA_SampleStart:
      begin
       data^.first := tag^.ti_Data;
       MUI_Redraw (obj, MADF_DRAWUPDATE);
      end;

      WYKA_SampleLenght:
      begin
        data^.lenght := tag^.ti_Data;
        MUI_Redraw (obj, MADF_DRAWUPDATE);
      end;
    end; // case
  end;
  result := (DoSuperMethodA (cl, obj, intuition.PMsg(msg) ) );  

  Leave(ProcName);
end;


//* method Get */

function mGet(cl: pIClass; obj: pObject_; msg: popGet): LONG;
Const ProcName = 'mGet';
Var
  data : pSampleViewData;
begin
  Enter(ProcName);

  data := INST_DATA(cl, pointer(obj));

  case (msg^.opg_AttrID) of
    WYKA_Buffer         : 
    begin
      PULONG(msg^.opg_Storage)^ := LONG(data^.buffer); 
      LongBool(result) := TRUE;
    end;
    WYKA_SampleStart    : 
    begin
      PULONG(msg^.opg_Storage)^ := data^.first;
      LongBool(result) := TRUE;
    end;
    WYKA_SampleLenght   : 
    begin
      PULONG(msg^.opg_Storage)^ := data^.lenght;
      LongBool(result) := TRUE;
    end;
    else
      result := (DoSuperMethodA (cl, obj, intuition.pmsg(msg) ));
  end; // case

  Leave(ProcName);
end;


//* method AskMinMax */

function mAskMinMax(cl: pIClass; obj: pObject_; msg: pMUIP_AskMinMax): LONG;
Const ProcName = 'mAskMinMax';
begin
  Enter(ProcName);

  DoSuperMethodA (cl, obj, intuition.pmsg(msg));

  msg^.MinMaxInfo^.MinWidth  := msg^.MinMaxInfo^.MinWidth  + 50;
  msg^.MinMaxInfo^.DefWidth  := msg^.MinMaxInfo^.DefWidth  + 200;
  msg^.MinMaxInfo^.MaxWidth  := msg^.MinMaxInfo^.MaxWidth  + MUI_MAXMAX;

  msg^.MinMaxInfo^.MinHeight := msg^.MinMaxInfo^.MinHeight + 25;
  msg^.MinMaxInfo^.DefHeight := msg^.MinMaxInfo^.DefHeight + 100;
  msg^.MinMaxInfo^.MaxHeight := msg^.MinMaxInfo^.MaxHeight + MUI_MAXMAX;

  result := 0;

  Leave(ProcName);
end;


//* This is the Sampleview dispatcher */

function  SampleviewDispatcher(cl: pIClass; obj: pObject_; msg: Intuition.PMsg): LONG;
Const ProcName = 'SampleviewDispatcher';
begin
  Enter(ProcName);

  case msg^.MethodID of
    OM_NEW          : result := (mNew ( cl, obj, popSet(msg) ));
    OM_SET          : 
    begin
      writeln('dispatcher OM_SET');
      result := (mSet ( cl, obj, popSet(msg) ));
    end;
    OM_GET          : 
    begin
      writeln('dispatcher OM_GET');
      result := (mGet ( cl, obj, popGet(msg) ));
    end;
    MUIM_Draw       : result := (mDraw (cl, obj, pMUIP_Draw(msg) ));
    MUIM_AskMinMax  : result := (mAskMinMax (cl, obj, pMUIP_AskMinMax(msg) ));
    else              result := (DoSuperMethodA (cl, obj, msg));
  end;

  Leave(ProcName);
end;


//* Hook implementations of the Sampleview */

Const
  UPDATE_BUFFER = 1;
  UPDATE_START  = 2;
  UPDATE_END    = 3;


Function Update(hook: pHook; View: pObject_; parametr: PLONG): LONG;
Const ProcName = 'Update';
var
  v: LONG;
begin
  Enter(ProcName);

  Case parametr^ of
    UPDATE_BUFFER:
    begin
      GetAttr (MUIA_String_Integer, BStr, @v);
      SetAttrs (View, [TAG_(WYKA_Buffer), TAG_(v), TAG_END]);
    end;
    UPDATE_START:
    begin
      GetAttr (MUIA_String_Integer, SStr, @v);
      SetAttrs (View, [TAG_(WYKA_SampleStart), TAG_(v), TAG_END]);
    end;
    UPDATE_END:
    begin
      GetAttr (MUIA_String_Integer, EStr, @v);
      SetAttrs (View, [TAG_(WYKA_SampleLenght), TAG_(v), TAG_END]);
    end;
  end; // case

  result := 0; 
  
  Leave(ProcName);
end;


Var
  h_Update: THook;


//* Function that creates the GUI */

function BuildApplication: boolean;
Const ProcName = 'BuildApplication';
begin
  Enter(ProcName);

  App := MUI_NewObject (MUIC_Application,
  [
    TAG_(MUIA_Application_Author)           , TAG_(PChar('Grzegorz "Krashan" Kraszewski')),
    TAG_(MUIA_Application_Base)             , TAG_(PChar('EXAMPLE14A')),
    TAG_(MUIA_Application_Copyright)        , TAG_(PChar('© 2000 by Grzegorz Kraszewski')),
    TAG_(MUIA_Application_Description)      , TAG_(PChar('Example 14a to the MUI tutorial')),
    TAG_(MUIA_Application_Title)            , TAG_(PChar('Example14a')),
    TAG_(MUIA_Application_Version)          , TAG_(PChar('$VER: example14a 1.0 (21.9.2000)')),
    TAG_(MUIA_Application_Window)           , TAG_(SetAndGet(Win, MUI_NewObject (MUIC_Window,
    [
      TAG_(MUIA_Window_Title)               , TAG_(PChar('Example 14a')),
      TAG_(MUIA_Window_ID)                  , $57594B52,
      TAG_(MUIA_Window_RootObject)          , TAG_(MUI_NewObject (MUIC_Group,
      [
        TAG_(MUIA_Group_Child)              , TAG_(SetAndGet(Wyk, NewObject (SampleViewClass^.mcc_Class, nil,
        [
          TAG_(MUIA_Frame)                  , TAG_(MUIV_Frame_InputList),
          TAG_(MUIA_Background)             , TAG_(MUII_ListBack),
          {
            FPC Note:
            We can't just peek into memory on all supported platforms,
            so instead look at our own defined sample buffer
          }
          TAG_(WYKA_Buffer)                 , TAG_(@SampleData[0]),
          TAG_(WYKA_SampleStart)            , 0,
          TAG_(WYKA_SampleLenght)           , 250,
          TAG_END
        ]))),
        TAG_(MUIA_Group_Child)              , TAG_(MUI_NewObject (MUIC_Group,      
        [                                                                        
          TAG_(MUIA_Group_Horiz)            , TAG_(TRUE),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)        , TAG_(PChar('Buffer')),
            TAG_(MUIA_HorizWeight)          , 0,
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_(MUIA_FramePhantomHoriz)    , TAG_(TRUE),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(SetAndGet(BStr, MUI_NewObject (MUIC_String,
          [
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_(MUIA_CycleChain)           , TAG_(TRUE),
            TAG_(MUIA_String_AdvanceOnCR)   , TAG_(TRUE),
            TAG_(MUIA_String_Accept)        , TAG_(PChar('0123456789')),
            {
              FPC Note: Use address value accordingly with our sample buffer
            }
            TAG_(MUIA_String_Integer)       , TAG_(@SampleData[0]),
            TAG_END
          ]))),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)        , TAG_(PChar('start position')),
            TAG_(MUIA_HorizWeight)          , 0,
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_(MUIA_FramePhantomHoriz)    , TAG_(TRUE),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(SetAndGet(SStr, MUI_NewObject (MUIC_String,
          [
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_(MUIA_CycleChain)           , TAG_(TRUE),
            TAG_(MUIA_String_AdvanceOnCR)   , TAG_(TRUE),
            TAG_(MUIA_String_Accept)        , TAG_(PChar('0123456789')),
            TAG_(MUIA_String_Integer)       , 0,
            TAG_END
          ]))),
          TAG_(MUIA_Group_Child)            , TAG_(MUI_NewObject (MUIC_Text,
          [
            TAG_(MUIA_Text_Contents)        , TAG_(PChar('length')),
            TAG_(MUIA_HorizWeight)          , 0,
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_(MUIA_FramePhantomHoriz)    , TAG_(TRUE),
            TAG_END
          ])),
          TAG_(MUIA_Group_Child)            , TAG_(SetAndGet(EStr, MUI_NewObject (MUIC_String,
          [
            TAG_(MUIA_Frame)                , TAG_(MUIV_Frame_String),
            TAG_(MUIA_CycleChain)           , TAG_(TRUE),
            TAG_(MUIA_String_AdvanceOnCR)   , TAG_(TRUE),
            TAG_(MUIA_String_Accept)        , TAG_(PChar('0123456789')),
            TAG_(MUIA_String_Integer)       , 250,
            TAG_END
          ]))),
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


//* Initialize notifications */

procedure SetNotifications;
Const ProcName = 'SetNotifications';
begin
  Enter(ProcName);
  
  DoMethod (Win, MUIM_Notify, 
  [
    TAG_(MUIA_Window_CloseRequest), TAG_(MUIV_EveryTime), TAG_(App), 
    2, TAG_(MUIM_Application_ReturnID), TAG_(MUIV_Application_ReturnID_Quit)
  ]);
  
  inithook(h_update, THookFunction(@Update), nil);

  DoMethod (BStr, MUIM_Notify, 
  [
    TAG_(MUIA_String_Acknowledge), TAG_(MUIV_EveryTime), TAG_(Wyk), 
    3, TAG_(MUIM_CallHook), TAG_(@h_Update), TAG_(UPDATE_BUFFER)
  ]);

  DoMethod (SStr, MUIM_Notify, 
  [
    TAG_(MUIA_String_Acknowledge), TAG_(MUIV_EveryTime), TAG_(Wyk), 
    3, TAG_(MUIM_CallHook), TAG_(@h_Update), TAG_(UPDATE_START)
  ]);

  DoMethod (EStr, MUIM_Notify, 
  [
    TAG_(MUIA_String_Acknowledge), TAG_(MUIV_EveryTime), TAG_(Wyk), 
    3, TAG_(MUIM_CallHook), TAG_(@h_Update), TAG_(UPDATE_END)
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

  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if not ( SetAndTest( GfxBase      , OpenLibrary('graphics.library'  , 39))) then exit(false);
  {$ENDIF}
  {$IFDEF MORPHOS}
  if not ( SetAndTest( IntuitionBase, OpenLibrary('intuition.library' , 39))) then exit(false);
  {$ENDIF}
  {$IFNDEF HASAMIGA}
  if not ( SetAndTest( UtilityBase  , OpenLibrary('utility.library'   , 39))) then exit(false);
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
  {$IFNDEF HASAMIGA}
  if (UtilityBase    <> nil) then CloseLibrary(UtilityBase);
  {$ENDIF}
  {$IFDEF MORPHOS}
  if (IntuitionBase  <> nil) then CloseLibrary(pointer(IntuitionBase));
  {$ENDIF}
  {$IF DEFINED(MORPHOS) or DEFINED(AMIGA)}
  if (GfxBase        <> nil) then CloseLibrary(pointer(GfxBase));
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
    if CreateSampleViewClass then
    begin
      if BuildApplication then
      begin
        SetNotifications;
        MainLoop;
        MUI_DisposeObject(App);
      end;
    end;
    DeleteSampleViewClass;
  end;
  CloseLibs;
  result := 0;

  Leave(ProcName);
end;


{
  FPC Note:
  This routine is not present in the original c-source because the original 
  c-source displays contents of chip memory using a direct memory location.
  
  Because it's not safe todo so for AROS and MorphOS we store some sine
  data in a special designated buffer in order to have data to be viewed.
  
  This routine calculates the sine values and fills that buffer.
}

Procedure CalcSineWave(Var SampleStorage: Array of smallint; Frequency: Integer; SampleRate: Integer);
Var
  Hz : Integer;     // frequency in hertz of sample (cycles per second)
  SR : integer;     // Sample Rate
  SL : LongWord;    // Length of the sample (in number of samples)
  SA : SmallInt;    // Max. Amplitude of sample
  SF : single;      // Frequency of the sample
  T  : Integer;
begin
  Hz := Frequency;
  SL := High(SampleStorage);
  SA := MaxSmallInt;
  SR := SampleRate;
  SF := (2*pi*hz)/SR;
  For T := 0 to SL do
  begin
    SampleStorage[T] := Round( SA * sin(SF * T) );
  end;
end;


//
//        Startup
//

begin
  WriteLn('enter');

  { FPC Note: fill some data into our wave buffer }
  CalcSineWave(SampleData, 440, 22000);
  
  ExitCode := Main;

  WriteLn('leave');  
end.
