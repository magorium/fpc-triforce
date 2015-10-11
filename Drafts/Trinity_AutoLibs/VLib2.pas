Unit VLib2;

{$MODE OBJFPC}{$H+}{$HINTS ON}


Interface

Uses
  Exec;


Const
  VLIB2NAME     : PChar     = 'asl.library';
  VLIB2VERSION              = 0;


Var
  VLib2Base     : PLibrary;



Implementation

Uses
  triniLibUtils;



Initialization
begin
  DebugLn('VLib2 - enter - initialization');

  AutoInitLib(VLIB2NAME, @VLib2Base, VLIB2VERSION, false);

  DebugLn('VLib2 - leave - initialization');
end;



Finalization
  DebugLn('VLib2 - enter - finalization');
  DebugLn('VLib2 - leave - finalization');
End.
