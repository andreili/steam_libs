unit Steam_Logging;

interface  

{$I defines.inc}

uses
  Windows, USE_Types,
    utils, SteamTypes;

function SteamCreateLogContext(cszName: pAnsiChar): SteamHandle_t; export; cdecl;
function SteamLog(hContext: SteamHandle_t; cszMsg: pAnsiChar): int; export; cdecl;
procedure SteamLogResourceLoadStarted(cszMsg: pAnsiChar); export; cdecl;
procedure SteamLogResourceLoadFinished(cszMsg: pAnsiChar); export; cdecl;

implementation

function SteamCreateLogContext(cszName: pAnsiChar): SteamHandle_t; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_LOGING then
    Log('SteamCreateLogContext: "'+cszName+'"'+#13#10);   
{$ENDIF}
  result:=1;
end;

function SteamLog(hContext: SteamHandle_t; cszMsg: pAnsiChar): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_LOGING then
    Log('SteamLog: "'+cszMsg+'"'+#13#10);  
{$ENDIF}
  result:=1;
end;

procedure SteamLogResourceLoadStarted(cszMsg: pAnsiChar); export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_LOGING then
    Log('SteamLogResourceLoadStarted: "'+cszMsg+'"'+#13#10); 
{$ENDIF}
end;

procedure SteamLogResourceLoadFinished(cszMsg: pAnsiChar); export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_LOGING then
    Log('SteamLogResourceLoadFinished: "'+cszMsg+'"'+#13#10);    
{$ENDIF}
end;

end.
