unit Int_Applications;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils, CDRFile;

{$I defines.inc}

type
  {$IFDEF SL_ONE}
  TApplication = class (CBaseClass)
  {$ELSE}
  TApplication = class (TObject)
  {$ENDIF}
      function GetEncoding(): EEncoding; overload; virtual; stdcall;
      function GetType(): EInterfaceType; overload; virtual; stdcall;
      function Init(): boolean; overload; virtual; stdcall;
      procedure DeInit(); overload; virtual; stdcall;

      procedure BuildCachesList(); virtual; stdcall;
      function GetAppID(): uint32; virtual; stdcall;
      function GetName(): pChar; virtual; stdcall;
      function GetFolderName(): pChar; virtual; stdcall;
      function GetLastVersion(): uint32; virtual; stdcall;
      function GetUserDefinedRecord(Name: pAnsiChar): pAnsiChar; virtual; stdcall;

      function GetWork(): IWork; virtual; stdcall;
    public
      fAppRec: TAppRecord;
    private
      fCaches: TCachesArray;
      fAppType: EApplicationType;
  end;

  {$IFDEF SL_ONE}
  TApp = class (TApplication, IApp)
  {$ELSE}
  TApp = class (TApplication)
  {$ENDIF}
      function GetEncoding(): EEncoding; override;
      function GetType(): EInterfaceType; override;
      function Init(): boolean; override;
      procedure DeInit(); override;

      function GetAppType(): EApplicationType; virtual; stdcall;
      function IsLoaded(): boolean; virtual; stdcall;
      function IsIncompleted(): boolean; virtual; stdcall;

      function GetVersion(): uint32; virtual; stdcall;
      function GetCompletion(): single; virtual; stdcall;
      function GetSize(): uint64; virtual; stdcall;
      function GetCompleted(): uint64; virtual; stdcall;
      function GetCaches(): TCachesArray; virtual; stdcall;

      function GetDeveloperName(): pChar; virtual; stdcall;
      function GetHomepageURL(): pChar; virtual; stdcall;
      function GetCMDLine(): pChar; virtual; stdcall;
      function GetIconString(): pChar; virtual; stdcall;
      function GetRecommendEmulator(): EEmulator; virtual; stdcall;
      function GetAppSize(IsStandAlone: boolean): Int64; virtual; stdcall;
  end;

  {$IFDEF SL_ONE}
  TCache = class (TApplication, ICache)
  {$ELSE}
  TCache = class (TApplication)
  {$ENDIF}
      function GetEncoding(): EEncoding; override;
      function GetType(): EInterfaceType; override;
      function Init(): boolean; override;
      procedure DeInit(); override;

      function GetAppType(): EApplicationType; virtual; stdcall;
      function IsLoaded(): boolean; virtual; stdcall;
      function IsIncompleted(): boolean; virtual; stdcall;

      function GetVersion(): uint32; virtual; stdcall;
      function GetCompletion(): single; virtual; stdcall;
      function GetSize(): uint64; virtual; stdcall;
      function GetCompleted(): uint64; virtual; stdcall;
      function GetCaches(): TCachesArray; virtual; stdcall;
      procedure CreateFoldersList(Root: Pointer; OnItem: TAddTreeItemProc); virtual; stdcall;
      procedure CreateFilesList(Item: uint32; OnItem: TAddFileItemProc); virtual; stdcall;

      function GetCacheType(): ECacheType; virtual; stdcall;
      function GetFilesCount(): uint32; virtual; stdcall;
      function GetFoldersCount(): uint32; virtual; stdcall;
      function Open(): IFileCache; virtual; stdcall;
      procedure Close(); virtual; stdcall;
      function GetCacheSize(IsStandAlone: boolean): Int64; virtual; stdcall;
    private
      fCache: record
        IsNCF: boolean;
        IsIncompleted: boolean;
        Version: uint32;
        Completion: single;
        Files,
        Folders: uint32;
        Size,
        CompletedSize: uint64;
      end;
      fFile: IFileCache;
  end;

implementation

function TApplication.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TApplication.GetType(): EInterfaceType;
begin
  result:=INTERFACE_APPLICATION;
end;

function TApplication.Init(): boolean;
begin
  result:=true;
end;

procedure TApplication.DeInit();
begin
  //fAppRec.Free;
end;

procedure TApplication.BuildCachesList();
var
  i, l: integer;
begin
  if (fAppType=APPLICATION_CACHE) then
  begin
  end
    else
  begin
    l:=Length(fAppRec.FilesystemsRecords);
    SetLength(fCaches, l);
    if (l>0) then
      for i:=0 to l-1 do
      begin
        fCaches[i]:=Core.ApplicationsList.GetCache(fAppRec.FilesystemsRecords[i].AppId);
        {if fCaches[i]=nil then
          writeln('');}
      end;
  end;
