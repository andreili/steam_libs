unit Int_Core;

interface

uses
  Windows, Messages, SL_Interfaces, Sockets, USE_Utils;

type
  CCore = class (TObject)
    Log: ILog;
    Utils: IUtils;
    Translation: ITranslation;
    Settings: ISettings;
    UI: IUserInterface;
    ApplicationsList: IApplicationsList;
    WorksList: IWorksList;
    Network: INetwork;
    P2P: IP2P;
    Files: IFileFormats;
    Converter: IGameConverter;
    fSock: CSocket;

    destructor Destroy(); override;
    procedure Start(); virtual; stdcall;
  private
    procedure ClientProc(Socket: CSocket);
    procedure SendSettingsValue(Socket: CSocket);
    procedure SendAppsList(Socket: CSocket);
    procedure SendIsAppBusy(Socket: CSocket);
    procedure SendAppProperties(Socket: CSocket; IsCache: boolean);
    procedure SendWorkState(Socket: CSocket);
    procedure WorkAdd(Socket: CSocket);
    procedure WorkPause(Socket: CSocket);
    procedure WorkResume(Socket: CSocket);
    procedure WorkStop(Socket: CSocket);
    //procedure Send(Socket: CSocket);
  end;

  TLoadInterface = function(_Core: CCore): ISLInterface; stdcall;

function LoadCore(): boolean;

implementation

//{$IFDEF SL_ONE}
uses
  Int_Log, Int_Translation, Int_Settings, Int_Utils, Int_Applications, Int_ApplicationsList, Int_FileFormats,
  Int_GameConverter, Int_Network, Int_p2p,
  Int_Works, Int_UI;
//{$ENDIF}

function LoadCore(): boolean;
begin
  result:=false;
  Core:=ICore(CCore.Create());
  Core.Start();
end;

destructor CCore.Destroy();
begin
  if (Log<>nil) then Log.AddEvent('Shut down.');
  if (Log<>nil) then Log.DeInit;
  if (Translation<>nil) then Translation.DeInit;
  if (Settings<>nil) then Settings.DeInit;
  if (Utils<>nil) then Utils.DeInit;
  if (ApplicationsList<>nil) then ApplicationsList.DeInit;
  if (WorksList<>nil) then WorksList.DeInit;
  if (Network<>nil) then Network.DeInit;
  if (P2P<>nil) then P2P.DeInit;
  if (Files<>nil) then Files.DeInit;
  if (Converter<>nil) then Converter.DeInit;
end;

procedure CCore.Start();
begin
 // {$IFDEF SL_ONE}
  Log:=Int_Log.LoadInterface();
  Settings:=Int_Settings.LoadInterface();
  Translation:=Int_Translation.LoadInterface();
  Utils:=Int_Utils.LoadInterface();
  UI:=int_UI.LoadInterface();
  Files:=Int_FileFormats.LoadInterface();
  ApplicationsList:=Int_ApplicationsList.LoadInterface();
  WorksList:=Int_Works.LoadInterface();
  //////////////Core.Network:=Int_Network.LoadInterface();
  //////////////Core.P2P:=Int_p2p.LoadInterface();
  Core.Converter:=Int_GameConverter.LoadInterface();
  //{$ENDIF}

  if (Log<>nil) then Log.Init;
  if (Settings<>nil) then Settings.Init;
  if (Translation<>nil) then Translation.Init;
  if (Utils<>nil) then Utils.Init;
  if (Files<>nil) then Files.Init;
  if (WorksList<>nil) then WorksList.Init;
  if (Network<>nil) then Network.Init;
  if (P2P<>nil) then P2P.Init;
  if (ApplicationsList<>nil) then ApplicationsList.Init;
  if (Converter<>nil) then Converter.Init;

  if (Log<>nil) then Log.AddEvent('Start Up.');
  //WorksList.AddWork(WORK_LOAD_CORE, nil);

  {fSock:=CSocket.Create(SOCKET_TCP);
  fSock.Bind('0.0.0.0', 27050);
  fSock.OnClientConnected:=ClientProc;
  fSock.Listen();
  fSock.Accept(); }
