unit Int_UI;

interface

uses
  ShareMem, Windows, Messages, SL_Interfaces, USE_Types, USE_Utils,
  Forms, Classes, Graphics, Dialogs, StdCtrls, Controls, ComCtrls, CommCtrl,
  ComObj, CommDlg, ShlObj, ActiveX, TabNotBk, ExtCtrls, Menus, ValEdit;

{$I defines.inc}

{$IFDEF SL_ONE}
function LoadInterface(): IUserInterface; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

type
  {$IFDEF SL_ONE}
  TUIWindow = class (CBaseClass, IUIWindow)
  {$ELSE}
  TUIWindow = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    //procedure Close();
  end;

  EUIOperation =
    (UI_NONE,
     UI_SHOW_MAIN_FORM,
     UI_CLOSE_FORM,
     UI_SHOW_LOADING_FORM,
     UI_CLOSE_LOADING_FORM,
     UI_SHOW_SETTINGS_FORM,
     UI_CLOSE_SETTINGS_FORM,
     UI_SHOW_APP_PROPERTIES_FORM,
     UI_SHOW_CACHE_PROPERTIES_FORM,
     UI_WORK_START,
     UI_WORK_UPDATE_PROGRESS,
     UI_WORK_END,
     UI_CLOSE = 255);

  TUIThread = class (Classes.TThread)
    private
      fUIOperation: EUIOperation;
      fSem: THandle;
      procedure UIProc();
    protected
      procedure Execute(); override;
    public
      Caption: pChar;
      Progres: integer;
      constructor Create();
      destructor Destroy(); override;
      class procedure CallUIOperation(Operation: EUIOperation);
  end;

  {$IFDEF SL_ONE}
  TUserInterface = class (CBaseClass, IUserInterface)
  {$ELSE}
  TUserInterface = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function ShowMainForm(): IUIWindow; virtual; stdcall;
    procedure WaitShowMainForm(); virtual; stdcall;
    function ShowSettingsForm(): IUIWindow; virtual; stdcall;
    function ShowCachePropertiesForm(AppID: uint32): IUIWindow; virtual; stdcall;
    function ShowAppPropertiesForm(AppID: uint32): IUIWindow; virtual; stdcall;
    procedure ReloadControlsText(Parent: TObject); virtual; stdcall;

    procedure OnWorkStart(Work: IWork; Text: pChar); virtual; stdcall;
    procedure OnWorkProc(Work: IWork; Text: pChar; CurPos, MaxPos: uint64); virtual; stdcall;
    procedure OnWorkEnd(Work: IWork); virtual; stdcall;
    procedure OnWorkError(Work: IWork; Error: EWorkError; Item: pChar); virtual; stdcall;
    procedure OnLoadingStart(); virtual; stdcall;
    procedure OnLoadingEnd(); virtual; stdcall;

    procedure UpdateApplicationStatus(Application: IApplication); virtual; stdcall;

    procedure AddApplicationToList(Application: IApplication); virtual; stdcall;
    procedure ClearApplicationsList(Lists: uint32); virtual; stdcall;
    procedure AddLogEvent(EventIdx: uint32); virtual; stdcall;
    procedure SetLogEventResult(EventIdx: uint32); virtual; stdcall;

    function GetFilenameFromDlg(Caption, Mask: pChar): pChar; virtual; stdcall;
    function GetDirectoryFromDlg(Caption: pChar): pChar; virtual; stdcall;
  private
    fOnLoading: boolean;
    fThread: TUIThread;
    fApp: IApplication;
    procedure OnChildren(Child: TComponent);
    procedure Add();
  public
    fMFSem: THandle;
  end;

implementation

uses
  MainForm, LoadingForm;

{$IFDEF SL_ONE}
function LoadInterface(): IUserInterface;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TUserInterface.Create();
end;

constructor TUIThread.Create();
begin
  inherited Create(true);
  fSem:=CreateSemaphore(nil, 1, 1, 'Sem_UIThread');
end;

destructor TUIThread.Destroy();
begin
  CloseHandle(fSem);
  inherited Destroy();
end;

