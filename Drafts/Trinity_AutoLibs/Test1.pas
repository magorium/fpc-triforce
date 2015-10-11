program Test1;

{$MODE OBJFPC}{$H+}{$HINTS ON}

Uses
  VLib1, VLib2, VLib3, AutoInit, VLib4, VLib5;


begin
  WriteLn('enter');
  DebugLn('enter');

  ShowStatus;

  DebugLn('leave');
  WriteLn('leave');
end.