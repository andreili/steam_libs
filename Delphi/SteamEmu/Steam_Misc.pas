unit Steam_Misc;

interface   

{$I defines.inc}

uses
  Windows,
    utils, SteamTypes;

procedure SteamClearError(pError: PSteamError); export; cdecl;

function InternalSteamNumClientsConnectedToEngine(pError: PSteamError): int; export; cdecl;
function InternalSteamShouldShutdownEngine2: int; export; cdecl;

function SteamChangeOfflineStatus(pSteamOfflineStatus: pSteamOfflineStatus; pError: pSteamError): int; export; cdecl;
function SteamGetOfflineStatus(buIsOffline: pint; pError: PSteamError): int; export; cdecl;

function SteamUninstall(pError: PSteamError): SteamCallHandle_t; export; cdecl;

function SteamWeakVerifyNewValveCDKey: int; export; cdecl;
function SteamGetEncryptedNewValveCDKey(cszValveCDkey: pAnsiChar; pnGameCode: pint; puTerritoryCode: puint32;
  pUniqueSerialNumber: Pointer): int; export; cdecl;

function SteamDecryptDataForThisMachine(pEncryptedData: puint8; uEncryptedDataSize: uint32;
  pDecryptedBuffer: puint8; uDecryptedBufferSize: uint32; puDecryptedDataSize: puint32): ESteamError; export; cdecl;
function SteamEncryptDataForThisMachine(pPlaintextData: puint8; uPlaintextDataSize: uint32;
  pEncryptedBuffer: puint8; uEncryptedBufferSize: uint32; puEncryptedDataSize: puint32): ESteamError; export; cdecl;

function SteamFindServersGetErrorString: int; export; cdecl;
function SteamFindServersIterateServer(SteamServerType: ESteamServerType; uIndex: uint32;
  szServerAddress: pAnsiChar; uServerAddressChars: uint32): int32; export; cdecl;
function SteamFindServersNumServers(SteamServerType: ESteamServerType): int; export; cdecl;

function SteamGetContentServerInfo(uArg1: uint32; puArg2, puArg3: puint32; pError: pSteamError): int; export; cdecl;

function SteamRefreshMinimumFootprintFiles: int; export; cdecl;
function SteamSetNotificationCallback(pCallbackFunction: SteamNotificationCallback_t; pError: PSteamError): int; export; cdecl;

function SteamGetCachePercentFragmentation(uAppId: uint32; puPercentFragmented: puint32; pError: pSteamError): int; export; cdecl;
function SteamGetAppDLCStatus(a, b, c, d: int): int; export; cdecl;

function SteamIsUsingSdkContentServer(unknown: int; pError: pSteamError): int; export; cdecl;

function SteamIsFileNeededByApp(uAppId: uint32; cszFileName: pAnsiChar; uArg1: uint32; puArg2: puint32; pError: pSteamError): int; export; cdecl;

procedure SteamWasBlobRegistryDeleted; export; cdecl;

function SteamCheckAppOwnership: int; export; cdecl;

function SteamForceCellId(uCellId: uint32; pError: pSteamError): int; export; cdecl;
function SteamDefragCaches(uAppId: uint32; pError: pSteamError): int; export; cdecl;
function SteamWaitForAppResources(uAppId: uint32; cszMasterList: pAnsiChar; pError: pSteamError): int; export; cdecl;

implementation

procedure SteamClearError(pError: PSteamError); export; cdecl;
begin
  if pError=nil then
    Exit;
  pError^.SteamError:=eSteamErrorNone;
  pError^.DetailedErrorType:=eNoDetailedErrorAvailable;
  pError^.DetailedErrorCode:=0;
  pError^.Desc[0]:=#00;
end;

