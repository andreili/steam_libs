unit Int_FileFormat_GCF;

interface

uses
  Windows, SL_Interfaces, USE_Types, USE_Utils, GCFFile;

{$I defines.inc}

type
  {$IFDEF SL_ONE}
  TFileFormat = class (CBaseClass, IFileFormat)
  {$ELSE}
  TFileFormat = class (TObject)
  {$ENDIF}
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function TestFile(FileName: pChar): boolean; virtual; stdcall;
    function TestStream(Stream: TStream): boolean; virtual; stdcall;
    function LoadFromFile(FileName: pChar): IFile; virtual; stdcall;
    function LoadFromStream(Stream: TStream): IFile; virtual; stdcall;
  end;

  {$IFDEF SL_ONE}
  TFileGCF = class (CBaseClass, IFileCache)
  {$ELSE}
  TFileGCF = class (TObject)
  {$ENDIF}
    OnErrorObj: TOnErrorObj;
    OnProgressObj: TOnProgressObj;
    function GetEncoding(): EEncoding; virtual; stdcall;
    function GetType(): EInterfaceType; virtual; stdcall;
    function Init(): boolean; virtual; stdcall;
    procedure DeInit(); virtual; stdcall;
    function LoadFromFile(FileName: pChar): boolean; virtual; stdcall;
    function LoadFromStream(Stream: TStream): boolean; virtual; stdcall;
    function GetMainStream(): TStream; virtual; stdcall;
    function GetFileType(): EFileType; virtual; stdcall;
    function OpenFile(FileName: pChar; Mode: byte): TStream; virtual; stdcall;

    function GetItemName(Item: uint32): pChar; virtual;stdcall;
    function GetItemByName(Name: pChar): uint32; virtual; stdcall;
    function Validate(Item: uint32): EValidateResult; virtual; stdcall;
    function Correct(Item: uint32): EValidateResult; virtual; stdcall;
    function Extract(Item: uint32; Dst: pChar): EValidateResult; virtual; stdcall;
    function GetVersion(): uint; virtual; stdcall;
    function GetItemSize(Item: uint32): TItemSize; virtual; stdcall;
    function GetItemFlags(Item: uint32): uint32; virtual; stdcall;
    function GetCompletion(Item: uint32): single; virtual; stdcall;
    function CreateArchive(): pChar; virtual; stdcall;
    function CreateUpdate(ArchiveName: pChar): boolean; virtual; stdcall;
    function ApplyUpdae(UpdateName: pChar): boolean; virtual; stdcall;
    procedure CreateFoldersList(Item: Pointer; OnItem: TAddTreeItemProc); virtual; stdcall;
    procedure CreateFilesList(Item: uint32; OnItem: TAddFileItemProc); virtual; stdcall;
  private
    fGCF: TGCFFile;
  public
  end;

{$IFDEF SL_ONE}
function LoadInterface(): IFileFormat; stdcall;
{$ELSE}
function LoadInterface(): TObject; stdcall;
{$ENDIF}

implementation

{$IFDEF SL_ONE}
function LoadInterface(): IFileFormat;
{$ELSE}
function LoadInterface(): TObject;
{$ENDIF}
begin
  result:=TFileFormat.Create();
end;

function TFileFormat.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TFileFormat.GetType(): EInterfaceType;
begin
  result:=INTERFACE_FILE_FORMAT;
end;

function TFileFormat.Init(): boolean;
begin
  result:=true;
end;

procedure TFileFormat.DeInit();
begin
end;

function TFileFormat.TestFile(FileName: pChar): boolean;
begin
  result:=TGCFFile.IsGCF(FileName);
end;

function TFileFormat.TestStream(Stream: TStream): boolean;
begin
  result:=TGCFFile.IsGCF(Stream);
end;

function TFileFormat.LoadFromFile(FileName: pChar): IFile;
begin
  result:=IFileCache(TFileGCF.Create());
  result.Init();
  if not result.LoadFromFile(FileName) then
  begin
    result.DeInit;
    result:=nil;
  end;
