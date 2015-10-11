Unit VLib1;

{$MODE OBJFPC}{$H+}{$HINTS ON}


Interface

Uses
  Exec;


Const
  VLIB1NAME     : PChar     = 'diskfont.library';
  VLIB1VERSION              = 0;


Var
  VLib1Base     : PLibrary;



Implementation

Uses
  triniLibUtils;



Initialization
begin
  DebugLn('VLib1 - enter - initialization');

  AutoInitLib(VLIB1NAME, @VLib1Base, VLIB1VERSION, false);

  DebugLn('VLib1 - leave - initialization');
end;



Finalization
  DebugLn('VLib1 - enter - finalization');
  DebugLn('VLib1 - leave - finalization');
End.
