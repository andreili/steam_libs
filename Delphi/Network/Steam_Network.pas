unit Steam_Network;

interface

{$I defines.inc}

//{$DEFINE DEBUG_CS_SLEEP}

uses
  Windows, USE_Types, USE_Utils, WinSock, SHA, DECCipher, BLOBFile, GCFFile, RSA, CDRFile, Sockets, Steam_FriendProtocol;

const
  CL_MAX_SERVERS: uint32 = 10;

  REGION_US_East: uint32 = $00;
  REGION_US_West : uint32 = $01;
  REGION_South_America: uint32 = $02;
  REGION_Europe: uint32 = $03;
  REGION_Asia: uint32 = $04;
  REGION_Australia: uint32 = $05;
  REGION_Middle_East: uint32 = $06;
  REGION_Africa: uint32 = $07;
  REGION_Rest_World: uint32 = $ff;

type
  ENetWorkResult =
    (
     // error's
     eConnectionError,
     eSignError,
     eZLibError,
     //
     eServerReset,
     eNotDataFromSocket,
     //
     eOK,
     // authentifaction result
     eLoggedIn,
     eAccountNotExist,
     eAccountNotExistOrPasswordNotCorrect,
     eClockDiffers,
     eAccountDisabled,
     eAccountUnknowError,
     eBadAuthReply,
     eUserExists,
     eUsetNotExists
     );

  TByteArray = array of byte;

  TLogin_SubHeader = packed record
    innerkey: array[0..15] of byte;
    nullData: uint16;
    SteamID: uint64;
    Server1IP: uint32;
    Server1Port: uint16;
    Server2IP: uint32;
    Server2Port: uint16;
    CurrTime: uint64;
    OutTime: uint64;
    TicketLen: uint16;
  end;

  TTicket_SubHeader = packed record
    nullData1: uint16;
    outerIV: array[0..15] of byte;
    nullData2: uint16;
    nullData3: uint16;
    EncrData: array[0..63] of byte;
    TicketLen: uint16;
  end;
  TTicket_Data = packed record
    nullData1: uint16;
    Tick1Size: uint16;
    Tick1: array[0..145] of byte;
    nullData2: uint16;
    Tick2Size: uint16;
    Tick2: array[0..79] of byte;
    ExtDataSize: uint16;
    SteamID: uint64;
    ExternalIP: uint32;
    nullData3: uint32;
    Sign: array[0..127] of byte;
    BLOBLen: uint32;
  end;

  TTicket_BLOBHeader = packed record
    //Len: uint32;
    NodeHeader: uint16;
    Len2: uint32;
    ZerosSize: uint32;
    BLOBLen: uint32;
    InnerIV: array[0..15] of byte;
  end;

  TTicket_UserHeader = packed record
    InnerKey: array[0..15] of byte;
    Dummy1: uint16;
    SteamID: uint64;
    Servers: packed record
      IP1: uint32;
      Port1: uint16;
      IP2: uint32;
      Port2: uint16;
    end;
    CurrentTime: uint64;
    ExpiredTime: uint64;
    Dummy2: array[0..9] of byte;
  end;

  TTicket_TestData = packed record
    len: uint16;  //always $1000
    SteamID: uint64;
    ExternalIP: uint32;
    {Dymmy0: uint32;
    TicketSign: array[0..127] of byte; }
  end;

  TContentListEntry = packed record
    ID: uint32;     // нагрузка на сервер???
    ClientUpdateIP: uint32;
    ClientUpdatePort: uint16;
    ContentServerIP: uint32;
    ContentServerPort: uint16;
  end;
  TContentListEntries = array of TContentListEntry;

  pSteamNetwork = ^TSteamNetwork;
  TSteamNetwork = class (TObject)
    private
      fGDSIP: ulong;
      fGDSPort: word;

      function ConectToServer(Addr: TSockAddr; const QUERY; QSize: uint32; Command: pByte; CSize: uint32; var ReplySize: uint32; IsConfigServer: boolean = false): pByte;

      // General Direcrory server
      function GetServer(Server_Q: array of byte): TSockAddr;
      function GetConfigServer(): TSockAddr;
      function GetAuthServer(): TSockAddr;
      function GetContentListServer(): TSockAddr;

      // Auth server
    private
     { Key, Cipher: array[0..15] of byte;
      Ticket1, Ticket2: array of byte;
      UserBLOB: TBLOBFile;   }
      //procedure MakeLoginPacket(Salt: array of byte; Pass: AnsiString; ExternalIP, LocalIP: uint32);
      //function ParseTicket(data: pByte; Size: uint32): boolean;

      // content lists server
    private

    public
      CDR: TCDR;
      MaxServers: uint16;

      OnLoadingProc: procedure(CaptionMain, CaptionProgress: string; CurrentProg, TotalProg: integer) of object;

      constructor Create(ServerAddr: string);
      destructor Destroy(); override;
      function IsInit(): boolean;

      // Config Server
      function Config_GetCDR(FileName: string): ENetWorkResult;
      function Config_GetVersionBLOB(var Size: uint32; var Data: pByte): ENetWorkResult;
      function Config_GetNetworkKey(var Size: uint16; var Data: pByte): ENetWorkResult;
      function Config_UpdateNetworkKey(): ENetWorkResult;

      // Auth Server
      function Auth_Login(UserName, Pass: AnsiString): ENetWorkResult;
      function Auth_IsLoginExists(UserName: AnsiString): ENetWorkResult;
      function Auth_CheckEMail(EMail: AnsiString): ENetWorkResult;

      // Content list server
      function ContentList_GetContentServers(AppID, Version, Region: uint32): TContentListEntries;
      function ContentList_GetContentServer(AppID, Version, Region: uint32): TSockAddr; overload;
      function ContentList_GetContentServer(DepotID, DepotVersion: int32): TSockAddr; overload;
      function ContentList_GetContentServer(): TSockAddr; overload; inline;

      // Content server
      function Content_DownloadPackage(Name: AnsiString; FileName: string): ENetWorkResult;
      function Content_DownloadGCF(AppID, Version: uint32): ENetWorkResult;
  end;

implementation

var
  GDS_QUERY: ulong = $02000000;
  GCS_Q_AUTH_SERVERS: array[0..4] of byte = (0,$C4,$1D,$1A,0);   // 0,
  GCS_Q_CONFIG_SERVERS: byte = 3;
  GCS_Q_CONTENTLIST_SERVERS: byte = 6;
  GCS_Q_CSER_SERVERS: byte = $14;

  CfS_QUERY: ulong = $03000000;
  CfS_Q_GET_VERSIONS: byte = 1;
  CfS_Q_GET_CDR: byte = 2;
  CfS_Q_GET_NETKEY: byte = 4;
  CfS_Q_UPDATE_CDR: byte = 9;

  AUT_QUERY: array [0..4] of byte = (0, 0, 0, 0, 4);
  AUTH_Q_CHECK_LOGIN: byte = $1d;
  AUTH_Q_CHECK_EMAIL: byte = $22;
  AUTH_Q_CREATE_USER: byte = $01;
  AUTH_Q_LP_LOGIN_CHECK: byte = $0e;
  AUTH_Q_LP_EMAIL_CHECK: byte = $20;
//  AUTH_Q_LP_PRODUCT_CHECK: byte = $21;
  AUTH_Q_CHANGE_PASS: byte = $0f;

  CL_QUERY: ulong = $02000000;
  CL_Q_GET_SERVERS_WITH_PACKAGES: uint16 = $0000;
  CL_Q_GET_SERVERS_WITH_STORAGES: uint16 = $0100;

  CS_PACKAGE_QUERY: uint32 = $03000000;
  CS_PACKAGE_GET_FILE: uint32 = $00000000;
  CS_PACKAGE_FIRST: uint32 = $02000000;
  CS_PACKAGE_CCLOSE: uint32 = $03000000;

  CS_STORAGE_QUERY: uint32 = $07000000;
  CS_STORAGE_BANNER_URL: uint32 = $00;
  //CS_STORAGE_NULL: uint32 = $01;
  CS_STORAGE_GET_CDR: uint32 = $02;
  CS_STORAGE_OPEN: uint32 = $09;
  CS_STORAGE_OPEN_EX: uint32 = $0a;
  CS_STORAGE_GET_MANIFEST: uint32 = $04;
  CS_STORAGE_GET_LIST_UPDATE_FILES: uint32 = $05;
  CS_STORAGE_GET_CHECKSUM: uint32 = $06;
  CS_STORAGE_GET_FILE: uint32 = $07;
  CS_STORAGE_CLOSE: uint32 = $03;

