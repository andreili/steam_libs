unit Steam_FriendProtocol;

interface

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils, Sockets, err, RSA;

const
  UDP_BUFFER_SIZE = $1000;

  FRIENDS_HEADER_CHECK: uint32 = $31305356;
  FRIENDS_MSG_HANDSNAKE_OK: uint32 = $00000517;
  FRIENDS_MSG_HANDSNAKE_KEY: uint32 = $00000518;
  FRIENDS_MSG_HANDSNAKE_KEY_OK: uint32 = $00000519;

type
  EUDPPktType =
    (k_EUDPPktTypeNone = 0,
     k_EUDPPktTypeChallengeReq = 1,
     k_EUDPPktTypeChallenge = 2,
     k_EUDPPktTypeConnect = 3,
     k_EUDPPktTypeAccept = 4,
     k_EUDPPktTypeDisconnect = 5,
     k_EUDPPktTypeData = 6,
     k_EUDPPktTypeDatagram = 7,
     k_EUDPPktTypeMax = 8);

  pPacketHeader = ^TPacketHeader;
  TPacketHeader = packed record
    check: uint32;                      // the 4 characters 'VS01' (0x56, 0x53, 0x30, 0x31) or 'VT01' (0x56, 0x54, 0x30, 0x31)
    PacketLen: uint16;                  // the length of the packet after this header
    PacketType: EUDPPktType;
    Flags: uint8;
    SrcID: uint32;                      // the source ID of the packet
    DstID: uint32;                      // the destination ID of the packet
    Sequence: uint32;                   // the packet's sequence number. server and client keep track of own numbers
    SequenceAcked: uint32;              // the sequence number of the last packet received
    PacketsInMessage: uint32;           // the number of packets the current message was split in to
    SequenceOfFirstPacket: uint32;      // the sequence number of the first packet for current message
    AllDataSize: uint32;                // the length of the data in this message (which will be greater than packet length if the message is split)
  end;

  THandsnakeMsg = packed record
    Header: TPacketHeader;
    Data: uint32;
    Distance: uint32;
  end;

  THandsnakeReplyHeader = packed record
    MsgID: uint32;
    FF: array[0..15] of byte;
    DataSize: uint32;
    Data: uint32;
  end;

const
  SIZE_PACKET_HEADER = sizeof(TPacketHeader);
  SIZE_HANDSNAKE_HEADER = sizeof(THandsnakeReplyHeader);

type
  CSteamFriendsProto = class (TObject)
    private
      fSocks: array of CSocket;
      fSockIdx: integer;
      fDistance: uint32;
      fFignerPrint: uint32;
      fServerID: uint32;
      fSequence: uint32;
      fLastRecived: uint32;
      fHandsnakeHeader: THandsnakeMsg;
      fHeader: TPacketHeader;
      fBuffer: array[0..UDP_BUFFER_SIZE-1] of byte;
      fKey: array[0..15] of byte;

      function Challenge(): boolean;
      function Connect(): boolean;
      function SendAESKey(): boolean;

      function RecvHandSnake(size: uint32): boolean;
      function SendHandSnake(data: pByte; dataSize: uint32): boolean;
      procedure PrepareHeader(header: pPacketHeader; msgType: EUDPPktType; flags: byte; dataSize: uint16);
    public
      constructor Create(ServersList: string);
      destructor Destroy(); override;

      function HandSnake(): boolean;
      function SendData(data: pByte; dataSize: uint32; msgType: EUDPPktType; flags: byte): boolean;
      function RecvData(data: pByte; dataSize: uint32; IsContinuationOfPacket: boolean = false): boolean;
  end;

implementation

constructor CSteamFriendsProto.Create(ServersList: string);
var
  i, l, count: integer;
  addr: string;
begin
  inherited Create();
  l:=Length(ServersList);
  count:=0;
  for i:=1 to l do
    if ServersList[i]=' ' then
      inc(count);
  inc(count);
  SetLength(fSocks, count);
  fSockIdx:=-1;
  fServerID:=0;
  fSequence:=0;
  fLastRecived:=0;
  fDistance:=$ffffff;
  fFignerPrint:=0;
  for i:=0 to count-1 do
  begin
    fSocks[i]:=CSocket.Create(SOCKET_UDP);
    //fSocks[i].SetTimeOut(1000);
    addr:=Parse(ServersList, ' ');
    if not fSocks[i].Connect(Addr, 27017) then
      raise Exception.Create(e_Custom, 'Unable connect to server!');
  end;
end;

