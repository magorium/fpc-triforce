program prefnotify;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : prefnotify
  Topic     : notified if serial prefs change
  Source    : RKRM
}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/Trinity}
{$UNITPATH ../../../Base/CHelpers}

Uses
  Exec, AmigaDOS,
  CHelpers,
  Trinity;


const
  PREFSFILENAME         = 'ENV:sys/serial.prefs';

  VersTag       : PChar = #0'$VER: prefnot 37.1 (09.07.91)';


Var
  {$IFDEF AROS}
  DOSBase       : PLibrary absolute AOS_DOSBase;
  {$ENDIF}
  {$IFDEF AMIGA}
  DOSBase       : PLibrary absolute _DOSBase;
  {$ENDIF}
  {$IFDEF MORPHOS}
  DOSBase       : PLibrary absolute AmigaDOS.DOSBase;
  {$ENDIF}


procedure Main(argc: Integer; argv: PPChar);
var
  done          : boolean = FALSE;
  notifyrequest : PNotifyRequest;
  filename      : PChar;
  signum        : LONG;
  signals       : ULONG;
begin
  //* We need at least V37 for notification */
  if (DOSBase^.lib_Version >= 37) then
  begin
    //* Allocate a NotifyRequest structure */
    if SetAndTest(notifyrequest, ExecAllocMem(sizeof(TNotifyRequest), MEMF_CLEAR)) then
    begin
      //* And allocate a signalsbit */
      if (SetAndGet(signum, AllocSignal(-1)) <> -1) then
      begin
        //* Initialize notification request */
        filename := PREFSFILENAME;
        notifyrequest^.nr_Name := filename;
        notifyrequest^.nr_Flags := NRF_SEND_SIGNAL;
        //* Signal this task */
        notifyrequest^.nr_stuff.nr_Signal.nr_Task := PTask(FindTask(nil));
        //* with this signals bit */
        notifyrequest^.nr_stuff.nr_Signal.nr_SignalNum := signum;

        if (StartNotify(notifyrequest)) then
        begin
          WriteLn('Select Serial Prefs SAVE or USE to notify this program');
          WriteLn('CTRL-C to exit');
          WriteLn;
          //* Loop until Ctrl-C to exit */
          while not(done) do
          begin
            signals := Wait(  (1 shl signum) or SIGBREAKF_CTRL_C );
            if (signals and (1 shl signum)) <> 0
              then WriteLn('Notification signal received.');
            if (signals and SIGBREAKF_CTRL_C) <> 0 then
            begin
              EndNotify(notifyrequest);
              done := TRUE;
            end;
          end;
        end
        else WriteLn('Can''t start notification');

        FreeSignal(signum);
      end
      else WriteLn('No signals available');

      ExecFreeMem(notifyrequest, SizeOf(TNotifyRequest));
    end
    else WriteLn('Not enough memory for NotifyRequest.');
  end
  else WriteLn('Requires at least V37 dos.library');
end;


begin
  Main(ArgC, ArgV);
end.
