program RKRMButClass;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : RKRM Button Class
  Source    : RKRM
}

{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, AGraphics, Intuition, Utility, InputEvent,
  {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
  AmigaLib,
  {$ENDIF}
  {$IFDEF AMIGA}
  SystemVartags,
  {$ENDIF}  
  CHelpers,
  Trinity;

  { FPC Note: some helper types }
Type
  BOOL   = LongBool;
  pUWORD = ^UWORD;
  SWORD  = SmallInt;

Const
  vers : PChar = #0'$VER: TestBut 37.1';

//***********************************************************/
//****************      Class specifics      ****************/
//***********************************************************/
Const
  RKMBUT_Pulse      = (TAG_USER + 1);

Type
  PButINST = ^TButINST;
  TButINST = record
    midX, midY      : LONG;         //* Coordinates of middle of gadget */
  end;


//* ButINST has one flag:  */
Const
  ERASE_ONLY        = $00000001;    //* Tells rendering routine to */
                                    //* only erase the gadget, not */
                                    //* rerender a new one.  This  */
                                    //* lets the gadget erase it-  */
                                    //* self before it rescales.   */

  //* The functions in this module */
  function  initRKMButGadClass: pIClass; forward;
  function  freeRKMButGadClass( cl: pIClass ): BOOL; forward;
  function  dispatchRKMButGad( cl: pIClass; o: PObject_; msg: Intuition.PMsg): ULONG; forward;
  procedure NotifyPulse(cl: pIClass; o: pObject_; flags: ULONG; mid: LONG; gpi: pgpInput); forward;
  Function  RenderRKMBut(cl: PIClass; g: pGadget; msg: pgpRender): ULONG; forward;
  // void   geta4(void);
  procedure MainLoop(attr: TAG; value: TAG); forward;


//*************************************************************************************************/
//* The main() function connects an RKMButClass object to a Boopsi integer gadget, which displays */
//* the RKMButClass gadget's RKMBUT_Pulse value.  The code scales and move the gadget while it is */
//* in place.                                                                                     */
//*************************************************************************************************/

var
  pulse2int : array[0..1] of TTagItem =
  (
    (ti_Tag: RKMBUT_Pulse; ti_Data: STRINGA_LongVal),
    (ti_tag: TAG_END; ti_Data: 0)
  );

Const
  INTWIDTH  = 40;
  INTHEIGHT = 20;


Var
  {
    FOC Note: library base pointers are located inside their respective unit
  }
  w         : pWindow;
  rkmbutcl  : PiClass;
  but,
  int       : pGadget;
  msg       : pIntuiMessage;
  

Procedure Main;
begin
  {$IFDEF MORPHOS}
  IntuitionBase := OpenLibrary('intuition.library', 37);
  if Assigned(IntuitionBase) then
  {$ENDIF}
  begin
    {$IFNDEF HASAMIGA}
    Utilitybase := OpenLibrary('utility.library', 37);
    if Assigned(UtilityBase) then
    {$ENDIF}
    begin
      {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
      GfxBase := OpenLibrary('graphics.library', 37);
      if Assigned(Gfxbase) then
      {$ENDIF}
      begin  
        w := OpenWindowTags(nil,
        [
          TAG_(WA_Flags)  , (WFLG_DEPTHGADGET or WFLG_DRAGBAR or WFLG_CLOSEGADGET or WFLG_SIZEGADGET),
          TAG_(WA_IDCMP)  , (IDCMP_CLOSEWINDOW),
          TAG_(WA_Width)  , 640,
          TAG_(WA_Height) , 200,
          TAG_END
        ]);
        if assigned(w) then
        begin
          WindowLimits(w, 450, 200, 640, 200);

          rkmbutcl := initRKMButGadClass();
          if assigned(rkmbutcl) then
          begin
            int := pGadget(
            NewObject(nil, PChar('strgclass'),
            [
              TAG_(GA_ID)           , 1,
              TAG_(GA_Top)          , (w^.BorderTop)  + 5,
              TAG_(GA_Left)         , (w^.BorderLeft) + 5,
              TAG_(GA_Width)        , INTWIDTH,
              TAG_(GA_Height)       , INTHEIGHT,
              TAG_(STRINGA_LongVal) , 0,
              TAG_(STRINGA_MaxChars), 5,
              TAG_END
            ]));
            If assigned(int) then
            begin
              but := pGadget(
              NewObject(rkmbutcl, nil,
              [
                TAG_(GA_ID)         , 2,
                TAG_(GA_Top)        , (w^.BorderTop) + 5,
                TAG_(GA_Left)       , int^.LeftEdge + int^.Width + 5,
                TAG_(GA_Width)      , 40,
                TAG_(GA_Height)     , INTHEIGHT,
                TAG_(GA_Previous)   , TAG_(int),
                TAG_(ICA_MAP)       , TAG_(@pulse2int),
                TAG_(ICA_TARGET)    , TAG_(int),
                TAG_END
              ]));
              if assigned(but) then
              begin
                AddGList(w, int, LongWord(-1), -1, nil);
                RefreshGList(int, w, nil, -1);

                SetWindowTitles(w, PChar('<-- Click to resize gadget Height'), nil);
                MainLoop(TAG_DONE, 0);

                SetWindowTitles(w, PChar('<-- Click to resize gadget Width'), nil);
                MainLoop(GA_Height, 100);

                SetWindowTitles(w, PChar('<-- Click to resize gadget Y position'), nil);
                MainLoop(GA_Width, 100);

                SetWindowTitles(w, PChar('<-- Click to resize gadget X position'), nil);
                MainLoop(GA_Top, but^.TopEdge + 20);

                SetWindowTitles(w, PChar('<-- Click to quit'), nil);
                MainLoop(GA_Left, but^.LeftEdge + 20);

                RemoveGList(w, int, -1);
                DisposeObject(but);
              end;
              DisposeObject(int);
            end;
            freeRKMButGadClass(rkmbutcl);
          end;  
          CloseWindow(w)
        end;
        {$IF DEFINED(AMIGA) or DEFINED(MORPHOS)}
        CloseLibrary(GfxBase);
        {$ENDIF}
      end;
      {$IFNDEF HASAMIGA}
      CloseLibrary(UtilityBase);
      {$ENDIF}
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(pLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;



procedure MainLoop(attr: TAG; value: TAG);
var
  done: boolean = false;
begin
  SetGadgetAttrs(but, w, nil, [TAG_(attr), TAG_(value), TAG_DONE]);

  while (done = false) do
  begin
    WaitPort(pMsgPort(w^.UserPort));
    while SetAndTest(msg, GetMsg(w^.UserPort)) do
    begin
      if (msg^.IClass = IDCMP_CLOSEWINDOW) then
      begin
        done := TRUE;
      end;
      ReplyMsg(pMessage(msg));
    end;
  end;
end;



//***********************************************************/
//**    Make the class and set up the dispatcher's hook    **/
//***********************************************************/
function initRKMButGadClass: pIClass;
var
  cl: pIClass = nil;
begin
  cl := MakeClass(nil, PChar('gadgetclass'), nil, sizeof(TButINST), 0);
  if assigned(cl) then
  begin
    //* initialize the cl_Dispatcher Hook    */

    // FPC Note: Use cross platform compatible hook initialization
    InitHook(cl^.cl_Dispatcher, THookFunction(@dispatchRKMButGad), nil);
  end;
  result := cl;
end;



//***********************************************************/
//******************     Free the class      ****************/
//***********************************************************/
function freeRKMButGadClass( cl: pIClass ): BOOL;
begin
  result := FreeClass(cl);
end;



//***********************************************************/
//**********       The RKMBut class dispatcher      *********/
//***********************************************************/
function  dispatchRKMButGad( cl: pIClass; o: PObject_; msg: PMsg): ULONG;
var
  inst    : pButINST;
  retval  : ULONG; 
  obj     : p_Object;
var
  g       : pGadget;
var
  gpi     : pgpInput;
  ie      : pInputEvent;
var
  x,y,w,h : SWORD;
  rp      : pRastPort;
  pens    : pUWORD;
begin
  //* SAS/C and Manx function to make sure register A4 contains a pointer to global data */
  // geta4();

  retval := LFALSE;

  Case msg^.MethodID of
    OM_NEW :        //* First, pass up to superclass */
    begin
      if SetAndTest(obj, pointer(DoSuperMethodA(cl, o, msg)) ) then
      begin
        g := pGadget(obj);
                    //* Initial local instance data */
        inst := INST_DATA(cl, obj);
        inst^.midX   := g^.LeftEdge + ( (g^.Width)  div 2 );
        inst^.midY   := g^.TopEdge  + ( (g^.Height) div 2 );

        retval := ULONG(obj);
      end;
    end;
    GM_HITTEST :
    begin
      //* Since this is a rectangular gadget this  */
      //* method always returns GMR_GADGETHIT.     */
      retval := GMR_GADGETHIT;
    end;
    GM_GOACTIVE :
    begin
      inst := INST_DATA(cl, obj);

      //* Only become active if the GM_GOACTIVE   */
      //* was triggered by direct user input.     */
      if (pgpInput(msg)^.gpi_IEvent <> nil) then
      begin
        //* This gadget is now active, change    */
        //* visual state to selected and render. */
        pGadget(o)^.Flags := pGadget(o)^.Flags or GFLG_SELECTED;
        
        RenderRKMBut(cl, pGadget(o), pgpRender(msg));
        retval := GMR_MEACTIVE;
      end
      else
      begin
        //* The GM_GOACTIVE was not         */
        //* triggered by direct user input. */
        retval := GMR_NOREUSE;        
      end;
    end;
    GM_RENDER:
    begin
      retval := RenderRKMBut(cl, pGadget(o), pgpRender(msg));
    end;
    GM_HANDLEINPUT:   
    begin
      //* While it is active, this gadget sends its superclass an        */
      //* OM_NOTIFY pulse for every IECLASS_TIMER event that goes by     */
      //* (about one every 10th of a second).  Any object that is        */
      //* connected to this gadget will get A LOT of OM_UPDATE messages. */
      g   := pGadget(o);
      gpi := pgpInput(msg);
      ie  := gpi^.gpi_IEvent;

      inst := INST_DATA(cl, pointer(o));

      retval := GMR_MEACTIVE;      

      if (ie^.ie_Class = IECLASS_RAWMOUSE) then
      begin
        case ie^.ie_Code of
          SELECTUP :
          begin
            //* The user let go of the gadget so return GMR_NOREUSE    */
            //* to deactivate and to tell Intuition not to reuse       */
            //* this Input Event as we have already processed it.      */

            //*If the user let go of the gadget while the mouse was    */
            //*over it, mask GMR_VERIFY into the return value so       */
            //*Intuition will send a Release Verify (GADGETUP).        */
            if 
            ( 
              ( (gpi^.gpi_Mouse).X < g^.LeftEdge            ) or
              ( (gpi^.gpi_Mouse).X > g^.LeftEdge + g^.Width ) or
              ( (gpi^.gpi_Mouse).Y < g^.TopEdge             ) or
              ( (gpi^.gpi_Mouse).Y > g^.TopEdge + g^.Height ) 
            )
            then retval := GMR_NOREUSE or GMR_VERIFY
            else retval := GMR_NOREUSE;
            
            //* Since the gadget is going inactive, send a final   */
            //* notification to the ICA_TARGET.                    */
            NotifyPulse(cl , o, 0, inst^.midX, pgpInput(msg));
          end;
          MENUDOWN :
          begin
            //* The user hit the menu button. Go inactive and let      */
            //* Intuition reuse the menu button event so Intuition can */
            //* pop up the menu bar.                                   */
            retval := GMR_REUSE;
            
            //* Since the gadget is going inactive, send a final   */
            //* notification to the ICA_TARGET.                    */
            NotifyPulse(cl , o, 0, inst^.midX, pgpInput(msg));
          end;
          else
          begin
            retval := GMR_MEACTIVE;
          end;
        end; // case
      end
      else 
        //* If the gadget gets a timer event, it sends an interim OM_NOTIFY */
        //* to its superclass. */
        if (ie^.ie_Class = IECLASS_TIMER) 
        then NotifyPulse(cl, o, OPUF_INTERIM, inst^.midX, gpi); 
    end;
    GM_GOINACTIVE:           
    begin                   
      //* Intuition said to go inactive.  Clear the GFLG_SELECTED */
      //* bit and render using unselected imagery.                */
      pGadget(o)^.Flags := pGadget(o)^.Flags and not(GFLG_SELECTED);
      RenderRKMBut(cl, pGadget(o), pgpRender(msg));
    end;
    OM_SET: 
    begin
      //* Although this class doesn't have settable attributes, this gadget class   */
      //* does have scaleable imagery, so it needs to find out when its size and/or */
      //* position has changed so it can erase itself, THEN scale, and rerender.    */
      if 
      ( 
        ( FindTagItem(GA_Width  , popSet(msg)^.ops_AttrList) <> nil ) or
        ( FindTagItem(GA_Height , popSet(msg)^.ops_AttrList) <> nil ) or
        ( FindTagItem(GA_Top    , popSet(msg)^.ops_AttrList) <> nil ) or
        ( FindTagItem(GA_Left   , popSet(msg)^.ops_AttrList) <> nil ) 
      ) then
      begin

        g := pGadget(o);
        
        x := g^.LeftEdge;
        y := g^.TopEdge;
        w := g^.Width;
        h := g^.Height;

        inst   := INST_DATA(cl, pointer(o));

        retval := DoSuperMethodA(cl, o, msg);

        //* Get pointer to RastPort for gadget. */
        if SetAndTest(rp, ObtainGIRPort( popSet(msg)^.ops_GInfo) ) then
        begin
          pens := popSet(msg)^.ops_GInfo^.gi_DrInfo^.dri_Pens;

          SetAPen(rp, pens[BACKGROUNDPEN]);
          SetDrMd(rp, JAM1);                                //* Erase the old gadget.       */
          RectFill(rp, x, y, x+w, y+h);

          inst^.midX := g^.LeftEdge + ( (g^.Width)  div 2); //* Recalculate where the       */
          inst^.midY := g^.TopEdge +  ( (g^.Height) div 2); //* center of the gadget is.    */

          //* Rerender the gadget.        */
          DoMethod(o, GM_RENDER, [TAG_(popSet(msg)^.ops_GInfo), TAG_(rp), TAG_(GREDRAW_REDRAW)]);
          ReleaseGIRPort(rp);
        end;
      end
      else
      begin
        retval := DoSuperMethodA(cl, o, msg);
      end;
    end;
    else                   
    begin
      //* rkmmodelclass does not recognize the methodID, let the superclass's */
      //* dispatcher take a look at it.                                       */
      retval := DoSuperMethodA(cl, o, msg);
    end;
  end; // case MethodID

  result := retval;
end;



//*************************************************************************************************/
//************** Build an OM_NOTIFY message for RKMBUT_Pulse and send it to the superclass. *******/
//*************************************************************************************************/
procedure NotifyPulse(cl: pIClass; o: pObject_; flags: ULONG; mid: LONG; gpi: pgpInput); 
var
  tt: array[0..pred(3)] of TTagItem;
begin  
  tt[0].ti_Tag  := RKMBUT_Pulse;
  tt[0].ti_Data := mid - ((gpi^.gpi_Mouse).X + (pGadget(o))^.LeftEdge);

  tt[1].ti_Tag  := GA_ID;
  tt[1].ti_Data := (pGadget(o))^.GadgetID;

  tt[2].ti_Tag  := TAG_DONE;

  DoSuperMethod(cl, o, OM_NOTIFY, [TAG_(@tt), TAG_(gpi^.gpi_GInfo), TAG_(flags)]);
end;



//*************************************************************************************************/
//*******************************   Erase and rerender the gadget.   ******************************/
//*************************************************************************************************/
Function  RenderRKMBut(cl: PIClass; g: pGadget; msg: pgpRender): ULONG;
var
  inst   : pButINST;
  rp     : pRastPort;
  retval : ULONG;
  pens   : pUWORD;
var
  back, shine, shadow, w, h, x, y: UWORD;
  
begin
  retval := LTRUE;
  inst   := INST_DATA(cl, p_Object(g));
  pens   := msg^.gpr_GInfo^.gi_DrInfo^.dri_Pens;

  if (msg^.MethodID = GM_RENDER)            //* If msg is truly a GM_RENDER message (not a gpInput that */
  then rp := msg^.gpr_RPort                 //* looks like a gpRender), use the rastport within it...   */
  else rp := ObtainGIRPort(msg^.gpr_GInfo); //* ...Otherwise, get a rastport using ObtainGIRPort().     */

  if assigned(rp) then
  begin
    if ((g^.Flags and GFLG_SELECTED) <> 0) then //* If the gadget is selected, reverse the meanings of the pens */
    begin
      back   := pens[FILLPEN];
      shine  := pens[SHADOWPEN];
      shadow := pens[SHINEPEN];
    end
    else
    begin
      back   := pens[BACKGROUNDPEN];
      shine  := pens[SHINEPEN];
      shadow := pens[SHADOWPEN];
    end;

    SetDrMd(rp, JAM1);

    SetAPen(rp, back);          //* Erase the old gadget.       */
    RectFill(rp, g^.LeftEdge,
                 g^.TopEdge,
                 g^.LeftEdge + g^.Width,
                 g^.TopEdge + g^.Height);

    SetAPen(rp, shadow);        //* Draw shadow edge.            */
    GfxMove(rp, g^.LeftEdge + 1, g^.TopEdge + g^.Height);
    Draw(rp, g^.LeftEdge + g^.Width, g^.TopEdge + g^.Height);
    Draw(rp, g^.LeftEdge + g^.Width, g^.TopEdge + 1);

    w := g^.Width  div 4;       //* Draw Arrows - Sorry, no frills imagery */
    h := g^.Height div 2;
    x := g^.LeftEdge + (w div 2);
    y := g^.TopEdge  + (h div 2);

    GfxMove(rp, x, inst^.midY);
    Draw(rp, x + w, y);
    Draw(rp, x + w, y + (g^.Height) - h);
    Draw(rp, x, inst^.midY);

    x := g^.LeftEdge + (w div 2) + g^.Width div 2;

    GfxMove(rp, x + w, inst^.midY);
    Draw(rp, x, y);
    Draw(rp, x, y  + (g^.Height) - h);
    Draw(rp, x + w, inst^.midY);

    SetAPen(rp, shine);         //* Draw shine edge.           */
    GfxMove(rp, g^.LeftEdge, g^.TopEdge + g^.Height - 1);
    Draw(rp, g^.LeftEdge, g^.TopEdge);
    Draw(rp, g^.LeftEdge + g^.Width - 1, g^.TopEdge);

    if (msg^.MethodID <> GM_RENDER)     //* If we allocated a rastport, give it back. */
    then ReleaseGIRPort(rp);
  end
  else retval := LFALSE;

  result := retval;
end;



begin
  WriteLn('enter');
  Main;
  WriteLn('leave');
end.
