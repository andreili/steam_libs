unit PAKFile;

interface

uses
  USE_Types, USE_Utils, Windows, Package;

type
  TPAKHeader = packed record
    lpSignature: array[0..3] of AnsiChar;
    uiDirectoryOffset,
    uiDirectoryLength: uint;
  end;

  TPAKDirectoryItem = packed record
    lpItemName: array[0..55] of AnsiChar;
    uiItemOffset,
    uiItemLength: uint;
  end;

  TPAKFile = class (TObject)
  {TPackage -->}
    public
      PackageType: TPackageType;
      Stop: boolean;
      fOnError: TOnError;
      fOnErrorObj: TOnErrorObj;
      fOnProgress: TOnProgress;
      fOnProgressObj: TOnProgressObj;
      fFileName: string;
      fStream: TStream;
      fStreamMethods: TStreamMethods;

      class function IsPAK(FileName: string): boolean; virtual;

      constructor Create(); virtual;
      destructor Destroy; override;

      function GetItemSize(Item: integer): TItemSize; virtual;
      function GetItemPath(Item: integer): string; virtual;
      function GetItemByPath(Path: string): integer; virtual;

      function LoadFromFile(FileName: string): boolean; virtual;
      function LoadFromStream(Stream: TStream): boolean; virtual;

      property ItemSize[Item: integer]: TItemSize read GetItemSize;
      property ItemPath[Item: integer]: string read GetItemPath;
      property ItemByPath[Item: string]: integer read GetItemByPath;

      function OpenFile(FileName: string; Access: byte): TStream; overload; virtual;
      function OpenFile(Item: integer; Access: byte): TStream; overload; virtual;
      property StreamMethods: TStreamMethods read fStreamMethods;

    private
      function Read(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize; virtual;
      function Write(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize; virtual;
      procedure SetFileSize(Strm: TStream; Size: TStrmSize); virtual;
      procedure CloseFile(Strm: TStream; Flag: ulong = 0); virtual;
  {<-- TPackage}
    private
      fHeader: TPAKHeader;
      fItemsCount: uint;
      fItems: array of TPAKDirectoryItem;
    public
      property ItemsCount: ulong read fItemsCount;
  end;

implementation

function StreamOnStream_Seek(Strm: TStream; MoveTo: TStrmMove; MoveFrom: TMoveMethod): TStrmSize;
var
  NewPos: DWORD;
begin
  case MoveFrom of
    spBegin: NewPos:=MoveTo;
    spCurrent: NewPos:=Strm.Data.fPosition+MoveTo;
    else NewPos:=Strm.Data.fSize+MoveTo;
  end;
  if NewPos>Strm.Data.fSize then
    Strm.Size:=NewPos;
  Strm.Data.fPosition:=NewPos;
  Result:=NewPos;
end;

function StreamOnStream_GetSize(Strm: TStream): TStrmSize; inline;
begin
  result:=(Strm.Data.Package as TPAKFile).ItemSize[Strm.Data.fHandle].Size;
end;

procedure StreamOnStream_SetSize(Strm: TStream; NewSize: TStrmSize); inline;
begin
  (Strm.Data.Package as TPAKFile).SetFileSize(Strm, NewSize);
end;

function StreamOnStream_Read(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize; inline;
begin
  result:=(Strm.Data.Package as TPAKFile).Read(Strm, @Buffer, Count);
end;

function StreamOnStream_Write(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize; inline;
begin
  result:=(Strm.Data.Package as TPAKFile).Write(Strm, @Buffer, Count);
end;

procedure StreamOnStream_Close(Strm: TStream); inline;
begin
  (Strm.Data.Package as TPAKFile).CloseFile(Strm);
  Strm.Data.fHandle:=ulong(-1);
  Strm.Data.fSize:=0;
  Strm.Data.fPosition:=0;
  Strm.Data.Package:=nil;
end;

procedure StreamOnStream_SetSizeNULL(Strm: TStream; NewSize: TStrmSize); inline;
begin
end;

function StreamOnStream_WriteNULL(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize; inline;
begin
  result:=0;
end;

class function TPAKFile.IsPAK(FileName: string): boolean;
var
  str: TStream;
  Header: TPAKHeader;
begin
  str:=TStream.CreateReadFileStream(FileName);
  str.Read(Header, sizeof(TPAKHeader));
  result:=(Header.lpSignature = 'PACK');
  str.Free;
end;

constructor TPAKFile.Create();
begin
  inherited Create();
  fStreamMethods.fSeek:=StreamOnStream_Seek;
  fStreamMethods.fGetSiz:=StreamOnStream_GetSize;
  fStreamMethods.fSetSiz:=StreamOnStream_SetSize;
  fStreamMethods.fRead:=StreamOnStream_Read;
  fStreamMethods.fWrite:=StreamOnStream_Write;
  fStreamMethods.fClose:=StreamOnStream_Close;
end;

function TPAKFile.LoadFromFile(FileName: string): boolean;
begin
  result:=false;

  fFileName:=FileName;
  fStream:=TStream.CreateReadFileStream(FileName);
  if fStream.Handle=INVALID_HANDLE_VALUE then
    Exit;
  result:=LoadFromStream(fStream);
end;

function TPAKFile.LoadFromStream(Stream: TStream): boolean;
begin
  result:=false;

  fStream:=Stream;
  fStream.Read(fHeader, sizeof(TPAKHeader));
  if fHeader.lpSignature<>'PACK' then
    Exit;
  fItemsCount:=Trunc(fHeader.uiDirectoryLength / sizeof(TPAKDirectoryItem));
  SetLength(fItems, fItemsCount);
  fStream.Seek(fHeader.uiDirectoryOffset, spBegin);
  fStream.Read(fItems[0], fItemsCount*sizeof(TPAKDirectoryItem));

  result:=true;
  PackageType:=PACKAGE_PAK;
end;

destructor TPAKFile.Destroy;
begin
  fStream.Free;
  SetLength(fItems, 0);
end;

function TPAKFile.GetItemSize(Item: integer): TItemSize;
begin
  result.Size:=fItems[Item].uiItemLength;
  result.CSize:=result.Size;
  result.Folders:=0;
  result.CFiles:=1;
  result.Sectors:=0;
end;

function TPAKFile.GetItemPath(Item: integer): string;
begin
  result:=Ansi2Wide(fItems[Item].lpItemName);
end;

function TPAKFile.GetItemByPath(Path: string): integer;
var
  i: integer;
begin
  result:=-1;
  for i:=0 to fItemsCount-1 do
    if CompareStr_NoCase(Path, Ansi2Wide(fItems[i].lpItemName))=0 then
    begin
      result:=i;
      Exit;
    end;
end;

function TPAKFile.Read(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize;
var
  ItemIdx, SizeToRead: uint;
begin
  ItemIdx:=Strm.Data.fHandle;
  SizeToRead:=min(Strm.Size-Strm.Position, Count);
  fStream.Seek(fItems[ItemIdx].uiItemOffset, spBegin);
  result:=fStream.Read(Buffer^, SizeToRead);
end;

function TPAKFile.Write(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize;
{var
  ItemIdx, SizeToRead: uint; }
begin
  {ItemIdx:=Strm.Data.fHandleStrm.Data.fHandle;
  SizeToRead:=min(Strm.Size-Strm.Position, Count);
  fStream.Seek(fItems[ItemIdx].uiItemOffset, spBegin);
  result:=fStream.Write(Buffer^, SizeToRead);  }
  result:=0;
end;

procedure TPAKFile.SetFileSize(Strm: TStream; Size: TStrmSize);
begin
end;

procedure TPAKFile.CloseFile(Strm: TStream; Flag: ulong = 0);
begin
end;

function TPAKFile.OpenFile(FileName: string; Access: byte): TStream;
begin
  result:=OpenFile(ItemByPath[FileName], Access);
end;

function TPAKFile.OpenFile(Item: integer; Access: byte): TStream;
var
  res: TStream;
begin
  res:=TStream.CreateStreamOnStream(@fStreamMethods);
  res.Data.fHandle:=ulong(Item);
  res.Data.Package:=self;
  res.Data.fSize:=(res.Data.Package as TPAKFile).ItemSize[Item].Size;
  res.Data.fPosition:=0;
  if Access<>ACCES_READ then
  begin
    res.Data.fHandle:=INVALID_HANDLE_VALUE;
  end;
  res.Methods.fSetSiz:=StreamOnStream_SetSizeNULL;
  res.Methods.fWrite:=StreamOnStream_WriteNULL;

  result:=res;
end;


end.