constructor TSteamNetwork.Create(ServerAddr: string);
begin
  inherited Create;

  fGDSIP:=0;
  if (ServerAddr='') then
    Exit;
  fGDSIP:=CSocket.GetIP(Parse(ServerAddr, ':'));
  fGDSPort:=Str2Int(ServerAddr);
  if (fGDSIP=0) or (fGDSPort=0) then
    Exit;
  MaxServers:=10;
  CDR:=nil;
end;

destructor TSteamNetwork.Destroy();
begin
  inherited Destroy;
end;

function TSteamNetwork.IsInit(): boolean;
begin
  result:=(fGDSIp<>0);
end;

// functions
{$REGION}
function TSteamNetwork.ConectToServer(Addr: TSockAddr; const QUERY; QSize: uint32; Command: pByte; CSize: uint32; var ReplySize: uint32; IsConfigServer: boolean = false): pByte;
var
  Accept: boolean;
  DestIP: uint32;
  Sock: CSocket;
begin
  result:=nil;
  Sock:=CSocket.Create(SOCKET_IP);
  if not Sock.Connect(Addr) then
    Exit;
  {if (Sock=nil) or (not Sock.Connect(Addr)) then
    Exit;  }
  Sock.SetTimeOut(3000);
  if not Sock.Send(QUERY, QSize) then
    Exit;
  if not Sock.recv(Accept, 1) then
    Exit;
  if IsConfigServer then
    if not Sock.recv(DestIP, 4) then
      Exit;
  if not Accept then
    Exit;
  CSize:=htonl(CSize);
  if not Sock.send(CSize, 4) then
    Exit;
  CSize:=htonl(CSize);
  if not Sock.send(Command^, CSize) then
    Exit;
  Sock.OnLoadingProc:=OnLoadingProc;
  result:=Sock.RecvFromLen(ReplySize);
  Sock.Free;
end;
{$ENDREGION}

// Get servers proc's
{$REGION}
function TSteamNetwork.GetServer(Server_Q: array of byte): TSockAddr;
var
  Data, d: pByte;
  Len: Word;
  i: integer;
  Size: uint32;
  Addr: TSockAddr;
  AddrList: array of TSockAddr;
begin
  FillChar(result, sizeof(TSockAddr), 0);
  FillChar(Addr, sizeof(TSockAddr), 0);
  Addr.sin_port:=htons(fGDSPort);
  Addr.sin_addr.S_addr:=fGDSIP;

  Data:=ConectToServer(Addr, GDS_QUERY, 4, @Server_Q[0], Length(Server_Q), Size);
  if Data=nil then
    Exit;

  d:=Data;
  Len:=0;
  Move(Data^, Len, 2);    inc(Data, 2);
  Len:=htons(Len);
  SetLength(AddrList, Len);
  for i:=0 to Len-1 do
  begin
    move(Data^, AddrList[i].sin_addr, 4);  inc(Data, 4);
    move(Data^, AddrList[i].sin_port, 2);  inc(Data, 2);
    AddrList[i].sin_port:=htons(AddrList[i].sin_port);
  end;
  FreeMem(d, Size);
  result:=AddrList[Random(Len)];
  result.sin_family:=AF_INET;
  SetLength(AddrList, 0);
end;

function TSteamNetwork.GetConfigServer(): TSockAddr;
begin
  result:=GetServer(GCS_Q_CONFIG_SERVERS);
end;

function TSteamNetwork.GetAuthServer(): TSockAddr;
begin
  result:=GetServer(GCS_Q_AUTH_SERVERS);
end;

function TSteamNetwork.GetContentListServer(): TSockAddr;
begin
  result:=GetServer(GCS_Q_CONTENTLIST_SERVERS);
end;

{$ENDREGION}

// config server proc's
{$REGION}
function TSteamNetwork.Config_GetCDR(FileName: string): ENetWorkResult;
var
  Data, Q: pByte;
  Size: uint32;
  str: TStream;
  Addr: TSockAddr;
  SHA: TSHA1;
begin
  result:=eConnectionError;
  Addr:=GetConfigServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;

  GetMem(Q, 21);
  Q[0]:=CfS_Q_GET_CDR;
  SHA:=TSHA1.Create();
  SHA.HashFile(FileName);
  Move(SHA.GetDigest^, (Q+1)^, 20);
  SHA.Free;

  Data:=ConectToServer(Addr, CfS_QUERY, 4, Q, 21, Size, true);
  FreeMem(Q, 21);

  str:=TStream.CreateWriteFileStream(FileName);
  str.Write(Data^, Size);
  str.Free;
  FreeMem(Data, Size);

  result:=eOK;
end;

function TSteamNetwork.Config_GetVersionBLOB(var Size: uint32; var Data: pByte): ENetWorkResult;
var
  Addr: TSockAddr;
begin
  Data:=nil;
  result:=eConnectionError;
  Addr:=GetConfigServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;

  Data:=ConectToServer(Addr, CfS_QUERY, 4, @CfS_Q_GET_VERSIONS, 1, Size, true);
  if Data<>nil then
    result:=eOK;
end;

function TSteamNetwork.Config_GetNetworkKey(var Size: uint16; var Data: pByte): ENetWorkResult;
var
  Accept: boolean;
  Len: uint16;
  Sock: CSocket;
  sign: pByte;
  PS: uint32;
  Addr: TSockAddr;
begin
  Data:=nil;
  result:=eConnectionError;
  Addr:=GetConfigServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;

  Sock:=CSocket.Create(SOCKET_IP);
  Sock.SetTimeOut(3000);
  if (Sock=nil) or (not Sock.Connect(Addr)) then
    Exit;
  if not Sock.Send(CfS_QUERY, 4) then
    Exit;
  if not Sock.Recv(Accept, 1) then
    Exit;
  if not Accept then
  begin
    result:=eServerReset;
    Exit;
  end;
  if not Sock.Recv(PS, 4) then
    Exit;

  PS:=htonl(1);
  if not Sock.Send(PS, 4) then
    Exit;
  if not Sock.Send(CfS_Q_GET_NETKEY, 1) then
    Exit;

  Data:=Sock.RecvFromLenShort(Size);

  //signature
  sign:=Sock.RecvFromLenShort(Len);
  if not RSACheckSign(MainKeySign, sign, Data, Size, 256) then
  begin
    FreeMem(Data, Size);
    Data:=nil;
    result:=eSignError;
  end
    else result:=eOK;

  FreeMem(sign, Len);
  Sock.Free;
end;

function TSteamNetwork.Config_UpdateNetworkKey(): ENetWorkResult;
var
  key: pByte;
  KeySize: uint16;
begin
  result:=Config_GetNetworkKey(KeySize, Key);
  if result=eOK then
    SetNetworkKey(@Key[KeySize-128-3]);
  FreeMem(Key, KeySize);
end;
{$ENDREGION}

// Auth server proc's
{$REGION }

const
  SecPerDay = 86400;
  Offset1970 = 25569;
  SecPerHour = 3600;

var
  TimeZoneInformation: TTimeZoneInformation;
  TimeZoneBias: double;

function GetSteamTime(): uint64; inline;
begin
  Result:=(round((Now()-719163+TimeZoneBias)*(24*3600))+62135596800)*1000000;
end;

function GetDateTime(SteamTime: uint64): TDateTime; inline;
begin
  Result:=719163+(Trunc(SteamTime/1000000-62135596800)/(24*3600))-TimeZoneBias;
end;

