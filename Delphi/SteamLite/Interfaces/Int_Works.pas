unit Int_Works;

interface

uses
  ShareMem, Windows, SL_Interfaces, USE_Types, USE_Utils;

{$I defines.inc}

{$IFDEF SL_ONE}
function LoadInterface(): IWorksList; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  {$IFDEF SL_ONE}
  TWorksList = class (CBaseClass, IWorksList)
  {$ELSE}
  TWorksList = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;

    function AddWork(WorkType: EWorkType; Application: IApplication): IWork; overload; virtual; stdcall;
    function AddWork(WorkType: EWorkType; Application: IApplication; Parent: IWork): IWork; overload; virtual; stdcall;
    function GetMaxWorks(): uint32; virtual; stdcall;
    procedure SetMaxWorks(Value: uint32); virtual; stdcall;
    function GetCurrentWorksCount(): uint32; virtual; stdcall;
    function GetWorkFromApplicationID(AppID: uint32): IWork; virtual; stdcall;
    function GetWorkByID(WorkID: uint32): IWork; virtual; stdcall;
    function GetWorkState(WorkID: uint32): TWorkState; virtual; stdcall;
    function GetNewWorkID(): uint32; virtual; stdcall;
    procedure WaitForWork(WorkID: uint32); virtual; stdcall;
  private
    fWorks: TList;
    fMaxWorks: uint32;
    fLastWorkID: uint32;
    fThread: TThread;
    fWorksSem: THandle;

    function OnWorksProc(Sender: TThread): integer;
  end;

  {$IFDEF SL_ONE}
  TWork = class (CBaseClass, IWork)
  {$ELSE}
  TWork = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;

    function GetSubWorksList(): IWorksList; virtual; stdcall;
    function GetState(): EWorkState; virtual; stdcall;
    function GetSize(): uint64; virtual; stdcall;
    function GetCompletedSize(): uint64; virtual; stdcall;
    function GetCaption(): pChar; virtual; stdcall;            // возвращает строку с описание текущего действия
    function GetWorkID(): uint32; virtual; stdcall;
    function IsActive(): boolean; virtual; stdcall;

    function GetApplication(): IApplication; virtual; stdcall;

    procedure Stop(); virtual; stdcall;
    procedure Pause(); virtual; stdcall;
    procedure Resume(); virtual; stdcall;
  private
    fApp: IApplication;
    fType: EWorkType;
    fState: EWorkState;
    fPaused: boolean;
    fStop: boolean;
    fThread: TThread;
    fID: uint32;
    fSubWorksCount: uint32;
    fCaption: pChar;
    fSem: THandle;
    fSize: int64;
    fCurr: int64;
    fParent: IWork;
    fSubWorks: TList;

    function OnWorkProc(Sender: TThread): integer;
  end;

implementation

{$IFDEF SL_ONE}
function LoadInterface(): IWorksList; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}
begin
  result:=TWorksList.Create();
end;

function TWorksList.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TWorksList.GetType(): EInterfaceType;
begin
  result:=INTERFACE_WORK_LIST;
end;

function TWorksList.Init(): boolean;
begin
  fWorks:=TList.Create();
  fThread:=TThread.CreateAutoFree(OnWorksProc);
  fMaxWorks:=Str2Int(Core.Settings.GetStringValue(VALUE_MAXWORKS));
  fWorksSem:=CreateSemaphore(nil, 1, 1, 'Sem_WorksList');
  fLastWorkID:=0;
  result:=true;
end;

procedure TWorksList.DeInit();
var
  i, l: integer;
  list: TList;
begin
  list:=fWorks;
  fWorks:=nil;
  WaitForSingleObject(fWorksSem, INFINITE);
  WaitForSingleObject(fWorksSem, INFINITE);
  //sleep(500);
  CloseHandle(fWorksSem);
  l:=list.Count;
  if l>0 then
    for i:=0 to l-1 do
      IWork(list[i]).DeInit();
  list.Clear();
  list.Free;
end;

function TWorksList.AddWork(WorkType: EWorkType; Application: IApplication): IWork;
var
  Work: TWork;
