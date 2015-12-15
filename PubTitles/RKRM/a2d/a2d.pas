program a2d;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : a2d
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, Timer, Utility,
  SysUtils,
  CHelpers,
  Trinity;


function Main: LONG;
var
  clockdata : PClockData;
  tr        : Ptimerequest;
  tv        : Ptimeval;
  seconds   : LONG;
begin
  // FPC Note:
  // awkward ifdef, to match original source with opening and closing
  // utility.library, which isn't needed for Amiga, AROS and MorphOS as
  // FPC auto-opens this library for us.
  {$IFNDEF HASAMIGA}  
  if SetAndTest(UtilityBase, OpenLibrary('utility.library', 37)) then
  {$ENDIF}
  begin
    if SetAndTest(tr, ExecAllocMem(sizeof(Ttimerequest), MEMF_CLEAR)) then
    begin
      if SetAndTest(tv, ExecAllocMem(sizeof(Ttimeval), MEMF_CLEAR)) then
      begin
        if SetAndTest(clockdata, ExecAllocMem(sizeof(TClockData), MEMF_CLEAR)) then
        begin
          if (not( OpenDevice('timer.device', UNIT_VBLANK, PIORequest(tr), 0) <> 0)) then
          begin
            TimerBase := tr^.tr_node.io_Device;

            GetSysTime(tv);

            WriteLn(Format('GetSysTime():'#9'%d %d', [tv^.tv_secs, tv^.tv_micro]));

            Amiga2Date(tv^.tv_secs, clockdata);

            WriteLn(Format('Amiga2Date():  sec %d min %d hour %d', [clockdata^.sec,
                        clockdata^.min, clockdata^.hour]));

            WriteLn(Format('               mday %d month %d year %d wday %d', [clockdata^.mday,
                       clockdata^.month, clockdata^.year, clockdata^.wday]));

            seconds := CheckDate(clockdata);

            WriteLn(Format('CheckDate():'#9'%d', [seconds]));

            seconds := Date2Amiga(clockdata);

            WriteLn(Format('Date2Amiga():'#9'%d', [seconds]));

            CloseDevice(PIORequest(tr));
          end;
          ExecFreeMem(clockdata, sizeof(TClockData));
        end;
        ExecFreeMem(tv, sizeof(Ttimeval));
      end;
      ExecFreeMem(tr, sizeof(Ttimerequest));
    end;
    {$IFNDEF HASAMIGA}
    CloseLibrary(UtilityBase);
    {$ENDIF}
  end;
end;


begin
  Main;
end.
