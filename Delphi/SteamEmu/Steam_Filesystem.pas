unit Steam_Filesystem;

interface  

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils, FileSystem,
    utils, SteamTypes, Steam_Misc;

function SteamMountAppFilesystem(pError: PSteamError): int; export; cdecl;
function SteamUnmountAppFilesystem(pError: PSteamError): int; export; cdecl;
function SteamMountFilesystem(uAppId: uint; szMountPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
function SteamUnmountFilesystem(uAppId: uint32; pError: PSteamError): int; export; cdecl;
function SteamOpenFileEx(const szFileName, szMode: pAnsiChar; Size: puint; pError: pSteamError): SteamHandle_t; export; cdecl;
function SteamOpenFile(cszFileName, cszMode: pAnsiChar; pError: PSteamError): SteamHandle_t; export; cdecl;
function SteamOpenFile64(cszFileName, cszMode: pAnsiChar; pError: PSteamError): SteamHandle_t; export; cdecl;
function SteamOpenTmpFile(pError: PSteamError): SteamHandle_t; export; cdecl;
function SteamFlushFile(hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
function SteamCloseFile(hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
function SteamSetvBuf(hFile: SteamHandle_t; pBuf: Pointer; eMethod: ESteamBufferMethod; uBytes: uint; pError: PSteamError): int; export; cdecl;
function SteamGetc(hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
function SteamPutc(cChar: int; hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
function SteamPrintFile(hFile: SteamHandle_t; pError: PSteamError; cszFormat: pAnsiChar; param: array of const): int; export; cdecl;
function SteamReadFile(pBuf: PByte; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint; export; cdecl;
function SteamWriteFile(pBuf: Pointer; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint; export; cdecl;
function SteamSeekFile(hFile: SteamHandle_t; lOffset: ulong; esMethod: ESteamSeekMethod; pError: PSteamError): int; export; cdecl;
{}procedure SteamSeekFile64; export; cdecl;
function SteamSizeFile(hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
function SteamSizeFile64(hFile: SteamHandle_t; pError: PSteamError): uint32; export; cdecl;
function SteamTellFile(hFile: SteamHandle_t; pError: PSteamError): uint32; export; cdecl;
{}procedure SteamTellFile64; export; cdecl;
function SteamStat(cszFileName: pAnsiChar; pInfo: PSteamElemInfo; pError: PSteamError): int; export; cdecl;
{}procedure SteamStat64; export; cdecl;
function SteamFindClose(hFind: SteamHandle_t; pError: PSteamError): int; export; cdecl;
function SteamFindFirst(cszPattern: pAnsiChar; eFilter: ESteamFindFilter; pFindInfo: PSteamElemInfo; pError: PSteamError): SteamHandle_t; export; cdecl;
function SteamFindFirst64(cszPattern: pAnsiChar; eFilter: ESteamFindFilter; pFindInfo: PSteamElemInfo; pError: PSteamError): SteamHandle_t; export; cdecl;
function SteamFindNext(hFind: SteamHandle_t; pFindInfo: PSteamElemInfo; pError: PSteamError): int; export; cdecl;
function SteamFindNext64(hFind: SteamHandle_t; pFindInfo: PSteamElemInfo; pError: PSteamError): int; export; cdecl;
function SteamGetLocalFileCopy(cszFileName: pAnsiChar; pError: PSteamError): int; export; cdecl;
function SteamIsFileImmediatelyAvailable(cszName: pAnsiChar; pError: PSteamError): int; export; cdecl;
function SteamHintResourceNeed(cszHintList: pAnsiChar; bForgetEverything: int; pError: PSteamError): int; export; cdecl;
function SteamForgetAllHints(cszMountPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
function SteamPauseCachePreloading(cszMountPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
function SteamResumeCachePreloading(cszMountPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
function SteamWaitForResources(cszMasterList: pAnsiChar; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamFlushCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamGetCacheDecryptionKey(uAppId: uint32; szCacheDecryptionKey: pAnsiChar; uBufferLength: uint32; puRecievedLength: puint32; pError: pSteamError): int; export; cdecl;
function SteamGetCacheDefaultDirectory(szPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
function SteamSetCacheDefaultDirectory(szPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
function SteamGetCacheFilePath(uAppId: uint32; szFilePath: pAnsiChar; uBufferLength: uint32; puRecievedLength: puint32; pError: pSteamError): int; export; cdecl;
function SteamIsFileNeededByCache(uAppId: uint32; cszFileName: pAnsiChar; uArg3: uint32; pError: pSteamError): int; export; cdecl;
function SteamRepairOrDecryptCaches(uAppId: uint32; iArg2: int; pError: pSteamError): int; export; cdecl;
function SteamCreateCachePreloaders(pError: PSteamError): int; export; cdecl;
function SteamIsCacheLoadingEnabled(uAppId: uint; pbIsLoading: pint; pError: PSteamError): int; export; cdecl;
function SteamLoadCacheFromDir(uAppId: uint; szPath: pAnsiChar; pError: PSteamError): SteamCallHandle_t; export; cdecl;
{}procedure SteamLoadFileToApp; export; cdecl;
function SteamLoadFileToCache(uArg1: uint32; cszArg2: pAnsiChar; pcvArg3: Pointer; uArg4, uArg5: uint32; pError: pSteamError): int; export; cdecl;
function SteamStartLoadingCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
function SteamStopLoadingCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;

implementation

function SteamMountAppFilesystem(pError: PSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    Log('SteamMountAppFilesystem'+#13#10);
{$ENDIF}

  result:=integer(true);
end;

function SteamUnmountAppFilesystem(pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    Log('SteamUnmountAppFilesystem'+#13#10);  
{$ENDIF}

  result:=1;
end;

function SteamMountFilesystem(uAppId: uint; szMountPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    Log('SteamMountFilesystem (AppId: '+Int2Str(uAppId)+'; path: '+Ansi2Wide(szMountPath)+#13#10);
{$ENDIF}

  result:=1;
end;

function SteamUnmountFilesystem(uAppId: uint32; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamUnmountFilesystem'+#13#10);   
{$ENDIF}

  result:=1;
end;

function SteamOpenFileEx(const szFileName, szMode: pAnsiChar; Size: puint; pError: pSteamError): SteamHandle_t; export; cdecl;
begin       (*
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamOpenFileEx: FileName = '+Ansi2Wide(szFileName)+' ; FileMode = '+Ansi2Wide(szMode)+#13#10);
{$ENDIF}     *)

  result:=FS.OpenFileEx(Ansi2Wide(szFileName), Ansi2Wide(szMode), Size, pError);
end;

function SteamOpenFile(cszFileName, cszMode: pAnsiChar; pError: PSteamError): SteamHandle_t; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamOpenFile: FileName = '+Ansi2Wide(cszFileName)+#13#10);
{$ENDIF}

  result:=SteamOpenFileEx(cszFileName, cszMode, nil, pError);
end;

function SteamOpenFile64(cszFileName, cszMode: pAnsiChar; pError: PSteamError): SteamHandle_t export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamOpenFile64'+#13#10);  
{$ENDIF}
  result:=SteamOpenFileEx(cszFileName, cszMode, nil, pError)
end;

function SteamOpenTmpFile(pError: PSteamError): SteamHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamOpenTmpFile'+#13#10);  
{$ENDIF}
    
  result:=0;
end;

function SteamFlushFile(hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamFlushFile'+#13#10);  
{$ENDIF}

  result:=FS.FlushFile(hFile, pError);
end;

function SteamCloseFile(hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamCloseFile : '+Int2Str(hFile)+#13#10); 
{$ENDIF}

  result:=FS.CloseFile(hFile, pError);
end;

function SteamSetvBuf(hFile: SteamHandle_t; pBuf: Pointer; eMethod: ESteamBufferMethod; uBytes: uint; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamSetvBuf'+#13#10);  
{$ENDIF}

  result:=1;
end;

function SteamGetc(hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamGetc'+#13#10);   
{$ENDIF}

  result:=1;
end;

function SteamPutc(cChar: int; hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
begin    
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamPutc'+#13#10); 
{$ENDIF}

  result:=1;
end;

function SteamPrintFile(hFile: SteamHandle_t; pError: PSteamError; cszFormat: pAnsiChar; param: array of const): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamPrintFile'+#13#10);     
{$ENDIF}

  result:=1;
end;

function SteamReadFile(pBuf: PByte; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamReadFile ('+Int2Str(hFile)+'): Size = '+Int2Str(uSize)+' ; Count = '+Int2Str(uCount)+#13#10);
{$ENDIF}

  SteamClearError(pError);
  result:=TStream(hFile).Read(pBuf^, uSize*uCount);
  //result:=FS.ReadFile(pBuf, uSize, uCount, hFile, pError);
end;

function SteamWriteFile(pBuf: Pointer; uSize, uCount: uint; hFile: SteamHandle_t; pError: PSteamError): uint; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamWriteFile ('+Int2Str(hFile)+'): Size = '+Int2Str(uSize)+' ; Count = '+Int2Str(uCount)+#13#10);
{$ENDIF}

  //result:=FS.WriteFile(pBuf, uSize, uCount, hFile, pError);
  SteamClearError(pError);
  result:=TStream(hFile).Write(pBuf^, uSize*uCount);
end;

function SteamSeekFile(hFile: SteamHandle_t; lOffset: ulong; esMethod: ESteamSeekMethod; pError: PSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
  begin
    log('SteamSeekFile ('+Int2Str(hFile)+'): Offset = '+Int2Str(lOffset)+' ; Method = ');
    case esMethod of
      eSteamSeekMethodSet: Log('eSteamSeekMethodSet');
      eSteamSeekMethodCur: Log('eSteamSeekMethodCur');
      eSteamSeekMethodEnd: Log('eSteamSeekMethodEnd');
    end;
    Log(#13#10);
  end;
{$ENDIF}

  SteamClearError(pError);
  result:=TStream(hFile).Seek(lOffset, TMoveMethod(esMethod));
  //result:=FS.SeekFile(hFile, lOffset, esMethod, pError);
end;

procedure SteamSeekFile64; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamSeekFile64'+#13#10);
{$ENDIF}
end;

function SteamSizeFile(hFile: SteamHandle_t; pError: PSteamError): int; export; cdecl;
begin
  //result:=FS.SizeFile(hFile, pError);
  SteamClearError(pError);
  result:=TStream(hFile).Size;

{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamSizeFile ('+Int2Str(hFile)+'): Size = '+Int2Str(result)+#13#10);
{$ENDIF}
end;

function SteamSizeFile64(hFile: SteamHandle_t; pError: PSteamError): uint32 export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamSizeFile64'+#13#10); 
{$ENDIF}
  result:=SteamSizeFile(hFile, pError);
end;

function SteamTellFile(hFile: SteamHandle_t; pError: PSteamError): uint32; export; cdecl;
begin
  //result:=FS.TellFile(hFile, pError);
  SteamClearError(pError);
  result:=TStream(hFile).Position;

{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamTellFile ('+Int2Str(hFile)+') : Position = '+Int2Str(result)+#13#10);
{$ENDIF}
end;

procedure SteamTellFile64; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamTellFile64'+#13#10);   
{$ENDIF}
end;

function SteamStat(cszFileName: pAnsiChar; pInfo: PSteamElemInfo; pError: PSteamError): int; export; cdecl;
begin                (*
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamStat: '+cszFileName);
{$ENDIF}
                *)
  result:=FS.Stat(Ansi2Wide(cszFileName), pInfo, pError);
  SteamClearError(pError);
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamStat: '+Int2Str(result)+#13#10);
{$ENDIF}
end;

procedure SteamStat64; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    Log('SteamStat64'+#13#10);
{$ENDIF}
end;

function SteamFindClose(hFind: SteamHandle_t; pError: PSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamFindClose'+#13#10);     
{$ENDIF}

  result:=FS.FindClose(hFind, pError);
end;

function SteamFindFirst(cszPattern: pAnsiChar; eFilter: ESteamFindFilter; pFindInfo: PSteamElemInfo; pError: PSteamError): SteamHandle_t; export; cdecl;
begin     (*
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamFindFirst: '+cszPattern+#13#10);
{$ENDIF}   *)

  result:=FS.FindFirst(Ansi2Wide(cszPattern), eFilter, pFindInfo, pError);
end;

function SteamFindFirst64(cszPattern: pAnsiChar; eFilter: ESteamFindFilter; pFindInfo: PSteamElemInfo; pError: PSteamError): SteamHandle_t; export; cdecl;
begin     
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamFindFirst64'+#13#10);
{$ENDIF}
  result:=SteamFindFirst(cszPattern, eFilter, pFindInfo, pError);
end;

function SteamFindNext(hFind: SteamHandle_t; pFindInfo: PSteamElemInfo; pError: PSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamFindNext'+#13#10);
{$ENDIF}

  result:=FS.FindNext(hFind, pFindInfo, pError);
end;

function SteamFindNext64(hFind: SteamHandle_t; pFindInfo: PSteamElemInfo; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamFindNext64'+#13#10);
{$ENDIF}
  result:=SteamFindNext(hFind, pFindInfo, pError);
end;

function SteamGetLocalFileCopy(cszFileName: pAnsiChar; pError: PSteamError): int; export; cdecl;
begin     (*
{$IFDEF LOGING}
  if LOGING_FILESYSTEM_ALL then
    log('SteamGetLocalFileCopy: FileName = '+cszFileName+#13#10);
{$ENDIF}     *)

  result:=FS.GetLocalFileCopy(Ansi2Wide(cszFileName), pError);
end;

function SteamIsFileImmediatelyAvailable(cszName: pAnsiChar; pError: PSteamError): int; export; cdecl;
begin     
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamIsFileImmediatelyAvailable'+#13#10);   
{$ENDIF}

  SteamClearError(pError);
  result:=0;
  if FileExists(Ansi2Wide(cszName)) then
    result:=1;
end;

function SteamHintResourceNeed(cszHintList: pAnsiChar; bForgetEverything: int; pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamHintResourceNeed: '+cszHintList+#13#10);     
{$ENDIF}

  result:=0;
end;

function SteamForgetAllHints(cszMountPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamForgetAllHints'+#13#10); 
{$ENDIF}

  result:=1;  
end;

function SteamPauseCachePreloading(cszMountPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamPauseCachePreloading'+#13#10);  
{$ENDIF}

  result:=1;
end;

function SteamResumeCachePreloading(cszMountPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
begin   
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamResumeCachePreloading'+#13#10); 
{$ENDIF}
    
  result:=1;
end;

function SteamWaitForResources(cszMasterList: pAnsiChar; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamWaitForResources: MasterList = '+cszMasterList+#13#10);  
{$ENDIF}

  result:=1;
end;

function SteamFlushCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamFlushCache'+#13#10); 
{$ENDIF}

  result:=1;
end;

function SteamGetCacheDecryptionKey(uAppId: uint32; szCacheDecryptionKey: pAnsiChar; uBufferLength: uint32; puRecievedLength: puint32; pError: pSteamError): int; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamGetCacheDecryptionKey'+#13#10);  
{$ENDIF}

  result:=1;
end;

function SteamGetCacheDefaultDirectory(szPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamGetCacheDefaultDirectory'+#13#10);  
{$ENDIF}

  result:=FS.GetCacheDefaultDirectory(Ansi2Wide(szPath), pError);
end;

function SteamSetCacheDefaultDirectory(szPath: pAnsiChar; pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamSetCacheDefaultDirectory: Path = '+szPath+#13#10);  
{$ENDIF}

  result:=FS.SetCacheDefaultDirectory(Ansi2Wide(szPath), pError);
end;

function SteamGetCacheFilePath(uAppId: uint32; szFilePath: pAnsiChar; uBufferLength: uint32; puRecievedLength: puint32; pError: pSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamGetCacheFilePath'+#13#10);  
{$ENDIF}

  result:=1;
end;

function SteamIsFileNeededByCache(uAppId: uint32; cszFileName: pAnsiChar; uArg3: uint32; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamIsFileNeededByCache'+#13#10);   
{$ENDIF}

  result:=1;
end;

function SteamRepairOrDecryptCaches(uAppId: uint32; iArg2: int; pError: pSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamRepairOrDecryptCaches'+#13#10); 
{$ENDIF}

  result:=1;
end;

function SteamCreateCachePreloaders(pError: PSteamError): int; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamCreateCachePreloaders'+#13#10); 
{$ENDIF}

  SteamClearError(pError);
  result:=1;
end;

function SteamIsCacheLoadingEnabled(uAppId: uint; pbIsLoading: pint; pError: PSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamIsCacheLoadingEnabled'+#13#10);   
{$ENDIF}

  SteamClearError(pError);
  pbIsLoading^:=1;
  result:=1;
end;

function SteamLoadCacheFromDir(uAppId: uint; szPath: pAnsiChar; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamLoadCacheFromDir'+#13#10);    
{$ENDIF}
    
  result:=1;
end;

procedure SteamLoadFileToApp; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamLoadFileToApp'+#13#10);  
{$ENDIF}

end;

function SteamLoadFileToCache(uArg1: uint32; cszArg2: pAnsiChar; pcvArg3: Pointer; uArg4, uArg5: uint32; pError: pSteamError): int; export; cdecl;
begin  
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamLoadFileToCache'+#13#10); 
{$ENDIF}

  result:=1;
end;

function SteamStartLoadingCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin 
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamStartLoadingCache'+#13#10);    
{$ENDIF}

  SteamClearError(pError);
  result:=1;
end;

function SteamStopLoadingCache(uAppId: uint; pError: PSteamError): SteamCallHandle_t; export; cdecl;
begin
{$IFDEF LOGING}
  if LOGING_FILESYSTEM then
    log('SteamStopLoadingCache'+#13#10);
{$ENDIF}

  SteamClearError(pError);
  result:=1;
end;

end.
