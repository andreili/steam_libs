unit BLOBFile;

interface

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils;

const
  NODE_MAGIC            = $5001;
  NODE_COMPRESSED_MAGIC = $4301;

type
  pBLOBDataHeader = ^TBLOBDataHeader;
  TBLOBDataHeader = packed record
    NameLen: uint16;
    DataLen: uint32;
  end;

  TBLOBCompressedDataHeader = packed record
    UncompressedSize: uint32;
    unknown1: uint32;
    unknown2: uint16;
  end;

  pBLOBNodeHeader = ^TBLOBNodeHeader;
  TBLOBNodeHeader = packed record
    Magic: uint16;
    Size: uint32;
    StackSize: uint32;
  end;

  pBLOBNode = ^TBLOBNode;
  TBLOBNode = class
    private
      fIsData: boolean;
      fName: AnsiString;
      fData: Pointer;
      fNameLen: uint32;
      fDataLen: uint32;
      fSlackLen: uint32;
      fChildrens: array of TBLOBNode;
      procedure DeserializeFromMem(Mem: pByte);
      function GetChildrensSize(): uint32;
      function SerializeToMem(var Mem: pByte; IsCompressed: boolean = false): uint32;
      function GetChildrensCount(Mem: pByte): integer; inline;

      procedure SetName(Value: AnsiString);
      function GetNode(Name: AnsiString): pBLOBNode;
      procedure SetNode(Name: AnsiString; Value: pBLOBNode);
      function GetNodeIdx(Name: uint32): pBLOBNode;
      procedure SetNodeIdx(Name: uint32; Value: pBLOBNode);
      function ChildrensCount(): uint32;
      function GetChildrenIdx(Idx: uint32): pBLOBNode;
    public
      constructor Create();
      destructor Destroy(); override;
      procedure DeserializeFromStream(Stream: TStream); //inline;
      procedure SerializeToStream(Stream: TStream; IsCompressed: boolean = false);// inline;

      property Childrens: uint32 read ChildrensCount;
      property Children[Idx: uint32]: pBLOBNode read GetChildrenIdx;
      property NameSize: uint32 read fNameLen;
      property Name: AnsiString read fName write SetName;
      property DataSize: uint32 read fDataLen;
      property SlackSize: uint32 read fSlackLen write fSlackLen;
      property Data: Pointer read fData;
      procedure SetData(Value: Pointer; size: uint32);
      property Nodes[Name: AnsiString]: pBLOBNode read GetNode write SetNode; default;
      property Nodes[Name: uint32]: pBLOBNode read GetNodeIdx write SetNodeIdx; default;

      procedure AddData(Name: AnsiString; Data: pByte; Size: uint32);
      procedure AddString(Name: AnsiString; str: AnsiString);
  end;

  TBLOBFile = class
    private
      fFileName: string;
      fStream: TStream;
      fRootNode: TBLOBNode;
    public
      constructor Create(); overload;
      constructor Create(FileName: string); overload;
      constructor Create(Stream: TStream); overload;
      constructor Create(Memory: Pointer; Size: uint32); overload;
      destructor Destroy(); override;
      procedure Save(IsCompressed: boolean = false);
      procedure SaveToFile(FileName: string; IsCompressed: boolean = false); inline;
      function SaveToMem(var Mem: pByte): uint32; inline;

      property RootNode: TBLOBNode read fRootNode;
  end;

function StringFromData(Node: pBLOBNode): AnsiString;
function UINT32FromData(Node: pBLOBNode): uint32; inline;
function BoolFromData(Node: pBLOBNode): boolean; inline;


implementation

function StringFromData(Node: pBLOBNode): AnsiString;
var
  len: integer;
