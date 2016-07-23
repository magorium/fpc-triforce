Program Simple_Timer;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : Simple_Timer
  Source    : RKRM
}
{
 *****************************************************************************
 *
 * Simple_Timer.c
 *
 * A simple example of using the timer device.
 *
 * Compile with SAS C 5.10: LC -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */
}

{$MODE OBJFPC}{$H+}{.$HINTS ON}

{$UNITPATH ../../../Base/Trinity}

Uses
  Exec,
  AmigaDOS,
  Timer,
  {$IFDEF AMIGA}
  AmigaLib,
  {$ENDIF}
  SysUtils
  {$IF DEFINED(AROS) or DEFINED(MORPHOS)}
  ,Trinity
  {$ENDIF}
  ;


  //* Our timer sub-routines */
  procedure delete_timer  (tr: ptimerequest); forward;
  function  get_sys_time  (tv: ptimeval): LONG; forward;
  function  set_new_time  (secs: LONG): LONG; forward;
  procedure wait_for_timer(tr: ptimerequest; tv: ptimeval); forward;
  function  time_delay    (tv: ptimeval; unitnr: LONG): LONG; forward;
  function  create_timer  (unitnr: ULONG): ptimerequest; forward;
  procedure show_time     (secs: ULONG); forward;


var
 TimerBase: pLibrary absolute Timer.TimerBase;  //* to get at the time comparison functions */

const
//* manifest constants -- "never will change" */
  SECSPERMIN   = (60);
  SECSPERHOUR  = (60*60);
  SECSPERDAY   = (60*60*24);


procedure main(argc: integer; argv: ppchar);
var
  seconds    : LONG;
  tr         : ptimerequest;    //* IO block for timer commands */
  oldtimeval : ttimeval;        //* timevals to store times     */
  mytimeval  : ttimeval;
  currentval : ttimeval;
