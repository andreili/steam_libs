unit ISteamNetworking004_;

interface

uses
  SteamTypes, NetworkingCommon;

type
  ISteamNetworking004 = class (TObject)
    procedure _Destructor(); virtual; abstract;

    ////////////////////////////////////////////////////////////////////////////////////////////
    // Session-less connection functions
    //    automatically establishes NAT-traversing or Relay server connections

    // Sends a P2P packet to the specified user
    // UDP-like, unreliable and a max packet size of 1200 bytes
    // the first packet send may be delayed as the NAT-traversal code runs
    // if we can't get through to the user, an error will be posted via the callback P2PSessionConnectFail_t
    // see EP2PSend enum above for the descriptions of the different ways of sending packets
    function SendP2PPacket(steamIDRemote: CSteamID; pubData: Pointer; cubData: uint32; eP2PSendType: EP2PSend; unk: int): boolean; virtual; abstract;

    // returns true if any data is available for read, and the amount of data that will need to be read
    function IsP2PPacketAvailable(var pcubMsgSize: uint32; unk: int): boolean; virtual; abstract;

    // reads in a packet that has been sent from another user via SendP2PPacket()
    // returns the size of the message and the steamID of the user who sent it in the last two parameters
    // if the buffer passed in is too small, the message will be truncated
    // this call is not blocking, and will return false if no data is available
    function ReadP2PPacket(pubDest: Pointer; cubDest: uint32; var pcubMsgSize: uint32; var psteamIDRemote: CSteamID; unk: int): boolean; virtual; abstract;

    // AcceptP2PSessionWithUser() should only be called in response to a P2PSessionRequest_t callback
    // P2PSessionRequest_t will be posted if another user tries to send you a packet that you haven't talked to yet
    // if you don't want to talk to the user, just ignore the request
    // if the user continues to send you packets, another P2PSessionRequest_t will be posted periodically
    // this may be called multiple times for a single user
    // (if you've called SendP2PPacket() on the other user, this implicitly accepts the session request)
    function AcceptP2PSessionWithUser(steamIDRemote: CSteamID): boolean; virtual; abstract;

    // call CloseP2PSessionWithUser() when you're done talking to a user, will free up resources under-the-hood
    // if the remote user tries to send data to you again, another P2PSessionRequest_t callback will be posted
    function CloseP2PSessionWithUser(steamIDRemote: CSteamID): boolean; virtual; abstract;

    // fills out P2PSessionState_t structure with details about the underlying connection to the user
    // should only needed for debugging purposes
    // returns false if no connection exists to the specified user
    function GetP2PSessionState(steamIDRemote: CSteamID; var pConnectionState: P2PSessionState_t): boolean; virtual; abstract;

    ////////////////////////////////////////////////////////////////////////////////////////////
    // LISTEN / CONNECT style interface functions
    //
    // This is an older set of functions designed around the Berkeley TCP sockets model
    // it's preferential that you use the above P2P functions, they're more robust
    // and these older functions will be removed eventually
    //
    ////////////////////////////////////////////////////////////////////////////////////////////

    // creates a socket and listens others to connect
    // will trigger a SocketStatusCallback_t callback on another client connecting
    // nVirtualP2PPort is the unique ID that the client will connect to, in case you have multiple ports
    //		this can usually just be 0 unless you want multiple sets of connections
    // unIP is the local IP address to bind to
    //		pass in 0 if you just want the default local IP
    // unPort is the port to use
    //		pass in 0 if you don't want users to be able to connect via IP/Port, but expect to be always peer-to-peer connections only
    function CreateListenSocket(nVirtualP2PPort: int; nIP: uint32; nPort: uint16; bAllowUseOfPacketRelay: boolean): SNetListenSocket_t; virtual; abstract;
    // creates a socket and begin connection to a remote destination
    // can connect via a known steamID (client or game server), or directly to an IP
    // on success will trigger a SocketStatusCallback_t callback
    // on failure or timeout will trigger a SocketStatusCallback_t callback with a failure code in m_eSNetSocketState
    function CreateP2PConnectionSocket(steamIDTarget: CSteamID; nVirtualPort, nTimeoutSec: int; bAllowUseOfPacketRelay: boolean): SNetSocket_t; virtual; abstract;
    function CreateConnectionSocket(nIP: uint32; nPort: uint16; nTimeoutSec: int): SNetSocket_t; virtual; abstract;
    // disconnects the connection to the socket, if any, and invalidates the handle
    // any unread data on the socket will be thrown away
    // if bNotifyRemoteEnd is set, socket will not be completely destroyed until the remote end acknowledges the disconnect
    function DestroySocket(hSocket: SNetSocket_t; bNotifyRemoteEnd: bool): bool; virtual; abstract;
    // destroying a listen socket will automatically kill all the regular sockets generated from it
    function DestroyListenSocket(hSocket: SNetListenSocket_t; bNotifyRemoteEnd: bool): bool; virtual; abstract;
    // sending data
    // must be a handle to a connected socket
    // data is all sent via UDP, and thus send sizes are limited to 1200 bytes; after this, many routers will start dropping packets
    // use the reliable flag with caution; although the resend rate is pretty aggressive,
    // it can still cause stalls in receiving data (like TCP)
    function SendDataOnSocket(hSocket: SNetSocket_t; pubData: Pointer; cubData: uint32; bReliable: bool): bool; virtual; abstract;
    // receiving data
    // returns false if there is no data remaining
    // fills out *pcubMsgSize with the size of the next message, in bytes
    function IsDataAvailableOnSocket(hSocket: SNetSocket_t; var cubMsgSize: uint32): bool; virtual; abstract;
    // fills in pubDest with the contents of the message
    // messages are always complete, of the same size as was sent (i.e. packetized, not streaming)
    // if *pcubMsgSize < cubDest, only partial data is written
    // returns false if no data is available
    function RetrieveDataFromSocket(hSocket: SNetSocket_t; pubDest: Pointer; cubDest: uint32; var pcubMsgSize: uint32): bool; virtual; abstract;
    // checks for data from any socket that has been connected off this listen socket
    // returns false if there is no data remaining
    // fills out *pcubMsgSize with the size of the next message, in bytes
    // fills out *phSocket with the socket that data is available on
    function IsDataAvailable(hListenSocket: SNetListenSocket_t; var pcubMsgSize: uint32; var phSocket: SNetSocket_t): bool; virtual; abstract;
    // retrieves data from any socket that has been connected off this listen socket
    // fills in pubDest with the contents of the message
    // messages are always complete, of the same size as was sent (i.e. packetized, not streaming)
    // if *pcubMsgSize < cubDest, only partial data is written
    // returns false if no data is available
    // fills out *phSocket with the socket that data is available on
    function RetrieveData(hListenSocket: SNetListenSocket_t; pubDest: Pointer; cubDest: uint32; var cubMsgSize: uint32; var phSocket: SNetSocket_t): bool; virtual; abstract;
    // returns information about the specified socket, filling out the contents of the pointers
    function GetSocketInfo(hSocket: SNetSocket_t; var pSteamIDRemote: CSteamID; var peSocketStatus: int; var punIPRemote: uint32; var punPortRemote: uint16): bool; virtual; abstract;
    // returns which local port the listen socket is bound to
    // *pnIP and *pnPort will be 0 if the socket is set to listen for P2P connections only
    function GetListenSocketInfo(hListenSocket: SNetListenSocket_t; var pnIP: uint32; var pnPort: uint16): bool; virtual; abstract;

    // returns true to describe how the socket ended up connecting
    function GetSocketConnectionType(hSocket: SNetSocket_t): ESNetSocketConnectionType; virtual; abstract;

    // max packet size, in bytes
    function GetMaxPacketSize(hSocket: SNetSocket_t): int; virtual; abstract;
  end;

implementation

end.
