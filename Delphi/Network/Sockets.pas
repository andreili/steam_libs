unit Sockets;

interface

{$I defines.inc}

uses
  Windows, USE_Types, USE_Utils, WinSock;

const
  RECV_BUFFER_SIZE = $8000;
  MAXCONN = 128;

type
  ESocketType =
    (SOCKET_IP,
     SOCKET_TCP,
     SOCKET_UDP);

  CSocket = class
    public
      OnClientConnected: procedure(Socket: CSocket) of object;
    private
      fUseTimeOut,
      fIsTCP,
      fRunned: boolean;
      fSock: TSocket;
      fAddr: TSockAddr;
      fType: ESocketType;

      fTimeOut: TTimeVal;
      fRead,
      fWrite,
      fError: TFDSet;
    public
      OnLoadingProc: procedure(CaptionMain, CaptionProgress: string; CurrentProg, TotalProg: integer) of object;

      constructor Create(SockType: ESocketType);
      destructor Destroy(); override;

      function Connect(Adr: string; Port: uint16): boolean; overload; inline;
      function Connect(Adr: uint32; Port: uint16): boolean; overload; inline;
      function Connect(Adr: TSockAddr): boolean; overload;

      function Bind(Adr: string; Port: uint16): boolean; overload;
      function Bind(Adr: uint32; Port: uint16): boolean; overload;
      function Bind(Adr: TSockAddr): boolean; overload;
      function Listen(): boolean;
      procedure Accept();

      function Sendi(const Data; Size: int32): int32;
      function Recvi(var Data; Size: int32): int32;
      function Send(const Data; Size: int32): boolean; //inline;
      function Recv(var Data; Size: int32): boolean; //inline;

      function SendFromLenShort(Len: uint16; Data: pByte): boolean;
      function SendFromLen(Len: uint32; Data: pByte): boolean;
      function RecvFromLen(var Len: uint32): pByte;
      function RecvFromLenShort(var Len: uint16): pByte;

      class function GetIP(Adr: string): uint32;
      class function htons(val: uint16): uint16;
      class function htonl(val: uint32): uint32;
      procedure SetTimeOut(MSec: uint32);
      function GetRemoteIP(): uint32;
      function GetRemoteAddr(): string;
    public
      // only Delphi
      property UseTimeOut: boolean read fUseTimeOut;
      property Sock: TSocket read fSock;
      property Addr: TSockAddr read fAddr;
  end;

implementation

constructor CSocket.Create(SockType: ESocketType);
begin
  inherited Create();
  case SockType of
    SOCKET_IP: fSock:=socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    SOCKET_TCP: fSock:=socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    SOCKET_UDP: fSock:=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  end;
  if (fSock=SOCKET_ERROR) then
  begin
    Destroy();
    self:=nil;
    Exit;
  end;
  FD_ZERO(fRead);
  FD_SET(fSock, fRead);
  FD_ZERO(fWrite);
  FD_SET(fSock, fWrite);
  FD_ZERO(fError);
  FD_SET(fSock, fError);
  fUseTimeOut:=false;
  fIsTCP:=(SockType<>SOCKET_UDP);
  fRunned:=true;
  fType:=SockType;
  {$IFDEF LOG}
  Log('Socket #'+Int2Str(fSock)+' created');
  {$ENDIF}
end;

destructor CSocket.Destroy();
begin
  fRunned:=false;
  WinSock.shutdown(fSock, SD_BOTH);
  closesocket(fSock);
  {$IFDEF LOG}
    Log('Socket #'+Int2Str(fSock)+' closed');
  {$ENDIF}
  inherited Destroy();
end;

function CSocket.Connect(Adr: string; Port: uint16): boolean;
begin
  fAddr.sin_family:=AF_INET;
  fAddr.sin_addr.S_addr:=GetIP(Adr);
  fAddr.sin_port:=htons(Port);
  result:=Connect(fAddr);
end;

function CSocket.Connect(Adr: uint32; Port: uint16): boolean;
begin
  fAddr.sin_family:=AF_INET;
  fAddr.sin_addr.S_addr:=Adr;
  fAddr.sin_port:=htons(Port);
  result:=Connect(fAddr);
end;

function CSocket.Connect(Adr: TSockAddr): boolean;
begin
  fAddr:=Adr;
  fAddr.sin_family:=AF_INET;
  if (fType<>SOCKET_UDP) then result:=(WinSock.connect(fSock, fAddr, sizeof(TSockAddr))<>SOCKET_ERROR)
    else result:=true;
  {$IFDEF LOG}
  if result then
    Log('Socket #'+Int2Str(fSock)+' connected to '+
     {$IFDEF UNICODE}Ansi2Wide(inet_ntoa(Adr.sin_addr)){$ELSE}inet_ntoa(Adr.sin_addr){$ENDIF}+':'+Int2Str(htons(Adr.sin_port)));
  {$ENDIF}
