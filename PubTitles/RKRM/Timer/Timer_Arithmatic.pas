program Timer_ArithMatic;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : Timer_Arithmatic
  Source    : RKRM
}
{
 *****************************************************************************
 *
 *
 * Timer_Arithmetic.c
 *
 * Example of timer device arithmetic functions
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */
}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/Trinity}

Uses
  Exec,
  Timer
  {$IF DEFINED(AMIGA) or DEFINED(AROS)}
  ,Trinity
  {$ENDIF}  
  ;


var
  TimerBase: pLibrary absolute timer.TimerBase;      //* setup the interface variable (must be global) */


procedure Main(argc: integer; argv: ppchar);
var
  time1, time2, time3: ptimeval;
  tr : ptimerequest;
  error, res : LONG;
label
  cleanexit;
begin
  //*------------------------------------*/
  //* Get some memory for our structures */
  //*------------------------------------*/
  time1 := ptimeval(ExecAllocMem(sizeof(ttimeval), MEMF_PUBLIC or MEMF_CLEAR));
  time2 := ptimeval(ExecAllocMem(sizeof(ttimeval), MEMF_PUBLIC or MEMF_CLEAR));
  time3 := ptimeval(ExecAllocMem(sizeof(ttimeval), MEMF_PUBLIC or MEMF_CLEAR));
  tr := ptimerequest(ExecAllocMem(sizeof(ttimerequest), MEMF_PUBLIC or MEMF_CLEAR));
  //* Make sure we got the memory */
  if (not (time1 <> nil) or not (time2 <> nil) or not (time3 <> nil) or not (tr <> nil)) 
  then goto cleanexit;
  
  //*---------------------------------------------------------------------------*/
  //* Set up values to test time arithmetic with.  In a real application these  */
  //* values might be filled in via the GET_SYSTIME command of the timer device */
  //*---------------------------------------------------------------------------*/
  time1^.tv_secs := 3; time1^.tv_micro := 0;           //* 3.0 seconds */
  time2^.tv_secs := 2; time2^.tv_micro := 500000;      //* 2.5 seconds */
  time3^.tv_secs := 1; time3^.tv_micro := 900000;      //* 1.9 seconds */

  WriteLn('Time1 is ', time1^.tv_secs, '.', time1^.tv_micro);
  WriteLn('Time2 is ', time2^.tv_secs, '.', time2^.tv_micro);
  WriteLn('Time3 is ', time3^.tv_secs, '.', time3^.tv_micro);
  WriteLn;
  //*-------------------------------*/
  //* Open the MICROHZ timer device */
  //*-------------------------------*/
  error := OpenDevice(TIMERNAME,UNIT_MICROHZ, pIORequest(tr), 0);
  if (error <> 0) then goto cleanexit;

  //* Set up to use the special time arithmetic functions */
  TimerBase := pLibrary(tr^.tr_node.io_Device);
  //*--------------------------------------------------------------------------*/
  //* Now that TimerBase is initialized, it is permissible to call the         */
  //* time-comparison or time-arithmetic routines.  Result of this example     */
  //* is -1 which means the first parameter has greater time value than second */
  //* parameter +1 means the second parameter is bigger; 0 means equal.        */
  //*--------------------------------------------------------------------------*/
  res := CmpTime( time1, time2 );
  WriteLn('Time1 and Time2 compare = ',res);

  //* Add time2 to time1, result in time1 */
  AddTime( time1, time2);
  WriteLn('Time1 + Time2 = ', time1^.tv_secs, '.', time1^.tv_micro);

  //* Subtract time3 from time2, result in time2 */
  SubTime( time2, time3);
  WriteLn('Time2 - Time3 = ', time2^.tv_secs, '.', time2^.tv_micro);

  //*------------------------------------*/
  //* Free system resources that we used */
  //*------------------------------------*/
cleanexit:
  if (time1 <> nil)
     then ExecFreeMem(time1,sizeof(ttimeval));
  if (time2 <> nil)
     then ExecFreeMem(time2,sizeof(ttimeval));
  if (time3 <> nil)
     then ExecFreeMem(time3,sizeof(ttimeval));
  if not(error <> 0)
     then CloseDevice(pIORequest(tr));
  if (tr <> nil)
     then ExecFreeMem(tr,sizeof(ttimerequest));
end;



begin
  WriteLn('enter');

  Main(argc, argv);
  
  WriteLn('leave');
end.
