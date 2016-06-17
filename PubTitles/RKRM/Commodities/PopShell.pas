program PopShell;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : PopShell
  Topic     : Simple hot key commodity
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, Workbench, AmigaDos, Icon, Commodities, InputEvent,
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  amigalib,
  {$ENDIF}
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  keymap,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;


  {$IFDEF AMIGA}
  // (re)define structure Newbroker from commodities.pas in order
  // to align the structure properly with packrecords 2.
  // Not doing so result in a crash because fields are not aligned properly
  // otherwise.
  {$PACKRECORDS 2}
  Type
  tNewBroker = record
   nb_Version           : Shortint;     // set to NB_VERSION
   nb_Name,
   nb_Title,
   nb_Descr             : STRPTR;
   nb_Unique,
   nb_Flags             : smallint;
   nb_Pri               : Shortint;
   // new in V5
   nb_Port              : pMsgPort;
   nb_ReservedChannel   : smallint;     // plans for later port sharing
  end;
  {$ENDIF}

const
  EVT_HOTKEY    = 1;

var
  broker_mp : PMsgPort;
  
  broker,
  filter    : PCxObj;

  newbroker : TNewBroker =
  (
    nb_Version          : NB_VERSION;
    nb_Name             : 'RKM PopShell';                   //* string to identify this broker */
    nb_Title            : 'A Simple PopShell';                         
    nb_Descr            : 'A simple PopShell commodity';
    nb_Unique           : NBU_UNIQUE or NBU_NOTIFY;         //* Don't want any new commodities starting with this name. */
                                                            //* If someone tries it, let me know */
    nb_Flags            : 0;
    nb_Pri              : 0;
    nb_Port             : nil;
    nb_ReservedChannel  : 0
  );

  newshell  : PChar = #13'llehswen';   //* "newshell" spelled backwards */
  ie        : PInputEvent;
  cxsigflag : ULONG;
  
  
  procedure main(argc: integer; argv: PPChar); forward;
  procedure ProcessMsg; forward;


