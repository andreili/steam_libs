unit SL_Mess;

interface

uses
  Windows, Messages, Sockets, SL_Interfaces;

type
  TOnApplicationProc = procedure(App: pClientAppRecord) of object;

  TMess = class (TObject)
    private
      fSock: CSocket;
      fSem: THandle;
    public
      constructor Create(ServerAddr: string; ServerPort: uint16);
      destructor Destroy(); override;
      function GetSettingsValue(ValueID: uint32): pChar;
      procedure SetSettingsValue(ValueID: uint32; Value: pChar);

      procedure GetAppsList(OnApp: TOnApplicationProc);
      function IsAppBusy(AppID: uint32): boolean;
      function GetDetailedAppInfo(AppID: uint32): pDetailedAppInfo;

      procedure ShutdownCore();
  end;

implementation

constructor TMess.Create(ServerAddr: string; ServerPort: uint16);
var
  version: uint32;
  res: boolean;
begin
  fSem:=CreateSemaphore(nil, 1, 1, 'Sem_UI_Socket');
  fSock:=CSocket.Create(SOCKET_TCP);
  if not fSock.Connect(ServerAddr, ServerPort) then
  begin
    halt(2);
  end;
  fSock.Recv(version, 4);
  res:=(version=CORE_VERSION);
  fSock.Send(res, 1);
  if not res then
    halt(3);
end;

destructor TMess.Destroy();
begin
  fSock.Free;
end;

function TMess.GetSettingsValue(ValueID: uint32): pChar;
var
  len: integer;
begin
  result:='';
  if not fSock.Send(MESS_GET_SETTINGS_VALUE, 4) then
    Exit;
  if not fSock.Send(ValueID, 4) then
    Exit;
  if not fSock.Recv(len, 4) then
    Exit;
  GetMem(result, len*sizeof(char));
  if not fSock.Recv(result[0], len*sizeof(char)) then
    Exit;
end;

procedure TMess.SetSettingsValue(ValueID: uint32; Value: pChar);
begin
end;

procedure TMess.GetAppsList(OnApp: TOnApplicationProc);
var
  len, i: integer;
  AppInfo: TClientAppRecord;
begin
  if not fSock.Send(MESS_GET_APPS_LIST, 4) then
    Exit;
  if not fSock.Recv(len, 4) then
    Exit;
  for i:=0 to len-1 do
  begin
    if not fSock.Recv(AppInfo, sizeof(TClientAppRecord)) then
      Exit;
    OnApp(@AppInfo);
  end;
end;

function TMess.IsAppBusy(AppID: uint32): boolean;
begin
  result:=true;
  if not fSock.Send(MESS_GET_IS_APP_BUSY, 4) then
    Exit;
  if not fSock.Send(AppID, 4) then
    Exit;
  if not fSock.Recv(result, 1) then
    Exit;
end;

function TMess.GetDetailedAppInfo(AppID: uint32): pDetailedAppInfo;
begin
  result:=nil;
  if not fSock.Send(MESS_GET_APP_PROPERTIES, 4) then
    Exit;
  if not fSock.Send(AppID, 4) then
    Exit;
  new(result);
  if not fSock.Recv(result^, sizeof(TDetailedAppInfo)) then
    Exit;
end;

procedure TMess.ShutdownCore();
begin
  if not fSock.Send(MESS_SHUTDOWN, 4) then
    Exit;
end;


end.
