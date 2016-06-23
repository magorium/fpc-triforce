program findboards;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : findboards
  Source    : RKRM
}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, ConfigVars, ConfigRegs, Expansion,
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  AmigaDOS,
  {$ENDIF}
  SysUtils,
  CHelpers;


procedure Main(argc: integer; argv: PPChar);
var
  myCD  : PConfigDev;
  m,i   : UWORD;
  p,f,t : UBYTE;
begin
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  if (SetAndGet(ExpansionBase, OpenLibrary('expansion.library',0)) = nil)
  then halt(RETURN_FAIL);
  {$ENDIF}
  //*--------------------------------------------------*/
  //* FindConfigDev(oldConfigDev,manufacturer,product) */
  //* oldConfigDev = NULL for the top of the list      */
  //* manufacturer = -1 for any manufacturer           */
  //* product      = -1 for any product                */
  //*--------------------------------------------------*/
  myCD := nil;
  while SetAndTest(myCD, FindConfigDev(myCD, -1, -1)) do  //* search for all ConfigDevs */
  begin
    WriteLn(LineEnding, Format('---ConfigDev structure found at location $%p---', [myCD]));

    //* These values were read directly from the board at expansion time */
    WriteLn('Board ID (ExpansionRom) information:');

    t := myCD^.cd_Rom.er_Type;
    m := myCD^.cd_Rom.er_Manufacturer;
    p := myCD^.cd_Rom.er_Product;
    f := myCD^.cd_Rom.er_Flags;
    i := myCD^.cd_Rom.er_InitDiagVec;

    WriteLn(Format('er_Manufacturer         =%d=$%.4x=(~$%.4x)', [m, m, UWORD(not m)]));
    WriteLn(Format('er_Product              =%d=$%.2x=(~$%.2x)', [p, p, UBYTE(not p)]));

    Write(Format('er_Type                 =$%.2x', [myCD^.cd_Rom.er_Type]));
    if (myCD^.cd_Rom.er_Type and ERTF_MEMLIST) <> 0
    then WriteLn('  (Adds memory to free list)')
    else WriteLn;

    WriteLn(Format('er_Flags                =$%.2x=(~$%.2x)', [f, UBYTE(not f)]));
    WriteLn(Format('er_InitDiagVec          =$%.4x=(~$%.4x)', [i, UWORD(not i)]));


    {* These values are generated when the AUTOCONFIG(tm) software
     * relocates the board
     *}
    WriteLn('Configuration (ConfigDev) information:');
    WriteLn(Format('cd_BoardAddr            =$%p'      , [myCD^.cd_BoardAddr]));
    WriteLn(Format('cd_BoardSize            =$%x (%dK)', [myCD^.cd_BoardSize, ULONG(myCD^.cd_BoardSize) div 1024]));

    Write(Format('cd_Flags                =$%x'      , [myCD^.cd_Flags]));
    if (myCD^.cd_Flags and CDF_CONFIGME) <> 0
    then WriteLn
    else WriteLn('  (driver clears CONFIGME bit)');
  end;
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}  
  CloseLibrary(ExpansionBase);
  {$ENDIF}
end;


begin
  WriteLn('This example makes no sense whatsoever on certain hardware/OS combinations');
  Main(ArgC, ArgV);
end.