(*const
  CLEAR_DATA: pAnsiChar = #4#4#4#4;
  LOGIN_IV: pAnsiChar = #1#1#1#1#1#1#1#1#1#1#1#1#1#1#1#1;
  LOGIN_NULLDATA: pAnsiChar = #$00#$0c#$00#$10;

procedure TSteamNetwork.MakeLoginPacket(Salt: array of byte; Pass: AnsiString; ExternalIP, LocalIP: uint32);
var
  i: integer;
  SHA: TSHA1;
  AES: TCipher_Rijndael;
  XorKey, timest, ClearText: array[0..15] of byte;
  SteamTimeStamp: uint64;
begin
  ExternalIP:=htonl(ExternalIP);

  // Password-based key
  SHA:=TSHA1.Create();
  SHA.AddBytes(@Salt[0], 4);
  SHA.AddBytes(@Pass[1], Length(Pass));
  SHA.AddBytes(@Salt[4], 4);
  Move(SHA.GetDigest^, Key[0], 16);
  SHA.Free;

  // Xor Key
  SHA:=TSHA1.Create;
  SHA.AddBytes(@ExternalIP, 4);
  SHA.AddBytes(@LocalIP, 4);
  Move(SHA.GetDigest^, XorKey[0], 8);
  SHA.Free;

  // Clear text
  SteamTimeStamp:=GetSteamTime();
  Move(SteamTimeStamp, timest, 8);
  for i:=0 to 7 do
    ClearText[i]:=XorKey[i] xor timest[i];
  Move(LocalIP, ClearText[8], 4);
  Move(CLEAR_DATA[0], ClearText[12], 4);

  // encrypt data
  AES:=TCipher_Rijndael.Create();
  AES.Mode:=cmCBCx;
  AES.Init(Key[0], 16, LOGIN_IV[0], 16);
  AES.Encode(ClearText[0], Cipher[0], 16);
  AES.Free;
end;

type
  TTicketHeader = record
    SZ1,
    SZ2: uint16;
  end;

function SignMessage(Key: pByte; Mess: pByte; MessLen: integer): pByte;
var
  i: integer;
  chA: array[0..19] of byte;
  keyA, keyB: array[0..63] of byte;
  SHA: TSHA1;
begin
  for i:=0 to 63 do
  begin
    if i<16 then keyA[i]:=Key[i] xor $36
      else KeyA[i]:=$00 xor $36;
    if i<16 then keyB[i]:=Key[i] xor $5c
      else KeyB[i]:=$00 xor $5c;
  end;

  SHA:=TSHA1.Create;
  SHA.AddBytes(@KeyA[0], 64);
  SHA.AddBytes(@Mess[0], MessLen);
  Move(SHA.GetDigest()^, chA[0], 20);
  SHA.Free;

  SHA:=TSHA1.Create;
  SHA.AddBytes(@KeyB[0], 64);
  SHA.AddBytes(@chA[0], 20);
  GetMem(result, 20);
  Move(SHA.GetDigest()^, result^, 20);
  SHA.Free;
end;

function TSteamNetwork.ParseTicket(data: pByte; Size: uint32): boolean;
var
  //i: integer;
  //BLOBsign: pByte;
  firstIV: array[0..15] of byte;
  //sign: array[0..19] of byte;
  TicketSign: array[0..127] of byte;
  BLOBSize: uint32;
  AES: TCipher_Rijndael;
  str, tmp: TStream;

  TicketHeader: TTicketHeader;
  SubHeader: TTicket_SubHeader;
  BLOBHeader: TTicket_BLOBHeader;
  UserHeader: TTicket_UserHeader;
  TestData: TTicket_TestData;
begin
  result:=false;

  str:=TStream.CreateWriteFileStream('.\userticket.dat');
  str.Write(data^, Size);
  str.Free;

  tmp:=TStream.CreateMemoryStreamEx(data, Size);

  // subheader
  tmp.Read(SubHeader, sizeof(TTicket_SubHeader));
  SubHeader.TicketLen:=htons(SubHeader.TicketLen);
  AES:=TCipher_Rijndael.Create();
  AES.Mode:=cmCBCx;
  AES.Init(Key[0], 16, SubHeader.outerIV[0], 16);
  AES.Decode(SubHeader.EncrData[0], UserHeader, 64);
  AES.Free;

  // Ticket
    // part 1
  tmp.Read(TicketHeader, sizeof(TTicketHeader));
   TicketHeader.SZ2:=htons(TicketHeader.SZ2);
   SetLength(Ticket1, TicketHeader.SZ2);
  tmp.Read(firstIV[0], 16);
  tmp.Read(Ticket1[0], TicketHeader.SZ2);
    // part 2
  tmp.Read(TicketHeader, sizeof(TTicketHeader));
   TicketHeader.SZ2:=htons(TicketHeader.SZ2);
   SetLength(Ticket2, TicketHeader.SZ2);
  tmp.Read(Ticket2[0], TicketHeader.SZ2);

  // user validation data
  tmp.Read(TestData, sizeof(TTicket_TestData));
  if (UserHeader.SteamID<>TestData.SteamID) then
    Exit;
  tmp.Seek(-(sizeof(TTicket_TestData)-2)+htons(TestData.len), spCurrent);
  tmp.Read(TicketSign[0], 128);

  // user BLOB
  tmp.Seek(4, spCurrent);
  tmp.Read(BLOBHeader, sizeof(TTicket_BLOBHeader));
  BLOBSize:=BLOBHeader.Len2-20-sizeof(TTicket_BLOBHeader);
  str:=TStream.CreateMemoryStream();
  AES:=TCipher_Rijndael.Create();
  AES.Mode:=cmCBCx;
  AES.Init(UserHeader.InnerKey[0], 16, BLOBHeader.InnerIV[0], 16);
  AES.DecodeStream(tmp, str, BLOBSize);
  AES.Free;
  str.Position:=0;
  UserBLOB:=TBLOBFile.Create(str);
  USERBLOB.SaveToFile('.\user.blob');
  str.Free;

  // check signature
 { BLOBSign:=SignMessage(@UserHeader.InnerKey[0], data+tmp.Position-20-BLOBSize, BLOBSize+20);
  tmp.Read(sign[0], 20);
  for i:=0 to 19 do
    if sign[i]<>BLOBSign[i] then
    begin
      tmp.Free;
      Exit;
    end;  }

  tmp.Free;
  result:=true;
end;
      *) (*
type
  TLoginPacketHeader = packed record    // 36 bytes
    check: uint32;                      // the 4 characters 'V', 'S', '0', '1' (0x56, 0x53, 0x30, 0x31)
    PacketLen: uint16;                  // the length of the packet after this header
    TypeBits: uint16;                   // the first byte is possibly some type identifier. It is always <8
    DestinationID: uint32;              // the destination ID of the packet
    SourceID: uint32;                   // the source ID of the packet
    SequenceNumber: uint32;             // the packet's sequence number. server and client keep track of own numbers
    SequenceNumberLastReceived: uint32; // 	the sequence number of the last packet received
    SplitCount: uint32;                 // the number of packets the current message was split in to
    SequenceOfFirstPacket: uint32;      // the sequence number of the first packet for current message
    AllDataSize: uint32;                // the length of the data in this message (which will be greater than packet length if the message is split)
  end;
  TLoginPacketHeaderEx = packed record    // 36 bytes
    check: uint32;                      // the 4 characters 'V', 'S', '0', '1' (0x56, 0x53, 0x30, 0x31)
    PacketLen: uint16;                  // the length of the packet after this header
    TypeBits: uint16;                   // the first byte is possibly some type identifier. It is always <8
    DestinationID: uint32;              // the destination ID of the packet
    SourceID: uint32;                   // the source ID of the packet
    SequenceNumber: uint32;             // the packet's sequence number. server and client keep track of own numbers
    SequenceNumberLastReceived: uint32; // 	the sequence number of the last packet received
    SplitCount: uint32;                 // the number of packets the current message was split in to
    SequenceOfFirstPacket: uint32;      // the sequence number of the first packet for current message
    AllDataSize: uint32;                // the length of the data in this message (which will be greater than packet length if the message is split)
    Data: uint32;
    Distance: uint32;
  end;

const
  LOGIN_HEADER_CHECK: uint32 = $31305356;
  LOGIN_PACKET_C2S_INIT: uint16 = $0001;
  LOGIN_PACKET_S2C_INIT: uint16 = $0002;
  LOGIN_PACKET_C2S_1: uint16 = $0403;
  LOGIN_PACKET_S2C_2: uint16 = $0404;
  LOGIN_PACKET_S2C_3: uint16 = $0406;
  LOGIN_PACKET_C2S_4: uint16 = $0406;
  LOGIN_PACKET_S2C_5: uint16 = $0406;


var
  Login_Servers: array[0..35] of string =
    ('72.165.61.174'{'68.142.64.165'}, '72.165.61.175', '72.165.61.176', '72.165.61.185',
     '72.165.61.186', '72.165.61.187', '72.165.61.188', '69.28.156.250',
     '68.142.64.164', '68.142.64.165', '69.28.145.170', '69.28.145.171',
     '69.28.145.172', '208.111.158.52', '208.111.158.53', '208.111.171.82',
     '208.111.171.83', '68.142.91.34', '68.142.91.35', '68.142.91.36',
     '208.111.133.84', '208.111.133.85', '68.142.116.178', '68.142.116.179',
     '68.142.83.180', '68.142.83.181', '68.142.83.182', '68.142.83.183',
     '79.141.174.7', '79.141.174.8', '79.141.174.9', '79.141.174.10',
     '81.171.115.5', '81.171.115.6', '81.171.115.7', '81.171.115.8');

procedure Make0Header(var Header: TLoginPacketHeaderEx);
begin
  Header.check:=LOGIN_HEADER_CHECK;
  Header.PacketLen:=0;
  Header.TypeBits:=LOGIN_PACKET_C2S_INIT;
  Header.DestinationID:=$200;
  Header.SourceID:=0;
  Header.SequenceNumber:=1;
  Header.SequenceNumberLastReceived:=0;
  Header.SplitCount:=0;
  Header.SequenceOfFirstPacket:=0;
  Header.AllDataSize:=0;
end;

function SendData(Sock: CSocket; type_: uint16; seq, ack: uint32; last: uint32; src, dst: uint32; split: uint32; Data: TByteArray): boolean;
var
  Header: TLoginPacketHeader;
begin
  result:=false;
  Header.check:=LOGIN_HEADER_CHECK;
  Header.PacketLen:=Length(Data);
  Header.TypeBits:=type_;
  Header.DestinationID:=dst;
  Header.SourceID:=src;
  Header.SequenceNumber:=seq;
  Header.SequenceNumberLastReceived:=ack;
  Header.SplitCount:=split;
  Header.SequenceOfFirstPacket:=seq;
  Header.AllDataSize:=Length(Data);
  if not Sock.Send(Header, sizeof(TLoginPacketHeader)) then
    Exit;
  if (Header.PacketLen>0) then
    if not Sock.Send(Data, Header.PacketLen) then
      Exit;
  result:=true;
end;

function LoginHandsnake(var Socket: CSocket; Addr: string): boolean;
var
  Header: TLoginPacketHeaderEx;
begin
  result:=false;
  Socket:=CSocket.Create(SOCKET_UDP);
  if not Socket.Connect(Addr, 27017) then
    Exit;
  //Socket.SetTimeOut(3000);
  Header.check:=LOGIN_HEADER_CHECK;
  Header.PacketLen:=0;
  Header.TypeBits:=LOGIN_PACKET_C2S_INIT;
  Header.DestinationID:=$200;
  Header.SourceID:=0;
  Header.SequenceNumber:=1;
  Header.SequenceNumberLastReceived:=0;
  Header.SplitCount:=0;
  Header.SequenceOfFirstPacket:=0;
  Header.AllDataSize:=0;
  if not Socket.Send(Header, sizeof(TLoginPacketHeaderEx)-8) then
    Exit;
  result:=true;
end;    *)

