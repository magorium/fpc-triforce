Unit VLib4;

{$MODE OBJFPC}{$H+}{$HINTS ON}


Interface

Uses
  Exec;


Const
  VLIB4NAME     : PChar     = 'layers.library';
  VLIB4VERSION              = 0;


Var
  VLib4Base     : PLibrary;



Implementation

Uses
  triniLibUtils;



Initialization
begin
  DebugLn('VLib4 - enter - initialization');

  AutoInitLib(VLIB4NAME, @VLib4Base, VLIB4VERSION, false);

  DebugLn('VLib4 - leave - initialization');
end;



Finalization
  DebugLn('VLib4 - enter - finalization');
  DebugLn('VLib4 - leave - finalization');
End.
