program HotKey;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : HotKey
  Source    : RKRM
}
 {
 * Simple hot key commodity 
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, Workbench, AmigaDos, Icon, Commodities,
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  amigalib,
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
  filter,
  sender,
  translate : PCxObj;
  newbroker : TNewBroker =
  (
    nb_Version          : NB_VERSION;
    nb_Name             : 'RKM HotKey';                     //* string to identify this broker */
    nb_Title            : 'A Simple HotKey';                         
    nb_Descr            : 'A simple hot key commodity';
    nb_Unique           : NBU_UNIQUE or NBU_NOTIFY;         //* Don't want any new commodities starting with this name. */
                                                            //* If someone tries it, let me know */
    nb_Flags            : 0;
    nb_Pri              : 0;
    nb_Port             : nil;
    nb_ReservedChannel  : 0
  );

  cxsigflag : ULONG;
  
  
  procedure main(argc: integer; argv: PPChar); forward;
  procedure ProcessMsg; forward;


{$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
//////////////////////////////////////////////////////////////////////////////

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

//////////////////////////////////////////////////////////////////////////////
{$ENDIF}


procedure Main(argc: Integer; ArgV: PPChar);
var
  ttypes    : PPChar;
  hotkey    : PChar;
  msg       : PCxMsg;
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if SetAndTest(CxBase, OpenLibrary('commodities.library', 37)) then
  {$ENDIF}
  begin
    {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
    //* open the icon.library for the support library */
    //* functions, ArgArrayInit() and ArgArrayDone()  */
    if SetAndTest(IconBase, OpenLibrary('icon.library', 36)) then
    {$ENDIF}
    begin
      if SetAndTest(broker_mp, CreateMsgPort) then
      begin
        newbroker.nb_Port := broker_mp;
        cxsigflag := 1 shl broker_mp^.mp_SigBit;

        {* ArgArrayInit() is a support library function (from the 2.0 version
         * of amiga.lib) that makes it easy to read arguments from either a
         * CLI or from Workbench's ToolTypes.  Because it uses icon.library,
         * the library has to be open before calling this function.
         * ArgArrayDone() cleans up after this function.
         *}
        ttypes := ArgArrayInit(argc, argv);

        {* ArgInt() (also from amiga.lib) searches through the array set up
         * by ArgArrayInit() for a specific ToolType.  If it finds one, it
         * returns the numeric value of the number that followed the
         * ToolType (i.e., CX_PRIORITY=7). If it doesn't find the ToolType,
         * it returns the default value (the third argument)
         *}
        newbroker.nb_Pri := BYTE(ArgInt(ttypes, 'CX_PRIORITY', 0));

        {* ArgString() works just like ArgInt(), except it returns a pointer to a string
         * rather than an integer. In the example below, if there is no ToolType
         * "HOTKEY", the function returns a pointer to "rawkey control esc".
         *}
        hotkey := ArgString(ttypes, 'HOTKEY', 'rawkey control esc');

        if SetAndTest(broker, CxBroker(@newbroker, nil)) then
        begin
          {* CxFilter() is a macro that creates a filter CxObject.  This filter
           * passes input events that match the string pointed to by hotkey.
           *}
          if SetAndTest(filter, CxFilter(hotkey)) then
          begin
            //* Add a CxObject to another's personal list */
            AttachCxObj(broker, filter);

            {* CxSender() creates a sender CxObject.  Every time a sender gets
             * a CxMessage, it sends a new CxMessage to the port pointed to in
             * the first argument. CxSender()'s second argument will be the ID
             * of any CxMessages the sender sends to the port.  The data pointer
             * associated with the CxMessage will point to a *COPY* of the
             * InputEvent structure associated with the orginal CxMessage.
             *}
            if SetAndTest(sender, CxSender(broker_mp, EVT_HOTKEY)) then
            begin
              AttachCxObj(filter, sender);

              {* CxTranslate() creates a translate CxObject. When a translate
               * CxObject gets a CxMessage, it deletes the original CxMessage
               * and adds a new input event to the input.device's input stream
               * after the Commodities input handler. CxTranslate's argument
               * points to an InputEvent structure from which to create the new
               * input event.  In this example, the pointer is NULL, meaning no
               * new event should be introduced, which causes any event that
               * reaches this object to disappear from the input stream.
               *}
              if SetAndTest(translate, (CxTranslate(nil))) then
              begin
                AttachCxObj(filter, translate);

                {* CxObjError() is a commodities.library function that returns
                 * the internal accumulated error code of a CxObject.
                 *}
                if not(CxObjError(filter) <> 0) then
                begin
                  ActivateCxObj(broker, 1);
                  ProcessMsg();
                end;
              end;
            end;
          end;
          {* DeleteCxObjAll() is a commodities.library function that not only
           * deletes the CxObject pointed to in its argument, but it deletes
           * all of the CxObjects that are attached to it.
           *}
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
              WriteLn('You hit the HotKey.');
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
  Main(ArgC, ArgV);
end.
