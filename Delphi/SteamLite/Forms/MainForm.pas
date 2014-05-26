unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, TabNotBk, ExtCtrls, Menus, StdCtrls, USE_Types, USE_Utils,
  SL_Interfaces, Int_Core;

type
  TForm_Main = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    TabbedNotebook1: TTabbedNotebook;
    LV_Caches: TListView;
    LV_Games: TListView;
    PM_Caches: TPopupMenu;
    PM_Caches_Open: TMenuItem;
    N1: TMenuItem;
    PM_Caches_Downloading: TMenuItem;
    PM_Caches_Down_Continue: TMenuItem;
    PM_Caches_Down_Stop: TMenuItem;
    PM_Caches_Patching: TMenuItem;
    PM_Caches_Patch_CreateArchive: TMenuItem;
    PM_Caches_Patch_CreatePatch: TMenuItem;
    PM_Caches_Patch_ApplyPatch: TMenuItem;
    N2: TMenuItem;
    PM_Caches_Stop: TMenuItem;
    PM_Caches_Validate: TMenuItem;
    PM_Caches_Correct: TMenuItem;
    N3: TMenuItem;
    PM_Caches_Delete: TMenuItem;
    PM_Caches_CreateMiniGCF: TMenuItem;
    N4: TMenuItem;
    PM_Caches_Properties: TMenuItem;
    PM_Games: TPopupMenu;
    PM_Games_Launch: TMenuItem;
    PM_Games_CreateStandAlone: TMenuItem;
    PM_Games_s1: TMenuItem;
    PM_Games_CreateGCF: TMenuItem;
    PM_Games_s2: TMenuItem;
    PM_Games_Download: TMenuItem;
    PM_Games_Loading_Continue: TMenuItem;
    PM_Games_Loading_Stop: TMenuItem;
    PM_Games_Update: TMenuItem;
    PM_Games_Update_CreateArchive: TMenuItem;
    PM_Games_Update_CreateUpdate: TMenuItem;
    PM_Games_Update_ApplyUpdate: TMenuItem;
    PM_Games_s3: TMenuItem;
    PM_Games_Stop: TMenuItem;
    PM_Games_Validate: TMenuItem;
    PM_Games_Correct: TMenuItem;
    PM_Games_s4: TMenuItem;
    PM_Games_Delete: TMenuItem;
    PM_Games_CreateMiniGCF: TMenuItem;
    PM_Games_s5: TMenuItem;
    PM_Games_Properties: TMenuItem;
    procedure AddWork(List: TListView; Work: EWorkType);
    procedure StopWork(List: TListView);
    procedure FormActivate(Sender: TObject);
    procedure LV_GamesColumnClick(Sender: TObject; Column: TListColumn);
    procedure LV_CachesColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormDestroy(Sender: TObject);
    procedure PM_GamesPopup(Sender: TObject);
    procedure PM_Games_PropertiesClick(Sender: TObject);
    procedure PM_CachesPopup(Sender: TObject);
    procedure PM_Caches_OpenClick(Sender: TObject);
    procedure PM_Caches_Patch_CreateArchiveClick(Sender: TObject);
    procedure PM_Caches_Patch_CreatePatchClick(Sender: TObject);
    procedure PM_Caches_Patch_ApplyPatchClick(Sender: TObject);
    procedure PM_Caches_Down_ContinueClick(Sender: TObject);
    procedure PM_Caches_Down_StopClick(Sender: TObject);
    procedure PM_Caches_StopClick(Sender: TObject);
    procedure PM_Caches_ValidateClick(Sender: TObject);
    procedure PM_Caches_CorrectClick(Sender: TObject);
    procedure PM_Caches_DeleteClick(Sender: TObject);
    procedure PM_Caches_CreateMiniGCFClick(Sender: TObject);
    procedure PM_Games_LaunchClick(Sender: TObject);
    procedure PM_Games_CreateStandAloneClick(Sender: TObject);
    procedure PM_Games_CreateGCFClick(Sender: TObject);
    procedure PM_Games_Loading_ContinueClick(Sender: TObject);
    procedure PM_Games_Loading_StopClick(Sender: TObject);
    procedure PM_Games_Update_CreateArchiveClick(Sender: TObject);
    procedure PM_Games_Update_CreateUpdateClick(Sender: TObject);
    procedure PM_Games_Update_ApplyUpdateClick(Sender: TObject);
    procedure PM_Games_StopClick(Sender: TObject);
    procedure PM_Games_ValidateClick(Sender: TObject);
    procedure PM_Games_CorrectClick(Sender: TObject);
    procedure PM_Games_DeleteClick(Sender: TObject);
    procedure PM_Games_CreateMiniGCFClick(Sender: TObject);
  private
    { Private declarations }
    Sort_Games: TIntArray;
    Sort_Caches: TIntArray;
    // procedure OnRecvAppInfo(App: pClientAppRecord);
  public
    { Public declarations }
  end;

