program Talk2boopsi;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : Talk2boopsi
  Source    : RKRM
}

 {*
 ** This example creates a Boopsi prop gadget and integer string gadget, 
 ** connecting them so they update each other when the user changes their 
 ** value.
 ** The example program only initializes the gadgets and puts them on the 
 ** window; it doesn't have to interact with them to make them talk to each 
 ** other.
 *}



{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}

Uses
  Exec, Intuition, utility,
  {$IFDEF AMIGA}
  SystemVarTags,
  {$ENDIF}
  CHelpers,
  Trinity;



Const
  vers          : PChar = #0'$VER: Talk2boopsi 37.1';

var
  w             : PWindow;
  msg           : PIntuiMessage;
  prop, 
  integergad    : PGadget;

  //* The attribute mapping lists */
  prop2intmap   : array[0..1] of TTagItem =
  (                                 //* This tells the prop gadget to */
    (                               //* map its PGA_Top attribute to  */
      ti_Tag    : PGA_Top;          //* STRINGA_LongVal when it       */
      ti_Data   : STRINGA_LongVal   //* issues an update about the    */
    ),                              //* change to its PGA_Top value.  */
    ( 
      ti_Tag    : TAG_END; 
      ti_Data   : 0 
    )
  );

  int2propmap   : array[0..1] of TTagItem =
  (                                 //* This tells the string gadget */
    (                               //* to map its STRINGA_LongVal   */
      ti_Tag    : STRINGA_LongVal;  //* attribute to PGA_Top when it */
      ti_Data   : PGA_Top;          //* issues an update.            */
    ),
    (
      ti_Tag    : TAG_END;
      ti_Data   : 0;
    )
  );  

const
  PROPGADGET_ID     = 1;
  INTGADGET_ID      = 2;
  PROPGADGETWIDTH   = 10;
  PROPGADGETHEIGHT  = 80;
  INTGADGETHEIGHT   = 18;
  VISIBLE           = 10;
  TOTAL             = 100;
  INITIALVAL        = 25;
  MINWINDOWWIDTH    = 80;
  MINWINDOWHEIGHT   = (PROPGADGETHEIGHT + 70);
  MAXCHARS          = 3;



procedure Main;
var
  done  : Boolean;
begin
  done := FALSE;

  {$IFDEF MORPHOS}
  if SetAndTest(IntuitionBase, OpenLibrary('intuition.library', 37)) then
  {$ENDIF}
  begin
    //* Open the window--notice that the window's IDCMP port     */
    //* does not listen for GADGETUP messages.                   */
    if SetAndTest(w, OpenWindowTags(nil,
    [
      TAG_(WA_Flags)        , WFLG_DEPTHGADGET or WFLG_DRAGBAR or WFLG_CLOSEGADGET or WFLG_SIZEGADGET,
      TAG_(WA_IDCMP)        , IDCMP_CLOSEWINDOW,
      TAG_(WA_MinWidth)     , MINWINDOWWIDTH,
      TAG_(WA_MinHeight)    , MINWINDOWHEIGHT,
      TAG_END
    ])) then
    begin                       //* Create a new propgclass object */
      if SetAndTest(prop, PGadget(NewObject(nil, 'propgclass',
      [                                             //* These are defined by */
        TAG_(GA_ID)         , PROPGADGET_ID,        //* gadgetclass and      */
        TAG_(GA_Top)        , (w^.BorderTop)  + 5,  //* correspond to        */
        TAG_(GA_Left)       , (w^.BorderLeft) + 5,  //* similarly named      */
        TAG_(GA_Width)      , PROPGADGETWIDTH,      //* fields in the Gadget */
        TAG_(GA_Height)     , PROPGADGETHEIGHT,     //* structure.           */
        //* The prop gadget's attribute map */
        TAG_(ICA_MAP)       , TAG_(@prop2intmap),  
        //* The rest of this gadget's attributes are defined by propgclass. */

        //* This is the integer range of the prop gadget.  */
        TAG_(PGA_Total)     , TOTAL,        
        //* The initial integer value of the prop gadget.  */
        TAG_(PGA_Top)       , INITIALVAL,   
        //* This determines how much of the prop gadget area is   */
        //* covered by the prop gadget's knob, or how much of     */        
        //* the gadget's TOTAL range is taken up by the prop      */        
        //* gadget's knob.                                        */
        TAG_(PGA_Visible)   , VISIBLE,      
        //* Use new-look prop gadget imagery */
        TAG_(PGA_NewLook)   , TAG_(TRUE),   
        TAG_END
      ]))) then
      begin        //* create the integer string gadget.                     */
        if SetAndTest(integergad, PGadget(NewObject(nil, 'strgclass',
        [                        //* Parameters for the Gadget structure     */
          TAG_(GA_ID)       , INTGADGET_ID,  
          TAG_(GA_Top)      , (w^.BorderTop) + 5,
          TAG_(GA_Left)     , (w^.BorderLeft) + PROPGADGETWIDTH + 10,
          TAG_(GA_Width)    , MINWINDOWWIDTH - (w^.BorderLeft + w^.BorderRight + PROPGADGETWIDTH + 15),
          TAG_(GA_Height)   , INTGADGETHEIGHT,

          TAG_(ICA_MAP)     , TAG_(@int2propmap),      //* The attribute map */
          TAG_(ICA_TARGET)  , TAG_(prop),              //* plus the target.  */

          //* Th GA_Previous attribute is defined by gadgetclass and is used */
          //* to wedge a new gadget into a list of gadget's linked by their  */
          //* Gadget.NextGadget field.  When NewObject() creates this        */
          //* gadget, it inserts the new gadget into this list behind the    */
          //* GA_Previous gadget. This attribute is a pointer to the         */
          //* previous gadget (struct Gadget *).  This attribute cannot be   */
          //* used to link new gadgetsinto the gadget list of an open        */
          //* window or requester, use AddGList() instead.                   */
          TAG_(GA_Previous) , TAG_(prop),
          //* These attributes are defined by strgclass.  */
          //* The first contains the value of the         */
          //* integer string gadget. The second is the    */
          //* maximum number of characters the user is    */
          //* allowed to type into the gadget.            */
          TAG_(STRINGA_LongVal) , INITIALVAL, 
          TAG_(STRINGA_MaxChars), MAXCHARS,   
          TAG_END
        ]))) then            
        begin
          //* Because the integer string gadget did not   */
          //* exist when this example created the prop    */
          //* gadget, it had to wait to set the           */
          //* ICA_Target of the prop gadget.              */
          SetGadgetAttrs(prop, w, nil,          
          [                                     
            TAG_(ICA_TARGET), TAG_(integergad), 
            TAG_END                             
          ]);                 
                                                  
          AddGList(w, prop, -1, -1, nil);   //* Add the gadgets to the       */
          RefreshGList(prop, w, nil, -1);   //* window and display them.     */

          while (done = FALSE) do           //* Wait for the user to click   */
          begin                             //* the window close gadget.     */
            WaitPort(PMsgPort(w^.UserPort));
            while SetAndTest(msg, PIntuiMessage(GetMsg(PMsgPort(w^.UserPort)))) do
            begin
              if (msg^.IClass = IDCMP_CLOSEWINDOW)
              then done := TRUE;
              ReplyMsg(PMessage(msg));
            end;
          end;
          RemoveGList(w, prop, -1);
          DisposeObject(integergad);
        end;
        DisposeObject(prop);
      end;
      CloseWindow(w);
    end;
    {$IFDEF MORPHOS}
    CloseLibrary(PLibrary(IntuitionBase));
    {$ENDIF}
  end;
end;


begin
  Main;
end.