destructor CSteamFriendsProto.Destroy();
var
  i, l: integer;
begin
  l:=Length(fSocks);
  if l>0 then
    for i:=0 to l-1 do
      if (fSocks[i]<>nil) then
        fSocks[i].Free;
  SetLength(fSocks, 0);
  inherited Destroy();
end;

function CSteamFriendsProto.HandSnake(): boolean;
var
  i, l, idx: integer;
  fignerPrints: array[0..1] of uint32;
  fignerPrint, distance: uint32;
  key: array[0..127] of byte;
  KeyEncr: pByte;
begin
  result:=false;
  l:=length(fSocks);
  if l=0 then
    Exit;
  for i:=0 to l-1 do
  begin
    Writeln(i);
    fSockIdx:=i;
    if i=2 then
      break;
    if not Challenge() then
      Exit;
  end;
  while true do
    case fHeader.PacketType of
      k_EUDPPktTypeChallenge: if not Connect() then Exit;
      k_EUDPPktTypeDisconnect: Exit;
      k_EUDPPktTypeAccept: if not SendAESKey() then Exit;
    end;
  result:=true;
end;

function CSteamFriendsProto.SendData(data: pByte; dataSize: uint32; msgType: EUDPPktType; flags: byte): boolean;
begin
  result:=false;
  if fSockIdx=-1 then
    Exit;
  PrepareHeader(@fHeader, msgType, flags, dataSize);
  Move(fHeader, fBuffer[0], SIZE_PACKET_HEADER);
  if dataSize>0 then
    Move(data^, fBuffer[SIZE_PACKET_HEADER], dataSize);
  inc(dataSize, SIZE_PACKET_HEADER);
  if not fSocks[fSockIdx].Send(fBuffer[0], dataSize) then
    Exit;
  inc(fSequence);
  result:=true;
end;

function CSteamFriendsProto.RecvData(data: pByte; dataSize: uint32; IsContinuationOfPacket: boolean = false): boolean;
var
  recvSize, recivedData, i: integer;
begin
  result:=false;
  if fSockIdx=-1 then
    Exit;
  FillChar(fBuffer[0], UDP_BUFFER_SIZE, 0);
  recvSize:=fSocks[fSockIdx].Recvi(fBuffer[0], SIZE_PACKET_HEADER+dataSize);
  if not IsContinuationOfPacket then
  begin
    Move(fBuffer[0], fHeader, SIZE_PACKET_HEADER);
    fLastRecived:=fHeader.Sequence;
    recivedData:=recvSize-SIZE_PACKET_HEADER;
    if (recivedData<>dataSize) and (fHeader.PacketsInMessage=1) then
      Exit;
    Move(fBuffer[SIZE_PACKET_HEADER], data^, recivedData);
    if fHeader.PacketsInMessage>1 then
    begin
      //!!!!
    end;
  end
    else
  begin
  end;
  result:=true;
end;

function CSteamFriendsProto.Challenge(): boolean;
var
  fignerPrints: array[0..1] of uint32;
begin
  result:=false;
  if not SendData(nil, 0, k_EUDPPktTypeChallengeReq, 0) then
    Exit;
  if not RecvData(@fignerPrints[0], 8) then
    Exit;
  if (fDistance>fignerPrints[1]) then
  begin
    fServerID:=fSockIdx;
    fDistance:=fignerPrints[0];
    fFignerPrint:=fignerPrints[0];
    fFignerPrint:=fFignerPrint xor $A426DF2B;
  end;
  result:=true;
end;

function CSteamFriendsProto.Connect(): boolean;
begin
  Writeln('Connecting');
  result:=false;
  fSockIdx:=fServerID;
  if not SendData(@fFignerPrint, 4, k_EUDPPktTypeConnect, $04) then
    Exit;
  if not RecvData(nil, 0) then
    Exit;
  result:=true;
end;

function CSteamFriendsProto.SendAESKey(): boolean;
var
  i: integer;
  crc: uint32;
  Reply: THandsnakeReplyHeader;
  buf: array[0..SIZE_HANDSNAKE_HEADER+128+8-1] of byte;
  encr: pByte;
