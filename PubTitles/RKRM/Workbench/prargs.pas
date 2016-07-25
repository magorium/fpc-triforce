program prargs;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : prargs
  Topic     : This program prints all Workbench or Shell (CLI) arguments.
  Source    : RKRM
}
  {*
  ** The following example will display all WBArgs if started from
  ** Workbench, and all Shell arguments if started from the Shell.
  **
  *}


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

{$IFDEF AMIGA}   {$UNITPATH ../../../Sys/Amiga}   {$ENDIF}
{$IFDEF AROS}    {$UNITPATH ../../../Sys/AROS}    {$ENDIF}
{$IFDEF MORPHOS} {$UNITPATH ../../../Sys/MorphOS} {$ENDIF}


Uses
  Exec, AmigaDOS, Workbench,
  Trinity,
  SysUtils;


procedure Main(argc: integer; argv: PPChar);
var
  argmsg    : PWBStartup;
  wb_arg    : PWBArg;
  ktr       : LONG;
  olddir    : BPTR;
  outfile   : Text;
begin
  //* AOS_WbMsg is nil when run from the CLI and positive when run from Workbench.
  {$IFDEF MORPHOS}
  if (argc = 0) then  
  {$ELSE}
  if (AOS_WbMsg <> nil) then
  {$ENDIF}
  begin
    //* AmigaDOS has a special facility that  allows a window  with a */
    //* console and a file handle to be easily created. */
    //* CON: windows allow you to use Pascal RTL write functions, although 
    //* doing so is not advisable.
    System.Assign(OutFile, 'CON:0/0/640/200/PrArgs');
    System.Rewrite(OutFile);

    if (TextRec(outfile).Handle <> -1) then
    begin
      {* in SAS/Lattice, argv is a pointer to the WBStartup message
      ** when argc is zero.  (run under the Workbench.)
      *}
      {$IFDEF MORPHOS}
      argmsg := PWBStartup(argv);
      {$ELSE}
      argmsg := PWBStartup(AOS_WbMsg);      // AOS_WbMsg is actually PWBStartup
      {$ENDIF}
      wb_arg := PWBArg(argmsg^.sm_ArgList); //* head of the arg list */

      WriteLn(outFile, Format('Run from the workbench, %d args.', [argmsg^.sm_NumArgs]));
      System.Flush(OutFile);    //* unfortunately we need to flush manually with FPC
      
      ktr := 0;
      while (ktr < argmsg^.sm_NumArgs) do
      begin
        if (default(bptr) <> wb_arg^.wa_Lock) then
        begin
          //* locks supported, change to the proper directory */
          olddir := CurrentDir(wb_arg^.wa_Lock);

          {* process the file.
          ** If you have done the CurrentDir() above, then you can
          ** access the file by its name.  Otherwise, you have to
          ** examine the lock to get a complete path to the file.
          *}
          WriteLn(outFile, Format(#9'Arg %2.2d (w/ lock): "%s".', [ktr, wb_arg^.wa_Name]));
          System.Flush(OutFile);    //* unfortunately we need to flush manually with FPC
          {* change back to the original directory when done.
          ** be sure to change back before you exit.
          *}
          CurrentDir(olddir);
        end
        else
        begin
          //* something that does not support locks */
          WriteLn(outFile, Format(#9'Arg %2.2d (no lock): "%s".', [ktr, wb_arg^.wa_Name]));
          System.Flush(OutFile);    //* unfortunately we need to flush manually with FPC
        end;
        inc(ktr); inc(wb_arg);
      end;
      //* wait before closing down */
      System.Flush(OutFile);
      DOSDelay(500);
      System.close(outFile);
    end;
  end
  else
  begin
    {* using some FPC trickery.
    ** To define a place to send the output (originating CLI window = "")
    ** Note - if you open "" and your program is RUN, the user will not
    ** be able to close the CLI window until you close the "" file.
    *}
    System.Assign(OutFile, '');
    System.Rewrite(OutFile);

    if (TextRec(outfile).Handle <> -1) then
    begin
      WriteLn(outFile, Format('Run from the CLI, %d args.', [argc]));
      System.Flush(OutFile);

      ktr := 0;
      while (ktr < argc) do
      begin
        //* print an arg, and its number */
        WriteLn(outFile, Format(#9'Arg %2.2d: "%s".', [ktr, argv[ktr]]));
        System.Flush(OutFile);
        inc(ktr);
      end;
      system.close(outFile);
    end;
  end;
end;

begin
  Main(ArgC, ArgV);
end.
