unit NetworkingCommon;

interface

{$I Defines.inc}

uses
  SteamTypes;

const
  STEAMNETWORKING_INTERFACE_VERSION_001 = 'SteamNetworking001';
  STEAMNETWORKING_INTERFACE_VERSION_002 = 'SteamNetworking002';
  STEAMNETWORKING_INTERFACE_VERSION_003 = 'SteamNetworking003';
  STEAMNETWORKING_INTERFACE_VERSION_004 = 'SteamNetworking004';

type
  // SendP2PPacket() send types
  // Typically k_EP2PSendUnreliable is what you want for UDP-like packets, k_EP2PSendReliable for TCP-like packets
  EP2PSend =
    (// Basic UDP send. Packets can't be bigger than 1200 bytes (your typical MTU size). Can be lost, or arrive out of order (rare).
     // The sending API does have some knowledge of the underlying connection, so if there is no NAT-traversal accomplished or
     // there is a recognized adjustment happening on the connection, the packet will be batched until the connection is open again.);
     k_EP2PSendUnreliable = 0,
     // As above, but if the underlying p2p connection isn't yet established the packet will just be thrown away. Using this on the first
     // packet sent to a remote host almost guarantees the packet will be dropped.
     // This is only really useful for kinds of data that should never buffer up, i.e. voice payload packets
     k_EP2PSendUnreliableNoDelay = 1,
     	// Reliable message send. Can send up to 1MB of data in a single message.
     // Does fragmentation/re-assembly of messages under the hood, as well as a sliding window for efficient sends of large chunks of data.
     k_EP2PSendReliable = 2,
     	// As above, but applies the Nagle algorithm to the send - sends will accumulate
     // until the current MTU size (typically ~1200 bytes, but can change) or ~200ms has passed (Nagle algorithm).
     // Useful if you want to send a set of smaller messages but have the coalesced into a single packet
     // Since the reliable stream is all ordered, you can do several small message sends with k_EP2PSendReliableWithBuffering and then
     // do a normal k_EP2PSendReliable to force all the buffered data to be sent.
     k_EP2PSendReliableWithBuffering = 3);

  // list of possible errors returned by SendP2PPacket() API
  // these will be posted in the P2PSessionConnectFail_t callback
  EP2PSessionError =
    (k_EP2PSessionErrorNone = 0,
     k_EP2PSessionErrorNotRunningApp = 1,             // target is not running the same game
     k_EP2PSessionErrorNoRightsToApp = 2,             // local user doesn't own the app that is running
     k_EP2PSessionErrorDestinationNotLoggedIn = 3,    // target user isn't connected to Steam
     k_EP2PSessionErrorTimeout = 4);                  // target isn't responding, perhaps not calling AcceptP2PSessionWithUser()
     // corporate firewalls can also block this (NAT traversal is not firewall traversal)
     // make sure that UDP ports 3478, 4379, and 4380 are open in an outbound direction

  // describes how the socket is currently connected
  ESNetSocketConnectionType =
    (k_ESNetSocketConnectionTypeNotConnected = 0,
     k_ESNetSocketConnectionTypeUDP = 1,
     k_ESNetSocketConnectionTypeUDPRelay = 2);

  // connection progress indicators
  ESNetSocketState =
    (k_ESNetSocketStateInvalid = 0,
     	// communication is valid
     k_ESNetSocketStateConnected = 1,
     	// states while establishing a connection
     k_ESNetSocketStateInitiated = 10,                // the connection state machine has started
     	// p2p connections
     k_ESNetSocketStateLocalCandidatesFound = 11,     // we've found our local IP info
     k_ESNetSocketStateReceivedRemoteCandidates = 12, // we've received information from the remote machine, via the Steam back-end, about their IP info
     	// direct connections
     k_ESNetSocketStateChallengeHandshake = 15,       // we've received a challenge packet from the server
     	// failure states
     k_ESNetSocketStateDisconnecting = 21,            // the API shut it down, and we're in the process of telling the other end
     k_ESNetSocketStateLocalDisconnect = 22,          // the API shut it down, and we've completed shutdown
     k_ESNetSocketStateTimeoutDuringConnect = 23,     // we timed out while trying to creating the connection
     k_ESNetSocketStateRemoteEndDisconnected = 24,    // the remote end has disconnected from us
     k_ESNetSocketStateConnectionBroken = 25);        // connection has been broken; either the other end has disappeared or our local network connection has broke

  // connection state to a specified user, returned by GetP2PSessionState()
  // this is under-the-hood info about what's going on with a SendP2PPacket(), shouldn't be needed except for debuggin
  P2PSessionState_t = record
    m_bConnectionActive,            // true if we've got an active open connection
    m_bConnecting,                  // true if we're currently trying to establish a connection
    m_eP2PSessionError,             // last error recorded (see enum above)
    m_bUsingRelay: uint8;           // true if it's going through a relay server (TURN)
    m_nBytesQueuedForSend,
    m_nPacketsQueuedForSend: int32;
    m_nRemoteIP: uint32;            // potential IP:Port of remote host. Could be TURN server.
    m_nRemotePort: uint16;          // Only exists for compatibility with older authentication api's
  end;

  // callback notification - status of a socket has changed
  SocketStatusCallback_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamNetworkingCallbacks +1
    {$ENDIF}
    m_hSocket: SNetSocket_t;              // the socket used to send/receive data to the remote host
    m_hListenSocket: SNetListenSocket_t;  // this is the server socket that we were listening on; NULL if this was an outgoing connection
    m_steamIDRemote: CSteamID;            // remote steamID we have connected to, if it has one
    m_eSNetSocketState: int;              // socket state, ESNetSocketState
  end;

  // callback notification - a user wants to talk to us over the P2P channel via the SendP2PPacket() API
  // in response, a call to AcceptP2PPacketsFromUser() needs to be made, if you want to talk with them
  P2PSessionRequest_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamNetworkingCallbacks +2
    {$ENDIF}
    m_steamIDRemote: CSteamID;   // user who wants to talk to us
  end;

  // callback notification - packets can't get through to the specified user via the SendP2PPacket() API
  // all packets queued packets unsent at this point will be dropped
  // further attempts to send will retry making the connection (but will be dropped if we fail again)
  P2PSessionConnectFail_t = record
    {$IFDEF ICALLBACKS}
    k_iCallback: int;//k_iSteamNetworkingCallbacks +3
    {$ENDIF}
    m_steamIDRemote: CSteamID;    // user we were sending packets to
    m_eP2PSessionError: uint8;    // EP2PSessionError indicating why we're having trouble
  end;

implementation

end.