procedure TUIThread.UIProc();
begin
  case fUIOperation of
    UI_SHOW_MAIN_FORM:
      begin
       { Application.Initialize;
        Application.MainFormOnTaskbar:=true;
        Application.CreateForm(TForm_Main, Form_Main);
        fUIOperation:=UI_NONE;
        ReleaseSemaphore(fSem, 1, nil);
        ReleaseSemaphore(fSem, 1, nil);
        Application.Run();   }
      end;
    UI_SHOW_LOADING_FORM:
      begin
        Form_Loading:=TForm_Loading.Create(Application);
        fUIOperation:=UI_NONE;
        ReleaseSemaphore(fSem, 1, nil);
        ReleaseSemaphore(fSem, 1, nil);
        Form_Loading.ShowModal();
      end;
    UI_CLOSE_LOADING_FORM:
      begin
        Form_Loading.ModalResult:=1;
        Form_Loading:=nil;
        fUIOperation:=UI_NONE;
        ReleaseSemaphore(fSem, 1, nil);
        ReleaseSemaphore(fSem, 1, nil);
      end;
    else
      begin
        fUIOperation:=UI_NONE;
        ReleaseSemaphore(fSem, 1, nil);
        ReleaseSemaphore(fSem, 1, nil);
      end;
  end;
end;

procedure TUIThread.Execute();
begin
  while true do
    if fUIOperation=UI_CLOSE then
    begin
      ReleaseSemaphore(fSem, 1, nil);
      ReleaseSemaphore(fSem, 1, nil);
      break;
    end
      else if fUIOperation<>UI_NONE then
      begin
        if fUIOperation=UI_SHOW_MAIN_FORM then UIProc()
          else Synchronize(UIProc);
        break;
      end
        else sleep(100);
end;

class procedure TUIThread.CallUIOperation(Operation: EUIOperation);
var
  th: TUIThread;
begin
  th:=TUIThread.Create();
  th.fUIOperation:=Operation;
  th.Start;
  WaitForSingleObject(th.fSem, INFINITE);
  WaitForSingleObject(th.fSem, INFINITE);
end;

function TUserInterface.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TUserInterface.GetType(): EInterfaceType;
begin
  result:=INTERFACE_UI;
end;

function TUserInterface.Init(): boolean;
begin
  fOnLoading:=false;
  fMFSem:=CreateSemaphore(nil, 1, 1, 'Sem_MainForm');
  fThread:=TUIThread.Create();
  result:=true;
end;

procedure TUserInterface.DeInit();
begin
  CloseHandle(fMFSem);
  fThread.CallUIOperation(UI_CLOSE);
end;

function TUserInterface.ShowMainForm(): IUIWindow;
begin
  WaitForSingleObject(fMFSem, INFINITE);
  {fThread.fUIOperation:=UI_SHOW_MAIN_FORM;
  fThread.Synchronize(fThread.UIProc); }
  TUIThread.CallUIOperation(UI_SHOW_MAIN_FORM);
end;

procedure TUserInterface.WaitShowMainForm();
begin
  WaitForSingleObject(fMFSem, INFINITE);
  ReleaseSemaphore(fMFSem, 1, nil);
end;

function TUserInterface.ShowSettingsForm(): IUIWindow;
begin
  fThread.CallUIOperation(UI_SHOW_SETTINGS_FORM);
end;

function TUserInterface.ShowCachePropertiesForm(AppID: uint32): IUIWindow;
begin
  fThread.CallUIOperation(UI_SHOW_CACHE_PROPERTIES_FORM);
end;

function TUserInterface.ShowAppPropertiesForm(AppID: uint32): IUIWindow;
begin
  fThread.CallUIOperation(UI_SHOW_APP_PROPERTIES_FORM);
end;

procedure TUserInterface.OnChildren(Child: TComponent);
begin
  ReloadControlsText(Child);
end;

procedure TUserInterface.ReloadControlsText(Parent: TObject);
var
  i, l: integer;
  Ctrl: TWinControl;
  VE: TValueListEditor;
