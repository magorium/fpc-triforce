Unit VLib5;

{$MODE OBJFPC}{$H+}{$HINTS ON}


Interface

Uses
  Exec;


Const
  VLIB5NAME     : PChar     = 'icon.library';	
  VLIB5VERSION              = 0;


Var
  VLib5Base     : PLibrary;



Implementation

Uses
  triniLibUtils;



Initialization
begin
  DebugLn('VLib5 - enter - initialization');

  AutoInitLib(VLIB5NAME, @VLib5Base, VLIB5VERSION, false);

  DebugLn('VLib5 - leave - initialization');
end;



Finalization
  DebugLn('VLib5 - enter - finalization');
  DebugLn('VLib5 - leave - finalization');
End.