end;

procedure CCore.ClientProc(Socket: CSocket);
var
  res: boolean;
  LogIdx, OpCode: uint32;
begin
  LogIdx:=Log.AddEvent(Translation.GetTitle(pChar('#ClientConnected'+' '+Socket.GetRemoteAddr())));
  Socket.Send(CORE_VERSION, 4);
  Socket.Recv(res, 1);
  if not res then
  begin
    Log.SetEventResult(LogIdx, '#IncorrectVersion');
    Exit;
  end;
  while true do
  begin
    if not Socket.Recv(OpCode, 4) then
      break;
    if (OpCode=MESS_GET_SETTINGS_VALUE) then SendSettingsValue(Socket)
    else if (OpCode=MESS_GET_APPS_LIST) then SendAppsList(Socket)
    else if (OpCode=MESS_GET_IS_APP_BUSY) then SendIsAppBusy(Socket)
    else if (OpCode=MESS_GET_APP_PROPERTIES) then SendAppProperties(Socket, false)
    else if (OpCode=MESS_GET_CACHE_PROPERTIES) then SendAppProperties(Socket, true)
    else if (OpCode=MESS_WORK_GET_STATE) then SendWorkState(Socket)
    else if (OpCode=MESS_WORK_ADD) then WorkAdd(Socket)
    else if (OpCode=MESS_WORK_PAUSE) then WorkPause(Socket)
    else if (OpCode=MESS_WORK_STOP) then WorkStop(Socket)
    else if (OpCode=MESS_WORK_RESUME) then WorkResume(Socket)
    else if (OpCode=MESS_SHUTDOWN) then
    begin
      self.fSock.Free;
      break;
    end
  end;
end;

procedure CCore.SendSettingsValue(Socket: CSocket);
var
  code, len: uint32;
  str: string;
begin
  if not Socket.Recv(code, 4) then
    Exit;
  str:=Settings.GetStringValue(code);
  len:=length(str);
  Socket.Send(len, 4);
  Socket.Send(str[1], len*sizeof(char));
  str:='';
end;

procedure CCore.SendAppsList(Socket: CSocket);
var
  len, i: integer;
  pc: pChar;
  App: IApplication;
  AppInfo: TClientAppRecord;
begin
  len:=ApplicationsList.GetAppsCount();
  Socket.Send(len, 4);
  for i:=0 to len-1 do
  begin
    FillChar(AppInfo.Name, length(AppInfo.Name)*sizeof(char), 0);
    FillChar(AppInfo.Developer, length(AppInfo.Developer)*sizeof(char), 0);

    App:=ApplicationsList.GetApplicationByIdx(i);
    AppInfo.AppType:=App.GetAppType();
    AppInfo.IsLoaded:=App.IsLoaded();
    pc:=App.GetName();
    Move(pc[0], AppInfo.Name[0], length(pc)*sizeof(char));
    pc:=App.GetFolderName();
    Move(pc[0], AppInfo.CommonPath[0], length(pc)*sizeof(char));
    pc:=pChar(Ansi2Wide(App.GetUserDefinedRecord('developer')));
    Move(pc[0], AppInfo.Developer[0], length(pc)*sizeof(char));
    AppInfo.AppID:=App.GetAppID();
    AppInfo.AppVersion:=App.GetVersion();
    AppInfo.AppSize:=App.GetSize();
    AppInfo.Complention:=App.GetCompletion();
    Socket.Send(AppInfo, sizeof(TClientAppRecord));
  end;
end;

procedure CCore.SendIsAppBusy(Socket: CSocket);
var
  AppID: uint32;
  App: IApplication;
  res: boolean;
begin
  if not Socket.Recv(AppID, 4) then
    Exit;
  App:=ApplicationsList.GetApplication(AppID);
  // если приложение существует
  if (App<>nil) then
  begin
    res:=(App.GetWork()<>nil);
    Socket.Send(res, 1);
  end
    else
  begin
    res:=true;
    Socket.Send(res, 1);
  end;