{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
//////////////////////////////////////////////////////////////////////////////

{$IFDEF MORPHOS}
const
  IESUBCLASS_NEWTABLET  = $03;

procedure FreeIEvents(ie: PInputEvent);
var
  next: PInputEvent;
begin
  next := ie;
  
  while (next <> nil) do
  begin
    next := ie^.ie_NextEvent;

    if (
      ( ie^.ie_Class = IECLASS_NEWPOINTERPOS ) and
      (
        (ie^.ie_SubClass = IESUBCLASS_TABLET) or
        (ie^.ie_SubClass = IESUBCLASS_NEWTABLET) or
        (ie^.ie_SubClass = IESUBCLASS_PIXEL)
      )
    )
    // then FreeVec(ie^.ie_EventAddress);
    then FreeVec(ie^.ie_position.ie_addr);

    FreeMem(ie, sizeof(TInputEvent));
    ie := next;
  end;
end;
{$ENDIF}


var
  __alib_dObject : PDiskObject = nil;   //* Used for reading tooltypes */


function ArgArrayInit(argc: ULONG; argv: PPChar): PPChar;
var
  olddir    : BPTR;
  startup   : PWBStartup;
begin
  startup := PWBStartup(argv);
  
  if (argc <> 0)
  then exit(argv);

  if (startup^.sm_NumArgs >= 1) then
  begin
    olddir := CurrentDir(PWBArg(startup^.sm_ArgList)[0].wa_Lock);
    __alib_dObject := GetDiskObject(PWBArg(startup^.sm_ArgList)[0].wa_Name);
    CurrentDir(olddir);
  end
  else
    exit(nil);

  if (__alib_dObject = nil)
  then exit(nil);
  
  result := PPChar(__alib_dObject^.do_ToolTypes);
end;


function ArgInt(tt: PPChar; entry: STRPTR; defaultval: LongInt): LongInt;
var
  match : STRPTR;
begin
  match := FindToolType(tt, entry);
  if match = nil
  then result := defaultval
  else result := StrToIntDef(match, 0);
end;


procedure ArgArrayDone;
begin
  if (__alib_dObject <> nil)
  then FreeDiskObject(__alib_dObject);
end;


function ArgString(tt: PPChar; entry: STRPTR; defaultString: STRPTR): STRPTR;
var
  match: STRPTR;
begin
  match := FindToolType(tt, entry);
  if (match = nil)
  then Result := defaultstring
  else Result := match;
end;


function  InvertStringForwd(str: STRPTR; km: PKeyMap): PInputEvent;
{$IFDEF AMIGA}
Type
  TIX = IX;
{$ENDIF}
var
  ieChain   : PInputEvent = nil;
  ie        : PInputEvent;
  first     : PInputEvent = nil;
  ansiCode  : UBYTE;
  start     : PChar;
var
  ix        : TIX;
  err       : LONG;

begin
  while (str <> nil) and (str^ <> #0) do
  begin
    ie := ExecAllocMem(sizeof(TInputEvent), MEMF_PUBLIC or MEMF_CLEAR);
    if (ie = nil) then
    begin
      if (first <> nil)
      then FreeIEvents(first);
      exit(nil);;
    end;
         
    if (first = nil)
    then first := ie;
         
    if (ieChain <> nil)
    then ieChain^.ie_NextEvent := ie;            
         
    ieChain := ie;
        
    ie^.ie_Class := IECLASS_RAWKEY;
    //ie^.ie_EventAddress := nil;
    ie^.ie_position.ie_addr := nil;

    case (str^) of
      '\' :
      begin
        inc(str);
        case (str^) of
          't': ansiCode := Ord(#09);  // tab
          'r', 
          'n': ansiCode := Ord(#10);
          '\': ansiCode := Ord('\');
          else 
               //* FIXME: What to do if "\x" comes? */
               //* stegerg: This? */
               ansiCode := Ord(str^);
        end;
  
        if (InvertKeyMap(ansiCode, ie, km) = FALSE) then
        begin
          FreeIEvents(first);
          exit(nil);
        end;

        inc(str);
      end;

      '<' :
      begin
        inc(str);
        start := str;

        while (str^ <> #0) and (str^ <> '>') do inc(str);
        begin
          ix := default(TIX);

          str^ := #0;
          err := ParseIX(start, @ix);
          str^ := '>'; inc(str);

          if (err < 0) then
          begin
            FreeIEvents(first);
            exit(nil);
          end;

          ie^.ie_Class     := ix.ix_Class;
          ie^.ie_Code      := ix.ix_Code;
          ie^.ie_Qualifier := ix.ix_Qualifier;
        end;
      end;

      else
      begin
        if (InvertKeyMap(Ord(str^), ie, km) = FALSE) then
        begin
          inc(str);
          FreeIEvents(first);
          exit(nil);
        end;
        inc(str);
      end;
    end;
  end;
  InvertStringForwd := first;
end;


function  InvertString(str: STRPTR; km: PKeyMap): PInputEvent;
var
  first, second, third, fourth: PInputEvent;
begin
  first := InvertStringForwd(str, km);

  if (first <> nil) then
  begin
    fourth := first;
    third := first^.ie_NextEvent;
    while (third <> nil) do
    begin
      second := first;
      first := third;
      third := first^.ie_NextEvent;
      first^.ie_NextEvent := second;
    end;
    fourth^.ie_NextEvent := nil;
  end;
  InvertString := first;
end;


function  HotKey(description: STRPTR; port: PMsgPort; id: LONG): PCxObj;
var
  filter        : PCxObj;       //* The objects making up the hotkey */
  sender        : PCxObj;       //* functionality... */
  translator    : PCxObj;
begin
  filter := CxFilter(description);
  
  if (filter = nil)
  then exit(nil);

  sender := CxSender(port, id);
  if (sender = nil) then
  begin
    DeleteCxObj(filter);
    exit(nil);
  end;

  AttachCxObj(filter, sender);

  //* Create the commodities equivalent of NIL: */
  translator := CxTranslate(nil);
  if (translator = nil) then
  begin
    DeleteCxObjAll(filter);
    exit(nil);
  end;

  AttachCxObj(filter, translator);

  HotKey := filter;
end;

//////////////////////////////////////////////////////////////////////////////
{$ENDIF}


procedure Main(argc: Integer; ArgV: PPChar);
var
  ttypes    : PPChar;
  ahotkey   : PChar;
  msg       : PCxMsg;
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if SetAndTest(CxBase, OpenLibrary('commodities.library', 37)) then
  {$ENDIF}
  begin
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    if SetAndTest(IconBase, OpenLibrary('icon.library', 36)) then
    {$ENDIF}
    begin
      if SetAndTest(broker_mp, CreateMsgPort) then
      begin
        newbroker.nb_Port := broker_mp;
        cxsigflag := 1 shl broker_mp^.mp_SigBit;
        ttypes := ArgArrayInit(argc, argv);
        newbroker.nb_Pri := BYTE(ArgInt(ttypes, 'CX_PRIORITY', 0));
        ahotkey := ArgString(ttypes, 'HOTKEY', 'rawkey control esc');

        if SetAndTest(broker, CxBroker(@newbroker, nil)) then
        begin
          //* HotKey() is an amiga.lib function that creates a filter, sender */
          //* and translate CxObject and connects them to report a hot key    */
          //* press and delete its input event. */
          if SetAndTest(filter, HotKey(ahotkey, broker_mp, EVT_HOTKEY)) then
          begin
            AttachCxObj(broker, filter);    //* Add a CxObject to another's personal list */

            if not(CxObjError(filter) <> 0) then
            begin
              //* InvertString() is an amiga.lib function that creates a linked */
              //* list of input events which would translate into the string    */
              //* passed to it.  Note that it puts the input events in the      */
              //* opposite order in which the corresponding letters appear in   */
              //* the string.  A translate CxObject expects them backwards.     */
              if SetAndTest(ie, InvertString(newshell, nil)) then
              begin
                ActivateCxObj(broker, 1);
                ProcessMsg;
                //* we have to release the memory allocated by InvertString.       */
                FreeIEvents(ie);
              end;
            end;
          end;
            
          //* DeleteCxObjAll() is a commodities.library function that not only      */
          //* deletes the CxObject pointed to in its argument, but deletes all of   */
          //* the CxObjects attached to it.                                         */
          DeleteCxObjAll(broker);

          //* Empty the port of all CxMsgs */
          while SetAndTest(msg, PCxMsg(GetMsg(broker_mp)))
            do ReplyMsg(PMessage(msg));
        end;

        DeletePort(broker_mp);
      end;
      //* this amiga.lib function cleans up after ArgArrayInit() */
      ArgArrayDone();
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      CloseLibrary(IconBase);
      {$ENDIF}
    end;
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    CloseLibrary(CxBase);
    {$ENDIF}
  end;
end;


procedure ProcessMsg;
var
  msg           : PCxMsg;

  sigrcvd, 
  msgid, 
  msgtype       : ULONG;

  returnvalue   : LONG  = 1;
begin
  while (returnvalue <> 0) do
  begin
    sigrcvd := Wait(SIGBREAKF_CTRL_C or cxsigflag);

    while SetAndTest(msg, PCxMsg(GetMsg(broker_mp))) do
    begin
      msgid := CxMsgID(msg);
      msgtype := CxMsgType(msg);
      ReplyMsg(PMessage(msg));

      case (msgtype) of
        CXM_IEVENT:
        begin
          Write('A CXM_EVENT, "');
          case (msgid) of
            EVT_HOTKEY: //* We got the message from the sender CxObject */
            begin
              WriteLn('You hit the HotKey.');
              //* Add the string "newshell" to input * stream.  If a shell       */
              //* gets it, it'll open a new shell.                               */
              AddIEvents(ie);
            end
            else
              WriteLn('unknown.');
          end;
        end;
        CXM_COMMAND:
        begin
          Write('A command: ');
          case (msgid) of
            CXCMD_DISABLE:
            begin
              WriteLn('CXCMD_DISABLE');
              ActivateCxObj(broker, 0);
            end;
            CXCMD_ENABLE:
            begin
              WriteLn('CXCMD_ENABLE');
              ActivateCxObj(broker, 1);
            end;
            CXCMD_KILL:
            begin
              WriteLn('CXCMD_KILL');
              returnvalue := 0;
            end;
            CXCMD_UNIQUE:
            begin
              {* Commodities Exchange can be told not only to refuse to launch a
               * commodity with a name already in use but also can notify the
               * already running commodity that it happened. It does this by
               * sending a CXM_COMMAND with the ID set to CXMCMD_UNIQUE.  If the
               * user tries to run a windowless commodity that is already running,
               * the user wants the commodity to shut down. 
               *}
              WriteLn('CXCMD_UNIQUE');
              returnvalue := 0;
            end;
            else 
              WriteLn('Unknown msgid');
          end;
        end;
        else
        begin
          WriteLn('Unknown msgtype');
        end;
      end;
    end;

    if (sigrcvd and SIGBREAKF_CTRL_C <> 0) then
    begin
      returnvalue := 0;
      WriteLn('CTRL C signal break');
    end;
  end;
end;


begin
  {$IFDEF AROS}
  WriteLn('This example shows unexpected result on AROS and as such might crash when "leaving" the commodity');
  {$ENDIF}
  {$IFDEF AMIGA}
  WriteLn('On Amiga the shell will be opened after the commodity exits (press crtl-c or use exchange)');
  {$ENDIF}
  {$IFDEF MORPHOS}
  Writeln('MorphOS version was not tested');
  {$ENDIF}
  Main(ArgC, ArgV);
end.
