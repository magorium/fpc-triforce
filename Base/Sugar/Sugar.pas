unit Sugar;

{$MODE OBJFPC}{$H+}

// ---------------------------------------------------------------------------
// Edit Date   $ Entry 
// ---------------------------------------------------------------------------
// 2015-08-27  $ configurable enter/leave debug, initialization with 
//               environment variable:
//               - debug=con   -> debug to console
//               - debug=sys   -> debug with sysdebugln
//               By default, no output at all.
//             $ added additional debug routines
// 2015-08-26  $ Initial release
//             $ debug, enter and leave vars + accompanied procs
//             $ MSG_RETURN_... functions, return dos error code w+ print msg
//             $ xget, get a single class attribute
// ---------------------------------------------------------------------------

interface

uses
  Intuition;

  Function  MSG_RETURN_OK   (Msg: String): Integer;
  Function  MSG_RETURN_WARN (Msg: String): Integer;
  Function  MSG_RETURN_FAIL (msg: String): Integer;
  Function  MSG_RETURN_ERROR(msg: String): Integer;

  function  xget(o: pObject_; attribute: LongWord): LongWord;


  {.$IFDEF DEBUG_ON}
  Procedure EnterProc_None(S: String);
  Procedure LeaveProc_None(S: String);
  Var Enter: procedure(s: string) = @EnterProc_None;
  Var Leave: procedure(s: string) = @LeaveProc_None;
  {.$ENDIF}


implementation

Uses
  DOS, AmigaDOS;


Function  MSG_RETURN_OK(Msg: String): Integer;
begin
  result := AmigaDOS.RETURN_OK;
  WriteLn('OK: ', Msg);
end;


Function  MSG_RETURN_WARN(Msg: String): Integer;
begin
  result := AmigaDOS.RETURN_WARN;
  WriteLn('Warning: ', Msg);
end;


Function  MSG_RETURN_FAIL(msg: String): Integer;
begin
  result := AmigaDOS.RETURN_FAIL;
  WriteLn('Failure: ', Msg);
end;


Function  MSG_RETURN_ERROR(msg: String): Integer;
begin
  result := AmigaDOS.RETURN_ERROR;
  WriteLn('Error: ', Msg);
end;



//===========================================================================
//        xget(), Small helper to retrieve a single MUI object attribute
//===========================================================================


function  xget(o: pObject_; attribute: LongWord): LongWord;
var
  Retval: LongWord = 0;
begin
  {$IF DEFINED(AROS) or DEFINED(AMIGA)}
  GetAttr(attribute, o, @Retval);
  {$ENDIF}
  {$IFDEF MORPHOS}
  GetAttr(attribute, o, Retval);
  {$ENDIF}
  result := RetVal;
end;



//===========================================================================
//        enter + leave, for debug purposes
//===========================================================================

{$PUSH}{$HINTS OFF}
Procedure EnterProc_None(S: String);
begin
end;

Procedure LeaveProc_None(S: String);
begin
end;
{$POP}

Procedure EnterProc_Sys(S: String);
begin
  SysDebugLn('enter - ' + S);
end;

Procedure LeaveProc_Sys(S: String);
begin
  SysDebugLn('leave - ' + S);
end;

Procedure EnterProc_Con(S: String);
begin
  WriteLn('enter - ', S);
end;

Procedure LeaveProc_Con(S: String);
begin
  WriteLn('leave - ', S);
end;


Initialization

Begin
  Case Upcase(GetEnv('debug')) of
   'CON', 'CONSOLE' :
   begin
     Enter := @EnterProc_Con;
     Leave := @LeaveProc_Con;
   end;
   'SYS', 'SYSTEM' :
   begin
     Enter := @EnterProc_Sys;
     Leave := @LeaveProc_Sys;
   end;
  end;
end;


end.