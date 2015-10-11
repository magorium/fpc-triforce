unit QuickDebug;


{$MODE OBJFPC}{$H+}{$HINTS ON}


Interface

  Procedure DebugLn(S: String);
  Procedure DebugLn(S: String; const Args: array of const);


Implementation


Uses
  SysUtils;


Procedure DebugLn(S: String);
begin
  System.DebugLn(S);
end;


Procedure DebugLn(S: String; const Args: array of const);
begin
  System.DebugLn(Format(S, args));
end;

end.