end;

procedure CCore.SendAppProperties(Socket: CSocket; IsCache: boolean);
var
  AppID, i: uint32;
  App: IApplication;
  AppInfoEx: TDetailedAppInfo;
  Caches: TCachesArray;
  pc: pChar;

  procedure SetAppInfo(App: IApplication; rec: pClientAppRecord);
  begin
    FillChar(rec^, sizeof(TClientAppRecord), 0);
    rec^.AppType:=App.GetAppType();
    rec^.IsLoaded:=App.IsLoaded();
    pc:=App.GetName();
    Move(pc[0], rec^.Name[0], length(pc)*sizeof(char));
    rec^.Name[length(pc)]:=#0;
    pc:=App.GetFolderName();
    Move(pc[0], rec^.CommonPath[0], length(pc)*sizeof(char));
    rec^.CommonPath[length(pc)]:=#0;
    pc:=pChar(Ansi2Wide(App.GetUserDefinedRecord('developer')));
    Move(pc[0], rec^.Developer[0], length(pc)*sizeof(char));
    rec^.Developer[length(pc)]:=#0;
    rec^.AppID:=App.GetAppID();
    rec^.AppVersion:=App.GetVersion();
    rec^.AppSize:=App.GetSize();
    rec^.Complention:=App.GetCompletion();
  end;
begin
  if not Socket.Recv(AppID, 4) then
    Exit;
  if IsCache then App:=ApplicationsList.GetCache(AppID)
    else App:=ApplicationsList.GetApplication(AppID);
  FillChar(AppInfoEx, sizeof(TDetailedAppInfo), 0);
  if App<>nil then
  begin
    SetAppInfo(App, @AppInfoEx.BaseInfo);

    pc:=pChar(Ansi2Wide(App.GetUserDefinedRecord('homepage')));
    Move(pc[0], AppInfoEx.HomePage[0], length(pc)*sizeof(char));

    Caches:=App.GetCaches();
    AppInfoEx.CachesCount:=Length(Caches);
    for i:=0 to AppInfoEx.CachesCount-1 do
      if (Caches[i]<>nil) then
        SetAppInfo(Caches[i], @AppInfoEx.Caches[i]);

    AppInfoEx.UDRCount:=0;
  end;
  Socket.Send(AppInfoEx, sizeof(TDetailedAppInfo));
end;

procedure CCore.SendWorkState(Socket: CSocket);
var
  WorkID: uint32;
  state: TWorkState;
begin
  if not Socket.Recv(WorkID, 4) then
    Exit;
  state:=WorksList.GetWorkState(WorkID);
  Socket.Send(state, sizeof(TWorkState));
end;

procedure CCore.WorkAdd(Socket: CSocket);
var
  IsCache: boolean;
  WorkID, AppID: uint32;
  work: EWorkType;
  app: IApplication;
begin
  if not Socket.Recv(WorkID, 4) then
    Exit;
  if not Socket.Recv(work, sizeof(EWorkType)) then
    Exit;
  if not Socket.Recv(AppID, 4) then
    Exit;
  if not Socket.Recv(IsCache, 1) then
    Exit;
  if IsCache then app:=ApplicationsList.GetCache(AppID)
    else app:=ApplicationsList.GetApplication(AppID);
  WorksList.AddWork(work, app);
end;

procedure CCore.WorkPause(Socket: CSocket);
var
  WorkID: uint32;
begin
  if not Socket.Recv(WorkID, 4) then
    Exit;
  WorksList.GetWorkByID(WorkID).Pause();
end;

procedure CCore.WorkResume(Socket: CSocket);
var
  WorkID: uint32;
begin
  if not Socket.Recv(WorkID, 4) then
    Exit;
  WorksList.GetWorkByID(WorkID).Resume();
end;

procedure CCore.WorkStop(Socket: CSocket);
var
  WorkID: uint32;
begin
  if not Socket.Recv(WorkID, 4) then
    Exit;
  WorksList.GetWorkByID(WorkID).Stop();
end;

end.
