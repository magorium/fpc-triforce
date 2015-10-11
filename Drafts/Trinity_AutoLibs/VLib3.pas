Unit VLib3;

{$MODE OBJFPC}{$H+}{$HINTS ON}


Interface

Uses
  Exec;


Const
  VLIB3NAME     : PChar     = 'gadtools.library';
  VLIB3VERSION              = 0;


Var
  VLib3Base     : PLibrary;



Implementation

Uses
  triniLibUtils;



Initialization
begin
  DebugLn('VLib3 - enter - initialization');

  AutoInitLib(VLIB3NAME, @VLib3Base, VLIB3VERSION, false);

  DebugLn('VLib3 - leave - initialization');
end;



Finalization
  DebugLn('VLib3 - enter - finalization');
  DebugLn('VLib3 - leave - finalization');
End.