end;

function TApplication.GetAppID(): uint32;
begin
  result:=fAppRec.AppId;
end;

function TApplication.GetName(): pChar;
begin
  result:=pChar(Ansi2Wide(fAppRec.Name));
end;

function TApplication.GetFolderName(): pChar;
begin
  result:=pChar(Ansi2Wide(fAppRec.InstallDirName));
end;

function TApplication.GetLastVersion(): uint32;
begin
  result:=fAppRec.CurrentVersionId;
end;

function TApplication.GetUserDefinedRecord(Name: pAnsiChar): pAnsiChar;
begin
  result:=pAnsiChar(fAppRec.UserRecord[Name]);
end;

function TApplication.GetWork(): IWork;
var
  res: IWork;
  state: EWorkState;
begin
  res:=Core.WorksList.GetWorkFromApplicationID(self.GetAppID());
  if (res<>nil) then
  begin
    state:=res.GetState();
    case state of
      WORK_STATE_OK, WORK_STATE_STOP, WORK_STATE_ERROR: res:=nil;
    end;
  end;
  result:=res;
end;

function TCache.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TCache.GetType(): EInterfaceType;
begin
  result:=INTERFACE_CACHE;
end;

function TCache.Init(): boolean;
var
  fn: string;
  ItemSize: TItemSize;
begin
  result:=true;
  fAppType:=APPLICATION_CACHE;
  FillChar(fCache, sizeof(fCache), 0);
  fCache.IsNCF:=(fAppRec.AppOfManifestOnlyCache<>0);
  fn:=string(Core.Settings.GetStringValue(VALUE_CACHE_PATH))+GetFolderName();
  if fCache.IsNCF then fn:=fn+'.ncf'
    else fn:=fn+'.gcf';

  fFile:=IFileCache(Core.Files.LoadFromFile(pChar(fn)));
  if (fFile<>nil) then
  begin
    fCache.Version:=fFile.GetVersion();
    ItemSize:=fFIle.GetItemSize(ITEM_ROOT);
    fCache.Files:=ItemSize.Files;
    fCache.Folders:=ItemSize.Folders;
    fCache.Size:=ItemSize.Size;
    fCache.CompletedSize:=ItemSize.CSize;
    fCache.Files:=ItemSize.Files;
    fCache.Completion:=fFile.GetCompletion(ITEM_ROOT);
    fFile.DeInit();
    fFile:=nil;
  end
    else
  begin
    fCache.IsIncompleted:=true;
    fCache.Version:=fAppRec.CurrentVersionId;
    fCache.Completion:=-1;
    fCache.Files:=0;
    fCache.Size:=fAppRec.MinCacheFileSizeMB*MBYTE;
  end;
end;

procedure TCache.DeInit();
begin
end;

function TCache.GetAppType(): EApplicationType;
begin
  result:=fAppType;
end;

function TCache.IsLoaded(): boolean;
begin
  result:=(fCache.Files>0);
end;

function TCache.IsIncompleted(): boolean;
begin
  result:=(fCache.Completion>-1) and (fCache.Completion<1);
end;

function TCache.GetCacheType(): ECacheType;
begin
  if fCache.IsNCF then result:=CACHE_NCF else result:=CACHE_GCF;
end;

procedure TCache.CreateFoldersList(Root: Pointer; OnItem: TAddTreeItemProc);
begin
  Open();
  if fFile<>nil then
    fFile.CreateFoldersList(Root, OnItem);
end;

procedure TCache.CreateFilesList(Item: uint32; OnItem: TAddFileItemProc);
begin
  fFile.CreateFilesList(Item, OnItem);
end;

function TCache.GetVersion(): uint32;
begin
  result:=fCache.Version;
end;

function TCache.GetCompletion(): single;
var
  size: uint64;
begin
  size:=GetSize();
  if size>0 then  result:=GetCompleted()/size
    else result:=1;
  if result>1 then
    result:=1;
  if (result=0) and (fCache.Files=0) then
    result:=-1;
end;

function TCache.GetSize(): uint64;
begin
  result:=fCache.Size;
end;

function TCache.GetCompleted(): uint64;
begin
  result:=fCache.CompletedSize;
end;

function TCache.GetCaches(): TCachesArray;
begin
  SetLength(result, 1);
  Move(self, result[0], sizeof(ICache));
end;

function TCache.GetFilesCount(): uint32;
begin
  result:=fCache.Files;
end;

function TCache.GetFoldersCount(): uint32;
begin
  result:=fCache.Folders;
end;