end;

function CSocket.Bind(Adr: string; Port: uint16): boolean;
begin
  fAddr.sin_family:=AF_INET;
  fAddr.sin_addr.S_addr:=GetIP(Adr);
  fAddr.sin_port:=htons(Port);
  result:=Bind(fAddr);
end;

function CSocket.Bind(Adr: uint32; Port: uint16): boolean;
begin
  fAddr.sin_family:=AF_INET;
  fAddr.sin_addr.S_addr:=Adr;
  fAddr.sin_port:=htons(Port);
  result:=Bind(fAddr);
end;

function CSocket.Bind(Adr: TSockAddr): boolean;
begin
  fAddr:=Adr;
  fAddr.sin_family:=AF_INET;
  result:=(WinSock.bind(fSock, fAddr, sizeof(TSockAddr))<>SOCKET_ERROR);
  {$IFDEF LOG}
  if result then
    Log('Socket #'+Int2Str(fSock)+' binded to '+
     {$IFDEF UNICODE}Ansi2Wide(inet_ntoa(Adr.sin_addr)){$ELSE}inet_ntoa(Adr.sin_addr){$ENDIF}+':'+Int2Str(htons(Adr.sin_port)));
  {$ENDIF}
end;

function CSocket.Listen(): boolean;
begin
  result:=(WinSock.listen(fSock, MAXCONN)<>SOCKET_ERROR);
end;

procedure CSocket.Accept();
var
  Client: CSocket;
  ClientSock: TSocket;
  AddrLen: integer;
  ClientAddr: TSockAddr;
begin
  while fRunned do
  begin
    if select(0, @fRead, @fWrite, @fError, nil)<1 then
      continue;
    AddrLen:=sizeof(TSockAddr);
    FillChar(ClientAddr, AddrLen, 0);
    ClientSock:=WinSock.accept(fSock, @ClientAddr, @AddrLen);
    if ClientSock<>SOCKET_ERROR then
    begin
      writeln('Accepted: ', ClientSock);
      Client:=CSocket.Create(fType);
      Client.fSock:=ClientSock;
      Move(ClientAddr, Client.fAddr, sizeof(TSockAddr));
      if fUseTimeOut then
        Move(self.fTimeOut, Client.fTimeOut, sizeof(timeval));
      if Assigned(OnClientConnected) then
        OnClientConnected(Client);
    end;
  end;
  fRunned:=true;
end;

function CSocket.Sendi(const Data; Size: int32): int32;
var
  d: pByte;
begin
  d:=@Data;
  if fIsTCP then result:=WinSock.send(fSock, d^, Size, 0)
    else result:=WinSock.sendto(fSock, d^, Size, 0, fAddr, sizeof(TSockAddr));
  {$IFDEF LOG}
    Log('Socket #'+Int2Str(fSock)+' send '+Int2Str(result)+' byte');
  {$ENDIF}
end;

function CSocket.Recvi(var Data; Size: int32): int32;
var
  len: int32;
begin
  result:=0;
  if fUseTimeOut then
  begin
    if select(0, @fRead, nil, nil, @fTimeOut)<1 then
      Exit;
  end;

  len:=sizeof(TSockAddr);
  if fIsTCP then result:=WinSock.recv(fSock, Data, Size, 0)
    else result:=WinSock.recvfrom(fSock, Data, Size, 0, fAddr, len);
  {$IFDEF LOG}
    Log('Socket #'+Int2Str(fSock)+' recived '+Int2Str(result)+' byte');
  {$ENDIF}
end;

function CSocket.Send(const Data; Size: int32): boolean;
begin
  result:=(Sendi(Data, Size)=Size);
end;

function CSocket.Recv(var Data; Size: int32): boolean;
begin
  result:=(Recvi(Data, Size)=Size);
end;

function CSocket.RecvFromLen(var Len: uint32): pByte;
var
  i, size: uint32;
begin
  result:=nil;
  Len:=0;
  if WinSock.recv(fSock, Len, 4, 0)<>4 then
    Exit;
  Len:=htonl(Len);
  GetMem(result, Len);
  i:=0;
  while i<Len do
  begin
    size:=WinSock.recv(fSock, (Pointer(result+i))^, min(Abs(Len-i), RECV_BUFFER_SIZE), 0);
    if (size=uint32(SOCKET_ERROR))  then
      break;
    if (size=0) then
    begin
      Len:=i;
      break;
    end;
    inc(i, size);
    if Assigned(OnLoadingProc) then
      OnLoadingProc('', '', i, Len);
    //writeln(i, ' / ', Len);
  end;
  {$IFDEF LOG}
    Log('Socket #'+Int2Str(fSock)+' recived '+Int2Str(i)+' byte');
  {$ENDIF}