var
  Form_Main: TForm_Main;

implementation

uses
  LoadingForm, AppPropertiesForm, Form_CacheViewer, Form_AppPrepare;

{$R *.dfm}

procedure TForm_Main.AddWork(List: TListView; Work: EWorkType);
var
  i, l: integer;
begin
  l:=List.Items.Count-1;
  for i:=0 to l do
    if List.Items[i].Selected then
      Core.WorksList.AddWork(Work, IApplication(List.Items[i].Data));
end;

procedure TForm_Main.StopWork(List: TListView);
var
  i, l: integer;
begin
  l:=List.Items.Count-1;
  for i:=0 to l do
    if List.Items[i].Selected then
      Core.WorksList.GetWorkFromApplicationID(IApplication(List.Items[i].Data).GetAppID()).Stop();
end;

procedure TForm_Main.PM_CachesPopup(Sender: TObject);
var
  isBusy: boolean;
  i, l: integer;
begin
  // проверяем на доступность действий
  isBusy := false;
  l := LV_Caches.Items.Count;
  for i := 0 to l - 1 do
    if (LV_Caches.Items[i].Selected) then
      if Core.ApplicationsList.IsAppBusy(IApplication(LV_Games.Items[i].Data).GetAppID) then
      begin
        isBusy := true;
        break;
      end;
  PM_Caches_Open.Enabled := (not isBusy) and (LV_Caches.SelCount = 1);
  PM_Caches_Down_Continue.Enabled := not isBusy;
  PM_Caches_Down_Stop.Enabled := isBusy;
  PM_Caches_Patch_CreateArchive.Enabled := not isBusy;
  PM_Caches_Patch_CreatePatch.Enabled := not isBusy;
  PM_Caches_Patch_ApplyPatch.Enabled := not isBusy;
  PM_Caches_Stop.Enabled := isBusy;
  PM_Caches_Validate.Enabled := not isBusy;
  PM_Caches_Correct.Enabled := not isBusy;
  PM_Caches_Delete.Enabled := not isBusy;
  PM_Caches_CreateMiniGCF.Enabled := not isBusy;
  PM_Caches_Properties.Enabled := (not isBusy) and (LV_Caches.SelCount = 1);
end;

procedure TForm_Main.PM_Caches_CorrectClick(Sender: TObject);
begin
  AddWork(LV_Caches, WORK_CORRECT);
end;

procedure TForm_Main.PM_Caches_CreateMiniGCFClick(Sender: TObject);
begin
  AddWork(LV_Caches, WORK_CREATE_MINI_GCF);
end;

procedure TForm_Main.PM_Caches_DeleteClick(Sender: TObject);
begin
  //AddWork(LV_Caches, WORK_DELETE);
end;

procedure TForm_Main.PM_Caches_Down_ContinueClick(Sender: TObject);
begin
  AddWork(LV_Caches, WORK_DOWNLOAD);
end;

procedure TForm_Main.PM_Caches_Down_StopClick(Sender: TObject);
begin
  StopWork(LV_Caches);
end;

procedure TForm_Main.PM_Caches_OpenClick(Sender: TObject);
begin
  Form_CacheViewer.Cache := ICache(LV_Caches.Selected.Data);
  CacheViewerForm.ShowForm();
end;

procedure TForm_Main.PM_Caches_Patch_ApplyPatchClick(Sender: TObject);
begin
  AddWork(LV_Caches, WORK_APPLY_UDATE);
end;

procedure TForm_Main.PM_Caches_Patch_CreateArchiveClick(Sender: TObject);
begin
  AddWork(LV_Caches, WORK_CREATE_ARCHIVE);
end;