function TCache.Open(): IFileCache;
var
  ext: string;
begin
  if fFile<>nil then
  begin
    result:=fFile;
    Exit;
  end;
  case GetCacheType() of
    CACHE_GCF: ext:='.gcf';
    CACHE_NCF: ext:='.ncf';
    CACHE_OTHER: ext:='.acf';
  end;
  fFile:=IFileCache(Core.Files.LoadFromFile(pChar(string(Core.Settings.GetStringValue(VALUE_CACHE_PATH))+GetFolderName()+ext)));
  result:=fFile;
end;

procedure TCache.Close();
begin
  if fFile<>nil then
    fFile.DeInit();
  fFile:=nil;
end;

function TCache.GetCacheSize(IsStandAlone: boolean): Int64;
begin
  if IsStandAlone then result:=GetSize()
    else result:=0;
end;




function TApp.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TApp.GetType(): EInterfaceType;
begin
  result:=INTERFACE_APP;
end;

function TApp.Init(): boolean;
begin
  result:=true;
  if fAppRec.IsMedia() then fAppType:=APPLICATION_MEDIA
  else if fAppRec.IsTool() then fAppType:=APPLICATION_TOOLS
  else fAppType:=APPLICATION_GAME;
end;

procedure TApp.DeInit();
begin
end;

function TApp.GetAppType(): EApplicationType;
begin
  result:=fAppType;
end;

function TApp.IsLoaded(): boolean;
var
  i, l: integer;
  res: boolean;
begin
  res:=false;
  l:=Length(fCaches);
  if l>0 then
    for i:=0 to l-1 do
    begin
      if ((fCaches[i]<>nil) and (fCaches[i].IsLoaded())) then
        res:=true;
    end;
  if (res) then
  begin
    if (l=1) and (fCaches[0].GetAppID()=7) then
      res:=false;
    if fAppRec.IsMedia() then
    begin
      res:=(fCaches[0].IsLoaded());
    end;
  end;
  result:=res;
end;

function TApp.IsIncompleted(): boolean;
var
  i, l: integer;
  res: boolean;
begin
  res:=false;
  l:=Length(fCaches);
  if l>0 then
    for i:=0 to l-1 do
    begin
      if (fCaches[i].GetCompletion>-1) then
        if fCaches[i].GetCompletion()<1 then res:=true;
    end;
  result:=res;
end;

function TApp.GetVersion(): uint32;
begin
  result:=fAppRec.CurrentVersionId;
end;

function TApp.GetCompletion(): single;
var
  size: uint64;
begin
  size:=GetSize();
  if size>0 then  result:=GetCompleted()/size
    else result:=1;
  if result>1 then
    result:=1;
end;

function TApp.GetSize(): uint64;
var
  i, l: integer;
  res: uint64;
begin
  res:=0;
  l:=Length(fCaches);
  if l>0 then
    for i:=0 to l-1 do
      if (fCaches[i]<>nil) then
        res:=res+fCaches[i].GetSize();
  result:=res;
end;

function TApp.GetCompleted(): uint64;
var
  i, l: integer;
  res: uint64;
begin
  res:=0;
  l:=Length(fCaches);
  if l>0 then
    for i:=0 to l-1 do
      if (fCaches[i]<>nil) then
        res:=res+fCaches[i].GetCompleted();
  result:=res;
end;

function TApp.GetCaches(): TCachesArray;
var
  l: integer;
begin
  l:=Length(fCaches);
  SetLength(result, l);
  Move(fCaches[0], result[0], l*sizeof(ICache));
end;

function TApp.GetDeveloperName(): pChar;
begin
  result:=pChar(Ansi2Wide(fAppRec.UserRecord['developer']));
end;

function TApp.GetHomepageURL(): pChar;
begin
  result:=pChar(Ansi2Wide(fAppRec.UserRecord['homepage']));
end;

function TApp.GetCMDLine(): pChar;
begin
  result:=pChar(Ansi2Wide(fAppRec.LaunchOptionRecords[fAppRec.VersionsRecord[fAppRec.CurrentVersionId].LaunchOptionIdsRecord[0]].CommandLine));
end;

function TApp.GetIconString(): pChar;
begin
  result:='';
end;

function TApp.GetRecommendEmulator(): EEmulator;
begin
  result:=EMULATOR_REV;
end;

function TApp.GetAppSize(IsStandAlone: boolean): Int64;
var
  i, l: integer;
  caches: TCachesArray;
  res: int64;
begin
  res:=0;
  caches:=GetCaches();
  l:=Length(caches);
  for i:=0 to l-1 do
    res:=res+caches[i].GetCacheSize(IsStandAlone);
  result:=res;
end;

end.