begin
  Work:=TWork.Create();
  Work.fApp:=Application;
  Work.fType:=WorkType;
  Work.Init();
  result:=IWork(Work);
  fWorks.Add(Pointer(Work));
  if WorkType<>WORK_LOAD_CORE then
    Core.UI.OnWorkStart(IWork(Work), Core.Translation.GetTitle('#Idle'));
end;

function TWorksList.AddWork(WorkType: EWorkType; Application: IApplication; Parent: IWork): IWork;
var
  Work: TWork;
begin
  Work:=TWork.Create();
  Work.fApp:=Application;
  Work.fType:=WorkType;
  Work.Init();
  Work.fParent:=Parent;
  result:=IWork(Work);
  fWorks.Add(Pointer(Work));
  if WorkType<>WORK_LOAD_CORE then
    Core.UI.OnWorkStart(IWork(Work), Core.Translation.GetTitle('#Idle'));
end;

function TWorksList.GetMaxWorks(): uint32;
begin
  result:=Str2Int(Core.Settings.GetStringValue(VALUE_MAXWORKS));
  fMaxWorks:=result;
end;

procedure TWorksList.SetMaxWorks(Value: uint32);
begin
  Core.Settings.SetStringValue(VALUE_MAXWORKS, pChar(Int2Str(Value)));
  fMaxWorks:=Value;
end;

function TWorksList.GetCurrentWorksCount(): uint32;
var
  i, l: integer;
  c: uint32;
begin
  c:=0;
  l:=fWorks.Count;
  if l>0 then
    for i:=0 to l-1 do
      case (TWork(fWorks[i]).GetState) of
        WORK_STATE_IDLE: inc(c);
        WORK_STATE_RUN: inc(c);
        WORK_STATE_PAUSED: inc(c);
      end;
  result:=c;
end;

function TWorksList.GetWorkFromApplicationID(AppID: uint32): IWork;
var
  i, l: integer;
begin
  l:=fWorks.Count;
  result:=nil;
  if l>0 then
    for i:=0 to l-1 do
      if (TWork(fWorks[i]).GetApplication()<>nil) and (TWork(fWorks[i]).IsActive()) and (TWork(fWorks[i]).GetApplication().GetAppID() = AppID) then
      begin
        result:=TWork(fWorks[i]);
        break;
      end;
end;

function TWorksList.GetWorkByID(WorkID: uint32): IWork;
var
  i, l: integer;
begin
  l:=fWorks.Count;
  if l>0 then
    for i:=0 to l-1 do
      if TWork(fWorks[i]).GetWorkID()=WorkID then
      begin
        result:=TWork(fWorks[i]);
        break;
      end;
end;

function TWorksList.GetWorkState(WorkID: uint32): TWorkState;
var
  i, l: integer;
  work: TWork;
  s: pChar;
begin
  l:=fWorks.Count;
  if l>0 then
    for i:=0 to l-1 do
    begin
      Work:=TWork(fWorks[i]);
      if Work.GetWorkID()=WorkID then
      begin
        result.Max:=Work.fSize;
        result.Current:=Work.fCurr;
        s:=Work.GetCaption();
        l:=Length(s);
        Move(s[0], result.Caption[0], l);
        result.Caption[l]:=#0;
        break;
      end;
    end;
end;

function TWorksList.OnWorksProc(Sender: TThread): integer;
var
  i, l: integer;
begin
  while true do
  begin
    if fWorks=nil then
      break;
    if (GetCurrentWorksCount()<fMaxWorks) then
    begin
      l:=fWorks.Count;
      for i:=0 to l-1 do
        if (IWork(fWorks[i]).GetState=WORK_STATE_IDLE) then
        begin
          {if (TWork(fWorks[i]).fType=WORK_LOAD_CORE) then
            Core.UI.OnLoadingStart();    }
          //TWork(fWorks[i]).fState:=WORK_STATE_RUN;
          IWork(fWorks[i]).Resume();
          break;
        end;
    end;
    sleep(200);
  end;
  ReleaseSemaphore(fWorksSem, 1, nil);
  result:=0;
end;