procedure TForm_Main.PM_Caches_Patch_CreatePatchClick(Sender: TObject);
begin
  AddWork(LV_Caches, WORK_CREATE_UPDATE);
end;

procedure TForm_Main.PM_Caches_StopClick(Sender: TObject);
begin
  StopWork(LV_Caches);
end;

procedure TForm_Main.PM_Caches_ValidateClick(Sender: TObject);
begin
  AddWork(LV_Caches, WORK_VALIDATE);
end;

procedure TForm_Main.PM_GamesPopup(Sender: TObject);
var
  isBusy: boolean;
  i, l: integer;
begin
  // проверяем на доступность действий
  isBusy := false;
  l := LV_Games.Items.Count;
  for i := 0 to l - 1 do
    if (LV_Games.Items[i].Selected) then
      if Core.ApplicationsList.IsAppBusy(IApplication(LV_Games.Items[i].Data)
          .GetAppID) then
      begin
        isBusy := true;
        break;
      end;
  PM_Games_Launch.Enabled := (not isBusy) and (LV_Games.SelCount = 1);
  PM_Games_CreateStandAlone.Enabled := not isBusy;
  PM_Games_CreateGCF.Enabled := not isBusy;
  PM_Games_Launch.Enabled := not isBusy;
  PM_Games_Loading_Continue.Enabled := not isBusy;
  PM_Games_Loading_Stop.Enabled := isBusy;
  PM_Games_Update_CreateArchive.Enabled := not isBusy;
  PM_Games_Update_CreateUpdate.Enabled := not isBusy;
  PM_Games_Update_ApplyUpdate.Enabled := not isBusy;
  PM_Games_Stop.Enabled := isBusy;
  PM_Games_Validate.Enabled := not isBusy;
  PM_Games_Correct.Enabled := not isBusy;
  PM_Games_Delete.Enabled := not isBusy;
  PM_Games_CreateMiniGCF.Enabled := not isBusy;
  PM_Games_Properties.Enabled := (not isBusy) and (LV_Games.SelCount = 1);
end;

procedure TForm_Main.PM_Games_CorrectClick(Sender: TObject);
begin
  AddWork(LV_Games, WORK_CORRECT);
end;

procedure TForm_Main.PM_Games_CreateGCFClick(Sender: TObject);
var
  i, l, c: integer;
begin
  l:=LV_Games.Items.Count-1;
  c:=0;
  for i:=0 to l do
    if LV_Games.Items[i].Selected then
      inc(c);
  SetLength(Form_AppPrepare.apps, c);
  c:=0;
  for i:=0 to l do
    if LV_Games.Items[i].Selected then
    begin
      Form_AppPrepare.apps[c]:=IApp(LV_Games.Items[i].Data);
      inc(c);
    end;
  AppPrepareForm:=TAppPrepareForm.Create(self);
  AppPrepareForm.ShowModal;
  AppPrepareForm.Free;
end;
{begin
  AddWork(LV_Games, WORK_CREATE_GCF_APPLICATION);
end;   }

procedure TForm_Main.PM_Games_CreateMiniGCFClick(Sender: TObject);
begin
  AddWork(LV_Games, WORK_CREATE_MINI_GCF);
end;

procedure TForm_Main.PM_Games_CreateStandAloneClick(Sender: TObject);
begin
  //AddWork(LV_Games, WORK_CREATE_STAND_ALONE_APPLICATION);
end;

procedure TForm_Main.PM_Games_DeleteClick(Sender: TObject);
begin
//
end;

procedure TForm_Main.PM_Games_LaunchClick(Sender: TObject);
begin
  //AddWork(LV_Games, WORK_LAUNCH);
end;

procedure TForm_Main.PM_Games_Loading_ContinueClick(Sender: TObject);
begin
  AddWork(LV_Games, WORK_DOWNLOAD);
end;

procedure TForm_Main.PM_Games_Loading_StopClick(Sender: TObject);
begin
  StopWork(LV_Games);
end;

procedure TForm_Main.PM_Games_PropertiesClick(Sender: TObject);
begin
  AppPropertiesForm.AppID := uint32(IApplication(LV_Games.Selected.Data).GetAppID);
  Form_AppProperties.ShowForm();
end;

procedure TForm_Main.PM_Games_StopClick(Sender: TObject);
begin
  StopWork(LV_Games);
end;