const
  LOGIN_SERVERS: string = '72.165.61.174 72.165.61.175 72.165.61.176 72.165.61.185 '+
                          '72.165.61.186 72.165.61.187 72.165.61.188 69.28.156.250 '+
                          '68.142.64.164 68.142.64.165 69.28.145.170 69.28.145.171 '+
                          '69.28.145.172 208.111.158.52 208.111.158.53 208.111.171.82 '+
                          '208.111.171.83 68.142.91.34 68.142.91.35 68.142.91.36 '+
                          '208.111.133.84 208.111.133.85 68.142.116.178 68.142.116.179 '+
                          '68.142.83.180 68.142.83.181 68.142.83.182 68.142.83.183 '+
                          '79.141.174.7 79.141.174.8 79.141.174.9 79.141.174.10 '+
                          '81.171.115.5 81.171.115.6 81.171.115.7 81.171.115.8';

function TSteamNetwork.Auth_Login(UserName, Pass: AnsiString): ENetWorkResult;
{var
  i, l, mainServer: integer;
  mainAddr: string;
  Socks: array of CSocket;
  ServersReply: array of record
      Data: pByte;
      DataSize: uint32;
    end;
  Header: TLoginPacketHeader;
  HeaderEx: TLoginPacketHeaderEx;
  Headers: array of TLoginPacketHeaderEx;
  str: TStream;
  b, d: pByte;
  ServerMask, DistanceMin: uint32;
  Data: array of byte;
  DataSize: integer; }
var
  Server: CSteamFriendsProto;
begin
  result:=eConnectionError;
  Server:=CSteamFriendsProto.Create(LOGIN_SERVERS);
  if not Server.HandSnake() then
  begin
    result:=eBadAuthReply;
    Exit;
  end;
  {str:=TStream.CreateReadFileStream('e:\Projects\Steam\NetWork\SteamNet\exe\in.bin');
  l:=str.Size;
  GetMem(b, l);
  str.Read(b^, l);
  str.Free;

  d:=RSADecrypt(NetWorkKey, b, l);
  str:=TStream.CreateWriteFileStream('e:\Projects\Steam\NetWork\SteamNet\exe\out.bin');
  str.Write(d^, l);
  str.Free;   }

  //result:=eConnectionError;



  (*

  l:=Length(Login_Servers);
  mainAddr:='';
  SetLength(ServersReply, l);
  SetLength(Socks, l);
  SetLength(Headers, l);


  {  Socks[2]:=CSocket.Create(SOCKET_UDP);
    if not Socks[2].Connect(Login_Servers[2], 27017) then
      Exit;
    Make0Header(Header);
    if not SendData(Socks[2], LOGIN_PACKET_C2S_INIT, 1, 0, 0, $200, 0, 0, nil) then
      Exit;

    if not Socks[2].Send(Header.check, sizeof(TLoginPacketHeader)) then
      Exit;
    if not Socks[2].Recv(Header.check, sizeof(TLoginPacketHeader)) then
      Exit;
    ServersReply[2].DataSize:=Header.PacketLen;
    if not Socks[2].Recv(ServersReply[2].Data, ServersReply[2].DataSize) then
      Exit;
    ServerMask:=puint32(ServersReply[2].Data)^;

                                      }
  //l:=1;
  for i:=0 to l-1 do
  begin
    Writeln(i);
    //sleep(200);
    if not LoginHandsnake(Socks[i], login_servers[i]) then
      break;
  end;
  DistanceMin:=$ffff;
  for i:=0 to l-1 do
  begin
    Writeln(i);
    //sleep(100);
    if not Socks[i].Recv(Headers[i], sizeof(TLoginPacketHeaderEx)) then
      Break;
    if Headers[i].Distance<DistanceMin then
    begin
      DistanceMin:=Headers[i].Distance;
      mainServer:=i;
    end;
    {$IFDEF LOG}
      Log('Handsnake from server "'+inet_ntoa(Socks[i].Addr.sin_addr)+'" OK');
    {$ENDIF}
    {if i=0 then
    begin

    end;  }
  end;
  for i:=0 to l-1 do
    if i<>mainServer then
      Socks[i].Destroy();

  Make0Header(HeaderEx);
  HeaderEx.Data:=HeaderEx.Data xor $A426DF2B;
  HeaderEx.PacketLen:=4;
  HeaderEx.TypeBits:=$0403;
  HeaderEx.SequenceNumber:=1;
  HeaderEx.SequenceOfFirstPacket:=1;
  HeaderEx.SequenceNumberLastReceived:=1;
  HeaderEx.SplitCount:=1;
  HeaderEx.DestinationID:=$200;
  HeaderEx.SourceID:=0;
  HeaderEx.AllDataSize:=4;
  if not Socks[mainServer].Send(HeaderEx, sizeof(TLoginPacketHeaderEx)-4) then
    Exit;
  if not Socks[mainServer].Recv(HeaderEx, sizeof(TLoginPacketHeaderEx)-8) then
    Exit;
  SetLength(Data, 2048*10);
  //Socks[i].Recv(HeaderEx, sizeof(TLoginPacketHeaderEx)-8); Writeln(5);
  if not Socks[mainServer].Recv(Data[0], $1c+sizeof(TLoginPacketHeaderEx)-8) then
    Exit;
  Move(Data[0], HeaderEx, sizeof(TLoginPacketHeaderEx)-4);


  Result:=eOK; *)