end;

function CSocket.RecvFromLenShort(var Len: uint16): pByte;
var
  i, size: integer;
begin
  result:=nil;
  Len:=0;
  if WinSock.recv(fSock, Len, 2, 0)=SOCKET_ERROR then
    Exit;
  Len:=htons(Len);
  GetMem(result, Len);
  i:=0;
  while i<Len do
  begin
    size:=WinSock.recv(fSock, (Pointer(result+i))^, min(Len-i, RECV_BUFFER_SIZE), 0);
    if size=SOCKET_ERROR then
      break;
    if (size=0) then
    begin
      Len:=i;
      break;
    end;
    inc(i, size);
    if Assigned(OnLoadingProc) then
      OnLoadingProc('', '', i, Len);
  end;
  {$IFDEF LOG}
    Log('Socket #'+Int2Str(fSock)+' recived '+Int2Str(i)+' byte');
  {$ENDIF}
end;

function CSocket.SendFromLen(Len: uint32; Data: pByte): boolean;
var
  i, size, l: uint32;
begin
  result:=false;
  Len:=htonl(Len);
  if WinSock.send(fSock, Len, 4, 0)=SOCKET_ERROR then
    Exit;
  Len:=htonl(Len);
  i:=0;
  l:=Len;
  while i<Len do
  begin
    size:=WinSock.send(fSock, (Pointer(Data+i))^, min(RECV_BUFFER_SIZE, l), 0);
    if size=uint32(SOCKET_ERROR) then
      break;
    inc(i, size);
    dec(l, size);
    if Assigned(OnLoadingProc) then
      OnLoadingProc('', '', i, Len);
  end;
  result:=true;
  {$IFDEF LOG}
    Log('Socket #'+Int2Str(fSock)+' sended '+Int2Str(i)+' byte');
  {$ENDIF}
end;

function CSocket.SendFromLenShort(Len: uint16; Data: pByte): boolean;
var
  i, size, l: uint32;
begin
  result:=false;
  Len:=htons(Len);
  if WinSock.send(fSock, Len, 2, 0)=SOCKET_ERROR then
    Exit;
  Len:=htons(Len);
  i:=0;
  l:=Len;
  while i<Len do
  begin
    size:=WinSock.send(fSock, (Pointer(Data+i))^, min(RECV_BUFFER_SIZE, l), 0);
    if size=uint32(SOCKET_ERROR) then
      break;
    inc(i, size);
    dec(l, size);
    if Assigned(OnLoadingProc) then
      OnLoadingProc('', '', i, Len);
  end;
  result:=true;
  {$IFDEF LOG}
    Log('Socket #'+Int2Str(fSock)+' sended '+Int2Str(i)+' byte');
  {$ENDIF}
end;


class function CSocket.GetIP(Adr: string): uint32;
var
  Host: PHostEnt;
begin
  result:=0;
  {$IFDEF UNICODE}
  Host:=gethostbyname(pAnsiChar(Wide2Ansi(Adr)));
  {$ELSE}
  Host:=gethostbyname(pAnsiChar(Adr));
  {$ENDIF}
  if Host<>nil then
    Move(Host^.h_addr_list^[0], result, 4);
  {$IFDEF LOG}
    Log('Get host by name: "'+Adr+'"  - '+inet_ntoa(in_addr(result)));
  {$ENDIF}
end;

class function CSocket.htons(val: uint16): uint16;
begin
  result:=WinSock.htons(val);
end;

class function CSocket.htonl(val: uint32): uint32;
begin
  result:=WinSock.htonl(val);
end;

procedure CSocket.SetTimeOut(MSec: uint32);
begin
  //MSec:=MAXDWORD;
  fTimeOut.tv_usec:= (MSec mod 1000) * 1000;;
  fTimeOut.tv_sec:=MSec div 100;
  fUseTimeOut:=true;
  {$IFDEF LOG}
    Log('Socket #'+Int2Str(fSock)+' set timeout '+Int2Str(MSec)+' msec');
  {$ENDIF}
end;

function CSocket.GetRemoteIP(): uint32;
var
  destAddr: TSockAddr;
  len: integer;
begin
  len:=sizeof(TSockAddr);
  getsockname(fSock, destAddr, len);
  result:=destAddr.sin_addr.S_addr;
end;

function CSocket.GetRemoteAddr(): string;
begin
  result:=inet_ntoa(in_addr(GetRemoteIP()));
end;

var
  WSA: TWSAData;

initialization
  if WSAStartup(MakeWord(2,2), WSA)=SOCKET_ERROR then
    RaiseException(5, 0, 0, nil);
  {$IFDEF LOG}
    Log('WSA start Up');
  {$ENDIF}

finalization
  WSACleanup();
  {$IFDEF LOG}
    Log('WSA shutdown');
  {$ENDIF}

end.