unit VPKFile;

interface

uses
  USE_Types, USE_Utils, Windows;

const
  VPK_SIGNATURE = $55aa1234;

type
  TVPKHeader = packed record
    uiSignature,
    uiPaksCount,
    uiDirSize: uint;
  end;

  TVPKDirectoryEntry = packed record
    uiDummy0: uint;
    uiPreloadBytes,
    uiArchiveIndex: ushort;
    uiEntryOffset,
    uiEntryLength: uint;
    uiDummy1: ushort;
  end;

  pVPKDirectoryItem = ^TVPKDirectoryItem;
  TVPKDirectoryItem = packed record
    lpExtention,
    lpPath,
    lpName: AnsiString;
    DirectoryEntry: TVPKDirectoryEntry;
    lpPreloadData: Pointer;
  end;

  pVPKNode = ^TVPKNode;
  TVPKNode = packed record
    Name: AnsiString;
    DirEntry: TVPKDirectoryEntry;
    lpPreloadData: Pointer;
    uiSize,
    ParentIdx,
    FirstChildren,
    NextItem: uint32;
  end;

  TVPKFile = class (TObject)
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

      class function IsVPK(FileName: string): boolean; virtual;

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
    private
      fHeader: TVPKHeader;
      fItemsCount: integer;
      fArchiveCount: integer;
      fTmpItems: array of TVPKDirectoryItem;
      fItems: array of TVPKNode;
      fArchives: array of TStream;

      procedure MakeTree();
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
  result:=(Strm.Data.Package as TVPKFile).ItemSize[Strm.Data.fHandle].Size;
end;

procedure StreamOnStream_SetSize(Strm: TStream; NewSize: TStrmSize); inline;
begin
  (Strm.Data.Package as TVPKFile).SetFileSize(Strm, NewSize);
end;

function StreamOnStream_Read(Strm: TStream; var Buffer; Count: TStrmSize): TStrmSize; inline;
begin
  result:=(Strm.Data.Package as TVPKFile).Read(Strm, @Buffer, Count);
end;

function StreamOnStream_Write(Strm: TStream; const Buffer; Count: TStrmSize): TStrmSize; inline;
begin
  result:=(Strm.Data.Package as TVPKFile).Write(Strm, @Buffer, Count);
end;

procedure StreamOnStream_Close(Strm: TStream); inline;
begin
  (Strm.Data.Package as TVPKFile).CloseFile(Strm);
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

class function TVPKFile.IsVPK(FileName: string): boolean;
var
  str: TStream;
  Header: TVPKHeader;
begin
  str:=TStream.CreateReadFileStream(FileName);
  str.Read(Header, sizeof(TVPKHeader));
  str.Free;
  result:=(Header.uiSignature = VPK_SIGNATURE);
end;

constructor TVPKFile.Create();
begin
  inherited Create();
  fArchiveCount:=0;
  fStreamMethods.fSeek:=StreamOnStream_Seek;
  fStreamMethods.fGetSiz:=StreamOnStream_GetSize;
  fStreamMethods.fSetSiz:=StreamOnStream_SetSize;
  fStreamMethods.fRead:=StreamOnStream_Read;
  fStreamMethods.fWrite:=StreamOnStream_Write;
  fStreamMethods.fClose:=StreamOnStream_Close;
end;

destructor TVPKFile.Destroy;
var
  i: integer;
begin
  fStream.Free;
  if fItemsCount>0 then
    for i:=0 to fItemsCount-1 do
      FreeMem(fItems[i].lpPreloadData, fItems[i].DirEntry.uiPreloadBytes);
  SetLength(fItems, 0);
  if fArchiveCount>0 then
    for i:=0 to fArchiveCount-1 do
      fArchives[i].Free;
  SetLength(fArchives, 0);
end;

function TVPKFile.LoadFromFile(FileName: string): boolean;
begin
  result:=false;

  fFileName:=FileName;
  fStream:=TStream.CreateReadFileStream(FileName);
  if fStream.Handle=INVALID_HANDLE_VALUE then
    Exit;
  result:=LoadFromStream(fStream);
end;

function TVPKFile.LoadFromStream(Stream: TStream): boolean;
var
  ArchiveFileName: string;
  ext, path, name: AnsiString;
  i, n: integer;
  tmpStream: TStream;
  b: pByte;
  c: AnsiChar;
  tmp: TVPKDirectoryEntry;