end;
{var
  Accept: byte;
  NameLen, NL: uint16;
  Sock: CSocket;
  LocalIP, ExternalIP, UserHash, PacketSize: uint32;
  Salt:array[0..7] of byte;
  ServerTime, TimeMAXDelta: uint64;
  LoginPacket: pByte;
  Addr: TSockAddr;
begin
  result:=eConnectionError;

  Addr:=GetAuthServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;
  Sock:=CSocket.Create(SOCKET_IP);
  Sock.SetTimeOut(3000);
  if (Sock=nil) or (not Sock.Connect(Addr)) then
    Exit;

  LocalIP:=htonl(CSocket.GetIP(''));
  NameLen:=Length(UserName);
  UserHash:=htonl(jenkinsLookupHash2(@UserName[1], NameLen, 0));

  if not Sock.Send(AUT_QUERY[0], length(AUT_QUERY)) then
    Exit;
  if not Sock.Send(LocalIP, 4) then
    Exit;
  if not Sock.Send(UserHash, 4) then
    Exit;

  if not Sock.Recv(Accept, 1) then
    Exit;
  if not Sock.Recv(ExternalIP, 4) then
    Exit;
  if Accept<>0 then
  begin
    result:=eServerReset;
    Exit;
  end;

  Accept:=2;
  NL:=htons(NameLen);
  PacketSize:=htonl(5+NameLen*2);
  if not Sock.Send(PacketSize, 4) then
    Exit;
  if not Sock.Send(Accept, 1) then
    Exit;
  if not Sock.Send(NL, 2) then
    Exit;
  if not Sock.Send(UserName[1], NameLen) then
    Exit;
  if not Sock.Send(NL, 2) then
    Exit;
  if not Sock.Send(UserName[1], NameLen) then
    Exit;

  if not Sock.Recv(Salt[0], 8) then
    Exit;

  MakeLoginPacket(Salt, Pass, ExternalIP, htonl(LocalIP));

  PacketSize:=htonl(16*2+4);
  if not Sock.Send(PacketSize, 4) then
    Exit;
  if not Sock.Send(LOGIN_IV[0], 16) then
    Exit;
  if not Sock.Send(LOGIN_NULLDATA[0], 4) then
    Exit;
  if not Sock.Send(Cipher[0], 16) then
    Exit;

  if not Sock.Recv(Accept, 1) then
    Exit;
  if not Sock.Recv(ServerTime, 8) then
    Exit;
  if not Sock.Recv(TimeMAXDelta, 8) then
    Exit;

  writeln('Server time: ', DateTime2StrShort(GetDateTime(ServerTime)));

  case Accept of
    0: result:=eLoggedIn;
    1: result:=eAccountNotExist;
    2: result:=eAccountNotExistOrPasswordNotCorrect;
    3: result:=eClockDiffers;
    4: result:=eAccountDisabled;
    else result:=eAccountUnknowError;
  end;

  if Accept=0 then
  begin
    LoginPacket:=Sock.RecvFromLen(PacketSize);
    if not ParseTicket(LoginPacket, PacketSize) then
    begin
      FreeMem(LoginPacket, PacketSize);
      result:=eBadAuthReply;
      Exit;
    end;
    FreeMem(LoginPacket, PacketSize);
  end;

  Sock.Free;
end;           }
      (*
type
  pAuth_Request = ^TAuth_Request;
  TAuth_Request = packed record
    PacketSize: uint32;
    RSABlockSize: uint16; // always $0080 (128bytes)
    RSABlock: array[0..127] of byte;
    DataLen: uint32;
    NodeHeader: uint16;
    NodeSize: uint32;
    SlackSize: uint32;
    PlainSize: uint32;
    IV: array[0..15] of byte;
    BLOB: array of byte;
    sign: array[0..19] of byte;
  end;

procedure GetAESKey(Data: pByte; Size: uint32; Key: TRSAKey);
var
  i: integer;
  SHA: TSHA1;
  d: array[0..3] of byte;
  buf: array[0..127] of byte;
  first, PK, control: array[0..19] of byte;
  //ch: array[0..5] of array[0..19] of byte;
  total, fin: array[0..139] of byte;

  procedure GetCH(No: byte; SPK: pByte; chN: pByte);
  begin
    SHA:=TSHA1.Create();
    SHA.AddBytes(SPK, 20);
    d[3]:=No;
    SHA.AddBytes(@d[0], 4);
    Move(SHA.GetDigest()^, chN^, 20);
    SHA.Free;
  end;
begin
  Move(RSADecrypt(Key, Data, Size)^, buf[0], 128);
  FillChar(d[0], 4, 0);

  // firstpasschecksum
  SHA:=TSHA1.Create();
  SHA.AddBytes(@buf[20], 107);
  SHA.AddBytes(@d[0], 4);
  Move(SHA.GetDigest()^, first[0], 20);
  // secondpasskey
  for i:=0 to 19 do
    PK[i]:=first[i] xor buf[i];
  {// secondpasschecksum0
  GetCH(0, @PK[0], @ch[0][0]);
  // secondpasschecksum1
  GetCH(1, @PK[0], @ch[1][0]);
  // secondpasschecksum2
  GetCH(2, @PK[0], @ch[2][0]);
  // seczndpasschecksum3
  GetCH(3, @PK[0], @ch[3][0]);
  // secondpasschecksum4
  GetCH(4, @PK[0], @ch[4][0]);
  // secondpasschecksum5
  GetCH(5, @PK[0], @ch[5][0]);
  // secondpasstotalchecksum
  for i:=0 to 106 do
    total[i]:=ch[i div 20][i mod 20];   }
  GetCH(0, @PK[0], @total[0]);
  GetCH(1, @PK[0], @total[20]);
  GetCH(2, @PK[0], @total[40]);
  GetCH(3, @PK[0], @total[60]);
  GetCH(4, @PK[0], @total[80]);
  GetCH(5, @PK[0], @total[100]);

  // controlchecksum
  SHA:=TSHA1.Create();
  Move(SHA.GetDigest()^, control[0], 20);
  SHA.Free;
  // finishedkey
  for i:=0 to 106 do
    fin[i]:=total[i] xor buf[i+20];

  if memcmp(@fin[0], @control[0], 20)<>0 then
    writeln('Error');
end;

function MakeRSALoginPacket(AESKey: pByte): pByte;
var
  i: integer;
  SHA: TSHA1;
  d: array[0..3] of byte;
  firstpasschecksum: array[0..19] of byte;
  res: array[0..126] of byte;
  total: array[0..139] of byte;

  procedure GetCH(No: byte; SPK: pByte; chN: pByte; len: uint32 = 20);
  begin
    SHA:=TSHA1.Create();
    SHA.AddBytes(SPK, len);
    d[3]:=No;
    SHA.AddBytes(@d[0], 4);
    Move(SHA.GetDigest()^, chN^, 20);
    SHA.Free;
  end;
begin
  FillChar(d[0], 4, 0);

  for i:=0 to 126 do
    res[i]:=i;

  // controlchecksum
  SHA:=TSHA1.Create();
  Move(SHA.GetDigest()^, res[20], 20);
  SHA.Free;
  Move(res[111], AESKey[0], 16);

  GetCH(0, @res[0], @total[0]);
  GetCH(1, @res[0], @total[20]);
  GetCH(2, @res[0], @total[40]);
  GetCH(3, @res[0], @total[60]);
  GetCH(4, @res[0], @total[80]);
  GetCH(5, @res[0], @total[100]);
  for i:=0 to 106 do
    res[20+i]:=res[20+i] xor total[i];

  GetCH(0, @res[20], @firstpasschecksum[0], 107);
  for i:=0 to 19 do
    res[i]:=res[i] xor firstpasschecksum[i];

  result:=RSAEncrypt(NetWorkKey, @res[0], 127);
end;

function MakeLoginPacketEx(Request: pAuth_Request; BLOB: TBLOBFile; var BLOBSize: uint32): uint32;
var
  BLOBMem, RSA: pByte;
  AES: TCipher_Rijndael;
  AESKey: array[0..15] of byte;
  data: array[0..150] of byte;
begin
  RSA:=MakeRSALoginPacket(@AESKey[0]);

  BLOBMem:=nil;
  Request.PlainSize:=BLOB.SaveToMem(BLOBMem);

  BLOBSize:=Request.PlainSize + (16-(Request.PlainSize mod 16));
  SetLength(Request.BLOB, BLOBSize);
  FillChar(Request.BLOB[0], BLOBSize, 0);
  Move(BLOBMem^, Request.BLOB[0], Request.PlainSize);
  FreeMem(BLOBMem, Request.PlainSize);

  AES:=TCipher_Rijndael.Create();
  AES.Mode:=cmCBCx;
  AES.Init(AESKey[0], 16, Request.IV[0], 16);
  AES.Encode(Request.BLOB[0], Request.BLOB[0], BLOBSize);
  AES.Free;

  // sign message
  Move(Request.PlainSize, data[0], 20);
  Move(Request.BLOB[0], data[20], BLOBSize);
  Move(SignMessage(@AESKey[0], @data[0], BLOBSize+20)^, Request.sign[0], 20);

  Request.RSABlockSize:=$8000;
  Move(RSA^, Request.RSABlock[0], 128);
  Request.DataLen:=htonl(BLOBSize+16+3*4+2);
  Request.NodeHeader:=$4501;
  Request.NodeSize:=Request.DataLen;
  Request.SlackSize:=0;

  result:=htonl(sizeof(TAuth_Request)-8{DynArray}+BLOBSize);
end;     *)

