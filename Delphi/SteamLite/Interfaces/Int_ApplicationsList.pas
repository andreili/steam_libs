unit Int_ApplicationsList;

interface

{$I defines.inc}

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils, {$IFDEF USE_CDR_BLOB}CDRFile{$ELSE}VDFFile{$ENDIF};

type
  {$IFDEF SL_ONE}
  TApplicationsList = class (CBaseClass, IApplicationsList)
  {$ELSE}
  TApplicationsList = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function ReloadList(): ELoadListResult; virtual; stdcall;
    procedure LoadApplicationsState(); virtual; stdcall;
    procedure SaveApplicationsState(); virtual; stdcall;

    function UpdateCDR(): EUpdateCDR; virtual; stdcall;
    function ReloadCDR(): ELoadListResult; virtual; stdcall;

    function GetAppsCount(): integer; virtual; stdcall;
    function GetCachesCount(): integer; virtual; stdcall;
    function GetApplicationsCount(): integer; virtual; stdcall;

    function GetApplication(AppID: uint32): IApp; virtual; stdcall;
    function GetCache(AppID: uint32): ICache; virtual; stdcall;
    function GetApplicationByIdx(Index: integer): IApplication; virtual; stdcall;
    function IsAppBusy(AppID: uint32): boolean; virtual; stdcall;
  private
    {$IFDEF USE_CDR_BLOB}
    fCDR: TCDR;
    {$ELSE}
    fCDR: TVDFFile;
    {$ENDIF}
    //fApps: array of IApplication;
    fApps: TList;
  end;

{$IFDEF SL_ONE}
function LoadInterface(): IApplicationsList; stdcall;
{$ELSE}
function LoadInterface(_Core: CCore): TObject; stdcall;
{$ENDIF}

implementation

uses
  Int_Applications;

{$IFDEF SL_ONE}
function LoadInterface(): IApplicationsList;
{$ELSE}
function LoadInterface(_Core: CCore): TObject;
{$ENDIF}
begin
  result:=TApplicationsList.Create();
end;

function TApplicationsList.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TApplicationsList.GetType(): EInterfaceType;
begin
  result:=INTERFACE_APPLICATION_LIST;
end;

function TApplicationsList.Init(): boolean;
begin
  {result:=false;
  if (ReloadCDR()<>LOAD_LIST_OK) then
    Exit; }
  fApps:=TList.Create;
  result:=true;
end;

procedure TApplicationsList.DeInit();
var
  i, l: integer;
begin
  l:=fApps.Count;
  if (l>0) then
    for i:=0 to l-1 do
      if fApps[i]<>nil then
        IApplication(fApps.Items[i]).DeInit();
  //SetLength(fApps, 0);
  fApps.Free;

  if fCDR<>nil then
    fCDR.Free;
end;

function TApplicationsList.ReloadList(): ELoadListResult;
var
  i, l, idx, c, caches: integer;
  cache: TCache;
  app: TApp;
  path: pChar;
begin
  result:=LOAD_LIST_FAILED;
  l:=fApps.Count;
  if (l>0) then
    for i:=0 to l-1 do
      IApplication(fApps.Items[i]).DeInit();
  //SetLength(fApps, 0);
  fApps.Clear;

  while not DirectoryExists(Core.Settings.GetStringValue(VALUE_CACHE_PATH)) do
  begin
    path:=Core.UI.GetDirectoryFromDlg(Core.Translation.GetTitle('#BrowseCachePath'));
    if DirectoryExists(path) then
    begin
      Core.Settings.SetStringValue(VALUE_CACHE_PATH, path);
      break;
    end;
  end;

  if Core.UI<>nil then
    Core.UI.OnWorkStart(nil, Core.Translation.GetTitle('#LoadingCaches'));
  idx:=Core.Log.AddEvent(Core.Translation.GetTitle('#LoadingCaches'));
  {$IFDEF USE_CDR_BLOB}
  l:=Length(fCDR.AppRecords);
  //SetLength(fApps, l);
  {for i:=0 to l-1 do
    IApplication(fApps.Items[i]).BuildCachesList();}
  caches:=0;
  for i:=0 to l-1 do
    if fCDR.AppRecords[i].IsCache() then
      inc(caches);
  c:=0;
  for i:=0 to l-1 do
    if fCDR.AppRecords[i].IsCache() then
    begin
      cache:=TCache.Create;
      cache.fAppRec:=fCDR.AppRecords[i];
      //writeln(cache.GetName());
      if not cache.Init() then
      begin
        DeInit();
        Exit;
      end;
      fApps.Add(cache);
      // загрузка файла кэша в список для интерфейса пользователя
      if Core.UI<>nil then
        Core.UI.AddApplicationToList(IApplication(fApps[fApps.Count-1]));
      inc(c);
      if (c mod 100=0) then
        Core.UI.OnWorkProc(nil, cache.GetFolderName(), c, caches);
    end;
  Core.UI.OnWorkEnd(nil);
  Core.Log.SetEventResult(idx, Core.Translation.GetTitle('#OK'));
  if Core.UI<>nil then
    Core.UI.OnWorkStart(nil, Core.Translation.GetTitle('#LoadingApps'));
  idx:=Core.Log.AddEvent(Core.Translation.GetTitle('#LoadingApps'));
  caches:=l-caches;
  c:=0;
  for i:=0 to l-1 do
    if fCDR.AppRecords[i].IsApp() then
    begin
      app:=TApp.Create();
      app.fAppRec:=fCDR.AppRecords[i];
      if not app.Init() then
      begin
        DeInit();
        Exit;
      end;
      app.BuildCachesList();
      fApps.Add(app);
      // загрузка файла кэша в список для интерфейса пользователя
      if Core.UI<>nil then
        Core.UI.AddApplicationToList(IApplication(fApps[fApps.Count-1]));
      inc(c);
      if (c mod 100=0) then
        Core.UI.OnWorkProc(nil, app.GetName(), c, caches);
    end;
  Core.UI.OnWorkEnd(nil);
  Core.Log.SetEventResult(idx, Core.Translation.GetTitle('#OK'));
  {$ELSE}
  {$ENDIF}
  //Core.UI.OnLoadingEnd();
  result:=LOAD_LIST_OK;
