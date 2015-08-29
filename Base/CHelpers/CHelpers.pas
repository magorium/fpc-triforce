unit CHelpers;

{$MODE OBJFPC}{$H+}

// ---------------------------------------------------------------------------
// Edit Date   $ Entry 
// ---------------------------------------------------------------------------
// 2015-08-27  $ Use out parameters instead of var to shut up compiler hints.
// 2015-08-26  $ SetAndGet()
// 2015-08-04  $ initial release
//             $ SetAndTest()
// ---------------------------------------------------------------------------


interface


  function  SetAndTest(Out OldValue: pointer;  NewValue: pointer) : boolean; overload; inline;
  function  SetAndTest(Out OldValue: LongWord; NewValue: LongWord): boolean; overload; inline;
  function  SetAndTest(Out OldValue: LongInt;  NewValue: LongInt) : boolean; overload; inline;

  function  SetAndGet(Out Variable: pointer;   Value: pointer)  : pointer;  overload; inline;
  function  SetAndGet(Out Variable: LongWord;  Value: LongWord) : LongWord; overload; inline;
  function  SetAndGet(Out Variable: LongInt;   Value: LongInt)  : LongInt;  overload; inline;


Implementation


function  SetAndTest(Out OldValue: pointer; NewValue: pointer): boolean;
begin
  OldValue := NewValue;
  result := (NewValue <> nil)
end;

function  SetAndTest(Out OldValue: LongWord; NewValue: LongWord): boolean;
begin
  OldValue := NewValue;
  result := (NewValue <> 0)
end;

function  SetAndTest(Out OldValue: LongInt; NewValue: LongInt): boolean;
begin
  OldValue := NewValue;
  result := (NewValue <> 0)
end;


function  SetAndGet(Out Variable: pointer;  Value: pointer) : pointer; overload;
begin
  Variable := Value;
  result   := Value;
end;

function  SetAndGet(Out Variable: LongWord;  Value: LongWord) : LongWord; overload;
begin
  Variable := Value;
  result   := Value;
end;

function  SetAndGet(Out Variable: LongInt;  Value: LongInt) : LongInt; overload;
begin
  Variable := Value;
  result   := Value;
end;


end.
