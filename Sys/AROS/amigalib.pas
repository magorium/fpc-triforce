unit amigalib;


(*
  Unit amigalib for AROS

    NOTE: All functions inside this unit are either based on (already) 
          existing Pascal implementation(s) or are converted from C-Source
          (AROS tree). None of the functions are actually tested atm.

          Be prepared to encounter c-source to Pascal conversion errors.

          #####     Use at your own risk     #####
*) 


{$MODE OBJFPC}{$H+}  // OBJFPC for array of const :-(

{$UNITPATH .}


interface


uses
  Exec;



  function  ACrypt(buffer: PChar; password: PChar; username: PChar): PChar;
  function  FastRand(seed: ULONG): ULONG;
  function  RangeRand(maxValue: ULONG): ULONG;


implementation



// ###########################################################################
// ###
// ###    ALib
// ###
// ###########################################################################



const
  OSIZE = 12;


function  ACrypt(buffer: PChar; password: PChar; username: PChar): PChar;
var
  buf   : Array[0..Pred(OSIZE)] of LONG;
  i,d,k : LONG;
begin
  if ((buffer = nil) or (password = nil) or (username = nil)) then
  begin
    exit(nil);
  end;

  i := 0;
  while (i < OSIZE) do
  begin
    if ((password^) <> #0) then
    begin
      d := Ord(password^);
      inc(password);
    end
    else
      d := i;

    if ((username^) <> #0) then
    begin
      d := d + Ord(username^);
      inc(username);
    end
    else
      d := d + i;

    buf[i] := Ord('A') + d;
    
    inc(i);
  end;

  i := 0;
  while (i < OSIZE) do
  begin
    k := 0;
    while (k < OSIZE) do
    begin
      buf[i] := (buf[i] + buf[OSIZE - k - 1]) mod 53;
      inc(k);
    end;

    Ord(buffer[i]) := buf[i] + Ord('A');    //  buffer[i] := Chr(buf[i]) + ('A');
    
    inc(i);
  end;

  buffer[OSIZE-1] := #0;

  ACrypt := buffer;
end;


function  FastRand(seed: ULONG): ULONG;
var
  a : ULONG;
begin
  a := seed shl 1;

  if (LONG(seed) <= 0)
  then a := a xor $1d872b41;

  FastRand := a;
end;


var
  RangeSeed: ULONG;


function  RangeRand(maxValue: ULONG): ULONG;
var
  a,b   : ULONG;
  i     : UWORD;
begin
  a := RangeSeed;
  i := maxValue - 1;

  repeat
    b := a;

    a := a shl 1;

    if (LONG(b) <= 0)
    then a := a xor $1d872b41;

    i := i shr 1;
    if not(i <> 0) then break;
  until false;

  RangeSeed := a;

  if (UWORD(maxValue) <> 0)
  then exit( UWORD(UWORD(a) * UWORD(maxValue) shr 16) );

  RangeRand := UWORD(a);
end;


end.
