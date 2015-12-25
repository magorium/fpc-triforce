program broker;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : broker
  Source    : RKRM
}
 {
 * The example below, Broker.c, receives input from one source, the
 * controller program.  The controller program sends a CxMessage each
 * time the user clicks its Enable, Disable, or Kill gadgets.  Using the
 * CxMsgID() function, the commodity finds out what the command is and
 * executes it.
 }

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDos, Commodities,
  {$IFDEF AMIGA}
  amigalib,
  {$ENDIF}
  CHelpers,
  Trinity;


  {$IFDEF AMIGA}
  // (re)define structure Newbroker from commodities.pas in order
  // to align the structure properly with packrecords 2.
  // Not doing so result in a crash becuase fileds are not aligned properly
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


var
  broker_   : PCxObj;
  broker_mp : PMsgPort;
  cxsigflag : ULONG;

  newbroker : TNewBroker =
  (
    nb_Version          : NB_VERSION;                       //* nb_Version - Version of the NewBroker structure */
    nb_Name             : 'RKM broker';                     //* nb_Name - Name Commodities uses to identify this commodity */
    nb_Title            : 'Broker';                         //* nb_Title - Title of commodity that appears in CXExchange */
    nb_Descr            : 'A simple example of a broker';   //* nb_Descr - Description of the commodity */
    nb_Unique           : 0;                                //* nb_Unique - Tells CX not to launch another commodity with same name */
    nb_Flags            : 0;                                //* nb_Flags - Tells CX if this commodity has a window */
    nb_Pri              : 0;                                //* nb_Pri - This commodity's priority */
    nb_Port             : nil;                              //* nb_Port - MsgPort CX talks to */
    nb_ReservedChannel  : 0                                 //* nb_ReservedChannel - reserved for later use */
  );


  procedure main; forward;
  procedure ProcessMsg; forward;


procedure Main;
var
  msg   : PCxMsg;
begin
  //* Before bothering with anything else, open the library */
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if SetAndTest(CxBase, OpenLibrary('commodities.library', 37)) then
  {$ENDIF}
  begin
    //* Commodities talks to a Commodities application through */
    //* an Exec Message port, which the application provides   */
    if SetAndTest(broker_mp, CreateMsgPort) then
    begin
      newbroker.nb_Port := broker_mp;

      {
      * The commodities.library function CxBroker() adds a borker to the
      * master list.  It takes two arguments, a pointer to a NewBroker
      * structure and a pointer to a LONG.  The NewBroker structure contains
      * information to set up the broker.  If the second argument is not
      * NULL, CxBroker will fill it in with an error code.
      }
      if SetAndTest(broker_, CxBroker(@newbroker, nil)) then
      begin
        cxsigflag := 1 shl broker_mp^.mp_SigBit;

        //* After it's set up correctly, the broker has to be activated */
        ActivateCxObj(broker_, 1);

        //* the main processing loop */
        ProcessMsg();

        {
        * It's time to clean up.  Start by removing the broker from the
        * Commodities master list.  The DeleteCxObjAll() function will
        * take care of removing a CxObject and all those connected
        * to it from the Commodities network
        }
        DeleteCxObj(broker_);

        //* Empty the port of CxMsgs */
        while SetAndTest(msg, PCxMsg(GetMsg(broker_mp))) 
          do ReplyMsg(PMessage(msg));
      end;
      DeletePort(broker_mp);
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
    //* wait for something to happen */
    sigrcvd := Wait(SIGBREAKF_CTRL_C or cxsigflag);

    //* process any messages */
    while SetAndTest(msg, PCxMsg(GetMsg(broker_mp))) do
    begin
      //* Extract necessary information from the CxMessage and return it */
      msgid := CxMsgID(msg);
      msgtype := CxMsgType(msg);
      ReplyMsg(PMessage(msg));

      case (msgtype) of
        CXM_IEVENT:
        begin
          //* Shouldn't get any of these in this example */
        end;
        CXM_COMMAND:
        begin
          //* Commodities has sent a command */
          Write('A command: ');
          case (msgid) of
            CXCMD_DISABLE:
            begin
              WriteLn('CXCMD_DISABLE');
              {
              * The user clicked Commodities Exchange disable
              * gadget better disable
              }
              ActivateCxObj(broker_, 0);
            end;
            CXCMD_ENABLE:
            begin
              //* user clicked enable gadget */
              WriteLn('CXCMD_ENABLE');
              ActivateCxObj(broker_, 1);
            end;
            CXCMD_KILL:
            begin
              //* user clicked kill gadget, better quit */
              WriteLn('CXCMD_KILL');
              returnvalue := 0;
            end;
          end;
        end;
        else
        begin
          WriteLn('Unknown msgtype');
        end;
      end;
    end;
    //* Test to see if user tried to break */
    if (sigrcvd and SIGBREAKF_CTRL_C <> 0) then
    begin
      returnvalue := 0;
      WriteLn('CTRL C signal break');
    end;
  end;
end;


{
* Notice that Broker.c uses Ctrl-C as a break key.  The break key for
* any commodity should be Ctrl-C.
}


begin
  Main;
end.
