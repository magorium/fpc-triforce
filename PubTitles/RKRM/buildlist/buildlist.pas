program buildlist;

{$IFNDEF HASAMIGA}
{$FATAL This source is compatible with Amiga, AROS and MorphOS only !}
{$ENDIF}

{
  Project   : buildlist
  Source    : RKRM
}
 {
  example which uses an application-specific Exec list
 }


{$MODE OBJFPC}{$H+}{$HINTS ON}

{$UNITPATH ../../../Base/CHelpers}
{$UNITPATH ../../../Base/Trinity}


Uses
  Exec,
  {$IFDEF AMIGA}
  AmigaLib,
  {$ENDIF}
  SysUtils,
  CHelpers,
  Trinity;


  //* Our function prototypes */
  procedure AddName(list: PList; name: PChar); forward;
  procedure FreeNameNodes(list: PList); forward;
  procedure DisplayNameList(list: PList); forward;
  procedure DisplayName(list: PList; name: PChar); forward;


Type
  PNameNode = ^TNameNode;
  TNameNode = record
    nn_Node : TNode;                                //* System Node structure */
    nn_Data : packed array [0..Pred(62)] of char;   //* Node-specific data */
  end;
  
Const  
  NAMENODE_ID   = 100;                              //* The type of "NameNode" */


Procedure Main;
var
  NameList  : PList;                //* Note that a MinList would also work */
begin
  if (not SetAndTest(NameList, ExecAllocMem(sizeof(TList), MEMF_CLEAR)) )
  then WriteLn('Out of memory')
  else
  begin
    NewList(NameList);          //* Important: prepare header for use */

    AddName(NameList, 'Name7');   AddName(NameList, 'Name6');
    AddName(NameList, 'Name5');   AddName(NameList, 'Name4');
    AddName(NameList, 'Name2');   AddName(NameList, 'Name0');

    AddName(NameList, 'Name7');   AddName(NameList, 'Name5');
    AddName(NameList, 'Name3');   AddName(NameList, 'Name1');

    DisplayName(NameList, 'Name5');
    DisplayNameList(NameList);

    FreeNameNodes(NameList);
    ExecFreeMem(NameList, sizeof(TList));   //* Free list header */
  end;
end;


{* Allocate a NameNode structure, copy the given name into the structure,
 * then add it the specified list.  This example does not provide an
 * error return for the out of memory condition.
 *}
procedure AddName(list: PList; name: PChar);
var
  namenode  : PNameNode;
begin
  if (not SetAndTest(namenode, ExecAllocMem(sizeof(TNameNode), MEMF_CLEAR) ))
  then WriteLn('Out of memory')
  else
  begin
    strcopy(namenode^.nn_Data, name);
    namenode^.nn_Node.ln_Name := namenode^.nn_Data;
    namenode^.nn_Node.ln_Type := NAMENODE_ID;
    namenode^.nn_Node.ln_Pri  := 0;
    AddHead( PList(list), PNode(namenode) );
  end;
end;


{*
 * Free the entire list, including the header.  The header is not updated
 * as the list is freed.  This function demonstrates how to avoid
 * referencing freed memory when deallocating nodes.
 *}
procedure FreeNameNodes(list: PList);
var
  worknode  : PNameNode;
  nextnode  : PNameNode;
begin
  worknode := PNameNode(list^.lh_Head);     //* First node */
  while SetAndTest(nextnode, PNameNode(worknode^.nn_Node.ln_Succ)) do
  begin
    ExecFreeMem(worknode, sizeof(TNameNode));
    worknode := nextnode;
  end;
end;


{*
 * Print the names of each node in a list.
 *}
procedure DisplayNameList(list: PList);
var
  node  : PNode;
begin
  if (list^.lh_TailPred = PNode(list))
  then WriteLn('List is empty.')
  else
  begin
    node := list^.lh_Head;
    while node^.ln_Succ <> nil do
    begin
      WriteLn(Format('%p -> %s', [node, node^.ln_Name]));
      node := node^.ln_Succ;
    end;
  end;
end;


{*
 * Print the location of all nodes with a specified name.
 *}
procedure DisplayName(list: PList; name: PChar);
var
  node  : PNode;
begin
  if SetAndTest(node, FindName(list, name)) then
  begin
    while Assigned(node) do
    begin
      WriteLn(Format('Found a %s at location %p', [node^.ln_Name, node]));
      node := FindName(PList(node), name);
    end;
  end else WriteLn(Format('No node with name %s found.', [name]));
end;


begin
  Main;
end.
