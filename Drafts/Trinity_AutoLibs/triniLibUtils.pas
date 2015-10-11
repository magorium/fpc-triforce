Unit  TriniLibUtils;


{$MODE OBJFPC}{$H+}{$HINTS ON}


Interface


Uses
  Exec;


  {
    Procedure AutoInitLib
    =======================================================================
    This routine is to be called upon unit initialization of a shared 
    system library.
    
    In order for this implementation to work, every library is obligated to
    'initialize' itself by calling this routine. Options allows you tell 
    which actual action to take.

    Parameters:
    LibName     Pointer to the name of the (disk)library
    LibBase     Ponter to the variable that stores the (opened) library 
                base.
    Version     The version number of the library to open, see System SDK
    Forced      A boolean value that allows you to force to open the 
                library directly upon call to this function.
    =======================================================================
  }

  Procedure AutoInitLib(LibName: PChar; LibBase: Pointer; Version: ULONG; Forced: boolean);

  {
    TODO: missing documentation
  }
  Procedure ForceAutoInit;

  {
    temp routine for showing status, can be removed.
  }
  Procedure ShowStatus;



implementation


Uses
  QuickDebug, Sysutils;


Type
  TAutoLibraryEntry = record
    Library_Name    : PChar;	  // The (disk)name of the library
    Library_Base    : PPointer;   // The pointer to a variable holding the libbase
    Library_Version : ULONG;      // The version of the library to be opened
    ForcedOpen      : boolean;    // Whether this library was forced to open
    IsOpen          : boolean;    // whether the library is 'opened' or 'closed'
  end;


Var
  {
    The library list that holds all entries during duration of the program.
  }
  AutoInitList              : Array of TAutoLibraryEntry;
  
  {
    Variable AutoFailure
    =======================================================================
    The idea is/was to use this value in order to indicate failure along the
    way of auto init initialization, in order to remove the halt. 
    Somehow i managed to forget how i wanted to implement that exactly.
    =======================================================================
  }
  AutoFailure               : boolean = false;

  {
    Variable MasterStatus_ForcedOpen
    =======================================================================
    This value is a boolean value that is false by default.

    The moment this variable turns true, libraries will directly be opened 
    automatically, otherwise not.
    
    The value of this variable should not be changed manually by the user, 
    instead only a certain (internal) routine call should change it.
    =======================================================================
  }
  MasterStatus_ForcedOpen   : boolean = false;



{
  ShowStatus() - Show all the entries from the current library list
}
Procedure ShowStatus;
Var
  i: Integer;
  S, T1, T2, T3, T4, T5, U: String;
begin
  DebugLn('triniLibUtils - enter - ShowStatus()');

  Writeln('number of entries in the library list = ', Length(AutoInitList));
  DebugLn('number of entries in the library list = ' + IntToStr(Length(AutoInitList)));
  
  For i := low(AutoInitList) to High(AutoInitList) do
  begin
    WriteStr(S, '[', i, ']');
    WriteStr(T1, AutoInitList[i].Library_Name);
    WriteStr(T2, '$', IntToHex(LongWord(AutoInitList[i].Library_Base^), 8));
    WriteStr(T3, AutoInitList[i].Library_Version);
    WriteStr(T4, AutoInitList[i].ForcedOpen);
    WriteStr(T5, AutoInitList[i].IsOpen);

    WriteStr(U, S:4, T1:20, T2:10, T3:4, T4:7, T5:7);
    //Writeln(U);
    DebugLn(U);
  end;

  DebugLn('triniLibUtils - leave - ShowStatus()');
end;



{
  AddLibEntry() - Add a library entry to the list
  
  TODO: add more detailed description
}
Function AddLibEntry(LibName: PChar; LibBase: Pointer; Version: ULONG; Forced: Boolean): Integer;
Var
  CurrentIndex : Integer;
begin
  DebugLn('triniLibUtils - enter - AddLibEntry()');

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

  DebugLn('triniLibUtils - leave - AddLibEntry()');
end;



{
  OpenLibEntry() - Open a library based on it index that's in the list 

  This routine uses the given EntryIndex to retrieve the individual and 
  corresponding library data as stored in the list.

  If the library is not already opened, it will attempt to open the library 
  and will update the library data in the list correspondingly. In that case
  the routine will return a true for success. If this opening failed then 
  it's at this point uncertain what will happen, but the code shown
  below will halt the program as well as let the routine return a false as
  result value (if it ever reached this part of the code).
  
  In case the library entries in the list indicates that the library was 
  already opened, this routine will silently exit the routine, returning
  a true status.
}
Function OpenLibEntry(EntryIndex: Integer): Boolean;
Var
  ThisBase : Pointer;
