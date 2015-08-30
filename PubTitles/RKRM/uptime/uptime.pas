program uptime;

{$MODE OBJFPC}{$H+}

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : uptime
  Source    : RKRM
}

{$UNITPATH ../../../Trinity}

Uses
  Exec, AmigaDOS, Utility,
  Trinity;

{$IFNDEF HASAMIGA}
Var
  UtilityBase : pLibrary;
{$ENDIF}


Function Main(): LONG;
Var
  infodata      : pInfoData;
  ramdevice     : pDeviceList;
  now           : pDateStamp;
  boottime,
  currenttime   : LONG;
  ramlock       : BPTR;
  vargs         : array[0..pred(3)] of LONG;
  rc            : LONG = RETURN_FAIL;

  getreg        : LONG;
begin
  //* Fails silently if < 37 */
  {$IFNDEF HASAMIGA}
  UtilityBase := OpenLibrary('utility.library', 37);
  If Assigned(UtilityBase) then
  {$ENDIF}
  begin
    infodata := ExecAllocMem(sizeof(TInfoData), MEMF_CLEAR);
    if assigned(infodata) then
    begin
      now := ExecAllocMem(sizeof(TDateStamp), MEMF_CLEAR);
      if Assigned(now) then
      begin
        ramlock := Lock('RAM:', SHARED_LOCK);
        if ( ramlock <> Default(BPTR) ) then
        begin
          If ( Info(ramlock, infodata) = DOSTRUE ) then
          begin
            //* Make C pointer */

            ramdevice   := BADDR(infodata^.id_VolumeNode);

            boottime    := SMult32(ramdevice^.dl_VolumeDate.ds_Days, 86400) +
                           SMult32(ramdevice^.dl_VolumeDate.ds_Minute, 60) +
                           SDivMod32(ramdevice^.dl_VolumeDate.ds_Tick,
                             TICKS_PER_SECOND );

            DateStamp(now);

            currenttime := SMult32(now^.ds_Days, 86400) +
                           SMult32(now^.ds_Minute, 60) +
                           SDivMod32(now^.ds_Tick, TICKS_PER_SECOND);

            currenttime := currenttime - boottime;

            if (currenttime > 0) then
            begin
              {
                getreg 'simulation' workaround
                a. FPC does not support getreg()
                b. FPC + AROS + UDivMod32 does not support register return.
              }
              getreg   := currenttime mod 86400;
              vargs[0] := UDivMod32(currenttime, 86400);

              vargs[1] := getreg;
              getreg   := vargs[1] mod 3600;
              vargs[1] := UDivMod32(vargs[1], 3600);

              vargs[2] := getreg;
              getreg   := vargs[2] mod 60;
              vargs[2] := UDivMod32(vargs[2], 60);

              //* Passing the address of the array allows the VPrintf()
              //* function to access the array contents.  Keep in mind
              //* that VPrintf() does _NOT_ know how many elements are
              //* really valid in the final parameter, and will gleefully
              //* run past the valid arguments.

              VFPrintf(DOSOutput(),
                           'up for %ld days, %ld hours, %ld minutes'#10,
                           vargs );

              rc := RETURN_OK;
            end;
          end;
          UnLock(ramlock);
        end;
        ExecFreeMem(now, sizeof(TDateStamp));
      end;
      ExecFreeMem(infodata, sizeof(TInfoData));
    end;
    {$IFNDEF HASAMIGA}
    CloseLibrary(UtilityBase);
    {$ENDIF}
  end;
  exit(rc);
end;



begin
  ExitCode := Main;
end.
