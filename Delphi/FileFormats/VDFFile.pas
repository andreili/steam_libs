unit VDFFile;

interface

uses
  Windows, USE_Types, USE_Utils, err;

const
  SIGN_APPINFO = $06564424; // $DV(0x06)
  SIGN_PKGINFO = $06565525; // %UV(0x06)

  APP_CACHE: uint32 = $00000000;
  APP_APP: uint32 = $00000002;

  NODE_END = $00;
  // $01
  NODE_APP_INFO = $02;
  NODE_EXTENDED_INFO = $03;
  NODE_LAUNCH_INFO = $04;
  //$05
  NODE_INSTALL = $06;
  NODE_CACHE_LIST = $07;
  // $08
  // $09
  NODE_STEAM_INFO = $0a;
  // $0b
  // $0c
  // $0d
  NODE_MACOS_PARAMS = $0e;
 {
  LANG_COUNT = 26;

var
  STEAM_LANGUAGES: array[0..LANG_COUNT-1] of AnsiString = ('brazilian', 'bulgarian',
    'czech', 'danish', 'dutch', 'english', 'finnish', 'french', 'german', 'hungarian',
    'hungarian', 'italian', 'japanese', 'korean', 'koreana', 'norwegian', 'polish',
    'portuguese', 'romanian', 'russian', 'schinese', 'spanish', 'swedish', 'tchinese',
    'thai', 'turkish');  }

const
  //ENodeType
  NODE_TYPE_NONE     = 0;
  NODE_TYPE_STRING   = 1;
  NODE_TYPE_INT      = 2;
  NODE_TYPE_FLOAT    = 3;
  NODE_TYPE_PTR      = 4;
  NODE_TYPE_WSTRING  = 5;
  NODE_TYPE_COLOR    = 6;
  NODE_TYPE_UINT64   = 7;
  NODE_TYPE_NUMTYPES = 8;