procedure TForm_Main.PM_Games_Update_ApplyUpdateClick(Sender: TObject);
begin
  AddWork(LV_Games, WORK_APPLY_UDATE);
end;

procedure TForm_Main.PM_Games_Update_CreateArchiveClick(Sender: TObject);
begin
  AddWork(LV_Games, WORK_CREATE_ARCHIVE);
end;

procedure TForm_Main.PM_Games_Update_CreateUpdateClick(Sender: TObject);
begin
  AddWork(LV_Games, WORK_CREATE_UPDATE);
end;

procedure TForm_Main.PM_Games_ValidateClick(Sender: TObject);
begin
  AddWork(LV_Games, WORK_VALIDATE);
end;

type
  pSortItem = ^TSortItem;

  TSortItem = record
    Directions: TIntArray;
    idx: integer;
  end;

procedure TForm_Main.FormActivate(Sender: TObject);
var
  i: integer;
  Work: IWork;
begin
  if Core<>nil then
    Exit;
  LoadCore();
  Core.UI.ReloadControlsText(self);
  SetLength(Sort_Games, LV_Games.Columns.Count);
  for i := 0 to Length(Sort_Games) - 1 do
    Sort_Games[i] := 1;
  SetLength(Sort_Caches, LV_Caches.Columns.Count);
  for i := 0 to Length(Sort_Caches) - 1 do
    Sort_Caches[i] := 1;
  Work := Core.WorksList.AddWork(WORK_LOAD_CORE, nil);
  Core.WorksList.WaitForWork(Work.GetWorkID());
end;

function CustomStrSortProc(lParam1, lParam2: integer; ParamSort: integer)
  : integer; stdcall;
var
  Item1, Item2: TListItem;
  s1, s2: string;
  si: pSortItem;
begin
  si := pSortItem(ParamSort);
  Item1 := TListItem(lParam1);
  Item2 := TListItem(lParam2);
  if si.idx = -1 then
  begin
    s1 := Item1.Caption;
    s2 := Item2.Caption;
  end
  else
  begin
    s1 := Item1.SubItems[si.idx];
    s2 := Item2.SubItems[si.idx];
  end;
  result := CompareStr(s1, s2) * si.Directions[si.idx + 1];
end;

function CustomIntSortProc(lParam1, lParam2: integer; ParamSort: integer)
  : integer; stdcall;
var
  Item1, Item2: TListItem;
  i1, i2: single;
  si: pSortItem;
begin
  si := pSortItem(ParamSort);
  Item1 := TListItem(lParam1);
  Item2 := TListItem(lParam2);
  if si.idx = -1 then
  begin
    i1 := Str2Double(Item1.Caption);
    i2 := Str2Double(Item2.Caption);
  end
  else
  begin
    i1 := integer(Item1.SubItems.Objects[si.idx]);
    i2 := integer(Item2.SubItems.Objects[si.idx]);
  end;
  if (i1 < i2) then
    result := -1 * si.Directions[si.idx + 1]
  else if (i1 > i2) then
    result := +1 * si.Directions[si.idx + 1]
  else
    result := 0;
end;

procedure TForm_Main.FormDestroy(Sender: TObject);
begin
  Core.Free;
  // Mess.ShutdownCore();
end;

procedure TForm_Main.LV_CachesColumnClick(Sender: TObject; Column: TListColumn);
var
  si: TSortItem;
begin
  si.Directions := Sort_Caches;
  si.idx := Column.Index - 1;
  case Column.Index of
    0, 5:
      LV_Caches.CustomSort(CustomStrSortProc, integer(@si));
    1, 2, 3, 4:
      LV_Caches.CustomSort(CustomIntSortProc, integer(@si));
  end;
  Sort_Caches[Column.Index] := Sort_Caches[Column.Index] * -1;
end;

procedure TForm_Main.LV_GamesColumnClick(Sender: TObject; Column: TListColumn);
var
  si: TSortItem;
begin
  si.Directions := Sort_Games;
  si.idx := Column.Index - 1;
  case Column.Index of
    0, 2, 3:
      LV_Games.CustomSort(CustomStrSortProc, integer(@si));
    1:
      LV_Games.CustomSort(CustomIntSortProc, integer(@si));
  end;
  Sort_Games[Column.Index] := Sort_Games[Column.Index] * -1;
end;

end.