function TWorksList.GetNewWorkID(): uint32;
begin
  result:=fLastWorkID;
  inc(fLastWorkID);
end;

procedure TWorksList.WaitForWork(WorkID: uint32);
var
  work: TWork;
begin
  work:=TWork(GetWorkByID(WorkID));
  if (work<>nil) then
  begin
    WaitForSingleObject(Work.fSem, INFINITE);
    ReleaseSemaphore(Work.fSem, 1, nil);
  end;
end;

function TWork.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TWork.GetType(): EInterfaceType;
begin
  result:=INTERFACE_WORK;
end;

function TWork.Init(): boolean;
begin
  fPaused:=false;
  fStop:=false;
  fState:=WORK_STATE_IDLE;
  fThread:=TThread.Create();
  fThread.OnExecute:=OnWorkProc;
  fThread.AutoFree:=true;
  fID:=Core.WorksList.GetNewWorkID();
  fParent:=nil;
  fSubWorksCount:=0;
  fSubWorks:=nil;
  fSem:=CreateSemaphore(nil, 1, 1, pChar('Work #'+Int2Str(fID)));
  result:=true;
end;

procedure TWork.DeInit();
begin
  Stop();
  CloseHandle(fSem);
  if fSubWorks<>nil then
    fSubWorks.Free;
  fStop:=true;
end;

function TWork.GetSubWorksList(): IWorksList;
begin
  result:=nil;
end;

function TWork.GetState(): EWorkState;
begin
  result:=fState;
end;

function TWork.GetSize(): uint64;
begin
  result:=fSize;
end;

function TWork.GetCompletedSize(): uint64;
begin
  result:=fCurr;
end;

function TWork.GetCaption(): pChar;
begin
  result:='';
end;

function TWork.GetWorkID(): uint32;
begin
  result:=fID;
end;

function TWork.IsActive(): boolean;
begin
  case fState of
    WORK_STATE_OK: result:=false;
    WORK_STATE_IDLE: result:=true;
    WORK_STATE_RUN: result:=true;
    WORK_STATE_STOP: result:=false;
    WORK_STATE_PAUSED: result:=true;
    WORK_STATE_ERROR: result:=false;
    else result:=false;
  end;
end;

function TWork.GetApplication(): IApplication;
begin
  result:=fApp;
end;

procedure TWork.Stop();
begin
  ReleaseSemaphore(fSem, 1, nil);
  fStop:=true;
end;

procedure TWork.Pause();
begin
  ReleaseSemaphore(fSem, 1, nil);
  fPaused:=true;
end;

procedure TWork.Resume();
begin
  case fState of
    WORK_STATE_IDLE, WORK_STATE_PAUSED:
    begin
      if fPaused then
      begin
        WaitForSingleObject(fSem, INFINITE);
        fPaused:=false;
        fState:=WORK_STATE_RUN;
      end
        else
      begin
        fThread.Resume;
        fPaused:=false;
        fState:=WORK_STATE_RUN;
      end;
    end;
  end;
end;