begin
  result:=false;

  fStream:=Stream;
  fStream.Read(fHeader, sizeof(TVPKHeader));
  if fHeader.uiSignature<>VPK_SIGNATURE then
    Exit;
  GetMem(b, fHeader.uiDirSize);
  fStream.Read(b^, fHeader.uiDirSize);
  tmpStream:=TStream.CreateMemoryStreamEx(b, fHeader.uiDirSize);

  // geting items count
  i:=0;
  while tmpStream.Position<tmpStream.Size do
  begin
    // extension
    //ext:=tmpStream.ReadStrZ();
    n:=-1;
    repeat
      tmpStream.Read(c, 1);
      inc(n);
    until c=#0;
    if n=0 then
      break;
    while true do
    begin
      // path
      //path:=tmpStream.ReadStrZ();
      n:=-1;
      repeat
        tmpStream.Read(c, 1);
        inc(n);
      until c=#0;
      if n=0 then
        break;
      while true do
      begin
        // file name
        //name:=tmpStream.ReadStrZ();
        n:=-1;
        repeat
          tmpStream.Read(c, 1);
          inc(n);
        until c=#0;
        if n=0 then
          break;
        tmpStream.Read(tmp, sizeof(TVPKDirectoryEntry));
        tmpStream.Seek(tmp.uiPreloadBytes, spCurrent);
        inc(i);
      end;
    end;
  end;

  fItemsCount:=i;
  SetLength(fTmpItems, fItemsCount);
  i:=0;
  tmpStream.Seek(0, spBegin);
  while tmpStream.Position<tmpStream.Size do
  begin
    // extension
    ext:=tmpStream.ReadStrZ();
    if ext='' then
      break;
    while true do
    begin
      // path
      path:=tmpStream.ReadStrZ();
      if path='' then
        break;
      while true do
      begin
        // file name
        name:=tmpStream.ReadStrZ();
        if name='' then
          break;

        fTmpItems[i].lpExtention:=ext;
        fTmpItems[i].lpPath:=path;
        fTmpItems[i].lpName:=name;
        tmpStream.Read(fTmpItems[i].DirectoryEntry, sizeof(TVPKDirectoryEntry));
        if (fTmpItems[i].DirectoryEntry.uiPreloadBytes>0) then
        begin
          GetMem(fTmpItems[i].lpPreloadData, fTmpItems[i].DirectoryEntry.uiPreloadBytes);
          tmpStream.Read(fTmpItems[i].lpPreloadData^, fTmpItems[i].DirectoryEntry.uiPreloadBytes);
        end;
        if (fTmpItems[i].DirectoryEntry.uiArchiveIndex+1>fArchiveCount) then
          fArchiveCount:=fTmpItems[i].DirectoryEntry.uiArchiveIndex+1;

        inc(i);
      end;
    end;
  end;
  tmpStream.Free;
  //FreeMem(b, fHeader.uiDirSize);

  if (fArchiveCount>0) and (fFileName<>'') then
  begin
    SetLength(fArchives, fArchiveCount);
    ArchiveFileName:=fFileName;
    StrReplace(ArchiveFileName, '_dir.vpk', '');

    for i:=0 to fArchiveCount-1 do
      fArchives[i]:=TStream.CreateReadFileStream(ArchiveFileName+'_'+Int2StrEx(i, 3)+'.vpk');
  end;

  MakeTree();
  result:=true;
  PackageType:=PACKAGE_VPK;
end;

procedure TVPKFile.MakeTree();
var
  i, FirstNull: integer;

  function AddItem(ItemName: AnsiString; ParentIdx: uint): uint;
  var
    idx: uint;
  begin
    idx:=fItems[ParentIdx].FirstChildren;
    while (idx<>INVALID_HANDLE_VALUE) do
    begin
      if (fItems[idx].Name=ItemName) then
      begin
        result:=idx;
        Exit;
      end;
      if fItems[idx].NextItem=INVALID_HANDLE_VALUE then
      begin
        // add new node
        SetLength(fItems, Length(fItems)+1);
        fItems[FirstNull].Name:=ItemName;
        fItems[FirstNull].uiSize:=0;
        fItems[FirstNull].ParentIdx:=fItems[idx].ParentIdx;
        fItems[FirstNull].FirstChildren:=INVALID_HANDLE_VALUE;
        fItems[FirstNull].NextItem:=INVALID_HANDLE_VALUE;
        fItems[idx].NextItem:=FirstNull;
        result:=FirstNull;
        inc(FirstNull);
        Exit;
      end;
      idx:=fItems[idx].NextItem;
    end;
    SetLength(fItems, Length(fItems)+1);
    fItems[FirstNull].Name:=ItemName;
    fItems[FirstNull].uiSize:=0;
    fItems[FirstNull].ParentIdx:=ParentIdx;
    fItems[FirstNull].FirstChildren:=INVALID_HANDLE_VALUE;
    fItems[FirstNull].NextItem:=INVALID_HANDLE_VALUE;
    fItems[ParentIdx].FirstChildren:=FirstNull;
    result:=FirstNull;
    inc(FirstNull);
  end;
  procedure AddNode(Item: pVPKDirectoryItem; ParentIdx: uint);
  var
    s, dir: string;
    cNode: uint;
  begin
    cNode:=ParentIdx;
    s:=Item^.lpPath;
    repeat
      dir:=Parse(s, '/');
      if dir<>'' then
        cNode:=AddItem(dir, cNode);
    until dir='';
    cNode:=AddItem(Item^.lpName+'.'+Item^.lpExtention, cNode);
    fItems[cNode].uiSize:=Item^.DirectoryEntry.uiEntryLength;
    Move(Item^.DirectoryEntry, fItems[cNode].DirEntry, sizeof(TVPKDirectoryEntry));
    fItems[cNode].lpPreloadData:=Item^.lpPreloadData;
  end;