type
  ENodeType =
    (TYPE_NONE     = 0,
     TYPE_STRING   = 1,
     TYPE_INT      = 2,
     TYPE_FLOAT    = 3,
     TYPE_PTR      = 4,
     TYPE_WSTRING  = 5,
     TYPE_COLOR    = 6,
     TYPE_UINT64   = 7,
     TYPE_NUMTYPES = 8);

  TNodeData = record
    case integer of
      0: (AsString: pAnsiChar);
      1: (AsInt: integer);
      2: (AsFloat: single);
      3: (AsPointer: Pointer);
      4: (AsWideString: pAnsiChar);
      5: (AsColor: integer);
      6: (AsUINT64: uint64);
  end;

  TVDFNode = class
    private
      fChildrensCount: uint32;
      fChildrens: array of TVDFNode;

      fName: AnsiString;
      fType: ENodeType;
      fDataSize: integer;
      fData: TNodeData;

      function GetChildrenByIdx(Idx: uint32): TVDFNode;
      function GetChildrenByName(Name: AnsiString): TVDFNode;
    public
      constructor Create();
      destructor Destroy(); override;

      procedure LoadFromStreamAsBinary(Stream: TStream);
      procedure LoadFromStreamAsText(Stream: TStream);
      procedure SaveToStreamAsBinary(Stream: TStream);
      procedure SaveToStreamAsText(Stream: TStream);
      procedure LoadFromFile(FileName: string; AsText: boolean = true);
      procedure SaveToFile(FileName: string; AsText: boolean = true);

      property ChildrensCount: uint32 read fChildrensCount;
      property ChildrenByIdx[Idx: uint32]: TVDFNode read GetChildrenByIdx;
      property Children[Name: AnsiString]: TVDFNode read GetChildrenByName; default;
      procedure AddChildren(NewChild: TVDFNode);

      property Name: AnsiString read fName write fName;
      property Type_: ENodeType read fType;
      property DataSize: integer read fDataSize;

      property DataAsString: pAnsiChar read fData.AsString;
      property DataAsInt: integer read fData.AsInt;
      property DataAsFloat: single read fData.AsFloat;
      property DataAsPointer: Pointer read fData.AsPointer;
      property DataAsWideString: pAnsiChar read fData.AsWideString;
      property DataAsUInt64: uint64 read fData.AsUInt64;
  end;

  TVDFHeader = record
    Sign: uint32;
    Version: uint32;
  end;

  TVDFFile = class
    public
      function LoadFromStream(Stream: TStream): boolean; virtual; abstract;
      function LoadFromFile(FileName: string): boolean;
      procedure SaveToStream(Stream: TStream); virtual; abstract;
      function SaveToFile(FileName: string): boolean;
  end;

  TVDFSteamState = class (TVDFFile)
    private
      fHeader: TVDFHeader;
      fNode: TVDFNode;
    public
      constructor Create();
      destructor Destroy(); override;

      function LoadFromStream(Stream: TStream): boolean; override;
      procedure SaveToStream(Stream: TStream); override;

      property RootNode: TVDFNode read fNode;
  end;

  TAchivementType =
    (ACHIVEMENT_EASY = 1,
     ACHIVEMENT_TREE = 4);

  TSteamStats = class
    private
      fUserStats,
      fStatsSchema: TVDFSteamState;

      function GetAchivementsCount(): integer;
      function GetAchivementType(Index: integer): TAchivementType;
      function GetAchivementName(Index: integer): string;
      function GetAchivementValue(Index: integer): integer;
      function GetAchivementsCountEx(Index: integer): integer;
      function GetAchivementNameEx(Index: integer; SubIndex: integer; Language: AnsiString): string;
      function GetAchivementDescriptionEx(Index: integer; SubIndex: integer; Language: AnsiString): string;
      function GetAchivementValueEx(Index: integer; SubIndex: integer): integer;
    public
      constructor Create(StatsDir: string; UserID, AppID: uint32);
      destructor Destroy(); override;

      property AchivementsCount: integer read GetAchivementsCount;
      property AchivementType[Index: integer]: TAchivementType read GetAchivementType;
      property AchivementName[Index: integer]: string read GetAchivementName;
      property AchivementValue[Index: integer]: integer read GetAchivementValue;
      property SubAchivementsCount[Index: integer]: integer read GetAchivementsCountEx;
      property SubAchivementName[Index: integer; SubIndex: integer; Language: AnsiString]: string read GetAchivementNameEx;
      property SubAchivementDescription[Index: integer; SubIndex: integer; Language: AnsiString]: string read GetAchivementDescriptionEx;
      property SubAchivementValue[Index: integer; SubIndex: integer]: integer read GetAchivementValueEx;
  end;

  TVDFPKGHeader = packed record
    unk1: uint32;
    Hash: array[0..19] of byte;
  end;

  TVDFPackageRecord = record
    Header: TVDFPKGHeader;
    Node:  TVDFNode;
  end;

  TPackageInfo = class (TVDFFile)
    private
      fHeader: TVDFHeader;
      fAppIDs: TVDFPackageRecord;
    public
      fPackagesCount: integer;
      fPackages: array of TVDFPackageRecord;

      constructor Create();
      destructor Destroy(); override;

      function LoadFromStream(Stream: TStream): boolean; override;
      procedure SaveToStream(Stream: TStream); override;
  end;

  TVDFAppHeader = record
    AppID: uint32;
    DataSize: uint32;
  end;

  TVDFAppInfo = record
    AppType: uint32;
    unk2: uint32;
    LastChangeNumber: uint32;
  end;
    {
  pApplicationInfo = ^TApplicationInfo;
  TApplicationInfo = record
    Name,
    MetactirticName,
    MetactirticURL,
    MetactirticFullURL,
    SectionType,
    Type_,
    DriverVersion: AnsiString;

    GameID,
    MetactirticScore: uint32;
    OGG: array[0..17] of AnsiChar;
    ClientIcon,
    Icon,
    Logo,
    LogoSmall,
    ClientICNS: array[0..39] of AnsiChar;
    Languages: array[0..LANG_COUNT-1] of boolean;
  end; }

  pVDFApp = ^TVDFApp;
  TVDFApp = record
    Header: TVDFAppHeader;
    AppInfo: TVDFAppInfo;
    Nodes: array[0..15] of TVDFNode;
  end;

  TAppInfo = class (TVDFFile)
    private
      fHeader: TVDFHeader;
      fAppsCount: integer;
      fApps: array of TVDFApp;

      function AppInfo_GetCount(Stream: TStream): integer;
      function GetApp(Idx: integer): pVDFApp;
    public
      constructor Create();
      destructor Destroy(); override;

      function LoadFromStream(Stream: TStream): boolean; override;
      procedure SaveToStream(Stream: TStream); override;

      procedure SaveToFileAsText(FileName: string);
      procedure SaveToStreamAsText(Stream: TStream);

      property AppsCount: integer read fAppsCount;
      property App[Idx: integer]: pVDFApp read GetApp; default;
  end;