function InternalSteamNumClientsConnectedToEngine(pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('InternalSteamNumClientsConnectedToEngine'+#13#10);    
{$ENDIF}
  result:=1;
end;

function InternalSteamShouldShutdownEngine2: int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('InternalSteamShouldShutdownEngine2'+#13#10);  
{$ENDIF}
  result:=1;
end;

function SteamGetLocalClientVersion(a1, uSourceControlId: puint; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamGetLocalClientVersion'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamChangeOfflineStatus(pSteamOfflineStatus: pSteamOfflineStatus; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamChangeOfflineStatus'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamGetOfflineStatus(buIsOffline: pint; pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamGetOfflineStatus'+#13#10);
{$ENDIF}
  if buIsOffline<>nil then
    buIsOffline^:=0;
  result:=1;
end;

function SteamUninstall(pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamUninstall'+#13#10);    
{$ENDIF}
  result:=1;
end;

function SteamWeakVerifyNewValveCDKey: int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_MISK then
    log('SteamWeakVerifyNewValveCDKey'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamGetEncryptedNewValveCDKey(cszValveCDkey: pAnsiChar; pnGameCode: pint; puTerritoryCode: puint32;
  pUniqueSerialNumber: Pointer): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_MISK then
    log('SteamGetEncryptedNewValveCDKey'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamDecryptDataForThisMachine(pEncryptedData: puint8; uEncryptedDataSize: uint32;
  pDecryptedBuffer: puint8; uDecryptedBufferSize: uint32; puDecryptedDataSize: puint32): ESteamError; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_MISK then
    log('SteamDecryptDataForThisMachine'+#13#10);  
{$ENDIF}
  result:=eSteamErrorNone;
end;

function SteamEncryptDataForThisMachine(pPlaintextData: puint8; uPlaintextDataSize: uint32;
  pEncryptedBuffer: puint8; uEncryptedBufferSize: uint32; puEncryptedDataSize: puint32): ESteamError; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_MISK then
    log('SteamEncryptDataForThisMachine'+#13#10); 
{$ENDIF}
  result:=eSteamErrorNone;
end;

function SteamFindServersGetErrorString: int; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamFindServersGetErrorString'+#13#10);   
{$ENDIF}
  result:=0;
end;

function SteamFindServersIterateServer(SteamServerType: ESteamServerType; uIndex: uint32;
  szServerAddress: pAnsiChar; uServerAddressChars: uint32): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamFindServersIterateServer'+#13#10);  
{$ENDIF}
  result:=0;
end;

function SteamFindServersNumServers(SteamServerType: ESteamServerType): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamFindServersNumServers'+#13#10); 
{$ENDIF}
  result:=0;
end;  

function SteamGetContentServerInfo(uArg1: uint32; puArg2, puArg3: puint32; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamGetContentServerInfo'+#13#10);  
{$ENDIF}
  result:=0;
end;

function SteamRefreshMinimumFootprintFiles: int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamRefreshMinimumFootprintFiles'+#13#10); 
{$ENDIF}
  result:=1;
end;

function SteamSetNotificationCallback(pCallbackFunction: SteamNotificationCallback_t; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamSetNotificationCallback'+#13#10);    
{$ENDIF}
  result:=1;
end;

function SteamGetCachePercentFragmentation(uAppId: uint32; puPercentFragmented: puint32; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamGetCachePercentFragmentation'+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamGetAppDLCStatus(a, b, c, d: int): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamGetAppDLCStatus'+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamIsUsingSdkContentServer(unknown: int; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamIsUsingSdkContentServer'+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamIsFileNeededByApp(uAppId: uint32; cszFileName: pAnsiChar; uArg1: uint32; puArg2: puint32; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamIsFileNeededByApp'+#13#10);
{$ENDIF}
  result:=1;
end;

procedure SteamWasBlobRegistryDeleted; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamWasBlobRegistryDeleted'+#13#10);
{$ENDIF}
end;

function SteamCheckAppOwnership: int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_MISK then
    Log('SteamCheckAppOwnership'+#13#10);
{$ENDIF}
  result:=1;
end;

function SteamForceCellId(uCellId: uint32; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamForceCellId'+#13#10);
{$ENDIF}

  SteamClearError(pError);
  result:=1;
end;

function SteamDefragCaches(uAppId: uint32; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamDefragCaches'+#13#10);
{$ENDIF}

  SteamClearError(pError);
  result:=1;
end;

function SteamWaitForAppResources(uAppId: uint32; cszMasterList: pAnsiChar; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamWaitForAppResources'+#13#10);
{$ENDIF}

  SteamClearError(pError);
  result:=1;
end;


end.