end;

procedure TApplicationsList.LoadApplicationsState();
begin
end;

procedure TApplicationsList.SaveApplicationsState();
begin
end;

function TApplicationsList.UpdateCDR(): EUpdateCDR;
begin
  result:=UPDATE_CDR_OK;
end;

function TApplicationsList.ReloadCDR(): ELoadListResult;
var
  idx: integer;
begin
  result:=LOAD_LIST_FAILED;
  if Core.UI<>nil then
    Core.UI.OnWorkStart(nil, Core.Translation.GetTitle('#LoadingCDR'));
  if fCDR<>nil then
    fCDR.Free;
  idx:=Core.Log.AddEvent(Core.Translation.GetTitle('#LoadingCDR'));
  {$IFDEF USE_CDR_BLOB}
  fCDR:=TCDR.Create('.\Files\cdr.bin');
  if Length(fCDR.AppRecords)=0 then
    Exit;
  {$ELSE}
  fCDR:=TVDFFile.Create();
  if not fCDR.LoadFromFile('.\Files\appinfo.vdf') then
    Exit;
  {$ENDIF}
  Core.Log.SetEventResult(idx, Core.Translation.GetTitle('#OK'));
  Core.UI.OnWorkEnd(nil);
  result:=ReloadList();
  //Core.UI.OnLoadingEnd();
end;

function TApplicationsList.GetAppsCount(): integer;
begin
  result:=fApps.Count;
end;

function TApplicationsList.GetCachesCount(): integer;
var
  i, l, c: integer;
begin
  l:=GetAppsCount();
  c:=0;
  for i:=0 to l-1 do
    if IApplication(fApps.Items[i]).GetAppType=APPLICATION_CACHE then
      inc(c);
  result:=c;
end;

function TApplicationsList.GetApplicationsCount(): integer;
begin
  result:=GetAppsCount()-GetCachesCount();
end;

function TApplicationsList.GetApplication(AppID: uint32): IApp;
var
  i, l: integer;
begin
  l:=fApps.Count;
  for i:=0 to l-1 do
    if (fApps.Items[i]<>nil) and (IApplication(fApps.Items[i]).GetAppID()=AppID) and (IApplication(fApps.Items[i]).GetAppType<>APPLICATION_CACHE) then
    begin
      result:=IApp(IApplication(fApps.Items[i]));
      Exit;
    end;
  result:=nil;
end;

function TApplicationsList.GetCache(AppID: uint32): ICache;
var
  i, l: integer;
begin
  l:=fApps.Count;
  for i:=0 to l-1 do
    if (fApps.Items[i]<>nil) and (IApplication(fApps.Items[i]).GetAppID()=AppID) and (IApplication(fApps.Items[i]).GetAppType=APPLICATION_CACHE) then
    begin
      result:=ICache(IApplication(fApps.Items[i]));
      Exit;
    end;
  result:=nil;
end;

function TApplicationsList.GetApplicationByIdx(Index: integer): IApplication;
begin
  if Index<fApps.Count then result:=IApplication(fApps.Items[Index])
    else result:=nil;
end;

function TApplicationsList.IsAppBusy(AppID: uint32): boolean;
var
  App: IApp;
begin
  App:=GetApplication(AppID);
  // если приложение существует
  if (App<>nil) then result:=((App.GetWork()<>nil) and (App.GetWork().IsActive()))
    else result:=true;
end;

end.