implementation

function TVDFNode.GetChildrenByIdx(Idx: uint32): TVDFNode;
begin
  if (Idx>=fChildrensCount) then
  begin
    result:=nil;
    raise Exception.Create(e_Range, '');
  end
    else result:=fChildrens[Idx];
end;

function TVDFNode.GetChildrenByName(Name: AnsiString): TVDFNode;
var
  i: integer;
  s, path: string;
begin
  s:=Ansi2Wide(Name);
  path:=Parse(s, '\');
  result:=nil;
  Name:=Wide2Ansi(path);
  if (fChildrensCount>0) then
    for i:=0 to fChildrensCount-1 do
      if (fChildrens[i].fName=Name) then
      begin
        if (s='') then result:=fChildrens[i]
          else result:=fChildrens[i][Wide2Ansi(s)];
        Exit;
      end;
  if result=nil then
    raise Exception.Create(e_InvalidPointer, '');
end;

constructor TVDFNode.Create();
begin
  inherited Create();
  fName:='';
  fDataSize:=0;
  fData.AsInt:=0;
  fChildrensCount:=0;
end;

destructor TVDFNode.Destroy();
var
  i: integer;
begin
  inherited Destroy();
  fName:='';
  fDataSize:=0;
  if (fType=TYPE_STRING) then FreeMem(fData.AsString, Length(fData.AsString))//fData.AsString:=''
  else if (fType=TYPE_WSTRING) then fData.AsWideString:='';
  if (fChildrensCount>0) then
    for i:=0 to fChildrensCount-1 do
      fChildrens[i].Free;
end;

procedure TVDFNode.LoadFromStreamAsBinary(Stream: TStream);
  function Recurse(Root: TVDFNode): boolean;
  var
    s: AnsiString;
    len: integer;
  begin
    result:=false;
    Stream.Read(Root.fType, 1);
    if (Root.fType = TYPE_NUMTYPES) then
      Exit;
    Root.fName:=Stream.ReadStrZ();
    if (Root.fName='{') then
      Writeln('');
    case byte(Root.fType) of
      NODE_TYPE_NONE:
        while true do
        begin
          inc(Root.fChildrensCount);
          SetLength(Root.fChildrens, Root.fChildrensCount);
          Root.fChildrens[Root.fChildrensCount-1]:=TVDFNode.Create();
          if (not Recurse(Root.fChildrens[Root.fChildrensCount-1])) then
          begin
            dec(Root.fChildrensCount);
            Root.fChildrens[Root.fChildrensCount].Free;
            SetLength(Root.fChildrens, Root.fChildrensCount);
            break;
          end;
        end;
      NODE_TYPE_STRING:
        begin
          s:=Stream.ReadStrZ();
          len:=Length(s);
          GetMem(Root.fData.AsString, len+1);
          Move(s[1], Root.fData.AsString[0], len);
          Root.fData.AsString[len]:=#0;
        end;
      NODE_TYPE_INT{, NODE_TYPE_PTR, NODE_TYPE_COLOR}: Stream.Read(Root.fData.AsInt, 4);
      NODE_TYPE_FLOAT: Stream.Read(Root.fData.AsFloat, 4);
      NODE_TYPE_WSTRING: Writeln('WideString!');
      NODE_TYPE_UINT64: Stream.Read(Root.fData.AsUINT64, 8);
        else Writeln(byte(Root.fType));
    end;

    result:=true;
  end;
begin
  Recurse(self);
  Stream.Seek(1, spCurrent);
end;

function ReadToken(Stream: TStream): AnsiString;
var
  c: AnsiChar;
  l: integer;

  procedure EatWhiteSpace();
  begin
    while (Stream.Position<Stream.Size) do
    begin
      Stream.Read(c, 1);
      if not (c in [#0..#20]) then
      begin
        Stream.Seek(-1, spCurrent);
        break;
      end;
    end;
  end;
  function EatCPPComment(): boolean;
  begin
    result:=false;
  end;
begin
  result:='';
  if (Stream.Position>=Stream.Size) then
    Exit;
  while (true) do
  begin
    EatWhiteSpace();
    if (Stream.Position>=Stream.Size) then
      Exit;
    if not EatCPPComment() then
      break;
    if (Stream.Position>=Stream.Size) then
      Exit;
  end;

  Stream.Read(c, 1);

  if (c='"') then
  begin
    Stream.Read(c, 1);
    repeat
      result:=result+c;
      Stream.Read(c, 1);
    until (c in [#0..#19]);
    l:=length(result);
    if (result[l]='"') then
      Delete(result, l, 1);
  end
    else if (c='{') or (c='}') then
  begin
    result:=c;
  end;
end;

procedure TVDFNode.LoadFromStreamAsText(Stream: TStream);
  procedure Recurse(RootNode: TVDFNode);
  var
    s, s_i, s_f: AnsiString;
    pCurrentKey: TVDFNode;
    ival, len: integer;
    fval: single;
  begin
    while true do
    begin
      s:=ReadToken(Stream);

      if (s='}') or (s='') then
        break;

      pCurrentKey:=TVDFNode.Create();
      RootNode.AddChildren(pCurrentKey);
      pCurrentKey.fName:=s;
      s:=ReadToken(Stream);
      if (s='{') then
      begin
        pCurrentKey.fType:=TYPE_NONE;
        Recurse(pCurrentKey);
      end
        else
      begin
        ival:=Str2Int(s);      s_i:=Int2Str(ival);
        fval:=Str2Double(s);   s_f:=Double2Str(fval);
        len:=Length(s);
        if (s='') then
        begin
          pCurrentKey.fType:=TYPE_STRING;
          pCurrentKey.fData.AsString:='';
        end
          else if (len=18) and (s[1]='0') and (s[2]='x')then
        begin
          pCurrentKey.fType:=TYPE_UINT64;
          pCurrentKey.fData.AsUINT64:=Hex2Int(s);
        end
          else if (fval<>ival) and (s_f[len]=s[len])  then
        begin
          pCurrentKey.fType:=TYPE_FLOAT;
          pCurrentKey.fData.AsFloat:=fval;
        end
          else if (ival<>0) and (s_i[len]=s[len]) then
        begin
          pCurrentKey.fType:=TYPE_INT;
          pCurrentKey.fData.AsInt:=ival;
        end
          else
        begin
          pCurrentKey.fType:=TYPE_STRING;
          len:=Length(s);
          GetMem(pCurrentKey.fData.AsString, len+1);
          Move(s[1], pCurrentKey.fData.AsString[0], len);
          pCurrentKey.fData.AsString[len]:=#0;
        end;
      end;
    end;
  end;
begin
  fName:=ReadToken(Stream);
  ReadToken(Stream);
  Recurse(self);
end;

procedure TVDFNode.SaveToStreamAsBinary(Stream: TStream);
  procedure Recurse(Root: TVDFNode);
  var
    b: byte;
    i: integer;
  begin
    b:=$08;
    Stream.Write(Root.fType, 1);
    Stream.WriteAnsiStr(Root.fName+#0);
    case byte(Root.fType) of
      NODE_TYPE_NONE:
        begin
          for i:=0 to Root.fChildrensCount-1 do
            Recurse(Root.fChildrens[i]);
          Stream.Write(b, 1);
        end;
      NODE_TYPE_STRING:
        Stream.Write(Root.fData.AsString[0], Length(Root.fData.AsString)+1);
      NODE_TYPE_INT, NODE_TYPE_PTR, NODE_TYPE_COLOR: Stream.Write(Root.fData.AsInt, 4);
      NODE_TYPE_FLOAT: Stream.Write(Root.fData.AsFloat, 4);
      NODE_TYPE_WSTRING:
        begin
          Writeln('WideString!');
        end;
      NODE_TYPE_UINT64:
        begin
          Stream.Write(Root.fData.AsUINT64, 8);
        end;
        else Writeln(byte(Root.fType));
    end;
  end;
begin
  Recurse(self);
  Stream.WriteAnsiStr(#8);
end;

procedure TVDFNode.SaveToStreamAsText(Stream: TStream);
  procedure Recurse(Level: integer; Parent: TVDFNode);
  var
    trim: AnsiString;
    i: integer;
  begin
    trim:='';
    if (Level>0) then
      for i:=1 to Level do
        trim:=trim+#9;
    Stream.WriteAnsiStr(trim+'"'+Parent.fName+'"'+#9);
    case byte(Parent.fType) of
      NODE_TYPE_NONE: Stream.WriteAnsiStr(#10+trim+'{'+#10);
      NODE_TYPE_STRING: Stream.WriteAnsiStr(#9#9'"'+Parent.fData.AsString+'"'+#10);
      NODE_TYPE_INT, NODE_TYPE_COLOR: Stream.WriteAnsiStr(Wide2Ansi(#9#9'"'+Int2Str(Parent.fData.AsInt)+'"'+#10));
      NODE_TYPE_FLOAT: Stream.WriteAnsiStr(Wide2Ansi(#9#9'"'+Double2Str(Parent.fData.AsFloat)+'"'+#10));
      NODE_TYPE_WSTRING: Stream.WriteAnsiStr(#9#9'"'+Parent.fData.AsWideString+'"'+#10);
      NODE_TYPE_UINT64: Stream.WriteAnsiStr(#9#9'"0x'+Int2Hex(Parent.fData.AsUINT64, 16)+'"'+#10);
    end;
    if Parent.fChildrensCount>0 then
      for i:=0 to Parent.fChildrensCount-1 do
        Recurse(Level+1, Parent.fChildrens[i]);
    if (Parent.fType=TYPE_NONE) then
      Stream.WriteAnsiStr(trim+'}'+#10);
  end;
begin
  Recurse(0, self);
end;

procedure TVDFNode.LoadFromFile(FileName: string; AsText: boolean = true);
var
  Stream, tmp: TStream;
  len: integer;
  buf: pByte;
begin
  tmp:=TStream.CreateReadFileStream(FileName);
  if (tmp.Handle=INVALID_HANDLE_VALUE) then
    Exit;
  len:=tmp.Size;
  GetMem(buf, len);
  tmp.Read(buf^, len);
  tmp.Free;
  Stream:=TStream.CreateMemoryStreamEx(buf, len);
  if AsText then LoadFromStreamAsText(Stream)
    else LoadFromStreamAsBinary(Stream);
  Stream.Free;
  FreeMem(buf, len);
end;

procedure TVDFNode.SaveToFile(FileName: string; AsText: boolean = true);
var
  Stream: TStream;
begin
  Stream:=TStream.CreateWriteFileStream(FileName);
  if (Stream.Handle=INVALID_HANDLE_VALUE) then
    Exit;
  if AsText then SaveToStreamAsText(Stream)
    else SaveToStreamAsBinary(Stream);
  Stream.Free;
end;

procedure TVDFNode.AddChildren(NewChild: TVDFNode);
begin
  SetLength(fChildrens, fChildrensCount+1);
  fChildrens[fChildrensCount]:=NewChild;
  inc(fChildrensCount);
end;

function TVDFFile.LoadFromFile(FileName: string): boolean;
var
  Stream, tmp: TStream;
  len: integer;
  buf: array of byte;
begin
  result:=false;
  tmp:=TStream.CreateReadFileStream(FileName);
  if (tmp.Handle=INVALID_HANDLE_VALUE) then
    Exit;
  len:=tmp.Size;
  SetLength(buf, len);
  tmp.Read(buf[0], len);
  tmp.Free;
  Stream:=TStream.CreateMemoryStreamEx(buf, len);
  Stream.Position:=0;
  result:=LoadFromStream(Stream);
  Stream.Free;
  SetLength(buf, 0);
end;

function TVDFFile.SaveToFile(FileName: string): boolean;
var
  Stream: TStream;
begin
  result:=false;
  Stream:=TStream.CreateWriteFileStream(FileName);
  if (Stream.Handle=INVALID_HANDLE_VALUE) then
    Exit;
  SaveToStream(Stream);
  Stream.Free;
  result:=true;
end;

constructor TVDFSteamState.Create();
begin
  inherited Create();
  fNode:=nil;
end;

destructor TVDFSteamState.Destroy();
begin
  inherited Destroy();
  fNode.Free;
end;

function TVDFSteamState.LoadFromStream(Stream: TStream): boolean;
begin
  Stream.Read(fHeader, sizeof(TVDFHeader));
  if (fHeader.Sign<>SIGN_APPINFO) and (fHeader.Sign<>SIGN_PKGINFO) then
  begin
    Stream.Seek(-sizeof(TVDFHeader), spCurrent);
    fNode:=TVDFNode.Create();
    fNode.LoadFromStreamAsBinary(Stream);

    result:=true;
  end
    else result:=false;
end;

procedure TVDFSteamState.SaveToStream(Stream: TStream);
begin
  fNode.SaveToStreamAsBinary(Stream);
end;

constructor TSteamStats.Create(StatsDir: string; UserID, AppID: uint32);
begin
  inherited Create();
  fUserStats:=TVDFSteamState.Create();
  fUserStats.LoadFromFile(StatsDir+'UserGameStats_'+Int2Str(UserID)+'_'+Int2Str(AppID)+'.bin');
  fStatsSchema:=TVDFSteamState.Create();
  fStatsSchema.LoadFromFile(StatsDir+'UserGameStatsSchema_'+Int2Str(AppID)+'.bin');
end;

destructor TSteamStats.Destroy();
begin
  inherited Destroy();
  fUserStats.Free;
  fStatsSchema.Free;
end;

function TSteamStats.GetAchivementsCount(): integer;
begin
  if fStatsSchema.RootNode['stats']=nil then result:=0
    else result:=fStatsSchema.RootNode['stats'].ChildrensCount;
end;

function TSteamStats.GetAchivementType(Index: integer): TAchivementType;
begin
  result:=TAchivementType(fStatsSchema.RootNode['stats'].ChildrenByIdx[Index]['type_int'].DataAsInt);
end;

function TSteamStats.GetAchivementName(Index: integer): string;
var
  Node: TVDFNode;
begin
  result:='';
  Node:=fStatsSchema.RootNode['stats'].ChildrenByIdx[Index];
  if Node<>nil then
    if (Node['display\name'].Type_=TYPE_STRING) then result:=Utf8ToAnsi(Node['display\name'].DataAsString);
end;

function TSteamStats.GetAchivementValue(Index: integer): integer;
var
  ID: AnsiString;
  Node: TVDFNode;
begin
  if GetAchivementType(Index)=ACHIVEMENT_TREE then result:=-1
    else
  begin
    ID:=fStatsSchema.RootNode['stats'].ChildrenByIdx[Index]['ID'].DataAsString;
    Node:=fUserStats.RootNode[ID];
    if Node=nil then result:=-1
      else result:=Node['data'].DataAsInt;
  end;
end;

function TSteamStats.GetAchivementsCountEx(Index: integer): integer;
var
  Node: TVDFNode;
begin
  result:=0;
  Node:=fStatsSchema.RootNode['stats'].ChildrenByIdx[Index]['bits'];
  if (Node<>nil) then
    result:=Node.ChildrensCount;
end;

function TSteamStats.GetAchivementNameEx(Index: integer; SubIndex: integer; Language: AnsiString): string;
var
  Node: TVDFNode;
begin
  result:='';
  Node:=fStatsSchema.RootNode['stats'].ChildrenByIdx[Index]['bits'].ChildrenByIdx[SubIndex];
  if Node<>nil then
    if (Node['display\name\'+Language]<>nil) then result:=Utf8ToAnsi(Node['display\name\'+Language].DataAsString)
      else result:=Node['display\name\english'].DataAsString;
end;

function TSteamStats.GetAchivementDescriptionEx(Index: integer; SubIndex: integer; Language: AnsiString): string;
var
  Node: TVDFNode;
begin
  result:='';
  Node:=fStatsSchema.RootNode['stats'].ChildrenByIdx[Index]['bits'].ChildrenByIdx[SubIndex];
  if Node<>nil then
    if (Node['display\desc\'+Language]<>nil) then result:=Utf8ToAnsi(Node['display\desc\'+Language].DataAsString)
      else result:=Node['display\desc\english'].DataAsString;
end;

function TSteamStats.GetAchivementValueEx(Index: integer; SubIndex: integer): integer;
var
  ID: AnsiString;
  bit: integer;
  Node: TVDFNode;
begin
  if GetAchivementType(Index)=ACHIVEMENT_EASY then result:=-1
    else
  begin
    //ID:=Int2Str(fStatsSchema.RootNode['stats'].ChildrenByIdx[Index]['bits'].ChildrenByIdx[SubIndex]['bit'].DataAsInt);
    Node:=fStatsSchema.RootNode['stats'].ChildrenByIdx[Index];
    ID:=Node['ID'].DataAsString;
    bit:=Node['bits'].ChildrenByIdx[SubIndex]['bit'].DataAsInt;
    Node:=fUserStats.RootNode[ID]['AchievementTimes\'+Int2Str(bit)];
    if Node=nil then result:=-1
      else result:=Node.DataAsInt;
  end;
end;

constructor TPackageInfo.Create();
begin
  inherited Create();
  fPackagesCount:=0;
  fPackages:=nil;
end;

destructor TPackageInfo.Destroy();
var
  i: integer;
begin
  fAppIDs.Node.Free;
  if (fPackagesCount>0) then
    for i:=0 to fPackagesCount-1 do
      fPackages[i].Node.Free;
  inherited Destroy();
end;

function TPackageInfo.LoadFromStream(Stream: TStream): boolean;
var
  end_p: integer;
begin
  Stream.Read(fHeader, sizeof(TVDFHeader));
  if (fHeader.Sign=SIGN_PKGINFO) then
  begin
    while (true) do
    begin
      Stream.Read(end_p, 4);
      if (end_p=integer($ffffffff)) then
        break;
      Stream.Seek(-4, spCurrent);
      SetLength(fPackages, fPackagesCount+1);
      Stream.Read(fPackages[fPackagesCount].Header, sizeof(TVDFPKGHeader));
      fPackages[fPackagesCount].Node:=TVDFNode.Create();
      fPackages[fPackagesCount].Node.LoadFromStreamAsBinary(Stream);
      inc(fPackagesCount);
    end;

    result:=true;
  end
    else result:=false;
end;

procedure TPackageInfo.SaveToStream(Stream: TStream);
var
  i: integer;
begin
  Stream.Write(fHeader, sizeof(TVDFHeader));
  for i:=0 to fPackagesCount-1 do
  begin
    Stream.Write(fPackages[i].Header, sizeof(TVDFPKGHeader));
    fPackages[i].Node.SaveToStreamAsBinary(Stream);
  end;
  i:=-1;
  Stream.Write(i, 4);
end;

constructor TAppInfo.Create();
begin
  inherited Create();
  fAppsCount:=0;
end;

destructor TAppInfo.Destroy();
var
  i, j: integer;
begin
  inherited Destroy();
  if fAppsCount>0 then
    for i:=0 to fAppsCount-1 do
      for j:=0 to 15 do
        if (fApps[i].Nodes[j]<>nil) then fApps[i].Nodes[j].Free;
end;

function TAppInfo.AppInfo_GetCount(Stream: TStream): integer;
var
  n: integer;
  pos: int64;
  header: TVDFAppHeader;
begin
  pos:=Stream.Position;
  n:=0;
  while (Stream.Position<Stream.Size) do
  begin
    if (Stream.Read(header, sizeof(TVDFAppHeader))<sizeof(TVDFAppHeader)) then
      break;
    Stream.Seek(header.DataSize, spCurrent);
    inc(n);
  end;
  Stream.Seek(pos, spBegin);
  result:=n;
end;

function TAppInfo.GetApp(Idx: integer): pVDFApp;
begin
  result:=@fApps[Idx];
end;

function TAppInfo.LoadFromStream(Stream: TStream): boolean;
var
  FieldType: byte;
  i, j: integer;
  EndPos: int64;
begin
  Stream.Read(fHeader, sizeof(TVDFHeader));
  if (fHeader.Sign=SIGN_APPINFO) then
  begin
    fAppsCount:=AppInfo_GetCount(Stream);
    SetLength(fApps, fAppsCount);
    for i:=0 to fAppsCount-1 do
    begin
      FillChar(fApps[i], sizeof(TVDFApp), 0);
      Stream.Read(fApps[i].Header, sizeof(TVDFAppHeader));
      EndPos:=Stream.Position+fApps[i].Header.DataSize;
      Stream.Read(fApps[i].AppInfo, sizeof(TVDFAppInfo));
      while (Stream.Position<EndPos) do
      begin
        Stream.Read(FieldType, 1);
        if (FieldType=0) then
          break;
        fApps[i].Nodes[FieldType]:=TVDFNode.Create();
        fApps[i].Nodes[FieldType].LoadFromStreamAsBinary(Stream);
      end;
    end;

    result:=true;
  end
    else result:=false;
end;

procedure TAppInfo.SaveToStream(Stream: TStream);
var
  FieldType: byte;
  i, j: integer;
begin
  Stream.Write(fHeader, sizeof(TVDFHeader));
  if (fAppsCount>0) then
    for i:=0 to fAppsCount-1 do
    begin
      Stream.Write(fApps[i].Header, sizeof(TVDFAppHeader));
      Stream.Write(fApps[i].AppInfo, sizeof(TVDFAppInfo));
      for j:=0 to 15 do
        if (fApps[i].Nodes[j]<>nil) then
        begin
          Stream.Write(j, 1);
          fApps[i].Nodes[j].SaveToStreamAsBinary(Stream);
        end;
      FieldType:=NODE_END;
      Stream.Write(FieldType, 1);
    end;
  i:=0;
  Stream.Write(i, 4);
end;

procedure TAppInfo.SaveToFileAsText(FileName: string);
var
  Stream: TStream;
begin
  Stream:=TStream.CreateWriteFileStream(FileName);
  if (Stream.Handle=INVALID_HANDLE_VALUE) then
    Exit;
  SaveToStreamAsText(Stream);
end;

procedure TAppInfo.SaveToStreamAsText(Stream: TStream);
var
  i, j: integer;
begin
  if (fAppsCount>0) then
    for i:=0 to fAppsCount-1 do
    begin
      Stream.WriteAnsiStr('AppID: '+Int2Str(fApps[i].Header.AppID)+#10);
      Stream.WriteAnsiStr('Type: '+Int2Str(fApps[i].AppInfo.AppType)+#10);
      for j:=0 to 15 do
        if (fApps[i].Nodes[j]<>nil) then
          fApps[i].Nodes[j].SaveToStreamAsText(Stream);
      Stream.WriteAnsiStr(#10#10);
    end;
end;

end.