begin
  WriteLn(LineEnding, 'Timer test');

  //* sleep for two seconds */
  currentval.tv_secs  := 2;
  currentval.tv_micro := 0;
  time_delay( @currentval, UNIT_VBLANK );
  WriteLn( 'After 2 seconds delay' );

  //* sleep for four seconds */
  currentval.tv_secs  := 4;
  currentval.tv_micro := 0;
  time_delay( @currentval, UNIT_VBLANK );
  WriteLn( 'After 4 seconds delay' );

  //* sleep for 500,000 micro-seconds = 1/2 second */
  currentval.tv_secs  := 0;
  currentval.tv_micro := 500000;
  time_delay( @currentval, UNIT_MICROHZ );
  WriteLn( 'After 1/2 second delay' );

  WriteLn( 'DOS Date command shows: ' );
  // (void) Execute( "date", 0, 0 );
  Execute('date', Default(BPTR), Default(BPTR));

  //* save what system thinks is the time....we'll advance it temporarily */
  get_sys_time( @oldtimeval );
  WriteLn('Original system time is:');
  show_time(oldtimeval.tv_secs );

  WriteLn('Setting a new system time');

  seconds := 1000 * SECSPERDAY + oldtimeval.tv_secs;

  set_new_time( seconds );
  //* (if user executes the AmigaDOS DATE command now, he will*/
  //* see that the time has advanced something over 1000 days */

  WriteLn( 'DOS Date command shows: ' );
  // (void) Execute( "date", 0, 0 );
  Execute('date', Default(BPTR), Default(BPTR));

  get_sys_time( @mytimeval );
  WriteLn( 'Current system time is:');
  show_time(mytimeval.tv_secs);

  //* Added the microseconds part to show that time keeps */
  //* increasing even though you ask many times in a row  */

  WriteLn('Now do three TR_GETSYSTIMEs in a row (notice how the microseconds increase)');
  WriteLn;
  get_sys_time( @mytimeval );
  WriteLn(' First TR_GETSYSTIME ', #9, mytimeval.tv_secs, '.', mytimeval.tv_micro);
  get_sys_time( @mytimeval );
  WriteLn('Second TR_GETSYSTIME ', #9, mytimeval.tv_secs, '.', mytimeval.tv_micro);
  get_sys_time( @mytimeval );
  WriteLn(' Third TR_GETSYSTIME ', #9, mytimeval.tv_secs, '.', mytimeval.tv_micro);

  WriteLn( LineEnding, 'Resetting to former time' );
  set_new_time( oldtimeval.tv_secs );

  get_sys_time( @mytimeval );
  WriteLn( 'Current system time is:' );
  show_time(mytimeval.tv_secs);

  //* just shows how to set up for using the timer functions, does not */
  //* demonstrate the functions themselves.  (TimerBase must have a    */
  //* legal value before AddTime, SubTime or CmpTime are performed.    */
  tr := create_timer( UNIT_MICROHZ );
  TimerBase := pLibrary(tr^.tr_node.io_Device);

  //* and how to clean up afterwards */
  TimerBase := pLibrary(-1);
  delete_timer( tr );
end;



function  create_timer(unitnr: ULONG): ptimerequest;
//* return a pointer to a timer request.  If any problem, return NULL */
var
  error     : LONG;
  timerport : pMsgPort;
  TimerIO   : ptimerequest;
begin
  timerport := CreatePort( nil, 0 );
  if (timerport = nil )
    then exit ( nil );

  TimerIO := ptimerequest(
    CreateExtIO( timerport, sizeof( ttimerequest ) ));
  if (TimerIO = nil ) then
  begin
    DeletePort(timerport);   //* Delete message port */
    exit( nil );
  end;

  error := OpenDevice( TIMERNAME, unitnr, pIORequest(TimerIO), 0 );
  if (error <> 0 ) then
  begin
    delete_timer( TimerIO );
    exit( nil );
  end;
  result := TimerIO;
end;


//* more precise timer than AmigaDOS Delay() */
function  time_delay(tv: ptimeval; unitnr: LONG): LONG;
var
  tr: ptimerequest;
begin
  //* get a pointer to an initialized timer request block */
  tr := create_timer( unitnr );

  //* any nonzero return says timedelay routine didn't work. */
  if (tr = nil )
    then exit( -1 );

  wait_for_timer( tr, tv );

  //* deallocate temporary structures */
  delete_timer( tr );
  result := 0;
end;


procedure wait_for_timer(tr: ptimerequest; tv: ptimeval);
begin
  tr^.tr_node.io_Command := TR_ADDREQUEST; //* add a new timer request */

  //* structure assignment */
  tr^.tr_time := tv^;

  //* post request to the timer -- will go to sleep till done */
  DoIO(pIORequest( tr ));
end;


function  set_new_time(secs: LONG): LONG;
var
  tr: ptimerequest;
begin
  tr := create_timer( UNIT_MICROHZ );

  //* non zero return says error */
  if (tr = nil )
    then exit( -1 );

  tr^.tr_time.tv_secs := secs;
  tr^.tr_time.tv_micro := 0;
  tr^.tr_node.io_Command := TR_SETSYSTIME;
  DoIO(pIORequest( tr ));

  delete_timer(tr);
  result := 0;
end;


function  get_sys_time(tv: ptimeval): LONG;
var
  tr: ptimerequest;
begin  
  tr := create_timer( UNIT_MICROHZ );

  //* non zero return says error */
  if (tr = nil )
    then exit( -1 );

  tr^.tr_node.io_Command := TR_GETSYSTIME;
  DoIO(pIORequest( tr ));

  //* structure assignment */
  tv^ := tr^.tr_time;

  delete_timer( tr );
  result := 0;
end;


procedure delete_timer(tr: ptimerequest);
var
  tp: pMsgPort;
begin  
  if (tr <> nil ) then
  begin
    tp := tr^.tr_node.io_Message.mn_ReplyPort;

    if (tp <> nil)
      then DeletePort(tp);

    CloseDevice( pIORequest( tr ));
    DeleteExtIO( pIORequest( tr ));
  end;
end;


procedure show_time(secs: ULONG);
var
 days,hrs,mins: ULONG;
begin
  //* Compute days, hours, etc. */
  mins := secs div 60;
  hrs  := mins div 60;
  days := hrs  div 24;
  secs := secs mod 60;
  mins := mins mod 60;
  hrs  := hrs  mod 24;

  //* Display the time */
  WriteLn('*   Hour Minute Second  (Days since Jan.1,1978)');
  WriteLn(Format('*%5d:%5d:%5d            (%6d )', [hrs, mins, secs, days]));
  WriteLn;  
end;    //* end of main */



begin
  WriteLn('enter');

  Main(argc, argv);
  
  WriteLn('leave');
end.