begin
  Ctrl:=TWinControl(Parent);
  if (Parent is TWinControl) then
  begin
    l:=Ctrl.ControlCount;
    for i:=0 to l-1 do
      ReloadControlsText(Ctrl.Controls[i]);
  end;
  if (Parent is TListView) then
  begin
    l:=(Parent as TListView).Columns.Count;
    for i:=0 to l-1 do
      ReloadControlsText((Parent as TListView).Columns[i]);
  end
    else if (Parent is TTabbedNotebook) then
  begin
    l:=TTabbedNotebook(Parent).Pages.Count;
    for i:=0 to l-1 do
      TTabbedNotebook(Parent).Pages[i]:=Core.Translation.GetTitle(pChar(TTabbedNotebook(Parent).Pages[i]));
    Ctrl.GetChildren(OnChildren, Ctrl);
  end
    else if (Parent is TPanel) then
  begin
    Ctrl.GetChildren(OnChildren, Ctrl);
  end
    else if (Parent is TValueListEditor) then
  begin
    VE:=TValueListEditor(Parent);
    l:=VE.RowCount-1;
    for i:=1 to l do
    begin
      VE.Cells[0,i]:=Core.Translation.GetTitle(pChar(VE.Cells[0,i]));
      VE.Cells[1,i]:=Core.Translation.GetTitle(pChar(VE.Cells[1,i]));
    end;
  end
    else if (Parent is TLabel) then (Parent as TLabel).Caption:=Core.Translation.GetTitle(pChar((Parent as TLabel).Caption))
    else if (Parent is TButton) then (Parent as TButton).Caption:=Core.Translation.GetTitle(pChar((Parent as TButton).Caption))
    else if (Parent is TCheckBox) then (Parent as TCheckBox).Caption:=Core.Translation.GetTitle(pChar((Parent as TCheckBox).Caption))
    else if (Parent is TRadioButton) then (Parent as TRadioButton).Caption:=Core.Translation.GetTitle(pChar((Parent as TRadioButton).Caption))
    else if (Parent is TGroupBox) then (Parent as TGroupBox).Caption:=Core.Translation.GetTitle(pChar((Parent as TGroupBox).Caption))
    else if (Parent is TListColumn) then (Parent as TListColumn).Caption:=Core.Translation.GetTitle(pChar((Parent as TListColumn).Caption))
    else if (Parent is TMenuItem) then
    begin
      (Parent as TMenuItem).Caption:=Core.Translation.GetTitle(pChar((Parent as TMenuItem).Caption));
      l:=(Parent as TMenuItem).Count;
      for i:=0 to l-1 do
        ReloadControlsText((Parent as TMenuItem).Items[i]);
    end
    else if (Parent is TForm) then
    begin
      TForm(Parent).Caption:=Core.Translation.GetTitle(pChar((Parent as TForm).Caption));
      Ctrl.GetChildren(OnChildren, Ctrl);
    end
    else if (Parent is TPopupMenu) then Ctrl.GetChildren(OnChildren, Ctrl);
end;

procedure TUserInterface.OnWorkStart(Work: IWork; Text: pChar);
begin
  if fOnLoading then
  begin
    {fThread.Caption:=Text;
    fThread.Progres:=0;
    fThread.CallUIOperation(UI_WORK_START);}
    Form_Loading.L_Operation.Caption:=Text;
    Form_Loading.ProgressBar1.Position:=0;
  end;
end;

procedure TUserInterface.OnWorkProc(Work: IWork; Text: pChar; CurPos, MaxPos: uint64);
begin
  if fOnLoading then
  begin
    {fThread.Progres:=Trunc(CurPos/MaxPOs*100);
    fThread.CallUIOperation(UI_WORK_UPDATE_PROGRESS);}
    //Form_Loading.L_Operation.Caption:=Text;
    Form_Loading.ProgressBar1.Position:=Trunc(CurPos/MaxPOs*100);
  end;
end;

procedure TUserInterface.OnWorkEnd(Work: IWork);
begin
  if fOnLoading then
  begin
    Form_Loading.L_Operation.Caption:='';
    Form_Loading.ProgressBar1.Position:=100;
    {fThread.Caption:='';
    fThread.Progres:=100;
    fThread.CallUIOperation(UI_WORK_END);}
  end;
end;

procedure TUserInterface.OnWorkError(Work: IWork; Error: EWorkError; Item: pChar);
begin
end;

procedure TUserInterface.OnLoadingStart();
begin
  if Form_Loading=nil then
  begin
    //WaitForSingleObject(fMFSem, INFINITE);
    TUIThread.CallUIOperation(UI_SHOW_LOADING_FORM);
    //fThread.CallUIOperation(UI_SHOW_LOADING_FORM);
    WaitShowMainForm();
    fOnLoading:=true;
  end;
end;

procedure TUserInterface.OnLoadingEnd();
begin
  if Form_Loading<>nil then
  begin
    fOnLoading:=false;
    Form_Loading.ModalResult:=1;
    Form_Loading:=nil;
    Application.ProcessMessages;
    //fThread.CallUIOperation(UI_CLOSE_LOADING_FORM);
  end;
end;

procedure TUserInterface.UpdateApplicationStatus(Application: IApplication);
var
  i, l: integer;
  LV: TListView;
  Item: TListItem;
begin
  case Application.GetAppType() of
    APPLICATION_CACHE: LV:=nil;//Form_Main.LV_Caches;
    else LV:=nil;
  end;
  if LV=nil then
    Exit;
  l:=LV.Items.Count;
  for i:=0 to l-1 do
    if LV.Items[i].Data=Pointer(Application) then
    begin
      Item:=LV.Items[i];
      Item.SubItems[2]:='qw';

      Exit;
    end;
end;

procedure TUserInterface.Add();
var
  cache: ICache;
  app: IApp;
  Item: TListItem;
