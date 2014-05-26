unit Steam_Init;

interface

{$I defines.inc}

uses
  Windows, USE_Types,
    utils, SteamTypes, Steam_Misc;

function SteamStartEngine(var Error: TSteamError): int; export; cdecl;
function SteamStartup(uUsingMask: uint; pError: PSteamError): int; export; cdecl;

function SteamGetVersion(szVersion: pAnsiChar; uVersionBufSize: uint): int; export; cdecl;
function SteamGetLocalClientVersion(a1, uSourceControlId: puint; pError: pSteamError): int; export; cdecl;

function SteamCleanup(pError: PSteamError): int; export; cdecl;
function SteamShutdownEngine(pError: PSteamError): int; export; cdecl;

implementation

function SteamStartEngine(var Error: TSteamError): int;
begin
{$IFDEF LOGING}
  if LOGING_INIT then
    Log('SteamStartEngine'+#13#10)
{$ENDIF};
  SteamClearError(@Error);
  result:=1;
end;

function SteamStartup(uUsingMask: uint; pError: PSteamError): int;
begin
{$IFDEF LOGING}
  if LOGING_INIT then
    Log('SteamStartup: ');
  if uUsingMask and STEAM_USING_FILESYSTEM<>0 then Log(' FileSystem');
  if uUsingMask and STEAM_USING_LOGGING<>0 then Log(' Logging');
  if uUsingMask and STEAM_USING_USERID<>0 then Log(' UserID');
  if uUsingMask and STEAM_USING_ACCOUNT<>0 then Log(' Account');
  Log(#13#10);
{$ENDIF}

  SteamClearError(pError);
  result:=1;
end;

function SteamGetVersion(szVersion: pAnsiChar; uVersionBufSize: uint): int;
begin
{$IFDEF LOGING}
  if LOGING_INIT then
    Log('SteamGetVersion'+#13#10);
{$ENDIF}
  result:=0;
end;

function SteamGetLocalClientVersion(a1, uSourceControlId: puint; pError: pSteamError): int;
begin
{$IFDEF LOGING}
  if LOGING_INIT then
    Log('SteamGetLocalClientVersion'+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamCleanup(pError: PSteamError): int;
begin
{$IFDEF LOGING}
  if LOGING_INIT then
    Log('SteamCleanup'+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamShutdownEngine(pError: PSteamError): int;
begin
{$IFDEF LOGING}
  if LOGING_INIT then
    Log('SteamShutdownEngine'+#13#10);
{$ENDIF}
  result:=1;
end;

end.
