unit Steam_MiniDump;

interface  

{$I defines.inc}

uses
  Windows, USE_Types,
    utils, SteamTypes;

function SteamWriteMiniDumpFromAssert(unknown1, unknown2, unknown3: uint32; szMessage, szFileName: pAnsiChar): int; export; cdecl;
function SteamWriteMiniDumpSetComment(cszComment: pAnsiChar): int; export; cdecl;
function SteamWriteMiniDumpUsingExceptionInfo: int; export; cdecl;
function SteamWriteMiniDumpUsingExceptionInfoWithBuildId: int; export; cdecl;

implementation

function SteamWriteMiniDumpFromAssert(unknown1, unknown2, unknown3: uint32; szMessage, szFileName: pAnsiChar): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGIN_MINIDUMP then
    Log('SteamWriteMiniDumpFromAssert'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamWriteMiniDumpSetComment(cszComment: pAnsiChar): int; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGIN_MINIDUMP then
    Log('SteamWriteMiniDumpSetComment'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamWriteMiniDumpUsingExceptionInfo: int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGIN_MINIDUMP then
    Log('SteamWriteMiniDumpUsingExceptionInfo'+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamWriteMiniDumpUsingExceptionInfoWithBuildId: int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGIN_MINIDUMP then
    Log('SteamWriteMiniDumpUsingExceptionInfoWithBuildId'+#13#10); 
{$ENDIF}
  result:=1;
end;

end.