begin
  result:='';
  if Node=nil then
    Exit;
  SetLength(result, Node^.DataSize);
  Move(Node^.Data^, result[1], Node^.DataSize);
  while true do
  begin
    len:=Length(result);
    if (len>0) and (result[len]=#0) then Delete(result, len, 1)
      else break;
  end;
end;

function UINT32FromData(Node: pBLOBNode): uint32;
begin
  result:=0;
  if Node=nil then
    Exit;
  result:=puint32(Node^.Data)^;
end;

function BoolFromData(Node: pBLOBNode): boolean;
begin
  result:=false;
  if Node=nil then
    Exit;
  result:=pboolean(Node^.Data)^;
end;

constructor TBLOBNode.Create();
begin
  inherited Create();
  fIsData:=true;
  fNameLen:=0;
  fDataLen:=0;
  fSlackLen:=0;
  fName:='';
  fData:=nil;
end;

destructor TBLOBNode.Destroy();
var
  len, i: integer;
begin
  inherited Destroy();
  SetLength(fName, 0);
  FreeMem(fData, fDataLen);
  len:=Length(fChildrens);
  if (len>0) then
    for i:=0 to len-1 do
      fChildrens[i].Free;
  SetLength(fChildrens, 0);
end;

procedure TBLOBNode.DeserializeFromMem(Mem: pByte);
var
  NodeHeader: pBLOBNodeHeader;
  DataHeader: pBLOBDataHeader;
  CompressedHeader: TBLOBCompressedDataHeader;
  compSize, uncompSize: uint32;
  Data: Pointer;
  ChildrensCount, i: integer;
  //str: TStream;
begin
  NodeHeader:=pBLOBNodeHeader(Mem);
  DataHeader:=pBLOBDataHeader(Mem);
  Data:=nil;

  if (NodeHeader^.Magic=NODE_COMPRESSED_MAGIC) then
  begin
    inc(Mem, sizeof(TBLOBNodeHeader));
    Move(Mem^, CompressedHeader, sizeof(TBLOBCompressedDataHeader));
    inc(Mem, sizeof(TBLOBCompressedDataHeader));
    compSize:=NodeHeader^.Size-sizeof(TBLOBNodeHeader)-sizeof(TBLOBCompressedDataHeader);
    uncompSize:=CompressedHeader.UncompressedSize;
    GetMem(Data, uncompSize);
    uncompress(Data, uncompSize, Mem, compSize);
    Mem:=Data;
    NodeHeader:=pBLOBNodeHeader(Mem);
    DataHeader:=pBLOBDataHeader(Mem);
      {
    Str:=TStream.CreateWriteFileStream('.\dr.unc');
    str.Write(Mem^, uncompSize);
    str.Free;  }
  end;

  if (NodeHeader^.Magic=NODE_MAGIC) then
  begin
    fIsData:=false;
    fDataLen:=NodeHeader^.Size;
    fSlackLen:=NodeHeader^.StackSize;
    {if fSlackLen<>0 then
      Writeln(fSlackLen);}
    ChildrensCount:=GetChildrensCount(Mem);
    SetLength(fChildrens, ChildrensCount);
    inc(Mem, sizeof(TBLOBNodeHeader));
    for i:=0 to ChildrensCount-1 do
    begin
      fChildrens[i]:=TBLOBNode.Create();
      fChildrens[i].DeserializeFromMem(Mem);
      NodeHeader:=pBLOBNodeHeader(Mem);
      DataHeader:=pBLOBDataHeader(Mem);
      if (NodeHeader^.Magic=NODE_MAGIC) or (NodeHeader^.Magic=NODE_COMPRESSED_MAGIC) then
        inc(Mem, NodeHeader^.Size+NodeHeader^.StackSize)
          else inc(Mem, sizeof(TBLOBDataHeader)+DataHeader^.NameLen+DataHeader^.DataLen);
    end;
  end
    else
  begin
    fIsData:=true;
    fNameLen:=DataHeader^.NameLen;
    fDataLen:=DataHeader^.DataLen;
    inc(Mem, sizeof(TBLOBDataHeader));
    SetLength(fName, fNameLen);
    Move(Mem^, fName[1], fNameLen);
    inc(Mem, fNameLen);
    {if (fDataLen=160) and (fName=AnsiString(#0#0#0#0)) and (puint16(Mem)^<>NODE_MAGIC) then
      writeln('');  }
    if (puint16(Mem)^=NODE_MAGIC) or (puint16(Mem)^=NODE_COMPRESSED_MAGIC) then
    begin
      DeserializeFromMem(Mem);
      fData:=nil;
    end
      else
    begin
      GetMem(fData, fDataLen);
      Move(Mem^, fData^, fDataLen);
    end;
  end;

  if Data<>nil then
    FreeMem(Data, uncompSize);
end;

function TBLOBNode.GetChildrensSize(): uint32;
var
  i, len: integer;
begin
  result:=0;
  len:=Length(fChildrens);
  for i:=0 to len-1 do
  begin
    inc(result, fChildrens[i].fDataLen);
    inc(result, fChildrens[i].fSlackLen);
    inc(result, fChildrens[i].fNameLen);
    inc(result, sizeof(TBLOBDataHeader));
  end;
  if (not fIsData) then
  begin
    inc(result, fSlackLen);
    inc(result, sizeof(TBLOBNodeHeader));
  end;
end;

function TBLOBNode.SerializeToMem(var Mem: pByte; IsCompressed: boolean = false): uint32;
var
  MainMem: boolean;
  i, len: integer;
  data: pByte;
  NodeHeader: TBLOBNodeHeader;
  DataHeader: TBLOBDataHeader;
  CompressedHeader: TBLOBCompressedDataHeader;
  DataSize, sz, compSize: uint32;
begin
  DataSize:=GetChildrensSize();
  MainMem:=(Mem=nil);
  if Mem=nil then
  begin
    GetMem(Mem, DataSize);
    FillChar(Mem^, DataSize, 0);
  end;
  data:=Mem;
  if (fIsData) then
  begin
    DataHeader.NameLen:=fNameLen;
    DataHeader.DataLen:=fDataLen;
    Move(DataHeader, Data^, sizeof(TBLOBDataHeader));
    inc(data, sizeof(TBLOBDataHeader));
    Move(fName[1], data^, fNameLen);
    inc(data, fNameLen);
    if (fData<>nil) then
      Move(fData^, data^, fDataLen);
    DataSize:=fDataLen+fNameLen+sizeof(TBLOBDataHeader);
  end
    else
  begin
    NodeHeader.Magic:=NODE_MAGIC;
    NodeHeader.Size:=fDataLen;
    NodeHeader.StackSize:=fSlackLen;
    Move(NodeHeader, data^, sizeof(TBLOBNodeHeader));
    inc(data, sizeof(TBLOBNodeHeader));
    len:=Length(fChildrens);
    if len>0 then
      for i:=0 to len-1 do
      begin
        if (not fChildrens[i].fIsData) then
        begin
          DataHeader.NameLen:=fChildrens[i].fNameLen;
          DataHeader.DataLen:=fChildrens[i].GetChildrensSize();
          Move(DataHeader, Data^, sizeof(TBLOBDataHeader));
          inc(data, sizeof(TBLOBDataHeader));
          Move(fChildrens[i].fName[1], data^, fChildrens[i].fNameLen);
          inc(data, fChildrens[i].fNameLen);
        end;
        sz:=fChildrens[i].SerializeToMem(data);
        inc(data, sz);
      end;
    inc(data, NodeHeader.StackSize);
  end;

  if (MainMem) and (IsCompressed) then
  begin
    // compressing BLOB
    compSize:=DataSize+trunc(DataSize *0.01)+16;
    GetMem(Data, DataSize);
    compress(Data, compSize, Mem, DataSize);
    FreeMem(Mem, DataSize);
    NodeHeader.Magic:=NODE_COMPRESSED_MAGIC;
    NodeHeader.Size:=compSize;
    NodeHeader.StackSize:=0;
    CompressedHeader.UncompressedSize:=DataSize;
    CompressedHeader.unknown1:=0;
    CompressedHeader.unknown2:=0;
    DataSize:=compSize+sizeof(TBLOBNodeHeader)+sizeof(TBLOBCompressedDataHeader);
    GetMem(Mem, DataSize);
    Move(NodeHeader, Mem[0], sizeof(TBLOBNodeHeader));
    Move(CompressedHeader, Mem[sizeof(TBLOBNodeHeader)], sizeof(TBLOBCompressedDataHeader));
    Move(Data[0], Mem[sizeof(TBLOBNodeHeader)+sizeof(TBLOBCompressedDataHeader)], compSize);
    FreeMem(Data, DataSize);
  end;

  result:=DataSize;
end;

function TBLOBNode.GetChildrensCount(Mem: pByte): integer;
var
  res: integer;
  NodeHeader: pBLOBNodeHeader;
  DataHeader: pBLOBDataHeader;
  EndData: pByte;
begin
  res:=0;
  NodeHeader:=pBLOBNodeHeader(Mem);
  EndData:=Mem+NodeHeader^.Size;
  inc(Mem, sizeof(TBLOBNodeHeader));
  while (Mem<EndData) do
  begin
    NodeHeader:=pBLOBNodeHeader(Mem);
    DataHeader:=pBLOBDataHeader(Mem);
    inc(res);
    if (NodeHeader^.Magic=NODE_MAGIC) or (NodeHeader^.Magic=NODE_COMPRESSED_MAGIC) then
      inc(Mem, NodeHeader^.Size+NodeHeader^.StackSize);
        //else
    begin
      inc(Mem, sizeof(TBLOBDataHeader));
      inc(Mem, DataHeader^.NameLen+DataHeader^.DataLen);
    end;
  end;
  result:=res;
end;

procedure TBLOBNode.DeserializeFromStream(Stream: TStream);
var
  Data: Pointer;
  size: integer;
begin
  size:=Stream.Size;
  GetMem(Data, size);

  Stream.Read(Data^, size);
  DeserializeFromMem(Data);
  FreeMem(Data, size);
end;

procedure TBLOBNode.SerializeToStream(Stream: TStream; IsCompressed: boolean = false);
var
  size: uint32;
  Data: Pointer;
begin
  Data:=nil;
  Size:=SerializeToMem(pByte(Data), IsCompressed);
  Stream.Write(Data^, size);
  FreeMem(Data, size);
end;

procedure TBLOBNode.SetName(Value: AnsiString);
begin
  fNameLen:=Length(Value);
  fName:=Value;
end;

function TBLOBNode.GetNode(Name: AnsiString): pBLOBNode;
var
  i, len: integer;
begin
  result:=nil;
  len:=Length(fChildrens);
  if len=0 then
    Exit;
  for i:=0 to len-1 do
    if fChildrens[i].fName=Name then
    begin
      result:=@fChildrens[i];
      Exit;
    end;
end;

procedure TBLOBNode.SetNode(Name: AnsiString; Value: pBLOBNode);
var
  i, len: integer;
begin
  len:=Length(fChildrens);
  if len=0 then
    Exit;
  for i:=0 to len-1 do
    if fName=Name then
    begin
      fChildrens[i].fIsData:=Value^.fIsData;
      fChildrens[i].fName:=Copy(Value^.fName, 1, length(Value^.fName));
      fChildrens[i].fNameLen:=Value^.fNameLen;
      fChildrens[i].fSlackLen:=Value^.fSlackLen;
      FreeMem(fChildrens[i].fData, fChildrens[i].fDataLen);
      GetMem(fChildrens[i].fData, Value^.fDataLen);
      Move(Value.fData^, fChildrens[i].fData^, Value^.fDataLen);
      fChildrens[i].fDataLen:=Value^.fDataLen;
      Exit;
    end;
end;

function TBLOBNode.GetNodeIdx(Name: uint32): pBLOBNode;
var
  ch: AnsiString;
begin
  SetLength(ch, 4);
  Move(Name, ch[1], 4);
  result:=GetNode(ch);
  ch:='';
end;

procedure TBLOBNode.SetNodeIdx(Name: uint32; Value: pBLOBNode);
var
  ch: AnsiString;
begin
  SetLength(ch, 4);
  Move(Name, ch[1], 4);
  SetNode(ch, Value);
  ch:='';
end;

function TBLOBNode.ChildrensCount(): uint32;
begin
  result:=Length(fChildrens);
end;

function TBLOBNode.GetChildrenIdx(Idx: uint32): pBLOBNode;
begin
  if integer(Idx)>=Length(fChildrens) then
  begin
    result:=nil;
    Exit;
  end;
  result:=@fChildrens[Idx];
end;

procedure MoveMy(S, D: Pointer; size: integer);
asm
    mov ecx, [size]
    jcxz    @done
    mov esi, [S]
    mov edi, [D]
    pushf
    cld
    repnz   movsb
    popf
@done:
end;

procedure TBLOBNode.SetData(Value: Pointer; size: uint32);
begin
  if (fData<>nil) then
  begin
    if (size<>fDataLen) then
      ReallocMem(fData, size);
  end
    else GetMem(fData, size);
  {FreeMem(fData, fDataLen);
  GetMem(fData, size);  }
  fDataLen:=size;
  //MoveMy(Value, fData, size);
  Move(Value^, fData^, size);
end;

procedure TBLOBNode.AddData(Name: AnsiString; Data: pByte; Size: uint32);
var
  len: integer;
begin
  fIsData:=false;
  len:=Length(fChildrens);
  SetLength(fChildrens, len+1);
  fChildrens[len]:=TBLOBNode.Create();
  fChildrens[len].fIsData:=true;
  fChildrens[len].fNameLen:=Length(Name);
  fChildrens[len].fName:=Name;
  GetMem(fChildrens[len].fData, Size);
  fChildrens[len].fDataLen:=Size;
  Move(Data[0], fChildrens[len].fData^, Size);

  if fDataLen=0 then
    fDataLen:=sizeof(TBLOBNodeHeader);
  inc(fDataLen, fChildrens[len].fNameLen+fChildrens[len].fDataLen+sizeof(TBLOBDataHeader));
end;

procedure TBLOBNode.AddString(Name: AnsiString; str: AnsiString);
begin
  AddData(Name, @str[1], Length(str));
end;

constructor TBLOBFile.Create();
begin
  inherited Create();
  fRootNode:=TBLOBNode.Create();
end;

constructor TBLOBFile.Create(FileName: string);
begin
  inherited Create();
  fFileName:=FileName;
  fRootNode:=TBLOBNode.Create();
  fStream:=TStream.CreateReadFileStream(FileName);
  if (fStream.Handle=INVALID_HANDLE_VALUE) then
    Exit;
  fRootNode.DeserializeFromStream(fStream);
  fStream.Free();
end;

constructor TBLOBFile.Create(Stream: TStream);
begin
  inherited Create();
  fRootNode:=TBLOBNode.Create();
  fRootNode.DeserializeFromStream(Stream);
end;

constructor TBLOBFile.Create(Memory: Pointer; Size: uint32);
var
  str: TStream;
begin
  str:=TStream.CreateMemoryStreamEx(Memory, Size);
  Create(str);
  str.Free;
end;

destructor TBLOBFile.Destroy();
begin
  inherited Destroy();
  fFileName:='';
  fRootNode.Free;
end;

procedure TBLOBFile.Save(IsCompressed: boolean = false);
begin
  fStream:=TStream.CreateWriteFileStream(fFileName);
  if (fStream.Handle=INVALID_HANDLE_VALUE) then
    Exit;
  fRootNode.SerializeToStream(fStream, IsCompressed);
  fStream.Free();
end;

procedure TBLOBFile.SaveToFile(FileName: string; IsCompressed: boolean = false);
begin
  fFileName:=FileName;
  Save(IsCompressed);
end;

function TBLOBFile.SaveToMem(var Mem: pByte): uint32;
begin
  result:=fRootNode.SerializeToMem(Mem);
end;

end.
