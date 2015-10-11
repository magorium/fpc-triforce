Unit  TriniLibUtils;


{$MODE OBJFPC}{$H+}{$HINTS ON}


Interface


Uses
  Exec;



  Procedure AutoInitLib(LibName: PChar; LibBase: Pointer; Version: ULONG; Forced: boolean);
  Procedure ForceAutoInit;
  Procedure ShowStatus;



implementation


Uses
  SysUtils;


Type
  TAutoLibraryEntry = record
    Library_Name    : PChar;	  // The (disk)name of the library
    Library_Base    : PPointer;   // The pointer to a variable holding the libbase
    Library_Version : ULONG;      // The version of the library to be opened
    ForcedOpen      : boolean;    // Whether this library was forced to open
    IsOpen          : boolean;    // whether the library is 'opened' or 'closed'
  end;


Var
  AutoInitList              : Array of TAutoLibraryEntry;
  
  AutoFailure               : boolean = false;
  MasterStatus_ForcedOpen   : boolean = false;



Procedure ShowStatus;
Var
  i: Integer;
  S, T1, T2, T3, T4, T5, U: String;
begin
  Writeln('number of entries in the library list = ', Length(AutoInitList));
  
  For i := low(AutoInitList) to High(AutoInitList) do
  begin
    WriteStr(S, '[', i, ']');
    WriteStr(T1, AutoInitList[i].Library_Name);
    WriteStr(T2, '$', IntToHex(LongWord(AutoInitList[i].Library_Base^), 8));
    WriteStr(T3, AutoInitList[i].Library_Version);
    WriteStr(T4, AutoInitList[i].ForcedOpen);
    WriteStr(T5, AutoInitList[i].IsOpen);

    WriteStr(U, S:4, T1:20, T2:10, T3:4, T4:7, T5:7);
    Writeln(U);
  end;
end;


Function AddLibEntry(LibName: PChar; LibBase: Pointer; Version: ULONG; Forced: Boolean): Integer;
Var
  CurrentIndex : Integer;
begin
  SetLength(AutoInitList, Length(AutoInitList) + 1);
  CurrentIndex := High(AutoInitList);
  With AutoInitList[CurrentIndex] do
  begin
    library_Name := libName;
    Library_base := libbase;
    Library_Version := Version;
    ForcedOpen := Forced;
    IsOpen := false;    
  end;
  Result := CurrentIndex;
end;


Function OpenLibEntry(EntryIndex: Integer): Boolean;
Var
  ThisBase : Pointer;
begin
  Result := False;
  With AutoInitList[EntryIndex] do
  begin
    // more checks necessary in case the base is already valid ?
    If Not(IsOpen) then
    begin  
      library_base^ := nil;

      ThisBase := OpenLibrary(library_name, library_version);
      if ThisBase <> nil then 
      begin
        library_base^ := ThisBase;
        IsOpen        := True;
        Result        := True;
      end 
      else 
      begin
        AutoFailure := true;
        {
          MessageBox('FPC Pascal Error',
          'Can''t open asl.library version ' + VERSION + #10 +
          'Deallocating resources and closing down',
          'Oops');
        }
        halt(20);
      end;
    end
    else // library was already open.
    begin
      Result := true;
    end;
  end;
end;



procedure CloseLibEntry(EntryIndex: Integer);
begin
  // close the library
  With AutoInitList[EntryIndex] do
  begin
    // TODO: make extra check to see if library _can_ be closed (is already 
    //       open etc.)
    CloseLibrary(library_base^);
    IsOpen        := False;
  end;
end;



Procedure AutoInitLib(LibName: PChar; LibBase: Pointer; Version: ULONG; Forced: boolean);
Var
  CIndex: Integer;
begin
  CIndex := AddLibEntry(LibName, Libbase, version, forced);
  if (forced or MasterStatus_ForcedOpen) then
  begin
    OpenLibEntry(CIndex);
  end;
end;



Procedure AutoCloseLibs;
var
  i : Integer;
begin
  For i := high(AutoInitList) downto low(AutoInitList) do
  begin
    // RemLibEntry(i);
    CloseLibEntry(i);
  end;
  // clear the list
  SetLength(AutoInitList, 0);
end;



Procedure ForceAutoInit;
var
  i : Integer;
begin
  // 1) change the AutoInitLibsStatus to true.
  MasterStatus_ForcedOpen := true;

  // 2) walk the libentries and open libraries not already opened
  For i := low(AutoInitList) to high(AutoInitList) do
  begin
    // RemLibEntry(i);
    Writeln('i = ', i);
    OpenLibEntry(i);
  end;
end;



Var
  OldExitProc : pointer;



Initialization
begin
  OldExitProc := ExitProc;
  ExitProc := @AutoCloseLibs;
end;



Finalization

end.