begin
  Writeln('Sending AES key');
  result:=false;

  if not RecvData(@Reply.MsgID, SIZE_HANDSNAKE_HEADER) then
    Exit;
  FillChar(buf[0], 16, $ff);
  if (Reply.MsgID<>FRIENDS_MSG_HANDSNAKE_OK) or (memcmp(@Reply.FF[0], @buf[0], 16)<>0) or
   (Reply.DataSize<>1) or (Reply.Data<>1) then
    Exit;

  FillChar(buf[0], Length(buf), 0);
  for i:=0 to 15 do
    fKey[i]:=Random(255);
  Move(fKey[0], buf[SIZE_HANDSNAKE_HEADER], 128);
  encr:=RSAEncrypt(NetWorkKey, @buf[SIZE_HANDSNAKE_HEADER], 128);
  Move(encr^, buf[SIZE_HANDSNAKE_HEADER], 128);
  FreeMem(encr, 128);
  crc:=CRC32(@buf[SIZE_HANDSNAKE_HEADER], 128);

  Reply.MsgID:=FRIENDS_MSG_HANDSNAKE_KEY;
  Reply.DataSize:=$80;
  Move(Reply, buf[0], SIZE_HANDSNAKE_HEADER);
  Move(crc, buf[SIZE_HANDSNAKE_HEADER+128], 4);

  if not SendData(@buf[0], length(buf), k_EUDPPktTypeData, 4) then
    Exit;

  if not RecvData(@Reply.MsgID, SIZE_HANDSNAKE_HEADER-4) then
    Exit;
  if fHeader.PacketType=k_EUDPPktTypeAccept then
  begin
    result:=true;
    Exit;
  end;
  FillChar(buf[0], 16, $ff);
  if (Reply.MsgID<>FRIENDS_MSG_HANDSNAKE_KEY_OK) or (memcmp(@Reply.FF[0], @buf[0], 16)<>0) or
   (Reply.DataSize<>1) then
    Exit;

  result:=true;
end;

function CSteamFriendsProto.RecvHandSnake(size: uint32): boolean;
var
  recivedData, recvSize: integer;
begin
  result:=false;
  //PrepareHeader(@fHeader, msgType, $04, size);
  recvSize:=fSocks[fSockIdx].Recvi(fBuffer[0], SIZE_PACKET_HEADER+size);
  Move(fBuffer[0], fHeader, SIZE_PACKET_HEADER);
  recivedData:=recvSize-SIZE_PACKET_HEADER;
  if recivedData=0 then
    Exit;
  case fHeader.Sequence of
    3: if (puint32(@fBuffer[SIZE_PACKET_HEADER])^<>FRIENDS_MSG_HANDSNAKE_OK) then
         Exit;
    4: if (puint32(@fBuffer[SIZE_PACKET_HEADER])^<>FRIENDS_MSG_HANDSNAKE_KEY_OK) then
         Exit;
  end;
  if fHeader.PacketType=k_EUDPPktTypeDisconnect then
    Exit;
  fServerID:=fHeader.SrcID;
  result:=true;
end;

function CSteamFriendsProto.SendHandSnake(data: pByte; dataSize: uint32): boolean;
begin
  result:=false;
  PrepareHeader(@fHeader, k_EUDPPktTypeData, $04, dataSize);
  Move(fHeader, fBuffer[0], SIZE_PACKET_HEADER);
  Move(FRIENDS_MSG_HANDSNAKE_KEY, fBuffer[SIZE_PACKET_HEADER], 4);
  FillChar(fBuffer[SIZE_PACKET_HEADER+4], 16, $ff);
  puint32(@fBuffer[SIZE_PACKET_HEADER+24])^:=$00000001;
  puint32(@fBuffer[SIZE_PACKET_HEADER+28])^:=dataSize;
  Move(data^, fBuffer[SIZE_PACKET_HEADER+32], dataSize);
  puint32(@fBuffer[SIZE_PACKET_HEADER+32+dataSize])^:=CSocket.htonl(CRC32(data, dataSize));

  inc(dataSize, SIZE_PACKET_HEADER+36);
  if not fSocks[fSockIdx].Send(fBuffer[0], dataSize) then
    Exit;
  inc(fSequence);
  result:=true;
end;

procedure CSteamFriendsProto.PrepareHeader(header: pPacketHeader; msgType: EUDPPktType; flags: byte; dataSize: uint16);
begin
  header^.check:=FRIENDS_HEADER_CHECK;
  header^.PacketLen:=dataSize;
  header^.PacketType:=msgType;
  header^.Flags:=flags;
  header^.SrcID:=$200;
  header^.DstID:=fServerID;
  header^.Sequence:=fSequence;
  header^.SequenceAcked:=fLastRecived;
  header^.PacketsInMessage:=1;
  header^.SequenceOfFirstPacket:=fSequence;
  header^.AllDataSize:=dataSize;
end;

end.