begin
  case fApp.GetAppType() of
    APPLICATION_CACHE:
      begin
        cache:=ICache(fApp);
        if (cache.IsLoaded()) then
        begin
          Item:=Form_Main.LV_Caches.Items.Add();
          Item.Caption:=cache.GetName();
          Item.SubItems.AddObject(Int2Str(cache.GetAppID()), Pointer(cache.GetAppID()));
          Item.SubItems.AddObject(Double2Str(Round(cache.GetCompletion()*1000)/10)+'%', Pointer(Round(cache.GetCompletion()*1000)));
          Item.SubItems.AddObject(Int2Str(cache.GetVersion()), Pointer(cache.GetVersion()));
          Item.SubItems.AddObject(Core.Utils.GetSizeTitle(cache.GetSize()), Pointer(cache.GetSize()));
          Item.SubItems.Add('');
          Item.Data:=Pointer(cache);
        end
          else
        begin
        end;
      end;
    APPLICATION_GAME:
      begin
        app:=IApp(fApp);
        if app.IsLoaded() then
        begin
          Item:=Form_Main.LV_Games.Items.Add();
          Item.Caption:=App.GetName();
          Item.SubItems.AddObject(Double2Str(Round(App.GetCompletion()*1000)/10)+'%', Pointer(Round(App.GetCompletion()*1000)));
          Item.SubItems.Add(App.GetDeveloperName());
          Item.SubItems.Add('');
          Item.Data:=Pointer(app);
        end;
      end;
  end;
end;

procedure TUserInterface.AddApplicationToList(Application: IApplication);
begin
  fApp:=Application;
  fThread.Synchronize(fThread, Add);
end;

procedure TUserInterface.ClearApplicationsList(Lists: uint32);
begin
  if Lists and LIST_INSTALLED_CACHES=LIST_INSTALLED_CACHES then
    Form_Main.LV_Caches.Clear();
  if Lists and LIST_INSTALLED_GAMES=LIST_INSTALLED_GAMES then
    Form_Main.LV_Games.Clear();
end;

procedure TUserInterface.AddLogEvent(EventIdx: uint32);
begin
end;

procedure TUserInterface.SetLogEventResult(EventIdx: uint32);
begin
end;

function TUserInterface.GetFilenameFromDlg(Caption, Mask: pChar): pChar;
begin
  result:='';
end;

threadvar
  myDir: string;

function BrowseCallBackProc(hwnd: HWND; uMsg: UINT; lParam: LPARAM;lpData: LPARAM): integer; stdcall;
begin
  Result:=0;
  if uMsg=BFFM_INITIALIZED then
    SendMessage(hwnd,BFFM_SETSELECTION, 1, LongInt(PChar(myDir)));
end;

function TUserInterface.GetDirectoryFromDlg(Caption: pChar): pChar;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: pChar;
  RootItemIDList,ItemIDList: pItemIDList;
  ShellMalloc: IMalloc;
  Cmd: Boolean;
begin
  Result:=Core.Settings.GetStringValue(VALUE_CACHE_PATH);
  FillChar(BrowseInfo, SizeOf(BrowseInfo),0);
  if DirectoryExists(Result) then
    myDir:=Result;
  if (ShGetMalloc(ShellMalloc)=S_OK) and (ShellMalloc<>nil) then
  begin
    Buffer:=ShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList:=nil;
      with BrowseInfo do
      begin
        hwndOwner:=Form_Main.Handle;
        pidlRoot:=RootItemIDList;
        pszDisplayName:=Buffer;
        lpfn:=@BrowseCallbackProc;
        lpszTitle:=PChar(Caption);
        //какие еще флаги есть посмотри в константах ShlObj
        ulFlags:=BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or BIF_EDITBOX or BIF_STATUSTEXT;
        //кстати BIF_EDITBOX (добавляет edit для ручного ввода пути) не даст выбрать не существующий каталог
      end;
      WindowList:=DisableTaskWindows(0);
      try
        ItemIDList:=ShBrowseForFolder(BrowseInfo);
      finally
        EnableTaskWindows(WindowList);
      end;
      Cmd:=ItemIDList<>nil;
      if Cmd then
      begin
        ShGetPathFromIDList(ItemIDList,Buffer);
        ShellMalloc.Free(ItemIDList);
        if Length(Buffer)<>0 then
          Result:=pChar(IncludeTrailingPathDelimiter(Buffer))
            else Result:='';
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;

function TUIWindow.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TUIWindow.GetType(): EInterfaceType;
begin
  result:=INTERFACE_WINDOW;
end;

function TUIWindow.Init(): boolean;
begin
  result:=true;
end;

procedure TUIWindow.DeInit();
begin
end;

end.