function TWork.OnWorkProc(Sender: TThread): integer;
  procedure AddCachesToWorkList();
  var
    caches: TCachesArray;
    i, l: integer;
  begin
    fSubWorks:=TList.Create();
    caches:=fApp.GetCaches();
    l:=Length(caches);
    for i:=0 to l-1 do
      if (caches[i]<>nil) then
      begin
        inc(fSubWorksCount);
        fSubWorks.Add(Pointer(Core.WorksList.AddWork(fType, caches[i], self)));
      end;
    SetLength(caches, 0);
    {while (fState<>WORK_STATE_OK) and (fState<>WORK_STATE_STOP) and (fState<>WORK_STATE_ERROR) do
      sleep(100);    }
  end;
  procedure LoadCoreProc();
  begin
    Core.UI.OnLoadingStart();
    Core.ApplicationsList.ReloadCDR();
    //sleep(400);
    Core.UI.OnLoadingEnd();
    self.fState:=WORK_STATE_OK;
  end;
  procedure ValidateProc();
  var
    valRes: EValidateResult;
    cacheFile: IFileCache;
  begin
    fSize:=fApp.GetSize();
    fCurr:=0;
    cacheFile:=ICache(fApp).Open;
    valRes:=VALIDATE_OK;
    case fType of
      WORK_VALIDATE: valRes:=cacheFile.Validate(ITEM_ROOT);
      WORK_CORRECT: valRes:=cacheFile.Correct(ITEM_ROOT);
    end;
    case valRes of
      VALIDATE_OK: fState:=WORK_STATE_OK;
      VALIDATE_CHECKSUM_ERROR, VALIDATE_INCOMPLETE: fState:=WORK_STATE_ERROR;
    end;
  end;
  procedure CreateArchiveProc();
  var
    idx: integer;
    cacheFile: IFileCache;
  begin
    fSize:=fApp.GetSize();
    fCurr:=0;
    idx:=Core.Log.AddEvent(pChar(Format(Core.Translation.GetTitle('#ArchiveFileCreate'), [fApp.GetName()])));
    cacheFile:=ICache(fApp).Open;
    fCaption:=cacheFile.CreateArchive();
    if fCaption='' then
    begin
      fState:=WORK_STATE_ERROR;
      Core.Log.SetEventResult(idx, Core.Translation.GetTitle('#Failed'));
    end
      else
    begin
      fState:=WORK_STATE_OK;
      Core.Log.SetEventResult(idx, fCaption);
    end;
  end;
  procedure UpdateProc();
  var
    res: boolean;
    idx: integer;
    FN: pChar;
    cacheFile: IFileCache;
  begin
    fSize:=fApp.GetSize();
    fCurr:=0;
    idx:=Core.Log.AddEvent(pChar(Format(Core.Translation.GetTitle('#UpdateFileCreate'), [fApp.GetName()])));
    if fType=WORK_CREATE_UPDATE then
      FN:=Core.UI.GetFilenameFromDlg(Core.Translation.GetTitle('#SelectArchiveFile'), 'Archive files (*.gcf.archive)|*.gcf.archive')
        else FN:=Core.UI.GetFilenameFromDlg(Core.Translation.GetTitle('#SelectUpdateFile'), 'Archive files (*.update.gcf)|*.update.gcf');
    if FN='' then fState:=WORK_STATE_ERROR
      else
    begin
      cacheFile:=ICache(fApp).Open();
      if fType=WORK_CREATE_UPDATE then res:=cacheFile.CreateUpdate(FN)
        else res:=cacheFile.ApplyUpdae(FN);
      if not res then
      begin
        fState:=WORK_STATE_ERROR;
        Core.Log.SetEventResult(idx, Core.Translation.GetTitle('#Failed'));
      end
        else
      begin
        fState:=WORK_STATE_OK;
        Core.Log.SetEventResult(idx, fCaption);
      end;
    end;
  end;
  procedure CreateGCFGame();
  begin
    //Core.Converter.
  end;
var
  i, l: integer;
begin
  WaitForSingleObject(fSem, INFINITE);
  if (fApp<>nil) and (fApp.GetAppType()<>APPLICATION_CACHE) then
  begin
    AddCachesToWorkList();
    while fSubWorksCount>0 do
      sleep(100);
    l:=fSubWorks.Count-1;
    fState:=WORK_STATE_OK;
    for i:=0 to l do
      case TWork(fSubWorks[i]).fState of
        WORK_STATE_ERROR: fState:=WORK_STATE_ERROR;
      end;
  end
    else
  case fType of
    WORK_LOAD_CORE: LoadCoreProc();
    WORK_VALIDATE, WORK_CORRECT: ValidateProc();
    WORK_CREATE_ARCHIVE: CreateArchiveProc();
    WORK_CREATE_UPDATE, WORK_APPLY_UDATE: UpdateProc();
    WORK_CREATE_GCF_APPLICATION: CreateGCFGame();
  end;
  result:=0;
  if fType<>WORK_LOAD_CORE then
    Core.UI.OnWorkEnd(self);
  if fParent<>nil then
    dec(TWork(fParent).fSubWorksCount);
  ReleaseSemaphore(fSem, 1, nil);
end;

end.
