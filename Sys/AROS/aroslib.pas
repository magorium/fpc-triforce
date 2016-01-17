unit aroslib;

{$MODE OBJFPC}{$H+}

interface


Uses
  Exec, Utility;


var
  ArosBase      : PLibrary = nil;



// ###### aros/arosbase.h ###################################################



var
  AROSLIBNAME   : PChar = 'aros.library';


const
  // Minimum version that supports everything from the current includes.
  // Will be bumped whenever new functions are added to the library.
  AROSLIBVERSION        = 41;
  AROSLIBREVISION       =  1;



// ###### aros/inquire.h ####################################################



const
  AI_Base               = (TAG_USER);
   
  // If you use any of these tags, the tag's ti_Data field should point to the
  // location where the result is stored.

  //
  // General tags
  //

  AI_ArosVersion        = (AI_Base + 1);    // ULONG: Major AROS version number, e.g. 41
  AI_ArosReleaseMajor   = (AI_Base + 2);    // ULONG: Major AROS release version, e.g. 1
  AI_ArosReleaseMinor   = (AI_Base + 3);    // ULONG: Minor AROS release version, e.g. 11
  AI_ArosReleaseDate    = (AI_Base + 4);    // LONG: Days since 1978-01-01
  AI_ArosBuildDate      = (AI_Base + 5);    // STRPTR
  AI_ArosVariant        = (AI_Base + 6);    // STRPTR
  AI_ArosArchitecture   = (AI_Base + 7);    // STRPTR
  AI_ArosABIMajor       = (AI_Base + 8);    // LONG: Major AROS ABI version, e.g. 1

  //
  // Architecture specific tags
  //

  // Native Amiga
  AI_BaseA              = (AI_Base + $10000);
  AI_KickstartBase      = (AI_BaseA + 1);   // IPTR: Kickstart base address
  AI_KickstartSize      = (AI_BaseA + 2);   // IPTR: Kickstart size
  AI_KickstartVersion   = (AI_BaseA + 3);   // UWORD: Major Kickstart version
  AI_KickstartRevision  = (AI_BaseA + 4);   // UWORD: Minor Kickstart revision

  // Linux
  AI_BaseL              = (AI_Base + $20000);



// ###### function declarations #############################################



  function  ArosInquireA(tagList: PTagItem): ULONG; syscall ArosBase 5;

  // varargs
  function  ArosInquire(Const tags: Array of Const): ULONG;
  
  
  
implementation

uses
  TagsArray;
  
  
Function  ArosInquire(Const tags: Array of Const): ULONG;
Var
  TagList: TTagsList;
begin
  AddTags(TagList, tags);
  ArosInquire := ArosInquireA(GetTagPtr(TagList));
end;



Initialization

  ArosBase := OpenLibrary(AROSLIBNAME, 0);

finalization

  CloseLibrary(ArosBase);

end.
