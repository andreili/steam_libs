unit SteamWorks;

interface

uses
  SteamTypes, Windows, KOL;

const
  CREATEINTERFACE_PROCNAME: pAnsiChar = 'CreateInterface';
  FACTORY_PROCNAME: pAnsiChar = '_f';

type
  CSteamAPILoader = class
    public
      SteamClientHandle,
      SteamHandle: THandle;

      CallCreateInterface: function(version: pAnsiChar; var returnCode: TSteamError): Pointer; cdecl;
      CallCreateSteamInterface: function(version: pAnsiChar): Pointer; cdecl;
      CallSteamBGetCallback: function(pipe: int; msg: CallbackMsg_t): boolean; cdecl;
      CallSteamFreeLastCallback: function(pipe: int): boolean; cdecl;
    public
      function GetInstallPath(): pAnsiChar;
      function CreateInterface(version: pAnsiChar): Pointer;
      function CreateSteamInterface(version: pAnsiChar): Pointer;
      function GetCallback(pipe: int; var mes: CallbackMsg_t): boolean;
      function FreeLastCallback(pipe:int): boolean;
      function Load(): boolean; overload;
      function Load(steam: boolean): boolean; overload;
      function LoadSteam(): boolean;
      function LoadSteamClient(): boolean;
  end;

function SetDllDirectory(lpPathName: pAnsiChar): Pointer; stdcall; external 'kernel32.dll' name 'SetDllDirectoryA';

implementation

uses
  ClientCommon, ISteamClient006_, ISteamClient008_;

function CSteamAPILoader.GetInstallPath(): pAnsiChar;
var
  hRegKey: HKEY;
  err, dwLength: integer;
  pchSteamDir: array[0..MAX_PATH-1] of AnsiChar;
begin
  err:=RegOpenKeyExA(HKEY_LOCAL_MACHINE, 'Software\Valve\Steam', 0, KEY_QUERY_VALUE, hRegKey);
  result:='';
  if err=ERROR_SUCCESS then
  begin
    dwLength:=sizeof(pchSteamDir);
    RegQueryValueExA(hRegKey, 'InstallPath', nil, nil, @pchSteamDir[0], @dwLength);
    RegCloseKey(hRegKey);
    result:=pchSteamDir;
  end;
end;

function CSteamAPILoader.CreateInterface(version: pAnsiChar): Pointer;
var
  err: TSteamError;
begin
  result:=nil;
  if not Assigned(CallCreateInterface) then
    Exit;
  result:=CallCreateInterface(version, err);
  if StrComp_NoCase(version, STEAMCLIENT_INTERFACE_VERSION_006)=0 then result:=ConverClient006CppToI(result)
    //else if StrComp_NoCase(version, STEAMCLIENT_INTERFACE_VERSION_007)=0 then result:=ConverClient007CppToI(result)
      else if StrComp_NoCase(version, STEAMCLIENT_INTERFACE_VERSION_008)=0 then result:=ConverClient008CppToI(result)
        //else if StrComp_NoCase(version, STEAMCLIENT_INTERFACE_VERSION_009)=0 then result:=ConverClient009CppToI(result);
end;

function CSteamAPILoader.CreateSteamInterface(version: pAnsiChar): Pointer;
begin
  result:=nil;
  if not Assigned(CallCreateSteamInterface) then
    Exit;
  result:=CallCreateSteamInterface(version);
end;

function CSteamAPILoader.GetCallback(pipe: int; var mes: CallbackMsg_t): boolean;
begin
  result:=false;
  if not Assigned(CallSteamBGetCallback) then
    Exit;
  result:=CallSteamBGetCallback(pipe, mes);
end;

function CSteamAPILoader.FreeLastCallback(pipe:int): boolean;
begin
  result:=false;
  if not Assigned(CallSteamFreeLastCallback) then
    Exit;
  result:=CallSteamFreeLastCallback(pipe);
end;

function CSteamAPILoader.Load(): boolean;
begin
  result:=Load(false);
end;

function CSteamAPILoader.Load(steam: boolean): boolean;
begin
  result:=false;
  if (steam) and (not LoadSteam()) then
    Exit;
  result:=LoadSteamClient();
end;

function CSteamAPILoader.LoadSteam(): boolean;
var
  path: pAnsiChar;
begin
  result:=false;

  path:=GetInstallPath();
  SetDllDirectory(pAnsiChar(path+';'+IncludeTrailingPathDelimiter(path)+'bin'));
  path:=pAnsiChar(IncludeTrailingPathDelimiter(path)+'steam.dll');

  SteamHandle:=LoadLibraryExA(path, 0, LOAD_WITH_ALTERED_SEARCH_PATH);
  if SteamHandle=INVALID_HANDLE_VALUE then
    Exit;

  CallCreateSteamInterface:=GetProcAddress(SteamHandle, '_f');
  if not Assigned(CallCreateSteamInterface) then
    Exit;

  result:=true;
end;

function CSteamAPILoader.LoadSteamClient(): boolean;
var
  path: pAnsiChar;
begin
  result:=false;

  path:=GetInstallPath();
  SetDllDirectory(pAnsiChar(path+';'+IncludeTrailingPathDelimiter(path)+'bin'));
  path:=pAnsiChar(IncludeTrailingPathDelimiter(path)+'steamclient.dll');

  SteamClientHandle:=LoadLibraryExA(path, 0, LOAD_WITH_ALTERED_SEARCH_PATH);
  if SteamClientHandle=INVALID_HANDLE_VALUE then
    Exit;

  CallCreateInterface:=GetProcAddress(SteamClientHandle, 'CreateInterface');
  if not Assigned(CallCreateInterface) then
    Exit;
  CallSteamBGetCallback:=GetProcAddress(SteamClientHandle, 'Steam_BGetCallback');
  if not Assigned(CallSteamBGetCallback) then
    Exit;
  CallSteamFreeLastCallback:=GetProcAddress(SteamClientHandle, 'Steam_FreeLastCallback');
  if not Assigned(CallSteamFreeLastCallback) then
    Exit;

  result:=true;
end;

end.
