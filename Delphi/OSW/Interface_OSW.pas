unit Interface_OSW;

interface

uses
  SteamTypes, Win32Library, Windows;

const
  CREATEINTERFACE_PROCNAME: pAnsiChar = 'CreateInterface';
  FACTORY_PROCNAME: pAnsiChar = '_f';

type
  CSteamAPILoader = class
    public
      constructor Create();
      function Load(): CreateInterfaceFn;
      function LoadFactory(): FactoryFn;
      function GetSteamDir(): pAnsiChar;
      function GetSteamClientModule(): pDynamicLibrary;
      function GetSteamModule(): pDynamicLibrary;
    private
      procedure TryGetSteamDir();
      procedure TryLoadLibraries();
    private
      m_steamDir: pAnsiChar;
      m_steamclient,
      m_steam: DynamicLibrary;
  end;

implementation

constructor CSteamAPILoader.Create();
begin
  TryGetSteamDir();
  TryLoadLibraries();
end;

function CSteamAPILoader.Load(): CreateInterfaceFn;
begin
  result:=m_steamclient.GetSymbol(CREATEINTERFACE_PROCNAME);
end;

function CSteamAPILoader.LoadFactory(): FactoryFn;
begin
  result:=m_steam.GetSymbol(FACTORY_PROCNAME);
end;

function CSteamAPILoader.GetSteamDir(): pAnsiChar;
begin
  result:=m_steamDir;
end;

function CSteamAPILoader.GetSteamClientModule(): pDynamicLibrary;
begin
  result:=@m_steamclient;
end;

function CSteamAPILoader.GetSteamModule(): pDynamicLibrary;
begin
  result:=@m_steam;
end;

procedure CSteamAPILoader.TryGetSteamDir();
var
  hRegKey: HKEY;
  err, dwLength: integer;
  pchSteamDir: array[0..MAX_PATH-1] of AnsiChar;
begin
  err:=RegOpenKeyExA(HKEY_LOCAL_MACHINE, 'Software\Valve\Steam', 0, KEY_QUERY_VALUE, hRegKey);
  if err=ERROR_SUCCESS then
  begin
    dwLength:=sizeof(pchSteamDir);
    RegQueryValueExA(hRegKey, 'InstallPath', nil, nil, @pchSteamDir[0], @dwLength);
    RegCloseKey(hRegKey);
    m_steamDir:=pchSteamDir;
  end;
end;

procedure CSteamAPILoader.TryLoadLibraries();
begin
  // steamclient.dll expects to be able to load tier0_s without an absolute
  // path, so we'll need to add the steam dir to the search path.
  m_steamclient:=DynamicLibrary.Create(pAnsiChar(m_steamDir+'\steamclient.dll'));
  m_steam:=DynamicLibrary.Create(pAnsiChar(m_steamDir+'\steam.dll'));
end;

end.
