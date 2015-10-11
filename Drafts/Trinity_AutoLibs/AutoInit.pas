unit AutoInit;


Interface

  Procedure ShowStatus;



Implementation

Uses
  triniLibUtils;



Procedure ShowStatus;
begin
  triniLibUtils.ShowStatus;
end;



Initialization
begin
  DebugLn('AutoInit - enter - initialization');

  ForceAutoInit;

  DebugLn('AutoInit - leave - initialization');
end;



Finalization
  DebugLn('AutoInit - enter - finalization');
  DebugLn('AutoInit - leave - finalization');
End.
