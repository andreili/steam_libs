{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{                                                       }
{           Copyright (c) 1995-2008 CodeGear            }
{                                                       }
{*******************************************************}

{*******************************************************}
{       Win32 sockets API Interface Unit                }
{*******************************************************}

unit WinSock;

{$WEAKPACKAGEUNIT}

interface

uses Windows;

{ HPPEMIT '#include <windows.h>'}

type
  {$EXTERNALSYM u_char}
  u_char = AnsiChar;
  {$EXTERNALSYM u_short}
  u_short = Word;
  {$EXTERNALSYM u_int}
  u_int = Integer;
  {$EXTERNALSYM u_long}
  u_long = Longint;

{ The new type to be used in all
  instances which refer to sockets. }
  {$EXTERNALSYM TSocket}
  TSocket = u_int;

const
  {$EXTERNALSYM FD_SETSIZE}
  FD_SETSIZE     =   64;

// WinSock 2 extension -- manifest constants for shutdown()
  {$EXTERNALSYM SD_RECEIVE}
  SD_RECEIVE     = 0;
  {$EXTERNALSYM SD_SEND}
  SD_SEND        = 1;
  {$EXTERNALSYM SD_BOTH}
  SD_BOTH        = 2;

type
// the following emits are a workaround to the name conflict with
// procedure FD_SET and struct fd_set in winsock.h
(*$HPPEMIT '#include <winsock.h>'*)
(*$HPPEMIT 'namespace Winsock'*)
(*$HPPEMIT '{'*)
(*$HPPEMIT 'typedef fd_set *PFDSet;'*) // due to name conflict with procedure FD_SET
(*$HPPEMIT 'typedef fd_set TFDSet;'*)  // due to name conflict with procedure FD_SET
(*$HPPEMIT '}'*)

  {$NODEFINE PFDSet}
  PFDSet = ^TFDSet;
  {$NODEFINE TFDSet}
  TFDSet = record
    fd_count: u_int;
    fd_array: array[0..FD_SETSIZE-1] of TSocket;
  end;

  PTimeVal = ^TTimeVal;
  {$EXTERNALSYM timeval}
  timeval = record
    tv_sec: Longint;
    tv_usec: Longint;
  end;
  TTimeVal = timeval;

const
  {$EXTERNALSYM IOCPARM_MASK}
  IOCPARM_MASK = $7f;
  {$EXTERNALSYM IOC_VOID}
  IOC_VOID     = $20000000;
  {$EXTERNALSYM IOC_OUT}
  IOC_OUT      = $40000000;
  {$EXTERNALSYM IOC_IN}
  IOC_IN       = $80000000;
  {$EXTERNALSYM IOC_INOUT}
  IOC_INOUT    = (IOC_IN or IOC_OUT);

  {$EXTERNALSYM FIONREAD}
  FIONREAD     = IOC_OUT or { get # bytes to read }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 127;
  {$EXTERNALSYM FIONBIO}
  FIONBIO      = IOC_IN or { set/clear non-blocking i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 126;
  {$EXTERNALSYM FIOASYNC}
  FIOASYNC     = IOC_IN or { set/clear async i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 125;

type
  PHostEnt = ^THostEnt;
  {$EXTERNALSYM hostent}
  hostent = record
    h_name: PAnsiChar;
    h_aliases: ^PAnsiChar;
    h_addrtype: Smallint;
    h_length: Smallint;
    case Byte of
      0: (h_addr_list: ^PAnsiChar);
      1: (h_addr: ^PAnsiChar)
  end;
  THostEnt = hostent;

  PNetEnt = ^TNetEnt;
  {$EXTERNALSYM netent}
  netent = record
    n_name: PAnsiChar;
    n_aliases: ^PAnsiChar;
    n_addrtype: Smallint;
    n_net: u_long;
  end;
  TNetEnt = netent;

  PServEnt = ^TServEnt;
  {$EXTERNALSYM servent}
  servent = record
    s_name: PAnsiChar;
    s_aliases: ^PAnsiChar;
    s_port: Word;
    s_proto: PAnsiChar;
  end;
  TServEnt = servent;

  PProtoEnt = ^TProtoEnt;
  {$EXTERNALSYM protoent}
  protoent = record
    p_name: PAnsiChar;
    p_aliases: ^PAnsiChar;
    p_proto: Smallint;
  end;
  TProtoEnt = protoent;

const

{ Protocols }

  {$EXTERNALSYM IPPROTO_IP}
  IPPROTO_IP     =   0;             { dummy for IP }
  {$EXTERNALSYM IPPROTO_ICMP}
  IPPROTO_ICMP   =   1;             { control message protocol }
  {$EXTERNALSYM IPPROTO_IGMP}
  IPPROTO_IGMP   =   2;             { group management protocol }
  {$EXTERNALSYM IPPROTO_GGP}
  IPPROTO_GGP    =   3;             { gateway^2 (deprecated) }
  {$EXTERNALSYM IPPROTO_TCP}
  IPPROTO_TCP    =   6;             { tcp }
  {$EXTERNALSYM IPPROTO_PUP}
  IPPROTO_PUP    =  12;             { pup }
  {$EXTERNALSYM IPPROTO_UDP}
  IPPROTO_UDP    =  17;             { user datagram protocol }
  {$EXTERNALSYM IPPROTO_IDP}
  IPPROTO_IDP    =  22;             { xns idp }
  {$EXTERNALSYM IPPROTO_ND}
  IPPROTO_ND     =  77;             { UNOFFICIAL net disk proto }

  {$EXTERNALSYM IPPROTO_RAW}
  IPPROTO_RAW    =  255;            { raw IP packet }
  {$EXTERNALSYM IPPROTO_MAX}
  IPPROTO_MAX    =  256;

{ Port/socket numbers: network standard functions}

  {$EXTERNALSYM IPPORT_ECHO}
  IPPORT_ECHO    =   7;
  {$EXTERNALSYM IPPORT_DISCARD}
  IPPORT_DISCARD =   9;
  {$EXTERNALSYM IPPORT_SYSTAT}
  IPPORT_SYSTAT  =   11;
  {$EXTERNALSYM IPPORT_DAYTIME}
  IPPORT_DAYTIME =   13;
  {$EXTERNALSYM IPPORT_NETSTAT}
  IPPORT_NETSTAT =   15;
  {$EXTERNALSYM IPPORT_FTP}
  IPPORT_FTP     =   21;
  {$EXTERNALSYM IPPORT_TELNET}
  IPPORT_TELNET  =   23;
  {$EXTERNALSYM IPPORT_SMTP}
  IPPORT_SMTP    =   25;
  {$EXTERNALSYM IPPORT_TIMESERVER}
  IPPORT_TIMESERVER  =  37;
  {$EXTERNALSYM IPPORT_NAMESERVER}
  IPPORT_NAMESERVER  =  42;
  {$EXTERNALSYM IPPORT_WHOIS}
  IPPORT_WHOIS       =  43;
  {$EXTERNALSYM IPPORT_MTP}
  IPPORT_MTP         =  57;

{ Port/socket numbers: host specific functions }

  {$EXTERNALSYM IPPORT_TFTP}
  IPPORT_TFTP        =  69;
  {$EXTERNALSYM IPPORT_RJE}
  IPPORT_RJE         =  77;
  {$EXTERNALSYM IPPORT_FINGER}
  IPPORT_FINGER      =  79;
  {$EXTERNALSYM IPPORT_TTYLINK}
  IPPORT_TTYLINK     =  87;
  {$EXTERNALSYM IPPORT_SUPDUP}
  IPPORT_SUPDUP      =  95;

{ UNIX TCP sockets }

  {$EXTERNALSYM IPPORT_EXECSERVER}
  IPPORT_EXECSERVER  =  512;
  {$EXTERNALSYM IPPORT_LOGINSERVER}
  IPPORT_LOGINSERVER =  513;
  {$EXTERNALSYM IPPORT_CMDSERVER}
  IPPORT_CMDSERVER   =  514;
  {$EXTERNALSYM IPPORT_EFSSERVER}
  IPPORT_EFSSERVER   =  520;

{ UNIX UDP sockets }

  {$EXTERNALSYM IPPORT_BIFFUDP}
  IPPORT_BIFFUDP     =  512;
  {$EXTERNALSYM IPPORT_WHOSERVER}
  IPPORT_WHOSERVER   =  513;
  {$EXTERNALSYM IPPORT_ROUTESERVER}
  IPPORT_ROUTESERVER =  520;

{ Ports < IPPORT_RESERVED are reserved for
  privileged processes (e.g. root). }

  {$EXTERNALSYM IPPORT_RESERVED}
  IPPORT_RESERVED    =  1024;

{ Link numbers }

  {$EXTERNALSYM IMPLINK_IP}
  IMPLINK_IP         =  155;
  {$EXTERNALSYM IMPLINK_LOWEXPER}
  IMPLINK_LOWEXPER   =  156;
  {$EXTERNALSYM IMPLINK_HIGHEXPER}
  IMPLINK_HIGHEXPER  =  158;

type
  {$EXTERNALSYM SunB}
  SunB = packed record
    s_b1, s_b2, s_b3, s_b4: u_char;
  end;

  {$EXTERNALSYM SunW}
  SunW = packed record
    s_w1, s_w2: u_short;
  end;

  PInAddr = ^TInAddr;
  {$EXTERNALSYM in_addr}
  in_addr = record
    case integer of
      0: (S_un_b: SunB);
      1: (S_un_w: SunW);
      2: (S_addr: u_long);
  end;
  TInAddr = in_addr;

  PSockAddrIn = ^TSockAddrIn;
  {$EXTERNALSYM sockaddr_in}
  sockaddr_in = record
    case Integer of
      0: (sin_family: u_short;
          sin_port: u_short;
          sin_addr: TInAddr;
          sin_zero: array[0..7] of AnsiChar);
      1: (sa_family: u_short;
          sa_data: array[0..13] of AnsiChar)
  end;
  TSockAddrIn = sockaddr_in;

const
  {$EXTERNALSYM INADDR_ANY}
  INADDR_ANY       = $00000000;
  {$EXTERNALSYM INADDR_LOOPBACK}
  INADDR_LOOPBACK  = $7F000001;
  {$EXTERNALSYM INADDR_BROADCAST}
  INADDR_BROADCAST = DWORD($FFFFFFFF);
  {$EXTERNALSYM INADDR_NONE}
  INADDR_NONE      = DWORD($FFFFFFFF);

  {$EXTERNALSYM WSADESCRIPTION_LEN}
  WSADESCRIPTION_LEN     =   256;
  {$EXTERNALSYM WSASYS_STATUS_LEN}
  WSASYS_STATUS_LEN      =   128;

type
  PWSAData = ^TWSAData;
  {$EXTERNALSYM WSAData}
  WSAData = record // !!! also WSDATA
    wVersion: Word;
    wHighVersion: Word;
    szDescription: array[0..WSADESCRIPTION_LEN] of AnsiChar;
    szSystemStatus: array[0..WSASYS_STATUS_LEN] of AnsiChar;
    iMaxSockets: Word;
    iMaxUdpDg: Word;
    lpVendorInfo: PAnsiChar;
  end;
  TWSAData = WSAData;

  {$EXTERNALSYM PTransmitFileBuffers}
  PTransmitFileBuffers = ^TTransmitFileBuffers;
  {$EXTERNALSYM _TRANSMIT_FILE_BUFFERS}
  _TRANSMIT_FILE_BUFFERS = record
      Head: Pointer;
      HeadLength: DWORD;
      Tail: Pointer;
      TailLength: DWORD;
  end;
  {$EXTERNALSYM TTransmitFileBuffers}
  TTransmitFileBuffers = _TRANSMIT_FILE_BUFFERS;
  {$EXTERNALSYM TRANSMIT_FILE_BUFFERS}
  TRANSMIT_FILE_BUFFERS = _TRANSMIT_FILE_BUFFERS;


const
  {$EXTERNALSYM TF_DISCONNECT}
  TF_DISCONNECT           = $01;
  {$EXTERNALSYM TF_REUSE_SOCKET}
  TF_REUSE_SOCKET         = $02;
  {$EXTERNALSYM TF_WRITE_BEHIND}
  TF_WRITE_BEHIND         = $04;

{ Options for use with [gs]etsockopt at the IP level. }

  {$EXTERNALSYM IP_OPTIONS}
  IP_OPTIONS          = 1;
  {$EXTERNALSYM IP_MULTICAST_IF}
  IP_MULTICAST_IF     = 2;           { set/get IP multicast interface   }
  {$EXTERNALSYM IP_MULTICAST_TTL}
  IP_MULTICAST_TTL    = 3;           { set/get IP multicast timetolive  }
  {$EXTERNALSYM IP_MULTICAST_LOOP}
  IP_MULTICAST_LOOP   = 4;           { set/get IP multicast loopback    }
  {$EXTERNALSYM IP_ADD_MEMBERSHIP}
  IP_ADD_MEMBERSHIP   = 5;           { add  an IP group membership      }
  {$EXTERNALSYM IP_DROP_MEMBERSHIP}
  IP_DROP_MEMBERSHIP  = 6;           { drop an IP group membership      }
  {$EXTERNALSYM IP_TTL}
  IP_TTL              = 7;           { set/get IP Time To Live          }
  {$EXTERNALSYM IP_TOS}
  IP_TOS              = 8;           { set/get IP Type Of Service       }
  {$EXTERNALSYM IP_DONTFRAGMENT}
  IP_DONTFRAGMENT     = 9;           { set/get IP Don't Fragment flag   }


  {$EXTERNALSYM IP_DEFAULT_MULTICAST_TTL}
  IP_DEFAULT_MULTICAST_TTL   = 1;    { normally limit m'casts to 1 hop  }
  {$EXTERNALSYM IP_DEFAULT_MULTICAST_LOOP}
  IP_DEFAULT_MULTICAST_LOOP  = 1;    { normally hear sends if a member  }
  {$EXTERNALSYM IP_MAX_MEMBERSHIPS}
  IP_MAX_MEMBERSHIPS         = 20;   { per socket; must fit in one mbuf }

{ This is used instead of -1, since the
  TSocket type is unsigned.}

  {$EXTERNALSYM INVALID_SOCKET    =}
  INVALID_SOCKET    = TSocket(NOT(0));
  {$EXTERNALSYM SOCKET_ERROR      =}
  SOCKET_ERROR      = -1;

{ Types }

  {$EXTERNALSYM SOCK_STREAM}
  SOCK_STREAM     = 1;               { stream socket }
  {$EXTERNALSYM SOCK_DGRAM}
  SOCK_DGRAM      = 2;               { datagram socket }
  {$EXTERNALSYM SOCK_RAW}
  SOCK_RAW        = 3;               { raw-protocol interface }
  {$EXTERNALSYM SOCK_RDM}
  SOCK_RDM        = 4;               { reliably-delivered message }
  {$EXTERNALSYM SOCK_SEQPACKET}
  SOCK_SEQPACKET  = 5;               { sequenced packet stream }

{ Option flags per-socket. }

  {$EXTERNALSYM SO_DEBUG}
  SO_DEBUG        = $0001;          { turn on debugging info recording }
  {$EXTERNALSYM SO_ACCEPTCONN}
  SO_ACCEPTCONN   = $0002;          { socket has had listen() }
  {$EXTERNALSYM SO_REUSEADDR}
  SO_REUSEADDR    = $0004;          { allow local address reuse }
  {$EXTERNALSYM SO_KEEPALIVE}
  SO_KEEPALIVE    = $0008;          { keep connections alive }
  {$EXTERNALSYM SO_DONTROUTE}
  SO_DONTROUTE    = $0010;          { just use interface addresses }
  {$EXTERNALSYM SO_BROADCAST}
  SO_BROADCAST    = $0020;          { permit sending of broadcast msgs }
  {$EXTERNALSYM SO_USELOOPBACK}
  SO_USELOOPBACK  = $0040;          { bypass hardware when possible }
  {$EXTERNALSYM SO_LINGER}
  SO_LINGER       = $0080;          { linger on close if data present }
  {$EXTERNALSYM SO_OOBINLINE}
  SO_OOBINLINE    = $0100;          { leave received OOB data in line }

  {$EXTERNALSYM SO_DONTLINGER}
  SO_DONTLINGER  =   $ff7f;

{ Additional options. }

  {$EXTERNALSYM SO_SNDBUF}
  SO_SNDBUF       = $1001;          { send buffer size }
  {$EXTERNALSYM SO_RCVBUF}
  SO_RCVBUF       = $1002;          { receive buffer size }
  {$EXTERNALSYM SO_SNDLOWAT}
  SO_SNDLOWAT     = $1003;          { send low-water mark }
  {$EXTERNALSYM SO_RCVLOWAT}
  SO_RCVLOWAT     = $1004;          { receive low-water mark }
  {$EXTERNALSYM SO_SNDTIMEO}
  SO_SNDTIMEO     = $1005;          { send timeout }
  {$EXTERNALSYM SO_RCVTIMEO}
  SO_RCVTIMEO     = $1006;          { receive timeout }
  {$EXTERNALSYM SO_ERROR}
  SO_ERROR        = $1007;          { get error status and clear }
  {$EXTERNALSYM SO_TYPE}
  SO_TYPE         = $1008;          { get socket type }

{ Options for connect and disconnect data and options.  Used only by
  non-TCP/IP transports such as DECNet, OSI TP4, etc. }

  {$EXTERNALSYM SO_CONNDATA}
  SO_CONNDATA     = $7000;
  {$EXTERNALSYM SO_CONNOPT}
  SO_CONNOPT      = $7001;
  {$EXTERNALSYM SO_DISCDATA}
  SO_DISCDATA     = $7002;
  {$EXTERNALSYM SO_DISCOPT}
  SO_DISCOPT      = $7003;
  {$EXTERNALSYM SO_CONNDATALEN}
  SO_CONNDATALEN  = $7004;
  {$EXTERNALSYM SO_CONNOPTLEN}
  SO_CONNOPTLEN   = $7005;
  {$EXTERNALSYM SO_DISCDATALEN}
  SO_DISCDATALEN  = $7006;
  {$EXTERNALSYM SO_DISCOPTLEN}
  SO_DISCOPTLEN   = $7007;

{ Option for opening sockets for synchronous access. }

  {$EXTERNALSYM SO_OPENTYPE}
  SO_OPENTYPE     = $7008;

  {$EXTERNALSYM SO_SYNCHRONOUS_ALERT}
  SO_SYNCHRONOUS_ALERT    = $10;
  {$EXTERNALSYM SO_SYNCHRONOUS_NONALERT}
  SO_SYNCHRONOUS_NONALERT = $20;

{ Other NT-specific options. }

  {$EXTERNALSYM SO_MAXDG}
  SO_MAXDG        = $7009;
  {$EXTERNALSYM SO_MAXPATHDG}
  SO_MAXPATHDG    = $700A;
  {$EXTERNALSYM SO_UPDATE_ACCEPT_CONTEXT}
  SO_UPDATE_ACCEPT_CONTEXT     = $700B;
  {$EXTERNALSYM SO_CONNECT_TIME}
  SO_CONNECT_TIME = $700C;

{ TCP options. }

  {$EXTERNALSYM TCP_NODELAY}
  TCP_NODELAY     = $0001;
  {$EXTERNALSYM TCP_BSDURGENT}
  TCP_BSDURGENT   = $7000;

{ Address families. }

  {$EXTERNALSYM AF_UNSPEC}
  AF_UNSPEC       = 0;               { unspecified }
  {$EXTERNALSYM AF_UNIX}
  AF_UNIX         = 1;               { local to host (pipes, portals) }
  {$EXTERNALSYM AF_INET}
  AF_INET         = 2;               { internetwork: UDP, TCP, etc. }
  {$EXTERNALSYM AF_IMPLINK}
  AF_IMPLINK      = 3;               { arpanet imp addresses }
  {$EXTERNALSYM AF_PUP}
  AF_PUP          = 4;               { pup protocols: e.g. BSP }
  {$EXTERNALSYM AF_CHAOS}
  AF_CHAOS        = 5;               { mit CHAOS protocols }
  {$EXTERNALSYM AF_IPX}
  AF_IPX          = 6;               { IPX and SPX }
  {$EXTERNALSYM AF_NS}
  AF_NS           = 6;               { XEROX NS protocols }
  {$EXTERNALSYM AF_ISO}
  AF_ISO          = 7;               { ISO protocols }
  {$EXTERNALSYM AF_OSI}
  AF_OSI          = AF_ISO;          { OSI is ISO }
  {$EXTERNALSYM AF_ECMA}
  AF_ECMA         = 8;               { european computer manufacturers }
  {$EXTERNALSYM AF_DATAKIT}
  AF_DATAKIT      = 9;               { datakit protocols }
  {$EXTERNALSYM AF_CCITT}
  AF_CCITT        = 10;              { CCITT protocols, X.25 etc }
  {$EXTERNALSYM AF_SNA}
  AF_SNA          = 11;              { IBM SNA }
  {$EXTERNALSYM AF_DECnet}
  AF_DECnet       = 12;              { DECnet }
  {$EXTERNALSYM AF_DLI}
  AF_DLI          = 13;              { Direct data link interface }
  {$EXTERNALSYM AF_LAT}
  AF_LAT          = 14;              { LAT }
  {$EXTERNALSYM AF_HYLINK}
  AF_HYLINK       = 15;              { NSC Hyperchannel }
  {$EXTERNALSYM AF_APPLETALK}
  AF_APPLETALK    = 16;              { AppleTalk }
  {$EXTERNALSYM AF_NETBIOS}
  AF_NETBIOS      = 17;              { NetBios-style addresses }
  {$EXTERNALSYM AF_VOICEVIEW}
  AF_VOICEVIEW    = 18;              { VoiceView }
  {$EXTERNALSYM AF_FIREFOX}
  AF_FIREFOX      = 19;              { FireFox }
  {$EXTERNALSYM AF_UNKNOWN1}
  AF_UNKNOWN1     = 20;              { Somebody is using this! }
  {$EXTERNALSYM AF_BAN}
  AF_BAN          = 21;              { Banyan }

  {$EXTERNALSYM AF_MAX}
  AF_MAX          = 22;

type
  { Structure used by kernel to store most addresses. }

  {$EXTERNALSYM PSOCKADDR}
  PSOCKADDR = ^TSockAddr;
  {$EXTERNALSYM TSockAddr}
  TSockAddr = sockaddr_in;


  { Structure used by kernel to pass protocol information in raw sockets. }
  PSockProto = ^TSockProto;
  {$EXTERNALSYM sockproto}
  sockproto = record
    sp_family: u_short;
    sp_protocol: u_short;
  end;
  TSockProto = sockproto;

const
{ Protocol families, same as address families for now. }

  {$EXTERNALSYM PF_UNSPEC}
  PF_UNSPEC       = AF_UNSPEC;
  {$EXTERNALSYM PF_UNIX}
  PF_UNIX         = AF_UNIX;
  {$EXTERNALSYM PF_INET}
  PF_INET         = AF_INET;
  {$EXTERNALSYM PF_IMPLINK}
  PF_IMPLINK      = AF_IMPLINK;
  {$EXTERNALSYM PF_PUP}
  PF_PUP          = AF_PUP;
  {$EXTERNALSYM PF_CHAOS}
  PF_CHAOS        = AF_CHAOS;
  {$EXTERNALSYM PF_NS}
  PF_NS           = AF_NS;
  {$EXTERNALSYM PF_IPX}
  PF_IPX          = AF_IPX;
  {$EXTERNALSYM PF_ISO}
  PF_ISO          = AF_ISO;
  {$EXTERNALSYM PF_OSI}
  PF_OSI          = AF_OSI;
  {$EXTERNALSYM PF_ECMA}
  PF_ECMA         = AF_ECMA;
  {$EXTERNALSYM PF_DATAKIT}
  PF_DATAKIT      = AF_DATAKIT;
  {$EXTERNALSYM PF_CCITT}
  PF_CCITT        = AF_CCITT;
  {$EXTERNALSYM PF_SNA}
  PF_SNA          = AF_SNA;
  {$EXTERNALSYM PF_DECnet}
  PF_DECnet       = AF_DECnet;
  {$EXTERNALSYM PF_DLI}
  PF_DLI          = AF_DLI;
  {$EXTERNALSYM PF_LAT}
  PF_LAT          = AF_LAT;
  {$EXTERNALSYM PF_HYLINK}
  PF_HYLINK       = AF_HYLINK;
  {$EXTERNALSYM PF_APPLETALK}
  PF_APPLETALK    = AF_APPLETALK;
  {$EXTERNALSYM PF_VOICEVIEW}
  PF_VOICEVIEW    = AF_VOICEVIEW;
  {$EXTERNALSYM PF_FIREFOX}
  PF_FIREFOX      = AF_FIREFOX;
  {$EXTERNALSYM PF_UNKNOWN1}
  PF_UNKNOWN1     = AF_UNKNOWN1;
  {$EXTERNALSYM PF_BAN}
  PF_BAN          = AF_BAN;

  {$EXTERNALSYM PF_MAX}
  PF_MAX          = AF_MAX;

type
{ Structure used for manipulating linger option. }
  PLinger = ^TLinger;
  {$EXTERNALSYM linger}
  linger = record
    l_onoff: u_short;
    l_linger: u_short;
  end;
  TLinger = linger;

const
{ Level number for (get/set)sockopt() to apply to socket itself. }

  {$EXTERNALSYM SOL_SOCKET}
  SOL_SOCKET      = $ffff;          {options for socket level }

{ Maximum queue length specifiable by listen. }

  {$EXTERNALSYM SOMAXCONN}
  SOMAXCONN       = 5;

  {$EXTERNALSYM MSG_OOB}
  MSG_OOB         = $1;             {process out-of-band data }
  {$EXTERNALSYM MSG_PEEK}
  MSG_PEEK        = $2;             {peek at incoming message }
  {$EXTERNALSYM MSG_DONTROUTE}
  MSG_DONTROUTE   = $4;             {send without using routing tables }

  {$EXTERNALSYM MSG_MAXIOVLEN}
  MSG_MAXIOVLEN   = 16;

  {$EXTERNALSYM MSG_PARTIAL}
  MSG_PARTIAL     = $8000;          {partial send or recv for message xport }

{ Define constant based on rfc883, used by gethostbyxxxx() calls. }

  {$EXTERNALSYM MAXGETHOSTSTRUCT}
  MAXGETHOSTSTRUCT        = 1024;

{ Define flags to be used with the WSAAsyncSelect() call. }

  {$EXTERNALSYM FD_READ}
  FD_READ         = $01;
  {$EXTERNALSYM FD_WRITE}
  FD_WRITE        = $02;
  {$EXTERNALSYM FD_OOB}
  FD_OOB          = $04;
  {$EXTERNALSYM FD_ACCEPT}
  FD_ACCEPT       = $08;
  {$EXTERNALSYM FD_CONNECT}
  FD_CONNECT      = $10;
  {$EXTERNALSYM FD_CLOSE}
  FD_CLOSE        = $20;

{ All Windows Sockets error constants are biased by WSABASEERR from the "normal" }

  {$EXTERNALSYM WSABASEERR}
  WSABASEERR              = 10000;

{ Windows Sockets definitions of regular Microsoft C error constants }

  {$EXTERNALSYM WSAEINTR}
  WSAEINTR                = (WSABASEERR+4);
  {$EXTERNALSYM WSAEBADF}
  WSAEBADF                = (WSABASEERR+9);
  {$EXTERNALSYM WSAEACCES}
  WSAEACCES               = (WSABASEERR+13);
  {$EXTERNALSYM WSAEFAULT}
  WSAEFAULT               = (WSABASEERR+14);
  {$EXTERNALSYM WSAEINVAL}
  WSAEINVAL               = (WSABASEERR+22);
  {$EXTERNALSYM WSAEMFILE}
  WSAEMFILE               = (WSABASEERR+24);

{ Windows Sockets definitions of regular Berkeley error constants }

  {$EXTERNALSYM WSAEWOULDBLOCK}
  WSAEWOULDBLOCK          = (WSABASEERR+35);
  {$EXTERNALSYM WSAEINPROGRESS}
  WSAEINPROGRESS          = (WSABASEERR+36);
  {$EXTERNALSYM WSAEALREADY}
  WSAEALREADY             = (WSABASEERR+37);
  {$EXTERNALSYM WSAENOTSOCK}
  WSAENOTSOCK             = (WSABASEERR+38);
  {$EXTERNALSYM WSAEDESTADDRREQ}
  WSAEDESTADDRREQ         = (WSABASEERR+39);
  {$EXTERNALSYM WSAEMSGSIZE}
  WSAEMSGSIZE             = (WSABASEERR+40);
  {$EXTERNALSYM WSAEPROTOTYPE}
  WSAEPROTOTYPE           = (WSABASEERR+41);
  {$EXTERNALSYM WSAENOPROTOOPT}
  WSAENOPROTOOPT          = (WSABASEERR+42);
  {$EXTERNALSYM WSAEPROTONOSUPPORT}
  WSAEPROTONOSUPPORT      = (WSABASEERR+43);
  {$EXTERNALSYM WSAESOCKTNOSUPPORT}
  WSAESOCKTNOSUPPORT      = (WSABASEERR+44);
  {$EXTERNALSYM WSAEOPNOTSUPP}
  WSAEOPNOTSUPP           = (WSABASEERR+45);
  {$EXTERNALSYM WSAEPFNOSUPPORT}
  WSAEPFNOSUPPORT         = (WSABASEERR+46);
  {$EXTERNALSYM WSAEAFNOSUPPORT}
  WSAEAFNOSUPPORT         = (WSABASEERR+47);
  {$EXTERNALSYM WSAEADDRINUSE}
  WSAEADDRINUSE           = (WSABASEERR+48);
  {$EXTERNALSYM WSAEADDRNOTAVAIL}
  WSAEADDRNOTAVAIL        = (WSABASEERR+49);
  {$EXTERNALSYM WSAENETDOWN}
  WSAENETDOWN             = (WSABASEERR+50);
  {$EXTERNALSYM WSAENETUNREACH}
  WSAENETUNREACH          = (WSABASEERR+51);
  {$EXTERNALSYM WSAENETRESET}
  WSAENETRESET            = (WSABASEERR+52);
  {$EXTERNALSYM WSAECONNABORTED}
  WSAECONNABORTED         = (WSABASEERR+53);
  {$EXTERNALSYM WSAECONNRESET}
  WSAECONNRESET           = (WSABASEERR+54);
  {$EXTERNALSYM WSAENOBUFS}
  WSAENOBUFS              = (WSABASEERR+55);
  {$EXTERNALSYM WSAEISCONN}
  WSAEISCONN              = (WSABASEERR+56);
  {$EXTERNALSYM WSAENOTCONN}
  WSAENOTCONN             = (WSABASEERR+57);
  {$EXTERNALSYM WSAESHUTDOWN}
  WSAESHUTDOWN            = (WSABASEERR+58);
  {$EXTERNALSYM WSAETOOMANYREFS}
  WSAETOOMANYREFS         = (WSABASEERR+59);
  {$EXTERNALSYM WSAETIMEDOUT}
  WSAETIMEDOUT            = (WSABASEERR+60);
  {$EXTERNALSYM WSAECONNREFUSED}
  WSAECONNREFUSED         = (WSABASEERR+61);
  {$EXTERNALSYM WSAELOOP}
  WSAELOOP                = (WSABASEERR+62);
  {$EXTERNALSYM WSAENAMETOOLONG}
  WSAENAMETOOLONG         = (WSABASEERR+63);
  {$EXTERNALSYM WSAEHOSTDOWN}
  WSAEHOSTDOWN            = (WSABASEERR+64);
  {$EXTERNALSYM WSAEHOSTUNREACH}
  WSAEHOSTUNREACH         = (WSABASEERR+65);
  {$EXTERNALSYM WSAENOTEMPTY}
  WSAENOTEMPTY            = (WSABASEERR+66);
  {$EXTERNALSYM WSAEPROCLIM}
  WSAEPROCLIM             = (WSABASEERR+67);
  {$EXTERNALSYM WSAEUSERS}
  WSAEUSERS               = (WSABASEERR+68);
  {$EXTERNALSYM WSAEDQUOT}
  WSAEDQUOT               = (WSABASEERR+69);
  {$EXTERNALSYM WSAESTALE}
  WSAESTALE               = (WSABASEERR+70);
  {$EXTERNALSYM WSAEREMOTE}
  WSAEREMOTE              = (WSABASEERR+71);

  {$EXTERNALSYM WSAEDISCON}
  WSAEDISCON              = (WSABASEERR+101);

{ Extended Windows Sockets error constant definitions }

  {$EXTERNALSYM WSASYSNOTREADY}
  WSASYSNOTREADY          = (WSABASEERR+91);
  {$EXTERNALSYM WSAVERNOTSUPPORTED}
  WSAVERNOTSUPPORTED      = (WSABASEERR+92);
  {$EXTERNALSYM WSANOTINITIALISED}
  WSANOTINITIALISED       = (WSABASEERR+93);

{ Error return codes from gethostbyname() and gethostbyaddr()
  (when using the resolver). Note that these errors are
  retrieved via WSAGetLastError() and must therefore follow
  the rules for avoiding clashes with error numbers from
  specific implementations or language run-time systems.
  For this reason the codes are based at WSABASEERR+1001.
  Note also that [WSA]NO_ADDRESS is defined only for
  compatibility purposes. }

{ Authoritative Answer: Host not found }

  {$EXTERNALSYM WSAHOST_NOT_FOUND}
  WSAHOST_NOT_FOUND       = (WSABASEERR+1001);
  {$EXTERNALSYM HOST_NOT_FOUND}
  HOST_NOT_FOUND          = WSAHOST_NOT_FOUND;

{ Non-Authoritative: Host not found, or SERVERFAIL }

  {$EXTERNALSYM WSATRY_AGAIN}
  WSATRY_AGAIN            = (WSABASEERR+1002);
  {$EXTERNALSYM TRY_AGAIN}
  TRY_AGAIN               = WSATRY_AGAIN;

{ Non recoverable errors, FORMERR, REFUSED, NOTIMP }

  {$EXTERNALSYM WSANO_RECOVERY}
  WSANO_RECOVERY          = (WSABASEERR+1003);
  {$EXTERNALSYM NO_RECOVERY}
  NO_RECOVERY             = WSANO_RECOVERY;

{ Valid name, no data record of requested type }

  {$EXTERNALSYM WSANO_DATA}
  WSANO_DATA              = (WSABASEERR+1004);
  {$EXTERNALSYM NO_DATA}
  NO_DATA                 = WSANO_DATA;

{ no address, look for MX record }

  {$EXTERNALSYM WSANO_ADDRESS}
  WSANO_ADDRESS           = WSANO_DATA;
  {$EXTERNALSYM NO_ADDRESS}
  NO_ADDRESS              = WSANO_ADDRESS;

{ Windows Sockets errors redefined as regular Berkeley error constants.
  These are commented out in Windows NT to avoid conflicts with errno.h.
  Use the WSA constants instead. }

  {$EXTERNALSYM EWOULDBLOCK}
  EWOULDBLOCK        =  WSAEWOULDBLOCK;
  {$EXTERNALSYM EINPROGRESS}
  EINPROGRESS        =  WSAEINPROGRESS;
  {$EXTERNALSYM EALREADY}
  EALREADY           =  WSAEALREADY;
  {$EXTERNALSYM ENOTSOCK}
  ENOTSOCK           =  WSAENOTSOCK;
  {$EXTERNALSYM EDESTADDRREQ}
  EDESTADDRREQ       =  WSAEDESTADDRREQ;
  {$EXTERNALSYM EMSGSIZE}
  EMSGSIZE           =  WSAEMSGSIZE;
  {$EXTERNALSYM EPROTOTYPE}
  EPROTOTYPE         =  WSAEPROTOTYPE;
  {$EXTERNALSYM ENOPROTOOPT}
  ENOPROTOOPT        =  WSAENOPROTOOPT;
  {$EXTERNALSYM EPROTONOSUPPORT}
  EPROTONOSUPPORT    =  WSAEPROTONOSUPPORT;
  {$EXTERNALSYM ESOCKTNOSUPPORT}
  ESOCKTNOSUPPORT    =  WSAESOCKTNOSUPPORT;
  {$EXTERNALSYM EOPNOTSUPP}
  EOPNOTSUPP         =  WSAEOPNOTSUPP;
  {$EXTERNALSYM EPFNOSUPPORT}
  EPFNOSUPPORT       =  WSAEPFNOSUPPORT;
  {$EXTERNALSYM EAFNOSUPPORT}
  EAFNOSUPPORT       =  WSAEAFNOSUPPORT;
  {$EXTERNALSYM EADDRINUSE}
  EADDRINUSE         =  WSAEADDRINUSE;
  {$EXTERNALSYM EADDRNOTAVAIL}
  EADDRNOTAVAIL      =  WSAEADDRNOTAVAIL;
  {$EXTERNALSYM ENETDOWN}
  ENETDOWN           =  WSAENETDOWN;
  {$EXTERNALSYM ENETUNREACH}
  ENETUNREACH        =  WSAENETUNREACH;
  {$EXTERNALSYM ENETRESET}
  ENETRESET          =  WSAENETRESET;
  {$EXTERNALSYM ECONNABORTED}
  ECONNABORTED       =  WSAECONNABORTED;
  {$EXTERNALSYM ECONNRESET}
  ECONNRESET         =  WSAECONNRESET;
  {$EXTERNALSYM ENOBUFS}
  ENOBUFS            =  WSAENOBUFS;
  {$EXTERNALSYM EISCONN}
  EISCONN            =  WSAEISCONN;
  {$EXTERNALSYM ENOTCONN}
  ENOTCONN           =  WSAENOTCONN;
  {$EXTERNALSYM ESHUTDOWN}
  ESHUTDOWN          =  WSAESHUTDOWN;
  {$EXTERNALSYM ETOOMANYREFS}
  ETOOMANYREFS       =  WSAETOOMANYREFS;
  {$EXTERNALSYM ETIMEDOUT}
  ETIMEDOUT          =  WSAETIMEDOUT;
  {$EXTERNALSYM ECONNREFUSED}
  ECONNREFUSED       =  WSAECONNREFUSED;
  {$EXTERNALSYM ELOOP}
  ELOOP              =  WSAELOOP;
  {$EXTERNALSYM ENAMETOOLONG}
  ENAMETOOLONG       =  WSAENAMETOOLONG;
  {$EXTERNALSYM EHOSTDOWN}
  EHOSTDOWN          =  WSAEHOSTDOWN;
  {$EXTERNALSYM EHOSTUNREACH}
  EHOSTUNREACH       =  WSAEHOSTUNREACH;
  {$EXTERNALSYM ENOTEMPTY}
  ENOTEMPTY          =  WSAENOTEMPTY;
  {$EXTERNALSYM EPROCLIM}
  EPROCLIM           =  WSAEPROCLIM;
  {$EXTERNALSYM EUSERS}
  EUSERS             =  WSAEUSERS;
  {$EXTERNALSYM EDQUOT}
  EDQUOT             =  WSAEDQUOT;
  {$EXTERNALSYM ESTALE}
  ESTALE             =  WSAESTALE;
  {$EXTERNALSYM EREMOTE}
  EREMOTE            =  WSAEREMOTE;


{ Socket function prototypes }

{$EXTERNALSYM accept}
function accept(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket; stdcall;
{$EXTERNALSYM bind}
function bind(s: TSocket; var addr: TSockAddr; namelen: Integer): Integer; stdcall;
{$EXTERNALSYM closesocket}
function closesocket(s: TSocket): Integer; stdcall;
{$EXTERNALSYM connect}
function connect(s: TSocket; var name: TSockAddr; namelen: Integer): Integer; stdcall;
{$EXTERNALSYM ioctlsocket}
function ioctlsocket(s: TSocket; cmd: DWORD; var arg: u_long): Integer; stdcall;
{$EXTERNALSYM getpeername}
function getpeername(s: TSocket; var name: TSockAddr; var namelen: Integer): Integer; stdcall;
{$EXTERNALSYM getsockname}
function getsockname(s: TSocket; var name: TSockAddr; var namelen: Integer): Integer; stdcall;
{$EXTERNALSYM getsockopt}
function getsockopt(s: TSocket; level, optname: Integer; optval: PAnsiChar; var optlen: Integer): Integer; stdcall;
{$EXTERNALSYM htonl}
function htonl(hostlong: u_long): u_long; stdcall;
{$EXTERNALSYM htons}
function htons(hostshort: u_short): u_short; stdcall;
{$EXTERNALSYM inet_addr}
function inet_addr(cp: PAnsiChar): u_long; stdcall; {PInAddr;}  { TInAddr }
{$EXTERNALSYM inet_ntoa}
function inet_ntoa(inaddr: TInAddr): PAnsiChar; stdcall;
{$EXTERNALSYM listen}
function listen(s: TSocket; backlog: Integer): Integer; stdcall;
{$EXTERNALSYM ntohl}
function ntohl(netlong: u_long): u_long; stdcall;
{$EXTERNALSYM ntohs}
function ntohs(netshort: u_short): u_short; stdcall;
{$EXTERNALSYM recv}
function recv(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
{$EXTERNALSYM recvfrom}
function recvfrom(s: TSocket; var Buf; len, flags: Integer;
  var from: TSockAddr; var fromlen: Integer): Integer; stdcall;
{$EXTERNALSYM select}
function select(nfds: Integer; readfds, writefds, exceptfds: PFDSet;
  timeout: PTimeVal): Longint; stdcall;
{$EXTERNALSYM send}
function send(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
{$EXTERNALSYM sendto}
function sendto(s: TSocket; var Buf; len, flags: Integer; var addrto: TSockAddr;
  tolen: Integer): Integer; stdcall;
{$EXTERNALSYM setsockopt}
function setsockopt(s: TSocket; level, optname: Integer; optval: PAnsiChar;
  optlen: Integer): Integer; stdcall;
{$EXTERNALSYM shutdown}
function shutdown(s: TSocket; how: Integer): Integer; stdcall;
{$EXTERNALSYM socket}
function socket(af, Struct, protocol: Integer): TSocket; stdcall;
{$EXTERNALSYM gethostbyaddr}
function gethostbyaddr(addr: Pointer; len, Struct: Integer): PHostEnt; stdcall;
{$EXTERNALSYM gethostbyname}
function gethostbyname(name: PAnsiChar): PHostEnt; stdcall;
{$EXTERNALSYM gethostname}
function gethostname(name: PAnsiChar; len: Integer): Integer; stdcall;
{$EXTERNALSYM getservbyport}
function getservbyport(port: Integer; proto: PAnsiChar): PServEnt; stdcall;
{$EXTERNALSYM getservbyname}
function getservbyname(name, proto: PAnsiChar): PServEnt; stdcall;
{$EXTERNALSYM getprotobynumber}
function getprotobynumber(proto: Integer): PProtoEnt; stdcall;
{$EXTERNALSYM getprotobyname}
function getprotobyname(name: PAnsiChar): PProtoEnt; stdcall;
{$EXTERNALSYM WSAStartup}
function WSAStartup(wVersionRequired: word; var WSData: TWSAData): Integer; stdcall;
{$EXTERNALSYM WSACleanup}
function WSACleanup: Integer; stdcall;
{$EXTERNALSYM WSASetLastError}
procedure WSASetLastError(iError: Integer); stdcall;
{$EXTERNALSYM WSAGetLastError}
function WSAGetLastError: Integer; stdcall;
{$EXTERNALSYM WSAIsBlocking}
function WSAIsBlocking: BOOL; stdcall;
{$EXTERNALSYM WSAUnhookBlockingHook}
function WSAUnhookBlockingHook: Integer; stdcall;
{$EXTERNALSYM WSASetBlockingHook}
function WSASetBlockingHook(lpBlockFunc: TFarProc): TFarProc; stdcall;
{$EXTERNALSYM WSACancelBlockingCall}
function WSACancelBlockingCall: Integer; stdcall;
{$EXTERNALSYM WSAAsyncGetServByName}
function WSAAsyncGetServByName(HWindow: HWND; wMsg: u_int;
  name, proto, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
{$EXTERNALSYM WSAAsyncGetServByPort}
function WSAAsyncGetServByPort( HWindow: HWND; wMsg, port: u_int;
  proto, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
{$EXTERNALSYM WSAAsyncGetProtoByName}
function WSAAsyncGetProtoByName(HWindow: HWND; wMsg: u_int;
  name, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
{$EXTERNALSYM WSAAsyncGetProtoByNumber}
function WSAAsyncGetProtoByNumber(HWindow: HWND; wMsg: u_int; number: Integer;
  buf: PAnsiChar; buflen: Integer): THandle; stdcall;
{$EXTERNALSYM WSAAsyncGetHostByName}
function WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int;
  name, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
{$EXTERNALSYM WSAAsyncGetHostByAddr}
function WSAAsyncGetHostByAddr(HWindow: HWND; wMsg: u_int; addr: PAnsiChar;
  len, Struct: Integer; buf: PAnsiChar; buflen: Integer): THandle; stdcall;
{$EXTERNALSYM WSACancelAsyncRequest}
function WSACancelAsyncRequest(hAsyncTaskHandle: THandle): Integer; stdcall;
{$EXTERNALSYM WSAAsyncSelect}
function WSAAsyncSelect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer; stdcall;
{$EXTERNALSYM WSARecvEx}
function WSARecvEx(s: TSocket; var buf; len: Integer; var flags: Integer): Integer; stdcall;
{$EXTERNALSYM __WSAFDIsSet}
function __WSAFDIsSet(s: TSocket; var FDSet: TFDSet): Bool; stdcall;

{$EXTERNALSYM TransmitFile}
function TransmitFile(hSocket: TSocket; hFile: THandle; nNumberOfBytesToWrite: DWORD;
  nNumberOfBytesPerSend: DWORD; lpOverlapped: POverlapped;
  lpTransmitBuffers: PTransmitFileBuffers; dwReserved: DWORD): BOOL; stdcall;

{$EXTERNALSYM AcceptEx}
function AcceptEx(sListenSocket, sAcceptSocket: TSocket;
  lpOutputBuffer: Pointer; dwReceiveDataLength, dwLocalAddressLength,
  dwRemoteAddressLength: DWORD; var lpdwBytesReceived: DWORD;
  lpOverlapped: POverlapped): BOOL; stdcall;

{$EXTERNALSYM GetAcceptExSockaddrs}
procedure GetAcceptExSockaddrs(lpOutputBuffer: Pointer;
  dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD;
  var LocalSockaddr: PSockAddr; var LocalSockaddrLength: Integer;
  var RemoteSockaddr: PSockAddr; var RemoteSockaddrLength: Integer); stdcall;

{$EXTERNALSYM WSAMakeSyncReply}
function WSAMakeSyncReply(Buflen, Error: Word): Longint;
{$EXTERNALSYM WSAMakeSelectReply}
function WSAMakeSelectReply(Event, Error: Word): Longint;
{$EXTERNALSYM WSAGetAsyncBuflen}
function WSAGetAsyncBuflen(Param: Longint): Word;
{$EXTERNALSYM WSAGetAsyncError}
function WSAGetAsyncError(Param: Longint): Word;
{$EXTERNALSYM WSAGetSelectEvent}
function WSAGetSelectEvent(Param: Longint): Word;
{$EXTERNALSYM WSAGetSelectError}
function WSAGetSelectError(Param: Longint): Word;

{$EXTERNALSYM FD_CLR}
procedure FD_CLR(Socket: TSocket; var FDSet: TFDSet);
{$EXTERNALSYM FD_ISSET}
function FD_ISSET(Socket: TSocket; var FDSet: TFDSet): Boolean;
{$EXTERNALSYM FD_SET}
procedure FD_SET(Socket: TSocket; var FDSet: TFDSet); // renamed due to conflict with fd_set (above)
{$EXTERNALSYM FD_ZERO}
procedure FD_ZERO(var FDSet: TFDSet);

implementation

const
  winsocket = 'wsock32.dll';

function WSAMakeSyncReply;
begin
  WSAMakeSyncReply:= MakeLong(Buflen, Error);
end;

function WSAMakeSelectReply;
begin
  WSAMakeSelectReply:= MakeLong(Event, Error);
end;

function WSAGetAsyncBuflen;
begin
  WSAGetAsyncBuflen:= LOWORD(Param);
end;

function WSAGetAsyncError;
begin
  WSAGetAsyncError:= HIWORD(Param);
end;

function WSAGetSelectEvent;
begin
  WSAGetSelectEvent:= LOWORD(Param);
end;

function WSAGetSelectError;
begin
  WSAGetSelectError:= HIWORD(Param);
end;

procedure FD_CLR(Socket: TSocket; var FDSet: TFDSet);
var
  I: Integer;
begin
  I := 0;
  while I < FDSet.fd_count do
  begin
    if FDSet.fd_array[I] = Socket then
    begin
      while I < FDSet.fd_count - 1 do
      begin
        FDSet.fd_array[I] := FDSet.fd_array[I + 1];
        Inc(I);
      end;
      Dec(FDSet.fd_count);
      Break;
    end;
    Inc(I);
  end;
end;

function FD_ISSET(Socket: TSocket; var FDSet: TFDSet): Boolean;
begin
  Result := __WSAFDIsSet(Socket, FDSet);
end;

procedure FD_SET(Socket: TSocket; var FDSet: TFDSet);
begin
  if FDSet.fd_count < FD_SETSIZE then
  begin
    FDSet.fd_array[FDSet.fd_count] := Socket;
    Inc(FDSet.fd_count);
  end;
end;

procedure FD_ZERO(var FDSet: TFDSet);
begin
  FDSet.fd_count := 0;
end;

function accept;            external    winsocket name 'accept';
function bind;              external    winsocket name 'bind';
function closesocket;       external    winsocket name 'closesocket';
function connect;           external    winsocket name 'connect';
function getpeername;       external    winsocket name 'getpeername';
function getsockname;       external    winsocket name 'getsockname';
function getsockopt;        external    winsocket name 'getsockopt';
function htonl;             external    winsocket name 'htonl';
function htons;             external    winsocket name 'htons';
function inet_addr;         external    winsocket name 'inet_addr';
function inet_ntoa;         external    winsocket name 'inet_ntoa';
function ioctlsocket;       external    winsocket name 'ioctlsocket';
function listen;            external    winsocket name 'listen';
function ntohl;             external    winsocket name 'ntohl';
function ntohs;             external    winsocket name 'ntohs';
function recv;              external    winsocket name 'recv';
function recvfrom;          external    winsocket name 'recvfrom';
function select;            external    winsocket name 'select';
function send;              external    winsocket name 'send';
function sendto;            external    winsocket name 'sendto';
function setsockopt;        external    winsocket name 'setsockopt';
function shutdown;          external    winsocket name 'shutdown';
function socket;            external    winsocket name 'socket';

function gethostbyaddr;     external    winsocket name 'gethostbyaddr';
function gethostbyname;     external    winsocket name 'gethostbyname';
function getprotobyname;    external    winsocket name 'getprotobyname';
function getprotobynumber;  external    winsocket name 'getprotobynumber';
function getservbyname;     external    winsocket name 'getservbyname';
function getservbyport;     external    winsocket name 'getservbyport';
function gethostname;       external    winsocket name 'gethostname';

function WSAAsyncSelect;    external    winsocket name 'WSAAsyncSelect';
function WSARecvEx;         external    winsocket name 'WSARecvEx';
function WSAAsyncGetHostByAddr; external winsocket name 'WSAAsyncGetHostByAddr';
function WSAAsyncGetHostByName; external winsocket name 'WSAAsyncGetHostByName';
function WSAAsyncGetProtoByNumber; external winsocket name 'WSAAsyncGetProtoByNumber';
function WSAAsyncGetProtoByName; external winsocket name 'WSAAsyncGetProtoByName';
function WSAAsyncGetServByPort; external winsocket name 'WSAAsyncGetServByPort';
function WSAAsyncGetServByName; external winsocket name 'WSAAsyncGetServByName';
function WSACancelAsyncRequest; external winsocket name 'WSACancelAsyncRequest';
function WSASetBlockingHook; external    winsocket name 'WSASetBlockingHook';
function WSAUnhookBlockingHook; external winsocket name 'WSAUnhookBlockingHook';
function WSAGetLastError;    external    winsocket name 'WSAGetLastError';
procedure WSASetLastError;   external    winsocket name 'WSASetLastError';
function WSACancelBlockingCall; external winsocket name 'WSACancelBlockingCall';
function WSAIsBlocking;     external     winsocket name 'WSAIsBlocking';
function WSAStartup;        external     winsocket name 'WSAStartup';
function WSACleanup;        external     winsocket name 'WSACleanup';
function __WSAFDIsSet;      external     winsocket name '__WSAFDIsSet';

function TransmitFile;      external     winsocket name 'TransmitFile';
function AcceptEx;          external     winsocket name 'AcceptEx';
procedure GetAcceptExSockaddrs;  external    winsocket name 'GetAcceptExSockaddrs';

end.