end;

function TFileFormat.LoadFromStream(Stream: TStream): IFile;
begin
  result:=IFileCache(TFileGCF.Create());
  result.Init();
  if not result.LoadFromStream(Stream) then
  begin
    result.DeInit;
    result:=nil;
  end;
end;



function TFileGCF.GetEncoding(): EEncoding;
begin
  result:=ENCODING_UNICODE;
end;

function TFileGCF.GetType(): EInterfaceType;
begin
  result:=INTERFACE_FILE;
end;

function TFileGCF.Init(): boolean;
begin
  result:=true;
end;

procedure TFileGCF.DeInit();
begin
  fGCF.Free;
end;

function TFileGCF.LoadFromFile(FileName: pChar): boolean;
begin
  result:=false;
  fGCF:=TGCFFile.Create();
  if (not fGCF.LoadFromFile(FileName)) then
  begin
    fGCF.Free;
    Exit;
  end;
  fGCF.OnErrorObj:=OnErrorObj;
  fGCF.OnProgressObj:=OnProgressObj;
  result:=true;
end;

function TFileGCF.LoadFromStream(Stream: TStream): boolean;
begin
  result:=false;
  fGCF:=TGCFFile.Create();
  if (not fGCF.LoadFromStream(Stream)) then
  begin
    fGCF.Free;
    Exit;
  end;
  fGCF.OnErrorObj:=OnErrorObj;
  fGCF.OnProgressObj:=OnProgressObj;
  result:=true;
end;

function TFileGCF.GetMainStream(): TStream;
begin
  result:=fGCF.fStream;
end;

function TFileGCF.GetFileType(): EFileType;
begin
  result:=FILE_CACHE;
end;

function TFileGCF.OpenFile(FileName: pChar; Mode: byte): TStream;
begin
  result:=fGCF.OpenFile(FileName, Mode);
end;

function TFileGCF.GetItemName(Item: uint32): pChar;
begin
  result:=pChar(fGCF.ItemPath[Item]);
end;

function TFileGCF.GetItemByName(Name: pChar): uint32;
begin
  result:=fGCF.ItemByPath[Name];
end;

function TFileGCF.Validate(Item: uint32): EValidateResult;
begin
  result:=EValidateResult(fGCF.ValidateItem(Item));
end;

function TFileGCF.Correct(Item: uint32): EValidateResult;
begin
  result:=EValidateResult(fGCF.CorrectItem(Item));
end;

function TFileGCF.Extract(Item: uint32; Dst: pChar): EValidateResult;
begin
  result:=EValidateResult(fGCF.ExtractItem(Item, Dst));
end;

function TFileGCF.GetVersion(): uint;
begin
  result:=fGCF.CacheVersion;
end;

function TFileGCF.GetItemSize(Item: uint32): TItemSize;
begin
  result:=fGCF.ItemSize[Item];
end;

function TFileGCF.GetItemFlags(Item: uint32): uint32;
begin
  result:=fGCF.GetFlags(Item);
end;

function TFileGCF.GetCompletion(Item: uint32): single;
begin
  result:=fGCF.GetCompletion(Item);
end;

function TFileGCF.CreateArchive(): pChar;
begin
  result:=pChar(fGCF.CreateInfo());
end;

function TFileGCF.CreateUpdate(ArchiveName: pChar): boolean;
begin
  result:=fGCF.CreatePatch(ArchiveName);
end;

function TFileGCF.ApplyUpdae(UpdateName: pChar): boolean;
begin
  //result:=fGCF.CreatePatch(ArchiveName);
  result:=false;
end;

procedure TFileGCF.CreateFoldersList(Item: Pointer; OnItem: TAddTreeItemProc);
begin
  fGCF.CreateItemsTree(0, Item, OnItem);
end;

procedure TFileGCF.CreateFilesList(Item: uint32; OnItem: TAddFileItemProc);
begin
  fGCF.CreateItemsList(Item, OnItem);
end;

end.