begin
  SetLength(fItems, 1);
  fItems[0].Name:='';
  fItems[0].uiSize:=0;
  fItems[0].ParentIdx:=INVALID_HANDLE_VALUE;
  fItems[0].FirstChildren:=INVALID_HANDLE_VALUE;
  fItems[0].NextItem:=INVALID_HANDLE_VALUE;
  FirstNull:=1;

  for i:=0 to fItemsCount-1 do
    AddNode(@fTmpItems[i], 0);

  SetLength(fTmpItems, 0);
  fItemsCount:=Length(fItems);
end;

function TVPKFile.GetItemSize(Item: integer): TItemSize;
  function Recurse(Idx: integer): TItemSize;
  var
    f: TItemSize;
  begin
    FillChar(result, sizeof(TItemSize), 0);
    if fItems[idx].FirstChildren<>INVALID_HANDLE_VALUE then
    begin
      Idx:=fItems[idx].FirstChildren;
      while Idx>0 do
      begin
        if fItems[idx].FirstChildren<>INVALID_HANDLE_VALUE then
          inc(result.Folders, 1);
        f:=Recurse(Idx);
        inc(result.Size, f.Size);
        inc(result.CSize, f.CSize);
        inc(result.Folders, f.Folders);
        inc(result.Files, f.Files);
        inc(result.CFiles, f.CFiles);
        inc(result.Sectors, f.Sectors);
        Idx:=fItems[idx].NextItem;
      end;
    end
      else
    begin
      result.Size:=fItems[idx].uiSize;
      result.Sectors:=0;
      result.Files:=1;
      result.CSize:=result.Size;
      result.CFiles:=1;
    end;
  end;
begin
  result:=Recurse(Item);
end;

function TVPKFile.GetItemPath(Item: integer): string;
var
  res: AnsiString;
begin
  res:=fItems[Item].Name;
  Item:=fItems[Item].ParentIdx;
  while (Item>-1) do
  begin
    res:=fItems[Item].Name+'\'+res;
    Item:=fItems[Item].ParentIdx;
  end;
  Delete(res, 1, 1);
{$IFDEF UNICODE}
  result:=Ansi2Wide(res);
{$ELSE}
  result:=res;
{$ENDIF}
end;

function TVPKFile.GetItemByPath(Path: string): integer;
  function Recurse(FN: string; Node: uint): integer;
  var
    path: string;
  begin
    result:=-1;
    if FN='' then
    begin
      result:=Node;
      Exit;
    end;
    path:=Parse(FN, '\');
    Node:=fItems[Node].FirstChildren;
    while Node<>INVALID_HANDLE_VALUE do
    begin
      if CompareStr(path, Wide2Ansi(fItems[Node].Name))=0 then
      begin
        result:=Recurse(FN, Node);
        Exit;
      end;
      Node:=fItems[Node].NextItem;
    end;
  end;
begin
  result:=Recurse(Path, 0);
end;

function TVPKFile.Read(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize;
var
  ItemIdx, SizeToRead: uint;
begin
  ItemIdx:=Strm.Data.fHandle;
  SizeToRead:=0;
  if (Strm.Position<fItems[ItemIdx].DirEntry.uiPreloadBytes) then
  begin
    SizeToRead:=min(fItems[ItemIdx].DirEntry.uiPreloadBytes-Strm.Position, Count);
    Move(pByte(uint(fItems[ItemIdx].lpPreloadData)+Strm.Position)^, Buffer^, SizeToRead);
    inc(Buffer, SizeToRead);
    dec(Count, SizeToRead);
  end;
  SizeToRead:=min(Strm.Size-Strm.Position, Count);
  fArchives[fItems[ItemIdx].DirEntry.uiArchiveIndex].Seek(fItems[ItemIdx].DirEntry.uiEntryOffset, spBegin);
  result:=fArchives[fItems[ItemIdx].DirEntry.uiArchiveIndex].Read(Buffer^, SizeToRead);
end;

function TVPKFile.Write(Strm: TStream; Buffer: pByte; Count: TStrmSize): TStrmSize;
begin
  result:=0;
end;

procedure TVPKFile.SetFileSize(Strm: TStream; Size: TStrmSize);
begin
end;

procedure TVPKFile.CloseFile(Strm: TStream; Flag: ulong = 0);
begin
end;

function TVPKFile.OpenFile(FileName: string; Access: byte): TStream;
begin
  result:=OpenFile(ItemByPath[FileName], Access);
end;

function TVPKFile.OpenFile(Item: integer; Access: byte): TStream;
var
  res: TStream;
begin
  res:=TStream.CreateStreamOnStream(@fStreamMethods);
  res.Data.fHandle:=ulong(Item);
  res.Data.Package:=self;
  res.Data.fSize:=(res.Data.Package as TVPKFile).ItemSize[Item].Size;
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