function TSteamNetwork.Auth_IsLoginExists(UserName: AnsiString): ENetWorkResult;
{var
  Accept: byte;
  Sock: CSocket;
  LocalIP, ExternalIP, PacketSize, BLOBSize: uint32;
  Addr: TSockAddr;

  NKSize, NKSSize: uint16;
  NetKey, NKSign: pByte;

  Request: TAuth_Request;
  BLOB: TBLOBFile;     }
begin
  result:=eConnectionError;
              (*
  Addr:=GetAuthServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;
  Sock:=CSocket.Create(SOCKET_IP);
  Sock.SetTimeOut(3000);
  if (Sock=nil) or (not Sock.Connect(Addr)) then
    Exit;

  LocalIP:=htonl(CSocket.GetIP(''));
  PacketSize:=0;

  {Move(AUT_QUERY[0], AESKey[0], 5);
  Move(LocalIP, AESKey[5], 4);
  Move(PacketSize, AESKey[9], 4);
  if not Sock.Send(AESKey[0], 13) then
    Exit;   }
  if not Sock.Send(AUT_QUERY[0], length(AUT_QUERY)) then
    Exit;
  if not Sock.Send(LocalIP, 4) then
    Exit;
  if not Sock.Send(PacketSize, 4) then
    Exit;

  if not Sock.Recv(Accept, 1) then
    Exit;
  if not Sock.Recv(ExternalIP, 4) then
    Exit;
  if Accept<>0 then
  begin
    result:=eServerReset;
    Exit;
  end;

  Sock.SendFromLen(1, @AUTH_Q_CHECK_LOGIN);
  NetKey:=Sock.RecvFromLenShort(NKSize);
  NKSign:=Sock.RecvFromLenShort(NKSSize);

  if not RSACheckSign(MainKeySign, NKSign, NetKey, NKSize, NKSSize) then
  begin
    LocalIP:=0;
    Sock.Send(LocalIP, 4);
    result:=eSignError;
    Exit;
  end;
  SetNetworkKey(@NetKey[NKSize-128-3]);

  // create BLOB
  FillChar(Request.IV[0], 16, $12);
  BLOB:=TBLOBFile.Create();
  UserName:=UserName+#0;
  BLOB.RootNode.AddData(#1#0#0#0, @UserName[1], Length(UserName));
  PacketSize:=MakeLoginPacketEx(@Request, BLOB, BLOBSize);
  BLOB.Free;

  if not Sock.Send(Request, PacketSize) then
    Exit;
  if not Sock.Send(Request.BLOB[0], BLOBSize) then
    Exit;
  if not Sock.Send(Request.sign[0], 20) then
    Exit;
  SetLength(Request.BLOB, 0);

  if not Sock.Recv(Accept, 1) then
    Exit;
  if Accept=0 then result:=eUsetNotExists
    else result:=eUserExists; *)
end;

function TSteamNetwork.Auth_CheckEMail(EMail: AnsiString): ENetWorkResult;
begin
  result:=eConnectionError;
end;

{$ENDREGION}

// Content list server proc's
{$REGION}

function GetAddr(Data: pByte; IsPKGServer: boolean): TSockAddr;
var
  Count, idx: uint16;
  reply: array of TContentListEntry;
begin
  Move(data[0], Count, 2);
  Count:=htons(Count);
  SetLength(reply, Count);
  Move(Data[2], reply[0], sizeof(TContentListEntry)*Count);
  idx:=Random(Count);
  result.sin_family:=AF_INET;
  if IsPKGServer then
  begin
    result.sin_addr.S_addr:=reply[idx].ClientUpdateIP;
    result.sin_port:=htons(reply[idx].ClientUpdatePort);
  end
    else
  begin
    result.sin_addr.S_addr:=reply[idx].ContentServerIP;
    result.sin_port:=htons(reply[idx].ContentServerPort);
  end;
  SetLength(reply, 0);
end;

function TSteamNetwork.ContentList_GetContentServers(AppID, Version, Region: uint32): TContentListEntries;
var
  Count: uint16;
  i: integer;
  PacketSize: uint32;
  Data, Q: pByte;
  Addr: TSockAddr;
begin
  SetLength(result, 0);

  Addr:=GetContentListServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;

  AppID:=htonl(AppID);
  Version:=htonl(Version);
  Count:=htons(MaxServers);
  Region:=htonl(Region);
  GetMem(Q, 25);
  Q[0]:=0;
  Move(CL_Q_GET_SERVERS_WITH_STORAGES, Q[1], 2);
  Move(AppID, Q[3], 4);
  Move(Version, Q[7], 4);
  Move(Count, Q[11], 2);
  Move(Region, Q[13], 4);
  FillChar(Q[17], 8, $ff);

  Data:=ConectToServer(Addr, CL_QUERY, 4, Q, 25, PacketSize);
  FreeMem(Q, 25);
  if Data=nil then
    Exit;

  Move(data[0], Count, 2);
  Count:=htons(Count);
  SetLength(result, Count);
  Move(Data[2], result[0], sizeof(TContentListEntry)*Count);
  for i:=0 to Count-1 do
  begin
    result[i].ClientUpdatePort:=htons(result[i].ClientUpdatePort);
    result[i].ContentServerPort:=htons(result[i].ContentServerPort);
  end;
end;

function TSteamNetwork.ContentList_GetContentServer(AppID, Version, Region: uint32): TSockAddr;
var
  Count: uint16;
  PacketSize: uint32;
  Data, Q: pByte;
  Addr: TSockAddr;
begin
  FillChar(result, sizeof(TSockAddr), 0);

  Addr:=GetContentListServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;

  AppID:=htonl(AppID);
  Version:=htonl(Version);
  Count:=htons(MaxServers);
  Region:=htonl(Region);
  GetMem(Q, 25);
  Q[0]:=0;
  Move(CL_Q_GET_SERVERS_WITH_STORAGES, Q[1], 2);
  Move(AppID, Q[3], 4);
  Move(Version, Q[7], 4);
  Move(Count, Q[11], 2);
  Move(Region, Q[13], 4);
  FillChar(Q[17], 8, $ff);

  Data:=ConectToServer(Addr, CL_QUERY, 4, Q, 25, PacketSize);
  FreeMem(Q, 25);

  result:=GetAddr(Data, false);
  FreeMem(Data, PacketSize);
end;

function TSteamNetwork.ContentList_GetContentServer(DepotID, DepotVersion: int32): TSockAddr;
var
  Count: uint16;
  PacketSize: uint32;
  Data, Q: pByte;
  Addr: TSockAddr;
begin
  FillChar(result, sizeof(TSockAddr), 0);

  Addr:=GetContentListServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;
  Count:=CL_MAX_SERVERS;

  GetMem(Q, 21);
  Q[0]:=0;
  Move(CL_Q_GET_SERVERS_WITH_PACKAGES, Q[1], 2);
  Move(DepotID, Q[3], 4);
  Move(DepotVersion, Q[7], 4);
  Move(Count, Q[11], 2);
  Move(REGION_Rest_World, Q[13], 4);
  FillChar(Q[17], 4, $ff);

  Data:=ConectToServer(Addr, CL_QUERY, 4, Q, 21, PacketSize);
  FreeMem(Q, 21);

  result:=GetAddr(Data, true);
  FreeMem(Data, PacketSize);
end;

function TSteamNetwork.ContentList_GetContentServer(): TSockAddr;
begin
  result:=ContentList_GetContentServer(0, 0);
end;

{$ENDREGION}

// Content server proc's
{$REGION}

function TSteamNetwork.Content_DownloadPackage(Name: AnsiString; FileName: string): ENetWorkResult;
var
  Accepted: boolean;
  Sock: CSocket;
  PacketSize, Request, MessSize: uint32;
  Data, Mess: pByte;
  str: TStream;
  Addr: TSockAddr;

  procedure ProcPackage(N, FN: AnsiString);
  begin
    PacketSize:=htonl(4+8+Length(N)+4);
    if not Sock.Send(PacketSize, 4) then
      Exit;
    if not Sock.Send(CS_PACKAGE_GET_FILE, 4) then
      Exit;
    Request:=0;
    if not Sock.Send(Request, 4) then
      Exit;
    Request:=htonl(Length(N));
    if not Sock.Send(Request, 4) then
      Exit;
    if not Sock.Send(N[1], Length(N)) then
      Exit;
    Request:=0;
    if not Sock.Send(Request, 4) then
      Exit;

    if not Sock.Recv(PacketSize, 4) then
      Exit;
    Data:=Sock.RecvFromLen(PacketSize);
  end;
begin
  result:=eConnectionError;

  Addr:=ContentList_GetContentServer();
  if Addr.sin_addr.S_addr=0 then
    Exit;

  Sock:=CSocket.Create(SOCKET_IP);
  Sock.SetTimeOut(3000);
  if (Sock=nil) or (not Sock.Connect(Addr)) then
    Exit;

  if not Sock.Send(CS_PACKAGE_QUERY, 4) then
    Exit;
  if not Sock.Recv(Accepted, 1) then
    Exit;
  if not Accepted then
  begin
    result:=eServerReset;
    Exit;
  end;

  ProcPackage(Name, Wide2Ansi(FileName));
  MessSize:=PacketSize;
  Mess:=Data;
  ProcPackage(Name+'_rsa_signature', '');

  Sock.Free;

  if RSACheckSign(NetWorkKeySign, Data, Mess, MessSize, 128) then
  begin
    str:=TStream.CreateWriteFileStream(FileName);
    str.Write(Mess^, MessSize);
    str.Free;
    result:=eOK;
  end
    else result:=eSignError;

  FreeMem(Mess, MessSize);
  FreeMem(Data, 128);
end;

function TSteamNetwork.Content_DownloadGCF(AppID, Version: uint32): ENetWorkResult;
var
  Accepted: boolean;
  Sock: CSocket;
  i: integer;
  ConnID, MessageID, MsgID, BlockSize, CacheID, ManifestCheck: uint32;
  ManifestSize, ChecksumSize, PS: uint32;
  Manifest, Checksum: pByte;
  UpdateList: puint32;
  str: TStream;
  GCF: TGCFFile;
  q: array[0..HL_GCF_CHECKSUM_LENGTH*2] of byte;
  Addr: TSockAddr;

  function RecvPacket(var Size: uint32): pByte;
  var
    Pos, recived: uint32;
  begin
    result:=nil;
    if not Sock.Recv(CacheID, 4) then
      Exit;
    if not Sock.Recv(MsgID, 4) then
      Exit;
    if not Sock.Recv(Accepted, 1) then
      Exit;
    if Accepted then
      Exit;
    if not Sock.Recv(Size, 4) then
      Exit;

    if not Sock.Recv(CacheID, 4) then
      Exit;
    if not Sock.Recv( MsgID, 4) then
      Exit;
    if not Sock.Recv(BlockSize, 4) then
      Exit;
    Pos:=0;
    Size:=htonl(Size);
    BlockSize:=htonl(BlockSize);
    GetMem(result, Size);
    repeat
      recived:=Sock.Recvi(pByte(result+Pos)^, BlockSize);
      inc(Pos, recived);
    until (Pos>=Size) or (recived=0);
  end;

  function GetBannerURL(): boolean;
  var
    URL: pAnsiChar;
    Len: uint16;
  begin
    result:=false;
    FillChar(Q[0], 9, 0);
    Q[0]:=CS_STORAGE_BANNER_URL;
    Sock.SendFromLen(5, @Q[0]);
    if not Sock.Recv(Accepted, 1) then
      Exit;
    URL:=pAnsiChar(Sock.RecvFromLenShort(Len));
    //URL:=pAnsiChar(URL+#0);
    Writeln('Banner URL: "'+URL+'"');
    FreeMem(URL, Len);
    result:=true;
  end;

  function Open(): boolean;
  begin
    result:=false;
    AppID:=htonl(AppID);
    Version:=htonl(Version);

    FillChar(Q[0], 17, 0);
    Q[0]:=CS_STORAGE_OPEN;
    Move(ConnID, Q[1], 4);
    Move(MessageID, Q[5], 4);
    Move(AppID, Q[9], 4);
    Move(Version, Q[13], 4);
    if not Sock.SendFromLen(17, @Q[0]) then
      Exit;
    if not Sock.Recv(ConnID, 4) then
      Exit;
    if not Sock.Recv(MsgID, 4) then
      Exit;
    if not Sock.Recv(Accepted, 1) then
      Exit;
    if Accepted then
      Exit;
    if not Sock.Recv(CacheID, 4) then
      Exit;
    if not Sock.Recv(ManifestCheck, 4) then
      Exit;

    AppID:=htonl(AppID);
    Version:=htonl(Version);
    result:=true;
  end;

  function OpenEx(): boolean;
  begin
    //result:=false;
    result:=true;
  end;

  function GetManifest(): boolean;
  begin
    result:=false;
    FillChar(Q[0], 9, 0);
    Q[0]:=CS_STORAGE_GET_MANIFEST;
    Move(CacheID, Q[1], 4);
    Move(MessageID, Q[5], 4);
    if not Sock.SendFromLen(9, @Q[0]) then
      Exit;

    Manifest:=RecvPacket(ManifestSize);
    result:=(Manifest<>nil);
    inc(MessageID);
  end;

  function GetChecksum(): boolean;
  begin
    result:=false;
    FillChar(Q[0], 9, 0);
    Q[0]:=CS_STORAGE_GET_CHECKSUM;
    Move(CacheID, Q[1], 4);
    Move(MessageID, Q[5], 4);
    if not Sock.SendFromLen(9, @Q[0]) then
      Exit;

    Checksum:=RecvPacket(ChecksumSize);
    result:=(Checksum<>nil);
    inc(MessageID);
  end;

  function GetListUpdateFiles(): boolean;
  var
    r: byte;
    Count: uint32;
  begin
    result:=false;
    FillChar(Q[0], 13, 0);
    Q[0]:=CS_STORAGE_GET_LIST_UPDATE_FILES;
    Move(CacheID, Q[1], 4);
    Move(MessageID, Q[5], 4);
    Move(#0#0#0#0, Q[9], 4);
    Sock.SendFromLen(13, @Q[0]);

    if not Sock.Recv(CacheID, 4) then
      Exit;
    if not Sock.Recv(MsgID, 4) then
      Exit;
    if not Sock.Recv(r, 1) then
      Exit;
    if not Sock.Recv(Count, 4) then
      Exit;
    if Count=0 then
      Exit;

    if not Sock.Recv(CacheID, 4) then
      Exit;
    if not Sock.Recv(MsgID, 4) then
      Exit;
    UpdateList:=puint32(Sock.RecvFromLen(PS));

    str:=TStream.CreateWriteFileStream('.\package\7.diff');
    str.Write(UpdateList^, PS);
    str.Free;
    result:=true;
    inc(MessageID);
  end;

  function RecvChunk(var Size: uint32): pByte; //inline;
  var
    len, recvd: uint32;
  begin
    result:=nil;
    Size:=0;
    if not Sock.Recv(CacheID, 4) then
      Exit;
    if not Sock.Recv(MsgID, 4) then
      Exit;
    if not Sock.Recv(Size, 4) then
       Exit;
    Size:=htonl(Size);
    len:=0;
    GetMem(result, Size);
    repeat
      if not Sock.Recv( CacheID, 4) then
        Exit;
      if not Sock.Recv(MsgID, 4) then
        Exit;
      if not Sock.Recv(BlockSize, 4) then
        Exit;
      BlockSize:=htonl(BlockSize);
      write(BlockSize);
      recvd:=0;
      repeat
        inc(recvd, Sock.Recvi(pByte(result+len)^, BlockSize));
      until recvd=BlockSize;
      if recvd=uint32(SOCKET_ERROR) then
        break;
      inc(len, recvd);
    until len>=Size;
    inc(MessageID);
  end;

  function GetFile(Idx: uint32): ENetWorkResult;
  var
    Start, Count, i: integer;
    FileIdx, IsCompressed, ChunkSize, UncSize: uint32;
    Chunk: pByte;
  begin
    result:=eConnectionError;
    str:=GCF.OpenFile(Idx, ACCES_WRITE);
    Start:=0;
    Count:=GCF.ItemSize[Idx].Size div HL_GCF_CHECKSUM_LENGTH;  // размер в блоках = HL_GCF_CHECKSUM_LENGTH
    if GCF.ItemSize[Idx].Size mod HL_GCF_CHECKSUM_LENGTH>0 then
      inc(Count);

    FileIdx:=htonl(GCF.CheckIdx(Idx));
    Start:=htonl(Start);
    Count:=htonl(Count);

    FillChar(Q[0], 22, 0);
    Q[0]:=CS_STORAGE_GET_FILE;
    Move(CacheID, Q[1], 4);
    Move(MessageID, Q[5], 4);
    Move(FileIdx, Q[9], 4);
    Move(Start, Q[13], 4);
    Move(Count, Q[17], 4);
    Q[21]:=$00;
    if not Sock.SendFromLen(22, @Q[0]) then
      Exit;

    if not Sock.Recv(CacheID, 4) then
      Exit;
    if not Sock.Recv(MsgID, 4) then
      Exit;
    if not Sock.Recv(Accepted, 1) then
      Exit;
    if Accepted then
      Exit;
    if not Sock.Recv(Count, 4) then
      Exit;
    if not Sock.Recv(IsCompressed, 4) then
      Exit;

    Count:=htonl(Count);
    IsCompressed:=htonl(IsCompressed);

    result:=eOK;
    for i:=0 to Count-1 do
    begin
      Chunk:=RecvChunk(ChunkSize);

      UncSize:=HL_GCF_CHECKSUM_LENGTH;
      if (IsCompressed=1) then
      begin
        // zipped
        if uncompress(@q[0], UncSize, Chunk, ChunkSize)<>0 then
        begin
          result:=eZLibError;
          break;
        end;
        str.Write(q[0], UncSize);
      end else if (IsCompressed=2) then
      begin
        writeln(HL_GCF_CHECKSUM_LENGTH-ChunkSize);
        str.Write(Chunk^, ChunkSize);
        FillChar(q[0], HL_GCF_CHECKSUM_LENGTH, 0);
        str.Write(q[0], HL_GCF_CHECKSUM_LENGTH-ChunkSize);
      end
        else str.Write(Chunk^, ChunkSize);
      FreeMem(Chunk, ChunkSize);
    {$IFDEF DEBUG_CS_SLEEP}
        sleep(300);
    {$ENDIF}
    end;

    if (IsCompressed=2) and (CDR<>nil) then
      begin
        // encrypted (and zipped?)
        //GCF.DecryptItem(Idx, CDR.AppRecord[AppID].DecryptKey(Version));
      end;

    str.Free;
  end;

  function Close(): boolean;
  begin
    result:=false;
    FillChar(Q[0], 9, 0);
    Q[0]:=CS_STORAGE_CLOSE;
    Move(CacheID, Q[1], 4);
    Move(MessageID, Q[5], 4);
    Sock.SendFromLen(9, @Q[0]);

    if not Sock.Recv(CacheID, 4) then
      Exit;
    if not Sock.Recv(MsgID, 4) then
      Exit;
    if not Sock.Recv(Accepted, 1) then
      Exit;
    result:=true;
  end;
begin
  result:=eConnectionError;

  Addr:=ContentList_GetContentServer(AppID, Version, REGION_Rest_World);
  if Addr.sin_addr.S_addr=0 then
    Exit;

  Sock:=CSocket.Create(SOCKET_IP);
  Sock.SetTimeOut(3000);
  if (Sock=nil) or (not Sock.Connect(Addr)) then
    Exit;

  if not Sock.Send(CS_STORAGE_QUERY, 4) then
    Exit;
  if not Sock.Recv(Accepted, 1) then
    Exit;
  if not Accepted then
  begin
    result:=eServerReset;
    Exit;
  end;

  ConnID:=0;
  MessageID:=0;

  writeln('Get banner URL');
  if not GetBannerURL() then
  begin
    Sock.Free;
    Exit;
  end;
  writeln('Open');
  if not Open() then
  begin
    Sock.Free;
    Exit;
  end;
  writeln('Get manifest');
  if not GetManifest() then
  begin
    Sock.Free;
    Exit;
  end;
  writeln('Get checksums');
  if not GetChecksum() then
  begin
    Sock.Free;
    Exit;
  end;
  //RSASignMessage(NetWorkKeySign, Checksum, ChecksumSize-128);
  {if not GetListUpdateFiles() then
  begin
    closesocket(Sock);
    Exit;
  end;}

  GCF:=TGCFFile.Create('.\storage\common\'+Int2Str(AppID));
  GCF.LoadFromMem(Manifest, Checksum, ManifestSize, ChecksumSize, false);
  GCF.SaveToFile('.\storage\'+Int2Str(AppID)+'.ncf');

  for i:=0 to GCF.ItemsCount-1 do
    if (GCF.IsFile(i)) and (GCF.GetCompletion(i)<1) then
    begin
      Writeln(GCF.ItemPath[i]);
      {$IFDEF DEBUG_CS_SLEEP}
      sleep(100);
      {$ENDIF}
      if GetFile(i)<>eOK then
        break;
    end;

  GCF.Free;

  Close();
  Sock.Free;

  str:=TStream.CreateWriteFileStream('.\storage\'+Int2Str(AppID)+'.manifest');
  str.Write(Manifest^, ManifestSize);
  str.Free;
  FreeMem(Manifest, ManifestSize);
  str:=TStream.CreateWriteFileStream('.\storage\'+Int2Str(AppID)+'.checksum');
  str.Write(Checksum^, ChecksumSize);
  str.Free;
  FreeMem(Checksum, ChecksumSize);

  result:=eOK;
end;


{$ENDREGION}

initialization
  GetTimeZoneInformation(TimeZoneInformation);
  TimeZoneBias:=(TimeZoneInformation.Bias+TimeZoneInformation.DaylightBias)/(24*60);


end.