begin
  DebugLn('triniLibUtils - enter - OpenLibEntry()');

  Result := False;
  With AutoInitList[EntryIndex] do
  begin
    // more checks necessary in case the base is already valid ?
    If Not(IsOpen) then
    begin  
  
      library_base^ := nil;
      DebugLn('.Opening the library');
      ThisBase := OpenLibrary(library_name, library_version);
      if ThisBase <> nil then 
      begin
        DebugLn('.library opened sucessfully');
    
        library_base^ := ThisBase;
        IsOpen        := True;
        Result        := True;
      end 
      else 
      begin
        DebugLn('.open of the library failed');

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
      DebugLn('.library was already open');
      Result := true;
    end;
  end;
  DebugLn('triniLibUtils - leave - OpenLibEntry()');
end;



{
  CloseLibEntry() - Close a library from the list of library entries.
  
  TODO: add more detailed description
}
procedure CloseLibEntry(EntryIndex: Integer);
begin
  DebugLn('triniLibUtils - enter - CloseLibEntry()');

  // close the library
  With AutoInitList[EntryIndex] do
  begin
    // TODO: make extra check to see if library _can_ be closed (is already 
    //       open etc.)
    CloseLibrary(library_base^);
    IsOpen        := False;
  end;

  DebugLn('triniLibUtils - leave - CloseLibEntry()');
end;



{
  AutoinitLib() - Auto initialize a library based on the given parameters

  Depending on the status of the passed forced parameter (all or not in 
  combination with the global overuling master forced status) the given
  library parameters will be stored (added) to the library list.
  
  In case the library is forced to open, the library will also be opened
  and all related required information will be stored properly.
}
Procedure AutoInitLib(LibName: PChar; LibBase: Pointer; Version: ULONG; Forced: boolean);
Var
  CIndex: Integer;
begin
  DebugLn('triniLibUtils - enter - AutoInitLib()');

  CIndex := AddLibEntry(LibName, Libbase, version, forced);
  if (forced or MasterStatus_ForcedOpen) then
  begin
    OpenLibEntry(CIndex);
  end;

  DebugLn('triniLibUtils - leave - AutoInitLib()');
end;



{
  AutoCloseLibs() - Close all libraries marked as openeed in the list.

  This is a 'panic' routine that will be called upon a FPC RTL call to 
  ExitProc.
  
  It walks the library list and all libraries marked as opened will be
  closed (in down-top order) automatically.
  
  The library list will be cleared on exiting this routine, so that
  allocated resources are returned back to the system.
}
Procedure AutoCloseLibs;
var
  i : Integer;
begin
  DebugLn('triniLibUtils - enter - AutoCloseLibs()');

  For i := high(AutoInitList) downto low(AutoInitList) do
  begin
    // RemLibEntry(i);
    CloseLibEntry(i);
  end;
  // clear the list
  SetLength(AutoInitList, 0);

  DebugLn('triniLibUtils - leave - AutoCloseLibs()');
end;



{
  ForceAutoInit() - Forces to open the libraries.
  
  This routine will change the MasterStatus_ForcedOpen value from False to 
  true, which indicates that from now on, each call to autoinitlib will 
  actually open the library, even when not (manually) forced to open.
  
  All the already existing libraries in the list that are not already opened,
  will be opened as well, changing the IsOpen status from false to true in
  case an individual library was opened sucessfully.
}
Procedure ForceAutoInit;
var
  i : Integer;
begin
  DebugLn('triniLibUtils - enter - ForceAutoInit()');

  // 1) change the AutoInitLibsStatus to true.
  MasterStatus_ForcedOpen := true;

  // 2) walk the libentries and open libraries not already opened
  For i := low(AutoInitList) to high(AutoInitList) do
  begin
    // RemLibEntry(i);
    Writeln('i = ', i);
    OpenLibEntry(i);
  end;

  DebugLn('triniLibUtils - leave - ForceAutoInit()');
end;



Var
  OldExitProc : pointer;



Initialization
begin
  DebugLn('triniLibUtils - enter - initialization');

  OldExitProc := ExitProc;
  ExitProc := @AutoCloseLibs;

  DebugLn('triniLibUtils - leave - initialization');
end;



Finalization
  DebugLn('triniLibUtils - enter - finalization');
  DebugLn('triniLibUtils - leave - finalization');
end.
